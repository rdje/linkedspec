"""Retain and correct a compile-invalid public guard instrument, not the runtime."""
import json
import common as c
import review_before as b
import review_after as a


def main():
    prior=c.read('tests/signed-array-rust/cases.json')
    original=json.loads(c.decode(prior['base64']))
    packet=c.load('test-expanded1-run.json.gz')
    assert packet['run']['returncode']==101 and packet['inputs_unchanged']
    stderr=c.decode(packet['run']['stderr_base64']).decode()
    assert 'progressive_span_binding_required' in stderr
    rows=b.decode_rows(packet['run'])
    targets={row['id']:a.exact(row['expected']) for row in original['cases']}
    assert all(a.matches(row,targets[row['id']]) for row in rows)
    assert {row['route'] for row in rows}==a.FOUR
    reached={row['id'] for row in rows}
    assert len(rows)==len(reached)*4
    value=json.loads(c.decode(prior['base64']))
    case=next(row for row in value['cases'] if row['id']=='signed-guard-before-expression-failure')
    assert case['source'].count('dispatch_span()')==2
    case['id']='signed-guard-before-expression-effects'
    case['source']=case['source'].replace('{ dispatch_span(); -1 }','{ push(audit,"selector"); -1 }').replace('=dispatch_span()','= { push(audit,"rhs"); 99 }')
    raw=(json.dumps(value,ensure_ascii=False,indent=2)+'\n').encode()
    c.write_new('expanded-instrument-qualification.json.gz',dict(producer=c.read(c.PREFIX+'qualify_expanded.py'),
        before=prior,after=dict(base64=c.encode(raw),sha256=c.sha(raw),mode=prior['mode']),
        reached_cases=sorted(reached),observations=len(rows),all_observed_rows_pass=True,
        reason='Public compilation rejects unbound dispatch_span before runtime. The original guard fixture therefore cannot prove runtime guard precedence; it is a rejected instrument, not a product RED. Private context tests deliberately exercise runtime-only dispatch failure. The corrected public fixture uses valid ordinary effects; its guard outcome remains the target. No full expanded/generated/emitted-suite success is credited.'))
    c.source('tests/signed-array-rust/cases.json').write_bytes(raw)
    print('Instrument qualification:',len(reached),'cases/',len(rows),'observed rows pass; no emitted/full-suite credit. Valid effectful guard instrument supplied.')


if __name__=='__main__':main()
