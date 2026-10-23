"""Execute exact public commands and retain complete book/source-render controls."""
import copy
from html.parser import HTMLParser
import os
from pathlib import Path
import re
import shlex
import subprocess
import tempfile
import common as c
import context
import document

PAGES = dict(integration='public-api/integration-perl.html',flow='dsl/values-containers-and-flow-helpers.html')


class Content(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.text = []
        self.blocks = []
        self.code = None
    def handle_starttag(self,tag,attrs):
        if tag=='code':
            self.code = []
    def handle_data(self,data):
        self.text.append(data)
        if self.code is not None:
            self.code.append(data)
    def handle_endtag(self,tag):
        if tag=='code' and self.code is not None:
            self.blocks.append(''.join(self.code).rstrip('\n'))
            self.code = None


def validate(run,commands):
    assert run['returncode']==0, 'book command'
    integration = Content()
    integration.feed(c.decode(run['pages']['integration']).decode())
    flow = Content()
    flow.feed(c.decode(run['pages']['flow']).decode())
    text = ''.join(integration.text)
    assert document.HEADING in text, 'CLI heading'
    assert document.PROTOCOL.replace('`','') in text, 'CLI failure protocol'
    assert document.FLOW_MARKER in ''.join(flow.text), 'flow failure protocol'
    for command in commands.values():
        assert integration.blocks.count(command)==1, 'CLI executable source'


def render(packets):
    with tempfile.TemporaryDirectory(prefix='cli-runtime-book-',dir=os.environ['TMPDIR']) as directory:
        root = Path(directory)
        assert root.stat().st_dev==c.ROOT.stat().st_dev
        for path,packet in packets.items():
            raw = c.decode(packet['base64'])
            assert c.sha(raw)==packet['sha256']
            target = root/path
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(raw)
            target.chmod(packet['mode'])
        command = ['mdbook','build','docs/linkedspec-book','-d','output']
        env = {key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
        run = subprocess.run(command,cwd=root,env=env,capture_output=True)
        return dict(command=command,returncode=run.returncode,
            stdout_base64=c.encode(run.stdout),stderr_base64=c.encode(run.stderr),
            pages={name:c.encode((root/'output'/path).read_bytes()) for name,path in PAGES.items()})


def changed(packets,old,new):
    result = copy.deepcopy(packets)
    packet = result[document.INTEGRATION]
    raw = c.decode(packet['base64'])
    assert raw.count(old)==1
    raw = raw.replace(old,new,1)
    packet.update(base64=c.encode(raw),sha256=c.sha(raw))
    return result


def main():
    assert c.read('bin/linkedspec')==c.load('repair-completion.json.gz')['source']
    epoch = context.snapshot()
    available = set(c.paths())
    paths = {path for path in available if path.startswith('docs/linkedspec-book/src/')
        or path=='docs/linkedspec-book/book.toml'}
    pending = list(paths)
    while pending:
        path = pending.pop()
        for include in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}',c.source(path).read_bytes()):
            target = ((c.ROOT/path).parent/include.decode().split(':',1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert target in available
            if target not in paths:
                paths.add(target)
                pending.append(target)
    packets = {path:c.read(path) for path in sorted(paths)}
    commands = c.load('documentation.json.gz')['commands']
    page = c.decode(packets[document.INTEGRATION]['base64']).decode()
    blocks = re.findall(r'```sh\n(.*?)\n```',page,re.S)
    cases = {row['id']:row for row in c.load('cases2.json')['cases']}
    executions = {}
    for name,command in commands.items():
        assert blocks.count(command)==1
        argv = shlex.split(command)
        case = cases[name]
        assert argv==['perl','-Iperl','bin/linkedspec','--inline-spec',case['source'],'--input',case['input']]
        executions[name] = c.run(argv)
    c.write_new('book-inputs.json.gz',dict(context=epoch,inputs=packets,commands=commands,
        producer=c.read(c.PREFIX+'book.py'),version=c.run(['mdbook','--version'])))
    c.write_new('book-runtime.json.gz',executions)
    assert executions['fractional-write']['returncode']==1
    assert c.decode(executions['fractional-write']['stdout_base64'])==b''
    assert c.decode(executions['fractional-write']['stderr_base64'])==b'linkedspec: parser invocation failed\n'
    assert executions['valid-null']['returncode']==0
    assert c.decode(executions['valid-null']['stdout_base64'])==b'null\n'
    assert not c.decode(executions['valid-null']['stderr_base64'])
    healthy = render(packets)
    validate(healthy,commands)
    faults = dict(
        heading=changed(packets,document.HEADING.encode(),b'Removed CLI heading'),
        command=changed(packets,commands['fractional-write'].encode(),commands['fractional-write'].replace('items[1.5]','items[0]').encode()),
        protocol=changed(packets,document.PROTOCOL.encode(),document.PROTOCOL.replace('`1`','`0`').encode()))
    c.write_new('book-changed-inputs.json.gz',faults)
    runs = {name:render(value) for name,value in faults.items()}
    reasons = dict(heading='CLI heading',command='CLI executable source',protocol='CLI failure protocol')
    denials = {}
    for name,run in runs.items():
        assert run['returncode']==0
        try:
            validate(run,commands)
        except AssertionError as error:
            assert str(error)==reasons[name]
            denials[name]=str(error)
        else:
            raise AssertionError('changed source/render admitted')
    stable = c.unchanged(epoch['inputs'])
    c.write_new('book-runs.json.gz',dict(healthy=healthy,faults=runs,denials=denials,inputs_unchanged=stable))
    assert stable
    print('Book PASS:',len(packets),'complete inputs;two exact executed CLI commands;three actual source/render denials')


if __name__ == '__main__':
    main()
