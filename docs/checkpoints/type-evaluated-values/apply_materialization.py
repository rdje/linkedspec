"""Install a shared list-context value boundary after the observed unchanged-runtime RED."""
import gzip
import json
import common as c

assert json.loads((c.ROOT / c.OLD_CLAIM).read_bytes())['claims'][0]['durability']['revision'] == c.BASE
red = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'red-run.json.gz')).read_bytes()))
assert red['syntax']['returncode'] == 0 and red['tap']['returncode'] != 0 and red['inputs_unchanged']
path = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
before = c.read(path)
snapshot = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes()))
assert before == snapshot['inputs'][path]
source = c.decode(before['base64']).decode()
changes = []


def replace(text, old, new, count, scope):
    assert text.count(old) == count, (scope, text.count(old), count)
    changes.append(dict(scope=scope, old=old, new=new, occurrences=count))
    return text.replace(old, new)


helper = '''# Capture each operand before evaluating the next list member. A private array
# preserves explicit flat splices and scalar kinds without deep-copying references.
# Its initializer still resolves caller bindings, even if a rule uses the same name.
sub _materialize_list_operand_expr {
 my ($expr) = @_;
 return undef unless defined($expr) && length($expr);
 return 'do { my @__ls_evaluated_values = ('.$expr.'); @__ls_evaluated_values }'
}

'''
source = replace(source, 'sub _uniform_binding_array_push_expr {',
    helper + 'sub _uniform_binding_array_push_expr {', 1, 'private list operand template')
source = replace(source, 'push @lowered_items, $lowered_item;',
    'push @lowered_items, _materialize_list_operand_expr($lowered_item);', 2, 'typed and legacy shape array members')
source = replace(source, "push @lowered_pairs, $key_expr.' => '.$value_expr;",
    "push @lowered_pairs, _materialize_list_operand_expr($key_expr).' => '._materialize_list_operand_expr($value_expr);",
    2, 'typed and legacy shape hash keys/values')

start = source.index(' $lower_ast_codeblock_variable_call_node = sub {')
end = source.index(' my $ast_string_source_node = sub {', start)
section = replace(source[start:end], 'push @lowered_args, $arg_expr;',
    'push @lowered_args, _materialize_list_operand_expr($arg_expr);', 1, 'bound callable arguments')
source = source[:start] + section + source[end:]

start = source.index("  if ($method eq 'hash'\n      && !(")
end = source.index('\n  my @arg_exprs;', start)
section = replace(source[start:end], 'push @pairs, $flat;',
    'push @pairs, _materialize_list_operand_expr($flat);', 2, 'typed hash explicit splices')
section = replace(section, "push @pairs, $key_expr.' => '.$value_expr;",
    "push @pairs, _materialize_list_operand_expr($key_expr).' => '._materialize_list_operand_expr($value_expr);",
    1, 'typed hash constructor pairs')
source = source[:start] + section + source[end:]
source = replace(source, "return '['.join(', ', @arg_exprs).']'\n   if $method eq 'array' && @arg_exprs != 1;",
    "return '['.join(', ', map { _materialize_list_operand_expr($_) } @arg_exprs).']'\n   if $method eq 'array' && @arg_exprs != 1;",
    1, 'typed multi-argument array constructor')
source = replace(source, 'push @pairs, $flat_pair_expr;',
    'push @pairs, _materialize_list_operand_expr($flat_pair_expr);', 1, 'legacy hash explicit splices')
source = replace(source, "push @pairs, $key_expr.' => '.$val_expr;",
    "push @pairs, _materialize_list_operand_expr($key_expr).' => '._materialize_list_operand_expr($val_expr);",
    1, 'legacy hash constructor pairs')
source = replace(source, "return '['.join(', ', @lowered).']';",
    "return '['.join(', ', map { _materialize_list_operand_expr($_) } @lowered).']';",
    1, 'legacy array constructor')
after = dict(base64=c.encode(source.encode()), sha256=c.sha(source.encode()), mode=before['mode'])
c.write_new(c.PREFIX + 'candidate-proposal.json.gz', dict(path=path, before=before, after=after,
    exact_changes=changes, producer=c.read(c.PREFIX + 'apply_materialization.py'), helper=c.read(c.PREFIX + 'common.py'),
    scope='Only emitted Perl list operands change. AST-to-DSL source rendering, deferred-body '
          'interpretation, helper resolution and scalar consumer contexts remain unchanged. '
          'Per-operand array assignment preserves explicit list splices and existing reference identity.'), packed=True)
(c.ROOT / path).write_bytes(c.decode(after['base64']))
print('List-preserving materialization installed at the recorded emitted-value boundaries')
