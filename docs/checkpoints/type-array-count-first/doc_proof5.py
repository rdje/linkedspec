"""Execute all affected book bodies and verify the complete rendered book and new anchor."""
import html
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import common as c
import context
import oracle

CHAPTER = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
HEADING = b'### Counting and selecting first inside Perl codeblocks'
KIND_HEADING = b'### Counting and selecting first inside Perl codeblocks'
PAGE = 'dsl/values-containers-and-flow-helpers.html'
REFERENCE_PAGE = 'dsl/value-container-flow-helper-reference.html'


def examples():
    text = c.source(CHAPTER).read_text()
    assert text.count(HEADING.decode()) == 1
    section = re.split(r'\n#{1,3} ', text.split(HEADING.decode() + '\n', 1)[1], maxsplit=1)[0]
    bodies = re.findall(r'^```text\n(.*?)^```\s*$', section, re.M | re.S)
    plan = c.load('book-cases.json')
    assert len(bodies) == len(plan['cases'])
    for body, case in zip(bodies, plan['cases']):
        assert re.sub(r'\s+', '', body) == re.sub(r'\s+', '', case['body'])
        case['body'] = body
    return plan


def book_inputs():
    tracked = set(subprocess.check_output(['git', 'ls-files', '-z'], cwd=c.ROOT).decode().split('\0'))
    paths = {path for path in tracked if path.startswith('docs/linkedspec-book/src/') or path == 'docs/linkedspec-book/book.toml'}
    pending = list(paths)
    while pending:
        path = pending.pop()
        for name in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}', c.source(path).read_bytes()):
            relative = ((c.ROOT / path).parent / name.decode().split(':', 1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert relative in tracked
            if relative not in paths:
                paths.add(relative)
                pending.append(relative)
    return {path: c.identity(path) for path in sorted(paths)}


def render(inputs, changed=False):
    assert c.unchanged(inputs)
    with tempfile.TemporaryDirectory(prefix='sort-kind-book-', dir=os.environ['TMPDIR']) as directory:
        root = Path(directory)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        for path, item in inputs.items():
            raw = c.source(path).read_bytes()
            assert c.sha(raw) == item['sha256']
            if changed and path == CHAPTER:
                assert raw.count(KIND_HEADING) == 1
                raw = raw.replace(KIND_HEADING, b'#### Deliberately displaced scalar-kind heading', 1)
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(item['mode'])
        command = ['mdbook', 'build', 'docs/linkedspec-book', '-d', 'output']
        environment = {key: value for key, value in os.environ.items() if not key.startswith('MDBOOK_')}
        result = subprocess.run(command, cwd=root, env=environment, capture_output=True)
        page = (root / 'output' / PAGE).read_bytes()
        reference = (root / 'output' / REFERENCE_PAGE).read_bytes()
    assert c.unchanged(inputs)
    return dict(command=command, returncode=result.returncode,
        stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr),
        page_base64=c.encode(page), reference_base64=c.encode(reference))


def validate(build, plan):
    assert build['returncode'] == 0
    page = c.decode(build['page_base64']).decode()
    assert 'id="counting-and-selecting-first-inside-perl-codeblocks"' in page, 'Missing count/first heading anchor'
    assert 'id="counting-and-selecting-first-inside-perl-codeblocks"' in page, 'Missing count/first heading anchor'
    for case in plan['cases']:
        assert case['body'].rstrip() in html.unescape(page)
    assert 'values-containers-and-flow-helpers.html#counting-and-selecting-first-inside-perl-codeblocks' in c.decode(build['reference_base64']).decode()


def main():
    assert sys.argv[1:] in ([], ['doc2'])
    stem = sys.argv[1] if sys.argv[1:] else 'doc5'
    supplied = context.snapshot()
    supplied.update(book=book_inputs(), plan=examples())
    c.write_new(stem + '-inputs.json.gz', supplied)
    public = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(supplied['plan']).encode())
    builds = dict(healthy=render(supplied['book']), changed=render(supplied['book'], True))
    try:
        validate(builds['changed'], supplied['plan'])
    except AssertionError as error:
        red = dict(rejected=True, message=str(error))
    else:
        red = dict(rejected=False, message='')
    stable = c.unchanged(supplied['inputs'])
    failed = oracle.failures(public, supplied['plan'])
    c.write_new(stem + '-run.json.gz', dict(public=public, failures=failed, builds=builds,
        heading_control=red, inputs_unchanged=stable, version=c.run(['mdbook', '--version'])))
    assert stable and not failed, failed
    validate(builds['healthy'], supplied['plan'])
    assert red == dict(rejected=True, message='Missing count/first heading anchor')
    print('Book GREEN:', len(supplied['book']), 'inputs;', len(supplied['plan']['cases']), 'executed bodies; new anchor/link and actual heading RED')


if __name__ == '__main__':
    main()
