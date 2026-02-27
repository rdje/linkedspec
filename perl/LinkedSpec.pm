#===================================================================
# Copyright (c) 2005-2008 Richard DJE. All rights reserved.
#
# This Perl module is free software, you may redistribute it and/or 
# modify it under the same terms as Perl itself.
#===================================================================
package LinkedSpec;

use 5.010;
use re 'eval';
use Data::Dumper;

use LinkedRE;

# UVM-style verbosity levels
use constant {
    DUMP_NONE   => 0,    # No dumps
    DUMP_LOW    => 100,  # Essential dumps only (errors, final results)
    DUMP_MEDIUM => 200,  # Standard dumps (parse results, generated spec)
    DUMP_HIGH   => 300,  # Detailed dumps (rule info, handlers)
    DUMP_FULL   => 400,  # Very detailed dumps (DSL transformations)
    DUMP_DEBUG  => 500   # Maximum detail (everything)
};

# Global verbosity level - can be set externally for debugging
our $DUMP_VERBOSITY = DUMP_NONE;

#------------------------------------------------------------------------------
# Function: _lower_is_empty_expr
# Purpose : Lower `is_empty(...)` checks across scalar/array/general expression
#           payloads used in fluent control-flow expressions.
# Args    : ($arg_expr)
# Returns : Perl boolean expression string or undef
#------------------------------------------------------------------------------
sub _lower_is_empty_expr {
 my ($arg_expr) = @_;
 return undef unless defined $arg_expr;
 my $trimmed = _trim_action_ir_value($arg_expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ /^array\s*\(/o) {
  my $array_symbol = _extract_array_symbol_name($trimmed);
  return "(!\@$array_symbol)" if defined $array_symbol;
 }

 my $scalar_symbol = _extract_scalar_symbol_name($trimmed);
 if (defined $scalar_symbol) {
  return "(!defined(\$$scalar_symbol) || \$$scalar_symbol eq '')";
 }

 my $lowered = _lower_method_value_expr($trimmed);
 $lowered = $trimmed unless defined($lowered) && length($lowered);
 return "(!($lowered))"
}

#------------------------------------------------------------------------------
# Function: _lower_flow_composite_expr
# Purpose : Recursively lower Lisp-like fluent expression trees so control-flow
#           conditions (`if`, `elseif`, `switch`) and value surfaces share one
#           expression-lowering path.
# Args    : ($expr)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_flow_composite_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ /^(?:scalaref|scalar|array|hash)\s*\(/o) {
  my $lowered_value = _lower_method_value_expr($trimmed);
  return $lowered_value if defined($lowered_value) && length($lowered_value);
 }

 my $call = _parse_method_function_expr($trimmed);
 return $trimmed unless $call;

 my $method = $call->{method} // '';
 my $args = $call->{args} || [];
 my %string_compare_ops = map { $_ => 1 } qw(eq ne gt ge lt le);
 my %numeric_compare_ops = (
  num_eq => '==',
  num_ne => '!=',
  num_gt => '>',
  num_ge => '>=',
  num_lt => '<',
  num_le => '<=',
 );

 if ($method eq 'or' || $method eq 'and') {
  my $effective_args = _normalize_method_args_with_optional_scope($args, 1, undef);
  return undef unless $effective_args && @$effective_args;
  my @parts = map { _lower_flow_composite_expr($_) } @$effective_args;
  return undef if grep { !defined($_) || !length($_) } @parts;
  my $joiner = $method eq 'or' ? ' || ' : ' && ';
  return '('.join($joiner, map { "($_)" } @parts).')';
 }

 if ($method eq 'not') {
  my $effective_args = _normalize_method_args_with_optional_scope($args, 1, 1);
  return undef unless $effective_args;
  my $value = _lower_flow_composite_expr($effective_args->[0]);
  return undef unless defined($value) && length($value);
  return "(!($value))";
 }

 if ($method eq 'is_empty') {
  my $effective_args = _normalize_method_args_with_optional_scope($args, 1, 1);
  return undef unless $effective_args;
  return _lower_is_empty_expr($effective_args->[0]);
 }

 if ($method eq 'is_nonempty') {
  my $effective_args = _normalize_method_args_with_optional_scope($args, 1, 1);
  return undef unless $effective_args;
  my $empty_expr = _lower_is_empty_expr($effective_args->[0]);
  return undef unless defined($empty_expr) && length($empty_expr);
  return "(!($empty_expr))";
 }

 if (exists $string_compare_ops{$method}) {
  my $effective_args = _normalize_method_args_with_optional_scope($args, 2, 2);
  return undef unless $effective_args;
  my $lhs = _lower_flow_composite_expr($effective_args->[0]);
  my $rhs = _lower_flow_composite_expr($effective_args->[1]);
  return undef unless defined($lhs) && length($lhs);
  return undef unless defined($rhs) && length($rhs);
  return "($lhs $method $rhs)";
 }

 if (exists $numeric_compare_ops{$method}) {
  my $effective_args = _normalize_method_args_with_optional_scope($args, 2, 2);
  return undef unless $effective_args;
  my $lhs = _lower_flow_composite_expr($effective_args->[0]);
  my $rhs = _lower_flow_composite_expr($effective_args->[1]);
  return undef unless defined($lhs) && length($lhs);
  return undef unless defined($rhs) && length($rhs);
  return "($lhs $numeric_compare_ops{$method} $rhs)";
 }

 if ($method eq 'matches') {
  my $effective_args = _normalize_method_args_with_optional_scope($args, 2, 2);
  return undef unless $effective_args;
  my $lhs = _lower_flow_composite_expr($effective_args->[0]);
  my $rhs = _lower_flow_composite_expr($effective_args->[1]);
  return undef unless defined($lhs) && length($lhs);
  return undef unless defined($rhs) && length($rhs);
  return "($lhs =~ $rhs)";
 }

 return $trimmed
}

#------------------------------------------------------------------------------
# Function: log_output
# Purpose : Central logging entrypoint with verbosity-gating and optional file
#           mirroring to $main::LOG_FILE.
# Args    : ($level, $message, $context)
# Returns : undef (side effects only: console/file output)
#------------------------------------------------------------------------------
sub log_output {
    my ($level, $message, $context) = @_;
    
    # Check if we should log at this level
    return if $level > $DUMP_VERBOSITY;
    
    # Format timestamp
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime();
    my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d", 
                           $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
    
    # Build log message
    my $log_msg = "[$timestamp] $message\n";
    $log_msg .= "  Context: $context\n" if defined $context;
    
    # Output to console and file
    print $log_msg;
    
    # Try to write to log file if it exists
    if (defined $main::LOG_FILE && -w $main::LOG_FILE) {
        open(my $log_fh, '>>', $main::LOG_FILE) or return;
        print $log_fh $log_msg;
        close($log_fh);
    }
}

#------------------------------------------------------------------------------
# Function: log_dump
# Purpose : Lightweight dump writer used for already-formatted debug payloads
#           (e.g. Data::Dumper output), without timestamp decoration.
# Args    : ($message)
# Returns : undef (side effects only: console/file output)
#------------------------------------------------------------------------------
sub log_dump {
    my ($message) = @_;
    print $message;
    
    # Try to write to log file if it exists
    if (defined $main::LOG_FILE && -w $main::LOG_FILE) {
        open(my $log_fh, '>>', $main::LOG_FILE) or return;
        print $log_fh $message;
        close($log_fh);
    }
}

#------------------------------------------------------------------------------
# Function: should_dump
# Purpose : Small helper that standardizes verbosity threshold checks.
# Args    : ($level)
# Returns : boolean (true when current verbosity enables this level)
#------------------------------------------------------------------------------
sub should_dump {
    my ($level) = @_;
    return $DUMP_VERBOSITY >= $level;
}

