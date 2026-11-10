"""Publish the bounded catalogue-fixture repair observation beside the map proof."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
NAME = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'
destination = ROOT / NAME
original = destination.read_bytes()
record = json.loads(original)
assert len(record['claims']) == 2, 'one-shot fixture publication already exists'
archive = HERE / 'implementation-pre-epoch-claim.json.gz'
assert not archive.exists()
archive.write_bytes(gzip.compress(original, mtime=0))
before = json.loads(gzip.decompress((HERE / 'epoch-fixture-qualified-before.json.gz').read_bytes()))
old_claim = json.loads(gzip.decompress((HERE / 'epoch-fixture-original-claim.json.gz').read_bytes()))
bindings = [row['sha256'] for claim in old_claim['claims'] for row in claim['durability'].get('inputs', [])
            if row['path'] == 'tools/test_task_narrative.py']
assert bindings and set(bindings) == {before['inputs']['tools/test_task_narrative.py']['sha256']}
names = ('epoch_fixture_capture.py', 'epoch-fixture-capture-original.py.gz',
         'epoch-fixture-qualified-before.json.gz', 'epoch-fixture-qualified-after.json.gz',
         'epoch_fixture_review.py', 'epoch-fixture-review-result.json',
         'epoch-fixture-original-claim.json.gz', 'preserve_epoch_claim.py',
         'epoch-claim-preservation-result.json', 'canonical-third.log.gz',
         'implementation-pre-epoch-claim.json.gz', 'publish_epoch_fixture.py')
paths = [HERE / name for name in names]
paths.extend(ROOT / name for name in ('tools/test_task_narrative.py', 'tools/task_narrative.py',
                                      'docs/claims/TYPE-REFERENCE-BOOK.1.2.20.2.json'))
inputs = [{'path': path.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
           'role': 'producer' if path.suffix == '.py' else 'input'} for path in paths]
record['claims'].append({
    'name': 'catalogue-complete-epoch-fixture-source-seeding',
    'statement': 'The isolated epoch fixture seeds every current source path declared by its retained catalogue, including Lua, with exact frozen file bytes; the original single-source setup reproduces the missing-Lua-file failure and the repaired consumer completes successfully.',
    'scope': 'Scoped fixture-source discovery/copying and dated actual consumer channels. Production readers, manifests, historical observations, runtime behavior and separate lowercase frontier4.17 remain unchanged. Frozen helper replay retains its complete scoped source inputs and immutable Git identities through retained manifests; no full control-program/native/archive-input closure or whole-feature admission credit. Initial direct collector attempts used a stale TYPE index and failed before retaining inner channels; their instrument is preserved without original-normal credit. Qualified before executes exact staged-old source privately with PYTHONPATH=tools and fresh real task indexes; qualified after executes the repaired production test.',
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/epoch_fixture_review.py && bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/preserve_epoch_claim.py',
                 'granularity': 'Every frozen catalogue source path and copied file body; actual original/candidate producer images and consumer channels; all original20.2 declared input hashes verified at its accepted capture.',
                 'result': (HERE / 'epoch-fixture-review-result.json').read_text().strip()},
    'falsify': {'status': 'checked',
                'hypothesis': 'Seeding only the selected older epoch can satisfy verification of the whole retained catalogue, or omitted/changed copied source files can pass the fixture oracle.',
                'oracle': 'Actual original consumer FileNotFoundError versus repaired exit0; independent frozen expected-file map compared with output membership/bytes after the archived actual helper runs.',
                'red_control': 'Actual old staged producer reproduces missing docs/tasks/LUA-BACKEND-PARITY.md. Missing-source and changed-source mutations reject; healthy frozen replay and repaired full consumer pass with empty stderr. Older20.2 producer matches the exact retained original; only its selected durability mode/revision and explicit historical scope change.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
})
assert record['claims'][:2] == json.loads(original)['claims']
raw = json.dumps(record, indent=2).encode() + b'\n'
assert len(raw) <= 131072
destination.write_bytes(raw)
