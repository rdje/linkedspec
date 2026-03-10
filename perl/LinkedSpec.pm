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
use LinkedSpec::RuleIR ();
use LinkedSpec::ActionRewriter ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::MethodExpr ();
use LinkedSpec::ActionIR::ValueExpr ();
use LinkedSpec::ActionIR::FlowExpr ();
use LinkedSpec::ActionIR::ControlFlow ();
use LinkedSpec::ActionIR::ArrayPipeline ();
use LinkedSpec::ActionIR::DeclareMethod ();
use LinkedSpec::ActionIR::MethodLowering ();
use LinkedSpec::ActionIR::Contracts ();
use LinkedSpec::Compiler ();
use LinkedSpec::ParserFactory ();
use LinkedSpec::Runtime ();
use LinkedSpec::SpecEntry ();
use LinkedSpec::PluginBridge ();
use LinkedSpec::Deps ();

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
# Function: _lower_is_empty_expr
# Purpose : Lower `is_empty(...)` checks across scalar/array/general expression
#           payloads used in fluent control-flow expressions.
# Args    : ($arg_expr)
# Returns : Perl boolean expression string or undef
#------------------------------------------------------------------------------
sub _flow_expr_deps {
 return LinkedSpec::Deps::flow_expr_deps_for_package(__PACKAGE__)
}
sub _method_lowering_deps {
 return LinkedSpec::Deps::method_lowering_deps_for_package(__PACKAGE__)
}
sub _declare_method_deps {
 return LinkedSpec::Deps::declare_method_deps_for_package(__PACKAGE__)
}
sub _array_pipeline_deps {
 return LinkedSpec::Deps::array_pipeline_deps_for_package(__PACKAGE__)
}

sub _control_flow_deps {
 return LinkedSpec::Deps::control_flow_deps_for_package(__PACKAGE__)
}
sub _lower_is_empty_expr {
 my ($arg_expr) = @_;
 return LinkedSpec::ActionIR::FlowExpr::_lower_is_empty_expr($arg_expr, _flow_expr_deps())
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
 return LinkedSpec::ActionIR::FlowExpr::_lower_flow_composite_expr($expr, _flow_expr_deps())
}

#------------------------------------------------------------------------------
# Trace core helpers (verbosity parsing, formatting, routing, scope API)
#------------------------------------------------------------------------------

sub _trace_level_name {
 return LinkedSpec::Trace::_trace_level_name(@_)
}

#------------------------------------------------------------------------------
# Function: configure_trace
# Purpose : Runtime trace configuration API (verbosity, sink routing, style).
# Args    : (%opts)
# Returns : hashref effective trace settings
#------------------------------------------------------------------------------
sub configure_trace {
 return LinkedSpec::Trace::configure_trace(@_)
}

