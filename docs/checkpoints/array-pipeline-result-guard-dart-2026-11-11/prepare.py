"""Author independent Dart pipeline policy questions; import no peer outcomes."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '52cc3fa8073106154e8a3646ae27ee8e77d5d401'
assert not (BASE / 'cases.json').exists()
rows = []
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')


def add(identifier, body, question):
    rows.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
        input='x', rule='Value', profile_only=True, question=question))


def call(helper, source, receiver=False, excess=False):
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
    for form, expression in (('free', helper + '(["head"])'), ('receiver', '["head"].' + helper + '()')):
        add('missing_operand_' + helper + '_' + form, 'order="";out=' + expression
            + '.with(){order=cat(order,"W");return(value)};return([out,order])', 'excluded-missing-arity')
for name, expression in (('count', '[1].count()'), ('key_count', '{"a":1}.count_keys()'),
                         ('length', '"abc".length()'), ('hash', 'set_key({},"k",1)'),
                         ('copy', 'copy(3)'), ('view', 'sorted_keys({"a":1})')):
    add('prior_' + name, 'order="";out=' + expression
        + '.trim_each().with(){order=cat(order,"W");return(value)};return([out,order])', 'earlier-owner')
for receiver in (False, True):
    form = 'receiver' if receiver else 'free'
    expression = ('["head:tail"].split_each({items="bad";items+=1;":"})' if receiver
                  else 'split_each(["head:tail"],{items="bad";items+=1;":"})')
    add('needed_delimiter_' + form, 'order="";return(' + expression
        + '.set_key({order=cat(order,"K");"k"},1).coalesce("masked"))', 'needed-delimiter-error')
    expression = '["head"].filter_match(/[z-a]/)' if receiver else 'filter_match(["head"],/[z-a]/)'
    for composed in (False, True):
        add('invalid_range_' + form + ('_composed' if composed else '_terminal'), 'order="";return(' + expression
            + ('.set_key({order=cat(order,"K");"k"},1).coalesce("masked")' if composed else '') + ')', 'regex-error-policy')
add('nested_scalar_kinds', 'source=[false,0,undef,"0",""];out=uniq(source);return([out,source])', 'nested-kinds')
add('numeric_array_source', 'source=[3];return([trim_each(source),filter_nonempty(source),uniq(source),source])', 'numeric-kind')
assert len(rows) == 137
shared = json.loads(Path('tests/fixtures/array_pipeline_result_guard_cases.json').read_bytes())
assert len(shared) == 36
cases = shared + rows
assert len(cases) == len({row['id'] for row in cases}) == 173
for name, data in [('profile-sources.json', rows), ('cases.json', cases)]:
    (BASE / name).write_text(json.dumps(data, indent=2) + '\n')
prior = Path('dart/tool/probe_array_transform_results.dart')
body = prior.read_bytes()
(BASE / 'probe-template.dart.gz').write_bytes(gzip.compress(body, mtime=0))
(BASE / 'probe-template-identity.json').write_text(json.dumps(dict(path=str(prior), bytes=len(body), sha256=hashlib.sha256(body).hexdigest()), indent=2) + '\n')
probe = Path('dart/tool/probe_array_pipeline_results.dart')
assert not probe.exists()
source = body.decode().replace('ARRAY_TRANSFORM_DART', 'ARRAY_PIPELINE_DART')
source = source.replace('array_transform_dart_fresh', 'array_pipeline_dart_fresh')
source = source.replace('array-transform-result-guard', 'array-pipeline-result-guard')
probe.write_text(source)
print('Authored137 source-only Dart questions/shared36 and public four-route probe; no outcomes imported')
