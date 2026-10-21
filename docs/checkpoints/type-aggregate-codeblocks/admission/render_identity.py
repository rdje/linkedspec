"""Capture the generated search-index artifact responsible for the HTML difference."""
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import doc_proof


def build(packets):
    with tempfile.TemporaryDirectory(prefix='aggregate-render-identity-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory)
        assert root.stat().st_dev==ROOT.stat().st_dev
        for path,packet in packets.items():
            raw=c.decode(packet['base64']);assert c.sha(raw)==packet['sha256']
            target=root/path;target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(raw);target.chmod(packet['mode'])
        command=['mdbook','build','docs/linkedspec-book','-d','output']
        environment={key:value for key,value in os.environ.items() if not key.startswith('MDBOOK_')}
        run=subprocess.run(command,cwd=root,env=environment,capture_output=True)
        page=(root/'output'/doc_proof.PAGE).read_bytes()
        names=re.findall(rb'window\.path_to_searchindex_js = "\.\./(searchindex-[a-f0-9]+\.js)";',page)
        assert len(names)==1
        index=(root/'output'/names[0].decode()).read_bytes()
        return dict(command=command,returncode=run.returncode,stdout_base64=c.encode(run.stdout),
            stderr_base64=c.encode(run.stderr),page_base64=c.encode(page),
            searchindex_name=names[0].decode(),searchindex_base64=c.encode(index))


def main():
    old=c.load('doc-inputs.json.gz')['book'];new=c.load('admission/doc-inputs.json.gz')['book']
    assert c.unchanged(new)
    assert set(old)==set(new) and [path for path in old if old[path]!=new[path]]==[doc_proof.CHAPTER]
    packets={path:c.read(path) for path in new}
    old_packets=dict(packets)
    old_packets[doc_proof.CHAPTER]=c.load('admission/correction.json.gz')['before'][doc_proof.CHAPTER]
    for declared,actual in ((old,old_packets),(new,packets)):
        assert declared=={path:{key:packet[key] for key in ('sha256','mode')} for path,packet in actual.items()}
    builds={name:build(inputs) for name,inputs in [('old',old_packets),('new',packets)]}
    for name,stem in [('old','doc'),('new','admission/doc')]:
        assert builds[name]['returncode']==0
        assert builds[name]['page_base64']==c.load(stem+'-run.json.gz')['builds']['healthy']['page_base64']
    assert c.unchanged(new)
    c.write_new('admission/render-index.json.gz',dict(old_inputs=old_packets,new_inputs=packets,
        builds=builds,producer=c.read(c.PREFIX+'admission/render_identity.py'),
        scope='Actual89-input rebuilds reproduce both measured complete HTML pages byte-for-byte. '
              'Retain the generated search-index payload named by each page before deciding a comparison rule.'))
    for name,build_result in builds.items():
        raw=c.decode(build_result['searchindex_base64'])
        print(name,build_result['searchindex_name'],len(raw),repr(raw[:220]))


if __name__=='__main__':main()
