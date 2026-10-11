"""Guarded metadata closure; original347 publication/instruments stay exact. Default readonly."""
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
DIR='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json'
assert sys.argv[1:] in ([],['--capture'])
read=lambda p:(ROOT/p).read_bytes()
sha=lambda raw:hashlib.sha256(raw).hexdigest()
for tail in ('review.py','evidence.py'):
    p=subprocess.run(['python3',DIR+tail],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    assert p.returncode==0 and not p.stderr,(tail,p.returncode,p.stdout,p.stderr)
original=read(DIR+'original-claim.json'); data=json.loads(original); first=data['claims'][0]
disclosure=(' The original uncommitted347-input publication, root and capacity card remain byte-exact under the leaf directory. '
            'Its note mistakenly put old admission rejection before archive creation. Current root corrects only archived to admitted, with identical byte/line counts; '
            'the card changes only its readonly entrypoint. Original actual publisher/reader/instruments and all observations/metrics remain fixed. '
            'Actual full original logical publication replays healthy, rejects the corrected root for its named historical source boundary, and restores healthy;345 current inputs stay exact and two relocate byte-identically. '
            'The first replay preflight exited1 because include executable modes were not copied; exact draft/reached channels are retained and corrected supplied modes match the original book ledger. '
            'Nested assertion envelopes are decoded only for the named reason while preserving complete outer channels. No partial preflight success or runtime/book remeasurement is claimed. '
            'Independent current review proves the sole wording/pointer correction; an unrelated wording mutation actually rejects and exact restoration passes before canonical admission.')
first['scope']+=disclosure
first['rederive']['command']='bash tools/run_python_project_data.sh '+DIR+'publish.py (readonly default). Leaf-directory replay.py/review.py/evidence.py are readonly defaults; --capture writers are one-shot. The original hyphenated publisher requires its exact supplied original logical state, retained by replay.py; do not run it against corrected current root/card.'
first['rederive']['granularity']+=' Exact original347 input hashes/logical paths and actual supplied modes; healthy/changed-root/restored full original publication; equal-byte archived-to-admitted correction, sole current pointer change and unrelated-wording RED/restoration.'
first['rederive']['result']+=disclosure
first['falsify']['oracle']+=' Exact retained original full claim/root/card and actual original logical publication; independently reconstructed one-word/current pointer correction.'
first['falsify']['red_control']+=' Original publisher/reader rejects the corrected current root when supplied as an original input, with its named inner reason/full outer channels retained; exact original restoration passes. Current reviewer rejects an unrelated ADR spelling before publication hash gating; exact wording restoration passes.'
relocations={'DEVELOPMENT_NOTES.md':DIR+'original-root.md','docs/knowledge/finite-engineering-notes-member-0131.md':DIR+'original-card.md'}
inputs=first['durability']['inputs']
assert len(inputs)==347
for entry in inputs:
    entry['path']=relocations.get(entry['path'],entry['path'])
    assert sha(read(entry['path']))==entry['sha256'],'original347 binding: '+entry['path']
names={e['path'] for e in inputs}
for p in sorted(set(relocations)|{p.relative_to(ROOT).as_posix() for p in (ROOT/DIR).iterdir() if p.is_file()}):
    if p not in names:
        inputs.append({'path':p,'sha256':sha(read(p)),'role':'producer' if Path(p).suffix in ('.py','.pl') else 'input'}); names.add(p)
assert data['claims'][1:]==json.loads(original)['claims'][1:],'historical claims remain exact'
raw=(json.dumps(data,indent=2)+'\n').encode(); assert len(raw)<=131072
if sys.argv[1:]:
    assert read(CLAIM)==original,'guarded original draft replacement'
    (ROOT/CLAIM).write_bytes(raw)
else: assert read(CLAIM)==raw,'current chronology metadata/inputs drift'
print('Finite admission metadata closure PASS:',len(inputs),'live inputs;',len(raw),'bytes; original347 unchanged/345 current/two exact relocations')
