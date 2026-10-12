"""One-shot before/after public Knowledge checker observations and identical TAP proof."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-'
assert sys.argv[1:] in (['before'], ['after'])
stage = sys.argv[1]
target = ROOT / (PREFIX + stage + '.json')
assert not target.exists(), 'one-shot actual commands'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
paths = ['t/knowledge_map_header_lists.t', 'knowledge-map/scripts/check_knowledge_map.sh',
    'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/knowledge_map.conf',
    '.knowledge_map.conf', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
    PREFIX + 'population.json', PREFIX + 'population.json.gz',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-headers-census.json']
inputs = {path: sha((ROOT / path).read_bytes()) for path in paths}
rows = []
for command in (['perl', 't/knowledge_map_header_lists.t', '--observe'],
                ['prove', '-v', 't/knowledge_map_header_lists.t']):
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    rows.append({'command': command, 'returncode': process.returncode,
        'stdout_base64': base64.b64encode(process.stdout).decode(),
        'stderr_base64': base64.b64encode(process.stderr).decode()})
result = {'stage': stage, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': inputs, 'rows': rows}
target.write_text(json.dumps(result, indent=2) + '\n')
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in inputs.items()), 'unchanged during actual proof'
native = rows[0]
assert native['returncode'] == 0 and not base64.b64decode(native['stderr_base64'])
cases = json.loads(base64.b64decode(native['stdout_base64']))['rows']
assert len(cases) == 20 and len({row['name'] for row in cases}) == len(cases)
orphans = [row for row in cases if row['kind'] == 'orphan']
assert len(orphans) == 8 and sum(row['name'].startswith('historical-') for row in orphans) == 2
for row in cases:
    assert row['generate']['status'] == 0, ('actual generated fixture', row['name'])
    expected = 256 if row['kind'] == 'required' or (stage == 'after' and row['kind'] == 'orphan') else 0
    assert row['check']['status'] == expected, ('actual public verdict', row['name'], row['check']['status'])
    assert not base64.b64decode(row['check']['stdout_base64'])
    stderr = base64.b64decode(row['check']['stderr_base64'])
    if stage == 'after' and row['kind'] == 'orphan':
        assert re.search(rb'front-matter orphan list item at line \d+', stderr), row['name']
tap = base64.b64decode(rows[1]['stdout_base64']).decode()
failures = re.findall(r'^not ok (\d+) - (.*)$', tap, re.M)
assert re.search(r'^1\.\.80$', tap, re.M), 'complete numeric test plan'
assert len(re.findall(r'^(?:not )?ok \d+ - ', tap, re.M)) == 80
assert len(failures) == (16 if stage == 'before' else 0), ('actual named REDs', failures)
assert bool(rows[1]['returncode']) == (stage == 'before')
print('Knowledge public checker', stage, 'PASS:', len(cases), 'cases; 80 assertions;', len(failures), 'observed failures')
