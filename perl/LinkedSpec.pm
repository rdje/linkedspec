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
use LinkedSpec::ActionIR::Contracts ();
use LinkedSpec::SpecEntry ();
use LinkedSpec::Compiler ();
use LinkedSpec::BootstrapSpec ();

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
 return {
  trim_action_ir_value => \&_trim_action_ir_value,
  extract_array_symbol_name => \&_extract_array_symbol_name,
  extract_scalar_symbol_name => \&_extract_scalar_symbol_name,
  lower_method_value_expr => \&_lower_method_value_expr,
  parse_method_function_expr => \&_parse_method_function_expr,
  normalize_method_args_with_optional_scope => \&_normalize_method_args_with_optional_scope,
 }
}

sub _control_flow_deps {
 return {
  trim_action_ir_value => \&_trim_action_ir_value,
  normalize_method_tag_expr => \&_normalize_method_tag_expr,
  lower_flow_composite_expr => \&_lower_flow_composite_expr,
  parse_method_function_expr => \&_parse_method_function_expr,
  normalize_method_args_with_optional_scope => \&_normalize_method_args_with_optional_scope,
 }
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

our $PARSER_SOURCE_EMIT_CB;

sub _emit_parser_source_line {
 my ($chunk) = @_;
 return unless ref($PARSER_SOURCE_EMIT_CB) eq 'CODE';
 $PARSER_SOURCE_EMIT_CB->($chunk);
 return
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
# Bootstrap parser metadata and global state
#------------------------------------------------------------------------------
# Optional parser-source emitter callback is configured by Get() when requested.
my ($spec_descr, $bootstrap_rule_index_ref, $gdata) = LinkedSpec::BootstrapSpec::build_bootstrap_spec();
my %bootstrap_rule_index = %$bootstrap_rule_index_ref;


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
 return LinkedSpec::Compiler::_build_action_rewriter_migration_summary(@_)
}
#------------------------------------------------------------------------------
# Function: Get
# Purpose : Compile a .spec source into a runnable parser coderef (or return
#           descriptor/parse-only outputs based on options).
# Args    : ($spec_scalar_ref, %options)
# Returns : parser coderef | descriptor hashref | undef (mode/error dependent)
#------------------------------------------------------------------------------
sub Get {
 my $spec_content_ref = $_[0];
 my %option = @_[1 .. $#_];
 my @parser_source_chunks;
 local $PARSER_SOURCE_EMIT_CB = $option{dump_parser_source} ? sub {
  my ($chunk) = @_;
  push @parser_source_chunks, $chunk;
 } : undef;
 return LinkedSpec::Compiler::run_get_pipeline(
  $spec_content_ref,
  \%option,
  {
   spec_descr => $spec_descr,
   bootstrap_rule_index => \%bootstrap_rule_index,
   gdata => $gdata,
   emit_parser_source_line => \&_emit_parser_source_line,
   top_rule_ref => \$top_rule,
   parser_source_chunks_ref => \@parser_source_chunks,
  }
 )
}

#------------------------------------------------------------------------------
# Function: _select_rule_handler_variant
# Purpose : Deterministically map a rule shape (node type + code mix) to the
#           handler template variant that should emit runtime behavior.
# Args    : ($node_type, $acode_count, $bcode_count, $regex_count)
# Returns : variant id string
#------------------------------------------------------------------------------
sub _select_rule_handler_variant {
 return LinkedSpec::RuleIR::_select_rule_handler_variant(@_)
}

#------------------------------------------------------------------------------
# Function: _build_rule_execution_meta
# Purpose : Build normalized metadata describing how a rule executes, including
#           action mode, selected variant and loop behavior.
# Args    : named args hash
# Returns : hashref metadata
#------------------------------------------------------------------------------
sub _build_rule_execution_meta {
 return LinkedSpec::RuleIR::_build_rule_execution_meta(@_)
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
# Function: _action_contract_deps
# Purpose : Provide explicit lowering callback dependencies for contract
#           assembly so contract definition ownership can live outside
#           LinkedSpec.pm without hidden callback indirection.
# Args    : none
# Returns : hashref callback dependency map
#------------------------------------------------------------------------------
sub _action_contract_deps {
 return {
  lower_return_general_statement => \&_lower_return_general_statement,
  lower_return_imatch_statement  => \&_lower_return_imatch_statement,
  lower_assign_method_statement  => \&_lower_assign_method_statement,
  lower_regex_subst_statement    => \&_lower_regex_subst_statement,
  lower_array_pipeline_expr      => \&_lower_array_pipeline_expr,
  lower_if_flow_statement        => \&_lower_if_flow_statement,
  lower_elseif_flow_statement    => \&_lower_elseif_flow_statement,
  lower_else_flow_statement      => \&_lower_else_flow_statement,
  lower_endif_flow_statement     => \&_lower_endif_flow_statement,
  lower_switch_flow_statement    => \&_lower_switch_flow_statement,
  lower_case_flow_statement      => \&_lower_case_flow_statement,
  lower_default_flow_statement   => \&_lower_default_flow_statement,
  lower_endcase_flow_statement   => \&_lower_endcase_flow_statement,
  lower_endswitch_flow_statement => \&_lower_endswitch_flow_statement,
  lower_say_statement            => \&_lower_say_statement,
  lower_print_statement          => \&_lower_print_statement,
  lower_return_undef_statement   => \&_lower_return_undef_statement,
  lower_return_array_statement   => \&_lower_return_array_statement,
  lower_declare_method_statement => \&_lower_declare_method_statement,
 }
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
 return LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts(
  $label,
  _action_contract_deps(),
 )
}

#------------------------------------------------------------------------------
# Function: _collect_rule_ir
# Purpose : Normalize parsed bootstrap entry tuples into a structured RuleIR
#           payload consumed by planning/validation/emission stages.
# Args    : ($einfo)
# Returns : hashref RuleIR
#------------------------------------------------------------------------------
sub _collect_rule_ir {
 return LinkedSpec::RuleIR::_collect_rule_ir(@_)
}

#------------------------------------------------------------------------------
# Function: _plan_rule_ir_meta
# Purpose : Derive deterministic execution metadata from RuleIR counts/types.
# Args    : ($rule_ir)
# Returns : hashref execution metadata
#------------------------------------------------------------------------------
sub _plan_rule_ir_meta {
 return LinkedSpec::RuleIR::_plan_rule_ir_meta(@_)
}

#------------------------------------------------------------------------------
# Function: _validate_rule_ir_or_exit
# Purpose : Enforce rule-shape invariants before emission (notably disallowing
#           mixed ACTION + BLIND CALL forms in one rule).
# Args    : ($rule_ir, $rule_meta)
# Returns : 1 on success, 0 on validation failure
#------------------------------------------------------------------------------
sub _validate_rule_ir_or_exit {
 return LinkedSpec::RuleIR::_validate_rule_ir_or_exit(@_)
}

#------------------------------------------------------------------------------
# Function: _normalize_rule_code_chunks
# Purpose : Rewrite and join lifecycle code chunks while accumulating rewrite
#           diagnostics across each transformed chunk.
# Args    : ($label, $chunks, $rewrite_diag_acc, $rewrite_rules)
# Returns : normalized code string
#------------------------------------------------------------------------------
sub _normalize_rule_code_chunks {
 return LinkedSpec::RuleIR::_normalize_rule_code_chunks(@_)
}

#------------------------------------------------------------------------------
# Function: _build_rule_ir_emit_context
# Purpose : Build fully-rewritten emit context (ACODE/BCODE/gdata/lifecycle
#           chunks) plus rich action-rewriter diagnostics metadata.
# Args    : ($rule_ir)
# Returns : hashref emit context
#------------------------------------------------------------------------------
sub _build_rule_ir_emit_context {
 return LinkedSpec::RuleIR::_build_rule_ir_emit_context(@_)
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
 my ($label, $info, $top_rule_candidate) = LinkedSpec::SpecEntry::compile_spec_entry(
  $einfo,
  {
   emit_parser_source_line => \&_emit_parser_source_line,
  }
 );
 return undef unless defined($label) && ref($info) eq 'HASH';
 $top_rule = $top_rule_candidate if defined $top_rule_candidate;
 return ($label, $info)
}

#------------------------------------------------------------------------------
# Function: spec_gdata
# Purpose : Build compiled dispatch regex bundles (gdata) for each rule from
#           rule-to-rule gdata references collected during descriptor build.
# Args    : ($spec_hashref)
# Returns : hashref rule => compiled LinkedRE regex
#------------------------------------------------------------------------------
sub spec_gdata {
 return LinkedSpec::Compiler::spec_gdata(@_)
}
#------------------------------------------------------------------------------
# Function: _find_unresolved_action_helpers
# Purpose : Detect helper forms that remain unresolved after rewrite/lowering
#           and report both counts and statement-level events.
# Args    : ($code, $rewrite_rules)
# Returns : hashref unresolved diagnostics payload
#------------------------------------------------------------------------------
sub _find_unresolved_action_helpers {
 return LinkedSpec::ActionRewriter::_find_unresolved_action_helpers(@_)
}

#------------------------------------------------------------------------------
# Function: _trim_action_ir_value
# Purpose : Shared whitespace normalization helper for action-IR payload text.
# Args    : ($value)
# Returns : trimmed scalar or undef
#------------------------------------------------------------------------------
sub _trim_action_ir_value {
 return LinkedSpec::ActionRewriter::_trim_action_ir_value(@_)
}

#------------------------------------------------------------------------------
# Function: _split_declare_symbol_names
# Purpose : Parse and sanitize comma-separated declaration symbol names.
# Args    : ($raw_names)
# Returns : arrayref of symbol names
#------------------------------------------------------------------------------
sub _split_declare_symbol_names {
 return LinkedSpec::ActionRewriter::_split_declare_symbol_names(@_)
}
#------------------------------------------------------------------------------
# Function: _parse_declare_binding_entry
# Purpose : Parse a single declare binding entry token (`name` or `name = expr`).
# Args    : ($entry)
# Returns : hashref { name => ..., init => ...? } or undef
#------------------------------------------------------------------------------
sub _parse_declare_binding_entry {
 return LinkedSpec::ActionRewriter::_parse_declare_binding_entry(@_)
}

#------------------------------------------------------------------------------
# Function: _lower_declare_value_expr
# Purpose : Lower a generic declare initializer value using the same expression
#           surfaces as flow/value helpers.
# Args    : ($expr)
# Returns : lowered Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_declare_value_expr {
 return LinkedSpec::ActionRewriter::_lower_declare_value_expr(@_)
}

#------------------------------------------------------------------------------
# Function: _lower_declare_initializer_expr
# Purpose : Lower declare initializer payloads for scalar/array/hash declares.
# Args    : ($type, $expr)
# Returns : lowered Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_declare_initializer_expr {
 return LinkedSpec::ActionRewriter::_lower_declare_initializer_expr(@_)
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

sub _value_expr_deps {
 return {
  trim_action_ir_value      => \&_trim_action_ir_value,
  lower_flow_composite_expr => \&_lower_flow_composite_expr,
  lower_method_value_expr   => \&_lower_method_value_expr,
 }
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
 return LinkedSpec::ActionRewriter::_lower_assign_method_statement(@_)
}

#------------------------------------------------------------------------------
# Function: _extract_declare_statement_from_method_expr
# Purpose : Parse declare(...) / declare_* alias helper expressions and return
#           normalized declaration type + entry arguments.
# Args    : ($expr)
# Returns : hashref { declaration_type => ..., entries => [...] } or undef
#------------------------------------------------------------------------------
sub _extract_declare_statement_from_method_expr {
 return LinkedSpec::ActionRewriter::_extract_declare_statement_from_method_expr(@_)
}

#------------------------------------------------------------------------------
# Function: _lower_declare_method_statement
# Purpose : Lower full declare(...) / declare_* alias helper expressions with
#           optional scope token and per-variable initialization entries.
# Args    : ($expr)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_declare_method_statement {
 return LinkedSpec::ActionRewriter::_lower_declare_method_statement(@_)
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
 return LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
  $contract,
  $code,
  {
   split_action_ir_statements                 => \&_split_action_ir_statements,
   trim_action_ir_value                       => \&_trim_action_ir_value,
   parse_method_function_expr                 => \&_parse_method_function_expr,
   normalize_method_args_with_optional_scope  => \&_normalize_method_args_with_optional_scope,
   build_array_pipeline_plan_from_expr        => \&_build_array_pipeline_plan_from_expr,
   extract_declare_statement_from_method_expr => \&_extract_declare_statement_from_method_expr,
   parse_declare_binding_entry                => \&_parse_declare_binding_entry,
  }
 )
}

