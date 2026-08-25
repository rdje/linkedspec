#------------------------------------------------------------------------------
# Package: LinkedSpec::StagedParseJobPolicy
# Purpose: Reject malformed general parse-job annotation events before any
#          parser carrier or authored execution can exist.
#------------------------------------------------------------------------------
package LinkedSpec::StagedParseJobPolicy;

use 5.010;
use strict;
use warnings;

use LinkedSpec::ActionIR::StagedParseJob ();

sub validate_rule_rows {
 my ($rows) = @_;
 return _diagnostic(
  'staged_parse_job_options_required',
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
    && ($event->{kind} // '') eq 'STAGED_PARSE_JOB_MARKER';
   my $validated = LinkedSpec::ActionIR::StagedParseJob::validate_static_operands(
    $event->{args},
   );
   next if ref($validated) eq 'HASH' && $validated->{ok};
   my $code = ref($validated) eq 'HASH'
    ? $validated->{code}
    : 'staged_parse_job_options_required';
   my %context = ref($validated) eq 'HASH' ? %$validated : (operand => '<invalid>');
   delete @context{qw(ok code text_plan options)};
   return _diagnostic($code, $label, %context)
  }
 }
 return undef
}

sub _diagnostic {
 my ($code, $rule, %context) = @_;
 return {
  code => $code,
  phase => 'declare',
  rule => $rule,
  origin => $rule.':parse_job',
  %context,
 }
}

1;
