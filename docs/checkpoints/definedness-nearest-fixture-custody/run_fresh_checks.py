"""Run one retained nearest-suite command with explicit before/after identities."""
from pathlib import Path
import gzip,hashlib,json,subprocess,sys

directory=Path('docs/checkpoints/definedness-nearest-fixture-custody')
v=Path('.linkedspec-data/verification')
raw=(directory/'recovery.json.gz').read_bytes();recovery_sha=hashlib.sha256(raw).hexdigest()
activation=json.loads((v/'definedness-fixture-repair-activation.json').read_bytes())
assert recovery_sha==activation['recovery_sha256']
recovery=json.loads(gzip.decompress(raw));key=sys.argv[1]
assert len(sys.argv)==2 and key in recovery['current_cases']
case=recovery['current_cases'][key]
base=v/('definedness-fixture-repair-'+key)
stdout=Path(str(base)+'.log');stderr=Path(str(base)+'.stderr');result_path=Path(str(base)+'-result.json')
assert not any(path.exists() for path in (stdout,stderr,result_path))
producer=directory/'run_fresh_checks.py';producer_sha=hashlib.sha256(producer.read_bytes()).hexdigest()
def verify():
    observed={}
    for path,item in case['files'].items():
        digest=hashlib.sha256(Path(path).read_bytes()).hexdigest()
        assert digest==item['sha256'],path
        observed[path]=digest
    captured=recovery['original_captures'][case['backend']]
    assert hashlib.sha256(Path(captured['path']).read_bytes()).hexdigest()==captured['sha256']
    assert hashlib.sha256((directory/'recovery.json.gz').read_bytes()).hexdigest()==recovery_sha
    assert hashlib.sha256(producer.read_bytes()).hexdigest()==producer_sha
    return hashlib.sha256(json.dumps(observed,sort_keys=True,separators=(',',':')).encode()).hexdigest()
before=verify()
with stdout.open('wb') as out,stderr.open('wb') as err:
    result=subprocess.run(case['command'],cwd=case['cwd'],stdout=out,stderr=err)
after=verify();assert before==after
record={'case':key,'activation_commit':recovery['activation_commit'],'command':case['command'],'cwd':case['cwd'],'exit':result.returncode,'input_manifest':str(directory/'recovery.json.gz'),'input_manifest_sha256':recovery_sha,'verified_inputs':len(case['files']),'before_input_fingerprint':before,'after_input_fingerprint':after,'producer':str(producer),'producer_sha256':producer_sha,'stdout':str(stdout),'stdout_sha256':hashlib.sha256(stdout.read_bytes()).hexdigest(),'stderr':str(stderr),'stderr_sha256':hashlib.sha256(stderr.read_bytes()).hexdigest(),'scope':'Fresh selected nearest proof with actual current source/fixture identities. Historical recovery is not an original runtime-time hash. No full suite, transitive census or runtime change.'}
result_path.write_text(json.dumps(record,indent=2)+'\n')
print(key,'actual exit',result.returncode,'before/after input identity exact;',len(case['files']),'inputs')
if key=='dart':
    events=[json.loads(line) for line in stdout.read_text().splitlines() if line.startswith('{')]
    done=[e for e in events if e.get('type')=='testDone' and not e.get('hidden') and not e.get('skipped')]
    print('Dart non-skipped completions',len(done),'PASS',sum(e['result']=='success' for e in done))
else:
    print('\n'.join(line for line in stdout.read_text().splitlines() if ('Tests=' in line or 'Result:' in line or 'test result:' in line or ' | ' in line or 'GUARD_SUMMARY' in line or 'checks passed' in line) and len(line)<250))
sys.exit(result.returncode)
