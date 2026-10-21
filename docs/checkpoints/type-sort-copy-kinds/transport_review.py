"""Compare the actual warning/corrected epochs, permitting validated log timestamps only."""
import copy
from datetime import datetime
import json
import re
import sys
import common as c
import oracle

STAMP = re.compile(r'^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]', re.M)


def without_stamps(text):
    stamps = STAMP.findall(text)
    assert stamps, 'expected timestamped diagnostic'
    for stamp in stamps:
        datetime.strptime(stamp, '%Y-%m-%d %H:%M:%S')
    return STAMP.sub('[TIMESTAMP]', text), len(stamps)


def compare(first, second):
    left, right = copy.deepcopy(first), copy.deepcopy(second)
    assert len(left['rows']) == len(right['rows'])
    changed = []
    for a, b in zip(left['rows'], right['rows']):
        assert a['id'] == b['id']
        before, after = a['native']['stdout'], b['native']['stdout']
        if before != after:
            for row in (a, b):
                detail = row['native']['runtime_detail']['fields']
                assert detail['code'] == 'nested_write_kind_conflict'
                assert detail['expected_kind'] == 'harray' and detail['actual_kind'] == 'array'
            normalized_before, count_before = without_stamps(before)
            normalized_after, count_after = without_stamps(after)
            assert normalized_before == normalized_after and count_before == count_after, 'diagnostic changed beyond timestamps'
            a['native']['stdout'] = normalized_before
            b['native']['stdout'] = normalized_after
            changed.append(dict(id=a['id'], timestamp_tokens=count_before))
    # Canonical JSON retains booleans versus numbers and every other field/string.
    assert json.dumps(left, sort_keys=True, separators=(',', ':')) == json.dumps(right, sort_keys=True, separators=(',', ':')), 'observer payload changed beyond permitted timestamps'
    return changed


def check():
    old = c.load('accepted-observed.json.gz')
    new = c.load('accepted2-observed.json.gz')
    assert old['inputs_unchanged'] and new['inputs_unchanged']
    assert old['run']['returncode'] == new['run']['returncode'] == 0
    assert c.decode(old['run']['stderr_base64']) == b'Wide character in print at docs/checkpoints/type-array-pipelines/probe.pl line 72.\n'
    assert not c.decode(new['run']['stderr_base64'])
    first = json.loads(c.decode(old['run']['stdout_base64']))
    second = json.loads(c.decode(new['run']['stdout_base64']))
    changes = compare(first, second)
    assert changes
    report = c.load('accepted2-run.json.gz')
    failures = oracle.failures(new['run'], c.load('cases.json'))
    assert failures == report['failures']
    assert report['observation_identity'] == c.identity(c.PREFIX + report['observation'])
    corruption = {}
    changed_id = changes[0]['id']
    for name in ('diagnostic-text', 'typed-value', 'malformed-timestamp'):
        bad = copy.deepcopy(second)
        if name == 'typed-value':
            bad['rows'][0]['native']['value'] = 'changed'
        else:
            row = next(row for row in bad['rows'] if row['id'] == changed_id)
            if name == 'diagnostic-text':
                row['native']['stdout'] += 'changed diagnostic\n'
            else:
                row['native']['stdout'] = row['native']['stdout'].replace('[2026-', '[BAD-', 1)
        try:
            compare(first, bad)
        except (AssertionError, ValueError):
            corruption[name] = 'rejected'
        else:
            raise AssertionError('transport reader admitted ' + name)
    return dict(cases=len(first['rows']), changed_timestamp_fields=changes,
        controls=corruption, accepted_red=len(failures), accepted_controls=len(first['rows']) - len(failures),
        scope='Raw channels remain exact. All decoded fields and complete diagnostic text agree after validating only line-leading timestamp tokens in actual typed-error stdout; warning removal is the sole transport correction. Non-time diagnostic, typed-value and malformed-timestamp changes reject.')


def main():
    assert sys.argv[1:] in ([], ['--capture'])
    names = ['common.py', 'oracle.py', 'transport_review.py', 'cases.json',
        'accepted-observed.json.gz', 'accepted2-observed.json.gz', 'accepted2-run.json.gz']
    paths = [c.PREFIX + name for name in names]
    inputs = {path: c.identity(path) for path in paths}
    error = None
    try:
        result = check()
    except Exception as caught:
        result = None
        error = repr(caught)
    stable = c.unchanged(inputs)
    if sys.argv[1:]:
        c.write_new('transport-review.json.gz', dict(inputs=inputs,
            producer=c.read(c.PREFIX + 'transport_review.py'), result=result,
            error=error, inputs_unchanged=stable))
    assert stable and error is None, error
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
