"""Retain the independent finite source-oracle template before composing a Lua reader."""
import gzip
from pathlib import Path
import subprocess
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[2]
p=ROOT/'docs/checkpoints/array-concat-open-arity-julia-2026-11-12/review.py'
body=p.read_bytes();assert body==subprocess.check_output(['git','show','HEAD:'+str(p.relative_to(ROOT))])
assert not (BASE/'oracle-template.py.gz').exists()
(BASE/'oracle-template.py.gz').write_bytes(gzip.compress(body,mtime=0))
text=body.decode();oracle=text[text.index('def semantic_oracle('):text.index('\ndef main():')]
assert 'def compare_records(' in oracle
(BASE/'semantic_oracle.py').write_text('"""Finite source intents; no peer observations or backend verdicts."""\nimport copy\nimport json\nimport re\ndef wire(value):\n    return json.dumps(value,sort_keys=True,separators=(\",\",\":\"))\ndef require(condition,reason):\n    assert condition,reason\nROUTES=(\"native\",\"restored\",\"plan\",\"fresh\")\n'+oracle)
print('Prepared source-only independent semantic oracle; Lua actual records remain sole backend outcomes')
