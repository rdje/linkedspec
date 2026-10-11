"""Preserve every live intersection before the bounded hash-index writes."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '557a7d9e533710c6aae211f905ca2f231a8aedae'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7.json'
WRITES = {
    'perl/LinkedSpec/ActionIR/MethodLowering.pm',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'docs/knowledge/perl-method-ast-assignment-capture.md',
    'docs/knowledge/guarded-ast-change-history-capacity.md',
    'docs/knowledge/aggregate-selector-self-test-concurrency-boundary.md',
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'KNOWLEDGE_MAP.md',
    'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md', 'ROADMAP_V2.md',
    'docs/TASK_TREE.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md', CLAIM,
}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
for suffix in ('freeze.json', 'before-capacity.json', 'baseline.json'):
    assert not (ROOT / (PREFIX + suffix)).exists(), 'one-shot preservation'
selected = []
for source in sorted((ROOT / 'docs/claims').glob('*.json')):
    relative = source.relative_to(ROOT).as_posix()
    raw = source.read_bytes()
    for claim in json.loads(raw)['claims']:
        durability = claim['durability']
        common = WRITES & {entry['path'] for entry in durability.get('inputs', [])}
        if durability.get('mode') != 'live' or not common:
            continue
        assert raw == old(relative), 'accepted full claim'
        for entry in durability['inputs']:
            original = old(entry['path'])
            assert sha(original) == entry['sha256'], 'accepted Git binding: ' + entry['path']
            assert read(entry['path']) == original, 'before bound write: ' + entry['path']
        selected.append({'claim': relative, 'name': claim['name'],
                         'bindings': len(durability['inputs']), 'intersections': sorted(common)})
assert selected == [
    {'claim': CLAIM, 'name': 'finite-change-history-with-portable-evidence', 'bindings': 392,
     'intersections': ['CHANGES.md', 'DEVELOPMENT_NOTES.md',
        'docs/knowledge/aggregate-selector-self-test-concurrency-boundary.md',
        'docs/knowledge/guarded-ast-change-history-capacity.md',
        'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md']},
    {'claim': CLAIM, 'name': 'exact-private-array-end-selector-classification', 'bindings': 12,
     'intersections': ['docs/knowledge/aggregate-selector-self-test-concurrency-boundary.md']},
]
command = ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7/publish.py']
result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
baseline = {'command': command, 'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode(),
            'producer_sha256': sha(Path(__file__).read_bytes())}
(ROOT / (PREFIX + 'baseline.json')).write_text(json.dumps(baseline, indent=2) + '\n')
assert result.returncode == 0 and not result.stderr, 'accepted publication baseline'
before = old(CLAIM)
assert len(before) == 108215
record = json.loads(before)
for claim in record['claims']:
    if claim['durability'].get('mode') == 'live':
        claim['durability'].update(mode='historical', revision=BASE)
after = (json.dumps(record, indent=2) + '\n').encode()
(ROOT / (PREFIX + 'before-capacity.json')).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
(ROOT / (PREFIX + 'freeze.json')).write_text(json.dumps({
    'base': BASE, 'claim': CLAIM, 'before': PREFIX + 'before-capacity.json',
    'original_sha256': sha(before), 'after_sha256': sha(after),
    'producer_sha256': sha(Path(__file__).read_bytes()),
    'planned_writes': sorted(WRITES), 'intersections': selected,
    'scope': 'All392 primary and12 selector accepted bindings and full108215-byte four-claim publication stay exact. Only the two live mode/revision pairs become historical; both already historical claims stay unchanged. Actual accepted publisher baseline precedes bound writes. Every live record was checked for intersections.'
}, indent=2) + '\n')
print('Hash-index preservation PASS: original392/12 bindings/full108215-byte record; actual accepted publisher baseline')
