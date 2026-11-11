"""Acquire finite full-source public observations with source/product custody."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'qualified'
OUT.mkdir()
paths = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [BASE / name for name in ('prepare.py', 'acquire.py', 'capture.py', 'qualified-cases.json', 'qualified_observer.pl',
    'observer-template.pl.gz', 'template-identities.json', 'pointer-repairs.json',
    'prepare-command.json', 'prepare-exit.txt', 'prepare-stdout.log.gz', 'prepare-stderr.log.gz',
    'prepare-producer-images.json.gz', 'capture-producer-images.json.gz')]
paths += list(BASE.glob('pointer-*.gz'))
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh')]
paths += [Path(name) for name in (
    'docs/checkpoints/array-pipeline-callable-selection-2026-11-11/observer.pl',
    'docs/checkpoints/array-pipeline-callable-selection-2026-11-11/prepare.py',
    'docs/checkpoints/array-pipeline-callable-selection-2026-11-11/capture.py',
    'docs/checkpoints/type-operation-inventory/helpers.md',
    'docs/checkpoints/type-operation-inventory/syntax.md',
    'docs/checkpoints/type-reference-inventory/README.md',
    'docs/checkpoints/type-operation-inventory/array-transform-result-guard-composition.md',
    'docs/checkpoints/type-operation-inventory/array-pipeline-callable-result-guard-composition.md',
    'docs/knowledge/terse-user-defined-functions-mvp-contract.md',
    'docs/knowledge/array-transform-result-guard-selection.md',
    'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md',
    'docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
    'docs/linkedspec-book/src/appendix/formal-grammar.md',
    'capability_conformance/uniform_binding_contract.json',
    'capability_conformance/scalar_text_contract.json')]
paths += list(Path('capability_conformance').glob('callable*.json'))
paths += list(Path('capability_conformance').glob('*function*.json'))
paths += [BASE / name for name in ('capture_qualified.py', 'inspect_qualified.py', 'qualify.py',
    'run_qualified.py', 'qualification.json', 'oracle-template.json.gz',
    'observer.pl-qualification-template.gz', 'capture.py-qualification-template.gz',
    'inspect.py-qualification-template.gz', 'cases.json', 'observer.pl',
    'qualified-capture-producer-images.json.gz')]
paths += [Path('tests/fixtures/array_transform_result_guard_cases.json')]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        records[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == set(records)
    for member in archive:
        body = archive.extractfile(member).read()
        row = records[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
commands = {
    'version': ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V'],
    'observer': ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
                 str(BASE / 'qualified_observer.pl'), str(BASE / 'qualified-cases.json'), str(OUT)],
}
for tag, command in commands.items():
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    for name, row in records.items():
        path = Path(name)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
        assert path.stat().st_mode & 0o777 == row['mode']
    assert result.returncode == 0, 'original channels retained; qualification requires a separate owner/output'
    print(tag, 'actual0/full channels and original inputs retained', flush=True)
(OUT / 'complete.txt').write_text('Original full-source callable transform intake completed; inputs unchanged.\n')
