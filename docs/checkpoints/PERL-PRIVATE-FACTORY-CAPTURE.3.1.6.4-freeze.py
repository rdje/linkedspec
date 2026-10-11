"""Preserve every intersecting live claim before required array-end parser writes."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '98990ffbc4a7150b20d0e416be3ea4f9938cfd10'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3.json'
WRITES = {
    'perl/LinkedSpec/ActionIR/MethodLowering.pm',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'docs/knowledge/perl-method-ast-array-end-capture.md',
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'KNOWLEDGE_MAP.md',
    'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md', 'ROADMAP_V2.md',
    'docs/TASK_TREE.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md', CLAIM,
}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
for suffix in ('freeze.json', 'before-hash-required.json', 'baseline.json'):
    assert not (ROOT / (PREFIX + suffix)).exists(), 'one-shot preservation'
selected = []
for source in sorted((ROOT / 'docs/claims').glob('*.json')):
    relative = source.relative_to(ROOT).as_posix()
    raw = source.read_bytes()
    record = json.loads(raw)
    for claim in record['claims']:
        durability = claim['durability']
        common = WRITES & {entry['path'] for entry in durability.get('inputs', [])}
        if durability.get('mode') != 'live' or not common:
            continue
        assert raw == old(relative), 'accepted full claim'
        for entry in durability['inputs']:
            original = old(entry['path'])
            assert sha(original) == entry['sha256'], 'accepted Git binding: ' + entry['path']
            assert read(entry['path']) == original, 'preservation before bound write: ' + entry['path']
        selected.append({'claim': relative, 'name': claim['name'],
                         'bindings': len(durability['inputs']), 'intersections': sorted(common)})
assert selected == [{'claim': CLAIM, 'name': 'hash-required-callback-isolation',
                     'bindings': 321, 'intersections': ['docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', 'perl/LinkedSpec/ActionIR/MethodLowering.pm']}]
command = ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3-publish-claim.py']
result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
baseline = {'command': command, 'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode(),
            'producer_sha256': sha(Path(__file__).read_bytes())}
(ROOT / (PREFIX + 'baseline.json')).write_text(json.dumps(baseline, indent=2) + '\n')
assert result.returncode == 0 and not result.stderr, 'accepted current publication baseline'
before = old(CLAIM)
record = json.loads(before)
record['claims'][0]['durability'].update(mode='historical', revision=BASE)
after = (json.dumps(record, indent=2) + '\n').encode()
(ROOT / (PREFIX + 'before-hash-required.json')).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
(ROOT / (PREFIX + 'freeze.json')).write_text(json.dumps({
    'base': BASE, 'claim': CLAIM, 'before': PREFIX + 'before-hash-required.json',
    'original_sha256': sha(before), 'after_sha256': sha(after),
    'producer_sha256': sha(Path(__file__).read_bytes()),
    'planned_writes': sorted(WRITES), 'intersections': selected,
    'scope': 'All321 accepted live bindings and the full original claim are preserved before source/book/card writes. Only first live durability mode/revision changes; the separate original-review-command preservation claim and all old fields/producer/hash/observations remain exact. Every live record was checked for intersections.'
}, indent=2) + '\n')
print('Required array-end preservation PASS: all live intersections, original321 bindings/full claim, actual accepted publication baseline')
