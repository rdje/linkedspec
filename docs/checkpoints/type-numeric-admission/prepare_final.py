"""Retain actual final-reader preparation and its exact producers before corrections."""
import re
import sys
import admission_data as a
c = a.c


def main():
    assert len(sys.argv) == 2 and re.fullmatch('[1-9][0-9]*', sys.argv[1])
    names = [c.PREFIX + 'review_final.py', c.PREFIX + 'publish_final.py',
             a.PREFIX + 'numeric_admission.py', a.PREFIX + 'admission_data.py', a.PREFIX + 'prepare_final.py']
    sources = {path: c.read(path) for path in names}
    run = c.run(['python3', '-B', c.PREFIX + 'review_final.py', '--retained'])
    a.write('final-preparation' + sys.argv[1] + '.json.gz', dict(producers=sources, run=run,
        scope='Actual retained epoch/admission review preparation, distinct from fresh runtime execution.'))
    print(c.decode(run['stdout_base64']).decode(), end='')
    print(c.decode(run['stderr_base64']).decode(), end='', file=sys.stderr)
    raise SystemExit(run['returncode'])


if __name__ == '__main__':
    main()
