"""Render the complete supplied current book and inspect the affected public pages."""
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
MARKER = b'Migrating the retired tagged returns'
PAGE = 'dsl/values-containers-and-flow-helpers.html'


def population():
    tracked = set(subprocess.check_output(['git', 'ls-files', '-z'], cwd=c.ROOT).decode().split('\0'))
    selected = {path: c.read(path) for path in tracked if path == 'docs/linkedspec-book/book.toml'
                or path.startswith('docs/linkedspec-book/src/')}
    original = set(selected)
    pending = list(selected)
    while pending:
        path = pending.pop()
        for name in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}', c.decode(selected[path]['base64'])):
            target = ((c.ROOT / path).parent / name.decode().split(':', 1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert target in tracked, ('tracked recursive book input', target)
            if target not in selected:
                selected[target] = c.read(target)
                pending.append(target)
    return selected, len(original)


def render(inputs, changed=False):
    with tempfile.TemporaryDirectory(prefix='type-book-', dir=os.environ['TMPDIR']) as directory:
        fixture = Path(directory)
        assert fixture.stat().st_dev == c.ROOT.stat().st_dev
        selected = dict(inputs)
        if changed:
            raw = c.decode(selected[CHAPTER]['base64'])
            assert raw.count(b'### ' + MARKER) == 1
            raw = raw.replace(b'### ' + MARKER, b'### Changed migration heading', 1)
            selected[CHAPTER] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=selected[CHAPTER]['mode'])
        for path, item in selected.items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(c.decode(item['base64']))
            target.chmod(item['mode'])
        command = [os.environ.get('LINKEDSPEC_MDBOOK_CMD', 'mdbook'), 'build', 'docs/linkedspec-book', '-d', 'output']
        environment = {key: value for key, value in os.environ.items() if not key.startswith('MDBOOK_')}
        result = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
        assert all((fixture / path).read_bytes() == c.decode(item['base64']) and
                   (fixture / path).stat().st_mode & 0o7777 == item['mode'] for path, item in selected.items())
        pages = {}
        for path in (PAGE, 'appendix/formal-grammar.html', 'appendix/helper-contract-catalog.html'):
            raw = (fixture / 'output' / path).read_bytes()
            pages[path] = dict(base64=c.encode(raw), sha256=c.sha(raw))
        files = {target.relative_to(fixture / 'output').as_posix(): dict(sha256=c.sha(target.read_bytes()),
                 bytes=target.stat().st_size, mode=target.stat().st_mode & 0o7777)
                 for target in (fixture / 'output').rglob('*') if target.is_file()}
        return dict(command=command, returncode=result.returncode, stdout_base64=c.encode(result.stdout),
                    stderr_base64=c.encode(result.stderr), pages=pages, output_manifest=files,
                    inputs={path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in selected.items()},
                    source_bytes_modes_unchanged=True)


def verify(row, changed=False):
    assert row['returncode'] == 0 and row['source_bytes_modes_unchanged']
    assert b'ERROR' not in c.decode(row['stderr_base64'])
    pages = {path: c.decode(item['base64']) for path, item in row['pages'].items()}
    main = pages[PAGE].split(b'<main>', 1)[1].rsplit(b'</main>', 1)[0]
    anchor = b'id="migrating-the-retired-tagged-returns"'
    if changed:
        assert anchor not in main and b'id="changed-migration-heading"' in main
    else:
        assert anchor in main and b'flat_array(entry_groups())' in main
        assert b'&quot;?Top:&quot;' in main and b'&quot;seed&quot;' in main
        for name in ('appendix/formal-grammar.html', 'appendix/helper-contract-catalog.html'):
            assert b'../dsl/values-containers-and-flow-helpers.html#migrating-the-retired-tagged-returns' in pages[name]
    return main


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--capture'])
    inputs, book_count = population()
    tool = shutil.which(os.environ.get('LINKEDSPEC_MDBOOK_CMD', 'mdbook'))
    assert tool
    identity = dict(name=Path(tool).name, sha256=c.sha(Path(tool).read_bytes()))
    if sys.argv[1:]:
        c.write_new(c.PREFIX + 'book-inputs.json.gz', dict(inputs=inputs, tool=identity,
            producer=c.read(c.PREFIX + 'book.py'), book_sources=book_count), packed=True)
    healthy, changed = render(inputs), render(inputs, True)
    result = dict(healthy=healthy, changed_heading=changed, tool=identity,
        book_sources=book_count, recursive_include_sources=len(inputs)-book_count)
    if sys.argv[1:]:
        c.write_new(c.PREFIX + 'book-run.json.gz', result, packed=True)
    assert verify(healthy) != verify(changed, True), 'actual visible heading control distinguishes rendered output'
    assert c.unchanged(inputs)
    print('Complete supplied book render and changed-heading RED PASS:', len(inputs), 'inputs;', book_count, 'book sources')
