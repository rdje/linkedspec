"""Scoped producer checks; reuse declared qualified direct inputs without runtime edits."""
import hashlib,json,os,subprocess,tarfile
from pathlib import Path
root=Path.cwd().resolve();base=Path(__file__).resolve().parent.relative_to(root);out=base/'format';out.mkdir()
paths=[Path('dart/tool/probe_key_count_callable_results.dart'),Path('dart/test/key_count_callable_result_guard_composition_test.dart'),Path('specs/user_function_definition.spec'),base/'capture_format.py']
records={}
with tarfile.open(out/'inputs-before-first-run.tar.gz','x:gz') as archive:
 for p in paths:
  assert p.is_file() and not p.is_symlink() and p.stat().st_dev==root.stat().st_dev
  body=p.read_bytes();records[str(p)]={'sha256':hashlib.sha256(body).hexdigest(),'bytes':len(body),'mode':p.stat().st_mode & 0o777}
  archive.add(p,arcname=str(p),recursive=False)
(out/'input-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
(out/'source-reference.txt').write_text(str(base/'direct-qualified/root-before-first-run.tar.gz')+'\n')
commands={'format':['format','--output=none','--set-exit-if-changed','tool/probe_key_count_callable_results.dart','test/key_count_callable_result_guard_composition_test.dart'],'probe-analysis':['analyze','--fatal-infos','--fatal-warnings','tool/probe_key_count_callable_results.dart'],'empty-phase':['run','tool/probe_key_count_callable_results.dart','']}
for tag,args in commands.items():
 command=['bash','../tools/run_dart_project_data.sh',*args]
 (out/(tag+'-command.json')).write_text(json.dumps({'cwd':'dart','argv':command,'environment':{'TERM':'dumb','NO_COLOR':'1'}},indent=2)+'\n')
 with (out/(tag+'-stdout.log')).open('xb') as stdout,(out/(tag+'-stderr.log')).open('xb') as stderr:
  r=subprocess.run(command,cwd=root/'dart',env=dict(os.environ,TERM='dumb',NO_COLOR='1'),stdout=stdout,stderr=stderr)
 (out/(tag+'-exit.txt')).write_text(str(r.returncode)+'\n')
 if tag=='empty-phase':
  stderr=(out/(tag+'-stderr.log')).read_text()
  assert r.returncode!=0 and 'phase must stay relative to the repository root' in stderr and 'FileSystemException' not in stderr
 else:assert r.returncode==0,'inspect retained channels'
 assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==v['sha256'] for p,v in records.items())
 print(tag,'PASS',flush=True)
