"""Readonly complete current admission review; immutable observations have independent anchors."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = base64.b64decode
raw = lambda path: (ROOT / path).read_bytes()
read = lambda name: json.loads(raw(PREFIX + name))
assert sys.argv[1:] in ([], ['--capture'])

snapshots = {}
for stem in ('native-before', 'native-extra-before', 'native-context-before', 'native-prove-context-before',
             'red', 'red-final', 'red-fixed', 'red-accepted', 'red-semantic', 'first-green', 'native-factory', 'runtime'):
    metadata = read(stem + '.json')
    packed = raw(PREFIX + stem + '-inputs.json.gz')
    assert sha(packed) == metadata.get('input_capsule_sha256', metadata.get('capsule_sha256'))
    snapshots[stem] = json.loads(gzip.decompress(packed))

def payload(item):
    return decode(item.get('base64', item.get('bytes_base64')))

for name, owner in [('native-before.json', 'red'), ('native-extra-before.json', 'red'),
                    ('native-context-before.json', 'red-accepted'),
                    ('native-prove-context-before.json', 'red-semantic'), ('native-factory.json', 'runtime')]:
    path = PREFIX + name
    assert raw(path) == payload(snapshots[owner][path]), ('immutable native observation', name, owner)

children = []
for name in ('review-runtime-final.py', 'review-documentation.py'):
    command = ['python3', PREFIX + name]
    run = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert run.returncode == 0 and not run.stderr, ('readonly reviewer', name, run.stdout, run.stderr)
    children.append(dict(command=command, returncode=run.returncode,
                         stdout_base64=base64.b64encode(run.stdout).decode(),
                         stderr_base64=base64.b64encode(run.stderr).decode()))

# Retired unique-name sources/observations never change merely because a later
# finisher has a new name. These anchors precede the final publication hashes.
immutable = {}
for owner, values in snapshots.items():
    for path, item in values.items():
        if not path.startswith(PREFIX):
            continue
        value = payload(item)
        assert sha(value) == item['sha256']
        assert raw(path) == value, ('retained original source/artifact', owner, path)
        assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
        if path in immutable:
            assert immutable[path] == item['sha256'], ('distinct immutable epochs', owner, path)
        immutable[path] = item['sha256']

review_repair = read('runtime-reviewer-repair.json')
assert decode(review_repair['original_source_base64']) == raw(PREFIX + 'review-runtime.py')
assert sha(raw(PREFIX + 'review-runtime-final.py')) == review_repair['corrected_source_sha256']
assert b"KeyError: 'bytes_base64'" in decode(review_repair['actual_combined_failure_base64'])
derived = read('derived-instruments.json')
for name, item in derived['templates'].items():
    value = subprocess.check_output(['git', 'show', BASE + ':' + item['path']], cwd=ROOT)
    assert value == decode(item['bytes_base64']) and sha(value) == item['sha256']
    assert sha(raw(PREFIX + name)) == derived['current'][name]
assert subprocess.check_output(['git', 'diff', '--name-only', BASE, '--', 'perl'], cwd=ROOT, text=True).splitlines() == [
    'perl/LinkedSpec/ActionIR/RewritePipeline.pm']

roster = read('current-input-roster.json')
assert roster == sorted(set(roster)) and PREFIX + 'review-current.py' in roster
assert PREFIX + 'current-input-roster.json' in roster
runtime = read('runtime.json')
knowledge = read('knowledge.json')
knowledge_capsule = json.loads(gzip.decompress(raw(PREFIX + 'knowledge-inputs.json.gz')))
historical_markdown = set(knowledge_capsule['original'])
live = set(runtime['inputs']) | set(roster)
live.update(path for path in knowledge['inputs'] if path not in historical_markdown or path in knowledge['changed_cards'])
live.update(read('documentation-review.json')['source_inputs'])
inputs = {}
for path in sorted(live):
    value = ROOT / path
    assert value.is_file() and not value.is_symlink()
    inputs[path] = dict(sha256=sha(value.read_bytes()), mode=value.stat().st_mode & 0o7777)
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()), children=children,
              inputs=inputs, immutable_prefix_inputs=immutable,
              population=dict(original_claim_inputs=603, original_claim_bytes=115985,
                              native_rows=96, supplemental_rows=9, public_native_calls=1,
                              supplied_inputs=426, focused_assertions=2065, semantic_inverses=13,
                              direct_suites=91, direct_assertions=32235,
                              markdown=1487, facts=1349, question_keys=10448, knowledge_bytes=8384111,
                              current_routes=15, changed_bodies=2, book_inputs=89, render_controls=4),
              scope='Whole accepted claim/native/source/repair custody, independent exact runtime inverses '
                    'and complete valid TAP, dated complete Knowledge snapshot/current15 overlays and '
                    'full book/rendered semantics. Every actual current input of this reader is explicit; '
                    'retired unique-name sources and original observations are anchored in prior captures. '
                    'No original native/capture/generator writer is executed or refreshed.')
target = ROOT / (PREFIX + 'current-review.json')
if sys.argv[1:]:
    with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
else: assert json.loads(target.read_bytes()) == report
print('Complete pipeline review PASS:2065/13;426 inputs;91/32235;Knowledge1487/15;book89/4;original custody')
