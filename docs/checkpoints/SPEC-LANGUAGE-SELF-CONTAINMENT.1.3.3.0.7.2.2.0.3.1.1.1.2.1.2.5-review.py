"""Independent finite historical qualification and complete current recurrence review."""
import base64
import copy
import functools
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '42e00f840059db5bd4e602aee7a3b5d1e366b97b'
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
STEM = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.'
EPOCHS = {
 '2.0.1': ('5fae1476f3fbd69c70b598a2f7f56d3088ea5156', 2306, 7),
 '2.1.1': ('0d52a407c4c508cfb00d45765471f741a10de616', 215, 10),
 '2.1.2.0': ('e0ebc8d24e6b473c74ad246873402ba9dcd7a3e3', 216, 11),
 '2.1.2.4': ('8f0cdaec69b80ce5a8f4edfd783199693498bae1', 217, 12),
}
ARTIFACTS = {
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0-cases.json': 't/actionir_method_argument_source_frames.t',
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-cases.json': 't/actionir_executable_source_membership.t',
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-cases.json': 't/actionir_compiler_source_membership.t',
}
ORIGINAL_ARTIFACTS = list(ARTIFACTS)[1:]
PARSER = 'perl/LinkedSpec/ActionIR/AST/Parser.pm'
SOURCE = 'docs/linkedspec-book/src/development/documentation-workflow.md'
SUMMARY = 'docs/linkedspec-book/src/SUMMARY.md'
MARKER = 'Checkpoint JSON belongs to the measured input tree.'
CHANGES = {
 '2.1.1': ('Ten guarded live consumer suites, three actual public Toolbox lowering routes and eight reason-sensitive evidence RED controls pass; only Parser changes production.', 'Three actual public Toolbox lowering routes and eight reason-sensitive evidence RED controls pass; only Parser changes production.'),
 '2.1.2.0': ('Eleven guarded live suites (including constructor77), three actual Toolbox routes and eight reason-sensitive evidence RED controls pass.', 'Three actual Toolbox routes and eight reason-sensitive evidence RED controls pass.'),
 '2.1.2.4': ('Four effective semantic source inverses, twelve guarded direct suites, three unchanged actual Toolbox lowering routes and eight reason-sensitive evidence controls pass.', 'Four effective semantic source inverses, three unchanged actual Toolbox lowering routes and eight reason-sensitive evidence controls pass.'),
}

def digest(raw):
    return hashlib.sha256(raw).hexdigest()
@functools.lru_cache(None)
def blob(revision, path):
    return subprocess.check_output(['git', 'show', revision + ':' + path], cwd=ROOT)
def read(suffix):
    return json.loads((ROOT / (PREFIX + suffix + '.json')).read_text())
def channels(row):
    return tuple(base64.b64decode(row[k]).decode() for k in ('stdout_base64', 'stderr_base64'))

# Actual original source/read edges, not the audit producer's proposed list.
for epoch, _, _ in EPOCHS.values():
    for artifact, test in list(ARTIFACTS.items())[1:]:
        raw = blob(epoch, test).decode()
        assert 'open my $file' in raw
        assert (artifact in raw or artifact.removesuffix('cases.json') in raw), 'actual historical reader edge'


