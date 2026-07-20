#===================================================================
# Copyright (c) 2005-2008 Richard DJE. All rights reserved.
#
# This Perl module is free software, you may redistribute it and/or 
# modify it under the same terms as Perl itself.
#===================================================================
#------------------------------------------------------------------------------
# Package: LinkedSpec
# Purpose: Public facade for parser compilation, trace control, and the modern
#          plugin/runtime entrypoints while lazy-loading the heavier owners.
#------------------------------------------------------------------------------
package LinkedSpec;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 unshift @INC, $module_dir unless grep { defined($_) && $_ eq $module_dir } @INC;
}
use LinkedSpec::OwnerDispatch ();

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
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::Trace', 'configure_trace', @args)
}

#------------------------------------------------------------------------------
# Function: trace_enter
# Purpose : Structured entry trace event for high-level pipeline/functions.
# Args    : ($topic, $details, $level)
# Returns : scope hashref (pass to trace_exit)
#------------------------------------------------------------------------------
sub trace_enter {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::Trace', 'trace_enter', @args)
}

#------------------------------------------------------------------------------
# Function: trace_exit
# Purpose : Structured exit trace event paired with trace_enter.
# Args    : ($scope, $details, $level)
# Returns : undef
#------------------------------------------------------------------------------
sub trace_exit {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::Trace', 'trace_exit', @args)
}

#------------------------------------------------------------------------------
# Function: trace_decision
# Purpose : Emit decision/branch trace messages with explicit reason/context.
# Args    : ($decision_name, $taken, $reason, $level)
# Returns : boolean normalized taken value
#------------------------------------------------------------------------------
sub trace_decision {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::Trace', 'trace_decision', @args)
}

#------------------------------------------------------------------------------
# Function: log_output
# Purpose : Central trace/log entrypoint with UVM-style verbosity gating,
#           metadata formatting, and stdout/file routing.
# Args    : ($level, $message, $context, $opts)
# Returns : undef (side effects only: console/file output)
#------------------------------------------------------------------------------
sub log_output {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::Trace', 'log_output', @args)
}

#------------------------------------------------------------------------------
# Function: log_dump
# Purpose : Dump writer for preformatted payloads with trace metadata routing.
# Args    : ($message, $opts)
# Returns : undef (side effects only: console/file output)
#------------------------------------------------------------------------------
sub log_dump {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::Trace', 'log_dump', @args)
}

#------------------------------------------------------------------------------
# Function: should_dump
# Purpose : Small helper that standardizes verbosity threshold checks.
# Args    : ($level)
# Returns : boolean (true when current verbosity enables this level)
#------------------------------------------------------------------------------
sub should_dump {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::Trace', 'should_dump', @args)
}

#------------------------------------------------------------------------------
# Function: _dispatch_owner_call
# Purpose : Shared facade delegator that lazy-loads an owner package and calls
#           one named routine through it.
# Args    : ($pkg, $subname, @args)
# Returns : delegated owner return value
#------------------------------------------------------------------------------
sub _dispatch_owner_call {
 my ($pkg, $subname, @args) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(__PACKAGE__, $pkg, $subname, @args)
}

#------------------------------------------------------------------------------
# Function: _normalize_flat_option_pairs
# Purpose : Normalize variadic public wrapper options into even key/value pairs.
# Args    : (@args)
# Returns : normalized flat key/value list or empty list on odd input
#------------------------------------------------------------------------------
sub _normalize_flat_option_pairs {
 my @args = @_;
 return (@args % 2 == 0) ? @args : ()
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
 my %option = _normalize_flat_option_pairs(@args);
 return _dispatch_owner_call('LinkedSpec::Runtime', 'run_get', $spec_content_ref, \%option)
}

#------------------------------------------------------------------------------
# Function: semantic_index
# Purpose : Build one opaque immutable semantic-index snapshot from in-memory
#           decoded text or strict UTF-8 bytes without executing the parser.
# Args    : ($spec_scalar_ref, logical_name => ..., source_detail_ceiling => ...)
# Returns : LinkedSpec::SemanticIndex object (compiled or failed-compilation)
#------------------------------------------------------------------------------
sub semantic_index {
 my $spec_content_ref = shift @_;
 return _dispatch_owner_call(
  'LinkedSpec::SemanticIndex',
  'create',
  $spec_content_ref,
  @_,
 )
}

