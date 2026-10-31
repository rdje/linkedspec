"""One-shot retention of the bounded input-custody diagnosis context."""
from pathlib import Path
import base64,gzip,hashlib,json

directory=Path('docs/checkpoints/definedness-nearest-fixture-custody')
output=directory/'intake-context.json.gz';cause_path=directory/'root-cause.json'
assert not output.exists() and not cause_path.exists()
report=json.loads((directory/'original-audit.json').read_bytes());causes={}
for backend,item in report.items():
    raw=Path(item['capture']).read_bytes();assert hashlib.sha256(raw).hexdigest()==item['capture_sha256']
    packet=json.loads(gzip.decompress(raw));inputs={entry['path']:entry for entry in packet['inputs']}
    def source(path):
        entry=inputs[path];data=base64.b64decode(entry['base64'],validate=True)
        assert len(data)==entry['bytes'] and hashlib.sha256(data).hexdigest()==entry['sha256']
        return data,entry['sha256']
    activation='.linkedspec-data/verification/activate_definedness_guard_'+backend+'.py'
    data,digest=source(activation)
    assert b"glob('string_comparison_result_receiver_values.*')" in data
    selector='.linkedspec-data/verification/run_definedness_guard_'+backend+('_nearest.lua' if backend=='lua' else '.py')
    selected,selected_digest=source(selector)
    assert b'definedness_result_receiver' in selected and b'lexical_result_guard_composition' in selected
    for wrapper in ('tools/run_python_project_data.sh','tools/project_data_env.sh','tools/project_data_run.sh'):
        captured,_=source(wrapper);assert Path(wrapper).read_bytes()==captured,wrapper
    causes[backend]={'capture':item['capture'],'source_epoch':item['source_epoch'],'activation':activation,'activation_sha256':digest,'inherited_glob':'string_comparison_result_receiver_values.*','nearest_selector':selector,'nearest_selector_sha256':selected_digest,'named_direct_dependencies':len(item['dependencies']),'all_named_dependencies_missing':all(row['missing_from_original_capture'] for row in item['dependencies'])}
cause_path.write_text(json.dumps(causes,indent=2,sort_keys=True)+'\n')
paths=[Path('.linkedspec-data/verification/definedness-nearest-fixture-intake-initial-auditor.py'),Path('.linkedspec-data/verification/definedness-nearest-fixture-intake-audit.stderr'),Path('.linkedspec-data/verification/definedness-nearest-fixture-intake-audit.json'),Path('.linkedspec-data/verification/audit_definedness_nearest_fixture_inputs.py'),Path('.linkedspec-data/verification/definedness-nearest-fixture-intake-qualified-audit.json'),Path('.linkedspec-data/verification/definedness-nearest-fixture-intake-qualified-audit.stderr'),Path('tools/run_python_project_data.sh'),Path('tools/project_data_env.sh'),Path('tools/project_data_run.sh')]
inputs=[]
for p in paths:
    raw=p.read_bytes();inputs.append({'path':str(p),'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'base64':base64.b64encode(raw).decode()})
packet={'root_cause':causes,'inputs':inputs,'setup_qualification':'Initial auditor assumed literal full filenames and stopped on a constructed Dart stem/extension loader. Actual observed tool exit1 and raw producer/stderr retained; no missing-input RED credit. Qualified auditor verifies explicit calls and loaders, completes all five cohorts and returns1 with empty stderr. Original producer inputs/results/captures are unchanged.','scope':'Named direct fixture prerequisites of selected nearest consumer sources only. No current runtime failure, successful historical input hash capture, full transitive dependency/producer census or admission claim.'}
output.write_bytes(gzip.compress(json.dumps(packet,sort_keys=True,separators=(',',':')).encode(),mtime=0))
for entry in json.loads(gzip.decompress(output.read_bytes()))['inputs']:
    raw=base64.b64decode(entry['base64'],validate=True);assert len(raw)==entry['bytes'] and hashlib.sha256(raw).hexdigest()==entry['sha256']
print('Confirmed inherited fixture-glob cause in all five recorded activations; actual context/setup qualification retained')
