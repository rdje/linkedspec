"""Rehearse/apply only the reproduced installed-Lua classifier correction."""
import difflib
import gzip
import os
from pathlib import Path
import stat
import subprocess
import sys

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'fff959ef7e8896b5b97f311a276cabc4f5034551'
OWNER = Path('lua/src/linkedspec/interpreter.lua')
RUNNER = Path('lua/test/run.lua')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert all((BASE / 'before' / host / 'normal-exit.txt').read_text() == '1\n' for host in ('puc', 'luajit'))
assert (BASE / 'trace/complete.txt').read_text() == 'Both installed host nine public trace epochs complete.\n'
assert sys.argv[1:] in (['--rehearse'], ['--apply'])
old = b'''  if expr ~= nil and expr.kind == "call" then
    if engine.compiled_spec.function_registry:has_name(expr.name) then return false end
    if (expr.source_method or expr.name) == expr.name and not expr.trailing_block_arg and
      typed_source.receiver_mutation.is_canonical_array_transform_arity(expr.name, #(expr.args or {})) and
      typed_source.receiver_mutation.is_ordinary_array_transform_arguments(expr.args) then
'''
new = b'''  -- Invocation keeps its arity checks and caller effects. A canonical transform
  -- prefix owns the produced result without becoming an unregistered free call.
  if expr ~= nil and expr.kind == "call" then
    if not engine.compiled_spec.function_registry:has_name(expr.name) and
      (expr.source_method or expr.name) == expr.name and not expr.trailing_block_arg and
      typed_source.receiver_mutation.is_canonical_array_transform_arity(expr.name, #(expr.args or {})) and
      typed_source.receiver_mutation.is_ordinary_array_transform_arguments(expr.args) then
'''
anchor = b'''test("Ordinary Array-transform result guards", function()
  dofile("lua/test/array_transform_result_guard_composition_test.lua")
end)
'''
added = b'''test("Callable Array-transform result guards", function()
  dofile("lua/test/array_transform_callable_result_guard_composition_test.lua")
end)
'''
before = {}
for path, name in ((OWNER, 'owner'), (RUNNER, 'runner')):
    assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    before[name] = path.read_bytes()
    assert before[name] == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
assert before['owner'].count(old) == 1 and before['runner'].count(anchor) == 1
after = dict(owner=before['owner'].replace(old, new), runner=before['runner'].replace(anchor, anchor + added))
if sys.argv[1] == '--rehearse':
    for name in before:
        for phase, body in (('before', before[name]), ('after', after[name])):
            target = BASE / (name + '-' + phase + '.lua.gz')
            if phase == 'before':
                assert gzip.decompress(target.read_bytes()) == body
            else:
                assert not target.exists()
                target.write_bytes(gzip.compress(body, mtime=0))
                assert gzip.decompress(target.read_bytes()) == body
    patch = ''.join(''.join(difflib.unified_diff(before[name].decode().splitlines(True), after[name].decode().splitlines(True),
        fromfile=str(path), tofile=str(path))) for path, name in ((OWNER, 'owner'), (RUNNER, 'runner')))
    (BASE / 'source.diff').write_text(patch)
    print('Exact namespace/runner rehearsal retained; source unchanged')
else:
    for name in before:
        assert gzip.decompress((BASE / (name + '-before.lua.gz')).read_bytes()) == before[name]
        assert gzip.decompress((BASE / (name + '-after.lua.gz')).read_bytes()) == after[name]
    for path, name in ((OWNER, 'owner'), (RUNNER, 'runner')):
        temporary = path.with_name(path.name + '.callable-transform-new')
        assert not temporary.exists() and not temporary.is_symlink()
        mode = stat.S_IMODE(path.stat().st_mode)
        with temporary.open('xb') as stream:
            stream.write(after[name])
        temporary.chmod(mode)
        assert temporary.read_bytes() == after[name]
        os.replace(temporary, path)
        assert path.read_bytes() == after[name] and stat.S_IMODE(path.stat().st_mode) == mode
    print('Applied only registered-source transform classification and one runner group; no chunk locals')
