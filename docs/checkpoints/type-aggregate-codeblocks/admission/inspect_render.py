"""Retain and locate the surprising complete-render comparison rejection."""
import difflib
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c


def main():
    old=c.load('doc-run.json.gz');new=c.load('admission/doc-run.json.gz')
    pages=[c.decode(run['builds']['healthy']['page_base64']) for run in (old,new)]
    normalized=[re.sub(rb'\s+',b' ',page).strip() for page in pages]
    run=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'admission/verify.py'])
    assert run['returncode']!=0 and b'AssertionError' in c.decode(run['stderr_base64'])
    differences=[]
    words=[value.split() for value in normalized]
    for tag,a,b,x,y in difflib.SequenceMatcher(a=words[0],b=words[1],autojunk=False).get_opcodes():
        if tag!='equal':
            differences.append(dict(tag=tag,old=c.encode(b' '.join(words[0][max(0,a-8):b+8])),
                new=c.encode(b' '.join(words[1][max(0,x-8):y+8]))))
    c.write_new('admission/render-rejection.json.gz',dict(run=run,differences=differences,
        verifier=c.read(c.PREFIX+'admission/verify.py'),producer=c.read(c.PREFIX+'admission/inspect_render.py'),
        old_page_sha256=c.sha(pages[0]),new_page_sha256=c.sha(pages[1]),
        scope='Actual first complete-render comparison rejection; locate its precise cause before '
              'changing any assertion or source. Old and new raw pages stay in their measured epochs.'))
    print('Changed rendered spans:',len(differences))
    for item in differences[:8]:
        print(item['tag'],'OLD',c.decode(item['old']).decode(),'NEW',c.decode(item['new']).decode())


if __name__=='__main__':main()
