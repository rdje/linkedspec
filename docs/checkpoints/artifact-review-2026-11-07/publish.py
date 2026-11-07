"""Bind the completed dated observation, actual channels and composition instrument."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
OWNER='TYPE-REFERENCE-BOOK.1.2.23.4.15'
report=json.loads(gzip.decompress((BASE/'observation.json.gz').read_bytes()))
result=json.loads((BASE/'result.json').read_bytes())
assert report['owner']==OWNER and report['removed']==[]
assert report['activation_commit']=='12cfcaa7ae01af8451fda2d9533ac612a08d7317'
assert result['date']==report['at_utc'] and result['result']=='PASS' and result['removed']==0
assert result['scoped_rows']==sum(len(row['primary']) for row in report['scopes'].values())
assert len(report['scopes'])==8 and report['configured_cargo_target']=='rust/target'
for row in report['scopes'].values(): assert row['primary']==row['independent']
for name,packet in report['producers'].items():
    body=Path(name).read_bytes()
    assert body==base64.b64decode(packet['base64'])
    assert hashlib.sha256(body).hexdigest()==packet['sha256']
for mode,target in (('capture','capture-result.json'),('review','result.json')):
    assert (BASE/(mode+'-exit.txt')).read_text()=='0\n'
    assert gzip.decompress((BASE/(mode+'-stderr.log.gz')).read_bytes())==b''
    assert gzip.decompress((BASE/(mode+'-stdout.log.gz')).read_bytes())==(BASE/target).read_bytes()
    assert json.loads((BASE/target).read_bytes())==result
controls=['missing-row','wrong-size','duplicate-row','outside-path','producer-byte']
assert result['rejected_controls']==report['rejected_controls']==controls
claim=json.loads(Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.13.json').read_bytes())
claim['owner']=OWNER
item=claim['claims'][0]
item['statement']=f"The {result['scoped_rows']} retained named-scope artifact rows agree with independent path/byte metadata observations; all selected artifacts remain retained and five altered-evidence controls reject."
item['scope']=f"Dated {report['at_utc']} root-level strays, six explicit root/crate Rust release/incremental/deps locations and retained log directory only; .log/.bin/.DS_Store suffixes. Configured Cargo target rust/target is covered. Not a whole-project inventory, content ownership, disposability, liveness, reclamation, cold bootstrap or concurrent-adversarial claim. Dart/Julia convention presence and Lua wrapper reference grant no purge permission."
item['rederive']['command']='bash tools/run_python_project_data.sh '+str(BASE/'review.py')
item['rederive']['result']=(BASE/'result.json').read_text().strip()
item['falsify']['red_control']='Actual missing-row, wrong-size, duplicate-row, outside-path and producer-byte mutations reject. Healthy one-shot capture and separate readonly replay return0 with empty stderr. No deletion or liveness inference follows.'
paths=set(report['producers'])|{str(BASE/'publish.py'),str(BASE/'observation.json.gz'),str(BASE/'capture-result.json'),str(BASE/'result.json')}
for mode in ('capture','review'):
    paths|={str(BASE/(mode+suffix)) for suffix in ('-command.json','-exit.txt','-stdout.log.gz','-stderr.log.gz')}
item['durability']['inputs']=[]
for name in sorted(paths):
    path=Path(name)
    assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
    role='producer' if name.endswith('.py') or name in report['producers'] and name!='tools/run_lua_project_data.sh' else 'input'
    item['durability']['inputs'].append(dict(path=name,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),role=role))
output=Path('docs/claims')/(OWNER+'.json')
assert not output.exists()
output.write_text(json.dumps(claim,indent=2)+'\n')
readme=BASE/'README.md';assert not readme.exists()
readme.write_text(f'''# November7 bounded artifact review

Owner: {OWNER}. Clean activation: {report['activation_commit']}.
The November6 05:15UTC cleanup record was over24h old. New dated observation:
{report['at_utc']}.

The existing non-following scanner and independent scandir/lstat agree on all
{result['scoped_rows']} per-file path/suffix/byte rows in eight named scopes: root-level
strays, six root/crate Rust release/incremental/deps locations and retained logs.
Configured Cargo target rust/target is covered. Dart/Julia caches and Lua managed
runs remain retained; managed-run contents are not traversed. No dependency
implementation or other repository is inspected or modified.

Nothing was removed. Metadata alone establishes no content ownership, liveness,
disposability or reclamation. Reusable caches, active output and unresolved proof
remain protected. The snapshot retains primary/independent populations, direct
producer bodies, outer channel instrument and actual Git-index bytes. Five
missing-row/wrong-size/duplicate-row/outside-path/producer-byte controls reject.
Separate readonly replay returns0/empty stderr, matching the actual acquisition.
Actual argv/cwd/exit/full stdout/stderr survive; raw channels are lossless gzip.

Readonly: bash tools/run_python_project_data.sh {BASE}/review.py.
The --capture writer and run.py acquisition phases are completed one-shot writers.
publish.py binds the actual observation/channels and this composition instrument
in docs/claims/{OWNER}.json. Earlier observations/claims remain immutable.

This is dated named-scope metadata, not a whole-project inventory or authority to
purge. No runtime/storage-default/hook/CI policy changed and no broad suite ran.
Independent Dart77.3 resumes after the normal maintenance commit/clean handoff.
''')
Path('docs/ARTIFACT_CLEANUP.md').write_text(f'''# Latest artifact cleanup

- Date: {report['at_utc']}
- Summary: {OWNER} reviewed eight named root/Rust/log scopes with all{result['scoped_rows']} per-file metadata rows matching an independent walk; configured Cargo target covered, five altered-evidence controls and separate readonly replay pass. Nothing was removed; caches, proof, active outputs and other repositories remain protected. Actual snapshot/channels: {BASE}/; readonly review.py in that directory.
''')
print('dated claim, latest-only cleanup record and review note written')
