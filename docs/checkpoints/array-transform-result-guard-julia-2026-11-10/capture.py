"""One current Julia acquisition; actual source/grammar precede SDK use."""
import gzip
import os
from pathlib import Path
import subprocess
import sys
import traceback

sys.dont_write_bytecode = True
from proof_io import BASE, ROOT, NORMAL, FIXTURE, PROFILE, GRAMMAR, freeze, verify, execute, artifacts

phase, = sys.argv[1:]
assert phase in ('intake', 'before', 'after', 'direct')
out = BASE / phase
out.mkdir()
try:
    paths = [Path(p) for p in subprocess.check_output(
        ['git', 'ls-files', 'julia', 'tests/fixtures'], text=True).splitlines()]
    paths += list(BASE.glob('*.py')) + [BASE / 'observer.jl', BASE / 'cases.json', BASE / 'profile-sources.json']
    paths += [Path(p) for p in ('specs/user_function_definition.spec',
        'docs/checkpoints/hash-value-result-guard-julia-2026-11-07/observer.jl',
        'tests/fixtures/array_transform_result_guard_cases.json',
        'tests/fixtures/hash_value_result_guard_julia_cases.json',
        'tests/fixtures/hash_value_result_guard_julia_profiles.json',
        'tests/fixtures/hash_view_result_guard_julia_cases.json',
        'tests/fixtures/hash_view_result_guard_julia_profiles.json')]
    paths += [Path('tools') / p for p in ('run_julia_project_data.sh', 'project_data_env.sh',
                                        'project_data_run.sh', 'run_python_project_data.sh')]
    paths += [FIXTURE, GRAMMAR]
    paths += [p for p in (NORMAL, PROFILE) if p.exists()]
    records = freeze(out, paths)
    (out / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
    environment = dict(os.environ, JULIA_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', JULIA_PKG_PRECOMPILE_AUTO='0')
    prefix = ['bash', 'tools/run_julia_project_data.sh', '--project=julia', '--startup-file=no',
              '--history-file=no', '--depwarn=error']
    assert execute(out, 'version', prefix + ['--version'], environment).returncode == 0
    if phase == 'intake':
        arguments = [str(BASE / 'observer.jl'), str(FIXTURE), str(out)]
    else:
        environment['LINKEDSPEC_ARRAY_TRANSFORM_CAPTURE'] = str(out)
        tests = [str(NORMAL)]
        if phase == 'direct':
            tests += ['julia/test/with_hash_results_test.jl',
                      'julia/test/hash_value_result_guard_composition_test.jl',
                      'julia/test/hash_view_result_guard_composition_test.jl',
                      'julia/test/constructor_result_composition_test.jl']
        arguments = ['-e', 'using LinkedSpecJulia,JSON3,Test; println("ARRAY_TRANSFORM_JULIA_OWNER ",relpath(pathof(LinkedSpecJulia),pwd())); for path in ARGS; include(path); end', *tests]
    result = execute(out, 'normal', prefix + arguments, environment)
    verify(records)
    artifacts(out)
    print(phase + ': actual exit' + str(result.returncode) + '; inputs/channels/artifacts retained; grade observations')
    assert result.returncode in ((0, 1) if phase == 'before' else (0,))
except BaseException:
    (out / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
    raise
