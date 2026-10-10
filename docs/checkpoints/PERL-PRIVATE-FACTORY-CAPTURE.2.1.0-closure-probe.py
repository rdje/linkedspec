"""Reverify the actual failed lifetime block at original/current source boundaries."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2d878478028fc417ac5b7790c016543c18c1f48b'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.0-'
MODULE = 'perl/LinkedSpec/ActionIR/Contracts.pm'
TEST = 't/actionir_contract_dependency_capture.t'
COLD = 't/actionir_contract_dependency_capture_cold.t'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.0-consumers.json'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
blob = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
target = ROOT / (PREFIX + 'closure-probe.json')
assert not target.exists(), 'one-shot closure probe'
seed = json.loads(blob(SEED))
original = {p: blob(p) for p in seed['inputs']}
assert {p: digest(raw) for p, raw in original.items()} == seed['inputs']
fixture = (ROOT / (PREFIX + 'draft1-fixture.t')).read_bytes()
source = (ROOT / (PREFIX + 'draft1-Contracts.pm')).read_bytes()
prefix = fixture[:fixture.index(b'sub capture')]
block = fixture[fixture.rindex(b'\n{\n my $actual = sub'):fixture.index(b'\ndone_testing;')]
lexical = block.replace(b"my $actual = sub { return 'same' };",
                        b"my $identity = {}; my $actual = sub { return $identity ? 'same' : undef };")
assert lexical != block
rows = []
for boundary in ('original', 'current'):
    for kind, body in (('no-lexical-state', block), ('lexical-state', lexical)):
        files = dict(original, **{TEST: fixture, COLD: (ROOT / COLD).read_bytes()})
        files[MODULE] = original[MODULE] if boundary == 'original' else source
        with tempfile.TemporaryDirectory(prefix='actual-closure-probe-', dir=os.environ['TMPDIR']) as temporary:
            supplied = Path(temporary)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            for path, raw in files.items():
                output = supplied / path; output.parent.mkdir(parents=True, exist_ok=True); output.write_bytes(raw)
            inputs = {p: digest(raw) for p, raw in sorted(files.items())}
            command = ['perl', '-Iperl', '-e', (prefix + body + b'\ndone_testing;\n').decode()]
            result = subprocess.run(command, cwd=supplied, env=dict(os.environ, PERL5LIB='', PERL5OPT=''),
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
            population = {p.relative_to(supplied).as_posix(): digest(p.read_bytes())
                          for p in supplied.rglob('*') if p.is_file()}
            row = {'boundary': boundary, 'kind': kind, 'command': command, 'inputs': inputs,
                   'returncode': result.returncode, 'stdout_base64': base64.b64encode(result.stdout).decode(),
                   'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': inputs == population}
            rows.append(row)
            target.write_text(json.dumps({'result': 'pending', 'rows': rows}, indent=2) + '\n')
            assert row['unchanged'] and b'1..2\n' in result.stdout
            if kind == 'no-lexical-state':
                assert result.returncode != 0 and b'not ok 2 - private binding release' in result.stdout
            else:
                assert result.returncode == 0 and b'not ok' not in result.stdout and not result.stderr
target.write_text(json.dumps({'result': 'PASS', 'base': BASE, 'producer_sha256': digest(Path(__file__).read_bytes()),
    'fixture_sha256': digest(fixture), 'current_source_sha256': digest(source), 'rows': rows,
    'scope': 'Exact extracted lifetime block fails on original and current Contracts with no lexical callback state; adding actual lexical state passes both. Reverification of the already known native shared-closure fixture issue, not a new production retention finding or cross-version Perl claim.'}, indent=2) + '\n')
print('Actual lifetime probe PASS: original/current no-state RED2, lexical-state GREEN2')
