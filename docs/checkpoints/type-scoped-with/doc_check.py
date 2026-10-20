"""Render complete book inputs in same-volume fixtures and check current Knowledge."""
import html
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
import common as c

CHAPTER = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
HEADING = b'### Callable values in with'
PAGE = 'dsl/values-containers-and-flow-helpers.html'
ANCHOR = 'id="callable-values-in-with"'


def population():
    paths = subprocess.check_output(['git', 'ls-files', '-z'], cwd=c.ROOT).decode().split('\0')
    book = {path for path in paths if path.startswith('docs/linkedspec-book/src/')
            or path == 'docs/linkedspec-book/book.toml'}
    pending = list(book)
    while pending:
        path = pending.pop()
        for name in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}', (c.ROOT / path).read_bytes()):
            relative = ((c.ROOT / path).parent / name.decode().split(':', 1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert relative in paths
            if relative not in book:
                book.add(relative)
                pending.append(relative)
    graph = {path for path in paths if
             (path.startswith(('docs/knowledge/', 'docs/decisions/')) and path.endswith('.md'))
             or path.startswith('knowledge-map/') or path == '.knowledge_map.conf'}
    graph.update(('tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
                  c.PREFIX + 'common.py', c.PREFIX + 'doc_check.py'))
    return {path: c.identity(path) for path in sorted(book)}, {
        path: c.identity(path) for path in sorted(graph) if (c.ROOT / path).is_file()}


def render(inputs, changed=False):
    assert c.unchanged(inputs)
    with tempfile.TemporaryDirectory(prefix='scoped-with-book-', dir=os.environ['TMPDIR']) as name:
        root = Path(name)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        for path, item in inputs.items():
            raw = (c.ROOT / path).read_bytes()
            assert c.sha(raw) == item['sha256']
            if changed and path == CHAPTER:
                assert raw.count(HEADING) == 1
                raw = raw.replace(HEADING, b'### Deliberately displaced callable heading', 1)
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(item['mode'])
        environment = {key: value for key, value in os.environ.items() if not key.startswith('MDBOOK_')}
        command = ['mdbook', 'build', 'docs/linkedspec-book', '-d', 'output']
        result = subprocess.run(command, cwd=root, env=environment, capture_output=True)
        page = (root / 'output' / PAGE).read_bytes()
    assert c.unchanged(inputs)
    return dict(command=command, returncode=result.returncode, stdout_base64=c.encode(result.stdout),
                stderr_base64=c.encode(result.stderr), page_base64=c.encode(page))


def validate(build, changed=False):
    assert build['returncode'] == 0
    page = c.decode(build['page_base64']).decode()
    assert (ANCHOR in page) != changed
    cases = json.loads((c.ROOT / 'tests/scoped-with/cases.json').read_bytes())['cases']
    for name in ('receiver-attached', 'nested-scopes', 'outer-callable-restored'):
        body = next(case['body'] for case in cases if case['id'] == name)
        assert body in html.unescape(page)


def check(fresh=True):
    plan = c.load('doc-final-inputs.json')
    assert population() == (plan['book'], plan['graph'])
    assert c.unchanged(plan['book']) and c.unchanged(plan['graph'])
    captured = c.load('doc-final-run.json.gz')
    if fresh:
        check = c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'])
        assert check['returncode'] == 0
        runs = dict(healthy=render(plan['book']), changed=render(plan['book'], True))
    else:
        runs = captured['book']
    for name, build in runs.items():
        validate(build, name == 'changed')
    assert captured['inputs_unchanged']
    assert all(run['returncode'] == 0 for run in captured['knowledge'])
    assert c.identity('KNOWLEDGE_MAP.md') == captured['mapping']
    return dict(result='PASS', book_inputs=len(plan['book']))


if __name__ == '__main__':
    assert sys.argv[1:] == ['--capture-final']
    book, graph = population()
    c.write_new('doc-final-inputs.json', dict(book=book, graph=graph,
        toolchain='Installed mdbook and system Perl/core modules are read-only prerequisites; '
                  'complete owned book/include and Knowledge producers/sources precede commands.'))
    knowledge = [c.run(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh']),
                 c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'])]
    builds = dict(healthy=render(book), changed=render(book, True))
    c.write_new('doc-final-run.json.gz', dict(knowledge=knowledge, book=builds,
        mapping=c.identity('KNOWLEDGE_MAP.md'), inputs_unchanged=c.unchanged(book) and c.unchanged(graph),
        toolchain=c.run(['mdbook', '--version'])))
    print('Knowledge/book proof:', check(False))
