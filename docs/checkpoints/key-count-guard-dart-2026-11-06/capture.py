"""One-shot focused Dart phases; preserve actual direct inputs before execution."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
phase=sys.argv[1]
assert phase in ('probe-before','probe-after','normal-before','normal-after','final')
OUT=BASE/phase
OUT.mkdir()
env=dict(os.environ,TERM='dumb',NO_COLOR='1')
custody=[]


def run(tag,arguments,cwd=Path('dart'),accepted=(0,)):
    wrapper=os.path.relpath(ROOT/'tools/run_dart_project_data.sh',ROOT/cwd)
    command=['bash',wrapper,*arguments]
    (OUT/(tag+'-command.json')).write_text(json.dumps(dict(cwd=str(cwd),argv=command,
        environment=dict(TERM='dumb',NO_COLOR='1')),indent=2)+'\n')
    with (OUT/(tag+'-stdout.log')).open('wb') as stdout,(OUT/(tag+'-stderr.log')).open('wb') as stderr:
        result=subprocess.run(command,cwd=ROOT/cwd,env=env,stdout=stdout,stderr=stderr)
    (OUT/(tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
    assert result.returncode in accepted,f'{tag}: exit{result.returncode}; inspect full raw channels'


def freeze(tag,paths):
    records={}
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev==ROOT.stat().st_dev
        body=path.read_bytes()
        records[str(path)]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest(),mode=path.stat().st_mode & 0o777)
    archive_path=OUT/(tag+'-before-first-run.tar.gz')
    with tarfile.open(archive_path,'w:gz') as archive:
        for path in records: archive.add(path,arcname=path,recursive=False)
    with tarfile.open(archive_path) as archive:
        recovered={m.name:hashlib.sha256(archive.extractfile(m).read()).hexdigest() for m in archive.getmembers() if m.isfile()}
    assert recovered=={p:r['sha256'] for p,r in records.items()}
    custody.append(dict(archive=str(archive_path),files=records))


(OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
run('version',['--version'])
run('root-resolution',['pub','get','--offline','--enforce-lockfile'])
paths=[Path(p) for p in subprocess.check_output(['git','ls-files','dart','tests/fixtures'],text=True).splitlines()]
paths += [BASE/'capture.py',Path('dart/tool/probe_key_count_result_guards.dart'),Path('dart/.dart_tool/package_config.json')]
paths += [Path(p) for p in ('tools/run_dart_project_data.sh','tools/project_data_env.sh','tools/run_python_project_data.sh')]
# New untracked direct inputs must be explicit, not inferred from git ls-files.
for p in ('dart/test/key_count_result_guard_composition_test.dart','tests/fixtures/key_count_result_guard_dart_domain.json'):
    if Path(p).is_file(): paths.append(Path(p))
if phase.startswith('probe-'):
    cases=[]
    for name in ('tests/fixtures/key_count_result_guard_cases.json',):
        cases.extend(json.loads(Path(name).read_text()))
    assert len({r['id'] for r in cases})==len(cases)
    (OUT/'cases.json').write_text(json.dumps(cases,indent=2)+'\n')
    paths.append(OUT/'cases.json')
freeze('root',paths)
if phase.startswith('probe-'):
    run('root-analysis',['analyze','--fatal-infos','--fatal-warnings','tool/probe_key_count_result_guards.dart'])
    fresh=OUT/'fresh';fresh.mkdir()
    (fresh/'pubspec.yaml').write_text('''name: key_count_source_dart_fresh
publish_to: none
environment:
  sdk: ">=3.9.0 <4.0.0"
dependencies:
  linkedspec_dart:
    path: ../../../../../dart
''')
    run('native',['run','tool/probe_key_count_result_guards.dart',str(OUT)])
    run('fresh-resolution',['pub','get','--offline'],cwd=fresh)
    freeze('fresh',list(fresh.rglob('*.dart'))+list((fresh/'inputs').glob('*.json'))+
        [fresh/'pubspec.yaml',fresh/'pubspec.lock',fresh/'.dart_tool/package_config.json'])
    run('fresh-analysis',['analyze','--fatal-infos','--fatal-warnings'],cwd=fresh)
    run('fresh',['run','bin/main.dart'],cwd=fresh)
else:
    run('root-analysis',['analyze','--fatal-infos','--fatal-warnings',
        'lib/src/runtime/interpreter.dart','test/key_count_result_guard_composition_test.dart','tool/probe_key_count_result_guards.dart'])
    tests=['test/key_count_result_guard_composition_test.dart']
    if phase=='final': tests+=['test/count_length_receivers_test.dart','test/count_result_guard_composition_test.dart','test/length_result_guard_composition_test.dart']
    run('normal',['test','--reporter','expanded','--concurrency=1',*tests],accepted=(0,1) if phase=='normal-before' else (0,))
for record in custody:
    for path,item in record['files'].items():
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==item['sha256'],path
        assert Path(path).stat().st_mode & 0o777 == item['mode']
if phase.startswith('probe-'):
    assert fresh.parent==OUT and not fresh.is_symlink()
    shutil.rmtree(fresh)
    assert not fresh.exists()
(OUT/'custody.json').write_text(json.dumps(custody,indent=2,sort_keys=True)+'\n')
print(f'{phase}: complete declared direct root/fresh inputs; inspect raw observations before grading')
