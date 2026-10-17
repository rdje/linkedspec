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
BASE = '736c6a43efab526fe898ed5c72b061479955fc5c'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'knowledge.json')
assert not target.exists(), 'one-shot complete population capture'
archive = subprocess.check_output(['git', 'archive', BASE, '--', 'docs/knowledge', 'docs/decisions'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as source:
    original = {item.name: {'bytes_base64': base64.b64encode(source.extractfile(item).read()).decode(),
                           'mode': item.mode} for item in source if item.isfile() and item.name.endswith('.md')}
paths = sorted(p.relative_to(ROOT).as_posix() for directory in ('docs/knowledge', 'docs/decisions')
               for p in (ROOT / directory).rglob('*.md') if p.is_file())
assert set(paths) == set(original) | {'docs/decisions/0135-finite-engineering-notes-member.md'} and len(paths) == 1486
current = {}
for path in paths + ['knowledge-map/scripts/check_knowledge_map.sh', 'knowledge-map/scripts/gen_knowledge_map.sh',
                     'knowledge-map/scripts/knowledge_map.conf', '.knowledge_map.conf', 'KNOWLEDGE_MAP.md',
                     'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
                     PREFIX + 'knowledge.py']:
    source = ROOT / path
    raw = source.read_bytes()
    current[path] = {'sha256': sha(raw), 'mode': source.stat().st_mode & 0o7777,
                     'bytes_base64': base64.b64encode(raw).decode()}
changed = [p for p in paths if p not in original or current[p]['bytes_base64'] != original[p]['bytes_base64']]
assert len(changed) == 13 and sum(p.startswith('docs/knowledge/') for p in changed) == 11
assert {'docs/decisions/INDEX.md', 'docs/decisions/0135-finite-engineering-notes-member.md'} <= set(changed)
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
          'scope': 'Complete original1485/current1486 Markdown bytes/modes and actual full gate channels. Eleven current card overlays retain whole original headers/bodies at accepted Git; ten route bodies remain exact and the finite-admission card prepends one current account. The sole ADR/index overhead is independently governed. No Knowledge card or budget grows. Capture writer is retired; readonly review checks full custody and current identities.'}
target.write_text(json.dumps(report, indent=2) + '\n')
assert process.returncode == 0 and not process.stdout
assert process.stderr == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert all(sha((ROOT / p).read_bytes()) == item['sha256'] for p, item in current.items())
print('Complete finite admission Knowledge gate PASS:1486 Markdown inputs; eleven card overlays; full original/current custody')
