"""Retain the first fixture failure and distinguish its actual Git-state mechanism."""
from pathlib import Path
import base64
import hashlib
import json
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
USED = PREFIX+'resulting-tree-capture.py'
RETAINED = PREFIX+'resulting-tree-capture-initial.py'
LOG = '.linkedspec-data/logs/accepted-state-before-resulting-tree.log'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def channel(raw): return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}

source = (ROOT/USED).read_bytes()
assert not (ROOT/RETAINED).exists(), 'one-shot retention before correction'
(ROOT/RETAINED).write_bytes(source)
error = (ROOT/LOG).read_bytes()
assert b'AssertionError: no tracked stage/worktree split' in error
assert b'line 147' in error and b'line 112' in error
assert source.count(b'\nbase_adr = original(ADR).decode()\n') == 1
# Execute only the exact original initialization and fixture functions. The
# original full-gate loop and report writer are not replayed or replaced.
initialization = source.split(b'\nbase_adr = original(ADR).decode()\n',1)[0]
namespace = {'__file__':str(ROOT/USED),'__name__':'retained_fixture_diagnosis'}
exec(compile(initialization,str(ROOT/USED),'exec'),namespace)
record = {'complete':False,'producer_sha256':sha(Path(__file__).read_bytes()),
          'original_used_path':USED,'retained_source_path':RETAINED,'original_source_sha256':sha(source),
          'initial_exit_code':1,'initial_combined_log':channel(error),
          'initial_channel_limits':'Original shell redirected stdout/stderr into this complete combined log; distinct channels and original Git diff bytes were not retained.',
          'scope':'Instrument failure before full README gate invocation, not a production admission defect. Exact used source and actual first combined error retained; a separate actual Git recurrence below identifies the cause. No original index/object/ref or other repository write; gitlink payload remains uninspected.'}
with tempfile.TemporaryDirectory(prefix='initial-diagnosis.',dir=namespace['scratch']) as temporary:
    tree = Path(temporary)
    env = namespace['materialize'](tree)
    git = namespace['git_fixture']
    actual_diff = git(tree,env,'diff','--binary')
    assert actual_diff and b'diff --git a/rgx b/rgx\n' in actual_diff
    assert actual_diff.count(b'diff --git ') == 1 and b'deleted file mode 160000' in actual_diff
    assert all(sha((tree/entry['path']).read_bytes()) == entry['sha256'] for entry in namespace['entries']), 'all actual regular fixture bytes unchanged'
    assert not (tree/'rgx').exists(), 'missing unpopulated gitlink directory'
    (tree/'rgx').mkdir()  # Empty metadata placeholder only; no payload or pin change.
    corrected_diff = git(tree,env,'diff','--binary')
    assert corrected_diff == b'', 'sole empty-directory correction restores actual Git agreement'
    boundary = namespace['fingerprint'](tree,env,[])
    record.update(complete=True,recurrence={'before_diff':channel(actual_diff),'after_diff':channel(corrected_diff),
                                          'restored_boundary':boundary,'regular_inputs':len(namespace['entries']),
                                          'correction':'Create only an empty directory at each excluded gitlink path; preserve every regular input and stage object, and never inspect or copy submodule payload.'})
assert sha((ROOT/USED).read_bytes()) == sha(source), 'original producer remains unchanged during diagnosis'
(ROOT/(PREFIX+'fixture-error.json')).write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({'complete':True,'initial_gate_not_invoked':True,'actual_gitlink_only_diff':True,'empty_placeholder_restores_agreement':True}))
