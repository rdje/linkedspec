"""Readonly historical recovery with separate product and compatibility controls."""
import argparse
import base64
import copy
import gzip
import importlib.util
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('callable_transform_historical_reader', BASE / 'review_model_qualified.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--first', action='store_true', help='one pre-seal publishing read, not the resume command')
args = parser.parse_args()
seal = BASE / 'sealed-identities.json'
if args.first:
    m.need(not seal.exists() and not (BASE / 'review_qualified_first-final-launch/exit.txt').exists(), 'first review is one-shot')
else:
    m.need(seal.is_file(), 'sealed historical recovery required')
    for name, row in json.loads(seal.read_bytes()).items():
        path = m.ROOT / name
        m.need(path.resolve().is_relative_to(BASE) and path.is_file() and not path.is_symlink(), 'sealed ownership')
        raw = path.read_bytes()
        m.need(len(raw) == row['bytes'] and m.sha(raw) == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], 'sealed byte identity')
    first = BASE / 'review_qualified_first-final-launch'
    m.need((first / 'exit.txt').read_text().strip() == '0' and not gzip.decompress((first / 'stderr.log.gz').read_bytes()), 'actual first independent review')
    prior = json.loads(gzip.decompress((first / 'stdout.log.gz').read_bytes()))
    m.need(prior['result'] == 'PASS' and prior['groups'] == 312, 'actual first independent review')

original_failure = BASE / 'review_first-final-launch'
m.need((original_failure / 'exit.txt').read_text().strip() == '1' and b'AssertionError: SDK origin' in gzip.decompress((original_failure / 'stderr.log.gz').read_bytes()), 'original reader qualification')

history = m.History()
current = m.expected_owner(history)
m.need(gzip.decompress((BASE / 'owner-old.pm.gz').read_bytes()) == history.files[m.OWNER][0], 'old owner image')
m.need(gzip.decompress((BASE / 'owner-current.pm.gz').read_bytes()) == current, 'current owner image')
cases = m.expected_cases(history)
policy, targets = m.target_intents(history, cases)
epochs = {phase: m.read_epoch(phase, cases, history, current) for phase in m.PHASES}
baseline = epochs['intake']['rows']
mode_differences = [dict(path=name, filesystem_mode=epochs['intake']['images'][name][1], git_mode=entry[1], sha256=m.sha(entry[0]), executable_class_equal=bool(epochs['intake']['images'][name][1] & 0o111) == bool(entry[1] & 0o111)) for name, entry in sorted(history.sdk.items()) if epochs['intake']['images'][name][1] != entry[1]]
m.need(m.equal(mode_differences, json.loads((BASE / 'mode-diagnostic.json').read_bytes())) and len(mode_differences) == 12 and all(row['executable_class_equal'] for row in mode_differences), 'retained filesystem-mode qualification')
expected = m.desired_rows(baseline, targets)


def intent_ok(row, intent):
    if not m.equal(row['metadata'], m.READY):
        return False
    for route, usable in (('native', 'native_callable'), ('fresh', 'loaded')):
        if row.get(usable) != 1 or route not in row:
            return False
        error = row.get(route + '_error')
        if intent['kind'] == 'value':
            if error or not m.equal(row[route], intent['value']):
                return False
        elif not error or intent['code'] not in m.wire(error) or (intent.get('identifier') and 'identifier=' + intent['identifier'] not in m.wire(error)):
            return False
    return True


old = history.json(m.OLD + '/observations.json')
old.update(history.json(m.OLD + '/terminal-observations.json'))
m.need(len(old) == 288, 'original record population')
for key, row in old.items():
    m.need(m.equal(m.projection(baseline[key]), m.projection(row)), 'original record preservation')
    for field in ('module_input', 'handler_input'):
        original = gzip.decompress(history.files[row[field]['path']][0])
        fresh = gzip.decompress((m.ROOT / baseline[key][field]['path']).read_bytes())
        m.need(original == fresh, 'original artifact preservation')
m.need(all(not intent_ok(baseline[key], value) for key, value in targets.items()), 'actual target RED boundary')
m.need(all(intent_ok(baseline[key], value) for key, value in policy['healthy_intents'].items()), 'healthy producer contract')
for key, case in cases.items():
    if key.startswith('positive_') and case['form'] != 'receiver_composed':
        m.need(intent_ok(baseline[key], dict(kind='value', value=case['expected'])), 'positive producer contract')


def same_baseline(candidate):
    m.need(set(candidate) == set(baseline), 'question population')
    for key, row in candidate.items():
        m.need(m.equal(m.projection(row), m.projection(baseline[key])), 'baseline full record')


