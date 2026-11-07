"""Preserve original capture; explicitly include the new untracked include_str input."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
original = (BASE / 'capture.py').read_bytes()
source = original.decode()
source = source.replace("('before', 'test'),", "('before', 'test'), ('qualified-before', 'test'),")
source = source.replace("paths += [p for p in (NORMAL, PROFILE) if p.exists()]",
                        "paths += [p for p in (NORMAL, PROFILE, Path('tests/fixtures/array_transform_optional_result_guard_cases.json')) if p.exists()]")
source = source.replace("phase in ('before', 'private-old')", "phase in ('before', 'qualified-before', 'private-old')")
assert source != original.decode()
qualified = BASE / 'capture_qualified.py'
assert not qualified.exists()
qualified.write_text(source)
event = dict(owner='TYPE-REFERENCE-BOOK.1.2.23.3.78.2',
    defect='Original before root archive omitted the new untracked include_str optional fixture path. All195 semantic frames survive; no complete first-normal custody credit.',
    repair='Explicit fixture in separate qualified-before and all subsequent first-use captures; original capture/before untouched.',
    original_sha256=hashlib.sha256(original).hexdigest(), qualified_sha256=hashlib.sha256(qualified.read_bytes()).hexdigest())
(BASE / 'capture-qualification.json').write_text(json.dumps(event, indent=2) + '\n')
print('separate prospective capture adds actual optional fixture before build; original epoch preserved')
