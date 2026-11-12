"""Prepare unused document query/custody instruments from accepted finite templates."""
import gzip
from pathlib import Path
import subprocess
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[2]
OLD=ROOT/'docs/checkpoints/array-concat-open-arity-julia-2026-11-12'
for name in ('check_publication_inputs.py','review_publication_inputs.py','run_publication.py'):
 p=OLD/name;body=p.read_bytes()
 assert body==subprocess.check_output(['git','show','HEAD:'+str(p.relative_to(ROOT))])
 (BASE/('publication-template-'+name+'.gz')).write_bytes(gzip.compress(body,mtime=0))
 s=body.decode().replace('952f8a022c59a478614ba1413e0e36e49e7e14e8','fb613736f68f7d1f90df5ade3c0e73c98160ca3f').replace('Julia','Lua').replace('julia-open-arity-concat','lua-open-arity-concat').replace('TYPE-REFERENCE-BOOK.1.2.23.3.80.4','TYPE-REFERENCE-BOOK.1.2.23.3.80.5')
 if name=='check_publication_inputs.py':
  s=s.replace("'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md', 'ROADMAP.md', 'ROADMAP_V2.md']", "'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md', 'ROADMAP.md', 'ROADMAP_V2.md',\n    'docs/tasks/TYPE-REFERENCE-BOOK.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md']")
 if name=='review_publication_inputs.py':
  s=s.replace("    match = next(row for row in report['checked_intersections'] if row['path'] == target)", "    matches = [row for row in report['checked_intersections'] if row['path'] == target]\n    if not matches:\n        continue\n    match = matches[0]")
 compile(s,name,'exec');(BASE/name).write_text(s)
print('Prepared prospective shared-document binding query and actual producer/document custody; no shared edit yet')
