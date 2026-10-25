"""Read-only dated cleanup review. Capture/removal entrypoints are retired."""
import copy
import gzip
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile
import zipfile
import common as c


def successful(run):
    assert run['returncode']==0,'failed actual command'


def quiet_absence(run):
    assert run['returncode']==1 and not c.decode(run['stdout_base64']) and not c.decode(run['stderr_base64']),'unproved open-file absence'


def packets(value):
    if isinstance(value,dict):
        if 'base64' in value and 'sha256' in value:
            assert c.sha(c.decode(value['base64']))==value['sha256'],'retained packet identity'
        for child in value.values():packets(child)
    elif isinstance(value,list):
        for child in value:packets(child)


def joined(record):
    blocks=[]
    for row in record['parts']:
        raw=c.source(row['path']).read_bytes()
        assert len(raw)==row['bytes'] and c.sha(raw)==row['sha256'],'retained part bytes'
        assert c.identity(row['path'])['mode']==row['mode'],'retained part mode'
        blocks.append(raw)
    raw=b''.join(blocks)
    assert len(raw)==record['bytes'] and c.sha(raw)==record['sha256'],'whole retained archive'
    return raw


def archive_review(record):
    payload=joined(record['payload']);manifest=joined(record['manifest'])
    with tempfile.TemporaryDirectory(prefix='hygiene23-review-',dir=os.environ['TMPDIR']) as name:
        path=Path(name)/'payload.zip';path.write_bytes(payload)
        counts=dict(entries=0,files=0,directories=0,symlinks=0,logical_bytes=0,allocated_bytes=0)
        with zipfile.ZipFile(path) as archive:
            names=archive.namelist();assert len(set(names))==len(names),'duplicate payload'
            sizes={}
            for name in names:
                digest=hashlib.sha256();size=0
                assert name.startswith('blobs/') and len(name)==70
                with archive.open(name) as stream:
                    while raw:=stream.read(1024*1024):digest.update(raw);size+=len(raw)
                assert name[6:]==digest.hexdigest(),'payload digest'
                sizes[name[6:]]=size
            parents=set();used=set();previous=None;hardlinks={};reader_sources={}
            sample=record['sample']
            for line in gzip.decompress(manifest).splitlines():
                row=json.loads(line);path=Path(row['path'])
                assert not path.is_absolute() and '..' not in path.parts,'unsafe manifest path'
                assert previous is None or previous<path.parts,'manifest order/population'
                previous=path.parts
                assert row['path']=='.' or path.parent.as_posix() in parents,'manifest parent'
                counts['entries']+=1;counts['allocated_bytes']+=row['charged_allocated']
                if row['kind']=='directory':parents.add(row['path']);counts['directories']+=1
                elif row['kind']=='symlink':
                    assert isinstance(row['link_target'],str);counts['symlinks']+=1
                else:
                    assert row['kind']=='file' and sizes[row['sha256']]==row['size'],'manifest payload'
                    used.add(row['sha256']);counts['files']+=1;counts['logical_bytes']+=row['size']
                    if 'hardlink_to' in row:
                        assert hardlinks[row['hardlink_to']]==(row['sha256'],row['size']) and row['charged_allocated']==0
                    elif row['links']>1:hardlinks[row['path']]=(row['sha256'],row['size'])
                    for family in ('change_history','engineering_notes'):
                        if row['path']==sample+'/'+family+'-fresh/tools/read_document_history.pl':
                            reader_sources[family]=archive.read('blobs/'+row['sha256'])
            assert used==set(sizes) and counts==record['counts'],'complete archive population/totals'
            expected=c.decode(c.load('history-before-inputs.json.gz')['sources']['tools/read_document_history.pl']['base64'])
            assert set(reader_sources)=={'change_history','engineering_notes'}
            assert all(raw==expected for raw in reader_sources.values()),'actual archived public reader identity'
    return counts


