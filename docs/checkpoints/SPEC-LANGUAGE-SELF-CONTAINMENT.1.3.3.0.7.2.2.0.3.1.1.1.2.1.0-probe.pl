use strict;
use warnings;
use utf8;
use LinkedSpec ();
use LinkedSpec::ActionIR::AST::Parser ();
use LinkedSpec::ActionIR::MethodExpr ();
use LinkedSpec::ActionIR::Contracts ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();
use JSON::PP ();
use Scalar::Util qw(refaddr);

my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-';
my $json = JSON::PP->new->utf8->canonical;
open my $in, '<:raw', $prefix.'cases.json' or die $!;
my $cases = $json->decode(do { local $/; <$in> }); close $in or die $!;
my (%ids, @retained);
sub identity {
 my ($value) = @_;
 return undef unless ref($value);
 my $address = refaddr($value);
 unless (exists $ids{$address}) {
  push @retained, $value;
  $ids{$address} = scalar @retained;
 }
 return $ids{$address}
}
sub project {
 my ($value) = @_;
 return [map { project($_) } @$value] if ref($value) eq 'ARRAY';
 return {map { $_ => project($value->{$_}) } keys %$value} if ref($value) eq 'HASH';
 return "$value" if ref($value);
 return $value
}
my @observed;
for my $case (@$cases) {
 my $source = $case->{source};
 my $ordinary = LinkedSpec::ActionIR::AST::parse_action_expr($source);
 my (@nodes, $ast);
 {
  my $make = \&LinkedSpec::ActionIR::AST::Parser::_node;
  no warnings 'redefine';
  local *LinkedSpec::ActionIR::AST::Parser::_node = sub {
   my $context = wantarray;
   my @caller = caller;
   my ($kind, $text, $start, $end) = @_;
   my $node = $make->(@_); my $error = $@;
   push @nodes, {id => identity($node), kind => $kind, source => $text,
    source_span => {start => $start, end => $end}, node => project($node),
    context => defined($context) ? ($context ? 'list' : 'scalar') : 'void',
    caller => $caller[1], line => $caller[2]};
   $@ = $error;
   return $node
  };
  $ast = LinkedSpec::ActionIR::AST::parse_action_expr($source);
 }
 my $frames = LinkedSpec::ActionIR::MethodExpr::_parse_method_with_source_frames(
  \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr, $source);
 my $copy = {%$ast};
 my $foreign = LinkedSpec::ActionIR::AST::parse_action_expr($source);
 # Only the healthy ordinary cases are sent to the public lowering facade.
 # Empty-slot syntax is a parser observation, not public language admission.
 my $lowered = $case->{id} eq 'empty-slots' ? undef
  : LinkedSpec::call_spec_handler_subst('Top', 'return('.$source.')');
 push @observed, {id => $case->{id}, source => $source, ast => project($ast),
  ordinary => project($ordinary), nodes => \@nodes,
  root_id => identity($ast), copy_id => identity($copy), foreign_id => identity($foreign),
  argument_ids => [map { identity($_) } @{$ast->{args}}],
  frames => project($frames->{source_frames}), call => project($frames->{call}),
  lowered => $lowered};
}

my @callbacks;
my $source = 'cat("λ", "λ")';
for my $mode (qw(actual copied changed foreign opaque nested fatal)) {
 my ($actual, $context, $count, $nested);
 $count = 0;
 my $failure = bless {}, 'InputAuthority::Failure';
 my $callback = sub {
  $context = defined(wantarray) ? (wantarray ? 'list' : 'scalar') : 'void';
  ++$count;
  die $failure if $mode eq 'fatal';
  return 'opaque-result' if $mode eq 'opaque';
  $actual = LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr(
   $mode eq 'foreign' ? 'cat("foreign", "foreign")' : $_[0]);
  $nested = LinkedSpec::ActionIR::MethodExpr::_parse_method_with_source_frames(
   \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr, 'cat("nested", "nested")')
   if $mode eq 'nested';
  return {%$actual} if $mode eq 'copied';
  $actual->{args}[0] = 'changed' if $mode eq 'changed';
  return $actual
 };
 my ($result, $error);
 $@ = 'caller-error';
 if ($mode eq 'fatal') {
  eval { $result = LinkedSpec::ActionIR::MethodExpr::_parse_method_with_source_frames($callback, $source); 1 };
  $error = $@;
 } else {
  $result = LinkedSpec::ActionIR::MethodExpr::_parse_method_with_source_frames($callback, $source);
  $error = $@;
 }
 push @callbacks, {mode => $mode, count => $count, context => $context,
  actual_id => identity($actual), returned_id => identity(ref($result) eq 'HASH' ? $result->{call} : undef),
  result => project($result), error => ref($error) ? 'exception-object' : $error,
  same_exception => ref($error) && refaddr($error) == refaddr($failure) ? 1 : 0,
  nested => project($nested)};
}

my @dependency;
for my $barrier (0, 1) {
 my $source = 'input_slice(0, 1)';
 my $event = {raw => $source};
 my (@effects, $context, $capture);
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins($source, sub {
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event => $event, source => $source, source_span => {start => 0, end => length($source)}});
  # A controlled future producer publishes a generated-only packet. This is
  # deliberately not a claim that current production lowerers publish packets.
  my $builder_callback = sub {
   push @effects, 'builder';
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'sentinel');
   return LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder)
  };
  my $opaque = sub {
   push @effects, 'opaque';
   $context = defined(wantarray) ? (wantarray ? 'list' : 'scalar') : 'void';
   my $ignored = $builder_callback->();
   return 'sentinel'; # equal replacement, no returned producer object
  };
  my $deps = LinkedSpec::ActionIR::Contracts::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
  $deps->{lower_method_value_expr} = $barrier ? sub {
   return LinkedSpec::ActionIR::SourceEmissions::_capture_emission($opaque, @_)->{value}
  } : $opaque;
  my $contracts = LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts('Top', $deps);
  my ($contract) = grep { $_->{id} eq 'input_slice' } @$contracts;
  my $outer = $contract->{lower};
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers([$outer], sub {
   $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($outer, $source);
  });
 });
 push @dependency, {barrier => $barrier, value => $capture->{value},
  has_packet => defined($capture->{emission}) ? 1 : 0, effects => \@effects, context => $context};
}
print $json->encode({cases => \@observed, callbacks => \@callbacks, dependency => \@dependency}), "\n";
