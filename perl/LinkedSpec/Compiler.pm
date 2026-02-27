package LinkedSpec::Compiler;

use 5.010;
use Data::Dumper;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedRE;

use LinkedSpec::Trace ();

use constant {
 DUMP_NONE   => LinkedSpec::Trace::DUMP_NONE(),
 DUMP_LOW    => LinkedSpec::Trace::DUMP_LOW(),
 DUMP_MEDIUM => LinkedSpec::Trace::DUMP_MEDIUM(),
 DUMP_HIGH   => LinkedSpec::Trace::DUMP_HIGH(),
 DUMP_DEBUG  => LinkedSpec::Trace::DUMP_DEBUG(),
};

sub _run_bootstrap_parse {
 my ($spec_descr, $bootstrap_rule_index, $spec_content_ref, $gdata) = @_;

 my $retv;
 my $parse_success = 1;
 my $error = '';
 eval {
  $retv = &{$$spec_descr[$$bootstrap_rule_index{SPEC_ROOT}]{handler}}($spec_descr, $spec_content_ref, $gdata);
 } or do {
  $parse_success = 0;
  $error = $@;
 };

 return ($parse_success, $retv, $error);
}

sub _build_action_rewriter_migration_summary {
 my ($spec) = @_;

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
  language_agnostic_ready_rules => [],
  language_agnostic_blocked_rules => [],
 language_agnostic_blocked_raw_perl_only_rules => [],
 language_agnostic_blocked_unresolved_helper_only_rules => [],
 language_agnostic_blocked_mixed_rules => [],
  language_agnostic_blocked_rules_by_priority => [],
  language_agnostic_top_blocked_rule => undef,
 };

 return $summary unless ref($spec) eq 'HASH';

 foreach my $rule_name (sort keys %$spec) {
  my $rule = $spec->{$rule_name};
  next unless ref($rule) eq 'HASH';
  ++$summary->{total_rules};

  my $rule_meta = $rule->{meta};
  next unless ref($rule_meta) eq 'HASH';
  my $rewriter_meta = $rule_meta->{action_rewriter};
  next unless ref($rewriter_meta) eq 'HASH';

  ++$summary->{rules_with_action_rewriter_meta};

  my $is_ready = $rewriter_meta->{language_agnostic_action_ir_ready} ? 1 : 0;
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

 if (LinkedSpec::Trace::should_dump(DUMP_DEBUG)) {
  LinkedSpec::Trace::log_output(
   DUMP_DEBUG,
   "(LinkedSpec.pm::_build_action_rewriter_migration_summary) summary",
   Dumper($summary)
  );
 }

 return $summary
}

sub spec_descr {
 my $specretv = shift;
 my $trace_scope = LinkedSpec::Trace::trace_enter('LinkedSpec::Compiler::spec_descr', {
  entry_count => (ref($specretv) eq 'ARRAY') ? scalar(@$specretv) : undef,
 }, DUMP_MEDIUM);

 my @specinfo;
 foreach my $entry (@$specretv) {
  my ($label, $info) = LinkedSpec::spec_entry($entry);
  unless (defined($label) && defined($info) && ref($info) eq 'HASH') {
   LinkedSpec::Trace::log_output(DUMP_NONE, "CRITICAL ERROR", "Rule descriptor build failed while compiling parsed spec entries");
   LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'spec_entry' }, DUMP_MEDIUM);
   return undef
  }
  push @specinfo, $label, $info;
 }

 LinkedSpec::Trace::log_output(DUMP_LOW, "Specinfo array contents", "Number of entries: " . scalar(@specinfo));
 for (my $i = 0; $i < @specinfo; $i += 2) {
  my $label = $specinfo[$i];
  my $info  = $specinfo[$i + 1];
  LinkedSpec::Trace::log_output(DUMP_LOW, "Entry " . ($i / 2), "Label: '$label', Type: " . ref($info));
 }

 my %seen_rules;
 my @duplicate_rules;
 for (my $i = 0; $i < @specinfo; $i += 2) {
  my $label = $specinfo[$i];
  if (exists $seen_rules{$label}) {
   push @duplicate_rules, $label;
   LinkedSpec::Trace::log_output(DUMP_LOW, "Duplicate rule detected", "Rule '$label' is defined multiple times - second definition will overwrite the first");
  }
  $seen_rules{$label} = 1;
 }
 LinkedSpec::Trace::trace_decision('duplicate_rule_definitions_present', scalar(@duplicate_rules) ? 1 : 0, scalar(@duplicate_rules) ? ('duplicate_rules=' . join(',', @duplicate_rules)) : 'no duplicates detected', DUMP_MEDIUM);

 if (@duplicate_rules) {
  LinkedSpec::Trace::log_output(DUMP_LOW, "Duplicate rules summary", "Rules with multiple definitions: " . join(", ", @duplicate_rules));
 }

 my $result = {@specinfo};

 if (LinkedSpec::Trace::should_dump(DUMP_MEDIUM)) {
  LinkedSpec::Trace::log_dump("=== GENERATED SPEC DUMP ===\n");
  LinkedSpec::Trace::log_dump(Dumper($result));
  LinkedSpec::Trace::log_dump("=== END GENERATED SPEC DUMP ===\n");
 }
 LinkedSpec::Trace::trace_exit($trace_scope, { status => 'ok', rule_count => scalar(keys %$result) }, DUMP_MEDIUM);

 return $result
}

