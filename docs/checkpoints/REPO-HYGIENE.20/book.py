"""Retain complete supplied book inputs and actual healthy/missing-marker renders."""
import html
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import common as c
import document

PAGE = 'development/documentation-workflow.html'


def validate(value):
    assert value['returncode'] == 0, 'book command'
    assert document.MARKER in html.unescape(c.decode(value['page_base64']).decode()), 'maintenance marker'


def render(packets, changed=False):
    with tempfile.TemporaryDirectory(prefix='hygiene20-book-', dir=os.environ['TMPDIR']) as folder:
        root = Path(folder)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        for path,packet in packets.items():
            raw = c.decode(packet['base64'])
            assert c.sha(raw) == packet['sha256']
            if changed and path == document.BOOK:
                assert raw.count(document.MARKER.encode()) == 1
                raw = raw.replace(document.MARKER.encode(), b'', 1)
            target = root/path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(packet['mode'])
        command = ['mdbook','build','docs/linkedspec-book','-d','output']
        env = {key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
        run = subprocess.run(command,cwd=root,env=env,capture_output=True)
        return dict(command=command,returncode=run.returncode,stdout_base64=c.encode(run.stdout),
            stderr_base64=c.encode(run.stderr),page_base64=c.encode((root/'output'/PAGE).read_bytes()))


def main():
    tracked = set(subprocess.check_output(['git','ls-files','-z'],cwd=c.ROOT).decode().split('\0'))
    paths = {path for path in tracked if path.startswith('docs/linkedspec-book/src/')
        or path == 'docs/linkedspec-book/book.toml'}
    pending = list(paths)
    while pending:
        path = pending.pop()
        for name in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}',c.source(path).read_bytes()):
            target = ((c.ROOT/path).parent/name.decode().split(':',1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert target in tracked
            if target not in paths:
                paths.add(target)
                pending.append(target)
    packets = {path:c.read(path) for path in sorted(paths)}
    c.write_new('book-inputs.json.gz',dict(base=c.BASE,producer=c.read(c.PREFIX+'book.py'),
        inputs=packets,scope='Complete supplied configuration/source/recursive includes, full bytes and modes; no dependency on future mutable book files.'))
    healthy, changed = render(packets), render(packets,True)
    c.write_new('book-runs.json.gz',dict(healthy=healthy,changed=changed,
        version=c.run(['mdbook','--version']),inputs_unchanged=all(c.read(path)==packet for path,packet in packets.items())))
    validate(healthy)
    try:
        validate(changed)
    except AssertionError as error:
        assert str(error) == 'maintenance marker'
    else:
        raise AssertionError('missing marker admitted')
    assert all(c.read(path)==packet for path,packet in packets.items())
    print('Book PASS:',len(packets),'complete inputs; actual missing-maintenance-marker RED')


if __name__ == '__main__':
    main()
