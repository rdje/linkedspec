#------------------------------------------------------------------------------
# Package: LinkedSpec::CompilerState
# Purpose: Internal compiled-spec / gdata / descriptor state model owner for
#          the LinkedSpec compiler pipeline.
#------------------------------------------------------------------------------
package LinkedSpec::CompilerState;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub new_compiled_spec_state {
 return {
  kind => 'compiled_spec_state',
  version => 1,
  definition_order => [],
  compiled_rule_order => [],
  rules_by_label => {},
  redefined_rule_labels => [],
 }
}

sub is_compiled_spec_state {
 my ($value) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless defined($value->{kind}) && $value->{kind} eq 'compiled_spec_state';
 return 0 unless defined($value->{version}) && $value->{version} == 1;
 return 0 unless ref($value->{definition_order}) eq 'ARRAY';
 return 0 unless ref($value->{compiled_rule_order}) eq 'ARRAY';
 return 0 unless ref($value->{rules_by_label}) eq 'HASH';
 return 0 unless ref($value->{redefined_rule_labels}) eq 'ARRAY';
 return 1
}

sub compiled_spec_state_rule_count {
 my ($state) = @_;
 return 0 unless is_compiled_spec_state($state);
 return scalar(@{$state->{compiled_rule_order}})
}

sub compiled_spec_state_rules_by_label {
 my ($state) = @_;
 return undef unless is_compiled_spec_state($state);
 return $state->{rules_by_label}
}

sub compiled_spec_state_has_rule {
 my ($state, $label) = @_;
 return 0 unless is_compiled_spec_state($state);
 return exists $state->{rules_by_label}{$label} ? 1 : 0
}

sub compiled_spec_state_rule_info {
 my ($state, $label) = @_;
 return undef unless is_compiled_spec_state($state);
 return undef unless compiled_spec_state_has_rule($state, $label);
 return $state->{rules_by_label}{$label}
}

sub compiled_spec_state_compiled_rule_order {
 my ($state) = @_;
 return [] unless is_compiled_spec_state($state);
 return $state->{compiled_rule_order}
}

sub compiled_spec_state_rule_rows {
 my ($state) = @_;
 return [] unless is_compiled_spec_state($state);
 my $rules_by_label = compiled_spec_state_rules_by_label($state);
 return [map { [$_, $rules_by_label->{$_}] } @{compiled_spec_state_compiled_rule_order($state)}]
}

sub compiled_spec_state_definition_order {
 my ($state) = @_;
 return [] unless is_compiled_spec_state($state);
 return $state->{definition_order}
}

sub compiled_spec_state_redefined_rule_labels {
 my ($state) = @_;
 return [] unless is_compiled_spec_state($state);
 return $state->{redefined_rule_labels}
}

sub compiled_spec_state_to_legacy_spec {
 my ($state) = @_;
 return undef unless is_compiled_spec_state($state);
 return { %{$state->{rules_by_label}} }
}

sub compiled_spec_state_meta {
 my ($state) = @_;
 return {} unless is_compiled_spec_state($state);
 return {
  descriptor_model => 'compiled_spec_state_v1',
  definition_order => [map { $_->{label} } @{compiled_spec_state_definition_order($state)}],
  compiled_rule_order => [@{$state->{compiled_rule_order}}],
  redefined_rule_labels => [@{$state->{redefined_rule_labels}}],
 }
}

sub build_compiled_descriptor_meta {
 my ($compiled_spec_state, %args) = @_;
 return {} unless is_compiled_spec_state($compiled_spec_state);
 my $meta = compiled_spec_state_meta($compiled_spec_state);
 $meta->{parse_mode} = $args{parse_mode} if defined $args{parse_mode};
 $meta->{action_rewriter_migration} = $args{action_rewriter_migration}
  if exists $args{action_rewriter_migration};
 return $meta
}

