"""One-shot public generator reproduction for separately scheduled metadata projection."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-'
target = ROOT / (PREFIX + 'metadata-lists.json')
assert not target.exists(), 'one-shot projection diagnosis'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
before = json.loads((ROOT / (PREFIX + 'before.json')).read_bytes())
native = json.loads(base64.b64decode(before['rows'][0]['stdout_base64']))['rows']
rows = []
for case in native:
    if case['name'] not in ('block-evidence', 'block-reverify'):
        continue
    assert case['check']['status'] == 0, 'actual retained original public acceptance'
    with tempfile.TemporaryDirectory(prefix='metadata-list-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        scan = supplied / 'facts'
        scan.mkdir()
        raw = b'---\n' + base64.b64decode(case['header_base64']) + b'---\n'
        (scan / 'fact.md').write_bytes(raw)
        output = supplied / 'map.md'
        env = dict(os.environ, KM_SCAN_DIRS=scan.relative_to(ROOT).as_posix(), KM_OUTPUT=output.relative_to(ROOT).as_posix())
        command = ['bash', 'knowledge-map/scripts/gen_knowledge_map.sh']
        process = subprocess.run(command, cwd=ROOT, env=env, capture_output=True)
        mapped = output.read_bytes()
        assert process.returncode == 0
        field = 'evidence' if case['name'] == 'block-evidence' else 'reverify'
        assert ('**' + field + ':**').encode() not in mapped
        assert b'### sample' in mapped and b'first question' in mapped
        rows.append({'name': case['name'], 'input_base64': base64.b64encode(raw).decode(),
            'original_checker_status': case['check']['status'], 'command': command, 'returncode': process.returncode,
            'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode(),
            'map_base64': base64.b64encode(mapped).decode(), 'missing_field': field})
assert len(rows) == 2
result = {'result': 'REPRODUCED', 'repair_owner': 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12',
    'producer_sha256': sha(Path(__file__).read_bytes()), 'before_sha256': sha((ROOT / (PREFIX + 'before.json')).read_bytes()),
    'generator_sha256': sha((ROOT / 'knowledge-map/scripts/gen_knowledge_map.sh').read_bytes()), 'rows': rows,
    'scope': 'Two named public valid-block controls; original checker acceptance and fresh unchanged generator omission. No complete affected population count or field-type remedy is claimed.'}
target.write_text(json.dumps(result, indent=2) + '\n')
print('Metadata list omission reproduced: evidence/reverify; P3 .3.2.1.12 scheduled after factory/pipeline before type reference')
