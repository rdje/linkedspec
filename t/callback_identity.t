use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(reftype refaddr);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();

# TYPE-REFERENCE-BOOK.1.2.23.3.31.6.4.2 — close origin-matched cycles.
my $json = JSON::PP->new->canonical->allow_nonref;
my $sequence = 0;
my @cases = (
 ['contextual nesting', q{value="outer";result=with("outside"){return(with("inside"){return(value)})};return([result,value]);}, ['inside','outer']],
 ['explicit nesting', q{value="saved";result=with("outer",{|outer|return(with("inner",{|inner|return(cat(outer,inner))}))});return([result,value,if(is_defined(outer),outer,"missing"),if(is_defined(inner),inner,"missing")]);}, ['outerinner','saved','missing','missing']],
 ['helper cycle', q{calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,cb),"escaped"))};return(cb("x"));}, undef, ['cb','cb']],
 ['receiver cycle', q{calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),v.with(cb),"escaped"))};return(cb("x"));}, undef, ['cb','cb']],
 ['accepted opaque if cycle', q{calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),with(v,if(true,cb,cb)),"escaped"))};return(cb("x"));}, undef, ['cb','cb']],
 ['direct cycle', q{calls=0;cb={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),cb(v),"escaped"))};return(cb("x"));}, undef, ['cb','cb']],
 ['mutual cycle', q{calls=0;a={|v|calls=num_add(calls,1);return(if(num_lt(calls,4),b(v),"escaped"))};b={|v|return(a(v))};return(a("x"));}, undef, ['a','b','a']],
);
sub check_cycle {
 my ($detail, $cycle, $route) = @_;
 isa_ok($detail, 'LinkedSpec::CodeblockRuntime::Error', "$route typed callback error");
 is($detail->{code}, 'codeblock_recursion_unsupported', "$route exact code");
 is_deeply($detail->{cycle}, $cycle, "$route exact ordered callback cycle");
}
for my $case (@cases) {
 next if @ARGV && !grep {$_ eq $case->[0]} @ARGV;
 subtest $case->[0] => sub {
  my $source = "Top:: I {$case->[1]}";
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  my $actual = $parser->(\$input);
  if ($case->[3]) {
   is($actual, undef, 'native rejects cyclic invocation');
   check_cycle($context{last_error}{detail}, $case->[3], 'native');
  } else {
   is($context{last_error}, undef, 'native no handler error');
   is($json->encode($actual), $json->encode($case->[2]), 'native exact values and kinds');
  }
  my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'callback-identity.spec');
  my $package = 'LinkedSpec::CallbackIdentity' . ++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'fresh source compiles') or diag($@);
  return unless $loaded;
  my ($fresh, $failure);
  {
   no strict 'refs';
   my $fresh_input = 'x';
   eval {$fresh = &{$package . '::Execute'}(\$fresh_input); 1} or $failure = $@;
  }
  if ($case->[3]) {
   is(ref($failure), 'HASH', 'fresh structured wrapper');
   return unless ref($failure) eq 'HASH';
   is($failure->{type}, 'generated_source_error', 'fresh error type');
   is($failure->{code}, 'generated_execution_failed', 'fresh wrapper code');
   is($failure->{stage}, 'execute_generated', 'fresh wrapper stage');
   is($failure->{source_identity}, 'callback-identity.spec', 'fresh source identity');
   my $detail = $failure->{detail};
   while ((reftype($detail) // '') eq 'HASH' && ($detail->{type} // '') eq 'generated_source_error') {
    $detail = $detail->{detail};
   }
   check_cycle($detail, $case->[3], 'fresh');
  } else {
   is($failure, undef, 'fresh no execution error');
   is($json->encode($fresh), $json->encode($case->[2]), 'fresh exact values and kinds');
  }
 };
}
if (!@ARGV || grep {$_ eq 'copied aliases and independent records'} @ARGV) {
 subtest 'copied aliases and independent records' => sub {
  my $record = LinkedSpec::ActionIR::AST::parse_action_expr('{|| return("value") }');
  my $copy = LinkedSpec::CodeblockRuntime::_copy_value($record);
  my $independent = LinkedSpec::ActionIR::AST::parse_action_expr('{|| return("value") }');
  my $origin = LinkedSpec::CodeblockRuntime::_codeblock_origin($record);
  is(refaddr(LinkedSpec::CodeblockRuntime::_codeblock_origin($copy)), refaddr($origin), 'copy retains actual origin');
  isnt(refaddr(LinkedSpec::CodeblockRuntime::_codeblock_origin($independent)), refaddr($origin), 'equal independent record retains separate origin');
  my $invocation = {active_codeblocks => ['outer'], active_codeblock_records => [$origin]};
  is(LinkedSpec::CodeblockRuntime::invoke($independent, [], {}, 'inner', undef, $invocation), 'value', 'equal independent literal may execute while original is active');
  my $failure;
  eval {LinkedSpec::CodeblockRuntime::invoke($copy, [], {}, 'inner', undef, $invocation); 1} or $failure = $@;
  check_cycle($failure, ['outer','outer'], 'copied alias');
  is(scalar(keys %$record), 8, 'literal keeps eight serialized fields');
 };
}
done_testing;
