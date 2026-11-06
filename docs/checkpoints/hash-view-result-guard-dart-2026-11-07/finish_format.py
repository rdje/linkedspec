"""Recover metadata for the stopped format phase, then apply the scoped formatter."""
import hashlib,json,subprocess,tarfile
from pathlib import Path
base=Path(__file__).resolve().parent.relative_to(Path.cwd());out=base/'format'
records=[]
for tag in ['root','resolved']:
 p=out/(tag+'-before-first-run.tar.gz');files={}
 with tarfile.open(p) as a:
  for m in a:
   assert m.isfile();b=a.extractfile(m).read();assert b==Path(m.name).read_bytes()
   files[m.name]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),mode=m.mode & 0o777)
 records.append(dict(archive=str(p),files=files))
(out/'custody.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
(out/'partial-format-note.txt').write_text('Original format check exit1 requested layout in owner and probe; output=none changed no source. Custody metadata reconstructed from unchanged actual pre-use capsules after stopped phase. No empty-phase command ran in this partial epoch.\n')
command=['bash','../tools/run_dart_project_data.sh','format','lib/src/runtime/interpreter.dart','test/hash_view_result_guard_composition_test.dart','tool/probe_hash_view_results.dart']
(out/'format-apply-command.json').write_text(json.dumps(dict(cwd='dart',argv=command),indent=2)+'\n')
with (out/'format-apply-stdout.log').open('wb') as stdout,(out/'format-apply-stderr.log').open('wb') as stderr:r=subprocess.run(command,cwd='dart',stdout=stdout,stderr=stderr)
(out/'format-apply-exit.txt').write_text(str(r.returncode)+'\n');assert r.returncode==0
# Retain the formatting producer itself and exact resulting files without replacing original inputs.
with tarfile.open(out/'formatted-result.tar.gz','w:gz') as a:
 for p in [Path('dart/lib/src/runtime/interpreter.dart'),Path('dart/tool/probe_hash_view_results.dart'),Path('dart/test/hash_view_result_guard_composition_test.dart'),base/'finish_format.py']:a.add(p,arcname=p,recursive=False)
print('Original format RED and exact pre-use capsules retained; scoped formatter applied')
