"""Compose a new dated review from accepted sources; never replay old writers."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
TEMPLATE = Path('docs/checkpoints/artifact-review-2026-11-07')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'b3ab04a22019bd8e95fcba47d278b95bb401d709'
assert not (HERE / 'review.py').exists(), 'one-shot composition'
identities = {}
for name in ('review.py', 'run.py'):
    path = TEMPLATE / name
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', 'HEAD:' + str(path)])
    (HERE / ('template-' + name + '.gz')).write_bytes(gzip.compress(body, mtime=0))
    identities[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
    source = body.decode().replace('2026-11-07', '2026-11-16').replace('1.2.23.4.15', '1.2.23.4.33')
    if name == 'review.py':
        anchor = "    spec = importlib.util.spec_from_file_location('artifact_census', ROOT / HELPER)"
        insertion = """    # Preserve actual direct source bytes and modes before importing or scanning.
    sources = (*PRODUCERS, Path(__file__).relative_to(ROOT).as_posix())
    retained = {name: packet((ROOT / name).read_bytes()) for name in sources}
    modes = {name: (ROOT / name).stat().st_mode & 0o777 for name in sources}
"""
        assert source.count(anchor) == 1
        source = source.replace(anchor, insertion + anchor)
        source = source.replace("'producers': {name: packet((ROOT / name).read_bytes()) for name in sources},", "'producers': retained, 'producer_modes': modes,")
        source = source.replace('    validate(report)\n    report[', "    assert all(packet((ROOT / name).read_bytes()) == image for name, image in retained.items())\n    assert all((ROOT / name).stat().st_mode & 0o777 == mode for name, mode in modes.items())\n    validate(report)\n    report[")
    (HERE / name).write_text(source)
(HERE / 'composition.json').write_text(json.dumps(dict(templates=identities, activation='b3ab04a22019bd8e95fcba47d278b95bb401d709'), indent=2) + '\n')
print('composed new review; accepted template bodies retained')
