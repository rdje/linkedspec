"""One finite Dart phase; freeze declared direct inputs before every SDK use."""
import hashlib,json,os,shutil,subprocess,sys,tarfile
from pathlib import Path
ROOT=Path.cwd().resolve();BASE=Path(__file__).resolve().parent.relative_to(ROOT)
phase=sys.argv[1];assert phase in {'intake','before','after','after-intake','direct','format','direct-final','after-intake-final','format-final'}
OUT=BASE/phase;OUT.mkdir();custody=[]
mode=phase.removesuffix('-final')
env=dict(os.environ,TERM='dumb',NO_COLOR='1')

def freeze(tag,paths):
    records={}
    for p in sorted(set(paths)):
        assert not p.is_absolute() and '..' not in p.parts and p.is_file() and not p.is_symlink()
        assert p.stat().st_dev==ROOT.stat().st_dev
        b=p.read_bytes();records[str(p)]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),mode=p.stat().st_mode & 0o777)
    archive_path=OUT/(tag+'-before-first-run.tar.gz')
    with tarfile.open(archive_path,'w:gz') as a:
        for p in records:a.add(p,arcname=p,recursive=False)
    with tarfile.open(archive_path) as a:
        assert {m.name:hashlib.sha256(a.extractfile(m).read()).hexdigest() for m in a if m.isfile()}=={p:r['sha256'] for p,r in records.items()}
    custody.append(dict(archive=str(archive_path),files=records))

def run(tag,args,cwd=Path('dart'),accepted=(0,)):
    command=['bash',os.path.relpath(ROOT/'tools/run_dart_project_data.sh',ROOT/cwd),*args]
    (OUT/(tag+'-command.json')).write_text(json.dumps(dict(cwd=str(cwd),argv=command,environment=dict(TERM='dumb',NO_COLOR='1')),indent=2)+'\n')
    with (OUT/(tag+'-stdout.log')).open('wb') as out,(OUT/(tag+'-stderr.log')).open('wb') as err:
        result=subprocess.run(command,cwd=ROOT/cwd,env=env,stdout=out,stderr=err)
    (OUT/(tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
    assert result.returncode in accepted,f'{tag}: exit{result.returncode}; inspect retained full channels'

(OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
paths=[Path(p) for p in subprocess.check_output(['git','ls-files','dart'],text=True).splitlines()]
paths += [Path('specs/user_function_definition.spec'),Path('tests/fixtures/hash_view_result_guard_cases.json'),Path('tests/fixtures/hash_view_result_guard_rust_profiles.json'),Path('tests/fixtures/hash_view_receiver_policy_perl_cases.json'),BASE/'prepare.py',BASE/'capture.py',BASE/'cases.json',Path('dart/tool/probe_hash_view_results.dart'),Path('dart/.dart_tool/package_config.json')]
paths += [Path(p) for p in ('tools/run_dart_project_data.sh','tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh')]
# All fixtures used by directly selected existing tests, plus explicit untracked inputs.
paths += [Path(p) for p in subprocess.check_output(['git','ls-files','tests/fixtures'],text=True).splitlines()]
for p in [BASE/'freeze_profiles.py',Path('tests/fixtures/hash_view_result_guard_dart_profiles.json'),Path('dart/test/hash_view_result_guard_composition_test.dart')]:
    if p.exists():paths.append(p)
if mode in {'intake','after-intake'}:
    (OUT/'cases.json').write_bytes((BASE/'cases.json').read_bytes());paths.append(OUT/'cases.json')
freeze('root',paths)
run('version',['--version'])
run('resolution',['pub','get','--offline','--enforce-lockfile'])
# Resolve before compilation, and retain the actual post-resolution routing too.
freeze('resolved',[Path('dart/pubspec.yaml'),Path('dart/pubspec.lock'),Path('dart/.dart_tool/package_config.json')])
if mode in {'intake','after-intake'}:
    run('analysis',['analyze','--fatal-infos','--fatal-warnings','tool/probe_hash_view_results.dart'])
    fresh=OUT/'fresh';fresh.mkdir()
    (fresh/'pubspec.yaml').write_text('name: hash_view_dart_fresh\npublish_to: none\nenvironment:\n  sdk: ">=3.9.0 <4.0.0"\ndependencies:\n  linkedspec_dart:\n    path: ../../../../../dart\n')
    run('native',['run','tool/probe_hash_view_results.dart',str(OUT)])
    # The emitted modules and their parsed inputs exist before fresh resolution/load.
    freeze('emitted',list(fresh.rglob('*.dart'))+list((fresh/'inputs').glob('*.json'))+[fresh/'pubspec.yaml'])
    run('fresh-resolution',['pub','get','--offline'],fresh)
    freeze('fresh',list(fresh.rglob('*.dart'))+list((fresh/'inputs').glob('*.json'))+[fresh/'pubspec.yaml',fresh/'pubspec.lock',fresh/'.dart_tool/package_config.json'])
    run('fresh-analysis',['analyze','--fatal-infos','--fatal-warnings'],fresh)
    run('fresh',['run','bin/main.dart'],fresh)
elif mode=='format':
    run('format',['format','--output=none','--set-exit-if-changed','lib/src/runtime/interpreter.dart','test/hash_view_result_guard_composition_test.dart','tool/probe_hash_view_results.dart'])
    run('empty-phase',['run','tool/probe_hash_view_results.dart',''],accepted=(255,))
else:
    run('analysis',['analyze','--fatal-infos','--fatal-warnings','lib/src/runtime/interpreter.dart','test/hash_view_result_guard_composition_test.dart','tool/probe_hash_view_results.dart'])
    tests=['test/hash_view_result_guard_composition_test.dart']
    if mode=='direct':tests += ['test/constructor_result_composition_test.dart','test/value_copy_test.dart','test/receiver_copy_arity_test.dart']
    run('normal',['test','--reporter','expanded','--concurrency=1',*tests],accepted=(0,1) if phase=='before' else (0,))
for record in custody:
    for p,r in record['files'].items():
        assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==r['sha256'],p
        assert Path(p).stat().st_mode & 0o777==r['mode']
if mode in {'intake','after-intake'}:
    assert fresh.parent==OUT and not fresh.is_symlink();shutil.rmtree(fresh);assert not fresh.exists()
(OUT/'custody.json').write_text(json.dumps(custody,indent=2,sort_keys=True)+'\n')
print(phase+': finite phase complete; actual inputs/modules/full channels retained')