def validate(audit, consumers, inverse, artifacts, book):
    assert audit['base'] == BASE and len(audit['rows']) == 4, 'complete finite original population'
    assert {r['owner'] for r in audit['rows']} == {STEM + s for s in EPOCHS}, 'exact finite owners'
    for row in audit['rows']:
        suffix = row['owner'].removeprefix(STEM)
        epoch, count, suites = EPOCHS[suffix]
        assert row['epoch'] == epoch, 'actual original epoch'
        original_raw = blob(BASE, row['claim_path'])
        assert (ROOT / row['before']).read_bytes() == original_raw and digest(original_raw) == row['original_claim_sha256'], 'original claim retained'
        raw = blob(epoch, row['capture_path'])
        assert digest(raw) == row['capture_sha256'], 'actual original capture identity'
        captured = json.loads(raw)
        assert captured['returncode'] == 0 and 'Result: PASS' in channels(captured)[0], 'original passing observation'
        assert row['recorded_inputs'] == count == len(captured['inputs']) and row['tests'] == captured['command'][3:] and len(row['tests']) == suites, 'actual original inputs and suites'
        expected_missing = [p for p in ORIGINAL_ARTIFACTS if p not in captured['inputs']]
        assert row['missing_selected_json'] == expected_missing and len(expected_missing) == (0 if suffix == '2.0.1' else 2), 'actual omitted artifact population'
        assert not row['recorded_epoch_mismatches'], 'original recorded epoch matches'
        expected = [{'path': p, 'recorded_sha256': h, 'epoch_sha256': digest(blob(epoch, p))} for p, h in captured['inputs'].items()]
        assert row['recorded_epoch_matches'] == expected and all(r['recorded_sha256'] == r['epoch_sha256'] for r in expected), 'complete original recorded identities'
        assert row['epoch_json_inputs'] == {p: digest(blob(epoch, p)) for p in ORIGINAL_ARTIFACTS}, 'recoverable epoch JSON is not original read evidence'
    assert consumers['returncode'] == 0 and consumers['unchanged'] and 'Result: PASS' in channels(consumers)[0] and not channels(consumers)[1], 'actual complete recurrence PASS'
    seed_path = 'docs/checkpoints/' + STEM + '2.1.2.1-consumers.json'
    seed_raw = blob(BASE, seed_path)
    seed = json.loads(seed_raw)
    assert consumers['base'] == BASE and consumers['seed'] == seed_path and consumers['seed_sha256'] == digest(seed_raw), 'immutable selected seed'
    assert consumers['command'] == seed['command'] and len(consumers['command'][3:]) == 14, 'complete selected consumer command'
    assert consumers['inputs'] == seed['inputs'] and len(consumers['inputs']) == 133 and set(ARTIFACTS) <= set(consumers['inputs']), 'complete supplied consumer population'
    for p, h in consumers['inputs'].items():
        assert digest(blob(BASE, p)) == h, 'immutable supplied consumer input'
    assert consumers['producer_sha256'] == digest((ROOT / (PREFIX + 'recurrence.py')).read_bytes()), 'actual recurrence producer'
    old = b' my $remaining = length($text) - $leading;\n $trailing = $remaining if $trailing > $remaining;\n'
    raw = blob(BASE, PARSER)
    assert raw.count(old) == 1
    assert inverse['source'] == PARSER and inverse['old'].encode() == old and inverse['new'] == '', 'actual semantic source intervention'
    assert inverse['inputs'] == dict(consumers['inputs'], **{PARSER: digest(raw.replace(old, b'', 1))}), 'actual inverse supplied boundary'
    output, error = channels(inverse)
    assert inverse['returncode'] == 18 and output.endswith('1..65\n') and len(re.findall(r'^not ok ', output, re.M)) == 18 and 'empty expression has ordered original public interval' in error, 'actual semantic RED18'
    assert len(artifacts['rows']) == 3 and {r['missing'] for r in artifacts['rows']} == set(ARTIFACTS), 'complete actual artifact controls'
    for row in artifacts['rows']:
        assert row['command'] == ['perl', '-Iperl', ARTIFACTS[row['missing']]], 'actual missing artifact reader'
        assert row['inputs'] == {p: h for p, h in consumers['inputs'].items() if p != row['missing']}, 'actual missing artifact boundary'
        assert row['returncode'] != 0 and 'No such file or directory' in channels(row)[1], 'actual missing artifact RED'
    assert artifacts['baseline_sha256'] == digest((ROOT / (PREFIX + 'consumers.json')).read_bytes()) and artifacts['producer_sha256'] == digest((ROOT / (PREFIX + 'artifact-controls.py')).read_bytes()), 'actual artifact producer and baseline'
    assert [r['name'] for r in book['rows']] == ['final', 'missing-summary', 'changed-chapter'], 'complete book routes'
    final, missing, changed = book['rows']
    paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'docs/linkedspec-book/book.toml', 'docs/linkedspec-book/src'], cwd=ROOT).decode().split('\0')
    expected = {p: digest((ROOT / p).read_bytes()) for p in filter(None, paths)}
    assert final['inputs'] == expected and len(expected) == 57, 'complete book input population'
    assert final['returncode'] == 0 and final['unchanged'] and MARKER.encode() in base64.b64decode(final['html_base64']), 'actual complete rendered marker'
    assert missing['inputs'] == {p: h for p, h in expected.items() if p != SUMMARY} and missing['unchanged'], 'actual missing book boundary'
    assert missing['returncode'] != 0 and 'SUMMARY' in channels(missing)[1], 'actual missing summary RED'
    assert changed['inputs'] == dict(expected, **{SOURCE: digest((ROOT / SOURCE).read_bytes().replace(MARKER.encode(), b'', 1))}) and changed['unchanged'], 'actual changed chapter boundary'
    assert changed['returncode'] == 0 and MARKER.encode() not in base64.b64decode(changed['html_base64']), 'actual rendered marker product RED'
    assert book['producer_sha256'] == digest((ROOT / (PREFIX + 'book.py')).read_bytes()), 'actual complete book producer'

