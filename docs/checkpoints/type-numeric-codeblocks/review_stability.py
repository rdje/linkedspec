"""Retain the stopped first review and classify diagnostic-producing baseline RED."""
import common as c
import oracle_final as oracle


def main():
    plan = c.load('stability-red-inputs.json')
    saved = c.load('stability-red-run.json.gz')
    assert saved['inputs_unchanged'] and c.unchanged(plan['inputs'])
    status = c.read('.linkedspec-data/verification/type-numeric-stability-red.status')
    assert c.decode(status['base64']).strip() == b'1'
    failures = oracle.mismatches(saved['run'], plan['plan'], plan['inputs'])
    c.write_new('stability-reviewed.json', dict(failures=failures,
        original_status=status,
        original_log=c.read('.linkedspec-data/verification/type-numeric-stability-red.log'),
        original_observer=c.read(c.PREFIX + 'observe.py'), original_oracle=c.read(c.PREFIX + 'oracle.py'),
        producer=c.read(c.PREFIX + 'review_stability.py'), oracle=c.read(c.PREFIX + 'oracle_final.py'),
        scope='The original raw execution is unchanged. The initial oracle aborted on a real compiler warning. '
              'The distinct final oracle counts any warning as a failing case rather than accepting it or '
              'aborting classification. Candidate acceptance still requires quiet routes and exact values/errors.'))
    print('Retained stability baseline:', len(plan['plan']['cases']), 'cases;', len(failures), 'RED')
    print(failures)


if __name__ == '__main__':
    main()
