"""Run the actual three new book bodies and a real displaced-anchor RED."""
import html
import json
import sys
import os
from pathlib import Path
import re
import subprocess
import tempfile
import common as c
import context
import oracle

CHAPTER='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
HEADING=b'### Aggregate numeric helpers in codeblocks'
ANCHOR='id="aggregate-numeric-helpers-in-codeblocks"'
PAGE='dsl/values-containers-and-flow-helpers.html'


def examples():
    text=(c.ROOT/CHAPTER).read_text()
    assert text.count(HEADING.decode())==1
    section=text.split(HEADING.decode()+'\n',1)[1].split('\n### ',1)[0]
    bodies=re.findall(r'^```text\n(.*?)^```\s*$',section,re.M|re.S)
    plan=c.load('book-cases.json')
    assert len(bodies)==len(plan['cases'])==3
    for body,case in zip(bodies,plan['cases']):
        assert re.sub(r'\s+','',body)==re.sub(r'\s+','',case['body'])
        case['body']=body
    return plan


def book_inputs():
    tracked=set(subprocess.check_output(['git','ls-files','-z'],cwd=c.ROOT).decode().split('\0'))
    paths={path for path in tracked if path.startswith('docs/linkedspec-book/src/') or path=='docs/linkedspec-book/book.toml'}
    pending=list(paths)
    while pending:
        path=pending.pop()
        for name in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}',(c.ROOT/path).read_bytes()):
            relative=((c.ROOT/path).parent/name.decode().split(':',1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert relative in tracked
            if relative not in paths:paths.add(relative);pending.append(relative)
    return {path:c.identity(path) for path in sorted(paths)}


def render(inputs,changed=False):
    assert c.unchanged(inputs)
    with tempfile.TemporaryDirectory(prefix='aggregate-book-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory)
        assert root.stat().st_dev==c.ROOT.stat().st_dev
        for path,item in inputs.items():
            raw=(c.ROOT/path).read_bytes();assert c.sha(raw)==item['sha256']
            if changed and path==CHAPTER:
                assert raw.count(HEADING)==1
                raw=raw.replace(HEADING,b'### Deliberately displaced aggregate heading',1)
            target=root/path;target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(raw);target.chmod(item['mode'])
        command=['mdbook','build','docs/linkedspec-book','-d','output']
        environment={key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
        run=subprocess.run(command,cwd=root,env=environment,capture_output=True)
        page=(root/'output'/PAGE).read_bytes()
    assert c.unchanged(inputs)
    return dict(command=command,returncode=run.returncode,stdout_base64=c.encode(run.stdout),
        stderr_base64=c.encode(run.stderr),page_base64=c.encode(page))


def validate(build,plan):
    assert build['returncode']==0
    page=c.decode(build['page_base64']).decode()
    assert ANCHOR in page,'Missing aggregate heading anchor'
    for case in plan['cases']:assert case['body'].rstrip() in html.unescape(page)


def main():
    stem=sys.argv[1] if len(sys.argv)>1 else "doc"
    assert stem in ("doc","admission/doc")
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot.update(book=book_inputs(),plan=examples(),
        new_inputs={path:c.read(path) for path in extras if not path.endswith('.gz')})
    c.write_new(stem+'-inputs.json.gz',snapshot)
    knowledge=c.run(['bash','knowledge-map/scripts/check_knowledge_map.sh'])
    public=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(snapshot['plan']).encode())
    builds=dict(healthy=render(snapshot['book']),changed=render(snapshot['book'],True))
    try:validate(builds['changed'],snapshot['plan'])
    except AssertionError as error:red=dict(rejected=True,message=str(error))
    else:red=dict(rejected=False,message='')
    stable=c.unchanged(snapshot['inputs'])
    c.write_new(stem+'-run.json.gz',dict(knowledge=knowledge,public=public,builds=builds,anchor_control=red,
        inputs_unchanged=stable,toolchain=c.run(['mdbook','--version'])))
    assert stable and knowledge['returncode']==0 and not oracle.failures(public,snapshot['plan'])
    validate(builds['healthy'],snapshot['plan'])
    assert red==dict(rejected=True,message='Missing aggregate heading anchor')
    print('Book/Knowledge PASS:',len(snapshot['book']),'inputs;3 actual examples; observed displaced-anchor RED')


if __name__=='__main__':main()
