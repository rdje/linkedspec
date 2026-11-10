"""Retain actual reviewer-boundary failures and unchanged compatibility probes."""
import argparse
import base64
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
FACTORY = ROOT / 'docs/checkpoints/document-pressure-restoration'
sys.path.insert(0, str(FACTORY))
import factory_evidence as consumer

READERS = ('factory_evidence.py', 'factory_reviewer_calibration.py')


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert packet(raw) == row
    return raw


def execute(argv, env):
    result = subprocess.run(argv, cwd=ROOT, env=env, capture_output=True)
    return dict(argv=argv, cwd='.', exit=result.returncode,
                stdout=packet(result.stdout), stderr=packet(result.stderr))


def validate(report):
    for row in report['sources'].values():
        decode(row)
    for row in report['commands'].values():
        decode(row['stdout']); decode(row['stderr'])
    native = report['commands']['native']
    assert native['exit'] == 0 and decode(native['stderr']) == b''
    consumer.observations(json.loads(decode(native['stdout'])))
    if report['stage'] == 'before':
        rejected = report['commands']['factory_evidence.py']
        assert rejected['exit'] == 1
        assert b'native replay runtime drift: perl/LinkedSpec/ActionIR/MethodLowering.pm' in decode(rejected['stderr'])
    else:
        for name in READERS:
            command = report['commands'][name]
            assert command['exit'] == 0 and decode(command['stderr']) == b''
    return dict(result='PASS', stage=report['stage'], unchanged_public_targets='native/fresh semantic oracle PASS',
                reviewer_exits={name: report['commands'][name]['exit'] for name in READERS},
                limits=report['limits'])


def capture(stage):
    output = HERE / ('factory-boundary-' + stage + '.json.gz')
    assert not output.exists(), 'one-shot acquisition'
    names = subprocess.check_output(['git', 'ls-files', '-z', '--', 'perl', 'specs', 'conf', 'tablescript', 'ebnf'], cwd=ROOT).split(b'\0')
    names = {name.decode() for name in names if name and (ROOT / name.decode()).is_file()}
    names |= {str((FACTORY / name).relative_to(ROOT)) for name in (*READERS, 'factory_probe.pl', 'book_review.py',
              'factory-evidence.json.gz', 'factory-reviewer-source-calibration.json.gz',
              'objective-recovery-selector-literals.json.gz')}
    names |= {str(Path(__file__).relative_to(ROOT)), 'tools/run_python_project_data.sh',
              'tools/project_data_env.sh', 'tools/project_data_run.sh',
              'tools/check_executable_aggregate_selector_sources.py'}
    sources = {name: packet((ROOT / name).read_bytes()) for name in sorted(names)}
    saved = json.loads(gzip.decompress((FACTORY / 'factory-evidence.json.gz').read_bytes()))
    probe = decode(saved['producers']['docs/checkpoints/document-pressure-restoration/factory_probe.pl'])
    assert probe == (FACTORY / 'factory_probe.pl').read_bytes()
    env = dict(os.environ, PERL5LIB='', PERL5OPT='')
    commands = {name: execute(['bash', 'tools/run_python_project_data.sh',
                 str((FACTORY / name).relative_to(ROOT))], env) for name in READERS}
    commands['native'] = execute(['perl', '-Iperl', '-e', probe.decode()], env)
    assert all((ROOT / name).read_bytes() == decode(row) for name, row in sources.items())
    report = dict(stage=stage, activation_commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                  sources=sources, commands=commands,
                  limits='Finite unchanged authored compatibility targets and retained source/calibration replay only. '
                         'Conservative parent-owned project-source snapshot is not complete native/cache/transitive/toolchain custody; '
                         'that remains TYPE-REFERENCE-BOOK.1.2.23.4.2/SESSION5. Historical captures and runtime policies are unchanged.')
    output.write_bytes(gzip.compress(json.dumps(report, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    return validate(report)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', choices=('before', 'after'))
    args = parser.parse_args()
    if args.capture:
        result = capture(args.capture)
    else:
        result = [validate(json.loads(gzip.decompress((HERE / ('factory-boundary-' + stage + '.json.gz')).read_bytes())))
                  for stage in ('before', 'after')]
    print(json.dumps(result, sort_keys=True))
