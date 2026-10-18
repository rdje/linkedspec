"""One-shot complete-source object-target controls, using the444-assertion oracle."""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
OWNERS = tuple('perl/LinkedSpec/ActionIR/' + p + '.pm' for p in ('ControlFlow', 'FlowExpr', 'MethodLowering'))
FIXTURE = 't/actionir_default_object_capture.t'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'faults.json')
assert not target.exists()
capsule_raw = (ROOT / (PREFIX + 'paired-after-inputs.json.gz')).read_bytes()
capsule = json.loads(gzip.decompress(capsule_raw))
files = {p: decode(x['bytes_base64']) for p, x in capsule.items()}
modes = {p: x['mode'] for p, x in capsule.items()}
assert all((ROOT / p).read_bytes() == v for p, v in files.items())
sources = {p: files[p] for p in OWNERS}
guard = b"if (defined($pkg) && !ref($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'"
original = b"if (defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext'"
assert all(v.count(guard) == 1 for v in sources.values())
variants = [('inverse', {p: v.replace(guard, original, 1) for p, v in sources.items()})]
for path in OWNERS:
    selected = dict(sources)
    selected[path] = selected[path].replace(guard, original, 1)
    variants.append(('inverse-' + Path(path).stem, selected))
variants.append(('late-reference-guard', {p: v.replace(guard,
    b"if (defined($pkg) && $pkg eq 'LinkedSpec::RuleIR::EmitContext' && !ref($pkg)", 1) for p, v in sources.items()}))
variants.append(('inheritance-grants-target-authority', {p: v.replace(guard,
    b"if (defined($pkg) && (ref($pkg) ? $pkg->isa('LinkedSpec::RuleIR::EmitContext') : $pkg eq 'LinkedSpec::RuleIR::EmitContext')", 1) for p, v in sources.items()}))
selected = dict(sources)
fixed = b'if (defined &LinkedSpec::ActionIR::ValueExpr::_register_builtin_control_emission_callback) {'
assert selected[OWNERS[0]].count(fixed) == 1
selected[OWNERS[0]] = selected[OWNERS[0]].replace(fixed,
    b'if (!ref($pkg) && defined &LinkedSpec::ActionIR::ValueExpr::_register_builtin_control_emission_callback) {', 1)
variants.append(('fixed-provider-object-omission', selected))
for path in OWNERS:
    selected = dict(sources)
    selected[path] = selected[path].replace(guard, b'$pkg = "$pkg"; ' + guard, 1)
    variants.append(('coerced-target-' + Path(path).stem, selected))
assert len(variants) == 10
environment = dict(os.environ, PERL5LIB='', PERL5OPT='')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
rows = []
for name, replacements in variants:
    supplied_files = files | replacements
    with tempfile.TemporaryDirectory(prefix='default-object-fault-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        assert supplied.stat().st_dev == ROOT.stat().st_dev
        for path, value in supplied_files.items():
            destination = supplied / path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(value)
            destination.chmod(modes[path])
        channels = []
        for command in [['perl', '-c', '-Iperl', p] for p in OWNERS] + [['perl', '-Iperl', FIXTURE]]:
            result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
            channels.append(dict(command=command, returncode=result.returncode,
                stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr)))
        actual = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()}
        actual_modes = {p: (supplied / p).stat().st_mode & 0o7777 for p in actual}
    text = decode(channels[-1]['stdout_base64']).decode()
    tests = re.findall(r'^(not )?ok (\d+) - (.*)$', text, re.M)
    failed = [dict(number=int(n), name=title) for bad, n, title in tests if bad]
    row = dict(name=name, sources={p: dict(sha256=sha(v), bytes_base64=encode(v)) for p, v in replacements.items()},
        channels=channels, assertions=len(tests), failures=failed,
        unchanged=actual == {p: sha(v) for p, v in supplied_files.items()} and actual_modes == modes)
    rows.append(row)
    (ROOT / (PREFIX + 'faults-reached.json.gz')).write_bytes(gzip.compress(json.dumps(rows, sort_keys=True).encode(), mtime=0))
    assert row['unchanged'] and all(x['returncode'] == 0 for x in channels[:-1])
    assert channels[-1]['returncode'] != 0 and failed, ('semantic witness', name)
    assert re.findall(r'^1\.\.(\d+)$', text, re.M) == ['444'] and len(tests) == 444
    assert [int(n) for _, n, _ in tests] == list(range(1, 445))
before = json.loads((ROOT / (PREFIX + 'paired-before.json')).read_bytes())
assert rows[0]['failures'] == before['failures']
before_inputs = json.loads(gzip.decompress((ROOT / (PREFIX + 'paired-before-inputs.json.gz')).read_bytes()))
assert all(decode(before_inputs[p]['bytes_base64']) == decode(rows[0]['sources'][p]['bytes_base64']) for p in OWNERS)
data = gzip.compress(json.dumps(rows, sort_keys=True, separators=(',', ':')).encode(), mtime=0)
with (ROOT / (PREFIX + 'faults-data.json.gz')).open('xb') as output:
    output.write(data)
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
    positive_capsule_sha256=sha(capsule_raw), data_sha256=sha(data),
    variants=[dict(name=r['name'], assertions=r['assertions'], failures=len(r['failures'])) for r in rows],
    scope='Ten complete three-selector source variants and full444 plans. Exact inverse restores every100 original failure name/number and the actual pre-repair sources. Individual owner inverses, late guards, coercion, inheritance-based grants and fixed-provider omission have distinguishing semantic witnesses. Complete sources, syntax/raw TAP channels and unchanged supplied byte/mode populations are retained. No live mutation, historical-revision fiction or exhaustive mutation claim.')
with target.open('x') as output:
    output.write(json.dumps(report, indent=2) + '\n')
assert all((ROOT / p).read_bytes() == v for p, v in files.items())
print('Package-object source faults PASS:', [len(r['failures']) for r in rows])
