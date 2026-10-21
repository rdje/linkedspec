"""Retain the refused capture and repair every output reference before final admission."""
import json
from pathlib import Path
import shutil
import subprocess
import sys

root=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(root/'docs/checkpoints/type-array-pipelines'))
import common as c
import context
import publish

def main():
    paths=publish.input_paths()+[publish.CLAIM]
    saved=context.snapshot(paths)
    tracked=set(subprocess.check_output(['git','ls-files','-z'],cwd=root).decode().split('\0'))
    saved['new_inputs']={p:c.read(p) for p in paths if p not in tracked and not p.endswith(('.gz','.part'))}
    log=c.read('.linkedspec-data/verification/type-pipeline-publication2.log')
    assert b'FileExistsError' in c.decode(log['base64']) and not (root/publish.MANIFEST).exists()
    failed=dict(context=saved,log=log,publisher=c.read(c.PREFIX+'publish.py'),
        producer=c.read(Path(__file__).resolve().relative_to(root).as_posix()),
        scope='Actual refused capture before proof execution or output mutation. Old hard-coded manifest path hits exclusive creation; first publication/claim remain exact. No success is claimed and no runtime/test/book result changes.')
    c.write_new('report-writer-failure.json.gz',failed)
    names=[c.PREFIX+'publish.py',c.PREFIX+'review.py',c.PREFIX+'custody.py',c.PREFIX+'README.md','MEMORY.md']
    before={p:c.read(p) for p in names};after={p:c.decode(packet['base64']).decode() for p,packet in before.items()}
    path=c.PREFIX+'publish.py';text=after[path]
    text=text.replace("MANIFEST=c.PREFIX+'publication2-inputs.json.gz'","MANIFEST_NAME='publication2-inputs.json.gz'\nMANIFEST=c.PREFIX+MANIFEST_NAME",1)
    text=text.replace("PUBLICATION=c.PREFIX+'publication2.json'","PUBLICATION_NAME='publication2.json'\nPUBLICATION=c.PREFIX+PUBLICATION_NAME",1)
    text=text.replace("(['--controls'],['--controls','artifact2-inputs.json.gz'])","(['--controls'],['--controls','artifact2-inputs.json.gz'],['--controls','artifact3-inputs.json.gz'])",1)
    text=text.replace("c.write_new('publication-inputs.json.gz',",'c.write_new(MANIFEST_NAME,',1)
    text=text.replace("c.load('publication-inputs.json.gz')",'c.load(MANIFEST_NAME)',1)
    text=text.replace("c.write_new('publication.json',",'c.write_new(PUBLICATION_NAME,',1)
    text=text.replace("c.load('publication.json')",'c.load(PUBLICATION_NAME)',1)
    text=text.replace("    if capture:c.write_new(MANIFEST_NAME,", "    if capture:\n        assert c.read(CLAIM)==c.load('report-first.json.gz')['claim']\n        c.write_new(MANIFEST_NAME,",1)
    text=text.replace("        with (c.ROOT/CLAIM).open('xb') as output:output.write(raw)","        assert c.read(CLAIM)==c.load('report-first.json.gz')['claim']\n        (c.ROOT/CLAIM).write_bytes(raw)",1)
    assert "c.write_new('publication" not in text and "c.load('publication" not in text
    compile(text,path,'exec');after[path]=text
    path=c.PREFIX+'review.py';text=after[path]
    for old,new in [('artifact2-inputs.json.gz','artifact3-inputs.json.gz'),('artifact2-run.json.gz','artifact3-run.json.gz'),('artifact2-observed.json.gz','artifact3-observed.json.gz')]:text=text.replace(old,new)
    old="if __name__=='__main__':print(json.dumps(check(),sort_keys=True))"
    assert text.count(old)==1
    text=text.replace(old,"if __name__=='__main__':\n    import sys\n    assert sys.argv[1:] in ([],['--retained'])\n    print(json.dumps(check(fresh=not sys.argv[1:]),sort_keys=True))",1)
    compile(text,path,'exec');after[path]=text
    path=c.PREFIX+'custody.py';text=after[path]
    old="    contexts['report-first']=first['context']\n"
    new=old+"    failed=c.load('report-writer-failure.json.gz')\n    assert b'FileExistsError' in c.decode(failed['log']['base64'])\n    contexts['refused-report-writer']=failed['context']\n"
    assert text.count(old)==1;after[path]=text.replace(old,new,1)
    text=(root/(c.PREFIX+'artifacts2.py')).read_text()
    for old,new in [('artifact2-inputs.json.gz','artifact3-inputs.json.gz'),('artifact2-run.json.gz','artifact3-run.json.gz'),('artifact2-observed.json.gz','artifact3-observed.json.gz'),('artifacts2.py','artifacts3.py')]:text=text.replace(old,new)
    compile(text,c.PREFIX+'artifacts3.py','exec')
    with (root/(c.PREFIX+'artifacts3.py')).open('x') as output:output.write(text)
    after[c.PREFIX+'README.md']+='\nThe first corrected capture was refused before proof execution because one writer reference still used the old filename. report-writer-failure.json.gz retains its actual source/context/stream; exclusive creation preserved every old output. Final names are shared constants, the old claim is compared with the whole retained first record before replacement, and artifact3-* falsifies the final publisher. `review.py --retained` checks archived evidence only; the default publisher still executes fresh public/book proof.\n'
    after['MEMORY.md']=after['MEMORY.md'].replace('final artifact2 controls','final artifact3 controls')
    for p,text in after.items():(root/p).write_text(text)
    shutil.copy2(Path(__file__),root/(c.PREFIX+'writer-repair.py'))
    c.write_new('writer-repair.json.gz',dict(before=before,after={p:c.read(p) for p in names},producer=c.read(c.PREFIX+'writer-repair.py')))
    print('Output references unified; retained first claim guarded; final artifact3 verification and source-closed capture next')

if __name__=='__main__':main()
