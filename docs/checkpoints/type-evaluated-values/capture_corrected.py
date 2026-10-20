"""Retain a corrected accepted-runtime RED and candidate proof as a distinct epoch."""
import gzip
import json
import os
import subprocess
import tempfile
from pathlib import Path
import common as c

first = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'green-inputs.json.gz')).read_bytes()))
correction = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'oracle-correction.json.gz')).read_bytes()))
source_tests = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'source-test-proposals.json.gz')).read_bytes()))
preserved = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()))
inputs = dict(first['inputs'])
fixture_path = 'tests/evaluated-values/cases.json'
assert c.read(fixture_path) == correction['after']
inputs[fixture_path] = correction['after']
for path, item in source_tests['after'].items():
    assert c.read(path) == item
    inputs[path] = item
for name in ('capture_corrected.py', 'correct_oracle.py', 'strengthen_source_tests_final.py',
             'source-writer-run.json', 'push-oracle-run.json'):
    inputs[c.PREFIX + name] = c.read(c.PREFIX + name)
assert c.unchanged(inputs)
plan = set(preserved['planned_paths']) | {
    't/callable_codeblock_literal_contract.t', *source_tests['after'],
}
overlap = {key: sorted(set(item['inputs']) & plan) for key, item in preserved['live'].items()
           if set(item['inputs']) & plan}
assert list(overlap) == [c.OLD_CLAIM + '#0']
for key, item in preserved['live'].items():
    if key != c.OLD_CLAIM + '#0':
        assert c.read(key.rsplit('#', 1)[0]) == item['original']
        assert all(c.read(path)['sha256'] == wanted['sha256'] and c.read(path)['mode'] == wanted['mode']
                   for path, wanted in item['inputs'].items())
cases = json.loads(c.decode(inputs[fixture_path]['base64']))['cases']
for case in cases:
    case.update(spec=case.get('functions', '') + 'Top: /x/\n I { ' + case['body'] + ' }\n', input='x')
module = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
accepted = subprocess.check_output(['git', 'show', c.BASE + ':' + module], cwd=c.ROOT)
baseline_inputs = dict(inputs)
baseline_inputs[module] = dict(base64=c.encode(accepted), sha256=c.sha(accepted), mode=inputs[module]['mode'])
commands = [
    ['prove', '-v', '-Iperl', 't/callable_codeblock_literal_contract.t'],
    ['prove', '-v', '-Iperl', 't/generated_source_contract.t', 't/uniform_binding_contract.t',
     't/variadic_user_function_contract.t', 't/actionir_ast_parser.t',
     't/trace_actionir_method_lowering.t', 't/trace_emit_context_bridge.t'],
]
c.write_new(c.PREFIX + 'corrected-inputs.json.gz', dict(inputs=inputs, cases=cases, commands=commands,
    accepted_module=baseline_inputs[module], actual_expanded_plan=sorted(plan), intersections=overlap,
    scope='All actual corrected test/fixture and unchanged candidate sources precede measurements. '
          'The separate accepted-Git baseline changes only MethodLowering to real BASE in a fully '
          'supplied context. First rejected plan/candidate and the no-write source-writer failure '
          'remain immutable; no original observation is regenerated or overwritten.'), packed=True)
with tempfile.TemporaryDirectory(prefix='type-values-corrected-baseline-', dir=os.environ['TMPDIR']) as directory:
    root = Path(directory)
    assert root.stat().st_dev == c.ROOT.stat().st_dev
    for path, item in baseline_inputs.items():
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(c.decode(item['base64']))
        target.chmod(item['mode'])
    temporary = root / '.linkedspec-data/tmp'
    temporary.mkdir(parents=True)
    environment = dict(os.environ,
        GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
        GIT_WORK_TREE=str(root), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary), PERL5LIB='')

    def supplied(command, **kwargs):
        result = subprocess.run(command, cwd=root, env=environment, capture_output=True, **kwargs)
        return dict(command=command, returncode=result.returncode,
                    stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr))

    baseline_syntax = supplied(['perl', '-c', '-Iperl', 't/callable_codeblock_literal_contract.t'])
    baseline_tap = supplied(commands[0])
    baseline_public = supplied(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(cases).encode())
    assert all((root / path).read_bytes() == c.decode(item['base64']) and
               (root / path).stat().st_mode & 0o7777 == item['mode'] for path, item in baseline_inputs.items())
baseline = dict(syntax=baseline_syntax, tap=baseline_tap, public=baseline_public, source_bytes_modes_unchanged=True)
c.write_new(c.PREFIX + 'corrected-baseline.json.gz', baseline, packed=True)
assert baseline_syntax['returncode'] == 0 and baseline_tap['returncode'] != 0 and baseline_public['returncode'] == 0
syntax = [c.run(['perl', '-c', '-Iperl', path]) for path in
          ('t/actionir_ast_parser.t', 't/trace_actionir_method_lowering.t')]
runs = [c.run(command) for command in commands]
public = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(cases).encode())
c.write_new(c.PREFIX + 'corrected-green.json.gz', dict(syntax=syntax, runs=runs, public=public,
    inputs_unchanged=c.unchanged(inputs)), packed=True)
print('Corrected accepted-runtime RED:', baseline_tap['returncode'],
      'candidate/direct consumer exits:', [run['returncode'] for run in runs])
assert all(run['returncode'] == 0 for run in syntax + runs) and public['returncode'] == 0
assert c.unchanged(inputs)
