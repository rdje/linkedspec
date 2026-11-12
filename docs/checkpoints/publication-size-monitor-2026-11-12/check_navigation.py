"""Retain and inspect the rebuilt book's actual budget link and target."""
import gzip
import hashlib
from html.parser import HTMLParser
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'navigation'
OUT.mkdir()
paths = [Path('docs/linkedspec-book/book/development') / name for name in
    ('local-ci-and-regression.html', 'documentation-workflow.html')]
inputs = {}
bodies = []
for index, path in enumerate(paths):
    assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes(); archive = OUT / ('input-' + str(index) + '.html.gz')
    archive.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(archive.read_bytes()) == body
    inputs[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
        mode=path.stat().st_mode & 0o777, archive=str(archive))
    bodies.append(gzip.decompress(archive.read_bytes()).decode())
(OUT / 'inputs.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')


class Page(HTMLParser):
    def __init__(self, body):
        super().__init__()
        self.links, self.ids, self.text = [], [], []
        self.feed(body)

    def handle_starttag(self, tag, attrs):
        values = dict(attrs)
        if tag == 'a' and 'href' in values:
            self.links.append(values['href'])
        if 'id' in values:
            self.ids.append(values['id'])

    def handle_data(self, data):
        self.text.append(data)


ci, workflow = [Page(body) for body in bodies]
target = 'outgoing-publication-byte-budget'
assert 'documentation-workflow.html#' + target in ci.links
assert workflow.ids.count(target) == 1
text = ''.join(workflow.text)
assert 'docs/checkpoints/publication-size-monitor-2026-11-12/measure.py' in text
assert all(value in text for value in ('1,500,000,000', '1,400,000,000', '2 GiB'))
result = dict(rendered_navigation='PASS', link='documentation-workflow.html#' + target,
    target_occurrences=1, source_ci_lines=2048, source_workflow_lines=1013,
    scope='Actual rebuilt HTML images retained before inspection; command/budgets/link/target checked. No future render freshness or native toolchain closure claim.')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, sort_keys=True))
