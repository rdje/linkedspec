"""Read-only review of the bounded historical recovery and fresh companion."""
from pathlib import Path,PurePosixPath
import argparse,base64,copy,gzip,hashlib,json,re,subprocess,sys

DIRECTORY=Path('docs/checkpoints/definedness-nearest-fixture-custody')

class CustodyError(Exception):
    def __init__(self,code,detail):
        self.code=code
        super().__init__(code+': '+detail)

def require(condition,code,detail):
    if not condition:raise CustodyError(code,detail)

def safe_path(value):
    path=PurePosixPath(value)
    require(not path.is_absolute() and str(path)==value and not any(part in ('.','..','.git') for part in path.parts),'unsafe_path',value)
    return value

def decode(item):
    raw=base64.b64decode(item['base64'],validate=True)
    require(len(raw)==item['bytes'] and hashlib.sha256(raw).hexdigest()==item['sha256'],'retained_byte_identity',item.get('path','payload'))
    return raw

def load_recovery():
    raw=(DIRECTORY/'recovery.json.gz').read_bytes();recovery=json.loads(gzip.decompress(raw));captures={}
    for backend,item in recovery['original_captures'].items():
        data=Path(safe_path(item['path'])).read_bytes()
        require(hashlib.sha256(data).hexdigest()==item['sha256'],'original_capture_changed',item['path'])
        packet=json.loads(gzip.decompress(data));entries={entry['path']:entry for entry in packet['inputs']}
        require(len(entries)==len(packet['inputs']),'duplicate_original_path',backend)
        require(packet['base']==item['source_epoch'],'source_epoch',backend)
        captures[backend]=entries
    return raw,recovery,captures

def verify_historical(recovery,captures):
    audit=json.loads((DIRECTORY/'original-audit.json').read_bytes())
    expected={(backend,row['fixture'],row['retained_consumer'],row['consumer_sha256']) for backend,item in audit.items() for row in item['dependencies']}
    observed=set()
    for item in recovery['historical_fixtures']:
        backend=item['backend'];path=safe_path(item['path']);epoch=item['source_epoch']
        require(re.fullmatch(r'[0-9a-f]{40}',epoch) is not None,'unsafe_revision',epoch)
        require(epoch==recovery['original_captures'][backend]['source_epoch'],'source_epoch',path)
        key=(backend,path,item['retained_consumer'],item['consumer_sha256'])
        require(key in expected and key not in observed,'historical_edge_scope',str(key));observed.add(key)
        require(path not in captures[backend],'original_omission_changed',path)
        consumer=captures[backend][item['retained_consumer']];decode(consumer)
        require(consumer['sha256']==item['consumer_sha256'],'consumer_identity',path)
        require(item['original_runtime_time_hash_captured'] is False,'old_freshness_overclaim',path)
        data=decode(item)
        original=subprocess.check_output(['git','show',epoch+':'+path])
        blob=subprocess.check_output(['git','rev-parse',epoch+':'+path],text=True).strip()
        require(blob==item['git_blob'],'historical_git_blob_identity',path)
        require(data==original,'historical_provenance_mismatch',path)
    require(observed==expected and len(observed)==13,'historical_edge_closure','named direct input set')
    require(len({item['path'] for item in recovery['historical_fixtures']})==5,'historical_fixture_scope','unique named fixture set')

def expected_command(key,case,recovery,captures):
    backend=case['backend'];prefix='.linkedspec-data/verification/definedness-guard-'+backend+'-'
    phase='final-nearest' if backend=='rust' else 'nearest'
    if backend=='lua':phase=key.split('-',1)[1]+'-nearest'
    original=json.loads(decode(captures[backend][prefix+phase+'-command.json']))
    require(case['original_command']==original,'original_command_identity',key)
    if backend=='dart':return original['argv'],original['cwd']
    if backend=='lua':return original[:-1]+[recovery['retained_lua_selector']['path']],'.'
    return original,'.'

