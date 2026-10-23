"""Read-only recovery and distinguishing AST oracle for EOF containment."""
import ast
import gzip
import json
import sys
import common as c


def packet(value):
    raw=c.decode(value['base64'])
    assert c.sha(raw)==value['sha256']
    return raw


def check(fault=False):
    boundary=c.load('publication1-whitespace-boundary.json.gz')
    contained=c.load('whitespace-containment.json.gz')
    assert boundary['actual_readonly']['returncode']==0
    assert not c.decode(boundary['actual_readonly']['stderr_base64'])
    assert boundary['actual_whitespace_rejection']['returncode']==2
    old=boundary['outputs']
    declared=json.loads(gzip.decompress(packet(old['manifest'])))['inputs']
    assert declared==boundary['inputs'] and len(declared)==60
    assert json.loads(packet(old['publication']))['record_base64']==old['claim']['base64']
    assert contained['producer']==contained['producer_original']==boundary['producer']
    assert contained['producer']==c.read(c.PREFIX+'contain_whitespace.py')
    for name,path in contained['old_outputs'].items():
        assert c.read(path)==old[name], 'whole unpublished output'
    changed={c.PREFIX+'source_review.py',c.PREFIX+'README.md'}
    assert set(contained['changed_inputs'])==changed
    assert set(contained['unchanged_inputs'])==set(declared)-changed
    for path in contained['unchanged_inputs']:
        assert c.identity(path)==declared[path], 'unchanged original input'
    for path,image in ((c.PREFIX+'source_review.py',boundary['source_before']),
        (c.PREFIX+'README.md',boundary['readme_before'])):
        assert {key:image[key] for key in ('sha256','mode')}==declared[path]
        packet(image)
    before=packet(contained['source_before'])
    after=packet(contained['source_after'])
    assert c.read(c.PREFIX+'source_review.py')==contained['source_after']
    assert contained['source_before']==boundary['source_before']
    assert contained['source_before']['mode']==contained['source_after']['mode']
    if fault:
        marker=b'baseline-inputs.json.gz'
        assert after.count(marker)==1
        after=after.replace(marker,b'wrong-inputs.json.gz',1)
    assert ast.dump(ast.parse(before.decode()),include_attributes=False)==ast.dump(ast.parse(after.decode()),include_attributes=False), 'helper AST'
    assert before!=after and after==before.rstrip(b'\n')+b'\n', 'EOF-only containment'
    assert contained['ast_equal']
    return dict(original_inputs=60,unchanged_inputs=len(contained['unchanged_inputs']),
        whole_unpublished_outputs=3,actual_original_readonly=0,ast_equal=True)


if __name__=='__main__':
    assert sys.argv[1:] in ([],['--fault'])
    print(json.dumps(check(sys.argv[1:]==['--fault']),sort_keys=True))
