"""Preserve the unpublished proof before its AST-identical EOF containment."""
import ast
import json
from pathlib import Path
import sys
sys.path.insert(0,'docs/checkpoints/type-cli-runtime-errors')
import common as c
import context

prefix=c.PREFIX
boundary='publication1-whitespace-boundary.json.gz'
assert not (c.ROOT/prefix/boundary).exists()
producer_path=Path(__file__).resolve().relative_to(c.ROOT).as_posix()
producer=c.read(producer_path)
outputs=dict(manifest=prefix+'publication-inputs.json.gz',publication=prefix+'publication.json',claim='docs/claims/'+c.OWNER+'.json')
packets={name:c.read(path) for name,path in outputs.items()}
inputs=c.load('publication-inputs.json.gz')['inputs']
assert all(c.identity(path)==item for path,item in inputs.items())
source_path=prefix+'source_review.py'
source_before=c.read(source_path)
readme_before=c.read(prefix+'README.md')
epoch=context.snapshot()
failed_check=c.run(['git','diff','--cached','--check'])
assert failed_check['returncode']==2
assert b'source_review.py:88: new blank line at EOF.' in c.decode(failed_check['stdout_base64'])
readonly=c.run(['bash','tools/run_python_project_data.sh',prefix+'publish.py'])
assert readonly['returncode']==0 and not c.decode(readonly['stderr_base64'])
assert c.unchanged(epoch['inputs'])
c.write_new(boundary,dict(context=epoch,outputs=packets,output_paths=outputs,inputs=inputs,
    producer=producer,source_before=source_before,readme_before=readme_before,
    actual_readonly=readonly,actual_whitespace_rejection=failed_check,
    scope='Whole first unpublished publication/claim/manifest and actual readonly0 precede all containment writes. Every old physical input remains recoverable from its unchanged file or the complete before packets. This was not an accepted Git state.'))
with (c.ROOT/prefix/'contain_whitespace.py').open('xb') as out:
    out.write(c.decode(producer['base64']))
(c.ROOT/prefix/'contain_whitespace.py').chmod(producer['mode'])
backups={}
for name,packet in packets.items():
    target=prefix+dict(manifest='publication1-inputs.json.gz',publication='publication1.json',claim='publication1-claim.json')[name]
    with (c.ROOT/target).open('xb') as out: out.write(c.decode(packet['base64']))
    (c.ROOT/target).chmod(packet['mode'])
    assert c.read(target)==packet
    backups[name]=target
raw=c.decode(source_before['base64'])
contained=raw.rstrip(b'\n')+b'\n'
assert raw!=contained and raw.rstrip(b'\n')==contained.rstrip(b'\n')
assert ast.dump(ast.parse(raw.decode()),include_attributes=False)==ast.dump(ast.parse(contained.decode()),include_attributes=False)
c.source(source_path).write_bytes(contained)
c.source(source_path).chmod(source_before['mode'])
readme=c.decode(readme_before['base64']).decode()
marker='## Capture discipline\n'
assert readme.count(marker)==1
paragraph='''## Final staging containment

The first unpublished publication and actual readonly0 are preserved in
`publication1-whitespace-boundary.json.gz` plus exact publication/claim/manifest
copies. Staging found one redundant EOF blank in the copied source-epoch helper.
The contained helper differs only in trailing LF count and has an identical Python
syntax tree. Every original source image and observation remains recoverable;
`whitespace-containment.json.gz` verifies all unchanged old inputs. The current
publication rebinds this contained reader; no functional evidence or SUT changes.
`contain_whitespace.py` is the exact historical containment actor, first executed
from a project-local ignored path so the old publication namespace stayed exact
until its actual baseline result was captured. Never rerun it.

'''
c.source(prefix+'README.md').write_text(readme.replace(marker,paragraph+marker,1))
tree=c.source('docs/tasks/TYPE-REFERENCE-BOOK.md')
text=tree.read_text()
start=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.17.8`')
end=text.index('- ID: ',start+5)
node=text[start:end]
marker='  Acceptance checklist:\n'
assert node.count(marker)==1
node=node.replace(marker,'  Final staging hygiene: The first unpublished publication/claim/manifest and actual readonly0 precede containment in publication1-whitespace-boundary.json.gz. The copied source-epoch helper had one redundant EOF blank; trim only trailing LF, prove identical Python AST and retain every old input/source/mode. Exact old output copies and whitespace-containment.json.gz preserve the boundary. Rebind publication after containment; no functional, book, inverse or artifact observation changes.\n'+marker,1)
tree.write_text(text[:start]+node+text[end:])
unchanged=[]
for path,item in inputs.items():
    if path not in (source_path,prefix+'README.md'):
        assert c.identity(path)==item,path
        unchanged.append(path)
for name,path in outputs.items():
    assert c.read(backups[name])==packets[name]
    c.source(path).unlink()
c.write_new('whitespace-containment.json.gz',dict(boundary=prefix+boundary,
    producer=c.read(prefix+'contain_whitespace.py'),producer_original=producer,
    source_before=source_before,source_after=c.read(source_path),ast_equal=True,
    old_outputs=backups,unchanged_inputs=unchanged,changed_inputs=[source_path,prefix+'README.md'],
    original_input_count=len(inputs),scope='EOF/README containment only. Exact old outputs are copied, verified and removed from their current publication names before fresh capture. All original observations and historical producer images remain unchanged.'))
print('Unpublished publication60/actual readonly0 preserved; EOF-only AST-identical helper contained; old outputs copied/verified; recapture required')
