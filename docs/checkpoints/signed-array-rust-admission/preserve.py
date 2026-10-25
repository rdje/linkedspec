"""Retain canonical1's exact failed index without copying sealed binary inputs."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
BASE = '691d2d87690ce3f9052c1d032a3e862ee5d76211'
EXPECTED = '58420217aa9ae41825ea5dad2870a08aaf77bbe74e9ae10bc164a9e9de6cc4c6'


def packet(raw, mode):
    return dict(base64=base64.b64encode(raw).decode(), mode=mode,
                sha256=hashlib.sha256(raw).hexdigest())


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
    command = ['git', 'diff', '--cached', '--binary', '--full-index', '--no-ext-diff', 'HEAD']
    process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE)
    fingerprint = hashlib.sha256()
    for block in iter(lambda: process.stdout.read(1024 * 1024), b''):
        fingerprint.update(block)
    assert process.wait() == 0 and fingerprint.hexdigest() == EXPECTED
    paths = subprocess.check_output(['git', 'diff', '--cached', '--name-only', '-z'], cwd=ROOT)
    names = {name.decode() for name in paths.split(b'\0') if name}
    assert len(names) == 215
    index = subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=ROOT)
    retained, overlays = {}, {}
    for row in index.split(b'\0'):
        if not row:
            continue
        metadata, encoded = row.split(b'\t', 1)
        path = encoded.decode()
        if path not in names:
            continue
        mode, oid, stage = metadata.decode().split()
        assert stage == '0' and mode in ('100644', '100755')
        file = ROOT / path
        assert file.is_file() and not file.is_symlink()
        if path.startswith('docs/checkpoints/signed-array-rust/'):
            size = file.stat().st_size
            digest = hashlib.sha256()
            blob = hashlib.sha1(b'blob ' + str(size).encode() + b'\0')
            with file.open('rb') as stream:
                for block in iter(lambda: stream.read(1024 * 1024), b''):
                    digest.update(block)
                    blob.update(block)
            assert blob.hexdigest() == oid
            retained[path] = dict(git_mode=mode, git_oid=oid, sha256=digest.hexdigest(),
                                  mode=file.stat().st_mode & 0o7777, bytes=size)
        else:
            raw = subprocess.check_output(['git', 'show', ':' + path], cwd=ROOT)
            actual = hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest()
            assert actual == oid
            overlays[path] = dict(git_mode=mode, git_oid=oid,
                                  **packet(raw, file.stat().st_mode & 0o7777))
    assert set(retained) | set(overlays) == names
    assert len(retained) == 198
    additional = {}
    for path in ['tests/language-readiness/verify_objectives.py',
                 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py',
                 'tools/run_ci_local.sh', 'tools/run_python_project_data.sh',
                 'tools/project_data_run.sh', 'tools/project_data_env.sh']:
        file = ROOT / path
        raw = file.read_bytes()
        assert raw == subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
        additional[path] = packet(raw, file.stat().st_mode & 0o7777)
    log = ROOT / '.linkedspec-data/verification/signed-rust-canonical1.log'
    value = dict(base=BASE, fingerprint=EXPECTED, staged_index_base64=base64.b64encode(index).decode(),
                 overlays=overlays, sealed_inputs=retained, additional_sources=additional,
                 actual_gate=dict(command=['bash', 'tools/run_ci_local.sh'], returncode=1,
                                  log=packet(log.read_bytes(), log.stat().st_mode & 0o7777)),
                 producer=packet(Path(__file__).read_bytes(), Path(__file__).stat().st_mode & 0o7777),
                 scope='Exact failed215-file index from canonical1; all198 sealed inputs remain physically recoverable and Git-verified without recursive copying. Complete17 mutable index images, actual full gate channels and unchanged accepted auditor/gateway/wrappers are retained. Text-only blocker tracking has since changed the working Memory/task tree, but not this failed index. Git supplies original candidate bytes/executable modes; full filesystem modes are observed at preservation, not invented as earlier observations. No completed canonical result or runtime regression is inferred from this historical-integrity failure.')
    with (HERE / 'canonical1-candidate.json.gz').open('xb') as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode(), mtime=0))
    print('Retained exact failed215-file candidate:17 whole mutable images/198 sealed references; actual gate1.')


if __name__ == '__main__':
    main()
