"""Apply targeted actual-producer faults, observe RED, and restore exact sources."""
import json
import re
import common as c
import context
import oracle_final as oracle

RUNTIME = c.SOURCE
NUMERIC = 'perl/LinkedSpec/Numeric.pm'
LOWERING = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
AST_TEST = 't/actionir_ast_parser.t'


def definitions(sources):
    tasks = []

    def add(name, path, before, after, cases, required):
        tasks.append(dict(name=name, changes=[dict(path=path, before=before, after=after)],
                          cases=cases, required_red=required))

    add('scalar-dispatch', RUNTIME,
        b' my $numeric = LinkedSpec::Numeric::scalar_helper_name($name);', b' my $numeric;',
        ['deferred/canonical/add_variadic', 'deferred/alias/+', 'control/registered-function',
         'control/unknown/num_not_admitted'], ['deferred/canonical/add_variadic', 'deferred/alias/+'])
    add('receiver-dispatch', RUNTIME,
        b' return LinkedSpec::Numeric::scalar_helper_name($method)\n', b' return undef\n',
        ['deferred/receiver/abs', 'deferred/effect/receiver-continuation', 'outside/receiver/abs',
         'deferred/canonical/add_variadic'], ['deferred/receiver/abs'])
    add('symbol-alias', NUMERIC, b"'+' => 'num_add'", b"'+' => 'num_sub'",
        ['deferred/alias/+', 'outside/alias/+', 'deferred/alias/add'], ['deferred/alias/+'])
    add('word-alias', NUMERIC,
        b" $helper = 'num_'.$helper unless $helper =~ /\\Anum_/;\n", b'',
        ['deferred/alias/add', 'deferred/alias/abs', 'deferred/alias/+', 'deferred/canonical/add_variadic'],
        ['deferred/alias/add', 'deferred/alias/abs'])
    add('call-arity-order', RUNTIME,
        b'  return undef unless $array_overload || LinkedSpec::Numeric::arity_is_valid($numeric, scalar(@$args));\n',
        b'', ['deferred/effect/invalid-arity-skips-operands', 'outside/effect/invalid-arity-skips-operands',
              'deferred/canonical/invalid_sub_extra'], ['deferred/effect/invalid-arity-skips-operands'])
    runtime = c.decode(sources[RUNTIME]['base64'])
    start = runtime.index(b' # Validate numeric call shapes before any receiver or operands run, including\n')
    end = runtime.index(b' my $value = _eval_expr($node->{receiver}, $ctx);', start)
    add('receiver-shape-order', RUNTIME, runtime[start:end], b'',
        ['deferred/mixed-terminal/gt-cat', 'deferred/stability/receiver-arity-skips-receiver',
         'deferred/stability/single-min-evaluates', 'deferred/control/unknown-receiver-valid-numeric'],
        ['deferred/mixed-terminal/gt-cat', 'deferred/stability/receiver-arity-skips-receiver'])
    lowering = c.decode(sources[LOWERING]['base64'])
    for method in ('add', 'mul', 'min', 'max'):
        start = lowering.index(('  foreach my $arg (@$num_' + method + '_args) {').encode())
        end = lowering.index(b'\n  }', start)
        before = lowering[start:end]
        token = b'push @lowered_terms, _materialize_list_operand_expr($term_expr);'
        assert before.count(token) == 1
        add('snapshot-' + method, LOWERING, before,
            before.replace(token, b'push @lowered_terms, $term_expr;', 1),
            ['outside/snapshot/call/' + method, 'outside/snapshot/receiver/' + method,
             'control/saved-slot/' + method, 'control/splice/' + method, 'deferred/snapshot/call/' + method],
            ['outside/snapshot/call/' + method, 'outside/snapshot/receiver/' + method])
    start = lowering.index(b'  # Numeric shape errors are complete null expressions, including mixed chains.\n')
    end = lowering.index(b'  my $receiver_expr;', start)
    ast_guard = lowering[start:end]
    routine = lowering.index(b'sub _normalize_number_receiver_value_chain_expr {')
    start = lowering.index(b'  if ($method =~ /^(?:abs|floor|ceil|round)$/o) {', routine)
    end = lowering.index(b'  $current_expr = $helper.', start)
    legacy_guard = lowering[start:end]
    reverted = legacy_guard.replace(b"return 'undef' unless", b'return undef unless')
    reverted = reverted.replace(
        b"return ($method eq 'min' || $method eq 'max') ? undef : 'undef' unless @args >= 1;",
        b'return undef unless @args >= 1;')
    assert reverted != legacy_guard
    tasks.append(dict(name='compiler-shape-rejection', changes=[
        dict(path=LOWERING, before=ast_guard, after=b''),
        dict(path=LOWERING, before=legacy_guard, after=reverted)],
        cases=['outside/receiver-arity/sub', 'outside/receiver-arity/abs',
               'outside/mixed-terminal/cat-prefix-gt-tail', 'outside/stability/single-min-evaluates'],
        required_red=['outside/receiver-arity/sub', 'outside/mixed-terminal/cat-prefix-gt-tail']))
    before = (b'  foreach my $arg (@$args) {\n   my $value = _eval_expr($arg, $ctx);\n'
              b'   push @numbers, $value;\n  }\n')
    after = before.replace(b'   push @numbers, $value;',
        b"   $value = 0 + $value if ref($value) eq 'JSON::PP::Boolean';\n   push @numbers, $value;")
    add('boolean-argument-kind', RUNTIME, before, after,
        ['deferred/canonical/invalid_boolean', 'outside/canonical/invalid_boolean',
         'control/boolean-literal-owned-startup35', 'deferred/canonical/add_variadic'],
        ['deferred/canonical/invalid_boolean'])
    before = b'qw(name items meta key value foo i start acc depth)'
    after = b'qw(name items meta key value foo i start missing_acc depth)'
    tasks.append(dict(name='ast-first-operand-observer',
        changes=[dict(path=AST_TEST, before=before, after=after)], command=['prove', '-q', '-Iperl', AST_TEST],
        required_red=['variadic num_' + name + ' preserves the authored bare first value'
                      for name in ('add', 'mul', 'min', 'max')]))
    for task in tasks:
        for change in task['changes']:
            assert c.decode(sources[change['path']]['base64']).count(change['before']) == 1, task['name']
    return tasks