def review(control=None):
    if control is None:
        claim=json.loads(c.source('docs/claims/REPO-HYGIENE.23.json').read_bytes())
        rows=claim['claims'][0]['durability']['inputs']
        actual={path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()}
        assert actual=={row['path'] for row in rows},'closed input population'
        for row in rows:assert c.identity(row['path'])['sha256']==row['sha256'],'publication input identity'
    records={path.name:c.load(path.name) for path in (c.ROOT/c.PREFIX).iterdir() if path.name.endswith(('.json','.json.gz'))}
    for value in records.values():packets(value)
    archive=copy.deepcopy(records['history-archive.json.gz'])
    rust=copy.deepcopy(records['rust-fresh-use.json.gz'])
    opened=copy.deepcopy(records['history-final-recheck.json.gz'])
    if control=='part-bytes':archive['payload']['parts'][0]['sha256']='0'*64
    elif control=='part-mode':archive['manifest']['parts'][0]['mode']^=0o100
    elif control=='missing-part':archive['manifest']['parts'].pop()
    elif control=='wrong-total':archive['counts']['files']-=1
    elif control=='wrong-value':rust['runs'][0]['expected'][0]=-999
    elif control=='denied-inspection':opened['returncode']=2;opened['stderr_base64']=c.encode(b'Operation not permitted\n')
    elif control not in (None,'healthy'):raise AssertionError('unknown control')
    quiet_absence(opened)
    for name in ('history-quiescence.json.gz','rust-quiescence.json.gz'):
        quiet_absence(records[name]['open_files'])
        successful(records[name]['tracked']);assert not c.decode(records[name]['tracked']['stdout_base64'])
        successful(records[name]['ignored'])
    quiet_absence(records['rust-quarantine-recheck.json.gz'])
    counts=archive_review(archive)
    use=records['history-archive-use.json.gz'];original=records['history-original-readers.json.gz']
    assert use['public_outputs_byte_identical'] and use['verified']['counts']==counts
    for family,run in use['restored_readers'].items():
        successful(run);successful(original['runs'][family])
        assert not c.decode(run['stderr_base64']) and run['stdout_base64']==original['runs'][family]['stdout_base64'],'actual public restoration'
    binary=records['rust-primary-binary.json'];raw=gzip.decompress(b''.join(c.source(row['path']).read_bytes() for row in binary['parts']))
    assert len(raw)==binary['bytes'] and c.sha(raw)==binary['sha256'],'whole actual Rust executable'
    for row in binary['parts']:assert c.identity(row['path'])=={key:row[key] for key in ('mode','sha256')}
    successful(records['rust-fresh-build.json.gz']);successful(records['rust-native-clean.json.gz'])
    import rust_cleanup
    assert rust['inputs_and_binary_unchanged'] and len(rust['runs'])==4
    for row in rust['runs']:
        successful(row['run']);assert not c.decode(row['run']['stderr_base64'])
        assert rust_cleanup.same(json.loads(c.decode(row['run']['stdout_base64'])),row['expected']),'typed Rust value'
    reduction=records['rust-cleanup-result.json.gz']
    assert reduction['allocated_bytes_reclaimed']==reduction['before']['bytes']-reduction['after']['bytes']>0
    for period in ('before','after'):
        run=reduction[period]['run'];successful(run)
        assert int(c.decode(run['stdout_base64']).split()[0])*1024==reduction[period]['bytes']
    source_native=records['history-quiescence.json.gz']['before'];successful(source_native)
    assert int(c.decode(source_native['stdout_base64']).split()[0])*1024==counts['allocated_bytes']
    assert records['history-cleanup-result.json.gz']['source_absent'] and reduction['quarantine_absent']
    preflight=records['preflight.json.gz'];supplement=records['shared-home-preflight.json.gz']
    planned=set(preflight['planned']+supplement['planned'])
    assert not preflight['live_intersections'] and not supplement['live_intersections']
    for packet in preflight['claims'].values():
        for item in json.loads(c.decode(packet['base64']))['claims']:
            leg=item['durability']
            if leg.get('status')=='checked' and leg.get('mode')=='live':
                assert not planned&{row['path'] for row in leg['inputs']},'shared live claim intersection'
    return dict(rust_allocated_reduction=reduction['allocated_bytes_reclaimed'],
        history_source_allocated=counts['allocated_bytes'],history_entries=counts['entries'],
        retained_archive_bytes=archive['payload']['bytes']+archive['manifest']['bytes'],
        public_restored_readers=2,rust_public_examples=4,
        limits='Dated per-target allocation and byte custody, not global physical free-space causality or a cold dependency bootstrap. Global census excludes Git/protected repositories and includes managed observer metadata. Original removal is not replayed.')


if __name__=='__main__':
    assert len(sys.argv) in (1,3) and (len(sys.argv)==1 or sys.argv[1]=='--control')
    print(json.dumps(review(sys.argv[2] if len(sys.argv)==3 else None),sort_keys=True))
