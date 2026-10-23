"""Retain complete book inputs, executable examples and actual source/render denials."""
import copy
import html
from html.parser import HTMLParser
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import common as c
import context
import document2 as document

PAGES = dict(flow='dsl/values-containers-and-flow-helpers.html',
    integration='public-api/integration-perl.html')
EXPECTED = dict(read_last=[30,[10,20,30]],callable_read=[None,[10,20,30]])


class Code(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.active = False
        self.current = []
        self.blocks = []
    def handle_starttag(self,tag,attrs):
        if tag == 'code':
            self.active = True
            self.current = []
    def handle_data(self,data):
        if self.active:
            self.current.append(data)
    def handle_endtag(self,tag):
        if tag == 'code' and self.active:
            self.blocks.append(''.join(self.current).rstrip('\n'))
            self.active = False


def validate(run,packets):
    assert run['returncode'] == 0, 'book command'
    flow = c.decode(run['pages']['flow']).decode()
    integration = c.decode(run['pages']['integration']).decode()
    assert document.MARKER in html.unescape(flow), 'book heading'
    assert document.CLI_MARKER in html.unescape(integration), 'CLI limitation'
    parser = Code()
    parser.feed(flow)
    for path in document.EXAMPLES:
        text = c.decode(packets[path]['base64']).decode().rstrip('\n')
        assert parser.blocks.count(text) == 1, 'rendered executable source'


def render(packets):
    with tempfile.TemporaryDirectory(prefix='signed-index-book-',dir=os.environ['TMPDIR']) as folder:
        root = Path(folder)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        for path,packet in packets.items():
            raw = c.decode(packet['base64'])
            assert c.sha(raw) == packet['sha256']
            target = root/path
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(raw)
            target.chmod(packet['mode'])
        command = ['mdbook','build','docs/linkedspec-book','-d','output']
        env = {key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
        result = subprocess.run(command,cwd=root,env=env,capture_output=True)
        return dict(command=command,returncode=result.returncode,
            stdout_base64=c.encode(result.stdout),stderr_base64=c.encode(result.stderr),
            pages={name:c.encode((root/'output'/path).read_bytes()) for name,path in PAGES.items()})


def changed(packets,path,old,new):
    result = copy.deepcopy(packets)
    packet = result[path]
    raw = c.decode(packet['base64'])
    assert raw.count(old) == 1
    raw = raw.replace(old,new,1)
    packet.update(base64=c.encode(raw),sha256=c.sha(raw))
    return result


def main():
    epoch = context.snapshot()
    available = set(c.paths())
    paths = {path for path in available if path.startswith('docs/linkedspec-book/src/')
        or path == 'docs/linkedspec-book/book.toml'}
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
    cases = {row['id']:row for row in c.load('cases.json')['cases']}
    plan = dict(cases=[dict(id=case_id,source=c.decode(packets[path]['base64']).decode(),input='x')
        for path,case_id in document.EXAMPLES.items()])
    assert all(row['source'] == cases[row['id']]['source'] for row in plan['cases'])
    c.write_new('book-cases.json',plan)
    c.write_new('book-inputs.json.gz',dict(context=epoch,inputs=packets,
        producer=c.read(c.PREFIX+'book.py'),constants=c.read(c.PREFIX+'document2.py'),
        probe=c.read(c.PREFIX+'perl_probe.pl'),scope='Complete configuration/source/recursive includes with full bytes/modes, including the two new exact source examples. Later mutable book changes do not replace this dated input epoch.'))
    runtime = c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'perl_probe.pl'],
        input=json.dumps(plan).encode())
    c.write_new('book-runtime.json.gz',runtime)
    assert runtime['returncode'] == 0 and not c.decode(runtime['stderr_base64'])
    observed = json.loads(c.decode(runtime['stdout_base64']))['rows']
    assert [row['id'] for row in observed] == [row['id'] for row in plan['cases']]
    for row in observed:
        expected = EXPECTED[row['id'].replace('-','_')]
        for route in ('native','generated'):
            value = row[route]
            assert value['completed'] and not value['exception'] and not value['last_error']
            assert not value['warnings'] and not value['stdout'] and value['value'] == expected
    healthy = render(packets)
    validate(healthy,packets)
    mutations = dict(
        heading=changed(packets,document.FLOW,document.MARKER.encode(),b'Changed heading'),
        source=changed(packets,'examples/negative-array-current-perl.spec',b'items[-1]',b'items[-2]'),
        cli=changed(packets,document.INTEGRATION,document.CLI_MARKER.encode(),b'Changed CLI description'))
    c.write_new('book-changed-inputs.json.gz',dict(overrides={name:{path:packet for path,packet in value.items()
        if packet != packets[path]} for name,value in mutations.items()},
        scope='Actual source mutations to heading, executable selector and CLI limitation before independent complete renders. Original inputs remain unchanged.'))
    runs = {}
    reasons = dict(heading='book heading',source='rendered executable source',cli='CLI limitation')
    for name,changed_inputs in mutations.items():
        result = render(changed_inputs)
        runs[name] = result
        try:
            validate(result,packets)
        except AssertionError as error:
            assert str(error) == reasons[name]
        else:
            raise AssertionError('changed book admitted: '+name)
    stable = c.unchanged(epoch['inputs']) and all(c.read(path) == packet for path,packet in packets.items())
    c.write_new('book-runs.json.gz',dict(healthy=healthy,faults=runs,inputs_unchanged=stable,
        version=c.run(['mdbook','--version'])))
    assert stable
    print('Book PASS:',len(packets),'complete inputs;2 exact native/fresh examples;3 actual source/render denials')


if __name__ == '__main__':
    main()