#------------------------------------------------------------------------------
# Function: get_dsl_context
# Purpose : Build line-oriented context around a byte-position in .spec text so
#           validation errors can report useful nearby source.
# Args    : ($spec_content, $position)
# Returns : hashref { line_number, current_line, prev_line, next_line, position }
#------------------------------------------------------------------------------
sub get_dsl_context {
    my ($spec_content, $position) = @_;
    
    # Find line number and context around the position
    my $before_pos = substr($$spec_content, 0, $position);
    my $line_number = 1 + ($before_pos =~ tr/\n//);
    
    # Get the line containing the position
    my @lines = split(/\n/, $$spec_content);
    my $current_line = $lines[$line_number - 1] || "";
    
    # Get surrounding context (previous and next lines)
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

#------------------------------------------------------------------------------
# Function: report_dsl_error
# Purpose : Format and emit a human-readable DSL error message with local
#           source context and optional remediation guidance.
# Args    : ($spec_content, $position, $error_msg, $suggestion)
# Returns : undef (side effects only: logging)
#------------------------------------------------------------------------------
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
    
    log_output(DUMP_NONE, $error, "DSL validation failed");
}

#------------------------------------------------------------------------------
# Function: validate_spec_content
# Purpose : Validate raw .spec input envelope before deeper syntax parsing.
# Args    : ($spec_content)
# Returns : boolean (true if minimal shape/entry rule expectations are met)
#------------------------------------------------------------------------------
sub validate_spec_content {
    my ($spec_content) = @_;
    
    # Check if spec content is a string reference
    unless (ref($spec_content) eq 'SCALAR') {
        log_output(DUMP_NONE, "Invalid spec content type", "Expected SCALAR reference, got " . ref($spec_content));
        return 0;
    }
    
    # Check if spec content is not empty
    unless (length($$spec_content) > 0) {
        log_output(DUMP_NONE, "Spec content is empty", "Spec file must contain content");
        return 0;
    }
    
    # Check for basic .spec file structure (skip comment lines)
    my @lines = split(/\n/, $$spec_content);
    my $found_rule = 0;
    
    foreach my $line (@lines) {
        # Skip empty lines and comment lines
        next if $line =~ /^\s*$/;
        next if $line =~ /^\s*#/;
        
        # Check if this line starts with a rule definition
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

#------------------------------------------------------------------------------
# Function: validate_rule_definition
# Purpose : Structural sanity-check for generated rule definitions in the
#           descriptor (handler presence, regex shape, regex compilability).
# Args    : ($rule_name, $rule_def)
# Returns : boolean
#------------------------------------------------------------------------------
sub validate_rule_definition {
    my ($rule_name, $rule_def) = @_;
    
    # Check if rule definition is a hash reference
    unless (ref($rule_def) eq 'HASH') {
        log_output(DUMP_NONE, "Invalid rule definition for '$rule_name'", "Expected HASH reference, got " . ref($rule_def));
        return 0;
    }
    
    # Check required fields exist
    unless (exists $rule_def->{handler}) {
        log_output(DUMP_NONE, "Rule '$rule_name' missing required 'handler' field", "All rules must define handler code");
        return 0;
    }
    
    # Top-level rules (entry points) may not have 're' field
    if (exists $rule_def->{re}) {
        # Validate regex array
        unless (ref($rule_def->{re}) eq 'ARRAY') {
            log_output(DUMP_NONE, "Rule '$rule_name' 're' field must be an array", "Got " . ref($rule_def->{re}));
            return 0;
        }
        
        # Check regex patterns are valid
        for my $i (0..$#{$rule_def->{re}}) {
            my $regex = $rule_def->{re}[$i];
            eval { qr/$regex/ } or do {
                log_output(DUMP_NONE, "Invalid regex in rule '$rule_name' at index $i", "Error: $@");
                return 0;
            };
        }
    }
    
    return 1;
}

#------------------------------------------------------------------------------
# Function: validate_gdata_references
# Purpose : Validate integrity between gdata dispatch regexes and generated
#           spec rules, including gdata indirections embedded in rules.
# Args    : ($gdata, $spec)
# Returns : boolean
#------------------------------------------------------------------------------
sub validate_gdata_references {
    my ($gdata, $spec) = @_;
    
    # Check if gdata is a hash reference
    unless (ref($gdata) eq 'HASH') {
        log_output(DUMP_NONE, "Invalid gdata structure", "Expected HASH reference, got " . ref($gdata));
        return 0;
    }
    
    # Check if spec is a hash reference
    unless (ref($spec) eq 'HASH') {
        log_output(DUMP_NONE, "Invalid spec structure", "Expected HASH reference, got " . ref($spec));
        return 0;
    }
    
    # Validate each gdata entry (compiled regex objects)
    for my $rule_name (keys %$gdata) {
        my $gdata_entry = $gdata->{$rule_name};
        
        # Check if referenced rule exists in spec
        unless (exists $spec->{$rule_name}) {
            log_output(DUMP_NONE, "Gdata references non-existent rule '$rule_name'", "Rule not found in spec");
            return 0;
        }
        
        # Validate gdata entry is a compiled regex
        unless (ref($gdata_entry) eq 'Regexp') {
            log_output(DUMP_NONE, "Invalid gdata entry for rule '$rule_name'", "Expected compiled regex, got " . ref($gdata_entry));
            return 0;
        }
    }
    
    # Validate spec rule structures
    for my $rule_name (keys %$spec) {
        my $rule_def = $spec->{$rule_name};
        
        # Validate rule definition
        unless (validate_rule_definition($rule_name, $rule_def)) {
            return 0;
        }
        
        # Validate gdata references within each rule
        if (exists $rule_def->{gdata} && ref($rule_def->{gdata}) eq 'ARRAY') {
            for my $i (0..$#{$rule_def->{gdata}}) {
                my $element = $rule_def->{gdata}[$i];
                unless (ref($element) eq 'HASH' && exists $element->{label} && exists $element->{idx}) {
                    log_output(DUMP_NONE, "Invalid gdata element at index $i for rule '$rule_name'", "Expected HASH with 'label' and 'idx' keys");
                    return 0;
                }
                
                # Check if referenced rule exists
                my $ref_rule = $element->{label};
                unless (exists $spec->{$ref_rule}) {
                    log_output(DUMP_NONE, "Gdata element references non-existent rule '$ref_rule'", "Rule not found in spec");
                    return 0;
                }
                
                # Check if regex index is valid
                my $ref_idx = $element->{idx};
                my $ref_rule_def = $spec->{$ref_rule};
                unless (exists $ref_rule_def->{re} && $ref_idx < @{$ref_rule_def->{re}}) {
                    log_output(DUMP_NONE, "Invalid regex index $ref_idx for rule '$ref_rule'", "Index out of bounds");
                    return 0;
                }
            }
        }
    }
    
    return 1;
}

#------------------------------------------------------------------------------
# Function: validate_dsl_syntax
# Purpose : Perform rule-level DSL checks (duplicate definitions, regex literal
#           validity, undefined/unused rule warnings).
# Args    : ($spec_content)
# Returns : boolean
#------------------------------------------------------------------------------
sub validate_dsl_syntax {
    my ($spec_content) = @_;
    
    my @lines = split(/\n/, $$spec_content);
    my @defined_rules = ();
    my @used_rules = ();
    
    # First pass: collect all defined rules and used rules
    for my $line (@lines) {
        # Skip empty lines and comments
        next if $line =~ /^\s*$/;
        next if $line =~ /^\s*#/;
        
        # Check for rule definitions
        if ($line =~ /^\s*(\w+)::/) {
            my $rule_name = $1;
            push @defined_rules, $rule_name;
            
            # Check for duplicate rule definitions
            if (grep { $_ eq $rule_name } @defined_rules[0..$#defined_rules-1]) {
                my $position = index($$spec_content, $line);
                report_dsl_error($spec_content, $position,
                    "Duplicate rule definition: '$rule_name'",
                    "Remove the duplicate rule or rename one of them");
                return 0;
            }
        }
        
        # Collect used rules (for warnings only, not errors)
        if ($line =~ /->\s*(\w+)(?:\[(\d+)\])?/) {
            my $rule_name = $1;
            push @used_rules, $rule_name;
        }
    }
    
    # Second pass: validate syntax
    for my $line (@lines) {
        # Skip empty lines and comments
        next if $line =~ /^\s*$/;
        next if $line =~ /^\s*#/;

        # Check regex literals appearing in rule-definition lines.
        # Handles escaped delimiter slashes (e.g. \/\/) correctly.
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
    
    # Check for unused rules (warning only)
    my %defined_rules = map { $_ => 1 } @defined_rules;
    my %used_rules = map { $_ => 1 } @used_rules;

    my @unused_rules = grep { !$used_rules{$_} } @defined_rules;
    if (@unused_rules) {
        log_output(DUMP_LOW, "Warning: Unused rules detected", "Rules defined but never used: " . join(", ", @unused_rules));
    }
    
    # Check for undefined rules (warning only, since order doesn't matter)
    my @undefined_rules = grep { !$defined_rules{$_} } @used_rules;
    if (@undefined_rules) {
        my @unique_undefined = do { my %seen; grep { !$seen{$_}++ } @undefined_rules };
        log_output(DUMP_LOW, "Warning: Undefined rules referenced", "Rules referenced but not defined: " . join(", ", @unique_undefined));
    }
    
    return 1;
}

#------------------------------------------------------------------------------
# Function: extract_regex_literals_from_rule_rhs
# Purpose : Extract slash-delimited regex literals from a rule RHS while
#           respecting escaped delimiters.
# Args    : ($rhs)
# Returns : list of regex literal strings (including surrounding /.../)
#------------------------------------------------------------------------------
sub extract_regex_literals_from_rule_rhs {
    my ($rhs) = @_;
    my @regex_literals;

    while ($rhs =~ /(?<!\\)\/(?:\\\\.|[^\/])*?(?<!\\)\//g) {
        push @regex_literals, $&;
    }

    return @regex_literals;
}

#------------------------------------------------------------------------------
# Function: _parse_method_call_chain
# Purpose : Parse `.method(args).method2(args2)` chains into ordered call
#           descriptors while preserving nested-parenthesis argument payloads.
# Args    : ($chain)
# Returns : arrayref of { method => ..., args => ... } or undef on parse error
#------------------------------------------------------------------------------
sub _parse_method_call_chain {
 my ($chain) = @_;
 return [] unless defined($chain) && length($chain);

 my @calls;
 pos($chain) = 0;
 while ($chain =~ /\G\s*\.\s*(?<method>\w+)(?<args>\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))?/gc) {
  my $args = $+{args};
  if (defined $args) {
   $args =~ s/^\s*\(//o;
   $args =~ s/\)\s*$//o;
  }
  push @calls, {
   method => $+{method},
   args   => $args,
  };
 }

 return \@calls if $chain =~ /\G\s*$/gc;
 return undef
}

#------------------------------------------------------------------------------
# Function: _method_chain_return_uses_general_payload
# Purpose : Detect method-chain `.return(...)` payloads that should be emitted
#           as `return(payload)` without implicit scope-label injection.
# Args    : ($args)
# Returns : boolean
#------------------------------------------------------------------------------
sub _method_chain_return_uses_general_payload {
 my ($args) = @_;
 return 0 unless defined $args;
 my $trimmed = _trim_action_ir_value($args);
 return 0 unless defined($trimmed) && length($trimmed);
 return $trimmed =~ /^(?:\[|\{|"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|-?\d+(?:\.\d+)?|scalar\s*\(|array\s*\(|hash\s*\()/o ? 1 : 0
}

#------------------------------------------------------------------------------
# Function: _render_method_call_chain
# Purpose : Render parsed method-chain calls into semicolon-joined helper-style
#           calls with entry label injected as first argument.
# Args    : ($entry_label, $chain)
# Returns : rendered code string or undef
#------------------------------------------------------------------------------
sub _render_method_call_chain {
 my ($entry_label, $chain) = @_;
 my $calls = _parse_method_call_chain($chain);
 return undef unless $calls && @$calls;
 my @rendered = map {
  my $method = $_->{method};
  my $args = $_->{args};
  if ($method eq 'return' && _method_chain_return_uses_general_payload($args)) {
   return $method . '(' . $args . ')';
  }
  $method . "($entry_label" . ((defined($args) && length($args)) ? ",$args" : '') . ')'
 } @$calls;
 return join '; ', @rendered
}

#------------------------------------------------------------------------------
# Bootstrap parser metadata and global state
#------------------------------------------------------------------------------
# Maps bootstrap rule id => index in $spec_descr; avoids hardcoded positional
# assumptions when bootstrap handlers dispatch recursively.
my %bootstrap_rule_index;

# Declarative mapping from entry-label suffix markers to rule execution family.
my $node_type     = {
	'&'       => 'AND',
	'|'       => 'OR',
	'+'       => 'REP_PLUS',
	'*'       => 'REP_STAR',
	'?'       => 'REP_OPT'
};

# Min/max repetition semantics for REP_* rule families.
my $rep_nodes_minmax = {
	REP_PLUS=> [1, 10**9],
	REP_STAR=> [0, 10**9],
	REP_OPT => [0, 1]
};

# Legacy generation toggle: when enabled, emit parser descriptor Perl text.
my $pm_drive;

# Hardcoded bootstrap grammar used to parse .spec into intermediate entries.
my $spec_descr = [
{# Spec			-0-
 id => 'SPEC_ROOT',
 tags => { root => 1 },
 handler=> sub {
  my ($descr, $string, $gdata) = @_;
  my @specentry;
  my @specs;
  while (1) {
   my $minfo = LinkedRE::or($string, $$gdata{startREs});
   unless($minfo) {
	   # print "(Spec) Closing specentry DUE TO EOF\n" if @specentry;
    push @specs, [@specentry] if @specentry;
    return [@specs]
   }

   my $dispatch_idx = $$gdata{start_dispatch}[$$minfo{index}];
   return undef unless defined $dispatch_idx;

   my $retv = &{$$descr[$dispatch_idx]{handler}}($minfo, $descr, $string, $gdata);
   return undef unless $retv;

   unless ($$retv[0] eq 'COMMENT') {
    if ($$retv[0] =~ /ELABEL/o) {
     if (@specentry) {
      # say '(Spec) Closing specentry DUE TO NEW Entry';
      push @specs, [@specentry];
      # print "(Spec) Re-Initializing specentry (@{$retv})\n";
      @specentry = $retv
     } else {
     # say "(Spec) Initializing specentry @{$retv})";
     push @specentry, $retv;
      # Hack
      #$gdata->{_current_entry} = $retv->[1]
     }
    } else {
     # say "(Spec) Pushing in specentry (@{$retv})";
     push @specentry, $retv;
    }
   }

  }
 }

},

{# Entry Label
 id => 'ENTRY_LABEL',
 tags => { start_token => 1 },
 re=> [qr/\w+\s*::?(?:&|\||\+|\*|\?)?/o],
 handler=> sub {
  my ($info, undef, undef, $gdata) = @_;
  $$info{match} =~ s/\s*://o;

  #say "\n(Entry Label) ($$info{match})";
  my $target = $$info{match} =~ /:/ ? '_INITIAL' : '';
  $$info{match} =~ s/://o;
  
  $$info{match} =~ s/(\W)//o;
  $gdata->{_current_entry} = $$info{match};
  return ["ELABEL$target", $$info{match}, $1 ? $node_type->{$1} : "default"]
 }
},

{# RE pattern
 id => 'RE_PATTERN',
 tags => { start_token => 1 },
 re=> [qr/(?<!\\)\/.+?(?<!\\)\//o],
 handler=> sub {
  my ($info) = @_;
  $$info{match} =~ s/^\/|\/$//g;

  #say "(RE pattern) ($$info{match})";
  return ['RE', $$info{match}]
 }
},

{# Action code block
 id => 'ACTION_CODE_BLOCK',
 tags => { start_token => 1 },
 re=> [qr/->\s*\w+(?:\[\d+\])?\s*\{/o, qr/\}/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;

  my $ipos = pos($$string);
  my ($entry_label, $reidx) = $$info{match} =~ /(\w+)(?:\[(\d+)\])?/o; 
  $reidx = $reidx || 0;

  #say "(Action code block)($$info{match})($entry_label, $reidx)";
  while (1) {
   my $minfo = LinkedRE::or($string, $$gdata{cbrace});
   return undef unless $minfo;

   if ($$minfo{index} == 1) {
    # Closing brace, recursion stops here
    #say "(Action code block) (${\(substr($$string, $ipos, pos($$string) - $ipos - 1))}) Closing";
    return ['ACODE', {relabel=>$entry_label, reidx=>$reidx, code=>substr($$string, $ipos, pos($$string) - $ipos - 1)}]
   } elsif ($$minfo{index} == 0) {
    # Opening brace found, triggering recursion
    # say '(Curly BRACE) Recursion';
    &{$$descr[$bootstrap_rule_index{CURLY_BRACE}]{handler}}($minfo, $descr, $string, $gdata);
    # say '(Curly BRACE) Back From Recursion';
   } else {
    #say "QUOTES <$$minfo{match}>"
   }
  }
 }
},

{# Method-like Empty Action code block
 id => 'METHOD_EMPTY_ACTION_CODE_BLOCK',
 tags => { start_token => 1 },
 re=> [qr/->\s*(?<ENTRY_LABEL>\w+)\s*(?:\[\s*(?<INDEX>\d+)\s*\]\s*)?(?<CHAIN>(?:\s*\.\s*\w+(?<PAREN>\s*\((?:[^\(\)]++|(?&PAREN))*\))?)+)/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;
  my ($entry_label, $reidx, $chain) = @{$$info{match_hash}}{qw/ENTRY_LABEL INDEX CHAIN/};
  my $code = _render_method_call_chain($entry_label, $chain);
  return undef unless defined $code;
  return ['ACODE', {relabel=>$entry_label, reidx=> $reidx // 0, code=>$code}]
 }
},

{# Empty Action code block
 id => 'EMPTY_ACTION_CODE_BLOCK',
 tags => { start_token => 1 },
 re=> [qr/->\s*\w+(?:\[0\])?/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;

  my ($entry_label) = $$info{match} =~ /(\w+)/o; 
  #print "(Empty Action code block) ($entry_label)\n";
  return ['ACODE', {relabel=>$entry_label, reidx=>0, code=>"call($entry_label)"}]
 }
},


{# Non-Action code block
 id => 'NON_ACTION_CODE_BLOCK',
 tags => { start_token => 1 },
 re=> [qr/\w+\s*\{/o, qr/\}/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;

  my $ipos = pos($$string);
  my ($type) = $$info{match} =~ /(\w+)/o; 
  #print "(Non-Action code block) ($type) Opening\n";

  while (1) {
   my $minfo = LinkedRE::or($string, $$gdata{cbrace});
   return undef unless $minfo;

   if ($$minfo{index} == 1) {
    # Closing brace, recursion stops here
    # print "(Initial/Loop  ($type) code block) (${\(substr($$string, $ipos, pos($$string) - $ipos - 1))}) Closing\n";
    return ["${type}CODE", substr($$string, $ipos, pos($$string) - $ipos - 1)]
   } elsif ($$minfo{index} == 0) {
    # Opening brace found, triggering recursion
    # print "(Curly BRACE) Recursion\n";
    &{$$descr[$bootstrap_rule_index{CURLY_BRACE}]{handler}}($minfo, $descr, $string, $gdata);
    # print "(Curly BRACE) Back From Recursion\n";
   } else {
    #print "QUOTES <$$minfo{match}>\n"
   }
  }
 }
},

{# Comment
 id => 'COMMENT',
 tags => { start_token => 1 },
 #re=> [qr/(?:\r\n?)?[ \t]*#.*/o],
 re=> [qr/[ \t]*#.*/o],
 handler=> sub {return ['COMMENT']}
},

{# Blind call code block
 id => 'BLIND_CALL_CODE_BLOCK',
 tags => { start_token => 1 },
 re=> [qr/=>\s*\w+\s*\{/o, qr/\}/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;

  my $ipos = pos($$string);
  my ($call) = $$info{match} =~ /(\w+)/o; 

  #print "(Blind call code block)($$info{match})($call, $reidx)\n";
  while (1) {
   my $minfo = LinkedRE::or($string, $$gdata{cbrace});
   return undef unless $minfo;

   if ($$minfo{index} == 1) {
    # Closing brace, recursion stops here
    #print "(Action code block) (${\(substr($$string, $ipos, pos($$string) - $ipos - 1))}) Closing\n";
    return ['BCODE', {call=>$call, code=>"\$$gdata->{_current_entry} = call($call);\n".substr($$string, $ipos, pos($$string) - $ipos - 1)}]
   } elsif ($$minfo{index} == 0) {
    # Opening brace found, triggering recursion
    # print "(Curly BRACE) Recursion\n";
    &{$$descr[$bootstrap_rule_index{CURLY_BRACE}]{handler}}($minfo, $descr, $string, $gdata);
    # print "(Curly BRACE) Back From Recursion\n";
   } else {
    #print "QUOTES <$$minfo{match}>\n"
   }
  }
 }
},

{# Split-Like Code
 id => 'SPLIT_LIKE_CODE',
 tags => { start_token => 1 },
 re=> [qr/@\s*move_pos\b/o],
 handler=> sub {
  # say '(Split-Like Code)';
  return ['MOVE_POS']
 }
},


{# Empty Blind code block
 id => 'EMPTY_BLIND_CODE_BLOCK',
 tags => { start_token => 1 },
 re=> [qr/=>\s*\w+/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;

  my ($call) = $$info{match} =~ /(\w+)/o; 
  #print "(Empty Action code block) ($entry_label)\n";
  return ['BCODE', {call=>$call, code=>"\$$gdata->{_current_entry} = call($call)"}]
 }
},


{# Method-like Empty Non-Action code block
 id => 'METHOD_EMPTY_NON_ACTION_CODE_BLOCK',
 tags => { start_token => 1 },
 re=> [qr/(?<TYPE>\w+)(?<CHAIN>(?:\s*\.\s*\w+(?<PAREN>\s*\((?:[^\(\)]++|(?&PAREN))*\))?)+)/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;
  my ($type, $chain) = @{$$info{match_hash}}{qw/TYPE CHAIN/};
  my $code = _render_method_call_chain($gdata->{_current_entry}, $chain);
  return undef unless defined $code;
  return ["${type}CODE", $code]
 }
},


{# Curly Brace			-7- + dquotes + squotes
 id => 'CURLY_BRACE',
 tags => { start_token => 1, brace_scanner => 1 },
 #re=> [qr/(?<!\\)\{/o, qr/(?<!\\)\}/o],
 re=> [qr/(?<!\\)\{/o, qr/(?<!\\)\}/o, qr/(?<!\\)".*?(?<!\\)"/o, qr/(?<!\\)'.*?(?<!\\)'/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;

  my $ipos = pos($$string);
  #print "(Curly BRACE) Opening\n";

  while (1) {
   my $minfo = LinkedRE::or($string, $$gdata{cbrace});
   return undef unless $minfo;

   if ($$minfo{index} == 1) {
    # Closing brace, recursion stops here
    #print "(Curly BRACE) Closing <".substr($$string, $ipos, pos($$string) - $ipos - 1).">\n";
    return 1
   } elsif ($$minfo{index} == 0)  {
    # Opening brace found, triggering recursion
    #print "(Curly BRACE) Recursion\n";
    &{$$descr[$bootstrap_rule_index{CURLY_BRACE}]{handler}}($minfo, $descr, $string, $gdata);
    # print "(Curly BRACE) Back From Recursion\n";
   } else {
    #print "QUOTES <$$minfo{match}>\n"
   }
  }
 }
}
];

%bootstrap_rule_index = map {
 my $id = $spec_descr->[$_]{id};
 defined $id ? ($id => $_) : ()
} 0 .. $#$spec_descr;

for my $required_rule_id (qw/SPEC_ROOT CURLY_BRACE/) {
 die "(LinkedSpec.pm) -E- Missing required bootstrap rule id '$required_rule_id'"
  unless defined $bootstrap_rule_index{$required_rule_id};
}

my @bootstrap_start_res;
my @bootstrap_start_dispatch;
for my $idx (0 .. $#$spec_descr) {
 my $rule = $spec_descr->[$idx];
 next unless ref($rule) eq 'HASH';
 next unless exists $rule->{tags} && ref($rule->{tags}) eq 'HASH' && $rule->{tags}{start_token};
 next unless exists $rule->{re} && ref($rule->{re}) eq 'ARRAY' && @{$rule->{re}};
 push @bootstrap_start_res, $rule->{re}[0];
 push @bootstrap_start_dispatch, $idx;
}

die "(LinkedSpec.pm) -E- Bootstrap start-token registry is empty"
 unless @bootstrap_start_res && @bootstrap_start_dispatch;

my @bootstrap_cbrace_res = ();
if (defined $bootstrap_rule_index{CURLY_BRACE}
    && exists $spec_descr->[$bootstrap_rule_index{CURLY_BRACE}]{re}
    && ref($spec_descr->[$bootstrap_rule_index{CURLY_BRACE}]{re}) eq 'ARRAY') {
 @bootstrap_cbrace_res = @{$spec_descr->[$bootstrap_rule_index{CURLY_BRACE}]{re}};
}

# Bootstrap scanner bundles derived from tagged bootstrap rules.
my $gdata = {
 startREs       => LinkedRE::oredRE(@bootstrap_start_res),
 start_dispatch => \@bootstrap_start_dispatch,
 cbrace         => LinkedRE::oredRE(@bootstrap_cbrace_res)
};


# my $testdata = "999  + (3 + (7 - 9 + (arr + 99 - ZZAA)))";
# $file = qx(cat ~/specfiletest.txt);
# Get(\$file)->(\$testdata);
# Top-level entry rule selected while compiling the .spec source.
my $top_rule;

#------------------------------------------------------------------------------
# Function: _build_action_rewriter_migration_summary
# Purpose : Build descriptor-level migration summary from per-rule action_rewriter
#           metadata so roadmap follow-up can prioritize high-impact blockers.
# Args    : ($spec_hashref)
# Returns : hashref summary
#------------------------------------------------------------------------------
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

 if (should_dump(DUMP_DEBUG)) {
  log_output(
   DUMP_DEBUG,
   "(LinkedSpec.pm::_build_action_rewriter_migration_summary) summary",
   Dumper($summary)
  );
 }

 return $summary
}
#------------------------------------------------------------------------------
# Function: Get
# Purpose : Compile a .spec source into a runnable parser coderef (or return
#           descriptor/parse-only outputs based on options).
# Args    : ($spec_scalar_ref, %options)
# Returns : parser coderef | descriptor hashref | undef (mode/error dependent)
#------------------------------------------------------------------------------
sub Get {
 log_output(DUMP_LOW, "Starting parser generation", "Processing .spec file");
 
 my %option = @_[1 .. $#_];
 $pm_drive = $option{pm_drive};
 
 # Check for execution mode options
 my $parse_only = $option{parse_only};
 my $generate_only = $option{generate_only};
 my $return_descr = $option{return_descr};
 my $test_expectation = $option{test_expectation};
 
 # Always run validation, but handle failures differently for parse-only tests
 my $validation_failed = 0;
 
      # Validate input spec content
     unless (validate_spec_content($_[0])) {
         if ($parse_only && $test_expectation eq 'fail') {
             $validation_failed = 1;
             log_output(DUMP_LOW, "Validation failed as expected", "Spec content validation failed - this is expected for this test");
         } else {
             log_output(DUMP_NONE, "CRITICAL ERROR", "Spec content validation failed - terminating parser generation");
             return undef;
         }
     }
 
      # Validate DSL syntax (only if content validation passed)
     unless ($validation_failed) {
         unless (validate_dsl_syntax($_[0])) {
             if ($parse_only && $test_expectation eq 'fail') {
                 $validation_failed = 1;
                 log_output(DUMP_LOW, "Validation failed as expected", "DSL syntax validation failed - this is expected for this test");
             } else {
                 log_output(DUMP_NONE, "CRITICAL ERROR", "DSL syntax validation failed - terminating parser generation");
                 return undef;
             }
         }
     }
 
 my $retv;
 my $parse_success = 1;
 
      # Try to parse the spec file
     log_output(DUMP_LOW, "Starting spec file parsing", "Attempting to parse .spec file content");
     eval {
         $retv = &{$$spec_descr[$bootstrap_rule_index{SPEC_ROOT}]{handler}}($spec_descr, $_[0], $gdata);
     } or do {
         $parse_success = 0;
         my $error = $@;
         log_output(DUMP_NONE, "SPEC PARSING FAILED", "Hardcoded parser failed with error: $error");
     };
     
     if ($parse_success) {
         log_output(DUMP_LOW, "Spec file parsing successful", "Hardcoded parser completed successfully");
     }
 
 # Dump parse result if in dump mode (always for parse-only tests)
 if (should_dump(DUMP_MEDIUM) || $parse_only) {
     log_dump("=== SPEC COMPILE RESULT DUMP ===\n");
     if ($parse_success && defined $retv) {
         log_dump(Dumper($retv));
     } else {
         log_dump("Parse failed - no result available\n");
     }
     log_dump("=== END SPEC COMPILE RESULT DUMP ===\n");
 }

 # Do not continue into generation when bootstrap parse failed or returned no data
 unless ($parse_success && defined $retv) {
     log_output(DUMP_NONE, "CRITICAL ERROR", "Spec parsing did not produce a valid intermediate representation");
     return undef;
 }
 
      # If parse-only mode, stop here and return undef
     if ($parse_only) {
         log_output(DUMP_LOW, "Parse-only mode", "Stopping after .spec file parsing - no parser generated");
         return undef;
     }
     
     # Start parser generation phase
     log_output(DUMP_LOW, "Starting parser generation", "Converting parsed spec data into executable parser");

 my $auto_descr_spec  = spec_descr($retv);
 unless (defined($auto_descr_spec) && ref($auto_descr_spec) eq 'HASH') {
     log_output(DUMP_NONE, "CRITICAL ERROR", "Spec descriptor generation failed");
     return undef;
 }
 my $final_descr      = {spec=>$auto_descr_spec, gdata=>spec_gdata($auto_descr_spec)};
 $final_descr->{meta} ||= {};
 $final_descr->{meta}{action_rewriter_migration} = _build_action_rewriter_migration_summary($final_descr->{spec});
 
      # Validate generated structures
     unless (validate_gdata_references($final_descr->{gdata}, $final_descr->{spec})) {
         log_output(DUMP_NONE, "CRITICAL ERROR", "Generated parser validation failed - terminating parser generation");
         return undef;
     }
 
 log_output(DUMP_LOW, "Parser generation completed", "Generated parser with " . scalar(keys %$auto_descr_spec) . " rules");

 print "\n\nsub Get {&{\$descr->{spec}{$top_rule}}(\$descr, \$_[0])}\n" if $pm_drive;

 # Dump final_descr if in dump mode
 if (should_dump(DUMP_LOW)) {
     log_dump("=== FINAL_DESCR DUMP: top_rule=$top_rule ===\n");
     log_dump(Dumper($final_descr));
     log_dump("=== END FINAL_DESCR DUMP: top_rule=$top_rule ===\n");
 }
 
      # If generate-only mode, stop here and return undef
     if ($generate_only) {
         log_output(DUMP_LOW, "Generate-only mode", "Stopping after parser generation - no functional parser returned");
         return undef;
     }
     
     # Optional descriptor-return mode for tooling/introspection
     if ($return_descr) {
         log_output(DUMP_LOW, "Descriptor-return mode", "Returning generated parser descriptor hash");
         return $final_descr;
     }
     
     # Parser generation completed successfully
     log_output(DUMP_LOW, "Parser generation completed successfully", "Returning functional parser for execution");

 return sub {&{$final_descr->{spec}{$top_rule}{handler}}($final_descr, $_[0])}
}

#------------------------------------------------------------------------------
# Function: _select_rule_handler_variant
# Purpose : Deterministically map a rule shape (node type + code mix) to the
#           handler template variant that should emit runtime behavior.
# Args    : ($node_type, $acode_count, $bcode_count, $regex_count)
# Returns : variant id string
#------------------------------------------------------------------------------
sub _select_rule_handler_variant {
 my ($node_type, $acode_count, $bcode_count, $regex_count) = @_;

 $node_type   = defined $node_type ? $node_type : 'default';
 $acode_count = $acode_count // 0;
 $bcode_count = $bcode_count // 0;
 $regex_count = $regex_count // 0;

 return 'MIXED_ACTIONS' if $acode_count && $bcode_count;

 if ($node_type =~ /AND/o && $acode_count) {
  return $regex_count == 1 ? 'AND_SINGLE_ACODE' : 'AND_ACODE';
 }
 return 'AND_BCODE' if $node_type =~ /AND/o && $bcode_count;
 return 'OR_ACODE'  if $node_type =~ /OR/o  && $acode_count;
 return 'OR_BCODE'  if $node_type =~ /OR/o  && $bcode_count;
 return 'REP_ACODE' if $node_type =~ /REP_/o && $acode_count;
 return 'REP_BCODE' if $node_type =~ /REP_/o && $bcode_count;

 return '_default'
}

#------------------------------------------------------------------------------
# Function: _build_rule_execution_meta
# Purpose : Build normalized metadata describing how a rule executes, including
#           action mode, selected variant and loop behavior.
# Args    : named args hash
# Returns : hashref metadata
#------------------------------------------------------------------------------
sub _build_rule_execution_meta {
 my (%args) = @_;

 my $label = defined $args{label} ? $args{label} : '<undefined>';
 my $node_type = defined $args{node_type} ? $args{node_type} : 'default';
 my $regex_count = $args{regex_count} // 0;
 my $acode_count = $args{acode_count} // 0;
 my $bcode_count = $args{bcode_count} // 0;
 my $handler_variant = _select_rule_handler_variant($node_type, $acode_count, $bcode_count, $regex_count);

 my $action_mode =
    $acode_count && $bcode_count ? 'mixed'
  : $acode_count                 ? 'action'
  : $bcode_count                 ? 'blind_call'
  :                                'none';

 my ($execution_shape, $uses_loop) = ('default_scan_loop', 1);
 if ($handler_variant eq 'AND_SINGLE_ACODE') {
  ($execution_shape, $uses_loop) = ('single_match', 0);
 } elsif ($handler_variant eq 'AND_ACODE') {
  ($execution_shape, $uses_loop) = ('and_sequence_loop', 1);
 } elsif ($handler_variant eq 'AND_BCODE') {
  ($execution_shape, $uses_loop) = ('and_call_loop', 1);
 } elsif ($handler_variant eq 'OR_ACODE') {
  ($execution_shape, $uses_loop) = ('or_choice_dispatch', 0);
 } elsif ($handler_variant eq 'OR_BCODE') {
  ($execution_shape, $uses_loop) = ('or_call_loop', 1);
 } elsif ($handler_variant eq 'REP_ACODE' || $handler_variant eq 'REP_BCODE') {
  ($execution_shape, $uses_loop) = ('repeat_loop', 1);
 } elsif ($handler_variant eq 'MIXED_ACTIONS') {
  ($execution_shape, $uses_loop) = ('invalid_mixed_actions', 0);
 }

 my $meta = {
  label           => $label,
  node_type       => $node_type,
  regex_count     => $regex_count,
  acode_count     => $acode_count,
  bcode_count     => $bcode_count,
  action_mode     => $action_mode,
  handler_variant => $handler_variant,
  execution_shape => $execution_shape,
  uses_loop       => $uses_loop ? 1 : 0,
 };

 if (should_dump(DUMP_DEBUG)) {
  log_output(DUMP_DEBUG, "(LinkedSpec.pm::_build_rule_execution_meta) Rule meta", Dumper($meta));
 }

 return $meta
}

#------------------------------------------------------------------------------
# Function: spec_descr
# Purpose : Convert parsed bootstrap entries into the descriptor's `spec` hash
#           (rule label => compiled rule info).
# Args    : ($parsed_spec_entries)
# Returns : hashref of spec rule definitions
#------------------------------------------------------------------------------
sub spec_descr {
my $specretv = shift;

 print 'my $descr = {
 spec => {'."\n" if $pm_drive;
 my @specinfo;
 foreach my $entry (@$specretv) {
  my ($label, $info) = spec_entry($entry);
  unless (defined($label) && defined($info) && ref($info) eq 'HASH') {
   log_output(DUMP_NONE, "CRITICAL ERROR", "Rule descriptor build failed while compiling parsed spec entries");
   return undef
  }
  push @specinfo, $label, $info;
 }
 
 # Debug: Log the specinfo array
 log_output(DUMP_LOW, "Specinfo array contents", "Number of entries: " . scalar(@specinfo));
 for (my $i = 0; $i < @specinfo; $i += 2) {
     my $label = $specinfo[$i];
     my $info  = $specinfo[$i + 1];
     log_output(DUMP_LOW, "Entry " . ($i / 2), "Label: '$label', Type: " . ref($info));
 }
 
 # Debug: Check for duplicate rules
 my %seen_rules;
 my @duplicate_rules;
 for (my $i = 0; $i < @specinfo; $i += 2) {
     my $label = $specinfo[$i];
     if (exists $seen_rules{$label}) {
         push @duplicate_rules, $label;
         log_output(DUMP_LOW, "Duplicate rule detected", "Rule '$label' is defined multiple times - second definition will overwrite the first");
     }
     $seen_rules{$label} = 1;
 }
 
 if (@duplicate_rules) {
     log_output(DUMP_LOW, "Duplicate rules summary", "Rules with multiple definitions: " . join(", ", @duplicate_rules));
 }
 
 my $result = {@specinfo};
 
 # Dump generated spec if in dump mode
 if (should_dump(DUMP_MEDIUM)) {
     log_dump("=== GENERATED SPEC DUMP ===\n");
     log_dump(Dumper($result));
     log_dump("=== END GENERATED SPEC DUMP ===\n");
 }

 return $result
}

#------------------------------------------------------------------------------
# Function: _build_action_lowering_contracts
# Purpose : Declare helper-lowering contracts (scan pattern + lowering rewrite
#           semantics + IR identity) for action rewriting.
# Args    : ($label)
# Returns : arrayref of contract hashes
#------------------------------------------------------------------------------
sub _build_action_lowering_contracts {
 my ($label) = @_;

 return [
  {
   id                 => 'call',
   ir_node            => 'CALL',
   diag_name          => 'call',
   unresolved_pattern => qr/\bcall\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bcall\s*\(\s*(\w+)\s*\)/&{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_single_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bpush\s*\(\s*(\w+)\s*\)/push \@$label, &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_target_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)/push \@$2, &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_scope_target_arg',
   ir_node            => 'PUSH',
   diag_name          => 'push',
   unresolved_pattern => qr/\bpush\s*\(\s*\w+\s*,\s*\w+\s*,\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bpush\s*\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*\)/push \@$3, &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'return_a',
   ir_node            => 'RETURN_A',
   diag_name          => 'return_a',
   unresolved_pattern => qr/\breturn_a\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\breturn_a\s*\(\s*$label(?:\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+))?\s*\)/return ['?$label:', @{[$+{arg} ? "($+{arg}), " : '']}\\\@$label]/g;
    return $code
   },
  },
  {
   id                 => 'return_general',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   unresolved_pattern => qr/\breturn\s*\(\s*(?:\[|\{|"|'|-?\d+(?:\.\d+)?|scalar\s*\(|array\s*\(|hash\s*\()/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>return\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_return_general_statement($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'return',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   unresolved_pattern => qr/\breturn\s*\(\s*\w+\s*,/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\breturn\s*\(\s*$label\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+)\s*\)/return ['?$label:', $+{arg}]/g;
    return $code
   },
  },
  {
   id                 => 'return_ma',
   ir_node            => 'RETURN_MA',
   diag_name          => 'return_ma',
   unresolved_pattern => qr/\breturn_ma\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\breturn_ma\s*\(\s*$label\s*\)/return ['?$label:', \@IMATCH_LIST, \\\@$label]/g;
    return $code
   },
  },
  {
   id                 => 'return_m',
   ir_node            => 'RETURN_M',
   diag_name          => 'return_m',
   unresolved_pattern => qr/\breturn_m\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\breturn_m\s*\(\s*$label\s*\)/return ['?$label:', \@IMATCH_LIST]/g;
    return $code
   },
  },
  {
   id                 => 'capture_macro',
   ir_node            => 'CAPTURE_MACRO',
   diag_name          => 'capture_macro',
   unresolved_pattern => qr/\$CAPTURE\b/o,
   lower              => sub {
    my ($code) = @_;
    $code =~ s/\$CAPTURE\b/substr(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH)/g;
    return $code
   },
  },
  {
   id                 => 'capture',
   ir_node            => 'CAPTURE',
   diag_name          => 'capture',
   unresolved_pattern => qr/\bcapture\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bcapture\s*\(\s*\w+\s*\)/push \@$label, substr(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH)/g;
    return $code
   },
  },
  {
   id                 => 'capture_if',
   ir_node            => 'CAPTURE_IF',
   diag_name          => 'capture_if',
   unresolved_pattern => qr/\bcapture_if\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s{\bcapture_if\s*\(\s*\w+\s*\)}{my \$capt = substr(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH); \$capt =~ s/^\s*|\s*$//go; push \@$label, \$capt if \$capt}g;
    return $code
   },
  },
  {
   id                 => 'capture_if_macro',
   ir_node            => 'CAPTURE_IF',
   diag_name          => 'CAPTURE_IF',
   unresolved_pattern => qr/\bCAPTURE_IF\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s{\bCAPTURE_IF\s*\(\s*\)}{my \$capt = substr(\$\$STRING, \$IPOS, \$LSPOS - \$IPOS - length \$LMATCH); \$capt =~ s/^\s*|\s*$//go; push \@$label, \$capt if \$capt}g;
    return $code
   },
  },
  {
   id                 => 'ibacktrack_macro',
   ir_node            => 'IBACKTRACK',
   diag_name          => 'IBACKTRACK',
   unresolved_pattern => qr/\bIBACKTRACK\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bIBACKTRACK\s*\(\s*\)/pos(\$\$STRING) = \$IPOS  - length \$IMATCH/g;
    return $code
   },
  },
  {
   id                 => 'backtrack_macro',
   ir_node            => 'BACKTRACK',
   diag_name          => 'BACKTRACK',
   unresolved_pattern => qr/\bBACKTRACK\s*\(\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bBACKTRACK\s*\(\s*\)/pos(\$\$STRING)  = \$LSPOS - length \$LMATCH/g;
    return $code
   },
  },
  {
   id                 => 'ibacktrack',
   ir_node            => 'IBACKTRACK',
   diag_name          => 'ibacktrack',
   unresolved_pattern => qr/\bibacktrack\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bibacktrack\s*\(\s*\w+\s*\)/pos(\$\$STRING) = \$IPOS  - length \$IMATCH/g;
    return $code
   },
  },
  {
   id                 => 'backtrack',
   ir_node            => 'BACKTRACK',
   diag_name          => 'backtrack',
   unresolved_pattern => qr/\bbacktrack\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bbacktrack\s*\(\s*\w+\s*\)/pos(\$\$STRING)  = \$LSPOS - length \$LMATCH/g;
    return $code
   },
  },
  {
   id                 => 'assign_call_my',
   ir_node            => 'CALL',
   diag_name          => 'assign_call_my',
   unresolved_pattern => qr/\bmy\s+\$\w+\s*=\s*call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bmy\s+(\$\w+)\s*=\s*call\s*\(\s*(\w+)\s*\)/my $1 = &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'assign_call',
   ir_node            => 'CALL',
   diag_name          => 'assign_call',
   unresolved_pattern => qr/\$\w+\s*=\s*call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/(\$\w+)\s*=\s*call\s*\(\s*(\w+)\s*\)/$1 = &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'push_call_indexed_builtin',
   ir_node            => 'CALL',
   diag_name          => 'push_call_indexed_builtin',
   unresolved_pattern => qr/\bpush\s+\@\w+\s*,\s*call\s*\(\s*\w+\s*\)\s*->\s*\[\s*\d+\s*\]/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bpush\s+\@(\w+)\s*,\s*call\s*\(\s*(\w+)\s*\)\s*->\s*\[\s*(\d+)\s*\]/push \@$1, &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)->[$3]/g;
    return $code
   },
  },
  {
   id                 => 'push_call_builtin',
   ir_node            => 'CALL',
   diag_name          => 'push_call_builtin',
   unresolved_pattern => qr/\bpush\s+\@\w+\s*,\s*call\s*\(\s*\w+\s*\)(?!\s*->\s*\[)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bpush\s+\@(\w+)\s*,\s*call\s*\(\s*(\w+)\s*\)(?!\s*->\s*\[)/push \@$1, &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'return_call',
   ir_node            => 'CALL',
   diag_name          => 'return_call',
   unresolved_pattern => qr/\breturn\s+call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\breturn\s+call\s*\(\s*(\w+)\s*\)/return &{\$\$descr{spec}{$1}{handler}}(\$descr, \$STRING, \$minfo)/g;
    return $code
   },
  },
  {
   id                 => 'return_bare',
   ir_node            => 'RETURN',
   diag_name          => 'return',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'exit_bare',
   ir_node            => 'EXIT',
   diag_name          => 'exit',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'linecount_prefix_newline_matches',
   ir_node            => 'LINE_COUNT',
   diag_name          => 'line_count',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'print_capture_substr',
   ir_node            => 'PRINT',
   diag_name          => 'print',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'my_declare_bare',
   ir_node            => 'DECLARE',
   diag_name          => 'declare',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'assign_match_my',
   ir_node            => 'ASSIGN',
   diag_name          => 'assign',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'destructure_imatch_list_my',
   ir_node            => 'ASSIGN',
   diag_name          => 'assign',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'regex_subst_assignment',
   ir_node            => 'REGEX_SUBST',
   diag_name          => 'substr',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'next_bare',
   ir_node            => 'NEXT',
   diag_name          => 'next',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'ref_field_assign',
   ir_node            => 'ASSIGN',
   diag_name          => 'assign',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'position_tracking',
   ir_node            => 'POSITION_TRACK',
   diag_name          => 'position_tracking',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'print_foreach_iterable',
   ir_node            => 'PRINT',
   diag_name          => 'print',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'split_trim_filter_assignment',
   ir_node            => 'ASSIGN',
   diag_name          => 'assign',
   unresolved_pattern => undef,
   lower              => sub {
    my ($code) = @_;
    return $code
   },
  },
  {
   id                 => 'return_imatch',
   ir_node            => 'RETURN',
   diag_name          => 'return_imatch',
   unresolved_pattern => qr/\breturn_im(?:atch)?\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\breturn_im(?:atch)?\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<tag>(?:'[^']*'|"[^"]*"|\w+))\s*\)/_lower_return_imatch_statement($+{tag}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'assign_value',
   ir_node            => 'ASSIGN',
   diag_name          => 'assign',
   unresolved_pattern => qr/\bassign\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>assign\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_assign_method_statement($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'regex_subst',
   ir_node            => 'REGEX_SUBST',
   diag_name          => 'substr',
   unresolved_pattern => qr/\b(?:substr|regex_subst)\s*\(\s*(?:(?:\w+)\s*,\s*)?(?:scalar\s*\(\s*\w+\s*\)|\w+)\s*,/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?:substr|regex_subst)\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<target>(?:scalar\s*\(\s*\w+\s*\)|\w+))\s*,\s*(?<pattern>(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\/(?:\\.|[^\/])*\/))\s*,\s*(?<replacement>(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\/\/|\/(?:\\.|[^\/])*\/))\s*,\s*(?<flags>\w*)\s*\)/_lower_regex_subst_statement($+{target}, $+{pattern}, $+{replacement}, $+{flags}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'split_array',
   ir_node            => 'SPLIT',
   diag_name          => 'split',
   unresolved_pattern => qr/\bsplit\s*\(\s*(?:(?:\w+)\s*,\s*)?(?:array\s*\(\s*\w+\s*\)|\w+)\s*,\s*(?:scalar\s*\(\s*\w+\s*\)|\w+)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>split\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_array_pipeline_expr($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'trim_each',
   ir_node            => 'TRIM_EACH',
   diag_name          => 'trim_each',
   unresolved_pattern => qr/\btrim_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>trim_each\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_array_pipeline_expr($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'filter_nonempty',
   ir_node            => 'FILTER_NONEMPTY',
   diag_name          => 'filter_nonempty',
   unresolved_pattern => qr/\bfilter_nonempty\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>filter_nonempty\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_array_pipeline_expr($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'lowercase_each',
   ir_node            => 'MAP_LOWERCASE',
   diag_name          => 'lowercase_each',
   unresolved_pattern => qr/\blowercase_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>lowercase_each\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_array_pipeline_expr($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'uppercase_each',
   ir_node            => 'MAP_UPPERCASE',
   diag_name          => 'uppercase_each',
   unresolved_pattern => qr/\buppercase_each\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>uppercase_each\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_array_pipeline_expr($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'uniq_array',
   ir_node            => 'UNIQ',
   diag_name          => 'uniq',
   unresolved_pattern => qr/\buniq\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>uniq\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_array_pipeline_expr($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'filter_match',
   ir_node            => 'FILTER_MATCH',
   diag_name          => 'filter_match',
   unresolved_pattern => qr/\bfilter_match\s*\(/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>filter_match\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_array_pipeline_expr($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'if_flow',
   ir_node            => 'IF',
   diag_name          => 'if',
   unresolved_pattern => qr/\b(?:if|i)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))(?!\s*\{)/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>(?:if|i)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))(?!\s*\{))/_lower_if_flow_statement($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'elseif_flow',
   ir_node            => 'ELIF',
   diag_name          => 'elseif',
   unresolved_pattern => qr/\b(?:elif|elseif)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))(?!\s*\{)/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>(?:elif|elseif)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))(?!\s*\{))/_lower_elseif_flow_statement($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'else_flow',
   ir_node            => 'ELSE',
   diag_name          => 'else',
   unresolved_pattern => qr/\belse\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>else\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_else_flow_statement($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'endif_flow',
   ir_node            => 'ENDIF',
   diag_name          => 'endif',
   unresolved_pattern => qr/\bendif\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>endif\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_endif_flow_statement($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'switch_flow',
   ir_node            => 'SWITCH',
   diag_name          => 'switch',
   unresolved_pattern => qr/\bswitch\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>switch\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_switch_flow_statement($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'case_flow',
   ir_node            => 'CASE',
   diag_name          => 'case',
   unresolved_pattern => qr/\bcase\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>case\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_case_flow_statement($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'default_flow',
   ir_node            => 'DEFAULT',
   diag_name          => 'default',
   unresolved_pattern => qr/\bdefault\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>default\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_default_flow_statement($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'endcase_flow',
   ir_node            => 'ENDCASE',
   diag_name          => 'endcase',
   unresolved_pattern => qr/\bendcase\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>endcase\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_endcase_flow_statement($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'endswitch_flow',
   ir_node            => 'ENDSWITCH',
   diag_name          => 'endswitch',
   unresolved_pattern => qr/\bendswitch\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>endswitch\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_endswitch_flow_statement($+{expr}, $ctx) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'say_stmt',
   ir_node            => 'SAY',
   diag_name          => 'say',
   unresolved_pattern => qr/\bsay\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>say\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_say_statement($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'print_stmt',
   ir_node            => 'PRINT',
   diag_name          => 'print',
   unresolved_pattern => qr/\bprint\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>print\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_print_statement($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'return_undef',
   ir_node            => 'RETURN',
   diag_name          => 'return_undef',
   unresolved_pattern => qr/\breturn_undef\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))/o,
   lower              => sub {
    my ($code, $ctx) = @_;
   $code =~ s/\b(?<expr>return_undef\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_return_undef_statement($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'return_array',
   ir_node            => 'RETURN',
   diag_name          => 'return_array',
   unresolved_pattern => qr/\breturn_array\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\breturn_array\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<tag>(?:'[^']*'|"[^"]*"|\w+))\s*,\s*(?<payload>(?:[^()]++|(?<P>\((?:[^()]++|(?&P))*\)))+)\s*\)/_lower_return_array_statement($+{tag}, $+{payload}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'declare_typed',
   ir_node            => 'DECLARE',
   diag_name          => 'declare',
   unresolved_pattern => qr/\bdeclare\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>declare\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_declare_method_statement($+{expr}) || $&/ge;
    return $code
   },
  },
  {
   id                 => 'declare_alias',
   ir_node            => 'DECLARE',
   diag_name          => 'declare',
   unresolved_pattern => qr/\bdeclare_(?:a|array|s|scalar|h|hash)\s*\(/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\b(?<expr>declare_(?:a|array|s|scalar|h|hash)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/_lower_declare_method_statement($+{expr}) || $&/ge;
    return $code
   },
  },
 ]
}

#------------------------------------------------------------------------------
# Function: _collect_rule_ir
# Purpose : Normalize parsed bootstrap entry tuples into a structured RuleIR
#           payload consumed by planning/validation/emission stages.
# Args    : ($einfo)
# Returns : hashref RuleIR
#------------------------------------------------------------------------------
sub _collect_rule_ir {
 my ($einfo) = @_;

 my $rule_ir = {
  label         => undef,
  node_type     => 'default',
  top_rule      => undef,
  REs           => [],
  code_blocks   => {
   ICODE  => [],
   ECODE  => [],
   EXCODE => [],
   ITCODE => [],
   LXCODE => [],
   LSCODE => [],
   LECODE => [],
  },
  acode_entries => [],
  bcode_entries => [],
 };

 foreach my $centry (@$einfo) {
  ($rule_ir->{label}, $rule_ir->{node_type}) = @$centry[1 .. 2] if $$centry[0] =~ /ELABEL/o;

  my $entry_type = $$centry[0];
  if ($entry_type =~ /ELABEL_INITIAL/o) {
   $rule_ir->{top_rule} = $$centry[1];
  }
  elsif (exists $rule_ir->{code_blocks}{$entry_type}) {
   push @{$rule_ir->{code_blocks}{$entry_type}}, $$centry[1];
  }
  elsif ($entry_type eq 'RE') {
   push @{$rule_ir->{REs}}, qr/$$centry[1]/;
  }
  elsif ($entry_type eq 'ACODE') {
   push @{$rule_ir->{acode_entries}}, {
    relabel => $$centry[1]{relabel},
    reidx   => $$centry[1]{reidx},
    code    => $$centry[1]{code},
   };
  }
  elsif ($entry_type eq 'BCODE') {
   push @{$rule_ir->{bcode_entries}}, {
    call => $$centry[1]{call},
    code => $$centry[1]{code},
   };
  }
  elsif ($entry_type eq 'MOVE_POS') {
   push @{$rule_ir->{code_blocks}{LECODE}}, '$IPOS = pos $$STRING';
  }
 }

 return $rule_ir
}

#------------------------------------------------------------------------------
# Function: _plan_rule_ir_meta
# Purpose : Derive deterministic execution metadata from RuleIR counts/types.
# Args    : ($rule_ir)
# Returns : hashref execution metadata
#------------------------------------------------------------------------------
sub _plan_rule_ir_meta {
 my ($rule_ir) = @_;

 return _build_rule_execution_meta(
  label       => $rule_ir->{label},
  node_type   => $rule_ir->{node_type},
  regex_count => scalar(@{$rule_ir->{REs}}),
  acode_count => scalar(@{$rule_ir->{acode_entries}}),
  bcode_count => scalar(@{$rule_ir->{bcode_entries}}),
 )
}

#------------------------------------------------------------------------------
# Function: _validate_rule_ir_or_exit
# Purpose : Enforce rule-shape invariants before emission (notably disallowing
#           mixed ACTION + BLIND CALL forms in one rule).
# Args    : ($rule_ir, $rule_meta)
# Returns : 1 on success, 0 on validation failure
#------------------------------------------------------------------------------
sub _validate_rule_ir_or_exit {
 my ($rule_ir, $rule_meta) = @_;

 if ($rule_meta->{action_mode} eq 'mixed') {
  my $label = $rule_ir->{label};
  my $error_msg = "Rule '$label': Cannot mix ACTION (->) and BLIND CALL (=>) code blocks";
  my $context = "ACTION blocks: ".($rule_meta->{acode_count} // 0)." found, BLIND CALL blocks: ".($rule_meta->{bcode_count} // 0)." found";
  log_output(DUMP_NONE, $error_msg, $context);
  print "  Solution: Use either ACTION blocks OR BLIND CALL blocks, not both\n";
  print "  Example: Use '-> rule_name { code }' OR '=> function_name { code }'\n";
  return 0
 }

 return 1
}

#------------------------------------------------------------------------------
# Function: _normalize_rule_code_chunks
# Purpose : Rewrite and join lifecycle code chunks while accumulating rewrite
#           diagnostics across each transformed chunk.
# Args    : ($label, $chunks, $rewrite_diag_acc, $rewrite_rules)
# Returns : normalized code string
#------------------------------------------------------------------------------
sub _normalize_rule_code_chunks {
 my ($label, $chunks, $rewrite_diag_acc, $rewrite_rules) = @_;

 my @normalized;
 foreach my $chunk (@$chunks) {
  my ($rewritten, $diag) = _rewrite_action_code_with_diagnostics($label, $chunk, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag) if $rewrite_diag_acc;
  $rewritten =~ s/\s*;\s*$//o;
  push @normalized, $rewritten;
 }

 return join ";\n", @normalized
}

#------------------------------------------------------------------------------
# Function: _build_rule_ir_emit_context
# Purpose : Build fully-rewritten emit context (ACODE/BCODE/gdata/lifecycle
#           chunks) plus rich action-rewriter diagnostics metadata.
# Args    : ($rule_ir)
# Returns : hashref emit context
#------------------------------------------------------------------------------
sub _build_rule_ir_emit_context {
 my ($rule_ir) = @_;
 my $label = $rule_ir->{label};
 my $rewrite_rules = _build_action_rewrite_rules($label);
 my $rewrite_diag_acc = {
  unresolved_helper_hits  => {},
  unresolved_helper_count => 0,
  unresolved_helper_events => [],
  helper_action_ir_hits   => {},
  helper_action_ir_count  => 0,
  helper_action_ir_events => [],
  canonical_action_ir_hits   => {},
  canonical_action_ir_count  => 0,
  canonical_action_ir_events => [],
  canonical_action_ir_fallback_count => 0,
 };

 my @ACODEs;
 my @GDATA;
 foreach my $acode_entry (@{$rule_ir->{acode_entries}}) {
  my ($rewritten_acode, $diag) = _rewrite_action_code_with_diagnostics($label, $acode_entry->{code}, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @ACODEs, $rewritten_acode;
  push @GDATA, {label => $acode_entry->{relabel}, idx => $acode_entry->{reidx}};
 }

 my @BCALLs;
 my %BCODEs;
 foreach my $bcode_entry (@{$rule_ir->{bcode_entries}}) {
  my ($rewritten_bcode, $diag) = _rewrite_action_code_with_diagnostics($label, $bcode_entry->{code}, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @BCALLs, $bcode_entry->{call};
  $BCODEs{$bcode_entry->{call}} = $rewritten_bcode;
 }

 my %ab_count = (
  ACODE => scalar(@{$rule_ir->{acode_entries}}),
  BCODE => scalar(@{$rule_ir->{bcode_entries}}),
 );

 my $icode  = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{ICODE},  $rewrite_diag_acc, $rewrite_rules);
 my $ecode  = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{ECODE},  $rewrite_diag_acc, $rewrite_rules);
 my $excode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{EXCODE}, $rewrite_diag_acc, $rewrite_rules);
 my $itcode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{ITCODE}, $rewrite_diag_acc, $rewrite_rules);
 my $lxcode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{LXCODE}, $rewrite_diag_acc, $rewrite_rules);
 my $lscode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{LSCODE}, $rewrite_diag_acc, $rewrite_rules);
 my $lecode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{LECODE}, $rewrite_diag_acc, $rewrite_rules);

 my @rewrite_contract_ids = map { $_->{id} } @$rewrite_rules;
 my @unresolved_helper_statements;
 my %seen_unresolved_helper_statement;
 foreach my $event (@{$rewrite_diag_acc->{unresolved_helper_events}}) {
  my $raw_code = _trim_action_ir_value($event->{raw});
  next unless defined($raw_code) && length($raw_code);
  next if $seen_unresolved_helper_statement{$raw_code}++;
  push @unresolved_helper_statements, $raw_code;
 }
 my @raw_perl_dependency_statements;
 my %seen_raw_perl_dependency_statement;
 foreach my $event (@{$rewrite_diag_acc->{canonical_action_ir_events}}) {
  next unless ($event->{kind} // '') eq 'RAW_PERL';
  my $raw_code = (ref($event->{args}) eq 'HASH') ? $event->{args}{code} : $event->{raw};
  $raw_code = _trim_action_ir_value($raw_code);
  next unless defined($raw_code) && length($raw_code);
  next if $seen_raw_perl_dependency_statement{$raw_code}++;
  push @raw_perl_dependency_statements, $raw_code;
 }
 my $raw_perl_dependency_count = $rewrite_diag_acc->{canonical_action_ir_fallback_count} || 0;
 my @language_agnostic_action_ir_blocker_statements;
 my %seen_language_agnostic_action_ir_blocker_statement;
 foreach my $statement (@raw_perl_dependency_statements, @unresolved_helper_statements) {
  next unless defined($statement) && length($statement);
  next if $seen_language_agnostic_action_ir_blocker_statement{$statement}++;
  push @language_agnostic_action_ir_blocker_statements, $statement;
 }
 my $language_agnostic_action_ir_blocker_statement_count = scalar @language_agnostic_action_ir_blocker_statements;
 my $language_agnostic_action_ir_ready = (
  $raw_perl_dependency_count == 0 &&
  ($rewrite_diag_acc->{unresolved_helper_count} || 0) == 0
 ) ? 1 : 0;

 my $action_rewriter_meta = {
  unresolved_helper_count => $rewrite_diag_acc->{unresolved_helper_count},
  unresolved_helpers      => [sort keys %{$rewrite_diag_acc->{unresolved_helper_hits}}],
  unresolved_helper_hits  => {%{$rewrite_diag_acc->{unresolved_helper_hits}}},
  unresolved_helper_events => [@{$rewrite_diag_acc->{unresolved_helper_events}}],
  unresolved_helper_statements => \@unresolved_helper_statements,
  helper_action_ir_count  => $rewrite_diag_acc->{helper_action_ir_count},
  helper_action_ir_nodes  => [sort keys %{$rewrite_diag_acc->{helper_action_ir_hits}}],
  helper_action_ir_hits   => {%{$rewrite_diag_acc->{helper_action_ir_hits}}},
  helper_action_ir_events => [@{$rewrite_diag_acc->{helper_action_ir_events}}],
  canonical_action_ir_count => $rewrite_diag_acc->{canonical_action_ir_count},
  canonical_action_ir_nodes => [sort keys %{$rewrite_diag_acc->{canonical_action_ir_hits}}],
  canonical_action_ir_hits  => {%{$rewrite_diag_acc->{canonical_action_ir_hits}}},
  canonical_action_ir_events => [@{$rewrite_diag_acc->{canonical_action_ir_events}}],
  canonical_action_ir_fallback_count => $rewrite_diag_acc->{canonical_action_ir_fallback_count},
  raw_perl_dependency_count => $raw_perl_dependency_count,
  raw_perl_dependency_statements => \@raw_perl_dependency_statements,
  language_agnostic_action_ir_blocker_statement_count => $language_agnostic_action_ir_blocker_statement_count,
  language_agnostic_action_ir_blocker_statements => \@language_agnostic_action_ir_blocker_statements,
  language_agnostic_action_ir_ready => $language_agnostic_action_ir_ready,
  rewrite_contract_ids    => \@rewrite_contract_ids,
 };

 if ($action_rewriter_meta->{unresolved_helper_count}) {
  log_output(
   DUMP_LOW,
   "Rule '$label': unresolved action helper(s) after rewrite pipeline",
   "helpers=" . join(', ', @{$action_rewriter_meta->{unresolved_helpers}})
  );
 }

 return {
  label     => $label,
  node_type => $rule_ir->{node_type},
  REs       => $rule_ir->{REs},
  ACODEs    => \@ACODEs,
  BCODEs    => \%BCODEs,
  BCALLs    => \@BCALLs,
  GDATA     => \@GDATA,
  ab_count  => \%ab_count,
  icode     => $icode,
  ecode     => $ecode,
  excode    => $excode,
  itcode    => $itcode,
  lxcode    => $lxcode,
  lscode    => $lscode,
  lecode    => $lecode,
  action_rewriter_meta => $action_rewriter_meta,
 }
}

#------------------------------------------------------------------------------
# Function: spec_entry
# Purpose : Compile one parsed rule entry through staged RuleIR flow and return
#           a final (label, rule_info_hashref) pair for descriptor assembly.
# Args    : ($einfo)
# Returns : ($label, $rule_info_hashref)
#------------------------------------------------------------------------------
sub spec_entry {
my $einfo = shift;

 my %info;
 my %handlers;

 if (should_dump(DUMP_HIGH)) {
     log_dump("=== SPEC ENTRY DUMP ===\n");
     log_dump(Dumper($einfo));
     log_dump("=== END SPEC ENTRY DUMP ===\n");
 }

 my $rule_ir = _collect_rule_ir($einfo);
 $top_rule = $rule_ir->{top_rule} if defined $rule_ir->{top_rule};

 my $rule_meta = _plan_rule_ir_meta($rule_ir);
 return unless _validate_rule_ir_or_exit($rule_ir, $rule_meta);

 my $emit_ctx = _build_rule_ir_emit_context($rule_ir);
 $rule_meta->{action_rewriter} = $emit_ctx->{action_rewriter_meta};
 my $label    = $emit_ctx->{label};
 my $node_type = $emit_ctx->{node_type};
 my @REs      = @{$emit_ctx->{REs}};
 my @ACODEs   = @{$emit_ctx->{ACODEs}};
 my %BCODEs   = %{$emit_ctx->{BCODEs}};
 my @BCALLs   = @{$emit_ctx->{BCALLs}};
 my @GDATA    = @{$emit_ctx->{GDATA}};
 my %ab_count = %{$emit_ctx->{ab_count}};

 my $icode  = $emit_ctx->{icode};
 my $ecode  = $emit_ctx->{ecode};
 my $excode = $emit_ctx->{excode};
 my $itcode = $emit_ctx->{itcode};
 my $lxcode = $emit_ctx->{lxcode};
 my $lscode = $emit_ctx->{lscode};
 my $lecode = $emit_ctx->{lecode};

 # Initial value of the handler code
 my $actual_icode  = $icode  && "$icode;"  || "";
 my $actual_ecode  = $ecode  && "$ecode;"  || "";
 my $actual_excode = $excode && "$excode;" || "";
 my $actual_itcode = $itcode && "$itcode;" || "";

 my $handler = 
'my ($descr, $STRING, $info) = @_; 
my $IMATCH      = $$info{match}; 
my @IMATCH_LIST = @{$$info{match_list} // []};
my %IMATCH_HASH = %{$$info{match_hash} // {}};
my $IINDEX      = $$info{index}; 
my $IPOS        = pos $$STRING;

my @'.$label.';

'.$actual_icode;
 
 my $notvalid_lcodes = qr/^\s*$/o;
 
 if($ab_count{ACODE} || $ab_count{BCODE} || $lxcode !~ $notvalid_lcodes || $lscode !~ $notvalid_lcodes || $lecode !~ $notvalid_lcodes) {
  my $acodes = "";
  my $bcodes = "";
  if ($ab_count{ACODE}) {
   my $once  = 0;
   my $idx   = 0;
   $acodes  .= ($once++ ? " elsif " : "\n   if").'($$minfo{index} == '.$idx++.") {\n    $_\n   }" foreach (@ACODEs)
  }

  if ($ab_count{BCODE}) {
   my $once  = 0;
   $bcodes  .= ($once++ ? " elsif " : "\n   if")."(\$call eq \"$_\") {\n    $BCODEs{$_}\n   }" foreach (@BCALLs)
  }

  my $isAND = $node_type =~ /AND/o;
  my $isOR  = $node_type =~ /OR/o;
  my $isREP = $node_type =~ /REP_/o;

  my $actual_lxcode = $lxcode && "$lxcode;" || "";
  my $actual_lscode = $lscode && "$lscode;" || "";
  my $actual_lecode = $lecode && "$lecode;" || "";

 $handlers{_default} = ' 

 while (1) {
  my $minfo; eval q/$minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'})/;
  if($@) {
   print "\n(LinkedSpec) -E- Rule \''.$label.'\': Error during handler code generation\n";
   print "  Error: $@\n";
   print "  This usually indicates a syntax error in the generated Perl code\n";
   print "  Check your .spec file for malformed code blocks or invalid syntax\n";
   exit 1
  }

  unless($minfo) {
  '.($actual_lxcode || 'return undef').'
  }

  my $LMATCH      = $$minfo{match};
  my @LMATCH_LIST = @{$$minfo{match_list} // []};
  my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
  my $LINDEX      = $$minfo{index};
  my $LSPOS       = pos $$STRING;
  
  '.$actual_lscode.'

  '.   $acodes     .'

  '.$actual_lecode.'

 }' if $acodes;

 $handlers{AND_BCODE} = '

  my $'.$label.';
  my @'.$label.'_collect;
  foreach my $call (qw('."@BCALLs".')) {
   my $current_call = $call;

   '.$bcodes.'

   unless ($'.$label.') {
    '.($actual_lxcode || 'return undef').'
   }
   
   '.($actual_lecode || 'push @'.$label.'_collect, $'.$label).' 
  }

  '.($actual_ecode || 'return \@'.$label.'_collect').'
 ' if $isAND && $bcodes;

 $handlers{AND_SINGLE_ACODE} = ' 

 my @'.$label.'_collect;
 my $minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'});
 unless($minfo) {
  '.($actual_lxcode || 'return undef').'
 }
 
 unless($$minfo{index} == 0) {
  '.($actual_lxcode || 'return undef').'
 }

 my $LMATCH      = $$minfo{match};
 my @LMATCH_LIST = @{$$minfo{match_list} // []};
 my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
 my $LINDEX      = $$minfo{index};
 my $LSPOS       = pos $$STRING;
 
 '.$actual_lscode.'

 '.   $acodes     .'

 '.$actual_lecode.'
 
 return \@'.$label.'_collect;
 ' if $isAND && $acodes && scalar(@ACODEs) == 1;

 $handlers{AND_ACODE} = ' 

 my @'.$label.'_collect;
 my $idx = 0;
 
 while ($idx < '.scalar(@ACODEs).') {
  my $minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'});
  unless($minfo) {
   '.($actual_lxcode || 'return undef').'
  }
  
  # Only proceed if we match the expected index in sequence
  unless($$minfo{index} == $idx) {
   '.($actual_lxcode || 'return undef').'
  }

  my $LMATCH      = $$minfo{match};
  my @LMATCH_LIST = @{$$minfo{match_list} // []};
  my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
  my $LINDEX      = $$minfo{index};
  my $LSPOS       = pos $$STRING;
  
  '.$actual_lscode.'

  '.   $acodes     .'

  '.$actual_lecode.'
  
  $idx++;
 }
 
 return \@'.$label.'_collect;
 ' if $isAND && $acodes && scalar(@ACODEs) > 1;

 $handlers{OR_ACODE} = ' 

 my $minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'});
 unless($minfo) {
 '.($actual_lxcode || 'return undef').'
 }

 my $LMATCH      = $$minfo{match};
 my @LMATCH_LIST = @{$$minfo{match_list} // []};
 my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
 my $LINDEX      = $$minfo{index};
 my $LSPOS       = pos $$STRING;
 
 '.   $acodes .'
 ' if $isOR && $acodes;

 $handlers{OR_BCODE} = '

  my $'.$label.';
  foreach my $call (qw('."@BCALLs".')) {
   my $current_call = $call;

   '.$bcodes.'

   if ($'.$label.') {
    '.($actual_lxcode || 'return $'.$label).'
   }
  }

  '.($actual_ecode || 'return undef').'
 ' if $isOR && $bcodes;

  $handlers{REP_BCODE} = do {
  my $and_code = '

  my $'.$label.';
  my @'.$label.'_collect;
  foreach my $call (qw('."@BCALLs".')) {
   my $current_call = $call;

   '.$bcodes.'

   unless ($'.$label.') {
    '.($actual_lxcode || 'return undef').'
   }
   
   '.($actual_lecode || 'push @'.$label.'_collect, $'.$label).' 
  }

  return \@'.$label.'_collect
 ';



   '
   my $min='.$rep_nodes_minmax->{$node_type}[0].';
   my $max='.$rep_nodes_minmax->{$node_type}[1].';
   my $'.$label.';
   my @'.$label.'_collect;

   my $ccount = 0;
   my $and_code = sub {eval \''.$and_code.'\'};

   while(1) {
    my $and_ret = $and_code->();
    unless ($and_ret) {
     if ($ccount >= $min) {
      '.($actual_excode || 'return \@'.$label.'_collect').'
     } else {
      return undef
     }
    }

    ++$ccount;

    '.($actual_itcode || 'push @'.$label.'_collect, $and_ret;').'

    last unless $ccount < $max
   }

   '.($actual_ecode || 'return \@'.$label.'_collect').'
   '  
   } if ($isREP && $bcodes);
 
 $handlers{REP_ACODE} = '
 
   my $min='.$rep_nodes_minmax->{$node_type}[0].';
   my $max='.$rep_nodes_minmax->{$node_type}[1].';
   my @'.$label.'_collect;
   my $ccount = 0;

   while(1) {
    my $minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'});
    unless($minfo) {
     if ($ccount >= $min) {
      '.($actual_excode || 'return \@'.$label.'_collect').'
     } else {
      return undef
     }
    }

    my $LMATCH      = $$minfo{match};
    my @LMATCH_LIST = @{$$minfo{match_list} // []};
    my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
    my $LINDEX      = $$minfo{index};
    my $LSPOS       = pos $$STRING;
    
    '.$actual_lscode.'

    '.   $acodes     .'

    '.$actual_lecode.'
    
    ++$ccount;

    '.($actual_itcode || 'push @'.$label.'_collect, $'.$label.';').'

    last unless $ccount < $max
   }

   '.($actual_ecode || 'return \@'.$label.'_collect').'
 ' if ($isREP && $acodes);
 }

 if(@REs) {
  $info{re}      = [@REs];
 }

 # Updating the $handler variable with deterministic strategy selection
 my $selected_handler_variant = exists $handlers{$rule_meta->{handler_variant}} ? $rule_meta->{handler_variant}
                             : exists $handlers{_default} ? '_default'
                             : undef;
 $handler .= defined $selected_handler_variant ? ($handlers{$selected_handler_variant} || "") : "";
 $rule_meta->{selected_handler_variant} = $selected_handler_variant // '<none>';

 my $external_handler = $handler;
 $external_handler =~ s/&{\$\$descr{spec}{(\w+)}{handler}}/&{\$\$descr{spec}{$1}}/g;
 print "\n $label => sub {\n$external_handler\n },\n" if $pm_drive;

 $info{handler} = sub {eval $handler};
 #$info{acode}   = [@ACODEs];
 $info{gdata}   = [@GDATA];
 $info{meta}    = $rule_meta;

 # Dump individual rule info if in dump mode
 if (should_dump(DUMP_HIGH)) {
     log_dump("\n=== RULE INFO DUMP for $label ===\n");
     log_dump(Dumper(\%info));
     log_dump("=== END RULE INFO DUMP for $label ===\n");
     log_dump("=== HANDLER DUMP for $label ===\n");
     log_dump("{\n$handler\n}\n");
     log_dump("=== END HANDLER DUMP for $label ===\n");
 }

 return ($label, \%info)
}

#------------------------------------------------------------------------------
# Function: spec_gdata
# Purpose : Build compiled dispatch regex bundles (gdata) for each rule from
#           rule-to-rule gdata references collected during descriptor build.
# Args    : ($spec_hashref)
# Returns : hashref rule => compiled LinkedRE regex
#------------------------------------------------------------------------------
sub spec_gdata {
my $sg = shift;

 if (should_dump(DUMP_HIGH)) {
     log_dump("=== SPEC GDATA DUMP ===\n");
     log_dump(Dumper($sg));
     log_dump("=== END SPEC GDATA DUMP ===\n");
 }

 my $once=0;
 print ' gdata => {'."\n" if $pm_drive;

 my %gdata;
 foreach my $label (keys %$sg) {
  my @lgdata;
  foreach my $gde (@{$$sg{$label}{gdata}}) {
   if (exists $$sg{$$gde{label}}{re}[$$gde{idx}]) {
    push @lgdata, $$sg{$$gde{label}}{re}[$$gde{idx}]
   } else {
    my $error_msg = "Rule '$label': Referenced rule '$$gde{label}' has no regex at index $$gde{idx}";
    my $context = "Referenced rule: $$gde{label}, Requested index: $$gde{idx}, Available indices: " . 
                  (defined $$sg{$$gde{label}}{re} ? "0.." . ($#{$$sg{$$gde{label}}{re}}) : "none");
    log_output(DUMP_NONE, $error_msg, $context);
    print "  This usually means:\n";
    print "    1. Rule '$$gde{label}' doesn't exist in your .spec file\n";
    print "    2. Rule '$$gde{label}' has fewer regex patterns than expected\n";
    print "    3. There's a mismatch in regex indexing in your .spec file\n";
    if (should_dump(DUMP_HIGH)) {
        log_dump("=== GDATA ERROR CONTEXT ===\n");
        log_dump("label: $label\n");
        log_dump("gde: ".Dumper($gde)."\n");
        log_dump("sg: ".Dumper($sg)."\n");
        log_dump("lgdata: ".Dumper(\@lgdata)."\n");
        log_dump("=== END GDATA ERROR CONTEXT ===\n");
    }
    # exit 1
   }
  }

  if (@lgdata) {
   $gdata{$label} = LinkedRE::oredRE(@lgdata);

   print ''.($once ? ",\n" : "")." $label\t=> qr/$gdata{$label}/o" if $pm_drive;
   ++$once
  }

 }

 print "\n }\n};\n" if $pm_drive;
 
 my $result = \%gdata;
 
 # Dump generated gdata if in dump mode
 if (should_dump(DUMP_MEDIUM)) {
     log_dump("=== GENERATED GDATA DUMP ===\n");
     log_dump(Dumper($result));
     log_dump("=== END GENERATED GDATA DUMP ===\n");
 }
 
 return $result
}
#------------------------------------------------------------------------------
# Function: _find_unresolved_action_helpers
# Purpose : Detect helper forms that remain unresolved after rewrite/lowering
#           and report both counts and statement-level events.
# Args    : ($code, $rewrite_rules)
# Returns : hashref unresolved diagnostics payload
#------------------------------------------------------------------------------
sub _find_unresolved_action_helpers {
 my ($code, $rewrite_rules) = @_;

 my %hits;
 my $total = 0;
 my @events;
 my @statements = @{_split_action_ir_statements($code)};
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
# Function: _trim_action_ir_value
# Purpose : Shared whitespace normalization helper for action-IR payload text.
# Args    : ($value)
# Returns : trimmed scalar or undef
#------------------------------------------------------------------------------
sub _trim_action_ir_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}

#------------------------------------------------------------------------------
# Function: _split_declare_symbol_names
# Purpose : Parse and sanitize comma-separated declaration symbol names.
# Args    : ($raw_names)
# Returns : arrayref of symbol names
#------------------------------------------------------------------------------
sub _split_declare_symbol_names {
 my ($raw_names) = @_;
 return [] unless defined $raw_names;

 my @names = grep { length($_) } map {
  my $name = $_;
  $name =~ s/^\s*|\s*$//go;
  $name;
 } split /\s*,\s*/o, $raw_names;
 @names = grep { /^\w+$/o } @names;
 return \@names
}
#------------------------------------------------------------------------------
# Function: _parse_declare_binding_entry
# Purpose : Parse a single declare binding entry token (`name` or `name = expr`).
# Args    : ($entry)
# Returns : hashref { name => ..., init => ...? } or undef
#------------------------------------------------------------------------------
sub _parse_declare_binding_entry {
 my ($entry) = @_;
 return undef unless defined $entry;
 my $trimmed = _trim_action_ir_value($entry);
 return undef unless defined($trimmed) && length($trimmed);

 return {name => $1} if $trimmed =~ /^(?<name>\w+)$/o;
 if ($trimmed =~ /^(?<name>\w+)\s*=\s*(?<init>.+)$/s) {
  my $init = _trim_action_ir_value($+{init});
  return undef unless defined($init) && length($init);
  return {name => $+{name}, init => $init};
 }
 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_declare_value_expr
# Purpose : Lower a generic declare initializer value using the same expression
#           surfaces as flow/value helpers.
# Args    : ($expr)
# Returns : lowered Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_declare_value_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $lowered = _lower_flow_composite_expr($trimmed);
 return $lowered if defined($lowered) && length($lowered) && $lowered ne $trimmed;

 $lowered = _lower_method_value_expr($trimmed);
 return $lowered if defined($lowered) && length($lowered);

 return $trimmed
}

#------------------------------------------------------------------------------
# Function: _lower_declare_initializer_expr
# Purpose : Lower declare initializer payloads for scalar/array/hash declares.
# Args    : ($type, $expr)
# Returns : lowered Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_declare_initializer_expr {
 my ($type, $expr) = @_;
 return undef unless defined $type;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($type eq 'array') {
  my $array_ctor = _parse_method_function_expr($trimmed);
  if ($array_ctor && $array_ctor->{method} eq 'array') {
   my $items = $array_ctor->{args} || [];
   return undef unless ref($items) eq 'ARRAY';
   my @lowered_items = map { _lower_declare_value_expr($_) } @$items;
   return undef if grep { !defined($_) || !length($_) } @lowered_items;
   return '('.join(', ', @lowered_items).')';
  }
  if ($trimmed =~ /^\[(?<payload>.*)\]$/s) {
   return '('.$+{payload}.')';
  }
 }

 if ($type eq 'hash') {
  my $hash_ctor = _parse_method_function_expr($trimmed);
  if ($hash_ctor && $hash_ctor->{method} eq 'hash') {
   my $items = $hash_ctor->{args} || [];
   return undef unless ref($items) eq 'ARRAY';
   return undef unless @$items % 2 == 0;
   my @pairs;
   for (my $i = 0; $i < @$items; $i += 2) {
    my $key_expr = _lower_declare_value_expr($items->[$i]);
    my $val_expr = _lower_declare_value_expr($items->[$i + 1]);
    return undef unless defined($key_expr) && length($key_expr);
    return undef unless defined($val_expr) && length($val_expr);
    push @pairs, $key_expr.' => '.$val_expr;
   }
   return '('.join(', ', @pairs).')';
  }
  if ($trimmed =~ /^\{(?<payload>.*)\}$/s) {
   return '('.$+{payload}.')';
  }
 }

 return _lower_declare_value_expr($trimmed)
}

#------------------------------------------------------------------------------
# Function: _declare_sigil_for_type
# Purpose : Map canonical declaration type name to Perl declaration sigil.
# Args    : ($type)
# Returns : sigil scalar or undef
#------------------------------------------------------------------------------
sub _declare_sigil_for_type {
 my ($type) = @_;
 return '@' if defined($type) && $type eq 'array';
 return '$' if defined($type) && $type eq 'scalar';
 return '%' if defined($type) && $type eq 'hash';
 return undef
}

#------------------------------------------------------------------------------
# Function: _declare_alias_to_type
# Purpose : Resolve declaration alias tokens to canonical declaration type.
# Args    : ($alias)
# Returns : canonical type string or undef
#------------------------------------------------------------------------------
sub _declare_alias_to_type {
 my ($alias) = @_;
 return 'array'  if defined($alias) && ($alias eq 'a' || $alias eq 'array');
 return 'scalar' if defined($alias) && ($alias eq 's' || $alias eq 'scalar');
 return 'hash'   if defined($alias) && ($alias eq 'h' || $alias eq 'hash');
 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_typed_declare_statement
# Purpose : Lower typed declaration methods into canonical Perl declaration
#           statements (`my @x`, `my $y`, `my %z`).
# Args    : ($type, $entries_or_names)
# Returns : lowered statement string or undef
#------------------------------------------------------------------------------
sub _lower_typed_declare_statement {
 my ($type, $entries_or_names) = @_;
 my $sigil = _declare_sigil_for_type($type);
 return undef unless defined $sigil;
 my @entries;
 if (ref($entries_or_names) eq 'ARRAY') {
  @entries = @$entries_or_names;
 } else {
  my $names = _split_declare_symbol_names($entries_or_names);
  return undef unless $names && @$names;
  @entries = @$names;
 }
 return undef unless @entries;

 my @decls;
 foreach my $entry (@entries) {
  my $binding = _parse_declare_binding_entry($entry);
  return undef unless $binding && $binding->{name};

  my $decl = "my ${sigil}$binding->{name}";
  if (defined $binding->{init}) {
   my $init_expr = _lower_declare_initializer_expr($type, $binding->{init});
   return undef unless defined($init_expr) && length($init_expr);
   $decl .= " = $init_expr";
  }
  push @decls, $decl;
 }
 return join '; ', @decls
}

#------------------------------------------------------------------------------
# Function: _normalize_method_tag_expr
# Purpose : Normalize method tag atoms into Perl string expressions.
# Args    : ($tag)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _normalize_method_tag_expr {
 my ($tag) = @_;
 return undef unless defined $tag;
 $tag = _trim_action_ir_value($tag);
 return undef unless defined($tag) && length($tag);
 return $tag if $tag =~ /^".*"$/s || $tag =~ /^'.*'$/s;
 return "\"$tag\"" if $tag =~ /^\w+$/o;
 return $tag
}

#------------------------------------------------------------------------------
# Function: _extract_scalar_symbol_name
# Purpose : Resolve scalar variable symbol name from DSL method token surface.
# Args    : ($token)
# Returns : bare symbol name or undef
#------------------------------------------------------------------------------
sub _extract_scalar_symbol_name {
 my ($token) = @_;
 return undef unless defined $token;
 $token = _trim_action_ir_value($token);
 return undef unless defined($token) && length($token);
 return $1 if $token =~ /^scalar\s*\(\s*(\w+)\s*\)$/o;
 return $1 if $token =~ /^(\w+)$/o;
 return undef
}

#------------------------------------------------------------------------------
# Function: _extract_array_symbol_name
# Purpose : Resolve array variable symbol name from DSL method token surface.
# Args    : ($token)
# Returns : bare symbol name or undef
#------------------------------------------------------------------------------
sub _extract_array_symbol_name {
 my ($token) = @_;
 return undef unless defined $token;
 $token = _trim_action_ir_value($token);
 return undef unless defined($token) && length($token);
 return $1 if $token =~ /^array\s*\(\s*(\w+)\s*\)$/o;
 return $1 if $token =~ /^(\w+)$/o;
 return undef
}

#------------------------------------------------------------------------------
# Function: _extract_hash_symbol_name
# Purpose : Resolve hash variable symbol name from DSL method token surface.
# Args    : ($token)
# Returns : bare symbol name or undef
#------------------------------------------------------------------------------
sub _extract_hash_symbol_name {
 my ($token) = @_;
 return undef unless defined $token;
 $token = _trim_action_ir_value($token);
 return undef unless defined($token) && length($token);
 return $1 if $token =~ /^hash\s*\(\s*(\w+)\s*\)$/o;
 return $1 if $token =~ /^(\w+)$/o;
 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_scalar_access_key_expr
# Purpose : Lower scalar index/key expressions used for array/hash entry access.
# Args    : ($expr)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_scalar_access_key_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);
 return $trimmed if $trimmed =~ /^-?\d+(?:\.\d+)?$/o;
 return $trimmed if $trimmed =~ /^"(?:\\.|[^"])*"$/s || $trimmed =~ /^'(?:\\.|[^'])*'$/s;

 my $lowered = _lower_flow_composite_expr($trimmed);
 $lowered = _lower_method_value_expr($trimmed) unless defined($lowered) && length($lowered);
 $lowered = $trimmed unless defined($lowered) && length($lowered);

 return '$'.$lowered if $lowered =~ /^\w+$/o;
 return $lowered
}
#------------------------------------------------------------------------------
# Function: _split_scalaref_path_segments
# Purpose : Parse scalaref path payloads like `[A][B]{C}[D]` into ordered path
#           segments while preserving nested expression payloads.
# Args    : ($path_expr)
# Returns : arrayref of { kind => 'index'|'key', expr => ... } or undef
#------------------------------------------------------------------------------
sub _split_scalaref_path_segments {
 my ($path_expr) = @_;
 return undef unless defined $path_expr;
 my $path = _trim_action_ir_value($path_expr);
 return undef unless defined($path) && length($path);

 my @segments;
 my $len = length($path);
 my $idx = 0;
 while ($idx < $len) {
  while ($idx < $len && substr($path, $idx, 1) =~ /\s/o) {
   ++$idx;
  }
  last if $idx >= $len;

  my $open = substr($path, $idx, 1);
  return undef unless $open eq '[' || $open eq '{';
  my $close = $open eq '[' ? ']' : '}';
  ++$idx;

  my @stack = ($close);
  my $payload = '';
  my $in_single_quote = 0;
  my $in_double_quote = 0;
  my $escape_next = 0;
  while ($idx < $len && @stack) {
   my $char = substr($path, $idx, 1);
   if ($in_single_quote) {
    $payload .= $char;
    if ($escape_next) {
     $escape_next = 0;
    } elsif ($char eq '\\') {
     $escape_next = 1;
    } elsif ($char eq "'") {
     $in_single_quote = 0;
    }
    ++$idx;
    next;
   }
   if ($in_double_quote) {
    $payload .= $char;
    if ($escape_next) {
      $escape_next = 0;
    } elsif ($char eq '\\') {
      $escape_next = 1;
    } elsif ($char eq '"') {
      $in_double_quote = 0;
    }
    ++$idx;
    next;
   }
   if ($char eq "'") {
    $in_single_quote = 1;
    $payload .= $char;
    ++$idx;
    next;
   }
   if ($char eq '"') {
    $in_double_quote = 1;
    $payload .= $char;
    ++$idx;
    next;
   }
   if ($char eq '[') {
    push @stack, ']';
    $payload .= $char;
    ++$idx;
    next;
   }
   if ($char eq '{') {
    push @stack, '}';
    $payload .= $char;
    ++$idx;
    next;
   }
   if ($char eq ']' || $char eq '}') {
    my $expected = $stack[-1];
    return undef unless $char eq $expected;
    pop @stack;
    ++$idx;
    $payload .= $char if @stack;
    next;
   }
   $payload .= $char;
   ++$idx;
  }
  return undef if @stack;

  my $segment_expr = _trim_action_ir_value($payload);
  return undef unless defined($segment_expr) && length($segment_expr);
  push @segments, {
   kind => ($open eq '[' ? 'index' : 'key'),
   expr => $segment_expr,
  };
 }

 return undef unless @segments;
 return \@segments
}

#------------------------------------------------------------------------------
# Function: _lower_scalaref_segment_expr
# Purpose : Lower one scalaref path segment expression while preserving literal
#           bareword path atoms (e.g. `{A}` or `[B]`) when no lowering applies.
# Args    : ($segment_expr)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_scalaref_segment_expr {
 my ($segment_expr) = @_;
 return undef unless defined $segment_expr;
 my $trimmed = _trim_action_ir_value($segment_expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $lowered = _lower_flow_composite_expr($trimmed);
 return $lowered if defined($lowered) && length($lowered) && $lowered ne $trimmed;

 $lowered = _lower_method_value_expr($trimmed);
 return $lowered if defined($lowered) && length($lowered) && $lowered ne $trimmed;

 return $trimmed
}

#------------------------------------------------------------------------------
# Function: _lower_scalaref_value_expr
# Purpose : Lower `scalaref(base_ref, path)` helper into Perl dereference path
#           expression (e.g. `$ref->[A]->{B}`).
# Args    : ($base_expr, $path_expr)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_scalaref_value_expr {
 my ($base_expr, $path_expr) = @_;
 my $base_symbol = _extract_scalar_symbol_name($base_expr);
 return undef unless defined $base_symbol;

 my $segments = _split_scalaref_path_segments($path_expr);
 return undef unless $segments && @$segments;

 my $lowered = '$'.$base_symbol;
 foreach my $segment (@$segments) {
  my $segment_kind = $segment->{kind} // '';
  my $segment_expr = _lower_scalaref_segment_expr($segment->{expr});
  return undef unless defined($segment_expr) && length($segment_expr);

  if ($segment_kind eq 'index') {
   $lowered .= '->['.$segment_expr.']';
  } elsif ($segment_kind eq 'key') {
   $lowered .= '->{'.$segment_expr.'}';
  } else {
   return undef;
  }
 }
 return $lowered
}

#------------------------------------------------------------------------------
# Function: _infer_scalar_container_kind
# Purpose : Infer whether `scalar(container, key)` should resolve through array
#           index or hash key syntax when container kind is not explicit.
# Args    : ($container_symbol, $key_expr)
# Returns : 'array' or 'hash'
#------------------------------------------------------------------------------
sub _infer_scalar_container_kind {
 my ($container_symbol, $key_expr) = @_;
 return 'hash' if defined($container_symbol) && $container_symbol =~ /(hash|map|dict)/io;
 return 'array' if defined($container_symbol) && $container_symbol =~ /(arr|array|list|vec|vector)/io;

 my $key_trimmed = _trim_action_ir_value($key_expr // '');
 return 'hash' if defined($key_trimmed) && ($key_trimmed =~ /^"(?:\\.|[^"])*"$/s || $key_trimmed =~ /^'(?:\\.|[^'])*'$/s);
 return 'array' if defined($key_trimmed) && $key_trimmed =~ /^-?\d+(?:\.\d+)?$/o;
 return 'array'
}

#------------------------------------------------------------------------------
# Function: _lower_assignment_source_expr
# Purpose : Map assignment source tokens from method DSL to Perl expressions.
# Args    : ($source)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_assignment_source_expr {
 my ($source) = @_;
 return undef unless defined $source;
 $source = _trim_action_ir_value($source);
 return 'substr($$STRING, $IPOS, $LSPOS - $IPOS - length $LMATCH)' if $source eq 'CAPTURE';
 return '$IMATCH' if $source eq 'IMATCH';
 return '$LMATCH' if $source eq 'LMATCH';

 my $lowered = _lower_flow_composite_expr($source);
 return $lowered if defined($lowered) && length($lowered);

 $lowered = _lower_method_value_expr($source);
 return $lowered if defined($lowered) && length($lowered);

 return $source
}

#------------------------------------------------------------------------------
# Function: _strip_literal_delimiters
# Purpose : Strip outer literal delimiters for quoted/regex literal arguments.
# Args    : ($value)
# Returns : unwrapped scalar string or undef
#------------------------------------------------------------------------------
sub _strip_literal_delimiters {
 my ($value) = @_;
 return undef unless defined $value;
 $value = _trim_action_ir_value($value);
 return undef unless defined($value) && length($value);
 return '' if $value eq '//';
 return $1 if $value =~ m{^/(.*)/$}s;
 return $1 if $value =~ /^"(.*)"$/s;
 return $1 if $value =~ /^'(.*)'$/s;
 return $value
}

#------------------------------------------------------------------------------
# Function: _split_top_level_csv
# Purpose : Split comma-separated argument lists while honoring nested scopes
#           and quoted-string regions.
# Args    : ($text)
# Returns : arrayref of trimmed argument strings
#------------------------------------------------------------------------------
sub _split_top_level_csv {
 my ($text) = @_;
 return [] unless defined $text;

 my @parts;
 my $current = '';
 my $paren_depth = 0;
 my $brace_depth = 0;
 my $bracket_depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $in_slash_quote = 0;
 my $slash_escape_next = 0;
 my $escape_next = 0;

 foreach my $char (split //, $text) {
  if ($in_slash_quote) {
   $current .= $char;
   if ($slash_escape_next) {
    $slash_escape_next = 0;
   } elsif ($char eq '\\') {
    $slash_escape_next = 1;
   } elsif ($char eq '/') {
    $in_slash_quote = 0;
   }
   next;
  }
  if ($in_single_quote) {
   $current .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq "'") {
    $in_single_quote = 0;
   }
   next;
  }

  if ($in_double_quote) {
   $current .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq '"') {
    $in_double_quote = 0;
   }
   next;
  }

  if ($char eq "'") {
   $in_single_quote = 1;
   $current .= $char;
   next;
  }
  if ($char eq '"') {
   $in_double_quote = 1;
   $current .= $char;
   next;
  }
  if ($char eq '/') {
   my $current_context = $current;
   $current_context =~ s/\s+$//o;
   if (!length($current_context)) {
    $in_slash_quote = 1;
    $slash_escape_next = 0;
    $current .= $char;
    next;
   }
  }
  if ($char eq '(') {
   ++$paren_depth;
   $current .= $char;
   next;
  }
  if ($char eq ')') {
   --$paren_depth if $paren_depth > 0;
   $current .= $char;
   next;
  }
  if ($char eq '{') {
   ++$brace_depth;
   $current .= $char;
   next;
  }
  if ($char eq '}') {
   --$brace_depth if $brace_depth > 0;
   $current .= $char;
   next;
  }
  if ($char eq '[') {
   ++$bracket_depth;
   $current .= $char;
   next;
  }
  if ($char eq ']') {
   --$bracket_depth if $bracket_depth > 0;
   $current .= $char;
   next;
  }
  if ($char eq ',' && $paren_depth == 0 && $brace_depth == 0 && $bracket_depth == 0) {
   my $trimmed = _trim_action_ir_value($current);
   push @parts, $trimmed if defined($trimmed) && length($trimmed);
   $current = '';
   next;
  }
  $current .= $char;
 }

 my $trimmed = _trim_action_ir_value($current);
 push @parts, $trimmed if defined($trimmed) && length($trimmed);
 return \@parts
}

#------------------------------------------------------------------------------
# Function: _lower_method_value_expr
# Purpose : Lower method DSL value expressions (`scalar(...)`, `array(...)`)
#           into Perl value expressions.
# Args    : ($expr)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_method_value_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $method_call = _parse_method_function_expr($trimmed);
 if ($method_call && $method_call->{method} eq 'scalaref') {
  my $effective_args = _normalize_method_args_with_optional_scope($method_call->{args} || [], 2, 2);
  return undef unless $effective_args;
  return _lower_scalaref_value_expr($effective_args->[0], $effective_args->[1]);
 }
 if ($method_call && $method_call->{method} eq 'scalar') {
  my $scalar_args = $method_call->{args} || [];
  return undef unless ref($scalar_args) eq 'ARRAY';
  return undef unless @$scalar_args >= 1 && @$scalar_args <= 2;

  if (@$scalar_args == 1) {
   my $value = _trim_action_ir_value($scalar_args->[0]);
   return undef unless defined($value) && length($value);
   if ($value =~ /^(\w+)$/o) {
    return '$'.$1;
   }
   my $nested = _lower_method_value_expr($value);
   return $nested if defined($nested) && length($nested) && $nested ne $trimmed;
   return $value;
  }

  my ($container_expr, $key_expr) = @$scalar_args;
  my $container_trimmed = _trim_action_ir_value($container_expr);
  my $key_trimmed = _trim_action_ir_value($key_expr);
  return undef unless defined($container_trimmed) && length($container_trimmed);
  return undef unless defined($key_trimmed) && length($key_trimmed);

  if ($container_trimmed eq 'IMATCH_LIST' && $key_trimmed =~ /^\d+$/o) {
   return '$IMATCH_LIST['.$key_trimmed.']';
  }

  my ($explicit_array_symbol) = $container_trimmed =~ /^array\s*\(\s*(\w+)\s*\)$/o;
  my ($explicit_hash_symbol) = $container_trimmed =~ /^hash\s*\(\s*(\w+)\s*\)$/o;
  my $array_symbol = $explicit_array_symbol || _extract_array_symbol_name($container_trimmed);
  my $hash_symbol = $explicit_hash_symbol || _extract_hash_symbol_name($container_trimmed);
  my $key_lowered = _lower_scalar_access_key_expr($key_trimmed);
  return undef unless defined($key_lowered) && length($key_lowered);

  if (defined $explicit_array_symbol) {
   return '$'.$explicit_array_symbol.'['.$key_lowered.']';
  }
  if (defined $explicit_hash_symbol) {
   return '$'.$explicit_hash_symbol.'{'.$key_lowered.'}';
  }

  if (defined $array_symbol && defined $hash_symbol) {
   my $container_kind = _infer_scalar_container_kind($container_trimmed, $key_trimmed);
   return '$'.$array_symbol.'['.$key_lowered.']' if $container_kind eq 'array';
   return '$'.$hash_symbol.'{'.$key_lowered.'}';
  }
  if (defined $array_symbol) {
   return '$'.$array_symbol.'['.$key_lowered.']';
  }
  if (defined $hash_symbol) {
   return '$'.$hash_symbol.'{'.$key_lowered.'}';
  }
  return undef;
  return '$'.$1;
 }
 if ($trimmed =~ /^array\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))$/o) {
  my $payload = $+{PAREN};
  $payload =~ s/^\(|\)$//go;
  my $args = _split_top_level_csv($payload);
  my @lowered = map { _lower_method_value_expr($_) // $_ } @$args;
  return '['.join(', ', @lowered).']';
 }

 return $trimmed
}

#------------------------------------------------------------------------------
# Function: _lower_return_payload_expr
# Purpose : Lower generalized return payload expressions, preserving nested
#           `[]/{}` literals while lowering embedded scalar/array/hash helpers.
# Args    : ($expr)
# Returns : Perl payload expression string or undef
#------------------------------------------------------------------------------
sub _lower_return_payload_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $direct = _lower_method_value_expr($trimmed);
 if (
  defined($direct) &&
  length($direct) &&
  ($trimmed =~ /^(?:scalaref|scalar|array|hash)\s*\(/o || $direct ne $trimmed)
 ) {
  return $direct;
 }

 my $rewritten = $trimmed;
 for (1 .. 64) {
  my $before = $rewritten;
  $rewritten =~ s/\b(?<helper>(?:scalaref|scalar|array|hash)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/do {
   my $lowered = _lower_method_value_expr($+{helper});
   (defined($lowered) && length($lowered)) ? $lowered : $+{helper};
  }/ge;
  last if $rewritten eq $before;
 }
 return $rewritten
}

#------------------------------------------------------------------------------
# Function: _lower_return_general_statement
# Purpose : Lower generalized `return(payload)` helper form.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_general_statement {
 my ($expr) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'return';

 my $args = $call->{args} || [];
 return undef unless ref($args) eq 'ARRAY' && @$args == 1;
 my $payload = _lower_return_payload_expr($args->[0]);
 return undef unless defined($payload) && length($payload);
 return "return $payload"
}

#------------------------------------------------------------------------------
# Function: _lower_return_imatch_statement
# Purpose : Lower `return_imatch(...)`/`return_im(...)` method helper calls.
# Args    : ($tag)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_imatch_statement {
 my ($tag) = @_;
 my $tag_expr = _normalize_method_tag_expr($tag);
 return undef unless defined $tag_expr;
 return "return [$tag_expr, \$IMATCH]"
}

#------------------------------------------------------------------------------
# Function: _lower_assign_statement
# Purpose : Lower `assign(target, source)` method helper calls.
# Args    : ($target, $source)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_assign_statement {
 my ($target, $source) = @_;
 my $symbol = _extract_scalar_symbol_name($target);
 return undef unless defined $symbol;
 my $source_expr = _lower_assignment_source_expr($source);
 return undef unless defined $source_expr;
 return "\$$symbol = $source_expr"
}

#------------------------------------------------------------------------------
# Function: _lower_assign_method_statement
# Purpose : Lower full assign(...) helper expressions with optional scope token.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_assign_method_statement {
 my ($expr) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'assign';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 2, 2);
 return undef unless $effective_args;
 return _lower_assign_statement($effective_args->[0], $effective_args->[1])
}

#------------------------------------------------------------------------------
# Function: _extract_declare_statement_from_method_expr
# Purpose : Parse declare(...) / declare_* alias helper expressions and return
#           normalized declaration type + entry arguments.
# Args    : ($expr)
# Returns : hashref { declaration_type => ..., entries => [...] } or undef
#------------------------------------------------------------------------------
sub _extract_declare_statement_from_method_expr {
 my ($expr) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call;
 my $method = $call->{method} // '';

 if ($method eq 'declare') {
  my @effective_args = @{$call->{args} || []};
  if (
   @effective_args >= 3 &&
   _is_bare_method_scope_token($effective_args[0]) &&
   defined(_trim_action_ir_value($effective_args[1])) &&
   _trim_action_ir_value($effective_args[1]) =~ /^(array|scalar|hash)$/o
  ) {
   shift @effective_args;
  }

  return undef unless @effective_args >= 2;
  my $type = _trim_action_ir_value($effective_args[0]);
  return undef unless defined($type) && $type =~ /^(array|scalar|hash)$/o;
  my @entries = @effective_args[1 .. $#effective_args];
  return undef unless @entries;
  return {
   declaration_type => $type,
   entries          => \@entries,
  };
 }

 if ($method =~ /^declare_(?<alias>a|array|s|scalar|h|hash)$/o) {
  my $type = _declare_alias_to_type($+{alias});
  return undef unless defined $type;
  my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
  return undef unless $effective_args && @$effective_args >= 1;
  return {
   declaration_type => $type,
   entries          => [@$effective_args],
  };
 }

 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_declare_method_statement
# Purpose : Lower full declare(...) / declare_* alias helper expressions with
#           optional scope token and per-variable initialization entries.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_declare_method_statement {
 my ($expr) = @_;
 my $decl = _extract_declare_statement_from_method_expr($expr);
 return undef unless $decl;
 return _lower_typed_declare_statement($decl->{declaration_type}, $decl->{entries})
}

#------------------------------------------------------------------------------
# Function: _lower_regex_subst_statement
# Purpose : Lower regex substitution method helper calls for scalar targets.
# Args    : ($target, $pattern, $replacement, $flags)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_regex_subst_statement {
 my ($target, $pattern, $replacement, $flags) = @_;
 my $symbol = _extract_scalar_symbol_name($target);
 return undef unless defined $symbol;

 my $pattern_raw = _strip_literal_delimiters($pattern);
 my $replacement_raw = _strip_literal_delimiters($replacement);
 return undef unless defined($pattern_raw) && defined($replacement_raw);

 $flags = _trim_action_ir_value($flags // '');
 $flags = '' unless defined $flags;
 return "\$$symbol =~ s{$pattern_raw}{$replacement_raw}$flags"
}

#------------------------------------------------------------------------------
# Function: _normalize_split_delimiter_expr
# Purpose : Normalize split delimiter argument into a Perl regex expression.
# Args    : ($delimiter)
# Returns : Perl regex expression string or undef
#------------------------------------------------------------------------------
sub _normalize_split_delimiter_expr {
 my ($delimiter) = @_;
 $delimiter = _trim_action_ir_value($delimiter // '');
 return '/\s*,\s*/' unless defined($delimiter) && length($delimiter);
 return $delimiter if $delimiter =~ m{^/(?:\\.|[^/])*/[a-z]*$}io;

 my $literal = _strip_literal_delimiters($delimiter);
 return undef unless defined $literal;
 my $quoted = quotemeta($literal);
 return '/'.$quoted.'/'
}
#------------------------------------------------------------------------------
# Function: _parse_method_function_expr
# Purpose : Parse `method(arg1, arg2, ...)` expressions with nested-paren args.
# Args    : ($expr)
# Returns : hashref { method => ..., args => [...] } or undef
#------------------------------------------------------------------------------
sub _parse_method_function_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);
 return undef unless $trimmed =~ /^(?<method>\w+)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))$/o;
 my $method = $+{method};

 my $payload = $+{PAREN};
 $payload =~ s/^\(|\)$//go;
 return {
  method => $method,
  args   => _split_top_level_csv($payload),
 }
}

#------------------------------------------------------------------------------
# Function: _is_bare_method_scope_token
# Purpose : Check whether token is a bare scope label candidate.
# Args    : ($token)
# Returns : boolean
#------------------------------------------------------------------------------
sub _is_bare_method_scope_token {
 my ($token) = @_;
 return 0 unless defined $token;
 $token = _trim_action_ir_value($token);
 return defined($token) && $token =~ /^\w+$/o ? 1 : 0
}

#------------------------------------------------------------------------------
# Function: _normalize_method_args_with_optional_scope
# Purpose : Normalize method argument lists by stripping optional leading scope
#           token when present and validating min/max arity.
# Args    : ($args, $min_arity, $max_arity)
# Returns : arrayref effective args or undef
#------------------------------------------------------------------------------
sub _normalize_method_args_with_optional_scope {
 my ($args, $min_arity, $max_arity) = @_;
 return undef unless ref($args) eq 'ARRAY';

 $min_arity = 0 unless defined $min_arity;
 $max_arity = 10**9 unless defined $max_arity;

 my @effective = @$args;
 if (
  @effective >= ($min_arity + 1) &&
  @effective <= ($max_arity + 1) &&
  _is_bare_method_scope_token($effective[0])
 ) {
  my @without_scope = @effective;
  shift @without_scope;
  if (@without_scope >= $min_arity && @without_scope <= $max_arity) {
   @effective = @without_scope;
  }
 }

 return undef unless @effective >= $min_arity && @effective <= $max_arity;
 return \@effective
}

#------------------------------------------------------------------------------
# Function: _lower_control_flow_value_expr
# Purpose : Lower control-flow method argument values (`scalar(...)` etc.) into
#           Perl expression form while allowing raw expressions.
# Args    : ($expr)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_control_flow_value_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $lowered = _lower_flow_composite_expr($expr);
 return undef unless defined($lowered) && length($lowered);
 return $lowered
}

#------------------------------------------------------------------------------
# Function: _lower_switch_case_value_expr
# Purpose : Normalize switch-case match values into either `eq` or regex match
#           comparison payloads.
# Args    : ($expr)
# Returns : hashref { mode => 'eq'|'regex', expr => ... } or undef
#------------------------------------------------------------------------------
sub _lower_switch_case_value_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ m{^/(?:\\.|[^/])*/[a-z]*$}io) {
  return {mode => 'regex', expr => $trimmed}
 }
 my $lowered = _lower_flow_composite_expr($trimmed);
 return undef unless defined($lowered) && length($lowered);

 if ($trimmed =~ /^\w+$/o && $lowered eq $trimmed) {
  return {mode => 'eq', expr => _normalize_method_tag_expr($trimmed)}
 }
 return {mode => 'eq', expr => $lowered}
}

#------------------------------------------------------------------------------
# Function: _build_array_pipeline_plan_from_expr
# Purpose : Build recursive array-pipeline operation plan from composable
#           method expression forms like `filter_match(uniq(array(x)), /.../)`.
# Args    : ($expr)
# Returns : hashref { target_symbol => ..., ops => [...] } or undef
#------------------------------------------------------------------------------
sub _build_array_pipeline_plan_from_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $target_symbol = _extract_array_symbol_name($trimmed);
 return {target_symbol => $target_symbol, ops => []} if defined $target_symbol;

 my $call = _parse_method_function_expr($trimmed);
 return undef unless $call;
 my $method = $call->{method};
 my $args = $call->{args} || [];

 if ($method eq 'split') {
  my @effective_args = @$args;
  if ((@effective_args == 3 || @effective_args == 4) && _is_bare_method_scope_token($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1]);
   shift @effective_args if $scope_target_probe;
  }
  return undef unless @effective_args == 2 || @effective_args == 3;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0]);
  return undef unless $pipeline;

  my $source_symbol = _extract_scalar_symbol_name($effective_args[1]);
  return undef unless defined $source_symbol;
  my $delimiter_expr = _normalize_split_delimiter_expr($effective_args[2]);
  return undef unless defined $delimiter_expr;

  push @{$pipeline->{ops}}, {
   op             => 'split',
   source_symbol  => $source_symbol,
   delimiter_expr => $delimiter_expr,
  };
  return $pipeline
 }

 if ($method eq 'filter_match') {
  my @effective_args = @$args;
  if (@effective_args == 3 && _is_bare_method_scope_token($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1]);
   shift @effective_args if $scope_target_probe;
  }
  return undef unless @effective_args == 2;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0]);
  return undef unless $pipeline;

  my $pattern_expr = _normalize_split_delimiter_expr($effective_args[1]);
  return undef unless defined $pattern_expr;
  push @{$pipeline->{ops}}, {
   op           => 'filter_match',
   pattern_expr => $pattern_expr,
  };
  return $pipeline
 }

 if ($method =~ /^(trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq)$/o) {
  my @effective_args = @$args;
  if (@effective_args == 2 && _is_bare_method_scope_token($effective_args[0])) {
   my $scope_target_probe = _build_array_pipeline_plan_from_expr($effective_args[1]);
   shift @effective_args if $scope_target_probe;
  }
  return undef unless @effective_args == 1;

  my $pipeline = _build_array_pipeline_plan_from_expr($effective_args[0]);
  return undef unless $pipeline;
  push @{$pipeline->{ops}}, {op => $method};
  return $pipeline
 }

 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_array_pipeline_expr
# Purpose : Lower recursive composable array method expressions into ordered
#           Perl statements over a stable target array symbol.
# Args    : ($expr)
# Returns : lowered statement string or undef
#------------------------------------------------------------------------------
sub _lower_array_pipeline_expr {
 my ($expr) = @_;
 my $pipeline = _build_array_pipeline_plan_from_expr($expr);
 return undef unless $pipeline && $pipeline->{target_symbol};
 return undef unless @{$pipeline->{ops} || []};

 my $target_symbol = $pipeline->{target_symbol};
 my $list_expr = '@'.$target_symbol;
 foreach my $op (@{$pipeline->{ops}}) {
  my $name = $op->{op} // '';
  if ($name eq 'split') {
   $list_expr = 'split '.$op->{delimiter_expr}.', $'.$op->{source_symbol};
  } elsif ($name eq 'trim_each') {
   $list_expr = 'map { my $v = $_; $v =~ s/^\s+|\s+$//g; $v } '.$list_expr;
  } elsif ($name eq 'filter_nonempty') {
   $list_expr = 'grep { length($_) } '.$list_expr;
  } elsif ($name eq 'lowercase_each') {
   $list_expr = 'map { lc($_) } '.$list_expr;
  } elsif ($name eq 'uppercase_each') {
   $list_expr = 'map { uc($_) } '.$list_expr;
  } elsif ($name eq 'uniq') {
   $list_expr = 'do { my %seen; grep { !$seen{$_}++ } '.$list_expr.' }';
  } elsif ($name eq 'filter_match') {
   $list_expr = 'grep { $_ =~ '.$op->{pattern_expr}.' } '.$list_expr;
  } else {
   return undef;
  }
 }
 return '@'.$target_symbol.' = '.$list_expr
}

#------------------------------------------------------------------------------
# Function: _lower_if_flow_statement
# Purpose : Lower `if(...)`/`i(...)` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_if_flow_statement {
 my ($expr, $ctx) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && ($call->{method} eq 'if' || $call->{method} eq 'i');

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
 return undef unless $effective_args;
 my $cond_expr = _lower_control_flow_value_expr($effective_args->[0]);
 return undef unless defined($cond_expr) && length($cond_expr);

 $ctx->{if_stack} ||= [];
 push @{$ctx->{if_stack}}, {else_seen => 0};
 return "if ($cond_expr) {"
}

#------------------------------------------------------------------------------
# Function: _lower_elseif_flow_statement
# Purpose : Lower `elif(...)`/`elseif(...)` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_elseif_flow_statement {
 my ($expr, $ctx) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && ($call->{method} eq 'elif' || $call->{method} eq 'elseif');

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
 return undef unless $effective_args;
 my $cond_expr = _lower_control_flow_value_expr($effective_args->[0]);
 return undef unless defined($cond_expr) && length($cond_expr);

 my $if_stack = $ctx->{if_stack} || [];
 return undef unless @$if_stack;
 my $current_if = $if_stack->[-1];
 return undef if $current_if->{else_seen};

 return "} elsif ($cond_expr) {"
}

#------------------------------------------------------------------------------
# Function: _lower_else_flow_statement
# Purpose : Lower `else()` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_else_flow_statement {
 my ($expr, $ctx) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'else';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $if_stack = $ctx->{if_stack} || [];
 return undef unless @$if_stack;
 my $current_if = $if_stack->[-1];
 return undef if $current_if->{else_seen};
 $current_if->{else_seen} = 1;

 return '} else {'
}

