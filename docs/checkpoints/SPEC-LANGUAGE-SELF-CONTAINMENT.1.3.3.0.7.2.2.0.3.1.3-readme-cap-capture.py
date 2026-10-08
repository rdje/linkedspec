"""Distinguish actual README-cap status admission after routed controls are unchanged."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
HELPER = PREFIX+'resulting-tree-capture.py'
helper_raw = (ROOT/HELPER).read_bytes()
# Execute the retained materialization/identity helpers, never its observation loop.
helper_prefix = helper_raw.decode().split('\nbase_adr = original(ADR).decode()\n',1)
assert len(helper_prefix) == 2, 'exact retained helper boundary'
exec(compile(helper_prefix[0],HELPER,'exec'),globals())
helper_hash = sha(helper_raw)
base_adr = original(ADR).decode()
base_policy = original(POLICY).decode()
caps = ['- Previous README line cap: `128`','- New README line cap: `129`',
        '- Previous README byte cap: `6144`','- New README byte cap: `6145`']
observations = []
for status in ('accepted','proposed','missing'):
    with tempfile.TemporaryDirectory(prefix='caps.'+epoch+'.',dir=scratch) as temporary:
        tree = Path(temporary)
        assert tree.stat().st_dev == ROOT.stat().st_dev
        env = materialize(tree)
        env.update(GIT_AUTHOR_NAME='LinkedSpec admission fixture',
                   GIT_AUTHOR_EMAIL='fixture@linkedspec.invalid',
                   GIT_COMMITTER_NAME='LinkedSpec admission fixture',
                   GIT_COMMITTER_EMAIL='fixture@linkedspec.invalid',
                   GIT_AUTHOR_DATE='2000-01-01T00:00:00+0000',
                   GIT_COMMITTER_DATE='2000-01-01T00:00:00+0000')
        git_fixture(tree,env,'update-index','--force-remove',ADR)
        tree_oid = git_fixture(tree,env,'write-tree').decode().strip()
        commit_oid = git_fixture(tree,env,'commit-tree',tree_oid,'-p',REVISION,
                                 '-m','Synthetic README-cap fixture: eb6 minus only ADR0128').decode().strip()
        (tree/'.git/HEAD').write_text(commit_oid+'\n')
        commit_raw = git_fixture(tree,env,'cat-file','commit',commit_oid)
        head_entries = git_fixture(tree,env,'ls-tree','-rz',commit_oid)
        expected_entries = git_original('ls-tree','-rz',REVISION)
        expected_rows = [row for row in expected_entries.split(b'\0')
                         if row and row.split(b'\t',1)[1].decode() != ADR]
        assert head_entries == b'\0'.join(expected_rows)+b'\0', 'synthetic HEAD differs only by absent ADR0128'
        assert git_fixture(tree,env,'show','HEAD:doctrine/readme_stability/routes.jsonl') == original('doctrine/readme_stability/routes.jsonl'), 'all routed controls unchanged'
        git_fixture(tree,env,'read-tree',REVISION)
        overlays = []
        for path,raw in current_production.items():
            if raw != original(path): overlays.append(install_overlay(tree,env,path,raw))
        lines = base_adr.splitlines(keepends=True)
        blanks = [i for i,line in enumerate(lines) if line == '\n']
        assert len(blanks) >= len(caps)
        for i,marker in zip(blanks[-len(caps):],caps): lines[i] = marker+'\n'
        body = ''.join(lines)
        if status == 'proposed': body = re.sub(r'^- Status:.*$', '- Status: proposed; not accepted',body,count=1,flags=re.M)
        elif status == 'missing': body = re.sub(r'^- Status:.*\n', '',body,count=1,flags=re.M)
        policy = base_policy.replace('- Machine line cap: `128`','- Machine line cap: `129`',1).replace('- Machine byte cap: `6144`','- Machine byte cap: `6145`',1)
        assert policy != base_policy and body.count('\n') <= base_adr.count('\n')
        overlays.append(install_overlay(tree,env,POLICY,policy.encode()))
        overlays.append(install_overlay(tree,env,ADR,body.encode()))
        assert git_fixture(tree,env,'diff','--cached','--name-only','--diff-filter=A','--','docs/decisions').decode().splitlines() == [ADR], 'actual newly added decision'
        before = fingerprint(tree,env,overlays)
        args = ['bash','scripts/check_readme_stability.sh']
        process = subprocess.run(args,cwd=tree,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        after = fingerprint(tree,env,overlays)
        observations.append({'status':status,'args':args,'overlays':overlays,
                             'synthetic_head':{'tree_object':tree_oid,'commit_object':commit_oid,
                                               'commit':envelope(commit_raw),'regular_source':REVISION,
                                               'removed_path':ADR,'tree_entries':envelope(head_entries)},
                             'exit_code':process.returncode,'stdout':envelope(process.stdout),'stderr':envelope(process.stderr),
                             'boundary_before':before,'boundary_after':after,
                             'expected_policy_exit':0 if status == 'accepted' else 1,
                             'policy_result':'GREEN' if process.returncode == (0 if status == 'accepted' else 1) else 'RED'})
        result = {'complete':False,'epoch':epoch,'revision':REVISION,
                  'producer_sha256':producer_hash,'helper_path':HELPER,'helper_sha256':helper_hash,
                  'regular_input_graph':entries,'excluded_metadata_only':excluded,
                  'production_inputs':{path:sha(raw) for path,raw in current_production.items()},
                  'observations':observations,
                  'scope':'Complete reachable eb6 regular Git superset and declared overlays. Private project-local synthetic HEAD is exact eb6 tree minus only ADR0128, parent eb6; current routed controls remain identical. Restored actual index makes only ADR0128 newly added, so actual README-cap governance is reached independently of routed increases. No historical admission, global doctrine bypass, submodule payload access, or existing repository mutation is asserted. All regular filesystem/index identities and complete staged/worktree agreement are checked before/after; supplied inputs and actual channels are retained.'}
        (ROOT/(PREFIX+epoch+'-readme-caps.json')).write_text(json.dumps(result,indent=2)+'\n')
        assert before == after and before['head'] == commit_oid
        assert b'resulting-tree closure and pressure controls pass' in process.stdout, 'actual routed gate passes before cap branch'
        expected = 0 if epoch == 'before' or status == 'accepted' else 1
        assert process.returncode == expected, 'actual complete independent cap result '+status
        if expected == 0:
            assert b'routing-pressure closure pass' in process.stdout and process.stderr == b''
        else:
            assert b'cap increase 128/6144 -> 129/6145 requires' in process.stderr and b'accepted' in process.stderr.lower(), 'cap-specific status rejection'
            assert b'[readme-routing] FAIL' not in process.stderr and b'freshness verifier failed' not in process.stderr, 'routing does not explain cap RED'
        print('independent_readme_caps',status,process.returncode,flush=True)

assert producer_hash == sha(Path(__file__).read_bytes()) and helper_hash == sha((ROOT/HELPER).read_bytes())
assert current_production == {path:(ROOT/path).read_bytes() for path in PRODUCTION}
result['complete'] = True
(ROOT/(PREFIX+epoch+'-readme-caps.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'epoch':epoch,'regular_inputs':len(entries),'full_gate_observations':len(observations),
                  'policy_red':sum(row['policy_result']=='RED' for row in observations)}))
