"""Execute the exact new book examples and falsify the actual rendered anchor."""
import html
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import common as c
import document2 as document
import oracle

PAGE='dsl/values-containers-and-flow-helpers.html'
REFERENCE='dsl/value-container-flow-helper-reference.html'
ANCHOR='registered-array-pipelines-and-length'

def examples():
    text=c.source(document.CHAPTER).read_text()
    assert text.count(document.HEADING)==1
    section=re.split(r'\n#{1,3} ',text.split(document.HEADING+'\n',1)[1],maxsplit=1)[0]
    bodies=re.findall(r'^```text\n(.*?)^```\s*$',section,re.M|re.S)
    plan=c.load('book-cases.json')
    assert len(bodies)==len(plan['cases'])
    for body,case in zip(bodies,plan['cases']):
        key='source' if 'source' in case else 'body'
        assert body==case[key]
    return plan

def inputs():
    tracked=set(subprocess.check_output(['git','ls-files','-z'],cwd=c.ROOT).decode().split('\0'))
    paths={p for p in tracked if p.startswith('docs/linkedspec-book/src/') or p=='docs/linkedspec-book/book.toml'}
    pending=list(paths)
    while pending:
        path=pending.pop()
        for match in re.findall(rb'\{\{#include\s+([^}\s]+)\s*\}\}',c.source(path).read_bytes()):
            relative=((c.ROOT/path).parent/match.decode().split(':',1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert relative in tracked
            if relative not in paths:
                paths.add(relative)
                pending.append(relative)
    return {p:c.read(p) for p in sorted(paths)}

def render(supplied,changed=False):
    with tempfile.TemporaryDirectory(prefix='registered-pipeline-book-',dir=os.environ['TMPDIR']) as folder:
        root=Path(folder)
        assert root.stat().st_dev==c.ROOT.stat().st_dev
        for path,packet in supplied.items():
            raw=c.decode(packet['base64'])
            assert c.sha(raw)==packet['sha256']
            if changed and path==document.CHAPTER:
                old=document.HEADING.encode()
                assert raw.count(old)==1
                raw=raw.replace(old,b'### Deliberately removed pipeline anchor',1)
            target=root/path
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(raw)
            target.chmod(packet['mode'])
        command=['mdbook','build','docs/linkedspec-book','-d','output']
        environment={k:v for k,v in os.environ.items() if not k.startswith('MDBOOK_')}
        process=subprocess.run(command,cwd=root,env=environment,capture_output=True)
        return dict(command=command,returncode=process.returncode,stdout_base64=c.encode(process.stdout),
            stderr_base64=c.encode(process.stderr),pages={p:c.encode((root/'output'/p).read_bytes()) for p in (PAGE,REFERENCE)})

def validate(run,plan):
    assert run['returncode']==0,'book build'
    page=c.decode(run['pages'][PAGE]).decode()
    assert 'id="'+ANCHOR+'"' in page,'pipeline anchor'
    for case in plan['cases']:
        assert case.get('source',case.get('body')).rstrip() in html.unescape(page),'executed example'
    assert ANCHOR in c.decode(run['pages'][REFERENCE]).decode(),'reference link'

def main():
    plan=examples()
    supplied=inputs()
    c.write_new('book-inputs.json.gz',dict(inputs=supplied,producer=c.read(c.PREFIX+'book.py'),plan=plan))
    c.write_new('book-epoch.json.gz',c.epoch())
    public=c.observe(plan)
    builds={name:render(supplied,changed) for name,changed in [('healthy',False),('changed',True)]}
    try:
        validate(builds['changed'],plan)
    except AssertionError as error:
        control=dict(rejected=True,reason=str(error))
    else:
        control=dict(rejected=False,reason='')
    failed=oracle.failures(public,plan)
    stable=all(c.read(p)==packet for p,packet in supplied.items())
    c.write_new('book-run.json.gz',dict(public=public,builds=builds,control=control,failures=failed,
        inputs_unchanged=stable,version=c.run(['mdbook','--version'])))
    validate(builds['healthy'],plan)
    assert control==dict(rejected=True,reason='pipeline anchor')
    assert not failed and stable,failed
    print('Book GREEN:',len(supplied),'complete inputs;',len(plan['cases']),'executed examples; actual anchor RED')

if __name__=='__main__':main()
