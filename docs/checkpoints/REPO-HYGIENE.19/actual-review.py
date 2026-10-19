"""Readonly complete metadata capture/channel/source review; --capture freezes once."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='e953f69a9934c4ab48e643e69c9efaba0cb1d534'
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
assert sys.argv[1:] in ([],['--capture'])
inputs=set()
def raw(p):inputs.add(p);return (ROOT/p).read_bytes()
def load(name):return json.loads(raw(PREFIX+name))
def channel(value):
    assert set(value)=={'bytes','sha256','gzip_base64'},'both complete actual channels'
    data=gzip.decompress(decode(value['gzip_base64']))
    assert len(data)==value['bytes'] and sha(data)==value['sha256'],'actual channel byte custody'
    return data
actual=load('actual.json');assert actual['complete'] is True and actual['owner']=='REPO-HYGIENE.19' and actual['revision']==BASE
producers={PREFIX+n for n in ('census.py','review.py','capture.py')}
producers.update({'docs/checkpoints/REPO-HYGIENE.18-census.py','tools/run_python_project_data.sh','tools/project_data_env.sh','tools/project_data_run.sh'})
assert set(actual['inputs'])==producers,'complete actual producer population'
for p,identity in actual['inputs'].items():assert sha(raw(p))==identity,'actual producer source custody'
assert len(actual['runs'])==2
parsed=[]
for index,row in enumerate(actual['runs']):
    name='census.py' if index==0 else 'review.py'
    assert row['command']==['bash','tools/run_python_project_data.sh',PREFIX+name]+([] if index==0 else ['--live'])
    assert row['exit']==0,'actual producer exit'
    assert {'stdout','stderr'}<=set(row),'both complete actual channels'
    out=channel(row['stdout']);err=channel(row['stderr'])
    assert not err,'actual empty stderr'
    assert row['inputs_before']==row['inputs_after']==actual['inputs'],'actual producer guards'
    target=PREFIX+('artifact-review.json' if index==0 else 'verification.json')
    assert out==raw(target),'actual complete stdout artifact'
    parsed.append(json.loads(out))
data,verified=parsed
assert data['owner']==verified['owner']=='REPO-HYGIENE.19' and data['at_utc']==verified['at_utc']
assert data['activation_commit']==BASE and data['removed_files']==data['removed_bytes']==verified['removed_files']==verified['removed_bytes']==0
assert data['artifact_files']==len(data['rows'])==verified['artifact_files'],'actual complete metadata row population'
assert data['artifact_bytes']==sum(v['bytes'] for v in data['rows'])==verified['artifact_bytes'],'actual complete metadata byte census'
assert data['rows']==sorted(data['rows'],key=lambda v:v['path'])
seen=set()
for row in data['rows']+[v for group in data['rust_log_bin'].values() for v in group['rows']]:
    p=row['path'];assert not Path(p).is_absolute() and '..' not in Path(p).parts and p not in seen and not p.startswith('rgx/')
    assert row['bytes']>=0 and row['suffix'] in ('.log','.bin','.DS_Store') and p.endswith(row['suffix']);seen.add(p)
for suffix,value in data['by_suffix'].items():assert value==dict(files=sum(v['suffix']==suffix for v in data['rows']),bytes=sum(v['bytes'] for v in data['rows'] if v['suffix']==suffix))
assert set(data['rust_log_bin'])=={'rust/target/release','rust/target/debug/incremental','rust/target/debug/deps'}
for value in data['rust_log_bin'].values():assert value['files']==len(value['rows']) and value['bytes']==sum(v['bytes'] for v in value['rows'])
assert {'rgx','.git','.linkedspec-data/cache','.linkedspec-data/scratch/runs','.linkedspec-data/scratch/hygiene19','rust/target'}<=set(data['excluded_paths'])
assert all('.linkedspec-data/scratch/hygiene'+str(n) in data['excluded_paths'] for n in range(1,20))
assert verified['result']=='PASS' and verified['live_metadata_checked'] is True
for field in ('aggregate_inflation_rejected','start_symlink_rejected','ancestor_symlink_rejected',
    'start_nested_repository_rejected','start_submodule_rejected','outside_root_rejected',
    'fresh_metadata_census_matches','per_file_os_metadata_oracle_matches','balanced_size_redistribution_rejected'):
    assert verified[field] is True,('actual live control',field)
for p,identity in verified['inputs'].items():assert sha(raw(p))==identity,'actual live-review input custody'
assert data['base_census']=='docs/checkpoints/REPO-HYGIENE.18-census.py' and data['base_census_sha256']==sha(raw(data['base_census']))
default=subprocess.run(['python3',PREFIX+'review.py'],cwd=ROOT,capture_output=True)
assert default.returncode==0 and not default.stderr
assert json.loads(default.stdout)['live_metadata_checked'] is False
cleanup=raw('docs/ARTIFACT_CLEANUP.md')
assert cleanup.count(b'\n')==3 and data['at_utc'].encode() in cleanup and b'zero files removed' in cleanup
raw(PREFIX+'actual-review.py')
report=dict(result='PASS',base=BASE,producer_sha256=sha(raw(PREFIX+'actual-review.py')),
    parent_files=data['artifact_files'],parent_bytes=data['artifact_bytes'],at_utc=data['at_utc'],
    rust={p:dict(files=v['files'],bytes=v['bytes'],exists=v['exists']) for p,v in data['rust_log_bin'].items()},
    inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
    scope='Complete actual census/live-review commands, exits, both byte-exact channels and producer guards. Full dated parent/Rust rows and actual live fresh/lstat/size/traversal controls are retained. Defaults recheck dated custody only; no current filesystem stability, content ownership/disposability, concurrent adversarial traversal or liveness/recovery/purge claim. All artifacts/caches retained; zero removed.')
target=ROOT/(PREFIX+'actual-review.json')
if sys.argv[1:]:
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:assert json.loads(target.read_bytes())==report
print('Actual retention review PASS:',data['artifact_files'],'dated parent rows;full channels/live controls;zero removals')