#------------------------------------------------------------------------------
# Function: _collect_action_helper_ir_nodes
# Purpose : Aggregate helper-action IR hits/events across all rewrite contracts
#           before lowering is applied.
# Args    : ($code, $rewrite_rules)
# Returns : hashref helper-action IR diagnostics
#------------------------------------------------------------------------------
sub _collect_action_helper_ir_nodes {
 return LinkedSpec::ActionRewriter::_collect_action_helper_ir_nodes(@_)
}

#------------------------------------------------------------------------------
# Function: _canonicalize_helper_action_ir_event
# Purpose : Convert contract-level helper event identity into canonical IR
#           event kind + normalized args for downstream lowering/metadata.
# Args    : ($label, $event)
# Returns : canonical event hashref
#------------------------------------------------------------------------------
sub _canonicalize_helper_action_ir_event {
 return LinkedSpec::ActionRewriter::_canonicalize_helper_action_ir_event(@_)
}

#------------------------------------------------------------------------------
# Function: _split_action_ir_statements
# Purpose : Statement splitter for action code that honors nesting/quotes and
#           known Perl quote-like forms so semicolon boundaries are robust.
# Args    : ($code)
# Returns : arrayref of top-level statement strings
#------------------------------------------------------------------------------
sub _split_action_ir_statements {
 return LinkedSpec::ActionRewriter::_split_action_ir_statements(@_)
}

