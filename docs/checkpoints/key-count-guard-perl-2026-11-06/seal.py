"""One-shot lossless seal of completed CountKeys guard/source proof channels."""
import gzip
import hashlib
import json
from pathlib import Path
BASE=Path(__file__).parent.relative_to(Path.cwd())
records={}
for phase,count in [('intake',26),('function-controls',4),('before',27),('before-qualified',27),('after',27),('nearest',27)]:
    folder=BASE/phase
    assert (folder/('exit.txt' if phase in ('intake','function-controls') else 'normal-exit.txt')).is_file()
    modules={}
    for path in sorted((folder/'modules').glob('*.gz')):
        capsule=path.read_bytes();body=gzip.decompress(capsule)
        modules[str(path)]=dict(sha256=hashlib.sha256(capsule).hexdigest(),mode=path.stat().st_mode & 0o777,raw_sha256=hashlib.sha256(body).hexdigest(),raw_bytes=len(body))
    assert len(modules)==count
    target=folder/'module-identities.json';assert not target.exists()
    target.write_text(json.dumps(modules,indent=2,sort_keys=True)+'\n')
    tags=[''] if phase in ('intake','function-controls') else (['normal-','owner-syntax-'] if phase=='after' else ['normal-'])
    for tag in tags:
        for channel in ('stdout','stderr'):
            path=folder/(tag+channel+'.log');body=path.read_bytes();capsule=gzip.compress(body,mtime=0)
            target=Path(str(path)+'.gz');assert not target.exists();target.write_bytes(capsule)
            assert gzip.decompress(target.read_bytes())==body==path.read_bytes()
            records[str(path)]=dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),capsule=str(target),capsule_sha256=hashlib.sha256(capsule).hexdigest())
            path.unlink()
assert len(records)==14
(BASE/'raw-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
print('Completed original/corrected/source/guard channels sealed losslessly; actual pre-run modules/carriers retained')
