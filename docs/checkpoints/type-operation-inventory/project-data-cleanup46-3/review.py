"""Read-only dated proof review. Never replay historical disposal or test writers."""
from pathlib import Path
import base64,gzip,hashlib,importlib.util,json,os,subprocess,tempfile
R=Path(__file__).resolve().parents[4];P=Path(__file__).parent;prefix='.linkedspec-data/verification/project-data-cleanup46-3/'
sha=lambda b:hashlib.sha256(b).hexdigest()
record=json.loads(gzip.decompress((P/'intake.json.gz').read_bytes()));rows={v['path']:v for v in record['inputs']};assert len(rows)==len(record['inputs'])
def decode(row):
    path=Path(row['path']);assert not path.is_absolute() and '..' not in path.parts
    raw=base64.b64decode(row['base64'],validate=True);assert len(raw)==row['bytes'] and sha(raw)==row['sha256'];return raw
for row in rows.values():decode(row)
for path in P.glob('*.py'):assert sha(path.read_bytes())==rows[path.relative_to(R).as_posix()]['sha256']
def captured(name):return decode(rows[prefix+name])
def value(name):return json.loads(captured(name))
epoch=json.loads(gzip.decompress(captured('producer-epoch.json.gz')))
for row in epoch['inputs']:
    raw=decode(row)
    if row['path'] in rows:assert sha(raw)==rows[row['path']]['sha256']
def assemble(name,target):
    entry=record['large'][name];digest=hashlib.sha256();size=0
    with target.open('xb') as out:
        for part in entry['parts']:
            path=Path(part['path']);assert not path.is_absolute() and '..' not in path.parts
            path=R/path;assert path.is_file() and not path.is_symlink();raw=path.read_bytes()
            assert len(raw)==part['bytes'] and sha(raw)==part['sha256'];out.write(raw);digest.update(raw);size+=len(raw)
    assert size==entry['bytes'] and digest.hexdigest()==entry['sha256']
plan=value('plan.json');disposal=value('disposal.json');review=value('source-review.json');build=value('current-build.json');controls=value('guard-controls.json')
assert review['directory_epochs_stable'] and len(review['reconciliation_controls'])==5 and all(v['refused'] for v in review['reconciliation_controls'])
post_raw=captured('retained-entries.jsonl.gz');assert sha(post_raw)==review['retained_manifest_sha256']
post={}
for line in gzip.decompress(post_raw).splitlines():
    name,kind,info=json.loads(line);assert name not in post;post[name]=[kind,info]
post_children={}
for name in post:
    parent=name.rpartition('/')[0];post_children[parent]=post_children.get(parent,0)+1
link_probe=value('directory-link-investigation.json')
assert [v['identity'][7] for v in link_probe['private_directory_observations']]==[2,3,4,5,4,3,2]
assert not link_probe['original_target_mutated'] and all(v['before'][:3]==v['after'][:3] for v in link_probe['original_target_changes'])
assert sha(captured('namespace-review-epoch1.py'))==link_probe['failed_epoch_sha256']
assert b"AssertionError: ('retained directory changed', 'debug/deps')" in captured('source-review.stderr')
assert plan['base']==record['base']==epoch['base'] and not value('claim-bindings.json')['candidate_bindings']
assert len(controls['checks'])==17 and not controls['old_target_touched']
for mutant in controls['actual_unsafe_mutants_red']:
    assert mutant['exit']==1 and b'AssertionError' in captured('guard-mutant-'+mutant['name']+'.stderr')
assert len(controls['actual_unsafe_mutants_red'])==4
assert value('liveness-live-inventory.json')['candidate_hits'] and not value('liveness-live-inventory.json')['accepted_idle']
alias=value('alias-control.json');assert alias['exit']==2 and alias['actual_live_alias_open_refused'] and any(v['inode_match'] for v in alias['actual_candidate_hits'])
for label in ('before-quarantine','before-disposal'):
    live=value('liveness-v2-'+label+'.json');assert live['inspection_complete'] and live['accepted_idle'] and not live['candidate_hits'] and live['manifest_sha256']==plan['manifest_sha256']
links=value('link-transition-control.json');assert links['external_alias_refused'] and links['resume_hash_checked'] and links['keeper_identity_exact'] and not links['old_target_touched']
assert links['actual_link_transitions'][0]['before'][7]==2 and links['actual_link_transitions'][0]['after'][7]==1 and links['actual_link_transitions'][1]['after'][7]==0
assert build['exit']==0 and build['source_absent'] and build['quarantine_present'] and build['input_identities_unchanged'] and b'6 passed; 0 failed' in captured('current-build.stdout')
for v in json.loads(gzip.decompress(captured('current-build-inputs.json.gz'))).values():assert sha(base64.b64decode(v['base64'],validate=True))==v['sha256']
namespace=value('claim-bindings.json');refs=namespace['references'];assert len({v['path'] for v in refs})==len(refs)
tree={line.split('\t',1)[1]:line.split('\t',1)[0].split()[2] for line in subprocess.check_output(['git','ls-tree','-r',record['base'],'--','docs/claims'],cwd=R,text=True).splitlines()}
for ref in refs:
    if ref['git_blob']:
        assert tree[ref['path']]==ref['git_blob'];raw=subprocess.check_output(['git','cat-file','blob',ref['git_blob']],cwd=R)
    else:raw=base64.b64decode(ref['base64'],validate=True)
    assert len(raw)==ref['bytes'] and sha(raw)==ref['sha256']
