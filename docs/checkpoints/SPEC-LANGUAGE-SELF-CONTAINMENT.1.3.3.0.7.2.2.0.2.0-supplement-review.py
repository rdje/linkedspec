"""Verify the original composition record before its mode-only historical freeze."""
from pathlib import Path
import copy
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('supplement-review.py')
REVISION = '5f700625ef4bce962285ece583b088c457f2dd63'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1.json'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def check(before, after, report):
    original = subprocess.check_output(['git', 'show', REVISION + ':' + CLAIM], cwd=ROOT)
    assert before == json.loads(original), 'exact original composition claim'
    bindings = before['claims'][0]['durability']['inputs']
    assert len(bindings) == len({item['path'] for item in bindings}) == 141, 'complete original composition binding population'
    for item in bindings:
        raw = subprocess.check_output(['git', 'show', REVISION + ':' + item['path']], cwd=ROOT)
        assert sha(raw) == item['sha256'], 'original composition bound hashes'
    expected = copy.deepcopy(before)
    for claim in expected['claims']:
        claim['durability'].update(mode='historical', revision=REVISION)
    assert after == expected, 'mode revision only composition freeze'
    assert report['revision'] == REVISION and report['bound_inputs'] == report['unique_inputs'] == 141 and report['claims'] == 1, 'complete actual composition freeze'
    assert report['before_sha256'] == sha(original) and report['after_sha256'] == sha((ROOT / CLAIM).read_bytes()), 'actual freeze channel identities'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'freeze.py').read_bytes()), 'actual composition freeze instrument'


