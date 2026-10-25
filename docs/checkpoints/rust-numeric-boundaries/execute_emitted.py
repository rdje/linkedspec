"""Independently compile and execute the retained actual emitted source."""
import json
import math
import struct
import sys
import common as c
import emit_source as producer

MAIN=r'''
use linkedspec_numeric_emitted as parser;
use linkedspec_runtime::engine::ExecutionOptions;
use serde_json::{Value,json};
fn main() {
    let entries:Value=serde_json::from_str(include_str!("entries.json")).unwrap();
    for case in entries.as_array().unwrap() {
        let options=ExecutionOptions::new().with_entry_rule(case["entry"].as_str().unwrap());
        let result=parser::execute_with_options(case["input"].as_str().unwrap(),&options);
        let row=match result {
            Ok(value)=>json!({"id":case["id"],"ok":value}),
            Err(error)=>json!({"id":case["id"],"raw_error":error.detail.as_deref().unwrap_or(error.summary)}),
        };
        println!("NUMERIC_EMITTED\t{row}");
    }
}
'''


def exact(value,target):
    if type(value) is not type(target):return False
    if isinstance(target,dict):
        return value.keys()==target.keys() and all(exact(value[key],wanted)
            for key,wanted in target.items())
    if isinstance(target,list):
        return len(value)==len(target) and all(exact(item,wanted)
            for item,wanted in zip(value,target))
    if isinstance(target,float):return struct.pack('>d',value)==struct.pack('>d',target)
    return value==target


def matches(value,target):
    if 'binary64' in target:
        if target['json_kind'] in ('signed_integer','unsigned_integer'):
            return type(value) is int and str(value)==target['integer']
        return type(value) is float and math.isfinite(value) and struct.pack('>d',value).hex()==target['binary64']
    if 'exact' in target:return exact(value,target['exact'])
    if 'array' in target:
        return isinstance(value,list) and len(value)==len(target['array']) and all(
            matches(value,expected) for value,expected in zip(value,target['array']))
    if 'object' in target:
        return isinstance(value,dict) and value.keys()==target['object'].keys() and all(
            matches(value[key],expected) for key,expected in target['object'].items())
    raise AssertionError('unknown independent target')


def main():
    assert len(sys.argv) in (2,3)
    label=sys.argv[1];assert label.replace('-','').isalnum()
    functions=len(sys.argv)==3
    if functions:assert sys.argv[2]=='functions'
    result=c.load('function-emission-result.json.gz' if functions else 'emission-result.json.gz')
    fixture_path='tests/numeric-conversion/'+('functions.json' if functions else 'programs.json')
    fixture=json.loads(c.source(fixture_path).read_text())
    cases={row['id']:row for row in fixture['cases'] if row['pointer_width'] in
        (None,result['pointer_width'])}
    assert set(cases)=={row['id'] for row in result['entries']}
    root=producer.workspace('numeric55-emitted-'+label)
    name='linkedspec-numeric-emitted'
    producer.manifest(root,name)
    (root/'src/lib.rs').write_text(result['module'])
    (root/'src/main.rs').write_text(MAIN)
    (root/'src/entries.json').write_text(json.dumps(result['entries'])+'\n')
    stem='emitted-'+label
    path,artifact,supplied=producer.build(root,name,stem)
    run=producer.execute(path,artifact,supplied,stem)
    observed={}
    for line in c.decode(run['stdout_base64']).decode().splitlines():
        assert line.startswith('NUMERIC_EMITTED\t'),line[:100]
        row=json.loads(line.split('\t',1)[1]);name=row['id']
        assert name in cases and name not in observed
        observed[name]=row
    assert observed.keys()==cases.keys()
    failures=[]
    for name,case in cases.items():
        row=observed[name];expected=case['expected']
        if 'ok' in expected:
            correct='ok' in row and matches(row['ok'],expected['ok'])
        else:
            raw=row.get('raw_error');value=json.loads(raw) if isinstance(raw,str) else {}
            correct=all(key in value and exact(value[key],wanted)
                for key,wanted in expected['error'].items())
        if not correct:failures.append(name)
    c.save(stem+'-result.json.gz',dict(observed=observed,failures=failures,
        fixture=c.read(fixture_path),
        scope='Each selected authored ID and exact integer token/floating bit target '
            'is independently recomputed from complete actual emitted-process rows. '
            'The real public emitter output is compiled in its own locked offline '
            'workspace; SDK/OS/prepared RGX products remain read-only prerequisites.'))
    print('Independently compiled emitted cases:',len(observed),'mismatches:',len(failures),flush=True)
    assert not failures,failures


if __name__ == '__main__':
    main()
