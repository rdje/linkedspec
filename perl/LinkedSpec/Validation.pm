package LinkedSpec::Validation;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use constant {
 DUMP_NONE => 0,
 DUMP_LOW  => 100,
};

sub _require_trace_pkg {
 require LinkedSpec::Trace;
 return 1
}

sub _call_preserving_err {
 my ($cb) = @_;
 my $saved_err = $@;
 my $wantarray = wantarray;
 if ($wantarray) {
  my @ret = $cb->();
  $@ = $saved_err;
  return @ret
 }
 if (defined $wantarray) {
  my $ret = $cb->();
  $@ = $saved_err;
  return $ret
 }
 $cb->();
 $@ = $saved_err;
 return
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

sub report_dsl_error {
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

 _trace_log_output(DUMP_NONE, $error, "DSL validation failed");
 return undef
}

sub validate_spec_content {
 my ($spec_content) = @_;

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

 foreach my $line (@lines) {
  next if $line =~ /^\s*$/;
  next if $line =~ /^\s*#/;

  my $parsed = _parse_rule_label_line($line);
  if ($parsed) {
   $found_rule = 1;
   $found_top_rule = 1 if $parsed->{is_top};
   last if $found_top_rule;
  }
 }

 unless ($found_rule) {
  report_dsl_error($spec_content, 0,
   "Spec file must start with a rule definition",
   "Add a rule like 'RuleName::' at the beginning");
  return 0;
 }

 unless ($found_top_rule) {
  report_dsl_error($spec_content, 0,
   "Spec file must define a top rule with '::'",
   "Add a top rule like 'RuleName::' so the parser has an entrypoint");
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

sub validate_gdata_references {
 my ($gdata, $spec) = @_;

 unless (ref($gdata) eq 'HASH') {
  _trace_log_output(DUMP_NONE, "Invalid gdata structure", "Expected HASH reference, got " . ref($gdata));
  return 0;
 }

 unless (ref($spec) eq 'HASH') {
  _trace_log_output(DUMP_NONE, "Invalid spec structure", "Expected HASH reference, got " . ref($spec));
  return 0;
 }

 for my $rule_name (keys %$gdata) {
  my $gdata_entry = $gdata->{$rule_name};

  unless (exists $spec->{$rule_name}) {
   _trace_log_output(DUMP_NONE, "Gdata references non-existent rule '$rule_name'", "Rule not found in spec");
   return 0;
  }

  unless (ref($gdata_entry) eq 'Regexp') {
   _trace_log_output(DUMP_NONE, "Invalid gdata entry for rule '$rule_name'", "Expected compiled regex, got " . ref($gdata_entry));
   return 0;
  }
 }

 for my $rule_name (keys %$spec) {
  my $rule_def = $spec->{$rule_name};

  unless (validate_rule_definition($rule_name, $rule_def)) {
   return 0;
  }

  if (exists $rule_def->{gdata} && ref($rule_def->{gdata}) eq 'ARRAY') {
   for my $i (0..$#{$rule_def->{gdata}}) {
    my $element = $rule_def->{gdata}[$i];
    unless (ref($element) eq 'HASH' && exists $element->{label} && exists $element->{idx}) {
     _trace_log_output(DUMP_NONE, "Invalid gdata element at index $i for rule '$rule_name'", "Expected HASH with 'label' and 'idx' keys");
     return 0;
    }

    my $ref_rule = $element->{label};
    unless (exists $spec->{$ref_rule}) {
     _trace_log_output(DUMP_NONE, "Gdata element references non-existent rule '$ref_rule'", "Rule not found in spec");
     return 0;
    }

    my $ref_idx = $element->{idx};
    my $ref_rule_def = $spec->{$ref_rule};
    unless (exists $ref_rule_def->{re} && $ref_idx < @{$ref_rule_def->{re}}) {
     _trace_log_output(DUMP_NONE, "Invalid regex index $ref_idx for rule '$ref_rule'", "Index out of bounds");
     return 0;
    }
   }
  }
 }

 return 1;
}

sub validate_dsl_syntax {
 my ($spec_content) = @_;

 my @lines = split(/\n/, $$spec_content);
 my @defined_rules = ();
 my @used_rules = ();
 my %seen_defined_rules;
 my $current_rule;

 for my $line (@lines) {
  next if $line =~ /^\s*$/;
  next if $line =~ /^\s*#/;

  my $rule_label = _parse_rule_label_line($line);
  if ($rule_label) {
   if ($current_rule && $current_rule->{acode_count} && $current_rule->{bcode_count}) {
    return _report_mixed_rule_action_modes(
     $current_rule->{label},
     $current_rule->{acode_count},
     $current_rule->{bcode_count},
    );
   }
   if ($rule_label->{invalid_mode}) {
    my $position = index($$spec_content, $line);
    report_dsl_error($spec_content, $position,
     "Malformed rule label syntax",
     "Use a supported rule label like 'RuleName:', 'RuleName::', 'RuleName:AND+', 'RuleName:OR+', or 'RuleName:OR{2,4}'");
    return 0;
   }
   my $rule_name = $rule_label->{label};
   push @defined_rules, $rule_name;

   if ($seen_defined_rules{$rule_name}++) {
    my $position = index($$spec_content, $line);
    report_dsl_error($spec_content, $position,
     "Duplicate rule definition: '$rule_name'",
     "Remove the duplicate rule or rename one of them");
    return 0;
   }

   my $edge_scan = _scan_rule_edges_in_fragment($rule_label->{rhs});
   if ($edge_scan->{error}) {
    my $position = index($$spec_content, $line);
    return _report_edge_target_syntax_error($spec_content, $position, $edge_scan->{error});
   }
   my ($acode_count, $bcode_count) = _count_rule_edge_kinds_in_fragment($rule_label->{rhs}, $edge_scan);
   push @used_rules, map { $_->{label} } @{$edge_scan->{edges} || []};
   $current_rule = {
    label => $rule_name,
    acode_count => $acode_count,
    bcode_count => $bcode_count,
    edge_scan_depth => $edge_scan->{depth} // 0,
   };
  } elsif (_looks_like_malformed_rule_label_line($line)) {
   my $position = index($$spec_content, $line);
   report_dsl_error($spec_content, $position,
    "Malformed rule label syntax",
    "Use a supported rule label like 'RuleName:', 'RuleName::', 'RuleName:AND+', 'RuleName:OR+', or 'RuleName:OR{2,4}'");
   return 0;
  } elsif ($current_rule) {
   my $edge_scan = _scan_rule_edges_in_fragment($line, $current_rule->{edge_scan_depth} // 0);
   if ($edge_scan->{error}) {
    my $position = index($$spec_content, $line);
    return _report_edge_target_syntax_error($spec_content, $position, $edge_scan->{error});
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
    );
   }
  }

 }

 if ($current_rule && $current_rule->{acode_count} && $current_rule->{bcode_count}) {
  return _report_mixed_rule_action_modes(
   $current_rule->{label},
   $current_rule->{acode_count},
   $current_rule->{bcode_count},
  );
 }

 for my $line (@lines) {
  next if $line =~ /^\s*$/;
  next if $line =~ /^\s*#/;

  my $rule_label = _parse_rule_label_line($line);
  my @regex_literals = $rule_label
   ? _extract_leading_regex_literals_from_fragment($rule_label->{rhs})
   : _extract_leading_regex_literals_from_fragment($line);

  for my $regex_literal (@regex_literals) {
   my $regex_pattern = $regex_literal;
   $regex_pattern =~ s{^/|/$}{}g;

   eval { qr/$regex_pattern/ } or do {
    my $position = index($$spec_content, $line);
    report_dsl_error($spec_content, $position,
     "Invalid regex pattern: $regex_literal",
     "Check the regex syntax and ensure proper escaping");
    return 0;
   };
  }
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
   next;
  }

  if ($ch eq '{' || $ch eq '(' || $ch eq '[') {
   ++$depth;
   ++$i;
   next;
  }

  if (($ch eq '}' || $ch eq ')' || $ch eq ']') && $depth > 0) {
   --$depth;
   ++$i;
   next;
  }

  if ($depth == 0 && (substr($fragment, $i, 2) eq '->' || substr($fragment, $i, 2) eq '=>')) {
   my $kind = substr($fragment, $i, 2) eq '->' ? 'action' : 'blind_call';
   my $cursor = $i + 2;

   ++$cursor while $cursor < $len && substr($fragment, $cursor, 1) =~ /\s/;
   my $label_start = $cursor;
   ++$cursor while $cursor < $len && substr($fragment, $cursor, 1) =~ /\w/;

   if ($cursor == $label_start) {
    return {
     error => {
      kind   => $kind,
      reason => 'missing_target',
     },
    };
   }

   my $label = substr($fragment, $label_start, $cursor - $label_start);
   my $lookahead = $cursor;
   ++$lookahead while $lookahead < $len && substr($fragment, $lookahead, 1) =~ /\s/;

   if ($lookahead < $len && substr($fragment, $lookahead, 1) eq '[') {
    if ($kind eq 'blind_call') {
     return {
      error => {
       kind   => $kind,
       reason => 'indexed_target_not_supported',
       label  => $label,
      },
     };
    }

    my $index_cursor = $lookahead + 1;
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

    $lookahead = $index_cursor + 1;
   }

   push @edges, {
    kind  => $kind,
    label => $label,
   };
   $i = $lookahead;
   next;
  }

  ++$i;
 }

 return { edges => \@edges, depth => $depth };
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

sub _report_edge_target_syntax_error {
 my ($spec_content, $position, $error) = @_;
 my $kind = $error->{kind} || 'action';
 my $reason = $error->{reason} || '';

 if ($kind eq 'blind_call' && $reason eq 'missing_target') {
  return report_dsl_error(
   $spec_content,
   $position,
   "Blind-call edge is missing a target rule",
   "Use '=> RuleName' or '=> RuleName { ... }'; blind calls must name a child rule explicitly",
  );
 }

 if ($kind eq 'action' && $reason eq 'missing_target') {
  return report_dsl_error(
   $spec_content,
   $position,
   "Action edge is missing a target rule",
   "Use '-> RuleName', '-> RuleName[idx]', or '-> RuleName { ... }'; action edges must name a target rule explicitly",
  );
 }

 if ($kind eq 'blind_call' && $reason eq 'indexed_target_not_supported') {
  return report_dsl_error(
   $spec_content,
   $position,
   "Blind-call targets do not support regex-slot indexing",
   "Use '=> RuleName' for blind calls, or use '-> RuleName[idx]' when you need a regex-slot action edge",
  );
 }

 return report_dsl_error(
  $spec_content,
  $position,
  "Malformed action-edge target syntax",
  "Use '-> RuleName', '-> RuleName[0]', or '-> RuleName { ... }'; regex-slot indexes must be unsigned integers in brackets",
 );
}

sub _report_mixed_rule_action_modes {
 my ($label, $acode_count, $bcode_count) = @_;
 my $error_msg = "Rule '$label': Cannot mix ACTION (->) and BLIND CALL (=>) code blocks";
 my $context = "ACTION blocks: ".($acode_count // 0)." found, BLIND CALL blocks: ".($bcode_count // 0)." found";
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
 while ($fragment =~ /\G\s*(\/(?:\\\\.|[^\/])*?(?<!\\)\/)/gc) {
  push @regex_literals, $1;
 }

 return @regex_literals;
}

sub extract_regex_literals_from_rule_rhs {
 my ($rhs) = @_;
 my @regex_literals;

 while ($rhs =~ /(?<!\\)\/(?:\\\\.|[^\/])*?(?<!\\)\//g) {
  push @regex_literals, $&;
 }

 return @regex_literals;
}

1;
