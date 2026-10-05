"""Independently reconstruct the approved finite admission and corrupt its evidence."""
from pathlib import Path
import copy
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-'
REVISION = 'da3d34945d5067410b79f51782395f15b5184ff4'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
def old(path):
    return subprocess.check_output(['git', 'show', REVISION+':'+path], cwd=ROOT)
def sha(raw):
    return hashlib.sha256(raw).hexdigest()
proposal = json.loads((ROOT/(PREFIX+'capacity-proposal.json')).read_bytes())
original_rows = [json.loads(row) for row in old(REGISTRY).splitlines()]
rows = [json.loads(row) for row in (ROOT/REGISTRY).read_bytes().splitlines()]
original_manifest = old(MANIFEST).splitlines(keepends=True)
manifest = (ROOT/MANIFEST).read_bytes().splitlines(keepends=True)
archive_path = proposal['archive_record']['target_path']
archive = (ROOT/archive_path).read_bytes()
original_root = old('DEVELOPMENT_NOTES.md')
note = (ROOT/(PREFIX+'proposed-note.md')).read_bytes()+b'\n'
prior_archives = {json.loads(row)['target_path']: old(json.loads(row)['target_path'])
                  for row in original_manifest[1:]}
observed = {'rows':rows, 'manifest':manifest, 'archive':archive,
            'root':(ROOT/'DEVELOPMENT_NOTES.md').read_bytes(),
            'prior_archives':{p:(ROOT/p).read_bytes() for p in prior_archives}}
def verify(value):
    expected = copy.deepcopy(original_rows)
    route = next(row for row in expected if row.get('id') == 'engineering_notes')
    route['limits']['max_files'] = 44
    route['member_limits'][MANIFEST] = {'max_bytes':26021, 'max_lines':43}
    assert value['rows'] == expected, 'exact three scalar transitions and all other rows'
    assert value['prior_archives'] == prior_archives, 'all prior immutable archive bytes'
    assert value['manifest'][2:] == original_manifest[1:], 'all prior exact manifest rows and order'
    metadata = json.loads(original_manifest[0]);metadata['segment_count'] += 1
    assert json.loads(value['manifest'][0]) == metadata, 'manifest metadata changes only count'
    assert json.loads(value['manifest'][1]) == proposal['archive_record'], 'exact new archive binding'
    assert sha(value['archive']) == '8783c6d63164ded0745e6fd2e9cd9a440d71e3d5b682635b1b5573e126507f0e', 'original clean suffix identity'
    assert (len(value['archive']),value['archive'].count(b'\n')) == (27233,201), 'archive exact measurement'
    assert original_root.endswith(value['archive']), 'clean source suffix'
    prefix = original_root[:-len(value['archive'])]
    assert prefix.count(b'\n')+1 == 142, 'exact original source interval'
    start = re.search(rb'^## ', prefix, re.M).start()
    governed_root = prefix[:start]+note+prefix[start:]
    assert governed_root.endswith(b'\n\n'), 'governed final separator'
    assert value['root'] == governed_root[:-1], 'root exact prefix and note with only final blank separator removed'
    assert (len(value['root']),value['root'].count(b'\n')) == (32359,144), 'root measurement'
    assert len(value['root']) <= 32768 and value['root'].count(b'\n') <= 256, 'unchanged50% retain'
    assert (len(b''.join(value['manifest'])),len(value['manifest'])) == (26021,43), 'manifest exact finite bound'
    assert len(value['prior_archives'])+3 == 44, 'exact full collection members'
verify(observed)
controls = []
for name in ('archive_byte', 'prior_archive_byte', 'prior_row_order', 'root_byte', 'unrelated_limit', 'new_source_commit'):
    bad = copy.deepcopy(observed)
    if name == 'archive_byte': bad['archive'] = b'X'+bad['archive'][1:]
    elif name == 'prior_archive_byte':
        p = next(iter(bad['prior_archives']));bad['prior_archives'][p] = b'X'+bad['prior_archives'][p][1:]
    elif name == 'prior_row_order': bad['manifest'][2:4] = reversed(bad['manifest'][2:4])
    elif name == 'root_byte': bad['root'] += b'X'
    elif name == 'unrelated_limit': next(r for r in bad['rows'] if r.get('id')=='engineering_notes')['limits']['max_total_bytes'] += 1
    else:
        row = json.loads(bad['manifest'][1]);row['source_commit'] = '0'*40
        bad['manifest'][1] = (json.dumps(row)+'\n').encode()
    try: verify(bad)
    except AssertionError as error: controls.append({'name':name,'observed':'RED','reason':str(error)})
    else: raise AssertionError('corruption admitted: '+name)
subprocess.run(['perl', PREFIX+'capacity-controls.pl'], cwd=ROOT, check=True)
production = json.loads((ROOT/(PREFIX+'capacity-controls.json')).read_bytes())
assert production['complete'] and len(production['thresholds']) == 18 and len(production['controls']) == 7
assert production['production_sha256'] == sha((ROOT/'scripts/check_readme_routing_pressure.pl').read_bytes())
result = {'complete':True,'revision':REVISION,'instrument_sha256':sha(Path(__file__).read_bytes()),
          'prior_archives':len(prior_archives),'archive_bytes':len(archive),'archive_lines':archive.count(b'\n'),
          'root_bytes':len(observed['root']),'root_lines':observed['root'].count(b'\n'),
          'manifest_bytes':len(b''.join(manifest)),'manifest_lines':len(manifest),'collection_files':44,
          'scalar_changes':3,'controls':controls,'production_thresholds':18,'production_red_controls':7,
          'scope':'Exact approved prerequisite at da3d; complete prior archive/manifest/root reconstruction, unchanged production threshold/authority functions. Exact staged canonical CI remains required.'}
(ROOT/(PREFIX+'capacity-verification.json')).write_text(json.dumps(result,indent=2)+'\n')
print('Exact finite rollover reconstruction/6 evidence RED/18 actual thresholds/7 actual authority RED PASS')