sub build_action_rewriter_migration_summary {
 my ($spec_or_state) = @_;

 my $summary = {
 total_rules => 0,
 rules_with_action_rewriter_meta => 0,
 language_agnostic_ready_rule_count => 0,
 language_agnostic_blocked_rule_count => 0,
 language_agnostic_blocker_statement_total_count => 0,
  language_agnostic_blocked_raw_perl_only_rule_count => 0,
  language_agnostic_blocked_unresolved_helper_only_rule_count => 0,
  language_agnostic_blocked_mixed_rule_count => 0,
  language_agnostic_blocked_raw_perl_only_ratio => '0.0000',
  language_agnostic_blocked_unresolved_helper_only_ratio => '0.0000',
  language_agnostic_blocked_mixed_ratio => '0.0000',
  compatibility_surface_rule_count => 0,
  compatibility_surface_ready_rule_count => 0,
  compatibility_surface_statement_total_count => 0,
  language_agnostic_ready_rules => [],
  language_agnostic_blocked_rules => [],
  language_agnostic_blocked_raw_perl_only_rules => [],
  language_agnostic_blocked_unresolved_helper_only_rules => [],
  language_agnostic_blocked_mixed_rules => [],
  compatibility_surface_rules => [],
  compatibility_surface_ready_rules => [],
  compatibility_surface_rules_by_priority => [],
  compatibility_surface_top_rule => undef,
  language_agnostic_blocked_rules_by_priority => [],
  language_agnostic_top_blocked_rule => undef,
 };

 my @rule_rows;
 if (is_compiled_spec_state($spec_or_state)) {
  @rule_rows = @{compiled_spec_state_rule_rows($spec_or_state)};
 }
 elsif (ref($spec_or_state) eq 'HASH') {
  @rule_rows = map { [$_, $spec_or_state->{$_}] } sort keys %$spec_or_state;
 }
 else {
  return $summary
 }

 foreach my $row (@rule_rows) {
  my ($rule_name, $rule) = @$row;
  next unless ref($rule) eq 'HASH';
  ++$summary->{total_rules};

  my $rule_meta = $rule->{meta};
  next unless ref($rule_meta) eq 'HASH';
  my $rewriter_meta = $rule_meta->{action_rewriter};
  next unless ref($rewriter_meta) eq 'HASH';

  ++$summary->{rules_with_action_rewriter_meta};

  my $is_ready = $rewriter_meta->{language_agnostic_action_ir_ready} ? 1 : 0;
  my $compatibility_surface_count = $rewriter_meta->{compatibility_surface_count} || 0;
  if ($compatibility_surface_count > 0) {
   my @compatibility_surface_statements = ref($rewriter_meta->{compatibility_surface_statements}) eq 'ARRAY'
    ? @{$rewriter_meta->{compatibility_surface_statements}}
    : ();
   my @compatibility_surface_contract_ids = ref($rewriter_meta->{compatibility_surface_contract_ids}) eq 'ARRAY'
    ? @{$rewriter_meta->{compatibility_surface_contract_ids}}
    : ();
   ++$summary->{compatibility_surface_rule_count};
   push @{$summary->{compatibility_surface_rules}}, {
    rule => $rule_name,
    compatibility_surface_count => $compatibility_surface_count,
    compatibility_surface_statement_count => scalar @compatibility_surface_statements,
    compatibility_surface_statements => \@compatibility_surface_statements,
    compatibility_surface_contract_ids => \@compatibility_surface_contract_ids,
   };
   $summary->{compatibility_surface_statement_total_count} += scalar @compatibility_surface_statements;
   if ($is_ready) {
    ++$summary->{compatibility_surface_ready_rule_count};
    push @{$summary->{compatibility_surface_ready_rules}}, $rule_name;
   }
  }

  if ($is_ready) {
   ++$summary->{language_agnostic_ready_rule_count};
   push @{$summary->{language_agnostic_ready_rules}}, $rule_name;
   next;
  }

  ++$summary->{language_agnostic_blocked_rule_count};
  my $unresolved_helper_count = $rewriter_meta->{unresolved_helper_count} || 0;
  my $raw_perl_dependency_count = $rewriter_meta->{raw_perl_dependency_count} || 0;
  my @blocker_statements = ref($rewriter_meta->{language_agnostic_action_ir_blocker_statements}) eq 'ARRAY'
   ? @{$rewriter_meta->{language_agnostic_action_ir_blocker_statements}}
   : ();
  push @{$summary->{language_agnostic_blocked_rules}}, {
   rule => $rule_name,
   blocker_statement_count => scalar @blocker_statements,
   blocker_statements => \@blocker_statements,
   unresolved_helper_count => $unresolved_helper_count,
   raw_perl_dependency_count => $raw_perl_dependency_count,
  };
  $summary->{language_agnostic_blocker_statement_total_count} += scalar @blocker_statements;

  if ($raw_perl_dependency_count > 0 && $unresolved_helper_count > 0) {
   ++$summary->{language_agnostic_blocked_mixed_rule_count};
   push @{$summary->{language_agnostic_blocked_mixed_rules}}, $rule_name;
  }
  elsif ($raw_perl_dependency_count > 0) {
   ++$summary->{language_agnostic_blocked_raw_perl_only_rule_count};
   push @{$summary->{language_agnostic_blocked_raw_perl_only_rules}}, $rule_name;
  }
  elsif ($unresolved_helper_count > 0) {
   ++$summary->{language_agnostic_blocked_unresolved_helper_only_rule_count};
   push @{$summary->{language_agnostic_blocked_unresolved_helper_only_rules}}, $rule_name;
  }
 }

 my @blocked_by_priority = sort {
  $b->{blocker_statement_count} <=> $a->{blocker_statement_count}
   || $b->{unresolved_helper_count} <=> $a->{unresolved_helper_count}
   || $b->{raw_perl_dependency_count} <=> $a->{raw_perl_dependency_count}
   || $a->{rule} cmp $b->{rule}
 } @{$summary->{language_agnostic_blocked_rules}};
 $summary->{language_agnostic_blocked_rules_by_priority} = [map { $_->{rule} } @blocked_by_priority];
 $summary->{language_agnostic_top_blocked_rule} = @blocked_by_priority ? $blocked_by_priority[0]{rule} : undef;

 my @compatibility_by_priority = sort {
  $b->{compatibility_surface_statement_count} <=> $a->{compatibility_surface_statement_count}
   || $b->{compatibility_surface_count} <=> $a->{compatibility_surface_count}
   || $a->{rule} cmp $b->{rule}
 } @{$summary->{compatibility_surface_rules}};
 $summary->{compatibility_surface_rules_by_priority} = [map { $_->{rule} } @compatibility_by_priority];
 $summary->{compatibility_surface_top_rule} = @compatibility_by_priority ? $compatibility_by_priority[0]{rule} : undef;

 if ($summary->{rules_with_action_rewriter_meta} > 0) {
  $summary->{language_agnostic_ready_ratio} = sprintf(
   '%.4f',
   $summary->{language_agnostic_ready_rule_count} / $summary->{rules_with_action_rewriter_meta}
  );
 } else {
  $summary->{language_agnostic_ready_ratio} = '0.0000';
 }

 if ($summary->{language_agnostic_blocked_rule_count} > 0) {
  $summary->{language_agnostic_blocked_raw_perl_only_ratio} = sprintf(
   '%.4f',
   $summary->{language_agnostic_blocked_raw_perl_only_rule_count} / $summary->{language_agnostic_blocked_rule_count}
  );
  $summary->{language_agnostic_blocked_unresolved_helper_only_ratio} = sprintf(
   '%.4f',
   $summary->{language_agnostic_blocked_unresolved_helper_only_rule_count} / $summary->{language_agnostic_blocked_rule_count}
  );
  $summary->{language_agnostic_blocked_mixed_ratio} = sprintf(
   '%.4f',
   $summary->{language_agnostic_blocked_mixed_rule_count} / $summary->{language_agnostic_blocked_rule_count}
  );
 }

 return $summary
}