#------------------------------------------------------------------------------
# Function: _lower_endif_flow_statement
# Purpose : Lower `endif()` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_endif_flow_statement {
 my ($expr, $ctx) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'endif';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $if_stack = $ctx->{if_stack} || [];
 return undef unless @$if_stack;
 pop @$if_stack;
 return '}'
}

#------------------------------------------------------------------------------
# Function: _lower_flow_branch_action_expr
# Purpose : Lower one branch action expression used in inline-composite switch
#           branch arguments (`case(..., action1, action2, ...)`).
# Args    : ($expr, $ctx)
# Returns : lowered Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_flow_branch_action_expr {
 my ($expr, $ctx) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $rules = $ctx->{rewrite_rules};
 return $trimmed unless $rules && ref($rules) eq 'ARRAY';

 foreach my $rule (@$rules) {
  my $sub_ctx = {
   if_stack       => [],
   switch_stack   => [],
   switch_counter => ($ctx->{switch_counter} || 0),
   rewrite_rules  => $ctx->{rewrite_rules},
  };
  my $lowered = $rule->{apply}->($trimmed, $sub_ctx);
  next unless defined($lowered) && length($lowered);
  next if $lowered eq $trimmed;
  next if @{$sub_ctx->{if_stack} || []};
  next if @{$sub_ctx->{switch_stack} || []};
  $ctx->{switch_counter} = $sub_ctx->{switch_counter} if defined $sub_ctx->{switch_counter};
  return $lowered;
 }

 return $trimmed
}

