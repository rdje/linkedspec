"""Readonly attestation of the actual historical replay; rejected shadows remain separate."""
import hashlib
import json
import subprocess
import common as c


def check():
    saved=c.load('library-actual-inputs.json.gz')
    observed=c.load('library-actual-observed.json.gz')
    result=c.load('library-actual-run.json.gz')
    assert result['run']==observed['run'] and result['installed_unchanged']
    assert c.load('library-actual-restoration.json.gz')==dict(restored=True)
    assert result['run']['returncode']==0 and not c.decode(result['run']['stderr_base64'])
    tree={}
    for row in subprocess.check_output(['git','ls-tree','-rz',saved['revision'],'--','perl','specs','conf','tablescript'],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            if mode in ('100644','100755') and kind=='blob':tree[name.decode()]=(mode,oid)
    assert set(tree)==set(saved['entries'])
    for path,packet in saved['entries'].items():
        raw=c.decode(packet['base64'])
        assert c.sha(raw)==packet['sha256']
        assert tree[path]==(packet['mode'],packet['oid'])
        assert hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==packet['oid']
    value=json.loads(c.decode(result['run']['stdout_base64']))
    names={name for name in value['inc'] if name.startswith('LinkedSpec')}
    assert names==set(result['loaded'])
    for name,packet in result['loaded'].items():
        assert packet['sha256']==saved['entries'][packet['path']]['sha256']
        assert packet['mode']==int(saved['entries'][packet['path']]['mode'],8)&0o777
    expected=['[3]','[1]','[8]','[8]','[4]','[3]','[8]','[10]']
    assert [row['native']['value_json'] for row in value['rows']]==expected
    assert [row['generated']['value_json'] for row in value['rows']]==expected
    assert all(row[route]['error'] is None and row[route]['last_error'] is None
        and not row[route]['warnings'] and not row[route]['stdout']
        for row in value['rows'] for route in ('native','generated'))
    return dict(installed_inputs=len(tree),loaded_owned_modules=len(names),exact_sources=len(expected),
        scope='Real old Git bytes with current system/dependency prerequisites; loaded identities verified. '
              'The initial source shadow was rejected. Original95 instrument/environment remains unretained.')


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
