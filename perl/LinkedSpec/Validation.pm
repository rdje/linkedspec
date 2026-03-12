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

 foreach my $line (@lines) {
  next if $line =~ /^\s*$/;
  next if $line =~ /^\s*#/;

  if ($line =~ /^\s*\w+::/) {
   $found_rule = 1;
   last;
  }
 }

 unless ($found_rule) {
  report_dsl_error($spec_content, 0,
   "Spec file must start with a rule definition",
   "Add a rule like 'RuleName::' at the beginning");
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

 for my $line (@lines) {
  next if $line =~ /^\s*$/;
  next if $line =~ /^\s*#/;

  if ($line =~ /^\s*(\w+)::/) {
   my $rule_name = $1;
   push @defined_rules, $rule_name;

   if (grep { $_ eq $rule_name } @defined_rules[0..$#defined_rules-1]) {
    my $position = index($$spec_content, $line);
    report_dsl_error($spec_content, $position,
     "Duplicate rule definition: '$rule_name'",
     "Remove the duplicate rule or rename one of them");
    return 0;
   }
  }

  if ($line =~ /->\s*(\w+)(?:\[(\d+)\])?/) {
   my $rule_name = $1;
   push @used_rules, $rule_name;
  }
 }

 for my $line (@lines) {
  next if $line =~ /^\s*$/;
  next if $line =~ /^\s*#/;

  my ($rhs) = $line =~ /^\s*\w+\s*:\s*(.*)$/;
  next unless defined $rhs;

  my @regex_literals = extract_regex_literals_from_rule_rhs($rhs);
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

sub extract_regex_literals_from_rule_rhs {
 my ($rhs) = @_;
 my @regex_literals;

 while ($rhs =~ /(?<!\\)\/(?:\\\\.|[^\/])*?(?<!\\)\//g) {
  push @regex_literals, $&;
 }

 return @regex_literals;
}

1;
