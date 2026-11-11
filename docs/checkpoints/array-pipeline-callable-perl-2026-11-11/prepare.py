"""Own Perl callable pipeline policy questions, before production changes."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '237a738bfff46034b2f9b4d157e507c59f6994ca'
assert not (BASE / 'cases.json').exists()
rows = []
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')


def add(identifier, body, question):
    rows.append(dict(id='own_' + identifier, body=body,
        source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n',
        input='x', rule='Value', profile_only=True, question=question))


def call(helper, source, receiver=False, excess=False):
    arguments = ['":"'] if helper == 'split_each' else ['/^head/'] if helper == 'filter_match' else []
    if excess:
        arguments.append('{order=cat(order,"X");1}')
    source = 'supply(' + source + ')'
    return (source + '.' + helper + '(' + ','.join(arguments) + ')' if receiver else
        helper + '(' + ','.join([source] + arguments) + ')')


consumer = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1})'
tail = '.with(){order=cat(order,"W");return("ran")}'
for helper in helpers:
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"head"}')):
        for receiver in (False, True):
            form = 'receiver' if receiver else 'free'
            expression = call(helper, source, receiver)
            add('initial_' + kind + '_' + helper + '_' + form, 'return(' + expression + ')', 'initial-terminal')
            add('initial_' + kind + '_' + helper + '_' + form + '_with', 'order="";out=' + expression
                + '.with(){order=cat(order,"W");return(value.count())};return([out,order])', 'initial-first-with')
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        expression = call(helper, '{order=cat(order,"S");["head:tail"]}', receiver, True)
        add('extra_' + helper + '_' + form, 'order="";out=' + expression + consumer + tail
            + ';return([out,order])', 'excluded-helper-arity')
        expression = call(helper, '{items="bad";items+=1;["head"]}', receiver)
        add('needed_source_' + helper + '_' + form, 'order="";return(' + expression + consumer
            + '.coalesce("masked"))', 'needed-source-error')
for helper in ('split_each', 'filter_match'):
    for form, expression in (('free', helper + '(supply(["head"]))'),
                             ('receiver', 'supply(["head"]).' + helper + '()')):
        add('missing_' + helper + '_' + form, 'order="";out=' + expression + tail
            + ';return([out,order])', 'excluded-helper-arity')
for name, source in (('count', 'supply([1]).count()'), ('key_count', 'supply({"a":1}).count_keys()'),
                     ('length', 'supply("abc").length()'), ('hash', 'set_key(supply({}),"k",1)'),
                     ('copy', 'copy(supply(3))'), ('view', 'sorted_keys(supply({"a":1}))')):
    add('prior_' + name, 'order="";out=' + source + '.trim_each().with(){order=cat(order,"W");return(value)};return([out,order])', 'earlier-owner')
for form, expression in (('free', 'split_each(supply(["head:tail"]),{items="bad";items+=1;":"})'),
                         ('receiver', 'supply(["head:tail"]).split_each({items="bad";items+=1;":"})')):
    add('needed_delimiter_' + form, 'order="";return(' + expression + consumer + '.coalesce("masked"))', 'needed-delimiter-error')
for shape, expression in (('missing', 'supply()'), ('extra', 'supply(["head"],{order=cat(order,"F");1})')):
    for composed in (False, True):
        add('function_arity_' + shape + ('_composed' if composed else '_terminal'),
            'order="";out=' + expression + ('.trim_each()' + consumer + tail if composed else '')
            + ';return([out,order])', 'function-arity-composed' if composed else 'function-arity-terminal')
for kind, pattern in (('string', '"h"'), ('variable', 'needle'), ('block', '{order=cat(order,"P");"h"}')):
    for composed in (False, True):
        expression = 'supply(["head"]).filter_match(' + pattern + ')'
        add('pattern_source_' + kind + ('_composed' if composed else '_terminal'),
            'order="";needle="h";out=' + expression + (consumer + tail if composed else '')
            + ';return([out,order])', 'pattern-source-composed' if composed else 'pattern-source-terminal')
add('nested_scalar_kinds', 'items=[false,0,undef,"0",""];out=uniq(supply(items));return([out,items])', 'nested-kinds')
add('numeric_array_source', 'items=[3];return([trim_each(supply(items)),filter_nonempty(supply(items)),uniq(supply(items)),items])', 'numeric-kind')
add('source_before_rejection', 'order="";out=' + call('trim_each', '{order=cat(order,"S");[" tail "]}', True)
    + consumer + '.copy()' + tail + ';return([out,order])', 'source-before-rejection')
assert len(rows) == len({row['id'] for row in rows}) == 137
shared_path = ROOT / 'tests/fixtures/array_pipeline_callable_perl_selection_cases.json'
shared = json.loads(shared_path.read_bytes())
assert len(shared) == 41
(BASE / 'cases.json').write_text(json.dumps(shared + rows, indent=2) + '\n')
(BASE / 'profile-sources.json').write_text(json.dumps(rows, indent=2) + '\n')
template = ROOT / 'docs/checkpoints/array-pipeline-callable-selection-2026-11-11/observer.pl'
body = template.read_bytes()
(BASE / 'observer-template.pl.gz').write_bytes(gzip.compress(body, mtime=0))
(BASE / 'template-identity.json').write_text(json.dumps(dict(path=str(template.relative_to(ROOT)),
    bytes=len(body), sha256=hashlib.sha256(body).hexdigest()), indent=2) + '\n')
observer = body.decode().replace('array-pipeline-callable-selection-2026-11-11', BASE.name)
observer = observer.replace('ARRAY_PIPELINE_CALLABLE_', 'ARRAY_PIPELINE_CALLABLE_PERL_')
observer = observer.replace('ArrayPipelineCallableSelectionProbe', 'ArrayPipelineCallablePerlProbe')
observer = observer.replace('array-pipeline-callable-selection.spec', 'array-pipeline-callable-perl.spec')
(BASE / 'observer.pl').write_text(observer)
print('Unchanged qualified41 plus137 own Perl questions; no production edit')
