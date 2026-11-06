"""One source-role inverse and restoration through public Get on one source."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
mode, = sys.argv[1:]
assert mode in ('guard', 'policy')
OUT = BASE / ('guard-control' if mode == 'guard' else 'policy-control')
OUT.mkdir()
OWNER = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
original = OWNER.read_bytes()
needle = b'my $ordinary_hash_view_result_chain = ('
assert original.count(needle) == 1
inverse = original.replace(needle, b'my $ordinary_hash_view_result_chain = 0 && (')
cases = json.loads(Path('tests/fixtures/hash_view_result_guard_cases.json').read_bytes())
cases = [case for case in cases if case['id'] == 'free_sorted_keys_hash_guard']
variants = (('inverse', inverse), ('restored', original))
if mode == 'policy':
    activation = subprocess.check_output(['git', 'show', '6845971744426a9c897a994bddfcee3a5f2171b6:perl/LinkedSpec/ActionIR/MethodLowering.pm'])
    variants = (('activation', activation), ('implemented', original))
    body = 'return(["abc".length().sorted_values(),sorted_values(length("abc"))])'
    cases = [dict(id='length_sorted_values_policy', body=body,
                  source='Value:: I {' + body + '}\n', input='x', rule='Value', expected=[None, []])]
assert len(cases) == 1
(OUT / 'case.json').write_text(json.dumps(cases, indent=2) + '\n')
owner_path = OUT / 'owner.pm'
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl'], text=True).splitlines()]
paths += [BASE / 'causal_control.py', BASE / 'prepare_control.py', BASE / 'observe_control.pl',
          OUT / 'case.json', owner_path, Path('tests/fixtures/hash_view_result_guard_cases.json')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_run.sh', 'project_data_env.sh', 'run_python_project_data.sh')]
for phase, body in variants:
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
    rows = [json.loads(match[1]) for line in (directory / 'stdout.log').read_text().splitlines()
            if (match := re.match(r'^HASH_VIEW_CONTROL_PERL ' + cases[0]['id'] + r' (.*)$', line))]
    assert len(rows) == 1
    row = rows[0]
    assert row['native_callable'] == row['loaded'] == 1 and not row['warnings']
    if mode == 'policy':
        assert row['native'] == row['fresh'] == [None, []]
        assert row['native_error'] is row['fresh_error'] is None
        assert "ref($__ls_selected_default) eq 'HASH'" in row['substitution']
    elif phase == 'inverse':
        assert row['native_error']['stage'] == 'rule_handler_eval'
        assert row['fresh_error']['stage'] == 'execute_generated'
        assert all('Not a HASH reference' in row[route + '_error']['detail'] for route in ('native', 'fresh'))
    else:
        assert row['native'] == row['fresh'] == [None, '']
        assert row['native_error'] is row['fresh_error'] is None
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
owner_path.unlink()  # Exact inverse/restored bodies survive in the pre-use archives.
print(mode, 'same path/source/SDK/instrument; checkout owner unchanged')
