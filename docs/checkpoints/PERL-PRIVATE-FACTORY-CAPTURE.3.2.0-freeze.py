"""Preserve the complete accepted hash-index publication before package-flow writes."""
import base64
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4cc0b5a2a39ef3eec8baafbf874e43bd855e8b31'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5.json'
WRITES = {
    'perl/LinkedSpec/ActionIR/MethodLowering.pm',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'docs/knowledge/perl-method-slot-required-capture.md',
    'docs/knowledge/perl-method-ast-assignment-capture.md',
    'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'KNOWLEDGE_MAP.md',
    'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md', 'ROADMAP_V2.md',
    'docs/TASK_TREE.md', 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md',
    'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5.json',
}
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()


def old(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
for suffix in ('freeze.json', 'before-hash-index.json', 'baseline.json'):
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
assert selected == [{'claim': CLAIM, 'name': 'hash-index-required-callback-isolation', 'bindings': 350,
    'intersections': ['docs/knowledge/perl-method-ast-assignment-capture.md',
        'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
        'perl/LinkedSpec/ActionIR/MethodLowering.pm']}]
command = ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-publish-claim.py']
result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
baseline = {'command': command, 'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode(),
            'producer_sha256': sha(Path(__file__).read_bytes())}
(ROOT / (PREFIX + 'baseline.json')).write_text(json.dumps(baseline, indent=2) + '\n')
assert result.returncode == 0 and not result.stderr, 'accepted publication baseline'
before = old(CLAIM)
assert len(before) == 84391
record = json.loads(before)
assert record['claims'][0]['durability']['mode'] == 'live'
record['claims'][0]['durability'].update(mode='historical', revision=BASE)
after = (json.dumps(record, indent=2) + '\n').encode()
(ROOT / (PREFIX + 'before-hash-index.json')).write_bytes(before)
(ROOT / CLAIM).write_bytes(after)
(ROOT / (PREFIX + 'freeze.json')).write_text(json.dumps({
    'base': BASE, 'claim': CLAIM, 'before': PREFIX + 'before-hash-index.json',
    'original_sha256': sha(before), 'after_sha256': sha(after),
    'producer_sha256': sha(Path(__file__).read_bytes()),
    'planned_writes': sorted(WRITES), 'intersections': selected,
    'scope': 'All350 accepted bindings and full84391-byte two-claim publication stay exact. Only first live mode/revision becomes historical; original historical preservation claim stays unchanged. Actual accepted publisher baseline precedes bound writes. Every live record was checked for intersections.'
}, indent=2) + '\n')
print('Package-flow preservation PASS: original350 bindings/full84391-byte record; actual accepted publisher baseline')
