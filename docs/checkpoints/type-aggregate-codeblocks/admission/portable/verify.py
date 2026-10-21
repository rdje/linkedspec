"""Verify exact portable custody, named helper epochs and current physical inputs."""
import gzip
import json
import re
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import large_inputs


def third():
    saved=c.load('admission/portable/third.json.gz')
    assert saved['base']==c.BASE and len(saved['inputs'])==10540 and len(saved['images'])==10543
    assert saved['producer']==c.read(c.PREFIX+'admission/portable/preserve.py')
    assert json.loads(c.decode(saved['publication']['base64']))['record_base64']==saved['claim']['base64']
    assert json.loads(gzip.decompress(c.decode(saved['manifest']['base64'])))['inputs']==saved['inputs']
    assert c.decode(saved['baseline']['status']['base64']).strip()==b'0'
    assert b'10540 closed inputs;214/106 RED/7 faults;14/1948;book89/3' in c.decode(saved['baseline']['log']['base64'])
    assert saved['blob_limit_red']==dict(rejected=True,message='Staged Git blobs exceed the GitHub100MiB limit')
    assert saved['limit']['bytes']==104857600 and set(saved['oversized'])==large_inputs.LOGICAL_PATHS
    tree={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            tree[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    for path,image in saved['images'].items():
        identity={key:image[key] for key in ('sha256','mode')}
        if path in saved['before']:
            packet=saved['before'][path]
            assert c.sha(c.decode(packet['base64']))==packet['sha256']==image['sha256']
            assert packet['mode']==image['mode']
        elif tree.get(path)!=image['git']:assert c.identity(path)==identity,path
        if path in saved['inputs']:assert saved['inputs'][path]==identity
    verified=saved['git_verification']
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[
        saved['images'][path]['git']['oid'] for path in sorted(saved['images'])]
    sizes=saved['blob_sizes']
    assert sizes['returncode']==0 and not c.decode(sizes['stderr_base64'])
    rows=c.decode(sizes['stdout_base64']).decode().splitlines()
    assert len(rows)==len(saved['images'])
    bad={}
    for path,row in zip(sorted(saved['images']),rows):
        oid,size=row.split();assert oid==saved['images'][path]['git']['oid']
        if int(size)>104857600:bad[path]=int(size)
    assert bad==saved['oversized'] and len(bad)==3
    return saved


def recover(snapshot):
    assert snapshot['base']==c.BASE
    for path,item in snapshot['inputs'].items():
        packet=snapshot.get('new_inputs',{}).get(path) or snapshot.get('overrides',{}).get(path)
        if packet is not None:
            assert c.sha(c.decode(packet['base64']))==packet['sha256']==item['sha256']
            assert packet['mode']==item['mode']
        elif c.identity(path)!=item:
            raw=subprocess.check_output(['git','show',c.BASE+':'+path],cwd=ROOT)
            assert c.sha(raw)==item['sha256'],path


def check(physical_paths,require_documents=True):
    saved=third();value=large_inputs.manifest()
    adoption=c.load('admission/portable/adoption.json.gz')
    assert adoption['producer']==c.read(c.PREFIX+'admission/portable/adopt.py')
    assert adoption['manifest']==value and adoption['absence']['returncode']==1
    assert c.decode(adoption['terminal']['status']['base64']).strip()==b'143'
    preparation=c.load('admission/portable/preparation.json.gz')
    assert preparation['producer']==c.read(c.PREFIX+'admission/portable/split.py')
    assert preparation['parts']==37 and preparation['logical_bytes']==1171950805
    snapshot=c.load('admission/portable/proof-inputs.json.gz')
    proof=c.load('admission/portable/proof-run.json.gz')
    assert proof['producer']==c.read(c.PREFIX+'admission/portable/proof.py')==snapshot['producer']
    assert proof['helper']==snapshot['helper']
    assert proof['inputs_unchanged'] and not proof['backup_residue']
    assert proof['cold_red']==dict(rejected=True,error='FileNotFoundError')
    assert set(proof['reconstructed'])==large_inputs.LOGICAL_PATHS
    expected=[('missing-chunk','Missing proof chunk'),('chunk-byte','Proof chunk bytes mismatch'),
        ('whole-order','Reassembled logical proof mismatch'),
        ('logical-mode','Existing logical proof bytes or mode mismatch'),
        ('logical-byte','Existing logical proof bytes or mode mismatch')]
    assert proof['controls']==[dict(name=name,rejected=True,error=error) for name,error in expected]
    recover(snapshot)
    assert not any(path.endswith(('.gz','.part')) for path in snapshot['overrides'])
    count=0
    for item in value['objects']:
        assert item['size']==saved['oversized'][item['path']]
        assert {key:item[key] for key in ('sha256','mode')}==saved['inputs'][item['path']]
        assert large_inputs.identity(ROOT/item['path'])=={key:item[key] for key in ('sha256','size','mode')}
        for part in item['parts']:
            actual=large_inputs.identity(ROOT/part['path'])
            assert actual['sha256']==part['sha256'] and actual['size']==part['size']<=large_inputs.CHUNK_BYTES
            assert {key:actual[key] for key in ('sha256','mode')}==snapshot['inputs'][part['path']]
            count+=1
    assert count==37
    change=c.load('admission/portable/guard-change.json.gz')
    guard=c.load('admission/portable/guard-run.json.gz')
    assert change['producer']==guard['producer']==c.read(c.PREFIX+'admission/portable/guard.py')
    assert change['before']==proof['helper']
    assert c.decode(change['after'])==(ROOT/(c.PREFIX+'large_inputs.py')).read_bytes()
    assert guard['helper']==c.read(c.PREFIX+'large_inputs.py')
    for name in ('old_probe','new_probe','final_cold'):
        run=guard[name]
        assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    old=json.loads(c.decode(guard['old_probe']['stdout_base64']))
    new=json.loads(c.decode(guard['new_probe']['stdout_base64']))
    cold=json.loads(c.decode(guard['final_cold']['stdout_base64']))
    assert old['helper']==proof['helper'] and all(item['accepted'] for item in old['roots'].values())
    assert new['helper']==cold['helper']==guard['helper']
    assert new['roots']['.']['accepted'] and len(new['roots'])>1
    assert all(not item['accepted'] and item['error']=='Nested repository boundary'
        for name,item in new['roots'].items() if name!='.')
    assert cold['aliases']=={item['path']:{key:item[key] for key in ('sha256','size','mode')} for item in value['objects']}
    assert cold['project_volume'] and cold['temporary_outputs_removed']
    assert not set(physical_paths)&large_inputs.LOGICAL_PATHS
    maximum=max((ROOT/path).stat().st_size for path in physical_paths)
    assert maximum<=104857600
    documents=ROOT/(c.PREFIX+'admission/portable/final-docs.json.gz')
    if require_documents:
        final=c.load('admission/portable/final-docs.json.gz')
        assert final['producer']==c.read(c.PREFIX+'admission/portable/finalize.py')
        for path,text in final['after'].items():assert (ROOT/path).read_bytes()==c.decode(text),path
    pressure_bytes=None
    if require_documents:
        pressure=c.load('admission/portable/pressure-run.json.gz')
        assert pressure['producer']==c.read(c.PREFIX+'admission/portable/pressure.py')
        assert pressure['inputs_unchanged'] and pressure['run']['returncode']==0
        report=c.decode(pressure['run']['stdout_base64'])
        match=re.search(rb'surface knowledge_cards files=(\d+) lines=(\d+) bytes=(\d+)',report)
        assert match and int(match[1])==1350 and int(match[3])<=8388608
        pressure_bytes=int(match[3])
        assert pressure_bytes==sum(path.stat().st_size for path in (ROOT/'docs/knowledge').glob('*.md'))
        assert b'surface public_reference files=61 lines=49836 ' in report
        recover(c.load('admission/portable/pressure-inputs.json.gz'))
    return dict(third_inputs=10540,third_staged_images=10543,third_readonly_exit=0,
        oversized_git_blob_reds=3,canonical2_superseded=143,logical_inputs=3,logical_bytes=1171950805,
        chunks=37,max_chunk_bytes=large_inputs.CHUNK_BYTES,retained_pre_guard_faults=5,
        final_root_guard_red=1,final_cold_aliases=3,backup_residue=False,
        physical_input_max_bytes=maximum,documents_closed=documents.exists(),current_pressure_knowledge_bytes=pressure_bytes)
