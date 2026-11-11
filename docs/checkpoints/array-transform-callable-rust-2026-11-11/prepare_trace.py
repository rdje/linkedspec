"""Prepare seven public trace contrasts before selecting a production repair."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
assert not (BASE / 'capture_trace.py').exists()

def template(index):
    text = gzip.decompress((BASE / ('template-' + str(index) + '.gz')).read_bytes()).decode()
    return (text.replace('7e99813d1a88b748cf310992a4ef6ffadf7e978f', '238da4cc727e9f5921990ef5e8575b45ceac2887')
        .replace('array-pipeline-callable-rust-2026-11-11', BASE.name)
        .replace('array-pipeline-callable', 'array-transform-callable')
        .replace('callable-pipeline', 'callable-transform')
        .replace('CALLABLE_PIPELINE', 'CALLABLE_TRANSFORM'))

capture = template(4)
start = capture.index('    ids = {')
end = capture.index('    cases = ', start)
ids = {'take_receiver_hash_guard', 'take_later_with', 'reverse_copy_later_with',
    'drop_logical_later_with', 'initial_number_composed',
    'own_signature_variadic_multi_composed', 'source_effect_before_rejection'}
cases = json.loads((BASE / 'cases.json').read_bytes())
assert len(ids) == 7 and ids <= {case['id'] for case in cases}
capture = capture[:start] + '    ids = ' + repr(ids) + '\n' + capture[end:]
capture = capture.replace("list((OUT / 'inputs').glob('*.json'))", "list((OUT / 'inputs').glob('*.json')) + list((OUT / 'parsed-inputs').glob('*.json'))")
(BASE / 'capture_trace.py').write_text(capture)
observer = template(5)
anchor = '        validate(&parsed).unwrap();\n'
assert observer.count(anchor) == 1
snapshot = '''        let parsed_bytes = serde_json::to_vec(&parsed).unwrap();
        fs::create_dir_all(output.join("parsed-inputs")).unwrap();
        let parsed_path = output.join("parsed-inputs").join(format!("{id}.json"));
        assert!(!parsed_path.exists());
        fs::write(&parsed_path, &parsed_bytes).unwrap();
        assert_eq!(fs::read(&parsed_path).unwrap(), parsed_bytes);
        println!("CALLABLE_TRANSFORM_TRACE_PARSED_INPUT {id} {}", json!({"parsed": String::from_utf8(parsed_bytes).unwrap()}));
'''
observer = observer.replace(anchor, snapshot + anchor)
(BASE / 'trace_observer.rs').write_text(observer)
print('Prepared seven public trace contrasts with parsed snapshots before compile; no SDK invoked')
