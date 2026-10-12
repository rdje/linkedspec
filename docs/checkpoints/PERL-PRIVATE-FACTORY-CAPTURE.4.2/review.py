"""Readonly complete optional FlowExpr review; --capture publishes once."""
import base64
import copy
import gzip
import hashlib
import io
import json
import re
import subprocess
import sys
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '708c1afa04bb10aeacbdaf0a8133a95f380df434'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.2/'
MODULE = 'perl/LinkedSpec/ActionIR/FlowExpr.pm'
NATIVE = 't/actionir_flow_kind_native.pl'
FIXTURE = 't/actionir_flow_kind_capture.t'
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
read = lambda path: (ROOT / path).read_bytes()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
inputs = {}


def retain(path):
    raw = read(path)
    inputs[path] = {'sha256': sha(raw), 'mode': (ROOT / path).stat().st_mode & 0o7777}
    return raw


def load(tail):
    raw = retain(PREFIX + tail)
    return json.loads(gzip.decompress(raw) if tail.endswith('.gz') else raw)


def capsule(tail, metadata, current=False):
    data = load(tail)
    assert metadata == {p: {'sha256': item['sha256'], 'mode': item['mode']}
                        for p, item in data.items()}, ('complete capsule membership/modes', tail)
    for path, item in data.items():
        raw = decode(item['bytes_base64'])
        assert sha(raw) == item['sha256'], ('recoverable input bytes', path)
        assert item['mode'] in (0o640, 0o644, 0o750, 0o755)
        if current:
            assert retain(path) == raw and inputs[path]['mode'] == item['mode'], ('current supplied input', path)
    return data


def tap(channel, expected_failures):
    out, err = decode(channel['stdout_base64']), decode(channel['stderr_base64'])
    rows = re.findall(rb'^(not )?ok (\d+) - (.*)$', out, re.M)
    assert re.findall(rb'^1\.\.(\d+)$', out, re.M) == [b'762'], 'complete paired/fault plan'
    assert [int(row[1]) for row in rows] == list(range(1, 763)), 'complete paired/fault assertions'
    failures = [{'number': int(number), 'name': name.decode()} for no, number, name in rows if no]
    assert len(failures) == expected_failures, 'actual distinguishing semantic failure population'
    assert not re.search(rb'^Bail out!|^Dubious', out, re.M)
    if expected_failures:
        assert channel['returncode'] != 0 and b'Failed test' in err
    else:
        assert channel['returncode'] == 0 and not err
    return failures, [name.decode() for _, _, name in rows]


# Fixed Git census and the whole original publication, including every binding.
preservation = load('preservation.json')
assert preservation['result'] == 'PASS' and preservation['base'] == BASE
assert preservation['producer_sha256'] == sha(retain(PREFIX + 'preserve.py'))
namespace = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
assert [row['path'] for row in preservation['census']] == sorted(namespace), 'fixed original claim namespace'
selected = []
for row in preservation['census']:
    raw = old(row['path'])
    assert sha(raw) == row['sha256']
    record, intersections = json.loads(raw), []
    for index, claim in enumerate(record['claims']):
        durability = claim['durability']
        if durability.get('mode') != 'live':
            continue
        hits = sorted(set(preservation['owned_bound_paths']) & {item['path'] for item in durability['inputs']})
        if hits:
            for item in durability['inputs']:
                assert sha(old(item['path'])) == item['sha256'], 'complete original accepted binding recoverability'
            intersections.append({'claim_index': index, 'paths': hits, 'bindings': len(durability['inputs'])})
    assert row['intersections'] == intersections
    if intersections:
        selected.append(row['path'])
assert selected == ['docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.0.json']
prior = preservation['selected'][0]
original_claim = load('before-PERL-PRIVATE-FACTORY-CAPTURE.4.0.json')
assert retain(prior['before']) == old(prior['path']), 'complete original publication bytes'
assert prior['bytes'] == 112004 and prior['sha256'] == sha(read(prior['before']))
assert sum(row['bindings'] for row in prior['intersections']) == 451
historical = copy.deepcopy(original_claim)
for row in prior['intersections']:
    historical['claims'][row['claim_index']]['durability'].update(mode='historical', revision=BASE)
