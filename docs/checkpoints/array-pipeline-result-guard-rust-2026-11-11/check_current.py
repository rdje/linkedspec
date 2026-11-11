"""Pre-landing SDK identity check; later readonly metadata is excluded."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '74f3a4a1a21ba3cd1bf29579e3fcdb28cf3bd889'
snapshot = json.loads((BASE / 'direct/custody.json').read_bytes())[0]['files']
selected = [Path(name) for name in subprocess.check_output(['git', 'ls-files', 'rust', 'tests/fixtures'], text=True).splitlines()]
selected += [Path(name) for name in ('rust/linkedspec-runtime/tests/array_pipeline_result_guard_composition.rs',
    'tests/fixtures/array_pipeline_result_guard_rust_profiles.json', 'tools/project_data_env.sh',
    'tools/project_data_run.sh', 'tools/run_cargo_local.sh', 'tools/run_python_project_data.sh',
    'cli_conformance/cases/help/stdout.txt', 'specs/spec.spec', 'specs/user_function_definition.spec', 'specs/pplugin.spec')]
selected += [BASE / name for name in ('prepare.py', 'capture_intake.py', 'freeze_policy.py', 'capture.py',
    'observer.rs', 'observer-template.rs.gz', 'observer-template-identity.json', 'profile-sources.json',
    'baseline.json', 'owner-before.rs.gz', 'repair.py')]
for path in sorted(set(selected)):
    row = snapshot[str(path)]
    body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], str(path)
print('PASS:exact current own SDK/fixtures/grammars/help and explicit SDK instruments match direct first-use inputs')
print('LIMIT:pre-landing identity check only; historical recovery uses review.py; native/cache/transitive/toolchain/OS4.2 remains open')
