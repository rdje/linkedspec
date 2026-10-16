"""Preserve the accepted live publication before single-statement bound writes."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'c7570b71642e1889ab03ee07c29273dabdf16989'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.2/'
OWNED = {
    'perl/LinkedSpec/ActionIR/ControlFlow.pm', 'KNOWLEDGE_MAP.md',
    'docs/knowledge/perl-factory-capture-framework.md',
    'docs/knowledge/perl-match-alias-writability.md',
    'docs/knowledge/perl-emitcontext-callback-capture.md',
    'docs/knowledge/perl-method-default-capture.md',
    'docs/knowledge/perl-method-trim-capture.md',
    'docs/knowledge/perl-legacy-hash-kind-callback.md',
    'docs/knowledge/perl-method-assignment-required-capture.md',
    'docs/knowledge/perl-method-ast-call-capture.md',
    'docs/knowledge/perl-method-block-component-capture.md',
    'docs/knowledge/repo-generated-artifact-cleanup-boundary.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md', 'docs/TASK_TREE.md',
    'ROADMAP.md', 'ROADMAP_V2.md',
}
EXPECTED = {
    'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1.json': (
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/publish.py',
        b'ControlFlow attached-parser publication PASS: 461 live inputs; 110981 bytes\n', 461, 110981),
}

sha = lambda value: hashlib.sha256(value).hexdigest()
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists()
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
claim_paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'],
                                     cwd=ROOT, text=True).splitlines()
census, selected, writes = [], [], []
for path in sorted(claim_paths):
    raw = old(path)
    assert (ROOT / path).read_bytes() == raw
    original = json.loads(raw)
    changed = copy.deepcopy(original)
    hits = []
    for index, claim in enumerate(original['claims']):
        d = claim['durability']
        if d.get('mode') != 'live':
            continue
        intersection = sorted(OWNED & {x['path'] for x in d['inputs']})
        if not intersection:
            continue
        for item in d['inputs']:
            assert sha((ROOT / item['path']).read_bytes()) == item['sha256'] == sha(old(item['path']))
        hits.append({'claim_index': index, 'paths': intersection, 'bindings': len(d['inputs'])})
        changed['claims'][index]['durability'].update(mode='historical', revision=BASE)
    census.append({'path': path, 'sha256': sha(raw), 'intersections': hits})
    if hits:
        before = PREFIX + 'before-' + Path(path).name
        with (ROOT / before).open('xb') as output:
            output.write(raw)
        selected.append({'path': path, 'before': before, 'sha256': sha(raw),
                         'bytes': len(raw), 'intersections': hits})
        writes.append((path, (json.dumps(changed, indent=2) + '\n').encode()))
assert {x['path'] for x in selected} == set(EXPECTED)
baselines = []
for entry in selected:
    producer, suffix, count, size = EXPECTED[entry['path']]
    assert sum(x['bindings'] for x in entry['intersections']) == count and entry['bytes'] == size
    command = ['bash', 'tools/run_python_project_data.sh', producer]
    p = subprocess.run(command, cwd=ROOT, capture_output=True)
    row = {'claim': entry['path'], 'command': command, 'returncode': p.returncode,
           'stdout_base64': base64.b64encode(p.stdout).decode(),
           'stderr_base64': base64.b64encode(p.stderr).decode()}
    baselines.append(row)
    with (ROOT / (PREFIX + 'baseline-' + Path(entry['path']).stem + '.json')).open('x') as output:
        output.write(json.dumps(row, indent=2) + '\n')
    assert p.returncode == 0 and not p.stderr and p.stdout.endswith(suffix), 'actual accepted readonly baseline'
for path, raw in writes:
    (ROOT / path).write_bytes(raw)
result = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
          'owned_bound_paths': sorted(OWNED), 'census': census, 'selected': selected,
          'baselines': baselines,
          'scope': 'Fixed accepted Git namespace. The complete original publication and every461 original '
                   'binding are checked before all bound writes. Actual readonly baselines pass before only '
                   'durability mode/revision becomes historical. Original accepted Git retains every '
                   'producer/input byte; no old capsule is duplicated or observation refreshed. Activation '
                   'task/pointer edits are outside these measured input sets.'}
with target.open('x') as output:
    output.write(json.dumps(result, indent=2) + '\n')
print('Single-statement preservation PASS: one publication;461 bindings; full110981 bytes; actual readonly baseline')