records = [read(s) for s in ('audit', 'consumers', 'source-inverse', 'artifact-controls', 'book')]
validate(*records)
# Qualification changes no original bounded input hash or behavioral proof leg.
qualifications = read('qualification')
assert len(qualifications['rows']) == 4
bindings = 0
for row in records[0]['rows']:
    before = json.loads((ROOT / row['before']).read_text())
    after = json.loads((ROOT / row['claim_path']).read_text())
    suffix = row['owner'].removeprefix(STEM)
    for claim in before['claims']:
        leg = claim['durability']
        for entry in leg['inputs']:
            assert digest(blob(leg.get('revision', BASE), entry['path'])) == entry['sha256']
            bindings += 1
    if suffix == '2.0.1':
        assert before == after, 'foundation did not have omitted artifacts'
        continue
    old, new = CHANGES[suffix]
    expected = copy.deepcopy(before['claims'][0])
    assert expected['statement'].count(old) == expected['rederive']['result'].count(old) == 1
    expected['statement'] = expected['statement'].replace(old, new)
    expected['rederive']['result'] = expected['rederive']['result'].replace(old, new)
    expected_scope = after['claims'][0]['scope']
    assert expected_scope.startswith(expected['scope'] + ' Checked durability and semantic acceptance here are limited') and OWNER in expected_scope
    expected['scope'] = expected_scope
    assert after['claims'][0] == expected and len(after['claims']) == 2, 'bounded original changes limited to explicit qualification'
    gap = after['claims'][1]
    assert gap['name'] == 'historical-supplemental-consumer-observation' and row['epoch'] in gap['statement']
    for leg in ('falsify', 'durability'):
        assert gap[leg]['status'] == 'gap' and gap[leg]['repair_owner'] == 'SESSION-STARTUP-READING.5' and gap[leg]['reason']
assert bindings == 759
freeze = read('freeze')
assert len(freeze['records']) == 1 and freeze['records'][0]['verified_bindings'] == 163
for row in freeze['records']:
    original = json.loads((ROOT / row['before']).read_text())
    for claim in original['claims']:
        for entry in claim['durability']['inputs']:
            assert digest(blob(BASE, entry['path'])) == entry['sha256']
        claim['durability'].update(mode='historical', revision=BASE)
    assert original == json.loads((ROOT / row['path']).read_text()), 'actual MethodExpr mode and revision only'

controls = []
def red(name, index, mutate, reason):
    candidate = copy.deepcopy(records)
    mutate(candidate[index])
    try:
        validate(*candidate)
    except AssertionError as exc:
        assert str(exc) == reason, (name, str(exc))
        controls.append({'name': name, 'reason': str(exc), 'result': 'RED'})
        return
    raise AssertionError('ineffective control: ' + name)
red('missing-original-owner', 0, lambda r: r['rows'].pop(), 'complete finite original population')
red('invent-foundation-gap', 0, lambda r: r['rows'][0]['missing_selected_json'].append(ORIGINAL_ARTIFACTS[0]), 'actual omitted artifact population')
red('hide-native-gap', 0, lambda r: r['rows'][2]['missing_selected_json'].clear(), 'actual omitted artifact population')
red('forge-original-input', 0, lambda r: r['rows'][0]['recorded_epoch_matches'][0].update(epoch_sha256='0'*64), 'complete original recorded identities')
red('failed-recurrence', 1, lambda r: r.update(returncode=1), 'actual complete recurrence PASS')
red('drop-supplied-json', 1, lambda r: r['inputs'].pop(ORIGINAL_ARTIFACTS[0]), 'complete supplied consumer population')
red('lost-semantic-red', 2, lambda r: r.update(returncode=0), 'actual semantic RED18')
red('missing-artifact-control', 3, lambda r: r['rows'].pop(), 'complete actual artifact controls')
red('omit-book-chapter', 4, lambda r: r['rows'][0]['inputs'].pop(SOURCE), 'complete book input population')
red('failed-book', 4, lambda r: r['rows'][0].update(returncode=1), 'actual complete rendered marker')
red('forge-changed-marker', 4, lambda r: r['rows'][2].update(html_base64=base64.b64encode(MARKER.encode()).decode()), 'actual rendered marker product RED')
report = {'result': 'PASS', 'audited_records': 4, 'omitted_artifact_records': 3, 'foundation_inputs': 2306,
          'original_bindings_preserved': bindings, 'methodexpr_bindings_frozen': 163,
          'consumer_suites': 14, 'supplied_consumer_inputs': 133, 'semantic_red_assertions': 18,
          'actual_missing_artifact_reds': 3, 'book_inputs': 57, 'book_controls': 2, 'evidence_controls': controls,
          'producer_sha256': digest(Path(__file__).read_bytes()),
          'records': {s: digest((ROOT / (PREFIX + s + '.json')).read_bytes()) for s in ('audit', 'qualification', 'consumers', 'source-inverse', 'artifact-controls', 'book', 'freeze')},
          'scope': 'Finite historical qualification and complete current selected recurrence/book. Earlier unrecorded per-read JSON bytes remain explicitly unavailable; no retroactive complete acceptance, full Phase0 or mapped/canonical admission.'}
(ROOT / (PREFIX + 'review.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Finite audit review PASS:4 original records/3 gaps;759 original+163 frozen bindings;14 supplied suites/133 files,3 artifact REDs,semantic RED18;book57/2,11 evidence controls.')
