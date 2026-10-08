"""Retain the original recovery-review error and isolate private Git HEAD initialization."""
from pathlib import Path
import ast
import base64
import hashlib
import json
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
USED = PREFIX+'review.py'
RETAINED = PREFIX+'review-initial.py'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def channel(raw): return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}

source = (ROOT/USED).read_bytes()
assert not (ROOT/RETAINED).exists(), 'one-shot original review retention'
(ROOT/RETAINED).write_bytes(source)
syntax = ast.parse(source)
constants = {node.targets[0].id:ast.literal_eval(node.value) for node in syntax.body if isinstance(node,ast.Assign) and isinstance(node.targets[0],ast.Name) and node.targets[0].id in ('REV','BASE')}
recover = next(node for node in syntax.body if isinstance(node,ast.FunctionDef) and node.name == 'recover_boundary')
configs = [node.args[0].value for node in ast.walk(recover) if isinstance(node,ast.Call) and isinstance(node.func,ast.Attribute) and node.func.attr == 'write_text' and node.args and isinstance(node.args[0],ast.Constant) and isinstance(node.args[0].value,str) and node.args[0].value.startswith('[core]\n')]
assert len(configs) == 1
error = (ROOT/'.linkedspec-data/logs/accepted-state-review.log').read_bytes()
assert b'private input recovery' in error and b'fatal: not a git repository:' in error
objects = Path(subprocess.check_output(['git','rev-parse','--git-path','objects'],cwd=ROOT).decode().strip())
if not objects.is_absolute(): objects = ROOT/objects
scratch = ROOT/'.linkedspec-data/scratch/accepted-state-review'
scratch.mkdir(parents=True,exist_ok=True)
assert scratch.stat().st_dev == objects.stat().st_dev == ROOT.stat().st_dev
with tempfile.TemporaryDirectory(dir=scratch,prefix='head-diagnosis.') as temporary:
    tree = Path(temporary); metadata = tree/'.git'
    (metadata/'objects').mkdir(parents=True); (metadata/'refs').mkdir()
    (metadata/'config').write_text(configs[0])
    env = {k:v for k,v in os.environ.items() if not k.startswith('GIT_')}
    env.update(GIT_DIR=str(metadata),GIT_WORK_TREE=str(tree),GIT_INDEX_FILE=str(metadata/'index'),
               GIT_OBJECT_DIRECTORY=str(metadata/'objects'),GIT_ALTERNATE_OBJECT_DIRECTORIES=str(objects.resolve()),GIT_OPTIONAL_LOCKS='0')
    args = ['git','-c','core.fsmonitor=false','read-tree',constants['REV']]
    before = subprocess.run(args,cwd=tree,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    assert before.returncode == 128 and before.stdout == b'' and b'fatal: not a git repository:' in before.stderr and not (metadata/'HEAD').exists()
    (metadata/'HEAD').write_text(constants['BASE']+'\n')
    after = subprocess.run(args,cwd=tree,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    assert after.returncode == 0 and after.stdout == after.stderr == b''
    actual_head = subprocess.check_output(['git','rev-parse','HEAD'],cwd=tree,env=env).decode().strip()
    assert actual_head == constants['BASE']
assert source == (ROOT/USED).read_bytes()
result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),'original_used_path':USED,
          'retained_source_path':RETAINED,'original_source_sha256':sha(source),
          'original_combined_error':channel(error),'original_exit_code':1,
          'config_from_actual_source':configs[0],'args':args,
          'recurrence':{'before':{'exit_code':before.returncode,'stdout':channel(before.stdout),'stderr':channel(before.stderr)},
                        'after':{'exit_code':after.returncode,'stdout':channel(after.stdout),'stderr':channel(after.stderr)},'actual_head_after':actual_head},
          'scope':'Original independent review stops at its first private read-tree before any staged boundary review/result publication. Exact used source and actual combined error retained; distinct original stdout/stderr unavailable. Separate actual minimal private Git recurrence derives config/revisions from exact original source, rejects missing HEAD with128, and passes after adding only historical BASE HEAD. Existing repository metadata and completed gate/semantic observations remain unchanged; corrected independent review remains required.'}
(ROOT/(PREFIX+'review-fixture-error.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'actual_missing_head_exit':before.returncode,'actual_initialized_head_exit':after.returncode}))
