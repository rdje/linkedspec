"""Preserve fifteen whole cards before routes and the scoped CI-selection update."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
CARD='docs/knowledge/perl-receiver-copy-canonical-selection.md'
sha=lambda v:hashlib.sha256(v).hexdigest()
target=ROOT/(PREFIX+'knowledge-preparation-final.json');assert not target.exists()
assert sys.argv[1:] in ([],['--preflight'])
if not sys.argv[1:]:
    selection=json.loads((ROOT/(PREFIX+'selection.json')).read_bytes())
    audit=json.loads((ROOT/(PREFIX+'audit-final.json')).read_bytes())
    assert selection['result']==audit['result']=='PASS'
preservation=json.loads((ROOT/(PREFIX+'preservation.json')).read_bytes())
cards=sorted(p for p in preservation['owned_bound_paths'] if p.startswith('docs/knowledge/'))
assert len(cards)==15 and CARD in cards
originals={p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT) for p in cards}
route='Readonly: bash tools/run_python_project_data.sh '+PREFIX+'publish.py. Prior:858eba97c.'
values={}
for p,value in originals.items():
    assert (ROOT/p).read_bytes()==value
    header,body=value.split(b'\n---\n',1)
    header,count=re.subn(rb'^reverify: .*$',('reverify: '+json.dumps(route)).encode(),header,flags=re.M)
    assert count==1
    values[p]=header+b'\n---\n'+body
header,body=values[CARD].split(b'\n---\n',1)
header=header.replace(b'title: Canonical CI explicitly selects the public Perl receiver-copy regression',
    b'title: Canonical CI explicitly selects receiver-copy and supplied private factory fixtures',1)
header=header.replace(b'date: 2026-10-10',b'date: 2026-10-19',1)
header=re.sub(rb'^status: .*$',b'status: exact supplied fixture block and historical inverse verified; canonical receipt governs admission',header,count=1,flags=re.M)
header=header.replace(b'\ndate:',b'\n  - does canonical CI select the supplied private factory fixture population\n  - which supplied private factory helper scripts receive syntax checks\ndate:',1)
evidence=('Leaf .7 inventories91 suites/363 exact supplied inputs and46 test helpers. Original direct selection omits86 suites and132/131 tracked/syntax paths. Actual selected Bash population and historical inverse pass with effective faults; complete originals and failed instruments remain retained. Exact staged CI governs admission.')
header=re.sub(rb'^evidence: .*$',('evidence: '+json.dumps(evidence)).encode(),header,count=1,flags=re.M)
addition=('\n# Explicit Perl CI selection\n\n'
    'The runner selects files explicitly; adding a test alone does not register it. Leaf .7 selects91 supplied suites '
    'and46 supplied test helpers in one exact150-line block. All137 paths pass tracked-presence and syntax checks '
    'before the complete prove command. One suite is a historical checkpoint fixture; all363 supplied inputs stay exact.\n\n'
    'Original direct literal commands selected5 suites and checked5/6 of137 paths for presence/syntax:86/132/131 '
    'omissions. This says nothing about indirect coverage. Actual Bash137/91/30394 proof distinguishes missing or '
    'duplicated suites, a missing helper and disabled execution despite exit0. Future files still require registration.\n\n'
    'The historical auditor reverses this exact block before its older insertions and requires every original runner '
    'byte. Controls mutate paths within the owned block because six names also occur in older commands. Original '
    'inventory, metadata-anchor and control-scope refusals and exact corrections remain retained under the .7 checkpoint.\n\n'
    'Receiver-copy .3.1.6.0.0 earlier added three exact presence/syntax/execution blocks. Its interrupted first candidate '
    'has no receipt or independently retained starting read boundary; the second broke historical anchors. Corrected '
    'separate commands and exact inverses preserved the original CI hash. Complete older card/source/observation scope '
    'remains at858eba97c and in .7 preparation originals. Earlier observations are never relabeled as new runs.\n\n'
    'Exact staged canonical CI and normal hooks govern landing. Pipeline .6 and broader private/mapped/parent admissions '
    'remain separately owned. No runtime, fixture, dependency or budget change follows from selection.\n')
values[CARD]=header+b'\n---\n'+addition.encode()
total=sum(len(values.get(p.relative_to(ROOT).as_posix(),p.read_bytes())) for p in (ROOT/'docs/knowledge').glob('*.md'))
if sys.argv[1:]:
    print(json.dumps(dict(result='PASS' if total<=8388608 else 'OVER_CAP',knowledge_bytes=total,
        producer_sha256=sha(Path(__file__).read_bytes()),producer_base64=base64.b64encode(Path(__file__).read_bytes()).decode(),
        originals={p:sha(v) for p,v in originals.items()},proposed={p:sha(v) for p,v in values.items()},
        scope='Pure prewrite dry run: all original cards remain unchanged; no runtime/audit observation or current card is written.'),indent=2))
    raise SystemExit(0 if total<=8388608 else 1)
assert total<=8388608,('prewrite Knowledge budget',total)
record=dict(result='PASS',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),route=route,knowledge_bytes=total,
    originals={p:dict(bytes_base64=base64.b64encode(v).decode(),sha256=sha(v)) for p,v in originals.items()},
    current={p:sha(v) for p,v in values.items()},
    scope='Fifteen existing whole cards are retained before writes. Fourteen bodies stay exact; one canonical-selection body condenses the fully preserved older account with the bounded current population/inverse scope. Only its dated metadata/evidence/answers change beyond the routes. No card, fact or budget is added.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
for p,value in values.items():(ROOT/p).write_bytes(value)
print('Knowledge preparation PASS:',total,'bytes;15 routes/one condensed body;all originals retained')
