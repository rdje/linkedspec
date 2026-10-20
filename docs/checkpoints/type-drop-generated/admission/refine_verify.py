"""Retain the successful initial image review and bind the explicit cleanup successor."""
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c

path=c.PREFIX+'admission/verify.py'
before=c.read(path)
text=c.decode(before['base64']).decode()
old="    assert set(images)==set(saved['images'])\n"
new=old+'''    for path,packet in {**original,**saved['before']}.items():
        assert c.sha(c.decode(packet['base64']))==packet['sha256']
        assert {key:packet[key] for key in ('sha256','mode')}=={
            key:saved['images'][path][key] for key in ('sha256','mode')}, 'retained packet/staged image mismatch'
'''
assert text.count(old)==1
text=text.replace(old,new,1)
old="    for path,raw in correction['after'].items():assert (c.ROOT/path).read_bytes()==c.decode(raw)\n"
new='''    expected=dict(correction['after'])
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
'''
assert text.count(old)==1
text=text.replace(old,new,1)
baseline={name:c.read('.linkedspec-data/verification/type-drop-admission-review.'+name) for name in ('log','status')}
assert c.decode(baseline['status']['base64']).strip()==b'0' and b'"first_staged_images": 10308' in c.decode(baseline['log']['base64'])
compile(text,path,'exec')
c.write_new('admission/image-review-refinement.json.gz',dict(before=before,after_base64=c.encode(text.encode()),baseline=baseline,
 producer=c.read(c.PREFIX+'admission/refine_verify.py'),
 scope='Initial exact-image review actually passed before cache cleanup. Bind whole retained packets to '
       'their exact original stage identities and accept only the explicit hash-bound cleanup successor '
       'for Memory/task metadata. Runtime, tests and original publication images remain unchanged.'))
(c.ROOT/path).write_text(text)
