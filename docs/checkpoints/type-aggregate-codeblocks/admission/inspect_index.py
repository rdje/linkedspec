"""Decode the two actual generated indexes and locate their semantic differences."""
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c

PROGRAM="const vm=require('node:vm');let raw=require('node:fs').readFileSync(0,'utf8');let context={window:{search:{}}};vm.runInNewContext(raw,context,{timeout:5000});process.stdout.write(JSON.stringify(context.window.search));"


def differences(old,new,path='$'):
    if type(old)!=type(new):return [dict(path=path,old=old,new=new)]
    if isinstance(old,dict):
        assert old.keys()==new.keys(),path
        return [item for key in old for item in differences(old[key],new[key],path+'.'+key)]
    if isinstance(old,list):
        assert len(old)==len(new),path
        return [item for index,(a,b) in enumerate(zip(old,new)) for item in differences(a,b,path+'['+str(index)+']')]
    return [] if old==new else [dict(path=path,old=old,new=new,
        whitespace_only=isinstance(old,str) and re.sub(r'\s+',' ',old).strip()==re.sub(r'\s+',' ',new).strip())]


def main():
    captured=c.load('admission/render-index.json.gz')
    runs={name:c.run(['node','-e',PROGRAM],input=c.decode(item['searchindex_base64']))
        for name,item in captured['builds'].items()}
    for run in runs.values():assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    values={name:json.loads(c.decode(run['stdout_base64'])) for name,run in runs.items()}
    changed=differences(values['old'],values['new'])
    c.write_new('admission/index-differences.json.gz',dict(runs=runs,differences=changed,
        producer=c.read(c.PREFIX+'admission/inspect_index.py'),toolchain=c.run(['node','--version'])))
    print('Decoded index differences:',len(changed))
    for item in changed[:8]:
        print(item['path'],'whitespace_only=',item.get('whitespace_only'),
            'old=',repr(str(item['old'])[:250]),'new=',repr(str(item['new'])[:250]))


if __name__=='__main__':main()
