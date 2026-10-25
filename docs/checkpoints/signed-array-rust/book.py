"""Pure complete-book rendering and retained signed-selector validation."""
import html
from html.parser import HTMLParser
import os
from pathlib import Path
import re
import subprocess
import tempfile
import common as c

FLOW = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
HTML = 'dsl/values-containers-and-flow-helpers.html'
EXAMPLES = {
    'examples/negative-array-current-perl.spec': [30, [10,20,30]],
    'examples/negative-array-current-callable-perl.spec': [30, [10,20,30]],
    'examples/negative-array-write-perl.spec': [30, [10,99,30]],
    'examples/negative-array-write-callable-perl.spec': {'rows': [[1],[99,3]]},
}


def inputs():
    available = set(subprocess.check_output(['git','ls-files'],cwd=c.ROOT,text=True).splitlines())
    names = {path for path in available if path.startswith('docs/linkedspec-book/src/')
        or path == 'docs/linkedspec-book/book.toml'}
    pending = list(names)
    while pending:
        path = pending.pop()
        for include in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}',c.source(path).read_bytes()):
            target = ((c.ROOT/path).parent/include.decode().split(':',1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert target in available,target
            if target not in names:
                names.add(target);pending.append(target)
    return {path:c.read(path) for path in sorted(names)}


def render(packets):
    with tempfile.TemporaryDirectory(prefix='signed-rust-book-',dir=os.environ['TMPDIR']) as folder:
        root=Path(folder)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        for path,item in packets.items():
            destination=root/path;destination.parent.mkdir(parents=True,exist_ok=True)
            raw=c.decode(item['base64']);assert c.sha(raw)==item['sha256']
            destination.write_bytes(raw);destination.chmod(item['mode'])
        command=['mdbook','build','docs/linkedspec-book','-d','output']
        env={key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
        result=subprocess.run(command,cwd=root,env=env,capture_output=True)
        page=root/'output'/HTML
        return dict(command=command,returncode=result.returncode,stdout_base64=c.encode(result.stdout),
            stderr_base64=c.encode(result.stderr),page_base64=c.encode(page.read_bytes()) if page.exists() else '')


class Code(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True);self.current=None;self.blocks=[]
    def handle_starttag(self,tag,attrs):
        if tag=='code':self.current=[]
    def handle_data(self,data):
        if self.current is not None:self.current.append(data)
    def handle_endtag(self,tag):
        if tag=='code' and self.current is not None:
            self.blocks.append(''.join(self.current).rstrip('\n'));self.current=None


def validate(run,packets):
    assert run['returncode']==0,'book command'
    page=c.decode(run['page_base64']).decode()
    plain=html.unescape(page)
    assert 'Signed array selectors in Perl and Rust' in plain,'signed heading'
    assert 'The extension is available on Perl and Rust' in plain,'Rust support'
    assert 'Rust uses finite whole' in plain,'numeric-kind scope'
    parsed=Code();parsed.feed(page)
    for path in EXAMPLES:
        source=c.decode(packets[path]['base64']).decode().rstrip('\n')
        assert parsed.blocks.count(source)==1,'exact executable example: '+path


def check():
    packet=c.load('book-inputs.json.gz')
    runs=c.load('book-runs.json.gz')
    for path,item in packet['inputs'].items():
        assert c.sha(c.decode(item['base64']))==item['sha256'],path
    validate(runs['healthy'],packet['inputs'])
    for name,fault in runs['faults'].items():
        assert fault['run']['returncode']==0
        try:validate(fault['run'],packet['inputs'])
        except AssertionError:pass
        else:raise AssertionError('rendered fault admitted: '+name)
    return dict(book_inputs=len(packet['inputs']),rendered_faults=sorted(runs['faults']))


if __name__=='__main__':
    import json
    print(json.dumps(check(),sort_keys=True))
