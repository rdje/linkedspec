"""Restore the existing malformed-record boundary and retain every pre-guard source epoch."""
import common as c


def main():
    test='t/callable_codeblock_literal_contract.t'
    paths=[c.SOURCE,test,c.PREFIX+'capture_current.py',c.PREFIX+'review_current.py',c.PREFIX+'focused.py',
        'docs/tasks/TYPE-REFERENCE-BOOK.md','MEMORY.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    needle=" for (my $index = 0; $index < @$calls; ++$index) {\n  my $method = $calls->[$index]{method} // '';"
    replacement=" for (my $index = 0; $index < @$calls; ++$index) {\n  next unless ref($calls->[$index]) eq 'HASH';\n  my $method = $calls->[$index]{method} // '';"
    assert after[c.SOURCE].count(needle)==1
    after[c.SOURCE]=after[c.SOURCE].replace(needle,replacement,1)
    addition='''subtest 'malformed fluent members preserve typed invocation errors and records' => sub {
    require LinkedSpec::CodeblockRuntime;
    my $json = JSON::PP->new->canonical;
    foreach my $bad (undef, 'not-a-call', []) {
        my $record = parse_expr('{|| return(items.sum()) }');
        $record->{body_ast}{statements}[0]{expr}{args}[0]{calls}[0] = $bad;
        my $original = $json->encode($record);
        my $items = [3,1,8];
        my $error;
        eval { LinkedSpec::CodeblockRuntime::invoke($record, [], {items => \\$items}, 'malformed'); 1 }
            or $error = $@;
        my $typed = ref($error) eq 'LinkedSpec::CodeblockRuntime::Error';
        ok($typed, 'malformed serialized member reports the public typed error');
        is($typed ? $error->{code} : undef, 'invalid_codeblock_body', 'body error code stays exact');
        is($typed ? $error->{detail} : undef, 'invalid fluent call', 'fluent member detail stays exact');
        is_deeply($items, [3,1,8], 'failed invocation preserves caller values');
        is($json->encode($record), $original, 'validation does not vivify or mutate the record');
    }
};

'''
    assert after[test].count('done_testing();')==1
    after[test]=after[test].replace('done_testing();',addition+'done_testing();',1)
    path=c.PREFIX+'capture_current.py';text=after[path]
    text=text.replace('import json\n','import json\nimport sys\n',1)
    text=text.replace('def main():\n','def main():\n    epoch=sys.argv[1] if len(sys.argv)>1 else "candidate2"\n    assert epoch in ("candidate2","candidate3")\n',1)
    text=text.replace("'candidate2-inputs.json.gz'","epoch+'-inputs.json.gz'").replace("'candidate2-run.json.gz'","epoch+'-run.json.gz'")
    after[path]=text
    path=c.PREFIX+'review_current.py';text=after[path]
    text=text.replace('import json\n','import json\nimport sys\n',1).replace('def check():','def check(epoch="candidate3"):')
    text=text.replace("c.load('candidate2-run.json.gz')","c.load(epoch+'-run.json.gz')")
    text=text.replace('    result=check()','    epoch=sys.argv[1] if len(sys.argv)>1 else "candidate3"\n    assert epoch in ("candidate2","candidate3")\n    result=check(epoch)')
    text=text.replace("'candidate2-review.json.gz'","epoch+'-review.json.gz'")
    after[path]=text
    path=c.PREFIX+'focused.py';text=after[path]
    text=text.replace('import re\n','import re\nimport sys\nimport json\n',1)
    text=text.replace('def main():\n','def main():\n    epoch=sys.argv[1] if len(sys.argv)>1 else "focused1"\n    assert epoch in ("focused1","focused2")\n',1)
    text=text.replace("'focused1-inputs.json.gz'","epoch+'-inputs.json.gz'").replace("'focused1-run.json.gz'","epoch+'-run.json.gz'")
    old="    assert not c.decode(tests['stderr_base64'])"
    new='''    stderr=c.decode(tests['stderr_base64'])
    prefix=b'# RECEIVER_COPY_OBSERVATIONS '
    assert stderr.startswith(prefix) and len(stderr.splitlines())==1 and stderr.endswith(b'\\n')
    observed=json.loads(stderr[len(prefix):])
    assert observed['live_error'] is None and observed['live']==observed['standalone']
    assert observed['live_identity']==observed['standalone_identity']
    assert set(observed['live_identity'].values())=={1}
    sender='t/actionir_receiver_scalar_copy.t'
    assert b"diag('RECEIVER_COPY_OBSERVATIONS '" in (c.ROOT/sender).read_bytes()
    assert not c.decode(scanner['stderr_base64'])'''
    assert text.count(old)==1
    text=text.replace(old,new,1)
    after[path]=text
    task='docs/tasks/TYPE-REFERENCE-BOOK.md'
    anchor='  Intake: baseline176/dump3 retain42 deferred and6 ordinary arity failures; fix dispatch/shapes here. Next9 owns sorted. Rejected instruments and exact sources survive in the checkpoint.\n'
    assert after[task].count(anchor)==1
    after[task]=after[task].replace(anchor,anchor+'  Guard intake: New numeric preflight dereferenced a non-hash serialized call before the existing typed guard. Public invoke reproduces raw Perl text; real accepted Runtime gives invalid_codeblock_body. Restore the guard and lock null/string/list members plus unchanged caller/record. The initial shadow comparison misloaded current code and remains rejected preparation. Final source replay and dependent verification follow.\n',1)
    after['MEMORY.md']=after['MEMORY.md'].replace(
        'Run focused.py for14 dependent suites/scanner/historical audit, then resolve any actual historical inverse RED before canonical admission.',
        'Run candidate3 after the malformed-record guard, then focused2 and book proof. Recheck the old library with verified loaded bytes: the first shadow loaded current code. Keep both rejected preparations; no history inverse is needed (650 audit passed).')
    after['MEMORY.md']=after['MEMORY.md'].replace('Knowledge source8388576/8388608','Knowledge source8388596/8388608')
    after['MEMORY.md']=after['MEMORY.md'].replace('Canonical/normal commit pending.',
        'Malformed fluent guard and15 permanent assertions added; final214/dependents/canonical pending.')
    c.write_new('guard-change.json.gz',dict(before=before,after={path:c.encode(raw.encode()) for path,raw in after.items()},
        producer=c.read(c.PREFIX+'guard_fix.py'),
        scope='One runtime line skips non-hash members until the existing typed validator. Valid parsed '
              'calls are unchanged. Six aggregate faults and14/1947 remain retained pre-guard epochs. '
              'Current214 and final dependent proof are distinct. Preserve the exact intentional18010-byte '
              'receiver-copy diagnostic, rejecting all other stderr. Initial shadow loading is not a baseline.'))
    for path,raw in after.items():(c.ROOT/path).write_text(raw)
    print('Typed fluent guard restored;15 public record/caller assertions added; final source replay required')


if __name__=='__main__':main()
