"""Recur the unchanged whole original draft reader on its actual saved inputs."""
import json
import subprocess
import sys
from pathlib import Path
from common_final import ROOT, PREFIX, OLD, load, original_fixture, sha, encode

assert sys.argv[1:] in ([], ['--capture'])
original = load()
with original_fixture(original) as (fixture, environment):
    command = ['python3', OLD + 'publish.py']
    run = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
    unchanged = all(sha((fixture / path).read_bytes()) == item['sha256'] and
                    (fixture / path).stat().st_mode & 0o7777 == item['mode']
                    for path, item in original['inputs'].items())
report = dict(command=command, returncode=run.returncode,
              stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr),
              original_inputs_unchanged=unchanged, input_count=625,
              claim_sha256=original['claim_sha256'],
              producer_sha256=sha(Path(__file__).read_bytes()),
              common_sha256=sha((ROOT / (PREFIX + 'common_final.py')).read_bytes()),
              scope='Actual unchanged readonly original publisher and its readers; complete625 saved '
                    'inputs/modes plus the real activation Perl/claim namespace. Read-only project '
                    'Git object access uses runtime-derived GIT_DIR/GIT_WORK_TREE and disables optional '
                    'locks. No native/capture writer or current runtime is executed.')
target = ROOT / (PREFIX + 'replay-final.json')
if sys.argv[1:]:
    with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
assert run.returncode == 0 and not run.stderr and unchanged, report
assert run.stdout == b'Pipeline invocation publication PASS: 625 live inputs; 123401 bytes\n'
print('Original uncommitted whole625/full123401 readonly replay PASS')
