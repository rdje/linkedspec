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
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 unshift @INC, $module_dir unless grep { defined($_) && $_ eq $module_dir } @INC;
}

use LinkedRE;
use LinkedSpec::Trace ();
use LinkedSpec::Validation ();
use LinkedSpec::Resolver ();
use LinkedSpec::ActionRewriter ();
use LinkedSpec::Compiler ();
use LinkedSpec::ParserFactory ();
use LinkedSpec::Runtime ();
use LinkedSpec::PluginBridge ();

# UVM-style verbosity levels
use constant {
    DUMP_NONE   => 0,    # No dumps
    DUMP_LOW    => 100,  # Essential dumps only (errors, final results)
    DUMP_MEDIUM => 200,  # Standard dumps (parse results, generated spec)
    DUMP_HIGH   => 300,  # Detailed dumps (rule info, handlers)
    DUMP_FULL   => 400,  # Very detailed dumps (DSL transformations)
    DUMP_DEBUG  => 500   # Maximum detail (everything)
};

# Global trace state aliases (preserve public variable compatibility)
our ($DUMP_VERBOSITY, $TRACE_LOG_FILE, $TRACE_LOG_MODE, $TRACE_EMOJI, $TRACE_INDENT_LEVEL, $TRACE_INDENT_WIDTH, $TRACE_TOPIC_SPACING, $TRACE_INITIALIZED);
*DUMP_VERBOSITY   = \$LinkedSpec::Trace::DUMP_VERBOSITY;
*TRACE_LOG_FILE   = \$LinkedSpec::Trace::TRACE_LOG_FILE;
*TRACE_LOG_MODE   = \$LinkedSpec::Trace::TRACE_LOG_MODE;
*TRACE_EMOJI      = \$LinkedSpec::Trace::TRACE_EMOJI;
*TRACE_INDENT_LEVEL = \$LinkedSpec::Trace::TRACE_INDENT_LEVEL;
*TRACE_INDENT_WIDTH = \$LinkedSpec::Trace::TRACE_INDENT_WIDTH;
*TRACE_TOPIC_SPACING = \$LinkedSpec::Trace::TRACE_TOPIC_SPACING;
*TRACE_INITIALIZED = \$LinkedSpec::Trace::TRACE_INITIALIZED;

#------------------------------------------------------------------------------
# Trace core helpers (verbosity parsing, formatting, routing, scope API)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function: configure_trace
# Purpose : Runtime trace configuration API (verbosity, sink routing, style).
# Args    : (%opts)
# Returns : hashref effective trace settings
#------------------------------------------------------------------------------
sub configure_trace {
 return LinkedSpec::Trace::configure_trace(@_)
}

#------------------------------------------------------------------------------
# Function: trace_enter
# Purpose : Structured entry trace event for high-level pipeline/functions.
# Args    : ($topic, $details, $level)
# Returns : scope hashref (pass to trace_exit)
#------------------------------------------------------------------------------
sub trace_enter {
 return LinkedSpec::Trace::trace_enter(@_)
}

#------------------------------------------------------------------------------
# Function: trace_exit
# Purpose : Structured exit trace event paired with trace_enter.
# Args    : ($scope, $details, $level)
# Returns : undef
#------------------------------------------------------------------------------
sub trace_exit {
 return LinkedSpec::Trace::trace_exit(@_)
}

#------------------------------------------------------------------------------
# Function: trace_decision
# Purpose : Emit decision/branch trace messages with explicit reason/context.
# Args    : ($decision_name, $taken, $reason, $level)
# Returns : boolean normalized taken value
#------------------------------------------------------------------------------
sub trace_decision {
 return LinkedSpec::Trace::trace_decision(@_)
}

#------------------------------------------------------------------------------
# Function: log_output
# Purpose : Central trace/log entrypoint with UVM-style verbosity gating,
#           metadata formatting, and stdout/file routing.
# Args    : ($level, $message, $context, $opts)
# Returns : undef (side effects only: console/file output)
#------------------------------------------------------------------------------
sub log_output {
 return LinkedSpec::Trace::log_output(@_)
}

#------------------------------------------------------------------------------
# Function: log_dump
# Purpose : Dump writer for preformatted payloads with trace metadata routing.
# Args    : ($message, $opts)
# Returns : undef (side effects only: console/file output)
#------------------------------------------------------------------------------
sub log_dump {
 return LinkedSpec::Trace::log_dump(@_)
}

#------------------------------------------------------------------------------
# Function: should_dump
# Purpose : Small helper that standardizes verbosity threshold checks.
# Args    : ($level)
# Returns : boolean (true when current verbosity enables this level)
#------------------------------------------------------------------------------
sub should_dump {
 return LinkedSpec::Trace::should_dump(@_)
}


