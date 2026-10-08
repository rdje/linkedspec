"""Recur the actual initial rejection and verify the sole artifact-name correction."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('instrument-controls.py')
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def main():
    initial = Path(PREFIX + 'initial-review.py').read_bytes()
    current = Path(PREFIX + 'review.py').read_bytes()
    metadata = json.loads(Path(PREFIX + 'initial-review-error.json').read_bytes())
    archive = Path(PREFIX + 'initial-review-error.log.gz').read_bytes(); error = gzip.decompress(archive)
    assert sha(initial) == metadata['source_sha256'] and sha(archive) == metadata['archive_sha256']
    assert len(error) == metadata['error_bytes'] and sha(error) == metadata['error_sha256']
    assert b'grouped-cause.json' in error and b'CalledProcessError' in error
    old, new = b'0.2.2.2-grouped-cause.json', b'0.2.2.2-cause-observations.json'
    assert initial.count(old) == current.count(new) == 1
    assert current.replace(new, old, 1) == initial, 'sole artifact-name correction'
    preflight = json.loads(Path(PREFIX + 'preflight.json').read_bytes())
    assert preflight['reviewer_sha256'] == sha(initial), 'actual partial preflight retains initial source identity'
    command = ['bash', 'tools/run_python_project_data.sh',
               Path(PREFIX + 'initial-review-replay.py').relative_to(ROOT).as_posix()]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    report = {'complete': False, 'command': command, 'exit': result.returncode,
              'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr),
              'initial_sha256': sha(initial), 'corrected_sha256': sha(current),
              'replay_sha256': sha(Path(PREFIX + 'initial-review-replay.py').read_bytes()),
              'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'instrument-controls.json').write_text(json.dumps(report, indent=2) + '\n')
    assert result.returncode == 1 and result.stdout == b''
    assert b'grouped-cause.json' in result.stderr and b'CalledProcessError' in result.stderr
    proof = json.loads(Path(PREFIX + 'verification.json').read_bytes())
    assert proof['complete'] and proof['instrument_sha256'] == sha(current)
    report.update(complete=True, controls=[
        {'name': 'exact initial missing artifact', 'observed_red': 'Original source/filename replay exits1 on absent grouped-cause.json.'},
        {'name': 'sole correction inverse', 'observed_result': 'Corrected reference to retained cause-observations.json is the only reviewer delta; complete31-control positive review passes.'}])
    Path(PREFIX + 'instrument-controls.json').write_text(json.dumps(report, indent=2) + '\n')
    print('Original missing-artifact rejection recurs; sole corrected reference and complete review verified')


if __name__ == '__main__':
    main()
