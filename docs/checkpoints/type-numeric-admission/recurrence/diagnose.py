"""Retain exact historical-overlap and executable-source diagnostics before repair."""
import gzip
import json
import sys
from pathlib import Path
sys.path.insert(1, str(Path(__file__).resolve().parents[2] / 'type-numeric-codeblocks'))
import common as c
PREFIX = 'docs/checkpoints/type-numeric-admission/recurrence/'


def main():
    paths = ('t/phase0_regression.t', 'tests/language-readiness/evaluated-value-regression-evolution.json',
             'tests/language-readiness/verify_objectives.py', 'tools/check_executable_aggregate_selector_sources.py',
             PREFIX + 'diagnose.py', c.PREFIX + 'common.py')
    inputs = {path: c.read(path) for path in paths}
    table = json.loads(c.decode(inputs[paths[1]]['base64']))
    current = c.decode(inputs[paths[0]]['base64']).decode()
    absent = [index for index, row in enumerate(table['hunks']) if current.count(row['after']) != 1]
    run = c.run(['python3', '-B', 'tools/check_executable_aggregate_selector_sources.py'])
    result = dict(inputs=inputs, prior_hunks=len(table['hunks']), missing=absent, selector=run,
        scope='Exact current source and prior inverse table before repair; executable selector scan is an independent actual public checker run.')
    raw = (json.dumps(result,sort_keys=True,separators=(',', ':')) + '\n').encode()
    with (c.ROOT / (PREFIX + 'diagnosis.json.gz')).open('xb') as out:
        out.write(gzip.compress(raw,mtime=0))
    assert len(table['hunks']) == 70 and absent == [3]
    print('Prior inverse70: only hunk3 no longer matches; executable selector status',run['returncode'])
    print(c.decode(run['stdout_base64']).decode())
    print(c.decode(run['stderr_base64']).decode())


if __name__ == '__main__':
    main()
