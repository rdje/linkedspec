#------------------------------------------------------------------------------
# Package: LinkedSpec::ProgressiveSpanDispatchPolicy
# Purpose: Validate the private progressive node's literal identities and bare
#          span binding after the complete Perl rule table exists.
#------------------------------------------------------------------------------
package LinkedSpec::ProgressiveSpanDispatchPolicy;

use 5.010;
use strict;
use warnings;

use LinkedSpec::ActionIR::ProgressiveSpanDispatch ();

sub validate_rule_rows {
 my ($rows) = @_;
 return _diagnostic(
  'progressive_parser_identity_literal_required',
  '<compiler>',
  operand => '<invalid-rule-table>',
 ) unless ref($rows) eq 'ARRAY';

 for my $row (@$rows) {
  next unless ref($row) eq 'ARRAY' && @$row == 2;
  my ($label, $info) = @$row;
  next unless defined($label) && !ref($label) && ref($info) eq 'HASH';
  my $rewriter = ref($info->{meta}) eq 'HASH'
   && ref($info->{meta}{action_rewriter}) eq 'HASH'
   ? $info->{meta}{action_rewriter}
   : {};
  for my $event (@{$rewriter->{canonical_action_ir_events} // []}) {
   next unless ref($event) eq 'HASH'
    && ($event->{kind} // '') eq 'PROGRESSIVE_DISPATCH_SPAN';
   my $validated = LinkedSpec::ActionIR::ProgressiveSpanDispatch::validate_static_operands(
    $event->{args},
   );
   next if ref($validated) eq 'HASH' && $validated->{ok};
   my $code = ref($validated) eq 'HASH'
    ? $validated->{code}
    : 'progressive_parser_identity_literal_required';
   my %context = ref($validated) eq 'HASH' ? %$validated : (operand => '<invalid>');
   delete @context{qw/ok code/};
   return _diagnostic($code, $label, %context);
  }
 }
 return undef
}

sub _diagnostic {
 my ($code, $rule, %context) = @_;
 return {
  code => $code,
  rule => $rule,
  origin => $rule.':dispatch_span',
  %context,
 }
}

1;
