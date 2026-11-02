"""Actual public retrieval examples and distinguishing rejected segment spelling."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT=Path(__file__).resolve().parents[3]
PREFIX=Path(__file__).parent


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(),sha256=hashlib.sha256(raw).hexdigest())


def run(args):
    result=subprocess.run(args,cwd=ROOT,capture_output=True)
    return dict(args=args,returncode=result.returncode,stdout=packet(result.stdout),stderr=packet(result.stderr))


def capture():
    destination=PREFIX/'book-command-intake.json.gz'
    assert not destination.exists(),'capture is one-shot'
    base=['perl','tools/read_document_history.pl','--surface','change_history']
    red=run(base+['--segment','segment-0001'])
    assert red['returncode']!=0 and base64.b64decode(red['stderr']['base64'])==b'segment id must be four decimal digits\n'
    catalog=json.loads(subprocess.check_output(base+['--catalog-json'],cwd=ROOT))
    expected=(ROOT/catalog[1]['target_path']).read_bytes()
    assert catalog[1]['segment_id']=='4932','published retained segment disappeared'
    green=run(base+['--segment','4932'])
    assert green['returncode']==0 and base64.b64decode(green['stdout']['base64'])==expected
    whole=run(base+['--all'])
    assert whole['returncode']==0 and base64.b64decode(whole['stdout']['base64'])==b''.join((ROOT/row['target_path']).read_bytes() for row in catalog[1:])
    history=run(['python3','tools/read_task_narrative.py','--tree','TYPE-REFERENCE-BOOK','--id','TYPE-REFERENCE-BOOK.1.1'])
    source=subprocess.check_output(['git','show','0db5e9e87b7c1cfaf09936b9629974787038f5e3:docs/tasks/TYPE-REFERENCE-BOOK.md'],cwd=ROOT)
    match=re.search(rb'^- ID: `TYPE-REFERENCE-BOOK\.1\.1`\n.*?(?=^- ID: `)',source,re.M|re.S)
    assert history['returncode']==0 and base64.b64decode(history['stdout']['base64'])==match[0]
    current=run(['perl','tools/read_task_tree.pl','--tree','TYPE-REFERENCE-BOOK','--id','TYPE-REFERENCE-BOOK.1.2.20.1.10'])
    assert current['returncode']==0 and base64.b64decode(current['stdout']['base64'])==(ROOT/'docs/tasks/TYPE-REFERENCE-BOOK.overview.md').read_bytes()
    live=run(['perl','tools/read_document_history.pl','--surface','live_status','--segment','0001'])
    assert live['returncode']==0 and base64.b64decode(live['stdout']['base64'])
    producers={name:packet((ROOT/name).read_bytes()) for name in ('tools/read_document_history.pl','tools/lib/LinkedSpec/DocumentHistoryCatalog.pm','tools/read_task_narrative.py','tools/task_narrative.py','tools/read_task_tree.pl')}
    report=dict(red=red,green=green,whole_history=whole,historical_node=history,current_part=current,
                live_status_existing=live,producers=producers,expected_segment=packet(expected),limits='Actual dated public retrieval commands; source/Git byte oracles. No mutating scope-update example is rerun against the staged candidate.')
    destination.write_bytes(gzip.compress(json.dumps(report,sort_keys=True,separators=(',',':')).encode(),mtime=0))
    print('book examples: rejected draft spelling; corrected segment, whole history, historical node and current part exact PASS')

if __name__=='__main__':capture()
