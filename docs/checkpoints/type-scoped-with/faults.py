"""Mutate the actual producer, observe distinguishing RED, and restore exactly."""
import json
import common as c
import oracle

plan = c.load('green-inputs.json')
inputs = dict(plan['inputs'])
inputs.update({c.PREFIX + name: c.identity(c.PREFIX + name)
               for name in ('oracle.py', 'faults.py', 'span.pl')})
assert c.unchanged(inputs)
source = c.read(c.SOURCE)
original = c.decode(source['base64'])
changes = [
    ('scoped-kind', b"return 'scalar' if defined($_[0]) && $_[0] eq 'value';",
     b"return undef if defined($_[0]) && $_[0] eq 'value';"),
    ('dynamic-frame-vocabulary', b"push @names, 'value' unless grep { defined($_) && $_ eq 'value' } @names;",
     b"# Deliberately omit the scoped dynamic-frame name."),
    ('function-vocabulary', b"%{$scoped->{__user_function_scalar_value_names}}, value => 1,",
     b"%{$scoped->{__user_function_scalar_value_names}},"),
    ('function-frame-shadow', b"? 'local '.$bindings.'->{\"value\"} = \\\\$value; ' : '';",
     b"? '' : '';"),
    ('function-frame-restoration', b"? 'local '.$bindings.'->{\"value\"} = \\\\$value; ' : '';",
     b"? $bindings.'->{\"value\"} = \\\\$value; ' : '';"),
    ('authored-spans', b"my $ast_node = ref($provided_ast) eq 'HASH'\n   ? $provided_ast : _parse_method_value_ast_expr($trimmed, $deps);",
     b"my $ast_node = _parse_method_value_ast_expr($trimmed, $deps);"),
]
assert all(original.count(before) == 1 for _, before, _ in changes)
c.write_new('fault-inputs.json', dict(inputs=inputs, source=source,
    changes=[dict(name=name, before=c.encode(before), after=c.encode(after)) for name, before, after in changes],
    plan=plan['plan'], scope='Actual current MethodLowering bytes mutate only inside try/finally. '
    'Every competing producer runs fresh Perl; fixed contract outputs and authored string offsets are independent oracles.'))
rows = []
for name, before, after in changes:
    mutant = original.replace(before, after, 1)
    (c.ROOT / c.SOURCE).write_bytes(mutant)
    try:
        expected_inputs = dict(inputs, **{c.SOURCE: c.identity(c.SOURCE)})
        assert c.unchanged(expected_inputs)
        run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(plan['plan']).encode())
        bad = oracle.mismatches(run, plan['plan'], inputs)
        span = c.run(['perl', '-Iperl', c.PREFIX + 'span.pl'])
        assert span['returncode'] == 0 and not c.decode(span['stderr_base64'])
        offsets = json.loads(c.decode(span['stdout_base64']))
        span_red = any(offsets[route] != offsets['expected'] for route in ('native', 'generated'))
        c.write_new('fault-' + name + '-observed.json.gz', dict(
            mutant_sha256=c.sha(mutant), run=run, failures=bad, span=span, span_red=span_red))
        assert bad or span_red, ('unobserved producer fault', name)
        assert c.unchanged(expected_inputs)
    finally:
        (c.ROOT / c.SOURCE).write_bytes(original)
        (c.ROOT / c.SOURCE).chmod(source['mode'])
    assert c.unchanged(inputs)
    restored = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(plan['plan']).encode())
    restored_span = c.run(['perl', '-Iperl', c.PREFIX + 'span.pl'])
    assert not oracle.mismatches(restored, plan['plan'], inputs)
    assert restored_span['returncode'] == 0 and not c.decode(restored_span['stderr_base64'])
    offsets_after = json.loads(c.decode(restored_span['stdout_base64']))
    assert offsets_after['expected'] == offsets_after['native'] == offsets_after['generated']
    rows.append(dict(name=name, mutant_sha256=c.sha(mutant), run=run, failures=bad,
        span=span, span_red=span_red, restored=restored, restored_span=restored_span,
        inputs_restored=c.unchanged(inputs)))
    print('Producer fault RED/restored:', name, len(bad), 'value/diagnostic cases; span RED', span_red, flush=True)
    c.write_new('fault-' + name + '.json.gz', rows[-1])
c.write_new('fault-review.json', dict(result='PASS', faults=[row['name'] for row in rows]))
