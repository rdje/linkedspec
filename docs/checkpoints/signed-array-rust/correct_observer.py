"""Preserve the original observer, then compare wide wire integers through typed serde."""
import json
import common as c

TEST = 'rust/linkedspec-runtime/tests/signed_array_selector_contract.rs'
FIXTURE = 'tests/signed-array-rust/cases.json'


def decoded(value):
    if isinstance(value, dict):
        if set(value) == {'exact_integer'}:
            return int(value['exact_integer'])
        return {key: decoded(item) for key, item in value.items()}
    if isinstance(value, list):
        return [decoded(item) for item in value]
    return value


def main():
    prior = c.load('test-json-before-inputs.json.gz')
    before = {path: c.read(path) for path in (TEST, FIXTURE)}
    assert before[TEST] == prior['test'] and before[FIXTURE] == prior['fixture']
    c.write_new('observer-correction-inputs.json.gz', dict(before=before,
        producer=c.read(c.PREFIX + 'correct_observer.py'),
        scope='Original generic Value observer coarsens a wide expected integer. Its deliberate SDK-token failure is an observer-configuration control, not a new engine defect. Preserve every original channel/source; change only exact-integer comparison representation.'))
    text = c.decode(before[TEST]['base64']).decode()
    old = '''        Err(error) => json!({"error": serde_json::from_str::<Value>(&error)
            .unwrap_or(Value::String(error))}),'''
    new = '''        Err(error) => {
            let projection = serde_json::from_str::<Value>(&error)
                .unwrap_or_else(|_| Value::String(error.clone()));
            json!({"error": projection, "raw_error": error})
        }'''
    assert text.count(old) == 1
    text = text.replace(old, new, 1)
    old = '''        .all(|(key, value)| actual["error"].get(key) == Some(value))'''
    new = '''        .all(|(key, value)| {
            if let Some(integer) = value.get("exact_integer").and_then(Value::as_str) {
                let Some(raw) = actual["raw_error"].as_str() else {
                    return false;
                };
                let Ok(fields) = serde_json::from_str::<SignedDiagnosticIntegers>(raw) else {
                    return false;
                };
                let observed = match key.as_str() {
                    "index" => fields.index,
                    "resolved_index" => fields.resolved_index,
                    _ => None,
                };
                return observed == Some(integer.parse::<i128>().expect("exact integer target"));
            }
            actual["error"].get(key) == Some(value)
        })'''
    assert text.count(old) == 1
    text = text.replace(old, new, 1)
    marker = 'fn normalized(result: Result<Value, String>) -> Value {'
    assert text.count(marker) == 1
    text = text.replace(marker, '''#[derive(serde::Deserialize)]
struct SignedDiagnosticIntegers {
    #[serde(default)]
    index: Option<i128>,
    #[serde(default)]
    resolved_index: Option<i128>,
}

''' + marker, 1)
    text = text.replace('fn signed_diagnostic_json_preserves_exact_integer_tokens()',
        'fn signed_diagnostic_typed_json_preserves_exact_integer_tokens()', 1)
    old = '''        let value: Value = serde_json::from_str(source).expect("valid signed diagnostic integer");
        let encoded = value.to_string();'''
    new = '''        let value: i128 = serde_json::from_str(source).expect("valid signed diagnostic integer");
        let encoded = serde_json::to_string(&value).expect("serialize signed diagnostic integer");
        let reconstructed: i128 = serde_json::from_str(&encoded).expect("decode diagnostic integer");
        assert_eq!(reconstructed, value);'''
    assert text.count(old) == 1
    text = text.replace(old, new, 1)
    fixture = json.loads(c.decode(before[FIXTURE]['base64']))
    revised = json.loads(json.dumps(fixture))
    for case in revised['cases']:
        if case['id'] == 'unsigned-magnitude-underflow':
            for field in ('index', 'resolved_index'):
                case['expected']['error'][field] = {'exact_integer': str(case['expected']['error'][field])}
    assert decoded(revised) == fixture, 'no semantic target change'
    c.source(TEST).write_text(text)
    c.source(FIXTURE).write_text(json.dumps(revised, ensure_ascii=False, indent=2) + '\n')
    c.write_new('observer-correction.json.gz', dict(before=before,
        after={path: c.read(path) for path in (TEST, FIXTURE)}, semantic_targets_unchanged=True,
        scope='Actual raw error strings remain retained. Generic JSON projection is diagnostic-only; exact wide integer fields deserialize as i128. The direct typed integer token test verifies the selected SDK route before any runtime edit.'))
    print('Original observer retained; exact semantic targets unchanged; typed SDK control prepared.')


if __name__ == '__main__':
    main()
