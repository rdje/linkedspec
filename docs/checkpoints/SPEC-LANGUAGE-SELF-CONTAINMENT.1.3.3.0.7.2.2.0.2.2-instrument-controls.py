"""Retain actual original review failures and the distinguishing permission input."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import stat
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('instrument-controls.py')
SOURCE_RUNNER = ("from pathlib import Path; import sys; source = Path(sys.argv[1]); "
                 "exec(compile(source.read_bytes(), str(source), 'exec'), "
                 "{'__file__': sys.argv[2], '__name__': '__main__'})")


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def main():
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    entry = next(e for e in manifest['entries'] if e['path'] == 'perl/LinkedRE.pm')
    source = ROOT / entry['path']
    mode = stat.S_IMODE(source.stat().st_mode)
    assert sha(source.read_bytes()) == entry['sha256'], 'unchanged permission-counterexample bytes'
    assert mode != int(entry['mode'][-3:], 8), 'observed original full-permission counterexample'
    assert bool(mode & stat.S_IXUSR) == (entry['mode'] == '100755'), 'unchanged Git executable bit'
    failures = []
    for suffix, reason, preserve_identity in (
        ('initial-review.py', 'initial-inputs.json', False),
        ('initial-review.py', 'unchanged production and test modes', True),
        ('initial-control-review.py', 'unrejected evidence control: renamed consumer group', True),
    ):
        path = Path(PREFIX + suffix).relative_to(ROOT).as_posix()
        identity = Path(PREFIX + 'review.py').relative_to(ROOT).as_posix()
        command = (['python3', '-c', SOURCE_RUNNER, path, identity] if preserve_identity
                   else ['python3', path])
        result = subprocess.run(command, cwd=ROOT, capture_output=True)
        assert result.returncode == 1 and reason.encode() in result.stderr, 'actual original instrument rejection'
        failures.append({'command': command, 'exit': result.returncode,
                         'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr),
                         'instrument_sha256': sha((ROOT / path).read_bytes()), 'observed_red': reason})
    summary = {'complete': True, 'failures': failures,
               'permission_input': {'path': entry['path'], 'sha256': entry['sha256'],
                                    'git_mode': entry['mode'], 'filesystem_mode': format(mode, '04o')},
               'instrument_sha256': sha(Path(__file__).read_bytes()),
               'scope': 'Actual current-volume instrument failures only. The recorded permission input '
                        'plus immutable Git bytes reproduce the false comparison in a reconstructed tree; '
                        'Git executable mode remains unchanged. No chmod or source/test mutation. '
                        'Retained original source executes under its original __file__ identity, preserving '
                        'artifact-prefix lookup despite the historical source filename. No callback/source '
                        'or artifact substitution. The original control changes a nested line and fails '
                        'the demanded top-level RED. '
                        'Do not refresh historical observations after future source or permission changes.'}
    Path(PREFIX + 'instrument-controls.json').write_text(json.dumps(summary, indent=2) + '\n')
    print('Retained original filename, mode and control failures; permission input:', format(mode, '04o'))


if __name__ == '__main__':
    main()