def main():
    full = c.load('candidate2-inputs.json')['plan']
    cases = {case['id']: case for case in full['cases']}
    sources = {path: c.read(path) for path in (RUNTIME, NUMERIC, LOWERING, AST_TEST)}
    assert {path: sources[path] for path in (RUNTIME, NUMERIC, LOWERING)} == c.load('candidate2-inputs.json')['sources']
    tasks = definitions(sources)
    extras = [c.PREFIX + name for name in ('common.py', 'context.py', 'faults.py', 'probe.pl',
                                          'oracle_final.py', 'candidate2-inputs.json')]
    extras.extend('tests/numeric-codeblocks/' + name + '.json'
                  for name in ('cases', 'effects', 'stability', 'receiver-invalid', 'terminals'))
    inputs = context.snapshot(extras)
    encoded = [{**task, 'changes': [dict(path=item['path'], before=c.encode(item['before']),
        after=c.encode(item['after'])) for item in task['changes']]} for task in tasks]
    inputs.update(sources=sources, tasks=encoded,
        limits='Targeted finite cases per actual fault. Every restoration reruns that selected population; '
               'the final restoration separately executes the whole318-case matrix. The AST observer is '
               'a separate consumer-source fault. No all-input/runtime admission is inferred.')
    c.write_new('fault-inputs.json.gz', inputs)
    results = {}
    for task in tasks:
        touched = sorted({change['path'] for change in task['changes']})
        mutated = {path: c.decode(sources[path]['base64']) for path in touched}
        for change in task['changes']:
            assert mutated[change['path']].count(change['before']) == 1
            mutated[change['path']] = mutated[change['path']].replace(change['before'], change['after'], 1)
        plan = None if 'command' in task else dict(cases=[cases[name] for name in task['cases']])
        command = task.get('command', ['perl', '-Iperl', c.PREFIX + 'probe.pl'])
        execute = lambda: c.run(command, **({'input': json.dumps(plan).encode()} if plan is not None else {}))
        try:
            for path, raw in mutated.items():
                (c.ROOT / path).write_bytes(raw)
            syntax = c.run(['perl', '-c', '-Iperl', touched[0]])
            run = execute()
            c.write_new('fault-' + task['name'] + '-observed.json.gz', dict(run=run, syntax=syntax,
                mutant={path: c.identity(path) for path in touched}))
        finally:
            for path in touched:
                (c.ROOT / path).write_bytes(c.decode(sources[path]['base64']))
                (c.ROOT / path).chmod(sources[path]['mode'])
        assert c.unchanged(inputs['inputs'])
        restored = execute()
        if plan is None:
            failures = re.findall(r"Failed test '([^']+)'", c.decode(run['stderr_base64']).decode())
            assert run['returncode'] != 0 and restored['returncode'] == 0
            assert not c.decode(restored['stderr_base64'])
        else:
            failures = oracle.mismatches(run, plan, inputs['inputs'])
            assert not oracle.mismatches(restored, plan, inputs['inputs'])
        c.write_new('fault-' + task['name'] + '.json.gz', dict(run=run, restored=restored, syntax=syntax,
            failures=failures, sources_restored=True, inputs_restored=c.unchanged(inputs['inputs'])))
        assert syntax['returncode'] == 0 and set(task['required_red']) <= set(failures), task['name']
        assert c.unchanged(inputs['inputs'])
        results[task['name']] = failures
        print('Actual fault/restoration:', task['name'], '; RED', len(failures), flush=True)
    restored = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(full).encode())
    c.write_new('fault-full-restoration.json.gz', dict(run=restored,
        inputs_restored=c.unchanged(inputs['inputs'])))
    assert not oracle.mismatches(restored, full, inputs['inputs']) and c.unchanged(inputs['inputs'])
    c.write_new('fault-review.json', dict(faults=results, full_cases=len(full['cases']),
        producer=c.read(c.PREFIX + 'faults.py'), sources_restored=True))
    print('All actual producer/consumer faults restore; full318 GREEN')


if __name__ == '__main__':
    main()
