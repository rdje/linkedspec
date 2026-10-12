"""Preserve the entire first uncommitted publication before finite card extraction."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.0.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'preservation.json')
assert not target.exists(), 'one-shot complete candidate preservation'
raw = (ROOT / CLAIM).read_bytes()
record = json.loads(raw)
declared = record['claims'][0]['durability']['inputs']
assert len(raw) == 94719 and len(declared) == 408
capsule = {}
for item in declared:
    source = ROOT / item['path']
    data = source.read_bytes()
    assert sha(data) == item['sha256'], ('complete first publication input before bound writes', item['path'])
    capsule[item['path']] = {'sha256': sha(data), 'mode': source.stat().st_mode & 0o7777,
                            'bytes_base64': base64.b64encode(data).decode()}
for tail, value in [('original-claim.json', raw), ('original-inputs.json.gz',
                    gzip.compress(json.dumps(capsule, sort_keys=True).encode(), mtime=0))]:
    with (ROOT / (PREFIX + tail)).open('xb') as output:
        output.write(value)
command = ['bash', 'tools/run_python_project_data.sh',
           'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-publish-claim.py']
process = subprocess.run(command, cwd=ROOT, capture_output=True)
assert process.returncode == 0 and not process.stderr
assert process.stdout == b'Required FlowExpr publication PASS: 408 live inputs; 94719 bytes\n'
failures = []
for name, session in [('commit', 28075), ('claim-check', 53944)]:
    data = (ROOT / ('.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.4.0-' + name + '.log')).read_bytes()
    failures.append({'name': name, 'actual_tool_session': session, 'actual_returncode': 130,
                     'merged_log_base64': base64.b64encode(data).decode()})
assert b'knowledge_cards exceeds control: aggregate bytes 8401572/8388608' in base64.b64decode(failures[0]['merged_log_base64'])
result = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
          'base': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
          'candidate_kind': 'uncommitted supplied bytes; no fabricated accepted Git revision',
          'original_bindings': len(declared), 'original_claim_bytes': len(raw),
          'original_claim_sha256': sha(raw),
          'capsule_sha256': sha((ROOT / (PREFIX + 'original-inputs.json.gz')).read_bytes()),
          'baseline': {'command': command, 'returncode': process.returncode,
                       'stdout_base64': base64.b64encode(process.stdout).decode(),
                       'stderr_base64': base64.b64encode(process.stderr).decode()},
          'failed_admission': failures,
          'scope': 'Every original408 bound byte/mode and full94719 publication is retained before bound writes. Actual readonly first publisher passes. Normal hook already reports the finite Knowledge overage; it is interrupted130 before the remaining checks, so no all10 result is claimed. Redundant manual claim check is separately interrupted130. No native/runtime/oracle/producer byte is changed.'}
target.write_text(json.dumps(result, indent=2) + '\n')
print('First FlowExpr candidate preserved:408 complete bindings/full94719; actual readonly baseline; exact interrupted admission logs')
