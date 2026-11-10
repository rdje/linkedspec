"""Actual old/current own-Dart images at one private SDK path; checkout untouched."""
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
from urllib.parse import unquote,urljoin,urlparse

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
CONTROL=BASE/'control-owner'
OWNER=Path('dart/lib/src/runtime/interpreter.dart')
NORMAL=Path('dart/test/array_transform_result_guard_composition_test.dart')
PROFILE=Path('tests/fixtures/array_transform_result_guard_dart_profiles.json')
CASES=BASE/'cases.json'
GRAMMAR=Path('specs/user_function_definition.spec')
ACTIVATION='155f5f6444b30319a278a78e53265e4e3adda699'
phase=sys.argv[1];assert phase in ('private-inverse','private-restored')
OUT=BASE/phase;OUT.mkdir()
env=dict(os.environ,TERM='dumb',NO_COLOR='1')
custody=[]


def freeze(tag,paths):
    files={}
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
        assert path.stat().st_dev==ROOT.stat().st_dev
        body=path.read_bytes();files[str(path)]=dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),mode=path.stat().st_mode & 0o777)
    target=OUT/(tag+'-before-first-run.tar.gz')
    with tarfile.open(target,'w:gz') as archive:
        for name in files: archive.add(name,arcname=name,recursive=False)
    with tarfile.open(target) as archive:
        assert {m.name:(hashlib.sha256(archive.extractfile(m).read()).hexdigest(),m.mode & 0o777) for m in archive}=={p:(r['sha256'],r['mode']) for p,r in files.items()}
    custody.append(dict(tag=tag,archive=str(target),files=files))
    (OUT/'custody.json').write_text(json.dumps(custody,indent=2,sort_keys=True)+'\n')


def run(tag,args,accepted=(0,)):
    cwd=CONTROL/'dart'
    command=['bash',os.path.relpath(ROOT/'tools/run_dart_project_data.sh',ROOT/cwd),*args]
    (OUT/(tag+'-command.json')).write_text(json.dumps(dict(cwd=str(cwd),argv=command,environment=dict(TERM='dumb',NO_COLOR='1')),indent=2)+'\n')
    result=subprocess.run(command,cwd=ROOT/cwd,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for channel in ('stdout','stderr'): (OUT/(tag+'-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(result,channel),mtime=0))
    (OUT/(tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
    assert result.returncode in accepted,f'{tag} exit{result.returncode}; complete channels retained'
    return result


def frames(body):
    result={}
    for match in re.finditer(rb'ARRAY_TRANSFORM_DART_NORMAL ([a-z0-9_]+) (\{[^\n]+)',body):
        key=match[1].decode();assert key not in result;result[key]=json.loads(match[2])
    return result


def main():
    assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()==ACTIVATION
    paths=[Path(p) for p in subprocess.check_output(['git','ls-files','dart'],text=True).splitlines()]
    paths=sorted(set(paths+[NORMAL,PROFILE,CASES,GRAMMAR]))
    if phase=='private-inverse':
        assert not CONTROL.exists()
        for source in paths:
            assert source.is_file() and not source.is_symlink()
            target=CONTROL/source;target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(source,target)
    else:
        assert CONTROL.is_dir() and not CONTROL.is_symlink()
        prior=json.loads((BASE/'private-inverse/custody.json').read_bytes())[0]['files']
        for name,row in prior.items():
            if name.startswith(str(CONTROL)+'/'):
                path=Path(name);assert hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256']
                assert path.stat().st_mode & 0o777==row['mode']
    candidate=OWNER.read_bytes()
    old=subprocess.check_output(['git','show',ACTIVATION+':'+str(OWNER)])
    assert candidate!=old
    (CONTROL/OWNER).write_bytes(old if phase=='private-inverse' else candidate)
    declared=[CONTROL/path for path in paths]+[OWNER,BASE/'private_control.py',BASE/'prepare_private.py',BASE/'private-control-template.py.gz']
    declared += [Path(p) for p in ('tools/run_dart_project_data.sh','tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh')]
    declared += [BASE/'before/normal-stdout.log.gz',BASE/'after/normal-stdout.log.gz']
    (OUT/'activation.txt').write_text(ACTIVATION+'\n')
    freeze('root',declared)
    run('version',['--version'])
    run('resolution',['pub','get','--offline','--enforce-lockfile'])
    config=CONTROL/'dart/.dart_tool/package_config.json'
    packages=json.loads(config.read_bytes())['packages']
    own=next(p for p in packages if p['name']=='linkedspec_dart')
    uri=urlparse(urljoin((ROOT/config).as_uri(),own['rootUri']))
    assert uri.scheme=='file' and not uri.netloc
    assert Path(unquote(uri.path)).resolve()==(ROOT/CONTROL/'dart').resolve(),'private SDK routing required'
    freeze('resolved',[CONTROL/'dart/pubspec.yaml',CONTROL/'dart/pubspec.lock',*list((CONTROL/'dart/.dart_tool').glob('*.json'))])
    run('analysis',['analyze','--fatal-infos','--fatal-warnings','lib/src/runtime/interpreter.dart','test/array_transform_result_guard_composition_test.dart'])
    result=run('normal',['test','--reporter','expanded','--concurrency=1','test/array_transform_result_guard_composition_test.dart'],(1,) if phase=='private-inverse' else (0,))
    observed=frames(result.stdout)
    assert len(observed)==141
    original='before' if phase=='private-inverse' else 'after'
    expected=frames(gzip.decompress((BASE/original/'normal-stdout.log.gz').read_bytes()))
    assert observed==expected,'full actual own normal projections must match'
    suffix=b'+122 -19: Some tests failed.' if phase=='private-inverse' else b'+141: All tests passed!'
    assert suffix in result.stdout,'actual semantic counts required'
    for row in custody:
        for name,wanted in row['files'].items():
            path=Path(name)
            assert hashlib.sha256(path.read_bytes()).hexdigest()==wanted['sha256']
            assert path.stat().st_mode & 0o777==wanted['mode']
    assert OWNER.read_bytes()==candidate,'checkout owner must remain unchanged'
    if phase=='private-restored':
        assert CONTROL.parent==BASE and not CONTROL.is_symlink()
        shutil.rmtree(CONTROL);assert not CONTROL.exists()
    print(phase+': actual141 normal frames/counts and private SDK routing verified; checkout untouched')


try: main()
except BaseException:
    (OUT/'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    raise
