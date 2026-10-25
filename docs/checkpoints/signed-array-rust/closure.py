"""Retain accepted-Git first-party include inputs beyond the Rust source tree."""
import json
import re
import subprocess
from pathlib import Path
import common as c
import epoch


def census():
    refs=[];sources={}
    for path in epoch.rust_paths():
        if not path.endswith('.rs'):continue
        packet=c.read(path);raw=c.decode(packet['base64'])
        if not re.search(rb'include_(?:str|bytes)!',raw):continue
        sources[path]=packet
        direct=list(re.finditer(rb'include_(?:str|bytes)!\(\s*"([^"]+)"\s*\)',raw))
        concatenated=list(re.finditer(rb'include_(?:str|bytes)!\(\s*concat!\(\s*env!\("CARGO_MANIFEST_DIR"\),\s*"([^"]+)"\s*,?\s*\)\s*\)',raw))
        seen={m.start() for m in direct+concatenated}
        found={m.start() for m in re.finditer(rb'include_(?:str|bytes)!',raw)}
        assert seen==found,('unclassified macro input',path,found-seen)
        for match in direct+concatenated:
            if match in direct:
                destination=(c.ROOT/path).parent/match[1].decode()
            else:
                package=next(parent for parent in (c.ROOT/path).parents if (parent/'Cargo.toml').is_file())
                destination=Path(str(package)+match[1].decode())
            target=destination.resolve().relative_to(c.ROOT).as_posix()
            assert not target.startswith(('rgx/','.git/')),'black-box boundary'
            refs.append(dict(source=path,byte_offset=match.start(),path=target))
    return refs,sources


def main():
    refs,sources=census();paths=sorted({row['path'] for row in refs if not row['path'].startswith('rust/')})
    inputs={};baseline={}
    for path in paths:
        packet=c.read(path)
        if path=='tests/signed-array-rust/cases.json':continue # retained separately at every actual epoch
        raw=subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)
        metadata=subprocess.check_output(['git','ls-tree',c.BASE,'--',path],cwd=c.ROOT,text=True).split()
        assert raw==c.decode(packet['base64']),(path,'not immutable at activation')
        assert metadata[1]=='blob' and bool(packet['mode']&0o111)==(metadata[0]=='100755')
        inputs[path]=packet;baseline[path]=dict(git_mode=metadata[0],git_oid=metadata[2])
    c.write_new('first-party-include-closure.json.gz',dict(producer=c.read(c.PREFIX+'closure.py'),
        source_census=sources,references=refs,accepted_inputs=inputs,accepted_git=baseline,base=c.BASE,
        scope='Late custody completion, not an earlier full-mode observation. Earlier bounded epochs already retain every tracked Rust source, mutable fixture and actual executed binary. Unchanged first-party macro inputs outside rust/ are supplied by the declared immutable activation Git tree; this packet independently verifies and makes their complete bytes recoverable here. Current full modes are observed now, while accepted Git supplies historical byte/executable identity. No dependency implementation or whole-SDK replay. Final runtime/compatibility epochs must explicitly include these paths before measurement.'))
    print('First-party macro input closure:',len(refs),'references;',len(inputs),'unchanged accepted-Git inputs retained.')


if __name__=='__main__':main()
