#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::FlowExpr
# Purpose: Flow-expression lowering owner for composite truthiness checks,
#          emptiness predicates, and method-like condition assembly.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::FlowExpr;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();
use LinkedSpec::ActionIR::Trace ();

use constant ACTIONIR_TRACE_OWNER => 'flow_expr';

sub _trace_flow_decision {
 my (%args) = @_;
 return LinkedSpec::ActionIR::Trace::decision(
  owner => ACTIONIR_TRACE_OWNER,
  phase => $args{phase},
  label => $args{label},
  decision => $args{decision},
  taken => $args{taken},
  context => $args{context},
 );
}

sub _trace_flow_enter {
 my ($phase, $label, $details) = @_;
 return LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => ACTIONIR_TRACE_OWNER,
  phase => $phase,
  label => $label,
  details => $details,
 );
}

sub _trace_flow_exit {
 my ($scope, $details) = @_;
 return LinkedSpec::ActionIR::Trace::exit_scope($scope, $details);
}

#------------------------------------------------------------------------------
# Function: default_deps_for_package
# Purpose : Build the default flow-expression dependency bundle for one owner
#           package.
# Args    : ($pkg)
# Returns : hashref of dependency callbacks
#------------------------------------------------------------------------------
sub default_deps_for_package {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::build_dep_map(
  __PACKAGE__,
  $pkg,
  [
   'trim_action_ir_value',
   'extract_array_symbol_name',
   'extract_hash_symbol_name',
   'extract_scalar_symbol_name',
   'lower_method_value_expr',
   'lower_primitive_literal_expr',
   'lower_direct_nested_access_value_expr',
   'parse_method_function_expr',
   'normalize_method_args_with_optional_scope',
  ],
 )
}

#------------------------------------------------------------------------------
# Function: _looks_like_array_value_expr
# Purpose : Infer whether a method-like value expression should be treated as an
#           array-valued aggregate for emptiness checks.
# Args    : ($expr, $deps)
# Returns : 1 when the expression is array-like, else 0
#------------------------------------------------------------------------------
sub _looks_like_array_value_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::FlowExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $extract_array_symbol_name = $require_dep->('extract_array_symbol_name');

 return 0 unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return 0 unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ /^array\s*\(/o) {
  return 1;
 }

 my $array_symbol = $extract_array_symbol_name->($trimmed);
 if (defined($array_symbol) && length($array_symbol) && $trimmed =~ /^\w+$/o) {
  return 1;
 }

 my $call = $parse_method_function_expr->($trimmed);
 return 0 unless $call;

 my $method = $call->{method} // '';
 return 1 if $method =~ /^(?:array|array_copy|sorted|reversed|sorted_keys|sorted_values|drop_front|take|slice|take_last|drop_back|concat_arrays|split_tagged_records|split|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)$/o;

 # SPEC-FORMAT-TERSE.1.4.1 — the unified terse `copy(X)` is array-like iff X names an array
 # symbol (array-first resolution, mirroring the lowering dispatch); a bare `copy(x)` is array-like.
 if ($method eq 'copy') {
  my $copy_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
  return 0 unless $copy_args;
  my $inner = $trim_action_ir_value->($copy_args->[0]);
  return 0 unless defined($inner) && length($inner);
  my $sym = $extract_array_symbol_name->($inner);
  return 1 if defined($sym) && length($sym) && $inner =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o;
  return 0;
 }

 if ($method eq 'coalesce') {
  my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 2, undef);
  return 0 unless $effective_args && @$effective_args;

  my $saw_array_like = 0;
  foreach my $arg (@$effective_args) {
   next unless defined $arg;
   return 0 if _looks_like_hash_value_expr($arg, $deps);
   $saw_array_like ||= _looks_like_array_value_expr($arg, $deps);
  }
  return $saw_array_like ? 1 : 0;
 }

 return 0;
}

