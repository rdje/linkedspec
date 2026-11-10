"""One first public Perl selection intake; actual inputs before SDK, gzip-first channels."""
import gzip,hashlib,json,subprocess,tarfile
from pathlib import Path
ROOT=Path.cwd().resolve();BASE=Path(__file__).resolve().parent.relative_to(ROOT)
OUT=BASE/'intake';OUT.mkdir()
paths=[Path(p) for p in subprocess.check_output(['git','ls-files','perl'],text=True).splitlines()]
paths += [BASE/name for name in ('prepare.py','cases.json','capture.py','observer.pl')]
paths += [Path('specs')/name for name in ('spec.spec','user_function_definition.spec','pplugin.spec')]
paths += [Path('tools')/name for name in ('project_data_env.sh','project_data_run.sh','run_python_project_data.sh')]
paths += [Path(p) for p in ('docs/checkpoints/type-operation-inventory/helpers.md','docs/checkpoints/type-operation-inventory/constructor-result-composition.md','docs/checkpoints/type-operation-inventory/hash-view-result-guard-composition.md','docs/checkpoints/type-operation-inventory/hash-value-result-guard-composition.md','docs/checkpoints/hash-value-result-selection-2026-11-07/REVIEW.md','docs/linkedspec-book/src/appendix/helper-contract-catalog.md','docs/knowledge/punctuation-light-receiver-arity-calibration.md')]
paths += [Path(p) for p in ('t/array_pipeline_value_contract.t','docs/knowledge/array-helper-return-shape-caveats.md','docs/knowledge/lua-runtime-array-transform-pipelines.md','docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md','capability_conformance/uniform_binding_contract.json','capability_conformance/scalar_text_contract.json')]
records={}
with tarfile.open(OUT/'inputs-before-first-run.tar.gz','x:gz') as archive:
    for p in sorted(set(paths)):
        assert p.is_file() and not p.is_absolute() and '..' not in p.parts and not p.is_symlink() and p.stat().st_dev==ROOT.stat().st_dev
        body=p.read_bytes();records[str(p)]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest(),mode=p.stat().st_mode&0o777);archive.add(p,arcname=p,recursive=False)
with tarfile.open(OUT/'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames())==set(records)
    for member in archive:
        row=records[member.name];body=archive.extractfile(member).read();assert len(body)==row['bytes'] and hashlib.sha256(body).hexdigest()==row['sha256'] and member.mode&0o777==row['mode']
(OUT/'input-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
(OUT/'activation.txt').write_bytes(subprocess.check_output(['git','rev-parse','HEAD']))
command=['bash','tools/project_data_run.sh','env','PERL5LIB=','perl','-Iperl',str(BASE/'observer.pl'),str(BASE/'cases.json'),str(OUT)]
(OUT/'command.json').write_text(json.dumps(dict(argv=command,cwd='.'),indent=2)+'\n')
r=subprocess.run(command,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
for channel in ('stdout','stderr'):(OUT/(channel+'.log.gz')).write_bytes(gzip.compress(getattr(r,channel),mtime=0))
(OUT/'exit.txt').write_text(str(r.returncode)+'\n')
for p,row in records.items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==row['sha256'] and Path(p).stat().st_mode&0o777==row['mode']
print('first full-source public intake retained, exit',r.returncode)
assert r.returncode==0,'retain first failure; separate qualification required before retry'
