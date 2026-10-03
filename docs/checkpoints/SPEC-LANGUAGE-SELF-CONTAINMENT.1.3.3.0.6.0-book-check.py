"""Check three exact executed sources in authored and rendered diagnosis teaching."""
from pathlib import Path
import hashlib,html,json,re
ROOT=Path(__file__).resolve().parents[2]
OWNER='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0'
SOURCE='docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
source=(ROOT/SOURCE).read_text()
plain=re.sub('<[^>]*>','',html.unescape((ROOT/'docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html').read_text()))
cases={c['id']:c for c in json.loads((ROOT/('docs/checkpoints/'+OWNER+'-cases.json')).read_bytes())}
examples=[]
for id in ('nested_original','repeated','quoted'):
 assert cases[id]['source'] in source and cases[id]['source'] in plain,id
 examples.append({'id':id,'source_sha256':hashlib.sha256(cases[id]['source'].encode()).hexdigest()})
compact=re.sub(r'\s+',' ',plain)
assert 'not global lexical source order' in compact and 'not implemented by this diagnosis' in compact
assert 'three unresolved helpers' in compact
print(json.dumps({'owner':OWNER,'result':'PASS','examples':examples,'source':SOURCE,'source_sha256':hashlib.sha256((ROOT/SOURCE).read_bytes()).hexdigest(),'limits':'Exact three executed source identities and bounded diagnosis teaching; no theme/layout or new runtime admission.'},indent=2))