sub record_compiled_spec_rule {
 my ($state, $label, $info, $redefined_seen) = @_;
 die "(LinkedSpec::CompilerState::record_compiled_spec_rule) -E- compiled spec state is invalid"
  unless is_compiled_spec_state($state);

 my $is_duplicate = exists $state->{rules_by_label}{$label};
push @{$state->{definition_order}}, {
  label => $label,
  info => $info,
 };
 push @{$state->{compiled_rule_order}}, $label unless $is_duplicate;
 if ($is_duplicate && ref($redefined_seen) eq 'HASH' && !$redefined_seen->{$label}++) {
  push @{$state->{redefined_rule_labels}}, $label;
 }
 $state->{rules_by_label}{$label} = $info;
 return $is_duplicate
}

sub new_compiled_dependency_regex_state {
 my (%args) = @_;
 my $compiled_spec_state = $args{compiled_spec_state};
 my $compiled_dependency_regex_by_label = $args{compiled_dependency_regex_by_label};

 die "(LinkedSpec::CompilerState::new_compiled_dependency_regex_state) -E- compiled spec state is invalid"
  unless is_compiled_spec_state($compiled_spec_state);
 die "(LinkedSpec::CompilerState::new_compiled_dependency_regex_state) -E- compiled dependency-regex map must be HASH ref"
  unless ref($compiled_dependency_regex_by_label) eq 'HASH';

 my $source_rule_order = [@{compiled_spec_state_compiled_rule_order($compiled_spec_state)}];
 my %seen_compiled;
 my @compiled_label_order = grep {
  exists($compiled_dependency_regex_by_label->{$_}) && !$seen_compiled{$_}++
 } @$source_rule_order;
 my $dependency_regex_by_label = { %$compiled_dependency_regex_by_label };

 return {
  kind => 'compiled_dependency_regex_state',
  version => 1,
  source_rule_order => $source_rule_order,
  compiled_label_order => \@compiled_label_order,
  dependency_regex_by_label => $dependency_regex_by_label,
 }
}

