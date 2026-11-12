"""Independently recover exact task contracts, unchanged neighbors and dated history."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OUT=BASE/'landing-document-fix'
PART='docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'
ROOT='docs/tasks/TYPE-REFERENCE-BOOK.md'
LEAF='TYPE-REFERENCE-BOOK.1.2.23.3.80.5'
MARKER='- ID: `'+LEAF+'`'
def recover(tag):
    rows=json.loads((OUT/(tag+'.json')).read_bytes());result={}
    with tarfile.open(OUT/(tag+'.tar.gz')) as archive:
        assert len(archive.getnames())==len(rows) and set(archive.getnames())==rows.keys()
        for member in archive:
            assert member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts
            raw=archive.extractfile(member).read();row=rows[member.name]
            assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256'] and member.mode&0o777==row['mode']
            result[member.name]=raw
    return result
before,after=recover('before'),recover('after')
def validate(left,right):
    prior=left[PART].decode();current=right[PART].decode()
    start=prior.index(MARKER);original=prior[start:];compact=current[current.index(MARKER):]
    assert current[:current.index(MARKER)]==prior[:start],'other task bytes'
    for prefix in ('- ID:','  Status:','  Goal:','  Dependencies:','  Acceptance:'):
        assert [s for s in original.splitlines() if s.startswith(prefix)]==[s for s in compact.splitlines() if s.startswith(prefix)],'CORE contract'
    assert compact.count('- [x]')==6,'six proof fields'
    notes=right[str(BASE/'TASK-NOTES.md')].decode()
    assert notes.split('````markdown\n',1)[1].removesuffix('````\n')==original,'full original narrative'
    assert str(BASE/'TASK-NOTES.md') in compact,'routed pointer'
    old=left[ROOT].decode();new=right[ROOT].decode()
    oldphrase='installed Lua80.5 is focused-checked508/20 targets/four separate compatibility/484 preserved/old24-current508/direct6987 checks/readonly11/current266; all bounded80 backend outcomes recorded; fresh size then remaining coverage/current discovery4.1; raw-native observability4.28 remains before admission AND push;'
    newphrase='installed Lua80.5 is focused-checked; bounded80 outcomes recorded; fresh size then coverage/discovery4.1/raw-error4.28 before push;'
    oldrow=next(s for s in old.splitlines() if s.startswith('| 1 |'))
    newrow='| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.1` | `pending` | Fresh size/headroom, then resource4.14/discovery; publish near1.5GB. |'
    assert old.replace(oldphrase,newphrase,1).replace(oldrow,newrow,1)==new,'only own root pointer edits'
    changes=right['CHANGES.md'].decode()
    heading=next(line for line in changes.splitlines() if line.startswith('## '))
    assert heading=='## 2026-11-12 — '+LEAF+': installed Lua existing concat arity guards','dated new heading'
    tail='\n## 2026-11-12 — TYPE-REFERENCE-BOOK.1.2.23.4.31:'
    assert left['CHANGES.md'][left['CHANGES.md'].index(tail.encode()):]==right['CHANGES.md'][right['CHANGES.md'].index(tail.encode()):],'prior change records'
validate(before,after)
activation=subprocess.check_output(['git','show','fb613736f68f7d1f90df5ade3c0e73c98160ca3f:'+PART]).decode()
old=activation[activation.index(MARKER):]
for prefix in ('  Goal:','  Dependencies:','  Acceptance:'):
    assert [s for s in old.splitlines() if s.startswith(prefix)]==[s for s in after[PART].decode().split(MARKER,1)[1].splitlines() if s.startswith(prefix)],'activation contract'
query=BASE/'launches/public-task-query'
assert (query/'exit.txt').read_text()=='0\n' and gzip.decompress((query/'stderr.log.gz').read_bytes())==b''
assert gzip.decompress((query/'stdout.log.gz').read_bytes())==after[PART],'actual public query'
for name,raw in after.items(): assert Path(name).read_bytes()==raw,'point-in-time document identity'
controls=[]
for label,mutate,reason in (
    ('lost own Goal',lambda x:x.__setitem__(PART,x[PART].replace(b'  Goal:',b'  Lost:',1)),'CORE contract'),
    ('changed neighboring task byte',lambda x:x.__setitem__(PART,b'!'+x[PART][1:]),'other task bytes'),
    ('missing new heading date',lambda x:x.__setitem__('CHANGES.md',x['CHANGES.md'].replace(('## 2026-11-12 — '+LEAF).encode(),('## '+LEAF).encode(),1)),'dated new heading'),
):
    right=copy.deepcopy(after)
    if label=='lost own Goal':
        body=right[PART];start=body.index(MARKER.encode());right[PART]=body[:start]+body[start:].replace(b'  Goal:',b'  Lost:',1)
    else: mutate(right)
    try: validate(before,right)
    except AssertionError as failure: assert reason in str(failure),'control reason:'+label
    else: raise AssertionError('corruption accepted:'+label)
    controls.append(label)
print(json.dumps(dict(landing_documents='PASS',original_contract='exact activation Goal/Dependencies/Acceptance and current Status',other_task_bytes='exact',prior_changes='exact',actual_public_query=0,corruptions=controls,scope='Historical before/after recovery plus point-in-time document/query identity. Original failed normal and SDK proof stay unchanged; focused gates/normal retry still govern landing.')))
