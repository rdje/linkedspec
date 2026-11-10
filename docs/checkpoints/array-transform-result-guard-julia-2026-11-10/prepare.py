"""Author Julia policy questions; no other backend's outcomes are inputs."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
profiles = []


def add(identifier, body, error=False):
    row = dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
               input='x', rule='Value', profile_only=True)
    if error:
        row['expected_error'] = 'binding_kind_mismatch'
    profiles.append(row)


def call(helper, source, receiver=False, optional=False, extra=False, operand_error=None):
    args = {'take': ['1'], 'take_last': ['1'], 'drop_front': ['1'],
            'drop_back': ['1'], 'slice': ['1', '1'], 'sorted': [],
            'reversed': [], 'concat_arrays': ['["second"]']}[helper][:]
    if optional:
        args.pop()
    if extra:
        args.append('{order=cat(order,"A");0}')
    if operand_error is not None:
        args[operand_error] = '{items="bad";items+=1;1}'
    return (source + '.' + helper + '(' + ','.join(args) + ')' if receiver else
            helper + '(' + ','.join([source] + args) + ')')


helpers = ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted',
           'reversed', 'concat_arrays')
for helper in helpers:
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":1}')):
        for receiver in (False, True):
            add('initial_' + kind + '_' + helper + ('_receiver' if receiver else '_free'),
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
    add(identifier, 'order="";out=' + source + '.take({order=cat(order,"A");1})'
        '.set_key({order=cat(order,"K");"k"},1)'
        '.with(){order=cat(order,"W");return("ran")};return([out,order])')

assert len(profiles) == 104


def needed(identifier, expression):
    add(identifier, 'return(' + expression +
        '.set_key("k",1).coalesce("masked"))', error=True)


for helper in helpers[1:]:  # Shared37 already owns take source/count terminal/composed errors.
    needed('needed_' + helper + '_source_free',
           call(helper, '{items="bad";items+=1;["head","tail"]}'))
for helper in ('take_last', 'drop_front', 'drop_back'):
    needed('needed_' + helper + '_count_free', call(helper, '["head","tail"]', operand_error=0))
for index, role in enumerate(('start', 'count')):
    needed('needed_slice_' + role + '_free', call('slice', '["head","tail"]', operand_error=index))
needed('needed_concat_arrays_second_free', call('concat_arrays', '["head"]', operand_error=0))
needed('needed_reversed_source_receiver', call('reversed', '{items="bad";items+=1;["head"]}', True))
needed('needed_slice_count_receiver', call('slice', '["head","tail"]', True, operand_error=1))
assert len(profiles) == 119
shared = json.loads((ROOT / 'tests/fixtures/array_transform_result_guard_cases.json').read_bytes())
assert len(shared) == 37
cases = shared + profiles
assert len(cases) == len({row['id'] for row in cases}) == 156
for name, rows in (('profile-sources.json', profiles), ('cases.json', cases)):
    target = BASE / name
    assert not target.exists()
    target.write_text(json.dumps(rows, indent=2) + '\n')
fixture = ROOT / 'tests/fixtures/array_transform_result_guard_julia_cases.json'
assert not fixture.exists()
fixture.write_bytes((BASE / 'cases.json').read_bytes())
template = ROOT / 'docs/checkpoints/hash-value-result-guard-julia-2026-11-07/observer.jl'
observer = template.read_text().replace('JuliaHashValueProbe', 'JuliaArrayTransformProbe')
observer = observer.replace('HASH_VALUE_JULIA', 'ARRAY_TRANSFORM_JULIA')
observer = observer.replace('HashValueGenerated', 'ArrayTransformGenerated')
observer = observer.replace('hash-value-result-guard-julia-2026-11-07', 'array-transform-result-guard-julia-2026-11-10')
observer = observer.replace('hash-value-result-guard', 'array-transform-result-guard')
(BASE / 'observer.jl').write_text(observer)
print('Unchanged37 plus119 own source-only Julia controls authored; no SDK use or outcomes')
