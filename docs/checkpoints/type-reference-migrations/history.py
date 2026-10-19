"""Retain the relevant LinkedSpec-owned retirement history without executing it."""
import subprocess
from pathlib import Path
import common as c

revision = subprocess.check_output(['git', 'rev-parse', '4e92503'], cwd=c.ROOT).decode().strip()
parent = subprocess.check_output(['git', 'rev-parse', revision + '^1'], cwd=c.ROOT).decode().strip()
path = 'perl/LinkedSpec/ActionIR/Contracts.pm'
inputs = {}
for label, commit in [('before', parent), ('after', revision)]:
    value = subprocess.check_output(['git', 'show', commit + ':' + path], cwd=c.ROOT)
    start = value.index(b'sub _build_return_contracts {')
    end = value.find(b'\nsub ', start + 1)
    assert end > start
    inputs[label] = dict(revision=commit, path=path, base64=c.encode(value), sha256=c.sha(value),
        return_contract_block_base64=c.encode(value[start:end]))
diff = subprocess.check_output(['git', 'diff', '--no-ext-diff', '--no-color', parent, revision, '--', path], cwd=c.ROOT)
metadata = subprocess.check_output(['git', 'show', '-s', '--format=fuller', revision], cwd=c.ROOT)
c.write_new(c.PREFIX + 'history.json.gz', dict(result='CAPTURED', inputs=inputs,
    exact_diff_base64=c.encode(diff), diff_sha256=c.sha(diff), commit_metadata_base64=c.encode(metadata),
    producer=c.read(c.PREFIX + 'history.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Only LinkedSpec-owned immutable Git history is read. Original June observations remain dated; '
          'this capture does not execute the retired engine or infer current behavior.'), packed=True)
print('Retirement source retained:', parent, '->', revision)
print(c.decode(inputs['before']['return_contract_block_base64']).decode())
print('Accepted retirement block:')
print(c.decode(inputs['after']['return_contract_block_base64']).decode())
