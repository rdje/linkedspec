"""Retain both after fixture errors and reproduce the exact executable-mode mismatch."""
from pathlib import Path
import base64
import hashlib
import json
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
USED = PREFIX+'resulting-tree-capture.py'
RETAINED = PREFIX+'resulting-tree-capture-before.py'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def channel(raw): return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}

source = (ROOT/USED).read_bytes()
assert not (ROOT/RETAINED).exists(), 'one-shot exact retention before overlay correction'
(ROOT/RETAINED).write_bytes(source)
prefix,loop = source.split(b'\nbase_adr = original(ADR).decode()\n',1)
assert loop
namespace = {'__file__':str(ROOT/USED),'__name__':'actual_overlay_mode_diagnosis'}
exec(compile(prefix,USED,'exec'),namespace)
errors = []
for suffix in ('after-resulting-tree','after-independent-caps'):
    path = '.linkedspec-data/logs/accepted-state-'+suffix+'.log'
    raw = (ROOT/path).read_bytes()
    assert b'AssertionError: complete regular worktree identity scripts/check_readme_routing_pressure.pl' in raw
    errors.append({'log_path':path,'combined_channel':channel(raw),'exit_code':1,
                   'producer_path':USED if suffix == 'after-resulting-tree' else PREFIX+'readme-cap-capture.py',
                   'producer_sha256':sha((ROOT/(USED if suffix == 'after-resulting-tree' else PREFIX+'readme-cap-capture.py')).read_bytes())})
with tempfile.TemporaryDirectory(dir=namespace['scratch'],prefix='overlay-mode.') as temporary:
    tree = Path(temporary)
    env = namespace['materialize'](tree)
    git = namespace['git_fixture']
    overlays = [namespace['install_overlay'](tree,env,path,raw) for path,raw in namespace['current_production'].items()]
    modes = {entry['path']:entry['mode'] for entry in namespace['entries']}
    observations = []
    for overlay in overlays:
        target = tree/overlay['path']
        assert sha(target.read_bytes()) == overlay['sha256']
        observations.append({'path':overlay['path'],'original_git_mode':modes[overlay['path']],
                             'actual_filesystem_permissions':oct(target.stat().st_mode & 0o777),
                             'overlay_index_mode':overlay['mode'],'bytes_exact':True})
        assert modes[overlay['path']] == '100755' and overlay['mode'] == '100644' and target.stat().st_mode & 0o777 == 0o755
    before_diff = git(tree,env,'diff','--binary')
    assert before_diff.count(b'diff --git ') == len(overlays)
    assert before_diff.count(b'old mode 100644\nnew mode 100755\n') == len(overlays)
    for overlay in overlays:
        overlay['mode'] = modes[overlay['path']]
        git(tree,env,'update-index','--cacheinfo',overlay['mode'],overlay['object_id'],overlay['path'])
    after_diff = git(tree,env,'diff','--binary')
    assert after_diff == b''
    boundary = namespace['fingerprint'](tree,env,overlays)
assert source == (ROOT/USED).read_bytes(), 'used source unchanged during actual diagnosis'
result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),
          'original_used_path':USED,'retained_source_path':RETAINED,'original_source_sha256':sha(source),
          'errors':errors,'observed_modes':observations,'recurrence':{'before_diff':channel(before_diff),'after_diff':channel(after_diff),'restored_boundary':boundary},
          'scope':'Both original after attempts fail before full gate invocation/report. Complete used helper and actual first combined logs retained; distinct original stdout/stderr unavailable. Separate actual private-index recurrence isolates two executable mode differences with exact body/object bytes. Correct only overlay modes to original regular Git modes; restored actual diff is empty and full fingerprint passes. Original repository metadata, production bytes, original before reports and submodule payload remain untouched; corrected after full gates still required.'}
(ROOT/(PREFIX+'overlay-mode-error.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'gate_not_invoked':True,'mode_only_differences':len(observations),'original_modes_restore_agreement':True}))
