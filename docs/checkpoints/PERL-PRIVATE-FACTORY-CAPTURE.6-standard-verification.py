"""Retain already observed standard checks; never execute or refresh a check."""
import base64
import gzip
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.6'
PREFIX = '.linkedspec-data/verification/' + LEAF
TARGET = ROOT / ('docs/checkpoints/' + LEAF + '-standard-verification.json.gz')


def supplied(path):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink(), path
    value = source.read_bytes()
    return dict(path=path, sha256=hashlib.sha256(value).hexdigest(),
                mode=source.stat().st_mode & 0o7777,
                base64=base64.b64encode(value).decode())


sources = [supplied(path) for path in (
    Path(__file__).relative_to(ROOT).as_posix(),
    'tools/project_data_run.sh', 'tools/project_data_env.sh',
    't/phase0_regression.t', 't/legacy_pathsearch_fallback.t',
    't/native_spec_resolution.t',
    'perl/LinkedSpec/ActionIR/RewritePipeline.pm',
    'docs/claims/' + LEAF + '.json',
    'docs/checkpoints/' + LEAF + '/publish.py')]
for row in sources[1:6]:
    original = subprocess.run(['git', 'show', BASE + ':' + row['path']],
                              cwd=ROOT, capture_output=True, check=True).stdout
    assert original == base64.b64decode(row['base64']), row['path']

commands = [
    dict(name='invalid-unwrapped-phase0', suffix='-phase0-attempt1.log',
         command='PERL5LIB= PERL5OPT= prove -v -Iperl t/phase0_regression.t',
         observed_session_exit=143,
         disposition='Stopped owned test/prove processes after the volume failure; incomplete run.'),
    dict(name='wrapped-storage-confirmation', suffix='-storage-confirmation-attempt1.log',
         command='env PERL5LIB= PERL5OPT= bash tools/project_data_run.sh prove -v -Iperl '
                 't/legacy_pathsearch_fallback.t t/native_spec_resolution.t',
         observed_session_exit=0),
    dict(name='readonly-publication', suffix='-final-publication-attempt1.log',
         command='bash tools/run_python_project_data.sh docs/checkpoints/' + LEAF + '/publish.py',
         observed_session_exit=0,
         disposition='Publisher passes; wrapper emits the known child setpgid warning for43054. '
                     'Final PGID was not captured. SESSION-STARTUP-READING.7 retains ownership; '
                     'no lifecycle success/failure conclusion or recovery/purge follows.'),
    dict(name='wrapped-complete-phase0', suffix='-phase0-attempt2.log',
         command='env PERL5LIB= PERL5OPT= bash tools/project_data_run.sh prove -v -Iperl '
                 't/phase0_regression.t', observed_session_exit=0),
]
for row in commands:
    row['log'] = supplied(PREFIX + row.pop('suffix'))
    channel = base64.b64decode(row['log']['base64']).decode()
    if row['name'] == 'invalid-unwrapped-phase0':
        assert 'fixture stays on repository volume' in channel
        assert "got: '16777234'" in channel and "expected: '16777244'" in channel
        assert 'ok 27 - owned fixture and excluded-tree decoy are removed' in channel
        assert 'Result: PASS' not in channel
    elif row['name'] == 'readonly-publication':
        assert 'Pipeline invocation publication PASS: 625 live inputs; 123401 bytes' in channel
        assert 'child setpgid (43054 to 43054): Operation not permitted' in channel
    else:
        assert re.search(r'^Result: PASS$', channel, re.M), row['name']
        assert not re.search(r'^\s*not ok\b', channel, re.M), row['name']
        summary = re.search(r'^Files=(\d+), Tests=(\d+),', channel, re.M)
        assert summary, row['name']
        row['files'], row['top_level_tests'] = map(int, summary.groups())
        if row['name'] == 'wrapped-storage-confirmation':
            assert (row['files'], row['top_level_tests']) == (2, 32)
            assert 'ok 2 - fixture stays on repository volume' in channel
        else:
            plans = re.findall(r'^1\.\.(\d+)$', channel, re.M)
            results = re.findall(r'^ok (\d+)\b', channel, re.M)
            assert row['files'] == 1 and plans == [str(row['top_level_tests'])]
            assert list(map(int, results)) == list(range(1, row['top_level_tests'] + 1))

record = dict(
    version=1, owner=LEAF, result='PASS', activation_commit=BASE,
    scope='Standard verification command correction only; frozen625-input publication stays exact. '
          'Session exits are the actual tool results transcribed after joining each run. Logs are '
          'complete original merged stdout/stderr. These source snapshots are post-run, not a '
          'claim of pre-run custody; five unchanged invocation/fixture sources additionally match '
          'the actual activation Git object. Supplied runtime proof retains its separate pre-run '
          'custody and channels. No check is replayed by this retainer.',
    limits='The failed fixture reports removal of its owned paths. No census or deletion of '
           'other off-volume data, global cleanup, kernel confinement or recovery admission is claimed.',
    sources=sources, observations=commands)
payload = (json.dumps(record, indent=1) + '\n').encode()
with TARGET.open('xb') as output:
    output.write(gzip.compress(payload, mtime=0))
print('Retained standard verification:', commands[-1]['top_level_tests'], 'Phase0 results')
