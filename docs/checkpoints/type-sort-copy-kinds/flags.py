"""Recheck the original public numeric flag/copy/index controls after the repair."""
import json
import sys
import common as c
import context
import oracle


def validate(run, plan):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    rows = json.loads(c.decode(run['stdout_base64']))['rows']
    assert len(rows) == 2 * len(plan['cases'])
    assert [(row['id'],row['route']) for row in rows] == [
        (case['id'],route) for case in plan['cases'] for route in ('native','generated')]
    for row in rows:
        assert row['completed'] and not row['error'] and not row['runtime_error']
        assert not row['warnings'] and not row['stdout']
        if row['id'].endswith('/index'):
            assert oracle.typed(row['value']) == oracle.typed(['zero','changed','two'])
        else:
            selected = row['value'][0] if row['id'].endswith('/sort-outer') else row['value']
            assert oracle.typed(selected) == oracle.typed([1,10,2])
            assert oracle.typed(row['cloned_value']) == oracle.typed([1,10,2])
            for key in ('flags','cloned_flags'):
                assert all(flag['iOK'] == 1 and flag['pOK'] == 0 for flag in row[key])
    return len(rows)


def main():
    assert sys.argv[1:] in ([], ['flags2'])
    stem = sys.argv[1] if sys.argv[1:] else 'flags'
    plan = c.load('baseline.json.gz')['plan']
    inputs = context.snapshot()
    c.write_new(stem+'-inputs.json.gz', inputs)
    run = c.run(['perl','-Iperl','docs/checkpoints/type-array-pipelines/kinds.pl'],
        input=json.dumps(plan).encode())
    stable = c.unchanged(inputs['inputs'])
    c.write_new(stem+'-run.json.gz',dict(run=run,inputs_unchanged=stable,plan=plan))
    assert stable
    print('Public flag/clone/index GREEN:',validate(run,plan),'native/fresh routes')


if __name__ == '__main__':
    main()
