"""One-shot accepted-input preservation before optional FlowExpr kind bindings."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '708c1afa04bb10aeacbdaf0a8133a95f380df434'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.2/'
OWNED = {
    'perl/LinkedSpec/ActionIR/FlowExpr.pm',
    'perl/LinkedSpec/RuleIR/EmitContext.pm',
    'docs/knowledge/perl-factory-capture-framework.md',
    'docs/knowledge/perl-factory-capture-plan.md',
    'docs/knowledge/perl-method-trim-capture.md',
    'docs/knowledge/perl-legacy-hash-kind-callback.md',
    'docs/knowledge/perl-method-assignment-required-capture.md',
    'docs/knowledge/perl-method-ast-call-capture.md',
    'docs/knowledge/perl-method-block-component-capture.md',
    'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
    'KNOWLEDGE_MAP.md', 'ROADMAP.md', 'ROADMAP_V2.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'MEMORY.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md',
    'docs/TASK_TREE.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
    'LIVE_ACHIEVEMENT_STATUS.md',
}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists(), 'one-shot preservation'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
paths = subprocess.check_output(
    ['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'],
    cwd=ROOT, text=True).splitlines()
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
            assert sha((ROOT / item['path']).read_bytes()) == item['sha256'], (
                'original live binding before all bound writes', path, item['path'])
            assert sha(old(item['path'])) == item['sha256'], (
                'accepted Git recoverability', path, item['path'])
        intersections.append({'claim_index': index, 'paths': hits,
                              'bindings': len(durability['inputs'])})
        changed['claims'][index]['durability']['mode'] = 'historical'
        changed['claims'][index]['durability']['revision'] = BASE
    census.append({'path': path, 'sha256': sha(raw), 'intersections': intersections})
    if intersections:
        before = PREFIX + 'before-' + Path(path).name
        with (ROOT / before).open('xb') as output:
            output.write(raw)
        selected.append({'path': path, 'before': before, 'sha256': sha(raw),
                         'bytes': len(raw), 'intersections': intersections})
        writes.append((path, (json.dumps(changed, indent=2) + '\n').encode()))
assert len(selected) == 1
prior = selected[0]
assert prior['path'] == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.0.json'
bindings = sum(item['bindings'] for item in prior['intersections'])
command = ['bash', 'tools/run_python_project_data.sh',
           'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/publish.py']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
baseline = {'command': command, 'returncode': process.returncode,
            'stdout_base64': base64.b64encode(process.stdout).decode(),
            'stderr_base64': base64.b64encode(process.stderr).decode()}
baseline_path = ROOT / (PREFIX + 'baseline.json')
with baseline_path.open('x') as output:
    output.write(json.dumps(baseline, indent=2) + '\n')
assert process.returncode == 0 and not process.stderr, 'actual accepted readonly baseline'
assert process.stdout == (
    b"Required FlowExpr final publication PASS: 451 live inputs; 112004 bytes;"
    b"both original uncommitted publications remain exact\n"), 'exact original readonly result'

for path, raw in writes:
    (ROOT / path).write_bytes(raw)
result = {'result': 'PASS', 'base': BASE,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'owned_bound_paths': sorted(OWNED), 'census': census, 'selected': selected,
          'baseline_sha256': sha(baseline_path.read_bytes()),
          'scope': 'Fixed accepted Git claim namespace. Every intersecting original input byte and complete publication is verified before bound writes. Only durability mode/revision becomes historical after the actual readonly baseline passes. Original instruments and observations remain unchanged; activation task-tree/pointer changes are outside this measured binding set.'}
with target.open('x') as output:
    output.write(json.dumps(result, indent=2) + '\n')
print('Optional FlowExpr preservation PASS:', len(selected), 'intersecting records;',
      bindings, 'original bindings;', prior['bytes'], 'full prior bytes; actual readonly baseline')
