use strict;
use warnings;
use utf8;
use Test::More;
use JSON::PP ();
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();

my $json = JSON::PP->new->canonical;
my $sequence = 0;
sub slurp {
 my ($path) = @_;
 open my $file, '<:encoding(UTF-8)', $path or die "$path: $!";
 local $/; return <$file>;
}
sub check_source {
 my ($label, $source, $input, $expected, $rule) = @_;
 $rule //= 'Value';
 subtest $label => sub {
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $native_input = $input;
  my $actual = eval { $parser->(\$native_input) };
  is("$@", '', 'native has no thrown error');
  is($context{last_error}, undef, 'native has no context error');
  is($json->encode($actual), $json->encode($expected), 'native exact values/kinds/effects');
  my $emitted = LinkedSpec::emit_generated_source(\$source,
   source_identity => 'capture-collection-selection.spec');
  my $package = 'LinkedSpec::CaptureCollectionRegression'.++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'fresh parser compiles') or diag($@);
  if ($loaded) {
   my $fresh_input = $input;
   no strict 'refs';
   my $value = eval { &{$package.'::Execute'}(\$fresh_input) };
   is("$@", '', 'fresh has no thrown error');
   is($json->encode($value), $json->encode($expected), 'fresh exact values/kinds/effects');
  }
  my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
  my $metadata = $descriptor->{spec}{$rule}{meta}{action_rewriter};
  is($metadata->{raw_perl_dependency_count}, 0, 'capture selections are typed');
  is($metadata->{unresolved_helper_count}, 0, 'capture helpers stay resolved');
  ok($metadata->{language_agnostic_action_ir_ready}, 'ordinary capture selection is ready');
 };
}

check_source('unchanged frozen capture target',
 slurp('tests/fixtures/capture_collection_selection_values.spec'), 'name=Alpha',
 $json->decode(slurp('tests/fixtures/capture_collection_selection_values.json')));

my $source = <<'SPEC';
Top::
 -> Value .push
 LX {return(copy(Top))}
Value:
 /(?<head>0)(?<empty>)(?<missing>x)?/
 /=/
 /(?<value>Alpha)(?<empty>)(?<missing>x)?/
 -> Value[1] {separator=match_text()}
 -> Value[2] {
  entry_groups={|| return(["shadow"]) };
  match_map={|| return({"value":"shadow"}) };
  return([entry_groups()[0],entry_groups()[1],entry_groups()[2].coalesce("missing"),entry_map()["head"].is_defined(),entry_map()["empty"].is_defined(),entry_map()["empty"],match_groups()[-1],match_map()["value"],entry_named_map()["head"],match_named_map()["empty"]]);
 }
SPEC
check_source('String zero empty compaction and static helper ownership', $source, '0=Alpha',
 # Definedness retains Perl's numeric true; capture payloads stay Strings.
 [['0','','missing',1,1,'','','Alpha','0','']]);

check_source('no local capture produces missing reads', q{
Top:: I {return([entry_groups()[0],entry_map()["absent"],match_groups()[-1],match_map()["absent"]])}
}, 'x', [undef,undef,undef,undef], 'Top');

my $text = 'entry_map()["🙂"].uppercase()';
my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($text, {base_start => 17});
is($node->{kind}, 'fluent_chain', 'capture result consumer remains a typed chain');
my $read = $node->{receiver} || {};
is($read->{kind}, 'value_access', 'capture helper is a typed read source');
is($read->{receiver}{name}, 'entry_map', 'static source identity is retained');
is_deeply($read->{segments}[0]{source_span}, {start => 28, end => 33}, 'quoted selector span counts Unicode scalars');
for my $source ('entry_text()[0]', 'cursor_rest()[0]', 'flat([1])[0]', '(items)[0]', 'unknown()[0]') {
 is(LinkedSpec::ActionIR::AST::Parser::parse_action_expr($source)->{kind}, 'raw_perl',
  "unrelated source boundary remains raw: $source");
}
for my $source ('entry_groups()[-1]', 'entry_map()["head"]', 'match_groups()[-1]',
 'match_map()["value"]', 'entry_named_map()["head"]', 'match_named_map()["value"]') {
 my $literal = LinkedSpec::ActionIR::AST::Parser::parse_action_expr('{|| return('.$source.') }');
 is($literal->{body_ast}{statements}[0]{expr}{args}[0]{kind}, 'raw_perl',
  "deferred source retains existing vocabulary: $source");
 local $LinkedSpec::ActionIR::AST::Parser::_registered_function_registry = {by_name => {
  apply => {kind => 'user_function_definition', name => 'apply', params => ['callback'],
   arity => 1, parameter_kinds => {callback => 'codeblock'}},
 }};
 for my $call ('apply() {return('.$source.')}', 'apply({return('.$source.')})') {
  my $node = LinkedSpec::ActionIR::AST::Parser::parse_action_expr($call);
  is($node->{args}[-1]{block}{statements}[0]{expr}{args}[0]{kind}, 'raw_perl',
   "contextual callback keeps deferred vocabulary: $call");
 }
}
done_testing() unless caller;
1;
