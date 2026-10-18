"""Readonly completeness oracle for every retained native selection observation."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
payload = (ROOT / (PREFIX + 'after-native-data.json.gz')).read_bytes()
index = json.loads((ROOT / (PREFIX + 'after-native.json')).read_bytes())
assert index['data_sha256'] == hashlib.sha256(payload).hexdigest()
data = json.loads(gzip.decompress(payload))
for captured in data[1:]:
    assert json.loads(base64.b64decode(captured['stdout_base64'], validate=True)) == captured['observation']
    observed = captured['observation']
    assert len(observed['rows']) == 26
    assert len({(r['label'], r['context']) for r in observed['rows']}) == 26
    for row in observed['rows']:
        authority = row['authority']
        assert set(authority) == {'native_selected', 'registrations', 'values'}, 'complete selection observation population'
        assert len(authority['native_selected']) == len(observed['keys']) == 8, 'complete native selection population'
        assert all(type(v) is int and v in (0, 1) for v in authority['native_selected'])
        assert len(authority['values']) == len(row['values']), 'complete selection observation population'
        for i in range(len(row['values'])):
            callbacks = row['values'][i].get('callbacks', [])
            selected = authority['values'][i]
            assert len(selected) == len(callbacks), 'complete callback selection population'
            assert [v['key'] for v in selected] == [v['key'] for v in callbacks], 'complete callback selection keys'
            assert all(set(v) == {'key', 'selected'} and type(v['selected']) is int
                and v['selected'] in (0, 1) for v in selected)
print('Native authority shape PASS:26 warm/26 cold observations; complete map and callback selection populations')
