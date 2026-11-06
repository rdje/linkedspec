"""Prepare independent four-route GREEN acquisition for all unchanged22 sources."""
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-result-guard-rust-2026-11-06')
target = BASE / 'capture_after.py'
assert not target.exists(), 'one-shot GREEN producer preparation'
source = (BASE / 'capture.py').read_text()
source = source.replace("assert phase in ('intake', 'normal', 'direct')", "assert phase == 'after-intake'")
source = source.replace("if phase == 'intake':", "if phase == 'after-intake':")
needle = "paths += [BASE/'capture.py', BASE/'observer.rs', BASE/'freeze_profiles.py', BASE/'prepare.py', BASE/'profile-sources.json']"
assert source.count(needle) == 1
source = source.replace(needle, needle + "\npaths += [BASE/'capture_after.py', BASE/'prepare_after.py', BASE/'receiver-profile-sources.json']")
needle = "    assert len({r['id'] for r in cases}) == len(cases)"
assert source.count(needle) == 1
source = source.replace(needle, "    cases.extend(json.loads((BASE/'receiver-profile-sources.json').read_bytes()))\n" + needle)
target.write_text(source)
print('Separate actual four-route GREEN capture prepared; original intake epochs unchanged')