def main():
    before = json.loads(Path(PREFIX + 'before-composition-claim.json').read_bytes())
    after = json.loads((ROOT / CLAIM).read_bytes())
    report = json.loads(Path(PREFIX + 'freeze.json').read_bytes())
    check(before, after, report)
    controls = []
    def reject(name, target, mutation, validator, reason):
        changed = copy.deepcopy(target); mutation(changed)
        assert changed != target, 'effective historical freeze corruption'
        try: validator(changed)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason}); return
        raise AssertionError('accepted historical freeze corruption: ' + name)
    reject('rewritten original statement', after, lambda value: value['claims'][0].update(statement='refreshed'),
           lambda value: check(before, value, report), 'mode revision only composition freeze')
    reject('rewritten original binding', before, lambda value: value['claims'][0]['durability']['inputs'][0].update(sha256='0' * 64),
           lambda value: check(value, after, report), 'exact original composition claim')
    reject('lost original population', report, lambda value: value.update(bound_inputs=140),
           lambda value: check(before, after, value), 'complete actual composition freeze')
    reject('forged original producer', report, lambda value: value.update(instrument_sha256='0' * 64),
           lambda value: check(before, after, value), 'actual composition freeze instrument')
    reject('forged original channel', report, lambda value: value.update(before_sha256='0' * 64),
           lambda value: check(before, after, value), 'actual freeze channel identities')
    result = {'complete': True, 'revision': REVISION, 'bound_inputs': 141,
              'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes()),
              'scope': 'Every original composition hash, statement, rejected instrument/channel, historical adjudication and input binding stays exact at the committed revision. Only durability mode/revision changes. Current source/publication changes require new evidence; no refresh of old observations.'}
    Path(PREFIX + 'supplement-verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print('141 original hashes/mode-revision-only composition freeze; ' + str(len(controls)) + ' effective exact-reason historical controls RED')


def check_runtime_supplement():
    import importlib.util
    import re
    spec = importlib.util.spec_from_file_location('membership_supplement_oracle', Path(PREFIX + 'review.py'))
    review = importlib.util.module_from_spec(spec); spec.loader.exec_module(review)
    read = lambda suffix: json.loads(Path(PREFIX + suffix).read_bytes())
    reports = {mode: read('initial-' + mode + '-observations.json') for mode in ('before', 'after')}
    manifests = {mode: read('initial-' + mode + '-inputs.json') for mode in ('before', 'after')}
    for mode in manifests:
        review.check_manifest(manifests[mode], mode)
        assert manifests[mode] == read(mode + '-inputs.json'), 'identical remeasurement inputs'
    try:
        review.check_reports(reports, manifests, read('cases.json'))
    except AssertionError as error:
        assert str(error) == 'empty actual command stderr', 'actual initial rejection reason'
    else:
        raise AssertionError('original warning silently accepted')
    warnings = [(mode, row['kind'], row['seed'], review.decode(row['stderr']))
                for mode in reports for row in reports[mode]['runs']
                if row['kind'] != 'membership-tap' and review.decode(row['stderr'])]
    assert len(warnings) == 1 and warnings[0][:3] == ('before', 'membership-probe', 1)
    assert len(warnings[0][3]) == 83 and re.fullmatch(
        rb'tools/project_data_run\.sh: child setpgid \([0-9]+ to [0-9]+\): Operation not permitted\n',
        warnings[0][3]), 'exact retained initial startup warning'
    initial = read('review-initial-failure.json')
    assert initial['exit'] == 1 and review.decode(initial['stdout']) == b''
    assert b'AssertionError: empty actual command stderr' in review.decode(initial['stderr'])
    assert initial['reviewer_sha256'] == sha(Path(PREFIX + 'review.py').read_bytes())
    assert Path(PREFIX + 'initial-review.py').read_bytes() == Path(PREFIX + 'review.py').read_bytes()
    assert initial['producer_sha256'] == sha(Path(PREFIX + 'review-failure-capture.py').read_bytes())
    for mode, size, digest in [
        ('before', 26062, 'aa26b9a358573e6630e3f1b17925e59427d940829477326d94477410aca42bdb'),
        ('after', 21059, 'e986b923ff796068113887f157e79a59c2c5d1d2c9979e7de2968f256747ddd8'),
    ]:
        raw = review.decode(read('initial-' + mode + '-tap.json'))
        assert len(raw) == size and sha(raw) == digest, 'exact preliminary TAP transport'
        output = raw.decode()
        assert re.findall(r'^1\.\.(\d+)$', output, re.M) == ['39'], 'complete preliminary TAP reach'
        assert re.findall(r'^not ok \d+ - (.+)$', output, re.M) == (review.RED if mode == 'before' else []), 'original preliminary RED GREEN'
        if mode == 'after': assert not re.search(r'^\s*not ok ', output, re.M)

    def check_mutants(document):
        assert document['complete'] is True and document['revision'] == REVISION, 'complete actual producer controls'
        assert document['producer_sha256'] == sha(Path(PREFIX + 'mutants.py').read_bytes()), 'actual mutant producer'
        names = ['inclusive_opener', 'numeric_slash_as_pattern', 'equal_raw_authority', 'lost_caller_error']
        targets = ['literal_receiver', 'numeric_slash_call_code_interval',
                   'copied origin event cannot authorize an equal raw event',
                   'active classification restores caller error after lexical helper work']
        assert [row['name'] for row in document['variants']] == names, 'complete producer control population'
        reference = {entry['path']: entry for entry in read('after-inputs.json')['entries']}
        for row, target in zip(document['variants'], targets, strict=True):
            artifact = ROOT / row['artifact']
            assert artifact.read_bytes() != (ROOT / review.OWNER).read_bytes(), 'effective actual producer delta'
            assert sha(artifact.read_bytes()) == row['sha256'], 'actual bad producer bytes'
            manifest = json.loads((ROOT / row['input_manifest']).read_bytes())
            entries = {entry['path']: entry for entry in manifest['entries']}
            assert len(entries) == len(manifest['entries']) and set(entries) == set(reference), 'closed mutant input population'
            for path, entry in entries.items():
                if path == review.OWNER:
                    assert entry['sha256'] == row['sha256'] and entry['artifact'] == row['artifact'], 'actual mutant supplied input'
                else:
                    assert entry == reference[path], 'unchanged mutant input superset'
            observed = row['observation']
            assert observed['exit'] == 1 and observed['kind'] == 'membership-tap' and observed['seed'] == 0, 'actual producer RED exit'
            assert observed['command'] == ['bash', 'tools/project_data_run.sh', 'prove', '-v', '-Iperl', review.capture.FIXTURE], 'actual producer control command'
            assert observed['inputs_before'] == observed['inputs_after'] == len(entries), 'actual producer input guards'
            output = review.decode(observed['stdout']).decode(); review.decode(observed['stderr'])
            assert re.findall(r'^1\.\.(\d+)$', output, re.M) == ['41'], 'complete producer RED reach'
            assert [int(n) for n in re.findall(r'^(?:not )?ok (\d+) - ', output, re.M)] == list(range(1, 42)), 'complete ordered producer RED groups'
            failures = re.findall(r'^not ok \d+ - (.+)$', output, re.M)
            assert target == row['expected_red_group'] and target in failures == row['observed_red_groups'], 'distinguishing actual producer RED'
    mutants = read('mutants.json'); check_mutants(mutants)
    controls = []
    for name, mutation, reason in [
        ('hidden bad producer', lambda value: value.update(producer_sha256='0' * 64), 'actual mutant producer'),
        ('omitted bad producer', lambda value: value['variants'].pop(), 'complete producer control population'),
        ('lost mutant guards', lambda value: value['variants'][0]['observation'].update(inputs_after=0), 'actual producer input guards'),
        ('hidden actual RED', lambda value: value['variants'][0]['observation'].update(exit=0), 'actual producer RED exit'),
        ('wrong distinguishing oracle', lambda value: value['variants'][0].update(expected_red_group='other'), 'distinguishing actual producer RED'),
    ]:
        bad = copy.deepcopy(mutants); mutation(bad); assert bad != mutants
        try: check_mutants(bad)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason})
        else: raise AssertionError('accepted bad producer evidence: ' + name)
    result = read('supplement-verification.json')
    result.update(initial_warning_retained=True, unchanged_host_remeasurement=True,
                  actual_producer_red_controls=4, runtime_controls=controls)
    Path(PREFIX + 'supplement-verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print('Original warning/rejection retained; unchanged remeasurement; four actual producer RED/five supplemental evidence RED')


if __name__ == '__main__':
    main()
    check_runtime_supplement()