#------------------------------------------------------------------------------
# Function: _lower_inline_switch_branch_expr
# Purpose : Lower a single inline switch branch expression (`case(...)` or
#           `default(...)`) in composite switch syntax.
# Args    : ($branch_expr, $switch_var, $hit_var, $ctx, $switch_state)
# Returns : Perl clause string or undef
#------------------------------------------------------------------------------
sub _lower_inline_switch_branch_expr {
 my ($branch_expr, $switch_var, $hit_var, $ctx, $switch_state) = @_;
 my $branch_call = _parse_method_function_expr($branch_expr);
 return undef unless $branch_call;
 my $method = $branch_call->{method} // '';

 if ($method eq 'case') {
  my $effective_args = _normalize_method_args_with_optional_scope($branch_call->{args} || [], 1, undef);
  return undef unless $effective_args && @$effective_args >= 1;
  return undef if $switch_state->{default_seen};

  my $case_value = _lower_switch_case_value_expr($effective_args->[0]);
  return undef unless $case_value && defined($case_value->{expr});
  my $match_expr = $case_value->{mode} eq 'regex'
   ? "\$$switch_var =~ $case_value->{expr}"
   : "\$$switch_var eq $case_value->{expr}";

  my @actions;
  foreach my $action_expr (@$effective_args[1 .. $#$effective_args]) {
   my $lowered_action = _lower_flow_branch_action_expr($action_expr, $ctx);
   return undef unless defined($lowered_action) && length($lowered_action);
   push @actions, $lowered_action;
  }
  my $body = @actions ? '; '.join('; ', @actions) : '';
  return "if (!\$$hit_var && $match_expr) { \$$hit_var = 1$body }";
 }

 if ($method eq 'default') {
  my $effective_args = _normalize_method_args_with_optional_scope($branch_call->{args} || [], 0, undef);
  return undef unless $effective_args;
  return undef if $switch_state->{default_seen};
  $switch_state->{default_seen} = 1;

  my @actions;
  foreach my $action_expr (@$effective_args) {
   my $lowered_action = _lower_flow_branch_action_expr($action_expr, $ctx);
   return undef unless defined($lowered_action) && length($lowered_action);
   push @actions, $lowered_action;
  }
  my $body = @actions ? '; '.join('; ', @actions) : '';
  return "if (!\$$hit_var) { \$$hit_var = 1$body }";
 }

 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_switch_flow_statement
# Purpose : Lower `switch(...)` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_switch_flow_statement {
 my ($expr, $ctx) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'switch';
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
 return undef unless $effective_args && @$effective_args >= 1;
 return undef unless $effective_args;
 my $switch_expr = _lower_control_flow_value_expr($effective_args->[0]);
 return undef unless defined($switch_expr) && length($switch_expr);

 $ctx->{switch_stack} ||= [];
 $ctx->{switch_counter} = ($ctx->{switch_counter} || 0) + 1;
 my $suffix = $ctx->{switch_counter};
 my $switch_var = "__ls_switch_value_$suffix";
 my $hit_var = "__ls_switch_hit_$suffix";
 my $switch_state = {
  switch_var   => $switch_var,
  hit_var      => $hit_var,
  open_case    => 0,
  default_seen => 0,
 };

 if (@$effective_args > 1) {
  my @clauses;
  foreach my $branch_expr (@$effective_args[1 .. $#$effective_args]) {
   my $clause = _lower_inline_switch_branch_expr($branch_expr, $switch_var, $hit_var, $ctx, $switch_state);
   return undef unless defined($clause) && length($clause);
   push @clauses, $clause;
  }
  my $body = @clauses ? '; '.join('; ', @clauses) : '';
  return "do { my \$$switch_var = $switch_expr; my \$$hit_var = 0$body }";
 }

 $ctx->{switch_stack} ||= [];
 push @{$ctx->{switch_stack}}, $switch_state;

 return "do { my \$$switch_var = $switch_expr; my \$$hit_var = 0"
}

#------------------------------------------------------------------------------
# Function: _lower_case_flow_statement
# Purpose : Lower `case(...)` fluent switch-branch markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_case_flow_statement {
 my ($expr, $ctx) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'case';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
 return undef unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return undef unless @$switch_stack;
 my $switch_state = $switch_stack->[-1];
 return undef if $switch_state->{default_seen};

 my $case_value = _lower_switch_case_value_expr($effective_args->[0]);
 return undef unless $case_value && defined($case_value->{expr});
 my $switch_var = $switch_state->{switch_var};
 my $hit_var = $switch_state->{hit_var};
 my $match_expr = $case_value->{mode} eq 'regex'
  ? "\$$switch_var =~ $case_value->{expr}"
  : "\$$switch_var eq $case_value->{expr}";

 my $prefix = '';
 if ($switch_state->{open_case}) {
  $prefix = '} ';
 }
 $switch_state->{open_case} = 1;

 return $prefix."if (!\$$hit_var && $match_expr) { \$$hit_var = 1"
}

#------------------------------------------------------------------------------
# Function: _lower_default_flow_statement
# Purpose : Lower `default()` fluent switch default-branch markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_default_flow_statement {
 my ($expr, $ctx) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'default';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return undef unless @$switch_stack;
 my $switch_state = $switch_stack->[-1];
 return undef if $switch_state->{default_seen};

 my $prefix = '';
 if ($switch_state->{open_case}) {
  $prefix = '} ';
 }
 $switch_state->{open_case} = 1;
 $switch_state->{default_seen} = 1;

 my $hit_var = $switch_state->{hit_var};
 return $prefix."if (!\$$hit_var) { \$$hit_var = 1"
}

