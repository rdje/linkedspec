"""Retain the exact failed staged candidate and disclose the unavailable full log."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
sha = lambda value: hashlib.sha256(value).hexdigest()
target = ROOT / (PREFIX + 'canonical-attempt01.json')
assert not target.exists(), 'one-shot failed-candidate custody'
base = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
candidate = subprocess.check_output(['git', 'diff', '--cached', '--full-index', '--binary', '--no-ext-diff', '--no-color'], cwd=ROOT)
assert base == '736c6a43efab526fe898ed5c72b061479955fc5c'
assert sha(candidate) == '6b45e0e6b474772f8076223e124b467462fde6a688c4f130bcaf9520cdb6ce08', 'exact first measured staged candidate'
compressed = gzip.compress(candidate, mtime=0)
with (ROOT / (PREFIX + 'canonical-candidate01.diff.gz')).open('xb') as output:
    output.write(compressed)
controls_raw = (ROOT / (PREFIX + 'canonical-environment-controls.json')).read_bytes()
controls = json.loads(controls_raw)
assert controls['restricted']['exit_code'] == 71 and controls['host']['exit_code'] == 0
assert controls['restricted']['output'] == 'sandbox-exec: sandbox_apply: Operation not permitted\n'
assert controls['host']['output'] == ''
excerpt = (b'sandbox-exec: sandbox_apply: Operation not permitted\n'
           b'[project-data-process-test] ERROR: representative relocated driver failed with status 71\n')
record = dict(command=['bash','tools/run_ci_local.sh'], observed_exit_code=1,
    observed_tool_chunk='54169b', base=base, staged_diff_sha256=sha(candidate), staged_diff_bytes=len(candidate),
    candidate_capsule=PREFIX+'canonical-candidate01.diff.gz', candidate_capsule_sha256=sha(compressed),
    producer_sha256=sha(Path(__file__).read_bytes()),
    gate_source_sha256=sha((ROOT/'tools/run_ci_local.sh').read_bytes()),
    environment_controls_sha256=sha(controls_raw),
    retained_error_excerpt_base64=base64.b64encode(excerpt).decode(),
    full_log_available=False,
    scope=('Actual failed canonical attempt: all ten doctrines passed before later process-containment '
        'initialization failed under the restricted harness. Its full log was incorrectly placed in managed '
        'disposable TMPDIR, so normal failure cleanup removed it; the terminal returned only its tail '
        'and that tool output was truncated. This record retains only the exact observed two-line error '
        'excerpt and exact original staged candidate, not an invented full channel or successful receipt. '
        'The existing Knowledge card documents approved host execution. Actual no-op controls reproduce71 '
        'inside/0 outside. Repair owner PERL-PRIVATE-FACTORY-CAPTURE.5.1.3 reruns the unchanged complete '
        'gate after staging this disclosure, under approved host execution, with persistent same-volume '
        'logging and failed-run retention. The first attempt and original focused observations are not refreshed.'))
target.write_text(json.dumps(record,indent=2)+'\n')
print('Failed canonical candidate retained; full-log limit disclosed; host prerequisite independently confirmed')
