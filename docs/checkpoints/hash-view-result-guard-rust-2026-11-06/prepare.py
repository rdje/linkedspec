"""Prepare independent Hash-view public Rust intake without executing the SDK."""
import json
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-result-guard-rust-2026-11-06')
PREVIOUS = Path('docs/checkpoints/key-count-callable-rust-2026-11-06')
assert not (BASE / 'observer.rs').exists(), 'one-shot Rust intake preparation'
source = (PREVIOUS / 'observer.rs').read_text()
source = source.replace('CALLABLE_KEY_COUNT_RUST', 'HASH_VIEW_RUST')
source = source.replace('key_count_callable_rust_fresh', 'hash_view_result_rust_fresh')
source = source.replace('key-count-callable', 'hash-view-result')
(BASE / 'observer.rs').write_text(source)
# These are authored source programs only. No Perl outcomes/metadata are imported.
profiles = json.loads(Path('docs/checkpoints/hash-view-result-guard-perl-2026-11-06/profiles.json').read_bytes())
assert len(profiles) == 5 and all(row.get('profile_only') and 'expected' not in row for row in profiles)
(BASE / 'profile-sources.json').write_text(json.dumps(profiles, indent=2) + '\n')
source = (PREVIOUS / 'capture.py').read_text()
source = source.replace("BASE/'capture.py', BASE/'observer.rs', BASE/'freeze_profiles.py'",
    "BASE/'capture.py', BASE/'observer.rs', BASE/'freeze_profiles.py', BASE/'prepare.py', BASE/'profile-sources.json'")
needle = "# Explicitly include new/untracked direct consumers and fixture profiles."
assert source.count(needle) == 1
source = source.replace(needle, "paths += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]\n" + needle)
source = source.replace('rust/linkedspec-runtime/tests/key_count_callable_result_guard_composition.rs',
                        'rust/linkedspec-runtime/tests/hash_view_result_guard_composition.rs')
source = source.replace('tests/fixtures/key_count_callable_rust_profiles.json',
                        'tests/fixtures/hash_view_result_guard_rust_profiles.json')
source = source.replace('tests/fixtures/key_count_callable_result_cases.json',
                        'tests/fixtures/hash_view_result_guard_cases.json')
needle = "    assert len({r['id'] for r in cases}) == len(cases)"
assert source.count(needle) == 1
source = source.replace(needle, "    cases.extend(json.loads((BASE/'profile-sources.json').read_bytes()))\n" + needle)
source = source.replace('key-count-callable-rust-', 'hash-view-result-rust-')
source = source.replace("['key_count_result_guard_composition','user_function_parser_context_boundary']",
                        "['value_copy','constructor_result_composition']")
source = source.replace("['key_count_callable_result_guard_composition']",
                        "['hash_view_result_guard_composition']")
(BASE / 'capture.py').write_text(source)
print('Independent Rust shared15/profile5 sources, observer and pre-build grammar custody prepared')
