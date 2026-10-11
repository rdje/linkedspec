"""Readonly reconstruction of bounded scalar-held receiver-copy repair evidence."""
import base64
import copy
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2b4e484a9bf27471d23d86f72aa25c7616b2bd3b'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_receiver_scalar_copy.t'
PROBE = 't/actionir_receiver_scalar_copy_probe.pl'
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()
checked = {}


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


def record(tail):
    return json.loads(read(PREFIX + tail + '.json'))


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


seed_raw = read(SEED)
assert seed_raw == blob(SEED)
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
original = {p: blob(p) for p in seed['inputs']}
assert len(original) == 182 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
for path, raw in original.items():
    if path != MODULE:
        assert read(path) == raw, 'unrelated supplied input changed'
inputs = dict(seed['inputs'], **{p: digest(read(p)) for p in (MODULE, TEST, PROBE)})
before_inputs = dict(inputs, **{MODULE: seed['inputs'][MODULE]})
assert len(inputs) == 184
change = """  my $first_args = $calls->[0]{args} || [];
  if ($first_method eq 'copy' && @$calls == 1
   && ref($first_args) eq 'ARRAY' && @$first_args == 0
   && ($receiver->{kind} // '') eq 'variable'
   && (($bare_symbol_kind->($receiver->{name}) // '') eq 'scalar')) {
   # Scalar bindings can hold either container family. Reuse function-form
   # copy's runtime dispatch before selecting an array or hash receiver chain.
   return $lower_ast_aggregate_call_node->({
    kind => 'call', name => 'copy', args => [$receiver],
    source_span => $node->{source_span},
   });
  }
"""
anchor = "  my $first_method = $calls->[0]{method} // '';\n  if (_is_tree_traversal_receiver_method($first_method))"
source = original[MODULE].decode()
assert source.count(anchor) == 1
expected_source = source.replace(anchor, anchor.split('\n')[0] + '\n' + change + anchor.split('\n')[1], 1)
assert read(MODULE) == expected_source.encode(), 'production exceeds bounded copy dispatch'
capture = read(PREFIX + 'capture.py')


def channel(row, population, command):
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == digest(seed_raw)
    assert row['producer_sha256'] == digest(capture), 'capture producer identity'
    assert row['inputs'] == population, 'supplied input population/content mismatch'
    assert row['command'] == command and row['unchanged'] is True
    return (base64.b64decode(row['stdout_base64'], validate=True),
            base64.b64decode(row['stderr_base64'], validate=True))


def tap(raw):
    assert re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE) == [b'50'], 'incomplete TAP plan'
    rows = re.findall(rb'^(not )?ok (\d+) - (.*)$', raw, re.MULTILINE)
    assert [int(n) for _, n, _ in rows] == list(range(1, 51)), 'incomplete TAP population'
    return [name.decode() for _, _, name in rows], [name.decode() for bad, _, name in rows if bad]


native = record('native')
out, err = channel(native, before_inputs, ['perl', '-Iperl', PROBE, 'observe'])
assert native['returncode'] == 0 and not err
first = json.loads(out)
captures = []
for mode, population in [('before', before_inputs), ('fixture', inputs)]:
    row = record(mode)
    out, err = channel(row, population, ['perl', '-Iperl', TEST])
    names, failures = tap(out)
    matches = re.findall(rb'^# RECEIVER_COPY_OBSERVATIONS (.*)$', err, re.MULTILINE)
    assert len(matches) == 1, 'missing actual observation channel'
    captures.append((row, names, failures, json.loads(matches[0])))
before, current = captures
assert before[3] == first, 'original immutable observations changed'
assert current[0]['returncode'] == 0 and not current[2], 'positive receiver-copy capture failed'
assert before[0]['returncode'] != 0
names = 'original-hash receiver-hash function-hash original-array receiver-array function-array original-empty-hash receiver-empty-hash original-empty-array receiver-empty-array multi-step-hash-count multi-step-array-count text-copy zero-copy'.split()
facts = 'hash_distinct hash_nested_shared function_hash_distinct function_hash_nested_shared array_distinct function_array_distinct'.split()
expected_names = []
for route in ('live', 'standalone'):
    expected_names += [route + ' result is an array', route + ' complete case population']
    expected_names += [route + ' ' + name for name in names + facts]
