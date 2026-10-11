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
for tail in ('review.py','evidence.py','metadata-review.py','hygiene.py'):
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

disclosure+=(' The exact prior362-input metadata closure and publisher are retained;361 inputs remain current and its publisher relocates byte-identically. '
             'Actual identical-candidate canonical attempt02 passes nine doctrines and rejects producer-free checked historical records before runtime CI starts. '
             'The first attempt exited1 but its detailed log was lost inside automatic managed scratch cleanup; that cause remains unknown. Persistent project-local logging and explicit failed-run retention repair the invocation without wrapper changes. '
             'Actual production validate() controls reject both original historical entries and accept exact provenance repairs: one existing pressure-checker role becomes producer, and the original scalar publisher is added as a historical producer without changing any original SHA. '
             'An additional intersecting REPO-HYGIENE.15 live book binding was discovered after the book edit. All19 original hashes and full claim fields are independently recovered at accepted d8418423e; only mode/revision changes. '
             'Late timing is disclosed, a beyond-immediate-SHA original-binding RED restores, and no dated artifact/runtime/book observation is refreshed. Related hygiene Knowledge retains the dated body under explicit historical context and teaches all-live intersection/provenance/log retention. '
             'Existing SESSION-STARTUP-READING.7 owns the restricted false-abandoned recurrence; permitted known-PID inspection confirms live CI, and no recovery/purge is performed.')
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
for p in sorted(set(relocations)|{'docs/claims/REPO-HYGIENE.15.json','docs/knowledge/repo-generated-artifact-cleanup-boundary.md','tools/check_claim_verification.py'}|{p.relative_to(ROOT).as_posix() for p in (ROOT/DIR).iterdir() if p.is_file()}):
    if p not in names:
        inputs.append({'path':p,'sha256':sha(read(p)),'role':'producer' if Path(p).suffix in ('.py','.pl') else 'input'}); names.add(p)

BASE='d8418423e7461235280e9a34b9d90f4571fc9490'
def old(path): return subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)
baseline=copy.deepcopy(data['claims'][1:])
row=next(e for e in data['claims'][1]['durability']['inputs'] if e['path']=='scripts/check_readme_routing_pressure.pl')
assert row['role']=='input'; row['role']='producer'
scalar_pub='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-publish-claim.py'
producer={'path':scalar_pub,'sha256':sha(old(scalar_pub)),'role':'producer'}
data['claims'][2]['durability']['inputs'].append(producer)
expected=copy.deepcopy(baseline)
next(e for e in expected[0]['durability']['inputs'] if e['path']=='scripts/check_readme_routing_pressure.pl')['role']='producer'
expected[1]['durability']['inputs'].append(producer)
assert data['claims'][1:]==expected, 'sole historical provenance metadata repairs'
hygiene='docs/claims/REPO-HYGIENE.15.json'; hygiene_pub='docs/checkpoints/REPO-HYGIENE.15-claim.py'
data['claims'].append({
    'name':'original-hygiene-publication-boundary',
    'statement':'All19 original dated hygiene hashes and claim fields remain exact at accepted d8418423e; only its live mode/revision changes. Shared-book intersection was discovered after the edit and this late timing is disclosed.',
    'scope':'Original full hygiene claim and19 referenced Git inputs; no dated observation, artifact count, cleanup or hash refresh. Related original card body remains dated under explicit historical context. Actual current chapter stays the already captured89-input book source.',
    'rederive':{'status':'checked','command':'bash tools/run_python_project_data.sh '+DIR+'hygiene.py (readonly final default)','granularity':'Full original claim, every19 accepted Git hash, exact mode/revision-only conversion and every17 unaffected current input; authorized book/card successors separately checked.','result':'All19 accepted bindings and original claim fields retained exactly; late preservation timing explicit.'},
    'falsify':{'status':'checked','hypothesis':'Updated immediate freeze-SHA metadata might conceal a changed original binding.','oracle':'Accepted Git full claim and19 original input blobs, exact JSON comparison allowing only live mode/revision.','red_control':'Actual original-binding mutation plus matching immediate metadata update rejects for exact original hygiene claim; complete channels/changed bytes retained and exact restoration passes.'},
    'durability':{'status':'checked','mode':'historical','revision':BASE,'inputs':[{'path':hygiene,'sha256':sha(old(hygiene)),'role':'input'},{'path':hygiene_pub,'sha256':sha(old(hygiene_pub)),'role':'producer'}]}})

raw=(json.dumps(data,indent=2)+'\n').encode(); assert len(raw)<=131072
if sys.argv[1:]:
    assert read(CLAIM)==read(DIR+'metadata-before-claim.json'),'guarded prior362 metadata replacement'
    (ROOT/CLAIM).write_bytes(raw)
else: assert read(CLAIM)==raw,'current chronology metadata/inputs drift'
print('Finite admission metadata closure PASS:',len(inputs),'live inputs;',len(raw),'bytes; original347/362 inputs retained; historical producer provenance and hygiene19 repaired')
