"""Lossless content-deduplicated rollover scratch archive and safe disposal."""
import datetime
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import tempfile
import zipfile
import common as c

SOURCE='.linkedspec-data/scratch/history-rollover-eof'
WORK='.linkedspec-data/verification/hygiene23'
REVISION='b2156813fffed53622e640583a46a4ca94186a08'
FIELDS=('path','kind','mode','size','device','inode','links','mtime_ns','native_allocated','link_target')


def file_hash(path):
    value=hashlib.sha256()
    with path.open('rb') as stream:
        while raw:=stream.read(1024*1024):value.update(raw)
    return value.hexdigest()


def entries(root):
    pending=[root];device=c.ROOT.stat().st_dev
    while pending:
        path=pending.pop();info=path.lstat()
        assert info.st_dev==device,'foreign device in source tree'
        directory=stat.S_ISDIR(info.st_mode);regular=stat.S_ISREG(info.st_mode)
        symbolic=stat.S_ISLNK(info.st_mode)
        assert directory or regular or symbolic,'special source entry'
        if directory:assert not os.path.lexists(path/'.git'),'nested repository in source tree'
        row=dict(path=path.relative_to(root).as_posix(),kind='directory' if directory else 'file' if regular else 'symlink',
            mode=info.st_mode & 0o7777,size=info.st_size,device=info.st_dev,inode=info.st_ino,
            links=info.st_nlink,mtime_ns=info.st_mtime_ns,native_allocated=info.st_blocks*512)
        if symbolic:row['link_target']=os.readlink(path)
        yield row,path
        if directory:
            with os.scandir(path) as stream:
                pending.extend(Path(item.path) for item in sorted(stream,key=lambda item:item.name,reverse=True))


def safe_root():
    root=c.ROOT/SOURCE
    for parent in [root,*root.parents]:
        if not parent.is_relative_to(c.ROOT):continue
        assert not parent.is_symlink(),'symbolic source ancestor'
        if parent!=c.ROOT:assert not os.path.lexists(parent/'.git'),'nested source repository'
    assert root.is_dir() and root.stat().st_dev==c.ROOT.stat().st_dev
    return root


def split(path,stem):
    parts=[]
    with path.open('rb') as stream:
        while raw:=stream.read(32*1024*1024-1024):
            name=stem+'-'+str(len(parts)+1).zfill(3)+'.part'
            with (c.ROOT/c.PREFIX/name).open('xb') as output:output.write(raw)
            parts.append(dict(path=c.PREFIX+name,bytes=len(raw),**c.identity(c.PREFIX+name)))
    return dict(bytes=path.stat().st_size,sha256=file_hash(path),parts=parts)


def assemble(record,destination):
    digest=hashlib.sha256();size=0
    with destination.open('xb') as output:
        for part in record['parts']:
            raw=c.source(part['path']).read_bytes()
            assert len(raw)==part['bytes'] and c.sha(raw)==part['sha256'],'archive part identity'
            assert c.identity(part['path'])['mode']==part['mode'],'archive part mode'
            digest.update(raw);size+=len(raw);output.write(raw)
    assert size==record['bytes'] and digest.hexdigest()==record['sha256'],'whole archive identity'


def verify(record,folder):
    payload=folder/'payload.zip';manifest=folder/'entries.jsonl.gz'
    assemble(record['payload'],payload);assemble(record['manifest'],manifest)
    counts=dict(entries=0,files=0,directories=0,symlinks=0,logical_bytes=0,allocated_bytes=0)
    directories=set();used=set();previous=None;links={}
    with zipfile.ZipFile(payload) as archive:
        names=archive.namelist();assert len(names)==len(set(names))
        sizes={}
        for name in names:
            assert name.startswith('blobs/') and len(name)==70
            digest=hashlib.sha256();size=0
            with archive.open(name) as stream:
                while raw:=stream.read(1024*1024):digest.update(raw);size+=len(raw)
            assert digest.hexdigest()==name[6:],'retained unique payload digest'
            sizes[name[6:]]=size
        with gzip.open(manifest,'rt',encoding='utf-8') as stream:
            for line in stream:
                row=json.loads(line);path=Path(row['path']);parts=path.parts
                assert not path.is_absolute() and '..' not in parts,'archive path containment'
                assert previous is None or previous<parts,'unique preorder source entry'
                previous=parts
                assert row['path']=='.' or path.parent.as_posix() in directories,'source parent'
                assert row['kind'] in ('file','directory','symlink')
                counts['entries']+=1;counts['allocated_bytes']+=row['charged_allocated']
                if row['kind']=='directory':
                    directories.add(row['path']);counts['directories']+=1
                elif row['kind']=='symlink':
                    assert isinstance(row['link_target'],str);counts['symlinks']+=1
                else:
                    digest=row['sha256'];assert sizes[digest]==row['size'],'source payload size'
                    used.add(digest);counts['files']+=1;counts['logical_bytes']+=row['size']
                    if 'hardlink_to' in row:
                        assert links[row['hardlink_to']]==(digest,row['size'])
                        assert row['charged_allocated']==0
                    elif row['links']>1:links[row['path']]=(digest,row['size'])
    assert used==set(sizes),'closed payload population'
    assert counts==record['counts'],'independent archive totals'
    return dict(counts=counts,unique_payloads=len(sizes),unique_payload_bytes=sum(sizes.values())),payload,manifest