sub is_compiled_dependency_regex_state {
 my ($value) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless defined($value->{kind}) && $value->{kind} eq 'compiled_dependency_regex_state';
 return 0 unless defined($value->{version}) && $value->{version} == 1;
 return 0 unless ref($value->{source_rule_order}) eq 'ARRAY';
 return 0 unless ref($value->{compiled_label_order}) eq 'ARRAY';
 return 0 unless ref($value->{dependency_regex_by_label}) eq 'HASH';
 return 1
}

sub compiled_dependency_regex_state_regex_by_label {
 my ($state) = @_;
 return {} unless is_compiled_dependency_regex_state($state);
 return $state->{dependency_regex_by_label}
}

sub compiled_dependency_regex_state_to_legacy_gdata {
 my ($state) = @_;
 return undef unless is_compiled_dependency_regex_state($state);
 return { %{compiled_dependency_regex_state_regex_by_label($state)} }
}

sub new_compiled_descriptor_state {
 my (%args) = @_;
 my $compiled_spec_state = $args{compiled_spec_state};
 my $compiled_dependency_regex_state = $args{compiled_dependency_regex_state};
 my $meta = (ref($args{meta}) eq 'HASH') ? $args{meta} : {};

 die "(LinkedSpec::CompilerState::new_compiled_descriptor_state) -E- compiled spec state is invalid"
  unless is_compiled_spec_state($compiled_spec_state);
 die "(LinkedSpec::CompilerState::new_compiled_descriptor_state) -E- compiled dependency-regex state is invalid"
  unless is_compiled_dependency_regex_state($compiled_dependency_regex_state);

 return {
  kind => 'compiled_descriptor_state',
  version => 1,
  compiled_spec_state => $compiled_spec_state,
  compiled_dependency_regex_state => $compiled_dependency_regex_state,
  meta => { %$meta },
 }
}

sub is_compiled_descriptor_state {
 my ($value) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless defined($value->{kind}) && $value->{kind} eq 'compiled_descriptor_state';
 return 0 unless defined($value->{version}) && $value->{version} == 1;
 return 0 unless is_compiled_spec_state($value->{compiled_spec_state});
 return 0 unless is_compiled_dependency_regex_state($value->{compiled_dependency_regex_state});
 return 0 unless ref($value->{meta}) eq 'HASH';
 return 1
}

sub compiled_descriptor_state_spec_state {
 my ($state) = @_;
 return undef unless is_compiled_descriptor_state($state);
 return $state->{compiled_spec_state}
}

sub compiled_descriptor_state_dependency_regex_state {
 my ($state) = @_;
 return undef unless is_compiled_descriptor_state($state);
 return $state->{compiled_dependency_regex_state}
}

sub compiled_descriptor_state_dependency_regex_by_label {
 my ($state) = @_;
 return {} unless is_compiled_descriptor_state($state);
 return compiled_dependency_regex_state_regex_by_label(compiled_descriptor_state_dependency_regex_state($state))
}

sub compiled_descriptor_state_dependency_regex_entry {
 my ($state, $label) = @_;
 return undef unless is_compiled_descriptor_state($state);
 my $dependency_regex_by_label = compiled_descriptor_state_dependency_regex_by_label($state);
 return $dependency_regex_by_label->{$label}
}

sub compiled_descriptor_state_dependency_regex_rows {
 my ($state) = @_;
 return [] unless is_compiled_descriptor_state($state);

 my $dependency_regex_by_label = compiled_descriptor_state_dependency_regex_by_label($state);
 my $compiled_rule_order = compiled_spec_state_compiled_rule_order(compiled_descriptor_state_spec_state($state));
 my %seen;
 my @rows = map {
  $seen{$_} = 1;
  [$_, $dependency_regex_by_label->{$_}]
 } grep { exists $dependency_regex_by_label->{$_} } @$compiled_rule_order;

 push @rows, map { [$_, $dependency_regex_by_label->{$_}] } sort grep { !$seen{$_} } keys %$dependency_regex_by_label;
 return \@rows
}