#------------------------------------------------------------------------------
# Function: _build_canonical_action_ir_events
# Purpose : Promote helper events + fallback statements into canonical action
#           IR event stream with per-kind hit accounting.
# Args    : ($label, $code, $helper_events)
# Returns : hashref canonical action-IR diagnostics
#------------------------------------------------------------------------------
sub _build_canonical_action_ir_events {
 return LinkedSpec::ActionRewriter::_build_canonical_action_ir_events(@_)
}

#------------------------------------------------------------------------------
# Function: _lower_action_code_from_canonical_ir
# Purpose : Apply lowering contracts by replaying canonical helper events on
#           the original source string while preserving non-helper regions.
# Args    : ($label, $code, $rewrite_rules, $canonical_ir_diag)
# Returns : lowered code string
#------------------------------------------------------------------------------
sub _lower_action_code_from_canonical_ir {
 return LinkedSpec::ActionRewriter::_lower_action_code_from_canonical_ir(@_)
}

#------------------------------------------------------------------------------
# Function: _accumulate_action_rewrite_diagnostics
# Purpose : Merge per-chunk diagnostics into a rule-level accumulator used for
#           metadata emission and migration readiness reporting.
# Args    : ($acc, $diag)
# Returns : updated accumulator hashref
#------------------------------------------------------------------------------
sub _accumulate_action_rewrite_diagnostics {
 return LinkedSpec::ActionRewriter::_accumulate_action_rewrite_diagnostics(@_)
}