def restore_sample(prefix,manifest,payload,destination):
    destination.mkdir(exist_ok=False)
    directory_modes=[]
    with zipfile.ZipFile(payload) as archive,gzip.open(manifest,'rt',encoding='utf-8') as stream:
        for line in stream:
            row=json.loads(line);relative=Path(row['path'])
            if not relative.parts or relative.parts[0]!=prefix:continue
            path=destination/relative
            assert path.is_relative_to(destination)
            if row['kind']=='directory':
                path.mkdir(parents=True,exist_ok=True);directory_modes.append((path,row))
            elif row['kind']=='symlink':path.symlink_to(row['link_target'])
            elif 'hardlink_to' in row and (destination/row['hardlink_to']).is_file():
                path.hardlink_to(destination/row['hardlink_to'])
            else:
                with archive.open('blobs/'+row['sha256']) as source,path.open('xb') as output:
                    shutil.copyfileobj(source,output,1024*1024)
                assert file_hash(path)==row['sha256']
            if row['kind']!='symlink':
                path.chmod(row['mode']);os.utime(path,ns=(row['mtime_ns'],row['mtime_ns']))
    for path,row in reversed(directory_modes):
        path.chmod(row['mode']);os.utime(path,ns=(row['mtime_ns'],row['mtime_ns']))
    return destination/prefix


def reader(tree,family):
    env=os.environ.copy();env.update(GIT_DIR=str(c.ROOT/'.git'),GIT_WORK_TREE=str(tree),
        PATH=str(tree.parent/'bin')+os.pathsep+env['PATH'],LINKEDSPEC_HISTORY_FIXTURE_SOURCE=REVISION,
        LINKEDSPEC_HISTORY_FIXTURE_GIT=shutil.which('git'))
    return c.run(['perl','tools/read_document_history.pl','--surface',family,'--all'],cwd=tree,env=env)


