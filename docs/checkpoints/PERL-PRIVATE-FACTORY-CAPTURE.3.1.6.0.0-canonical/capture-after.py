"""One-shot capture of the exact CI inverse and isolated historical audit proof."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
TARGET = HERE / 'after.json'
assert not TARGET.exists(), 'original observation already retained'
BASE = json.loads((HERE / 'attempt-02.json').read_bytes())['base_head']
RUNNER = 'tools/run_ci_local.sh'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
insertions = (
    (b'require_tracked_file t/uniform_binding_contract.t\n',
     b'require_tracked_file t/actionir_receiver_scalar_copy.t\n'
     b'require_tracked_file t/actionir_receiver_scalar_copy_probe.pl\n'),
    (b'perl -c -Iperl t/actionir_ast_parser.t\n',
     b'perl -c -Iperl t/actionir_receiver_scalar_copy.t\n'
     b'perl -c -Iperl t/actionir_receiver_scalar_copy_probe.pl\n'),
    (b'prove -Iperl t/actionir_ast_parser.t\n',
     b'\nlog "running scalar receiver-copy regression suite"\n'
     b'prove -Iperl t/actionir_receiver_scalar_copy.t\n'),
)
expected = subprocess.check_output(['git', 'show', BASE + ':' + RUNNER], cwd=ROOT)
for anchor, insertion in insertions:
    assert expected.count(anchor) == 1
    expected = expected.replace(anchor, anchor + insertion, 1)
assert expected == (ROOT / RUNNER).read_bytes(), 'CI changes exceed the three owned insertions'
command = ['bash', 'tools/run_python_project_data.sh', PROOF]
result = subprocess.run(command, cwd=ROOT, capture_output=True)
channels = {'command': command, 'returncode': result.returncode,
            'stdout_base64': base64.b64encode(result.stdout).decode(),
            'stderr_base64': base64.b64encode(result.stderr).decode()}
if result.returncode:
    (HERE / 'after-failure.json').write_text(json.dumps(channels, indent=2) + '\n')
    raise AssertionError('historical proof failed; complete channels retained')
report = json.loads(result.stdout)
assert report['healthy_audit_guard'] == {'original_log_attempts': 0, 'tracked_write_attempts': 0}
paths = set(report['tracked_inputs']) | {
    RUNNER, 'tests/language-readiness/verify_objectives.py',
    'tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh',
    Path(__file__).relative_to(ROOT).as_posix(),
}
paths.update(p.relative_to(ROOT).as_posix() for p in HERE.iterdir() if p.is_file())
inputs = {path: {'sha256': digest((ROOT / path).read_bytes()),
                 'data': base64.b64encode((ROOT / path).read_bytes()).decode()}
          for path in sorted(paths)}
assert all(inputs[p]['sha256'] == h for p, h in report['tracked_inputs'].items())
raw = (json.dumps({'base': BASE, 'inputs': inputs, 'execution': channels,
                  'producer_sha256': digest(Path(__file__).read_bytes()),
                  'scope': 'Complete supplied tracked inputs and producer channels; exact three-insertion CI delta from accepted activation. Historical Git objects remain repository inputs verified by the unchanged historical audit. External Python/Perl/toolchain identities are not immutable reproduction claims.'}, indent=2) + '\n').encode()
TARGET.write_text(json.dumps({'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': digest(raw),
    'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}, indent=2) + '\n')
print('Historical CI inverse proof PASS; complete inputs and channels retained')
print(json.dumps({'controls': len(report['controls']), 'audit_controls': report['audit_controls'],
                  'supplied_inputs': len(inputs), 'restored_inputs': report['restored_inputs']}, sort_keys=True))
