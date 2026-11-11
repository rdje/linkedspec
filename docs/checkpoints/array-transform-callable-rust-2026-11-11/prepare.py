"""Prepare source-only questions and prospective Rust four-route custody."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
ACTIVATION = '238da4cc727e9f5921990ef5e8575b45ceac2887'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
prior = Path('docs/checkpoints/array-pipeline-callable-rust-2026-11-11')
names = [prior / name for name in ('capture_intake.py', 'observer.rs', 'capture.py', 'review.py',
    'capture_trace.py', 'trace_observer.rs', 'repair.py', 'run_repair.py', 'retire_live_copies.py', 'check_current.py', 'seal.py')]
shared_path = Path('tests/fixtures/array_transform_callable_result_guard_cases.json')
questions_path = Path('docs/checkpoints/array-transform-callable-result-perl-2026-11-11/cases.json')
names += [shared_path, questions_path]
images = {}
for index, name in enumerate(names):
    raw = (ROOT / name).read_bytes()
    assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(name)])
    artifact = BASE / ('template-' + str(index) + '.gz')
    artifact.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(artifact.read_bytes()) == raw
    images[str(name)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), artifact=str(artifact.relative_to(ROOT)))
(BASE / 'template-identities.json').write_text(json.dumps(images, indent=2, sort_keys=True) + '\n')

shared = json.loads((ROOT / shared_path).read_bytes())
original = json.loads((ROOT / questions_path).read_bytes())
assert len(shared) == 45 and len(original) == 312 and original[:45] == shared
own = []
for row in original[45:]:
    # Deliberately omit every peer verdict, role and expected observation/value.
    source = {key: row[key] for key in ('id', 'body', 'source', 'input', 'rule', 'question', 'paired_with', 'form') if key in row}
    source['profile_only'] = True
    source.setdefault('question', 'source-order-or-terminal-question')
    assert not {'expected', 'expected_error', 'expected_observation', 'role'} & source.keys()
    own.append(source)
cases = shared + own
assert len(cases) == len({row['id'] for row in cases}) == 312
(BASE / 'own-questions.json').write_text(json.dumps(own, indent=2) + '\n')
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')

def adapted(name):
    text = (ROOT / prior / name).read_text()
    text = text.replace('7e99813d1a88b748cf310992a4ef6ffadf7e978f', ACTIVATION)
    text = text.replace('array-pipeline-callable-rust-2026-11-11', BASE.name)
    text = text.replace('array-pipeline-callable', 'array-transform-callable')
    text = text.replace('array_pipeline_callable', 'array_transform_callable')
    text = text.replace('CALLABLE_PIPELINE', 'CALLABLE_TRANSFORM')
    return text

observer = adapted('observer.rs')
anchor = '    validate(&parsed).map_err(|error| format!("validate: {error:?}"))?;\n'
assert observer.count(anchor) == 1
snapshot = '''    let parsed_bytes = serde_json::to_vec(&parsed).unwrap();
    fs::create_dir_all(fresh.join("parsed-inputs")).unwrap();
    let parsed_path = fresh.join("parsed-inputs").join(format!("{id}.json"));
    assert!(!parsed_path.exists(), "parsed snapshots are one-shot");
    fs::write(&parsed_path, &parsed_bytes).unwrap();
    assert_eq!(fs::read(&parsed_path).unwrap(), parsed_bytes);
    println!("CALLABLE_TRANSFORM_RUST_PARSED_INPUT {id} {}", json!({"parsed": String::from_utf8(parsed_bytes).unwrap()}));
'''
observer = observer.replace(anchor, snapshot + anchor)
observer = observer.replace('execute_generated_parser_v2(&serialized,', 'execute_generated_parser_v2(&retained,')
(BASE / 'observer.rs').write_text(observer)

capture = adapted('capture_intake.py')
start = capture.index("    cases = json.loads(Path('tests/fixtures/")
end = capture.index("    (OUT / 'cases.json').write_text", start)
capture = capture[:start] + "    cases = json.loads((BASE / 'cases.json').read_bytes())\n    assert len(cases) == len({c['id'] for c in cases}) == 312\n" + capture[end:]
capture = capture.replace("list((fresh / 'inputs').glob('*.json'))", "list((fresh / 'inputs').glob('*.json')) + list((fresh / 'parsed-inputs').glob('*.json'))")
capture = capture.replace('Original194', 'Original312')
(BASE / 'capture_intake.py').write_text(capture)
print(json.dumps(dict(prepared='PASS', shared=45, source_only_own=267, total=312,
    scope='Question sources only; Rust observations, classifications and policies remain unacquired. Parsed snapshots precede validation/compile; serialized persistence/readback precedes restore.')))