#------------------------------------------------------------------------------
# Function: _looks_like_hash_value_expr
# Purpose : Infer whether a method-like value expression should be treated as a
#           hash-valued aggregate for emptiness checks.
# Args    : ($expr, $deps)
# Returns : 1 when the expression is hash-like, else 0
#------------------------------------------------------------------------------
sub _looks_like_hash_value_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::FlowExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $extract_hash_symbol_name = $require_dep->('extract_hash_symbol_name');
 my $extract_array_symbol_name = $require_dep->('extract_array_symbol_name');

 return 0 unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return 0 unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ /^hash\s*\(/o) {
  return 1;
 }

 my $hash_symbol = $extract_hash_symbol_name->($trimmed);
 if (defined($hash_symbol) && length($hash_symbol) && $trimmed =~ /^\w+$/o) {
  return 1;
 }

 my $call = $parse_method_function_expr->($trimmed);
 return 0 unless $call;

 my $method = $call->{method} // '';
 return 1 if $method =~ /^(?:hash|hash_copy|merge_hash|set_key|rename_key|drop_keys|pick_keys)$/o;

 # SPEC-FORMAT-TERSE.1.4.1 — `copy(X)` is hash-like iff X names a hash symbol AND does not
 # resolve as an array (array-first precedence), so a bare `copy(x)` / `copy(array(x))` stays array-only.
 if ($method eq 'copy') {
  my $copy_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
  return 0 unless $copy_args;
  my $inner = $trim_action_ir_value->($copy_args->[0]);
  return 0 unless defined($inner) && length($inner);
  my $array_sym = $extract_array_symbol_name->($inner);
  return 0 if defined($array_sym) && length($array_sym) && $inner =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o;
  my $hash_sym = $extract_hash_symbol_name->($inner);
  return 1 if defined($hash_sym) && length($hash_sym) && $inner =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o;
  return 0;
 }

 if ($method eq 'coalesce') {
  my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 2, undef);
  return 0 unless $effective_args && @$effective_args;

  my $saw_hash_like = 0;
  foreach my $arg (@$effective_args) {
   next unless defined $arg;
   return 0 if _looks_like_array_value_expr($arg, $deps);
   $saw_hash_like ||= _looks_like_hash_value_expr($arg, $deps);
  }
  return $saw_hash_like ? 1 : 0;
 }

 return 0;
}

