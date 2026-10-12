"""One-shot original Knowledge population capsule and list-association census."""
import base64
import gzip
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '328b11c5ed1d5ffbc870f6785448e3a8249fe882'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'population.json')
capsule = ROOT / (PREFIX + 'population.json.gz')
assert not target.exists() and not capsule.exists(), 'one-shot original population'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--',
    'docs/knowledge', 'docs/decisions'], cwd=ROOT, text=True).splitlines()
rows, contents = [], {}
for path in sorted(path for path in paths if path.endswith('.md')):
    raw = (ROOT / path).read_bytes()
    original = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    assert raw == original, ('before Knowledge writes', path)
    contents[path] = base64.b64encode(raw).decode()
    lines = raw.decode().splitlines()
    current, orphans, forms, answers, closed = None, [], {}, False, False
    if lines and lines[0].strip() == '---':
        for number, line in enumerate(lines[1:], 2):
            if line.strip() == '---':
                closed = True
                break
            if re.match(r'^[ \t]+-[ \t]+', line):
                if current is None:
                    orphans.append({'line': number, 'text': line})
                if current == 'answers' and re.sub(r'^[ \t]+-[ \t]+', '', line).strip(' "'):
                    answers = True
                continue
            match = re.match(r'^([A-Za-z_][A-Za-z0-9_]*):(.*)$', line)
            if match:
                key, value = match.group(1), match.group(2).strip()
                kind = 'block' if not value else 'inline' if value.startswith('[') and value.endswith(']') else 'scalar'
                forms[kind] = forms.get(kind, 0) + 1
                current = key if kind == 'block' else None
                if key == 'answers' and kind == 'inline' and re.search(r'[A-Za-z0-9]', value):
                    answers = True
    rows.append({'path': path, 'sha256': sha(raw), 'bytes': len(raw),
        'fact': answers, 'closed_front_matter': closed, 'forms': forms, 'orphans': orphans})
capsule.write_bytes(gzip.compress((json.dumps(contents, sort_keys=True) + '\n').encode(), mtime=0))
assert json.loads(gzip.decompress(capsule.read_bytes())) == contents
inputs = ['knowledge-map/scripts/check_knowledge_map.sh', 'knowledge-map/scripts/gen_knowledge_map.sh',
    'knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md', 'knowledge-map/scripts/knowledge_map.conf', '.knowledge_map.conf']
result = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'capsule_sha256': sha(capsule.read_bytes()), 'rows': rows,
    'source_inputs': {path: sha((ROOT / path).read_bytes()) for path in inputs},
    'scope': 'Exact complete tracked original Markdown scan population; full bytes in the capsule, independently counted header list association. Current .8 repaired headers precede this .11 capture. Historical four orphan entries remain in immutable .8 evidence.'}
target.write_text(json.dumps(result, indent=2) + '\n')
print('Original Knowledge population:', len(rows), 'Markdown inputs;', sum(row['fact'] for row in rows),
    'facts;', sum(len(row['orphans']) for row in rows), 'orphan entries;', len(capsule.read_bytes()), 'capsule bytes')
