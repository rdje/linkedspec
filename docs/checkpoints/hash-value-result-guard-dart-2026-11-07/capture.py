"""One finite Dart acquisition; retain declared inputs before SDK compilation/use."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile
import traceback

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
phase,mode=sys.argv[1:]
assert phase in ('intake','before','after','after-intake','direct','format')
assert mode in ('routes','test','format')
OUT=BASE/phase;OUT.mkdir()
env=dict(os.environ,TERM='dumb',NO_COLOR='1')
custody=[]
PROBE=Path('dart/tool/probe_hash_value_results.dart')
NORMAL=Path('dart/test/hash_value_result_guard_composition_test.dart')
PROFILE=Path('tests/fixtures/hash_value_result_guard_dart_profiles.json')
CONFIG=Path('dart/.dart_tool/package_config.json')


def freeze(tag,paths):
    files={}
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev==ROOT.stat().st_dev
        body=path.read_bytes()
        files[str(path)]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest(),mode=path.stat().st_mode & 0o777)
    target=OUT/(tag+'-before-first-run.tar.gz')
    with tarfile.open(target,'w:gz') as archive:
        for path in files: archive.add(path,arcname=path,recursive=False)
    with tarfile.open(target) as archive:
        assert {m.name:(hashlib.sha256(archive.extractfile(m).read()).hexdigest(),m.mode & 0o777) for m in archive}=={p:(r['sha256'],r['mode']) for p,r in files.items()}
    custody.append(dict(tag=tag,archive=str(target),files=files))
    (OUT/'custody.json').write_text(json.dumps(custody,indent=2,sort_keys=True)+'\n')


def run(tag,args,cwd=Path('dart'),accepted=(0,)):
    command=['bash',os.path.relpath(ROOT/'tools/run_dart_project_data.sh',ROOT/cwd),*args]
    (OUT/(tag+'-command.json')).write_text(json.dumps(dict(cwd=str(cwd),argv=command,environment=dict(TERM='dumb',NO_COLOR='1')),indent=2)+'\n')
    result=subprocess.run(command,cwd=ROOT/cwd,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for channel in ('stdout','stderr'):
        (OUT/(tag+'-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(result,channel),mtime=0))
    (OUT/(tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
    assert result.returncode in accepted,f'{tag}: exit{result.returncode}; complete raw channels retained'
    return result


def verify():
    for row in custody:
        for name,expected in row['files'].items():
            # The pre-resolution routing image is historical. The resolved image
            # below is the actual SDK routing input and must remain byte-exact.
            if row['tag']=='root' and name==str(CONFIG): continue
            path=Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest()==expected['sha256'],name
            assert path.stat().st_mode & 0o777==expected['mode']


def main():
    (OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
    paths=[Path(p) for p in subprocess.check_output(['git','ls-files','dart','tests/fixtures'],text=True).splitlines()]
    paths += [Path('specs/user_function_definition.spec'),PROBE,BASE/'prepare.py',BASE/'format_probe.py',BASE/'capture.py',BASE/'cases.json',BASE/'profile-sources.json']
    paths += [Path(p) for p in ('tools/run_dart_project_data.sh','tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh')]
    if CONFIG.exists(): paths.append(CONFIG)
    for path in (NORMAL,PROFILE,BASE/'freeze_profiles.py'):
        if path.exists(): paths.append(path)
    if mode=='routes':
        (OUT/'cases.json').write_bytes((BASE/'cases.json').read_bytes())
        paths.append(OUT/'cases.json')
    freeze('root',paths)
    run('version',['--version'])
    run('resolution',['pub','get','--offline','--enforce-lockfile'])
    freeze('resolved',[Path('dart/pubspec.yaml'),Path('dart/pubspec.lock'),*Path('dart/.dart_tool').glob('*.json')])
    if mode=='routes':
        run('analysis',['analyze','--fatal-infos','--fatal-warnings','tool/probe_hash_value_results.dart'])
        fresh=OUT/'fresh';fresh.mkdir()
        (fresh/'pubspec.yaml').write_text('name: hash_value_dart_fresh\npublish_to: none\nenvironment:\n  sdk: ">=3.9.0 <4.0.0"\ndependencies:\n  linkedspec_dart:\n    path: ../../../../../dart\n')
        run('native',['run','tool/probe_hash_value_results.dart',str(OUT)])
        freeze('emitted',list(fresh.rglob('*.dart'))+list((fresh/'inputs').glob('*.json'))+[fresh/'pubspec.yaml'])
        run('fresh-resolution',['pub','get','--offline'],fresh)
        freeze('fresh',list(fresh.rglob('*.dart'))+list((fresh/'inputs').glob('*.json'))+[fresh/'pubspec.yaml',fresh/'pubspec.lock',*list((fresh/'.dart_tool').glob('*.json'))])
        run('fresh-analysis',['analyze','--fatal-infos','--fatal-warnings'],fresh)
        run('fresh',['run','bin/main.dart'],fresh)
        verify()
        assert fresh.parent==OUT and not fresh.is_symlink()
        shutil.rmtree(fresh)
    elif mode=='test':
        run('analysis',['analyze','--fatal-infos','--fatal-warnings','lib/src/runtime/interpreter.dart','test/hash_value_result_guard_composition_test.dart','tool/probe_hash_value_results.dart'])
        tests=['test/hash_value_result_guard_composition_test.dart']
        if phase=='direct': tests += ['test/hash_view_result_guard_composition_test.dart','test/constructor_result_composition_test.dart','test/value_copy_test.dart','test/receiver_copy_arity_test.dart']
        result=run('normal',['test','--reporter','expanded','--concurrency=1',*tests],accepted=(0,1) if phase=='before' else (0,))
        frames=re.findall(rb'HASH_VALUE_DART_NORMAL ([a-z0-9_]+) (\{[^\n]+)',result.stdout)
        assert len(frames)==len({key for key,_ in frames})==89,'actual semantic frames required'
        assert b'All tests passed!' in result.stdout or b'Some tests failed.' in result.stdout
        verify()
    else:
        run('format',['format','--output=none','--set-exit-if-changed','lib/src/runtime/interpreter.dart','test/hash_value_result_guard_composition_test.dart','tool/probe_hash_value_results.dart'])
        verify()
    print(phase+': declared input/artifact/full-channel acquisition completed; grade actual observations')


try:
    main()
except BaseException:
    (OUT/'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    raise
