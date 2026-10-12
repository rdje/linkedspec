"""One-shot preserve intersecting publications before the mutation/write predicate binding repair."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '99f2939ac1d5e543bc2aa7f9c38b8166d5d510cc'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6-'
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
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
failure = json.loads((ROOT / (PREFIX + 'first-preservation-failure.json')).read_bytes())
assert failure['actual_returncode'] == 1
assert all(sha((ROOT / p).read_bytes()) == digest for p, digest in failure['inputs'].items())
assert base64.b64decode((json.loads((ROOT / (PREFIX + 'baseline.json')).read_bytes()))['stdout_base64']) == b'AST optional publication PASS: 517 live inputs; 119899 bytes\n'
target = ROOT / (PREFIX + 'preservation-final.json')
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
        assert (ROOT / before).read_bytes() == raw, 'exact first original full publication retained'
        selected.append({'path': path, 'before': before, 'sha256': sha(raw), 'bytes': len(raw), 'intersections': intersections})
        writes.append((path, (json.dumps(changed, indent=2) + '\n').encode()))
command = ['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-publish-claim.py']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
baseline = {'command': command, 'returncode': process.returncode,
    'stdout_base64': base64.b64encode(process.stdout).decode(),
    'stderr_base64': base64.b64encode(process.stderr).decode()}
baseline_path = ROOT / (PREFIX + 'baseline-final.json')
assert not baseline_path.exists()
baseline_path.write_text(json.dumps(baseline, indent=2) + '\n')
assert process.returncode == 0 and not process.stderr, 'actual original readonly baseline'
assert process.stdout == f"AST optional publication PASS: {selected[0]['intersections'][0]['bindings']} live inputs; {selected[0]['bytes']} bytes\n".encode()
assert len(selected) == 1 and selected[0]['path'] == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5.json'
assert sum(x['bindings'] for x in selected[0]['intersections']) == 517
for path, raw in writes:
    (ROOT / path).write_bytes(raw)
result = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'owned_bound_paths': sorted(OWNED), 'census': census, 'selected': selected,
    'baseline_sha256': sha(baseline_path.read_bytes()),
    'scope': 'Fixed original Git claim namespace. Every intersecting original live binding and full publication is verified before bound writes; only its live mode/revision pair becomes historical. Original readonly baseline has actual separate channels. No old observation or producer is refreshed.'}
target.write_text(json.dumps(result, indent=2) + '\n')
print('Mutation predicate preservation PASS:', selected[0]['intersections'][0]['bindings'], 'original bindings;', selected[0]['bytes'], 'full bytes; actual readonly baseline')
