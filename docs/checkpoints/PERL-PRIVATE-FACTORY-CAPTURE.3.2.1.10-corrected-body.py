"""Readonly native/paired/full-source/provenance review of three optional-kind sites."""
import base64
import copy
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '61cca1cccff6027461e120e4236431d1bc7d20b1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBES = ('t/actionir_small_kind_probe.pl', 't/actionir_small_kind_symbolic_probe.pl', 't/actionir_small_kind_reference_probe.pl')
CACHE_PROBE = 't/actionir_uniform_container_cache_probe.pl'
TEST = 't/actionir_small_kind_capture.t'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1.json'
NATIVES = tuple(PREFIX + tail + '.json' for tail in ('native', 'symbolic-native', 'reference-native', 'reference-native-final'))
sha = lambda raw: hashlib.sha256(raw).hexdigest()
b64 = lambda raw: base64.b64encode(raw).decode()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert sys.argv[1:] in ([], ['--capture'])
proof_paths = set()


def read(tail):
    path = PREFIX + tail
    proof_paths.add(path)
    return json.loads((ROOT / path).read_bytes())


def channels(row):
    return tuple(base64.b64decode(row[key], validate=True) for key in ('stdout_base64', 'stderr_base64'))


def tap(row):
    out, err = channels(row)
    plans = re.findall(rb'^1\.\.(\d+)$', out, re.M)
    members = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', out, re.M)
    assert plans == [b'1135'] and [int(n) for _, n, _ in members] == list(range(1, 1136)), 'complete1135 TAP'
    return [label.decode() for _, _, label in members], [label.decode() for failed, _, label in members if failed]


original = old(MODULE)
source = (ROOT / MODULE).read_bytes()
# Reconstruct the whole accepted module with only the three declared owner edits.
expected = original
owners = {
    'infer': ('_infer_assignment_source_container_kind', '_lower_value_binding_source_expr'),
    'target': ('_uniform_binding_target_symbol', '_uniform_binding_hash_index_set_expr'),
    'candidate': ('_codeblock_variable_call_candidate', '_codeblock_runtime_binding_expr'),
}
native_calls = {
    'infer': b'   my $kind = $bare_symbol_kind->($1);',
    'target': b" return (($bare_symbol_kind->($name) // '') eq 'scalar') ? $name : undef",
    'candidate': b" return (($deps->{bare_symbol_kind}->($name) // '') eq 'scalar') ? 1 : 0",
}
bound_calls = {}
choices = {}
spans = {}
for key, (name, following) in owners.items():
    start = original.index(('sub ' + name + ' {').encode())
    end = original.index(('sub ' + following + ' {').encode(), start)
    block = original[start:end]
    selected = '$selected_kind' if key == 'candidate' else '$bare_symbol_kind'
    choice = ("ref(" + selected + ") eq 'CODE' ? " + selected + ' : sub { return ' + selected + '->(@_) }').encode()
    choices[key] = choice
    declaration = b'my $kind_callback = ' + choice + b';'
    if key == 'infer':
        new = b'   ' + declaration + b'\n   my $kind = _bind_emission_dependency($kind_callback)->($1);'
        changed = block.replace(native_calls[key], new, 1).replace(b'\n }\n\n return undef\n}', b'\n }\n return undef\n}', 1)
    elif key == 'target':
        new = b' ' + declaration + b"\n return ((_bind_emission_dependency($kind_callback)->($name) // '') eq 'scalar') ? $name : undef"
        changed = block.replace(native_calls[key], new, 1).replace(b'\n}\n\n', b'\n}\n', 1)
    else:
        comment = b' # A pure function cannot borrow callable names from its rule caller.'
        new = b' my $selected_kind = $deps->{bare_symbol_kind};\n ' + declaration + b"\n return ((_bind_emission_dependency($kind_callback)->($name) // '') eq 'scalar') ? 1 : 0"
        changed = block.replace(b'\n' + comment + b'\n', b'\n', 1)
        changed = changed.replace(('sub ' + name + ' {').encode(), ('sub ' + name + ' {').encode() + comment, 1)
        changed = changed.replace(native_calls[key], new, 1).replace(b'\n}\n\n', b'\n}\n', 1)
    assert block.count(native_calls[key]) == 1 and changed.count(new) == 1
    assert changed.count(b'\n') == block.count(b'\n'), 'native owner line count'
    expected = expected.replace(block, changed, 1)
    bound_calls[key] = new
