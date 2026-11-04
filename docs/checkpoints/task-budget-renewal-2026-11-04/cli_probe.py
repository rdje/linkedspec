"""Retain actual reader capability observations before/after epoch admission."""
import argparse
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

from intake import BASE, HERE, ROOT, git


def packet(raw):
    return {'sha256': hashlib.sha256(raw).hexdigest(), 'base64': base64.b64encode(raw).decode()}


def capture(phase):
    output = HERE / ('reader-' + phase + '.json.gz')
    assert not output.exists(), 'reader capture is one-shot'
    command = ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
               '--tree', 'PERL-PRIVATE-FACTORY-CAPTURE', '--epoch', 'TYPE-REFERENCE-BOOK.1.2.20.2',
               '--id', 'PERL-PRIVATE-FACTORY-CAPTURE.1']
    actual = subprocess.run(command, cwd=ROOT, capture_output=True)
    raw_source = git('cat-file', 'blob', BASE + ':docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md')
    # Independent anchored source slice, not the reader's node parser.
    start = raw_source.index(b'- ID: `PERL-PRIVATE-FACTORY-CAPTURE.1`\n')
    end = raw_source.index(b'\n- ID: `', start + 1) + 1
    expected = raw_source[start:end]
    report = {'owner': 'TYPE-REFERENCE-BOOK.1.2.20.2', 'phase': phase, 'command': command,
              'returncode': actual.returncode, 'stdout': packet(actual.stdout), 'stderr': packet(actual.stderr),
              'expected': packet(expected), 'activation_commit': BASE,
              'producers': {name: packet((ROOT / name).read_bytes()) for name in (
                  'tools/read_task_narrative.py', 'tools/task_narrative.py',
                  'tools/project_data_env.sh', 'tools/project_data_run.sh',
                  'tools/run_python_project_data.sh')},
              'probe_source': packet(Path(__file__).read_bytes())}
    raw = json.dumps(report, separators=(',', ':')).encode()
    output.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(output.read_bytes()) == raw
    if phase == 'before':
        assert actual.returncode == 2 and b'invalid choice' in actual.stderr
    else:
        assert actual.returncode == 0 and actual.stdout == expected and not actual.stderr
    print(phase, 'reader exit', actual.returncode, 'matches pinned node', actual.stdout == expected)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--phase', choices=('before', 'after'), required=True)
    capture(parser.parse_args().phase)
