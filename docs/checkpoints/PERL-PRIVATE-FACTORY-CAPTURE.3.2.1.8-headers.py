"""One-shot bounded original Knowledge header census before current header repairs."""
import base64
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '22132b2b0eccb5ac38ef3c756f1b1e5b08992947'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-'
CARDS = ['docs/knowledge/' + name + '.md' for name in (
    'perl-method-trim-capture', 'perl-legacy-hash-kind-callback',
    'perl-method-assignment-required-capture', 'perl-method-ast-call-capture',
    'perl-method-block-component-capture', 'repo-generated-artifact-cleanup-boundary')]
SOURCES = ['knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md',
    'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh']
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
target = ROOT / (PREFIX + 'headers-census.json')
assert not target.exists(), 'one-shot original header census'
rows = []
for path in CARDS:
    raw = old(path)
    assert (ROOT / path).read_bytes() == raw, 'before current header writes'
    head = raw.split(b'\n---\n', 1)[0]
    active, orphans, route, route_kind = None, [], [], None
    for number, line in enumerate(head.decode().splitlines(), 1):
        field = re.match(r'^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$', line)
        if field:
            key, value = field.groups()
            active = key if not value else None
            if key == 'reverify':
                route_kind = 'scalar' if value else 'block-list'
                if value:
                    route.append(value.removeprefix('"').removesuffix('"'))
            continue
        item = re.match(r'^\s+-\s+(.*)$', line)
        if item:
            if active is None:
                orphans.append({'line': number, 'text': item[1]})
            if active == 'reverify' or active is None:
                route.append(item[1].removeprefix('"').removesuffix('"'))
    rows.append({'path': path, 'original_sha256': sha(raw),
        'header_base64': base64.b64encode(head).decode(),
        'reverify_kind': route_kind, 'routes': route, 'orphan_items': orphans})
inputs = {path: sha(old(path)) for path in CARDS + SOURCES}
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in inputs.items())
report = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'original_inputs': inputs, 'rows': rows,
    'scope': 'Complete six current owned Knowledge cards before header writes. Original Git bytes, complete headers, scalar/block reverify forms and orphan list entries retained. The architecture and actual portable awk parsers are bound. This is a bounded syntax/routing census; canonical full-population gate repair remains .3.2.1.11.'}
target.write_text(json.dumps(report, indent=2) + '\n')
print('Original Knowledge headers retained:', len(rows), 'cards;',
    sum(len(row['orphan_items']) for row in rows), 'orphan entries')
