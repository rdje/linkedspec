"""Verify the original composition record before its mode-only historical freeze."""
from pathlib import Path
import copy
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('supplement-review.py')
REVISION = '56c8f38d12a799e4f4fb8c5b0cfe27690d27f1fc'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0.json'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def check(before, after, report):
    original = subprocess.check_output(['git', 'show', REVISION + ':' + CLAIM], cwd=ROOT)
    assert before == json.loads(original), 'exact original composition claim'
    bindings = before['claims'][0]['durability']['inputs']
    assert len(bindings) == len({item['path'] for item in bindings}) == 151, 'complete original composition binding population'
    for item in bindings:
        raw = subprocess.check_output(['git', 'show', REVISION + ':' + item['path']], cwd=ROOT)
        assert sha(raw) == item['sha256'], 'original composition bound hashes'
    expected = copy.deepcopy(before)
    for claim in expected['claims']:
        claim['durability'].update(mode='historical', revision=REVISION)
    assert after == expected, 'mode revision only composition freeze'
    assert report['revision'] == REVISION and report['bound_inputs'] == report['unique_inputs'] == 151 and report['claims'] == 1, 'complete actual composition freeze'
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
    reject('lost original population', report, lambda value: value.update(bound_inputs=150),
           lambda value: check(before, after, value), 'complete actual composition freeze')
    reject('forged original producer', report, lambda value: value.update(instrument_sha256='0' * 64),
           lambda value: check(before, after, value), 'actual composition freeze instrument')
    reject('forged original channel', report, lambda value: value.update(before_sha256='0' * 64),
           lambda value: check(before, after, value), 'actual freeze channel identities')
    result = {'complete': True, 'revision': REVISION, 'bound_inputs': 151,
              'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes()),
              'scope': 'Every original composition hash, statement, rejected instrument/channel, historical adjudication and input binding stays exact at the committed revision. Only durability mode/revision changes. Current source/publication changes require new evidence; no refresh of old observations.'}
    Path(PREFIX + 'supplement-verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print('151 original hashes/mode-revision-only composition freeze; ' + str(len(controls)) + ' effective exact-reason historical controls RED')


if __name__ == '__main__': main()
