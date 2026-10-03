"""Read current rendered text and exact source-bound examples; emit a bounded QA result."""
from pathlib import Path
import hashlib, html, json, re
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4-'
SOURCE='docs/linkedspec-book/src/architecture/structured-format-program.md'
CASES=PREFIX+'cases.json'
examples=('empty_original','null_original','null_nested','null_eager')
cases={c['id']:c for c in json.loads((ROOT/CASES).read_bytes())}
source=(ROOT/SOURCE).read_text()
rendered=html.unescape((ROOT/'docs/linkedspec-book/book/architecture/structured-format-program.html').read_text())
plain=re.sub('<[^>]*>','',rendered)
for id in examples:
 assert cases[id]['source'] in source and cases[id]['source'] in plain,id
assert 'return_undef()' in plain and 'skip' in plain
flow=html.unescape((ROOT/'docs/linkedspec-book/book/dsl/values-containers-and-flow-helpers.html').read_text())
assert 'one payload lazily' in re.sub('<[^>]*>','',flow)
assert 'zero-argument `return()`/`return_undef()` remain separately owned gaps' not in (ROOT/'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md').read_text()
print(json.dumps({'owner':'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4','exact_executed_examples':list(examples),'rendered_source':SOURCE,'source_sha256':hashlib.sha256((ROOT/SOURCE).read_bytes()).hexdigest(),'cases_sha256':hashlib.sha256((ROOT/CASES).read_bytes()).hexdigest(),'result':'PASS','limits':'Four selected rendered text/source identities after run_mdbook_local.sh; no whole HTML/theme identity or visual admission.'},indent=2))
