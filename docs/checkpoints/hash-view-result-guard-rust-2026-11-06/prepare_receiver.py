"""Acquire two initial-receiver source-policy fences before changing result roles."""
import json
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-result-guard-rust-2026-11-06')
target = BASE / 'capture_receiver.py'
assert not target.exists(), 'one-shot receiver-profile preparation'
rows = []
for identifier, body in (
    ('receiver_input_profile', 'return([3.sorted_values(),undef.sorted_values(),[1].sorted_values(),3.sorted_keys(),undef.sorted_keys(),[1].sorted_keys(),{"b":2,"a":1}.sorted_values()])'),
    ('receiver_null_with_profile', 'order="";out=undef.sorted_values().with(){order=cat(order,"W");return(value.count())};return([out,order])'),
):
    rows.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
                     input='x', rule='Value', profile_only=True))
(BASE / 'receiver-profile-sources.json').write_text(json.dumps(rows, indent=2) + '\n')
source = (BASE / 'capture.py').read_text()
source = source.replace("assert phase in ('intake', 'normal', 'direct')", "assert phase == 'receiver-intake'")
source = source.replace("if phase == 'intake':", "if phase == 'receiver-intake':")
needle = "paths += [BASE/'capture.py', BASE/'observer.rs', BASE/'freeze_profiles.py', BASE/'prepare.py', BASE/'profile-sources.json']"
assert source.count(needle) == 1
source = source.replace(needle, needle + "\npaths += [BASE/'capture_receiver.py', BASE/'prepare_receiver.py', BASE/'receiver-profile-sources.json']")
start = source.index('    cases = []\n')
end = source.index("    assert len({r['id'] for r in cases})", start)
source = source[:start] + "    cases = json.loads((BASE/'receiver-profile-sources.json').read_bytes())\n" + source[end:]
target.write_text(source)
print('Two initial receiver source/with policy controls prepared before runtime edits')
