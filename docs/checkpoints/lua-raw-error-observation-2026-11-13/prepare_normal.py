"""Publish exact retained source questions and each host's old field baseline."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
paths = {
    BASE / 'cases.json': Path('tests/fixtures/lua_raw_error_observation_cases.json'),
    BASE / 'analysis/old-profiles.json': Path('tests/fixtures/lua_raw_error_observation_profiles.json'),
}
assert all(not target.exists() for target in paths.values())
self_body = Path(__file__).read_bytes()
(BASE / 'prepare-normal-before-use.py.gz').write_bytes(gzip.compress(self_body, mtime=0))
sources = {source.name: dict(bytes=source.stat().st_size, sha256=hashlib.sha256(source.read_bytes()).hexdigest()) for source in paths}
(BASE / 'normal-preparation-inputs.json').write_text(json.dumps(sources, indent=2, sort_keys=True) + '\n')
for source, target in paths.items():
    body = source.read_bytes()
    assert hashlib.sha256(body).hexdigest() == sources[source.name]['sha256']
    target.write_bytes(body)
    assert target.read_bytes() == body
print('Published exact source questions and independently validated old per-host profiles; no SDK execution')
