"""Run the complete README gate against generated LinkedSpec-owned Git-state fixtures."""
from pathlib import Path
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
REVISION = 'eb6d0d6ea7b88d13ebe669a507b3126d7508c0eb'
BASE = '47444428a8ceb65cb0ced06625db4eb8a44b8209'
ADR = 'docs/decisions/0128-replacement-note-history-capacity.md'
POLICY = 'README_POLICY.md'
PRODUCTION = ['scripts/check_readme_stability.sh','scripts/check_readme_routing_pressure.pl']
epoch = sys.argv[1] if len(sys.argv) == 2 else None
assert epoch in ('before','after'), 'usage: resulting-tree-capture.py before|after'

def sha(raw): return hashlib.sha256(raw).hexdigest()
def envelope(raw): return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}
def original(path): return subprocess.check_output(['git','show',REVISION+':'+path],cwd=ROOT)
def git_original(*args): return subprocess.check_output(['git',*args],cwd=ROOT)

scratch = ROOT/'.linkedspec-data/scratch/accepted-state-admission'
scratch.mkdir(parents=True,exist_ok=True)
assert scratch.stat().st_dev == ROOT.stat().st_dev
objects = Path(git_original('rev-parse','--git-path','objects').decode().strip())
if not objects.is_absolute(): objects = ROOT/objects
objects = objects.resolve()
assert objects.stat().st_dev == ROOT.stat().st_dev

entries,excluded = [],[]
for row in git_original('ls-tree','-rlz',REVISION).split(b'\0'):
    if not row: continue
    metadata,path = row.split(b'\t',1)
    mode,kind,oid,size = metadata.decode().split()
    if mode not in ('100644','100755') or kind != 'blob':
        excluded.append({'path':path.decode(),'mode':mode,'kind':kind,'payload_inspected':False})
    else:
        entries.append({'path':path.decode(),'mode':mode,'object_id':oid,'bytes':int(size)})
assert {row['path'] for row in excluded} == {'rgx'}, 'only existing gitlink metadata excluded'
current_production = {path:(ROOT/path).read_bytes() for path in PRODUCTION}
if epoch == 'before':
    assert all(raw == original(path) for path,raw in current_production.items()), 'unchanged committed production before repair'
producer_hash = sha(Path(__file__).read_bytes())

def environment(tree):
    reset = {'TMPDIR','TMP','TEMP','CARGO_HOME','CARGO_TARGET_DIR','PUB_CACHE',
             'JULIA_DEPOT_PATH','PYTHONPYCACHEPREFIX','MDBOOK_BUILD__BUILD_DIR',
             'BASH_ENV','PERL5LIB','PERL5OPT'}
    result = {k:v for k,v in os.environ.items() if k not in reset and not k.startswith(('LINKEDSPEC_','GIT_'))}
    result.update(GIT_DIR=str(tree/'.git'),GIT_WORK_TREE=str(tree),
                  GIT_INDEX_FILE=str(tree/'.git/index'),GIT_OBJECT_DIRECTORY=str(tree/'.git/objects'),
                  GIT_ALTERNATE_OBJECT_DIRECTORIES=str(objects),GIT_OPTIONAL_LOCKS='0')
    return result