#------------------------------------------------------------------------------
# Function: get_dsl_context
# Purpose : Build line-oriented context around a byte-position in .spec text so
#           validation errors can report useful nearby source.
# Args    : ($spec_content, $position)
# Returns : hashref { line_number, current_line, prev_line, next_line, position }
#------------------------------------------------------------------------------
sub get_dsl_context {
 return LinkedSpec::Validation::get_dsl_context(@_)
}

#------------------------------------------------------------------------------
# Function: report_dsl_error
# Purpose : Format and emit a human-readable DSL error message with local
#           source context and optional remediation guidance.
# Args    : ($spec_content, $position, $error_msg, $suggestion)
# Returns : undef (side effects only: logging)
#------------------------------------------------------------------------------
sub report_dsl_error {
 return LinkedSpec::Validation::report_dsl_error(@_)
}

#------------------------------------------------------------------------------
# Function: validate_spec_content
# Purpose : Validate raw .spec input envelope before deeper syntax parsing.
# Args    : ($spec_content)
# Returns : boolean (true if minimal shape/entry rule expectations are met)
#------------------------------------------------------------------------------
sub validate_spec_content {
 return LinkedSpec::Validation::validate_spec_content(@_)
}

#------------------------------------------------------------------------------
# Function: validate_rule_definition
# Purpose : Structural sanity-check for generated rule definitions in the
#           descriptor (handler presence, regex shape, regex compilability).
# Args    : ($rule_name, $rule_def)
# Returns : boolean
#------------------------------------------------------------------------------
sub validate_rule_definition {
 return LinkedSpec::Validation::validate_rule_definition(@_)
}

#------------------------------------------------------------------------------
# Function: validate_gdata_references
# Purpose : Validate integrity between gdata dispatch regexes and generated
#           spec rules, including gdata indirections embedded in rules.
# Args    : ($gdata, $spec)
# Returns : boolean
#------------------------------------------------------------------------------
sub validate_gdata_references {
 return LinkedSpec::Validation::validate_gdata_references(@_)
}

#------------------------------------------------------------------------------
# Function: validate_dsl_syntax
# Purpose : Perform rule-level DSL checks (duplicate definitions, regex literal
#           validity, undefined/unused rule warnings).
# Args    : ($spec_content)
# Returns : boolean
#------------------------------------------------------------------------------
sub validate_dsl_syntax {
 return LinkedSpec::Validation::validate_dsl_syntax(@_)
}

#------------------------------------------------------------------------------
# Function: extract_regex_literals_from_rule_rhs
# Purpose : Extract slash-delimited regex literals from a rule RHS while
#           respecting escaped delimiters.
# Args    : ($rhs)
# Returns : list of regex literal strings (including surrounding /.../)
#------------------------------------------------------------------------------
sub extract_regex_literals_from_rule_rhs {
 return LinkedSpec::Validation::extract_regex_literals_from_rule_rhs(@_)
}



#------------------------------------------------------------------------------
# Function: Get
# Purpose : Compile a .spec source into a runnable parser coderef (or return
#           descriptor/parse-only outputs based on options).
# Args    : ($spec_scalar_ref, %options)
# Returns : parser coderef | descriptor hashref | undef (mode/error dependent)
#------------------------------------------------------------------------------
sub Get {
 my @args = @_;
 my $spec_content_ref = shift @args;
 my %option = @args;
 return LinkedSpec::Runtime::run_get($spec_content_ref, \%option)
}

#------------------------------------------------------------------------------
# Function: spec_descr
# Purpose : Convert parsed bootstrap entries into the descriptor's `spec` hash
#           (rule label => compiled rule info).
# Args    : ($parsed_spec_entries)
# Returns : hashref of spec rule definitions
#------------------------------------------------------------------------------
sub spec_descr {
 return LinkedSpec::Compiler::spec_descr(@_)
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
 return LinkedSpec::ActionRewriter::call_spec_handler_subst(@_)
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
 my %opt_hash = (@opts % 2 == 0) ? @opts : ();
 return LinkedSpec::ParserFactory::run_get_parser($spec_name, \%opt_hash)
}

#------------------------------------------------------------------------------
# Function: AUTOLOAD
# Purpose : Lazy plugin bridge used by generated parsers for plugin dispatch.
# Args    : standard Perl AUTOLOAD args
# Returns : whatever plugin call returns
#------------------------------------------------------------------------------
sub AUTOLOAD {
 return LinkedSpec::PluginBridge::_dispatch_autoload($AUTOLOAD, \@_)
}

1;
