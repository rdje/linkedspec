"""Retain the original relative-runpy invocation error without losing producer bytes."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('instrument-controls.py')
RELATIVE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1-'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def main():
    # Use the original source with its original relative __file__ identity.
    # Supplying an absolute script path had avoided this caller-visible error;
    # the current reviewer resolves its own prefix for both entry methods.
    code = ('import pathlib,json; p=' + repr(RELATIVE) + '; '
            'm={"__file__":p+"review.py","__name__":"retained_original_reviewer"}; '
            'raw=pathlib.Path(p+"initial-review.py").read_bytes(); '
            'exec(compile(raw,p+"review.py","exec"),m); '
            'manifest=json.loads(pathlib.Path(p+"before-inputs.json").read_bytes()); '
            'm["check_inputs"](manifest,"before",m["original_population"]())')
    command = ['bash', 'tools/project_data_run.sh', 'python3', '-c', code]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    report = {'command': command, 'exit': result.returncode,
              'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr),
              'original_producer_sha256': sha(Path(PREFIX + 'initial-review.py').read_bytes()),
              'instrument_sha256': sha(Path(__file__).read_bytes()), 'complete': False}
    Path(PREFIX + 'instrument-controls.json').write_text(json.dumps(report, indent=2) + '\n')
    assert result.returncode == 1 and b'ValueError' in result.stderr
    assert b'is not in the subpath' in result.stderr
    report.update(complete=True, observed_red='relative __file__ prefix is not under absolute ROOT')
    Path(PREFIX + 'instrument-controls.json').write_text(json.dumps(report, indent=2) + '\n')
    print(report['observed_red'])


if __name__ == '__main__':
    main()
