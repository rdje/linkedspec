"""Readonly gate for the exact failed admission reader and its constant resolution."""
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
draft = read('review-draft.py')
old = "writes = ast.literal_eval(next(node.value for node in freezer.body if isinstance(node, ast.Assign)\n    and any(isinstance(target, ast.Name) and target.id == 'WRITES' for target in node.targets)))"
new = "write_node = next(node.value for node in freezer.body if isinstance(node, ast.Assign)\n    and any(isinstance(target, ast.Name) and target.id == 'WRITES' for target in node.targets))\nwrites = {OLD_CLAIM if isinstance(node, ast.Name) and node.id == 'CLAIM' else ast.literal_eval(node) for node in write_node.elts}"
assert draft.decode().count(old) == 1
assert read('review.py') == draft.decode().replace(old, new).encode(), 'sole admission constant correction'
target = ROOT / (PREFIX + 'admission-repair.json')
command = ['python3', PREFIX + 'review-draft.py']
if sys.argv[1:]:
    assert not target.exists(), 'one-shot repair retention'
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    log = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5-review.log').read_bytes()
    row = {'producer_sha256': sha(Path(__file__).read_bytes()), 'draft_sha256': sha(draft),
           'corrected_sha256': sha(read('review.py')), 'command': command, 'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode(),
           'original_merged_log_base64': base64.b64encode(log).decode(),
           'scope': 'Original complete reviewer exits1 before PASS at ast.literal_eval of named CLAIM. Exact draft and original merged stdout/stderr command log are retained, with a separate actual readonly failure reproduction. Sole correction resolves that one named constant without executing the freezer. No runtime/proof observations refresh; original tool transport is not independently retained.'}
    target.write_text(json.dumps(row, indent=2) + '\n')
else:
    row = json.loads(target.read_bytes())
assert row['producer_sha256'] == sha(Path(__file__).read_bytes()) and row['draft_sha256'] == sha(draft)
assert row['corrected_sha256'] == sha(read('review.py')) and row['command'] == command
assert row['returncode'] == 1 and not base64.b64decode(row['stdout_base64'], validate=True)
for name in ('stderr_base64', 'original_merged_log_base64'):
    raw = base64.b64decode(row[name], validate=True)
    assert b"ValueError: malformed node or string on line 21: Name(id='CLAIM', ctx=Load())" in raw
print('Hash-index admission reader repair PASS: exact failed source/log and sole constant resolution; runtime unchanged')