#------------------------------------------------------------------------------
# Function: _lower_endcase_flow_statement
# Purpose : Lower explicit `endcase()` markers (optional in fluent switch).
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_endcase_flow_statement {
 my ($expr, $ctx) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'endcase';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return undef unless @$switch_stack;
 my $switch_state = $switch_stack->[-1];
 return undef unless $switch_state->{open_case};
 $switch_state->{open_case} = 0;
 return '}'
}

#------------------------------------------------------------------------------
# Function: _lower_endswitch_flow_statement
# Purpose : Lower `endswitch()` fluent switch terminator markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_endswitch_flow_statement {
 my ($expr, $ctx) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'endswitch';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return undef unless @$switch_stack;
 my $switch_state = pop @$switch_stack;
 my $prefix = $switch_state->{open_case} ? '} ' : '';
 return $prefix.'}'
}

#------------------------------------------------------------------------------
# Function: _lower_say_statement
# Purpose : Lower `say(...)` fluent output helper calls.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_say_statement {
 my ($expr) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'say';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
 return undef unless $effective_args && @$effective_args;
 my @values = map { _lower_control_flow_value_expr($_) } @$effective_args;
 return undef unless @values && !grep { !defined($_) || !length($_) } @values;
 return 'say '.join(', ', @values)
}

