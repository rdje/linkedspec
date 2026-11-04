"""Read-only closed-narrative capacity intake from the clean activation source."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BASE = '659f19d748ddc9ddd6bc1c40c2c7b2d63107b138'
sys.path.insert(0, str(ROOT / 'tools'))
import task_narrative as subject


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def observe():
    assert not (HERE / 'intake.json').exists(), 'intake is one-shot'
    files = [f'docs/tasks/TYPE-REFERENCE-BOOK.{kind}.md' for kind in subject.PARTS]
    files += ['tools/task_narrative.py', 'tools/migrate_task_narrative.py',
              'tools/read_task_narrative.py', 'tools/test_task_narrative.py',
              'doctrine/readme_stability/routes.jsonl']
    inputs, parts = {}, []
    for name in files:
        blob = git('rev-parse', BASE + ':' + name).decode().strip()
        raw = git('cat-file', 'blob', blob)
        inputs[name] = {'blob': blob, 'sha256': hashlib.sha256(raw).hexdigest(),
                        'bytes': len(raw), 'retrieval': ['git', 'cat-file', 'blob', blob]}
        if name.startswith('tools/'):
            assert (ROOT / name).read_bytes() == raw, 'baseline producer already changed'
        if not name.startswith('docs/tasks/'):
            continue
        _, nodes = subject.nodes(raw)
        candidates = []
        for key, node in nodes.items():
            status = subject.fields(node).get('Status', b'')
            if not re.match(rb'  Status: `(done|completed|closed|superseded)`', status):
                continue
            if b'  Narrative: exact predecessor via ' in node:
                continue
            rendered = subject.compact(node, 'TYPE-REFERENCE-BOOK', key)
            if len(rendered) < len(node):
                candidates.append({'id': key, 'source_bytes': len(node),
                                   'legacy_render_bytes': len(rendered),
                                   'structural_saving': len(node) - len(rendered)})
        parts.append({'path': name, 'source_bytes': len(raw), 'nodes': len(nodes),
                      'candidate_count': len(candidates),
                      'structural_saving': sum(row['structural_saving'] for row in candidates),
                      'candidates': candidates})
    source = Path(__file__).read_bytes()
    report = {'owner': 'TYPE-REFERENCE-BOOK.1.2.20.2', 'activation_commit': BASE,
              'producer_source': source.decode(), 'producer_sha256': hashlib.sha256(source).hexdigest(),
              'inputs': inputs, 'parts': parts,
              'limits': 'Structural selection from the fixed clean Git source only. Existing compact '
                        'rendering is used to estimate available closed narrative, not to authorize its '
                        'old predecessor pointers for new nodes. No implementation, current file, '
                        'archive, numerical ceiling or dependency source is changed.'}
    (HERE / 'intake.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps([{key: value for key, value in part.items() if key != 'candidates'}
                      for part in parts], sort_keys=True))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true', required=True)
    parser.parse_args()
    observe()
