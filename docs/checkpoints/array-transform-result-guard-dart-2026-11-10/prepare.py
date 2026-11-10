"""Author finite Dart policies without importing another backend's outcomes."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
profiles = []


def add(identifier, body):
    profiles.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
                         input='x', rule='Value', profile_only=True))


def call(helper, source, receiver=False, optional=False, extra=False):
    operands = {'take': ['1'], 'take_last': ['1'], 'drop_front': ['1'],
                'drop_back': ['1'], 'slice': ['1', '1'], 'sorted': [],
                'reversed': [], 'concat_arrays': ['["second"]']}[helper][:]
    if optional:
        operands.pop()
    if extra:
        operands.append('{order=cat(order,"A");0}')
    return (source + '.' + helper + '(' + ','.join(operands) + ')' if receiver else
            helper + '(' + ','.join([source] + operands) + ')')


helpers = ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted',
           'reversed', 'concat_arrays')
for helper in helpers:
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":1}')):
        for receiver in (False, True):
            suffix = '_receiver' if receiver else '_free'
            add('initial_' + kind + '_' + helper + suffix,
                'return(' + call(helper, source, receiver) + ')')
        add('initial_' + kind + '_' + helper + '_with',
            'order="";out=' + call(helper, source, True) +
            '.with(){order=cat(order,"W");return(value.count())};return([out,order])')
    for receiver in (False, True):
        suffix = '_receiver' if receiver else '_free'
        add('extra_' + helper + suffix,
            'order="";out=' + call(helper, '{order=cat(order,"S");["head","tail"]}',
                                   receiver, extra=True) +
            '.set_key({order=cat(order,"K");"k"},1)'
            '.with(){order=cat(order,"W");return("ran")};return([out,order])')
        if helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
            add('optional_' + helper + suffix,
                'order="";out=' + call(helper, '["head","tail"]', receiver, optional=True) +
                '.with(){order=cat(order,"W");return(value)};return([out,order])')

for identifier, source in (('prior_count', '[1].count()'),
                           ('prior_key_count', '{"k":1}.count_keys()'),
                           ('prior_length', '"abc".length()'),
                           ('prior_view', 'sorted_keys({"k":1})'),
                           ('prior_copy', 'copy(3)'), ('prior_array', 'array(1)')):
    add(identifier, 'order="";out=' + source +
        '.take({order=cat(order,"A");1})'
        '.set_key({order=cat(order,"K");"k"},1)'
        '.with(){order=cat(order,"W");return("ran")};return([out,order])')

assert len(profiles) == 104
shared = json.loads((ROOT / 'tests/fixtures/array_transform_result_guard_cases.json').read_bytes())
assert len(shared) == 37
cases = shared + profiles
assert len(cases) == len({row['id'] for row in cases}) == 141
for name, rows in (('profile-sources.json', profiles), ('cases.json', cases)):
    target = BASE / name
    assert not target.exists()
    target.write_text(json.dumps(rows, indent=2) + '\n')

probe = ROOT / 'dart/tool/probe_array_transform_results.dart'
assert not probe.exists()
source = (ROOT / 'dart/tool/probe_hash_value_results.dart').read_text()
source = source.replace('HASH_VALUE_DART', 'ARRAY_TRANSFORM_DART')
source = source.replace('hash_value_dart_fresh', 'array_transform_dart_fresh')
source = source.replace('hash-value-result-guard', 'array-transform-result-guard')
probe.write_text(source)
print('Authored unchanged37 and104 own source-only Dart controls; no outcomes imported')