expected_names += ['live structured runtime error remains clear', 'typed AST receiver preserves hash value',
                   'typed AST override was actually used', 'typed AST ignores all poisoned source fields',
                   'legacy rule aggregate array snapshot remains exact', 'receiver copy still rejects an extra argument']
assert before[1] == current[1] == expected_names, 'paired assertion population changed'
expected_red = [route + ' ' + name for route in ('live', 'standalone')
                for name in ('receiver-hash', 'receiver-empty-hash', 'hash_distinct', 'hash_nested_shared')]
expected_red += ['typed AST receiver preserves hash value']
assert before[2] == expected_red, 'original semantic failure population changed'
value = {'k': 'v', 'nested': [1, 2]}
expected_value = [value, value, value, [1, 2], [1, 2], [1, 2], {}, {}, [], [], 2, 2, [], []]
expected_old = copy.deepcopy(expected_value)
expected_old[1] = expected_old[7] = []
for route in ('live', 'standalone'):
    assert first[route] == expected_old and current[3][route] == expected_value, 'public case value drift'
    assert first[route + '_identity'] == {f: (0 if f in ('hash_distinct', 'hash_nested_shared') else 1) for f in facts}
    assert current[3][route + '_identity'] == {f: 1 for f in facts}, 'snapshot identity contract changed'
assert first['typed_value'] == [] and current[3]['typed_value'] == {'k': 'v'}
for key in ('typed_calls', 'live_error', 'legacy_source', 'wrong_arity_source'):
    assert first[key] == current[3][key], 'unchanged control drift'
assert first['typed_calls'] > 0 and first['live_error'] is None and first['legacy_source'] == 'return [@Top]'
assert 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:copy' in current[3]['wrong_arity_source']
assert '__poison_' not in current[3]['typed_source'] and '__poison_' not in first['typed_source']
assert first['generated_source'] != current[3]['generated_source']
assert first['typed_source'] != current[3]['typed_source']

fault_producer = read(PREFIX + 'faults.py')
dispatch = "   return $lower_ast_aggregate_call_node->({\n    kind => 'call', name => 'copy', args => [$receiver],\n    source_span => $node->{source_span},\n   });"
assert change.count(dispatch) == 1
variants = {
    'remove-fix': expected_source.replace(change, '', 1),
    'ignore-tail': expected_source.replace(change, change.replace(' && @$calls == 1', '', 1), 1),
    'borrow-reference': expected_source.replace(change, change.replace(dispatch, "   return '$'.$receiver->{name};", 1), 1),
}
fault_index = record('inverses')
assert fault_index['producer_sha256'] == digest(fault_producer)
assert [r['name'] for r in fault_index['rows']] == list(variants), 'missing inverse'
for item in fault_index['rows']:
    name = item['name']
    path = PREFIX + 'inverse-' + name + '.json'
    raw = read(path)
    assert item['path'] == path and item['sha256'] == digest(raw)
    row = json.loads(raw)
    mutant = variants[name].encode()
    assert base64.b64decode(row['source_base64'], validate=True) == mutant, 'complete mutant source mismatch'
    assert row['producer_sha256'] == digest(fault_producer)
    assert row['fixture_sha256'] == digest(read(PREFIX + 'fixture.json'))
    assert row['inputs'] == dict(inputs, **{MODULE: digest(mutant)}), 'fault input population mismatch'
    assert row['unchanged'] is True
    syntax, tap_row = row['syntax'], row['tap']
    assert syntax['command'] == ['perl', '-c', '-Iperl', MODULE] and syntax['returncode'] == 0
    assert b'syntax OK' in base64.b64decode(syntax['stderr_base64'], validate=True)
    base64.b64decode(syntax['stdout_base64'], validate=True)
    assert tap_row['command'] == ['perl', '-Iperl', TEST] and tap_row['returncode'] != 0
    mutant_names, failed = tap(base64.b64decode(tap_row['stdout_base64'], validate=True))
    base64.b64decode(tap_row['stderr_base64'], validate=True)
    assert mutant_names == expected_names, 'source-fault assertion population changed'
    distinguishing = set(expected_red) if name == 'remove-fix' else {
        route + ' ' + fact for route in ('live', 'standalone')
        for fact in (('multi-step-hash-count', 'multi-step-array-count') if name == 'ignore-tail'
                     else ('text-copy', 'zero-copy', 'hash_distinct', 'array_distinct'))}
    assert failed == [n for n in expected_names if n in distinguishing], 'source-fault semantic reason changed'
    assert item['semantic_failures'] == failed