assert json.loads(retain(prior['path'])) == historical, 'only historical durability mode/revision changed'
baseline = load('baseline.json')
assert preservation['baseline_sha256'] == sha(read(PREFIX + 'baseline.json'))
assert baseline['returncode'] == 0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64']) == b'Required FlowExpr final publication PASS: 451 live inputs; 112004 bytes;both original uncommitted publications remain exact\n'

# Independently join every native row with the actual complete JSON channels.
native = {}
for stage, producer in [('before', 'observe.py'), ('after', 'observe-after.py')]:
    record = load(stage + '-native.json')
    assert record['base'] == BASE and record['result'] == 'captured'
    assert record['producer_sha256'] == sha(retain(PREFIX + producer))
    cap = capsule(stage + '-native-inputs.json.gz', record['inputs'], stage == 'after')
    assert len(cap) == 100 and record['capsule_sha256'] == sha(read(PREFIX + stage + '-native-inputs.json.gz'))
    assert record['instrument_sha256'] == cap[NATIVE]['sha256'] == sha(retain(NATIVE)), 'unchanged first native instrument'
    expected_paths = set(subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'perl'], cwd=ROOT, text=True).splitlines())
    expected_paths.update([NATIVE, PREFIX + producer, 'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh', '.knowledge_map.conf'])
    assert set(cap) == expected_paths, 'complete original parent Perl runtime namespace'
    if stage == 'before':
        assert decode(cap[MODULE]['bytes_base64']) == old(MODULE), 'native before production edits'
    channels = load(stage + '-native-data.json.gz')
    assert record['data_sha256'] == sha(read(PREFIX + stage + '-native-data.json.gz'))
    commands = [['perl', '-c', '-Iperl', NATIVE], ['perl', '-Iperl', NATIVE], ['perl', '-Iperl', NATIVE], ['perl', '-Iperl', NATIVE, 'cold'], ['perl', '-Iperl', NATIVE, 'cold']]
    assert [row['command'] for row in channels] == commands and all(row['returncode'] == 0 for row in channels)
    assert not decode(channels[0]['stdout_base64']) and decode(channels[0]['stderr_base64']) == (NATIVE + ' syntax OK\n').encode()
    for row in channels[1:]:
        assert not decode(row['stderr_base64'])
        assert json.loads(decode(row['stdout_base64'])) == row['observation'], 'actual complete native JSON channel'
        assert set(row['observation']['loaded_project_modules']) <= set(cap)
    assert channels[1] == channels[2] and channels[3] == channels[4], 'exact complete native recurrence'
    native[stage] = (cap, channels)
native_counts = {}
for index, mode in [(1, 'warm'), (3, 'cold')]:
    before = native['before'][1][index]['observation']
    after = native['after'][1][index]['observation']
    assert before['mode'] == after['mode'] == mode
    assert before['emission_loaded'] == after['emission_loaded'] == (mode == 'warm')
    assert before['trace_loaded'] == after['trace_loaded'] == 0
    assert len(before['rows']) == len(after['rows']) == 150
    labels = [row['label'] for row in before['rows']]
    assert len(set(labels)) == 150 and labels == [row['label'] for row in after['rows']]
    assert sum(len(row['native']['calls']) for row in before['rows']) == 78
    for original, current in zip(before['rows'], after['rows']):
        assert {k: v for k, v in original.items() if k != 'authority'} == {k: v for k, v in current.items() if k != 'authority'}, 'complete native compatibility ledger'
        assert all(call['context'] == 'scalar' and not call['first_is_caller_slot'] for call in current['native']['calls'])
        if mode == 'cold':
            assert original['authority'] == current['authority']
            continue
        options = current['options']
        actual_code = options.get('variant', 'code') == 'code'
        expected = [{'actual_callback': int(actual_code), 'eligible': int(bool(actual_code and options.get('known')))} for call in current['authority']['calls']]
        assert current['authority']['calls'] == expected, 'actual selected CODE identity or opaque native delegation'
        assert current['authority']['parent_packet'] == 0, 'no child publication donated to parent'
        assert current['authority']['child_packets'] == int(current['label'].startswith('child/') and bool(options.get('known'))), 'only registered matching actual child retains a packet'
        assert all(call == {'actual_callback': 0, 'eligible': 1} for call in original['authority']['calls'])
        assert original['authority']['parent_packet'] == int(bool(original['native']['calls']) and original['native']['fatal'] is None)
        assert original['authority']['child_packets'] == 0
    fatal_rows = [row for row in after['rows'] if row['native']['fatal'] is not None]
    assert len(fatal_rows) == 28
    assert sum(row['native']['fatal_is_original'] for row in fatal_rows) == 4
    assert all(row['label'].startswith('selection/') or row['options'].get('effect') == 'fatal' for row in fatal_rows)
    native_counts[mode] = {'rows': 150, 'scalar_callbacks': 78}

