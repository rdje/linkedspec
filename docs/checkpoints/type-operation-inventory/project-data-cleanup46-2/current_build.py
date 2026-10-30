"""Retain and run one current public Rust check with the obsolete deps unavailable."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
WORK = ROOT / '.linkedspec-data/verification/project-data-cleanup46-2'
source = ROOT / '.linkedspec-data/scratch/ls004-adoption26/pre-adoption-rust-target/debug/deps'
quarantine = source.with_name(source.name + '-cleanup46-2-quarantine')
assert not source.exists() and quarantine.is_dir()
paths = subprocess.check_output(['git', 'ls-files', 'rust', 'tools/run_cargo_local.sh',
                                'tools/project_data_env.sh', 'tools/project_data_run.sh',
                                'tests/fixtures/rule_call_selection_values.spec',
                                'tests/fixtures/rule_call_selection_values.json'], cwd=ROOT, text=True).splitlines()
inputs = {}
for name in paths:
    path = ROOT / name
    assert path.is_file() and not path.is_symlink()
    raw = path.read_bytes()
    inputs[name] = dict(sha256=hashlib.sha256(raw).hexdigest(), base64=base64.b64encode(raw).decode())
with (WORK / 'current-build-inputs.json.gz').open('xb') as output:
    output.write(gzip.compress(json.dumps(inputs, sort_keys=True).encode(), mtime=0))
command = ['bash', 'tools/run_cargo_local.sh', 'test', '--manifest-path', 'rust/Cargo.toml',
           '--locked', '--offline', '-p', 'linkedspec-runtime', '--test', 'rule_call_result_selection']
result = subprocess.run(command, cwd=ROOT, capture_output=True)
(WORK / 'current-build.stdout').write_bytes(result.stdout)
(WORK / 'current-build.stderr').write_bytes(result.stderr)
binary = None
if result.returncode == 0:
    matches = re.findall(rb'Running tests/rule_call_result_selection\.rs \(([^)]+)\)', result.stderr)
    assert len(matches) == 1, 'retain the actual Cargo-reported test executable'
    path = Path(matches[0].decode())
    path = path if path.is_absolute() else ROOT / path
    assert path.is_relative_to(ROOT) and path.is_file() and not path.is_symlink()
    raw = path.read_bytes()
    with (WORK / 'current-test-executable.gz').open('xb') as output:
        output.write(gzip.compress(raw, mtime=0))
    assert gzip.decompress((WORK / 'current-test-executable.gz').read_bytes()) == raw
    binary = dict(path=path.relative_to(ROOT).as_posix(), bytes=len(raw),
                  sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o7777)
unchanged = all(hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == row['sha256']
                for name, row in inputs.items())
record = dict(command=command, exit=result.returncode, source_absent=not source.exists(),
              quarantine_present=quarantine.is_dir(), input_identities_unchanged=unchanged,
              actual_test_executable=binary,
              limits='One current public offline test target; dependency warnings remain upstream-owned. '
              'No exhaustive suite, cold package bootstrap or old-revision rebuild claim.')
with (WORK / 'current-build.json').open('x') as output:
    json.dump(record, output, sort_keys=True, indent=2)
    output.write('\n')
print(json.dumps(record), flush=True)
assert unchanged
sys.exit(result.returncode)