same_baseline(epochs['before']['rows'])
same_baseline(epochs['private_old']['rows'])
m.need(epochs['before']['failed'] == set(targets), 'actual before failure identities')
m.need(epochs['after']['failed'] == m.COMPAT, 'actual first after failure identities')
m.need(epochs['private_old']['failed'] == set(targets) | m.COMPAT, 'separate private RED identities')
for phase in ('after', 'after_qualified', 'private_current'):
    m.semantics(epochs[phase]['rows'], expected, targets)
    if phase != 'after':
        m.need(not epochs[phase]['failed'], 'actual current TAP pass')
for key in cases:
    for field in ('module_input', 'handler_input'):
        m.need(epochs['before']['rows'][key][field]['sha256'] == baseline[key][field]['sha256'], 'before input identity')
        m.need(epochs['private_old']['rows'][key][field]['sha256'] == baseline[key][field]['sha256'], 'old input identity')
        for phase in ('after_qualified', 'private_current'):
            m.need(epochs[phase]['rows'][key][field]['sha256'] == epochs['after']['rows'][key][field]['sha256'], 'current input identity')


def fixture_valid(profiles, qualified):
    m.need(len(profiles) == 312 and {p['case']['id'] for p in profiles} == set(cases), 'qualified fixture')
    for profile in profiles:
        key = profile['case']['id']
        m.need(m.equal(profile['case'], cases[key]), 'qualified fixture')
        if key in targets:
            if targets[key]['kind'] == 'needed-error':
                oracle = key + '_terminal_probe' if key.startswith('own_') else key.replace('_composed', '_terminal')
                desired = dict(case=cases[key], role='needed-error-target', oracle=oracle, expected_observation=expected[key])
            else:
                desired = dict(case=cases[key], role='result-target', expected=targets[key]['value'])
        else:
            compat = qualified and key in m.COMPAT
            desired = dict(case=cases[key], role='compatibility-readiness' if compat else 'preservation',
                expected_observation=expected[key] if compat else m.projection(baseline[key]))
        m.need(m.equal(profile, desired), 'qualified fixture')


first_fixture = epochs['before']['images'][m.FIXTURE][0]
qualified_fixture = epochs['after_qualified']['images'][m.FIXTURE][0]
fixture_valid(json.loads(first_fixture), False)
fixture_valid(json.loads(qualified_fixture), True)
m.need(gzip.decompress((BASE / ('qualification-original-' + Path(m.FIXTURE).name + '.gz')).read_bytes()) == first_fixture, 'original fixture alias')
original_normal = epochs['before']['images'][m.NORMAL][0].decode()
old_message = ": 'full acquired observation preserved');"
new_message = ": $profile->{role} eq 'compatibility-readiness' ? 'payload/error boundaries and disclosed readiness' : 'full acquired observation preserved');"
m.need(original_normal.count(old_message) == 1, 'normal qualification origin')
qualified_normal = original_normal.replace(old_message, new_message).encode()
for phase in ('after_qualified', 'private_old', 'private_current'):
    m.need(epochs[phase]['images'][m.NORMAL][0] == qualified_normal and epochs[phase]['images'][m.FIXTURE][0] == qualified_fixture, 'unchanged qualified normal')
m.need(epochs['after']['images'][m.NORMAL][0] == original_normal.encode() and epochs['after']['images'][m.FIXTURE][0] == first_fixture, 'original failed after retained')
classification = json.loads((BASE / 'classification.json').read_bytes())
roles = {key: ('needed-error-target' if targets[key]['kind'] == 'needed-error' else 'result-target') if key in targets else 'compatibility-readiness' if key in m.COMPAT else 'preservation' for key in cases}
m.need(classification['roles'] == roles and classification['targets'] == 43 and classification['protected_records'] == 266 and set(classification['compatibility_readiness']) == m.COMPAT, 'separate role populations')
direct = m.direct(history, current)
m.need(direct['images'][m.NORMAL][0] == qualified_normal and direct['images'][m.FIXTURE][0] == qualified_fixture, 'direct current normal identity')

# Every producer image is recovered without treating a later worktree as SDK proof.
retained = {}
for epoch in list(epochs.values()) + [direct]:
    for name, item in epoch['images'].items():
        retained.setdefault(name, set()).add((m.sha(item[0]), item[1]))
for path in BASE.glob('*-launch/producer-images.json.gz'):
    for name, row in json.loads(gzip.decompress(path.read_bytes())).items():
        raw = base64.b64decode(row['base64'], validate=True)
        m.need(len(raw) == row['bytes'] and m.sha(raw) == row['sha256'], 'producer image identity')
        available = (m.sha(raw), row['mode']) in retained.get(name, set())
        own = m.ROOT / name
        if not available:
            m.need(own.resolve().is_relative_to(BASE) and own.is_file(), 'producer image ownership')
            available = own.read_bytes() == raw and own.stat().st_mode & 0o777 == row['mode']
        m.need(available, 'actual producer image')

controls = []


