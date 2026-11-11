"""Pre-landing current own SDK/input identity, excluding later readonly metadata."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '52cc3fa8073106154e8a3646ae27ee8e77d5d401'
records = json.loads((BASE / 'direct/custody.json').read_bytes())[0]['files']
selected = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'dart', 'tests/fixtures'], text=True).splitlines()]
selected += [Path(p) for p in ('dart/tool/probe_array_pipeline_results.dart', 'dart/test/array_pipeline_result_guard_composition_test.dart',
    'tests/fixtures/array_pipeline_result_guard_dart_profiles.json', 'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh', 'tools/run_dart_project_data.sh',
    'docs/checkpoints/array-transform-result-guard-dart-2026-11-10/cases.json')]
selected += [BASE / name for name in ('prepare.py', 'capture_intake.py', 'freeze_policy.py', 'capture.py',
    'cases.json', 'profile-sources.json', 'probe-template.dart.gz', 'probe-template-identity.json',
    'baseline.json', 'owner-before.dart.gz', 'repair.py')]
for path in sorted(set(selected)):
    body = path.read_bytes()
    row = records[str(path)]
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], str(path)
record = json.loads((BASE / 'private-fixed/custody.json').read_bytes())[0]['files'][str(BASE / 'private_control.py')]
path = BASE / 'private_control.py'
assert hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256'] and path.stat().st_mode & 0o777 == record['mode']
print('PASS:current own SDK, new/selected external fixtures, grammars and exact SDK/private instruments match actual first-use records')
print('LIMIT:pre-landing identity check; historical recovery uses review.py; complete native/VM/cache/toolchain custody4.2 remains separate')
