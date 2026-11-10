"""Distinguish receiver producer errors from downstream composition failures."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
rows = []


def add(key, body, expected=None, error=None):
    row = dict(id=key, body=body, source='Value:: I {' + body + '}\n', input='x', rule='Value')
    if error:
        row['expected_error'] = error
    else:
        row['expected'] = expected
    rows.append(row)


add('receiver_needed_delimiter_terminal', 'return(["head:tail"].split_each({items="bad";items+=1;":"}))', error='binding_kind_mismatch')
add('receiver_computed_delimiter_terminal', 'order="";out=["head:tail"].split_each({order=cat(order,"D");":"});return([out,order])', [['head', 'tail'], 'D'])
add('receiver_computed_delimiter_count', 'order="";out=["head:tail"].split_each({order=cat(order,"D");":"}).count();return([out,order])', [2, 'D'])
add('receiver_variable_delimiter', 'delimiter=":";return(["head:tail"].split_each(delimiter))', ['head', 'tail'])
for receiver in (False, True):
    expression = '["head"].filter_match(/[z-a]/)' if receiver else 'filter_match(["head"],/[z-a]/)'
    for composed in (False, True):
        add('invalid_range_' + ('receiver' if receiver else 'free') + ('_composed' if composed else '_terminal'),
            'order="";return(' + expression + ('.set_key({order=cat(order,"K");"k"},1).coalesce("masked")' if composed else '') + ')')
target = BASE / 'delimiter-cases.json'; assert not target.exists()
target.write_text(json.dumps(rows, indent=2) + '\n')
observer = (BASE / 'observer.pl').read_bytes()
capture = (BASE / 'capture.py').read_bytes()
for name, body in [('observer', observer), ('capture', capture)]:
    (BASE / ('delimiter-template-' + name + '.gz')).write_bytes(gzip.compress(body, mtime=0))
(BASE / 'delimiter-template-identities.json').write_text(json.dumps(dict(
    observer_sha256=hashlib.sha256(observer).hexdigest(), capture_sha256=hashlib.sha256(capture).hexdigest()), indent=2) + '\n')
(BASE / 'observer_delimiter.pl').write_text(observer.decode().replace('/cases.json', '/delimiter-cases.json'))
modified = capture.decode().replace("OUT=BASE/'preflight'", "OUT=BASE/'delimiter_controls'")
modified = modified.replace("str(BASE/'observer.pl')", "str(BASE/'observer_delimiter.pl')")
modified = modified.replace("str(BASE/'cases.json')", "str(BASE/'delimiter-cases.json')")
modified = modified.replace('records={}\n', "paths += [BASE/'observer_delimiter.pl',BASE/'delimiter-cases.json',BASE/'delimiter-template-observer.gz',BASE/'delimiter-template-capture.gz',BASE/'delimiter-template-identities.json']\nrecords={}\n")
(BASE / 'capture_delimiter.py').write_text(modified)
print('Authored eight terminal/compatible/invalid-range source distinctions; original176 unchanged')
