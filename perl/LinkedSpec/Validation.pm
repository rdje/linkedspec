#------------------------------------------------------------------------------
# Package: LinkedSpec::Validation
# Purpose: Frontend validation owner for early `.spec` envelope, rule-paragraph,
#          edge-target, and reference diagnostics before bootstrap/runtime work.
#------------------------------------------------------------------------------
package LinkedSpec::Validation;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::OwnerDispatch ();

use constant {
 DUMP_NONE => 0,
 DUMP_LOW  => 100,
};

sub _require_trace_pkg {
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
 return 1
}

sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
}

sub _trace_log_output {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::log_output(@args)
 })
}

sub _parse_rule_label_line {
 my ($line) = @_;
 return undef unless defined $line;
 return undef unless $line =~ /\A\s*(?<LABEL>\w+)\s*(?<COLON>::|:)(?<TAIL>.*)\z/o;

 my $label = $+{LABEL};
 my $is_top = $+{COLON} eq '::' ? 1 : 0;
 my $tail = defined($+{TAIL}) ? $+{TAIL} : '';
 $tail =~ s/^\s+//o;

 my ($mode, $rhs, $invalid_mode) = ('', $tail, 0);

 if ($tail =~ /\A(?<MODE>OR\s*\{[^}]+\}|AND\s*\{[^}]+\})(?<REST>\s.*|\z)/o) {
  ($mode, $rhs) = ($+{MODE}, defined($+{REST}) ? $+{REST} : '');
  my $normalized = $mode;
  $normalized =~ s/\s+//go;
  if ($normalized =~ /\A(?<KIND>OR|AND)\{(?<BODY>[^}]*)\}\z/o) {
   my $body = $+{BODY};
   if ($body =~ /\A\d+\z/o) {
    $invalid_mode = 0;
   } elsif ($body =~ /\A\d*,\d*\z/o && $body ne ',') {
    my ($min, $max) = split /,/, $body, 2;
    $min = length($min) ? $min : 0;
    $max = length($max) ? $max : 10**9;
    $invalid_mode = $max < $min ? 1 : 0;
   } else {
    $invalid_mode = 1;
   }
  }
 } elsif ($tail =~ /\A(?<MODE>AND\+|AND|OR\+|OR)(?<REST>\s.*|\z)/o) {
  ($mode, $rhs) = ($+{MODE}, defined($+{REST}) ? $+{REST} : '');
 } elsif ($tail =~ /\A(?:AND|OR)\w/o) {
  $invalid_mode = 1;
 } elsif ($tail =~ /\A(?<MODE>[&|\+\*\?])(?<REST>\s.*|\z)/o) {
  ($mode, $rhs) = ($+{MODE}, defined($+{REST}) ? $+{REST} : '');
 } elsif ($tail =~ /\A:/o) {
  $invalid_mode = 1;
 } elsif ($tail =~ /\A(?:[&|\+\*\?]|AND(?:\b|\{|\+)|OR(?:\b|\{|\+))/o) {
  $invalid_mode = 1;
 }

 return {
  label        => $label,
  is_top       => $is_top,
  mode         => $mode,
  rhs          => defined($rhs) ? $rhs : '',
  invalid_mode => $invalid_mode ? 1 : 0,
 }
}

sub _looks_like_malformed_rule_label_line {
 my ($line) = @_;
 my $parsed = _parse_rule_label_line($line);
 return ref($parsed) eq 'HASH' && $parsed->{invalid_mode} ? 1 : 0
}

sub get_dsl_context {
 my ($spec_content, $position) = @_;

 my $before_pos = substr($$spec_content, 0, $position);
 my $line_number = 1 + ($before_pos =~ tr/\n//);

 my @lines = split(/\n/, $$spec_content);
 my $current_line = $lines[$line_number - 1] || "";

 my $prev_line = $line_number > 1 ? $lines[$line_number - 2] : "";
 my $next_line = $line_number < @lines ? $lines[$line_number - 1] : "";

 return {
  line_number => $line_number,
  current_line => $current_line,
  prev_line => $prev_line,
  next_line => $next_line,
  position => $position
 };
}

sub _build_dsl_error_message {
 my ($spec_content, $position, $error_msg, $suggestion) = @_;

 my $context = get_dsl_context($spec_content, $position);

 my $error = "DSL Error at line $context->{line_number}:\n";
 $error .= "  $error_msg\n";
 $error .= "  Line: $context->{current_line}\n";

 if ($context->{prev_line}) {
  $error .= "  Previous: $context->{prev_line}\n";
 }
 if ($context->{next_line}) {
  $error .= "  Next: $context->{next_line}\n";
 }

 if ($suggestion) {
  $error .= "  Suggestion: $suggestion\n";
 }

 return $error;
}

sub report_dsl_error {
 my ($spec_content, $position, $error_msg, $suggestion) = @_;
 my $error = _build_dsl_error_message($spec_content, $position, $error_msg, $suggestion);

 _trace_log_output(DUMP_NONE, $error, "DSL validation failed");
 return undef
}

sub validate_spec_content {
 my ($spec_content, $option) = @_;
 $option = {} unless ref($option) eq 'HASH';

 unless (ref($spec_content) eq 'SCALAR') {
  _trace_log_output(DUMP_NONE, "Invalid spec content type", "Expected SCALAR reference, got " . ref($spec_content));
  return 0;
 }

 unless (length($$spec_content) > 0) {
  _trace_log_output(DUMP_NONE, "Spec content is empty", "Spec file must contain content");
  return 0;
 }

 my @lines = split(/\n/, $$spec_content);
 my $found_rule = 0;
 my $found_top_rule = 0;
 my $first_significant_line_seen = 0;

 foreach my $line (@lines) {
  next if $line =~ /^\s*$/;
  next if $line =~ /^\s*#/;

   unless ($first_significant_line_seen) {
    $first_significant_line_seen = 1;
   my $first_rule = _parse_rule_label_line($line);
    unless ($first_rule && !$first_rule->{invalid_mode}) {
     my $position = index($$spec_content, $line);
     if (_looks_like_malformed_rule_label_line($line)) {
      _report_dsl_validation_failure($spec_content, $position,
       "Malformed rule label syntax",
       "Use a supported rule label like 'RuleName:', 'RuleName::', 'RuleName:AND+', 'RuleName:OR+', or 'RuleName:OR{2,4}'",
       $option,
       summary => 'Malformed rule label syntax',
       rule_label => (ref($first_rule) eq 'HASH' ? $first_rule->{label} : undef),
      );
     } else {
      _report_dsl_validation_failure($spec_content, $position,
       "Spec file must start with a rule definition",
       "Make the first non-comment line a rule like 'RuleName:' or 'RuleName::'",
       $option,
       summary => 'Spec file must start with a rule definition',
      );
     }
     return 0;
    }
   }

  my $parsed = _parse_rule_label_line($line);
  if ($parsed) {
   $found_rule = 1;
   $found_top_rule = 1 if $parsed->{is_top};
   last if $found_top_rule;
  }
 }

 unless ($found_rule) {
  _report_dsl_validation_failure($spec_content, 0,
   "Spec file must start with a rule definition",
   "Add a rule like 'RuleName::' at the beginning",
   $option,
   summary => 'Spec file must start with a rule definition',
  );
  return 0;
 }

 unless ($found_top_rule) {
  _report_dsl_validation_failure($spec_content, 0,
   "Spec file must define a top rule with '::'",
   "Add a top rule like 'RuleName::' so the parser has an entrypoint",
   $option,
   summary => "Spec file must define a top rule with '::'",
  );
  return 0;
 }

 return 1;
}

sub validate_rule_definition {
 my ($rule_name, $rule_def) = @_;

 unless (ref($rule_def) eq 'HASH') {
  _trace_log_output(DUMP_NONE, "Invalid rule definition for '$rule_name'", "Expected HASH reference, got " . ref($rule_def));
  return 0;
 }

 unless (exists $rule_def->{handler}) {
  _trace_log_output(DUMP_NONE, "Rule '$rule_name' missing required 'handler' field", "All rules must define handler code");
  return 0;
 }

 if (exists $rule_def->{re}) {
  unless (ref($rule_def->{re}) eq 'ARRAY') {
   _trace_log_output(DUMP_NONE, "Rule '$rule_name' 're' field must be an array", "Got " . ref($rule_def->{re}));
   return 0;
  }

  for my $i (0..$#{$rule_def->{re}}) {
   my $regex = $rule_def->{re}[$i];
   eval { qr/$regex/ } or do {
    _trace_log_output(DUMP_NONE, "Invalid regex in rule '$rule_name' at index $i", "Error: $@");
    return 0;
   };
  }
 }

 return 1;
}

sub _notify_gdata_validation_failure {
 my ($option, %info) = @_;
 return undef unless ref($option) eq 'HASH';
 my $cb = $option->{on_failure};
 return undef unless ref($cb) eq 'CODE';
 return $cb->(%info)
}

sub _notify_dsl_validation_failure {
 my ($option, %info) = @_;
 return undef unless ref($option) eq 'HASH';
 my $cb = $option->{on_failure};
 return undef unless ref($cb) eq 'CODE';
 return $cb->(%info)
}

sub _report_dsl_validation_failure {
 my ($spec_content, $position, $error_msg, $suggestion, $option, %info) = @_;
 my $detail = _build_dsl_error_message($spec_content, $position, $error_msg, $suggestion);
 _notify_dsl_validation_failure(
  $option,
  summary => defined($info{summary}) ? $info{summary} : $error_msg,
  detail => $detail,
  (defined($info{rule_label}) ? (rule_label => $info{rule_label}) : ()),
 );
 return report_dsl_error($spec_content, $position, $error_msg, $suggestion)
}

sub _describe_validation_value_kind {
 my ($value) = @_;

 return 'undef' unless defined($value);
 return ref($value) ? ref($value) : 'SCALAR';
}

sub _is_compiled_descriptor_state {
 my ($value) = @_;

 return 0 unless ref($value) eq 'HASH';
 return 0 unless defined($value->{kind}) && $value->{kind} eq 'compiled_descriptor_state';
 return 0 unless defined($value->{version}) && $value->{version} == 1;
 return 0 unless ref($value->{compiled_spec_state}) eq 'HASH';
 return 0 unless ref($value->{compiled_spec_state}{rules_by_label}) eq 'HASH';
 return 0 unless ref($value->{compiled_gdata_by_label}) eq 'HASH';
 return 0 unless ref($value->{meta}) eq 'HASH';
 return 1;
}

sub _compiled_descriptor_state_to_legacy_spec {
 my ($descriptor_state) = @_;
 return undef unless _is_compiled_descriptor_state($descriptor_state);
 return { %{$descriptor_state->{compiled_spec_state}{rules_by_label}} };
}

sub validate_compiled_descriptor_state {
 my ($descriptor_state, $option) = @_;
 $option = {} unless ref($option) eq 'HASH';

 unless (_is_compiled_descriptor_state($descriptor_state)) {
  my $detail = 'Expected compiled_descriptor_state HASH reference, got '
   . _describe_validation_value_kind($descriptor_state);
  _notify_gdata_validation_failure(
   $option,
   summary => 'Invalid compiled descriptor state',
   detail => $detail,
  );
  _trace_log_output(DUMP_NONE, 'Invalid compiled descriptor state', $detail);
  return 0;
 }

 return validate_gdata_references(
  $descriptor_state->{compiled_gdata_by_label},
  _compiled_descriptor_state_to_legacy_spec($descriptor_state),
  $option,
 );
}

sub validate_gdata_references {
 my ($gdata, $spec, $option) = @_;
 $option = {} unless ref($option) eq 'HASH';

 unless (ref($gdata) eq 'HASH') {
  my $detail = "Expected HASH reference, got " . _describe_validation_value_kind($gdata);
  _notify_gdata_validation_failure(
   $option,
   summary => 'Invalid gdata structure',
   detail => $detail,
  );
  _trace_log_output(DUMP_NONE, "Invalid gdata structure", $detail);
  return 0;
 }

 unless (ref($spec) eq 'HASH') {
  my $detail = "Expected HASH reference, got " . _describe_validation_value_kind($spec);
  _notify_gdata_validation_failure(
   $option,
   summary => 'Invalid spec structure',
   detail => $detail,
  );
  _trace_log_output(DUMP_NONE, "Invalid spec structure", $detail);
  return 0;
 }

 for my $rule_name (keys %$gdata) {
  my $gdata_entry = $gdata->{$rule_name};

  unless (exists $spec->{$rule_name}) {
   my $summary = "Gdata references non-existent rule '$rule_name'";
   my $detail = 'Rule not found in spec';
   _notify_gdata_validation_failure(
    $option,
    summary => $summary,
    detail => $detail,
    rule_label => $rule_name,
   );
   _trace_log_output(DUMP_NONE, $summary, $detail);
   return 0;
  }

  unless (ref($gdata_entry) eq 'Regexp') {
   my $summary = "Invalid gdata entry for rule '$rule_name'";
   my $detail = "Expected compiled regex, got " . ref($gdata_entry);
   _notify_gdata_validation_failure(
    $option,
    summary => $summary,
    detail => $detail,
    rule_label => $rule_name,
   );
   _trace_log_output(DUMP_NONE, $summary, $detail);
   return 0;
  }
 }

 for my $rule_name (keys %$spec) {
  my $rule_def = $spec->{$rule_name};

  my $rule_valid = eval { validate_rule_definition($rule_name, $rule_def) };
  my $validate_rule_definition_error = $@;
  if ($validate_rule_definition_error) {
   _notify_gdata_validation_failure(
    $option,
    summary => "Rule definition validation failed for rule '$rule_name'",
    detail => $validate_rule_definition_error,
    rule_label => $rule_name,
   );
   die $validate_rule_definition_error;
  }

  unless ($rule_valid) {
   _notify_gdata_validation_failure(
    $option,
    summary => "Invalid rule definition for rule '$rule_name'",
    detail => "validate_rule_definition returned false for rule '$rule_name'",
    rule_label => $rule_name,
   );
   return 0;
  }

  if (exists $rule_def->{gdata} && ref($rule_def->{gdata}) eq 'ARRAY') {
   for my $i (0..$#{$rule_def->{gdata}}) {
    my $element = $rule_def->{gdata}[$i];
    unless (ref($element) eq 'HASH' && exists $element->{label} && exists $element->{idx}) {
     my $summary = "Invalid gdata element at index $i for rule '$rule_name'";
     my $detail = "Expected HASH with 'label' and 'idx' keys";
     _notify_gdata_validation_failure(
      $option,
      summary => $summary,
      detail => $detail,
      rule_label => $rule_name,
     );
     _trace_log_output(DUMP_NONE, $summary, $detail);
     return 0;
    }

    my $ref_rule = $element->{label};
    unless (exists $spec->{$ref_rule}) {
     my $summary = "Gdata element references non-existent rule '$ref_rule'";
     my $detail = "Rule '$rule_name' references missing gdata rule '$ref_rule'";
     _notify_gdata_validation_failure(
      $option,
      summary => $summary,
      detail => $detail,
      rule_label => $rule_name,
     );
     _trace_log_output(DUMP_NONE, $summary, $detail);
     return 0;
    }

    my $ref_idx = $element->{idx};
    my $ref_rule_def = $spec->{$ref_rule};
    unless (exists $ref_rule_def->{re} && $ref_idx < @{$ref_rule_def->{re}}) {
     my $summary = "Invalid regex index $ref_idx for rule '$ref_rule'";
     my $detail = "Rule '$rule_name' references out-of-bounds regex index $ref_idx on rule '$ref_rule'";
     _notify_gdata_validation_failure(
      $option,
      summary => $summary,
      detail => $detail,
      rule_label => $rule_name,
     );
     _trace_log_output(DUMP_NONE, $summary, $detail);
     return 0;
    }
   }
  }
 }

 return 1;
}

sub validate_dsl_syntax {
 my ($spec_content, $option) = @_;
 $option = {} unless ref($option) eq 'HASH';

 my @lines = split(/\n/, $$spec_content);
 my @defined_rules = ();
 my @used_rules = ();
 my %seen_defined_rules;
 my $current_rule;
 my $seen_first_rule = 0;

 for my $line (@lines) {
 next if $line =~ /^\s*$/;
 next if $line =~ /^\s*#/;

  my $at_rule_top_level = !($current_rule && (($current_rule->{edge_scan_depth} // 0) > 0));
  my $rule_label = $at_rule_top_level ? _parse_rule_label_line($line) : undef;
  if ($rule_label) {
   $seen_first_rule = 1;
   if ($current_rule && $current_rule->{acode_count} && $current_rule->{bcode_count}) {
 return _report_mixed_rule_action_modes(
  $current_rule->{label},
  $current_rule->{acode_count},
  $current_rule->{bcode_count},
  $option,
 );
}

   if ($rule_label->{invalid_mode}) {
    my $position = index($$spec_content, $line);
    _report_dsl_validation_failure($spec_content, $position,
     "Malformed rule label syntax",
     "Use a supported rule label like 'RuleName:', 'RuleName::', 'RuleName:AND+', 'RuleName:OR+', or 'RuleName:OR{2,4}'",
     $option,
     summary => 'Malformed rule label syntax',
    );
    return 0;
  }
  my $rule_name = $rule_label->{label};
  push @defined_rules, $rule_name;

  if ($seen_defined_rules{$rule_name}++) {
    my $position = index($$spec_content, $line);
    _report_dsl_validation_failure($spec_content, $position,
     "Duplicate rule definition: '$rule_name'",
     "Remove the duplicate rule or rename one of them",
     $option,
     summary => "Duplicate rule definition: '$rule_name'",
     rule_label => $rule_name,
    );
    return 0;
   }

   unless (_validate_rule_header_rhs_start($spec_content, $line, $rule_label->{rhs}, $option, $rule_name)) {
    return 0;
   }

   my $edge_scan = _scan_rule_edges_in_fragment($rule_label->{rhs});
   if ($edge_scan->{error}) {
    my $position = index($$spec_content, $line);
    return _report_edge_target_syntax_error($spec_content, $position, $edge_scan->{error}, $option, $rule_name);
   }
   my ($acode_count, $bcode_count) = _count_rule_edge_kinds_in_fragment($rule_label->{rhs}, $edge_scan);
   push @used_rules, map { $_->{label} } @{$edge_scan->{edges} || []};
   $current_rule = {
    label => $rule_name,
    acode_count => $acode_count,
    bcode_count => $bcode_count,
    edge_scan_depth => $edge_scan->{depth} // 0,
   };
  } elsif ($at_rule_top_level && _looks_like_malformed_rule_label_line($line)) {
   my $position = index($$spec_content, $line);
   _report_dsl_validation_failure($spec_content, $position,
    "Malformed rule label syntax",
    "Use a supported rule label like 'RuleName:', 'RuleName::', 'RuleName:AND+', 'RuleName:OR+', or 'RuleName:OR{2,4}'",
    $option,
    summary => 'Malformed rule label syntax',
   );
   return 0;
  } elsif (!$seen_first_rule) {
   my $position = index($$spec_content, $line);
   _report_dsl_validation_failure($spec_content, $position,
    "Spec file must start with a rule definition",
    "Make the first non-comment line a rule like 'RuleName:' or 'RuleName::'",
    $option,
    summary => 'Spec file must start with a rule definition',
   );
   return 0;
  } elsif ($current_rule) {
   my $start_depth = $current_rule->{edge_scan_depth} // 0;
   if ($start_depth == 0 && _looks_like_split_marker_prefix($line) && !_looks_like_supported_split_marker_start($line)) {
    my $position = index($$spec_content, $line);
    return _report_split_marker_syntax_error($spec_content, $position, $option, $current_rule->{label});
   }
   if ($start_depth == 0 && !_looks_like_supported_rule_paragraph_member_line($line)) {
    my $position = index($$spec_content, $line);
    _report_dsl_validation_failure($spec_content, $position,
     "Unsupported top-level rule paragraph content",
     "After a rule start, use regexes, lifecycle/code blocks, action edges, blind calls, split markers, or start the next rule",
     $option,
     summary => 'Unsupported top-level rule paragraph content',
     rule_label => $current_rule->{label},
    );
    return 0;
   }

   my $edge_scan = _scan_rule_edges_in_fragment($line, $start_depth);
   if ($edge_scan->{error}) {
    my $position = index($$spec_content, $line);
    return _report_edge_target_syntax_error($spec_content, $position, $edge_scan->{error}, $option, $current_rule->{label});
   }
   my ($acode_count, $bcode_count) = _count_rule_edge_kinds_in_fragment($line, $edge_scan);
   $current_rule->{acode_count} += $acode_count;
   $current_rule->{bcode_count} += $bcode_count;
   $current_rule->{edge_scan_depth} = $edge_scan->{depth} // 0;
   push @used_rules, map { $_->{label} } @{$edge_scan->{edges} || []};
   if ($current_rule->{acode_count} && $current_rule->{bcode_count}) {
    return _report_mixed_rule_action_modes(
     $current_rule->{label},
     $current_rule->{acode_count},
     $current_rule->{bcode_count},
     $option,
    );
   }
  }

 }

if ($current_rule && $current_rule->{acode_count} && $current_rule->{bcode_count}) {
 return _report_mixed_rule_action_modes(
  $current_rule->{label},
  $current_rule->{acode_count},
  $current_rule->{bcode_count},
  $option,
 );
}

 if ($current_rule && (($current_rule->{edge_scan_depth} // 0) > 0)) {
  return _report_unclosed_rule_block_error($spec_content, length($$spec_content), $option, $current_rule->{label});
 }

my $regex_depth = 0;
 for my $line (@lines) {
  next if $line =~ /^\s*$/;
  next if $line =~ /^\s*#/;

  my $rule_label = $regex_depth == 0 ? _parse_rule_label_line($line) : undef;
  my $regex_fragment = $rule_label ? $rule_label->{rhs} : $line;
  my @regex_literals = $regex_depth == 0
   ? _extract_leading_regex_literals_from_fragment($regex_fragment)
   : ();

  for my $regex_literal (@regex_literals) {
   my $regex_pattern = $regex_literal;
   $regex_pattern =~ s{^/|/$}{}g;

   eval { qr/$regex_pattern/ } or do {
    my $position = index($$spec_content, $line);
    _report_dsl_validation_failure($spec_content, $position,
     "Invalid regex pattern: $regex_literal",
     "Check the regex syntax and ensure proper escaping",
     $option,
     summary => "Invalid regex pattern: $regex_literal",
     rule_label => $current_rule ? $current_rule->{label} : undef,
    );
    return 0;
   };
  }

  my $regex_scan = _scan_rule_edges_in_fragment($regex_fragment, $regex_depth);
  $regex_depth = $regex_scan->{depth} // 0;
 }

 my %defined_rules = map { $_ => 1 } @defined_rules;
 my %used_rules = map { $_ => 1 } @used_rules;

 my @unused_rules = grep { !$used_rules{$_} } @defined_rules;
 if (@unused_rules) {
  _trace_log_output(DUMP_LOW, "Warning: Unused rules detected", "Rules defined but never used: " . join(", ", @unused_rules));
 }

 my @undefined_rules = grep { !$defined_rules{$_} } @used_rules;
 if (@undefined_rules) {
  my @unique_undefined = do { my %seen; grep { !$seen{$_}++ } @undefined_rules };
  _trace_log_output(DUMP_LOW, "Warning: Undefined rules referenced", "Rules referenced but not defined: " . join(", ", @unique_undefined));
 }

 return 1;
}

sub _looks_like_supported_rule_paragraph_member_line {
 my ($line) = @_;
 return 0 unless defined $line;
 return 1 if $line =~ /^\s*$/o;
 return 1 if $line =~ /^\s*#/o;
 return 1 if _parse_rule_label_line($line);
 return 1 if $line =~ /^\s*\/(?:\\.|[^\/])*?(?<!\\)\//o;
 return 1 if $line =~ /^\s*->/o;
 return 1 if $line =~ /^\s*=>/o;
 return 1 if $line =~ /^\s*@\s*(?:(?:capture_slice|capture_from_here|move_pos)\b|mark\s*\(\s*\w+\s*\))/o;
 return 1 if $line =~ /^\s*-\?\s+\w+\b/o;
 return 1 if $line =~ /^\s*\.\s*\w/o;
 return 1 if $line =~ /^\s*\w+\s*\(/o;
  return 1 if $line =~ /^\s*\w+\s*\{/o;
  return 1 if $line =~ /^\s*\w+\s*\./o;
  return 0;
}

sub _looks_like_split_marker_prefix {
 my ($fragment) = @_;
 return 0 unless defined $fragment;
 return $fragment =~ /^\s*@/o ? 1 : 0;
}

sub _looks_like_supported_split_marker_start {
 my ($fragment) = @_;
 return 0 unless defined $fragment;
 return $fragment =~ /^\s*@\s*(?:(?:capture_slice|capture_from_here|move_pos)\b|mark\s*\(\s*\w+\s*\))/o ? 1 : 0;
}

sub _trim_leading_rule_header_regex_cluster {
 my ($fragment) = @_;
 return '' unless defined $fragment;

 my $trimmed = $fragment;
 $trimmed =~ s/^\s+//o;
 return '' unless length($trimmed);

 pos($trimmed) = 0;
 while ($trimmed =~ /\G\s*(\/(?:\\.|[^\/])*?(?<!\\)\/)/gc) {
 }

 my $offset = pos($trimmed);
 $offset = 0 unless defined $offset;
 my $rest = substr($trimmed, $offset);
 $rest =~ s/^\s+//o;
 return $rest;
}

sub _invalid_regex_token_prefix {
 my ($fragment) = @_;
 return '/' unless defined $fragment;

 if ($fragment =~ /^\s*(\/[^\s]*)/o) {
  return $1;
 }

 return '/';
}

sub _validate_rule_header_rhs_start {
 my ($spec_content, $line, $rhs, $option, $rule_label) = @_;
 return 1 unless defined $rhs;

 my $trimmed_rhs = $rhs;
 $trimmed_rhs =~ s/^\s+//o;
 return 1 unless length($trimmed_rhs);

 my $remaining = _trim_leading_rule_header_regex_cluster($trimmed_rhs);

 if (length($remaining) && _looks_like_split_marker_prefix($remaining) && !_looks_like_supported_split_marker_start($remaining)) {
  my $position = index($$spec_content, $line);
  return _report_split_marker_syntax_error($spec_content, $position, $option, $rule_label);
 }

 if (length($remaining) && $remaining =~ m{\A/}o) {
  my $position = index($$spec_content, $line);
  my $bad_regex = _invalid_regex_token_prefix($remaining);
  _report_dsl_validation_failure($spec_content, $position,
   "Invalid regex pattern: $bad_regex",
   "Check the regex syntax and ensure proper escaping",
   $option,
   summary => "Invalid regex pattern: $bad_regex",
   rule_label => $rule_label,
  );
  return 0;
 }

 return 1 unless length($remaining);
 return 1 if _looks_like_supported_rule_paragraph_member_line($remaining);

 my $position = index($$spec_content, $line);
 _report_dsl_validation_failure($spec_content, $position,
  "Unsupported same-line rule header content",
  "After a rule start or leading regex cluster, use regexes, lifecycle/code blocks, action edges, blind calls, split markers, or end the line",
  $option,
  summary => 'Unsupported same-line rule header content',
  rule_label => $rule_label,
 );
 return 0;
}

#------------------------------------------------------------------------------
# Function: _scan_rule_edges_in_fragment
# Purpose : Scan one rule fragment for action/blind-call edges while tracking
#           cross-line block depth and reporting malformed target/balance state.
# Args    : ($fragment, $start_depth)
# Returns : hashref with `edges`, `depth`, and optional `error`
#------------------------------------------------------------------------------
sub _scan_rule_edges_in_fragment {
 my ($fragment, $start_depth) = @_;
 my @edges;
 return { edges => \@edges } unless defined $fragment;

 my $len = length($fragment);
 my $depth = $start_depth // 0;
 my $i = 0;

 while ($i < $len) {
  my $ch = substr($fragment, $i, 1);

  if ($ch eq q{'}) {
   ++$i;
   while ($i < $len) {
    my $inner = substr($fragment, $i, 1);
    if ($inner eq q{\\}) {
     $i += 2;
     next;
    }
    ++$i;
    last if $inner eq q{'};
   }
   next;
  }

  if ($ch eq q{"}) {
   ++$i;
   while ($i < $len) {
    my $inner = substr($fragment, $i, 1);
    if ($inner eq q{\\}) {
     $i += 2;
     next;
    }
    ++$i;
    last if $inner eq q{"};
   }
   next;
  }

  if ($ch eq q{/}) {
   my $slash_cursor = _consume_slash_construct($fragment, $i, $len);
   if (defined $slash_cursor) {
    $i = $slash_cursor;
    next;
   }
  }

  if ($ch eq '{' || $ch eq '(' || $ch eq '[') {
   ++$depth;
   ++$i;
   next;
  }

  if ($ch eq '}' || $ch eq ')' || $ch eq ']') {
   if ($depth > 0) {
    --$depth;
    ++$i;
    next;
   }

   return {
    error => {
     kind   => 'structure',
     reason => 'unexpected_closer',
     closer => $ch,
    },
   };
  }

  if ($depth == 0 && (substr($fragment, $i, 2) eq '->' || substr($fragment, $i, 2) eq '=>')) {
   my $kind = substr($fragment, $i, 2) eq '->' ? 'action' : 'blind_call';
   my $cursor = $i + 2;
   my @edge_targets;

   my $parse_target = sub {
    my ($target_cursor) = @_;

    ++$target_cursor while $target_cursor < $len && substr($fragment, $target_cursor, 1) =~ /\s/;
    my $label_start = $target_cursor;
    ++$target_cursor while $target_cursor < $len && substr($fragment, $target_cursor, 1) =~ /\w/;

    if ($target_cursor == $label_start) {
     return {
      error => {
       kind   => $kind,
       reason => 'missing_target',
      },
     };
    }

    my $label = substr($fragment, $label_start, $target_cursor - $label_start);
    my $suffix_cursor = $target_cursor;
    ++$target_cursor while $target_cursor < $len && substr($fragment, $target_cursor, 1) =~ /\s/;

    if ($target_cursor < $len && substr($fragment, $target_cursor, 1) eq '[') {
     if ($kind eq 'blind_call') {
      return {
       error => {
        kind   => $kind,
        reason => 'indexed_target_not_supported',
        label  => $label,
       },
      };
     }

     my $index_cursor = $target_cursor + 1;
     my $digit_start = $index_cursor;
     ++$index_cursor while $index_cursor < $len && substr($fragment, $index_cursor, 1) =~ /\d/;

     if ($index_cursor == $digit_start || $index_cursor >= $len || substr($fragment, $index_cursor, 1) ne ']') {
      return {
       error => {
        kind   => $kind,
        reason => 'malformed_index',
        label  => $label,
       },
      };
     }

     $target_cursor = $index_cursor + 1;
     $suffix_cursor = $target_cursor;
     ++$target_cursor while $target_cursor < $len && substr($fragment, $target_cursor, 1) =~ /\s/;
    }

    return {
     label         => $label,
     cursor        => $target_cursor,
     suffix_cursor => $suffix_cursor,
    };
   };

   my $first_target = $parse_target->($cursor);
   return { error => $first_target->{error} } if $first_target->{error};
   if ($first_target->{suffix_cursor} < $len) {
    my $immediate_suffix = substr($fragment, $first_target->{suffix_cursor}, 1);
    my $immediate_ok = $immediate_suffix =~ /\s/o || $immediate_suffix eq '{' || $immediate_suffix eq '.';
    $immediate_ok = 1 if $kind eq 'action' && $immediate_suffix eq '|';
    unless ($immediate_ok) {
     return {
      error => {
       kind   => $kind,
       reason => 'malformed_target_suffix',
       label  => $first_target->{label},
      },
     };
    }
   }
   push @edge_targets, { kind => $kind, label => $first_target->{label} };
   $cursor = $first_target->{cursor};

   if ($kind eq 'action') {
    while (1) {
     my $pipe_cursor = $cursor;
     ++$pipe_cursor while $pipe_cursor < $len && substr($fragment, $pipe_cursor, 1) =~ /\s/;
     last unless $pipe_cursor < $len && substr($fragment, $pipe_cursor, 1) eq '|';

     my $next_target = $parse_target->($pipe_cursor + 1);
     return { error => $next_target->{error} } if $next_target->{error};
     push @edge_targets, { kind => $kind, label => $next_target->{label} };
     $cursor = $next_target->{cursor};
    }
   }

   my $lookahead = $cursor;
   ++$lookahead while $lookahead < $len && substr($fragment, $lookahead, 1) =~ /\s/;

   if (@edge_targets > 1) {
    if ($lookahead >= $len || substr($fragment, $lookahead, 1) ne '{') {
     return {
      error => {
       kind   => $kind,
       reason => 'grouped_targets_require_block',
       label  => $edge_targets[0]{label},
      },
     };
    }
   } elsif ($lookahead < $len && substr($fragment, $lookahead, 1) eq '.') {
    my $fluent_cursor = $lookahead + 1;
    ++$fluent_cursor while $fluent_cursor < $len && substr($fragment, $fluent_cursor, 1) =~ /\s/o;
    unless ($fluent_cursor < $len && substr($fragment, $fluent_cursor, 1) =~ /\w/o) {
     return {
      error => {
       kind   => $kind,
        reason => 'malformed_fluent_suffix',
        label  => $edge_targets[0]{label},
      },
     };
    }
   } elsif ($kind eq 'blind_call' && $lookahead < $len && substr($fragment, $lookahead, 1) eq '|') {
    return {
     error => {
      kind   => $kind,
      reason => 'malformed_target_suffix',
      label  => $edge_targets[0]{label},
     },
    };
   }

   push @edges, @edge_targets;
   $i = $lookahead;
   next;
  }

  ++$i;
 }

 return { edges => \@edges, depth => $depth };
}

sub _consume_slash_construct {
 my ($fragment, $i, $len) = @_;
 return undef unless defined $fragment;
 $len = length($fragment) unless defined $len;
 return undef if $i >= $len || substr($fragment, $i, 1) ne q{/};

 my $prev_immediate = $i > 0 ? substr($fragment, $i - 1, 1) : '';
 my $prev_nonspace_idx = $i - 1;
 --$prev_nonspace_idx while $prev_nonspace_idx >= 0 && substr($fragment, $prev_nonspace_idx, 1) =~ /\s/o;
 my $prev_nonspace = $prev_nonspace_idx >= 0 ? substr($fragment, $prev_nonspace_idx, 1) : '';

 my $mode = '';
 if ($prev_nonspace eq 's' && ($prev_nonspace_idx == 0 || substr($fragment, $prev_nonspace_idx - 1, 1) !~ /[\w\$]/o)) {
  $mode = 'substitute';
 } elsif ($prev_nonspace eq 'y' && ($prev_nonspace_idx == 0 || substr($fragment, $prev_nonspace_idx - 1, 1) !~ /[\w\$]/o)) {
  $mode = 'translate';
 } elsif ($prev_nonspace eq 'r'
       && $prev_nonspace_idx > 0
       && substr($fragment, $prev_nonspace_idx - 1, 1) eq 't'
       && ($prev_nonspace_idx == 1 || substr($fragment, $prev_nonspace_idx - 2, 1) !~ /[\w\$]/o)) {
  $mode = 'translate';
 } elsif ($prev_nonspace eq 'r'
       && $prev_nonspace_idx > 0
       && substr($fragment, $prev_nonspace_idx - 1, 1) eq 'q'
       && ($prev_nonspace_idx == 1 || substr($fragment, $prev_nonspace_idx - 2, 1) !~ /[\w\$]/o)) {
  $mode = 'regex';
 } elsif ($prev_nonspace eq 'm' && ($prev_nonspace_idx == 0 || substr($fragment, $prev_nonspace_idx - 1, 1) !~ /[\w\$]/o)) {
  $mode = 'regex';
 } elsif ($i == 0 || $prev_immediate =~ /\s/o || $prev_nonspace =~ /[=~!,;:\(\[\{]/o) {
  $mode = 'regex';
 } else {
  return undef;
 }

 my $cursor = _consume_slash_segment($fragment, $i, $len);
 return $len if $cursor >= $len;

 if ($mode eq 'substitute' || $mode eq 'translate') {
  $cursor = _consume_until_next_unescaped_slash($fragment, $cursor, $len);
  return $len if $cursor >= $len;
 }

 ++$cursor while $cursor < $len && substr($fragment, $cursor, 1) =~ /[A-Za-z]/o;
 return $cursor;
}

sub _consume_slash_segment {
 my ($fragment, $i, $len) = @_;
 return $i unless defined $fragment;
 $len = length($fragment) unless defined $len;
 ++$i;
 while ($i < $len) {
  my $inner = substr($fragment, $i, 1);
  if ($inner eq q{\\}) {
   $i += 2;
   next;
  }
  ++$i;
  last if $inner eq q{/};
 }
 return $i;
}

sub _consume_until_next_unescaped_slash {
 my ($fragment, $i, $len) = @_;
 return $i unless defined $fragment;
 $len = length($fragment) unless defined $len;
 while ($i < $len) {
  my $inner = substr($fragment, $i, 1);
  if ($inner eq q{\\}) {
   $i += 2;
   next;
  }
  ++$i;
  last if $inner eq q{/};
 }
 return $i;
}

sub _count_rule_edge_kinds_in_fragment {
 my ($fragment, $edge_scan) = @_;
 my ($acode_count, $bcode_count) = (0, 0);
 return ($acode_count, $bcode_count) unless defined $fragment;
 $edge_scan ||= _scan_rule_edges_in_fragment($fragment);
 for my $edge (@{$edge_scan->{edges} || []}) {
  if (($edge->{kind} || '') eq 'action') {
   ++$acode_count;
  } elsif (($edge->{kind} || '') eq 'blind_call') {
   ++$bcode_count;
  }
 }

 return ($acode_count, $bcode_count);
}

#------------------------------------------------------------------------------
# Function: _report_edge_target_syntax_error
# Purpose : Convert low-level edge-scan syntax/balance failures into one
#           user-facing DSL diagnostic with targeted guidance.
# Args    : ($spec_content, $position, $error_hashref)
# Returns : undef/false through report_dsl_error
#------------------------------------------------------------------------------
sub _report_edge_target_syntax_error {
 my ($spec_content, $position, $error, $option, $rule_label) = @_;
 my $kind = $error->{kind} || 'action';
 my $reason = $error->{reason} || '';

 if ($reason eq 'unexpected_closer') {
  my $closer = $error->{closer} || '?';
  return _report_dsl_validation_failure(
   $spec_content,
   $position,
   "Unexpected closing delimiter '$closer' in rule paragraph",
   "Remove the stray '$closer' or add the matching opening delimiter earlier in the same rule paragraph",
   $option,
   summary => "Unexpected closing delimiter '$closer' in rule paragraph",
   rule_label => $rule_label,
  );
 }

 if ($kind eq 'blind_call' && $reason eq 'missing_target') {
  return _report_dsl_validation_failure(
   $spec_content,
   $position,
   "Blind-call edge is missing a target rule",
   "Use '=> RuleName' or '=> RuleName { ... }'; blind calls must name a child rule explicitly",
   $option,
   summary => 'Blind-call edge is missing a target rule',
   rule_label => $rule_label,
  );
 }

 if ($kind eq 'action' && $reason eq 'missing_target') {
 return _report_dsl_validation_failure(
   $spec_content,
   $position,
   "Action edge is missing a target rule",
   "Use '-> RuleName', '-> RuleName[idx]', '-> RuleA | RuleB { ... }', or '-> RuleName { ... }'; action edges must name target rule(s) explicitly",
   $option,
   summary => 'Action edge is missing a target rule',
   rule_label => $rule_label,
  );
 }

 if ($kind eq 'action' && $reason eq 'grouped_targets_require_block') {
  return _report_dsl_validation_failure(
   $spec_content,
   $position,
   "Grouped action-edge targets require a shared code block",
   "Use '-> RuleA | RuleB { ... }' when multiple action-edge targets need to share one code block",
   $option,
   summary => 'Grouped action-edge targets require a shared code block',
   rule_label => $rule_label,
  );
 }

 if ($kind eq 'blind_call' && $reason eq 'indexed_target_not_supported') {
  return _report_dsl_validation_failure(
   $spec_content,
   $position,
   "Blind-call targets do not support regex-slot indexing",
   "Use '=> RuleName' for blind calls, or use '-> RuleName[idx]' when you need a regex-slot action edge",
   $option,
   summary => 'Blind-call targets do not support regex-slot indexing',
   rule_label => $rule_label,
  );
 }

 if ($kind eq 'blind_call' && $reason eq 'malformed_target_suffix') {
  return _report_dsl_validation_failure(
   $spec_content,
   $position,
   "Malformed blind-call target syntax",
   "Use '=> RuleName' or '=> RuleName { ... }'; blind-call target names use word characters only and cannot have glued punctuation suffixes",
   $option,
   summary => 'Malformed blind-call target syntax',
   rule_label => $rule_label,
  );
 }

 if ($kind eq 'blind_call' && $reason eq 'malformed_fluent_suffix') {
  return _report_dsl_validation_failure(
   $spec_content,
   $position,
   "Malformed blind-call fluent suffix syntax",
   "Use '=> RuleName.method(...)', '=> RuleName .method(...)', or '=> RuleName { ... }'; the '.' must be followed by a method name",
   $option,
   summary => 'Malformed blind-call fluent suffix syntax',
   rule_label => $rule_label,
  );
 }

 if ($kind eq 'action' && $reason eq 'malformed_target_suffix') {
 return _report_dsl_validation_failure(
  $spec_content,
  $position,
  "Malformed action-edge target syntax",
   "Use '-> RuleName', '-> RuleName[idx]', '-> RuleA | RuleB { ... }', '-> RuleName { ... }', or a supported fluent suffix like '-> RuleName.method'; action-edge target names use word characters only",
  $option,
  summary => 'Malformed action-edge target syntax',
  rule_label => $rule_label,
  );
 }

 if ($kind eq 'action' && $reason eq 'malformed_fluent_suffix') {
  return _report_dsl_validation_failure(
   $spec_content,
   $position,
   "Malformed action-edge fluent suffix syntax",
   "Use a method-style continuation like '-> RuleName.method' or '-> RuleName.method(args)'; the '.' must be followed by a method name",
   $option,
   summary => 'Malformed action-edge fluent suffix syntax',
   rule_label => $rule_label,
  );
 }

 return _report_dsl_validation_failure(
  $spec_content,
  $position,
  "Malformed action-edge target syntax",
  "Use '-> RuleName', '-> RuleName[0]', or '-> RuleName { ... }'; regex-slot indexes must be unsigned integers in brackets",
  $option,
  summary => 'Malformed action-edge target syntax',
  rule_label => $rule_label,
 );
}

sub _report_split_marker_syntax_error {
 my ($spec_content, $position, $option, $rule_label) = @_;
 return _report_dsl_validation_failure(
  $spec_content,
  $position,
  "Malformed split marker syntax",
  "Use '@capture_slice', '@mark(name)', or compatibility aliases '@capture_from_here' / '@move_pos' when you need a split-boundary cursor marker",
  $option,
  summary => 'Malformed split marker syntax',
  rule_label => $rule_label,
 );
}

sub _report_unclosed_rule_block_error {
 my ($spec_content, $position, $option, $rule_label) = @_;
 $position = 0 unless defined $position;
 while ($position > 0 && substr($$spec_content, $position - 1, 1) eq "\n") {
  --$position;
 }
 return _report_dsl_validation_failure(
  $spec_content,
  $position,
  "Unclosed rule block before end of file",
  "Close the still-open '{', '(', or '[' construct before the end of the spec",
  $option,
  summary => 'Unclosed rule block before end of file',
  rule_label => $rule_label,
 );
}

sub _report_mixed_rule_action_modes {
 my ($label, $acode_count, $bcode_count, $option) = @_;
 my $error_msg = "Rule '$label': Cannot mix ACTION (->) and BLIND CALL (=>) code blocks";
 my $context = "ACTION blocks: ".($acode_count // 0)." found, BLIND CALL blocks: ".($bcode_count // 0)." found";
 my $detail = join(
  "\n",
  $context,
  "  Solution: Use either ACTION blocks OR BLIND CALL blocks, not both",
  "  Example: Use '-> rule_name { code }' OR '=> function_name { code }'",
 );
 _notify_dsl_validation_failure(
  $option,
  summary => $error_msg,
  detail => $detail,
  rule_label => $label,
 );
 _trace_log_output(DUMP_NONE, $error_msg, $context);
 print "  Solution: Use either ACTION blocks OR BLIND CALL blocks, not both\n";
 print "  Example: Use '-> rule_name { code }' OR '=> function_name { code }'\n";
 return 0;
}

sub _extract_leading_regex_literals_from_fragment {
 my ($fragment) = @_;
 my @regex_literals;
 return @regex_literals unless defined $fragment;

 pos($fragment) = 0;
 while ($fragment =~ /\G\s*(\/(?:\\.|[^\/])*?(?<!\\)\/)/gc) {
  push @regex_literals, $1;
 }

 return @regex_literals;
}

sub extract_regex_literals_from_rule_rhs {
 my ($rhs) = @_;
 my @regex_literals;

 while ($rhs =~ /(?<!\\)\/(?:\\.|[^\/])*?(?<!\\)\//g) {
  push @regex_literals, $&;
 }

 return @regex_literals;
}

1;
