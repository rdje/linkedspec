"""Author Rust pipeline policy questions and retain the public route instrument."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '74f3a4a1a21ba3cd1bf29579e3fcdb28cf3bd889'
target = BASE / 'profile-sources.json'
assert not target.exists()
rows = []
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')


def add(key, body, question):
    rows.append(dict(id=key, body=body, source='Value:: I {' + body + '}\n',
                     input='x', rule='Value', profile_only=True, question=question))


def call(helper, source, receiver=False, extra=False):
    args = ['":"'] if helper == 'split_each' else ['/^head/'] if helper == 'filter_match' else []
    if extra:
        args.append('{order=cat(order,"X");1}')
    return (source + '.' + helper + '(' + ','.join(args) + ')' if receiver
            else helper + '(' + ','.join([source] + args) + ')')


for helper in helpers:
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"head"}')):
        for receiver in (False, True):
            form = 'receiver' if receiver else 'free'
            expression = call(helper, source, receiver)
            add(f'initial_{kind}_{helper}_{form}', 'return(' + expression + ')', 'initial-source')
            add(f'initial_{kind}_{helper}_{form}_with',
                'order="";out=' + expression + '.with(){order=cat(order,"W");return(value.count())};return([out,order])', 'initial-source-with')
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        expression = call(helper, '{order=cat(order,"S");["head:tail"]}', receiver, extra=True)
        add('extra_' + helper + '_' + form,
            'order="";out=' + expression + '.set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")};return([out,order])', 'excluded-extra-arity')
        expression = call(helper, '{items="bad";items+=1;["head"]}', receiver)
        add('needed_source_' + helper + '_' + form,
            'order="";return(' + expression + '.set_key({order=cat(order,"K");"k"},1).coalesce("masked"))', 'needed-source-error')
    add('missing_' + helper + '_free',
        'order="";out=' + helper + '().with(){order=cat(order,"W");return(value)};return([out,order])', 'excluded-missing-arity')
for helper in ('split_each', 'filter_match'):
    for form, expression in (('free', helper + '(["head"])'), ('receiver', '["head"].' + helper + '()')):
        add('missing_operand_' + helper + '_' + form,
            'order="";out=' + expression + '.with(){order=cat(order,"W");return(value)};return([out,order])', 'excluded-missing-arity')
for name, source in (('count', '[1].count()'), ('key_count', '{"a":1}.count_keys()'),
                     ('length', '"abc".length()'), ('hash', 'set_key({},"k",1)'),
                     ('copy', 'copy(3)'), ('view', 'sorted_keys({"a":1})')):
    add('prior_' + name, 'order="";out=' + source + '.trim_each().with(){order=cat(order,"W");return(value)};return([out,order])', 'earlier-owner')
for receiver in (False, True):
    form = 'receiver' if receiver else 'free'
    expression = ('["head:tail"].split_each({items="bad";items+=1;":"})' if receiver
                  else 'split_each(["head:tail"],{items="bad";items+=1;":"})')
    add('needed_delimiter_' + form, 'order="";return(' + expression + '.set_key({order=cat(order,"K");"k"},1).coalesce("masked"))', 'needed-delimiter-error')
    expression = '["head"].filter_match(/[z-a]/)' if receiver else 'filter_match(["head"],/[z-a]/)'
    for composed in (False, True):
        add('invalid_range_' + form + ('_composed' if composed else '_terminal'),
            'order="";return(' + expression + ('.set_key({order=cat(order,"K");"k"},1).coalesce("masked")' if composed else '') + ')', 'regex-error-policy')
add('nested_scalar_kinds', 'source=[false,0,undef,"0",""];out=uniq(source);return([out,source])', 'nested-kinds')
add('numeric_array_source', 'source=[3];return([trim_each(source),filter_nonempty(source),uniq(source),source])', 'numeric-kind')
assert len(rows) == 137
target.write_text(json.dumps(rows, indent=2) + '\n')
prior = Path('docs/checkpoints/array-transform-result-guard-rust-2026-11-07/observer.rs')
raw = prior.read_bytes()
(BASE / 'observer-template.rs.gz').write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'observer-template-identity.json').write_text(json.dumps(dict(path=str(prior), bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest()), indent=2) + '\n')
text = raw.decode().replace('ARRAY_TRANSFORM_RUST', 'ARRAY_PIPELINE_RUST')
text = text.replace('array_transform_result_rust', 'array_pipeline_result_rust')
text = text.replace('array-transform-result', 'array-pipeline-result')
(BASE / 'observer.rs').write_text(text)
print('Authored137 independent Rust policy questions; shared36 stays unchanged')
