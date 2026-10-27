use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec ();
use LinkedSpec::ActionIR::AST ();
use LinkedSpec::CodeblockRuntime ();

# TYPE-REFERENCE-BOOK.1.2.23.3.31.6.4.3 — resolve callbacks before scoped value.
my $json = JSON::PP->new->canonical->allow_nonref;
my $sequence = 0;
my @cases = (
 ['helper callback named value', q{value={|item|return(cat(item,"!"))};return([with("a",value),value("c")]);}, ['a!','c!']],
 ['receiver callback named value', q{value={|item|return(cat(item,"!"))};return(["b".with(value),value("c")]);}, ['b!','c!']],
 ['deferred helper and receiver callback named value', q{value={|item|return(cat(item,"!"))};runner={||return([with("a",value),"b".with(value),value("c")])};return(runner());}, ['a!','b!','c!']],
 ['healthy callback named cb', q{cb={|item|return(cat(item,"!"))};return([with("a",cb),"b".with(cb),cb("c")]);}, ['a!','b!','c!']],
 ['source then callback exactly once before scoped value', q{
 order="";value={|item|return(cat("old:",item))};
 a=with({order=cat(order,"S");value={|item|order=cat(order,"B");return(cat("new:",item))};"a"},if({order=cat(order,"C");true},value,value));
 b={order=cat(order,"S");"b"}.with(if({order=cat(order,"C");true},value,value));
 return([a,b,value("c"),order]);
 }, ['new:a','new:b','new:c','SCBSCBB']],
);
for my $case (@cases) {
 next if @ARGV && !grep {$_ eq $case->[0]} @ARGV;
 subtest $case->[0] => sub {
  my $source = "Top:: I {$case->[1]}";
  my %context;
  my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%context);
  my $input = 'x';
  my $actual = $parser->(\$input);
  is($context{last_error}, undef, 'native no runtime error');
  is($json->encode($actual), $json->encode($case->[2]), 'native exact values and order');
  my $emitted = LinkedSpec::emit_generated_source(\$source, source_identity => 'with-callback-snapshot.spec');
  my $package = 'LinkedSpec::WithCallbackSnapshot' . ++$sequence;
  my $loaded = eval "package $package; $emitted; 1";
  ok($loaded, 'fresh source compiles') or diag($@);
  return unless $loaded;
  my ($fresh, $failure);
  {
   no strict 'refs';
   my $fresh_input = 'x';
   eval {$fresh = &{$package . '::Execute'}(\$fresh_input); 1} or $failure = $@;
  }
  is($failure, undef, 'fresh no runtime error');
  is($json->encode($fresh), $json->encode($case->[2]), 'fresh exact values and order');
 };
}
if (!@ARGV || grep {$_ eq 'validation and body failures preserve caller state'} @ARGV) {
 subtest 'validation and body failures preserve caller state' => sub {
  my $value = 'outer';
  my $present = 1;
  my %bindings = (value => \$value);
  my %presence = (value => \$present);
  my $runner = LinkedSpec::ActionIR::AST::parse_action_expr('{|| return(with({value="changed";"source"},9)) }');
  my $failure;
  eval {LinkedSpec::CodeblockRuntime::invoke($runner, [], \%bindings, 'runner', undef, {}, \%presence); 1} or $failure = $@;
  isa_ok($failure, 'LinkedSpec::CodeblockRuntime::Error', 'validation typed failure');
  is($failure->{code}, 'final_argument_not_codeblock', 'validation code unchanged');
  is($value, 'changed', 'ordinary value argument effect persists on validation failure');
  is(refaddr($bindings{value}), refaddr(\$value), 'validation preserves caller slot');
  is(refaddr($presence{value}), refaddr(\$present), 'validation preserves presence slot');
  is($present, 1, 'validation preserves presence');

  $value = 'outer';
  my $state = 'before';
  $bindings{state} = \$state;
  $runner = LinkedSpec::ActionIR::AST::parse_action_expr('{|| return(with("source",{|item|state="kept";value="inner";missing()})) }');
  undef $failure;
  eval {LinkedSpec::CodeblockRuntime::invoke($runner, [], \%bindings, 'runner', undef, {}, \%presence); 1} or $failure = $@;
  isa_ok($failure, 'LinkedSpec::CodeblockRuntime::Error', 'body typed failure');
  is($failure->{code}, 'unknown_helper', 'body code unchanged');
  is($failure->{name}, 'missing', 'body missing helper unchanged');
  is($value, 'outer', 'failed body restores scoped value');
  is(refaddr($bindings{value}), refaddr(\$value), 'failed body restores caller slot');
  is(refaddr($presence{value}), refaddr(\$present), 'failed body restores presence slot');
  is($present, 1, 'failed body preserves presence');
  ok(!exists($presence{item}), 'failed body removes temporary parameter presence');
  ok(!defined(${$bindings{item}}), 'retained parameter slot has no value');
  is($state, 'kept', 'failed body preserves unrelated effects');
 };
}
done_testing;