with tempfile.TemporaryDirectory(prefix='cleanup46-3-retained-') as folder:
    temporary=Path(folder);helper=temporary/'support.py';helper.write_bytes(captured('cleanup_support.py'))
    spec=importlib.util.spec_from_file_location('retained_cleanup_support',helper);lib=importlib.util.module_from_spec(spec);spec.loader.exec_module(lib)
    manifest=temporary/'entries.gz';assemble('old-target-entries.jsonl.gz',manifest)
    assert sha(manifest.read_bytes())==plan['manifest_sha256']
    nodes_path=temporary/'nodes.gz';assemble('plan-nodes.jsonl.gz',nodes_path);assert sha(nodes_path.read_bytes())==plan['nodes_sha256']
    nodes={}
    with gzip.open(nodes_path,'rt') as stream:
        for line in stream:
            n=json.loads(line);key=tuple(n['identity'][1:3]);assert key not in nodes;nodes[key]=n
            assert lib.closed_links(n['names'],n['identity'][7]) and len(bytes.fromhex(n['sha256']))==32
            observed_kind=lib.header_kind(base64.b64decode(n['header_base64'],validate=True));assert observed_kind==n['header_kind']
            assert lib.compatible(n['first_path'],observed_kind)
    totals={'selected_path_names':0,'selected_unique_inodes':len(nodes),'selected_unique_logical_bytes':sum(n['identity'][3] for n in nodes.values()),'selected_per_inode_allocated_bytes':sum(n['identity'][6]*512 for n in nodes.values()),'retained_namespace_entries':0}
    seen={};first_paths=set();directories={};entries=0
    with gzip.open(manifest,'rt') as stream:
        for line in stream:
            relative,kind,info=json.loads(line);lib.canonical_parts(relative);assert len(info)==8;entries+=1
            if kind=='dir':directories[relative]=info
            key=tuple(info[1:3]);n=nodes.get(key) if kind=='file' else None
            if n:
                assert relative not in post,'selected name remains in observed final namespace'
                assert info==n['identity'] and lib.metadata_eligible(relative,info,plan['cutoff_mtime_ns'],plan['source_identity'][1]) and lib.compatible(relative,n['header_kind'])
                if relative==n['first_path']:first_paths.add(key)
                seen[key]=seen.get(key,0)+1;totals['selected_path_names']+=1
            else:
                current_kind,current=post[relative];assert current_kind==kind
                if kind=='dir':assert current[:3]==info[:3] and current[7]==post_children.get(relative,0)+2
                else:assert current==info
                totals['retained_namespace_entries']+=1
    assert all(seen.get(key)==n['names'] for key,n in nodes.items()) and totals==plan['totals']==review['totals']
    assert first_paths==nodes.keys()
    assert entries==value('old-target-inventory.json')['entries'] and json.loads(captured('directory-identities.json'))==directories
    assert len(post)==totals['retained_namespace_entries']
    assert sha(captured('directory-identities.json'))==plan['directories_sha256'] and sha(captured('claim-bindings.json'))==plan['claim_namespace_sha256']
    assert disposal['removed_names']==review['removed_names_absent']==totals['selected_path_names'] and disposal['selected_unique_inodes']==len(nodes)
    assert review['retained_entries_checked']==totals['retained_namespace_entries'] and review['retained_file_identities_exact'] and review['retained_directory_identity_mode_exact'] and review['retained_directory_links_match_final_child_count'] and review['quarantine_absent'] and disposal['source_restored'] and disposal['quarantine_absent']
    binary=temporary/'executable.gz';assemble('current-test-executable.gz',binary);digest=hashlib.sha256();size=0
    with gzip.open(binary,'rb') as stream:
        while raw:=stream.read(1024*1024):digest.update(raw);size+=len(raw)
    assert size==build['actual_test_executable']['bytes'] and digest.hexdigest()==build['actual_test_executable']['sha256']
    db=temporary/'inode-analysis.gz';assemble('inode-analysis.sqlite3.gz',db)
    # The actual SQLite input is retained; the claim independently derives from original metadata above.
    digest=hashlib.sha256();size=0
    with gzip.open(db,'rb') as stream:
        header=stream.read(16);assert header==b'SQLite format 3\0';digest.update(header);size+=len(header)
        while raw:=stream.read(1024*1024):digest.update(raw);size+=len(raw)
    assert size==record['database_identity']['bytes'] and digest.hexdigest()==record['database_identity']['sha256']
print(json.dumps({'owner':record['owner'],'totals':totals,'retained_inputs':len(rows),'current_rust_tests':6,'observed_unsafe_models_red':4,'limits':record['limits']},sort_keys=True),flush=True)
