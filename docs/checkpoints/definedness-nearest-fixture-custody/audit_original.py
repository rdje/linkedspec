from pathlib import Path
import base64,gzip,hashlib,json,re,sys

root=Path('docs/checkpoints/type-operation-inventory')
spec='tests/fixtures/definedness_result_receiver_values.spec'
data='tests/fixtures/definedness_result_receiver_values.json'
perl_data='tests/fixtures/definedness_result_receiver_values.perl.json'
lexical='tests/fixtures/lexical_result_guard_cases.json'
shapes='tests/fixtures/lexical_result_guard_excluded_ast.json'
required={
 'perl':{spec:'t/definedness_result_receiver_contract.t',perl_data:'t/definedness_result_receiver_contract.t',lexical:'t/lexical_result_guard_composition.t'},
 'rust':{spec:'rust/linkedspec-runtime/tests/definedness_result_receivers.rs',data:'rust/linkedspec-runtime/tests/definedness_result_receivers.rs',lexical:'rust/linkedspec-runtime/tests/lexical_result_guard_composition.rs',shapes:'rust/linkedspec-runtime/tests/lexical_result_guard_composition.rs'},
 'dart':{spec:'dart/test/definedness_result_receivers_test.dart',data:'dart/test/definedness_result_receivers_test.dart'},
 'julia':{spec:'julia/test/definedness_result_receivers_test.jl',data:'julia/test/definedness_result_receivers_test.jl'},
 'lua':{spec:'lua/test/definedness_result_receivers_test.lua',data:'lua/test/definedness_result_receivers_test.lua'},
}
report={}
for backend,dependencies in required.items():
    path=root/('definedness-guard-'+backend+'-intake.json.gz');raw=path.read_bytes();packet=json.loads(gzip.decompress(raw))
    inputs={item['path']:item for item in packet['inputs']};assert len(inputs)==len(packet['inputs'])
    rows=[]
    for fixture,producer in dependencies.items():
        item=inputs[producer];source=base64.b64decode(item['base64'],validate=True)
        assert len(source)==item['bytes'] and hashlib.sha256(source).hexdigest()==item['sha256']
        if Path(fixture).name.encode() in source:
            form='literal fixture path'
        else:
            stem=Path(fixture).stem;extension=Path(fixture).suffix[1:];text=source.decode()
            pattern=r'\(\s*[\"\x27]'+re.escape(stem)+r'[\"\x27]\s*,\s*[\"\x27]'+re.escape(extension)+r'[\"\x27]\s*\)'
            assert re.search(pattern,text),(backend,producer,fixture)
            loader={
                'dart':"tests/fixtures/$name.$extension",
                'julia':'"tests", "fixtures", name * "." * extension',
                'lua':'"tests/fixtures/" .. name .. "." .. extension',
            }[backend]
            assert loader in text,(backend,producer,fixture)
            form='explicit stem/extension call and retained loader'
        rows.append({'fixture':fixture,'retained_consumer':producer,'consumer_sha256':item['sha256'],'dependency_oracle':form,'missing_from_original_capture':fixture not in inputs})
    report[backend]={'capture':str(path),'capture_sha256':hashlib.sha256(raw).hexdigest(),'source_epoch':packet['base'],'dependencies':rows}
print(json.dumps(report,indent=2,sort_keys=True))
sys.exit(1 if any(row['missing_from_original_capture'] for item in report.values() for row in item['dependencies']) else 0)
