"""Execute exact retired pure replacement callbacks, without building a retired engine."""
import gzip
import json
import common as c

history = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'history.json.gz')).read_bytes()))
print('Historical record keys:', sorted(history))
# The complete original Git file is retained independently before this probe.
import subprocess
source = subprocess.check_output(['git', 'show', 'fff219840212c26d78d75cda0ac9356f5f8d257c:perl/LinkedSpec/ActionIR/Contracts.pm'], cwd=c.ROOT)
start = source.index(b'sub _build_return_contracts {')
end = source.index(b'\nsub ', start + 1)
function = source[start:end]
inputs = {c.PREFIX + name: c.read(c.PREFIX + name) for name in ('historical-lowering.pl', 'capture-historical-lowering.py', 'common.py', 'history.json.gz')}
c.write_new(c.PREFIX + 'historical-lowering-inputs.json.gz', dict(inputs=inputs,
    source_base64=c.encode(source), function_base64=c.encode(function),
    revision='fff219840212c26d78d75cda0ac9356f5f8d257c',
    scope='Exact LinkedSpec-owned pure return-contract function. Only a/m/ma string callbacks '
          'and their emitted Perl snippets execute with explicit local arrays. No retired Get/compiler '
          'or dependency implementation is loaded; no broader historical runtime equivalence.'), packed=True)
run = c.run(['perl', c.PREFIX + 'historical-lowering.pl'], input=json.dumps(dict(function=function.decode())).encode())
c.write_new(c.PREFIX + 'historical-lowering.json', dict(run=run, unchanged=c.unchanged(inputs)))
print('Historical pure replacement exit:', run['returncode'])
print(c.decode(run['stdout_base64']).decode(), c.decode(run['stderr_base64']).decode())
