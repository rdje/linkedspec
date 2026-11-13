"""Select retained authored questions, with no historical outcome import."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
assert not (BASE / 'cases.json').exists()
self_body = Path(__file__).read_bytes()
(BASE / 'prepare-before-use.py.gz').write_bytes(gzip.compress(self_body, mtime=0))
assert gzip.decompress((BASE / 'prepare-before-use.py.gz').read_bytes()) == self_body
original = 'docs/checkpoints/array-transform-callable-lua-2026-11-12/cases.json'
identities = json.loads((BASE / 'intake/input-identities.json').read_bytes())
with tarfile.open(BASE / 'intake/inputs-before-use.tar.gz') as archive:
    member = archive.getmember(original)
    body = archive.extractfile(member).read()
assert hashlib.sha256(body).hexdigest() == identities[original]['sha256']
selected = (
    'own_needed_source_take_free', 'own_needed_source_take_receiver',
    'own_signature_fixed_missing_terminal', 'own_signature_fixed_missing_composed',
    'own_signature_fixed_extra_composed', 'own_signature_variadic_missing_composed',
)
questions = {row['id']: row for row in json.loads(body)}
cases = [{key: questions[name][key] for key in ('id', 'source', 'input')} for name in selected]
cases += [
    dict(id='nested_binding', input='x', source='Top::\n -> Child\n\nChild:\n /x/\n E {items="bad";items+=1;return(items)}\n'),
    dict(id='nested_fixed_arity', input='x', source='fn pair(left,right) {return([left,right])}\n\nTop::\n -> Child\n\nChild:\n /x/\n E {return(pair("head"))}\n'),
]
assert len(cases) == len({row['id'] for row in cases})
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
(BASE / 'preparation.json').write_text(json.dumps(dict(
    original=original, original_sha256=identities[original]['sha256'], selected=list(selected),
    added=['nested_binding', 'nested_fixed_arity'], source_only=True,
    producer_sha256=hashlib.sha256(self_body).hexdigest(),
    scope='Two selected error families; acyclic string/number-keyed finite values. Lua table identity, metatable implementation and all-error completeness are excluded.'), indent=2) + '\n')
print('Prepared eight source-only selected error questions; no SDK or native build')
