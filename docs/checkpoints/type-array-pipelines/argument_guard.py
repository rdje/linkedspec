"""Fix the observed public malformed-record failure and retain a separate final guard epoch."""
import common as c

def main():
    paths=[c.SOURCE,'t/callable_codeblock_literal_contract.t']
    before={p:c.read(p) for p in paths}
    source=c.decode(before[c.SOURCE]['base64']).decode()
    old='  my $args = $calls->[$index]{args} || [];\n'
    new='''  my $args = $calls->[$index]{args};
  _error('invalid_codeblock_body', detail => 'fluent arguments must be an array')
   unless ref($args) eq 'ARRAY';
'''
    assert source.count(old)==1
    source=source.replace(old,new,1)
    test=c.decode(before[paths[1]]['base64']).decode()
    block='''subtest 'serialized fluent argument fields preserve typed errors and values' => sub {
    require LinkedSpec::CodeblockRuntime;
    my $json = JSON::PP->new->canonical;
    foreach my $method (qw(sorted take sum)) {
        foreach my $kind (qw(null number string hash missing)) {
            my $record = parse_expr('{|| return(items.' . $method . '()) }');
            my $call = $record->{body_ast}{statements}[0]{expr}{args}[0]{calls}[0];
            if ($kind eq 'missing') { delete $call->{args} }
            else { $call->{args} = $kind eq 'null' ? undef : $kind eq 'number' ? 1 : $kind eq 'string' ? 'bad' : {} }
            my $before = $json->encode($record);
            my $items = [3,1,8];
            my $error;
            eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {items => \\$items}, 'malformed-args'); 1 }
                or $error = $@;
            my $typed = ref($error) eq 'LinkedSpec::CodeblockRuntime::Error';
            ok($typed, "$method/$kind reports a typed invocation error");
            is($typed ? $error->{code} : undef, 'invalid_codeblock_body', 'body error code');
            is($typed ? $error->{detail} : undef, 'fluent arguments must be an array', 'argument error detail');
            is_deeply($items, [3,1,8], 'caller values remain unchanged');
            is($json->encode($record), $before, 'record remains unchanged');
        }
    }
};

'''
    assert test.count('done_testing();')==1
    test=test.replace('done_testing();',block+'done_testing();',1)
    after={c.SOURCE:source,paths[1]:test}
    c.write_new('argument-guard-change.json.gz',dict(before=before,after={p:c.encode(t.encode()) for p,t in after.items()},
        producer=c.read(c.PREFIX+'argument_guard.py'),old=old,new=new,
        scope='Public malformed probe confirms raw host errors for nine non-array fields and acceptance of six missing/null lists. Require canonical array arguments before preflight dereferences. Six original source faults remain the exact pre-guard epoch; final typed guard has a separate actual removal/restoration.'))
    for p,t in after.items():(c.ROOT/p).write_text(t)
    print('Fluent argument guard and75 permanent assertions installed; final epochs still required')

if __name__=='__main__':main()
