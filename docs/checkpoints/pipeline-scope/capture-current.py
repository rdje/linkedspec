"""Capture the unchanged2065 fixture against the lossless current JSON view."""
import json
import os
import re
import subprocess
from pathlib import Path
from common_final import ROOT, PREFIX, OLD, NATIVE, load, verify_native, sha, encode, decode

original = load()
verify_native(original)
runtime = json.loads(decode(original['inputs'][OLD + 'runtime.json']['base64']))
before, changed = {}, []
for path, item in runtime['inputs'].items():
    source = ROOT / path
    value = source.read_bytes()
    before[path] = dict(sha256=sha(value), mode=source.stat().st_mode & 0o7777)
    if before[path] != item:
        changed.append(path)
assert len(before) == 426 and changed == [NATIVE], ('only native transport changes', changed)
environment = os.environ.copy()
environment.update(PERL5LIB='', PERL5OPT='')
command = ['prove', '-v', '-Iperl', 't/actionir_factory_capture.t']
run = subprocess.run(command, cwd=ROOT, env=environment, capture_output=True)
unchanged = all(sha((ROOT / path).read_bytes()) == item['sha256'] and
                (ROOT / path).stat().st_mode & 0o7777 == item['mode'] for path, item in before.items())
report = dict(command=command, returncode=run.returncode,
              stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr),
              input_count=426, inputs=before, changed_from_original=changed,
              current_view_base64=encode((ROOT / NATIVE).read_bytes()), inputs_unchanged=unchanged,
              producer_sha256=sha(Path(__file__).read_bytes()),
              scope='Actual current fixture, separate channels,426 pre-run input identities;425 exact '
                    'original bytes/modes recover through the complete saved draft and its runtime '
                    'capsule, and the sole changed JSON view is saved whole. No native oracle or '
                    'original runtime/source-fault capture is refreshed.')
with (ROOT / (PREFIX + 'current-runtime.json')).open('x') as output:
    output.write(json.dumps(report, indent=1) + '\n')
assert run.returncode == 0 and not run.stderr and unchanged, report
assert re.findall(rb'^1\.\.(\d+)\s*$', run.stdout, re.M) == [b'2065']
assert not re.search(rb'^not ok\b', run.stdout, re.M)
assert [int(value) for value in re.findall(rb'^ok (\d+)\b', run.stdout, re.M)] == list(range(1, 2066))
assert re.findall(rb'^Files=(\d+), Tests=(\d+),', run.stdout, re.M) == [(b'1', b'2065')]
print('Current solidus transport fixture PASS:2065 assertions;426 inputs;only one data encoding change')
