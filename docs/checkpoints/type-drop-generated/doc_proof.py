"""Execute the three actual book bodies and render their real chapter anchor."""
import html
import json
import os
import re
import subprocess
import tempfile
from pathlib import Path
import common as c
import context
import oracle

CHAPTER='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
HEADING=b'### Removing keys in Perl'
ANCHOR='id="removing-keys-in-perl"'
PAGE='dsl/values-containers-and-flow-helpers.html'


def examples():
    text=(c.ROOT/CHAPTER).read_text()
    assert text.count(HEADING.decode())==1
    section=text.split(HEADING.decode()+'\n',1)[1].split('\n## ',1)[0]
    bodies=re.findall(r'^```text\n(.*?)^```\s*$',section,re.M|re.S)
    plan=json.loads((c.ROOT/'tests/drop-generated/book-cases.json').read_bytes())
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
    with tempfile.TemporaryDirectory(prefix='drop-book-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory)
        root.resolve().relative_to(c.ROOT.resolve())
        assert root.stat().st_dev==c.ROOT.stat().st_dev
        for path,item in inputs.items():
            raw=(c.ROOT/path).read_bytes()
            assert c.sha(raw)==item['sha256']
            if changed and path==CHAPTER:
                assert raw.count(HEADING)==1
                raw=raw.replace(HEADING,b'### Deliberately displaced drop heading',1)
            target=root/path
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(raw);target.chmod(item['mode'])
        command=['mdbook','build','docs/linkedspec-book','-d','output']
        environment={key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
        run=subprocess.run(command,cwd=root,env=environment,capture_output=True)
        page=(root/'output'/PAGE).read_bytes()
    assert c.unchanged(inputs)
    return dict(command=command,returncode=run.returncode,stdout_base64=c.encode(run.stdout),
                stderr_base64=c.encode(run.stderr),page_base64=c.encode(page))


def validate(build,plan,changed=False):
    assert build['returncode']==0
    page=c.decode(build['page_base64']).decode()
    assert (ANCHOR in page)!=changed
    for case in plan['cases']:assert case['body'].rstrip() in html.unescape(page)


def main():
    extras=[c.PREFIX+path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    extras+=['tests/drop-generated/cases.json','tests/drop-generated/book-cases.json','t/drop_keys_generated.t',
             'tests/language-readiness/drop-generated-regression-evolution.json.gz']
    snapshot=context.snapshot(extras)
    book,plan=book_inputs(),examples()
    snapshot.update(book=book,examples=plan)
    c.write_new('doc-inputs.json.gz',snapshot)
    knowledge=c.run(['bash','knowledge-map/scripts/check_knowledge_map.sh'])
    public=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    builds=dict(healthy=render(book),changed=render(book,True))
    value=dict(knowledge=knowledge,examples=public,builds=builds,
               toolchain=c.run(['mdbook','--version']),inputs_unchanged=c.unchanged(snapshot['inputs']))
    c.write_new('doc-run.json.gz',value)
    assert knowledge['returncode']==0 and not oracle.failures(public,plan)
    for name,build in builds.items():validate(build,plan,name=='changed')
    assert value['inputs_unchanged']
    print('Book/Knowledge PASS:',len(book),'render inputs;3 actual examples; displaced-heading RED')


if __name__=='__main__':main()