def main():
    root=safe_root();work=c.ROOT/WORK;work.mkdir(exist_ok=True)
    paths=['tools/test_document_history_rollover.py','tools/read_document_history.pl',
        'tools/project_data_env.sh','tools/project_data_run.sh']
    supplied=c.snapshot(paths)
    c.save('history-before-inputs.json.gz',supplied)
    tracked=c.run(['git','ls-files','--',SOURCE]);ignored=c.run(['git','check-ignore','-v','--',SOURCE])
    assert tracked['returncode']==ignored['returncode']==0 and not c.decode(tracked['stdout_base64'])
    before=c.run(['du','-skx',SOURCE]);assert before['returncode']==0 and not c.decode(before['stderr_base64'])
    opened=c.run(['lsof','-nP','+D',SOURCE,'-Fpcftn'])
    c.save('history-quiescence.json.gz',dict(tracked=tracked,ignored=ignored,before=before,open_files=opened))
    assert opened['returncode']==1 and not c.decode(opened['stdout_base64']) and not c.decode(opened['stderr_base64']), 'source open or inspection unavailable'
    sample=max((path for path in root.iterdir() if path.name.startswith('repaired-') and
        (path/'change_history-fresh/tools/read_document_history.pl').is_file() and
        (path/'engineering_notes-fresh/tools/read_document_history.pl').is_file()),key=lambda path:path.stat().st_mtime_ns)
    original_readers={family:reader(sample/(family+'-fresh'),family)
        for family in ('change_history','engineering_notes')}
    assert all(run['returncode']==0 and not c.decode(run['stderr_base64']) for run in original_readers.values())
    c.save('history-original-readers.json.gz',dict(sample=sample.name,runs=original_readers,
        scope='Actual read-only public --all consumers on two original source views before archive/delete. '
            'Git metadata is this repository only; shim permits original published source reads.'))
    payload=work/'history-payload.zip';manifest=work/'history-entries.jsonl.gz'
    assert not payload.exists() and not manifest.exists()
    hashes=set();hardlinks={};counts=dict(entries=0,files=0,directories=0,symlinks=0,logical_bytes=0,allocated_bytes=0)
    lease=work/'history-lease.json';assert not lease.exists()
    state=dict(owner=c.OWNER,source=SOURCE,pid=os.getpid(),process_group=os.getpgrp(),state='archiving',closed=False)
    lease.write_text(json.dumps(state)+'\n')
    with zipfile.ZipFile(payload,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=9,allowZip64=True) as archive,gzip.open(manifest,'xt',encoding='utf-8') as output:
        for row,path in entries(root):
            row['charged_allocated']=row['native_allocated'];counts['entries']+=1
            if row['kind']=='file':
                key=(row['device'],row['inode']);counts['files']+=1;counts['logical_bytes']+=row['size']
                if key in hardlinks:
                    row['hardlink_to'],row['sha256']=hardlinks[key];row['charged_allocated']=0
                else:
                    row['sha256']=file_hash(path)
                    if row['links']>1:hardlinks[key]=(row['path'],row['sha256'])
                    if row['sha256'] not in hashes:
                        with path.open('rb') as source,archive.open('blobs/'+row['sha256'],'w',force_zip64=True) as target:
                            shutil.copyfileobj(source,target,1024*1024)
                        hashes.add(row['sha256'])
            elif row['kind']=='directory':counts['directories']+=1
            else:counts['symlinks']+=1
            counts['allocated_bytes']+=row['charged_allocated']
            output.write(json.dumps(row,sort_keys=True,separators=(',',':'))+'\n')
            if counts['entries']%100000==0:print('Archived source entries:',counts['entries'],flush=True)
    assert counts['allocated_bytes']==int(c.decode(before['stdout_base64']).split()[0])*1024,'native allocated source total'
    record=dict(source=SOURCE,at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),counts=counts,
        payload=split(payload,'history-payload'),manifest=split(manifest,'history-entries'),
        sample=sample.name,source_scope='Whole ordinary-file rollover scratch, including all unique records and '
            'generated views, without nested Git repositories or other devices. Content-addressed payloads '
            'retain every original byte once; per-path metadata keeps modes, timestamps, symlinks and hardlink relations. '
            'No dependency implementation or other repository payload is archived.')
    c.save('history-archive.json.gz',record)
    with tempfile.TemporaryDirectory(prefix='hygiene23-verify-',dir=os.environ['TMPDIR']) as temporary:
        checked,actual_payload,actual_manifest=verify(record,Path(temporary))
        restored=restore_sample(sample.name,actual_manifest,actual_payload,Path(temporary)/'restored')
        restored_readers={family:reader(restored/(family+'-fresh'),family)
            for family in ('change_history','engineering_notes')}
        for family,run in restored_readers.items():
            assert run['returncode']==0 and not c.decode(run['stderr_base64'])
            assert run['stdout_base64']==original_readers[family]['stdout_base64'],'actual restored public reader bytes'
        c.save('history-archive-use.json.gz',dict(verified=checked,restored_readers=restored_readers,
            public_outputs_byte_identical=True,
            scope='The actual retained parts are reconstructed and every unique payload/manifest entry is '
                'decoded/verified. One whole ordinary source run is restored, and both public archive-only '
                'readers return the exact original stdout. A partial sample copies any outside-sample '
                'hardlink payload independently; the full manifest preserves its original relationship.'))
    # Check every current source metadata entry against its copied record before authorizing deletion.
    current=entries(root)
    with gzip.open(manifest,'rt',encoding='utf-8') as stream:
        for line in stream:
            saved=json.loads(line);actual,path=next(current)
            assert all(saved.get(key)==actual.get(key) for key in FIELDS),'source changed during archive'
    assert next(current,None) is None,'source population changed during archive'
    assert c.unchanged(supplied['inputs'])
    recheck=c.run(['lsof','-nP','+D',SOURCE,'-Fpcftn'])
    c.save('history-final-recheck.json.gz',recheck)
    assert recheck['returncode']==1 and not c.decode(recheck['stdout_base64']) and not c.decode(recheck['stderr_base64'])
    safe_root();assert shutil.rmtree.avoids_symlink_attacks,'descriptor-based safe removal required'
    c.save('history-delete-plan.json.gz',dict(source=SOURCE,archive=c.read(c.PREFIX+'history-archive.json.gz'),
        source_metadata_and_population_unchanged=True,inputs_unchanged=True,
        policy='Only the exact verified source tree is removed after lossless copy, complete decoding, '
            'actual restored public use and permitted quiescence recheck. Symlink targets are never followed.'))
    state.update(state='verified_before_delete');lease.write_text(json.dumps(state)+'\n')
    shutil.rmtree(root);assert not root.exists()
    state.update(state='source_removed_archive_verified',closed=True);lease.write_text(json.dumps(state)+'\n')
    archive_bytes=sum(row['bytes'] for value in (record['payload'],record['manifest']) for row in value['parts'])
    c.save('history-cleanup-result.json.gz',dict(source_allocated_bytes=counts['allocated_bytes'],
        source_files=counts['files'],source_entries=counts['entries'],retained_archive_bytes=archive_bytes,
        net_allocated_minus_archive_bytes=counts['allocated_bytes']-archive_bytes,source_absent=True,
        scope='Dated source-tree allocated removal minus retained physical archive file lengths; '
            'archive filesystem allocation and global free space are measured separately. '
            'No claim that APFS clones or other host activity give the same volume-free delta.'))
    print('Rollover scratch removed after lossless archive/use:',counts['allocated_bytes'],'bytes; retained archive:',archive_bytes,flush=True)


if __name__=='__main__':main()