consumers = record('consumers')
out, err = channel(consumers, inputs, seed['command'] + [TEST])
assert consumers['returncode'] == 0, 'supplied consumer capture failed'
assert sum(p.endswith('.t') for p in consumers['command']) == 61
assert b'All tests successful.' in out and b'Result: PASS' in out and b'Files=61,' in out
assert not re.search(rb'^not ok ', out, re.MULTILINE)

freeze_producer = read(PREFIX + 'freeze.py')
freeze = record('freeze')
claim_path = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2.json'
before_path = PREFIX + 'before-regex-undef.json'
old_raw = read(before_path)
assert freeze['revision'] == BASE and freeze['claim'] == claim_path and freeze['before'] == before_path
assert freeze['producer_sha256'] == digest(freeze_producer) and freeze['original_sha256'] == digest(old_raw)
assert old_raw == blob(claim_path)
old = json.loads(old_raw)
historical = copy.deepcopy(old)
bindings = []
live = []
for claim in historical['claims']:
    durability = claim['durability']
    if durability.get('mode') == 'live':
        live.append(claim['name'])
        bindings.extend(durability['inputs'])
        durability.update(mode='historical', revision=BASE)
assert live == ['regex-undef-required-isolation'] and freeze['live_claims'] == live
assert len(bindings) == freeze['verified_bindings'] == 307
for entry in bindings:
    assert digest(blob(entry['path'])) == entry['sha256'], 'original binding identity changed'
assert json.loads(read(claim_path)) == historical, 'historical fields changed beyond mode/revision'
assert freeze['after_sha256'] == digest(read(claim_path))

report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'checked': checked, 'assertions': 50, 'public_cases_per_route': 14,
          'actual_execution_routes': ['live Get', 'standalone retained generated source', 'typed AST poisoned source'],
          'paired_original_semantic_failures': 9, 'paired_original_passing_controls': 41,
          'semantic_source_faults': 3, 'consumer_suites': 61, 'supplied_files': 184,
          'historical_bindings_preserved': 307,
          'generated_artifact_sha256': {route: digest(obs['generated_source'].encode())
                                      for route, obs in [('original', first), ('current', current[3])]},
          'scope': 'One exact12-line AST insertion for a scalar-bound variable, one copy call and zero arguments. '
                   'Complete first-native/original50-TAP/current50-TAP ledgers;14 cases per live/standalone route, '
                   'shallow outer/nested identity and typed AST poisoning, scalar/legacy aggregate/arity/multi-step controls. '
                   'Three complete syntax-valid184-input faults have independent exact semantic failure sets9/4/8. '
                   'All61 suites/184 inputs and original307 identities remain exact. Actual generated source consumed '
                   'by each test execution is retained in its observation channel. No legacy kind-callback repair, '
                   'other receiver population, required receiver capture or independent factory admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'readonly receiver-copy review drift'
print('Receiver-copy review PASS50; paired9RED/41controls/50GREEN; routes live/standalone/typed; faults9/4/8; consumers61/184; original307 preserved')
