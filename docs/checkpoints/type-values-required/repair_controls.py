"""Retain the incomplete first control epoch and supply its exact missing native inputs."""
import ast
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
failed = json.loads(gzip.decompress((ROOT / (P + 'controls-run.json.gz')).read_bytes()))
assert failed['controls']['returncode'] != 0
assert all(row['returncode'] != 0 for row in failed['runs'])
assert all(b'No such file or directory' in c.decode(row['stderr_base64']) for row in failed['runs'])
original = {P + name: c.read(P + name) for name in ('controls.pl', 'control_capture.py')}
perl = c.decode(original[P + 'controls.pl']['base64']).decode()
perl = perl.replace('trim_action_ir_value', 'lower_scalar_access_key_expr')
old = "is($normal->{error}, $old->{error}, 'same-routine correspondence matches the actual frozen native error');"
new = r'''my $expected = $old->{error};
$expected =~ s{\bat [^\n]*?\bperl/LinkedSpec/ActionIR/MethodLowering\.pm line (\d+)(?:, <[^\n]+> line \d+)?\.\n\z}{at perl/LinkedSpec/ActionIR/MethodLowering.pm line $1.\n};
is($normal->{error}, $expected, 'same-routine correspondence matches the actual frozen native error');'''
assert perl.count(old) == 1
perl = perl.replace(old, new, 1).replace("isnt($actual->{error}, $old->{error},", "isnt($actual->{error}, $expected,")
python = c.decode(original[P + 'control_capture.py']['base64']).decode()
python = python.replace('control_capture.py', 'control_capture_final.py').replace('controls.pl', 'controls_final.pl')
python = python.replace("'controls-inputs.json.gz'", "'controls-final-inputs.json.gz'").replace(
    "'controls-run.json.gz'", "'controls-final-run.json.gz'").replace("'controls-review.json'", "'controls-final-review.json'")
anchor = 'inputs = {path: c.read(path) for path in sorted(paths)}\n'
replacement = r'''# The test authors directly consume frozen native JSON; supply their literal paths too.
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
'''
assert python.count(anchor) == 1
python = python.replace(anchor, replacement, 1)
python = python.replace("('mapper-bypass', fault), ('restored', healthy)", "('healthy', healthy), ('mapper-bypass', fault), ('restored', healthy)")
python = python.replace("failed = c.decode(runs[0]['stdout_base64']).decode()", "assert runs[0]['returncode'] == 0\nfailed = c.decode(runs[1]['stdout_base64']).decode()")
python = python.replace("runs[0]['returncode'] == 1", "runs[1]['returncode'] == 1")
python = python.replace("assert runs[1]['returncode'] == 0", "assert runs[2]['returncode'] == 0")
python = python.replace("c.decode(runs[1]['stdout_base64']).decode()", "c.decode(runs[2]['stdout_base64']).decode()", 1) if False else python
python = python.replace("assert 'Files=12, Tests=5001,' in c.decode(runs[1]['stdout_base64']).decode()",
    "assert 'Files=12, Tests=5001,' in c.decode(runs[2]['stdout_base64']).decode()")
python = python.replace("scope='Actual mapper producer bypass", "native_inputs=len(native_inputs), scope='Actual mapper producer bypass")
texts = {P + 'controls_final.pl': perl, P + 'control_capture_final.py': python}
ast.parse(python)
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()), mode=0o644)
         for path, text in texts.items()}
c.write_new(P + 'control-repair.json.gz', dict(original=original, after=after,
    producer=c.read(P + 'repair_controls.py'),
    scope='First direct native control omitted the earlier required callback, while the '
          'isolated suite omitted 14 frozen native JSON inputs. Both failures remain exact; '
          'neither is behavioral RED. Corrected sources supply all literal native inputs, '
          'compare the actually first required callback and retain its original source line. '
          'A fresh isolated healthy/fault/restored sequence is required.'), packed=True)
for path, item in after.items():
    assert not (ROOT / path).exists()
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
print('Separate corrected control sources prepared; original failed epoch retained')
