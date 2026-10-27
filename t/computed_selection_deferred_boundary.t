use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

my $json = JSON::PP->new->canonical;
my $source = q{Top:: I { thunk={|| return(["a","b"][-1]) };return(thunk()) }};
my %context;
my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
my $input = 'x';
my $value = eval { $parser->(\$input) };
is("$@", '', 'native handler preserves its error envelope');
is($value, undef, 'unsupported deferred operation has no value');
my $native_error = $context{last_error}{detail};
is(reftype($native_error), 'HASH', 'native deferred error retains structured fields');
is_deeply(reftype($native_error) && reftype($native_error) eq 'HASH'
 ? {code => $native_error->{code}, kind => $native_error->{kind}} : undef,
 {code => 'unsupported_codeblock_actionir', kind => 'raw_perl'}, 'native deferred error identity is unchanged');
my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
is($metadata->{raw_perl_dependency_count}, 1, 'deferred source retains its raw dependency');
ok(!$metadata->{language_agnostic_action_ir_ready}, 'unsupported deferred source remains not ready');
my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'computed-deferred-boundary.spec');
my $loaded = eval "package LinkedSpec::ComputedDeferredBoundaryGenerated; $emitted; 1";
ok($loaded, 'fresh deferred parser compiles') or diag($@);
if ($loaded) {
 my $input = 'x';
 my $ok = eval { LinkedSpec::ComputedDeferredBoundaryGenerated::Execute(\$input); 1 };
 my $error = $@;
 ok(!$ok, 'fresh deferred execution still rejects');
 is(ref($error), 'HASH', 'fresh execution preserves its public envelope');
 my $detail = ref($error) eq 'HASH' ? $error->{detail} : undef;
 is(reftype($detail), 'HASH', 'fresh deferred error retains structured fields');
 is_deeply(reftype($detail) && reftype($detail) eq 'HASH'
  ? {code => $detail->{code}, kind => $detail->{kind}} : undef,
  {code => 'unsupported_codeblock_actionir', kind => 'raw_perl'}, 'fresh deferred error identity is unchanged');
}

my $control = q{Top:: I {
 items=["a","b"];
 unused={|| return(["a","b"][-1]) };
 named={|| return(items[-1]) };
 ordinary=["a","b"][-1];
 inline=["a","b"].with() {return(["a","b"][-1])};
 return([ordinary,inline,named()]);
}};
my %control_context;
my $control_parser = LinkedSpec::Get(\$control, runtime_ctx_ref => \%control_context);
my $control_input = 'x';
my $actual = $control_parser->(\$control_input);
is($control_context{last_error}, undef, 'ordinary/inline/named controls have no handler error');
is($json->encode($actual), $json->encode(['b','b','b']), 'ordinary reads and existing named deferred reads stay supported');
my $control_source = LinkedSpec::emit_generated_source(\$control, source_identity => 'computed-deferred-controls.spec');
my $control_loaded = eval "package LinkedSpec::ComputedDeferredControlsGenerated; $control_source; 1";
ok($control_loaded, 'fresh controls compile') or diag($@);
if ($control_loaded) {
 my $input = 'x';
 my $actual = eval { LinkedSpec::ComputedDeferredControlsGenerated::Execute(\$input) };
 is("$@", '', 'fresh controls have no thrown error');
 is($json->encode($actual), $json->encode(['b','b','b']), 'fresh ordinary/inline/named controls stay supported');
}

my $literal = q{{|| return(["🙂","b"][-1]) }};
my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($literal, {base_start => 17});
my $raw = $node->{body_ast}{statements}[0]{expr}{args}[0];
is($raw->{kind}, 'raw_perl', 'deferred literal retains pre-feature AST kind');
is($raw->{source}, q{["🙂","b"][-1]}, 'deferred source is exact');
my $offset = index($literal, $raw->{source});
is_deeply($raw->{source_span}, {start => 17+$offset, end => 17+$offset+length($raw->{source})}, 'deferred raw span retains Unicode-scalar offsets');
my $ordinary = LinkedSpec::ActionIR::AST::Parser::parse_action_expr(q{["a","b"][-1]});
is($ordinary->{kind}, 'value_access', 'literal parsing restores ordinary grammar scope');
eval { LinkedSpec::ActionIR::AST::Parser::parse_action_expr(q{{|| [1][0]=2 }}) };
like("$@", qr/nested write root must remain a bare identifier/, 'invalid deferred write retains syntax error');
my $after_failure = LinkedSpec::ActionIR::AST::Parser::parse_action_expr(q{["a","b"][-1]});
is($after_failure->{kind}, 'value_access', 'parse failure also restores ordinary grammar scope');
done_testing() unless caller;
1;
