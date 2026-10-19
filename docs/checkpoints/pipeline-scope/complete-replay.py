"""Recur the original reader with guards for every supplied overlay and claim input."""
import gzip
import json
import subprocess
import sys
from pathlib import Path
from common_final import ROOT, PREFIX, OLD, CLAIM, load, load_namespace, original_fixture, sha, encode, decode

assert sys.argv[1:] in ([], ['--capture'])
original = load()
namespace = load_namespace(original)
supplied = dict(original['inputs'], **namespace['inputs'])
assert len(supplied) == 786
standard = json.loads(gzip.decompress((ROOT / (
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-standard-verification.json.gz')).read_bytes()))
claim_mode = next(item['mode'] for item in standard['sources'] if item['path'] == CLAIM)
with original_fixture(original) as (fixture, environment):
    command = ['python3', OLD + 'publish.py']
    run = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
    unchanged = all(sha((fixture / path).read_bytes()) == item['sha256'] and
                    (fixture / path).stat().st_mode & 0o7777 == item['mode'] for path, item in supplied.items())
    claim_unchanged = (fixture / CLAIM).read_bytes() == decode(original['claim_base64']) and (
        (fixture / CLAIM).stat().st_mode & 0o7777 == claim_mode)
report = dict(command=command, returncode=run.returncode,
              stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr),
              original_declared_inputs=625, supplied_namespace=161, guarded_overlay_count=786,
              fixed_git_scopes=['perl', 'docs/claims'], claim_sha256=original['claim_sha256'],
              all_overlay_bytes_and_modes_unchanged=unchanged, whole_claim_and_mode_unchanged=claim_unchanged,
              producer_sha256=sha(Path(__file__).read_bytes()),
              scope='Actual unchanged original readonly publisher over complete supplied overlays and '
                    'fixed real activation Git scopes. All786 overlay byte streams/actual modes and '
                    'the original whole claim/mode are guarded after execution. No native writer or '
                    'uncommitted-draft Git revision is used.')
target = ROOT / (PREFIX + 'complete-replay.json')
if sys.argv[1:]:
    with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
else: assert json.loads(target.read_bytes()) == report
assert run.returncode == 0 and not run.stderr and unchanged and claim_unchanged, report
assert run.stdout == b'Pipeline invocation publication PASS: 625 live inputs; 123401 bytes\n'
print('Complete supplied original-reader replay PASS:786 overlays and whole claim guarded')
