"""Focused direct Count diagnostic/length compatibility, with actual Cargo inputs."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile

base = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
output = base / 'compat'
output.mkdir()
names = ['rust/Cargo.toml', 'rust/Cargo.lock', 'rust/linkedspec-core/Cargo.toml',
         'rust/linkedspec-runtime/Cargo.toml', 'rust/linkedspec-runtime/src/engine.rs',
         'rust/linkedspec-runtime/tests/count_result_guard_composition.rs',
         'rust/linkedspec-runtime/tests/count_length_receivers.rs',
         'tests/fixtures/count_result_guard_cases.json',
         'tests/fixtures/count_result_guard_source_owner_cases.json',
         'tests/fixtures/count_result_guard_excluded_ast.json',
         'tests/fixtures/count_result_guard_rust_ast.json']
images = {name: hashlib.sha256(Path(name).read_bytes()).hexdigest() for name in names}
with tarfile.open(output / 'before-first-run.tar.gz', 'w:gz') as archive:
    for name in names:
        assert not Path(name).is_symlink()
        archive.add(name, arcname=name, recursive=False)
with tarfile.open(output / 'before-first-run.tar.gz') as archive:
    assert {m.name: hashlib.sha256(archive.extractfile(m).read()).hexdigest()
            for m in archive.getmembers() if m.isfile()} == images
(output / 'inputs.json').write_text(json.dumps(images, sort_keys=True, indent=2) + '\n')
env = dict(os.environ, CARGO_BUILD_JOBS='1', RUST_TEST_THREADS='1')
for name, arguments in [
    ('domain', ['--test', 'count_result_guard_composition', 'source_domain_diagnostic']),
    ('length', ['--test', 'count_length_receivers']),
]:
    command = ['bash', 'tools/ram_guard.sh', '--danger-pct', '86', '--ceiling-mb', '2048',
               '--', 'bash', 'tools/run_cargo_local.sh', 'test', '--manifest-path', 'rust/Cargo.toml',
               '--locked', '--offline', '-p', 'linkedspec-runtime', *arguments,
               '--', '--nocapture', '--test-threads=1']
    (output / (name + '-command.json')).write_text(json.dumps(command) + '\n')
    with (output / (name + '-stdout.log')).open('wb') as stdout, (output / (name + '-stderr.log')).open('wb') as stderr:
        result = subprocess.run(command, env=env, stdout=stdout, stderr=stderr)
    (output / (name + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, name
assert all(hashlib.sha256(Path(name).read_bytes()).hexdigest() == digest for name, digest in images.items())
print('PASS: current Count domain1 and Count/length1, actual Cargo inputs retained unchanged')
