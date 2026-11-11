"""Acquire own Perl policies with named input and generated-product retention."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'intake'
OUT.mkdir()
paths = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'perl', 'specs'], text=True).splitlines()]
paths += [BASE / name for name in ('prepare.py', 'acquire.py', 'capture.py', 'cases.json', 'own-questions.json',
    'observer.pl', 'template-identities.json', 'template-0.gz', 'template-1.gz', 'template-2.gz', 'template-3.gz',
    'prepare-command.json', 'prepare-exit.txt', 'prepare-stdout.log.gz', 'prepare-stderr.log.gz',
    'prepare-producer-images.json.gz', 'capture-producer-images.json.gz')]
paths += [Path(name) for name in json.loads((BASE / 'template-identities.json').read_bytes())]
paths += [Path(name) for name in (
    'tools/project_data_env.sh', 'tools/project_data_run.sh',
    'docs/checkpoints/type-operation-inventory/array-transform-callable-result-guard-composition.md',
    'docs/checkpoints/type-operation-inventory/array-transform-result-guard-composition.md',
    'docs/checkpoints/type-operation-inventory/array-pipeline-callable-result-guard-composition.md',
    'docs/knowledge/array-transform-callable-result-selection.md',
    'docs/knowledge/terse-user-defined-functions-mvp-contract.md',
    'docs/knowledge/variadic-user-function-contract.md',
    'docs/decisions/0030-variadic-callable-signature-contract.md',
    'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md',
    'docs/linkedspec-book/src/appendix/formal-grammar.md',
    'docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
    'capability_conformance/uniform_binding_contract.json', 'capability_conformance/scalar_text_contract.json')]
paths += list(Path('capability_conformance').glob('callable*.json'))
paths += list(Path('capability_conformance').glob('*function*.json'))
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        records[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=path, recursive=False)
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz') as archive:
    assert set(archive.getnames()) == set(records)
    for member in archive:
        raw = archive.extractfile(member).read()
        row = records[member.name]
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256']
        assert member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
commands = {
    'version': ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-V'],
    'observer': ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
                 str(BASE / 'observer.pl'), str(BASE / 'cases.json'), str(OUT)],
}
for tag, command in commands.items():
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    for name, row in records.items():
        path = ROOT / name
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
        assert path.stat().st_mode & 0o777 == row['mode']
    assert result.returncode == 0, 'actual first channels retained; qualify separately on failure'
    print(tag, 'actual0/full channels and named inputs unchanged', flush=True)
(OUT / 'complete.txt').write_text('Own original Perl intake completed; no production edit.\n')
