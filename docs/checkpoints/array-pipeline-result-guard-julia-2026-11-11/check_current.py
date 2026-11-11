"""Pre-landing actual SDK/input identity; later readonly metadata is excluded."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '00a56ed62acbde73f066c7e00cb79ea23a720728'
records = json.loads((BASE / 'direct/custody.json').read_bytes())[0]['files']
selected = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'julia', 'tests/fixtures'], text=True).splitlines()]
selected += [Path(p) for p in ('julia/test/array_pipeline_result_guard_composition_test.jl',
    'tests/fixtures/array_pipeline_result_guard_julia_cases.json', 'tests/fixtures/array_pipeline_result_guard_julia_profiles.json',
    'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec', 'tools/project_data_env.sh',
    'tools/project_data_run.sh', 'tools/run_python_project_data.sh', 'tools/run_julia_project_data.sh')]
selected += [BASE / name for name in ('prepare.py', 'capture_intake.py', 'freeze_policy.py', 'capture.py',
    'observer.jl', 'observer-template.jl.gz', 'observer-template-identity.json', 'cases.json', 'profile-sources.json',
    'baseline.json', 'owner-before.jl.gz', 'runner-before.jl.gz', 'repair.py')]
for path in sorted(set(selected)):
    body = path.read_bytes()
    row = records[str(path)]
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], str(path)
for name in ('repair-run', 'direct-preflight'):
    rows = json.loads((BASE / name / 'inputs.json').read_bytes())
    for path_name, row in rows.items():
        if path_name == 'julia/src/runtime/Interpreter.jl':
            continue  # The writer input is the declared old source, not candidate.
        path = Path(path_name)
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], path_name
print('PASS:current own SDK/runner, new/selected external fixtures, grammars and exact SDK/writer/direct instruments match before-use records')
print('LIMIT:pre-landing identity check; historical recovery uses review.py; complete native/cache/toolchain custody4.2 remains separate')
