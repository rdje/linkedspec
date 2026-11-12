"""Date one new heading and route only this leaf's own detailed task commentary."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile
BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OUT = BASE / 'landing-document-fix'
OUT.mkdir()
ACTIVATION='fb613736f68f7d1f90df5ade3c0e73c98160ca3f'
assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()==ACTIVATION
assert subprocess.run(['git','diff','--cached','--quiet']).returncode==0
assert (BASE/'landing-failure/result.json').is_file()
part=Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
root=Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
changes=Path('CHANGES.md')
paths=[part,root,changes,Path('DEVELOPMENT_NOTES.md'),Path('MEMORY.md'),Path('LIVE_ACHIEVEMENT_STATUS.md'),BASE/'REVIEW.md']
notes=BASE/'TASK-NOTES.md';assert not notes.exists()
def freeze(tag,names):
    rows={}
    with tarfile.open(OUT/(tag+'.tar.gz'),'x:gz') as archive:
        for path in sorted(set(names)):
            assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
            body=path.read_bytes();rows[str(path)]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest(),mode=path.stat().st_mode&0o777)
            archive.add(path,arcname=str(path),recursive=False)
    with tarfile.open(OUT/(tag+'.tar.gz')) as archive:
        assert set(archive.getnames())==rows.keys()
        for member in archive:
            body=archive.extractfile(member).read();row=rows[member.name]
            assert len(body)==row['bytes'] and hashlib.sha256(body).hexdigest()==row['sha256'] and member.mode&0o777==row['mode']
    (OUT/(tag+'.json')).write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
freeze('before',paths+[BASE/'compact-node.txt',BASE/'landing-failure/result.json'])
before=part.read_text();marker='- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.80.5`'
start=before.index(marker);assert before.find('\n- ID:',start+1)==-1
original=before[start:];compact=(BASE/'compact-node.txt').read_text()
for prefix in ('- ID:','  Status:','  Goal:','  Dependencies:','  Acceptance:'):
    assert [line for line in original.splitlines() if line.startswith(prefix)]==[line for line in compact.splitlines() if line.startswith(prefix)],'CORE contract:'+prefix
assert compact.count('- [x]')==6
header='''# Lua80.5 task evidence and landing corrections

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.80.5. Full focused proof and qualified
historical reader: docs/checkpoints/array-concat-open-arity-lua-2026-11-12/REVIEW.md.
Default historical entrypoint is review_qualified.py; it recovers the unchanged
original reader with the exact gzip-retained oracle. Eleven original controls
and two added archive controls pass. Original standalone review.py expects the
retired plain oracle. Current266 is the earlier pre-packaging observation only.

The following complete pre-route task body is preserved byte-for-byte, including
its original goal, dependencies, acceptance and the staged chronology. Earlier
phrases saying no normal attempt refer to the packaging boundary. The later first
normal commit exits1: eight doctrines pass; DOCUMENT-HISTORY rejects the missing
date in the new change heading, and README-STABILITY rejects task-evidence bytes.
The original failed log/index/document images are retained in landing-failure/.
Both defects belong to this leaf. The new heading gains only its date. Only this
leaf's detailed commentary and two own root pointer texts route/shorten; every
other task-part byte and each CORE field remain exact. No limit/tool/policy change
or SDK replay occurs. Fresh committed size and a clean headroom-renewal leaf come
before larger resource4.14/current discovery/canonical publication work. Native/
raw-error/source/context/admission qualifications in the original body stay open.

## Complete pre-route task body

````markdown
'''
notes.write_text(header+original+'````\n')
assert notes.read_text()[len(header):-len('````\n')]==original
part.write_text(before[:start]+compact)
assert part.read_text()[:start]==before[:start]
oldphrase='installed Lua80.5 is focused-checked508/20 targets/four separate compatibility/484 preserved/old24-current508/direct6987 checks/readonly11/current266; all bounded80 backend outcomes recorded; fresh size then remaining coverage/current discovery4.1; raw-native observability4.28 remains before admission AND push;'
newphrase='installed Lua80.5 is focused-checked; bounded80 outcomes recorded; fresh size then coverage/discovery4.1/raw-error4.28 before push;'
body=root.read_text();root_before=body;assert body.count(oldphrase)==1
oldrow=next(line for line in body.splitlines() if line.startswith('| 1 |'))
newrow='| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.1` | `pending` | Fresh size/headroom, then resource4.14/discovery; publish near1.5GB. |'
root.write_text(body.replace(oldphrase,newphrase,1).replace(oldrow,newrow,1))
old='## TYPE-REFERENCE-BOOK.1.2.23.3.80.5 — installed Lua existing concat arity guards'
new='## 2026-11-12 — TYPE-REFERENCE-BOOK.1.2.23.3.80.5: installed Lua existing concat arity guards'
body=changes.read_text();assert body.count(old)==1
changes.write_text(body.replace(old,new,1))
for name in ('CHANGES.md','DEVELOPMENT_NOTES.md'):
    p=Path(name);body=p.read_text();start=body.index('TYPE-REFERENCE-BOOK.1.2.23.3.80.5');end=body.find('\n## ',start);end=len(body) if end<0 else end
    paragraph=' First normal landing1 (eight doctrines pass) retains missing-date/task-pressure failures; the new heading date and own-commentary routing correct them under unchanged limits. Full CORE contracts/pre-route body and all prior task bytes survive in TASK-NOTES and landing-document-fix; focused document gates precede the normal retry.'
    p.write_text(body[:end].rstrip()+paragraph+'\n\n'+body[end:])
p=BASE/'REVIEW.md';body=p.read_text()
body=body.replace('No normal commit was attempted.','No normal commit had been attempted at that packaging boundary.',1)
body+='''
First normal landing1 is retained with eight doctrines passing and two failing:
DOCUMENT-HISTORY requires a dated new change heading; README-STABILITY finds the
task-evidence collection over its unchanged ceiling. The correction dates only
the new heading and routes only this leaf's detailed commentary to TASK-NOTES.md,
with exact CORE fields and all other task bytes preserved. The complete pre-route
body, actual failed log/index/documents and source/full-mode before-after images
remain. Two own current root pointer texts shorten; no prior narrative is lost,
no limit or checker changes, and no SDK replay. Normal retry and exact clean
post-commit checks still govern landing. After fresh size, renew bounded task
headroom before larger resource4.14/current discovery/publication work.
'''
p.write_text(body)
p=Path('MEMORY.md');body=p.read_text();old='then inspect remaining feature coverage/current canonical discovery23.4.1.';new='then renew bounded task-evidence headroom before larger resource4.14/current canonical discovery23.4.1 and remaining coverage.';assert body.count(old)==1
body=body.replace(old,new,1)
body=body.replace('Default historical review_qualified.py/review_publication.py execute no SDK.','Default historical review_qualified.py/review_publication.py execute no SDK. Exact full task body/landing chronology now lives in checkpoint TASK-NOTES.md; first normal1/date-task-pressure failure is retained and corrected without changing limits or prior contracts.',1)
p.write_text(body)
p=Path('LIVE_ACHIEVEMENT_STATUS.md');body=p.read_text();old='Remeasure current committed outgoing bytes after clean Lua80.5; inspect remaining feature coverage and current canonical discovery4.1.';new='Remeasure current committed outgoing bytes after clean Lua80.5; renew task headroom before resource4.14/current canonical discovery4.1 and remaining coverage.';assert body.count(old)==1
p.write_text(body.replace(old,new,1))
freeze('after',paths+[notes])
result=dict(corrected_heading='2026-11-12 dated Lua80.5 heading',original_leaf_bytes=len(original.encode()),compact_leaf_bytes=len(compact.encode()),part_bytes_freed=len(original.encode())-len(compact.encode()),root_pointer_bytes_freed=len(root_before.encode())-len(root.read_bytes()),scope='Only own leaf commentary and two own current-root pointer texts route/shorten; all CORE fields and other task bytes exact. Full original retained in TASK-NOTES; no SDK replay/limit or infrastructure change. Focused gates and normal retry still required.')
(OUT/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(result))