#------------------------------------------------------------------------------
# Function: _lower_print_statement
# Purpose : Lower `print(...)` fluent output helper calls.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_print_statement {
 my ($expr) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'print';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
 return undef unless $effective_args && @$effective_args;
 my @values = map { _lower_control_flow_value_expr($_) } @$effective_args;
 return undef unless @values && !grep { !defined($_) || !length($_) } @values;
 return 'print '.join(', ', @values)
}

#------------------------------------------------------------------------------
# Function: _lower_return_undef_statement
# Purpose : Lower `return_undef()` fluent helper calls.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_undef_statement {
 my ($expr) = @_;
 my $call = _parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'return_undef';

 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 return undef unless $effective_args;
 return 'return undef'
}

#------------------------------------------------------------------------------
# Function: _lower_split_statement
# Purpose : Lower `split(...)` method helper into array-assignment form.
# Args    : ($target, $source, $delimiter)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_split_statement {
 my ($target, $source, $delimiter) = @_;
 my $expr = 'split('.$target.', '.$source;
 $expr .= ', '.$delimiter if defined($delimiter) && length($delimiter);
 $expr .= ')';
 return _lower_array_pipeline_expr($expr)
}

#------------------------------------------------------------------------------
# Function: _lower_trim_each_statement
# Purpose : Lower `trim_each(...)` method helper into array map-trim form.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_trim_each_statement {
 my ($target) = @_;
 return _lower_array_pipeline_expr('trim_each('.$target.')')
}

