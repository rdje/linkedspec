"""Retain the unexecuted correction and add full output custody before use."""
import ast
import gzip
import json
from pathlib import Path
import common as c

recovery = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'render-recovery.json.gz')).read_bytes()))
path = c.HOME + 'render-final.py'
before = c.read(path)
assert before['sha256'] == recovery['corrected_sha256']
source = c.decode(before['base64'])
marker = b"    assert mains['original'] == mains['compact'],"
assert source.count(marker) == 1
extra = b'''    generated = {}
    generated_dirs = {}
    output_root = book / 'output'
    for target in sorted(output_root.rglob('*')):
        assert not target.is_symlink() and not (target / '.git').exists()
        if target.is_dir():
            generated_dirs[target.relative_to(output_root).as_posix()] = target.stat().st_mode & 0o7777
        elif target.is_file():
            value = target.read_bytes()
            generated[target.relative_to(output_root).as_posix()] = dict(base64=c.encode(value), sha256=c.sha(value), mode=target.stat().st_mode & 0o7777)
        else:
            raise AssertionError('unexpected generated output entry')
    generated_dirs['.'] = output_root.stat().st_mode & 0o7777
    c.write_new(c.HOME + 'render-outputs.json.gz', dict(files=generated, directories=generated_dirs), packed=True)
'''
after = source.replace(marker, extra + marker, 1)
ast.parse(after, filename=path)
record = dict(result='PASS', original_unexecuted_proposal=before, after_base64=c.encode(after), after_sha256=c.sha(after),
              producer_base64=c.encode(Path(__file__).read_bytes()),
              scope='Before the corrected actor first executes, add a complete output byte/mode '
                    'inventory inside its scoped temporary destination. The exact first generated '
                    'proposal stays retained. Fresh whole-output equivalence can then govern '
                    'recovery of the first wrong-directory attempt without deleting unknown data.')
c.write_new(c.HOME + 'render-projection.json', record)
assert c.read(path) == before
(c.ROOT / path).write_bytes(after)
print('Corrected render full-output custody prepared before first execution')
