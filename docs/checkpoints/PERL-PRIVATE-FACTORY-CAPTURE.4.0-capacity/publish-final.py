"""Final readonly required FlowExpr publication after one archive EOF normalization."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/'
TARGET = ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.0.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
for tail in ['review-final.py', 'evidence-final.py']:
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual final readonly FlowExpr proof', tail, process.stderr)
review = json.loads((ROOT / (PREFIX + 'review-final.json')).read_bytes())
evidence = json.loads((ROOT / (PREFIX + 'evidence-final.json')).read_bytes())
assert review['result'] == evidence['result'] == 'PASS' and len(evidence['rows']) == 3
assert (review['eof_original_bindings'], review['eof_original_claim_bytes'], review['eof_supplied_inputs'], review['eof_supplied_controls'], review['eof_removed_bytes']) == (438, 105949, 1917, 2, 1)
assert (review['knowledge_markdown'], review['knowledge_facts'], review['knowledge_bytes']) == (1485, 1349, 8381805)
original = (ROOT / (PREFIX + 'eof-original-claim.json')).read_bytes()
paths = set(review['inputs']) | set(evidence['inputs'])
paths.update(PREFIX + tail for tail in ['review-final.py', 'review-final.json', 'evidence-final.py', 'evidence-final.json', 'publish-final.py', 'publish.py'])
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for p in sorted(paths)]
record = json.loads(original)
claim = record['claims'][0]
claim['statement'] += (' The complete first finite438-input/full105949 uncommitted publication is also '
 'preserved before removing exactly one final LF from its historical-header archive. Its unchanged publisher '
 'replays in1917 supplied inputs with two actual corruption controls and exact restoration. All live cards, '
 'Knowledge map, book, runtime, native observations and prior producers remain byte-exact. A distinct final '
 'reader/extractor/evidence/publisher identity and a thin current reader dispatcher retain stable card/book '
 'routes. Three final semantic artifact denials/restorations pass, including rehashed restoration of the extra LF.')
claim['scope'] += (' Archive EOF normalization only after complete438/full105949 preservation and actual '
 'readonly baseline. The first extractor/report/archive and actual old publisher source survive unchanged '
 'in the supplied snapshot; no earlier execution is relabeled with the new dispatcher identity. The original '
 'current publish.py source is retained there before it becomes a thin current reader pointer to the distinct '
 'publish-final.py. All fourteen full historical headers stay exact; only one redundant final LF is removed. '
 'Current live-card bytes remain8381805 under unchanged8388608, with no new card/map/book edit or runtime '
 'remeasurement. Original native/paired/fault/consumer/Phase0 proof remains governed by its original full '
 'source capsules. Normal focused hooks and a clean whitespace check govern final admission.')
claim['rederive'] = {'status': 'checked',
 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish.py (current thin dispatcher to publish-final.py). review-final.py, evidence-final.py, eof-replay.py, replay.py and book-review-final.py under the same wrapper/prefix have readonly defaults. All capture/preservation/extraction writers are retired. Original publishers run only in their supplied frozen boundaries.',
 'granularity': 'Both whole uncommitted408/full94719 and438/full105949 publications and every byte/mode; unchanged actual publishers in1887/1917 supplied inputs, two controls/restoration each. All original622 native rows/recurrences,1795 paired/490 RED/1305 controls,13 source faults and77/256/19470 consumer proof remain exact. Seven header extractions/14 full historical headers, original fact bodies/current routes and full1485/1349 Knowledge plus unchanged8381805/8388608 collection/member limits; book89/four controls; exactly one archive LF removed and only the current reader dispatcher additionally changes; three final semantic artifact denials/exact restorations.',
 'result': claim['statement']}
claim['falsify']['hypothesis'] += ' A redundant archive EOF LF could be retained under an amended digest, or old execution identities could be silently relabeled as a current reader.'
claim['falsify']['oracle'] += ' Complete first438/full105949 source/mode custody, unchanged old publisher in supplied isolation, exact original-archive-minus-one-LF comparison and distinct current source identities; existing independent header/collection/book oracles.'
claim['falsify']['red_control'] += (' Exact staged git diff --check originally returns2 for the archive EOF '
 'blank line. Frozen438 publisher rejects a forged whole claim and a missing actual fixture, then restores '
 'exact acceptance. The distinct final reader rejects rehashed header loss, a false collection byte count '
 'and rehashed restoration of the extra EOF LF for their exact deeper reasons; every restoration passes. '
 'No source observation is refreshed to make these controls pass.')
claim['durability'] = {'status': 'checked', 'mode': 'live', 'inputs': inputs}
raw = (json.dumps(record, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded final required FlowExpr publication', len(raw))
if sys.argv[1:]:
    assert TARGET.read_bytes() == original, 'replace only the completely preserved first finite publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'exact final readonly required FlowExpr publication'
print('Required FlowExpr final publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes;both original uncommitted publications remain exact')
