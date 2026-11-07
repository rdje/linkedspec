"""One prospective finite Julia epoch, with actual grammar before SDK use."""
import gzip,json,os,subprocess,sys,traceback
from pathlib import Path
sys.dont_write_bytecode=True
from proof_io import BASE,ROOT,NORMAL,FIXTURE,PROFILE,GRAMMAR,freeze,verify,execute,artifacts
phase,=sys.argv[1:];assert phase in {'intake','before','after','direct'}
out=BASE/phase;out.mkdir()
try:
    paths=[Path(p) for p in subprocess.check_output(['git','ls-files','julia'],text=True).splitlines()]
    paths += [BASE/p for p in ('prepare.py','proof_io.py','capture.py','observer.jl','freeze_profiles.py','private_control.py','cases.json','profile-sources.json')]
    paths += [Path(p) for p in ('docs/checkpoints/hash-view-result-guard-julia-2026-11-07/observer.jl','julia/test/hash_view_result_guard_composition_test.jl','tests/fixtures/hash_value_result_guard_cases.json','tests/fixtures/hash_view_result_guard_julia_cases.json','tests/fixtures/hash_view_result_guard_julia_profiles.json','tests/fixtures/value_copy_values.spec','tests/fixtures/value_copy_values.json')]
    paths += [Path('tools')/p for p in ('run_julia_project_data.sh','project_data_env.sh','project_data_run.sh','run_python_project_data.sh')]
    paths += [FIXTURE,GRAMMAR]
    if NORMAL.exists():paths.append(NORMAL)
    if PROFILE.exists():paths.append(PROFILE)
    records=freeze(out,paths)
    (out/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
    env=dict(os.environ,JULIA_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',JULIA_PKG_PRECOMPILE_AUTO='0')
    prefix=['bash','tools/run_julia_project_data.sh','--project=julia','--startup-file=no','--history-file=no','--depwarn=error']
    version=execute(out,'version',prefix+['--version'],env);assert version.returncode==0
    if phase=='intake':args=[str(BASE/'observer.jl'),str(FIXTURE),str(out)]
    else:
        env['LINKEDSPEC_HASH_VALUE_CAPTURE']=str(out)
        tests=[str(NORMAL)]
        if phase=='direct':tests += ['julia/test/hash_view_result_guard_composition_test.jl','julia/test/constructor_result_composition_test.jl','julia/test/value_copy_test.jl','julia/test/receiver_copy_arity_test.jl']
        args=['-e','using LinkedSpecJulia,JSON3,Test; println("HASH_VALUE_JULIA_OWNER ",relpath(pathof(LinkedSpecJulia),pwd())); for path in ARGS; include(path); end',*tests]
    result=execute(out,'normal',prefix+args,env)
    verify(records);artifacts(out)
    print(phase+': exit'+str(result.returncode)+'; full channels and actual inputs/artifacts retained')
    assert result.returncode in ((0,1) if phase=='before' else (0,))
except BaseException:
    (out/'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    print('capture failed; inspect retained epoch and compressed wrapper failure');sys.exit(1)
