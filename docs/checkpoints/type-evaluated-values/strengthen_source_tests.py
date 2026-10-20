"""Replace obsolete source spelling assertions with evaluated typed-value observations."""
import re
import subprocess
import common as c

paths = ('t/actionir_ast_parser.t', 't/trace_actionir_method_lowering.t')
before = {path: c.read(path) for path in paths}
for path, item in before.items():
    assert c.decode(item['base64']) == subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
changes = []


def assertion(text, description, body):
    token = "'" + description + "'"
    assert text.count(token) == 1
    position = text.index(token)
    starts = list(re.finditer(r'(?m)^([ \t]*)is\(\n', text[:position]))
    assert starts
    match = starts[-1]
    start, indent = match.start(), match[1]
    ending = re.search(r'(?m)^[ \t]*\);\n', text[position:])
    assert ending
    end = position + ending.end()
    original = text[start:end]
    assert len(re.findall(r'(?m)^[ \t]*(?:is|is_deeply|like|unlike|ok)\(', original)) == 1
    replacement = '\n'.join(indent + line if line else '' for line in body.strip().splitlines()) + '\n'
    changes.append(dict(description=description, before=original, after=replacement))
    return text[:start] + replacement + text[end:]


path = paths[0]
source = c.decode(before[path]['base64']).decode()
assert source.count('use Test::More;\n') == 1
source = source.replace('use Test::More;\n', 'use Test::More;\nuse JSON::PP ();\n', 1)
anchor = '    return LinkedSpec::ActionIR::AST::parse_action_block($code);\n}\n'
assert source.count(anchor) == 1
helper = r'''

# Observe the emitted behavior without making a private temporary layout public.
# Lexicals cover the fixed poisoned-AST fixtures below; compile/runtime errors are
# part of the single observation and cannot accidentally satisfy a value check.
sub lowered_observation {
    my ($code, $locals) = @_;
    $locals ||= {};
    my ($name, $items, $meta, $key, $value, $foo, $i, $start)
        = @{$locals}{qw(name items meta key value foo i start)};
    my $execute = eval 'sub { ' . $code . ' }';
    return { error => "compile: $@" } unless ref($execute) eq 'CODE';
    my $result;
    my $ok = eval { $result = $execute->(); 1 };
    return $ok ? { value => $result } : { error => "execute: $@" };
}
'''
source = source.replace(anchor, anchor + helper, 1)
source = assertion(source, 'scalar assignment operator lowers RHS from AST fields', r'''
is_deeply(
    lowered_observation($scalar, { value => 'payload' }),
    { value => ['payload'] },
    'scalar assignment operator executes the typed AST RHS'
);
''')
source = assertion(source, 'hash-index assignment lowers key/RHS into the uniform binding mutation', r'''
is_deeply(
    lowered_observation($hash_assign, {
        meta => { keep => 'retained' }, key => 'outer', value => 'payload',
    }),
    { value => { keep => 'retained', outer => { outer => 'payload' } } },
    'hash-index assignment executes the typed key and nested RHS'
);
''')
source = assertion(source, 'direct array shape RHS assignment returns the stored scalar-held array value', r'''
is_deeply(
    lowered_observation(
        LinkedSpec::call_spec_handler_subst('Top', q{return(set(items, [value]))}),
        { value => 'payload' },
    ),
    { value => ['payload'] },
    'direct array shape RHS assignment returns its evaluated typed value'
);
''')
source = assertion(source, 'single-equals operator call returns the stored scalar-held hash value', r'''
is_deeply(
    lowered_observation(
        LinkedSpec::call_spec_handler_subst('Top', q{return(=(meta, { key : value }))}),
        { key => 'field', value => 'payload' },
    ),
    { value => { field => 'payload' } },
    'single-equals operator call returns its evaluated typed hash'
);
''')
source = assertion(source, 'set statement lowers from AST call args', r'''
is_deeply(
    lowered_observation($assign, { value => 'payload' }),
    { value => ['payload'] },
    'set statement executes typed AST call arguments'
);
''')
source = assertion(source, 'return statement lowers payload from AST call args', r'''
is_deeply(
    lowered_observation($return, { value => 'payload' }),
    { value => ['payload'] },
    'return statement executes typed AST call arguments'
);
''')
source = assertion(source, 'AST value lowering preserves shape, scalar-read, literal, and direct-access output', r'''
is_deeply(
    lowered_observation($shape, {
        value => 'payload', key => 'field', foo => { a => ['first', 'second'] }, i => 1,
    }),
    { value => ['payload', JSON::PP::true(), 'second', { field => 'payload' }] },
    'AST value lowering executes shapes, primitive kinds and nested reads'
);
''')
replacements = (
    ("        like($quoted_count, qr/\\[\"items\"\\]/, 'AST aggregate lowering preserves quoted array wrapper literal payloads');",
     "        is_deeply(lowered_observation($quoted_count), { value => 1 }, 'quoted array wrapper payload remains one literal element');"),
    ("        like($constructed, qr/\"span\" => \\[\\$start,/, 'hash constructor reads the typed shape variable');",
     "        is_deeply(lowered_observation($constructed, { start => 7 }), { value => { span => [7, 'x'] } }, 'hash constructor executes the typed shape variable and nested helper');"),
    ("        like($payload, qr/\\{\\$key => \\$value\\}/, 'AST return payload lowers hash literals from typed nodes');",
     "        is_deeply(lowered_observation($payload, { value => 'payload', key => 'field', foo => { a => ['first', 'second'] }, i => 1 }), { value => ['payload', JSON::PP::true(), 'ab', 'second', { field => 'payload' }] }, 'AST return payload executes nested typed hash values');"),
)
for old, new in replacements:
    assert source.count(old) == 1
    source = source.replace(old, new, 1)
    changes.append(dict(description='single-line typed-value observation', before=old, after=new))
after = {path: dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()), mode=before[path]['mode'])}

path = paths[1]
source = c.decode(before[path]['base64']).decode()
old = ''' is($assign, q{$items = ["a", $name]}, 'bare direct-shape assignment stores the scalar-held value');'''
assert source.count(old) == 1
new = r''' my $assigned = eval {
  my ($items, $name) = (undef, 'caller');
  my $execute = eval 'sub { ' . $assign . ' }';
  die $@ unless ref($execute) eq 'CODE';
  $execute->();
  $items;
 };
 diag($@) if $@;
 is_deeply($assigned, ['a', 'caller'], 'bare direct-shape assignment stores the evaluated typed value');'''
source = source.replace(old, new, 1)
changes.append(dict(description='trace assignment value observation', before=old, after=new))
after[path] = dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()), mode=before[path]['mode'])
c.write_new(c.PREFIX + 'source-test-proposals.json.gz', dict(before=before, after=after,
    exact_changes=changes, producer=c.read(c.PREFIX + 'strengthen_source_tests.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Only emitted-layout assertions become execution observations. Poisoned AST source, '
          'static source denial, symbol ownership, parse-entry and trace checks remain. Each '
          'replacement keeps one assertion and includes compile/runtime errors in the result.'), packed=True)
for path, item in after.items():
    assert c.read(path) == before[path]
    (c.ROOT / path).write_bytes(c.decode(item['base64']))
print('AST and trace source checks now observe executed typed values instead of old temporary layout')
