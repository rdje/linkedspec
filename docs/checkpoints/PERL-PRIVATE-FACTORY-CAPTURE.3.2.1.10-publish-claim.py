"""Current readonly fixed-claim census/recovery publication; --capture writes once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ('accepted-review.py', 'historical.py', 'book-review.py', 'evidence.py'):
    result = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('actual readonly proof', tail, result.stderr)
review = json.loads((ROOT / (PREFIX + 'accepted-review.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 4
paths = set(review['input_metadata']) | set(evidence['inputs'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for p in sorted(paths)]
statement = ('The current readonly optional-kind review enumerates its original claim population from '
    'the same fixed Git boundary used for historical reads. The actual original post-maintenance '
    'publication fails at the unrelated newer hygiene claim. A complete532-input accepted-publication '
    'replay passes; extended533-input original review fails, corrected review passes, three syntax-valid '
    'population faults fail and exact restoration passes. Original25-input maintenance publication '
    'passes, rejects a changed bound predecessor claim and restores PASS. All390 original declared '
    'bindings and both full85779/9306-byte publications remain exact except live mode/revision pairs. '
    'Four actual evidence RED/restorations reject beyond updated immediate hashes. Complete89-input '
    'book/three controls and corrected current card routes pass. No runtime callback or language behavior changes.')
scope = ('Proof routing/recovery only. The retired .2 reviewer and all native, paired, fault, consumer, '
    'book and compatibility observations remain unchanged. The corrected executed body differs only '
    'in selecting the original Git claim population; its source/hash and executor are retained separately '
    'from the historical report original capture-producer identity. The complete historical namespaces '
    'are retained as compressed raw claim bytes and independently compared with Git. Recovery supplies '
    'every366 immediate publication binding, complete accepted namespace/full claim,33 absent published '
    'historical predecessor inputs and two explicit new instruments. The separately retained339-input '
    'historical predecessor claim already bound those33 inputs; the first499-input replay omission is '
    'an instrument defect, not an original missing durability leg. Both full predecessor publications '
    'retain their original bindings historically at16c70eaab688a877053b1addde8f07bc548e1cbf; original '
    'optional-kind logical replay uses acceptedfc96936fb and predecessor historical inputs at61cca1ccc. '
    'This publication reuses those full claim records rather than duplicating their original binding lists. '
    'Current runtime/proof files match their accepted bytes; only related book/card routing and claim '
    'preservation change. First wording-matcher, incomplete replay and wrong YAML-selection failures, '
    'their actual available merged outer channels and complete separate inner channels are retained. '
    'The first passing composed report and exact before-card bytes precede the final helper-name '
    'routing correction; a separate accepted reader checks this lineage. No original observation, '
    'producer or hash is refreshed. Readonly owning-repository Git object access uses optional locks '
    'disabled in supplied recovery; no Git-free/toolchain-immutable/cross-version claim. The previously '
    'accepted native1135/69-suite15093 proof is reused, not rerun as a new public compatibility admission. '
    'P2 container-cache .9, thirteen original ingress sites .3-.8, independent helper/private/parent/ '
    'canonical admissions and TYPE-REFERENCE-BOOK remain separately owned.')
claim = {'name': 'fixed-original-claim-population-readonly-recovery', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
        'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py; accepted-review.py, historical.py, book-review.py and evidence.py are also readonly defaults. Original capture/preserve/replay and --capture writers are retired one-shot producers.',
        'granularity': 'Each original390 binding/full claim; exact fixed-Git namespace/sole corrected source/executed identity; all532/533 supplied paths/modes/body variants and actual seven command results,25-input maintenance three-case recovery,33 published historical additions and first499-file failure; four damaged evidence records/actual named denials/restorations; all89 current book inputs/three controls and exact original knowledge bodies/current routes.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'A current filesystem claim namespace is interchangeable with an older accepted Git population, or omission/addition/stale selection and forged original/source/reason/book evidence can pass after updating immediate hashes.',
        'oracle': 'Exact historical Git and compressed complete claim populations, immutable full publications and published predecessor inputs; actual unchanged accepted publisher, corrected hash-bound source executor, complete supplied case inputs/channels and independent book source/include/render controls.',
        'red_control': 'Actual original newer-claim refusal; accepted publisher PASS, original-extra RED, corrected PASS, stale-body/omitted-origin/added-new source REDs, restored PASS. Maintenance bound-claim mutation RED/restored PASS. Evidence rejects forged-original beyond freeze SHA, censored semantic reason, stale corrected body and changed book beyond report SHA, each actual exact-restored review PASS. Book missing SUMMARY, removed marker despite exit0 and missing include retain three controls.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}
raw = (json.dumps({'version': 1, 'owner': LEAF, 'claims': [claim]}, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded publication bytes', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact current readonly publication'
print('Fixed claim census publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes')
