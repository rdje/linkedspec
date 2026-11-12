"""Recover original Lua proof with only the retained-oracle read path qualified."""
import contextlib
import gzip
import hashlib
import importlib.abc
import importlib.util
import io
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BASE = Path('docs/checkpoints/array-concat-open-arity-lua-2026-11-12')
ORACLE = BASE / 'semantic_oracle.py'
metadata = json.loads((ROOT / BASE / 'oracle-retention.json').read_bytes())
sealed = json.loads((ROOT / BASE / 'sealed-identities.json').read_bytes())
original = ROOT / BASE / 'review.py'
body = original.read_bytes()
assert len(body) == sealed[str(BASE / 'review.py')]['bytes']
assert hashlib.sha256(body).hexdigest() == sealed[str(BASE / 'review.py')]['sha256']
def recover(blob):
    raw = gzip.decompress(blob)
    assert len(raw) == metadata['bytes'] and hashlib.sha256(raw).hexdigest() == metadata['sha256'], 'retained oracle digest'
    assert metadata['sha256'] == sealed[str(ORACLE)]['sha256'], 'sealed oracle identity'
    return raw
compressed = (ROOT / BASE / 'semantic_oracle.py.gz').read_bytes()
assert hashlib.sha256(compressed).hexdigest() == metadata['compressed_sha256']
raw = recover(compressed)
assert not (ROOT / ORACLE).exists(), 'plain duplicate must remain retired'
spec = importlib.util.spec_from_file_location('original_lua_concat_review', original)
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)
old_read = review.read
old_factory = importlib.util.spec_from_file_location
def qualified_read(name):
    if str(name) == str(ORACLE):
        return recover(compressed)
    return old_read(name)
class RetainedOracle(importlib.abc.Loader):
    def create_module(self, spec):
        return None
    def exec_module(self, module):
        exec(compile(recover(compressed), str(ROOT / ORACLE), 'exec'), module.__dict__)
def qualified_factory(name, location, *args, **kwargs):
    if Path(location) == ROOT / ORACLE:
        return importlib.util.spec_from_loader(name, RetainedOracle(), origin=str(location))
    return old_factory(name, location, *args, **kwargs)
review.read = qualified_read
importlib.util.spec_from_file_location = qualified_factory
stream = io.StringIO()
try:
    with contextlib.redirect_stdout(stream):
        review.main()
finally:
    importlib.util.spec_from_file_location = old_factory
result = json.loads(stream.getvalue())
assert result['historical_recovery'] == 'PASS' and len(result['reason_sensitive_controls']) == 11
controls = []
try:
    recover(gzip.compress(raw + b'changed', mtime=0))
except AssertionError as failure:
    assert str(failure) == 'retained oracle digest'
else:
    raise AssertionError('oracle body corruption accepted')
controls.append('retained oracle body digest')
try:
    recover(compressed[:len(compressed)//2])
except (EOFError, OSError):
    pass
else:
    raise AssertionError('truncated oracle archive accepted')
controls.append('truncated oracle archive')
result.update(reader_entrypoint=str(BASE / 'review_qualified.py'), qualification_controls=controls,
    qualification_scope='Only one exact archived-source read/import path changes; original reader/oracle/first0/seal/producers/SDK observations stay byte-identical. No SDK replay or current-code freshness.')
print(json.dumps(result))
