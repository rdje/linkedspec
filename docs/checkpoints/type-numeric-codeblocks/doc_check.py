"""Execute published numeric examples and render the whole book with a heading control."""
import html
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path
import common as c
import context
import oracle_final as oracle

CHAPTER = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
HEADING = b'### Scalar numeric helpers in codeblocks'
PAGE = 'dsl/values-containers-and-flow-helpers.html'
ANCHOR = 'id="scalar-numeric-helpers-in-codeblocks"'


def examples():
    text = (c.ROOT / CHAPTER).read_text()
    section = text.split(HEADING.decode() + '\n', 1)[1].split('\n### ', 1)[0]
    bodies = re.findall(r'^```text\n(.*?)^```\s*$', section, re.M | re.S)
    ids = ('deferred/repeated-side-effects', 'deferred/effect/receiver-continuation', 'outside/effect/early-read')
    cases = json.loads((c.ROOT / 'tests/numeric-codeblocks/cases.json').read_bytes())['cases']
    assert len(bodies) == len(ids)
    rows = []
    for name, body in zip(ids, bodies):
        case = next(case for case in cases if case['id'] == name)
        assert re.sub(r'\s+', '', body) == re.sub(r'\s+', '', case['body'])
        rows.append(dict(id='book/' + name, body=body, expected=case['expected']))
    return dict(cases=rows)


def book_inputs():
    tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=c.ROOT).decode().split('\0')
    paths = {path for path in tracked if path.startswith('docs/linkedspec-book/src/')
             or path == 'docs/linkedspec-book/book.toml'}
    pending = list(paths)
    while pending:
        path = pending.pop()
        for name in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}', (c.ROOT / path).read_bytes()):
            relative = ((c.ROOT / path).parent / name.decode().split(':', 1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert relative in tracked
            if relative not in paths:
                paths.add(relative)
                pending.append(relative)
    return {path: c.identity(path) for path in sorted(paths)}


def render(inputs, changed=False):
    assert c.unchanged(inputs)
    with tempfile.TemporaryDirectory(prefix='numeric-book-', dir=os.environ['TMPDIR']) as directory:
        root = Path(directory)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        for path, item in inputs.items():
            raw = (c.ROOT / path).read_bytes()
            assert c.sha(raw) == item['sha256']
            if changed and path == CHAPTER:
                assert raw.count(HEADING) == 1
                raw = raw.replace(HEADING, b'### Deliberately displaced numeric heading', 1)
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


def validate(build, plan, changed=False):
    assert build['returncode'] == 0
    page = c.decode(build['page_base64']).decode()
    assert (ANCHOR in page) != changed
    for case in plan['cases']:
        assert case['body'].rstrip() in html.unescape(page)


def main():
    extras = [c.PREFIX + name for name in ('common.py', 'context.py', 'doc_check.py', 'probe.pl', 'oracle_final.py')]
    extras.extend('tests/numeric-codeblocks/' + name + '.json'
                  for name in ('cases', 'effects', 'stability', 'receiver-invalid', 'terminals'))
    snapshot = context.snapshot(extras)
    book = book_inputs()
    plan = examples()
    snapshot.update(book=book, examples=plan)
    c.write_new('doc-inputs.json.gz', snapshot)
    knowledge = c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'])
    native = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(plan).encode())
    builds = dict(healthy=render(book), changed=render(book, True))
    c.write_new('doc-run.json.gz', dict(knowledge=knowledge, examples=native, builds=builds,
        toolchain=c.run(['mdbook', '--version']), inputs_unchanged=c.unchanged(snapshot['inputs'])))
    assert knowledge['returncode'] == 0 and not oracle.mismatches(native, plan, snapshot['inputs'])
    for name, build in builds.items():
        validate(build, plan, name == 'changed')
    assert c.unchanged(snapshot['inputs'])
    print('Current book/Knowledge PASS:', len(book), 'book inputs;', len(plan['cases']),
          'executed native/fresh examples; changed-heading RED;', len(snapshot['inputs']), 'closed regular inputs')


if __name__ == '__main__':
    main()
