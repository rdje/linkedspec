"""Retain the second failed exact candidate and original public/source-origin repro."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('callable-capture.py')
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2'


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw),
            'sha256': hashlib.sha256(raw).hexdigest(),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def main():
    target = Path(PREFIX + 'failed-callable-canonical.json')
    if not target.exists():
        log = (ROOT / ('.linkedspec-data/scratch/' + OWNER + '-canonical-retry.log')).read_bytes()
        assert b"Failed test 'x,y native invocation returns its first parameter'" in log
        patch = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
        result = {'command': ['bash', 'tools/run_ci_local.sh'], 'exit': 1,
                  'channel': envelope(log), 'candidate': {
                      'base': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip(),
                      'full_index_binary_diff': envelope(patch)}}
        target.write_text(json.dumps(result, indent=2) + '\n')
    probe = 'docs/checkpoints/' + OWNER + '-callable-probe.pl'
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'perl', '-Iperl', probe]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    output = {'command': command, 'exit': result.returncode,
              'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr),
              'producer_sha256': hashlib.sha256((ROOT / probe).read_bytes()).hexdigest()}
    Path(PREFIX + 'callable-before.json').write_text(json.dumps(output, indent=2) + '\n')
    assert result.returncode == 0, 'complete original diagnostic observation'
    print('Original failed callable candidate and public/source-origin channels retained')


if __name__ == '__main__':
    main()
