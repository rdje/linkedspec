"""Freeze own Rust expectations and build the focused proof instruments."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
ACTIVATION = 'b3b9795f5c983e4dfb7ffa353b8368657c06bb65'
OLD = Path('docs/checkpoints/array-transform-callable-rust-2026-11-11')
NORMAL = Path('rust/linkedspec-runtime/tests/array_concat_open_arity_result_guard_composition.rs')
CASES = Path('tests/fixtures/array_concat_open_arity_rust_cases.json')
PROFILE = Path('tests/fixtures/array_concat_open_arity_result_guard_rust_profiles.json')
assert not any(path.exists() for path in (NORMAL, CASES, PROFILE))
assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
cases = json.loads((BASE / 'cases.json').read_bytes())
targets = assessment['targets'] | assessment['compatibility']
profiles = {case['id']: dict(case=case, role='supported-target' if case['id'] in assessment['targets']
    else 'legacy-operand-compatibility' if case['id'] in assessment['compatibility'] else 'preservation',
    **targets.get(case['id'], assessment['observed'][case['id']])) for case in cases}
assert len(profiles) == 504 and len(assessment['targets']) == 16 and len(assessment['compatibility']) == 2
CASES.write_text(json.dumps(cases, indent=2) + '\n')
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'baseline.json').write_text(json.dumps({key: assessment[key] for key in (
    'programs', 'supported_targets', 'compatibility_ids', 'preserved', 'initial_policies', 'invalid_signatures', 'limits')}, indent=2) + '\n')


def template(path, name):
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    (BASE / (name + '.gz')).write_bytes(gzip.compress(body, mtime=0))
    (BASE / (name + '-identity.json')).write_text(json.dumps(dict(path=str(path), bytes=len(body),
        sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777), indent=2) + '\n')
    return body.decode()


old_normal = template(Path('rust/linkedspec-runtime/tests/array_transform_callable_result_guard_composition.rs'), 'normal-template.rs')
normal = old_normal[:old_normal.index('callable_transform_cases! {')]
for old, new in (
    ('TYPE-REFERENCE-BOOK.1.2.23.3.78.6.2', 'TYPE-REFERENCE-BOOK.1.2.23.3.80.2'),
    ('array-transform-callable-rust-2026-11-11', BASE.name),
    ('array_transform_callable_rust_cases.json', CASES.name),
    ('array_transform_callable_result_guard_rust_profiles.json', PROFILE.name),
    ('CALLABLE_TRANSFORM', 'ARRAY_CONCAT'),
    ('callable_transform_cases', 'array_concat_cases'),
):
    normal = normal.replace(old, new)
anchor = 'fn routes(label: &str, source: &str, input: &str) -> Vec<Result<Value, String>> {'
assert normal.count(anchor) == 1
normal = normal.replace(anchor, 'fn routes(label: &str, source: &str, input: &str, legacy: bool) -> Vec<Result<Value, String>> {')
anchor = '"array-transform-callable-result-assessment.spec",'
assert normal.count(anchor) == 1
normal = normal.replace(anchor, 'if legacy { "array-transform-callable-result-assessment.spec" } else { "array-concat-open-arity-result-assessment.spec" },')
anchor = '        case["input"].as_str().unwrap(),\n'
assert normal.count(anchor) == 1
normal = normal.replace(anchor, anchor + '        case["origin"].as_str() == Some("legacy312"),\n')
normal += 'array_concat_cases! {\n' + ''.join('    ' + case['id'] + ',\n' for case in cases) + '}\n'
NORMAL.write_text(normal)
(BASE / 'normal-before-format.rs.gz').write_bytes(gzip.compress(NORMAL.read_bytes(), mtime=0))
command = ['bash', 'tools/project_data_run.sh', 'rustfmt', '--edition', '2024', str(NORMAL)]
(BASE / 'normal-format-command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('normal-format-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'normal-format-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and not result.stderr

capture = template(OLD / 'capture.py', 'capture-template.py')
capture = capture.replace('238da4cc727e9f5921990ef5e8575b45ceac2887', ACTIVATION)
capture = capture.replace('array_transform_callable_result_guard_composition', NORMAL.stem)
capture = capture.replace('array_transform_callable_result_guard_rust_profiles.json', PROFILE.name)
capture = capture.replace('array_transform_callable_rust_cases.json', CASES.name)
capture = capture.replace('CALLABLE_TRANSFORM', 'ARRAY_CONCAT')
capture = capture.replace('array-transform-callable-rust-', 'array-concat-open-arity-rust-')
capture = capture.replace('== 312', '== 504')
capture = capture.replace("'292 passed; 20 failed'", "'486 passed; 18 failed'")
capture = capture.replace("'312 passed; 0 failed'", "'504 passed; 0 failed'")
start = capture.index('    paths += [BASE / name for name in (')
end = capture.index('\n    sdk =', start)
capture = capture[:start] + "    paths += [p for p in BASE.iterdir() if p.is_file()]" + capture[end:]
anchor = "names += ['array_transform_result_guard_composition', 'array_pipeline_callable_result_guard_composition']"
assert capture.count(anchor) == 1
capture = capture.replace(anchor, "names += ['array_transform_result_guard_composition', 'array_transform_callable_result_guard_composition', 'array_pipeline_callable_result_guard_composition']")
capture = capture.replace("'194 passed; 0 failed') in stdout", "'312 passed; 0 failed' if index == 2 else '194 passed; 0 failed') in stdout")
capture = capture.replace('import os\n', 'import os\nimport re\n')
anchor = "    (OUT / 'activation.txt').write_text(ACTIVATION + '\\n')\n"
assert capture.count(anchor) == 1
capture = capture.replace(anchor, anchor + '''    memory = run('memory', ['bash', 'tools/project_data_run.sh', 'memory_pressure'])
    free = re.search(rb'System-wide memory free percentage: (\\d+)%', memory)
    assert free and int(free[1]) >= 45, 'Need conservative serial-build headroom'
''')
compile(capture, 'capture.py', 'exec')
(BASE / 'capture.py').write_text(capture)

run_repair = template(OLD / 'run_repair.py', 'run-repair-template.py')
run_repair = run_repair.replace('array_transform_callable_result_guard_composition.rs', NORMAL.name)
(BASE / 'run_repair.py').write_text(run_repair)
owner = Path('rust/linkedspec-runtime/src/engine.rs')
body = owner.read_bytes()
assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(owner)])
(BASE / 'owner-before.rs.gz').write_bytes(gzip.compress(body, mtime=0))
print('Frozen504:16 terminal-supported targets/two own legacy operand continuations/486 exact records; producer/signature untouched')