#------------------------------------------------------------------------------
# Function: _rewrite_action_code_with_diagnostics
# Purpose : One-stop action rewrite pipeline: helper IR scan, canonical IR
#           assembly, lowering, unresolved detection, and diag packaging.
# Args    : ($label, $code, $rewrite_rules)
# Returns : ($rewritten_code, $diag_hashref)
#------------------------------------------------------------------------------
sub _rewrite_action_code_with_diagnostics {
 return LinkedSpec::ActionRewriter::_rewrite_action_code_with_diagnostics(@_)
}
#------------------------------------------------------------------------------
# Function: _build_action_rewrite_rules
# Purpose : Compile apply-ready rewrite rules from lowering contracts.
# Args    : ($label)
# Returns : arrayref rewrite rules
#------------------------------------------------------------------------------
sub _build_action_rewrite_rules {
 return LinkedSpec::ActionRewriter::_build_action_rewrite_rules(@_)
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
# Function: _resolve_local_spec_path
# Purpose : Resolve a spec name/path via direct file match, local <name>.spec,
#           then module-relative specs/ lookup.
# Args    : ($spec_name)
# Returns : resolved file path or undef
#------------------------------------------------------------------------------
sub _resolve_local_spec_path {
 return LinkedSpec::Resolver::_resolve_local_spec_path(@_)
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
 _apply_trace_options(\%opt_hash) if %opt_hash;
 my $trace_scope = trace_enter('LinkedSpec::get_parser', {
  spec_name => $spec_name,
  option_keys => [sort keys %opt_hash],
 }, DUMP_LOW);

 unless (LinkedSpec::Resolver::validate_spec_name($spec_name, $trace_scope)) {
  return undef
 }

 my $spec_path = LinkedSpec::Resolver::resolve_spec_path($spec_name, $trace_scope);
 return undef unless defined $spec_path;

 my $content = LinkedSpec::Resolver::load_spec_content($spec_path, $trace_scope);
 return undef unless defined $content;
 my @forward_opts = @opts;
 if (%opt_hash && exists $opt_hash{trace_reset_log}) {
  @forward_opts = ();
  my @kv = @opts;
  while (@kv) {
   my ($k, $v) = splice(@kv, 0, 2);
   next if defined($k) && $k eq 'trace_reset_log';
   push @forward_opts, $k, $v;
  }
 }
 my $parser = Get(\$content, @forward_opts);
 trace_decision('get_parser_compilation_result', defined($parser) ? 1 : 0, defined($parser) ? 'parser coderef generated' : 'Get() returned undef', DUMP_MEDIUM);
 trace_exit(
  $trace_scope,
  {
   status => defined($parser) ? 'ok' : 'error',
   spec_path => $spec_path,
   parser_ref => ref($parser) || '',
  },
  DUMP_LOW
 );
 return $parser;
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
