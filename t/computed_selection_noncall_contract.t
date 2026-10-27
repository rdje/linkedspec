use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

sub slurp {
 my ($path) = @_;
 open my $file, '<:encoding(UTF-8)', $path or die "$path: $!";
 local $/;
 return <$file>;
}

my $json = JSON::PP->new->canonical;
my $source = slurp('tests/fixtures/computed_selection_noncall_values.spec');
my $expected = $json->decode(slurp('tests/fixtures/computed_selection_noncall_values.json'));
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $actual = eval { $parser->(\$input) };
is("$@", '', 'native execution has no thrown error');
is($context{last_error}, undef, 'native execution has no handler error');
is($json->encode($actual), $json->encode($expected), 'native computed selections retain kinds and ordered effects');
my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'computed-selection.spec');
my $loaded = eval "package LinkedSpec::ComputedSelectionGenerated; $emitted; 1";
ok($loaded, 'fresh parser compiles') or diag($@);
if ($loaded) {
 my $input = 'x';
 my $value = eval { LinkedSpec::ComputedSelectionGenerated::Execute(\$input) };
 is("$@", '', 'fresh execution has no thrown error');
 is($json->encode($value), $json->encode($expected), 'fresh computed selections retain kinds and ordered effects');
}

my $scoped_source = q{fn choose(input) { return({scratch="!";input.split(",")}[{position=-1;position}].uppercase().cat(scratch)) }
Top:: I { scratch="outer";position=9;return([choose("a,b"),scratch,position]); }};
my %scoped_context;
my $scoped_parser = LinkedSpec::Get(\$scoped_source, runtime_ctx_ref => \%scoped_context);
my $scoped_input = 'x';
my $scoped_value = $scoped_parser->(\$scoped_input);
is($scoped_context{last_error}, undef, 'computed-source function locals have no handler error');
is($json->encode($scoped_value), $json->encode(['B!','outer',9]), 'source and selector assignments stay function-local');
my $scoped_emitted = LinkedSpec::emit_generated_source(\$scoped_source, source_identity => 'computed-selection-locals.spec');
my $scoped_loaded = eval "package LinkedSpec::ComputedSelectionLocalsGenerated; $scoped_emitted; 1";
ok($scoped_loaded, 'fresh computed-local parser compiles') or diag($@);
if ($scoped_loaded) {
 my $input = 'x';
 my $value = eval { LinkedSpec::ComputedSelectionLocalsGenerated::Execute(\$input) };
 is("$@", '', 'fresh computed-local execution has no thrown error');
 is($json->encode($value), $json->encode(['B!','outer',9]), 'fresh source and selector assignments stay local');
}


my $text = q{"a,b,c".split(",")[-2].uppercase()};
my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($text, {base_start => 11});
is($node->{kind}, 'fluent_chain', 'consumer is a typed fluent chain');
my $access = $node->{receiver} || {};
is($access->{kind}, 'value_access', 'computed receiver uses value_access');
if (($access->{kind} // '') eq 'value_access') {
 is($access->{receiver}{kind}, 'fluent_chain', 'selection retains its typed producer chain');
 is($access->{receiver}{receiver}{value}, 'a,b,c', 'producer retains its String value');
 is($access->{receiver}{calls}[0]{method}, 'split', 'producer retains its method');
 is($access->{segments}[0]{kind}, 'index', 'numeric segment stays an index');
 is($access->{segments}[0]{expr}{value}, -2, 'signed selector stays numeric');
 my $suffix = index($text, '[-2]');
 is_deeply($access->{segments}[0]{source_span}, {start => 11+$suffix, end => 15+$suffix}, 'selector source span is authored');
 is($access->{source}, substr($text, 0, $suffix+4), 'computed access retains exact source');
}
for my $case (
 [q{["🙂","b"][-1]}, 'array_literal'],
 [q{{"items":[1]}["items"]}, 'hash_literal'],
 [q{{[1,2]}[0]}, 'block_value'],
) {
 my $parsed = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($case->[0]);
 is($parsed->{kind}, 'value_access', "$case->[1] source has typed selection");
 is(($parsed->{receiver} || {})->{kind}, $case->[1], "$case->[1] receiver is preserved");
 is_deeply($parsed->{source_span}, {start => 0, end => length($case->[0])}, "$case->[1] span counts authored characters");
}
my $quoted = LinkedSpec::ActionIR::AST::Parser::parse_action_expr(q{["a[0].b","c"][-2]});
is($quoted->{receiver}{items}[0]{value}, 'a[0].b', 'brackets and dots inside text remain payload');
my $regex = LinkedSpec::ActionIR::AST::Parser::parse_action_expr(q{"aXb".split(/[x]/i)[1]});
is($regex->{receiver}{calls}[0]{args}[0]{kind}, 'regex', 'brackets inside a regex stay in its literal operand');
my $bare = LinkedSpec::ActionIR::AST::Parser::parse_action_expr('items[-1]');
is($bare->{kind}, 'indexed_var', 'existing bare-binding reader stays indexed_var');
my $nested = LinkedSpec::ActionIR::AST::Parser::parse_action_expr('items[0][1]');
is($nested->{kind}, 'nested_access', 'existing named nested reader stays nested_access');
my $grouped = LinkedSpec::ActionIR::AST::Parser::parse_action_expr('(items)[0]');
is($grouped->{kind}, 'raw_perl', 'grouping boundary remains separately owned');
my $write = eval { LinkedSpec::ActionIR::AST::Parser::parse_action_expr('[1][0] = 2') };
ok(!$write, 'computed selection does not become a mutation target');
like("$@", qr/nested write root must remain a bare identifier/, 'computed writes retain the existing syntax diagnostic');
done_testing() unless caller;
1;
