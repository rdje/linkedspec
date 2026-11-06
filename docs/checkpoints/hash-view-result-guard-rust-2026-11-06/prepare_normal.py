"""Freeze the two measured receiver fences and prepare a maintained Rust normal."""
import json
from pathlib import Path
import re

BASE = Path('docs/checkpoints/hash-view-result-guard-rust-2026-11-06')
normal = Path('rust/linkedspec-runtime/tests/hash_view_result_guard_composition.rs')
assert not normal.exists(), 'one-shot maintained normal preparation'
fixture = Path('tests/fixtures/hash_view_result_guard_rust_profiles.json')
profiles = json.loads(fixture.read_bytes())
original_cases = json.loads((BASE / 'intake/cases.json').read_bytes())
for case in original_cases:
    if case['id'] in profiles:
        profiles[case['id']]['input'] = case['input']
        profiles[case['id']]['profile_only'] = bool(case.get('profile_only'))
rows, fresh = {}, {}
for name, prefix, target in (('native-stdout.log', 'HASH_VIEW_RUST', rows),
                              ('fresh-stdout.log', 'HASH_VIEW_RUST_FRESH', fresh)):
    for line in (BASE / 'receiver-intake' / name).read_text().splitlines():
        match = re.match('^' + prefix + r' ([a-z0-9_]+) (.*)$', line)
        if match:
            assert match[1] not in target
            target[match[1]] = json.loads(match[2])
receiver_cases = json.loads((BASE / 'receiver-intake/cases.json').read_bytes())
assert list(rows) == list(fresh) == [case['id'] for case in receiver_cases]
for case in receiver_cases:
    identifier = case['id']
    assert identifier not in profiles and 'preparation_error' not in rows[identifier]
    profiles[identifier] = dict(source=case['source'], input=case['input'], profile_only=True,
                                **rows[identifier], fresh=fresh[identifier])
fixture.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
source = Path('rust/linkedspec-runtime/tests/key_count_callable_result_guard_composition.rs').read_text()
source = source.replace('TYPE-REFERENCE-BOOK.1.2.23.3.75.6.2', 'TYPE-REFERENCE-BOOK.1.2.23.3.76.2')
source = source.replace('function-result CountKeys preservation', 'ordinary Hash-view result guards')
source = source.replace('CountKeys', 'Hash-view')
source = source.replace('key-count-callable-result-composition.spec', 'hash-view-result-assessment.spec')
source = source.replace('key_count_callable_result_cases.json', 'hash_view_result_guard_cases.json')
source = source.replace('key_count_callable_rust_profiles.json', 'hash_view_result_guard_rust_profiles.json')
source = source.replace('CALLABLE_KEY_COUNT_RUST_NORMAL', 'HASH_VIEW_RUST_NORMAL')
source = source.replace('callable_key_count_cases', 'hash_view_cases')
source = source.replace('let cases: Vec<Value>', 'let mut cases: Vec<Value>')
needle = '    let row = cases.iter().find(|row| row["id"] == label).unwrap();'
assert source.count(needle) == 1
source = source.replace(needle, '''    for (id, profile) in profiles.as_object().unwrap() {
        if profile["profile_only"].as_bool() == Some(true) {
            cases.push(serde_json::json!({
                "id": id, "source": profile["source"], "input": profile["input"],
            }));
        }
    }
''' + needle)
start = source.index('hash_view_cases! {')
cases = original_cases + receiver_cases
assert len(cases) == len({case['id'] for case in cases}) == 22
source = source[:start] + 'hash_view_cases! {\n' + ''.join('    ' + case['id'] + ',\n' for case in cases) + '}\n'
normal.write_text(source)
source = (BASE / 'capture.py').read_text()
source = source.replace("assert phase in ('intake', 'normal', 'direct')",
                        "assert phase in ('normal-before', 'normal-after', 'direct')")
needle = "paths += [BASE/'capture.py', BASE/'observer.rs', BASE/'freeze_profiles.py', BASE/'prepare.py', BASE/'profile-sources.json']"
assert source.count(needle) == 1
source = source.replace(needle, needle + "\npaths += [BASE/'capture_test.py', BASE/'prepare_normal.py', BASE/'prepare_receiver.py', BASE/'receiver-profile-sources.json']")
source = source.replace("run('normal',arguments,(0,101) if False else (0,))",
                        "run('normal',arguments,(101,) if phase == 'normal-before' else (0,))")
(BASE / 'capture_test.py').write_text(source)
print('Own seven source/arity profiles plus required-error profile frozen; unchanged22 normal prepared')
