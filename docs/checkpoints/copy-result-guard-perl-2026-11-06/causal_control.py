"""One predicate inverse and restoration through public Get on one source."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'logical-control'
OUT.mkdir()
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
original = OWNER.read_bytes()
needle = b'my $guarded_result_logical_chain = ($ordinary_count_result_chain || $ordinary_length_result_chain || $ordinary_key_count_result_chain\n    || $ordinary_copy_result_chain)'
assert original.count(needle) == 1
inverse = original.replace(needle, needle.replace(b'\n    || $ordinary_copy_result_chain', b''))
cases = json.loads(Path('tests/fixtures/copy_result_guard_perl_preservation_cases.json').read_bytes())
cases = [row for row in cases if row['id'] == 'logical_rejection']
assert len(cases) == 1
(OUT / 'case.json').write_text(json.dumps(cases, indent=2) + '\n')
owner_path = OUT / 'owner.pm'
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl'], text=True).splitlines()]
paths += [BASE / 'causal_control.py', BASE / 'observe_control.pl', OUT / 'case.json', owner_path,
          Path('tests/fixtures/copy_result_guard_perl_preservation_cases.json')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_run.sh', 'project_data_env.sh', 'run_python_project_data.sh')]
for phase, body in (('inverse', inverse), ('restored', original)):
    directory = OUT / phase
    directory.mkdir()
    owner_path.write_bytes(body)
    records = {}
    archive_path = directory / 'inputs-before-first-run.tar.gz'
    with tarfile.open(archive_path, 'x:gz') as archive:
        for path in sorted(set(paths)):
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            assert not path.is_absolute() and '..' not in path.parts
            raw = path.read_bytes()
            records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
    (directory / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl',
               str(BASE / 'observe_control.pl'), str(owner_path), str(OUT / 'case.json'), str(directory)]
    (directory / 'command.json').write_text(json.dumps(dict(argv=command), indent=2) + '\n')
    with (directory / 'stdout.log').open('wb') as stdout, (directory / 'stderr.log').open('wb') as stderr:
        result = subprocess.run(command, cwd=ROOT, stdout=stdout, stderr=stderr)
    (directory / 'exit.txt').write_text(str(result.returncode) + '\n')
    assert result.returncode == 0
    assert all(hashlib.sha256(Path(path).read_bytes()).hexdigest() == row['sha256'] for path, row in records.items())
    output = (directory / 'stdout.log').read_text()
    rows = [json.loads(match[1]) for line in output.splitlines()
            if (match := re.match(r'^COPY_CONTROL_PERL logical_rejection (.*)$', line))]
    assert len(rows) == 1
    row = rows[0]
    if phase == 'inverse':
        assert row['native_error']['stage'] == 'rule_handler_compile'
        assert row['loaded'] == 0 and 'syntax error' in row['load_error']
    else:
        assert row['native'] == row['fresh'] == [None, '']
        assert row['loaded'] == 1 and row['native_error'] is row['fresh_error'] is None and not row['warnings']
    with tarfile.open(archive_path) as archive:
        assert archive.extractfile(str(owner_path)).read() == body
    for name in ('stdout.log', 'stderr.log'):
        path = directory / name
        raw = path.read_bytes()
        destination = Path(str(path) + '.gz')
        destination.write_bytes(gzip.compress(raw, mtime=0))
        assert gzip.decompress(destination.read_bytes()) == path.read_bytes()
        path.unlink()
    print(phase, 'actual one-source public control verified', flush=True)
assert OWNER.read_bytes() == original and owner_path.read_bytes() == original
owner_path.unlink()  # Both exact bodies are retained in their pre-use archives.
print('Inverse RED/restored GREEN; same owner path, source, SDK and producer; worktree owner unchanged')
