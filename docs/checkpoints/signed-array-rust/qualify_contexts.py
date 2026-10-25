"""Qualify expanded observer/context and reject a compile-invalid guard probe."""
import copy
import json
import common as c
import review_before as b
import binary
import epoch

FIXTURE='tests/signed-array-rust/cases.json'
TEST='rust/linkedspec-runtime/tests/signed_array_selector_contract.rs'
READER=c.PREFIX+'review_after.py'


def main():
    sources={path:c.read(path) for path in [FIXTURE,TEST,READER,c.PREFIX+'qualify_expanded.py']}
    value=json.loads(c.decode(sources[FIXTURE]['base64']))
    before=copy.deepcopy(value)
    contexts=[]
    for case in value['cases']:
        if case['id'].startswith('authority/write/callable/') and 'error' in case['expected']:
            case['expected']['codeblock_contexts']=['runner'];contexts.append(case['id'])
    assert len(contexts)==15
    case=next(row for row in value['cases'] if row['id']=='signed-guard-before-expression-failure')
    assert case['source'].count('dispatch_span()')==2
    case['id']='signed-guard-before-expression-effects'
    case['source']=case['source'].replace('{ dispatch_span(); -1 }','{ push(audit,"selector"); -1 }').replace('=dispatch_span()','= { push(audit,"rhs"); 99 }')
    probe='Top: /x/\n I { tree=[10,20]; chosen="-1"; return([tree[-1.0],tree[-1.5],tree[chosen],tree["-1"]]) }\n'
    cli='rust/target/debug/linkedspec-rust'
    supplied=epoch.snapshot([TEST,FIXTURE])
    artifact=binary.archive(c.source(cli),'quoted-key-calibration')
    run=c.run([cli,'--inline-spec',probe,'--input','x'])
    c.write_new('quoted-key-calibration.json.gz',dict(context=supplied,producer=c.read(c.PREFIX+'qualify_contexts.py'),
        source=probe,run=run,executable=artifact,inputs_unchanged=c.unchanged(supplied['inputs'])))
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    assert json.loads(c.decode(run['stdout_base64']))==[20,10,10,None]
    case=next(row for row in value['cases'] if row['id']=='native-float-kind')
    case['source']=probe;case['expected']=dict(ok=[20,10,10,None])
    reports={}
    for name in ('expanded1','expanded2'):
        packet=c.load('test-'+name+'-run.json.gz')
        assert packet['run']['returncode']==101 and packet['inputs_unchanged']
        assert 'progressive_span_binding_required' in c.decode(packet['run']['stderr_base64']).decode()
        rows=b.decode_rows(packet['run']);reached={row['id'] for row in rows}
        assert len(rows)==len(reached)*4 and {row['route'] for row in rows}==b.ROUTES
        targets={row['id']:row['expected'] for row in before['cases']}
        wrapped=[]
        for row in rows:
            target=targets[row['id']];actual=row['actual']
            if 'ok' in target:assert actual==target
            else:
                raw=actual['raw_error']
                if row['id'] in contexts:
                    prefix="codeblock 'runner': ";assert raw.startswith(prefix)
                    raw=raw[len(prefix):];wrapped.append(dict(id=row['id'],route=row['route']))
                decoded=json.loads(raw)
                for key,wanted in target['error'].items():
                    if isinstance(wanted,dict) and set(wanted)=={'exact_integer'}:wanted=int(wanted['exact_integer'])
                    assert decoded.get(key)==wanted,(row['id'],key)
        assert len(wrapped)==60
        reports[name]=dict(reached=sorted(reached),rows=len(rows),context_observer_mismatches=wrapped,
            qualified_payload_mismatches=[],no_emitted_credit=True)
    test=c.decode(sources[TEST]['base64']).decode()
    anchor='''    expected["error"]
        .as_object()'''
    replacement='''    let Some(mut raw) = actual["raw_error"].as_str() else { return false; };
    if let Some(contexts) = expected.get("codeblock_contexts").and_then(Value::as_array) {
        for context in contexts {
            let prefix = format!("codeblock '{}': ", context.as_str().expect("context name"));
            let Some(inner) = raw.strip_prefix(&prefix) else { return false; };
            raw = inner;
        }
    }
    let Ok(projection) = serde_json::from_str::<Value>(raw) else { return false; };
    expected["error"]
        .as_object()'''
    assert test.count(anchor)==1;test=test.replace(anchor,replacement,1)
    removal='''                let Some(raw) = actual["raw_error"].as_str() else {
                    return false;
                };
'''
    assert test.count(removal)==1;test=test.replace(removal,'',1)
    assert test.count('actual["error"].get(key) == Some(value)')==1
    test=test.replace('actual["error"].get(key) == Some(value)','projection.get(key) == Some(value)',1)
    reader=c.decode(sources[READER]['base64']).decode()
    anchor="    try:\n        error = json.loads(raw)"
    replacement="    for context in wanted.get('codeblock_contexts', []):\n        prefix = \"codeblock '\" + context + \"': \"\n        if not raw.startswith(prefix):\n            return False\n        raw = raw[len(prefix):]\n    try:\n        error = json.loads(raw)"
    assert reader.count(anchor)==1;reader=reader.replace(anchor,replacement,1)
    updated={FIXTURE:(json.dumps(value,ensure_ascii=False,indent=2)+'\n').encode(),TEST:test.encode(),READER:reader.encode()}
    c.write_new('expanded-context-qualification.json.gz',dict(producer=c.read(c.PREFIX+'qualify_contexts.py'),
        before=sources,after={path:dict(base64=c.encode(raw),sha256=c.sha(raw),mode=sources[path]['mode']) for path,raw in updated.items()},
        reports=reports,
        reason='Two original epochs stop at compile-invalid dispatch_span. Expanded2 was inadvertently launched after the first qualification assertion failed; it repeats the same unchanged source and is not new proof. That failed qualifier expected every observed row to pass, overlooking the established codeblock runner context on15 callable error records. Explicit contexts retain exact original raw strings and require exact named prefix; only then compare the payload. Every observed target field/value is unchanged. The valid guard source uses ordinary effects. The unreached float/coercion draft also incorrectly treated a quoted key as an evaluated index; fresh public calibration preserves that existing distinction, retaining its exact source/binary/channels. These instrument/context qualifications earn no product RED or full generated/emitted success.'))
    for path,raw in updated.items():c.source(path).write_bytes(raw)
    print('Qualified contexts:',len(contexts),'records; original131-case/524-row partial epochs retained, no product RED or emitted credit.')


if __name__=='__main__':main()
