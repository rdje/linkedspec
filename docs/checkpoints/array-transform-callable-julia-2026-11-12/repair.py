"""Rehearse/apply only the independently reproduced Julia classifier correction."""
import difflib
import gzip
import json
import os
from pathlib import Path
import stat
import subprocess
import sys

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '3767c87c7167bdcb29b0092be35bc139520e3509'
OWNER = Path('julia/src/runtime/Interpreter.jl')
RUNNER = Path('julia/test/runtests.jl')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert (BASE / 'before/normal-exit.txt').read_text() == '1\n'
assert sys.argv[1:] in (['--rehearse'], ['--apply'])
old = b"""    if receiver isa ActionCallExpr
        has_user_function_name(engine.compiled_spec.function_registry, receiver.name) && return false
        if something(receiver.source_method, receiver.name) == receiver.name &&
            !receiver.trailing_block_arg &&
            _runtime_is_canonical_array_transform_arity(receiver.name, length(receiver.args)) &&
            _runtime_is_ordinary_array_transform_arguments(receiver.args)
"""
new = b"""    # Invocation keeps its arity checks and caller effects. A canonical transform
    # prefix owns the produced result without becoming an unregistered free call.
    if receiver isa ActionCallExpr
        if !has_user_function_name(engine.compiled_spec.function_registry, receiver.name) &&
            something(receiver.source_method, receiver.name) == receiver.name &&
            !receiver.trailing_block_arg &&
            _runtime_is_canonical_array_transform_arity(receiver.name, length(receiver.args)) &&
            _runtime_is_ordinary_array_transform_arguments(receiver.args)
"""
include = b'include("array_transform_result_guard_composition_test.jl")\n'
added = b'include("array_transform_callable_result_guard_composition_test.jl")\n'
before = {}
for path, name in ((OWNER, 'owner'), (RUNNER, 'runner')):
    assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    before[name] = body
assert before['owner'].count(old) == 1 and before['runner'].count(include) == 1
after = dict(owner=before['owner'].replace(old, new), runner=before['runner'].replace(include, include + added))
if sys.argv[1] == '--rehearse':
    for name in before:
        for phase, body in (('before', before[name]), ('after', after[name])):
            target = BASE / (name + '-' + phase + '.jl.gz')
            if phase == 'before':
                assert gzip.decompress(target.read_bytes()) == body
            else:
                assert not target.exists()
                target.write_bytes(gzip.compress(body, mtime=0))
                assert gzip.decompress(target.read_bytes()) == body
    patch = ''.join(''.join(difflib.unified_diff(before[name].decode().splitlines(True), after[name].decode().splitlines(True),
        fromfile=str(path), tofile=str(path))) for path, name in ((OWNER, 'owner'), (RUNNER, 'runner')))
    (BASE / 'source.diff').write_text(patch)
    print('Exact interpreter/runner rehearsal retained; production unchanged')
else:
    for name in before:
        assert gzip.decompress((BASE / (name + '-before.jl.gz')).read_bytes()) == before[name]
        assert gzip.decompress((BASE / (name + '-after.jl.gz')).read_bytes()) == after[name]
    for path, name in ((OWNER, 'owner'), (RUNNER, 'runner')):
        temporary = path.with_name(path.name + '.callable-transform-new')
        assert not temporary.exists() and not temporary.is_symlink()
        mode = stat.S_IMODE(path.stat().st_mode)
        with temporary.open('xb') as stream:
            stream.write(after[name])
        os.chmod(temporary, mode)
        assert temporary.read_bytes() == after[name]
        os.replace(temporary, path)
        assert path.read_bytes() == after[name] and stat.S_IMODE(path.stat().st_mode) == mode
    print('Applied only canonical registered-source transform classification and one normal runner include')
