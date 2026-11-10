"""Readonly review of a frozen projection and a proposed duplicate-display trim."""
import argparse
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BASE = '6cd8e78437df8693c31a9af64c2e242977c84786'
INPUTS = (
    'KNOWLEDGE_MAP.md', 'README_POLICY.md',
    'doctrine/readme_stability/routes.jsonl',
    'knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md',
    'knowledge-map/scripts/gen_knowledge_map.sh',
    'knowledge-map/scripts/check_knowledge_map.sh',
    'tools/test_knowledge_map_projection.py',
    'tools/test_knowledge_map_atomic_output.py',
    't/knowledge_map_header_lists.t',
    '.githooks/pre-commit', 'tools/run_ci_local.sh',
    'scripts/check_readme_routing_pressure.pl',
)


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def capture():
    destination = HERE / 'baseline.json.gz'
    assert not destination.exists(), 'one-shot capture already exists'
    images = {}
    for path in INPUTS:
        raw = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
        images[path] = {'sha256': digest(raw), 'base64': base64.b64encode(raw).decode()}
    packet = {'base': BASE, 'inputs': images}
    destination.write_bytes(gzip.compress(json.dumps(packet, sort_keys=True).encode(), mtime=0))


def preserved(original, proposed):
    """Walk original records; deletion is allowed solely at redundant answers lines."""
    remaining = iter(proposed.splitlines(keepends=True))
    for line in original.splitlines(keepends=True):
        if line.startswith('- **answers:** '):
            continue
        if next(remaining, None) != line:
            raise ValueError('changed question route, anchor or retained metadata')
    if next(remaining, None) is not None:
        raise ValueError('unexpected added content')


def review():
    packet = json.loads(gzip.decompress((HERE / 'baseline.json.gz').read_bytes()))
    assert packet['base'] == BASE and set(packet['inputs']) == set(INPUTS)
    images = {}
    for path, image in packet['inputs'].items():
        raw = base64.b64decode(image['base64'], validate=True)
        assert digest(raw) == image['sha256'], 'input identity: ' + path
        images[path] = raw
    original = images['KNOWLEDGE_MAP.md'].decode()
    proposed = re.sub(r'(?m)^- \*\*answers:\*\* .*\n', '', original)
    preserved(original, proposed)
    questions, facts = original.split('## Facts (by id)\n', 1)
    question_rows = re.findall(r'(?m)^- ".* -> .*$', questions)
    identities = re.findall(r'(?m)^### (.+)$', facts)
    assert len(identities) == len(set(identities))
    assert len(identities) == len(re.findall(r'(?m)^- \*\*answers:\*\* ', facts))
    assert proposed.split('## Facts (by id)\n', 1)[0] == questions
    header_facts, header_questions = map(int, re.search(r'\*\*(\d+)\*\* facts · \*\*(\d+)\*\* question keys', questions).groups())
    assert header_facts == len(identities) and header_questions == len(question_rows)
    rejected = []
    patterns = {
        'question': r'(?m)^- ".* -> .*\n', 'anchor': r'(?m)^### .*\n',
        'title': r'(?m)^_.*_\n',
        **{key: r'\*\*' + key + r':\*\* ' for key in ('date', 'source', 'evidence', 'reverify')},
    }
    for name, pattern in patterns.items():
        changed, count = re.subn(pattern, '', proposed, count=1)
        assert count == 1
        try:
            preserved(original, changed)
        except ValueError:
            rejected.append(name)
        else:
            raise AssertionError('ineffective control: ' + name)
    corrupt = copy.deepcopy(packet)
    corrupt['inputs']['KNOWLEDGE_MAP.md']['sha256'] = '0' * 64
    assert digest(base64.b64decode(corrupt['inputs']['KNOWLEDGE_MAP.md']['base64'])) != corrupt['inputs']['KNOWLEDGE_MAP.md']['sha256']
    return {'base': BASE, 'facts': len(identities), 'question_keys': len(question_rows),
            'before_lines': len(original.splitlines()), 'before_bytes': len(original.encode()),
            'proposed_lines': len(proposed.splitlines()), 'proposed_bytes': len(proposed.encode()),
            'original_sha256': digest(images['KNOWLEDGE_MAP.md']),
            'proposed_sha256': digest(proposed.encode()), 'rejected_controls': rejected,
            'scope': 'Frozen-map prospective display only; no production generator or capacity admission.',
            'result': 'PASS'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    if args.capture:
        capture()
    print(json.dumps(review(), sort_keys=True))
