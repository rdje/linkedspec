"""One-shot preserve intersecting publications before the container-cache repair."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'de02b83a1a794370b4071bb53677ab675745acc2'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-'
OWNED = {
    'perl/LinkedSpec/ActionIR/MethodLowering.pm',
    't/actionir_small_kind_capture.t',
    'docs/knowledge/perl-legacy-hash-kind-callback.md',
    'docs/knowledge/perl-method-trim-capture.md',
    'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists(), 'one-shot preservation'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
assert all((ROOT / p).read_bytes() == old(p) for p in OWNED), 'before all bound writes'
paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
census, selected, writes = [], [], []
for path in sorted(paths):
    raw = old(path)
    assert (ROOT / path).read_bytes() == raw, ('original claim bytes', path)
    record = json.loads(raw)
    changed = copy.deepcopy(record)
    intersections = []
    for index, claim in enumerate(record['claims']):
        durability = claim['durability']
        if durability.get('mode') != 'live':
            continue
        hit = sorted(OWNED & {item['path'] for item in durability['inputs']})
        if not hit:
            continue
        for item in durability['inputs']:
            assert sha((ROOT / item['path']).read_bytes()) == item['sha256'], ('original live binding', path, item['path'])
            assert sha(old(item['path'])) == item['sha256'], ('historical recoverability', path, item['path'])
        intersections.append({'claim_index': index, 'paths': hit, 'bindings': len(durability['inputs'])})
        changed['claims'][index]['durability']['mode'] = 'historical'
        changed['claims'][index]['durability']['revision'] = BASE
    census.append({'path': path, 'sha256': sha(raw), 'intersections': intersections})
    if intersections:
        before = PREFIX + 'before-' + Path(path).name
        assert not (ROOT / before).exists()
        (ROOT / before).write_bytes(raw)
        selected.append({'path': path, 'before': before, 'sha256': sha(raw), 'bytes': len(raw), 'intersections': intersections})
        writes.append((path, (json.dumps(changed, indent=2) + '\n').encode()))
command = ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10-publish-claim.py']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
baseline = {'command': command, 'returncode': process.returncode,
    'stdout_base64': base64.b64encode(process.stdout).decode(),
    'stderr_base64': base64.b64encode(process.stderr).decode()}
baseline_path = ROOT / (PREFIX + 'baseline.json')
assert not baseline_path.exists()
baseline_path.write_text(json.dumps(baseline, indent=2) + '\n')
assert process.returncode == 0 and not process.stderr, 'actual original readonly baseline'
assert process.stdout == b'Fixed claim census publication PASS: 422 live inputs; 97759 bytes\n'
assert len(selected) == 1 and selected[0]['path'] == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10.json'
assert sum(x['bindings'] for x in selected[0]['intersections']) == 422
for path, raw in writes:
    (ROOT / path).write_bytes(raw)
result = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'owned_bound_paths': sorted(OWNED), 'census': census, 'selected': selected,
    'baseline_sha256': sha(baseline_path.read_bytes()),
    'scope': 'Fixed original Git claim namespace. Every intersecting original live binding and full publication is verified before bound writes; only its live mode/revision pair becomes historical. Original readonly baseline has actual separate channels. No old observation or producer is refreshed.'}
target.write_text(json.dumps(result, indent=2) + '\n')
print('Container-cache preservation PASS: original422 bindings/full97759-byte publication; actual readonly baseline')
