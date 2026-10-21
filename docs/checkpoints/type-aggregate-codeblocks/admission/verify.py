"""Verify first-draft custody and the distinct lossless corrected-book epoch."""
import gzip
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import doc_proof
import oracle
from admission import inspect_index


def first():
    saved=c.load('admission/first.json.gz')
    assert saved['base']==c.BASE and len(saved['inputs'])==10496 and len(saved['images'])==10499
    assert c.read(c.PREFIX+'admission/preserve.py')==saved['producer']
    assert saved['baseline']['returncode']==0 and not c.decode(saved['baseline']['stderr_base64'])
    assert b'10496 closed inputs;214 cases/106 RED;7 faults' in c.decode(saved['baseline']['stdout_base64'])
    assert saved['pressure']['returncode']!=0
    assert b'aggregate lines 50007/50000' in c.decode(saved['pressure']['stdout_base64'])+c.decode(saved['pressure']['stderr_base64'])
    assert json.loads(c.decode(saved['publication']['base64']))['record_base64']==saved['claim']['base64']
    manifest=json.loads(gzip.decompress(c.decode(saved['manifest']['base64'])))
    assert manifest['inputs']==saved['inputs']
    base={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            base[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    for path,image in saved['images'].items():
        identity={key:image[key] for key in ('sha256','mode')}
        if path in saved['before']:
            packet=saved['before'][path]
            assert c.sha(c.decode(packet['base64']))==packet['sha256']==image['sha256']
            assert packet['mode']==image['mode']
        elif base.get(path)!=image['git']:
            assert c.identity(path)==identity,path
        if path in saved['inputs']:assert saved['inputs'][path]==identity
    verified=saved['git_verification']
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[
        saved['images'][path]['git']['oid'] for path in sorted(saved['images'])]
    aborted=c.load('admission/preflight-superseded.json.gz')
    assert aborted['joined_status']==143 and aborted['absence']['returncode']==1
    return dict(first_inputs=10496,staged_images=10499,baseline_exit=0,preflight_superseded=143)


def index_identity():
    saved=c.load('admission/render-index.json.gz')
    observed=c.load('admission/index-differences.json.gz')
    assert saved['producer']==c.read(c.PREFIX+'admission/render_identity.py')
    assert observed['producer']==c.read(c.PREFIX+'admission/inspect_index.py')
    values={}
    for name,build in saved['builds'].items():
        run=c.run(['node','-e',inspect_index.PROGRAM],input=c.decode(build['searchindex_base64']))
        assert run==observed['runs'][name]
        values[name]=json.loads(c.decode(run['stdout_base64']))
    changes=inspect_index.differences(values['old'],values['new'])
    assert changes==observed['differences'] and len(changes)==15
    for item in changes:
        match=re.fullmatch(r'\$\.index\.documentStore\.docs\.(\d+)\.body',item['path'])
        assert match and item['whitespace_only']
        assert values['old']['doc_urls'][int(match[1])].startswith(doc_proof.PAGE+'#')
    rejected=c.load('admission/render-rejection.json.gz')
    assert rejected['run']['returncode']!=0 and len(rejected['differences'])==1
    pages=[]
    for name,stem in [('old','doc'),('new','admission/doc')]:
        build=saved['builds'][name]
        page=c.decode(build['page_base64'])
        assert build['page_base64']==c.load(stem+'-run.json.gz')['builds']['healthy']['page_base64']
        reference=build['searchindex_name'].encode()
        assert page.count(reference)==1
        pages.append(re.sub(rb'\s+',b' ',page.replace(reference,b'searchindex-VERIFIED.js')).strip())
    assert pages[0]==pages[1]
    return len(changes)


def check():
    result=first()
    correction=c.load('admission/correction.json.gz')
    path=doc_proof.CHAPTER
    before=c.decode(correction['before'][path]['base64']).decode()
    after=c.decode(correction['after'][path]).decode()
    assert (c.ROOT/path).read_text()==after
    assert re.sub(r'\s+','',before)==re.sub(r'\s+','',after)
    assert correction['code_fences_unchanged'] and correction['non_whitespace_unchanged']
    assert before.count('\n')-after.count('\n')==correction['lines_reduced']
    old=c.load('doc-run.json.gz');new=c.load('admission/doc-run.json.gz')
    inputs=c.load('admission/doc-inputs.json.gz')
    assert new['inputs_unchanged'] and c.unchanged(inputs['book'])
    assert inputs['plan']==c.load('doc-inputs.json.gz')['plan']==doc_proof.examples()
    assert not oracle.failures(new['public'],inputs['plan'])
    doc_proof.validate(new['builds']['healthy'],inputs['plan'])
    assert new['anchor_control']==dict(rejected=True,message='Missing aggregate heading anchor')
    changed_bodies=index_identity()
    retained_pressure=c.load('admission/pressure-after.json.gz')
    assert retained_pressure['inputs_unchanged']
    assert retained_pressure['producer']==c.read(c.PREFIX+'admission/pressure.py')
    pressure=retained_pressure['run']
    assert pressure['returncode']==0
    output=c.decode(pressure['stdout_base64'])
    match=re.search(rb'surface public_reference files=(\d+) lines=(\d+) bytes=(\d+)',output)
    assert match and int(match[2])==correction['predicted_public_reference_lines']<50000
    result.update(public_reference_before=50007,public_reference_after=int(match[2]),
        prose_lines_reduced=correction['lines_reduced'],rendered_content_identical=True,
        search_index_body_whitespace_changes=changed_bodies,
        book_inputs=len(inputs['book']),book_examples=3)
    return result


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
