"""One-shot current Knowledge population and actual full checker channels."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/'
target = ROOT / (PREFIX + 'current-final.json')
assert not target.exists(), 'one-shot current gate observation'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
original = json.loads(gzip.decompress((ROOT / ('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-population.json.gz')).read_bytes()))
paths = subprocess.check_output(['find', 'docs/knowledge', 'docs/decisions', '-type', 'f', '-name', '*.md'], cwd=ROOT, text=True).splitlines()
assert sorted(paths) == sorted(original), 'exact complete scan population'
inputs = {path: sha((ROOT / path).read_bytes()) for path in paths}
changed = sorted(path for path in paths if sha(base64.b64decode(original[path])) != inputs[path])
assert len(changed) == 6 and all(path.startswith('docs/knowledge/') for path in changed)
for path in ('knowledge-map/scripts/check_knowledge_map.sh', 'knowledge-map/scripts/gen_knowledge_map.sh',
             'knowledge-map/scripts/knowledge_map.conf', '.knowledge_map.conf', 'KNOWLEDGE_MAP.md'):
    inputs[path] = sha((ROOT / path).read_bytes())
command = ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
result = {'producer_sha256': sha(Path(__file__).read_bytes()), 'inputs': inputs, 'changed_cards': changed,
    'command': command, 'returncode': process.returncode,
    'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()}
target.write_text(json.dumps(result, indent=2) + '\n')
assert process.returncode == 0 and not process.stdout
assert process.stderr == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert all(sha((ROOT / path).read_bytes()) == value for path, value in inputs.items())
print('Current complete Knowledge gate PASS:', len(paths), 'Markdown inputs; six route updates; exact map and source identities')
