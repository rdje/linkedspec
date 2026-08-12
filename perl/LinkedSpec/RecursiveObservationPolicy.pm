#------------------------------------------------------------------------------
# Package: LinkedSpec::RecursiveObservationPolicy
# Purpose: Validate the authored recursive-observation target and static call.
#------------------------------------------------------------------------------
package LinkedSpec::RecursiveObservationPolicy;

use 5.010;
use strict;
use warnings;

sub validate_rule_rows {
 my ($rows) = @_;
 return _operand_diagnostic('<compiler>', {}, 'missing') unless ref($rows) eq 'ARRAY';

 my %rules = map {
  ref($_) eq 'ARRAY' && @$_ == 2 && defined($_->[0])
   ? ($_->[0] => 1)
   : ()
 } @$rows;

 for my $row (@$rows) {
  next unless ref($row) eq 'ARRAY' && @$row == 2;
  my ($label, $info) = @$row;
  next unless defined($label) && ref($info) eq 'HASH';
  my $rewriter = ref($info->{meta}) eq 'HASH'
   && ref($info->{meta}{action_rewriter}) eq 'HASH'
   ? $info->{meta}{action_rewriter}
   : {};
  for my $event (@{$rewriter->{canonical_action_ir_events} // []}) {
   next unless ref($event) eq 'HASH'
    && ($event->{kind} // '') eq 'OBSERVE_RECOGNITION';
   my $args = ref($event->{args}) eq 'HASH' ? $event->{args} : {};
   my $target = $args->{target};
   return {
    code => 'source_location_recursive_observation_target',
    rule_role => $label,
    source_id => 'input',
    binding_name => defined($target) && !ref($target) ? $target : '',
    originating_edge_or_job => $label.':observe_recognition',
   } unless defined($target) && !ref($target)
    && $target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;

   my $callee = $args->{callee};
   my $operand_kind = $args->{operand_kind};
   $operand_kind = 'argument_count'
    if exists($args->{argument_count}) && $args->{argument_count} != 2;
   $operand_kind = 'static_call_missing_rule'
    if defined($callee) && !ref($callee) && !exists($rules{$callee});
   return _operand_diagnostic($label, $args, $operand_kind)
    if defined($operand_kind)
     || !defined($callee)
     || ref($callee)
     || !exists($rules{$callee});
  }
 }
 return undef
}

sub _operand_diagnostic {
 my ($label, $args, $kind) = @_;
 $args = {} unless ref($args) eq 'HASH';
 return {
  code => 'source_location_recursive_observation_operand',
  rule_role => $label,
  source_id => 'input',
  operand_kind => defined($kind) ? $kind : 'missing',
  originating_edge_or_job => $label.':observe_recognition',
 }
}

1;
