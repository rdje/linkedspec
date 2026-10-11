"""Readonly reconstruction of both admission-reader corrections and exact failed boundaries."""
import base64
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda tail: (ROOT / (PREFIX + tail)).read_bytes()
assert sys.argv[1:] in ([], ['--capture'])
first = read('review-draft.py')
second = read('review-draft02.py')
current = read('review.py')
old = "writes = ast.literal_eval(next(node.value for node in freezer.body if isinstance(node, ast.Assign)\n    and any(isinstance(target, ast.Name) and target.id == 'WRITES' for target in node.targets)))"
new = "write_node = next(node.value for node in freezer.body if isinstance(node, ast.Assign)\n    and any(isinstance(target, ast.Name) and target.id == 'WRITES' for target in node.targets))\nwrites = {OLD_CLAIM if isinstance(node, ast.Name) and node.id == 'CLAIM' else ast.literal_eval(node) for node in write_node.elts}"
assert first.decode().count(old) == 1 and second == first.decode().replace(old, new).encode()
old_call = 'spec.loader.exec_module(component)'
new_call = "arguments = sys.argv\nsys.argv = [PREFIX + 'native-review.py']\ntry:\n    spec.loader.exec_module(component)\nfinally:\n    sys.argv = arguments"
assert second.decode().count(old_call) == 1 and current == second.decode().replace(old_call, new_call).encode()
original = json.loads(read('admission-repair.json'))
assert original['producer_sha256'] == sha(read('admission-repair.py'))
assert original['draft_sha256'] == sha(first) and original['corrected_sha256'] == sha(second)
assert original['returncode'] == 1 and not base64.b64decode(original['stdout_base64'], validate=True)
for name in ('stderr_base64', 'original_merged_log_base64'):
    assert b"ValueError: malformed node or string on line 21: Name(id='CLAIM', ctx=Load())" in base64.b64decode(original[name], validate=True)
target = ROOT / (PREFIX + 'admission-final.json')
command = ['python3', PREFIX + 'review-draft02.py', '--capture']
native_before = read('native-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot final admission repair'
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    log = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-review02.log').read_bytes()
    preflight = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-evidence.log').read_bytes()
    row = {'producer_sha256': sha(Path(__file__).read_bytes()),
           'inputs': {PREFIX + tail: sha(read(tail)) for tail in ('review-draft.py', 'review-draft02.py',
              'review.py', 'admission-repair.py', 'admission-repair.json', 'native-review.py', 'native-review.json')},
           'command': command, 'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode(),
           'original_merged_log_base64': base64.b64encode(log).decode(),
           'evidence_preflight_merged_log_base64': base64.b64encode(preflight).decode(),
           'native_review_unchanged': read('native-review.json') == native_before,
           'scope': 'Both exact failed admission readers and original repair result stay retained. Original constant-repair corrected-source binding now resolves byte-for-byte to review-draft02.py; its writer is retired. Current reader differs only by constant resolution then readonly-component argv shielding under try/finally. Actual second-failure reproduction hits one-shot guard without changing native-review bytes. Original evidence invocation never passes missing-report preflight. Complete original merged logs are retained; original tool transport envelopes are unavailable. No native/runtime observation refresh.'}
    target.write_text(json.dumps(row, indent=2) + '\n')
else:
    row = json.loads(target.read_bytes())
assert row['producer_sha256'] == sha(Path(__file__).read_bytes())
assert all(sha((ROOT / path).read_bytes()) == digest for path, digest in row['inputs'].items())
assert row['command'] == command and row['returncode'] == 1 and row['native_review_unchanged']
assert not base64.b64decode(row['stdout_base64'], validate=True)
for name in ('stderr_base64', 'original_merged_log_base64'):
    assert b"AssertionError: one-shot review" in base64.b64decode(row[name], validate=True)
assert b'FileNotFoundError' in base64.b64decode(row['evidence_preflight_merged_log_base64'], validate=True)
assert read('native-review.json') == native_before
print('Hash-index final admission repair PASS: exact two reader corrections/failures, original proof fields preserved, no native refresh')
