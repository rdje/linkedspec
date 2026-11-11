"""Freeze unchanged intake programs and positive source/operand-order controls."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
OLD = Path('docs/checkpoints/array-transform-callable-perl-2026-11-11')
ACTIVATION = '09bad87aa19304486f836cf6dff44b499a8ea5ec'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
names = ['observer.pl', 'cases.json', 'terminal-cases.json', 'policy-contract.json']
templates = {}
for i, name in enumerate(names):
    path = OLD / name
    raw = path.read_bytes()
    assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    alias = 'template-' + str(i) + '.gz'
    (BASE / alias).write_bytes(gzip.compress(raw, mtime=0))
    templates[str(path)] = dict(alias=alias, bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
cases = json.loads((OLD / 'cases.json').read_bytes()) + json.loads((OLD / 'terminal-cases.json').read_bytes())
assert len(cases) == 288
positive = []
source = 'supply({order=cat(order,"S");["b","a","c"]})'
number = '{order=cat(order,"N");1}'
count = '{order=cat(order,"C");1}'
tail = '{order=cat(order,"T");["d"]}'
operations = {
    'take': ([number], ['b'], 'SN'),
    'take_last': ([number], ['c'], 'SN'),
    'drop_front': ([number], ['a', 'c'], 'SN'),
    'drop_back': ([number], ['b', 'a'], 'SN'),
    'slice': ([number, count], ['a'], 'SNC'),
    'sorted': ([], ['a', 'b', 'c'], 'S'),
    'reversed': ([], ['c', 'a', 'b'], 'S'),
    'concat_arrays': ([tail], ['b', 'a', 'c', 'd'], 'ST'),
}
for method, (args, value, order) in operations.items():
    for form in ('free_terminal', 'receiver_terminal', 'receiver_composed'):
        expression = method + '(' + ','.join([source] + args) + ')' if form == 'free_terminal' else source + '.' + method + '(' + ','.join(args) + ')'
        if form == 'receiver_composed':
            expression += '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).copy().and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")}'
        body = 'order="";out=' + expression + ';return([out,order])'
        positive.append(dict(id='positive_' + method + '_' + form, body=body,
            source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n',
            rule='Value', input='x', expected=[None if form == 'receiver_composed' else value, order],
            question='positive-source-once-and-operand-order', form=form, method=method))
assert len(positive) == 24
cases += positive
assert len(cases) == len({case['id'] for case in cases}) == 312
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
(BASE / 'positive-cases.json').write_text(json.dumps(positive, indent=2) + '\n')
(BASE / 'templates.json').write_text(json.dumps(templates, indent=2, sort_keys=True) + '\n')
observer = (OLD / 'observer.pl').read_text()
assert observer.count(str(OLD)) == 2
(BASE / 'observer.pl').write_text(observer.replace(str(OLD), str(REL)))
print('Prepared unchanged288 plus sixteen producer controls/eight composed source-order controls; no SDK execution.')
