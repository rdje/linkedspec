"""Prepare source-fault actors and admit the unchanged passing case population."""
import common as c
import context


def main():
    assert not c.load('candidate1-run.json.gz')['failures']
    c.write_new('checks-preparation-inputs.json.gz', context.snapshot())
    origin = 'docs/checkpoints/type-sort-copy-kinds/'
    text = c.source(origin+'faults.py').read_text()
    start, end = text.index('    implementation = '), text.index("    plan = c.load('cases.json')")
    text = text[:start]+'''    implementation = c.load('implementation.json.gz')
    runtime, emitter = c.SOURCES[:2]
    replacements = implementation['replacements']
    tasks = [
        ('free-dispatch',runtime,replacements[0]['new'],replacements[0]['old'],'deferred/count/free/integers'),
        ('receiver-dispatch',runtime,replacements[3]['new'],replacements[3]['old'],'deferred/first/receiver/integers'),
        ('free-arity',runtime,'  return undef unless @$args == 1;\\n  my $value = _eval_expr($args->[0], $ctx);',
            '  my $value = _eval_expr($args->[0], $ctx);','deferred/count/effects/free/extra'),
        ('receiver-arity',runtime,'   return undef if @$args || $index < $#$calls;',
            '   return undef if $index < $#$calls;','deferred/first/effects/receiver/extra'),
        ('terminal-effects',runtime,'   return undef if @$args || $index < $#$calls;',
            '   return undef if @$args;','deferred/count/effects/receiver/continuation'),
        ('first-selection',runtime," return ref($value) eq 'ARRAY' && @$value ? $value->[0] : undef",
            " return ref($value) eq 'ARRAY' && @$value ? $value->[-1] : undef",'deferred/first/free/integers'),
        ('count-kind',emitter,replacements[4]['new'],replacements[4]['old'],'ordinary/count/free/harray'),
        ('first-kind',emitter,replacements[5]['new'],replacements[5]['old'],'ordinary/first/free/harray'),
    ]
''' + text[end:]
    text = text.replace('for path in c.SOURCES + [\'perl/LinkedSpec/CodeblockRuntime.pm\']:',
        'for path in c.SOURCES + [\'perl/LinkedSpec.pm\']:')
    with (c.ROOT/c.PREFIX/'faults.py').open('x') as output:
        output.write(text)
    with (c.ROOT/c.PREFIX/'focused.py').open('xb') as output:
        output.write(c.source(origin+'focused.py').read_bytes())
    target = 'tests/numeric-codeblocks/count-first.json'
    with (c.ROOT/target).open('xb') as output:
        output.write(c.source(c.PREFIX+'cases.json').read_bytes())
    path = 't/scalar_numeric_contract.t'
    before = c.read(path)
    old = 'qw(cases effects stability receiver-invalid terminals pipelines sort-kinds)'
    value = c.decode(before['base64']).decode()
    assert value.count(old) == 1
    c.source(path).write_text(value.replace(old,old[:-1]+' count-first)',1))
    c.source(path).chmod(before['mode'])
    c.write_new('permanent.json.gz', dict(before=before,after=c.read(path),path=path,
        fixture=c.read(target),cases=len(c.load('cases.json')['cases']),
        producers={name:c.read(c.PREFIX+name) for name in ('prepare_checks.py','faults.py','focused.py')}))
    print('Permanent232 native/fresh cases; eight actual source-fault controls prepared')


if __name__ == '__main__':
    main()
