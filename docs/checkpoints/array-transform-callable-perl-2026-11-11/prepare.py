"""Author own Perl source/arity/signature questions before any production edit."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
BASE = HERE.relative_to(ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '51e1eb3522d2e7b963841be4388144437265ac44'
assert not (HERE / 'cases.json').exists(), 'one-shot preparation'
templates = (
    'docs/checkpoints/array-transform-callable-selection-2026-11-11/observer.pl',
    'docs/checkpoints/array-pipeline-callable-perl-2026-11-11/prepare.py',
    'docs/checkpoints/array-pipeline-callable-result-perl-2026-11-11/signature-cases.json',
    'tests/fixtures/array_transform_callable_result_guard_cases.json',
)
images = {}
for index, name in enumerate(templates):
    raw = (ROOT / name).read_bytes()
    target = HERE / ('template-' + str(index) + '.gz')
    target.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(target.read_bytes()) == raw
    images[name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), artifact=target.relative_to(ROOT).as_posix())
(HERE / 'template-identities.json').write_text(json.dumps(images, indent=2, sort_keys=True) + '\n')
rows = []
roles = ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays')
consumer = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1})'
tail = '.with(){order=cat(order,"W");return("ran")}'


def add(identifier, body, question, definition='fn supply(seed) {return(seed)}'):
    rows.append(dict(id='own_' + identifier, body=body,
        source=definition + '\n\nValue:: I {' + body + '}\n',
        input='x', rule='Value', profile_only=True, question=question))


def call(helper, source, receiver, *, excess=False, optional=False, missing=False):
    args = [] if helper in ('sorted', 'reversed') else ['1', '1'] if helper == 'slice' else ['["tail"]'] if helper == 'concat_arrays' else ['1']
    if optional:
        assert helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice')
        args = ['1'] if helper == 'slice' else []
    if missing:
        assert helper in ('slice', 'concat_arrays')
        args = []
    if excess: args.append('{order=cat(order,"X");1}')
    first = 'supply(' + source + ')'
    return first + '.' + helper + '(' + ','.join(args) + ')' if receiver else helper + '(' + ','.join([first] + args) + ')'


for helper in roles:
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"head"}')):
        for receiver in (False, True):
            form = 'receiver' if receiver else 'free'
            expression = call(helper, source, receiver)
            add('initial_' + kind + '_' + helper + '_' + form, 'return(' + expression + ')', 'initial-terminal')
            add('initial_' + kind + '_' + helper + '_' + form + '_with', 'order="";out=' + expression
                + '.with(){order=cat(order,"W");return(value.count())};return([out,order])', 'initial-first-with')
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        expression = call(helper, '{order=cat(order,"S");["head","tail"]}', receiver, excess=True)
        add('extra_' + helper + '_' + form, 'order="";out=' + expression + consumer + tail
            + ';return([out,order])', 'excluded-helper-arity')
        expression = call(helper, '{items="bad";items+=1;["head","tail"]}', receiver)
        add('needed_source_' + helper + '_' + form, 'order="";return(' + expression + consumer
            + '.coalesce("masked"))', 'needed-source-error')
for helper in ('slice', 'concat_arrays'):
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        expression = call(helper, '{order=cat(order,"S");["head","tail"]}', receiver, missing=True)
        add('missing_' + helper + '_' + form, 'order="";out=' + expression + tail
            + ';return([out,order])', 'excluded-helper-arity')
for name, source in (('count', 'supply([1]).count()'), ('key_count', 'supply({"a":1}).count_keys()'),
                     ('length', 'supply("abc").length()'), ('hash', 'set_key(supply({}),"k",1)'),
                     ('copy', 'copy(supply(3))'), ('view', 'sorted_keys(supply({"a":1}))')):
    add('prior_' + name, 'order="";out=' + source + '.take({order=cat(order,"T");1})'
        + '.with(){order=cat(order,"W");return(value)};return([out,order])', 'earlier-owner')
for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        expression = call(helper, '["head","tail"]', receiver, optional=True)
        add('optional_' + helper + '_' + form, 'return(' + expression + ')', 'optional-default-terminal')
        expression = call(helper, '{order=cat(order,"S");["head","tail"]}', receiver, optional=True)
        add('optional_' + helper + '_' + form + '_composed', 'order="";out=' + expression + consumer + tail
            + ';return([out,order])', 'optional-default-composed')
for shape, expression in (('missing', 'supply()'), ('extra', 'supply(["head"],{order=cat(order,"F");1})')):
    for composed in (False, True):
        add('function_arity_' + shape + ('_composed' if composed else '_terminal'),
            'order="";out=' + expression + ('.take(1)' + consumer + tail if composed else '')
            + ';return([out,order])', 'function-arity-composed' if composed else 'function-arity-terminal')
# Reuse only authored sources/labels, never the previous pipeline's outcomes or expected values.
signature = json.loads((ROOT / templates[2]).read_bytes())
for original in signature:
    row = {name: copy.deepcopy(original[name]) for name in ('id', 'body', 'source', 'rule', 'input', 'question', 'form')}
    row['id'] = 'own_' + row['id']
    row['body'] = row['body'].replace('.trim_each()', '.take(1)')
    row['source'] = row['source'].replace('.trim_each()', '.take(1)')
    row['profile_only'] = True
    row['question'] = 'signature-' + row['question']
    rows.append(row)
for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
    for receiver in (False, True):
        for position in (('start', 'count') if helper == 'slice' else ('count',)):
            args = ['1', '1'] if helper == 'slice' else ['1']
            args[0 if position == 'start' else -1] = '{items="bad";items+=1;1}'
            first = 'supply(["head","tail"])'
            expression = first + '.' + helper + '(' + ','.join(args) + ')' if receiver else helper + '(' + ','.join([first] + args) + ')'
            add('needed_' + position + '_' + helper + ('_receiver' if receiver else '_free'),
                'order="";return(' + expression + consumer + '.coalesce("masked"))', 'needed-operand-error')
for kind, source in (('bool', 'false'), ('string_binding_name', '"items"')):
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        expression = call('take', source, receiver)
        add('scalar_' + kind + '_' + form, 'items=["named"];return(' + expression + ')', 'additional-source-kind')
        add('scalar_' + kind + '_' + form + '_with', 'order="";items=["named"];out=' + expression
            + '.with(){order=cat(order,"W");return(value.count())};return([out,order])', 'additional-source-kind-first-with')
add('nested_scalar_kinds', 'items=[false,0,undef,"0",""];out=reversed(supply(items));return([out,items])', 'nested-kinds')
add('numeric_array_source', 'items=[3];return([take(supply(items),1),concat_arrays(supply(items),[0]),items])', 'numeric-kind')
add('source_before_rejection', 'order="";out=' + call('reversed', '{order=cat(order,"S");["head","tail"]}', True)
    + consumer + '.copy()' + tail + ';return([out,order])', 'source-before-rejection')
assert len(rows) == len({row['id'] for row in rows})
shared = json.loads((ROOT / templates[3]).read_bytes())
assert len(shared) == 45 and not {row['id'] for row in shared} & {row['id'] for row in rows}
(HERE / 'cases.json').write_text(json.dumps(shared + rows, indent=2) + '\n')
(HERE / 'own-questions.json').write_text(json.dumps(rows, indent=2) + '\n')
observer = gzip.decompress((HERE / 'template-0.gz').read_bytes()).decode()
observer = observer.replace('array-transform-callable-selection-2026-11-11', BASE.name)
observer = observer.replace('ARRAY_TRANSFORM_CALLABLE_', 'ARRAY_TRANSFORM_CALLABLE_PERL_')
observer = observer.replace('ArrayTransformCallableSelectionProbe', 'ArrayTransformCallablePerlIntakeProbe')
observer = observer.replace('array-transform-callable-selection.spec', 'array-transform-callable-perl.spec')
(HERE / 'observer.pl').write_text(observer)
print(json.dumps(dict(result='PASS', shared_questions=len(shared), own_questions=len(rows), total=len(shared)+len(rows),
    scope='Authored questions only; no policy/outcome/semantic PASS inferred before acquisition.'), sort_keys=True))
