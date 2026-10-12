"""One-shot source fault controls through the unchanged actual public checker fixture."""
import base64
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-'
SOURCE = 'knowledge-map/scripts/check_knowledge_map.sh'
target = ROOT / (PREFIX + 'faults-final.json')
assert not target.exists(), 'one-shot source fault proof'
path = ROOT / SOURCE
original = path.read_bytes()
sha = lambda raw: hashlib.sha256(raw).hexdigest()
faults = [
    ('scalar-keeps-list-owner', b'curkey=(rest=="" ? key : "")', b'curkey=key', 14),
    ('malformed-answers-hidden', b'(!hasans && !(anskey && orphan!=""))', b'!hasans', 2),
    ('orphan-verdict-disabled', b'[ -n "$orphan" ] && note ', b'[ -n "" ] && note ', 16),
]
rows = []
try:
    for name, old, new, count in faults:
        assert original.count(old) == 1, ('exact fault source', name)
        damaged = original.replace(old, new, 1)
        path.write_bytes(damaged)
        commands = []
        for command in (['bash', '-n', SOURCE], ['perl', 't/knowledge_map_header_lists.t', '--observe'],
                        ['prove', '-v', 't/knowledge_map_header_lists.t']):
            result = subprocess.run(command, cwd=ROOT, capture_output=True)
            commands.append({'command': command, 'returncode': result.returncode,
                'stdout_base64': base64.b64encode(result.stdout).decode(),
                'stderr_base64': base64.b64encode(result.stderr).decode()})
        tap = base64.b64decode(commands[2]['stdout_base64']).decode()
        failures = re.findall(r'^not ok (\d+) - (.*)$', tap, re.M)
        rows.append({'name': name, 'source_base64': base64.b64encode(damaged).decode(),
            'sha256': sha(damaged), 'commands': commands, 'failures': failures})
        target.write_text(json.dumps({'result': 'pending', 'rows': rows}, indent=2) + '\n')
        assert commands[0]['returncode'] == commands[1]['returncode'] == 0
        assert commands[2]['returncode'] != 0 and len(failures) == count, (name, failures)
        assert re.search(r'^1\.\.80$', tap, re.M)
        assert len(re.findall(r'^(?:not )?ok \d+ - ', tap, re.M)) == 80
        path.write_bytes(original)
        assert path.read_bytes() == original, 'exact immediate restoration'
finally:
    path.write_bytes(original)
assert path.read_bytes() == original
command = ['prove', '-v', 't/knowledge_map_header_lists.t']
result = subprocess.run(command, cwd=ROOT, capture_output=True)
restored = {'command': command, 'returncode': result.returncode,
    'stdout_base64': base64.b64encode(result.stdout).decode(), 'stderr_base64': base64.b64encode(result.stderr).decode()}
assert result.returncode == 0 and not re.search(rb'^not ok ', result.stdout, re.M)
report = {'result': 'PASS', 'source_sha256': sha(original), 'producer_sha256': sha(Path(__file__).read_bytes()),
    'fixture_sha256': sha((ROOT / 't/knowledge_map_header_lists.t').read_bytes()), 'rows': rows, 'restored': restored}
target.write_text(json.dumps(report, indent=2) + '\n')
print('Knowledge source controls PASS: 14/2/16 actual REDs; full 80-assertion plans; exact restoration GREEN')
