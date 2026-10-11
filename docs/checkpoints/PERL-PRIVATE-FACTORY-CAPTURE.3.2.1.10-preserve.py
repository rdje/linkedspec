"""Retain the first current refusal and preserve every intersecting original live claim."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '16c70eaab688a877053b1addde8f07bc548e1cbf'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10-'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
CLAIMS = ('docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json', 'docs/claims/REPO-HYGIENE.16.json')
WRITES = {'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'KNOWLEDGE_MAP.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md',
          'docs/knowledge/perl-legacy-hash-kind-callback.md', 'docs/knowledge/perl-method-trim-capture.md', 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
          'docs/linkedspec-book/src/development/documentation-workflow.md', *CLAIMS}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
assert not (ROOT / (PREFIX + 'refusal.json')).exists() and not (ROOT / (PREFIX + 'freeze.json')).exists()
baseline_path = 'docs/checkpoints/REPO-HYGIENE.16-review-baseline.json'
baseline_raw = old(baseline_path)
assert (ROOT / baseline_path).read_bytes() == baseline_raw
baseline = json.loads(baseline_raw)
assert baseline['returncode'] == 0 and baseline['unchanged'] and not base64.b64decode(baseline['stderr_base64'], validate=True)
assert b'366 live inputs; 85779 bytes' in base64.b64decode(baseline['stdout_base64'], validate=True)
assert baseline['inputs'][CLAIMS[0]] == sha(old(CLAIMS[0]))
command = ['python3', OLD + 'publish-claim.py']
result = subprocess.run(command, cwd=ROOT, capture_output=True)
refusal = {'command': command, 'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(), 'stderr_base64': base64.b64encode(result.stderr).decode(),
           'producer_sha256': sha(Path(__file__).read_bytes()), 'base': BASE,
           'prior_baseline': baseline_path, 'prior_baseline_sha256': sha(baseline_raw),
           'claim_inputs_before': {p: sha((ROOT / p).read_bytes()) for p in CLAIMS},
           'scope': 'First complete actual current readonly refusal after an unrelated maintenance claim. Prior actual readonly PASS is retained unchanged. No original/runtime producer or publication has changed before this observation.'}
(ROOT / (PREFIX + 'refusal.json')).write_text(json.dumps(refusal, indent=2) + '\n')
assert result.returncode != 0 and b'docs/claims/REPO-HYGIENE.16.json' in result.stderr and b'does not exist in' in result.stderr, 'actual unrelated-claim original refusal'
records = []
paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
for path in sorted(paths):
    raw = old(path)
    value = json.loads(raw)
    expected = copy.deepcopy(value)
    affected = []
    for index, claim in enumerate(value['claims']):
        leg = claim['durability']
        if leg.get('mode') != 'live' or not WRITES.intersection(entry['path'] for entry in leg['inputs']):
            continue
        assert all(sha(old(entry['path'])) == entry['sha256'] for entry in leg['inputs']), 'every original bound input'
        affected.append({'index': index, 'name': claim['name'], 'bindings': len(leg['inputs'])})
        expected['claims'][index]['durability'].update(mode='historical', revision=BASE)
    if affected:
        assert (ROOT / path).read_bytes() == raw, 'unchanged original before preservation'
        snapshot = PREFIX + 'before-' + Path(path).name
        records.append({'claim': path, 'before': snapshot, 'original_sha256': sha(raw), 'affected': affected,
                        'after_sha256': sha((json.dumps(expected, indent=2) + '\n').encode())})
assert [row['claim'] for row in records] == list(CLAIMS), 'complete original live intersection population'
for row in records:
    raw = old(row['claim'])
    (ROOT / row['before']).write_bytes(raw)
    expected = json.loads(raw)
    for entry in row['affected']:
        expected['claims'][entry['index']]['durability'].update(mode='historical', revision=BASE)
    (ROOT / row['claim']).write_text(json.dumps(expected, indent=2) + '\n')
report = {'base': BASE, 'records': records, 'planned_writes': sorted(WRITES),
          'producer_sha256': sha(Path(__file__).read_bytes()), 'refusal_sha256': sha((ROOT / (PREFIX + 'refusal.json')).read_bytes()),
          'scope': 'Every original390 declared binding and both full publications preserved; only each intersecting live mode/revision pair changes. Prior actual baseline and first actual namespace refusal precede bound writes. Retired observations/producers remain unchanged.'}
(ROOT / (PREFIX + 'freeze.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Original unrelated-claim refusal retained; two publications/390 bindings preserved')
