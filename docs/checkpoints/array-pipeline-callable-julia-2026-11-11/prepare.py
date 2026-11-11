"""Author Julia source questions without importing another backend's outcomes."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
ACTIVATION = '580fe233a7d0299d177ecbd442ad8ba027bbe6da'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
templates = {}
for name in ('prepare.py', 'observer.jl'):
    path = Path('docs/checkpoints/array-pipeline-result-guard-julia-2026-11-11') / name
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    target = BASE / ('ordinary-' + name + '.gz')
    assert not target.exists()
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
    templates[name] = dict(path=str(path), bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
(BASE / 'ordinary-template-identities.json').write_text(json.dumps(templates, indent=2) + '\n')

rows = []
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')


def add(identifier, body, question):
    rows.append(dict(id=identifier, body=body,
        source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n',
        input='x', rule='Value', profile_only=True, question=question))


def call(helper, value, receiver=False, excess=False):
    source = 'supply(' + value + ')'
    arguments = ['":"'] if helper == 'split_each' else ['/^head/'] if helper == 'filter_match' else []
    if excess:
        arguments.append('{order=cat(order,"X");1}')
    return (source + '.' + helper + '(' + ','.join(arguments) + ')' if receiver
        else helper + '(' + ','.join([source] + arguments) + ')')


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

signatures = []
tail = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")}'
for name, definitions, invocation, valid in (
    ('variadic_empty', 'fn all_values(...items) {return(items)}', 'all_values()', True),
    ('variadic_multi', 'fn all_values(...items) {return(items)}', 'all_values({order=cat(order,"S");" head "}," tail ")', True),
    ('fixed_missing', 'fn pair(left,right) {return([left,right])}', 'pair({order=cat(order,"S");"head"})', False),
    ('fixed_extra', 'fn pair(left,right) {return([left,right])}', 'pair({order=cat(order,"S");"head"},"tail","extra")', False),
    ('variadic_missing', 'fn collect(prefix,...items) {return(items)}', 'collect()', False),
):
    for composed in (False, True):
        form = 'composed' if composed else 'terminal'
        body = 'order="";out=' + invocation + '.trim_each()' + (tail if composed else '') + ';return([out,order])'
        signatures.append(dict(id='own_signature_' + name + '_' + form, body=body,
            source=definitions + '\n\nValue:: I {' + body + '}\n', input='x', rule='Value',
            profile_only=True, question='function-signature-valid' if valid else 'function-signature-invalid', form=form))
assert len(signatures) == 10
patterns = []
for name, setup, operand, canonical in (
    ('literal', '', '/^head/', True),
    ('string', '', '"^head"', False),
    ('bare', 'pattern="^head";', 'pattern', False),
    ('block', '', '{order=cat(order,"P");"^head"}', False),
    ('needed_error', '', '{items="bad";items+=1;"^head"}', False),
):
    for composed in (False, True):
        form = 'composed' if composed else 'terminal'
        body = 'order="";' + setup + 'out=supply(["head","tail"]).filter_match(' + operand + ')' + (tail if composed else '') + ';return([out,order])'
        patterns.append(dict(id='own_pattern_' + name + '_' + form, body=body,
            source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n', input='x', rule='Value',
            profile_only=True, question='canonical-pattern' if canonical else 'noncanonical-pattern-boundary', form=form))
assert len(patterns) == 10
shared = json.loads(Path('tests/fixtures/array_pipeline_callable_result_guard_cases.json').read_bytes())
assert len(shared) == 37
cases = shared + rows + signatures + patterns
assert len(cases) == len({row['id'] for row in cases}) == 194
for name, data in (('profile-sources.json', rows), ('signature-sources.json', signatures),
    ('pattern-sources.json', patterns), ('cases.json', cases)):
    (BASE / name).write_text(json.dumps(data, indent=2) + '\n')
print('Authored Julia shared37/own137/signature10/pattern10 source questions; no peer outcomes imported')
