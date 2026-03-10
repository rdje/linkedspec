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

use LinkedSpec::BootstrapSpec ();
use LinkedSpec::SpecEntry ();
use LinkedSpec::Trace ();
use LinkedSpec::Validation ();

use constant {
 DUMP_NONE   => LinkedSpec::Trace::DUMP_NONE(),
 DUMP_LOW    => LinkedSpec::Trace::DUMP_LOW(),
 DUMP_MEDIUM => LinkedSpec::Trace::DUMP_MEDIUM(),
 DUMP_HIGH   => LinkedSpec::Trace::DUMP_HIGH(),
 DUMP_DEBUG  => LinkedSpec::Trace::DUMP_DEBUG(),
};

sub _run_bootstrap_parse {
 my ($spec_descr, $bootstrap_rule_index, $spec_content_ref, $gdata) = @_;
 return LinkedSpec::BootstrapSpec::run_bootstrap_parse(
  $spec_content_ref,
  {
   spec_descr => $spec_descr,
   bootstrap_rule_index => $bootstrap_rule_index,
   gdata => $gdata,
  }
 )
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $value = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::Compiler::_require_dep) -E- missing dependency '$name'"
  unless defined $value;
 return $value
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
 my ($specretv, $compile_spec_entry) = @_;
 $compile_spec_entry ||= \&LinkedSpec::SpecEntry::compile_spec_entry;
 die "(LinkedSpec::Compiler::spec_descr) -E- compile_spec_entry callback must be CODE"
  unless ref($compile_spec_entry) eq 'CODE';
 my $trace_scope = LinkedSpec::Trace::trace_enter('LinkedSpec::Compiler::spec_descr', {
  entry_count => (ref($specretv) eq 'ARRAY') ? scalar(@$specretv) : undef,
 }, DUMP_MEDIUM);

 my @specinfo;
 foreach my $entry (@$specretv) {
  my ($label, $info) = $compile_spec_entry->($entry);
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
 $spec_gdata_cb ||= \&spec_gdata;

 my $final_descr = {
  spec  => $auto_descr_spec,
  gdata => $spec_gdata_cb->($auto_descr_spec),
 };
 $final_descr->{meta} ||= {};
 $final_descr->{meta}{action_rewriter_migration} = _build_action_rewriter_migration_summary($final_descr->{spec});
 return $final_descr;
}

sub _require_runtime_ctx {
 my ($deps) = @_;
 my $runtime_ctx = _require_dep($deps, 'runtime_ctx');
 die "(LinkedSpec::Compiler::_require_runtime_ctx) -E- dependency 'runtime_ctx' must be HASH ref"
  unless ref($runtime_ctx) eq 'HASH';
 if (ref($runtime_ctx->{parser_source_chunks_ref}) ne 'ARRAY') {
  my @parser_source_chunks;
  $runtime_ctx->{parser_source_chunks_ref} = \@parser_source_chunks;
 }
 return $runtime_ctx
}

sub _emit_runtime_ctx_parser_source_line {
 my ($runtime_ctx, $chunk) = @_;
 my $emit = (ref($runtime_ctx) eq 'HASH') ? $runtime_ctx->{emit_parser_source_line} : undef;
 return unless ref($emit) eq 'CODE';
 $emit->($chunk);
 return
}

