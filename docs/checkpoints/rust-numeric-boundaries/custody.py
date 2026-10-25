"""Read-only packet identities and streamed actual executable reconstruction."""
import hashlib
import zlib
import common as c


def packets(value):
    count=0
    if isinstance(value,dict):
        if {'base64','sha256'} <= value.keys():
            assert c.sha(c.decode(value['base64']))==value['sha256'],'retained packet digest'
            count+=1
        for item in value.values():count+=packets(item)
    elif isinstance(value,list):
        for item in value:count+=packets(item)
    return count


def binary(artifact):
    stream=zlib.decompressobj(31);digest=hashlib.sha256();size=0
    for part in artifact['parts']:
        assert part['path'].startswith(c.PREFIX)
        raw=c.source(part['path']).read_bytes()
        assert len(raw)==part['bytes'] and c.sha(raw)==part['sha256']
        assert c.identity(part['path'])=={key:part[key] for key in ('sha256','mode')}
        decoded=stream.decompress(raw)
        digest.update(decoded);size+=len(decoded)
    tail=stream.flush();digest.update(tail);size+=len(tail)
    assert stream.eof and not stream.unused_data
    assert digest.hexdigest()==artifact['sha256'] and size==artifact['bytes'],'actual executable reconstruction'
    return size


def artifacts(value,seen=None):
    seen=set() if seen is None else seen
    total=0
    if isinstance(value,dict):
        if {'parts','sha256','bytes','mode'} <= value.keys():
            key=tuple(part['path'] for part in value['parts'])
            if key not in seen:
                seen.add(key);binary(value);total+=1
        for item in value.values():total+=artifacts(item,seen)
    elif isinstance(value,list):
        for item in value:total+=artifacts(item,seen)
    return total


def check(manifest):
    root=c.ROOT/c.PREFIX
    actual={file.name for file in root.iterdir() if file.is_file() and file.name!='publication.json'}
    assert actual==set(manifest['inputs']),'exact publication namespace'
    packet_count=0;binary_count=0;seen=set()
    for name,expected in manifest['inputs'].items():
        assert '/' not in name and name not in ('.','..')
        assert c.identity(c.PREFIX+name)==expected,'publication input identity: '+name
        if name.endswith(('.json','.json.gz')):
            saved=c.load(name);packet_count+=packets(saved);binary_count+=artifacts(saved,seen)
    return dict(files=len(actual),packets=packet_count,executables=binary_count)