#------------------------------------------------------------------------------
# Function: _lower_filter_nonempty_statement
# Purpose : Lower `filter_nonempty(...)` method helper into array grep form.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_filter_nonempty_statement {
 my ($target) = @_;
 return _lower_array_pipeline_expr('filter_nonempty('.$target.')')
}

#------------------------------------------------------------------------------
# Function: _lower_lowercase_each_statement
# Purpose : Lower `lowercase_each(...)` helper into array map lowercase form.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_lowercase_each_statement {
 my ($target) = @_;
 return _lower_array_pipeline_expr('lowercase_each('.$target.')')
}

#------------------------------------------------------------------------------
# Function: _lower_uppercase_each_statement
# Purpose : Lower `uppercase_each(...)` helper into array map uppercase form.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_uppercase_each_statement {
 my ($target) = @_;
 return _lower_array_pipeline_expr('uppercase_each('.$target.')')
}

#------------------------------------------------------------------------------
# Function: _lower_uniq_statement
# Purpose : Lower `uniq(...)` helper into stable unique-filter assignment.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_uniq_statement {
 my ($target) = @_;
 return _lower_array_pipeline_expr('uniq('.$target.')')
}

#------------------------------------------------------------------------------
# Function: _lower_filter_match_statement
# Purpose : Lower `filter_match(...)` helper into regex grep assignment.
# Args    : ($target, $pattern)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_filter_match_statement {
 my ($target, $pattern) = @_;
 return _lower_array_pipeline_expr('filter_match('.$target.', '.$pattern.')')
}

#------------------------------------------------------------------------------
# Function: _lower_return_array_statement
# Purpose : Lower `return_array(tag, payload)` method helper calls.
# Args    : ($tag, $payload)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_array_statement {
 my ($tag, $payload) = @_;
 my $tag_expr = _normalize_method_tag_expr($tag);
 return undef unless defined $tag_expr;
 my $payload_expr = _lower_method_value_expr($payload);
 return undef unless defined $payload_expr;
 return "return [$tag_expr, $payload_expr]"
}