# Reconstruct the sole runtime patch and preserve all original function lines.
original_source = old(MODULE)
source = retain(MODULE)
expected_source = original_source
for container in (b'array', b'hash'):
    opening = next(line for line in original_source.splitlines(keepends=True)
                   if b'  if ($trimmed =~ /^' + container + b'\\s*\\(\\s*([A-Za-z_' in line)
    setup = b'  my $kind_callback = _bind_optional_emission_dependency($bare_symbol_kind, sub { $bare_symbol_kind->(@_) }); ' + opening[2:]
    expected_source = expected_source.replace(opening, setup, 1)
expected_source = expected_source.replace(b'&& (($bare_symbol_kind->($1)', b'&& (($kind_callback->($1)')
addition = b'''\n# Only actual CODE identities carry registration. Other second selections use
# the caller's native dispatch context and original invocation line.
sub _bind_optional_emission_dependency {
 my ($selected, $native_call) = @_;
 return _bind_emission_dependency(ref($selected) eq 'CODE' ? $selected : $native_call);
}
'''
position = expected_source.rfind(b'\n1;')
expected_source = expected_source[:position] + addition + expected_source[position:]
assert source == expected_source, 'exact two guarded optional invocations and appended helper only'
for name in re.findall(rb'^sub (\w+) \{', original_source, re.M):
    token = b'sub ' + name + b' {'
    assert source[:source.index(token)].count(b'\n') == original_source[:original_source.index(token)].count(b'\n'), 'original global function line locations'
assert retain('perl/LinkedSpec/RuleIR/EmitContext.pm') == old('perl/LinkedSpec/RuleIR/EmitContext.pm'), 'default selection owner unchanged'

# Preserve both rejected candidates and distinguish their executed identities.
paired = {}
selections = [('before', 'run.py', 154), ('after', 'run.py', 48),
              ('final-before', 'final-run.py', 154), ('final-after', 'final-run.py', 266),
              ('accepted-after', 'accepted-run.py', 0)]
for label, producer, failures in selections:
    record = load(label + '.json')
    assert record['stage'] == ('before' if label.endswith('before') else 'after')
    expected_result = 'GREEN' if label in ('after', 'accepted-after') else 'RED'
    assert record['result'] == expected_result, 'declared first target or actual final result'
    assert record['producer_sha256'] == sha(retain(PREFIX + producer))
    cap = capsule(label + '-inputs.json.gz', record['inputs'], label == 'accepted-after')
    assert len(cap) == 105 and record['capsule_sha256'] == sha(read(PREFIX + label + '-inputs.json.gz'))
    channels = load(label + '-channels.json.gz')
    assert record['channels_sha256'] == sha(read(PREFIX + label + '-channels.json.gz'))
    assert channels[0]['command'] == ['perl', '-c', '-Iperl', FIXTURE]
    assert channels[0]['returncode'] == 0 and not decode(channels[0]['stdout_base64'])
    assert decode(channels[0]['stderr_base64']) == (FIXTURE + ' syntax OK\n').encode()
    assert channels[1]['command'] == ['perl', '-Iperl', FIXTURE]
    failed, labels = tap(channels[1], failures)
    assert failed == record['failures'] and record['assertions'] == record['plan'] == 762
    assert record['controls'] == 762 - failures
    paired[label] = (cap, failed, labels)
