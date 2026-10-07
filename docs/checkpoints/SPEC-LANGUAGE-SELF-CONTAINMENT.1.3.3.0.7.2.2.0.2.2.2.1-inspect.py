"""Inspect complete captured TAP reach before choosing a production correction."""
from pathlib import Path
import base64
import gzip
import json
import re

PREFIX = str(Path(__file__).resolve()).removesuffix('inspect.py')


def main():
    report = json.loads(Path(PREFIX + 'before-observations.json').read_bytes())
    for run in report['runs']:
        if run['kind'] != 'compiler-tap':
            continue
        raw = gzip.decompress(base64.b64decode(run['stdout']['data']))
        text = raw.decode()
        failures = re.findall(r'^    not ok \d+ - (.+)$', text, re.M)
        print('seed', run['seed'], 'exit', run['exit'], 'failed nested assertions', len(failures))
        print('top failures', re.findall(r'^not ok \d+ - (.+)$', text, re.M))
        print('nested plans', re.findall(r'^    1\.\.(\d+)$', text, re.M)[-2:])
        print('first failures', failures[:6])
        print('role failures', [f.removesuffix(' retains independently authored compiler helper roles')
            for f in failures if f.endswith(' retains independently authored compiler helper roles')])


if __name__ == '__main__':
    main()
