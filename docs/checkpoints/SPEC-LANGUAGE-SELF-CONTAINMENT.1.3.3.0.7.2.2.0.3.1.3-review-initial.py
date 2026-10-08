"""Independently review source-bound accepted-state observations and input recovery."""
from pathlib import Path
import base64
import copy
import hashlib
import json
import os
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
REV = 'eb6d0d6ea7b88d13ebe669a507b3126d7508c0eb'
BASE = '47444428a8ceb65cb0ced06625db4eb8a44b8209'
ADR = 'docs/decisions/0128-replacement-note-history-capacity.md'
INITIAL = 'docs/decisions/0063-bounded-readme-landing-page.md'
INDEX = 'docs/decisions/INDEX.md'
POLICY = 'README_POLICY.md'
PRODUCTION = ['scripts/check_readme_stability.sh','scripts/check_readme_routing_pressure.pl']

def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return (ROOT/path).read_bytes()
def data(suffix): return json.loads(read(PREFIX+suffix))
def git(*args): return subprocess.check_output(['git',*args],cwd=ROOT)
def original(path,revision=REV): return git('show',revision+':'+path)
def channel(item):
    raw = base64.b64decode(item['base64'],validate=True)
    assert item == {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}, 'complete channel identity'
    return raw
def envelope(raw): return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}

# Independently recover every committed regular input, including all checker inputs.
graph = []
excluded = []
for row in git('ls-tree','-rlz',REV).split(b'\0'):
    if not row: continue
    metadata,path = row.split(b'\t',1)
    mode,kind,oid,size = metadata.decode().split()
    if kind == 'blob' and mode in ('100644','100755'):
        graph.append({'path':path.decode(),'mode':mode,'object_id':oid,'bytes':int(size)})
    else: excluded.append({'path':path.decode(),'mode':mode,'kind':kind,'payload_inspected':False})
assert excluded == [{'path':'rgx','mode':'160000','kind':'commit','payload_inspected':False}]
batch = subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
try:
    for entry in graph:
        batch.stdin.write((entry['object_id']+'\n').encode()); batch.stdin.flush()
        assert batch.stdout.readline().split() == [entry['object_id'].encode(),b'blob',str(entry['bytes']).encode()]
        raw = batch.stdout.read(entry['bytes'])
        assert len(raw) == entry['bytes'] and batch.stdout.read(1) == b'\n'
        entry['sha256'] = sha(raw)
finally:
    batch.stdin.close(); batch.stdout.close(); assert batch.wait() == 0

objects = Path(git('rev-parse','--git-path','objects').decode().strip())
if not objects.is_absolute(): objects = ROOT/objects
objects = objects.resolve()
scratch = ROOT/'.linkedspec-data/scratch/accepted-state-review'
scratch.mkdir(parents=True,exist_ok=True)
assert scratch.stat().st_dev == objects.stat().st_dev == ROOT.stat().st_dev
recovered_boundaries = {}

