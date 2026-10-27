use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

# TYPE-REFERENCE-BOOK.1.2.23.3.25.0: contextual callbacks share the explicit
# literal's existing executor vocabulary; ordinary compiled blocks stay broader.
my $json = JSON::PP->new->canonical;
my $sequence = 0;
sub execute_routes {
 my ($source) = @_;
 my %context;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
 my $input = 'x';
 my $native = eval { $parser->(\$input) };
 my $native_error = $@ || $context{last_error};
 my $emitted = LinkedSpec::emit_generated_source(\$source,
  source_identity => 'computed-contextual-boundary.spec');
 my $package = 'LinkedSpec::ComputedContextualBoundary'.++$sequence;
 my $loaded = eval "package $package; $emitted; 1";
 ok($loaded, 'fresh contextual parser compiles') or diag($@);
 my ($fresh, $fresh_error);
 if ($loaded) {
  my $input = 'x';
  no strict 'refs';
  $fresh = eval { &{$package.'::Execute'}(\$input) };
  $fresh_error = $@;
 }
 return ([native => $native, $native_error], [fresh => $fresh, $fresh_error]);
}

for my $body ('split("a,b",",")[0]', '["a","b"][0]') {
 for my $form (qw(literal attached parenthesized)) {
  subtest "$form $body" => sub {
   my $argument = $form eq 'literal' ? "{|| return($body)}" : "{return($body)}";
   my $call = $form eq 'attached' ? "apply() $argument" : "apply($argument)";
   my $source = "fn apply(callback: codeblock) {return(callback())}\nTop:: I {return($call)}";
   for my $row (execute_routes($source)) {
    my ($route, $value, $error) = @$row;
    is($value, undef, "$route unsupported read has no value");
    my $detail = (reftype($error) // '') eq 'HASH' ? $error->{detail} : undef;
    is_deeply((reftype($detail) // '') eq 'HASH'
     ? {map {$_ => $detail->{$_}} qw(code kind)} : undef,
     {code => 'unsupported_codeblock_actionir', kind => 'raw_perl'},
     "$route preserves explicit-literal error identity");
   }
   my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
   my $metadata = $descriptor->{spec}{Top}{meta}{action_rewriter};
   is($metadata->{raw_perl_dependency_count}, 1, 'raw dependency is retained');
   is($metadata->{unresolved_helper_count}, 0, 'no unrelated unresolved helper');
   ok(!$metadata->{language_agnostic_action_ir_ready}, 'unsupported body stays unready');
  };
 }
}

my $control = q{
 fn apply(callback: codeblock) {return(callback())}
 fn choose(items, callback: codeblock) {return(callback())}
 fn wrap(value) {return(value)}
 Top:: I {
  items=["a","b"];
  unused=apply({return(items[-1])});
  ordinary=wrap({split("a,b",",")[0]});
  inline=["x"].with() {return(["a","b"][-1])};
  named=apply() {return(items[-1])};
  passed=choose(items) {return(items[-1])};
  after=split("a,b",",")[-1];
  return([unused,ordinary,inline,named,passed,after]);
 }
};
for my $row (execute_routes($control)) {
 my ($route, $value, $error) = @$row;
 ok(!$error, "$route ordinary/inline/named/restored scopes have no error");
 # Pure functions expose invocation-local slots, not implicit caller captures.
 is($json->encode($value), $json->encode([undef,'a','b',undef,'b','b']),
  "$route ordinary arguments and immediate blocks keep computed reads");
}

my $registry = {by_name => {
 apply => {kind => 'user_function_definition', name => 'apply',
  params => ['callback'], arity => 1, parameter_kinds => {callback => 'codeblock'}},
 wrap => {kind => 'user_function_definition', name => 'wrap', params => ['value'], arity => 1},
}};
for my $source ('apply() {return(["🙂","b"][0])}', 'apply({return(["🙂","b"][0])})') {
 local $LinkedSpec::ActionIR::AST::Parser::_registered_function_registry = $registry;
 my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source, {base_start => 17});
 my $read = $node->{args}[-1]{block}{statements}[0]{expr}{args}[0];
 is($read->{kind}, 'raw_perl', 'registered final role retains deferred AST boundary');
 is($read->{source}, '["🙂","b"][0]', 'deferred raw source is exact');
 my $offset = index($source, $read->{source});
 is_deeply($read->{source_span}, {start => 17+$offset, end => 17+$offset+length($read->{source})},
  'contextual raw span counts Unicode scalars');
 is(LinkedSpec::ActionIR::AST::Parser::parse_action_expr('[1][0]')->{kind},
  'value_access', 'callback parse restores ordinary grammar');
}
for my $source ('wrap() {return([1][0])}', 'apply(1) {return([1][0])}') {
 local $LinkedSpec::ActionIR::AST::Parser::_registered_function_registry = $registry;
 my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source);
 is($node->{args}[-1]{block}{statements}[0]{expr}{args}[0]{kind}, 'value_access',
  'only an accepted final-codeblock signature/count fences the body');
}
{
 local $LinkedSpec::ActionIR::AST::Parser::_registered_function_registry = $registry;
 eval { LinkedSpec::ActionIR::AST::Parser::parse_action_expr('apply() {[1][0]=2}') };
 like("$@", qr/nested write root must remain a bare identifier/, 'callback syntax error is retained');
 is(LinkedSpec::ActionIR::AST::Parser::parse_action_expr('[1][0]')->{kind},
  'value_access', 'callback parse failure restores ordinary grammar');
}
done_testing() unless caller;
1;
