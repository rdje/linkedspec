"""Freeze and render the final public book separately from historical test inputs."""
from pathlib import Path
import gzip
import hashlib
import html
import importlib.util
import io
import json
import re
import shutil
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('book.py')
PREP = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.0-'
spec = importlib.util.spec_from_file_location('streams', ROOT / (PREP + 'review.py'))
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)
paths = subprocess.check_output(['git', 'ls-files', '-z', '--', 'docs/linkedspec-book'], cwd=ROOT).decode().split('\0')
paths = sorted(path for path in paths if path and not path.startswith('docs/linkedspec-book/book/'))
inputs = {}
entries = []
output = io.BytesIO()
with gzip.GzipFile(fileobj=output, mode='wb', filename='', mtime=0) as compressed:
    with tarfile.open(fileobj=compressed, mode='w|', format=tarfile.USTAR_FORMAT) as archive:
        for path in paths:
            file = ROOT / path
            streams.check(file.is_file() and not file.is_symlink(), 'regular public book input')
            data = file.read_bytes()
            inputs[path] = data
            item = tarfile.TarInfo(path)
            item.size = len(data); item.mode = 0o644
            archive.addfile(item, io.BytesIO(data))
            entries.append({'path': path, 'bytes': len(data), 'sha256': streams.sha(data)})
capsule = output.getvalue()
Path(PREFIX + 'book-inputs.tar.gz').write_bytes(capsule)
manifest = {'capsule_sha256': streams.sha(capsule), 'entries': entries,
            'boundary': 'Complete final working candidate book inputs, distinct from the immutable historical consumer capsule.'}
Path(PREFIX + 'book-inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
scratch = ROOT / '.linkedspec-data/scratch/selected-proof-closure'
tree = Path(tempfile.mkdtemp(prefix='public-book-', dir=scratch))
streams.check(tree.stat().st_dev == ROOT.stat().st_dev, 'same-volume public book inputs')
for path, data in inputs.items():
    target = tree / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
book_root = (tree / 'docs/linkedspec-book').relative_to(ROOT).as_posix()
command = ['bash', 'tools/project_data_run.sh', 'mdbook', 'build', book_root]
result = subprocess.run(command, cwd=ROOT, capture_output=True)
report = {'command': command, 'exit': result.returncode, 'stdout': streams.envelope(result.stdout),
          'stderr': streams.envelope(result.stderr), 'capsule_sha256': manifest['capsule_sha256'],
          'input_tree': tree.relative_to(ROOT).as_posix(), 'complete': False, 'mdbook_sha256': streams.sha(Path(shutil.which('mdbook')).resolve().read_bytes())}
Path(PREFIX + 'book.json').write_text(json.dumps(report, indent=2) + '\n')
streams.check(result.returncode == 0, 'actual final public book render')
actual_inputs = {p.relative_to(tree).as_posix() for p in tree.rglob('*') if p.is_file() and not p.relative_to(tree).as_posix().startswith('docs/linkedspec-book/book/')}
streams.check(actual_inputs == set(inputs), 'unchanged public book input population')
for entry in entries:
    path = entry['path']
    streams.check((tree / path).read_bytes() == (ROOT / path).read_bytes() == inputs[path], 'unchanged rendered public book input ' + path)
chapter = tree / 'docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html'
workflow = tree / 'docs/linkedspec-book/book/development/documentation-workflow.html'
rendered = chapter.read_bytes()
workflow_html = workflow.read_bytes()
fixed = streams.read_capsule((ROOT / (PREP + 'inputs.tar.gz')).read_bytes())
fixture = json.loads(fixed['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-cases.json'])
examples = [fixture[index]['source'] for index in (0, 7)]
blocks = [html.unescape(re.sub(r'<[^>]*>', '', block)).rstrip('\n') for block in
          re.findall(r'<code class="language-spec">(.*?)</code>', rendered.decode(), re.S)]
report.update(html=streams.envelope(rendered), workflow_html=streams.envelope(workflow_html), source_examples=examples)
Path(PREFIX + 'book.json').write_text(json.dumps(report, indent=2) + '\n')
streams.check(all(source.replace('\r\n', '\n').rstrip('\n') in blocks for source in examples), 'final public original example bytes')
streams.check(b'The selected thirteen-suite remeasurement' in workflow_html, 'actual final public acceptance explanation')
report.update(complete=True, inputs_after=len(entries), html=streams.envelope(rendered),
              workflow_html=streams.envelope(workflow_html), source_examples=examples)
Path(PREFIX + 'book.json').write_text(json.dumps(report, indent=2) + '\n')
print('PASS final public book from a separate complete input capsule and original examples')
