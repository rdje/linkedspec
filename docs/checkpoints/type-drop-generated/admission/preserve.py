"""Preserve the whole first drop draft and exact real staged images before repair."""
import json
import subprocess
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c

PREFIX=c.PREFIX+'admission/'
CLAIM='docs/claims/'+c.OWNER+'.json'
FACT='docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md'


def main():
    original={path:c.read(path) for path in (CLAIM,c.PREFIX+'publication-inputs.json',c.PREFIX+'publication.json')}
    manifest=json.loads(c.decode(original[c.PREFIX+'publication-inputs.json']['base64']))
    publication=json.loads(c.decode(original[c.PREFIX+'publication.json']['base64']))
    assert publication['record_base64']==original[CLAIM]['base64']
    assert len(manifest['inputs'])==10304 and c.unchanged(manifest['inputs'])
    baseline={name:c.read('.linkedspec-data/verification/type-drop-publication-readonly.'+name) for name in ('log','status')}
    assert c.decode(baseline['status']['base64']).strip()==b'0'
    assert b'10304 closed inputs;34 values/14 diagnostics;4 producer faults' in c.decode(baseline['log']['base64'])
    index=subprocess.check_output(['git','ls-files','--stage','-z'],cwd=c.ROOT)
    images={}
    for row in index.split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1);mode,oid,stage=metadata.decode().split()
        assert stage=='0'
        if mode in ('100644','100755'):
            path=name.decode()
            images[path]=dict(**c.identity(path),git_mode=mode,oid=oid)
    paths=sorted(images)
    verified=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(paths)+'\n').encode())
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[images[path]['oid'] for path in paths]
    assert all({key:images[path][key] for key in ('sha256','mode')}==item for path,item in manifest['inputs'].items())
    before_paths=[FACT,'docs/knowledge/terse-type-method-surface-inventory.md','KNOWLEDGE_MAP.md',
        'docs/tasks/TYPE-REFERENCE-BOOK.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','CHANGES.md',
        'DEVELOPMENT_NOTES.md',c.PREFIX+'README.md']
    before={path:c.read(path) for path in before_paths}
    old=c.run(['bash','tools/run_python_project_data.sh','docs/checkpoints/type-numeric-codeblocks/publish_recurrence.py'])
    assert old['returncode']!=0 and b"assert c.load('publication-recurrence-inputs.json')['inputs'] == inputs" in c.decode(old['stderr_base64'])
    assert c.unchanged(manifest['inputs'])
    c.write_new('admission/first.json.gz',dict(owner=c.OWNER,base=c.BASE,original=original,inputs=manifest['inputs'],
        images=images,index_base64=c.encode(index),git_verification=verified,baseline=baseline,before=before,
        old_reverify=old,producer=c.read(PREFIX+'preserve.py'),primitives=c.read(c.PREFIX+'common.py'),
        scope='Whole first unpublished drop record/publication/10304-input manifest/full modes, actual readonly0 '
              'and independently Git-verified staged source images. Changed bound files have whole before-images; '
              'other primary bytes remain available. The actual old fact command RED precedes the correction. '
              'Base9fc identifies only the accepted activation, never the unpublished draft.'))
    print('Whole first drop draft/10304 inputs and exact staged images preserved; old current-fact route observed RED')


if __name__=='__main__':main()
