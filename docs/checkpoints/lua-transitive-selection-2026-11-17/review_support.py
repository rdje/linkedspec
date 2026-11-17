"""Add Bash-channel recovery through a separate, fully retained reader body."""
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
identities = json.loads((BASE / 'support-identities.json').read_bytes())
with tarfile.open(BASE / 'support-inputs.tar.gz') as archive:
    assert len(archive.getmembers()) == len(identities) == 2
    for member in archive:
        assert member.isfile() and member.name in identities
        body = archive.extractfile(member).read()
        row = identities[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert stat.S_IMODE(member.mode) == row['mode']
        assert Path(member.name).read_bytes() == body and stat.S_IMODE(Path(member.name).stat().st_mode) == row['mode']
spec = importlib.util.spec_from_file_location('frozen_lua_selection', BASE / 'review.py')
original = importlib.util.module_from_spec(spec)
spec.loader.exec_module(original)
sources, _ = original.recover()
derived = json.loads((BASE / 'support-derivation.json').read_bytes())
body = sources[str(BASE / 'review.py')].decode()
assert (BASE / 'review.py').read_text() == body
for before, after in derived['replacements']:
    assert body.count(before) == 1
    body = body.replace(before, after, 1)
assert body == derived['derived_source'], 'full support reader bytes'
module = dict(__file__=str(BASE / 'review.py'), __name__='retained_lua_selection_support')
exec(compile(body, str(BASE / 'review.py'), 'exec'), module)
module['main']()