def recover_boundary(row,independent_caps):
    """Rebuild actual staged objects/diff in a private index without rerunning gates."""
    key = sha(json.dumps(row,sort_keys=True).encode())
    if key in recovered_boundaries: return recovered_boundaries[key]
    with tempfile.TemporaryDirectory(dir=scratch,prefix='index.') as temporary:
        tree = Path(temporary)
        metadata = tree/'.git'
        (metadata/'objects').mkdir(parents=True); (metadata/'refs').mkdir()
        (metadata/'config').write_text('[core]\n\trepositoryformatversion = 0\n\tbare = false\n\tfsmonitor = false\n')
        env = {k:v for k,v in os.environ.items() if not k.startswith('GIT_')}
        env.update(GIT_DIR=str(metadata),GIT_WORK_TREE=str(tree),GIT_INDEX_FILE=str(metadata/'index'),
                   GIT_OBJECT_DIRECTORY=str(metadata/'objects'),GIT_ALTERNATE_OBJECT_DIRECTORIES=str(objects),GIT_OPTIONAL_LOCKS='0')
        def run(*args,raw=None):
            result = subprocess.run(['git','-c','core.fsmonitor=false',*args],cwd=tree,env=env,input=raw,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            assert result.returncode == 0, 'private input recovery '+str(args)+': '+result.stderr.decode(errors='replace')
            return result.stdout
        run('read-tree',REV)
        if independent_caps:
            head = row['synthetic_head']
            run('update-index','--force-remove',ADR)
            tree_oid = run('write-tree').decode().strip()
            assert tree_oid == head['tree_object'], 'synthetic HEAD only removes declared ADR'
            commit_raw = channel(head['commit'])
            assert commit_raw.startswith(('tree '+tree_oid+'\nparent '+REV+'\n').encode()), 'synthetic HEAD exact parent/tree'
            oid = run('hash-object','-t','commit','-w','--stdin',raw=commit_raw).decode().strip()
            assert oid == head['commit_object']
            (metadata/'HEAD').write_text(oid+'\n')
            assert run('ls-tree','-rz',oid) == channel(head['tree_entries']), 'complete synthetic HEAD graph'
            assert head['regular_source'] == REV and head['removed_path'] == ADR
            run('read-tree',REV)
        else: (metadata/'HEAD').write_text(BASE+'\n')
        expected = {entry['path']:entry for entry in graph}
        for overlay in row['overlays']:
            raw = channel(overlay['content'])
            assert overlay['bytes'] == len(raw) and overlay['sha256'] == sha(raw) and overlay['mode'] == expected[overlay['path']]['mode'], 'original regular Git mode retained'
            oid = run('hash-object','-w','--stdin',raw=raw).decode().strip()
            assert oid == overlay['object_id'], 'recover exact overlay object'
            run('update-index','--cacheinfo',overlay['mode'],oid,overlay['path'])
            expected[overlay['path']] = overlay
        index = []
        for stage_row in run('ls-files','--stage','-z').split(b'\0'):
            if not stage_row: continue
            metadata_row,path = stage_row.split(b'\t',1)
            mode,oid,stage = metadata_row.decode().split()
            assert stage == '0'
            if mode not in ('100644','100755'): continue
            entry = expected[path.decode()]
            assert mode == entry['mode'] and oid == entry['object_id']
            index.append({'path':path.decode(),'mode':mode,'object_id':oid})
        assert len(index) == len(expected)
        boundary = {'head':run('rev-parse','HEAD').decode().strip(),
                    'staged_patch_sha256':sha(run('diff','--cached','--binary','--full-index')),
                    'regular_inputs':len(index),'worktree_inputs_checked':len(expected),
                    'index_graph_sha256':sha(json.dumps(index,sort_keys=True,separators=(',',':')).encode())}
        assert row['boundary_before'] == row['boundary_after'] == boundary, 'independent complete staged boundary recovery'
    recovered_boundaries[key] = boundary
    return boundary

def expected_adr(status,caps):
    body = original(ADR).decode()
    if caps:
        lines = body.splitlines(keepends=True)
        blanks = [i for i,line in enumerate(lines) if line == '\n']
        markers = ['- Previous README line cap: `128`','- New README line cap: `129`',
                   '- Previous README byte cap: `6144`','- New README byte cap: `6145`']
        for i,marker in zip(blanks[-4:],markers): lines[i] = marker+'\n'
        body = ''.join(lines)
    if status == 'proposed': body = re.sub(r'^- Status:.*$', '- Status: proposed; not accepted',body,count=1,flags=re.M)
    elif status == 'missing': body = re.sub(r'^- Status:.*\n', '',body,count=1,flags=re.M)
    return body.encode()

def check_full(report,independent_caps):
    epoch = report['epoch']
    assert report['complete'] is True and epoch in ('before','after')
    assert report['revision'] == REV and report['regular_input_graph'] == graph and report['excluded_metadata_only'] == excluded, 'complete reachable regular input graph'
    producer = 'readme-cap-capture.py' if independent_caps else ('resulting-tree-capture-before.py' if epoch == 'before' else 'resulting-tree-capture.py')
    assert report['producer_sha256'] == sha(read(PREFIX+producer)), 'actual full-gate producer'
    if independent_caps:
        helper = PREFIX+('resulting-tree-capture-before.py' if epoch == 'before' else 'resulting-tree-capture.py')
        assert report['helper_path'] == PREFIX+'resulting-tree-capture.py' and report['helper_sha256'] == sha(read(helper))
    else: assert report['fixture_head'] == BASE
    source = {path:original(path) if epoch == 'before' else read(path) for path in PRODUCTION}
    assert report['production_inputs'] == {path:sha(raw) for path,raw in source.items()}, 'actual supplied production bytes'
    scenarios = [None] if independent_caps else ['routed_controls','readme_caps']
    keys = [(scenario,status) for scenario in scenarios for status in ('accepted','proposed','missing')]
    assert [(row.get('scenario'),row['status']) for row in report['observations']] == keys, 'complete ordered full-gate population'
    for row in report['observations']:
        status = row['status']
        caps = independent_caps or row.get('scenario') == 'readme_caps'
        expected_overlays = {path:raw for path,raw in source.items() if raw != original(path)}
        expected_overlays[ADR] = expected_adr(status,caps)
        if caps: expected_overlays[POLICY] = original(POLICY).replace(b'- Machine line cap: `128`',b'- Machine line cap: `129`',1).replace(b'- Machine byte cap: `6144`',b'- Machine byte cap: `6145`',1)
        assert len(row['overlays']) == len(expected_overlays) and {o['path']:channel(o['content']) for o in row['overlays']} == expected_overlays, 'only exact declared overlays'
        assert row['args'] == ['bash','scripts/check_readme_stability.sh'], 'actual complete gate command'
        out,err = channel(row['stdout']),channel(row['stderr'])
        expected_exit = 0 if epoch == 'before' or status == 'accepted' else 1
        assert row['exit_code'] == expected_exit and row['expected_policy_exit'] == (0 if status == 'accepted' else 1), 'status-distinguishing full gate result'
        assert row['policy_result'] == ('GREEN' if row['exit_code'] == row['expected_policy_exit'] else 'RED')
        if expected_exit == 0: assert b'routing-pressure closure pass' in out and err == b'', 'complete positive gate channels'
        else:
            assert b'accepted' in err.lower() and b'exceeds control' not in err and b'freshness verifier failed' not in err and b'differs between staged result and worktree' not in err, 'status admission rather than independent pressure/freshness failure'
        if independent_caps:
            assert b'resulting-tree closure and pressure controls pass' in out, 'actual routing completed before cap branch'
            if expected_exit == 1: assert b'cap increase 128/6144 -> 129/6145 requires' in err and b'[readme-routing] FAIL' not in err, 'independent cap admission rejection'
        recover_boundary(row,independent_caps)

def check_components(report):
    epoch = report['epoch']
    assert report['complete'] is True and report['producer_sha256'] == sha(read(PREFIX+'component-probe.py'))
    assert report['input_hashes_before'] == report['input_hashes_after'], 'unchanged component input boundary'
    for path,digest in report['input_hashes_before'].items():
        raw = original(path) if epoch == 'before' and path in PRODUCTION else read(path)
        assert digest == sha(raw), 'actual component input '+path
    branches = ['routed_limits','routed_contract','initial_registry','new_readme_caps','initial_readme_caps']
    statuses = ['accepted_original','accepted_bare','proposed','missing','duplicate']
    assert [(row['branch'],row['status']) for row in report['observations']] == [(b,s) for b in branches for s in statuses], 'complete component population'
    drivers = {key:channel(value) for key,value in report['drivers'].items()}
    for row in report['observations']:
        driver = drivers['perl' if row['branch'] in branches[:3] else 'bash']
        assert row['driver_sha256'] == sha(driver) and row['fixture']['branch'] == row['branch'] and row['fixture']['status'] == row['status']
        body = original(INITIAL if row['branch'].startswith('initial_') else ADR).decode()
        status = row['status']
        if status == 'accepted_bare': body = re.sub(r'^- Status:.*$', '- Status: accepted',body,count=1,flags=re.M)
        elif status == 'proposed': body = re.sub(r'^- Status:.*$', '- Status: proposed; not accepted',body,count=1,flags=re.M)
        elif status == 'missing': body = re.sub(r'^- Status:.*\n', '',body,count=1,flags=re.M)
        elif status == 'duplicate': body += '\n- Status: proposed; ambiguous duplicate\n'
        if row['branch'] == 'initial_registry': body += '\nRouting-pressure fixture marker independent of the Status field.\n'
        if row['branch'] == 'new_readme_caps': body += ('\n- Previous README line cap: `128`\n- New README line cap: `129`\n'
                                                       '- Previous README byte cap: `6144`\n- New README byte cap: `6145`\n')
        fixture = {'branch':row['branch'],'status':status,'files':{ADR:body,INITIAL:body,INDEX:original(INDEX).decode()}}
        if row['branch'] in ('routed_limits','routed_contract'):
            plan = json.loads(read('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-capacity-plan.json'))
            suffix = 'limits' if row['branch'] == 'routed_limits' else 'contract'
            fixture.update(old=plan['old_'+suffix],new=plan['new_'+suffix])
        assert row['fixture'] == fixture, 'exact status-distinguishing component fixture'
        policy = row['status'].startswith('accepted_')
        actual = True if epoch == 'before' else policy
        out,err = channel(row['stdout']),channel(row['stderr'])
        parsed = json.loads(out)['authorized'] if row['branch'] in branches[:3] else out == b'1\n'
        assert row['exit_code'] == 0 and err == b'' and parsed == row['authorized'] == actual, 'actual branch status result'
        assert row['expected_policy_authorized'] == policy and row['policy_result'] == ('GREEN' if actual == policy else 'RED')
    # Reconstruct exact source function blocks independently of the capture producer.
    for language,path,names in [('perl',PRODUCTION[1],['adr_is_accepted','canonical_object','numeric_increase','limit_change_permitted','debt_retirement_permitted','adr_authorizes_limit_change','adr_authorizes_contract_change','validate_registry_governance']),('bash',PRODUCTION[0],['adr_has_accepted_status','new_adr_authorizes_caps','initial_adr_authorizes_caps'])]:
        source = (original(path) if epoch == 'before' else read(path)).decode()
        for name in names:
            pattern = r'^sub '+name+r' \{.*?(?=^sub |\Z)' if language == 'perl' else r'^'+name+r'\(\) \{\n.*?^\}\n'
            match = re.search(pattern,source,re.M|re.S)
            if match: assert match.group().encode() in drivers[language], 'complete actual source function '+name
            else: assert epoch == 'before' and name in ('adr_is_accepted','adr_has_accepted_status')
    return drivers

reports = {epoch:{'components':data(epoch+'-components.json'),
                  'full':data(epoch+'-resulting-tree.json'),
                  'caps':data(epoch+'-readme-caps.json')} for epoch in ('before','after')}
for epoch,group in reports.items():
    check_components(group['components']); check_full(group['full'],False); check_full(group['caps'],True)

# Preserve original claims exactly; the activation report is an observation, not a replay.
activation = data('activation.json')
assert activation['complete'] is True and activation['revision'] == REV and activation['producer_sha256'] == sha(read(PREFIX+'activate.py'))
frozen_inputs = 0
for record in activation['records']:
    old_raw = original(record['path'])
    old = json.loads(old_raw)
    current = json.loads(read(record['path']))
    expected = copy.deepcopy(old)
    for claim in expected['claims']:
        claim['durability']['mode'] = 'historical'
        claim['durability']['revision'] = record['revision']
    assert current == expected and sha(old_raw) == record['original_sha256'] and sha(read(record['path'])) == record['frozen_sha256'], 'only historical mode/revision changed'
    count = 0
    for old_claim,new_claim in zip(old['claims'],current['claims']):
        assert new_claim['durability']['mode'] == 'historical' and new_claim['durability']['revision'] == record['revision']
        for item in old_claim['durability']['inputs']:
            assert sha(original(item['path'],record['revision'])) == item['sha256'], 'original historical input '+item['path']
            count += 1
    assert count == record['inputs_checked']
    frozen_inputs += count

error = data('fixture-error.json')
assert error['complete'] is True and error['producer_sha256'] == sha(read(PREFIX+'fixture-error-review.py'))
initial_raw = read(PREFIX+'resulting-tree-capture-initial.py')
assert error['original_source_sha256'] == sha(initial_raw) and error['initial_exit_code'] == 1
assert b'AssertionError: no tracked stage/worktree split' in channel(error['initial_combined_log'])
delta = (b"    for entry in excluded:\n        if entry['mode'] == '160000':\n            (tree/entry['path']).mkdir(parents=True,exist_ok=True)\n")
before_helper = read(PREFIX+'resulting-tree-capture-before.py')
assert before_helper.replace(delta,b'',1) == initial_raw, 'only empty gitlink placeholder repair'
diff = channel(error['recurrence']['before_diff'])
assert diff.count(b'diff --git ') == 1 and diff.startswith(b'diff --git a/rgx b/rgx\ndeleted file mode 160000\n') and channel(error['recurrence']['after_diff']) == b''
assert error['recurrence']['regular_inputs'] == len(graph)

mode_error = data('overlay-mode-error.json')
assert mode_error['complete'] is True and mode_error['producer_sha256'] == sha(read(PREFIX+'overlay-mode-review.py')) and mode_error['original_source_sha256'] == sha(before_helper)
assert len(mode_error['errors']) == 2
for observation in mode_error['errors']:
    assert observation['exit_code'] == 1 and b'AssertionError: complete regular worktree identity scripts/check_readme_routing_pressure.pl' in channel(observation['combined_channel'])
    source = before_helper if observation['producer_path'] == PREFIX+'resulting-tree-capture.py' else read(PREFIX+'readme-cap-capture.py')
    assert observation['producer_sha256'] == sha(source), 'exact failed overlay producer'
assert {row['path'] for row in mode_error['observed_modes']} == set(PRODUCTION)
assert all(row['original_git_mode'] == '100755' and row['actual_filesystem_permissions'] == '0o755' and row['overlay_index_mode'] == '100644' and row['bytes_exact'] is True for row in mode_error['observed_modes'])
mode_diff = channel(mode_error['recurrence']['before_diff'])
assert mode_diff.count(b'diff --git ') == 2 and mode_diff.count(b'old mode 100644\nnew mode 100755\n') == 2 and channel(mode_error['recurrence']['after_diff']) == b''
corrected_helper = before_helper.replace(b"    oid = git_fixture(tree,env,'hash-object','-w','--stdin',input_bytes=raw).decode().strip()\n",
                                       b"    mode = next(entry['mode'] for entry in entries if entry['path'] == path)\n    oid = git_fixture(tree,env,'hash-object','-w','--stdin',input_bytes=raw).decode().strip()\n",1)
corrected_helper = corrected_helper.replace(b"'--cacheinfo','100644',oid,path",b"'--cacheinfo',mode,oid,path",1).replace(b"{'path':path,'mode':'100644','bytes':len(raw)",b"{'path':path,'mode':mode,'bytes':len(raw)",1)
assert read(PREFIX+'resulting-tree-capture.py') == corrected_helper, 'only original overlay mode preservation correction'

semantic = data('semantic-controls.json')
assert semantic['complete'] is True and semantic['producer_sha256'] == sha(read(PREFIX+'semantic-controls.py'))
assert semantic['input_hashes_before'] == semantic['input_hashes_after']
for path,digest in semantic['input_hashes_before'].items(): assert sha(read(path)) == digest, 'actual semantic control input '+path
base_drivers = {epoch:{language:channel(item) for language,item in group['components']['drivers'].items()} for epoch,group in reports.items()}

def recur_semantic_row(row):
    driver = channel(row['driver'])
    fixture = row['fixture']
    perl = row['branch'] in ('routed_limits','routed_contract','initial_registry')
    if perl:
        process = subprocess.run(['perl','-e',driver.decode()],cwd=ROOT,input=json.dumps(fixture).encode(),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        answer = json.loads(process.stdout)['authorized'] if process.returncode == 0 else None
    else:
        env = dict(os.environ)
        env.update(ACCEPTED_STATE_BODY=fixture['files'][ADR],ACCEPTED_STATE_INDEX=fixture['files'][INDEX],ACCEPTED_STATE_BRANCH=fixture['branch'])
        process = subprocess.run(['bash','-c',driver.decode()],cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        assert process.stdout in (b'0\n',b'1\n')
        answer = process.stdout == b'1\n'
    assert process.returncode == row['exit_code'] == 0 and process.stdout == channel(row['stdout']) and process.stderr == channel(row['stderr']) == b'' and answer == row['authorized'], 'actual semantic command recurrence'

recurrence_keys = [(epoch,row['branch'],row['status']) for epoch in ('before','after') for row in reports[epoch]['components']['observations']]
assert [(row['epoch'],row['branch'],row['status']) for row in semantic['recurrence']] == recurrence_keys
for row in semantic['recurrence']:
    observed = next(item for item in reports[row['epoch']]['components']['observations'] if item['branch'] == row['branch'] and item['status'] == row['status'])
    language = 'perl' if row['branch'] in ('routed_limits','routed_contract','initial_registry') else 'bash'
    assert channel(row['driver']) == base_drivers[row['epoch']][language] and row['fixture'] == observed['fixture'] and row['authorized'] == observed['authorized'], 'exact original/current driver recurrence'
    recur_semantic_row(row)
supplemental_keys = [(epoch,row['branch'],status) for epoch in ('before','after') for row in reports[epoch]['components']['observations'] if row['status'] == 'accepted_bare' for status in ('duplicate_accepted','duplicate_reverse','malformed_token')]
assert [(row['epoch'],row['branch'],row['status']) for row in semantic['supplemental_status_oracles']] == supplemental_keys
for row in semantic['supplemental_status_oracles']:
    observed = next(item for item in reports[row['epoch']]['components']['observations'] if item['branch'] == row['branch'] and item['status'] == 'accepted_bare')
    fixture = copy.deepcopy(observed['fixture'])
    body = fixture['files'][ADR]
    if row['status'] == 'duplicate_accepted': body += '\n- Status: accepted\n'
    elif row['status'] == 'duplicate_reverse': body = '- Status: proposed\n'+body
    else: body = body.replace('- Status: accepted','- Status: acceptedish',1)
    fixture['files'][ADR] = fixture['files'][INITIAL] = body
    language = 'perl' if row['branch'] in ('routed_limits','routed_contract','initial_registry') else 'bash'
    assert row['fixture'] == fixture and channel(row['driver']) == base_drivers[row['epoch']][language] and row['authorized'] == (row['epoch'] == 'before'), 'independent duplicate/token policy oracle'
    recur_semantic_row(row)
assert len(semantic['effective_source_inverse_mutants']) == 9 and len({row['name'] for row in semantic['effective_source_inverse_mutants']}) == 9
inverse_changes = {
    'omit_routed_limits_guard':('adr_authorizes_limit_change','adr_is_accepted($body)\n            && ',''),
    'omit_routed_contract_guard':('adr_authorizes_contract_change','adr_is_accepted($body)\n            && ',''),
    'omit_initial_registry_guard':('validate_registry_governance','!adr_is_accepted($adr) || ',''),
    'omit_new_readme_caps_guard':('new_adr_authorizes_caps','adr_has_accepted_status "$body" &&\n       ',''),
    'omit_initial_readme_caps_guard':('initial_adr_authorizes_caps','adr_has_accepted_status "$body" &&\n    ',''),
    'perl_duplicate_accepted_bypass':('adr_is_accepted','return @statuses == 1','return @statuses >= 1'),
    'bash_duplicate_accepted_bypass':('adr_has_accepted_status','"$count" -eq 1','"$count" -ge 1'),
    'perl_malformed_token_bypass':('adr_is_accepted','accepted(?:[ \\t;]|\\z)','accepted'),
    'bash_malformed_token_bypass':('adr_has_accepted_status','accepted([[:blank:];]|$)','accepted'),
}
assert {row['name'] for row in semantic['effective_source_inverse_mutants']} == set(inverse_changes), 'exact source inverse population'
for row in semantic['effective_source_inverse_mutants']:
    language = 'perl' if row['branch'] in ('routed_limits','routed_contract','initial_registry') else 'bash'
    name,old,new = inverse_changes[row['name']]
    driver = base_drivers['after'][language].decode()
    pattern = r'^sub '+name+r' \{.*?(?=^sub |\Z)' if language == 'perl' else r'^'+name+r'\(\) \{\n.*?^\}\n'
    block = re.search(pattern,driver,re.M|re.S).group()
    assert block.count(old) == 1 and channel(row['driver']) == driver.replace(block,block.replace(old,new,1),1).encode(), 'only declared actual function inverse'
    assert channel(row['driver']) != base_drivers['after'][language] and row['authorized'] is True and row['observed_policy'] == 'RED', 'effective source mutation escapes independent negative oracle'
    assert row['fixture']['files'][INDEX] != '' and re.search(r'^- Status:',row['fixture']['files'][ADR],re.M), 'source mutation preserves indexed status fixture'
    recur_semantic_row(row)
assert len(semantic['independent_authority_denials']) == 10
assert {row['name'] for row in semantic['independent_authority_denials']} == {branch+'/'+control for branch in ('routed_limits','routed_contract','initial_registry','new_readme_caps','initial_readme_caps') for control in ('missing_index','missing_exact_marker')}
for row in semantic['independent_authority_denials']:
    language = 'perl' if row['branch'] in ('routed_limits','routed_contract','initial_registry') else 'bash'
    original_fixture = next(item['fixture'] for item in reports['after']['components']['observations'] if item['branch'] == row['branch'] and item['status'] == 'accepted_original')
    expected_fixture = copy.deepcopy(original_fixture)
    if row['name'].endswith('/missing_index'): expected_fixture['files'][INDEX] = ''
    else:
        body = expected_fixture['files'][ADR]
        if row['branch'] == 'initial_registry': body = re.sub('routing-pressure|routed-destination','navigation',body,flags=re.I)
        else:
            marker = {'routed_limits':'Previous routed limits','routed_contract':'Previous routed contract','new_readme_caps':'Previous README line cap','initial_readme_caps':'Previous README line cap'}[row['branch']]
            body = re.sub(r'^- '+marker+r':.*\n','',body,flags=re.M)
        expected_fixture['files'][ADR] = expected_fixture['files'][INITIAL] = body
    assert row['fixture'] == expected_fixture, 'only independent index or exact marker removed'
    assert channel(row['driver']) == base_drivers['after'][language] and row['authorized'] is False and row['observed_rejection'] is True
    recur_semantic_row(row)
assert len(semantic['pressure_boundaries']) == 21
pressure_driver = channel(semantic['pressure_driver'])
match = re.search(r'^sub exceeds_limits \{.*?(?=^sub |\Z)',read(PRODUCTION[1]).decode(),re.M|re.S)
assert match and match.group().encode() in pressure_driver
assert {(row['key'],row['limit']) for row in semantic['pressure_boundaries']} == {(key,limit) for key in ('max_lines','max_bytes','max_files','max_total_lines','max_total_bytes','max_lines_per_file','max_bytes_per_file') for limit in (9,10,11)}
for row in semantic['pressure_boundaries']:
    assert row['fixture'] == {'metrics':{'files':10,'lines':10,'bytes':10,'members':['fixture'],'per_file':{'fixture':{'lines':10,'bytes':10}}},'limits':{row['key']:row['limit']}}, 'exact independent pressure population'
    process = subprocess.run(['perl','-e',pressure_driver.decode()],cwd=ROOT,input=json.dumps(row['fixture']).encode(),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    assert process.returncode == row['exit_code'] == 0 and process.stdout == channel(row['stdout']) and process.stderr == channel(row['stderr']) == b''
    assert json.loads(process.stdout) == row['violations'] and bool(row['violations']) == (row['limit'] == 9), 'independent exact/under/overflow metric predicate'

controls = []
def evidence_red(name,action):
    try: action()
    except (AssertionError,KeyError,ValueError) as failure:
        controls.append({'name':name,'observed_red':str(failure)}); return
    raise AssertionError('ineffective evidence control '+name)

def corrupt_full(name,change,caps=False):
    fixture = copy.deepcopy(reports['after']['caps' if caps else 'full'])
    change(fixture)
    evidence_red(name,lambda:check_full(fixture,caps))
corrupt_full('missing_input',lambda x:x['regular_input_graph'].pop())
corrupt_full('wrong_source_producer',lambda x:x.update(producer_sha256='0'*64))
corrupt_full('forged_status_success',lambda x:x['observations'][1].update(exit_code=0))
corrupt_full('lost_independent_cap_leg',lambda x:x['observations'].pop(),True)
corrupt_full('forged_status_error',lambda x:x['observations'][1].update(stderr=envelope(b'unrelated error\n')))
corrupt_full('lost_input_boundary',lambda x:x['observations'][0]['boundary_after'].update(regular_inputs=0))
component = copy.deepcopy(reports['after']['components']); component['observations'].pop()
evidence_red('missing_authority_branch',lambda:check_components(component))

result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),
          'regular_inputs':len(graph),'frozen_original_inputs':frozen_inputs,
          'component_observations_each_epoch':len(reports['after']['components']['observations']),
          'complete_full_gate_observations_each_epoch':len(reports['after']['full']['observations'])+len(reports['after']['caps']['observations']),
          'effective_source_inverse_mutants':len(semantic['effective_source_inverse_mutants']),
          'independent_authority_denials':len(semantic['independent_authority_denials']),
          'pressure_boundaries':len(semantic['pressure_boundaries']),
          'recovered_complete_boundaries':len(recovered_boundaries),'evidence_red_controls':controls,
          'scope':'Independent complete reachable Git regular graph and declared overlay recovery, actual private-index object/full staged diff reconstruction, before/after source and command/channel identity, status-specific full-gate and five-branch observations, original claim mode/revision-only preservation and instrument-error provenance. Captured gates establish behavior; this review does not rerun them. Original error distinct channels/diff unavailable; separate actual recurrence is retained. No global doctrine bypass, runtime repair, historical synthetic-HEAD admission or submodule payload assertion.'}
(ROOT/(PREFIX+'verification.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
