"""Read-only authored/rendered maintenance-boundary teaching check."""
from pathlib import Path
import hashlib,html,json,re
root=Path(__file__).resolve().parents[2]
source='docs/linkedspec-book/src/development/documentation-workflow.md'
plain=re.sub('<[^>]*>','',html.unescape((root/'docs/linkedspec-book/book/development/documentation-workflow.html').read_text()))
assert 'does not prove content ownership' in re.sub(r'\s+',' ',plain)
assert 'Keep the retained snapshot immutable' in plain
print(json.dumps({'owner':'REPO-HYGIENE.8','result':'PASS','source':source,'source_sha256':hashlib.sha256((root/source).read_bytes()).hexdigest(),'limits':'Bounded rendered retention teaching; no runtime or whole-layout admission.'},indent=2))