def red(label, action, reason):
    try:
        action()
    except AssertionError as error:
        m.need(str(error) == reason, 'wrong corruption reason: ' + label + ': ' + str(error))
        controls.append(dict(control=label, observed_red=reason))
    else:
        raise AssertionError('ineffective corruption: ' + label)


good = epochs['private_current']['rows']
changed = copy.deepcopy(good)
changed['take_receiver_hash_guard']['native'] = ['wrong']
red('wrong-target-value', lambda: m.semantics(changed, expected, targets), 'target value/effects')
changed = copy.deepcopy(good)
changed['take_later_with']['metadata']['language_agnostic_action_ir_ready'] = 0
red('hide-readiness-behind-null', lambda: m.semantics(changed, expected, targets), 'target readiness')
changed = copy.deepcopy(good)
changed['own_needed_count_take_receiver']['native_error']['opaque_extra'] = dict(module_input='must remain visible')
red('lose-full-error-field', lambda: m.semantics(changed, expected, targets), 'complete needed error')
changed = copy.deepcopy(good)
changed['own_function_arity_missing_terminal']['metadata'] = m.READY
red('admit-invalid-function-signature', lambda: m.semantics(changed, expected, targets), 'protected observation')
changed = copy.deepcopy(good)
changed['own_extra_take_receiver_terminal_probe']['metadata']['language_agnostic_action_ir_ready'] = 0
red('normalize-excluded-null-shape', lambda: m.semantics(changed, expected, targets), 'protected observation')
changed = copy.deepcopy(good)
changed['own_initial_number_sorted_receiver']['native_error'] = None
red('normalize-initial-typed-error', lambda: m.semantics(changed, expected, targets), 'protected observation')
changed = copy.deepcopy(good)
changed['positive_take_receiver_composed']['native'] = [None, 'SSN']
red('duplicate-source-effect', lambda: m.semantics(changed, expected, targets), 'target value/effects')
changed = copy.deepcopy(good)
changed['initial_number_composed']['native'] = [[], 'W']
red('promote-readiness-to-input-policy', lambda: m.semantics(changed, expected, targets), 'compatibility payload/readiness')
changed = copy.deepcopy(epochs['before']['rows'])
changed['needed_count_composed']['fresh'] = None
red('invent-fresh-after-failed-load', lambda: same_baseline(changed), 'baseline full record')
changed = copy.deepcopy(good)
del changed['take_compatible']
red('omit-question', lambda: m.semantics(changed, expected, targets), 'question population')
changed = copy.deepcopy(json.loads(qualified_fixture))
next(p for p in changed if p['case']['id'] == 'initial_number_composed')['role'] = 'result-target'
red('count-compatibility-as-product-target', lambda: fixture_valid(changed, True), 'qualified fixture')
changed = copy.deepcopy(epochs['private_current']['receipt'])
changed['path'] = m.OWNER
red('wrong-loaded-owner-path', lambda: m.owner_receipt(changed, current), 'loaded owner receipt')
changed = copy.deepcopy(epochs['private_current']['images'])
body, mode = changed['specs/spec.spec']
changed['specs/spec.spec'] = (body + b'changed', mode)
red('change-direct-grammar-source', lambda: m.sdk_origin(changed, history, current), 'SDK origin')
changed = copy.deepcopy(epochs['private_current']['inputs'])
length, digest = changed['take_compatible']['handler']
changed['take_compatible']['handler'] = (length + 1, digest)
red('change-handler-source-byte', lambda: m.products(good, changed, cases, 'private_current'), 'artifact input binding')
changed = copy.deepcopy(cases)
changed['take_compatible']['source'] += '\nchanged'
red('change-authored-program', lambda: m.products(good, epochs['private_current']['inputs'], changed, 'private_current'), 'authored source')

changed = copy.deepcopy(epochs['private_current']['images'])
body, mode = changed['specs/spec.spec']
changed['specs/spec.spec'] = (body, mode | 0o100)
red('change-executable-class', lambda: m.sdk_origin(changed, history, current), 'SDK executable class')
changed = json.loads((BASE / 'private_current/input-identities.json').read_bytes())
changed['specs/spec.spec']['mode'] ^= 0o040
red('change-full-filesystem-mode', lambda: m.read_archive(BASE / 'private_current/inputs-before-sdk.tar.gz', changed), 'archive identity')

print(json.dumps(dict(result='PASS', groups=312, product_targets=43,
    compatibility_readiness=sorted(m.COMPAT), preserved_observations=266,
    original_records_and_source_bodies=288, positive_terminal_controls=16,
    actual_source_pairs=312 * len(m.PHASES), direct_groups=direct['groups'],
    direct_artifacts=direct['artifact_count'], rejected_controls=controls,
    limits='Finite source-bound controls, not profile semantic PASS or portable initial-input authority. Native dumps follow internal compilation; native/cache/transitive/toolchain/OS4.2/SESSION5, full23.4 and other backend lanes remain open.'), sort_keys=True))
