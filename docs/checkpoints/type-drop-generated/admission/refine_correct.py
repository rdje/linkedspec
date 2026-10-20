"""Retain the size-guard rejection and compact prose without dropping its facts."""
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c

path=c.PREFIX+'admission/correct.py'
before=c.read(path)
run=c.run(['bash','tools/run_python_project_data.sh',path])
assert run['returncode']!=0 and b'AssertionError: (3246, 3045)' in c.decode(run['stderr_base64'])
text=c.decode(before['base64']).decode()
changes=[
('Scanner mock admission: five source controls/60 dated evolution denials. Evaluated3 preserves368+210; numeric5 preserves578+66. Drop6 preserves644+6, archive134/84613241 bytes/22 and zero healthy log/write escapes. Actual auditor faults/table-byte identity controls restore.',
 'Scanner five source controls/60 dated denials; evaluated368+210, numeric578+66, drop644+6. Archive134/84613241/22 and zero log/write escapes; auditor faults/table identity restore.'),
('The original\nauditor, failed candidate/gate and correction remain retained; .0.4 owns ledger\nfollow-up. [[historical-objective-audit-input-recovery]] defines archive/guard\ninvariants. Historical hashes, milestones, logs and runtime results never refresh.',
 'Original auditor/candidate/gate/correction stay retained; .0.4 owns ledger work.\n[[historical-objective-audit-input-recovery]] fixes archive/guard invariants.\nHistorical hashes, milestones, logs and runtime results never refresh.'),
('zero healthy original-log/tracked writes stay exact. Current reverify uses the\ncomposed historical producer above; it does not replay old runtime. The stale\nnumeric-only route\'s actual RED and whole first drop draft/readonly0 are retained\nunder docs/checkpoints/type-drop-generated/admission/.',
 'zero original-log/tracked writes stay exact. Reverify uses the composed producer,\nnot old runtime. The stale-route RED and whole first drop draft/readonly0 survive\nunder docs/checkpoints/type-drop-generated/admission/.'),
]
for old,new in changes:
 assert text.count(old)==1,old
 text=text.replace(old,new,1)
after=text.encode()
compile(after,path,'exec')
c.write_new('admission/correction-size-preparation.json.gz',dict(before=before,after_base64=c.encode(after),run=run,
 producer=c.read(c.PREFIX+'admission/refine_correct.py'),
 scope='The first correction did not write bound files: its existing-size guard rejected3246 vs3045 bytes. '
       'Keep the actual rejected producer/run; compact duplicated wording while retaining every dated count, '
       'mechanism, original hash and recovery boundary. No budget is raised.'))
(c.ROOT/path).write_bytes(after)
print('Size rejection retained; correction prose compacted with unchanged facts/budgets')
