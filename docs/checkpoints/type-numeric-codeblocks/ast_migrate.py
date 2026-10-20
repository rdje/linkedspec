"""Keep authored bare-operand coverage as numeric values instead of stack spelling."""
import re
import subprocess
import common as c

TEST = 't/actionir_ast_parser.t'


def main():
    before = c.read(TEST)
    assert c.decode(before['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + TEST], cwd=c.ROOT)
    paths = set(c.load('phase0-after-inputs.json')['inputs'])
    paths.add(c.PREFIX + 'ast_migrate.py')
    inputs = {path: c.identity(path) for path in sorted(paths)}
    c.write_new('ast-before-inputs.json', dict(inputs=inputs, test=before))
    command = ['prove', '-q', '-Iperl', TEST]
    baseline = c.run(command)
    c.write_new('ast-before-run.json.gz', dict(run=baseline, inputs_unchanged=c.unchanged(inputs)))
    expected_names = {'variadic num_' + method + ' preserves the authored bare first value'
                      for method in ('add', 'mul', 'min', 'max')}
    failed = set(re.findall(r"Failed test '([^']+)'", c.decode(baseline['stderr_base64']).decode()))
    assert baseline['returncode'] != 0 and expected_names <= failed
    assert c.unchanged(inputs)
    text = c.decode(before['base64']).decode()
    old = 'my ($name, $items, $meta, $key, $value, $foo, $i, $start)\n        = @{$locals}{qw(name items meta key value foo i start)};'
    new = 'my ($name, $items, $meta, $key, $value, $foo, $i, $start, $acc, $depth)\n        = @{$locals}{qw(name items meta key value foo i start acc depth)};'
    assert text.count(old) == 1
    text = text.replace(old, new, 1)
    changes = []
    for method, args, value in [('add', 'acc,value,depth', 9), ('mul', 'acc,value,depth', 24),
                                ('min', 'acc,value', 2), ('max', 'acc,value', 3)]:
        description = 'variadic num_' + method + ' preserves the authored bare first value'
        pos = text.index("'" + description + "'")
        start = text.rfind('    like(\n', 0, pos)
        end = text.index('    );\n', pos) + len('    );\n')
        original = text[start:end]
        assert original.count('qr/') == 1 and 'num_' + method + '(' + args + ')' in original
        replacement = ("    is_deeply(\n        lowered_observation(\n"
            + '            $L->(q{num_' + method + '(' + args + ')}),\n'
            + '            { acc => 2, value => 3, depth => 4 },\n'
            + '        ),\n        { value => ' + str(value) + ' },\n'
            + "        '" + description + "'\n    );\n")
        changes.append(dict(id=description, before=original, after=replacement, expected=value))
        text = text[:start] + replacement + text[end:]
    raw = text.encode()
    c.write_new('ast-proposals.json.gz', dict(before=before, after=c.encode(raw), changes=changes,
        producer=c.read(c.PREFIX + 'ast_migrate.py'),
        scope='Exactly four bare-first-operand assertions observe independent 2/3/4 scalar goldens. '
              'The existing observer only gains acc/depth fixture locals; previous locals retain positions.'))
    (c.ROOT / TEST).write_bytes(raw)
    after_inputs = {path: c.identity(path) for path in sorted(paths)}
    c.write_new('ast-after-inputs.json', dict(inputs=after_inputs, command=command))
    result = c.run(command)
    c.write_new('ast-after-run.json.gz', dict(run=result, inputs_unchanged=c.unchanged(after_inputs)))
    assert result['returncode'] == 0 and not c.decode(result['stderr_base64'])
    assert c.unchanged(after_inputs)
    print('AST numeric consumers: four spelling REDs become value GREEN; full suite PASS')


if __name__ == '__main__':
    main()
