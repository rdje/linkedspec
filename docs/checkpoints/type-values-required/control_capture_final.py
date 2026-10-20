"""Retain native comparison controls and an actual mapper source fault in supplied context."""
import gzip
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
plan = json.loads((ROOT / (P + 'focused-final-inputs.json')).read_bytes())
review = json.loads((ROOT / (P + 'focused-final-review.json')).read_bytes())
assert review['result'] == 'PASS'
paths = set(plan['inputs']) | {P + name for name in (
    'focused-final-inputs.json', 'focused-final-run.json.gz', 'focused-final-review.json',
    'controls_final.pl', 'control_capture_final.py')}
# The test authors directly consume frozen native JSON; supply their literal paths too.
native_inputs = set()
for path in plan['selected']:
    source = (ROOT / path).read_text()
    native_inputs.update(re.findall(r"['\"](docs/checkpoints/[^'\"]+\.json)['\"]", source))
    prefixes = re.findall(r"my \$prefix\s*=\s*'([^']+)'", source)
    for prefix in prefixes:
        native_inputs.update(prefix + name for name in re.findall(r"\$prefix\s*\.\s*'([^']+\.json)'", source))
assert len(native_inputs) == 14, sorted(native_inputs)
paths.update(native_inputs)
paths.update(str(path.relative_to(ROOT)) for path in (ROOT / P).iterdir() if path.is_file())
inputs = {path: c.read(path) for path in sorted(paths)}
assert all(all(inputs[path][key] == item[key] for key in ('sha256', 'mode'))
           for path, item in plan['inputs'].items())
helper = 't/lib/LinkedSpecTest/MethodLocations.pm'
healthy = c.decode(inputs[helper]['base64'])
needle = b' return $original{$line};'
assert healthy.count(needle) == 1
fault = healthy.replace(needle, b' return $line; # deliberately bypass coordinate producer', 1)
c.write_new(P + 'controls-final-inputs.json.gz', dict(inputs=inputs, selected=plan['selected'],
    fault=dict(path=helper, base64=c.encode(fault), sha256=c.sha(fault), mode=inputs[helper]['mode']),
    producer=c.read(P + 'control_capture_final.py'),
    scope='Full supplied source closure and modes before native/control and fault execution. '
          'Only the test mapper changes in an isolated same-volume context; production is exact.'),
    packed=True)
controls = c.run(['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', P + 'controls_final.pl'])
runs = []
git_dir = subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT, text=True).strip()
with tempfile.TemporaryDirectory(prefix='required-controls-', dir=os.environ['TMPDIR']) as directory:
    root = Path(directory)
    assert root.stat().st_dev == ROOT.stat().st_dev
    for path, item in inputs.items():
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(c.decode(item['base64']))
        target.chmod(item['mode'])
    temporary = root / '.linkedspec-data/tmp'
    temporary.mkdir(parents=True)
    environment = dict(os.environ, TMPDIR=str(temporary), GIT_DIR=git_dir,
                       GIT_WORK_TREE=str(root), GIT_OPTIONAL_LOCKS='0', PERL5LIB='')
    command = ['bash', 'tools/project_data_run.sh', 'prove', '-v', '-Iperl'] + plan['selected']
    for name, source in (('healthy', healthy), ('mapper-bypass', fault), ('restored', healthy)):
        (root / helper).write_bytes(source)
        result = subprocess.run(command, cwd=root, env=environment, capture_output=True)
        runs.append(dict(name=name, command=command, returncode=result.returncode,
            stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr),
            helper_sha256=c.sha(source),
            supplied_bytes_modes_unchanged=all(
                (root / path).read_bytes() == (source if path == helper else c.decode(item['base64']))
                and (root / path).stat().st_mode & 0o7777 == item['mode']
                for path, item in inputs.items())))
unchanged = c.unchanged(inputs)
c.write_new(P + 'controls-final-run.json.gz', dict(controls=controls, runs=runs,
    producer=c.read(P + 'control_capture_final.py'), main_inputs_bytes_modes_unchanged=unchanged), packed=True)
assert controls['returncode'] == 0
assert '1..14' in c.decode(controls['stdout_base64']).decode()
assert runs[0]['returncode'] == 0
failed = c.decode(runs[1]['stdout_base64']).decode()
count = len(re.findall(r'^not ok \d+', failed, re.M))
assert runs[1]['returncode'] == 1 and count == 198, count
assert runs[2]['returncode'] == 0
assert 'Files=12, Tests=5001,' in c.decode(runs[2]['stdout_base64']).decode()
assert unchanged and all(row['supplied_bytes_modes_unchanged'] for row in runs)
c.write_new(P + 'controls-final-review.json', dict(result='PASS', native_controls=14,
    mapper_bypass_failed_assertions=count, restored_assertions=5001,
    main_inputs_bytes_modes_unchanged=True, supplied_bytes_modes_unchanged=True,
    native_inputs=len(native_inputs), scope='Actual mapper producer bypass restores exactly 198 coordinate failures; source '
          'value repairs remain healthy. Native callback/file/line, unmatched statement, '
          'non-error payload, flattened return and wrong value controls stay distinct.'))
print('Native14 controls and actual mapper198 RED/exact restoration PASS')
