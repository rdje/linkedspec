"""Check the explicit pre-staging input point; no SDK or old producer replay."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
rows = json.loads((BASE / 'normal/input-identities.json').read_bytes())
for name, expected in rows.items():
    path = Path(name)
    assert not path.is_absolute() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    assert dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777) == expected, name
assert subprocess.run(['git', 'diff', '--quiet', '--', 'lua/src']).returncode == 0
assert subprocess.run(['git', 'diff', '--quiet', '--', 'docs/claims']).returncode == 0
html = Path('docs/linkedspec-book/book/appendix/runtime-semantics.html').read_text()
assert 'id="1021-lua-native-fields-and-generated-error-envelopes"' in html
assert 'public.identifier == nil and public.expected_kind == nil' in html
memory = Path('MEMORY.md').read_text()
assert 'do not resume PNT without an explicit request' in memory
assert 'active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.4.28` (completed)' in memory
print(json.dumps(dict(current='PASS', input_identities=len(rows), production_sdk_unchanged=True,
    rendered_book_section=True, stopped_handoff=True,
    scope='This actual pre-staging point only, not future freshness or native/physical closure. Private inputs stay protected; default historical recovery needs no live private workspace.')))
