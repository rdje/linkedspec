"""Preserve every first finite-publication byte before one archive EOF normalization."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'eof-preservation.json')
assert not target.exists(), 'one-shot complete finite-publication preservation'
raw = (ROOT / 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.0.json').read_bytes()
declared = json.loads(raw)['claims'][0]['durability']['inputs']
assert len(raw) == 105949 and len(declared) == 438
capsule = {}
for item in declared:
    source = ROOT / item['path']
    data = source.read_bytes()
    assert sha(data) == item['sha256'], ('every original finite binding before correction', item['path'])
    capsule[item['path']] = {'sha256': sha(data), 'mode': source.stat().st_mode & 0o7777,
                            'bytes_base64': base64.b64encode(data).decode()}
for tail, data in [('eof-original-claim.json', raw), ('eof-original-inputs.json.gz', gzip.compress(json.dumps(capsule, sort_keys=True).encode(), mtime=0))]:
    with (ROOT / (PREFIX + tail)).open('xb') as output:
        output.write(data)
command = ['python3', PREFIX + 'publish.py']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
assert process.returncode == 0 and not process.stderr
assert process.stdout == b'Final required FlowExpr publication PASS: 438 live inputs; 105949 bytes;original408/full94719 remains exact\n'
target.write_text(json.dumps({'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
 'original_bindings': 438, 'original_claim_bytes': 105949, 'original_claim_sha256': sha(raw),
 'capsule_sha256': sha((ROOT / (PREFIX + 'eof-original-inputs.json.gz')).read_bytes()),
 'baseline': {'command': command, 'returncode': process.returncode,
              'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()},
 'whitespace_observation': {'command': ['git', 'diff', '--cached', '--check'], 'actual_returncode': 2,
   'diagnostic': PREFIX + 'knowledge-headers.md:443: new blank line at EOF.'},
 'scope': 'Complete first438/full105949 uncommitted finite publication and every byte/mode remain immutable in supplied custody. Actual readonly baseline passes before any bound correction. The sole archive whitespace error is unrelated to native behavior or live-card size. No accepted Git revision is invented; all first producers/observations retain their original source identities.'}, indent=2) + '\n')
print('Finite publication preserved before EOF repair:438 complete bindings/full105949; actual readonly baseline')
