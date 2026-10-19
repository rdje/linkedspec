"""Freeze the complete existing proof-file namespace before later artifact controls/publication."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
target = ROOT / (PREFIX + 'current-input-roster.json')
assert not target.exists() and not (ROOT / (PREFIX + 'current-review.json')).exists()
paths = {path.relative_to(ROOT).as_posix() for path in (ROOT / PREFIX).iterdir() if path.is_file()}
paths.add(PREFIX + 'current-input-roster.json')
assert all(not (ROOT / path).is_symlink() for path in paths)
with target.open('x') as output: output.write(json.dumps(sorted(paths), indent=1) + '\n')
print('Current proof namespace retained:', len(paths), 'files; later controls/publication have separate owners')
