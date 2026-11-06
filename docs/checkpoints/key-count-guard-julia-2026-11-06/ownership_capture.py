"""One-shot Julia public observations and exact declared first-run inputs."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
phase=sys.argv[1]
assert phase in ('ownership-before','ownership-after')
OUT=BASE/phase
OUT.mkdir()
paths=[Path(p) for p in subprocess.check_output(['git','ls-files','julia','tests/fixtures'],text=True).splitlines()]
paths += [BASE/'capture.py',BASE/'observer.jl',BASE/'ownership_capture.py',BASE/'ownership-cases.json']
paths += [Path(p) for p in ('tools/run_julia_project_data.sh','tools/project_data_env.sh','tools/run_python_project_data.sh','tools/project_data_run.sh')]
for name in ('julia/test/key_count_result_guard_composition_test.jl','tests/fixtures/key_count_result_guard_julia_domain.json','tests/fixtures/key_count_result_guard_julia_errors.json'):
    if Path(name).is_file(): paths.append(Path(name))
cases=json.loads((BASE/'ownership-cases.json').read_text())
(OUT/'cases.json').write_text(json.dumps(cases,indent=2)+'\n')
paths.append(OUT/'cases.json')
records={}
with tarfile.open(OUT/'inputs-before-first-run.tar.gz','w:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.is_file() and path.stat().st_dev==ROOT.stat().st_dev
        body=path.read_bytes()
        records[str(path)]=dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),mode=path.stat().st_mode & 0o777)
        archive.add(path,arcname=str(path),recursive=False)
(OUT/'input-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
(OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
env=dict(os.environ,JULIA_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',JULIA_PKG_PRECOMPILE_AUTO='0')
args=[str(BASE/'observer.jl'),str(OUT/'cases.json'),str(OUT)]
command=['bash','tools/run_julia_project_data.sh','--project=julia','--startup-file=no','--history-file=no','--depwarn=error',*args]
(OUT/'command.json').write_text(json.dumps(dict(argv=command,environment={k:env[k] for k in ('JULIA_NUM_THREADS','OPENBLAS_NUM_THREADS','JULIA_PKG_PRECOMPILE_AUTO','LINKEDSPEC_KEY_COUNT_CAPTURE') if k in env}),indent=2)+'\n')
with (OUT/'stdout.log').open('wb') as stdout,(OUT/'stderr.log').open('wb') as stderr:
    result=subprocess.run(command,cwd=ROOT,env=env,stdout=stdout,stderr=stderr)
(OUT/'exit.txt').write_text(str(result.returncode)+'\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==r['sha256'] for p,r in records.items())
assert result.returncode in ((0,1) if phase=='normal-before' else (0,)), 'inspect full retained channels'
print(f'{phase}: exit{result.returncode}; actual declared inputs retained; inspect complete observations before grading')
