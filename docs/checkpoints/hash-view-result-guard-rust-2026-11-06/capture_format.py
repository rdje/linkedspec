"""One-shot scoped readonly formatting proof for the actual final owner/normal."""
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OUT = BASE / 'format'
OUT.mkdir()
paths = [Path('rust/linkedspec-runtime/src/engine.rs'),
         Path('rust/linkedspec-runtime/tests/hash_view_result_guard_composition.rs')]
before = {str(path): path.read_bytes() for path in paths}
(OUT / 'input-identities.json').write_text(json.dumps({path: dict(
    sha256=hashlib.sha256(body).hexdigest(), bytes=len(body)) for path, body in before.items()}, indent=2) + '\n')
command = ['rustfmt', '--edition', '2024', '--check', *map(str, paths)]
(OUT / 'command.json').write_text(json.dumps(command, indent=2) + '\n')
with (OUT / 'stdout.log').open('xb') as stdout, (OUT / 'stderr.log').open('xb') as stderr:
    result = subprocess.run(command, stdout=stdout, stderr=stderr)
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and all(Path(path).read_bytes() == body for path, body in before.items())
print('Actual owner/normal scoped format PASS; source bytes unchanged')