assert paired['before'][1] == paired['final-before'][1], 'unchanged semantic original RED names/numbers'
assert paired['before'][2] == paired['after'][2]
assert paired['final-before'][2] == paired['final-after'][2] == paired['accepted-after'][2], 'identical final assertions'
assert decode(paired['before'][0][MODULE]['bytes_base64']) == decode(paired['final-before'][0][MODULE]['bytes_base64']) == original_source
first_fixture = decode(paired['before'][0][FIXTURE]['bytes_base64'])
display_fixture = first_fixture.replace(
    b'  my $label = $row->{label};\n',
    b"  my $label = $row->{label};\n  my $display = $label;\n  $display =~ s/([^\\x00-\\x7f])/sprintf('U+%04X', ord($1))/eg;\n", 1)
display_fixture = display_fixture.replace(b'"$mode/$label ', b'"$mode/$display ').replace(b'"$label ', b'"$display ')
assert retain(FIXTURE) == display_fixture, 'only ASCII test-name display changes in the final fixture'
for label in ('final-before', 'final-after', 'accepted-after'):
    assert decode(paired[label][0][FIXTURE]['bytes_base64']) == display_fixture
before_cap, after_cap = paired['final-before'][0], paired['accepted-after'][0]
excluded = {PREFIX + 'final-run.py', PREFIX + 'accepted-run.py'}
assert set(before_cap) - excluded == set(after_cap) - excluded
assert [p for p in before_cap if p not in excluded and before_cap[p] != after_cap[p]] == [MODULE], 'only production changes between final semantic paired executions'
assert all(any(row['name'].endswith(tail) for tail in [
    'captures each actual callback independently with only its own registration',
    'cannot lend a dependency publication to its enclosing callback',
    "retains only an actually registered matching child's own packet"]) for row in paired['before'][1])
first_failure, second_failure = load('first-after-failure.json'), load('second-after-failure.json')
assert (first_failure['actual_outer_session'], first_failure['actual_outer_returncode']) == (6194, 1)
assert first_failure['producer_sha256'] == sha(read(PREFIX + 'run.py'))
assert all('preserves complete native' in row['name'] for row in paired['after'][1])
assert (second_failure['actual_outer_session'], second_failure['actual_outer_returncode']) == (92369, 1)
assert second_failure['producer_sha256'] == sha(read(PREFIX + 'final-run.py'))
assert len(second_failure['scope_probes']) == 2
assert all(row['returncode'] == 255 and not decode(row['stdout_base64']) for row in second_failure['scope_probes'])
assert b'Global symbol "$kind_callback"' in decode(second_failure['scope_probes'][0]['stderr_base64'])
assert b'Global symbol "$callback"' in decode(second_failure['scope_probes'][1]['stderr_base64'])

# Reconstruct the complete fault sources and check their full actual TAP.
faults = load('faults.json')
assert faults['result'] == 'PASS' and faults['producer_sha256'] == sha(retain(PREFIX + 'faults.py'))
assert faults['positive_capsule_sha256'] == sha(read(PREFIX + 'accepted-after-inputs.json.gz'))
assert faults['inputs'] == {p: {'sha256': item['sha256'], 'mode': item['mode']} for p, item in paired['accepted-after'][0].items()}
rows = load('faults-data.json.gz')
assert faults['data_sha256'] == sha(read(PREFIX + 'faults-data.json.gz'))
assert load('faults-reached.json.gz') == rows
variants = {'inverse': original_source}
lines, old_lines = source.splitlines(keepends=True), original_source.splitlines(keepends=True)
for container in (b'array', b'hash'):
    position = next(i for i, line in enumerate(lines)
                    if b'my $kind_callback = _bind_optional_emission_dependency' in line and b'/^' + container in line)
    variants['bypass-' + container.decode()] = source.replace(b''.join(lines[position:position + 2]), b''.join(old_lines[position:position + 2]), 1)
