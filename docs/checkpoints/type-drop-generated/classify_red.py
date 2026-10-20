"""Classify the immutable accepted public baseline against independent values."""
import json
import common as c


def main():
    inputs = c.load('red-inputs.json.gz')
    run = c.load('red-run.json.gz')
    assert run['inputs_unchanged'] and run['run']['returncode'] == 0
    actual = json.loads(c.decode(run['run']['stdout_base64']))
    plan = inputs['plan']
    rows = {row['id']: row for row in actual['rows']}
    review = []
    for case in plan['cases']:
        row = rows[case['id']]
        result = dict(id=case['id'], role=case['role'])
        if 'expected' in case:
            result['expected'] = case['expected']
            result['routes'] = {route: dict(
                passed=(row[route]['completed'] and row[route]['exception'] is None
                        and row[route]['last_error'] is None
                        and row[route]['value'] == case['expected']
                        and not row[route]['warnings'] and not row[route]['stdout']),
                observed=row[route]['value'], error=row[route]['exception'] or row[route]['last_error'],
                warnings=row[route]['warnings'])
                for route in ('native', 'generated', 'generated_fatal')}
        else:
            result['scope'] = 'Observation only; no invented key/source kind or arity contract.'
        review.append(result)
    counts = {route: sum(not row['routes'][route]['passed'] for row in review if 'routes' in row)
              for route in ('native', 'generated', 'generated_fatal')}
    c.write_new('red-review.json.gz', dict(owner=c.OWNER, review=review, failures=counts,
        baseline_revision=c.BASE,
        oracle='Fixture desired values were fixed before the accepted run. Full raw channels and '
               'all generated/dumped bodies survive in red-run; complete prior input identities '
               'and real accepted emitter bytes survive in red-inputs. This review is not a '
               'green result and does not promote diagnostic observation rows into contracts.',
        inputs={path:c.identity(path) for path in (c.PREFIX+'red-inputs.json.gz',
                c.PREFIX+'red-run.json.gz',c.PREFIX+'classify_red.py')}))
    print('Accepted independent value failures:', json.dumps(counts, sort_keys=True))


if __name__ == '__main__':
    main()
