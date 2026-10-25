"""Retain a one-character oracle error and derive the action-relative scalar span."""
import json
import common as c
import review_before as b
import review_after as a


def main():
    path='tests/signed-array-rust/cases.json';prior=c.read(path)
    value=json.loads(c.decode(prior['base64']))
    rows=b.decode_rows(c.load('test-expanded3-run.json.gz')['run'])
    targets={row['id']:a.exact(row['expected']) for row in value['cases']}
    failed=[row for row in rows if not a.matches(row,targets[row['id']])]
    assert len(rows)==137*5 and len(failed)==5
    assert {row['id'] for row in failed}=={'unicode-exact-public'}
    case=next(row for row in value['cases'] if row['id']=='unicode-exact-public')
    body=case['source'].split(' I {',1)[1].rsplit('}',1)[0].strip()
    start=len(body[:body.index('[-2]')+1])
    assert start==26 and len(body[:body.index('[-2]')+1].encode())==28
    assert case['expected']['error']['source_span']['start']==start+1
    case['expected']['error']['source_span'].update(start=start,end=start+2)
    for row in failed:
        assert a.matches(row,case['expected'])
    raw=(json.dumps(value,ensure_ascii=False,indent=2)+'\n').encode()
    c.write_new('span-oracle-qualification.json.gz',dict(producer=c.read(c.PREFIX+'qualify_spans.py'),
        before=prior,after=dict(base64=c.encode(raw),sha256=c.sha(raw),mode=prior['mode']),
        parser_source=c.read('rust/linkedspec-core/src/parser.rs'),
        geometry_probe=c.read('rust/linkedspec-runtime/tests/signed_array_selector_contract.rs'),
        reached=dict(cases=137,routes=sorted({row['route'] for row in rows}),observations=len(rows),mismatches=5),
        reason='Expanded3 completes five137-case routes; exactly the Unicode expected span includes one outer brace-padding character that the public parser trims. The code field is trimmed in consume_brace_block and then parsed by the compiler; offsets are scalar positions within that action. Derive26..28 from trimmed source, distinguish UTF-8 byte offset28 and the rejected untrimmed scalar27. A permanent public AST probe varies space/newline padding. No product RED, emitted execution or full-suite success is credited to the original epoch.'))
    c.source(path).write_bytes(raw)
    print('Span oracle qualified: original685 rows retained;5 oracle mismatches; trimmed scalar26 differs from byte28 and padded scalar27.')


if __name__=='__main__':main()
