"""Own initial-source continuations and literal Number routes before production."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
cases = []
for name in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays'):
    args = ['1', '1'] if name == 'slice' else ['["extra"]'] if name == 'concat_arrays' else [] if name in ('sorted', 'reversed') else ['1']
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"tail"}')):
        identifier = 'initial_with_' + kind + '_' + name
        body = 'source=' + source + ';return(source.' + name + '(' + ','.join(args) + ').with(){return(value)})'
        cases.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n', input='x', rule='Value', profile_only=True))
    for route in ('free', 'receiver'):
        expr = name + '(' + ','.join(['3'] + args) + ')' if route == 'free' else '3.' + name + '(' + ','.join(args) + ')'
        body = 'return(' + expr + ')'
        cases.append(dict(id='literal_number_' + name + '_' + route, body=body, source='Value:: I {' + body + '}\n', input='x', rule='Value', profile_only=True))
(BASE / 'supplement_cases.json').write_text(json.dumps(cases, indent=2) + '\n')
observer = (BASE / 'observer.pl').read_text().replace('/cases.json', '/supplement_cases.json')
(BASE / 'observer_supplement.pl').write_text(observer)
capture = (BASE / 'capture_qualified.py').read_text().replace("('preflight', 'after', 'inverse', 'restored')", "('supplement',)")
capture = capture.replace("BASE / 'observer.pl'", "BASE / 'observer_supplement.pl'").replace("BASE / 'cases.json'", "BASE / 'supplement_cases.json'")
(BASE / 'capture_supplement.py').write_text(capture)
print('Authored additional initial-source continuations and literal Number fences:', len(cases))
