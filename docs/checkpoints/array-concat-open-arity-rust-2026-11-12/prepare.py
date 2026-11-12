"""Prepare independent Rust source questions and actual four-route instruments."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'b3b9795f5c983e4dfb7ffa353b8368657c06bb65'
OLD = Path('docs/checkpoints/array-transform-callable-rust-2026-11-11')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
sources = [OLD / 'observer.rs', OLD / 'capture_intake.py',
    Path('docs/checkpoints/array-concat-open-arity-selection-2026-11-12/cases.json'),
    Path('tests/fixtures/array_transform_callable_rust_cases.json'),
    Path('tests/fixtures/array_transform_callable_result_guard_rust_profiles.json'),
    Path('docs/checkpoints/array-concat-open-arity-perl-2026-11-12/cases.json')]
images, bodies = {}, {}
for index, path in enumerate(sources):
    raw = path.read_bytes()
    assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    image = BASE / ('template-' + str(index) + '.gz')
    image.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(image.read_bytes()) == raw
    images[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(),
        mode=path.stat().st_mode & 0o777, image=str(image))
    bodies[str(path)] = raw
(BASE / 'template-identities.json').write_text(json.dumps(images, indent=2, sort_keys=True) + '\n')
shared = json.loads(bodies[str(sources[2])])
legacy = json.loads(bodies[str(sources[3])])
questions = json.loads(bodies[str(sources[5])])[396:]
assert len(shared) == 84 and len(legacy) == 312 and len(questions) == 108
allowed = ('id', 'body', 'source', 'input', 'rule', 'source_kind', 'array_count', 'form', 'tail',
    'empty', 'question', 'signature', 'paired_with')


def source_only(row, origin):
    result = {key: row[key] for key in allowed if key in row}
    result.update(origin=origin, profile_only=True)
    if 'expected_error' in row:
        result['question'] = 'needed-producer-error'
    assert not {'expected', 'expected_error', 'expected_observation', 'role'} & result.keys()
    return result


cases = [source_only(row, 'shared84') for row in shared]
cases += [source_only(row, 'legacy312') for row in legacy]
own = [source_only(row, 'questions108') for row in questions]
cases += own
assert len(cases) == len({row['id'] for row in cases}) == 504
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
(BASE / 'own-questions.json').write_text(json.dumps(own, indent=2) + '\n')

observer = bodies[str(sources[0])].decode()
observer = observer.replace('CALLABLE_TRANSFORM_RUST', 'ARRAY_CONCAT_RUST')
observer = observer.replace('array_transform_callable_rust_fresh', 'array_concat_open_arity_rust_fresh')
anchor = '    let emitted = emit_rust_source_v2(&compiled, &format!("array-transform-callable-result/{id}.spec"))'
assert observer.count(anchor) == 1
replacement = '''    let identity_prefix = if row["origin"].as_str() == Some("legacy312") {
        "array-transform-callable-result"
    } else {
        "array-concat-open-arity-result"
    };
    let plan_identity = format!("{identity_prefix}-assessment.spec");
    let emitted = emit_rust_source_v2(&compiled, &format!("{identity_prefix}/{id}.spec"))'''
observer = observer.replace(anchor, replacement)
anchor = '"array-transform-callable-result-assessment.spec", GENERATED_SOURCE_CONTRACT)'
assert observer.count(anchor) == 1
observer = observer.replace(anchor, '&plan_identity, GENERATED_SOURCE_CONTRACT)')
(BASE / 'observer.rs').write_text(observer)

capture = bodies[str(sources[1])].decode()
capture = capture.replace("ACTIVATION = '238da4cc727e9f5921990ef5e8575b45ceac2887'", "ACTIVATION = '" + ACTIVATION + "'")
capture = capture.replace('array-transform-callable-rust-', 'array-concat-open-arity-rust-')
assert capture.count('== 312') == 1
capture = capture.replace('== 312', '== 504').replace('Original312', 'Independent504')
capture = capture.replace('import os\n', 'import os\nimport re\n')
anchor = "    (OUT / 'activation.txt').write_text(ACTIVATION + '\\n')\n"
assert capture.count(anchor) == 1
capture = capture.replace(anchor, anchor + '''    memory = run('memory', ['bash', 'tools/project_data_run.sh', 'memory_pressure'])
    free = re.search(rb'System-wide memory free percentage: (\\d+)%', memory)
    assert free and int(free[1]) >= 45, 'Need conservative shared24GiB headroom before serial Rust builds'
    pin = subprocess.check_output(['git', 'ls-tree', 'HEAD', 'rgx'], text=True).split()[2]
    assert subprocess.check_output(['git', '-C', 'rgx', 'rev-parse', 'HEAD'], text=True).strip() == pin
    public = Path('rgx/docs/INTEGRATION.md')
    assert public.read_bytes() == subprocess.check_output(['git', '-C', 'rgx', 'show', pin + ':docs/INTEGRATION.md'])
    (OUT / 'rgx-public-contract.json').write_text(json.dumps(dict(pin=pin, published_guide=str(public),
        sha256=hashlib.sha256(public.read_bytes()).hexdigest(),
        scope='Published contract/pin metadata only. Prepared outputs are reused through normal own Cargo builds; no submodule writes, implementation inspection or transitive preparation recipe. Complete native/cache/toolchain closure remains4.2/SESSION5.'), indent=2) + '\\n')
''')
anchor = "    paths += [OUT / 'cases.json', native / 'src/main.rs', native / 'Cargo.toml', fresh / 'Cargo.toml']\n"
assert capture.count(anchor) == 1
capture = capture.replace(anchor, anchor + "    paths += [public, OUT / 'rgx-public-contract.json']\n")
compile(capture, 'capture_intake.py', 'exec')
(BASE / 'capture_intake.py').write_text(capture)
print('Prepared504 source-only questions: shared84/Rust legacy312/question108; own outcomes remain unacquired')
