"""Actual old/fixed runtime images at one private own-Rust path; checkout untouched."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import traceback

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
CONTROL=BASE/'control-owner'
OWNER=Path('rust/linkedspec-runtime/src/engine.rs')
NORMAL=Path('rust/linkedspec-runtime/tests/hash_value_result_guard_composition.rs')
PROFILE=Path('tests/fixtures/hash_value_result_guard_rust_profiles.json')
ACTIVATION='4eeb2de5dbe3c6a602bd756a41eb51c0b457692d'
phase=sys.argv[1]
assert phase in ('private-inverse','private-restored')
OUT=BASE/phase
OUT.mkdir()


def main():
    assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()==ACTIVATION
    paths=[Path(p) for p in subprocess.check_output(['git','ls-files','rust','tests/fixtures'],text=True).splitlines()]
    paths += [NORMAL,PROFILE]+[Path('specs')/name for name in ('spec.spec','user_function_definition.spec','pplugin.spec')]
    paths=sorted(set(paths))
    if phase=='private-inverse':
        assert not CONTROL.exists()
        for source in paths:
            assert source.is_file() and not source.is_symlink()
            target=CONTROL/source
            target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(source,target)
        manifest=CONTROL/'rust/Cargo.toml'
        original=manifest.read_text()
        dependency=os.path.relpath(ROOT/'rgx/rgx-core',(ROOT/manifest).parent)
        assert not Path(dependency).is_absolute()
        assert original.count('path = "../rgx/rgx-core"')==1
        manifest.write_text(original.replace('path = "../rgx/rgx-core"','path = "'+dependency+'"'))
    else:
        assert CONTROL.is_dir() and not CONTROL.is_symlink()
        prior=json.loads((BASE/'private-inverse/input-identities.json').read_bytes())
        for name,row in prior.items():
            if name.startswith(str(CONTROL)+'/'):
                assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==row['sha256']
    image=(subprocess.check_output(['git','show',ACTIVATION+':'+str(OWNER)]) if phase=='private-inverse' else OWNER.read_bytes())
    (CONTROL/OWNER).write_bytes(image)
    declared=[CONTROL/path for path in paths]
    declared += [BASE/'private_control.py']+[Path(p) for p in ('tools/run_cargo_local.sh','tools/project_data_run.sh','tools/project_data_env.sh','tools/run_python_project_data.sh')]
    identities={}
    for path in sorted(set(declared)):
        assert path.stat().st_dev==ROOT.stat().st_dev and not path.is_symlink()
        body=path.read_bytes()
        identities[str(path)]=dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),mode=path.stat().st_mode & 0o777)
    (OUT/'activation.txt').write_text(ACTIVATION+'\n')
    (OUT/'input-identities.json').write_text(json.dumps(identities,indent=2,sort_keys=True)+'\n')
    with tarfile.open(OUT/'inputs-before-first-run.tar.gz','w:gz') as archive:
        for path in identities: archive.add(path,arcname=path,recursive=False)
    with tarfile.open(OUT/'inputs-before-first-run.tar.gz') as archive:
        assert {m.name:(hashlib.sha256(archive.extractfile(m).read()).hexdigest(),m.mode & 0o777) for m in archive}=={p:(r['sha256'],r['mode']) for p,r in identities.items()}
    command=['bash','tools/run_cargo_local.sh','test','--manifest-path',str(CONTROL/'rust/Cargo.toml'),'--locked','--offline','-j','1','-p','linkedspec-runtime','--test','hash_value_result_guard_composition','--','--nocapture','--test-threads=1']
    environment=dict(CARGO_BUILD_JOBS='1',RUST_TEST_THREADS='1')
    (OUT/'command.json').write_text(json.dumps(dict(argv=command,environment=environment),indent=2)+'\n')
    result=subprocess.run(command,env=dict(os.environ,**environment),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    for channel in ('stdout','stderr'): (OUT/(channel+'.log.gz')).write_bytes(gzip.compress(getattr(result,channel),mtime=0))
    (OUT/'exit.txt').write_text(str(result.returncode)+'\n')
    assert result.returncode==(101 if phase=='private-inverse' else 0)
    for name,row in identities.items():
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==row['sha256']
        assert Path(name).stat().st_mode & 0o777==row['mode']
    assert OWNER.read_bytes()!=subprocess.check_output(['git','show',ACTIVATION+':'+str(OWNER)])
    if phase=='private-restored':
        assert CONTROL.parent==BASE and not CONTROL.is_symlink()
        shutil.rmtree(CONTROL)
        assert not CONTROL.exists()
    print(phase+': actual private image normal completed; checkout owner untouched')


try:
    main()
except BaseException:
    (OUT/'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    raise
