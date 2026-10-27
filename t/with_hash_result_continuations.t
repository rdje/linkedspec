use strict;
use warnings;
use Test::More;
use JSON::PP ();
use LinkedSpec ();

# TYPE-REFERENCE-BOOK.1.2.23.3.31.1 — ordinary eager with actual-result composition.
my $json = JSON::PP->new->canonical->allow_nonref;
my $sequence = 0;
sub read_file {
 my ($path) = @_;
 open my $fh, '<', $path or die "cannot read $path: $!";
 local $/;
 my $text = <$fh>;
 close $fh or die "cannot close $path: $!";
 return $text;
}
sub check_source {
 my ($label, $source, $input, $expected, $rule, $unsupported) = @_;
 $unsupported //= [];
 return if @ARGV && !grep {$_ eq $label} @ARGV;
 subtest $label => sub {
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $native_input = $input;
  my $native = eval {$parser->(\$native_input)};
  ok(!$@ && !$context{last_error}, 'native has no host error') or diag("$@");
  is($json->encode($native), $json->encode($expected), 'native exact values and kinds');
  my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'with-hash-results.spec');
  my $package = 'LinkedSpec::WithHashResults' . ++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'fresh source compiles') or diag($@);
  if ($loaded) {
   my $fresh_input = $input;
   no strict 'refs';
   my $fresh = eval {&{$package . '::Execute'}(\$fresh_input)};
   ok(!$@, 'fresh has no host error') or diag($@);
   is($json->encode($fresh), $json->encode($expected), 'fresh exact values and kinds');
  }
  my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
  my $meta = $descriptor->{spec}{$rule}{meta}{action_rewriter};
  is($meta->{raw_perl_dependency_count}, 0, 'no raw fallback');
  if (@$unsupported) {
   ok(!$meta->{language_agnostic_action_ir_ready}, 'forbidden function body stays unready');
   my %found = map {$_ => 1} @{$meta->{unresolved_helpers} // []};
   ok($found{$_}, "specific forbidden helper $_") for @$unsupported;
  } else {
   is($meta->{unresolved_helper_count}, 0, 'ordinary source helpers resolve');
   ok($meta->{language_agnostic_action_ir_ready}, 'ready metadata describes working code');
  }
 };
}
sub capture_source {
 my ($action) = @_;
 return "Top::\n -> Value .push\n LX {return(copy(Top))}\nValue:\n /(?<head>name)/\n /=/\n /(?<value>Alpha)/\n -> Value[2] {$action}\n";
}
check_source('frozen returned Hash target', read_file('tests/fixtures/with_hash_result_values.spec'), 'name=Alpha', $json->decode(read_file('tests/fixtures/with_hash_result_values.json')), 'Value');
check_source('actual scalar results skip incompatible operands and restore scope', capture_source(q{
 order="";value="outer";
 a={order=cat(order,"S");"source"}.with(){order=cat(order,"W");return(3)}.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});
 b="source".with(){return("text")}.take({order=cat(order,"A");1});
 c="source".with(){return(["a","b"])}.last().uppercase();
 d="source".with(){return(false)}.coalesce({order=cat(order,"F");true});
 e="source".with(){return(null)}.coalesce({order=cat(order,"N");7}).add(1);
 return([a,b,c,d,e,order,value]);
}), 'name=Alpha', [[undef,undef,'B',JSON::PP::false,8,'SWN','outer']], 'Value');
check_source('nested returned Hash scopes and effects', capture_source(q{
 value="outer";order="";
 result="outside".with(){
  inner="inside".with(){order=cat(order,"I");return({"k":[value]})}.sorted_values().first().first();
  order=cat(order,"O");return({"k":[value,inner]});
 }.sorted_values().first();
 return([result,value,order]);
}), 'name=Alpha', [[['outside','inside'],'outer','IO']], 'Value');
check_source('ordinary pure function keeps scoped local value', 'fn pure(text){return(text.with(){return({"n":[value.uppercase()]})}.sorted_values().first().first())}' . "\n" . 'Top:: I {return(pure("ok"))}', 'x', 'OK', 'Top');
check_source('with body preserves specific pure-function parser-state diagnostic', 'fn forbidden(){return("x".with(){return({"n":[entry_len()]})}.sorted_values().first()[0].uppercase())}' . "\n" . 'Top:: I {return(forbidden())}', 'x', undef, 'Top', ['entry_len']);
if (!@ARGV || grep {$_ eq 'nested with keeps unknown source unready'} @ARGV) {
 subtest 'nested with keeps unknown source unready' => sub {
  my $source = 'Top:: I {return(missing_source().with(){return({"n":[false]})}.sorted_values().first()[0].uppercase())}';
  my $descriptor = LinkedSpec::Get(\$source, return_descriptor => 1);
  my $meta = $descriptor->{spec}{Top}{meta}{action_rewriter};
  is($meta->{raw_perl_dependency_count}, 0, 'unknown call does not acquire raw fallback');
  ok(!$meta->{language_agnostic_action_ir_ready}, 'nested with does not admit unknown sources');
  my %helpers = map {$_ => 1} @{$meta->{unresolved_helpers} // []};
  ok($helpers{missing_source}, 'specific unknown source remains unresolved');
 };
}
done_testing;
