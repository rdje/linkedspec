"""Capture the actual unchanged normal before and after its bounded repair."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 2 and sys.argv[1] in ('private_inverse', 'private_restored')
phase = sys.argv[1]
OUT = BASE / phase
OUT.mkdir()
tests = ['t/hash_helper_source_isolation.t']
if phase == 'qualified_direct':
    tests += ['t/set_key_block_operands.t', 't/pick_keys_operand_isolation.t', 't/drop_keys_generated.t']
paths = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'perl'], text=True).splitlines()]
paths += [Path(p) for p in tests]
paths += sorted(p for p in BASE.iterdir() if p.suffix in ('.py', '.json', '.pl', '.pm'))
paths += [Path('tests/fixtures') / name for name in ('hash_helper_source_isolation_perl_cases.json',
          'hash_helper_source_isolation_perl_extra_cases.json', 'hash_value_result_guard_perl_profiles.json')]
if phase == 'qualified_direct':
    paths += [Path('tests/fixtures/pick_keys_operand_isolation.json')]
paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
records = {}
with tarfile.open(OUT / 'inputs-before-first-run.tar.gz', 'x:gz') as archive:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and not path.is_absolute() and '..' not in path.parts
        assert path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        records[str(path)] = dict(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
(OUT / 'activation.txt').write_bytes(subprocess.check_output(['git', 'rev-parse', 'HEAD']))
executor = 'perl -Iperl ' + str(BASE / 'private_runner.pl') + ' ' + str(BASE / 'control-owner.pm')
command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=',
           'LINKEDSPEC_HASH_HELPER_SOURCE_CAPTURE=' + str(OUT), 'prove', '-v', '-j1', '--exec', executor] + tests
(OUT / 'command.json').write_text(json.dumps(dict(argv=command), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name, raw in (('stdout', result.stdout), ('stderr', result.stderr)):
    (OUT / (name + '.log.gz')).write_bytes(gzip.compress(raw, mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == r['sha256'] for p, r in records.items())
print('Actual normal', phase, 'full declared inputs/artifacts/channels retained, exit', result.returncode)
assert result.returncode == (1 if phase in ('private_inverse',) else 0), 'preserve unexpected epoch and qualify separately'