optional_start = source.index(b'sub _bind_optional_emission_dependency {\n')
optional_end = source.index(b'\n1;', optional_start)
optional = source[optional_start:optional_end]
actual_selection = b"ref($selected) eq 'CODE' ? $selected : $native_call"
variants['opaque-actual-code'] = source[:optional_start] + optional.replace(actual_selection, b'$native_call') + source[optional_end:]
resolved = (rb"my $resolved = ref($selected) ? $selected : \&{$selected}; "
            b"return _bind_emission_dependency(ref($resolved) eq 'CODE' ? $resolved : $native_call);")
variants['named-authority'] = source[:optional_start] + optional.replace(b'return _bind_emission_dependency(' + actual_selection + b');', resolved) + source[optional_end:]
selection = (b" my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')\n"
             b"  ? $deps->{bare_symbol_kind}\n  : sub { return undef };\n")
single = (b" my $bare_symbol_kind = ref($deps) eq 'HASH' ? $deps->{bare_symbol_kind} : undef;\n"
          b" $bare_symbol_kind = sub { return undef } unless ref($bare_symbol_kind) eq 'CODE';\n"
          b" # Deliberate one-read selection fault.\n")
variants['collapsed-map-fetches'] = source.replace(selection, single, 1)
variants['reacquire-after-trim'] = source.replace(b'_bind_optional_emission_dependency($bare_symbol_kind,', b'_bind_optional_emission_dependency($deps->{bare_symbol_kind},')
helper_start = source.index(b'sub _bind_emission_dependency {\n')
helper_end = source.index(b'\n# Only actual CODE identities', helper_start)
helper = source[helper_start:helper_end]
changed_helpers = {
    'copied-argument-slots': helper.replace(b'return sub {\n', b'return sub {\n  my @args = @_;\n', 1).replace(b'($callback, @_)', b'($callback, @args)').replace(b'$callback->(@_)', b'$callback->(@args)'),
    'localized-error-effects': helper.replace(b'return sub {\n', b'return sub {\n  local $@;\n', 1),
    'twice-only-effects': helper.replace(b'return sub {\n', b'return sub {\n  $callback->(@_);\n', 1),
}
variants.update({name: source[:helper_start] + changed + source[helper_end:] for name, changed in changed_helpers.items()})
variants['eager-emission-loading'] = source[:optional_start] + optional.replace(b' my ($selected, $native_call) = @_;', b' my ($selected, $native_call) = @_; require LinkedSpec::ActionIR::SourceEmissions;') + source[optional_end:]
variants['public-map-rebinding'] = source.replace(selection, selection[:-1] + b' $deps->{bare_symbol_kind} = sub { return undef };\n', 1)
variants['native-diagnostic-shift'] = decode(paired['after'][0][MODULE]['bytes_base64'])
variants['condition-lexical-scope'] = decode(paired['final-after'][0][MODULE]['bytes_base64'])
counts = [154, 77, 77, 56, 24, 156, 184, 8, 156, 450, 2, 284, 48, 266]
assert [row['name'] for row in rows] == list(variants) and len(rows) == 14
fault_results = []
for row, failures in zip(rows, counts):
    assert decode(row['module_base64']) == variants[row['name']], 'exact complete semantic source variant'
    assert row['module_sha256'] == sha(variants[row['name']]) and row['unchanged'] is True
    syntax, channel = row['channels']
    assert syntax['command'] == ['perl', '-c', '-Iperl', MODULE] and syntax['returncode'] == 0
    assert not decode(syntax['stdout_base64']) and decode(syntax['stderr_base64']) == (MODULE + ' syntax OK\n').encode()
    assert channel['command'] == ['perl', '-Iperl', FIXTURE]
    failed, labels = tap(channel, failures)
    assert failed == row['failures'] and labels == paired['accepted-after'][2], 'full actual source-fault failures'
    assert row['assertions'] == 762 and row['plan'] == ['762']
    if row['name'] == 'inverse':
        assert failed == paired['final-before'][1], 'sole inverse restores every original failure name/number'
    fault_results.append({'name': row['name'], 'failures': failures})