sub spec_gdata {
 my $sg = shift;
 my $trace_scope = LinkedSpec::Trace::trace_enter('LinkedSpec::Compiler::spec_gdata', {
  rule_count => (ref($sg) eq 'HASH') ? scalar(keys %$sg) : undef,
 }, DUMP_MEDIUM);

 if (LinkedSpec::Trace::should_dump(DUMP_HIGH)) {
  LinkedSpec::Trace::log_dump("=== SPEC GDATA DUMP ===\n");
  LinkedSpec::Trace::log_dump(Dumper($sg));
  LinkedSpec::Trace::log_dump("=== END SPEC GDATA DUMP ===\n");
 }

 my %gdata;
 foreach my $label (keys %$sg) {
  my @lgdata;
  foreach my $gde (@{$$sg{$label}{gdata}}) {
   if (exists $$sg{$$gde{label}}{re}[$$gde{idx}]) {
    push @lgdata, $$sg{$$gde{label}}{re}[$$gde{idx}]
   } else {
    LinkedSpec::Trace::trace_decision("spec_gdata:$label", 0, "missing regex mapping for label=$$gde{label} idx=$$gde{idx}", DUMP_HIGH);
    my $error_msg = "Rule '$label': Referenced rule '$$gde{label}' has no regex at index $$gde{idx}";
    my $context = "Referenced rule: $$gde{label}, Requested index: $$gde{idx}, Available indices: " .
                  (defined $$sg{$$gde{label}}{re} ? "0.." . ($#{$$sg{$$gde{label}}{re}}) : "none");
    LinkedSpec::Trace::log_output(DUMP_NONE, $error_msg, $context);
    if (LinkedSpec::Trace::should_dump(DUMP_HIGH)) {
     LinkedSpec::Trace::log_dump("=== GDATA ERROR CONTEXT ===\n");
     LinkedSpec::Trace::log_dump("label: $label\n");
     LinkedSpec::Trace::log_dump("gde: ".Dumper($gde)."\n");
     LinkedSpec::Trace::log_dump("sg: ".Dumper($sg)."\n");
     LinkedSpec::Trace::log_dump("lgdata: ".Dumper(\@lgdata)."\n");
     LinkedSpec::Trace::log_dump("=== END GDATA ERROR CONTEXT ===\n");
    }
    # exit 1
   }
  }

  if (@lgdata) {
   LinkedSpec::Trace::trace_decision("spec_gdata:$label", 1, 'resolved at least one regex dependency', DUMP_DEBUG);
   $gdata{$label} = LinkedRE::oredRE(@lgdata);
  }
  else {
   LinkedSpec::Trace::trace_decision("spec_gdata:$label", 0, 'no resolvable regex dependencies for this label', DUMP_DEBUG);
  }
 }

 my $result = \%gdata;

 if (LinkedSpec::Trace::should_dump(DUMP_MEDIUM)) {
  LinkedSpec::Trace::log_dump("=== GENERATED GDATA DUMP ===\n");
  LinkedSpec::Trace::log_dump(Dumper($result));
  LinkedSpec::Trace::log_dump("=== END GENERATED GDATA DUMP ===\n");
 }
 LinkedSpec::Trace::trace_exit($trace_scope, { status => 'ok', compiled_labels => scalar(keys %$result) }, DUMP_MEDIUM);
 return $result
}

sub _build_final_descr {
 my ($auto_descr_spec, $spec_gdata_cb) = @_;

 my $final_descr = {
  spec  => $auto_descr_spec,
  gdata => $spec_gdata_cb->($auto_descr_spec),
 };
 $final_descr->{meta} ||= {};
 $final_descr->{meta}{action_rewriter_migration} = _build_action_rewriter_migration_summary($final_descr->{spec});
 return $final_descr;
}

1;
