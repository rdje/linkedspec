"""Exact original/current Julia interpreter at one private owned SDK path."""
import gzip,json,os,re,shutil,subprocess,sys,traceback
from pathlib import Path
sys.dont_write_bytecode=True
from proof_io import BASE,ROOT,OWNER,NORMAL,FIXTURE,PROFILE,GRAMMAR,freeze,verify,execute,artifacts,frames
phase,=sys.argv[1:];assert phase in {'private-inverse','private-restored'}
out=BASE/phase;out.mkdir();private=BASE/'control-owner'
try:
    inverse=phase=='private-inverse'
    if inverse:assert not private.exists();private.mkdir()
    else:assert private.is_dir()
    activation=(BASE/'intake/activation.txt').read_text().strip()
    paths=[Path(p) for p in subprocess.check_output(['git','ls-files','julia'],text=True).splitlines()]
    paths += [NORMAL,FIXTURE,PROFILE,GRAMMAR,Path('tests/fixtures/hash_value_result_guard_cases.json')]
    for p in sorted(set(paths)):
        target=private/p;target.parent.mkdir(parents=True,exist_ok=True)
        body=subprocess.check_output(['git','show',activation+':'+str(p)]) if inverse and p==OWNER else p.read_bytes()
        target.write_bytes(body);target.chmod(p.stat().st_mode&0o777)
    golden=BASE/('before' if inverse else 'after')/'normal-stdout.log.gz'
    inputs=[private/p for p in sorted(set(paths))]+[golden,BASE/'private_control.py',BASE/'proof_io.py']
    inputs += [Path('tools')/p for p in ('run_julia_project_data.sh','project_data_env.sh','project_data_run.sh')]
    records=freeze(out,inputs)
    (out/'activation.txt').write_text(activation+'\n')
    env=dict(os.environ,JULIA_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',JULIA_PKG_PRECOMPILE_AUTO='0',LINKEDSPEC_HASH_VALUE_CAPTURE=str(out))
    prefix=['bash','tools/run_julia_project_data.sh','--project='+str(private/'julia'),'--compiled-modules=no','--startup-file=no','--history-file=no','--depwarn=error']
    command=prefix+['-e','using LinkedSpecJulia,JSON3,Test; println("HASH_VALUE_JULIA_OWNER ",relpath(pathof(LinkedSpecJulia),pwd())); include(ARGS[1])',str(private/NORMAL)]
    result=execute(out,'normal',command,env)
    verify(records);artifacts(out)
    expected=gzip.decompress(golden.read_bytes());actual=result.stdout
    assert frames(actual)==frames(expected)
    assert ('HASH_VALUE_JULIA_OWNER '+str(private/'julia/src/LinkedSpecJulia.jl')+'\n').encode() in actual
    assert re.search(rb'Julia pure Hash-helper result guards\s*\|\s*458\s+52\s+510\s',actual) if inverse else re.search(rb'Julia pure Hash-helper result guards\s*\|\s*510\s+510\s',actual)
    assert result.returncode==(1 if inverse else 0)
    if not inverse:
        verify(records)
        assert set(p for p in private.rglob('*') if p.is_file())=={private/p for p in set(paths)}
        shutil.rmtree(private)
    print(phase+': actual89 frames match exact old/current oracle, route path and test totals verified')
except BaseException:
    (out/'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    print('private control failed; inspect retained full epoch and compressed failure');sys.exit(1)
