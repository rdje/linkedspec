"""Match the narrow probe's own declared wrapper closure; preserve both readers."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
source = BASE / 'review_qualified.py'
target = BASE / 'review_qualified2.py'
assert not target.exists()
failed = BASE / 'launches/first-qualified-review'
assert (failed / 'exit.txt').read_text() == '1\n'
stderr = gzip.decompress((failed / 'stderr.log.gz').read_bytes())
assert b"KeyError: 'tools/run_lua_project_data.sh'" in stderr and b'equal(probe_inputs[name], expected_body)' in stderr
probe = json.loads((BASE / 'fieldprobe/input-identities.json').read_bytes())
trace = json.loads((BASE / 'trace/input-identities.json').read_bytes())
omitted = {'tools/run_lua_project_data.sh', 'tools/run_python_project_data.sh'}
assert {name for name in trace if name.startswith('tools/')} - {name for name in probe if name.startswith('tools/')} == omitted
old = '        equal(probe_inputs[name], expected_body)\n'
new = '''        if name in probe_inputs:
            equal(probe_inputs[name], expected_body)
        else:
            assert name in ('tools/run_lua_project_data.sh', 'tools/run_python_project_data.sh')
'''
body = source.read_text()
assert body.count(old) == 1
target.write_text(body.replace(old, new))
(BASE / 'probe-input-qualification.json').write_text(json.dumps(dict(
    original=source.name, original_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
    qualified=target.name, qualified_sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
    original_actual_exit=1, original_stderr_bytes=len(stderr), original_stderr_sha256=hashlib.sha256(stderr).hexdigest(),
    cause='The narrow field probe used project_data_run directly and retained its three actual wrapper inputs; it never used the other two epoch convenience wrappers. The reader incorrectly required all five.',
    correction='Permit only those two unused wrapper absences in fieldprobe. Keep every own Lua/fixture/grammar and all actual wrapper byte/mode checks. No SDK replay, capture expansion or missing-input custody credit.'), indent=2) + '\n')
print('Qualified narrow probe wrapper census; both original actual1 readers remain unchanged')
