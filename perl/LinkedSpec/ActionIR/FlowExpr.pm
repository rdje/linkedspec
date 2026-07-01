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

 if ($trimmed =~ /^(?:array|a)\s*\(/o) {
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
  return 1 if defined($sym) && length($sym) && $inner =~ /^(?:(?:array|a)\s*\(\s*\w+\s*\)|\w+)$/o;
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

 if ($trimmed =~ /^(?:hash|h)\s*\(/o) {
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
 # resolve as an array (array-first precedence), so a bare `copy(x)` / `copy(a(x))` stays array-only.
 if ($method eq 'copy') {
  my $copy_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
  return 0 unless $copy_args;
  my $inner = $trim_action_ir_value->($copy_args->[0]);
  return 0 unless defined($inner) && length($inner);
  my $array_sym = $extract_array_symbol_name->($inner);
  return 0 if defined($array_sym) && length($array_sym) && $inner =~ /^(?:(?:array|a)\s*\(\s*\w+\s*\)|\w+)$/o;
  my $hash_sym = $extract_hash_symbol_name->($inner);
  return 1 if defined($hash_sym) && length($hash_sym) && $inner =~ /^(?:(?:hash|h)\s*\(\s*\w+\s*\)|\w+)$/o;
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

 return undef unless defined $arg_expr;
 my $trimmed = $trim_action_ir_value->($arg_expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ /^(?:array|a)\s*\(/o) {
  my $array_symbol = $extract_array_symbol_name->($trimmed);
  return "(!\@$array_symbol)" if defined $array_symbol;
 }

 if ($trimmed =~ /^(?:hash|h)\s*\(/o) {
  my $hash_symbol = $extract_hash_symbol_name->($trimmed);
  return "(!scalar(keys %$hash_symbol))" if defined $hash_symbol;
 }

 my $scalar_symbol = $extract_scalar_symbol_name->($trimmed);
 if (defined $scalar_symbol) {
  return "(!defined(\$$scalar_symbol) || \$$scalar_symbol eq '')";
 }

 my $lowered = $lower_method_value_expr->($trimmed);
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
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');

 return undef unless defined $arg_expr;
 my $trimmed = $trim_action_ir_value->($arg_expr);
 return undef unless defined($trimmed) && length($trimmed);

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
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 return '1' if $trimmed eq 'true';
 return '0' if $trimmed eq 'false';
 my $literal = $lower_primitive_literal_expr->($trimmed);
 return $literal if defined($literal);

 # SPEC-FORMAT-TERSE.1.4.1 — the terse renames `cat` (== concat) and `copy` (== array_copy/
 # hash_copy) are recognized here too so a composite/assignment-source value lowers identically.
 if ($trimmed =~ /^(?:scalaref|scalar|s|array|a|hash|h|hash_copy|trim|lowercase|uppercase|length|replace_substr|rm_prefix|rm_suffix|concat|cat|num_abs|num_floor|num_ceil|num_round|num_sum|num_avg|num_median|num_range|num_add|num_sub|num_mul|num_div|num_mod|num_clamp|num_min|num_max|abs|floor|ceil|round|sum|avg|median|range|add|sub|mul|div|mod|clamp|min|max|starts_with|ends_with|contains_substr|matches|coalesce_nonempty|count|first|last|drop_front|take|slice|take_last|drop_back|concat_arrays|split_tagged_records|sorted|reversed|contains|index_of|count_keys|sorted_keys|sorted_values|has_key|merge_hash|set_key|rename_key|drop_keys|pick_keys|join_values|coalesce|array_copy|copy)\s*\(/o) {
  my $lowered_value = $lower_method_value_expr->($trimmed);
  return $lowered_value if defined($lowered_value) && length($lowered_value);
 }

 my $call = $parse_method_function_expr->($trimmed);
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
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, undef);
  return undef unless $effective_args && @$effective_args;
  my @parts = map { _lower_flow_composite_expr($_, $deps) } @$effective_args;
  return undef if grep { !defined($_) || !length($_) } @parts;
  my $joiner = $method eq 'or' ? ' || ' : ' && ';
  return '('.join($joiner, map { "($_)" } @parts).')';
 }

 if ($method eq 'not') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return undef unless $effective_args;
  my $value = _lower_flow_composite_expr($effective_args->[0], $deps);
  return undef unless defined($value) && length($value);
  return "(!($value))";
 }

 if ($method eq 'is_empty') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return undef unless $effective_args;
  return _lower_is_empty_expr($effective_args->[0], $deps);
 }

 if ($method eq 'is_defined') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return undef unless $effective_args;
  my $target_expr = _lower_defined_target_expr($effective_args->[0], $deps);
  return undef unless defined($target_expr) && length($target_expr);
  return "defined($target_expr)";
 }

 if ($method eq 'is_undefined') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return undef unless $effective_args;
  my $target_expr = _lower_defined_target_expr($effective_args->[0], $deps);
  return undef unless defined($target_expr) && length($target_expr);
  return "(!defined($target_expr))";
 }

 if ($method eq 'is_nonempty') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return undef unless $effective_args;
  my $empty_expr = _lower_is_empty_expr($effective_args->[0], $deps);
  return undef unless defined($empty_expr) && length($empty_expr);
  return "(!($empty_expr))";
 }

 if (exists $string_compare_ops{$method}) {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);
  return undef unless $effective_args;
  my $lhs = _lower_flow_composite_expr($effective_args->[0], $deps);
  my $rhs = _lower_flow_composite_expr($effective_args->[1], $deps);
  return undef unless defined($lhs) && length($lhs);
  return undef unless defined($rhs) && length($rhs);
  return "($lhs $method $rhs)";
 }

 if (exists $numeric_compare_ops{$method}) {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);
  return undef unless $effective_args;
  my $lhs = _lower_flow_composite_expr($effective_args->[0], $deps);
  my $rhs = _lower_flow_composite_expr($effective_args->[1], $deps);
  return undef unless defined($lhs) && length($lhs);
  return undef unless defined($rhs) && length($rhs);
  return "($lhs $numeric_compare_ops{$method} $rhs)";
 }

 if ($method eq 'matches') {
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);
  return undef unless $effective_args;
  my $lhs = _lower_flow_composite_expr($effective_args->[0], $deps);
  my $rhs = _lower_flow_composite_expr($effective_args->[1], $deps);
  return undef unless defined($lhs) && length($lhs);
  return undef unless defined($rhs) && length($rhs);
  return "($lhs =~ $rhs)";
 }

 return $trimmed
}

1;
