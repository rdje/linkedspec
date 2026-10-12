"""One-shot preserve before the four formal trim invocation repairs."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'b1133da422bbf19b54818c97c2b67a5e6a402012'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7-'
OWNED = {
    'perl/LinkedSpec/ActionIR/MethodLowering.pm',
    'docs/knowledge/perl-legacy-hash-kind-callback.md',
    'docs/knowledge/perl-method-trim-capture.md',
    'docs/knowledge/perl-method-assignment-required-capture.md',
    'docs/knowledge/perl-method-ast-call-capture.md',
    'docs/knowledge/perl-method-block-component-capture.md',
    'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists(), 'one-shot preservation'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
assert all((ROOT / path).read_bytes() == old(path) for path in OWNED), 'before all bound writes'
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
        hits = sorted(OWNED & {item['path'] for item in durability['inputs']})
        if not hits:
            continue
        for item in durability['inputs']:
            assert sha((ROOT / item['path']).read_bytes()) == item['sha256'], ('original live binding', path, item['path'])
            assert sha(old(item['path'])) == item['sha256'], ('historical recoverability', path, item['path'])
        intersections.append({'claim_index': index, 'paths': hits, 'bindings': len(durability['inputs'])})
        changed['claims'][index]['durability']['mode'] = 'historical'
        changed['claims'][index]['durability']['revision'] = BASE
    census.append({'path': path, 'sha256': sha(raw), 'intersections': intersections})
    if intersections:
        before = PREFIX + 'before-' + Path(path).name
        with (ROOT / before).open('xb') as output:
            output.write(raw)
        assert (ROOT / before).read_bytes() == raw
        selected.append({'path': path, 'before': before, 'sha256': sha(raw), 'bytes': len(raw), 'intersections': intersections})
        writes.append((path, (json.dumps(changed, indent=2) + '\n').encode()))
assert len(selected) == 1 and selected[0]['path'] == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6.json'
bindings = sum(item['bindings'] for item in selected[0]['intersections'])
assert bindings == 519 and selected[0]['bytes'] == 119936
command = ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-publish-claim.py']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
baseline = {'command': command, 'returncode': process.returncode,
    'stdout_base64': base64.b64encode(process.stdout).decode(),
    'stderr_base64': base64.b64encode(process.stderr).decode()}
baseline_path = ROOT / (PREFIX + 'baseline.json')
with baseline_path.open('x') as output:
    output.write(json.dumps(baseline, indent=2) + '\n')
assert process.returncode == 0 and not process.stderr, 'actual original readonly baseline'
assert process.stdout == f"Tracking predicate publication PASS: {bindings} live inputs; {selected[0]['bytes']} bytes\n".encode()
for path, raw in writes:
    (ROOT / path).write_bytes(raw)
result = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'owned_bound_paths': sorted(OWNED), 'census': census, 'selected': selected,
    'baseline_sha256': sha(baseline_path.read_bytes()),
    'scope': 'Fixed original Git claim namespace. All intersecting original live bindings and exact full publications are verified before source/card/book writes; only current durability mode/revision becomes historical after the actual original readonly baseline passes. Original producers/observations are unchanged.'}
target.write_text(json.dumps(result, indent=2) + '\n')
print('Formal trim preservation PASS:', bindings, 'original bindings;', selected[0]['bytes'], 'full bytes; actual readonly baseline')
