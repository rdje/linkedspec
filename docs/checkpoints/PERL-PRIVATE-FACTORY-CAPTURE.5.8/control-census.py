"""Independent actual-population review; retain original census RED and correction."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
encode=lambda v:base64.b64encode(v).decode()
inputs=set()
def raw(p):inputs.add(p);return (ROOT/p).read_bytes()
def measure(paths):
    values=[raw(p) for p in paths]
    return dict(files=len(values),lines=sum(v.count(b'\n') for v in values),bytes=sum(map(len,values)))
def verify(stage):
    suffix='-final' if stage=='final' else ''
    captured=json.loads(raw(PREFIX+'controls'+suffix+'.json'))
    assert captured['producer_sha256']==sha(raw(PREFIX+'capture-controls'+suffix+'.py'))
    assert captured['returncode']==0 and not decode(captured['stderr_base64'])
    data=json.loads(decode(captured['stdout_base64']))
    assert data['instrument_sha256']==sha(raw(PREFIX+'controls'+suffix+'.pl'))
    assert data['production_sha256']==sha(raw('scripts/check_readme_routing_pressure.pl'))
    expected={}
    for surface,current,family in (('change_history','CHANGES.md','changes'),('engineering_notes','DEVELOPMENT_NOTES.md','development-notes')):
        paths=[current,'docs/history/'+family+'/manifest.jsonl']
        paths+=sorted(p.relative_to(ROOT).as_posix() for p in (ROOT/('docs/history/'+family)).glob('*.md'))
        expected[surface]=measure(paths)
    expected['decisions']=measure(sorted(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/decisions').glob('*.md')))
    manifest=raw('docs/history/changes/manifest.jsonl')
    expected['manifest']=dict(lines=manifest.count(b'\n'),bytes=len(manifest))
    mismatches=sorted(name for name in expected if data['measured'][name]!=expected[name])
    assert not mismatches, ('actual complete census mismatch',mismatches)
    plan=json.loads(raw(PREFIX+'plan.json'))
    members='docs/history/changes/manifest.jsonl'
    dimensions=[('change_history','files','max_files',plan['old_limits']['change_history'],plan['new_limits']['change_history']),
        ('engineering_notes','lines','max_total_lines',plan['old_limits']['engineering_notes'],plan['new_limits']['engineering_notes']),
        ('manifest','lines','max_lines',plan['old_contract']['member_limits'][members],plan['new_contract']['member_limits'][members]),
        ('manifest','bytes','max_bytes',plan['old_contract']['member_limits'][members],plan['new_contract']['member_limits'][members]),
        ('decisions','files','max_files',plan['old_limits']['decisions'],plan['new_limits']['decisions']),
        ('decisions','lines','max_total_lines',plan['old_limits']['decisions'],plan['new_limits']['decisions'])]
    populations=[]
    for surface,metric,key,old,new in dimensions:
        for value in (old[key]-1,old[key],expected[surface][metric],new[key],new[key]+1):
            for limit in (old[key],new[key]):populations.append((surface,metric,value,limit))
    assert [(v['surface'],v['metric'],v['value'],v['limit']) for v in data['thresholds']]==populations
    assert len(populations)==60
    for row in data['thresholds']:
        assert row['rejected']==(row['value']>row['limit']) and bool(row['reasons'])==row['rejected']
    assert len(data['authority'])==31 and all(v['observed']=='RED' for v in data['authority'])
    positive=subprocess.run(['perl',PREFIX+'controls-final.pl'],cwd=ROOT,capture_output=True)
    assert positive.returncode==0 and not positive.stderr and positive.stdout==decode(captured['stdout_base64'])
    return data
assert sys.argv[1:] in ([],['--capture'],['--original'],['--final'])
if sys.argv[1:] in (['--original'],['--final']):
    verify(sys.argv[1][2:]);print('Control census PASS: exact actual population;60 thresholds/31 authority REDs');raise SystemExit
source=raw(PREFIX+'controls.pl')
old=b": ('DEVELOPMENT_NOTES.md', glob('docs/history/development-notes/*.md'), 'docs/history/changes/manifest.jsonl');"
new=old.replace(b"'docs/history/changes/manifest.jsonl'",b"'docs/history/development-notes/manifest.jsonl'")
first=b"my $manifest = raw('docs/history/development-notes/manifest.jsonl');"
second=b"my $manifest = raw('docs/history/changes/manifest.jsonl');"
assert source.count(old)==source.count(first)==1
assert raw(PREFIX+'controls-final.pl')==source.replace(old,new,1).replace(first,second,1)
verify('final')
for name in ('capture-controls.py','capture-controls-final.py','controls.json','controls-final.json','control-census.py'):raw(PREFIX+name)
target=ROOT/(PREFIX+'control-census.json')
if sys.argv[1:]:
    rows=[]
    for name in ('original','final'):
        command=['python3',PREFIX+'control-census.py','--'+name]
        run=subprocess.run(command,cwd=ROOT,capture_output=True)
        rows.append(dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr)))
    assert rows[0]['returncode']!=0 and b"actual complete census mismatch" in decode(rows[0]['stderr_base64'])
    assert b"['engineering_notes', 'manifest']" in decode(rows[0]['stderr_base64'])
    assert rows[1]['returncode']==0 and not decode(rows[1]['stderr_base64'])
    report=dict(result='PASS',producer_sha256=sha(raw(PREFIX+'control-census.py')),rows=rows,
        inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
        scope='Original passing arithmetic/authority output is independently rejected for its wrong engineering and manifest populations. Exact two-line corrected source has full actual census equality,60 inclusive observations/31 authority REDs and actual readonly byte-exact output recurrence. Production checker and admission/measurement remain unchanged.')
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:report=json.loads(target.read_bytes())
assert report['producer_sha256']==sha(raw(PREFIX+'control-census.py'))
assert report['inputs']=={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)}
assert report['rows'][0]['returncode']!=0 and report['rows'][1]['returncode']==0
print('Control census review PASS: original two-population RED;exact correction/actual recurrence')
