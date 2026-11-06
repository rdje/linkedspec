"""One-shot actual current Perl CountKeys guard/source intake before production."""
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile
ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'intake'
OUT.mkdir(); (OUT / 'modules').mkdir()
paths = [Path(p) for p in subprocess.check_output(['git','ls-files','perl','specs','tests/fixtures','tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh'],text=True).splitlines()]
paths += [BASE / name for name in ('capture_intake.py','intake_probe.pl','intake-cases.json')]
paths.append(Path('tests/fixtures/key_count_perl_source_owner_cases.json'))
records = {}
with tarfile.open(OUT / 'inputs-before-first-get.tar.gz','x:gz') as archive:
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body=path.read_bytes()
        records[str(path)]=dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),mode=path.stat().st_mode & 0o777)
        archive.add(path,arcname=str(path),recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
command=['bash','tools/project_data_run.sh','env','PERL5LIB=','perl','-Iperl',str(BASE/'intake_probe.pl'),str(BASE/'intake-cases.json'),str(OUT/'modules')]
(OUT/'command.json').write_text(json.dumps(command,indent=2)+'\n')
with (OUT/'stdout.log').open('wb') as stdout,(OUT/'stderr.log').open('wb') as stderr:
    result=subprocess.run(command,cwd=ROOT,stdout=stdout,stderr=stderr)
(OUT/'exit.txt').write_text(str(result.returncode)+'\n')
assert result.returncode == 0
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==r['sha256'] for p,r in records.items())
print('Actual26 current source/result programs retained with declared first inputs/modules/full channels; inspect before freezing profiles or editing runtime')