#------------------------------------------------------------------------------
# Function: _lower_is_empty_expr
# Purpose : Lower `is_empty(...)` checks across scalar/array/general expression
#           payloads used in fluent control-flow expressions.
# Args    : ($arg_expr, $deps)
# Returns : Perl boolean expression string or undef
#------------------------------------------------------------------------------
sub _lower_is_empty_expr {
 my ($arg_expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::FlowExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $extract_array_symbol_name = $require_dep->('extract_array_symbol_name');
 my $extract_hash_symbol_name = $require_dep->('extract_hash_symbol_name');
 my $extract_scalar_symbol_name = $require_dep->('extract_scalar_symbol_name');
 my $lower_method_value_expr = $require_dep->('lower_method_value_expr');
 my $lower_direct_nested_access_value_expr = $require_dep->('lower_direct_nested_access_value_expr');

 return undef unless defined $arg_expr;
 my $trimmed = $trim_action_ir_value->($arg_expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ /^array\s*\(/o) {
  my $array_symbol = $extract_array_symbol_name->($trimmed);
  return "(!\@$array_symbol)" if defined $array_symbol;
 }

 if ($trimmed =~ /^hash\s*\(/o) {
  my $hash_symbol = $extract_hash_symbol_name->($trimmed);
  return "(!scalar(keys %$hash_symbol))" if defined $hash_symbol;
 }

 my $scalar_symbol = $extract_scalar_symbol_name->($trimmed);
 if (defined $scalar_symbol) {
  return "(!defined(\$$scalar_symbol) || \$$scalar_symbol eq '')";
 }

 my $lowered = $lower_direct_nested_access_value_expr->($trimmed);
 $lowered = $lower_method_value_expr->($trimmed) unless defined($lowered) && length($lowered);
 $lowered = $trimmed unless defined($lowered) && length($lowered);

 if (_looks_like_array_value_expr($trimmed, $deps)) {
  return 'do { my $__ls_empty_array = '.$lowered.'; (!defined($__ls_empty_array) || !@{$__ls_empty_array}) }';
 }

 if (_looks_like_hash_value_expr($trimmed, $deps)) {
  return 'do { my $__ls_empty_hash = '.$lowered.'; (!defined($__ls_empty_hash) || !scalar(keys %{$__ls_empty_hash})) }';
 }

 return "(!($lowered))"
}

#------------------------------------------------------------------------------
# Function: _lower_defined_target_expr
# Purpose : Lower `is_defined(...)` / `is_undefined(...)` targets into Perl
#           value expressions whose definedness can then be tested directly.
# Args    : ($arg_expr, $deps)
# Returns : Perl value expression string or undef
#------------------------------------------------------------------------------
sub _lower_defined_target_expr {
 my ($arg_expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::FlowExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_method_value_expr = $require_dep->('lower_method_value_expr');
 my $lower_direct_nested_access_value_expr = $require_dep->('lower_direct_nested_access_value_expr');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');

 return undef unless defined $arg_expr;
 my $trimmed = $trim_action_ir_value->($arg_expr);
 return undef unless defined($trimmed) && length($trimmed);
 if ($trimmed =~ /^:([A-Za-z_][A-Za-z0-9_]*)$/o) {
  return 'do { my $__ls_actionir_unsupported_helper = "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read"; undef }';
 }
 return '$'.$trimmed if $trimmed =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;

 my $direct_access = $lower_direct_nested_access_value_expr->($trimmed);
 return $direct_access if defined($direct_access) && length($direct_access);

 my $call = $parse_method_function_expr->($trimmed);
 if ($call) {
  my $lowered = $lower_method_value_expr->($trimmed);
  return undef unless defined($lowered) && length($lowered);
  return $lowered;
 }

 return $trimmed;
}

#------------------------------------------------------------------------------
# Function: _lower_flow_composite_expr
# Purpose : Recursively lower Lisp-like fluent expression trees so control-flow
#           conditions (`if`, `elseif`, `switch`) and value surfaces share one
#           expression-lowering path.
# Args    : ($expr, $deps)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_flow_composite_expr {
 my ($expr, $deps) = @_;
 my $scope = _trace_flow_enter(
  'lower_flow_composite_expr',
  'expr',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_flow_decision(
   phase => 'lower_flow_composite_expr',
   label => 'expr',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_flow_exit(
   $scope,
   {
    status => defined($result) && length($result) ? 'ok' : 'undef',
    decision => $decision,
    result => defined($result) ? $result : '<undef>',
   },
  );
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::FlowExpr::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_method_value_expr = $require_dep->('lower_method_value_expr');
 my $lower_primitive_literal_expr = $require_dep->('lower_primitive_literal_expr');
 my $lower_direct_nested_access_value_expr = $require_dep->('lower_direct_nested_access_value_expr');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 return $finish->(undef, 'missing_expr', {}) unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return $finish->(undef, 'empty_expr', {}) unless defined($trimmed) && length($trimmed);
 return $finish->('1', 'boolean_true', { expr => $trimmed }) if $trimmed eq 'true';
 return $finish->('0', 'boolean_false', { expr => $trimmed }) if $trimmed eq 'false';
 if ($trimmed =~ /^:([A-Za-z_][A-Za-z0-9_]*)$/o) {
  return $finish->(
   'do { my $__ls_actionir_unsupported_helper = "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read"; undef }',
   'retired_colon_scalar_slot',
   { symbol => $1 },
  );
 }
 my $literal = $lower_primitive_literal_expr->($trimmed);
 return $finish->($literal, 'primitive_literal', { expr => $trimmed }) if defined($literal);

 my $direct_access = $lower_direct_nested_access_value_expr->($trimmed);
 return $finish->($direct_access, 'direct_nested_access', { expr => $trimmed })
  if defined($direct_access) && length($direct_access);

 # SPEC-FORMAT-TERSE.1.4.1 — the terse renames `cat` (== concat) and `copy` (== array_copy/
 # hash_copy) are recognized here too so a composite/assignment-source value lowers identically.
 if ($trimmed =~ /^(?:array|hash|hash_copy|trim|lowercase|uppercase|length|replace_substr|rm_prefix|rm_suffix|concat|cat|num_abs|num_floor|num_ceil|num_round|num_sum|num_avg|num_median|num_range|num_add|num_sub|num_mul|num_div|num_mod|num_clamp|num_min|num_max|abs|floor|ceil|round|sum|avg|median|range|add|sub|mul|div|mod|clamp|min|max|str_eq|str_ne|str_gt|str_ge|str_lt|str_le|starts_with|ends_with|contains_substr|matches|coalesce_nonempty|count|first|last|drop_front|take|slice|take_last|drop_back|concat_arrays|split_tagged_records|sorted|reversed|contains|index_of|count_keys|sorted_keys|sorted_values|has_key|merge_hash|set_key|rename_key|drop_keys|pick_keys|join_values|coalesce|array_copy|copy)\s*\(/o) {
  my $lowered_value = $lower_method_value_expr->($trimmed);
  return $finish->($lowered_value, 'method_value_family', { expr => $trimmed })
   if defined($lowered_value) && length($lowered_value);
 }

 my $call = $parse_method_function_expr->($trimmed);
 unless ($call) {
  # SPEC-FORMAT-TERSE.15.2.2 — value-position-is-variable (ADR 0019): a bare identifier
  # reaching this point is not `true`/`false`, not retired colon scalar-slot syntax, not a
  # primitive literal, not direct nested access, and not a helper/method call — so in a value
  # or condition position it is a variable/parameter read.
  # Guarded to a lone identifier so multi-token passthrough expressions stay verbatim.
  return $finish->('$'.$trimmed, 'bare_variable_read', { symbol => $trimmed })
   if $trimmed =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  return $finish->($trimmed, 'passthrough_no_call', { expr => $trimmed });
 }

 my $method = $call->{method} // '';
 my $args = $call->{args} || [];
 if ($method =~ /^(?:[+\-*\/%]|==|!=|>=|<=|>|<)$/o) {
  my $lowered_value = $lower_method_value_expr->($trimmed);
  return $finish->($lowered_value, 'symbol_operator_method_value', { method => $method })
   if defined($lowered_value) && length($lowered_value);
 }
 my %string_compare_ops = (
  str_eq => 'eq',
  str_ne => 'ne',
  str_gt => 'gt',
  str_ge => 'ge',
  str_lt => 'lt',
  str_le => 'le',
 );
 my %numeric_compare_ops = (
  '=='   => '==',
  '!='   => '!=',
  '>'    => '>',
  '>='   => '>=',
  '<'    => '<',
  '<='   => '<=',
  eq     => '==',
  ne     => '!=',
  gt     => '>',
  ge     => '>=',
  lt     => '<',
  le     => '<=',
  num_eq => '==',
  num_ne => '!=',
  num_gt => '>',
  num_ge => '>=',
  num_lt => '<',
  num_le => '<=',
 );

 if ($method eq 'or' || $method eq 'and') {
  my $effective_args = $args;
  return $finish->(undef, 'logical_missing_args', { method => $method }) unless $effective_args && @$effective_args;
  my @parts = map { _lower_flow_composite_expr($_, $deps) } @$effective_args;
  return $finish->(undef, 'logical_arg_lowering_failed', { method => $method }) if grep { !defined($_) || !length($_) } @parts;
  my $joiner = $method eq 'or' ? ' || ' : ' && ';
  return $finish->('('.join($joiner, map { "($_)" } @parts).')', 'logical_'.$method, { arg_count => scalar(@parts) });
 }

 if ($method eq 'not') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return $finish->(undef, 'not_missing_arg', {}) unless $effective_args;
  my $value = _lower_flow_composite_expr($effective_args->[0], $deps);
  return $finish->(undef, 'not_arg_lowering_failed', {}) unless defined($value) && length($value);
  return $finish->("(!($value))", 'not', {});
 }

 if ($method eq 'is_empty') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return $finish->(undef, 'is_empty_missing_arg', {}) unless $effective_args;
  return $finish->(_lower_is_empty_expr($effective_args->[0], $deps), 'is_empty', {});
 }

 if ($method eq 'is_defined') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return $finish->(undef, 'is_defined_missing_arg', {}) unless $effective_args;
  my $target_expr = _lower_defined_target_expr($effective_args->[0], $deps);
  return $finish->(undef, 'is_defined_target_lowering_failed', {}) unless defined($target_expr) && length($target_expr);
  return $finish->("defined($target_expr)", 'is_defined', {});
 }

 if ($method eq 'is_undefined') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return $finish->(undef, 'is_undefined_missing_arg', {}) unless $effective_args;
  my $target_expr = _lower_defined_target_expr($effective_args->[0], $deps);
  return $finish->(undef, 'is_undefined_target_lowering_failed', {}) unless defined($target_expr) && length($target_expr);
  return $finish->("(!defined($target_expr))", 'is_undefined', {});
 }

 if ($method eq 'is_nonempty') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return $finish->(undef, 'is_nonempty_missing_arg', {}) unless $effective_args;
  my $empty_expr = _lower_is_empty_expr($effective_args->[0], $deps);
  return $finish->(undef, 'is_nonempty_arg_lowering_failed', {}) unless defined($empty_expr) && length($empty_expr);
  return $finish->("(!($empty_expr))", 'is_nonempty', {});
 }

 if (exists $string_compare_ops{$method}) {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);
  return $finish->(undef, 'string_compare_missing_args', { method => $method }) unless $effective_args;
  my $lhs = _lower_flow_composite_expr($effective_args->[0], $deps);
  my $rhs = _lower_flow_composite_expr($effective_args->[1], $deps);
  return $finish->(undef, 'string_compare_lhs_failed', { method => $method }) unless defined($lhs) && length($lhs);
  return $finish->(undef, 'string_compare_rhs_failed', { method => $method }) unless defined($rhs) && length($rhs);
  return $finish->("($lhs $string_compare_ops{$method} $rhs)", 'string_compare', { method => $method });
 }

 if (exists $numeric_compare_ops{$method}) {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);
  return $finish->(undef, 'numeric_compare_missing_args', { method => $method }) unless $effective_args;
  my $lhs = _lower_flow_composite_expr($effective_args->[0], $deps);
  my $rhs = _lower_flow_composite_expr($effective_args->[1], $deps);
  return $finish->(undef, 'numeric_compare_lhs_failed', { method => $method }) unless defined($lhs) && length($lhs);
  return $finish->(undef, 'numeric_compare_rhs_failed', { method => $method }) unless defined($rhs) && length($rhs);
  return $finish->("($lhs $numeric_compare_ops{$method} $rhs)", 'numeric_compare', { method => $method });
 }

 if ($method eq 'matches') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);
  return $finish->(undef, 'matches_missing_args', {}) unless $effective_args;
  my $lhs = _lower_flow_composite_expr($effective_args->[0], $deps);
  my $rhs = _lower_flow_composite_expr($effective_args->[1], $deps);
  return $finish->(undef, 'matches_lhs_failed', {}) unless defined($lhs) && length($lhs);
  return $finish->(undef, 'matches_rhs_failed', {}) unless defined($rhs) && length($rhs);
  return $finish->("($lhs =~ $rhs)", 'matches', {});
 }

 return $finish->($trimmed, 'passthrough_unknown_method', { method => $method })
}

1;
