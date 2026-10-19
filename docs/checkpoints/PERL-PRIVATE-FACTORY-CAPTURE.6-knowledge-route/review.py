"""Readonly current routing review; caller owns the assembled compatibility input."""
import gzip
import json
import subprocess
import sys
from pathlib import Path
import route as r

assert sys.argv[1:] in ([], ['--capture'])
manifest = r.load()
a = r.artifact()
assert (r.ROOT / a.RAW).is_file() and r.sha((r.ROOT / a.RAW).read_bytes()) == a.load_manifest()['raw_sha256']
before = r.recover_before(manifest)
# The same original reader still executes from all recovered parts. The current
# card projection is checked separately below because its canonical home moved.
artifact_manifest = a.load_manifest()
replay = r.replay_before(manifest)
assert replay['returncode'] == 0 and not r.decode(replay['stderr_base64'])
assert r.decode(replay['stdout_base64']) == b'Current pipeline publication PASS: 696 live inputs; 117298 bytes; original625+161 supplied\n'
assert replay['all696_bytes_modes_unchanged'] and replay['whole_claim_mode_unchanged']
assert replay['compatibility_copy_removed']
projection = json.loads(gzip.decompress((r.ROOT / (r.ARTIFACTS + 'reader-projection.json.gz')).read_bytes()))
assert r.decode(projection['producer_base64']) == (r.ROOT / (r.ARTIFACTS + 'prepare-review.py')).read_bytes()
for path, item in artifact_manifest['proposal'].items():
    assert before[path] == r.decode(item['base64'])
    assert manifest['inputs'][path]['mode'] == item['mode']
part_controls = subprocess.run(['python3', r.ARTIFACTS + 'controls.py'], cwd=r.ROOT, capture_output=True)
assert part_controls.returncode == 0 and not part_controls.stderr, (part_controls.stdout, part_controls.stderr)
for path, item in manifest['proposal'].items():
    assert (r.ROOT / path).read_bytes() == r.decode(item['base64'])
    assert (r.ROOT / path).stat().st_mode & 0o7777 == item['mode']
assert not (r.ROOT / r.OLD_CARD).exists()
old_header, old_body = before[r.OLD_CARD].split(b'\n---\n', 1)
new_card = (r.ROOT / r.CARD).read_bytes()
assert old_body in new_card
assert all(line in new_card for line in old_header.splitlines() if line.startswith(b'  - "'))
baseline = manifest['baseline']
assert baseline['returncode'] == 0 and not r.decode(baseline['stderr_base64'])
assert r.decode(baseline['stdout_base64']) == b'Current pipeline publication PASS: 696 live inputs; 117298 bytes; original625+161 supplied\n'
failure = r.decode(manifest['original_gate_failure_base64'])
assert b'knowledge_cards exceeds control: files 1351/1350' in failure and b'FAIL  README-STABILITY' in failure
run = subprocess.run(['python3', r.PREFIX + 'review-docs.py'], cwd=r.ROOT, capture_output=True)
assert run.returncode == 0 and not run.stderr, ('actual complete supplied current documentation review', run.stdout, run.stderr)
report = dict(result='PASS', producer_sha256=r.sha(Path(__file__).read_bytes()),
    complete_before_inputs=696, original_claim_bytes=117298,
    canonical_card=r.CARD, removed_redundant_card=r.OLD_CARD,
    original_reader=replay,
    part_controls=dict(command=['python3', r.ARTIFACTS + 'controls.py'], returncode=part_controls.returncode,
                       stdout_base64=r.encode(part_controls.stdout), stderr_base64=r.encode(part_controls.stderr)),
    child=dict(command=['python3', r.PREFIX + 'review-docs.py'], returncode=run.returncode,
               stdout_base64=r.encode(run.stdout), stderr_base64=r.encode(run.stderr)),
    scope='Every before696 byte/mode remains exactly recoverable; actual full readonly baseline '
          'before changes is retained without refreshing native measurements. All three artifact '
          'questions and complete body survive in the richer maintained canonical home. Current '
          'complete supplied graph/map and unchanged full book are independently checked; no '
          'registry/limit/measurement is refreshed. Compatibility input lifetime belongs to caller.')
target = r.ROOT / (r.PREFIX + 'current-review.json')
if sys.argv[1:]:
    with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
else: assert json.loads(target.read_bytes()) == report
print('Current canonical-home proof PASS:whole696 recovered;all questions/body preserved;no cap changes')
