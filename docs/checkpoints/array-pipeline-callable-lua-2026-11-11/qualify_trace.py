"""Preserve first instrument failure; author a separately retained qualified trace."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
spec = importlib.util.spec_from_file_location('trace_preservation_io', ROOT / BASE / 'proof_io.py')
proof = importlib.util.module_from_spec(spec)
spec.loader.exec_module(proof)
OUT = BASE / 'trace-failure'
OUT.mkdir()
assert (BASE / 'trace/puc/trace-exit.txt').read_text() == '1\n'
assert not (BASE / 'trace/luajit').exists()
partial = list((BASE / 'trace/puc').glob('*.trace.log')) + list((BASE / 'trace/puc').glob('*.parsed.json'))
assert len(partial) == 2
proof.freeze(OUT, partial + [BASE / 'capture_trace.py', BASE / 'trace.lua', BASE / 'qualify_trace.py'],
    'partial', 'actual-partial-and-producers.tar.gz')
tool_log = Path('.linkedspec-data/callable-pipeline-lua-trace.log')
(OUT / 'outer-tool-output.log.gz').write_bytes(gzip.compress(tool_log.read_bytes(), mtime=0))
native = json.loads((BASE / 'trace/puc/native-identities.json').read_bytes())
assert len(native) == 3
proof.verify(native)
for name in native:
    path = Path(name)
    assert path.parent == BASE / 'trace/puc/native'
    path.unlink()
(BASE / 'trace/puc/native').rmdir()
for original, target in (('trace.lua', 'trace_qualified.lua'), ('capture_trace.py', 'capture_trace_qualified.py')):
    source = (BASE / original).read_bytes()
    (OUT / (original + '.gz')).write_bytes(gzip.compress(source, mtime=0))
    text = source.decode()
    if original == 'trace.lua':
        assert text.count('local payloads = {}') == 1
        text = text.replace('local payloads = {}', 'local payloads = json.array({})')
        text = text.replace('/trace/[a-z]+$', '/traceq/[a-z]+$')
    else:
        text = text.replace("OUT = BASE / 'trace'", "OUT = BASE / 'traceq'")
        text = text.replace("BASE / 'trace.lua'", "BASE / 'trace_qualified.lua'")
        text = text.replace("BASE / 'capture_trace.py'", "BASE / 'capture_trace_qualified.py'")
    path = BASE / target
    assert not path.exists()
    path.write_text(text)
(OUT / 'failure.json').write_text(json.dumps(dict(outer_exit=1, child_exit=1, host='puc',
    luajit='not attempted', cause='plain Lua payload list rejected by JSON codec; tagged array required',
    credit='No complete first-trace PASS; original source/data/channels retained',
    native_retirement='Exact three verified before-use archive duplicates removed after child exit; no residue'), indent=2) + '\n')
print('First trace failure/partial inputs preserved; qualified tagged-array producers authored')
