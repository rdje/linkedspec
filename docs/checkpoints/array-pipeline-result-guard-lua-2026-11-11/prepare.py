"""Author installed-Lua pipeline source questions without importing any peer outcomes."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '2d764b05f76e7d7359fe8dcd75b78f1765aa678f'
assert not (BASE / 'cases.json').exists()
rows = []
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')


def add(identifier, body, question):
    rows.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
                     input='x', rule='Value', profile_only=True, question=question))


def call(helper, source, receiver=False, excess=False):
    arguments = ['":"'] if helper == 'split_each' else ['/^head/'] if helper == 'filter_match' else []
    if excess:
        arguments.append('{order=cat(order,"X");1}')
    return (source + '.' + helper + '(' + ','.join(arguments) + ')' if receiver
            else helper + '(' + ','.join([source] + arguments) + ')')


for helper in helpers:
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"head"}')):
        for receiver in (False, True):
            form = 'receiver' if receiver else 'free'
            expression = call(helper, source, receiver)
            add(f'initial_{kind}_{helper}_{form}', 'return(' + expression + ')', 'initial-source')
            add(f'initial_{kind}_{helper}_{form}_with', 'order="";out=' + expression
                + '.with(){order=cat(order,"W");return(value.count())};return([out,order])', 'initial-source-with')
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        expression = call(helper, '{order=cat(order,"S");["head:tail"]}', receiver, excess=True)
        add('extra_' + helper + '_' + form, 'order="";out=' + expression
            + '.set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")};return([out,order])', 'excluded-extra-arity')
        expression = call(helper, '{items="bad";items+=1;["head"]}', receiver)
        add('needed_source_' + helper + '_' + form, 'order="";return(' + expression
            + '.set_key({order=cat(order,"K");"k"},1).coalesce("masked"))', 'needed-source-error')
    add('missing_' + helper + '_free', 'order="";out=' + helper
        + '().with(){order=cat(order,"W");return(value)};return([out,order])', 'excluded-missing-arity')
for helper in ('split_each', 'filter_match'):
    for form, expression in (('free', helper + '(["head"])'), ('receiver', '["head"].' + helper + '()')):
        add('missing_operand_' + helper + '_' + form, 'order="";out=' + expression
            + '.with(){order=cat(order,"W");return(value)};return([out,order])', 'excluded-missing-arity')
for name, source in (('count', '[1].count()'), ('key_count', '{"a":1}.count_keys()'),
                     ('length', '"abc".length()'), ('hash', 'set_key({},"k",1)'),
                     ('copy', 'copy(3)'), ('view', 'sorted_keys({"a":1})')):
    add('prior_' + name, 'order="";out=' + source
        + '.trim_each().with(){order=cat(order,"W");return(value)};return([out,order])', 'earlier-owner')
for receiver in (False, True):
    form = 'receiver' if receiver else 'free'
    expression = ('["head:tail"].split_each({items="bad";items+=1;":"})' if receiver
                  else 'split_each(["head:tail"],{items="bad";items+=1;":"})')
    add('needed_delimiter_' + form, 'order="";return(' + expression
        + '.set_key({order=cat(order,"K");"k"},1).coalesce("masked"))', 'needed-delimiter-error')
    expression = ('["head"].filter_match({items="bad";items+=1;"^head"})' if receiver
                  else 'filter_match(["head"],{items="bad";items+=1;"^head"})')
    for composed in (False, True):
        add('needed_pattern_' + form + ('_composed' if composed else '_terminal'), 'order="";return(' + expression
            + ('.set_key({order=cat(order,"K");"k"},1).coalesce("masked")' if composed else '') + ')', 'needed-pattern-error')
add('nested_scalar_kinds', 'source=[false,0,undef,"0",""];out=uniq(source);return([out,source])', 'nested-kinds')
add('numeric_array_source', 'source=[3];return([trim_each(source),filter_nonempty(source),uniq(source),source])', 'numeric-kind')
assert len(rows) == 137
shared = json.loads(Path('tests/fixtures/array_pipeline_result_guard_cases.json').read_bytes())
assert len(shared) == 36
cases = shared + rows
assert len(cases) == len({row['id'] for row in cases}) == 173
for name, data in [('cases.json', cases), ('profile-sources.json', rows)]:
    (BASE / name).write_text(json.dumps(data, indent=2) + '\n')

# Own prior public probes are retained templates, not imported observations.
templates = Path('docs/checkpoints/array-transform-result-guard-lua-2026-11-10')
identities = {}
def specialize(body):
    return (body.replace('TYPE-REFERENCE-BOOK.1.2.23.3.78.5', 'TYPE-REFERENCE-BOOK.1.2.23.3.79.5')
        .replace('array%-transform%-result%-guard%-lua%-2026%-11%-10', 'array%-pipeline%-result%-guard%-lua%-2026%-11%-11')
        .replace('array-transform-result-guard-lua-2026-11-10', 'array-pipeline-result-guard-lua-2026-11-11')
        .replace('array-transform-result-guard', 'array-pipeline-result-guard')
        .replace('array_transform_result_guard', 'array_pipeline_result_guard')
        .replace('ARRAY_TRANSFORM', 'ARRAY_PIPELINE').replace('Array-transform', 'Array-pipeline'))
for name in ('observer.lua', 'proof_io.py', 'capture.py', 'freeze_profiles.py'):
    original = (templates / name).read_bytes()
    (BASE / ('template-' + name + '.gz')).write_bytes(gzip.compress(original, mtime=0))
    identities[str(templates / name)] = dict(bytes=len(original), sha256=hashlib.sha256(original).hexdigest())
    body = specialize(original.decode())
    if name == 'observer.lua':
        body = body.replace('take_later_with', 'trim_later_with').replace('reverse_copy_later_with', 'uniq_copy_later_with').replace('sort_logical_later_with', 'lower_logical_later_with')
    if name == 'capture.py':
        body = body.replace("paths = list(source_paths) + list(BASE.glob('*.py'))", "paths = list(source_paths) + [BASE / name for name in ('prepare.py', 'proof_io.py', 'capture.py', 'freeze_profiles.py')] + list(BASE.glob('template-*.gz')) + [BASE / 'template-identities.json']")
        body = body.replace("paths += [Path('docs/checkpoints/hash-value-result-guard-lua-2026-11-07/observer.lua')]", "paths += [Path(name) for name in json.loads((BASE / 'template-identities.json').read_bytes())]")
        body = body.replace("'lua/test/with_hash_results_test.lua', 'lua/test/hash_value_result_guard_composition_test.lua',\n                          'lua/test/hash_view_result_guard_composition_test.lua', 'lua/test/constructor_result_composition_test.lua'", "'lua/test/array_transform_result_guard_composition_test.lua', 'lua/test/value_copy_test.lua'")
        # Old transform's own capture variable remains absent: no path collision.
    if name == 'freeze_profiles.py':
        body = body.replace('123', '141').replace("if case.get('profile_only') or case.get('expected_error'):", "if case.get('profile_only') or case.get('expected_error'):")
    (BASE / name).write_text(body)
normal_path = Path('lua/test/array_transform_result_guard_composition_test.lua')
original = normal_path.read_bytes()
(BASE / 'template-normal.lua.gz').write_bytes(gzip.compress(original, mtime=0))
identities[str(normal_path)] = dict(bytes=len(original), sha256=hashlib.sha256(original).hexdigest())
normal = Path('lua/test/array_pipeline_result_guard_composition_test.lua')
assert not normal.exists()
normal.write_text(specialize(original.decode()))
fixture = Path('tests/fixtures/array_pipeline_result_guard_lua_cases.json')
assert not fixture.exists()
fixture.write_bytes((BASE / 'cases.json').read_bytes())
(BASE / 'template-identities.json').write_text(json.dumps(identities, indent=2) + '\n')
print('Unchanged36 plus137 independently authored Lua source questions; valid-pattern DSL errors only')