#------------------------------------------------------------------------------
# Function: _scan_contract_ir_events
# Purpose : Contract-specific scanner that extracts helper invocation events
#           and parsed arguments from raw action code.
# Args    : ($contract, $code)
# Returns : arrayref of event hashes
#------------------------------------------------------------------------------
sub _scan_contract_ir_events {
 my ($contract, $code) = @_;
 my $id = $contract->{id} // '';

 my @events;
 if ($id eq 'assign_call_my') {
  while ($code =~ /\bmy\s+(?<target>\$\w+)\s*=\s*call\s*\(\s*(?<callee>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}, scope => 'my'}};
  }
 } elsif ($id eq 'assign_call') {
  while ($code =~ /(?<!\bmy\s)(?<target>\$\w+)\s*=\s*call\s*\(\s*(?<callee>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}, scope => 'existing'}};
  }
 } elsif ($id eq 'push_call_indexed_builtin') {
  while ($code =~ /\bpush\s+\@(?<target>\w+)\s*,\s*call\s*\(\s*(?<callee>\w+)\s*\)\s*->\s*\[\s*(?<index>\d+)\s*\]/g) {
   push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}, index => $+{index}}};
  }
 } elsif ($id eq 'push_call_builtin') {
  while ($code =~ /\bpush\s+\@(?<target>\w+)\s*,\s*call\s*\(\s*(?<callee>\w+)\s*\)(?!\s*->\s*\[)/g) {
   push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}}};
  }
 } elsif ($id eq 'return_call') {
  while ($code =~ /\breturn\s+call\s*\(\s*(?<callee>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {callee => $+{callee}, context => 'return'}};
  }
 } elsif ($id eq 'return_bare') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^return(?:\s+.+)?$/o;
   next if $trimmed =~ /^return\s*\(/o;
   next if $trimmed =~ /^return_/o;
   next if $trimmed =~ /^return\s+call\s*\(/o;
   my $payload = $trimmed;
   $payload =~ s/^return//o;
   $payload = _trim_action_ir_value($payload // '');
   push @events, {raw => $trimmed, args => {payload => $payload}};
  }
 } elsif ($id eq 'exit_bare') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^exit(?:\b|(?=\())/o;
   my $payload = $trimmed;
   $payload =~ s/^exit//o;
   $payload = _trim_action_ir_value($payload // '');
   push @events, {raw => $trimmed, args => {payload => $payload}};
  }
 } elsif ($id eq 'linecount_prefix_newline_matches') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^my\s+\@(?<target>\w+)\s*=\s*substr\(\s*\$\$STRING\s*,\s*0\s*,\s*(?<upto>(?:[^()]++|(?<P>\((?:[^()]++|(?&P))*\)))+)\)\s*=~\s*\/\\n\/g$/o;
   push @events, {raw => $trimmed, args => {target => $+{target}, upto => _trim_action_ir_value($+{upto})}};
  }
 } elsif ($id eq 'print_capture_substr') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^print\s*"<"\s*\.\s*substr\(\s*\$\$STRING\s*,\s*\$IPOS\s*,\s*\$LSPOS\s*-\s*\$IPOS\s*-\s*1\s*\)\s*\.\s*">\\n"\s*$/o;
   push @events, {raw => $trimmed, args => {source => 'capture_substr'}};
  }
 } elsif ($id eq 'my_declare_bare') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^my\s+(?<sigil>[\$\@\%])(?<name>\w+)$/o;
   my $declaration_type = $+{sigil} eq '$' ? 'scalar' : $+{sigil} eq '@' ? 'array' : 'hash';
   push @events, {raw => $trimmed, args => {declaration_type => $declaration_type, names => [$+{name}], scope => 'my'}};
  }
 } elsif ($id eq 'assign_match_my') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^my\s+\$(?<target>\w+)\s*=\s*\$(?<source>CAPTURE|IMATCH|LMATCH)$/o;
   push @events, {raw => $trimmed, args => {target => $+{target}, source => $+{source}, scope => 'my'}};
  }
 } elsif ($id eq 'destructure_imatch_list_my') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^my\s*\((?<targets>[^()]+)\)\s*=\s*\@IMATCH_LIST$/o;
   my @targets = grep { defined($_) && length($_) } map { _trim_action_ir_value($_) } split /\s*,\s*/o, $+{targets};
   next unless @targets;
   next if grep { $_ !~ /^\$\w+$/o } @targets;
   push @events, {
    raw  => $trimmed,
    args => {
     targets => [map { my $name = $_; $name =~ s/^\$//o; $name } @targets],
     source  => 'IMATCH_LIST',
     scope   => 'my',
    },
   };
  }
 } elsif ($id eq 'regex_subst_assignment') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^\$(?<target>\w+)\s*=~\s*s\/(?<pattern>(?:\\.|[^\/])*)\/(?<replacement>(?:\\.|[^\/])*)\/(?<flags>[a-z]*)$/o;
   push @events, {raw => $trimmed, args => {target => $+{target}, pattern => '/'.$+{pattern}.'/', replacement => '/'.$+{replacement}.'/', flags => ($+{flags} // ''), scope => undef}};
  }
 } elsif ($id eq 'next_bare') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^next(?:\s+\w+)?$/o;
   push @events, {raw => $trimmed, args => {}};
  }
 } elsif ($id eq 'ref_field_assign') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^(?<decl>my\s+)?\$(?<target>\w+)\s*=\s*\$(?<source>\w+)\s*->\s*(?<path>(?:\{[^{}]+\}|\[[^\[\]]+\])(?:\s*(?:\{[^{}]+\}|\[[^\[\]]+\]))*)$/o;
   push @events, {raw => $trimmed, args => {target => $+{target}, source => $+{source}, path => _trim_action_ir_value($+{path}), scope => ($+{decl} ? 'my' : 'existing')}};
  }
 } elsif ($id eq 'position_tracking') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless (
    $trimmed =~ /^\$\w+\s*=\s*pos(?:\s*\(\s*\$\$STRING\s*\)|\s+\$\$STRING)\s*$/o ||
    $trimmed =~ /^my\s+\$\w+\s*=\s*\$IPOS\s*$/o ||
    $trimmed =~ /^my\s+\$shift\s*=\s*\$LSPOS\s*-\s*\$last_pos\s*-\s*length(?:\s*\(\s*\$LMATCH\s*\)|\s+\$LMATCH)\s*$/o ||
    $trimmed =~ /^push\s+\@\w+\s*,\s*substr\(\s*\$\$STRING\s*,\s*\$last_pos\s*,\s*\$shift\s*\)\s*if\s*\$shift\s*$/o ||
    $trimmed =~ /^push\s+\@\w+\s*,\s*\{[^{}]*substr\(\s*\$\$STRING\s*,\s*\$last_pos\s*,\s*\$shift\s*\)[^{}]*\}\s*if\s*\$shift\s*$/o
   );
   push @events, {raw => $trimmed, args => {category => 'position_tracking'}};
  }
 } elsif ($id eq 'print_foreach_iterable') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^print\s+.+\s+foreach\s*\(\s*\@(?<iterable>\w+)\s*\)$/s;
   push @events, {raw => $trimmed, args => {iterable => $+{iterable}}};
  }
 } elsif ($id eq 'split_trim_filter_assignment') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^my\s+\@(?<target>\w+)\s*=\s*grep\s*\{\s*length\(\$_\)\s*\}\s*map\s*\{\s*my\s+\$v\s*=\s*\$_\s*;\s*\$v\s*=~\s*s\/(?:\\.|[^\/])*\/(?:\\.|[^\/])*\/[a-z]*\s*;\s*\$v\s*\}\s*split\s*(?<delimiter>\/(?:\\.|[^\/])*\/[a-z]*)\s*,\s*\$(?<source>\w+)$/o;
   push @events, {
    raw  => $trimmed,
    args => {
     target    => $+{target},
     source    => $+{source},
     delimiter => $+{delimiter},
     transforms => ['split', 'trim_each', 'filter_nonempty'],
     scope     => 'my',
    },
   };
  }
 } elsif ($id eq 'return_imatch') {
  while ($code =~ /\breturn_im(?:atch)?\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<tag>(?:'[^']*'|"[^"]*"|\w+))\s*\)/g) {
   push @events, {raw => $&, args => {scope => $+{scope}, tag => $+{tag}}};
  }
 } elsif ($id eq 'assign_value') {
  while ($code =~ /\b(?<expr>assign\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call && $call->{method} eq 'assign';
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 2, 2);
   next unless $effective_args;
   push @events, {
    raw => $+{expr},
    args => {
     target => _trim_action_ir_value($effective_args->[0]),
     source => _trim_action_ir_value($effective_args->[1]),
    },
   };
  }
 } elsif ($id eq 'regex_subst') {
  while ($code =~ /\b(?:substr|regex_subst)\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<target>(?:scalar\s*\(\s*\w+\s*\)|\w+))\s*,\s*(?<pattern>(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\/(?:\\.|[^\/])*\/))\s*,\s*(?<replacement>(?:"(?:\\.|[^"])*"|'(?:\\.|[^'])*'|\/\/|\/(?:\\.|[^\/])*\/))\s*,\s*(?<flags>\w*)\s*\)/g) {
   push @events, {raw => $&, args => {scope => $+{scope}, target => $+{target}, pattern => $+{pattern}, replacement => $+{replacement}, flags => $+{flags}}};
  }
 } elsif ($id eq 'split_array') {
  while ($code =~ /\b(?<expr>split\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'split';
   push @events, {
    raw => $+{expr},
    args => {
     target    => $pipeline->{target_symbol},
     source    => $last_op->{source_symbol},
     delimiter => $last_op->{delimiter_expr},
    },
   };
  }
 } elsif ($id eq 'trim_each') {
  while ($code =~ /\b(?<expr>trim_each\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'trim_each';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'filter_nonempty') {
  while ($code =~ /\b(?<expr>filter_nonempty\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'filter_nonempty';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'lowercase_each') {
  while ($code =~ /\b(?<expr>lowercase_each\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'lowercase_each';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'uppercase_each') {
  while ($code =~ /\b(?<expr>uppercase_each\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'uppercase_each';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'uniq_array') {
  while ($code =~ /\b(?<expr>uniq\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'uniq';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'filter_match') {
  while ($code =~ /\b(?<expr>filter_match\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'filter_match';
   push @events, {
    raw => $+{expr},
    args => {
     target  => $pipeline->{target_symbol},
     pattern => $last_op->{pattern_expr},
    },
   };
  }
 } elsif ($id eq 'if_flow') {
  while ($code =~ /\b(?<expr>(?:if|i)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))(?!\s*\{))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {condition => _trim_action_ir_value($effective_args->[0])}};
  }
 } elsif ($id eq 'elseif_flow') {
  while ($code =~ /\b(?<expr>(?:elif|elseif)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))(?!\s*\{))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {condition => _trim_action_ir_value($effective_args->[0])}};
  }
 } elsif ($id eq 'else_flow') {
  while ($code =~ /\b(?<expr>else\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'endif_flow') {
  while ($code =~ /\b(?<expr>endif\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'switch_flow') {
  while ($code =~ /\b(?<expr>switch\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
   next unless $effective_args && @$effective_args >= 1;
   push @events, {raw => $+{expr}, args => {expr => _trim_action_ir_value($effective_args->[0])}};
  }
 } elsif ($id eq 'case_flow') {
  while ($code =~ /\b(?<expr>case\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {value => _trim_action_ir_value($effective_args->[0])}};
  }
 } elsif ($id eq 'default_flow') {
  while ($code =~ /\b(?<expr>default\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'endcase_flow') {
  while ($code =~ /\b(?<expr>endcase\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'endswitch_flow') {
  while ($code =~ /\b(?<expr>endswitch\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'say_stmt') {
  while ($code =~ /\b(?<expr>say\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
   next unless $effective_args && @$effective_args;
   push @events, {raw => $+{expr}, args => {values => [map { _trim_action_ir_value($_) } @$effective_args]}};
  }
 } elsif ($id eq 'print_stmt') {
  while ($code =~ /\b(?<expr>print\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
   next unless $effective_args && @$effective_args;
   push @events, {raw => $+{expr}, args => {values => [map { _trim_action_ir_value($_) } @$effective_args]}};
  }
 } elsif ($id eq 'return_undef') {
  while ($code =~ /\b(?<expr>return_undef\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {value => 'undef'}};
  }
 } elsif ($id eq 'return_array') {
  while ($code =~ /\breturn_array\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<tag>(?:'[^']*'|"[^"]*"|\w+))\s*,\s*(?<payload>(?:[^()]++|(?<P>\((?:[^()]++|(?&P))*\)))+)\s*\)/g) {
   push @events, {raw => $&, args => {scope => $+{scope}, tag => $+{tag}, payload => _trim_action_ir_value($+{payload})}};
  }
 } elsif ($id eq 'declare_typed') {
  while ($code =~ /\b(?<expr>declare\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $decl = _extract_declare_statement_from_method_expr($+{expr});
   next unless $decl;
   my @parsed_entries = map { _parse_declare_binding_entry($_) } @{$decl->{entries} || []};
   next if grep { !defined($_) || !defined($_->{name}) } @parsed_entries;
   my @names = map { $_->{name} } @parsed_entries;
   my %initializers = map { defined($_->{init}) ? ($_->{name} => $_->{init}) : () } @parsed_entries;
   push @events, {
    raw => $+{expr},
    args => {
     declaration_type => $decl->{declaration_type},
     names            => [@names],
     initializers     => {%initializers},
    },
   };
  }
 } elsif ($id eq 'declare_alias') {
  while ($code =~ /\b(?<expr>declare_(?:a|array|s|scalar|h|hash)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $decl = _extract_declare_statement_from_method_expr($+{expr});
   next unless $decl;
   my @parsed_entries = map { _parse_declare_binding_entry($_) } @{$decl->{entries} || []};
   next if grep { !defined($_) || !defined($_->{name}) } @parsed_entries;
   my @names = map { $_->{name} } @parsed_entries;
   my %initializers = map { defined($_->{init}) ? ($_->{name} => $_->{init}) : () } @parsed_entries;
   push @events, {
    raw => $+{expr},
    args => {
     declaration_type => $decl->{declaration_type},
     names            => [@names],
     initializers     => {%initializers},
    },
   };
  }
 } elsif ($id eq 'call') {
  while ($code =~ /\bcall\s*\(\s*(?<callee>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {callee => $+{callee}}};
  }
 } elsif ($id eq 'push_single_arg') {
  while ($code =~ /\bpush\s*\(\s*(?<source>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {source => $+{source}}};
  }
 } elsif ($id eq 'push_target_arg') {
  while ($code =~ /\bpush\s*\(\s*(?<source>\w+)\s*,\s*(?<target>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {source => $+{source}, target => $+{target}}};
  }
 } elsif ($id eq 'push_scope_target_arg') {
  while ($code =~ /\bpush\s*\(\s*(?<scope>\w+)\s*,\s*(?<source>\w+)\s*,\s*(?<target>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {scope => $+{scope}, source => $+{source}, target => $+{target}}};
  }
 } elsif ($id eq 'return_a') {
  while ($code =~ /\breturn_a\s*\(\s*(?<label>\w+)(?:\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+))?\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}, arg => _trim_action_ir_value($+{arg})}};
  }
 } elsif ($id eq 'return_general') {
  while ($code =~ /\b(?<expr>return\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call && $call->{method} eq 'return';
   my $args = $call->{args} || [];
   next unless ref($args) eq 'ARRAY' && @$args == 1;
   push @events, {raw => $+{expr}, args => {payload => _trim_action_ir_value($args->[0])}};
  }
 } elsif ($id eq 'return') {
  while ($code =~ /\breturn\s*\(\s*(?<label>\w+)\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}, arg => _trim_action_ir_value($+{arg})}};
  }
 } elsif ($id eq 'return_ma') {
  while ($code =~ /\breturn_ma\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'return_m') {
  while ($code =~ /\breturn_m\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'capture_macro') {
  while ($code =~ /\$CAPTURE\b/g) {
   push @events, {raw => $&, args => {}};
  }
 } elsif ($id eq 'capture') {
  while ($code =~ /\bcapture\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'capture_if') {
  while ($code =~ /\bcapture_if\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'capture_if_macro') {
  while ($code =~ /\bCAPTURE_IF\s*\(\s*\)/g) {
   push @events, {raw => $&, args => {}};
  }
 } elsif ($id eq 'ibacktrack_macro') {
  while ($code =~ /\bIBACKTRACK\s*\(\s*\)/g) {
   push @events, {raw => $&, args => {}};
  }
 } elsif ($id eq 'backtrack_macro') {
  while ($code =~ /\bBACKTRACK\s*\(\s*\)/g) {
   push @events, {raw => $&, args => {}};
  }
 } elsif ($id eq 'ibacktrack') {
  while ($code =~ /\bibacktrack\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'backtrack') {
  while ($code =~ /\bbacktrack\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 }

 return \@events
}

#------------------------------------------------------------------------------
# Function: _collect_action_helper_ir_nodes
# Purpose : Aggregate helper-action IR hits/events across all rewrite contracts
#           before lowering is applied.
# Args    : ($code, $rewrite_rules)
# Returns : hashref helper-action IR diagnostics
#------------------------------------------------------------------------------
sub _collect_action_helper_ir_nodes {
 my ($code, $rewrite_rules) = @_;

 my %hits;
 my $total = 0;
 my @events;
 foreach my $rule (@$rewrite_rules) {
  my $ir_node = $rule->{ir_node} // $rule->{id};
  my $rule_events = _scan_contract_ir_events($rule, $code);
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
# Function: _canonicalize_helper_action_ir_event
# Purpose : Convert contract-level helper event identity into canonical IR
#           event kind + normalized args for downstream lowering/metadata.
# Args    : ($label, $event)
# Returns : canonical event hashref
#------------------------------------------------------------------------------
sub _canonicalize_helper_action_ir_event {
 my ($label, $event) = @_;

 my $contract_id = $event->{contract_id} // '';
 my $ir_node = $event->{ir_node} // 'HELPER';
 my %args = %{(ref($event->{args}) eq 'HASH') ? $event->{args} : {}};

 my $kind = $ir_node;
 if ($contract_id eq 'call') {
  $kind = 'CALL';
 }
 elsif ($contract_id eq 'return_call') {
  $kind = 'CALL';
  $args{context} = 'return';
 }
 elsif ($contract_id eq 'return_bare') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'exit_bare') {
  $kind = 'EXIT';
 }
 elsif ($contract_id eq 'linecount_prefix_newline_matches') {
  $kind = 'LINE_COUNT';
 }
 elsif ($contract_id eq 'print_capture_substr') {
  $kind = 'PRINT';
 }
 elsif ($contract_id eq 'assign_match_my') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'destructure_imatch_list_my') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'regex_subst_assignment') {
  $kind = 'REGEX_SUBST';
 }
 elsif ($contract_id eq 'next_bare') {
  $kind = 'NEXT';
 }
 elsif ($contract_id eq 'ref_field_assign') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'position_tracking') {
  $kind = 'POSITION_TRACK';
 }
 elsif ($contract_id eq 'print_foreach_iterable') {
  $kind = 'PRINT';
 }
 elsif ($contract_id eq 'return_imatch' || $contract_id eq 'return_array') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'assign_value') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'regex_subst') {
  $kind = 'REGEX_SUBST';
 }
 elsif ($contract_id eq 'declare_typed' || $contract_id eq 'declare_alias') {
  $kind = 'DECLARE';
 }
 elsif ($contract_id eq 'push_single_arg') {
  $kind = 'PUSH';
  $args{target} = $label unless defined $args{target};
  $args{target_mode} = 'implicit_current_label';
 }
 elsif ($contract_id eq 'push_target_arg') {
  $kind = 'PUSH';
  $args{target_mode} = 'explicit';
 }
 elsif ($contract_id eq 'push_scope_target_arg') {
  $kind = 'PUSH';
  $args{target_mode} = 'explicit';
 }
 elsif ($contract_id eq 'return_a') {
  $kind = 'RETURN_A';
 }
 elsif ($contract_id eq 'return_general') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'return') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'return_ma') {
  $kind = 'RETURN_MA';
 }
 elsif ($contract_id eq 'return_m') {
  $kind = 'RETURN_M';
 }
 elsif ($contract_id eq 'capture_macro') {
  $kind = 'CAPTURE_MACRO';
 }
 elsif ($contract_id eq 'capture') {
  $kind = 'CAPTURE';
 }
 elsif ($contract_id eq 'capture_if' || $contract_id eq 'capture_if_macro') {
  $kind = 'CAPTURE_IF';
 }
 elsif ($contract_id eq 'ibacktrack' || $contract_id eq 'ibacktrack_macro') {
  $kind = 'IBACKTRACK';
 }
 elsif ($contract_id eq 'backtrack' || $contract_id eq 'backtrack_macro') {
  $kind = 'BACKTRACK';
 }
 elsif ($contract_id eq 'if_flow') {
  $kind = 'IF';
 }
 elsif ($contract_id eq 'elseif_flow') {
  $kind = 'ELIF';
 }
 elsif ($contract_id eq 'else_flow') {
  $kind = 'ELSE';
 }
 elsif ($contract_id eq 'endif_flow') {
  $kind = 'ENDIF';
 }
 elsif ($contract_id eq 'switch_flow') {
  $kind = 'SWITCH';
 }
 elsif ($contract_id eq 'case_flow') {
  $kind = 'CASE';
 }
 elsif ($contract_id eq 'default_flow') {
  $kind = 'DEFAULT';
 }
 elsif ($contract_id eq 'endcase_flow') {
  $kind = 'ENDCASE';
 }
 elsif ($contract_id eq 'endswitch_flow') {
  $kind = 'ENDSWITCH';
 }
 elsif ($contract_id eq 'say_stmt') {
  $kind = 'SAY';
 }
 elsif ($contract_id eq 'print_stmt') {
  $kind = 'PRINT';
 }
 elsif ($contract_id eq 'return_undef') {
  $kind = 'RETURN';
  $args{value} = 'undef';
 }

 return {
  kind        => $kind,
  source      => 'helper_contract',
  contract_id => $contract_id,
  raw         => $event->{raw},
  args        => \%args,
 }
}

#------------------------------------------------------------------------------
# Function: _split_action_ir_statements
# Purpose : Statement splitter for action code that honors nesting/quotes and
#           known Perl quote-like forms so semicolon boundaries are robust.
# Args    : ($code)
# Returns : arrayref of top-level statement strings
#------------------------------------------------------------------------------
sub _split_action_ir_statements {
 my ($code) = @_;

 my @statements;
 my $statement = '';
 my $paren_depth = 0;
 my $brace_depth = 0;
 my $bracket_depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $in_backtick_quote = 0;
 my $in_slash_quote = 0;
 my $slash_quote_segments_remaining = 0;
 my $slash_quote_escape_next = 0;
 my $in_angle_quote = 0;
 my $angle_quote_segments_remaining = 0;
 my $angle_quote_depth = 0;
 my $angle_quote_escape_next = 0;
 my $in_pipe_quote = 0;
 my $pipe_quote_segments_remaining = 0;
 my $pipe_quote_escape_next = 0;
 my $in_line_comment = 0;
 my $escape_next = 0;

 foreach my $char (split //, $code) {
  if ($in_line_comment) {
   $statement .= $char;
   if ($char eq "\n") {
    $in_line_comment = 0;
   }
   next;
  }
  if ($in_single_quote) {
   $statement .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq "'") {
    $in_single_quote = 0;
   }
   next;
  }

  if ($in_double_quote) {
   $statement .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq '"') {
    $in_double_quote = 0;
   }
   next;
  }

  if ($in_slash_quote) {
   $statement .= $char;
   if ($slash_quote_escape_next) {
    $slash_quote_escape_next = 0;
   } elsif ($char eq '\\') {
    $slash_quote_escape_next = 1;
   } elsif ($char eq '/') {
    --$slash_quote_segments_remaining if $slash_quote_segments_remaining > 0;
    $in_slash_quote = 0 if $slash_quote_segments_remaining == 0;
   }
   next;
  }
  if ($in_angle_quote) {
   $statement .= $char;
   if ($angle_quote_escape_next) {
    $angle_quote_escape_next = 0;
   } elsif ($char eq '\\') {
    $angle_quote_escape_next = 1;
   } elsif ($char eq '<') {
    ++$angle_quote_depth;
   } elsif ($char eq '>') {
    --$angle_quote_depth if $angle_quote_depth > 0;
    if ($angle_quote_depth == 0) {
     --$angle_quote_segments_remaining if $angle_quote_segments_remaining > 0;
     $in_angle_quote = 0 if $angle_quote_segments_remaining == 0;
    }
   }
   next;
  }
  if ($in_pipe_quote) {
   $statement .= $char;
   if ($pipe_quote_escape_next) {
    $pipe_quote_escape_next = 0;
   } elsif ($char eq '\\') {
    $pipe_quote_escape_next = 1;
   } elsif ($char eq '|') {
    --$pipe_quote_segments_remaining if $pipe_quote_segments_remaining > 0;
    $in_pipe_quote = 0 if $pipe_quote_segments_remaining == 0;
   }
   next;
  }
  if ($char eq "'") {
   $in_single_quote = 1;
   $statement .= $char;
   next;
  }
  if ($in_backtick_quote) {
   $statement .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq '`') {
    $in_backtick_quote = 0;
   }
   next;
  }

  if ($char eq '"') {
   $in_double_quote = 1;
   $statement .= $char;
   next;
  }

  if ($char eq '`') {
   $in_backtick_quote = 1;
   $statement .= $char;
   next;
  }

  if ($char eq '#') {
   $in_line_comment = 1;
   $statement .= $char;
   next;
  }
  if ($char eq '/') {
   my $slash_context = $statement;
   $slash_context =~ s/\s+$//o;

   if ($slash_context =~ /(?:^|[^\w:])(?<op>s|tr|y|qr|qq|qx|q|m)\s*$/o) {
    my $op = $+{op};
    $in_slash_quote = 1;
    $slash_quote_segments_remaining = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
    $slash_quote_escape_next = 0;
    $statement .= $char;
    next;
   } elsif ($slash_context =~ /(?:=~|!~)\s*$/o) {
    $in_slash_quote = 1;
    $slash_quote_segments_remaining = 1;
    $slash_quote_escape_next = 0;
    $statement .= $char;
    next;
   }
  }
  if ($char eq '<') {
   my $angle_context = $statement;
   $angle_context =~ s/\s+$//o;

   if ($angle_context =~ /(?:^|[^\$\w:])(?<op>s|tr|y|qr|qq|qx|q)\s*$/o) {
    my $op = $+{op};
    $in_angle_quote = 1;
    $angle_quote_segments_remaining = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
    $angle_quote_depth = 1;
    $angle_quote_escape_next = 0;
    $statement .= $char;
    next;
   }
  }
  if ($char eq '|') {
   my $pipe_context = $statement;
   $pipe_context =~ s/\s+$//o;

   if ($pipe_context =~ /(?:^|[^\$\w:])(?<op>s|tr|y|qr|qq|qx|q|m)\s*$/o) {
    my $op = $+{op};
    $in_pipe_quote = 1;
    $pipe_quote_segments_remaining = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
    $pipe_quote_escape_next = 0;
    $statement .= $char;
    next;
   } elsif ($pipe_context =~ /(?:=~|!~)\s*m?\s*$/o) {
    $in_pipe_quote = 1;
    $pipe_quote_segments_remaining = 1;
    $pipe_quote_escape_next = 0;
    $statement .= $char;
    next;
   }
  }

  if ($char eq '(') {
   ++$paren_depth;
   $statement .= $char;
   next;
  }

  if ($char eq ')') {
   --$paren_depth if $paren_depth > 0;
   $statement .= $char;
   next;
  }

  if ($char eq '{') {
   ++$brace_depth;
   $statement .= $char;
   next;
  }

  if ($char eq '}') {
   --$brace_depth if $brace_depth > 0;
   $statement .= $char;
   next;
  }

  if ($char eq '[') {
   ++$bracket_depth;
   $statement .= $char;
   next;
  }

  if ($char eq ']') {
   --$bracket_depth if $bracket_depth > 0;
   $statement .= $char;
   next;
  }

  if (
   $char eq ';' &&
   $paren_depth == 0 &&
   $brace_depth == 0 &&
   $bracket_depth == 0
  ) {
   my $trimmed = _trim_action_ir_value($statement);
   push @statements, $trimmed if defined($trimmed) && length($trimmed);
   $statement = '';
   next;
  }

  $statement .= $char;
 }

 my $trimmed = _trim_action_ir_value($statement);
 push @statements, $trimmed if defined($trimmed) && length($trimmed);
 return \@statements
}

#------------------------------------------------------------------------------
# Function: _build_canonical_action_ir_events
# Purpose : Promote helper events + fallback statements into canonical action
#           IR event stream with per-kind hit accounting.
# Args    : ($label, $code, $helper_events)
# Returns : hashref canonical action-IR diagnostics
#------------------------------------------------------------------------------
sub _build_canonical_action_ir_events {
 my ($label, $code, $helper_events) = @_;

 my %helper_event_queue;
 foreach my $helper_event (@$helper_events) {
  my $raw_key = _trim_action_ir_value($helper_event->{raw});
  next unless defined($raw_key) && length($raw_key);
  my $canonical_event = _canonicalize_helper_action_ir_event($label, $helper_event);
  push @{$helper_event_queue{$raw_key}}, $canonical_event;
 }

 my @canonical_events;
 my $fallback_count = 0;
 foreach my $statement (@{_split_action_ir_statements($code)}) {
  if (exists $helper_event_queue{$statement} && @{$helper_event_queue{$statement}}) {
   push @canonical_events, shift @{$helper_event_queue{$statement}};
  } else {
   push @canonical_events, {
    kind        => 'RAW_PERL',
    source      => 'fallback_non_helper_statement',
    contract_id => undef,
    raw         => $statement,
    args        => {code => $statement},
   };
   ++$fallback_count;
  }
 }

 foreach my $raw_key (keys %helper_event_queue) {
  while (@{$helper_event_queue{$raw_key}}) {
   my $event = shift @{$helper_event_queue{$raw_key}};
   $event->{source} = 'unmatched_helper_scan_event';
   push @canonical_events, $event;
  }
 }

 my %hits;
 my $count = 0;
 foreach my $event (@canonical_events) {
  my $kind = $event->{kind} // 'UNKNOWN';
  $hits{$kind} += 1;
  ++$count;
 }

 return {
  canonical_action_ir_count => $count,
  canonical_action_ir_hits  => \%hits,
  canonical_action_ir_nodes => [sort keys %hits],
  canonical_action_ir_events => \@canonical_events,
  canonical_action_ir_fallback_count => $fallback_count,
 }
}

#------------------------------------------------------------------------------
# Function: _lower_action_code_from_canonical_ir
# Purpose : Apply lowering contracts by replaying canonical helper events on
#           the original source string while preserving non-helper regions.
# Args    : ($label, $code, $rewrite_rules, $canonical_ir_diag)
# Returns : lowered code string
#------------------------------------------------------------------------------
sub _lower_action_code_from_canonical_ir {
 my ($label, $code, $rewrite_rules, $canonical_ir_diag) = @_;

 my %rewrite_by_id = map { $_->{id} => $_ } @$rewrite_rules;
 my $rewritten = $code;
 my $lower_ctx = {
  if_stack      => [],
  switch_stack  => [],
  switch_counter => 0,
  rewrite_rules => $rewrite_rules,
 };
 foreach my $event (@{$canonical_ir_diag->{canonical_action_ir_events}}) {
  my $kind = $event->{kind} // '';
  next if $kind eq 'RAW_PERL';

  my $contract_id = $event->{contract_id};
  next unless defined $contract_id && exists $rewrite_by_id{$contract_id};

  my $source_stmt = $event->{raw};
  next unless defined($source_stmt) && length($source_stmt);
  my $lowered_stmt = $rewrite_by_id{$contract_id}{apply}->($source_stmt, $lower_ctx);
  next unless defined($lowered_stmt) && length($lowered_stmt);
  next if $lowered_stmt eq $source_stmt;

  my $pos = index($rewritten, $source_stmt);
  next if $pos < 0;
  substr($rewritten, $pos, length($source_stmt), $lowered_stmt);
 }
 if (@{$lower_ctx->{if_stack}} || @{$lower_ctx->{switch_stack}}) {
  return $code;
 }

 return $rewritten
}

#------------------------------------------------------------------------------
# Function: _accumulate_action_rewrite_diagnostics
# Purpose : Merge per-chunk diagnostics into a rule-level accumulator used for
#           metadata emission and migration readiness reporting.
# Args    : ($acc, $diag)
# Returns : updated accumulator hashref
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

#------------------------------------------------------------------------------
# Function: _rewrite_action_code_with_diagnostics
# Purpose : One-stop action rewrite pipeline: helper IR scan, canonical IR
#           assembly, lowering, unresolved detection, and diag packaging.
# Args    : ($label, $code, $rewrite_rules)
# Returns : ($rewritten_code, $diag_hashref)
#------------------------------------------------------------------------------
sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules) = @_;

 $rewrite_rules //= _build_action_rewrite_rules($label);
 my $ir_diag = _collect_action_helper_ir_nodes($code, $rewrite_rules);
 my $canonical_ir_diag = _build_canonical_action_ir_events($label, $code, $ir_diag->{helper_action_ir_events});
 my $rewritten = _lower_action_code_from_canonical_ir($label, $code, $rewrite_rules, $canonical_ir_diag);
 my $diag = _find_unresolved_action_helpers($rewritten, $rewrite_rules);
 return ($rewritten, {
  %$diag,
  helper_action_ir_count => $ir_diag->{helper_action_ir_count},
  helper_action_ir_hits  => $ir_diag->{helper_action_ir_hits},
  helper_action_ir_nodes => $ir_diag->{helper_action_ir_nodes},
  helper_action_ir_events => $ir_diag->{helper_action_ir_events},
  canonical_action_ir_count => $canonical_ir_diag->{canonical_action_ir_count},
  canonical_action_ir_hits  => $canonical_ir_diag->{canonical_action_ir_hits},
  canonical_action_ir_nodes => $canonical_ir_diag->{canonical_action_ir_nodes},
  canonical_action_ir_events => $canonical_ir_diag->{canonical_action_ir_events},
  canonical_action_ir_fallback_count => $canonical_ir_diag->{canonical_action_ir_fallback_count},
 })
}
#------------------------------------------------------------------------------
# Function: _build_action_rewrite_rules
# Purpose : Compile apply-ready rewrite rules from lowering contracts.
# Args    : ($label)
# Returns : arrayref rewrite rules
#------------------------------------------------------------------------------
sub _build_action_rewrite_rules {
 my ($label) = @_;

 my $contracts = _build_action_lowering_contracts($label);
 return [map {{
  id                 => $_->{id},
  ir_node            => $_->{ir_node},
  diag_name          => $_->{diag_name},
  unresolved_pattern => $_->{unresolved_pattern},
  apply              => $_->{lower},
 }} @$contracts]
}


#------------------------------------------------------------------------------
# Function: call_spec_handler_subst
# Purpose : Compatibility/test helper that exposes helper-surface rewrite output
#           for regression locks; runtime rule compilation calls
#           _rewrite_action_code_with_diagnostics(...) directly.
# Args    : ($label, $code)
# Returns : rewritten code string
#------------------------------------------------------------------------------
sub call_spec_handler_subst {
my ($label, $code) = @_;

#say "call_spec_handler_subst: BEFORE <$label><$code>";
 ($code) = _rewrite_action_code_with_diagnostics($label, $code);

# say "call_spec_handler_subst: AFTER <$label><$code>";
 return $code
}


#------------------------------------------------------------------------------
# Function: _resolve_local_spec_path
# Purpose : Resolve a spec name/path via direct file match, local <name>.spec,
#           then module-relative specs/ lookup.
# Args    : ($spec_name)
# Returns : resolved file path or undef
#------------------------------------------------------------------------------
sub _resolve_local_spec_path {
 my ($spec_name) = @_;
 return undef unless defined $spec_name && length $spec_name;

 return $spec_name if -f $spec_name;
 my $spec_file = $spec_name =~ /\.spec$/o ? $spec_name : "$spec_name.spec";
 return $spec_file if -f $spec_file;

 my $candidate;
 my $ok = eval {
  require Cwd;
  require File::Basename;
  require File::Spec;

  my $module_path = Cwd::abs_path($INC{__PACKAGE__.'.pm'});
  my $module_dir  = (File::Basename::fileparse($module_path))[1];
  my $root_dir    = Cwd::realpath(File::Spec->catdir($module_dir, File::Spec->updir()));
  my $local_spec  = File::Spec->catfile($root_dir, 'specs', $spec_file);
  $candidate      = $local_spec if -f $local_spec;
  1;
 };

 return $candidate if $ok && $candidate;

 return undef
}

#------------------------------------------------------------------------------
# Function: get_parser
# Purpose : Public parser factory that resolves a spec, validates input, loads
#           fallback resolver lazily, compiles parser, and returns coderef.
# Args    : ($spec_name, %opts)
# Returns : parser coderef or undef
#------------------------------------------------------------------------------
sub get_parser {
 my ($spec_name, @opts) = @_;

 unless (defined $spec_name && !ref($spec_name) && $spec_name =~ /\S/o && $spec_name !~ /^\s|\s$/o && $spec_name !~ /[[:cntrl:]]/o) {
  log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Invalid spec name", "spec argument is undefined, empty, whitespace-only, non-scalar, contains control byte, or has leading/trailing whitespace");
  return undef
 }

 my $spec_path = _resolve_local_spec_path($spec_name);
 my $is_explicit_path = ($spec_name =~ m{[/\\]}o);
 my $is_explicit_spec_name = ($spec_name =~ /\.spec$/o);
 unless ($spec_path) {
  if ($is_explicit_path || $is_explicit_spec_name) {
   if (-e $spec_name && !-f $spec_name) {
    my $path_type = -d $spec_name ? 'directory' : 'non-regular';
    log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Spec path is not a file", "spec='$spec_name' resolved='$spec_name' type='$path_type'");
    return undef
   }
   log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Spec path not found", "spec='$spec_name' resolved='<undef>'");
   return undef
  }
 }
 unless ($spec_path) {
  my $ok = eval {require PathSearch; 1};
  unless ($ok) {
   log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Unable to resolve spec '$spec_name'", "PathSearch load failed: $@");
   return undef
  }
  my $resolved_spec_path = eval { PathSearch->go($spec_name, 'spec') };
  if ($@) {
   log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Unable to resolve spec '$spec_name'", "PathSearch runtime failure: $@");
   return undef
  }
  $spec_path = $resolved_spec_path;
 }
 if ($spec_path && -e $spec_path && !-f $spec_path) {
  my $path_type = -d $spec_path ? 'directory' : 'non-regular';
  log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Spec path is not a file", "spec='$spec_name' resolved='$spec_path' type='$path_type'");
  return undef
 }

 unless ($spec_path && -f $spec_path) {
  log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Spec path not found", "spec='$spec_name' resolved='".($spec_path // '<undef>')."'");
  return undef
 }

 open(my $f, '<', $spec_path) or do {
  log_output(DUMP_NONE, "(LinkedSpec::get_parser) -E- Unable to open spec file '$spec_path'", "OS Error: $!");
  return undef
 };
 local $/;
 my $content = <$f>;
 close($f);

 return Get(\$content, @opts)
}

#------------------------------------------------------------------------------
# Function: AUTOLOAD
# Purpose : Lazy plugin bridge used by generated parsers for plugin dispatch.
# Args    : standard Perl AUTOLOAD args
# Returns : whatever plugin call returns
#------------------------------------------------------------------------------
sub AUTOLOAD {
 my $ok = eval {require PPlugin; 1};
 die "(LinkedSpec::AUTOLOAD) -E- Unable to load PPlugin: $@" unless $ok;
 PPlugin->exec($AUTOLOAD, @_)
}

1;
