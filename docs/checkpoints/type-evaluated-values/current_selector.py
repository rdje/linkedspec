"""Capture current complete Knowledge sources and book before their actual commands."""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
import common as c

CHAPTER = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
PAGES = ('dsl/values-containers-and-flow-helpers.html', 'development/documentation-workflow.html')


def book_population():
    tracked = set(subprocess.check_output(['git', 'ls-files', '-z'], cwd=c.ROOT).decode().split('\0'))
    paths = {path for path in tracked if path == 'docs/linkedspec-book/book.toml' or path.startswith('docs/linkedspec-book/src/')}
    count = len(paths)
    pending = list(paths)
    while pending:
        path = pending.pop()
        for name in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}', (c.ROOT / path).read_bytes()):
            relative = ((c.ROOT / path).parent / name.decode().split(':', 1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert relative in tracked
            if relative not in paths:
                paths.add(relative)
                pending.append(relative)
    return {path: c.read(path) for path in sorted(paths)}, count


def render(inputs, changed=False):
    selected = dict(inputs)
    if changed:
        raw = c.decode(selected[CHAPTER]['base64'])
        old = b'### Evaluated values and later side effects'
        assert raw.count(old) == 1
        raw = raw.replace(old, b'### Deliberately changed evaluated-value heading', 1)
        selected[CHAPTER] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=selected[CHAPTER]['mode'])
    with tempfile.TemporaryDirectory(prefix='type-model-book-', dir=os.environ['TMPDIR']) as directory:
        fixture = Path(directory)
        assert fixture.stat().st_dev == c.ROOT.stat().st_dev
        for path, item in selected.items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(c.decode(item['base64']))
            target.chmod(item['mode'])
        command = [os.environ.get('LINKEDSPEC_MDBOOK_CMD', 'mdbook'), 'build', 'docs/linkedspec-book', '-d', 'output']
        environment = {key: value for key, value in os.environ.items() if not key.startswith('MDBOOK_')}
        result = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
        pages = {path: c.encode((fixture / 'output' / path).read_bytes()) for path in PAGES}
        assert all((fixture / path).read_bytes() == c.decode(item['base64']) and
                   (fixture / path).stat().st_mode & 0o7777 == item['mode'] for path, item in selected.items())
    return dict(command=command, returncode=result.returncode, stdout_base64=c.encode(result.stdout),
                stderr_base64=c.encode(result.stderr), pages=pages, source_bytes_modes_unchanged=True)


if __name__ == '__main__':
    assert sys.argv[1:] == ['--capture']
    paths = subprocess.check_output(['git', 'ls-files', 'docs/knowledge', 'docs/decisions'], cwd=c.ROOT, text=True).splitlines()
    paths = [path for path in paths if path.endswith('.md')]
    paths += ['.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
        'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
        'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
        'docs/checkpoints/knowledge-fields/metadata_oracle.py', c.PREFIX + 'current.py', c.PREFIX + 'current_selector.py', c.PREFIX + 'common.py']
    graph = {path: c.read(path) for path in paths}
    c.write_new(c.PREFIX + 'graph-selector-inputs.json.gz', dict(inputs=graph), packed=True)
    runs = [c.run(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh']),
            c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'])]
    c.write_new(c.PREFIX + 'graph-selector-run.json.gz', dict(runs=runs, mapping=c.read('KNOWLEDGE_MAP.md'),
        inputs_unchanged=c.unchanged(graph)), packed=True)
    assert all(run['returncode'] == 0 for run in runs), runs
    inputs, count = book_population()
    tool = shutil.which(os.environ.get('LINKEDSPEC_MDBOOK_CMD', 'mdbook'))
    assert tool
    identity = dict(name=Path(tool).name, sha256=c.sha(Path(tool).read_bytes()))
    c.write_new(c.PREFIX + 'book-selector-inputs.json.gz', dict(inputs=inputs, book_sources=count,
        producer=c.read(c.PREFIX + 'current_selector.py'), helper=c.read(c.PREFIX + 'common.py'), tool=identity), packed=True)
    c.write_new(c.PREFIX + 'book-selector-run.json.gz', dict(healthy=render(inputs), changed_heading=render(inputs, True)), packed=True)
    assert c.unchanged(inputs)
    print('Complete current Knowledge and book captures PASS')