#------------------------------------------------------------------------------
# Function: run_get_pipeline
# Purpose : Execute the full `.spec` compile/generate pipeline used by
#           `LinkedSpec::Get`, with explicit injected bootstrap/runtime state.
# Args    : ($spec_content_ref, $option_hashref, $deps_hashref)
# Returns : parser coderef | descriptor hashref | undef (mode/error dependent)
#------------------------------------------------------------------------------
sub run_get_pipeline {
 my ($spec_content_ref, $option, $deps) = @_;
 $option = {} unless ref($option) eq 'HASH';
 $deps = {} unless ref($deps) eq 'HASH';

 my $bootstrap_parse = _require_dep($deps, 'bootstrap_parse');
 my $compile_spec_entry = _require_dep($deps, 'compile_spec_entry');
 my $runtime_ctx = _require_runtime_ctx($deps);
 my $parser_source_chunks_ref = $runtime_ctx->{parser_source_chunks_ref};

 die "(LinkedSpec::Compiler::run_get_pipeline) -E- dependency 'bootstrap_parse' must be CODE"
  unless ref($bootstrap_parse) eq 'CODE';

 LinkedSpec::Trace::_apply_trace_options($option);
 my $parse_only = $option->{parse_only};
 my $generate_only = $option->{generate_only};
 my $return_descr = $option->{return_descr};
 my $test_expectation = $option->{test_expectation};
 my $dump_parser_source = $option->{dump_parser_source};
 my $parser_source_ref = $option->{parser_source_ref};

 my $trace_scope = LinkedSpec::Trace::trace_enter('LinkedSpec::Get', {
  parse_only => $parse_only ? 1 : 0,
  generate_only => $generate_only ? 1 : 0,
  return_descr => $return_descr ? 1 : 0,
  dump_parser_source => $dump_parser_source ? 1 : 0,
  trace_level => LinkedSpec::Trace::_trace_level_name($LinkedSpec::Trace::DUMP_VERBOSITY),
 }, DUMP_LOW);

 LinkedSpec::Trace::log_output(DUMP_LOW, "Starting parser generation", "Processing .spec file");

 my $validation_failed = 0;

 unless (LinkedSpec::Validation::validate_spec_content($spec_content_ref)) {
  LinkedSpec::Trace::trace_decision('validate_spec_content', 0, 'Input envelope validation failed', DUMP_HIGH);
  if ($parse_only && $test_expectation eq 'fail') {
   $validation_failed = 1;
   LinkedSpec::Trace::log_output(DUMP_LOW, "Validation failed as expected", "Spec content validation failed - this is expected for this test");
  } else {
   LinkedSpec::Trace::log_output(DUMP_NONE, "CRITICAL ERROR", "Spec content validation failed - terminating parser generation");
   LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'validate_spec_content' }, DUMP_LOW);
   return undef;
  }
 } else {
  LinkedSpec::Trace::trace_decision('validate_spec_content', 1, 'Input envelope validation passed', DUMP_HIGH);
 }

 unless ($validation_failed) {
  unless (LinkedSpec::Validation::validate_dsl_syntax($spec_content_ref)) {
   LinkedSpec::Trace::trace_decision('validate_dsl_syntax', 0, 'Rule-level DSL syntax validation failed', DUMP_HIGH);
   if ($parse_only && $test_expectation eq 'fail') {
    $validation_failed = 1;
    LinkedSpec::Trace::log_output(DUMP_LOW, "Validation failed as expected", "DSL syntax validation failed - this is expected for this test");
   } else {
    LinkedSpec::Trace::log_output(DUMP_NONE, "CRITICAL ERROR", "DSL syntax validation failed - terminating parser generation");
    LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'validate_dsl_syntax' }, DUMP_LOW);
    return undef;
   }
  } else {
   LinkedSpec::Trace::trace_decision('validate_dsl_syntax', 1, 'Rule-level DSL syntax validation passed', DUMP_HIGH);
  }
 }

 my $retv;
 my $parse_success = 1;

 LinkedSpec::Trace::log_output(DUMP_LOW, "Starting spec file parsing", "Attempting to parse .spec file content");
 my $parse_error = '';
 ($parse_success, $retv, $parse_error) = $bootstrap_parse->($spec_content_ref);
 unless ($parse_success) {
  LinkedSpec::Trace::log_output(DUMP_NONE, "SPEC PARSING FAILED", "Hardcoded parser failed with error: $parse_error");
 }

 LinkedSpec::Trace::trace_decision('bootstrap_spec_parse', $parse_success, $parse_success ? 'Hardcoded parser returned successfully' : 'Hardcoded parser eval failed', DUMP_HIGH);
 if ($parse_success) {
  LinkedSpec::Trace::log_output(DUMP_LOW, "Spec file parsing successful", "Hardcoded parser completed successfully");
 }

 if (LinkedSpec::Trace::should_dump(DUMP_MEDIUM) || $parse_only) {
  LinkedSpec::Trace::log_dump("=== SPEC COMPILE RESULT DUMP ===\n");
  if ($parse_success && defined $retv) {
   LinkedSpec::Trace::log_dump(Dumper($retv));
  } else {
   LinkedSpec::Trace::log_dump("Parse failed - no result available\n");
  }
  LinkedSpec::Trace::log_dump("=== END SPEC COMPILE RESULT DUMP ===\n");
 }

 unless ($parse_success && defined $retv) {
  LinkedSpec::Trace::log_output(DUMP_NONE, "CRITICAL ERROR", "Spec parsing did not produce a valid intermediate representation");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'bootstrap_parse' }, DUMP_LOW);
  return undef;
 }

 if ($parse_only) {
  LinkedSpec::Trace::log_output(DUMP_LOW, "Parse-only mode", "Stopping after .spec file parsing - no parser generated");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'ok', stage => 'parse_only', parse_only => 1 }, DUMP_LOW);
  return undef;
 }

 LinkedSpec::Trace::log_output(DUMP_LOW, "Starting parser generation", "Converting parsed spec data into executable parser");
 if ($dump_parser_source) {
  _emit_runtime_ctx_parser_source_line($runtime_ctx, "my \$descr = {\n spec => {\n");
 }

 my $auto_descr_spec = spec_descr($retv, $compile_spec_entry);
 unless (defined($auto_descr_spec) && ref($auto_descr_spec) eq 'HASH') {
  LinkedSpec::Trace::log_output(DUMP_NONE, "CRITICAL ERROR", "Spec descriptor generation failed");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'spec_descr' }, DUMP_LOW);
  return undef;
 }
 my $final_descr = _build_final_descr($auto_descr_spec);

 unless (LinkedSpec::Validation::validate_gdata_references($final_descr->{gdata}, $final_descr->{spec})) {
  LinkedSpec::Trace::log_output(DUMP_NONE, "CRITICAL ERROR", "Generated parser validation failed - terminating parser generation");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'validate_gdata_references' }, DUMP_LOW);
  return undef;
 }

 my $rule_count = scalar(keys %$auto_descr_spec);
 LinkedSpec::Trace::log_output(DUMP_LOW, "Parser generation completed", "Generated parser with $rule_count rules");
 if ($dump_parser_source) {
  _emit_runtime_ctx_parser_source_line($runtime_ctx, " },\n gdata => {\n");
  my @glabels = sort keys %{$final_descr->{gdata} || {}};
  for (my $i = 0; $i < @glabels; ++$i) {
   my $label = $glabels[$i];
   my $gregex = $final_descr->{gdata}{$label};
   my $prefix = $i ? ",\n" : '';
   _emit_runtime_ctx_parser_source_line($runtime_ctx, $prefix . " $label\t=> qr/$gregex/o");
  }
  my $top_rule = $runtime_ctx->{top_rule};
  _emit_runtime_ctx_parser_source_line($runtime_ctx, "\n }\n};\n\nsub Get {&{\$descr->{spec}{$top_rule}}(\$descr, \$_[0])}\n");
  my $parser_source = join('', @$parser_source_chunks_ref);
  if (ref($parser_source_ref) eq 'SCALAR') {
   $$parser_source_ref = $parser_source;
  } else {
   print $parser_source;
  }
 }

 if (LinkedSpec::Trace::should_dump(DUMP_LOW)) {
  my $top_rule = $runtime_ctx->{top_rule};
  LinkedSpec::Trace::log_dump("=== FINAL_DESCR DUMP: top_rule=$top_rule ===\n");
  LinkedSpec::Trace::log_dump(Dumper($final_descr));
  LinkedSpec::Trace::log_dump("=== END FINAL_DESCR DUMP: top_rule=$top_rule ===\n");
 }

 if ($generate_only) {
  LinkedSpec::Trace::log_output(DUMP_LOW, "Generate-only mode", "Stopping after parser generation - no functional parser returned");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'ok', stage => 'generate_only', generate_only => 1 }, DUMP_LOW);
  return undef;
 }

 if ($return_descr) {
  LinkedSpec::Trace::log_output(DUMP_LOW, "Descriptor-return mode", "Returning generated parser descriptor hash");
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'ok', stage => 'return_descr', return_descr => 1, rule_count => $rule_count }, DUMP_LOW);
  return $final_descr;
 }

 LinkedSpec::Trace::log_output(DUMP_LOW, "Parser generation completed successfully", "Returning functional parser for execution");
 LinkedSpec::Trace::trace_exit($trace_scope, { status => 'ok', stage => 'parser_ready', top_rule => $runtime_ctx->{top_rule}, rule_count => $rule_count }, DUMP_LOW);

 my $top_rule = $runtime_ctx->{top_rule};
 return sub {&{$final_descr->{spec}{$top_rule}{handler}}($final_descr, $_[0])}
}

1;
