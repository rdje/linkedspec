"""Retain exact final warning-free normal and direct-dependent Cargo inputs."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd()
BASE = Path(__file__).resolve().parent.relative_to(ROOT.resolve())
OUT = BASE/'final'
OUT.mkdir()
paths = [Path(p) for p in subprocess.check_output(['git','ls-files','rust','tests/fixtures'],text=True).splitlines()]
paths += [BASE/'cleanup.py', Path('rust/linkedspec-runtime/tests/length_result_guard_composition.rs'),
          Path('tests/fixtures/length_result_guard_rust_domain.json')]
paths += [Path(p) for p in ('tools/run_cargo_local.sh','tools/project_data_env.sh')]
records = {}
with tarfile.open(OUT/'inputs-before-first-run.tar.gz','w:gz') as archive:
    for p in sorted(set(paths)):
        assert not p.is_absolute() and '..' not in p.parts and not p.is_symlink()
        assert p.stat().st_dev == ROOT.stat().st_dev
        body = p.read_bytes()
        records[str(p)] = dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),mode=p.stat().st_mode & 0o777)
        archive.add(p,arcname=str(p),recursive=False)
(OUT/'input-identities.json').write_text(json.dumps(records,indent=2)+'\n')
argv=['bash','tools/run_cargo_local.sh','test','--manifest-path','rust/Cargo.toml','--locked','--offline','-j','1','-p','linkedspec-runtime',
      '--test','length_result_guard_composition','--test','count_length_receivers','--test','count_result_guard_composition','--','--nocapture','--test-threads=1']
(OUT/'command.json').write_text(json.dumps(dict(argv=argv,environment=dict(CARGO_BUILD_JOBS='1',RUST_TEST_THREADS='1')),indent=2)+'\n')
with (OUT/'stdout.log').open('wb') as stdout,(OUT/'stderr.log').open('wb') as stderr:
    result=subprocess.run(argv,env=dict(os.environ,CARGO_BUILD_JOBS='1',RUST_TEST_THREADS='1'),stdout=stdout,stderr=stderr)
(OUT/'exit.txt').write_text(str(result.returncode)+'\n')
assert result.returncode==0,'inspect preserved raw channels'
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==r['sha256'] for p,r in records.items())
print('final: new normal and directly dependent Count/length guards PASS; inputs unchanged')
