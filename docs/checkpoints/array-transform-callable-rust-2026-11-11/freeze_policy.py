"""Freeze independently acquired Rust policies and twenty supported targets."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
CASES = Path('tests/fixtures/array_transform_callable_rust_cases.json')
PROFILE = Path('tests/fixtures/array_transform_callable_result_guard_rust_profiles.json')
NORMAL = Path('rust/linkedspec-runtime/tests/array_transform_callable_result_guard_composition.rs')
assert not any(path.exists() for path in (CASES, PROFILE, NORMAL, BASE / 'baseline.json'))
assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
cases = json.loads((BASE / 'cases.json').read_bytes())
observed = assessment['observed']
ROUTES = ('native', 'restored', 'plan', 'fresh')
targets = {}
shared = {case['id']: case for case in cases[:45]}
assert set(assessment['shared_differences']) == {
    'take_later_with', 'reverse_copy_later_with', 'drop_logical_later_with', 'source_effect_before_rejection'}
for key in assessment['shared_differences']:
    targets[key] = {route: {'value': shared[key]['expected']} for route in ROUTES}
for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
    key = 'own_optional_' + helper + '_receiver_composed'
    contrast = observed['own_optional_' + helper + '_free_composed']
    assert all(row == {'value': [None, 'S']} for row in contrast.values())
    assert observed['own_optional_' + helper + '_receiver'] == observed['own_optional_' + helper + '_free']
    targets[key] = contrast
for key in ('own_signature_variadic_empty', 'own_signature_variadic_multi'):
    terminal = observed[key + '_terminal']
    targets[key + '_composed'] = {}
    for route in ROUTES:
        array, effects = terminal[route]['value']
        assert isinstance(array, list) and effects in ('', 'S')
        targets[key + '_composed'][route] = {'value': [None, effects]}
targets['own_source_before_rejection'] = {route: {'value': [None, 'S']} for route in ROUTES}
for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays'):
    terminal = observed['positive_' + helper + '_receiver_terminal']
    targets['positive_' + helper + '_receiver_composed'] = {}
    for route in ROUTES:
        array, effects = terminal[route]['value']
        assert isinstance(array, list) and effects in ('S', 'SN', 'SNC', 'ST')
        targets['positive_' + helper + '_receiver_composed'][route] = {'value': [None, effects]}
assert len(targets) == 20 and all(observed[key] != row for key, row in targets.items())
profiles = {case['id']: dict(case=case,
    role='supported-target' if case['id'] in targets else 'preservation',
    **targets.get(case['id'], observed[case['id']])) for case in cases}
assert len(profiles) == 312
CASES.write_text(json.dumps(cases, indent=2) + '\n')
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'baseline.json').write_text(json.dumps(dict(programs=312, supported_targets=sorted(targets),
    preserved=292, shared_healthy=34, shared_profiles=7,
    limits='Finite authored Rust controls, no compatibility/readiness normalization or peer policy; excluded/open-arity and initial-input authority stay unchanged.'), indent=2) + '\n')

prior = Path('rust/linkedspec-runtime/tests/array_pipeline_callable_result_guard_composition.rs')
raw = prior.read_bytes()
assert raw == subprocess.check_output(['git', 'show', 'HEAD:' + str(prior)])
(BASE / 'normal-template.rs.gz').write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'normal-template-identity.json').write_text(json.dumps(dict(path=str(prior), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest()), indent=2) + '\n')
prefix = raw.decode().split('fn check_case(')[0]
for old, new in (('TYPE-REFERENCE-BOOK.1.2.23.3.79.6.2', 'TYPE-REFERENCE-BOOK.1.2.23.3.78.6.2'),
    ('array-pipeline-callable-rust-2026-11-11', BASE.name), ('Array-pipeline', 'Array-transform'),
    ('array-pipeline-callable', 'array-transform-callable'), ('CALLABLE_PIPELINE', 'CALLABLE_TRANSFORM')):
    prefix = prefix.replace(old, new)
anchor = '    validate(&parsed).expect("validate Array-transform sources");\n'
assert prefix.count(anchor) == 1
snapshot = '''    if let Ok(folder) = std::env::var("LINKEDSPEC_CALLABLE_TRANSFORM_RUST_CAPTURE") {
        let path = std::path::Path::new(&folder);
        assert!(folder.starts_with("docs/checkpoints/array-transform-callable-rust-2026-11-11/"));
        assert!(path.components().all(|part| matches!(part, std::path::Component::Normal(_))));
        let inputs = path.join("normal-parsed");
        std::fs::create_dir_all(&inputs).unwrap();
        let target = inputs.join(format!("{label}.json"));
        assert!(!target.exists(), "parsed snapshots are one-shot");
        let body = serde_json::to_string(&parsed).unwrap();
        std::fs::write(&target, &body).unwrap();
        assert_eq!(std::fs::read_to_string(target).unwrap(), body);
        eprintln!("CALLABLE_TRANSFORM_RUST_NORMAL_PARSED_INPUT {label} {}", serde_json::json!({"parsed": body}));
    }
'''
prefix = prefix.replace(anchor, snapshot + anchor)
prefix = prefix.replace('            &serialized,\n            &plan,', '            &retained,\n            &plan,')
body = '''fn check_case(label: &str) {
    let cases: Vec<Value> = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_transform_callable_rust_cases.json")).unwrap();
    let profiles: Value = serde_json::from_str(include_str!(
        "../../../tests/fixtures/array_transform_callable_result_guard_rust_profiles.json")).unwrap();
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
    eprintln!("CALLABLE_TRANSFORM_RUST_NORMAL {label} {}", Value::Object(observed.clone()));
    for (name, actual) in observed {
        assert_eq!(actual, profile[&name], "{label} {name}: independent Rust policy/guard result");
    }
}

macro_rules! callable_transform_cases {
    ($($name:ident,)*) => { $(#[test] fn $name() { check_case(stringify!($name)); })* };
}
callable_transform_cases! {
'''
NORMAL.write_text(prefix + body + ''.join('    ' + case['id'] + ',\n' for case in cases) + '}\n')
unformatted = NORMAL.read_bytes()
(BASE / 'normal-before-format.rs.gz').write_bytes(gzip.compress(unformatted, mtime=0))
command = ['bash', 'tools/project_data_run.sh', 'rustfmt', '--edition', '2024', str(NORMAL)]
(BASE / 'normal-format-command.json').write_text(json.dumps(dict(argv=command, cwd='.', input_bytes=len(unformatted), input_sha256=hashlib.sha256(unformatted).hexdigest()), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('normal-format-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'normal-format-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b''
owner = Path('rust/linkedspec-runtime/src/engine.rs')
old = subprocess.check_output(['git', 'show', 'HEAD:' + str(owner)])
assert owner.read_bytes() == old
(BASE / 'owner-before.rs.gz').write_bytes(gzip.compress(old, mtime=0))
print('Frozen312 own Rust normal profiles:20 supported targets/292 full preserved records; no production change')
