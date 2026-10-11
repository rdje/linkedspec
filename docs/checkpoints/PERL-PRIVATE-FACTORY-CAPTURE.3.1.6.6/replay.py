"""Replay original347-input publication in supplied logical state; default readonly."""
import base64
import ast
import gzip
import copy
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[3]
DIR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json'
PUB = PREFIX + 'publish-claim.py'
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda p: (ROOT / p).read_bytes()
channel = lambda raw: {'base64': base64.b64encode(raw).decode(), 'bytes':len(raw), 'sha256':sha(raw)}
record = json.loads(read(DIR + 'original-claim.json'))
entries = record['claims'][0]['durability']['inputs']
assert len(entries) == 347 and len({e['path'] for e in entries}) == 347
relocations = {'DEVELOPMENT_NOTES.md': DIR+'original-root.md', 'docs/knowledge/finite-engineering-notes-member-0131.md': DIR+'original-card.md'}
files = {e['path']:read(relocations.get(e['path'],e['path'])) for e in entries}
for e in entries: assert sha(files[e['path']]) == e['sha256'], 'original logical input: '+e['path']
files[CLAIM] = read(DIR+'original-claim.json')
assert len(files) == 348
modes = {p:(ROOT / p).stat().st_mode & 0o777 for p in files}
book_envelope=json.loads(files[PREFIX+'book.json'])
book=json.loads(gzip.decompress(base64.b64decode(book_envelope['data'])))
assert all(modes[p] == mode for p,mode in book['rows'][0]['modes'].items()), 'exact original book modes'

def layers(raw):
    result=[channel(raw)]
    while b'AssertionError: ' in raw:
        try: obj=ast.literal_eval(raw.decode().rsplit('AssertionError: ',1)[-1])
        except (ValueError,SyntaxError): break
        if not isinstance(obj,dict) or 'stderr' not in obj: break
        for part in ('stdout','stderr'):
            assert channel(base64.b64decode(obj[part]['base64'])) == obj[part]
        raw=base64.b64decode(obj['stderr']['base64']); result.append(channel(raw))
    return result

def named_reason(row):
    return any(b'complete current root reconstruction' in base64.b64decode(c['base64']) for c in row['stderr_layers'])

def expected(name):
    selected = dict(files)
    if name == 'corrected-root':
        raw = selected['DEVELOPMENT_NOTES.md']
        old = b'pressure and old admission reject before the exact clean-Git suffix is archived.'
        assert raw.count(old) == 1
        selected['DEVELOPMENT_NOTES.md'] = raw.replace(old,old.replace(b'archived',b'admitted'),1)
    return selected

target = ROOT / (DIR + 'replay.json')
if sys.argv[1:]:
    assert not target.exists() and not (ROOT / (DIR+'replay-reached.json')).exists()
    rows = []
    for name in ('original','corrected-root','restored'):
        selected = expected(name)
        with tempfile.TemporaryDirectory(prefix='capacity-original-',dir=os.environ['TMPDIR']) as directory:
            supplied = Path(directory)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            for p,raw in selected.items():
                q=supplied/p; q.parent.mkdir(parents=True,exist_ok=True); q.write_bytes(raw); q.chmod(modes[p])
            env=dict(os.environ, GIT_DIR=str(ROOT/'.git'), GIT_WORK_TREE=str(supplied), GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1')
            args=['python3',PUB]
            p=subprocess.run(args,cwd=supplied,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            rows.append({'name':name,'args':args,'exit_code':p.returncode,'stdout':channel(p.stdout),'stderr':channel(p.stderr),'stderr_layers':layers(p.stderr),'modes':modes,'inputs':{p:sha(raw) for p,raw in selected.items()},'unchanged':all((supplied/p).read_bytes()==raw for p,raw in selected.items())})
            (ROOT/(DIR+'replay-reached.json')).write_text(json.dumps({'rows':rows},indent=2)+'\n')
            assert rows[-1]['unchanged']
            if name == 'corrected-root': assert p.returncode != 0 and named_reason(rows[-1])
            else: assert p.returncode == 0 and not p.stderr
    target.write_text(json.dumps({'rows':rows,'producer_sha256':sha(Path(__file__).read_bytes()),'scope':'Exact supplied original uncommitted347-input logical publication plus original claim. Only original root/card relocate byte-identically;345 current files remain exact. Git object/index reads use the owning repository read-only; GIT_OPTIONAL_LOCKS=0. Original actual publisher/reader/controls and recorded observations are unchanged; no runtime/book remeasurement.'},indent=2)+'\n')
data=json.loads(target.read_bytes())
assert data['producer_sha256'] == sha(Path(__file__).read_bytes())
assert json.loads(read(DIR+'replay-reached.json')) == {'rows':data['rows']}
assert [r['name'] for r in data['rows']] == ['original','corrected-root','restored']
for row in data['rows']:
    assert row['inputs'] == {p:sha(raw) for p,raw in expected(row['name']).items()}
    assert row['args']==['python3',PUB] and row['unchanged'] is True and row['modes']==modes
    assert row['stderr_layers'] == layers(base64.b64decode(row['stderr']['base64']))
    for part in ('stdout','stderr'): assert channel(base64.b64decode(row[part]['base64'],validate=True))==row[part]
    if row['name']=='corrected-root': assert row['exit_code']!=0 and named_reason(row)
    else: assert row['exit_code']==0 and row['stderr']['bytes']==0
assert data['rows'][0]['stdout']==data['rows'][2]['stdout']
print('Original347 publication review PASS: actual healthy/changed-root RED/restored channels; two exact relocations/345 unchanged inputs')
