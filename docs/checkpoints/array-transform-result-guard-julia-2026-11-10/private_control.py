"""Run exact old/current Julia interpreters at one owned SDK path."""
import gzip
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import traceback

sys.dont_write_bytecode = True
from proof_io import BASE, ROOT, OWNER, NORMAL, FIXTURE, PROFILE, GRAMMAR, freeze, verify, execute, artifacts, frames

phase, = sys.argv[1:]
assert phase in ('private-inverse', 'private-restored')
out = BASE / phase
out.mkdir()
private = BASE / 'control-owner'
try:
    inverse = phase == 'private-inverse'
    activation = (BASE / 'intake/activation.txt').read_text().strip()
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == activation
    paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'julia'], text=True).splitlines()]
    paths = sorted(set(paths + [NORMAL, FIXTURE, PROFILE, GRAMMAR,
                                Path('tests/fixtures/array_transform_result_guard_cases.json')]))
    if inverse:
        assert not private.exists()
        private.mkdir()
    else:
        assert private.is_dir() and not private.is_symlink()
        previous = json.loads((BASE / 'private-inverse/input-identities.json').read_bytes())
        verify({name: row for name, row in previous.items() if name.startswith(str(private) + '/')})
        assert {p for p in private.rglob('*') if p.is_file()} == {private / p for p in paths}
    candidate = OWNER.read_bytes()
    old = subprocess.check_output(['git', 'show', activation + ':' + str(OWNER)])
    assert old != candidate
    for path in paths:
        target = private / path
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
    (private / OWNER).write_bytes(old if inverse else candidate)
    golden = BASE / ('before' if inverse else 'after') / 'normal-stdout.log.gz'
    inputs = [private / p for p in paths] + [OWNER, golden, BASE / 'private_control.py', BASE / 'proof_io.py']
    inputs += [Path('tools') / p for p in ('run_julia_project_data.sh', 'project_data_env.sh',
                                         'project_data_run.sh', 'run_python_project_data.sh')]
    records = freeze(out, inputs)
    (out / 'activation.txt').write_text(activation + '\n')
    environment = dict(os.environ, JULIA_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1',
                       JULIA_PKG_PRECOMPILE_AUTO='0', LINKEDSPEC_ARRAY_TRANSFORM_CAPTURE=str(out))
    prefix = ['bash', 'tools/run_julia_project_data.sh', '--project=' + str(private / 'julia'),
              '--compiled-modules=no', '--startup-file=no', '--history-file=no', '--depwarn=error']
    assert execute(out, 'version', prefix + ['--version'], environment).returncode == 0
    command = prefix + ['-e', 'using LinkedSpecJulia,JSON3,Test; println("ARRAY_TRANSFORM_JULIA_OWNER ",relpath(pathof(LinkedSpecJulia),pwd())); include(ARGS[1])', str(private / NORMAL)]
    result = execute(out, 'normal', command, environment)
    verify(records)
    artifacts(out)
    expected = frames(gzip.decompress(golden.read_bytes()))
    actual = frames(result.stdout)
    assert len(actual) == 156
    assert json.dumps(actual, sort_keys=True) == json.dumps(expected, sort_keys=True)
    expected_path = ('ARRAY_TRANSFORM_JULIA_OWNER ' + str(private / 'julia/src/LinkedSpecJulia.jl') + '\n').encode()
    assert expected_path in result.stdout
    pattern = rb'Julia ordinary Array-transform result guards\s*\|\s*827\s+76\s+903\s' if inverse else rb'Julia ordinary Array-transform result guards\s*\|\s*903\s+903\s'
    assert re.search(pattern, result.stdout)
    assert result.returncode == (1 if inverse else 0)
    assert OWNER.read_bytes() == candidate
    if not inverse:
        verify(records)
        assert {p for p in private.rglob('*') if p.is_file()} == {private / p for p in paths}
        shutil.rmtree(private)  # Complete verified owned duplicates only.
    print(phase + ': actual156 frames/counts and private noncached source path verified; checkout untouched')
except BaseException:
    (out / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
