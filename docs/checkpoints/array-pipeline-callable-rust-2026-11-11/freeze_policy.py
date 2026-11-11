"""Freeze independent Rust policies and the supported later-with repair targets."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
CASES = Path('tests/fixtures/array_pipeline_callable_rust_cases.json')
PROFILE = Path('tests/fixtures/array_pipeline_callable_result_guard_rust_profiles.json')
NORMAL = Path('rust/linkedspec-runtime/tests/array_pipeline_callable_result_guard_composition.rs')
assert not any(path.exists() for path in (CASES, PROFILE, NORMAL))
assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
cases = json.loads((BASE / 'intake/cases.json').read_bytes())
shared = json.loads(Path('tests/fixtures/array_pipeline_callable_result_guard_cases.json').read_bytes())
shared_ids = {case['id'] for case in shared}
targets = set(assessment['shared_differences']) | {
    'own_signature_variadic_empty_composed', 'own_signature_variadic_multi_composed'}
compatibility = {'own_pattern_' + kind + '_composed' for kind in ('string', 'variable', 'block')}
assert len(targets) == 8 and len(compatibility) == 3
observed = dict(assessment['shared_differences'], **assessment['shared_profiles'])
for key in assessment['shared_healthy']:
    # Read complete cold route records rather than rebuilding expected errors.
    for line in gzip.open(BASE / 'intake/native-stdout.log.gz', 'rt'):
        prefix = 'CALLABLE_PIPELINE_RUST ' + key + ' '
        if line.startswith(prefix):
            observed[key] = json.loads(line[len(prefix):])
            break
for rows in assessment['own_groups'].values():
    observed.update(rows)
fresh = {}
for line in gzip.open(BASE / 'intake/fresh-stdout.log.gz', 'rt'):
    if line.startswith('CALLABLE_PIPELINE_RUST_FRESH '):
        _, key, body = line.split(' ', 2)
        fresh[key] = json.loads(body)
assert len(observed) == len(fresh) == len(cases) == 194
profiles = {}
for case in cases:
    key = case['id']
    row = dict(observed[key], fresh=fresh[key])
    role = 'preservation'
    if key in targets | compatibility:
        role = 'supported-target' if key in targets else 'pattern-compatibility'
        effects = ('S' if key == 'own_signature_variadic_multi_composed' else
            'P' if key == 'own_pattern_block_composed' else '')
        expected = {'value': [None, effects]}
        row = {route: expected for route in ('native', 'restored', 'plan', 'fresh')}
    profiles[key] = dict(case=case, role=role, **row)
assert set(profiles) == {case['id'] for case in cases}
CASES.write_text(json.dumps(cases, indent=2) + '\n')
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'baseline.json').write_text(json.dumps(dict(programs=194, supported_targets=sorted(targets),
    compatibility=sorted(compatibility), preserved=183,
    limits='Three pattern compatibility changes grant no new dynamic-pattern authority; existing terminal P effects survive.'), indent=2) + '\n')

prior = Path('rust/linkedspec-runtime/tests/array_pipeline_result_guard_composition.rs')
raw = prior.read_bytes()
assert raw == subprocess.check_output(['git', 'show', 'HEAD:' + str(prior)])
(BASE / 'normal-template.rs.gz').write_bytes(gzip.compress(raw, mtime=0))
prefix = raw.decode().split('fn check_case(')[0]
prefix = prefix.replace('TYPE-REFERENCE-BOOK.1.2.23.3.79.2', 'TYPE-REFERENCE-BOOK.1.2.23.3.79.6.2')
prefix = prefix.replace('ordinary Array-pipeline', 'callable Array-pipeline')
prefix = prefix.replace('array-pipeline-result-assessment.spec', 'array-pipeline-callable-result-assessment.spec')
prefix = prefix.replace('fn routes(source: &str, input: &str)', 'fn routes(label: &str, source: &str, input: &str)')
old = '    let restored: CompiledSpec = serde_json::from_str(&serialized).unwrap();\n'
assert prefix.count(old) == 1
replacement = '''    let retained = if let Ok(folder) = std::env::var("LINKEDSPEC_CALLABLE_PIPELINE_RUST_CAPTURE") {
        let path = std::path::Path::new(&folder);
        assert!(folder.starts_with("docs/checkpoints/array-pipeline-callable-rust-2026-11-11/"));
        assert!(path.components().all(|part| matches!(part, std::path::Component::Normal(_))));
        let inputs = path.join("normal-inputs");
        std::fs::create_dir_all(&inputs).unwrap();
        let target = inputs.join(format!("{label}.json"));
        assert!(!target.exists(), "capture inputs are one-shot");
        std::fs::write(&target, &serialized).unwrap();
        let retained = std::fs::read_to_string(target).unwrap();
        assert_eq!(retained.as_bytes(), serialized.as_bytes());
        eprintln!("CALLABLE_PIPELINE_RUST_NORMAL_INPUT {label} {}", serde_json::json!({"compiled": &retained}));
        retained
    } else { serialized.clone() };
    let restored: CompiledSpec = serde_json::from_str(&retained).unwrap();
'''
prefix = prefix.replace(old, replacement, 1)
body = '''fn check_case(label: &str) {
    let cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_pipeline_callable_rust_cases.json")).unwrap();
    let profiles: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_pipeline_callable_result_guard_rust_profiles.json")).unwrap();
    let case = cases.iter().find(|case| case["id"] == label).unwrap();
    let profile = &profiles[label];
    assert_eq!(&profile["case"], case, "cold source identity");
    let results = routes(label, case["source"].as_str().unwrap(), case["input"].as_str().unwrap());
    let mut observed = serde_json::Map::new();
    for (name, result) in ["native", "restored", "plan"].into_iter().zip(results) {
        let actual = match result {
            Ok(value) => serde_json::json!({"value": value}),
            Err(error) => serde_json::json!({"error": error}),
        };
        observed.insert(name.into(), actual);
    }
    eprintln!("CALLABLE_PIPELINE_RUST_NORMAL {label} {}", Value::Object(observed.clone()));
    for (name, actual) in observed {
        assert_eq!(actual, profile[&name], "{label} {name}: independent Rust policy/guard result");
    }
}

macro_rules! callable_pipeline_cases {
    ($($name:ident,)*) => { $(#[test] fn $name() { check_case(stringify!($name)); })* };
}
callable_pipeline_cases! {
'''
NORMAL.write_text(prefix + body + ''.join('    ' + case['id'] + ',\n' for case in cases) + '}\n')
owner = Path('rust/linkedspec-runtime/src/engine.rs')
original = subprocess.check_output(['git', 'show', 'HEAD:' + str(owner)])
assert owner.read_bytes() == original
(BASE / 'owner-before.rs.gz').write_bytes(gzip.compress(original, mtime=0))
print('Frozen194 independent normal profiles: eight supported targets, three separate compatibility changes,183 exact preservation records')
