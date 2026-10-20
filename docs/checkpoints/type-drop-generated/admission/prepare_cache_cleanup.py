"""Preserve the own generated cache before removing it from the final candidate."""
import importlib.util
import marshal
import struct
import sys
from datetime import datetime,timezone
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c

CACHE=c.PREFIX+'__pycache__/common.cpython-314.pyc'
TOOL='docs/knowledge/tool-project-data-ssd-storage.md'
TASK='docs/tasks/TYPE-REFERENCE-BOOK.md'


def main():
    first=c.load('admission/first.json.gz')
    cache=c.read(CACHE)
    assert {key:cache[key] for key in ('sha256','mode')}=={key:first['images'][CACHE][key] for key in ('sha256','mode')}
    raw=c.decode(cache['base64'])
    assert raw[:4]==importlib.util.MAGIC_NUMBER and struct.unpack('<I',raw[4:8])[0]==0
    code=marshal.loads(raw[16:])
    assert Path(code.co_filename).resolve()==(c.ROOT/(c.PREFIX+'common.py')).resolve()
    managed_cache=Path(c.__cached__).resolve().relative_to(c.ROOT).as_posix()
    assert managed_cache.startswith('.linkedspec-data/cache/python-pycache/') and managed_cache!=CACHE
    paths=['.gitignore','docs/ARTIFACT_CLEANUP.md','MEMORY.md',TASK,TOOL]
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    pattern='docs/checkpoints/**/__pycache__/'
    assert pattern not in after['.gitignore']
    initial=c.run(['git','check-ignore','--no-index','-v','--',CACHE])
    after['.gitignore']+='\n# Generated checkpoint Python caches\n'+pattern+'\n'
    stamp=datetime.now(timezone.utc).isoformat()
    after['docs/ARTIFACT_CLEANUP.md']='# Latest artifact cleanup\n\n- Date: '+stamp+'\n- Summary: TYPE-REFERENCE-BOOK.1.2.6 removed only its verified checkpoint common.cpython-314.pyc after whole-byte/mode and original-stage preservation; source and all historical proof bytes remain. Checkpoint caches are ignored; no other cache or repository data was removed.\n'
    lines=after['MEMORY.md'].splitlines()
    indices=[index for index,line in enumerate(lines) if line.startswith('- cleanup:')]
    assert len(indices)==1
    lines[indices[0]]='- cleanup: Latest'+stamp+'; removed only the preserved checkpoint common.pyc. docs/ARTIFACT_CLEANUP.md owns the latest record; source and all original-stage bytes remain.'
    after['MEMORY.md']='\n'.join(lines)+'\n'
    anchor='  Commit subject: `TYPE-REFERENCE-BOOK.1.2.6 - materialize generated drop keys`;'
    assert after[TASK].count(anchor)==1
    after[TASK]=after[TASK].replace(anchor,'  P3 cache cleanup: first-stage common.pyc is retained/removed; checkpoint ignore/source control and residue proof live in admission/.\n'+anchor,1)
    assert len(after[TASK].encode())<=65536
    anchor='  - where does LinkedSpec store Python bytecode\n'
    assert after[TOOL].count(anchor)==1
    after[TOOL]=after[TOOL].replace(anchor,anchor+'  - why is Python bytecode excluded from checkpoint staging\n',1)
    after[TOOL]=after[TOOL].replace('\ndate: 2026-10-02\n','\ndate: 2026-10-20\n',1)
    after[TOOL]+='\nCheckpoint `__pycache__` is ignored; drop6 retains its removed cache bytes under\n`docs/checkpoints/type-drop-generated/admission/`.\n'
    c.write_new('admission/cache-cleanup-inputs.json.gz',dict(cache=cache,before=before,
        after={path:c.encode(text.encode()) for path,text in after.items()},initial_ignore=initial,
        compiled_source_relative=c.PREFIX+'common.py',managed_cache_relative=managed_cache,
        producer=c.read(c.PREFIX+'admission/prepare_cache_cleanup.py'),
        scope='The source-image census identifies one generated CPython cache beyond10304 actual inputs '
              'and three own publication outputs. Validate its magic/source identity and full original '
              'stage hash/mode, preserve all bytes before exact unstage/delete, and prove the maintained '
              'wrapper uses managed cache instead. Ignore only checkpoint __pycache__ directories. '
              'Current cleanup/task/memory/fact records follow; no shared or external data is deleted.'))
    for path,text in after.items():(c.ROOT/path).write_text(text)
    print('Generated cache fully preserved; bounded checkpoint ignore/cleanup records prepared')


if __name__=='__main__':main()
