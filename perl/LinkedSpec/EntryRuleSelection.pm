#------------------------------------------------------------------------------
# Package: LinkedSpec::EntryRuleSelection
# Purpose: Resolve one effective parser entry from ordered authored rule identity.
#------------------------------------------------------------------------------
package LinkedSpec::EntryRuleSelection;

use 5.010;
use strict;
use warnings;

our $CONTRACT_ID = 'linkedspec-root-rule-selection-v1';

#------------------------------------------------------------------------------
# Function: select_entry_rule
# Purpose : Apply explicit > first authored marker > first authored rule precedence.
# Args    : ($ordered_rule_rows_arrayref, $explicit_selector_opt)
# Rows    : { label => non-empty scalar, is_top => boolean }
# Returns : { ok => 1, entry_rule => LABEL, basis => BASIS }
#           or { ok => 0, code => CODE, stage => STAGE, ... }
#------------------------------------------------------------------------------
sub select_entry_rule {
 my ($rows, $explicit_selector) = @_;
 return {
  ok => 0,
  code => 'no_rules_defined',
  stage => 'validate_spec',
 } unless ref($rows) eq 'ARRAY' && @$rows;

 my @normalized;
 my %declared;
 for my $index (0 .. $#$rows) {
  my $row = $rows->[$index];
  die "(LinkedSpec::EntryRuleSelection::select_entry_rule) -E- row[$index] must be HASH ref\n"
   unless ref($row) eq 'HASH';
  my $label = $row->{label};
  die "(LinkedSpec::EntryRuleSelection::select_entry_rule) -E- row[$index] label must be a non-empty scalar\n"
   unless defined($label) && !ref($label) && length($label);
  $declared{$label} = 1;
  push @normalized, {
   label => $label,
   is_top => $row->{is_top} ? 1 : 0,
  };
 }

 if (defined($explicit_selector) && length($explicit_selector)) {
  return {
   ok => 0,
   code => 'entry_rule_not_found',
   stage => 'select_entry_rule',
   entry_rule => $explicit_selector,
  } unless $declared{$explicit_selector};
  return {
   ok => 1,
   entry_rule => $explicit_selector,
   basis => 'explicit_selector',
  };
 }

 for my $row (@normalized) {
  return {
   ok => 1,
   entry_rule => $row->{label},
   basis => 'first_authored_marker',
  } if $row->{is_top};
 }

 return {
  ok => 1,
  entry_rule => $normalized[0]{label},
  basis => 'first_authored_rule',
 };
}

1;
