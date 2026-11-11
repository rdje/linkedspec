"""One result-normal epoch, with actual inputs captured before SDK use."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--phase',required=True,choices=('before','after','private_old','private_current'))
args=parser.parse_args()
OUT=BASE/args.phase;OUT.mkdir()
paths=[Path(p) for p in subprocess.check_output(['git','ls-files','perl','specs'],text=True).splitlines()]
paths += [p for p in BASE.iterdir() if p.is_file()]
paths += [Path('t/array_pipeline_callable_result_guard_composition.t'),
    Path('tests/fixtures/array_pipeline_callable_result_guard_perl_cases.json')]
paths += [Path('tools')/name for name in ('project_data_env.sh','project_data_run.sh','run_python_project_data.sh')]
paths += [BASE/phase/name for phase in ('intake','signatures')
    for name in ('input-identities.json','run-command.json','run-exit.txt','run-stdout.log.gz','run-stderr.log.gz')]
private=Path('.linkedspec-data/scratch/callable-pipeline-result-perl/owner.pm')
if args.phase.startswith('private_'):paths.append(private)
rows={}
with tarfile.open(OUT/'inputs-before-use.tar.gz','x:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.is_file() and path.stat().st_dev==ROOT.stat().st_dev
        raw=path.read_bytes()
        rows[str(path)]=dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest(),mode=path.stat().st_mode&0o777)
        archive.add(path,arcname=path,recursive=False)
with tarfile.open(OUT/'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames())==set(rows)
    for member in archive:
        raw=archive.extractfile(member).read();row=rows[member.name]
        assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256']
        assert member.mode&0o777==row['mode']
(OUT/'input-identities.json').write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
(OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
commands={'version':['bash','tools/project_data_run.sh','env','PERL5LIB=','perl','-V']}
run=['bash','tools/project_data_run.sh','env','PERL5LIB=',
    'LINKEDSPEC_CALLABLE_PIPELINE_RESULT_CAPTURE='+str(OUT),'perl','-Iperl']
if args.phase.startswith('private_'):run += [str(BASE/'private_runner.pl'),str(private)]
run += ['t/array_pipeline_callable_result_guard_composition.t']
commands['run']=run
for tag,command in commands.items():
    (OUT/(tag+'-command.json')).write_text(json.dumps(dict(cwd='.',argv=command),indent=2)+'\n')
    result=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for channel in ('stdout','stderr'):
        (OUT/(tag+'-'+channel+'.log.gz')).write_bytes(gzip.compress(getattr(result,channel),mtime=0))
    (OUT/(tag+'-exit.txt')).write_text(str(result.returncode)+'\n')
    for name,row in rows.items():
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==row['sha256'],name
        assert Path(name).stat().st_mode&0o777==row['mode'],name
    red=tag=='run' and args.phase in ('before','private_old')
    assert (result.returncode!=0) if red else (result.returncode==0), 'Actual unexpected failure retained; qualify separately'
    print(args.phase,tag,'actual exit',result.returncode,flush=True)
(OUT/'complete.txt').write_text('Actual result-normal epoch complete; declared inputs unchanged.\n')
