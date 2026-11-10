"""Preserve the prior declaration and close its saved-channel replay coverage."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
path = ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'
original = path.read_bytes()
before = json.loads(original)
saved = HERE / 'implementation-pre-callable-replay-claim.json.gz'
assert not saved.exists(), 'one-shot coverage qualification'
assert len(before['claims']) == 7
saved.write_bytes(gzip.compress(original, mtime=0))
record = copy.deepcopy(before)
source, native = record['claims'][5:]
assert source['name'] == 'callable-prepared-index-and-count-snapshot-source-custody'
assert native['name'] == 'callable-indexed-value-focused-behavior-with-custody-gap'
assert source['rederive']['command'] == native['rederive']['command']
command = source['rederive']['command'] + ' && bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/callable_channels_review.py'
result = (HERE / 'callable-channels-review-result.json').read_text().strip()
assert json.loads(result)['result'] == 'PASS'
for item in (source, native):
    item['rederive']['command'] = command
    item['rederive']['result'] += '\nQualified direct-channel coverage: ' + result
    item['scope'] += ' The prior replay command inspected the original fixture/source-fence artifacts but omitted saved direct-test channel coverage. Its declaration remains retained without first-declaration completeness credit. The qualified command additionally checks exact saved targets/exits, all original target failures, four direct passing files, calibrated18-row PASS and the six authored cases against frozen consumer bytes. Original before metadata hashes decoded channels; later packaging hashes physical gzip bytes. The initial reader assumes one domain and rejects; its exact source/empty output remain retained. Corrected explicit domains preserve every original hash. This adds artifact interpretation, not native re-execution or missing first-use custody.'
source['falsify']['red_control'] += ' The added channel reader rejects missing-pass, wrong-target, wrong-exit, missing-original-failure and missing-authored-case corruptions.'
names = ('callable_channels_review.py', 'callable-channels-review-result.json',
         'callable-channels-initial-review.py.gz', 'callable-channels-initial-empty-output.gz',
         'qualify_callable_replay.py', saved.name, 'canonical-seventh.log.gz',
         'stop_seventh.py', 'canonical-seventh-stop.json.gz', 'canonical-seventh-stop-result.json')
inputs = source['durability']['inputs']
assert not set((HERE / name).relative_to(ROOT).as_posix() for name in names) & {row['path'] for row in inputs}
for name in names:
    target = HERE / name
    inputs.append(dict(path=target.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
                       role='producer' if target.suffix == '.py' else 'input'))
inputs.sort(key=lambda row: row['path'])
assert record['claims'][:5] == before['claims'][:5]
assert source['statement'] == before['claims'][5]['statement']
assert native['statement'] == before['claims'][6]['statement']
assert native['durability'] == before['claims'][6]['durability'], 'native closure gap stays disclosed'
for row in before['claims'][5]['durability']['inputs']:
    assert row in inputs, 'preserve every earlier source/result/producer binding'
raw = (json.dumps(record, indent=2) + '\n').encode()
assert len(raw) <= 128 * 1024
path.write_bytes(raw)
print(json.dumps(dict(result='qualified', unchanged_prior_claims=5, preserved_source_bindings=True, bytes=len(raw), native_gap='TYPE-REFERENCE-BOOK.1.2.23.4.2'), sort_keys=True))
