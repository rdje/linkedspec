"""Falsify the actual value-observation helper in a supplied finite source tree."""
import gzip
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import phase0_records as records

P = records.P
snapshot = records.load('focused-final-inputs.json.gz')
raw = (ROOT / snapshot['base_capsule']['path']).read_bytes()
assert c.sha(raw) == snapshot['base_capsule']['sha256']
inputs = json.loads(gzip.decompress(raw))['inputs']
inputs.update(snapshot['overrides'])
path = 't/phase0_regression.t'
source = c.decode(inputs[path]['base64']).decode()
old = 'my $ok = eval { $value = $execute->(); 1 };'
new = 'my $ok = eval { $value = undef; 1 };'
assert source.count(old) == 1
changed = source.replace(old, new, 1).encode()
mutant = dict(base64=c.encode(changed), sha256=c.sha(changed), mode=inputs[path]['mode'])
goldens = records.load('oracle-observed-review.json')['goldens']
renamed = {
    'typed slot/container lowering reuses the expected scalar/hash/array Perl shapes':
        'typed slot/container lowering executes the constructor result',
    'structured harray snapshot lowering is deterministic':
        'structured harray snapshot preserves the copied harray kind',
}
expected = {renamed.get(row['label'], row['label']) for row in goldens
            if json.loads(row['expected_json'])['value'] is not None}
assert len(expected) == 129
c.write_new(P + 'value-control-inputs.json.gz', dict(snapshot=c.read(P + 'focused-final-inputs.json.gz'),
    base_capsule=snapshot['base_capsule'], original=inputs[path], mutant=mutant,
    expected_failed_assertions=sorted(expected), producer=c.read(P + 'value_control.py'),
    reader=c.read(c.PREFIX + 'phase0_records.py'),
    scope='Actual helper bypasses execution and substitutes undef; all130 independent goldens '
          'remain unchanged. One genuine null case remains a healthy control. The supplied context '
          'and exact mutant precede the command. Healthy source is restored and rerun afterward. '
          'Main files remain unchanged; this is focused52 proof, not ordinary all1035 admission.'), packed=True)
runs = []
with tempfile.TemporaryDirectory(prefix='type-values-golden-control-', dir=os.environ['TMPDIR']) as directory:
    root = Path(directory)
    assert root.stat().st_dev == ROOT.stat().st_dev
    for name, item in inputs.items():
        target = root / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(c.decode(item['base64']))
        target.chmod(item['mode'])
    temporary = root / '.linkedspec-data/tmp'
    temporary.mkdir(parents=True)
    environment = dict(os.environ, TMPDIR=str(temporary),
        GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT, text=True).strip(),
        GIT_WORK_TREE=str(root), GIT_OPTIONAL_LOCKS='0')
    for name, item in (('actual-undef-fault', mutant), ('healthy-restored', inputs[path])):
        (root / path).write_bytes(c.decode(item['base64']))
        (root / path).chmod(item['mode'])
        command = ['perl', '-Iperl', P + 'focused.pl']
        result = subprocess.run(command, cwd=root, env=environment,
            input=json.dumps(snapshot['positive']).encode(), capture_output=True)
        run = dict(command=command, returncode=result.returncode,
                   stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))
        for target, wanted in inputs.items():
            wanted = item if target == path else wanted
            assert (root / target).read_bytes() == c.decode(wanted['base64'])
            assert (root / target).stat().st_mode & 0o7777 == wanted['mode']
        runs.append(dict(name=name, run=run, all_supplied_bytes_modes_unchanged=True))
        if name == 'actual-undef-fault':
            summary = records.summary(run)
            failed = set(re.findall(r"^[ \t]+#\s+Failed test '([^\n]*)'\n",
                c.decode(run['stderr_base64']).decode(), re.M))
            assert run['returncode'] != 0 and summary['complete_selection'] and not summary['passing']
            assert failed == expected, (sorted(failed - expected), sorted(expected - failed))
        else:
            records.focused_result(run, snapshot['positive']['selected'])
c.write_new(P + 'value-control-run.json.gz', dict(runs=runs, result='PASS',
    failed_value_assertions=129, null_control=1,
    main_test_unchanged=c.read(path) == inputs[path]), packed=True)
assert c.read(path) == inputs[path]
print('Actual value-helper fault rejects129 goldens/one null control; exact restoration passes focused52')