sub compiled_descriptor_state_rules_by_label {
 my ($state) = @_;
 return {} unless is_compiled_descriptor_state($state);
 return compiled_spec_state_rules_by_label(compiled_descriptor_state_spec_state($state))
}

sub compiled_descriptor_state_has_rule {
 my ($state, $label) = @_;
 return 0 unless is_compiled_descriptor_state($state);
 return compiled_spec_state_has_rule(compiled_descriptor_state_spec_state($state), $label)
}

sub compiled_descriptor_state_rule_info {
 my ($state, $label) = @_;
 return undef unless is_compiled_descriptor_state($state);
 return compiled_spec_state_rule_info(compiled_descriptor_state_spec_state($state), $label)
}

sub compiled_descriptor_state_rule_rows {
 my ($state) = @_;
 return [] unless is_compiled_descriptor_state($state);
 return compiled_spec_state_rule_rows(compiled_descriptor_state_spec_state($state))
}

sub compiled_descriptor_state_validation_view {
 my ($state) = @_;
 return undef unless is_compiled_descriptor_state($state);

 my $rule_rows = compiled_descriptor_state_rule_rows($state);
 my $dependency_regex_rows = compiled_descriptor_state_dependency_regex_rows($state);
 my $rules_by_label = compiled_descriptor_state_rules_by_label($state);

 return {
  kind => 'compiled_descriptor_state_validation_view',
  version => 1,
  rule_rows => [map { [@$_] } @$rule_rows],
  dependency_regex_rows => [map { [@$_] } @$dependency_regex_rows],
  rules_by_label => { %$rules_by_label },
 }
}

sub is_compiled_descriptor_state_validation_view {
 my ($value) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless defined($value->{kind}) && $value->{kind} eq 'compiled_descriptor_state_validation_view';
 return 0 unless defined($value->{version}) && $value->{version} == 1;
 return 0 unless ref($value->{rule_rows}) eq 'ARRAY';
 return 0 unless ref($value->{dependency_regex_rows}) eq 'ARRAY';
 return 0 unless ref($value->{rules_by_label}) eq 'HASH';
 return 1
}

sub compiled_descriptor_state_meta {
 my ($state) = @_;
 return {} unless is_compiled_descriptor_state($state);
 return $state->{meta}
}

sub compiled_descriptor_state_to_legacy_descr {
 my ($state) = @_;
 return undef unless is_compiled_descriptor_state($state);
 return {
  spec => compiled_spec_state_to_legacy_spec(compiled_descriptor_state_spec_state($state)),
  gdata => compiled_dependency_regex_state_to_legacy_gdata(compiled_descriptor_state_dependency_regex_state($state)),
  meta => { %{compiled_descriptor_state_meta($state)} },
 }
}

sub normalize_compiled_spec_input {
 my ($value, %args) = @_;
 my $on_invalid = $args{on_invalid};
 return $value if is_compiled_spec_state($value);

 unless (ref($value) eq 'HASH') {
  my $detail = defined($on_invalid) && ref($on_invalid) eq 'CODE'
   ? $on_invalid->($value)
   : undef;
  die(($detail =~ /\n\z/) ? $detail : "$detail\n") if defined($detail) && length($detail);
  die "(LinkedSpec::CompilerState::normalize_compiled_spec_input) -E- expected HASH or compiled_spec_state";
 }

 my $state = new_compiled_spec_state();
 foreach my $label (sort keys %$value) {
  record_compiled_spec_rule($state, $label, $value->{$label}, {});
 }
 return $state
}

sub normalize_compiled_dependency_regex_output {
 my ($value, $compiled_spec_state, %args) = @_;
 my $on_invalid = $args{on_invalid};
 return $value if is_compiled_dependency_regex_state($value);

 unless (ref($value) eq 'HASH') {
  my $detail = defined($on_invalid) && ref($on_invalid) eq 'CODE'
   ? $on_invalid->($value)
   : undef;
  die(($detail =~ /\n\z/) ? $detail : "$detail\n") if defined($detail) && length($detail);
  die "(LinkedSpec::CompilerState::normalize_compiled_dependency_regex_output) -E- expected HASH or compiled_dependency_regex_state";
 }

 return new_compiled_dependency_regex_state(
  compiled_spec_state => $compiled_spec_state,
  compiled_dependency_regex_by_label => $value,
 )
}

1;