assert source == expected, 'exact three owned optional-kind source changes'
assert source.count(b'\n') == original.count(b'\n')
for key, (name, following) in owners.items():
    start = source.index(('sub ' + name + ' {').encode())
    spans[key] = (start, source.index(('sub ' + following + ' {').encode(), start))
seed_raw = old(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 215 and seed['returncode'] == 0 and seed['unchanged']
base_files = {p: old(p) for p in seed['inputs']}
assert {p: sha(raw) for p, raw in base_files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in base_files.items() if p != MODULE)
first_probe = (ROOT / (PREFIX + 'reference-probe-first.pl')).read_bytes()
assert first_probe.count(b"no warnings 'redefine';") == 1
assert (ROOT / PROBES[2]).read_bytes() == first_probe.replace(b"no warnings 'redefine';", b'no warnings qw(redefine once);', 1), 'sole reference probe warning repair'
first_fixture = (ROOT / (PREFIX + 'fixture-first.t')).read_bytes()
old_map = b'qw(tied-selection map-replacement result-scalar bare-name spaced-name);'
new_map = b'qw(tied-selection map-replacement result-scalar bare-name spaced-name container-empty);'
assert first_fixture.count(old_map) == 1
assert (ROOT / TEST).read_bytes() == first_fixture.replace(old_map, new_map, 1), 'sole native cache oracle correction'
records = {}
tails = ('native', 'symbolic-native', 'reference-native', 'reference-native-final', 'before', 'before-final', 'current', 'symbolic-current', 'reference-current', 'fixture', 'consumers', 'container-cache-native')
for tail in tails:
    row = read(tail + '.json')
    files = dict(base_files)
    if tail in ('current', 'symbolic-current', 'reference-current', 'fixture', 'consumers'):
        files[MODULE] = source
    count = 1 if tail == 'native' else 2 if tail == 'symbolic-native' else 3
    paths = (CACHE_PROBE,) if tail == 'container-cache-native' else PROBES[:count]
    if tail in ('before', 'before-final', 'fixture', 'consumers'):
        paths += (TEST,) + NATIVES
    files.update({p: (ROOT / p).read_bytes() for p in paths})
    if tail == 'reference-native':
        files[PROBES[2]] = first_probe
    if tail == 'before':
        files[TEST] = first_fixture
    assert row['inputs'] == {p: sha(raw) for p, raw in files.items()}, 'exact full supplied input population: ' + tail
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == sha(seed_raw) and row['unchanged'] is True
    if tail in ('native', 'symbolic-native', 'reference-native', 'reference-native-final'):
        producer = tail + '-capture.py'
    elif tail == 'container-cache-native':
        producer = 'container-cache-capture.py'
    else:
        producer = 'capture.py' if tail == 'before' else 'capture-final.py'
    proof_paths.add(PREFIX + producer)
    assert row['producer_sha256'] == sha((ROOT / (PREFIX + producer)).read_bytes()), 'actual retained producer'
    if tail in ('before', 'before-final', 'fixture'):
        command = ['perl', '-Iperl', TEST]
    elif tail == 'consumers':
        command = seed['command'] + [TEST]
    else:
        probe = CACHE_PROBE if tail == 'container-cache-native' else PROBES[1] if tail.startswith('symbolic') else PROBES[2] if tail.startswith('reference') else PROBES[0]
        command = ['perl', '-Iperl', './' + probe] + (['observe'] if probe in (PROBES[0], CACHE_PROBE) else [])
    assert row['command'] == command, 'actual complete command'
    if tail not in ('before', 'before-final'):
        assert row['returncode'] == 0
        if tail not in ('reference-native', 'consumers'):
            assert not channels(row)[1]
    records[tail] = row
for tail in ('symbolic-native', 'reference-native', 'reference-native-final'):
    assert records[tail]['first_native_sha256'] == sha((ROOT / NATIVES[0]).read_bytes())
for tail in ('reference-native', 'reference-native-final'):
    assert records[tail]['symbolic_native_sha256'] == sha((ROOT / NATIVES[1]).read_bytes())
assert records['reference-native-final']['reference_first_sha256'] == sha((ROOT / NATIVES[2]).read_bytes())
assert channels(records['reference-native'])[0] == channels(records['reference-native-final'])[0], 'all original object stdout bytes'
assert channels(records['reference-native'])[1] == b'Name "LinkedSpec::ActionIR::MethodLowering::small_kind_reference" used only once: possible typo at ./t/actionir_small_kind_reference_probe.pl line 46.\n'
failure = read('reference-first-failure.json')
assert failure['returncode'] == 1 and failure['original_probe_sha256'] == sha(first_probe) and failure['original_native_sha256'] == sha((ROOT / NATIVES[2]).read_bytes())
assert b'AssertionError: native small optional-kind observation' in base64.b64decode(failure['actual_merged_output_base64'], validate=True)
repair = read('fixture-first-repair.json')
assert repair['first_fixture_sha256'] == sha(first_fixture) and repair['first_capture_sha256'] == sha((ROOT / (PREFIX + 'before.json')).read_bytes())
assert (repair['old_base64'], repair['new_base64']) == (b64(old_map), b64(new_map))
ledger = lambda tail: json.loads(channels(records[tail])[0])
native, current = ledger('native'), ledger('current')
assert len(native['callbacks']) == 18 and len(native['branches']) == 105 and len(native['authority']) == 6
assert current['callbacks'] == native['callbacks'] and current['branches'] == native['branches'], 'complete native ordinary observations'
assert current['cold'] == native['cold'] and native['cold']['returncode'] == 0 and not native['cold']['stderr']
assert native['cold']['value']['loaded_before'] == native['cold']['value']['loaded_after'] == 0 and len(native['cold']['value']['rows']) == 9
authority = copy.deepcopy(native['authority'])
for row in authority:
    assert row['eligible'] == [1] and row['parent_packet'] == row['actual_map_identity'] == 1
    row.update(eligible=[row['known']], parent_packet=0)
assert current['authority'] == authority, 'actual callback authority and ordinary identities'
symbolic = ledger('symbolic-native')['rows']
assert len(symbolic) == 42
expected_symbolic = copy.deepcopy(symbolic)
valid = [row for row in expected_symbolic if row['trace']]
assert len(valid) == 18
for row in valid:
    assert row['eligible'] == [1] and row['parent_packet'] == 1 and row['first_calls'] == 0
    row.update(eligible=[0], parent_packet=0)
assert ledger('symbolic-current')['rows'] == expected_symbolic, 'actual non-CODE dispatch remains opaque with complete native errors'
reference = ledger('reference-native-final')['rows']
assert len(reference) == 10 and all(row['trace'][0]['actual_input'] == 1 for row in reference)
expected_reference = copy.deepcopy(reference)
for row in expected_reference:
    assert row['eligible'] == [1] and row['input']['coercions'] == 1
    row.update(eligible=[0 if row['outcome'] == 'symbolic' else row['known']], parent_packet=0)
assert ledger('reference-current')['rows'] == expected_reference, 'actual object identity effects errors and authority'
names, first_failures = tap(records['before'])
final_names, failures = tap(records['before-final'])
after_names, after_failures = tap(records['fixture'])
assert names == final_names == after_names and len(first_failures) == 58 and len(failures) == 57
extra = 'small kind target/container-empty independent authored result'
assert first_failures == [name for name in names if name in set(failures) | {extra}], 'one first wrong authored oracle only'
assert records['before']['returncode'] != 0 and records['before-final']['returncode'] != 0
assert records['fixture']['returncode'] == 0 and not after_failures, 'positive fixture must pass'
cache = ledger('container-cache-native')['runs']
assert len(cache) == 2
for run, order in zip(cache, (('array', 'hash'), ('hash', 'array'))):
    assert run['command'] == ['perl', '-Iperl', './' + CACHE_PROBE, *order] and run['returncode'] == 0 and run['stderr'] == ''
    value = json.loads(run['stdout'])
    assert value == {'calls': [['item']], 'rows': [{'container': container, 'input': container + '(item)', 'kind_calls': int(index == 0), 'value': 'item' if index == 0 else None} for index, container in enumerate(order)]}, 'fresh native dynamic container cache diagnosis'

# Independent fault specifications: reconstruct every complete source, never run/import its writer.
cases = [('raw-infer', 15, 'small kind infer/known0 child cannot donate parent packet'),
         ('raw-target', 15, 'small kind target/known0 child cannot donate parent packet'),
         ('raw-candidate', 27, 'small kind candidate/known0 child cannot donate parent packet'),
         ('wrapper-identity', 7, 'small kind infer/known1 actual selected CODE controls eligibility'),
         ('argument-copy', 29, 'small kind infer/effect complete native observation'),
         ('object-coercion', 34, 'reference kind effect/known0 actual object argument identity survives'),
         ('code-validation', 19, 'small kind infer/kind-string complete native observation'),
         ('early-function-decision', 12, 'small kind candidate/function-name-absent independent authored result'),
         ('name-authority', 70, 'symbolic kind infer/qualified/known1 selected non-CODE remains opaque')]
inverse = read('inverses.json')
proof_paths.add(PREFIX + 'faults.py')
assert inverse['result'] == 'PASS' and inverse['module_sha256'] == sha(source) and inverse['producer_sha256'] == sha((ROOT / (PREFIX + 'faults.py')).read_bytes())
assert [row['name'] for row in inverse['rows']] == [name for name, _, _ in cases]
for entry, (name, count, reason) in zip(inverse['rows'], cases):
    assert entry['artifact'] == PREFIX + 'inverse-' + name + '.json'
    proof_paths.add(entry['artifact'])
    raw = (ROOT / entry['artifact']).read_bytes()
    assert sha(raw) == entry['artifact_sha256']
    fault = json.loads(raw)
    modifications = {}
    expected_specs = []
    for key in ([name[4:]] if name.startswith('raw-') else owners):
        start, end = spans[key]
        block = source[start:end]
        selected = '$selected_kind' if key == 'candidate' else '$bare_symbol_kind'
        arg = '$1' if key == 'infer' else '$name'
        call = ('_bind_emission_dependency($kind_callback)->(' + arg + ')').encode()
        if name.startswith('raw-'):
            before = bound_calls[key]
            after = native_calls[key] + b'\n'
            if key == 'candidate':
                after = b'\n' + after
        elif name == 'wrapper-identity':
            before = choices[key]
            after = ("ref(" + selected + ") eq 'CODE' ? sub { return " + selected + '->(@_) } : sub { return ' + selected + '->(@_) }').encode()
        elif name == 'argument-copy':
            before, after = call, ('(sub { my ($copy) = @_; return _bind_emission_dependency($kind_callback)->($copy) })->(' + arg + ')').encode()
        elif name == 'object-coercion':
            if key != 'candidate':
                continue
            before, after = call, b"_bind_emission_dependency($kind_callback)->(''.$name)"
        elif name == 'code-validation':
            before, after = b"ref($deps->{bare_symbol_kind}) eq 'CODE'", b'defined($deps->{bare_symbol_kind})'
        elif name == 'early-function-decision':
            if key != 'candidate':
                continue
            before, after = b" return $function_names->{$name} ? 1 : 0 if ref($function_names) eq 'HASH';", b''
        else:
            before, after = choices[key], ("ref(" + selected + ") eq 'CODE' ? " + selected + ' : \\&{' + selected + '}').encode()
        assert block.count(before) == 1
        modifications[key] = block.replace(before, after, 1)
        expected_specs.append({'owner': key, 'old_base64': b64(before), 'new_base64': b64(after)})
    mutated = source
    for key, (start, end) in sorted(spans.items(), key=lambda item: item[1][0], reverse=True):
        mutated = mutated[:start] + modifications.get(key, source[start:end]) + mutated[end:]
    assert fault['replacement'] == expected_specs and base64.b64decode(fault['module_base64'], validate=True) == mutated, 'exact whole-source fault reconstruction'
    expected_inputs = dict(records['fixture']['inputs'], **{MODULE: sha(mutated)})
    assert fault['inputs'] == expected_inputs and fault['unchanged'] and fault['producer_sha256'] == inverse['producer_sha256']
    assert fault['syntax']['command'] == ['perl', '-Iperl', '-c', MODULE] and fault['syntax']['returncode'] == 0 and b'syntax OK' in channels(fault['syntax'])[1]
    assert len(fault['probes']) == 3
    for index, row in enumerate(fault['probes']):
        assert row['command'] == ['perl', '-Iperl', './' + PROBES[index]] + (['observe'] if index == 0 else []) and row['returncode'] == 0 and not channels(row)[1]
        assert json.loads(channels(row)[0])
    fault_names, fault_failures = tap(fault['fixture'])
    assert fault_names == names, 'all fault assertion labels preserved'
    assert fault['fixture']['command'] == ['perl', '-Iperl', TEST] and fault['fixture']['returncode'] != 0
    assert fault_failures == fault['failures'] and len(fault_failures) == entry['failure_count'] == count
    assert reason == fault['required_reason'] == entry['required_reason'] and reason in fault_failures

before_raw = (ROOT / (PREFIX + 'before-trim.json')).read_bytes()
assert before_raw == old(CLAIM) and len(before_raw) == 78325, 'original full trim publication'
before = json.loads(before_raw)
assert len(before['claims']) == 1 and len(before['claims'][0]['durability']['inputs']) == 339
for entry in before['claims'][0]['durability']['inputs']:
    assert sha(old(entry['path'])) == entry['sha256'], 'original339 binding identity'
frozen = copy.deepcopy(before)
frozen['claims'][0]['durability'].update(mode='historical', revision=BASE)
assert (ROOT / CLAIM).read_bytes() == (json.dumps(frozen, indent=2) + '\n').encode(), 'sole original mode/revision change'
freeze = read('freeze.json')
proof_paths.update((PREFIX + 'freeze.py', PREFIX + 'before-trim.json', PREFIX + 'census-first.py'))
assert freeze['original_sha256'] == sha(before_raw) and freeze['after_sha256'] == sha((ROOT / CLAIM).read_bytes()) and freeze['producer_sha256'] == sha((ROOT / (PREFIX + 'freeze.py')).read_bytes())
assert freeze['intersections'] == [{'claim': CLAIM, 'name': 'inline-required-dropped-value-trim-isolation', 'bindings': 339, 'intersections': ['docs/knowledge/perl-method-trim-capture.md', 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md', MODULE]}]
baseline = read('baseline.json')
assert baseline['command'] == ['python3', 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-publish-claim.py'] and baseline['returncode'] == 0 and baseline['producer_sha256'] == freeze['producer_sha256']
assert not channels(baseline)[1] and b'PASS' in channels(baseline)[0]
census = read('census-first.json')
assert census['stdin_sha256'] == sha((ROOT / (PREFIX + 'census-first.py')).read_bytes()) and census['returncode'] == 1 and "KeyError: 'inputs'" in census['actual_merged_output']
# Full accepted census, including non-live records that need no inputs field.
intersections = []
original_claim_paths = subprocess.check_output(
    ['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
for relative in sorted(original_claim_paths):
    if relative == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json':
        continue
    data = json.loads(old(relative))
    for claim in data['claims']:
        durability = claim['durability']
        if durability.get('mode') != 'live':
            continue
        common = sorted(set(freeze['planned_writes']) & {entry['path'] for entry in durability['inputs']})
        if common:
            intersections.append({'claim': relative, 'name': claim['name'], 'bindings': len(durability['inputs']), 'intersections': common})
assert intersections == freeze['intersections'], 'complete original live intersection census'
for tail in ('consumer-review.py', 'book-review.py'):
    proof_paths.add(PREFIX + tail)
    result = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, ('actual readonly direct-dependent proof', tail, result.stderr)
consumer, book = read('consumer-review.json'), read('book-review.json')
assert (consumer['suites'], consumer['inputs'], consumer['assertions']) == (69, 223, 15093)
assert book['source_count'] == 89 and book['actual_controls'] == 3
proof_paths.update(PREFIX + tail for tail in ('reference-probe-first.pl', 'fixture-first.t', 'book.py', 'book.json', 'review.py'))
proof_paths.update((CLAIM, CACHE_PROBE, 'docs/knowledge/perl-method-trim-capture.md', 'docs/knowledge/perl-legacy-hash-kind-callback.md'))
inputs = dict(records['fixture']['inputs'])
inputs.update(book['source_inputs'])
inputs.update({p: sha((ROOT / p).read_bytes()) for p in proof_paths})
assert all(sha((ROOT / p).read_bytes()) == digest for p, digest in inputs.items())
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'input_metadata': inputs,
          'native_callbacks': 18, 'native_guards': 105, 'authority_rows': 6, 'cold_cases': 9, 'symbolic_rows': 42, 'valid_symbolic_rows': 18, 'object_rows': 10,
          'first_paired_red': 58, 'paired_assertions': 1135, 'original_red': failures, 'original_controls': 1078, 'fault_failures': [count for _, count, _ in cases],
          'consumer_suites': 69, 'consumer_inputs': 223, 'consumer_assertions': 15093, 'book_inputs': 89, 'original_bindings': 339, 'original_record_bytes': 78325,
          'scope': 'Three actual optional-kind boundaries only. Exact native CODE identity and opaque caller-local non-CODE dispatch preserve aliases, references, context, guards, full errors and cold behavior. Independent original full-source/paired/native/fault/consumer/book/population reconstruction; first warning/oracle/census failures and sole repairs remain exact. Native /o cache bug is diagnosed but unchanged, owned by .9; no authored-language failure inferred. No full-helper/private/parent/canonical admission. Standard public compatibility is separately supplemental.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'exact readonly composed review'
print('Small optional-kind review PASS1135/57 RED/1078 controls; native18/105/6/cold9/symbolic42/object10; faults9; supplied69/223/15093/book89/3/original339')
