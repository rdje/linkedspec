#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::Diagnostics
# Purpose: ActionIR diagnostic owner for unresolved-helper, helper-node, and
#          canonical-event telemetry assembly.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::Diagnostics;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

#------------------------------------------------------------------------------
# Function: _require_pkg
# Purpose : Lazy-load one diagnostics dependency owner through the shared
#           owner-dispatch seam.
# Args    : ($pkg)
# Returns : requested package name
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg);
 return $pkg
}

#------------------------------------------------------------------------------
# Function: _require_dep
# Purpose : Resolve one required diagnostics dependency callback from the
#           provided dependency map.
# Args    : ($deps, $name)
# Returns : callback coderef
#------------------------------------------------------------------------------
sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::Diagnostics::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Preserve caller-visible successful `$@` while executing one
#           diagnostics helper callback.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

#------------------------------------------------------------------------------
# Function: default_deps_for_package
# Purpose : Build the default diagnostics dependency bundle for one owner
#           package.
# Args    : ($pkg)
# Returns : hashref of dependency callbacks
#------------------------------------------------------------------------------
sub default_deps_for_package {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::build_dep_map(
  __PACKAGE__,
  $pkg,
  [
   'split_action_ir_statements',
   'scan_contract_ir_events',
  ],
 )
}

#------------------------------------------------------------------------------
# Function: _find_unresolved_action_helpers
# Purpose : Count unresolved helper-like statement hits across the current
#           rewrite rules and split ActionIR statements.
# Args    : ($code, $rewrite_rules, $deps)
# Returns : hashref unresolved-helper diagnostics payload
#------------------------------------------------------------------------------
sub _find_unresolved_action_helpers {
 my ($code, $rewrite_rules, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $split_action_ir_statements = _require_dep($deps, 'split_action_ir_statements');

 my %hits;
 my $total = 0;
 my @events;
 my @statements = @{$split_action_ir_statements->($code)};
 foreach my $rule (@$rewrite_rules) {
  my $helper_name = $rule->{diag_name} // $rule->{id};
  my $helper_re = $rule->{unresolved_pattern};
  next unless $helper_re;
  foreach my $statement (@statements) {
   my $count = () = ($statement =~ /$helper_re/g);
   next unless $count;
   $hits{$helper_name} += $count;
   $total += $count;
   push @events, map { +{helper => $helper_name, raw => $statement} } (1 .. $count);
  }
 }

 return {
  unresolved_helper_count => $total,
  unresolved_helper_hits  => \%hits,
  unresolved_helpers      => [sort keys %hits],
  unresolved_helper_events => \@events,
 }
}

#------------------------------------------------------------------------------
# Function: _collect_action_helper_ir_nodes
# Purpose : Collect helper ActionIR node telemetry by replaying scanner rule
#           hits over the current action code.
# Args    : ($code, $rewrite_rules, $deps)
# Returns : hashref helper-node diagnostics payload
#------------------------------------------------------------------------------
sub _collect_action_helper_ir_nodes {
 my ($code, $rewrite_rules, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $scan_contract_ir_events = _require_dep($deps, 'scan_contract_ir_events');

 my %hits;
 my $total = 0;
 my @events;
 foreach my $rule (@$rewrite_rules) {
  my $ir_node = $rule->{ir_node} // $rule->{id};
  my $rule_events = $scan_contract_ir_events->($rule, $code);
  next unless ref($rule_events) eq 'ARRAY' && @$rule_events;
  foreach my $event (@$rule_events) {
   push @events, {
    ir_node     => $ir_node,
    contract_id => $rule->{id},
    raw         => $event->{raw},
    args        => $event->{args} || {},
   };
   $hits{$ir_node} += 1;
   $total += 1;
  }
 }

 return {
  helper_action_ir_count => $total,
  helper_action_ir_hits  => \%hits,
  helper_action_ir_nodes => [sort keys %hits],
  helper_action_ir_events => \@events,
 }
}

#------------------------------------------------------------------------------
# Function: _accumulate_action_rewrite_diagnostics
# Purpose : Merge one per-rule ActionIR diagnostics payload into the running
#           aggregate diagnostics bucket.
# Args    : ($acc, $diag)
# Returns : updated aggregate diagnostics hashref
#------------------------------------------------------------------------------
sub _accumulate_action_rewrite_diagnostics {
 my ($acc, $diag) = @_;
 return $acc unless $acc && $diag && ref($diag) eq 'HASH';

 my $hits = $diag->{unresolved_helper_hits};
 return $acc unless $hits && ref($hits) eq 'HASH';

 foreach my $helper_name (keys %$hits) {
  my $count = $hits->{$helper_name} || 0;
  next unless $count;
  $acc->{unresolved_helper_hits}{$helper_name} += $count;
  $acc->{unresolved_helper_count} += $count;
 }
 my $unresolved_events = $diag->{unresolved_helper_events};
 if ($unresolved_events && ref($unresolved_events) eq 'ARRAY' && @$unresolved_events) {
  push @{$acc->{unresolved_helper_events}}, @$unresolved_events;
 }

 my $ir_hits = $diag->{helper_action_ir_hits};
 if ($ir_hits && ref($ir_hits) eq 'HASH') {
  foreach my $ir_node (keys %$ir_hits) {
   my $count = $ir_hits->{$ir_node} || 0;
   next unless $count;
   $acc->{helper_action_ir_hits}{$ir_node} += $count;
   $acc->{helper_action_ir_count} += $count;
  }
 }

 my $ir_events = $diag->{helper_action_ir_events};
 if ($ir_events && ref($ir_events) eq 'ARRAY' && @$ir_events) {
  push @{$acc->{helper_action_ir_events}}, @$ir_events;
 }

 my $canonical_hits = $diag->{canonical_action_ir_hits};
 if ($canonical_hits && ref($canonical_hits) eq 'HASH') {
  foreach my $kind (keys %$canonical_hits) {
   my $count = $canonical_hits->{$kind} || 0;
   next unless $count;
   $acc->{canonical_action_ir_hits}{$kind} += $count;
   $acc->{canonical_action_ir_count} += $count;
  }
 }

 my $canonical_events = $diag->{canonical_action_ir_events};
 if ($canonical_events && ref($canonical_events) eq 'ARRAY' && @$canonical_events) {
  push @{$acc->{canonical_action_ir_events}}, @$canonical_events;
 }

 $acc->{canonical_action_ir_fallback_count} += ($diag->{canonical_action_ir_fallback_count} || 0);

 return $acc
}

1;
