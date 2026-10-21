"""Adopt the whole first publication and derive the corrected console result."""
import gzip
import json
from pathlib import Path
import shutil
import subprocess
import sys

root=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(root/'docs/checkpoints/type-array-pipelines'))
import common as c

def main():
    packet=root/'.linkedspec-data/verification/type-pipeline-report-first.json.gz'
    first=json.loads(gzip.decompress(packet.read_bytes()))
    assert len(first['context']['inputs'])==10719 and c.unchanged(first['context']['inputs'])
    prefix=root/c.PREFIX
    for source,target in [(packet,'report-first.json.gz'),(root/'.linkedspec-data/verification/type-pipeline-report-preserve.py','report-preserve.py')]:
        assert not (prefix/target).exists();shutil.copy2(source,prefix/target)
    assert first['producer']==c.read(c.PREFIX+'report-preserve.py')
    paths=[c.PREFIX+'publish.py',c.PREFIX+'review.py',c.PREFIX+'custody.py',c.PREFIX+'README.md',
        'docs/tasks/TYPE-REFERENCE-BOOK.md','MEMORY.md','CHANGES.md']
    before={p:c.read(p) for p in paths};after={p:c.decode(packet['base64']).decode() for p,packet in before.items()}
    path=c.PREFIX+'publish.py';text=after[path]
    text=text.replace("MANIFEST=c.PREFIX+'publication-inputs.json.gz'","MANIFEST=c.PREFIX+'publication2-inputs.json.gz'",1)
    text=text.replace("PUBLICATION=c.PREFIX+'publication.json'","PUBLICATION=c.PREFIX+'publication2.json'",1)
    text=text.replace('def controls():',"def controls(name='artifact-inputs.json.gz'):",1)
    text=text.replace("saved=c.load('artifact-inputs.json.gz');result={}","saved=c.load(name);result={}",1)
    old="""    if sys.argv[1:]==['--controls']:
        print(json.dumps(controls(),sort_keys=True));return
"""
    new="""    if sys.argv[1:] in (['--controls'],['--controls','artifact2-inputs.json.gz']):
        fixture=sys.argv[2] if len(sys.argv)==3 else 'artifact-inputs.json.gz'
        print(json.dumps(controls(fixture),sort_keys=True));return
"""
    assert text.count(old)==1;text=text.replace(old,new,1)
    start=text.index("    print('Pipeline publication PASS:'");end=text.index('\n\nif __name__',start)
    text=text[:start]+'''    print(f"Pipeline publication PASS: {len(actual)} closed physical inputs; "
        f"{result['cases']} values/{result['accepted_red']} accepted RED/"
        f"{len(result['faults'])} restored faults; "
        f"book{result['book_inputs']}/{result['book_examples']}; source readonly")
'''+text[end:]
    old='Exact staged canonical receipt governs landing.'
    assert text.count(old)==1
    text=text.replace(old,'Whole first10716-input unpublished claim/publication/10719 full-mode source images and actual source-readonly0 precede the console repair. The original structured result already has seven faults; the original label undercounts six. Final console fields derive from the reviewed result, and new artifact controls falsify the actual final publisher. Initial outputs remain frozen; no draft revision or runtime/test/book refresh is invented. Exact staged canonical receipt governs landing.',1)
    compile(text,path,'exec');after[path]=text
    artifact=(prefix/'artifacts.py').read_text()
    for old,new in [('artifact-inputs.json.gz','artifact2-inputs.json.gz'),('artifact-observed.json.gz','artifact2-observed.json.gz'),('artifact-run.json.gz','artifact2-run.json.gz'),("c.PREFIX+'artifacts.py'","c.PREFIX+'artifacts2.py'")]:artifact=artifact.replace(old,new)
    artifact=artifact.replace("command=[sys.executable,c.PREFIX+'publish.py','--controls']","command=[sys.executable,c.PREFIX+'publish.py','--controls','artifact2-inputs.json.gz']",1)
    compile(artifact,c.PREFIX+'artifacts2.py','exec')
    with (prefix/'artifacts2.py').open('x') as output:output.write(artifact)
    path=c.PREFIX+'review.py';text=after[path]
    for old,new in [('artifact-inputs.json.gz','artifact2-inputs.json.gz'),('artifact-observed.json.gz','artifact2-observed.json.gz'),('artifact-run.json.gz','artifact2-run.json.gz')]:text=text.replace(old,new)
    text=text.replace('good==publish.controls()',"good==publish.controls('artifact2-inputs.json.gz')",1)
    after[path]=text
    path=c.PREFIX+'custody.py';text=after[path]
    marker="    paths=set(saved['images'])\n";assert text.count(marker)==1
    addition="""    first=c.load('report-first.json.gz')
    assert first['producer']==c.read(c.PREFIX+'report-preserve.py')
    assert first['baseline']['returncode']==0 and not c.decode(first['baseline']['stderr_base64'])
    assert b'10716 closed physical inputs;85 values/41 accepted RED/6 restored faults' in c.decode(first['baseline']['stdout_base64'])
    assert len(first['context']['inputs'])==10719
    manifest=json.loads(__import__('gzip').decompress(c.decode(first['manifest']['base64'])))
    assert len(manifest['inputs'])==10716
    assert all(first['context']['inputs'][path]==item for path,item in manifest['inputs'].items())
    publication=json.loads(c.decode(first['publication']['base64']))
    assert publication['record_base64']==first['claim']['base64'] and len(publication['result']['faults'])==7
    assert first['context']['new_inputs'][c.PREFIX+'publish.py']==first['publisher']
    contexts['report-first']=first['context']
"""
    text=text.replace(marker,addition+marker,1);after[path]=text
    path=c.PREFIX+'README.md';text=after[path]
    text=text.replace('`publication-inputs.json.gz` closes the final physical population/full modes.','`publication2-inputs.json.gz` closes the final physical population/full modes; `publication2.json` is current. The initial publication outputs remain frozen.',1)
    text+='''
## Reporting correction before canonical admission

report-first.json.gz retains the whole first10716-input unpublished claim,
publication/full modes/10719 source images and actual source-readonly0 before
bound writes. Its structured result already lists seven faults; only its console
label still said six. report-preserve.py is the actual preserver. No draft Git
revision is invented. Final console fields derive from the reviewed result.
artifact2-* falsifies the actual final publisher with three denials, a real
validator-removal admission and restoration. Original artifact/source epochs
remain exact. Runtime, permanent tests, book and their observations are unchanged.
'''
    after[path]=text
    path='docs/tasks/TYPE-REFERENCE-BOOK.md';text=after[path]
    marker='  Commit subject: `TYPE-REFERENCE-BOOK.1.2.9 - execute deferred sorted take pipelines`.\n'
    assert text.count(marker)==1
    text=text.replace(marker,'  Reporting admission: Whole first10716 unpublished claim/publication/10719 source images/full modes/actual source-readonly0 survive before correcting its console6 versus structured7. Final console derives fields from the reviewed result; final artifact2 controls and publication2 bind the actual publisher. Runtime/test/book epochs stay unchanged.\n'+marker,1)
    after[path]=text
    after['MEMORY.md']+='- report_epoch: Whole first10716 unpublished claim/publication/10719 full-mode source images/actual readonly0 retained. Structured7 was correct; console6 is corrected by deriving result fields. Current publication2/manifest2 and final artifact2 controls bind the same publish.py gateway; original outputs stay frozen.\n'
    text=after['CHANGES.md'];start=text.index('\n## ')+1;end=text.index('\n## ',start+1)
    text=text[:end].rstrip()+'\n\nReporting correction preserves the whole first10716-input claim/publication/10719 source images/full modes/actual readonly0; only its console label undercounted six while the structured result listed seven. Final fields derive from the reviewed result, with fresh actual publisher artifact controls and separate publication2 outputs. Runtime/test/book observations remain unchanged.\n\n'+text[end:].lstrip('\n')
    after['CHANGES.md']=text
    assert len(after['docs/tasks/TYPE-REFERENCE-BOOK.md'].encode())<=65536
    for p,text in after.items():(root/p).write_text(text)
    shutil.copy2(Path(__file__),prefix/'report-correct.py')
    c.write_new('report-correction.json.gz',dict(before=before,after={p:c.read(p) for p in paths},producer=c.read(c.PREFIX+'report-correct.py'),
        scope='Only publication reporting/custody changes. Actual validator controls rerun on final publisher; all first outputs are immutable. No runtime/test/book producer or observation is refreshed.'))
    print('First publication adopted; dynamic report/final manifest2/artifact2 readers installed; no runtime/test/book change')

if __name__=='__main__':main()
