"""Verify current rendered parent teaching and eight preserved executed examples."""
from pathlib import Path
import hashlib,html,json,re
ROOT=Path(__file__).resolve().parents[2]
OWNER='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.6'
SOURCE='docs/linkedspec-book/src/architecture/structured-format-program.md'
source=(ROOT/SOURCE).read_text()
plain=re.sub('<[^>]*>','',html.unescape((ROOT/'docs/linkedspec-book/book/architecture/structured-format-program.html').read_text()))
examples=[]
for family,ids in (('5.4',('empty_original','null_original','null_nested','null_eager')),('5.5',('original','multiple','condition_effects','eager_local'))):
 path='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.'+family+'-cases.json'
 cases={r['id']:r for r in json.loads((ROOT/path).read_bytes())}
 for id in ids:
  assert cases[id]['source'] in source and cases[id]['source'] in plain,id
  examples.append({'family':family,'id':id,'source_sha256':hashlib.sha256(cases[id]['source'].encode()).hexdigest()})
assert 'What the Perl callable control composition covers' in plain
assert 'working runtime results do not prove portable metadata' in re.sub(r'\s+',' ',plain)
print(json.dumps({'owner':OWNER,'result':'PASS','examples':examples,'source':SOURCE,'source_sha256':hashlib.sha256((ROOT/SOURCE).read_bytes()).hexdigest(),'limits':'Eight preserved executed source/rendered-text identities plus bounded composition/exclusion teaching; no whole HTML/theme or visual admission.'},indent=2))
