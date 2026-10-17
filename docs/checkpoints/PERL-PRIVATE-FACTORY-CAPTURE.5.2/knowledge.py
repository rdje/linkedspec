"""One-shot complete accepted/current Knowledge population and actual gate channels."""
import base64
import gzip
import hashlib
import io
import json
import subprocess
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'a60764c11ae9bc59242b0220b7ef843a4e579b80'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.2/'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'knowledge.json')
assert not target.exists(), 'one-shot complete population capture'
archive = subprocess.check_output(['git', 'archive', BASE, '--', 'docs/knowledge', 'docs/decisions'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as source:
    original = {item.name: {'bytes_base64': base64.b64encode(source.extractfile(item).read()).decode(),
                           'mode': item.mode} for item in source if item.isfile() and item.name.endswith('.md')}
paths = sorted(p.relative_to(ROOT).as_posix() for directory in ('docs/knowledge', 'docs/decisions')
               for p in (ROOT / directory).rglob('*.md') if p.is_file())
assert paths == sorted(original) and len(paths) == 1486
current = {}
for path in paths + ['knowledge-map/scripts/check_knowledge_map.sh', 'knowledge-map/scripts/gen_knowledge_map.sh',
                     'knowledge-map/scripts/knowledge_map.conf', '.knowledge_map.conf', 'KNOWLEDGE_MAP.md',
                     'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
                     PREFIX + 'knowledge.py']:
    source = ROOT / path
    raw = source.read_bytes()
    current[path] = {'sha256': sha(raw), 'mode': source.stat().st_mode & 0o7777,
                     'bytes_base64': base64.b64encode(raw).decode()}
changed = [p for p in paths if current[p]['bytes_base64'] != original[p]['bytes_base64']]
assert len(changed) == 12 and all(p.startswith('docs/knowledge/') for p in changed)
capsule = ROOT / (PREFIX + 'knowledge-inputs.json.gz')
with capsule.open('xb') as output:
    output.write(gzip.compress(json.dumps({'original': original, 'current': current}, sort_keys=True).encode(), mtime=0))
command = ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
report = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
          'capsule_sha256': sha(capsule.read_bytes()), 'markdown': len(paths), 'changed_cards': changed,
          'inputs': {p: {'sha256': item['sha256'], 'mode': item['mode']} for p, item in current.items()},
          'command': command, 'returncode': process.returncode,
          'stdout_base64': base64.b64encode(process.stdout).decode(),
          'stderr_base64': base64.b64encode(process.stderr).decode(),
          'scope': 'Every original accepted Markdown byte/mode and current complete scan input is retained. Twelve current card overlays retain their whole original headers/bodies through accepted Git and the original full publication; eleven route-card bodies remain exact, while framework receives current causal facts. No card is added. Actual complete Knowledge gate runs against current source/map. Capture writer is retired; the independent reader owns population, header syntax, route lineage, fact count and all byte identities.'}
target.write_text(json.dumps(report, indent=2) + '\n')
assert process.returncode == 0 and not process.stdout
assert process.stderr == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert all(sha((ROOT / p).read_bytes()) == item['sha256'] for p, item in current.items())
print('Complete ControlFlow if/while Knowledge gate PASS:1486 Markdown inputs; twelve card overlays; full original/current custody')
