"""Preserve fourteen whole cards before header routes and one scoped warning update."""
import base64
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='e953f69a9934c4ab48e643e69c9efaba0cb1d534'
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
CARD='docs/knowledge/rust-dependency-warning-baseline.md'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
target=ROOT/(PREFIX+'knowledge-preparation-final.json');assert not target.exists()
preservation=json.loads((ROOT/(PREFIX+'preservation.json')).read_bytes())
cards=sorted(p for p in preservation['owned_bound_paths'] if p.startswith('docs/knowledge/'))
assert len(cards)==14
originals={p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT) for p in cards}
route='Readonly: bash tools/run_python_project_data.sh '+PREFIX+'publish.py. Prior inputs:e953f69a9.'
values={}
for p,value in originals.items():
    assert (ROOT/p).read_bytes()==value
    header,body=value.split(b'\n---\n',1)
    lines=header.splitlines(keepends=True);matches=[i for i,v in enumerate(lines) if v.startswith(b'reverify: ')]
    assert len(matches)==1
    i=matches[0];ending=b'\n' if lines[i].endswith(b'\n') else b''
    lines[i]=('reverify: '+json.dumps(route)).encode()+ending
    values[p]=b''.join(lines)+b'\n---\n'+body
warning=json.loads((ROOT/(PREFIX+'warning-review.json')).read_bytes())
assert warning['result']=='PASS'
counts=warning['counts_by_crate'];reported=warning['reported_values'];old=warning['historical_reported_values']
header=values[CARD].split(b'\n---\n',1)[0].decode()
header=header.replace('date: 2026-10-10','date: 2026-10-19',1)
header=header.replace('status: observable baseline retained; upstream implementation investigation and edits forbidden',
    'status: dated public summaries retained; fuller census/upstream work remains open',1)
header=header.replace('  - what git boundary owns rgx and pgen warning fixes',
    '  - what git boundary owns rgx and pgen warning fixes\n  - what does the current canonical output report for PGEN warnings\n  - does 7093 mean distinct PGEN defects',1)
evidence=('Canonical e953f69a9 retains '+str(warning['summary_occurrences'])+' summary occurrences; exact raw-line/phase/count and Git-receipt review pass. Reported counts and dated1870/26 stay scoped in the preserved body.')
header=re.sub(r'^evidence: .*$', 'evidence: '+json.dumps(evidence),header,count=1,flags=re.M)
body=('\n# Public warning-output account\n\n'
    'LinkedSpec integrates only with RGX through its published integration document, APIs and contracts. '
    'RGX owns PGEN/transitive preparation. Do not inspect or edit either implementation, reconstruct a separate '
    'PGEN procedure, change pins, execute source-changing cargo suggestions or suppress warnings to claim a clean build.\n\n'
    'The warranted canonical run admitted at e953f69a9 contains '+str(warning['summary_occurrences'])+' summary-line occurrences: '
    +str(counts['pgen'])+' report '+str(reported['pgen'][0])+' for pgen; '+str(counts['rgx-core'])+' report '+str(reported['rgx-core'][0])+' for rgx-core. '
    'The complete successful log, original staged and promoted receipts, separate partial/final observations and observed CLI '
    'tool identities are retained under docs/checkpoints/REPO-HYGIENE.19/. Independent review derives every raw line, nearest '
    'public phase, crate/count and actual accepted parent/diff/tree. Defaults read captured evidence; no new build is run.\n\n'
    'These are compiler-reported summaries, not counts of distinct diagnostics/bugs, proven comparable configurations '
    'or an internal cause. The earlier dated account reported '+str(old['pgen'])+'/'+str(old['rgx-core'])+'; its whole original '
    'header/body remains at e953f69a9 and warning-historical-card.md. Preserve that history rather than relabeling it as a new run.\n\n'
    'RUST-DEPENDENCY-WARNING-ZERO.1 owns the fuller public census; .2 owns an upstream RGX report and evaluation of published '
    'results. This partial output account closes neither. Keep the program non-blocking behind active residual repair. '
    'Observe future counts only through otherwise warranted documented builds; retain command, identity, exit and full channels.\n\n'
    'The September20 boundary already governed the canonical task/card. RUST-DEPENDENCY-WARNING-ZERO.8 corrected contrary '
    'current roadmap internal-repair/pin plans on October10; no old output was refreshed. LinkedSpec-owned diagnostics may '
    'be repaired only in their own task-owned slices. Related: [[rust-ci-pgen-missing-input-rebuilds]], [[verification-cadence-policy]].\n')
values[CARD]=header.encode()+b'\n---\n'+body.encode()
paths=sorted(p for p in (ROOT/'docs/knowledge').glob('*.md') if p.is_file())
total=sum(len(values.get(p.relative_to(ROOT).as_posix(),p.read_bytes())) for p in paths)
assert total<=8388608,('prewrite Knowledge budget',total)
record=dict(result='PASS',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),route=route,knowledge_bytes=total,
    originals={p:dict(bytes_base64=encode(v),sha256=sha(v)) for p,v in originals.items()},
    current={p:sha(v) for p,v in values.items()},
    scope='All fourteen whole original cards are preserved before writes. Thirteen bodies remain exact; one warning body condenses preserved policy/history and adds independently verified reported-summary observations with explicit limits and existing owner schedule. No fact card or budget is added.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
for p,value in values.items():(ROOT/p).write_bytes(value)
print('Knowledge preparation PASS:',total,'bytes;14 cards/one body;all originals retained')
