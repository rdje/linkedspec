"""Retain actual formatter inputs/channels and output identities."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
paths = ['lib/src/runtime/interpreter.dart',
         'test/array_transform_result_guard_composition_test.dart',
         'tool/probe_array_transform_results.dart']
before = {}
for index, name in enumerate(paths):
    body = (Path('dart') / name).read_bytes()
    target = BASE / ('formatter-input-' + str(index) + '.dart.gz')
    assert not target.exists()
    target.write_bytes(gzip.compress(body, mtime=0))
    before['dart/' + name] = dict(sha256=hashlib.sha256(body).hexdigest(), archive=target.name)
packet = dict(cwd='dart', argv=['bash', '../tools/run_dart_project_data.sh', 'format', *paths],
              environment=dict(TERM='dumb', NO_COLOR='1'))
(BASE / 'formatter-command.json').write_text(json.dumps(packet, indent=2) + '\n')
result = subprocess.run(packet['argv'], cwd=packet['cwd'],
                        env=dict(os.environ, **packet['environment']),
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('formatter-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'formatter-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0
after = {name: hashlib.sha256(Path(name).read_bytes()).hexdigest() for name in before}
(BASE / 'formatter-identities.json').write_text(json.dumps(dict(before=before, after=after), indent=2) + '\n')
print(result.stdout.decode(), end='')