def git_fixture(tree,env,*args,input_bytes=None):
    process = subprocess.run(['git','-c','core.fsmonitor=false',*args],cwd=tree,env=env,
                             input=input_bytes,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    assert process.returncode == 0, 'actual generated Git-state command '+str(args)+': '+process.stderr.decode(errors='replace')
    return process.stdout

def materialize(tree):
    # Regular committed inputs only; no submodule payload or another repository write.
    process = subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['object_id']+'\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [entry['object_id'].encode(),b'blob',str(entry['bytes']).encode()]
            raw = process.stdout.read(entry['bytes'])
            assert len(raw) == entry['bytes'] and process.stdout.read(1) == b'\n'
            entry.setdefault('sha256',sha(raw)); assert entry['sha256'] == sha(raw)
            target = tree/entry['path']; target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(raw); target.chmod(int(entry['mode'][-3:],8))
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    for entry in excluded:
        if entry['mode'] == '160000':
            (tree/entry['path']).mkdir(parents=True,exist_ok=True)
    metadata = tree/'.git'
    (metadata/'objects').mkdir(parents=True); (metadata/'refs').mkdir()
    (metadata/'HEAD').write_text(BASE+'\n')
    (metadata/'config').write_text('[core]\n\trepositoryformatversion = 0\n\tbare = false\n\tfilemode = true\n\tfsmonitor = false\n')
    env = environment(tree)
    git_fixture(tree,env,'read-tree',REVISION)
    assert git_fixture(tree,env,'rev-parse','HEAD').decode().strip() == BASE
    return env

def install_overlay(tree,env,path,raw):
    (tree/path).write_bytes(raw)
    mode = next(entry['mode'] for entry in entries if entry['path'] == path)
    oid = git_fixture(tree,env,'hash-object','-w','--stdin',input_bytes=raw).decode().strip()
    git_fixture(tree,env,'update-index','--cacheinfo',mode,oid,path)
    return {'path':path,'mode':mode,'bytes':len(raw),'sha256':sha(raw),'object_id':oid,'content':envelope(raw)}

def fingerprint(tree,env,overlays):
    expected = {entry['path']:entry for entry in entries}
    expected.update({entry['path']:entry for entry in overlays})
    for path,entry in expected.items():
        target = tree/path
        assert target.is_file() and not target.is_symlink()
        assert sha(target.read_bytes()) == entry['sha256'] and target.stat().st_mode & 0o777 == int(entry['mode'][-3:],8), 'complete regular worktree identity '+path
    index = []
    for row in git_fixture(tree,env,'ls-files','--stage','-z').split(b'\0'):
        if not row: continue
        metadata,path = row.split(b'\t',1); mode,oid,stage = metadata.decode().split()
        assert stage == '0'
        if mode not in ('100644','100755'): continue
        entry = expected[path.decode()]
        assert mode == entry['mode'] and oid == entry['object_id'], 'complete regular index identity '+path.decode()
        index.append({'path':path.decode(),'mode':mode,'object_id':oid})
    assert len(index) == len(expected), 'complete regular staged membership'
    assert git_fixture(tree,env,'diff','--binary') == b'', 'no tracked stage/worktree split'
    assert git_fixture(tree,env,'ls-files','--others','--exclude-standard') == b'', 'no untracked non-ignored fixture input'
    patch = git_fixture(tree,env,'diff','--cached','--binary','--full-index')
    return {'head':git_fixture(tree,env,'rev-parse','HEAD').decode().strip(),
            'staged_patch_sha256':sha(patch),'regular_inputs':len(index),
            'index_graph_sha256':sha(json.dumps(index,sort_keys=True,separators=(',',':')).encode()),
            'worktree_inputs_checked':len(expected)}

base_adr = original(ADR).decode()
base_policy = original(POLICY).decode()
caps = ['- Previous README line cap: `128`','- New README line cap: `129`',
        '- Previous README byte cap: `6144`','- New README byte cap: `6145`']
observations = []
report_path = ROOT/(PREFIX+epoch+'-resulting-tree.json')
for scenario in ('routed_controls','readme_caps'):
    for status in ('accepted','proposed','missing'):
        with tempfile.TemporaryDirectory(prefix=epoch+'.',dir=scratch) as temporary:
            tree = Path(temporary); assert tree.stat().st_dev == ROOT.stat().st_dev
            env = materialize(tree); overlays = []
            for path,raw in current_production.items():
                if raw != original(path): overlays.append(install_overlay(tree,env,path,raw))
            body = base_adr
            if scenario == 'readme_caps':
                lines = body.splitlines(keepends=True)
                blanks = [i for i,line in enumerate(lines) if line == '\n']
                assert len(blanks) >= len(caps)
                for i,marker in zip(blanks[-len(caps):],caps): lines[i] = marker+'\n'
                body = ''.join(lines)
                policy = base_policy.replace('- Machine line cap: `128`','- Machine line cap: `129`',1).replace('- Machine byte cap: `6144`','- Machine byte cap: `6145`',1)
                assert policy != base_policy
                overlays.append(install_overlay(tree,env,POLICY,policy.encode()))
            if status == 'proposed': body = re.sub(r'^- Status:.*$', '- Status: proposed; not accepted',body,count=1,flags=re.M)
            elif status == 'missing': body = re.sub(r'^- Status:.*\n', '',body,count=1,flags=re.M)
            overlays.append(install_overlay(tree,env,ADR,body.encode()))
            assert body.count('\n') <= base_adr.count('\n'), 'status/cap fixture never adds aggregate decision pressure'
            before = fingerprint(tree,env,overlays)
            args = ['bash','scripts/check_readme_stability.sh']
            process = subprocess.run(args,cwd=tree,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            after = fingerprint(tree,env,overlays)
            observation = {'scenario':scenario,'status':status,'args':args,'overlays':overlays,
                           'exit_code':process.returncode,'stdout':envelope(process.stdout),'stderr':envelope(process.stderr),
                           'boundary_before':before,'boundary_after':after,
                           'expected_policy_exit':0 if status == 'accepted' else 1,
                           'policy_result':'GREEN' if process.returncode == (0 if status == 'accepted' else 1) else 'RED'}
            observations.append(observation)
            result = {'complete':False,'epoch':epoch,'revision':REVISION,'fixture_head':BASE,
                      'producer_sha256':producer_hash,'original_objects_read_only':True,
                      'regular_input_graph':entries,'excluded_metadata_only':excluded,
                      'production_inputs':{path:sha(raw) for path,raw in current_production.items()},'observations':observations,
                      'scope':'Complete original regular Git superset from reachable capacity commit; actual detached historical HEAD, private project-local index/objects and complete unchanged production README gate. Explicit source/policy/ADR overlays recover all supplied input bytes; gitlinks/nonregular payload excluded without inspection. Generated Git-state data is owned by LinkedSpec, collocated and removed after capture; existing repositories/refs/index/objects remain unchanged. Every regular working/index identity and staged/worktree agreement is checked before/after. Status failures are distinguished from pressure/freshness failures; no global doctrine or claim-identity bypass assertion.'}
            report_path.write_text(json.dumps(result,indent=2)+'\n')
            assert before == after, 'complete actual fixture inputs unchanged during gate'
            expected = 0 if epoch == 'before' or status == 'accepted' else 1
            assert process.returncode == expected, 'unexpected complete resulting-tree behavior '+scenario+'/'+status
            if expected == 0:
                assert b'routing-pressure closure pass' in process.stdout and process.stderr == b'', 'full positive route and cap completion'
            else:
                assert b'accepted' in process.stderr.lower(), 'status-specific admission rejection'
                assert b'exceeds control' not in process.stderr and b'freshness verifier failed' not in process.stderr and b'differs between staged result and worktree' not in process.stderr, 'independent defenses do not explain status RED'
            print(scenario,status,process.returncode,flush=True)

assert producer_hash == sha(Path(__file__).read_bytes())
assert current_production == {path:(ROOT/path).read_bytes() for path in PRODUCTION}, 'actual supplied production unchanged throughout epoch'
result['complete'] = True
report_path.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'epoch':epoch,'regular_inputs':len(entries),'full_gate_observations':len(observations),
                  'policy_red':sum(row['policy_result']=='RED' for row in observations)}))
