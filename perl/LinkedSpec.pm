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
 re=> [qr/->\s*(?<ENTRY_LABEL>\w+)\s*(?:\[\s*(?<INDEX>\d+)\s*\]\s*)?\.\s*(?<METHOD>\w+)(?<ARGS>\s*\((?:[^\(\)]++|(?&ARGS))+\))?/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;

  my ($entry_label, $reidx, $method, $args) = @{$$info{match_hash}}{qw/ENTRY_LABEL INDEX METHOD ARGS/}; 
  # say "(Method code block) ($entry_label:".($reidx // 0).":$method:".($args // '').")";
  if (defined $args) {
   $args =~ s/^\s*\(//o;
   $args =~ s/\)\s*$//o;
  }
  return ['ACODE', {relabel=>$entry_label, reidx=> $reidx // 0, code=>"$method($entry_label".($args ? ",$args" : '').")"}]
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
 re=> [qr/(?<TYPE>\w+)\s*\.\s*(?<METHOD>\w+)(?<ARGS>\s*\((?:[^\(\)]++|(?&ARGS))+\))?/o],
 handler=> sub {
  my ($info, $descr, $string, $gdata) = @_;

  my ($type, $method, $args) = @{$$info{match_hash}}{qw/TYPE METHOD ARGS/};
  # say "(Method-like Empty Action code block) ($type)($method)(".($args// '').")";
  return ["${type}CODE", $method."($gdata->{_current_entry}".($args ? ",$args" :  '').')']
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
 
      # If parse-only mode, stop here and return undef
     if ($parse_only) {
         log_output(DUMP_LOW, "Parse-only mode", "Stopping after .spec file parsing - no parser generated");
         return undef;
     }
     
     # Start parser generation phase
     log_output(DUMP_LOW, "Starting parser generation", "Converting parsed spec data into executable parser");

 my $auto_descr_spec  = spec_descr($retv);
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

 my @specinfo = map {spec_entry($_)} @$specretv;
 
 # Debug: Log the specinfo array
 log_output(DUMP_LOW, "Specinfo array contents", "Number of entries: " . scalar(@specinfo));
 for (my $i = 0; $i < @specinfo; $i++) {
     my $entry = $specinfo[$i];
     if (ref($entry) eq 'ARRAY' && @$entry >= 2) {
         log_output(DUMP_LOW, "Entry $i", "Label: '$entry->[0]', Type: " . ref($entry->[1]));
     } else {
         log_output(DUMP_LOW, "Entry $i", "Type: " . ref($entry) . ", Content: " . Dumper($entry));
     }
 }
 
 # Debug: Check for duplicate rules
 my %seen_rules;
 my @duplicate_rules;
 foreach my $pair (@specinfo) {
     if (ref($pair) eq 'ARRAY' && @$pair >= 2) {
         my ($label, $info) = @$pair;
         if (exists $seen_rules{$label}) {
             push @duplicate_rules, $label;
             log_output(DUMP_LOW, "Duplicate rule detected", "Rule '$label' is defined multiple times - second definition will overwrite the first");
         }
         $seen_rules{$label} = 1;
     }
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
   id                 => 'push_call_builtin',
   ir_node            => 'CALL',
   diag_name          => 'push_call_builtin',
   unresolved_pattern => qr/\bpush\s+\@\w+\s*,\s*call\s*\(\s*\w+\s*\)/o,
   lower              => sub {
    my ($code) = @_;
   $code =~ s/\bpush\s+\@(\w+)\s*,\s*call\s*\(\s*(\w+)\s*\)/push \@$1, &{\$\$descr{spec}{$2}{handler}}(\$descr, \$STRING, \$minfo)/g;
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
# Returns : 1 on success (may exit on critical incompatibility)
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
  exit 1
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
 _validate_rule_ir_or_exit($rule_ir, $rule_meta);

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
 } elsif ($id eq 'push_call_builtin') {
  while ($code =~ /\bpush\s+\@(?<target>\w+)\s*,\s*call\s*\(\s*(?<callee>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}}};
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
 } elsif ($id eq 'return_a') {
  while ($code =~ /\breturn_a\s*\(\s*(?<label>\w+)(?:\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+))?\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}, arg => _trim_action_ir_value($+{arg})}};
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
 elsif ($contract_id eq 'push_single_arg') {
  $kind = 'PUSH';
  $args{target} = $label unless defined $args{target};
  $args{target_mode} = 'implicit_current_label';
 }
 elsif ($contract_id eq 'push_target_arg') {
  $kind = 'PUSH';
  $args{target_mode} = 'explicit';
 }
 elsif ($contract_id eq 'return_a') {
  $kind = 'RETURN_A';
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
 foreach my $event (@{$canonical_ir_diag->{canonical_action_ir_events}}) {
  my $kind = $event->{kind} // '';
  next if $kind eq 'RAW_PERL';

  my $contract_id = $event->{contract_id};
  next unless defined $contract_id && exists $rewrite_by_id{$contract_id};

  my $source_stmt = $event->{raw};
  next unless defined($source_stmt) && length($source_stmt);

  my $lowered_stmt = $rewrite_by_id{$contract_id}{apply}->($source_stmt);
  next unless defined($lowered_stmt) && length($lowered_stmt);
  next if $lowered_stmt eq $source_stmt;

  my $pos = index($rewritten, $source_stmt);
  next if $pos < 0;
  substr($rewritten, $pos, length($source_stmt), $lowered_stmt);
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
