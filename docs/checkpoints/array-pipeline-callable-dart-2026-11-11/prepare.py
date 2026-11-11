"""Author independent Dart pipeline policy questions; import no peer outcomes."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '9ed018787cac456a0e0bf95942bcdb735f5e4e6c'
assert not (BASE / 'cases.json').exists()
rows = []
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')


def add(identifier, body, question):
    rows.append(dict(id=identifier, body=body, source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n',
        input='x', rule='Value', profile_only=True, question=question))


def call(helper, source, receiver=False, excess=False):
    source = 'supply(' + source + ')'
    operands = ['":"'] if helper == 'split_each' else ['/^head/'] if helper == 'filter_match' else []
    if excess:
        operands.append('{order=cat(order,"X");1}')
    return (source + '.' + helper + '(' + ','.join(operands) + ')' if receiver
            else helper + '(' + ','.join([source] + operands) + ')')


for helper in helpers:
    for kind, value in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"head"}')):
        for receiver in (False, True):
            form = 'receiver' if receiver else 'free'
            expression = call(helper, value, receiver)
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
    for form, expression in (('free', helper + '(supply(["head"]))'), ('receiver', 'supply(["head"]).' + helper + '()')):
        add('missing_operand_' + helper + '_' + form, 'order="";out=' + expression
            + '.with(){order=cat(order,"W");return(value)};return([out,order])', 'excluded-missing-arity')
for name, expression in (('count', 'supply([1]).count()'), ('key_count', 'supply({"a":1}).count_keys()'),
                         ('length', 'supply("abc").length()'), ('hash', 'set_key(supply({}),"k",1)'),
                         ('copy', 'copy(supply(3))'), ('view', 'sorted_keys(supply({"a":1}))')):
    add('prior_' + name, 'order="";out=' + expression
        + '.trim_each().with(){order=cat(order,"W");return(value)};return([out,order])', 'earlier-owner')
for receiver in (False, True):
    form = 'receiver' if receiver else 'free'
    expression = ('supply(["head:tail"]).split_each({items="bad";items+=1;":"})' if receiver
                  else 'split_each(supply(["head:tail"]),{items="bad";items+=1;":"})')
    add('needed_delimiter_' + form, 'order="";return(' + expression
        + '.set_key({order=cat(order,"K");"k"},1).coalesce("masked"))', 'needed-delimiter-error')
    expression = 'supply(["head"]).filter_match(/[z-a]/)' if receiver else 'filter_match(supply(["head"]),/[z-a]/)'
    for composed in (False, True):
        add('invalid_range_' + form + ('_composed' if composed else '_terminal'), 'order="";return(' + expression
            + ('.set_key({order=cat(order,"K");"k"},1).coalesce("masked")' if composed else '') + ')', 'regex-error-policy')
add('nested_scalar_kinds', 'source=[false,0,undef,"0",""];out=uniq(supply(source));return([out,source])', 'nested-kinds')
add('numeric_array_source', 'source=[3];return([trim_each(supply(source)),filter_nonempty(supply(source)),uniq(supply(source)),source])', 'numeric-kind')
assert len(rows) == 137
shared = json.loads(Path('tests/fixtures/array_pipeline_callable_result_guard_cases.json').read_bytes())
assert len(shared) == 37
signatures = json.loads((BASE / 'signature-sources.json').read_bytes())
patterns = json.loads((BASE / 'pattern-sources.json').read_bytes())
cases = shared + rows + signatures + patterns
assert len(cases) == len({row['id'] for row in cases}) == 194
for name, data in [('profile-sources.json', rows), ('cases.json', cases)]:
    (BASE / name).write_text(json.dumps(data, indent=2) + '\n')
print('Authored independent Dart194 source questions; no peer outcomes imported')
