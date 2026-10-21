"""Classify retained accepted public results without reading implementation."""
import collections
import json
import common as c


def main():
    record=c.load('baseline-run.json.gz')
    assert record['inputs_unchanged'] and record['run']['returncode']==0
    assert not c.decode(record['run']['stderr_base64'])
    rows=json.loads(c.decode(record['run']['stdout_base64']))['rows']
    plan={row['id']:row for row in c.load('cases.json')['cases']}
    assert len(rows)==len(plan) and {row['id'] for row in rows}==set(plan)
    mismatches=[]
    observations=[]
    equal=lambda a,b:json.dumps(a,sort_keys=True)==json.dumps(b,sort_keys=True)
    for row in rows:
        case=plan[row['id']]
        descriptor=row['descriptor']
        assert descriptor['completed'] and descriptor['exception'] is None,row['id']
        assert descriptor['value']['canonical_action_ir_fallback_count']==0
        assert descriptor['value']['raw_perl_dependency_count']==0
        assert 'dump' not in row['native'] and 'source' in row['generated']
        # Initial accepted probe omitted dump_parser_source; fresh dump epoch is separate.
        values={route:{key:row[route][key] for key in
            ('completed','value','exception','runtime_detail','last_error','stdout','warnings')}
            for route in ('native','generated')}
        if 'expected' in case:
            healthy=all(row[route]['completed'] and row[route]['exception'] is None
                and row[route]['last_error'] is None and not row[route]['stdout'] and not row[route]['warnings']
                and equal(row[route]['value'],case['expected']) for route in ('native','generated'))
            if not healthy:mismatches.append(dict(id=row['id'],expected=case['expected'],observed=values))
        else:observations.append(dict(id=row['id'],observed=values))
    result=dict(mismatches=mismatches,observations=observations,
        inputs=c.identity(c.PREFIX+'baseline-inputs.json.gz'),
        raw=c.identity(c.PREFIX+'baseline-run.json.gz'),
        producer=c.read(c.PREFIX+'review_baseline.py'))
    c.write_new('baseline-review.json.gz',result)
    print('Accepted fixed-value mismatches:',len(mismatches),collections.Counter(
        row['id'].split('/')[0] for row in mismatches))
    for row in mismatches[:3]:print(json.dumps(row,sort_keys=True))
    for row in observations:
        if row['id'].startswith('ordinary/'):
            print(row['id'],json.dumps(row['observed']['native'],sort_keys=True))


if __name__=='__main__':main()
