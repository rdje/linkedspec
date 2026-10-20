"""Retain each actual review preparation, including its exact producer before corrections."""
import re
import sys
import common as c


def main():
    assert len(sys.argv) == 2 and re.fullmatch('[1-9][0-9]*', sys.argv[1])
    name = 'review-preparation' + sys.argv[1] + '.json.gz'
    assert not (c.ROOT / (c.PREFIX + name)).exists()
    producers = {c.PREFIX + file: c.read(c.PREFIX + file) for file in
                 ('common.py', 'review.py', 'doc_final.py', 'oracle_final.py', 'phase0_after.py',
                  'startup.py', 'prepare_review.py')}
    run = c.run(['python3', '-B', c.PREFIX + 'review.py', '--retained'])
    c.write_new(name, dict(producers=producers, run=run,
        scope='Actual retained-observation review preparation; errors are producer preparation, not runtime RED.'))
    print(c.decode(run['stdout_base64']).decode(), end='')
    print(c.decode(run['stderr_base64']).decode(), end='', file=sys.stderr)
    raise SystemExit(run['returncode'])


if __name__ == '__main__':
    main()
