"""Keep the oversized dry run; condense only the one dated selection body."""
import base64
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
sha=lambda v:hashlib.sha256(v).hexdigest()
source=(ROOT/(PREFIX+'prepare-knowledge.py')).read_bytes()
preflight=json.loads((ROOT/(PREFIX+'knowledge-preflight.json')).read_bytes())
assert preflight['result']=='OVER_CAP' and preflight['knowledge_bytes']==8389286
assert base64.b64decode(preflight['producer_base64'])==source and preflight['producer_sha256']==sha(source)
for p,identity in preflight['originals'].items():assert sha((ROOT/p).read_bytes())==identity
old=b'addition=('+source.split(b'\naddition=(',1)[1].split(b'\nvalues[CARD]=',1)[0]
new=b'''addition=('\\n# Explicit Perl CI selection\\n\\n'
    'The runner selects files explicitly; adding a test alone does not register it. Leaf .7 selects91 supplied suites '
    'and46 supplied test helpers in one exact150-line block. All137 paths pass tracked-presence and syntax checks '
    'before the complete prove command. One suite is a historical checkpoint fixture; all363 supplied inputs stay exact.\\n\\n'
    'Original direct literal commands selected5 suites and checked5/6 of137 paths for presence/syntax:86/132/131 '
    'omissions. This says nothing about indirect coverage. Actual Bash137/91/30394 proof distinguishes missing or '
    'duplicated suites, a missing helper and disabled execution despite exit0. Future files still require registration.\\n\\n'
    'The historical auditor reverses this exact block before its older insertions and requires every original runner '
    'byte. Controls mutate paths within the owned block because six names also occur in older commands. Original '
    'inventory, metadata-anchor and control-scope refusals and exact corrections remain retained under the .7 checkpoint.\\n\\n'
    'Receiver-copy .3.1.6.0.0 earlier added three exact presence/syntax/execution blocks. Its interrupted first candidate '
    'has no receipt or independently retained starting read boundary; the second broke historical anchors. Corrected '
    'separate commands and exact inverses preserved the original CI hash. Complete older card/source/observation scope '
    'remains at858eba97c and in .7 preparation originals. Earlier observations are never relabeled as new runs.\\n\\n'
    'Exact staged canonical CI and normal hooks govern landing. Pipeline .6 and broader private/mapped/parent admissions '
    'remain separately owned. No runtime, fixture, dependency or budget change follows from selection.\\n')'''
assert source.count(old)==1
corrected=source.replace(old,new,1)
corrected=corrected.replace(b"'knowledge-preparation.json'",b"'knowledge-preparation-final.json'",1)
corrected=corrected.replace(b"header+b'\\n---\\n'+body+addition.encode()",b"header+b'\\n---\\n'+addition.encode()",1)
old_scope=b'one canonical-selection body keeps its entire original body and appends the bounded current population/inverse scope.'
new_scope=b'one canonical-selection body condenses the fully preserved older account with the bounded current population/inverse scope.'
assert corrected.count(old_scope)==1
corrected=corrected.replace(old_scope,new_scope,1).replace(b'15 routes/one appended body',b'15 routes/one condensed body',1)
target=ROOT/(PREFIX+'prepare-knowledge-final.py');assert not target.exists()
record=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),original_sha256=sha(source),
    corrected_sha256=sha(corrected),old_base64=base64.b64encode(old).decode(),new_base64=base64.b64encode(new).decode(),
    preflight_sha256=sha((ROOT/(PREFIX+'knowledge-preflight.json')).read_bytes()),
    scope='Actual pure dry run refuses8389286 before all card writes. Retain that entire original producer/report and unchanged originals; a distinct writer condenses only the selection body and keeps all older content whole at accepted Git/in preparation originals. Fourteen other bodies remain exact; limits stay fixed. Final dry run and actual publication still required.')
with (ROOT/(PREFIX+'knowledge-source-repair.json')).open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
target.write_bytes(corrected)
print('Knowledge source preparation PASS:original dry run retained;one condensed body;no card writes')
