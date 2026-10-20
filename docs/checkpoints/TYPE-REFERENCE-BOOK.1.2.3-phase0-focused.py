"""Capture a recoverable source snapshot before focused ordinary-file subtests."""
import gzip
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import current

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
base_path = c.PREFIX + 'final-inputs.json.gz'
base = json.loads(gzip.decompress((ROOT / base_path).read_bytes()))['inputs']
original = json.loads((ROOT / (P + 'original-run.json')).read_bytes())
log = c.decode(original['combined_output_base64']).decode()
failed = set(re.findall(r"^#   Failed test '([^\n]*)'\n#   at t/phase0_regression.t line \d+\.", log, re.M))
top = {name: int(number) for _, number, name in re.findall(r'^(not )?ok (\d+) - ([^\n]+)$', log, re.M)}
assert len(failed) == 52 and failed <= top.keys()
selected = [dict(number=top[name], name=name) for name in sorted(failed, key=lambda name: top[name])]
positive = dict(selected=selected, ordinary_root_tests=1035)
negative = dict(selected=[dict(number=1, name='__absent_focused_root__')], ordinary_root_tests=1035)
tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
paths = set(base)
paths.update(path for path in tracked if path and (
    '/' not in path and path.endswith('.md')
    or path.startswith(('conf/', 'tablescript/', 'ebnf/'))))
paths.update(current.book_population()[0])
paths.update(('tools/project_data_env.sh', 'tools/project_data_run.sh',
              'tools/run_python_project_data.sh', P + 'focused.py', P + 'focused.pl', P + 'original-run.json'))
inputs = {path: c.read(path) for path in sorted(paths)}
overrides = {path: item for path, item in inputs.items() if base.get(path) != item}
identities = {path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in inputs.items()}
c.write_new(P + 'focused-inputs.json.gz', dict(
    base_capsule=dict(path=base_path, sha256=c.sha((ROOT / base_path).read_bytes())),
    overrides=overrides, identities=identities, positive=positive, missing_selector=negative,
    producer=c.read(P + 'focused.py'), actor=c.read(P + 'focused.pl'),
    scope='Recoverable exact finite snapshot before both commands: full base capsule plus actual '
          'current overlays, root/book Markdown and conf/tablescript/EBNF. The actor executes only '
          'the52 originally failing root subtests and all their children, plus unfiltered startup '
          'assertions. Every other root is explicit SKIP. This is supplemental focused proof, never '
          'ordinary all1035 acceptance. Canonical CI later runs the intact file against exact staged '
          'inputs. Main continuity may advance after this retained snapshot; no historical Git '
          'identity or old per-read environment evidence is fabricated.'), packed=True)
command = ['perl', '-Iperl', P + 'focused.pl']
run = c.run(command, input=json.dumps(positive).encode())
control = c.run(command, input=json.dumps(negative).encode())
c.write_new(P + 'focused-run.json.gz', dict(run=run, missing_selector=control,
    inputs_bytes_modes_unchanged=c.unchanged(inputs)), packed=True)


def summary(observation):
    marker = b'# FOCUSED_PHASE0_JSON '
    output = c.decode(observation['stdout_base64'])
    assert output.count(marker) == 1
    return json.loads(output.split(marker)[1].splitlines()[0])


actual, denied = summary(run), summary(control)
assert run['returncode'] == 0 and actual['passing'] and actual['complete_selection']
assert actual['selected'] == actual['wanted'] == 52 and actual['root_tests'] == 1035
assert actual['skipped'] == 982
loaded = Path(actual['loaded_method_lowering'])
if not loaded.is_absolute():
    loaded = ROOT / loaded
assert loaded.resolve() == (ROOT / 'perl/LinkedSpec/ActionIR/MethodLowering.pm').resolve()
assert control['returncode'] != 0 and not denied['complete_selection']
assert denied['selected'] == 0 and denied['wanted'] == 1
assert c.unchanged(inputs)
c.write_new(P + 'focused-review.json', dict(result='PASS', actual=actual, missing_selector=denied,
    inputs=len(inputs), overridden_inputs=len(overrides),
    limits='Focused52 plus one startup assertion;982 explicit skipped roots. Missing selector '
           'control rejects all-skip false acceptance. Ordinary all1035 remains canonical admission.'))
print('Focused Phase052 PASS;982 explicit skips; actual missing-selector RED; snapshot inputs', len(inputs))
