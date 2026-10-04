"""Render the book and retain complete output plus the actual affected chapter HTML."""
from pathlib import Path
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-'
spec = importlib.util.spec_from_file_location('capture', ROOT / (PREFIX + 'capture.py'))
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
command = ['bash', 'tools/run_mdbook_local.sh']
result = subprocess.run(command, cwd=ROOT, capture_output=True)
source = ROOT / 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
html = ROOT / 'docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html'
cases = json.loads((ROOT / (PREFIX + 'cases.json')).read_bytes())
ids = ['double_control', 'quoted_set', 'sentinel_data', 'unsupported_substr']
blocks = re.findall(r'```spec\n(.*?)\n```', source.read_text(), re.S)
checked = []
for id in ids:
    case = next(c for c in cases if c['id'] == id)
    assert case['source'] in blocks, id
    checked.append({'id': id, 'source': case['source']})
rendered = html.read_bytes() if html.exists() else b''
report = {'command': command, 'exit': result.returncode,
          'stdout': capture.envelope(result.stdout), 'stderr': capture.envelope(result.stderr),
          'html_path': str(html.relative_to(ROOT)), 'html': capture.envelope(rendered),
          'source_examples': checked}
(ROOT / (PREFIX + 'book.json')).write_text(json.dumps(report, indent=2) + '\n')
assert result.returncode == 0
assert b'Ignoring every quoted string would erase' in rendered
assert b'phantom replacement' in rendered
print('PASS rendered chapter and four exact probe-owned source examples')
