"""Author Julia pipeline source questions without importing any peer outcomes."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '00a56ed62acbde73f066c7e00cb79ea23a720728'
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
for name, data in [('cases.json', cases), ('profile-sources.json', rows)]:
    (BASE / name).write_text(json.dumps(data, indent=2) + '\n')
prior = Path('docs/checkpoints/array-transform-result-guard-julia-2026-11-10/observer.jl')
body = prior.read_bytes()
(BASE / 'observer-template.jl.gz').write_bytes(gzip.compress(body, mtime=0))
(BASE / 'observer-template-identity.json').write_text(json.dumps(dict(path=str(prior), bytes=len(body), sha256=hashlib.sha256(body).hexdigest()), indent=2) + '\n')
text = body.decode().replace('JuliaArrayTransformProbe', 'JuliaArrayPipelineProbe')
text = text.replace('ARRAY_TRANSFORM_JULIA', 'ARRAY_PIPELINE_JULIA').replace('ArrayTransformGenerated', 'ArrayPipelineGenerated')
text = text.replace('array-transform-result-guard-julia-2026-11-10', 'array-pipeline-result-guard-julia-2026-11-11')
text = text.replace('array-transform-result-guard', 'array-pipeline-result-guard')
(BASE / 'observer.jl').write_text(text)
print('Authored137 Julia source-only questions/shared36 and retained own public four-route probe; no outcomes imported')
