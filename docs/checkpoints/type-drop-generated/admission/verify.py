"""Verify the whole first draft, exact staged images and current history route."""
import copy
import gzip
import json
import subprocess
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c
import custody

FACT='docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md'
TYPE='docs/knowledge/terse-type-method-surface-inventory.md'
COMMAND='bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
OLD_COMMAND='bash tools/run_python_project_data.sh docs/checkpoints/type-numeric-codeblocks/publish_recurrence.py'


def fact():
    raw=(c.ROOT/FACT).read_text()
    header=raw.split('\n---\n',1)[0]
    assert '\nreverify: "'+COMMAND+'"\n' in header+'\n','current historical reverify must use composed producer'
    assert OLD_COMMAND not in header,'frozen numeric publication cannot be a current unqualified route'
    assert 'Drop owner6 inverses two complete subtests before numeric22/evaluated70.' in raw
    assert 'Keep644' in raw and 'add six omission/duplication/corruption denials.' in raw
    type_header=(c.ROOT/TYPE).read_text().split('\n---\n',1)[0]
    assert c.PREFIX+'publish_final.py' in type_header


def packets():
    pool={}
    def walk(value):
        if isinstance(value,dict):
            if {'base64','sha256','mode'}<=value.keys():
                raw=c.decode(value['base64']);assert c.sha(raw)==value['sha256']
                pool[(value['sha256'],value['mode'])]=raw
            for item in value.values():walk(item)
        elif isinstance(value,list):
            for item in value:walk(item)
    for value in custody.records().values():walk(value)
    for path in (c.ROOT/(c.PREFIX+'admission')).rglob('*.json.gz'):
        walk(json.loads(gzip.decompress(path.read_bytes())))
    return pool


def first_image(saved=None):
    saved=c.load('admission/first.json.gz') if saved is None else saved
    assert saved['base']==c.BASE and saved['producer']==c.read(c.PREFIX+'admission/preserve.py')
    assert saved['primitives']==c.read(c.PREFIX+'common.py')
    original=saved['original']
    manifest=json.loads(c.decode(original[c.PREFIX+'publication-inputs.json']['base64']))
    publication=json.loads(c.decode(original[c.PREFIX+'publication.json']['base64']))
    assert publication['record_base64']==original['docs/claims/'+c.OWNER+'.json']['base64']
    assert manifest['inputs']==saved['inputs'] and len(saved['inputs'])==10304
    assert c.decode(saved['baseline']['status']['base64']).strip()==b'0','first readonly baseline must be zero'
    assert b'10304 closed inputs;34 values/14 diagnostics;4 producer faults' in c.decode(saved['baseline']['log']['base64'])
    assert saved['old_reverify']['returncode']!=0
    assert b"assert c.load('publication-recurrence-inputs.json')['inputs'] == inputs" in c.decode(saved['old_reverify']['stderr_base64'])
    images={}
    for row in c.decode(saved['index_base64']).split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1);mode,oid,stage=metadata.decode().split()
        assert stage=='0'
        if mode in ('100644','100755'):images[name.decode()]=dict(git_mode=mode,oid=oid)
    assert set(images)==set(saved['images'])
    for path,packet in {**original,**saved['before']}.items():
        assert c.sha(c.decode(packet['base64']))==packet['sha256']
        assert {key:packet[key] for key in ('sha256','mode')}=={
            key:saved['images'][path][key] for key in ('sha256','mode')}, 'retained packet/staged image mismatch'
    for path,item in saved['images'].items():
        assert {key:item[key] for key in ('git_mode','oid')}==images[path],'staged image/index mismatch'
    assert saved['git_verification']['returncode']==0 and not c.decode(saved['git_verification']['stderr_base64'])
    assert c.decode(saved['git_verification']['stdout_base64']).decode().splitlines()==[images[path]['oid'] for path in sorted(images)]
    assert all({key:saved['images'][path][key] for key in ('sha256','mode')}==item for path,item in saved['inputs'].items())
    pool=packets()
    for path,item in saved['images'].items():
        wanted={key:item[key] for key in ('sha256','mode')}
        if (c.ROOT/path).is_file() and c.identity(path)==wanted:continue
        if (item['sha256'],item['mode']) in pool:continue
        run=c.run(['git','show',c.BASE+':'+path])
        assert run['returncode']==0,'first staged image is unrecoverable: '+path
        raw=c.decode(run['stdout_base64'])
        mode=subprocess.check_output(['git','ls-tree',c.BASE,'--',path],cwd=c.ROOT).split()[0]
        full_mode=0o755 if mode==b'100755' else 0o644
        assert c.sha(raw)==item['sha256'] and full_mode==item['mode'],'first staged image is unrecoverable: '+path
    correction=c.load('admission/correction.json.gz')
    assert correction['before']==saved['before']
    assert correction['producer']==c.read(c.PREFIX+'admission/correct.py')
    expected=dict(correction['after'])
    cache_inputs=c.load('admission/cache-cleanup-inputs.json.gz')
    cache_result=c.load('admission/cache-cleanup.json.gz')
    for path in ('MEMORY.md','docs/tasks/TYPE-REFERENCE-BOOK.md'):
        assert c.decode(cache_inputs['before'][path]['base64'])==c.decode(expected[path])
        expected[path]=cache_inputs['after'][path]
    for path,raw in expected.items():assert (c.ROOT/path).read_bytes()==c.decode(raw)
    for path,raw in cache_inputs['after'].items():assert (c.ROOT/path).read_bytes()==c.decode(raw)
    cache_path=c.PREFIX+'__pycache__/common.cpython-314.pyc'
    assert not (c.ROOT/cache_path).exists() and cache_result['residue_absent'] and cache_result['staged_cache_absent']
    assert {key:cache_inputs['cache'][key] for key in ('sha256','mode')}=={
        key:saved['images'][cache_path][key] for key in ('sha256','mode')}
    assert cache_result['source_kept']==c.read(c.PREFIX+'common.py')
    assert cache_result['ignored']['returncode']==0 and cache_result['source']['returncode']==1
    aborted=c.load('admission/canonical-abort.json.gz')
    assert aborted['actual_joined_exit']==143 and c.decode(aborted['status']['base64']).strip()==b'143'
    assert b'[ci] local CI gate passed' not in c.decode(aborted['log']['base64'])
    for name,count in [('correction-size-preparation',3246),('correction-size-preparation2',3052)]:
        run=c.load('admission/'+name+'.json.gz')['run']
        assert run['returncode']!=0 and ('AssertionError: ('+str(count)+', 3045)').encode() in c.decode(run['stderr_base64'])
    fact()
    return dict(first_inputs=10304,first_staged_images=len(images),first_readonly_exit=0,
        superseded_canonical_exit=143,stale_current_route_observed_red=True,
        current_history_route='composed historical producer',scope='Whole first unpublished drop claim/publication '
        'and actual readonly0 remain byte/mode recoverable through original primary files, exact before packets '
        'or real accepted9fc Git. Exact independently Git-verified stage images are not assigned a draft revision. '
        'Current historical reverify is decoupled from frozen whole-project publishers. Runtime/tests unchanged.')


if __name__=='__main__':print(json.dumps(first_image(),sort_keys=True))