assert faults['variants'] == [{'name': row['name'], 'assertions': 762, 'failures': len(row['failures']), 'module_sha256': row['module_sha256']} for row in rows]

consumer = load('consumers.json')
assert consumer['result'] == 'PASS' and consumer['base'] == BASE and consumer['returncode'] == 0 and consumer['unchanged'] is True
assert consumer['producer_sha256'] == sha(retain(PREFIX + 'consumers.py'))
seed = json.loads(retain(consumer['seed']))
assert read(consumer['seed']) == old(consumer['seed'])
seed_channel_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-consumers-channels.json.gz'
seed_channel_raw = retain(seed_channel_path)
assert seed_channel_raw == old(seed_channel_path)
seed_channels = json.loads(gzip.decompress(seed_channel_raw))
assert sha(read(consumer['seed'])) == consumer['seed_sha256']
cap = capsule('consumers-inputs.json.gz', {p: {'sha256': h, 'mode': consumer['modes'][p]} for p, h in consumer['inputs'].items()}, True)
assert len(cap) == 263 and consumer['capsule_sha256'] == sha(read(PREFIX + 'consumers-inputs.json.gz'))
assert consumer['command'] == seed['command'] + [FIXTURE]
assert all(consumer['inputs'][p] == h for p, h in seed['inputs'].items() if p != MODULE), 'unchanged complete accepted consumer inputs'
channels = load('consumers-channels.json.gz')
assert consumer['channels_sha256'] == sha(read(PREFIX + 'consumers-channels.json.gz'))
assert channels['command'] == consumer['command'] and channels['returncode'] == 0
out, err = decode(channels['stdout_base64']), decode(channels['stderr_base64'])
assert err == decode(seed_channels['stderr_base64']) and b'All tests successful.' in out and b'Result: PASS' in out
groups, current, assertions, plans = [], None, [], []
for line in out.splitlines():
    header = re.match(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$', line)
    if header:
        if current is not None:
            groups.append((current, assertions, plans))
        current, assertions, plans = header[1].decode(), [], []
        continue
    if current is None:
        continue
    assertion = re.match(rb'^(not )?ok (\d+)(?: - (.*))?$', line)
    if assertion:
        assert not assertion[1], 'actual consumer assertion failure'
        assertions.append(int(assertion[2]))
    plan = re.match(rb'^1\.\.(\d+)$', line)
    if plan:
        plans.append(int(plan[1]))
if current is not None:
    groups.append((current, assertions, plans))
assert [row[0] for row in groups] == consumer['command'][3:] and len(groups) == 78, 'complete ordered consumer header population'
for path, assertions, plans in groups:
    assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete consumer numeric plan', path)
total = sum(row[2][0] for row in groups)
assert groups[-1][2] == [762] and total == 20232
assert re.findall(rb'^Files=(\d+), Tests=(\d+),', out, re.M) == [(b'78', b'20232')]

# Complete current Knowledge population, syntax, retained original headers and bodies.
knowledge = load('knowledge.json')
assert knowledge['base'] == BASE and knowledge['markdown'] == 1485
assert knowledge['producer_sha256'] == sha(retain(PREFIX + 'knowledge.py'))
population = load('knowledge-inputs.json.gz')
assert knowledge['capsule_sha256'] == sha(read(PREFIX + 'knowledge-inputs.json.gz'))
assert knowledge['inputs'] == {p: {'sha256': item['sha256'], 'mode': item['mode']} for p, item in population['current'].items()}
paths = sorted(p.relative_to(ROOT).as_posix() for directory in ('docs/knowledge', 'docs/decisions') for p in (ROOT / directory).rglob('*.md') if p.is_file())
assert paths == sorted(population['original']) and len(paths) == 1485, 'complete current Knowledge population'
facts, changed = 0, []
for p in paths:
    raw = read(p)
    original = decode(population['original'][p]['bytes_base64'])
    current = population['current'][p]
    assert raw == decode(current['bytes_base64']) and sha(raw) == current['sha256'], 'full current Knowledge byte identity'
    if raw != original:
        changed.append(p)
        retain(p)
        old_end = original.index(b'\n---', 4) + 4
        new_end = raw.index(b'\n---', 4) + 4
        if not p.endswith(('/perl-factory-capture-framework.md', '/perl-legacy-hash-kind-callback.md')):
            assert raw[new_end:] == original[old_end:], 'unchanged five route-card bodies'
        else:
            assert b'FlowExpr' in raw[new_end:] and b'.4.2' in raw[new_end:]
        assert (PREFIX + 'publish.py').encode() in raw[:new_end], 'current bounded readonly route'
    lines = raw.decode().splitlines()
    if not lines or lines[0] != '---':
        continue
    owner, fact = None, False
    for number, line in enumerate(lines[1:], 2):
        if line.strip() == '---':
            break
        if re.match(r'^\s+-\s+', line):
            assert owner is not None, ('orphan current Knowledge header', p, number)
            fact |= owner == 'answers'
        elif re.match(r'^[A-Za-z_][A-Za-z_0-9]*\s*:', line):
            key, value = line.split(':', 1)
            owner = key if not value.strip() else None
            if key == 'answers' and re.match(r'^\s*\[.*[A-Za-z0-9].*\]\s*$', value):
                fact = True
    facts += fact
assert facts == 1349 and changed == knowledge['changed_cards'] and len(changed) == 7
for p, item in population['current'].items():
    if p not in paths:
        assert retain(p) == decode(item['bytes_base64']) and inputs[p]['mode'] == item['mode']
assert knowledge['returncode'] == 0 and not decode(knowledge['stdout_base64'])
assert decode(knowledge['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert knowledge['command'] == ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']
# The complete original accepted population is independently checked against its immutable Git tree.
archive = subprocess.check_output(['git', 'archive', BASE, '--', 'docs/knowledge', 'docs/decisions'], cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as source_archive:
    original_population = {item.name: {'bytes_base64': base64.b64encode(source_archive.extractfile(item).read()).decode(), 'mode': item.mode} for item in source_archive if item.isfile() and item.name.endswith('.md')}
assert population['original'] == original_population, 'complete original accepted Knowledge custody'

# Derive every resulting-tree member limit from the unchanged registry.
registry_raw = retain('doctrine/readme_stability/routes.jsonl')
assert registry_raw == old('doctrine/readme_stability/routes.jsonl'), 'unchanged pressure controls'
route = next(json.loads(line) for line in registry_raw.splitlines()
             if json.loads(line).get('id') == 'knowledge_cards')
limits = route['limits']
assert limits == {'max_bytes_per_file': 65536, 'max_files': 1350, 'max_lines_per_file': 512,
                  'max_total_bytes': 8388608, 'max_total_lines': 108000}
members = {p: decode(item['bytes_base64']) for p, item in population['current'].items()
           if p.startswith('docs/knowledge/')}
knowledge_bytes = sum(len(raw) for raw in members.values())
assert knowledge_bytes == 8384530, 'exact finite Knowledge collection measurement'
assert len(members) <= limits['max_files']
assert sum(raw.count(b'\n') for raw in members.values()) <= limits['max_total_lines']
assert all(len(raw) <= limits['max_bytes_per_file'] and raw.count(b'\n') <= limits['max_lines_per_file']
           for raw in members.values()), 'unchanged member and collection budgets'

process = subprocess.run(['python3', PREFIX + 'book-review.py'], cwd=ROOT, capture_output=True)
assert process.returncode == 0 and not process.stderr, ('actual readonly full book review', process.stderr)
book = load('book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4
for p, digest in book['source_inputs'].items():
    assert sha(retain(p)) == digest
retain(PREFIX + 'book.py'); retain(PREFIX + 'book-review.py'); retain(PREFIX + 'book.json')
retain(PREFIX + 'review.py')

process = subprocess.run(['python3', PREFIX + 'validation.py'], cwd=ROOT, capture_output=True)
assert process.returncode == 0 and not process.stderr, ('current readonly supplemental public guard', process.stderr)
validation = load('validation.json')
for path, digest in validation['sources'].items():
    assert sha(retain(path)) == digest
if sys.argv[1:] == ['--preflight']:
    print('Optional FlowExpr preflight PASS:300 native rows;762 paired/154 RED;14 faults;78/263/20232 consumers;original451/full112004;Knowledge1485/1349/8384530;book89/4')
    sys.exit(0)

compat = load('compat.json')
assert compat['result'] == 'PASS' and compat['producer_sha256'] == sha(retain(PREFIX + 'compat.py'))
assert [row['command'] for row in compat['rows']] == [['perl', '-Mstrict=vars', '-c', '-Iperl', MODULE], ['perl', '-c', 'perl/LinkedSpec.pm'], ['perl', '-c', '-Iperl', 't/phase0_regression.t'], ['prove', '-v', '-Iperl', 't/phase0_regression.t']]
assert all(row['returncode'] == 0 for row in compat['rows'])
phase = decode(compat['rows'][3]['stdout_base64'])
assert re.findall(rb'^Files=(\d+), Tests=(\d+),', phase, re.M) == [(b'1', b'1035')] and b'Result: PASS' in phase
phase_rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', phase, re.M)
assert re.findall(rb'^1\.\.(\d+)$', phase, re.M) == [b'1035']
assert [int(row[1]) for row in phase_rows] == list(range(1, 1036)) and not any(row[0] for row in phase_rows), 'complete supplemental Phase0 plan'
report = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(read(PREFIX + 'review.py')),
          'native': native_counts, 'paired_assertions': 762, 'original_red': 154, 'original_controls': 608,
          'rejected_candidates': [48, 266], 'source_faults': fault_results,
          'consumer_suites': 78, 'consumer_inputs': 263, 'consumer_assertions': total,
          'consumer_plans': [{'path': p, 'assertions': plan[0]} for p, _, plan in groups],
          'original_bindings': 451, 'original_publication_bytes': 112004,
          'knowledge_markdown': 1485, 'knowledge_facts': 1349, 'knowledge_overlays': 7,
          'knowledge_bytes': knowledge_bytes, 'knowledge_headroom': 8388608 - knowledge_bytes,
          'book_sources': 89, 'book_controls': 4, 'supplemental_phase0': 1035, 'inputs': inputs,
          'scope': 'Two optional FlowExpr kind invocations only. Original first native100 inputs/300 rows/exact recurrences precede assertions and edits. Complete ordinary native rows, actual CODE versus opaque callable frames, identical final762 TAP, exact154 inverse,14 complete-source faults and all78 supplied consumer headers/plans are independently reviewed. Both rejected source candidates and complete channels retain their actual identities; only test-name display changes between original/final fixture, with identical original RED properties. Full accepted451 bindings/112004 publication remain recoverable at original Git. Knowledge1485/1349/seven current overlays and unchanged finite member/collection budgets plus complete book89/four controls pass. Defaults, ControlFlow, pipeline, complete helper/private/parent/canonical and other backends remain separate. System tools are read-only and not immutable portable inputs. Standard public Phase0 and composed public guard are supplemental without complete transitive input capsules. Capture writers are retired.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:] == ['--capture']:
    assert not target.exists(), 'one-shot independent report capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'exact current independent review publication'
print('Optional FlowExpr independent review PASS:762/154/608;14 faults;78/263/20232 consumers;300 native rows;original451/full112004;Knowledge1485/1349/8384530;book89/4; supplemental Phase01035')
