"""Freeze the complete admitted publication before pipeline-bound writes."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
knowledge = json.loads(old('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/knowledge.json'))
OWNED = set(knowledge['changed_cards']) | {
    'perl/LinkedSpec/ActionIR/RewritePipeline.pm', 'KNOWLEDGE_MAP.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md', 'docs/TASK_TREE.md',
    'MEMORY.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'CHANGES.md',
    'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
}
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists() and not (ROOT / (PREFIX + 'baseline.json')).exists()
names = subprocess.check_output(
    ['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
census, selected, writes = [], [], []
for name in names:
    value = old(name)
    assert (ROOT / name).read_bytes() == value
    source = json.loads(value)
    changed = copy.deepcopy(source)
    hits = []
    for index, claim in enumerate(source['claims']):
        durability = claim['durability']
        if durability.get('mode') != 'live':
            continue
        overlap = sorted(OWNED & {item['path'] for item in durability['inputs']})
        if not overlap:
            continue
        bindings = {}
        for item in durability['inputs']:
            path = ROOT / item['path']
            assert path.is_file() and not path.is_symlink()
            data = path.read_bytes()
            assert sha(data) == item['sha256'] == sha(old(item['path']))
            bindings[item['path']] = dict(sha256=item['sha256'], bytes=len(data),
                                         mode=path.stat().st_mode & 0o7777)
        hits.append(dict(claim_index=index, overlap=overlap, bindings=bindings))
        changed['claims'][index]['durability'].update(mode='historical', revision=BASE)
    census.append(dict(path=name, sha256=sha(value), intersections=[
        dict(claim_index=hit['claim_index'], overlap=hit['overlap']) for hit in hits]))
    if hits:
        selected.append(dict(path=name, sha256=sha(value), bytes=len(value),
                             original_base64=encode(value), hits=hits))
        # Keep the admitted record's readable one-space layout and unchanged cap.
        writes.append((name, (json.dumps(changed, indent=1) + '\n').encode()))
assert [item['path'] for item in selected] == [CLAIM]
assert selected[0]['bytes'] == 115985 and len(selected[0]['hits']) == 1
assert len(selected[0]['hits'][0]['bindings']) == 603
activation_paths = {'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md', 'MEMORY.md'}
assert not any(activation_paths & set(hit['overlap']) for row in census for hit in row['intersections'])
command = ['bash', 'tools/run_python_project_data.sh',
           'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/publish.py']
run = subprocess.run(command, cwd=ROOT, capture_output=True)
baseline = dict(command=command, returncode=run.returncode,
                stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr))
with (ROOT / (PREFIX + 'baseline.json')).open('x') as output:
    output.write(json.dumps(baseline, indent=2) + '\n')
assert run.returncode == 0 and not run.stderr
assert run.stdout == b'Supplied fixture admission publication PASS: 603 live inputs; 115985 bytes\n'
for name, item in selected[0]['hits'][0]['bindings'].items():
    path = ROOT / name
    assert sha(path.read_bytes()) == item['sha256'] and path.stat().st_mode & 0o7777 == item['mode']
record = dict(result='PASS', base=BASE, producer_sha256=sha(Path(__file__).read_bytes()),
              owned_bound_paths=sorted(OWNED), census=census, selected=selected, baseline=baseline,
              activation_only_unbound_paths=sorted(activation_paths),
              scope='Complete603-input/115985-byte accepted record, fixed Git claim namespace, '
                    'every input Git byte identity and actual filesystem mode plus actual readonly baseline '
                    'retained before bound writes. Only durability mode/revision changes; original '
                    'producers and observations remain at the real accepted Git boundary.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
for name, value in writes:
    assert len(value) <= 131072
    (ROOT / name).write_bytes(value)
print('Pipeline preservation PASS: whole603/full115985; actual readonly baseline; mode/revision only')
