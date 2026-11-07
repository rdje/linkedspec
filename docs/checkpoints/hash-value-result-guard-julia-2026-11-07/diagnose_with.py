"""Retain the actual public ActionIR diagnosis of the first partial repair."""
import os,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
from proof_io import BASE,ROOT,FIXTURE,GRAMMAR,freeze,verify,execute
out=BASE/'with-diagnosis';out.mkdir()
paths=[Path(p) for p in subprocess.check_output(['git','ls-files','julia'],text=True).splitlines()]
paths += [FIXTURE,GRAMMAR,BASE/'diagnose_with.jl',BASE/'diagnose_with.py',BASE/'proof_io.py']
paths += [Path('tools')/p for p in ('run_julia_project_data.sh','project_data_env.sh','project_data_run.sh')]
records=freeze(out,paths)
env=dict(os.environ,JULIA_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',JULIA_PKG_PRECOMPILE_AUTO='0')
result=execute(out,'action',['bash','tools/run_julia_project_data.sh','--project=julia','--startup-file=no','--history-file=no','--depwarn=error',str(BASE/'diagnose_with.jl'),str(FIXTURE)],env)
verify(records);assert result.returncode==0
print(result.stdout.decode())