sub _apply_trace_options {
 return LinkedSpec::Trace::_apply_trace_options(@_)
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


sub _emit_parser_source_line {
 return LinkedSpec::Runtime::_emit_parser_source_line(@_)
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
# Function: _split_declare_symbol_names
# Purpose : Parse and sanitize comma-separated declaration symbol names.
# Args    : ($raw_names)
# Returns : arrayref of symbol names
#------------------------------------------------------------------------------
sub _split_declare_symbol_names {
 return LinkedSpec::ActionIR::DeclareMethod::_split_declare_symbol_names(@_, _declare_method_deps())
}
#------------------------------------------------------------------------------
# Function: _parse_declare_binding_entry
# Purpose : Parse a single declare binding entry token (`name` or `name = expr`).
# Args    : ($entry)
# Returns : hashref { name => ..., init => ...? } or undef
#------------------------------------------------------------------------------
sub _parse_declare_binding_entry {
 return LinkedSpec::ActionIR::DeclareMethod::_parse_declare_binding_entry(@_, _declare_method_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_declare_value_expr
# Purpose : Lower a generic declare initializer value using the same expression
#           surfaces as flow/value helpers.
# Args    : ($expr)
# Returns : lowered Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_declare_value_expr {
 return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_value_expr(@_, _declare_method_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_declare_initializer_expr
# Purpose : Lower declare initializer payloads for scalar/array/hash declares.
# Args    : ($type, $expr)
# Returns : lowered Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_declare_initializer_expr {
 return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_initializer_expr(@_, _declare_method_deps())
}

#------------------------------------------------------------------------------
# Function: _declare_sigil_for_type
# Purpose : Map canonical declaration type name to Perl declaration sigil.
# Args    : ($type)
# Returns : sigil scalar or undef
#------------------------------------------------------------------------------
sub _declare_sigil_for_type {
 my ($type) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_declare_sigil_for_type($type, _method_lowering_deps())
}

#------------------------------------------------------------------------------
# Function: _declare_alias_to_type
# Purpose : Resolve declaration alias tokens to canonical declaration type.
# Args    : ($alias)
# Returns : canonical type string or undef
#------------------------------------------------------------------------------
sub _declare_alias_to_type {
 my ($alias) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_declare_alias_to_type($alias, _method_lowering_deps())
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
 return LinkedSpec::ActionIR::MethodLowering::_lower_typed_declare_statement($type, $entries_or_names, _method_lowering_deps())
}

#------------------------------------------------------------------------------
# Function: _normalize_method_tag_expr
# Purpose : Normalize method tag atoms into Perl string expressions.
# Args    : ($tag)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _normalize_method_tag_expr {
 my ($tag) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_normalize_method_tag_expr($tag, _method_lowering_deps())
}

sub _value_expr_deps {
 return LinkedSpec::Deps::value_expr_deps_for_package(__PACKAGE__)
}

#------------------------------------------------------------------------------
# Function: _extract_scalar_symbol_name
# Purpose : Resolve scalar variable symbol name from DSL method token surface.
# Args    : ($token)
# Returns : bare symbol name or undef
#------------------------------------------------------------------------------
sub _extract_scalar_symbol_name {
 return LinkedSpec::ActionIR::ValueExpr::_extract_scalar_symbol_name(@_, _value_expr_deps())
}

#------------------------------------------------------------------------------
# Function: _extract_array_symbol_name
# Purpose : Resolve array variable symbol name from DSL method token surface.
# Args    : ($token)
# Returns : bare symbol name or undef
#------------------------------------------------------------------------------
sub _extract_array_symbol_name {
 return LinkedSpec::ActionIR::ValueExpr::_extract_array_symbol_name(@_, _value_expr_deps())
}

#------------------------------------------------------------------------------
# Function: _extract_hash_symbol_name
# Purpose : Resolve hash variable symbol name from DSL method token surface.
# Args    : ($token)
# Returns : bare symbol name or undef
#------------------------------------------------------------------------------
sub _extract_hash_symbol_name {
 return LinkedSpec::ActionIR::ValueExpr::_extract_hash_symbol_name(@_, _value_expr_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_scalar_access_key_expr
# Purpose : Lower scalar index/key expressions used for array/hash entry access.
# Args    : ($expr)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_scalar_access_key_expr {
 return LinkedSpec::ActionIR::ValueExpr::_lower_scalar_access_key_expr(@_, _value_expr_deps())
}
#------------------------------------------------------------------------------
# Function: _split_scalaref_path_segments
# Purpose : Parse scalaref path payloads like `[A][B]{C}[D]` into ordered path
#           segments while preserving nested expression payloads.
# Args    : ($path_expr)
# Returns : arrayref of { kind => 'index'|'key', expr => ... } or undef
#------------------------------------------------------------------------------
sub _split_scalaref_path_segments {
 return LinkedSpec::ActionIR::ValueExpr::_split_scalaref_path_segments(@_, _value_expr_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_scalaref_segment_expr
# Purpose : Lower one scalaref path segment expression while preserving literal
#           bareword path atoms (e.g. `{A}` or `[B]`) when no lowering applies.
# Args    : ($segment_expr)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_scalaref_segment_expr {
 return LinkedSpec::ActionIR::ValueExpr::_lower_scalaref_segment_expr(@_, _value_expr_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_scalaref_value_expr
# Purpose : Lower `scalaref(base_ref, path)` helper into Perl dereference path
#           expression (e.g. `$ref->[A]->{B}`).
# Args    : ($base_expr, $path_expr)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_scalaref_value_expr {
 return LinkedSpec::ActionIR::ValueExpr::_lower_scalaref_value_expr(@_, _value_expr_deps())
}

#------------------------------------------------------------------------------
# Function: _infer_scalar_container_kind
# Purpose : Infer whether `scalar(container, key)` should resolve through array
#           index or hash key syntax when container kind is not explicit.
# Args    : ($container_symbol, $key_expr)
# Returns : 'array' or 'hash'
#------------------------------------------------------------------------------
sub _infer_scalar_container_kind {
 return LinkedSpec::ActionIR::ValueExpr::_infer_scalar_container_kind(@_, _value_expr_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_assignment_source_expr
# Purpose : Map assignment source tokens from method DSL to Perl expressions.
# Args    : ($source)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_assignment_source_expr {
 return LinkedSpec::ActionIR::ValueExpr::_lower_assignment_source_expr(@_, _value_expr_deps())
}

#------------------------------------------------------------------------------
# Function: _strip_literal_delimiters
# Purpose : Strip outer literal delimiters for quoted/regex literal arguments.
# Args    : ($value)
# Returns : unwrapped scalar string or undef
#------------------------------------------------------------------------------
sub _strip_literal_delimiters {
 return LinkedSpec::ActionIR::ValueExpr::_strip_literal_delimiters(@_, _value_expr_deps())
}

#------------------------------------------------------------------------------
# Function: _split_top_level_csv
# Purpose : Split comma-separated argument lists while honoring nested scopes
#           and quoted-string regions.
# Args    : ($text)
# Returns : arrayref of trimmed argument strings
#------------------------------------------------------------------------------
sub _split_top_level_csv {
 return LinkedSpec::ActionIR::MethodExpr::_split_top_level_csv(@_)
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
 return LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr($expr, _method_lowering_deps())
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
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr($expr, _method_lowering_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_return_general_statement
# Purpose : Lower generalized `return(payload)` helper form.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_general_statement {
 my ($expr) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_general_statement($expr, _method_lowering_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_return_imatch_statement
# Purpose : Lower `return_imatch(...)`/`return_im(...)` method helper calls.
# Args    : ($tag)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_imatch_statement {
 my ($tag) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_imatch_statement($tag, _method_lowering_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_assign_statement
# Purpose : Lower `assign(target, source)` method helper calls.
# Args    : ($target, $source)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_assign_statement {
 my ($target, $source) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement($target, $source, _method_lowering_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_push_value_statement
# Purpose : Lower `push_value(array(target), value)` helper calls.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_push_value_statement {
 my ($expr) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_lower_push_value_statement($expr, _method_lowering_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_assign_method_statement
# Purpose : Lower full assign(...) helper expressions with optional scope token.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_assign_method_statement {
 return LinkedSpec::ActionIR::DeclareMethod::_lower_assign_method_statement(@_, _declare_method_deps())
}

#------------------------------------------------------------------------------
# Function: _extract_declare_statement_from_method_expr
# Purpose : Parse declare(...) / declare_* alias helper expressions and return
#           normalized declaration type + entry arguments.
# Args    : ($expr)
# Returns : hashref { declaration_type => ..., entries => [...] } or undef
#------------------------------------------------------------------------------
sub _extract_declare_statement_from_method_expr {
 return LinkedSpec::ActionIR::DeclareMethod::_extract_declare_statement_from_method_expr(@_, _declare_method_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_declare_method_statement
# Purpose : Lower full declare(...) / declare_* alias helper expressions with
#           optional scope token and per-variable initialization entries.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_declare_method_statement {
 return LinkedSpec::ActionIR::DeclareMethod::_lower_declare_method_statement(@_, _declare_method_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_regex_subst_statement
# Purpose : Lower regex substitution method helper calls for scalar targets.
# Args    : ($target, $pattern, $replacement, $flags)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_regex_subst_statement {
 my ($target, $pattern, $replacement, $flags) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_lower_regex_subst_statement($target, $pattern, $replacement, $flags, _method_lowering_deps())
}

#------------------------------------------------------------------------------
# Function: _normalize_split_delimiter_expr
# Purpose : Normalize split delimiter argument into a Perl regex expression.
# Args    : ($delimiter)
# Returns : Perl regex expression string or undef
#------------------------------------------------------------------------------
sub _normalize_split_delimiter_expr {
 my ($delimiter) = @_;
 return LinkedSpec::ActionIR::ArrayPipeline::_normalize_split_delimiter_expr($delimiter, _array_pipeline_deps())
}
#------------------------------------------------------------------------------
# Function: _parse_method_function_expr
# Purpose : Parse `method(arg1, arg2, ...)` expressions with nested-paren args.
# Args    : ($expr)
# Returns : hashref { method => ..., args => [...] } or undef
#------------------------------------------------------------------------------
sub _parse_method_function_expr {
 return LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr(@_)
}

#------------------------------------------------------------------------------
# Function: _is_bare_method_scope_token
# Purpose : Check whether token is a bare scope label candidate.
# Args    : ($token)
# Returns : boolean
#------------------------------------------------------------------------------
sub _is_bare_method_scope_token {
 return LinkedSpec::ActionIR::MethodExpr::_is_bare_method_scope_token(@_)
}

#------------------------------------------------------------------------------
# Function: _normalize_method_args_with_optional_scope
# Purpose : Normalize method argument lists by stripping optional leading scope
#           token when present and validating min/max arity.
# Args    : ($args, $min_arity, $max_arity)
# Returns : arrayref effective args or undef
#------------------------------------------------------------------------------
sub _normalize_method_args_with_optional_scope {
 return LinkedSpec::ActionIR::MethodExpr::_normalize_method_args_with_optional_scope(@_)
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
 return LinkedSpec::ActionIR::ControlFlow::_lower_control_flow_value_expr($expr, _control_flow_deps())
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
 return LinkedSpec::ActionIR::ControlFlow::_lower_switch_case_value_expr($expr, _control_flow_deps())
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
 return LinkedSpec::ActionIR::ArrayPipeline::_build_array_pipeline_plan_from_expr($expr, _array_pipeline_deps())
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
 return LinkedSpec::ActionIR::ArrayPipeline::_lower_array_pipeline_expr($expr, _array_pipeline_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_if_flow_statement
# Purpose : Lower `if(...)`/`i(...)` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_if_flow_statement {
 my ($expr, $ctx) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_if_flow_statement($expr, $ctx, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_elseif_flow_statement
# Purpose : Lower `elif(...)`/`elseif(...)` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_elseif_flow_statement {
 my ($expr, $ctx) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_elseif_flow_statement($expr, $ctx, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_else_flow_statement
# Purpose : Lower `else()` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_else_flow_statement {
 my ($expr, $ctx) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_else_flow_statement($expr, $ctx, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_endif_flow_statement
# Purpose : Lower `endif()` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_endif_flow_statement {
 my ($expr, $ctx) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_endif_flow_statement($expr, $ctx, _control_flow_deps())
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
 return LinkedSpec::ActionIR::ControlFlow::_lower_flow_branch_action_expr($expr, $ctx, _control_flow_deps())
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
 return LinkedSpec::ActionIR::ControlFlow::_lower_inline_switch_branch_expr($branch_expr, $switch_var, $hit_var, $ctx, $switch_state, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_switch_flow_statement
# Purpose : Lower `switch(...)` fluent control-flow markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_switch_flow_statement {
 my ($expr, $ctx) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_switch_flow_statement($expr, $ctx, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_case_flow_statement
# Purpose : Lower `case(...)` fluent switch-branch markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_case_flow_statement {
 my ($expr, $ctx) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_case_flow_statement($expr, $ctx, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_default_flow_statement
# Purpose : Lower `default()` fluent switch default-branch markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_default_flow_statement {
 my ($expr, $ctx) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_default_flow_statement($expr, $ctx, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_endcase_flow_statement
# Purpose : Lower explicit `endcase()` markers (optional in fluent switch).
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_endcase_flow_statement {
 my ($expr, $ctx) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_endcase_flow_statement($expr, $ctx, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_endswitch_flow_statement
# Purpose : Lower `endswitch()` fluent switch terminator markers.
# Args    : ($expr, $ctx)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_endswitch_flow_statement {
 my ($expr, $ctx) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_endswitch_flow_statement($expr, $ctx, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_say_statement
# Purpose : Lower `say(...)` fluent output helper calls.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_say_statement {
 my ($expr) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_say_statement($expr, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_print_statement
# Purpose : Lower `print(...)` fluent output helper calls.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_print_statement {
 my ($expr) = @_;
 return LinkedSpec::ActionIR::ControlFlow::_lower_print_statement($expr, _control_flow_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_return_undef_statement
# Purpose : Lower `return_undef()` fluent helper calls.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_undef_statement {
 my ($expr) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_undef_statement($expr, _method_lowering_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_split_statement
# Purpose : Lower `split(...)` method helper into array-assignment form.
# Args    : ($target, $source, $delimiter)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_split_statement {
 my ($target, $source, $delimiter) = @_;
 return LinkedSpec::ActionIR::ArrayPipeline::_lower_split_statement($target, $source, $delimiter, _array_pipeline_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_trim_each_statement
# Purpose : Lower `trim_each(...)` method helper into array map-trim form.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_trim_each_statement {
 my ($target) = @_;
 return LinkedSpec::ActionIR::ArrayPipeline::_lower_trim_each_statement($target, _array_pipeline_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_filter_nonempty_statement
# Purpose : Lower `filter_nonempty(...)` method helper into array grep form.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_filter_nonempty_statement {
 my ($target) = @_;
 return LinkedSpec::ActionIR::ArrayPipeline::_lower_filter_nonempty_statement($target, _array_pipeline_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_lowercase_each_statement
# Purpose : Lower `lowercase_each(...)` helper into array map lowercase form.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_lowercase_each_statement {
 my ($target) = @_;
 return LinkedSpec::ActionIR::ArrayPipeline::_lower_lowercase_each_statement($target, _array_pipeline_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_uppercase_each_statement
# Purpose : Lower `uppercase_each(...)` helper into array map uppercase form.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_uppercase_each_statement {
 my ($target) = @_;
 return LinkedSpec::ActionIR::ArrayPipeline::_lower_uppercase_each_statement($target, _array_pipeline_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_uniq_statement
# Purpose : Lower `uniq(...)` helper into stable unique-filter assignment.
# Args    : ($target)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_uniq_statement {
 my ($target) = @_;
 return LinkedSpec::ActionIR::ArrayPipeline::_lower_uniq_statement($target, _array_pipeline_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_filter_match_statement
# Purpose : Lower `filter_match(...)` helper into regex grep assignment.
# Args    : ($target, $pattern)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_filter_match_statement {
 my ($target, $pattern) = @_;
 return LinkedSpec::ActionIR::ArrayPipeline::_lower_filter_match_statement($target, $pattern, _array_pipeline_deps())
}

#------------------------------------------------------------------------------
# Function: _lower_return_array_statement
# Purpose : Lower `return_array(tag, payload)` method helper calls.
# Args    : ($tag, $payload)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_array_statement {
 my ($tag, $payload) = @_;
 return LinkedSpec::ActionIR::MethodLowering::_lower_return_array_statement($tag, $payload, _method_lowering_deps())
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
