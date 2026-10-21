"""Adopt the actual clean preservation before activating pipeline9."""
import gzip
import json
import shutil
from pathlib import Path

root=Path.cwd()
prefix=root/'docs/checkpoints/type-array-pipelines'
prior=json.loads(gzip.decompress((root/'.linkedspec-data/verification/type-pipeline-prior.json.gz').read_bytes()))
assert prior['base']=='49ce3fb472b01dc6a7987b0038fae22686dee7cd'
prefix.mkdir()
for source,target in [('type-pipeline-prior.json.gz','prior.json.gz'),('type-pipeline-baseline.json.gz','prior-baseline.json.gz'),('type-pipeline-preserve.py','preserve.py')]:
    shutil.copy2(root/'.linkedspec-data/verification'/source,prefix/target)
old=root/'docs/checkpoints/type-aggregate-codeblocks'
common=(old/'common.py').read_text().replace("BASE='efad62ba7a70e0b9d930b761f9cacaad87a0210c'","BASE='49ce3fb472b01dc6a7987b0038fae22686dee7cd'").replace("PREFIX='docs/checkpoints/type-aggregate-codeblocks/'","PREFIX='docs/checkpoints/type-array-pipelines/'").replace("OWNER='TYPE-REFERENCE-BOOK.1.2.7'","OWNER='TYPE-REFERENCE-BOOK.1.2.9'")
(prefix/'common.py').write_text(common)
shutil.copy2(old/'probe.pl',prefix/'probe.pl')
claim=root/'docs/claims/TYPE-REFERENCE-BOOK.1.2.7.json'
assert claim.read_bytes()==__import__('base64').b64decode(prior['claim']['base64'])
record=json.loads(claim.read_bytes())
for item in record['claims']:
    assert item['durability']['mode']=='live'
    item['durability'].update(mode='historical',revision=prior['base'])
claim.write_text(json.dumps(record,separators=(',',':'))+'\n')
with (old/'README.md').open('a') as output:
    output.write('\nHistorical at accepted49ce3fb472b01dc6a7987b0038fae22686dee7cd after pipeline9 activation. Complete accepted custody and clean readonly baseline: docs/checkpoints/type-array-pipelines/prior.json.gz. Restore the recorded accepted Git inputs for historical replay.\n')
task=root/'docs/tasks/TYPE-REFERENCE-BOOK.md'
text=task.read_text();start=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.9`\n');end=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.1`\n',start)
text=text[:start]+'''- ID: `TYPE-REFERENCE-BOOK.1.2.9`
  Status: `in_progress` / activation49ce3fb
  Goal: Execute deferred sorted/take aggregate pipelines.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.7`
  Reproduce/impact: items.sorted().take(2).sum() yields4 for [3,1,8] outside; deferred raises unknown_helper:sorted.
  Scope/custody: docs/checkpoints/type-array-pipelines/; whole accepted7 claim/10608 physical/3 logical/full modes/10611 Git images and actual clean readonly0 precede changes.
  Verification tier: `canonical`
  Focused checks: Public descriptor/Get/dump/fresh routes; lexical sorting, take default/count/arity/kind/effects/copy/chain boundaries; aggregate/scalar/callable direct consumers; book/Knowledge/doctrines.
  Canonical trigger: Public deferred helper availability and terminal composition admission; exact staged canonical receipt required.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.9.json`
  Acceptance Checklist
  - [ ] **REPRODUCE / ISSUE** — Accepted deferred failures and ordinary healthy controls.
  - [ ] **ROOT CAUSE (WHY + WHERE)** — Toolbox mechanism and public contracts before owner inspection.
  - [ ] **FIX** — Only sorted/take availability and supported compatible chains.
  - [ ] **ADDRESSED (verified)** — Values/arity/kind/effects/copy plus distinguishing source faults.
  - [ ] **NO REGRESSION** — Permanent tests/direct consumers/canonical receipt.
  - [ ] **LOCKSTEP** — Worked book, canonical fact and clean handoff; no complete inventory admission.

'''+text[end:]
text=text.replace('| 6 | `TYPE-REFERENCE-BOOK.1.2.9` | `pending` |','| 6 | `TYPE-REFERENCE-BOOK.1.2.9` | `in_progress` |')
task.write_text(text)
memory=root/'MEMORY.md';text=memory.read_text().replace('`efad62ba7a70e0b9d930b761f9cacaad87a0210c`','`49ce3fb472b01dc6a7987b0038fae22686dee7cd`').replace('(pending clean activation)','(in progress)')
lines=text.splitlines();lines=[('- next_action: Collect fixed public sorted/take baseline and exact lowering/dump mechanism before implementation inspection. Complete only pipeline9, verify and commit, then continue inventory1 in full PNT.' if line.startswith('- next_action:') else '- in_flight_uncommitted: Pipeline9 accepted7 preservation/activation; no runtime change. Whole prior/actual readonly0/full Git images retained in docs/checkpoints/type-array-pipelines/prior.json.gz.' if line.startswith('- in_flight_uncommitted:') else line) for line in lines]
memory.write_text('\n'.join(lines)+'\n')
shutil.copy2(Path(__file__),prefix/'activate.py')
print('Pipeline9 activated after accepted7 preservation; fixed public baseline next')
