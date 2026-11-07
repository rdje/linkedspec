"""Preserve failed writer/old-source acquisition; prospectively anchor exact lines."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
original = (BASE / 'repair.py').read_bytes()
source = original.decode()
old = "    assert source.count(needle) == 1\n    addition = "
new = "    assert source.count('\\n' + needle) == 1\n    addition = "
assert source.count(old) == 1
source = source.replace(old, new)
old = "    source = source.replace(needle, ''.join(indent + line + '\\n' for line in addition.splitlines()) + needle)"
new = "    source = source.replace('\\n' + needle, '\\n' + ''.join(indent + line + '\\n' for line in addition.splitlines()) + needle)"
assert source.count(old) == 1
source = source.replace(old, new)
qualified = BASE / 'repair_qualified.py'
assert not qualified.exists()
qualified.write_text(source)
capture = (BASE / 'capture_qualified.py').read_text()
needle = "('after', 'routes'),"
assert capture.count(needle) == 1
capture = capture.replace(needle, "('after', 'routes'), ('repaired-after', 'routes'),")
assert not (BASE / 'capture_repaired.py').exists()
(BASE / 'capture_repaired.py').write_text(capture)
event = dict(owner='TYPE-REFERENCE-BOOK.1.2.23.3.78.2',
    defect='First repair.py asserts before any owner write: an eight-space substring also matches the sixteen-space line. The shell lacked fail-fast and started after acquisition with unchanged old SDK.',
    resolution='Keep original repair/after instruments/channels/inputs. Qualified writer anchors full line starts; production follows only after old-source capture finishes. Guard dependent launches by explicit successful completion.',
    original_sha256=hashlib.sha256(original).hexdigest(),
    qualified_sha256=hashlib.sha256(qualified.read_bytes()).hexdigest(),
    capture_sha256=hashlib.sha256((BASE / 'capture_repaired.py').read_bytes()).hexdigest())
(BASE / 'writer-qualification.json').write_text(json.dumps(event, indent=2) + '\n')
print('separate anchored writer and repaired-after epoch prepared; original failure unchanged')
