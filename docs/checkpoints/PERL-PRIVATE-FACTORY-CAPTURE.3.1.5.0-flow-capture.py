"""One-shot supplied native diagnosis of the existing package-flow branch."""
import base64
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4b48593b59acb7aba4d616ae1bdc4320fbbf5364'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = PREFIX + 'flow-probe.pl'
TARGET = ROOT / (PREFIX + 'flow-capture.json')
assert not TARGET.exists(), 'one-shot flow diagnosis already retained'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
blob = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
seed_raw = blob(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
files = {path: blob(path) for path in sorted(seed['inputs'])}
assert len(files) == 168 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items()), 'diagnosis precedes production writes'
files[TEST] = (ROOT / TEST).read_bytes()
inputs = {p: digest(raw) for p, raw in sorted(files.items())}
source = files[MODULE].decode()
start = source.index('sub _lower_mutation_slot_value_expr {')
end = source.index('\nsub ', start + 1)
body = source[start:end]
guard = "ref($lower_flow_composite_expr) eq 'CODE'"
assert body.count(guard) == 1
changed = (source[:start] + body.replace(guard, '0', 1) + source[end:]).encode()
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0',
                   LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in directory.rglob('*') if p.is_file()}


rows = []
with tempfile.TemporaryDirectory(prefix='legacy-flow-diagnosis-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    for name, raw, command in (
        ('native-observe', files[MODULE], ['perl', '-Iperl', TEST, 'observe']),
        ('native', files[MODULE], ['perl', '-Iperl', TEST]),
        ('removed-package-branch-syntax', changed, ['perl', '-Iperl', '-c', MODULE]),
        ('removed-package-branch', changed, ['perl', '-Iperl', TEST]),
    ):
        (supplied / MODULE).write_bytes(raw)
        population = dict(inputs, **{MODULE: digest(raw)})
        assert census(supplied) == population
        result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True, check=False)
        rows.append({'case': name, 'command': command, 'inputs': population, 'returncode': result.returncode,
                     'stdout_base64': base64.b64encode(result.stdout).decode(),
                     'stderr_base64': base64.b64encode(result.stderr).decode(),
                     'unchanged': census(supplied) == population})
        report = {'result': 'pending', 'base': BASE, 'seed': SEED, 'seed_sha256': digest(seed_raw),
                  'producer_sha256': digest(Path(__file__).read_bytes()), 'rows': rows}
        TARGET.write_text(json.dumps(report, indent=2) + '\n')
        assert rows[-1]['unchanged']
        if name == 'native-observe':
            observed = json.loads(result.stdout)
            assert result.returncode == 0 and not result.stderr
            assert observed['controlled'][0]['value'] == 'METHOD_FALLBACK'
            assert observed['controlled'][1]['value'] == 'FLOW_OVERRIDE'
            assert all(r['map_calls'] == 0 for r in observed['controlled'])
            assert all(r['parent_packet'] == 1 and r['eligible'] == [1] for r in observed['publication'])
        elif name.endswith('syntax'):
            assert result.returncode == 0 and b'syntax OK' in result.stderr
        else:
            assert re.findall(rb'^1\.\.(\d+)$', result.stdout, re.MULTILINE) == [b'16']
            if name == 'native':
                assert result.returncode == 0 and not result.stderr
            else:
                assert result.returncode != 0
                assert re.search(rb'^not ok \d+ - actual package callback controls the legacy branch$', result.stdout, re.MULTILINE)
report.update(result='PASS',
              scope='Actual public Toolbox plus controlled legacy package/map/publication selection at accepted4b48593b5 in169 supplied files. Native16 assertions pass; disabling only the package branch is syntax-valid and produces complete16 TAP with a distinguishing semantic RED. This diagnoses an already scheduled optional/direct private boundary, not an authored-language failure or a fix. Only original accepted Git inputs are read; all scratch stays on repository volume.')
TARGET.write_text(json.dumps(report, indent=2) + '\n')
print('Legacy package-flow diagnosis PASS: native16/169 supplied files and syntax-valid branch-removal RED')