def verify_companion(raw,recovery,captures):
    packet=json.loads(gzip.decompress((DIRECTORY/'companion.json.gz').read_bytes()))
    inputs={item['path']:decode(item) for item in packet['inputs']}
    require(len(inputs)==len(packet['inputs']),'duplicate_companion_path','inputs')
    require(inputs[str(DIRECTORY/'recovery.json.gz')]==raw,'recovery_capture_identity','recovery.json.gz')
    require(packet['original_captures']==recovery['original_captures'],'original_capture_references','companion')
    require(set(packet['case_records'])==set(recovery['current_cases'])=={'perl','rust','dart','julia','lua-puc','lua-luajit'},'fresh_case_scope','six selected cases')
    selector=recovery['retained_lua_selector'];selector_data=base64.b64decode(selector['base64'],validate=True)
    require(hashlib.sha256(selector_data).hexdigest()==selector['sha256'],'selector_byte_identity','Lua selector')
    require(selector_data==decode(captures['lua'][selector['original_path']]),'selector_source_identity','Lua selector')
    require(inputs[selector['path']]==selector_data,'selector_relocation_identity',selector['path'])
    reports={}
    for key,case in recovery['current_cases'].items():
        observed={}
        for path,ref in case['files'].items():
            safe_path(path)
            if ref['storage']=='original_capture':
                require(ref['backend']==case['backend'] and ref['entry_path']==path,'source_reference_scope',path)
                data=decode(captures[ref['backend']][ref['entry_path']])
            elif ref['storage']=='historical_fixture':
                item=recovery['historical_fixtures'][ref['history_index']]
                require(item['backend']==case['backend'] and item['path']==path,'fixture_reference_scope',path);data=decode(item)
            else:
                require(ref['storage']=='retained_nearest_selector' and path==selector['path'] and case['backend']=='lua','unknown_input_reference',path)
                data=selector_data
            digest=hashlib.sha256(data).hexdigest();require(digest==ref['sha256'],'fresh_input_reference_identity',path);observed[path]=digest
        fingerprint=hashlib.sha256(json.dumps(observed,sort_keys=True,separators=(',',':')).encode()).hexdigest()
        result=json.loads(inputs[packet['case_records'][key]])
        require(result['case']==key and result['exit']==0,'fresh_result',key)
        require(result['activation_commit']==recovery['activation_commit'],'fresh_epoch',key)
        require(result['input_manifest_sha256']==hashlib.sha256(raw).hexdigest(),'fresh_manifest_identity',key)
        require(result['before_input_fingerprint']==result['after_input_fingerprint']==fingerprint,'fresh_before_after_identity',key)
        require(result['verified_inputs']==len(case['files']),'fresh_input_count',key)
        command,cwd=expected_command(key,case,recovery,captures)
        require(result['command']==case['command']==command and result['cwd']==case['cwd']==cwd,'fresh_command_identity',key)
        require(hashlib.sha256(inputs[result['producer']]).hexdigest()==result['producer_sha256'],'fresh_producer_identity',key)
        stdout=inputs[result['stdout']];stderr=inputs[result['stderr']]
        require(hashlib.sha256(stdout).hexdigest()==result['stdout_sha256'] and hashlib.sha256(stderr).hexdigest()==result['stderr_sha256'],'fresh_raw_channel_identity',key)
        text=stdout.decode()
        if key=='perl':
            require('Tests=28' in text and 'Result: PASS' in text,'fresh_selected_assertions',key)
        elif key=='rust':
            require(all(str(count)+' passed; 0 failed;' in text for count in (2,21)),'fresh_selected_assertions',key)
        elif key=='dart':
            events=[json.loads(line) for line in text.splitlines() if line.startswith('{')]
            done=[e for e in events if e.get('type')=='testDone' and not e.get('hidden') and not e.get('skipped')]
            require(len(done)==23 and all(e['result']=='success' for e in done) and any(e.get('type')=='done' and e.get('success') for e in events),'fresh_selected_assertions',key)
        elif key=='julia':
            require(all(re.search(r'\|\s*'+str(count)+r'\s+'+str(count)+r'\s',text) for count in (9,101)),'fresh_selected_assertions',key)
            require(not stderr,'fresh_strict_depwarn',key)
        else:
            require('definedness result receiver checks passed' in text and 'LEXICAL_GUARD_SUMMARY 101 checks 0 failures' in text,'fresh_selected_assertions',key)
            require(not stderr,'fresh_lua_stderr',key)
        reports[key]={'exit':0,'before_after_identity_exact':True,'verified_inputs':len(case['files'])}
    return {'historical_edges':13,'unique_named_fixtures':5,'original_captures_unchanged':True,'fresh_cases':reports,'scope':'Named direct fixture custody is restored by original captures plus this companion. Historical Git bytes and fresh execution identities have distinct epochs; no retroactive runtime-time hashes, transitive producer census or runtime change.'}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--falsify-historical-provenance',action='store_true')
    args=parser.parse_args()
    try:
        raw,recovery,captures=load_recovery();verify_historical(recovery,captures)
        if args.falsify_historical_provenance:
            changed=copy.deepcopy(recovery);item=changed['historical_fixtures'][0]
            data=decode(item)+b'\nprovenance mutant\n';item['bytes']=len(data);item['sha256']=hashlib.sha256(data).hexdigest();item['base64']=base64.b64encode(data).decode()
            decode(item)
            try:verify_historical(changed,captures)
            except CustodyError as error:
                require(error.code=='historical_provenance_mismatch','unexpected_negative_control',str(error))
                print(json.dumps({'observed_red':True,'hypothesis':'Self-consistent retained size and SHA256 suffice for historical input identity','fixture':item['path'],'self_consistent_payload':True,'rejected_by':'independent historical Git byte oracle','runtime_red':False},sort_keys=True));return 1
            raise CustodyError('negative_control_accepted','historical provenance mutant')
        print(json.dumps(verify_companion(raw,recovery,captures),sort_keys=True));return 0
    except (CustodyError,AssertionError,KeyError,OSError,ValueError,subprocess.CalledProcessError) as error:
        print('custody review failed: '+str(error),file=sys.stderr);return 2

if __name__=='__main__':sys.exit(main())
