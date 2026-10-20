"""Resolve every retained epoch identity from current bytes, full packets or real Git."""
import gzip
import json
import subprocess
from pathlib import Path
import common as c


def records():
    return {path.name:json.loads(gzip.decompress(path.read_bytes()) if path.name.endswith('.gz') else path.read_bytes())
            for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()
            and path.name.endswith(('.json','.json.gz')) and not path.name.startswith('publication')}


def verify():
    pool,identities,git_inputs={},[],[]
    def walk(value):
        if isinstance(value,dict):
            if {'base64','sha256','mode'}<=value.keys():
                raw=c.decode(value['base64'])
                assert c.sha(raw)==value['sha256']
                pool[(value['sha256'],value['mode'])]=raw
            entries=value.get('inputs')
            if isinstance(entries,dict) and entries and all(isinstance(item,dict) and
                    {'sha256','mode'}<=item.keys() for item in entries.values()):
                identities.extend(entries.items())
            git_inputs.extend(value.get('git_inputs',[]))
            for item in value.values():walk(item)
        elif isinstance(value,list):
            for item in value:walk(item)
    for value in records().values():walk(value)
    current,git,seen,missing={},{},set(),[]
    for path,item in identities:
        assert not Path(path).is_absolute() and '..' not in Path(path).parts
        key=(path,item['sha256'],item['mode'])
        if key in seen:continue
        seen.add(key)
        if path not in current:current[path]=c.identity(path) if (c.ROOT/path).is_file() else None
        if current[path]=={name:item[name] for name in ('sha256','mode')}:continue
        if (item['sha256'],item['mode']) in pool:continue
        if path not in git:
            result=c.run(['git','show',c.BASE+':'+path])
            if result['returncode']==0:
                entry=subprocess.check_output(['git','ls-tree',c.BASE,'--',path],cwd=c.ROOT).split()
                git[path]=(c.decode(result['stdout_base64']),0o755 if entry[0]==b'100755' else 0o644)
            else:git[path]=None
        if git[path] is None or (c.sha(git[path][0]),git[path][1])!=(item['sha256'],item['mode']):
            missing.append(dict(path=path,sha256=item['sha256'],mode=item['mode']))
    assert not missing,('Unrecoverable actual epoch bytes',missing)
    for item in git_inputs:
        raw=c.decode(item['base64'])
        assert c.sha(raw)==item['sha256']
        assert raw==subprocess.check_output(['git','show',item['revision']+':'+item['path']],cwd=c.ROOT)
        mode=subprocess.check_output(['git','ls-tree',item['revision'],'--',item['path']],cwd=c.ROOT).split()[0].decode()
        assert mode==item['git_mode']
    return dict(epoch_identities=len(seen),whole_packets=len(pool),immutable_git_inputs=len(git_inputs),
                scope='Every dated input resolves to actual current bytes/full filesystem modes, a retained whole '
                      'draft packet, or an independently verified real accepted Git blob. No draft revision is invented.')


if __name__=='__main__':print(json.dumps(verify(),sort_keys=True))
