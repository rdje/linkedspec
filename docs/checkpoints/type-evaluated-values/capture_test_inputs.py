"""Complete the selected-test source/data closure before a new proof epoch."""
import gzip
import json
import subprocess
import common as c

selected = ('t/callable_codeblock_literal_contract.t', 't/generated_source_contract.t',
    't/uniform_binding_contract.t', 't/variadic_user_function_contract.t', 't/actionir_ast_parser.t',
    't/trace_actionir_method_lowering.t', 't/trace_emit_context_bridge.t')
old = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'corrected-inputs.json.gz')).read_bytes()))
regression = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'regression-inputs.json.gz')).read_bytes()))
source_tests = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'source-test-proposals.json.gz')).read_bytes()))
declared_changes = {'t/callable_codeblock_literal_contract.t': regression['after'], **source_tests['after']}
rows = subprocess.check_output(['git', 'ls-tree', '-rz', '--full-tree', c.BASE, '--', 't', 'tests', 'bin'], cwd=c.ROOT).decode().split('\0')
paths = set()
for row in filter(None, rows):
    header, path = row.split('\t', 1)
    mode, kind, oid = header.split()
    assert mode in ('100644', '100755') and kind == 'blob', (mode, path)
    paths.add(path)
paths.add('tests/evaluated-values/cases.json')
inputs = {path: c.read(path) for path in sorted(paths)}
for path, item in inputs.items():
    if path == 'tests/evaluated-values/cases.json':
        continue
    if path in declared_changes:
        assert item == declared_changes[path]
    else:
        accepted = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert c.decode(item['base64']) == accepted
assert set(selected) <= set(inputs)
missing = sorted(set(selected) - set(old['inputs']))
assert missing
data_gap = 'tests/language-readiness/nested-tree/cases.json'
assert data_gap in inputs and data_gap not in old['inputs']
c.write_new(c.PREFIX + 'test-inputs.json.gz', dict(inputs=inputs, selected=selected,
    original_missing_selected_sources=missing, observed_fixture_data_gap=data_gap,
    producer=c.read(c.PREFIX + 'capture_test_inputs.py'), helper=c.read(c.PREFIX + 'common.py'),
    failed_reconstruction_sha256=c.sha((c.ROOT / (c.PREFIX + 'corrected-baseline.json.gz')).read_bytes()),
    scope='The conservative1300/1303 selection intentionally filters extensions and omitted .t; '
          'it is not a complete Perl test input declaration. The callable source already remains '
          'recoverable in its before/after regression artifact; other original sources remain in '
          'real accepted Git. Original absent per-test manifest/mode assertions are not invented. '
          'This fresh complete owned t/tests/bin population retains actual bytes/modes before new '
          'commands, including fixture data and the unchanged source plus declared current test edits.'), packed=True)
print('Fresh complete owned test/data/bin inputs retained:', len(inputs), 'selected suites:', len(selected))
