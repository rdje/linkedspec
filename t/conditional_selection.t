use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

my $json = JSON::PP->new->canonical;
my $sequence = 0;
sub slurp {
 my ($path) = @_;
 open my $file, '<:encoding(UTF-8)', $path or die "$path: $!";
 local $/; return <$file>;
}
sub routes {
 my ($source) = @_;
 my %context;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
 my $input = 'x';
 my $native = eval { $parser->(\$input) };
 my $error = $@ || $context{last_error};
 my $emitted = LinkedSpec::emit_generated_source(\$source,
  source_identity => 'conditional-selection.spec');
 my $package = 'LinkedSpec::ConditionalSelection'.++$sequence;
 my $loaded = eval "package $package; $emitted; 1";
 ok($loaded, 'fresh conditional parser compiles') or diag($@);
 my ($fresh, $fresh_error);
 if ($loaded) {
  my $input = 'x'; no strict 'refs';
  $fresh = eval { &{$package.'::Execute'}(\$input) };
  $fresh_error = $@;
 }
 return ([native => $native, $error], [fresh => $fresh, $fresh_error]);
}
sub metadata {
 my ($source) = @_;
 return LinkedSpec::Get(\$source, return_descriptor => 1)->{spec}{Top}{meta}{action_rewriter};
}
sub check_source {
 my ($label, $source, $expected) = @_;
 subtest $label => sub {
  for my $row (routes($source)) {
   my ($route, $value, $error) = @$row;
   ok(!$error, "$route no runtime error") or diag("$error");
   is($json->encode($value), $json->encode($expected), "$route exact values/kinds/effects");
  }
  my $meta = metadata($source);
  is($meta->{raw_perl_dependency_count}, 0, 'inline selections stay typed');
  is($meta->{unresolved_helper_count}, 0, 'inline value helpers remain resolved');
  ok($meta->{language_agnostic_action_ir_ready}, 'ordinary conditional selection is ready');
 };
}
check_source('unchanged frozen conditional target', slurp('tests/fixtures/conditional_selection_values.spec'),
 $json->decode(slurp('tests/fixtures/conditional_selection_values.json')));
check_source('function conditional selector and condition locals', q{
 fn choose(flag) {return(if({scratch="inner";flag},[{"items":["a","b"]}],[])[{position=-1;position}]["items"][-1].uppercase())}
 Top:: I {scratch="outer";position=9;return([choose(true),scratch,position]);}
}, ['B','outer',9]);
check_source('no matching payload or fallback stays missing', q{Top:: I {
 return([if(false,[1])[0],switch("other",case("k",[1]))[0]]);
}}, [undef,undef]);

my $text = 'if(true,["🙂","b"],[])[-1]';
my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($text, {base_start => 11});
is($node->{kind}, 'value_access', 'inline value call is a typed read source');
is($node->{receiver}{name}, 'if', 'inline source identity stays static');
my $offset = index($text, '[-1]');
is_deeply($node->{segments}[0]{source_span}, {start => 11+$offset, end => 15+$offset},
 'conditional selector span counts Unicode scalars');
for my $source ('if(true)[0]', 'switch()[0]', 'switch("k")[0]', 'i(true,[1],[])[0]', 'case("k",[1])[0]',
 'while(true)[0]', 'return([1])[0]', 'unknown()[0]', 'flat([1])[0]', '(items)[0]') {
 is(LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source)->{kind}, 'raw_perl',
  "unrelated or non-value control role stays raw: $source");
}
for my $body ('if(true,[1],[])[0]', 'switch("k",case("k",[1]))[0]') {
 my $literal = LinkedSpec::ActionIR::AST::Parser::parse_action_expr('{|| return('.$body.') }');
 is($literal->{body_ast}{statements}[0]{expr}{args}[0]{kind}, 'raw_perl', 'explicit callback vocabulary stays bounded');
 local $LinkedSpec::ActionIR::AST::Parser::_registered_function_registry = {by_name => {
  apply => {kind => 'user_function_definition', name => 'apply', params => ['callback'],
   arity => 1, parameter_kinds => {callback => 'codeblock'}},
 }};
 for my $source ('apply() {return('.$body.')}', 'apply({return('.$body.')})') {
  my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source);
  is($node->{args}[-1]{block}{statements}[0]{expr}{args}[0]{kind}, 'raw_perl',
   'contextual callback vocabulary stays bounded');
 }
}
my $deferred = q{fn apply(callback: codeblock) {return(callback())}
 Top:: I {return(apply() {return(if(true,[1],[])[0])})}};
for my $row (routes($deferred)) {
 my ($route, $value, $error) = @$row;
 is($value, undef, "$route deferred selection remains unsupported");
 my $detail = (reftype($error) // '') eq 'HASH' ? $error->{detail} : undef;
 is_deeply((reftype($detail) // '') eq 'HASH' ? {map {$_ => $detail->{$_}} qw(code kind)} : undef,
  {code => 'unsupported_codeblock_actionir', kind => 'raw_perl'}, "$route original deferred error");
}
my $meta = metadata($deferred);
is($meta->{raw_perl_dependency_count}, 1, 'deferred read retains its raw dependency');
ok(!$meta->{language_agnostic_action_ir_ready}, 'deferred read remains unready');

for my $producer ('if(and(),[1],[])', 'switch(and(),case("k",[1]))') {
 my $source = 'Top:: I {return('.$producer.'[0])}';
 for my $row (routes($source)) {
  my ($route, $value, $error) = @$row;
  is(reftype($error), 'HASH', "$route conditional source preserves structured error");
  is((reftype($error) // '') eq 'HASH' ? $error->{code} : undef, 'helper_arity_mismatch', 'original source error code');
  is((reftype($error) // '') eq 'HASH' ? $error->{helper_name} : undef, 'and', 'original source helper');
 }
}
done_testing() unless caller;
1;
