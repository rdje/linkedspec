"""Retain actual book rendering and two source-identical compiler probe examples."""
from pathlib import Path
import importlib.util
import html as html_module
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-'
spec = importlib.util.spec_from_file_location('streams', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)
command = ['bash', 'tools/run_mdbook_local.sh']
result = subprocess.run(command, cwd=ROOT, capture_output=True)
chapter = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
html_path = 'docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html'
cases = json.loads((ROOT / (PREFIX + 'cases.json')).read_bytes())
blocks = re.findall(r'```spec\n(.*?)\n```', (ROOT / chapter).read_text(), re.S)
examples = []
for index in (0, 7):
    case = cases[index]
    # Markdown normalizes CRLF. The captured source remains byte-exact; the
    # rendered teaching copy is compared after that explicit normalization.
    assert case['source'].replace('\r\n', '\n').rstrip('\n') in blocks
    examples.append({'id': case['id'], 'source': case['source']})
html = (ROOT / html_path).read_bytes()
rendered_blocks = [html_module.unescape(re.sub(r'<[^>]*>', '', block)).rstrip('\n')
                   for block in re.findall(r'<code class="language-spec">(.*?)</code>', html.decode(), re.S)]
for example in examples:
    assert example['source'].replace('\r\n', '\n').rstrip('\n') in rendered_blocks
report = {'command': command, 'exit': result.returncode, 'stdout': streams.envelope(result.stdout),
          'stderr': streams.envelope(result.stderr), 'html_path': html_path, 'html': streams.envelope(html),
          'source_examples': examples, 'normalization': 'CRLF to LF and final fence newline'}
(ROOT / (PREFIX + 'book.json')).write_text(json.dumps(report, indent=2) + '\n')
assert result.returncode == 0 and b'Nine basic regex contracts also retain' in html
print('PASS rendered private coverage and two exact-source examples with explicit Markdown newline normalization')