#------------------------------------------------------------------------------
# Function: emit_generated_source
# Purpose : Compile a .spec source and return independently loadable Perl source
#           conforming to linkedspec-generated-source-v2.
# Args    : ($spec_scalar_ref, %options), including source_identity
# Returns : generated Perl source string; dies with generated_source_error on failure
#------------------------------------------------------------------------------
sub emit_generated_source {
 my $spec_content_ref = shift @_;
 my %option = _normalize_flat_option_pairs(@_);
 return _dispatch_owner_call(
  'LinkedSpec::GeneratedSource',
  'emit_source',
  $spec_content_ref,
  \%option,
 )
}

#------------------------------------------------------------------------------
# Function: build_compiled_rule_table
# Purpose : Convert parsed bootstrap entries into the compiled rule-table
#           surface used by later descriptor assembly. Default return is the
#           rule-label => compiled-rule-info hash, while advanced callers may
#           request richer compiled-spec state through owner options.
# Args    : ($parsed_spec_entries, [$compile_spec_entry_cb], [$option_hashref])
# Returns : compiled rule-table hashref or compiled-spec state hashref
#------------------------------------------------------------------------------
sub build_compiled_rule_table {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::Compiler', 'build_compiled_rule_table', @args)
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
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::RuleIR::EmitContext', 'rewrite_action_code_for_compat', @args)
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
 my %opt_hash = _normalize_flat_option_pairs(@opts);
 return _dispatch_owner_call('LinkedSpec::ParserFactory', 'run_get_parser', $spec_name, \%opt_hash)
}

#------------------------------------------------------------------------------
# Legacy Plugin Methods — DEPRECATED
#
# All seven methods below are deprecated transition stubs scheduled for removal
# once PLUGIN-MODERNIZATION.5 retires PPlugin.pm / PluginBridge.pm.
#
# Each delegates to either PluginRegistry or PluginBridge through the standard
# OwnerDispatch path.  No new callers should be added.
#------------------------------------------------------------------------------

# DEPRECATED: removal pending PLUGIN-MODERNIZATION.5 (PluginRegistry retirement).
sub register_plugin {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::PluginRegistry', 'register_plugin', @args)
}

# DEPRECATED: removal pending PLUGIN-MODERNIZATION.5 (PluginRegistry retirement).
sub register_plugins {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::PluginRegistry', 'register_plugins', @args)
}

# DEPRECATED: removal pending PLUGIN-MODERNIZATION.5 (PluginRegistry retirement).
sub clear_registered_plugins {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::PluginRegistry', 'clear_registered_plugins', @args)
}

# DEPRECATED: removal pending PLUGIN-MODERNIZATION.5 (PluginBridge retirement).
sub run_plugin {
 my ($plugin_name, @args) = @_;
 return _dispatch_owner_call('LinkedSpec::PluginBridge', '_dispatch_plugin_name', $plugin_name, \@args)
}

# DEPRECATED: removal pending PLUGIN-MODERNIZATION.5 (PluginBridge retirement).
sub get_plugin {
 my ($plugin_name) = @_;
 return _dispatch_owner_call('LinkedSpec::PluginBridge', '_lookup_plugin_name', $plugin_name)
}

# DEPRECATED: removal pending PLUGIN-MODERNIZATION.5 (PluginBridge retirement).
# Its last external caller (FSMGen::AUTOLOAD) was retired with the legacy VHDL/RTL/FSM
# subsystem (LEGACY-VHDL-RETIRE); no external callers remain.
sub dispatch_plugin_autoload_name {
 my ($autoload_name, @args) = @_;
 return _dispatch_owner_call('LinkedSpec::PluginBridge', '_dispatch_autoload', $autoload_name, \@args)
}

# DEPRECATED: removal pending PLUGIN-MODERNIZATION.5 (PluginBridge retirement).
sub AUTOLOAD {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::PluginBridge', '_dispatch_autoload', $AUTOLOAD, \@args)
}

1;
