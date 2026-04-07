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
# Function: _require_pkg
# Purpose : Lazy-load one owner package by package name.
# Args    : ($pkg)
# Returns : true on successful require
#------------------------------------------------------------------------------
sub _require_pkg {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, $pkg)
}

#------------------------------------------------------------------------------
# Function: _call_preserving_err
# Purpose : Execute callback without clobbering caller-visible successful `$@`.
# Args    : ($cb)
# Returns : callback return value in caller context
#------------------------------------------------------------------------------
sub _call_preserving_err {
 my ($cb) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err($cb)
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
# Function: spec_descr
# Purpose : Convert parsed bootstrap entries into compiled rule state.
#           Default return remains the historical descriptor `spec` hash
#           (rule label => compiled rule info), while advanced callers may
#           request richer compiled-spec state through owner options.
# Args    : ($parsed_spec_entries, [$compile_spec_entry_cb], [$option_hashref])
# Returns : hashref of spec rule definitions or compiled-spec state hashref
#------------------------------------------------------------------------------
sub spec_descr {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::Compiler', 'spec_descr', @args)
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
# Function: register_plugin
# Purpose : Register an explicit named plugin handler for AUTOLOAD dispatch.
# Args    : ($plugin_name, $coderef)
# Returns : registered coderef
#------------------------------------------------------------------------------
sub register_plugin {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::PluginRegistry', 'register_plugin', @args)
}

#------------------------------------------------------------------------------
# Function: register_plugins
# Purpose : Register multiple explicit named plugin handlers at once.
# Args    : (\%plugin_name_to_coderef) | (%plugin_name_to_coderef)
# Returns : count of registered plugin handlers
#------------------------------------------------------------------------------
sub register_plugins {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::PluginRegistry', 'register_plugins', @args)
}

#------------------------------------------------------------------------------
# Function: clear_registered_plugins
# Purpose : Clear the explicit named plugin registry.
# Args    : ()
# Returns : number of cleared plugin handlers
#------------------------------------------------------------------------------
sub clear_registered_plugins {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::PluginRegistry', 'clear_registered_plugins', @args)
}

#------------------------------------------------------------------------------
# Function: run_plugin
# Purpose : Explicit named plugin dispatch entrypoint for registered or legacy
#           plugin handlers without relying on AUTOLOAD name extraction.
# Args    : ($plugin_name, @plugin_args)
# Returns : whatever plugin call returns
#------------------------------------------------------------------------------
sub run_plugin {
 my ($plugin_name, @args) = @_;
 return _dispatch_owner_call('LinkedSpec::PluginBridge', '_dispatch_plugin_name', $plugin_name, \@args)
}

#------------------------------------------------------------------------------
# Function: get_plugin
# Purpose : Explicit named plugin handler lookup entrypoint for registered or
#           legacy plugin handlers without relying on PPlugin directly.
# Args    : ($plugin_name)
# Returns : coderef | undef
#------------------------------------------------------------------------------
sub get_plugin {
 my ($plugin_name) = @_;
 return _dispatch_owner_call('LinkedSpec::PluginBridge', '_lookup_plugin_name', $plugin_name)
}

#------------------------------------------------------------------------------
# Function: dispatch_plugin_autoload_name
# Purpose : Compatibility helper for legacy module-owned AUTOLOAD shims that
#           still need bridge normalization but should not call PPlugin
#           directly anymore.
# Args    : ($autoload_name, @plugin_args)
# Returns : whatever plugin call returns
#------------------------------------------------------------------------------
sub dispatch_plugin_autoload_name {
 my ($autoload_name, @args) = @_;
 return _dispatch_owner_call('LinkedSpec::PluginBridge', '_dispatch_autoload', $autoload_name, \@args)
}

#------------------------------------------------------------------------------
# Function: AUTOLOAD
# Purpose : Lazy plugin bridge used by generated parsers for plugin dispatch.
# Args    : standard Perl AUTOLOAD args
# Returns : whatever plugin call returns
#------------------------------------------------------------------------------
sub AUTOLOAD {
 my @args = @_;
 return _dispatch_owner_call('LinkedSpec::PluginBridge', '_dispatch_autoload', $AUTOLOAD, \@args)
}

1;
