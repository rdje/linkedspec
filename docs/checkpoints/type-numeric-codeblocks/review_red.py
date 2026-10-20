"""Classify retained baseline routes without changing sources or expectations."""
import json
from collections import Counter
import common as c
import oracle


def main():
    plan = c.load('red-inputs.json')
    saved = c.load('red-run.json.gz')
    assert saved['inputs_unchanged'] and c.unchanged(plan['inputs'])
    failures = oracle.mismatches(saved['run'], plan['plan'], plan['inputs'])
    rows = oracle.observed(saved['run'], plan['inputs'])
    by_id = {row['id']: row for row in rows}
    result = dict(failures=failures, population=len(rows),
        groups=dict(Counter(name.split('/')[0] for name in failures)),
        producer=c.read(c.PREFIX + 'review_red.py'), oracle=c.read(c.PREFIX + 'oracle.py'),
        limits='Fixed contract-derived values and authored controls; original raw channels and source remain retained.')
    c.write_new('red-review.json', result)
    print('Baseline failures:', result['groups'], '; population', len(rows))
    for name in failures:
        if name.startswith('outside/') or '/effect/' in name:
            row = by_id[name]
            print(name, json.dumps({route: dict(value=row[route]['value'], error=row[route]['runtime_detail'],
                exception=row[route]['exception']) for route in ('native', 'generated')}, sort_keys=True))
    print('Healthy aggregate controls:', [row['id'] for row in rows
        if row['id'].startswith('separate-aggregate/') and row['id'] not in failures])


if __name__ == '__main__':
    main()
