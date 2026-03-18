package LinkedSpec::ActionIR::FlowExpr;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_pkg {
 my ($pkg) = @_;
 (my $path = "$pkg.pm") =~ s{::}{/}g;
 require $path;
 return $pkg
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::FlowExpr::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
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

sub _require_pkg_cb {
 my ($pkg, $name) = @_;
 return _call_preserving_err(sub {
  _require_pkg($pkg) unless $pkg->can($name);
  my $code = $pkg->can($name);
  die "(LinkedSpec::ActionIR::FlowExpr::_require_pkg_cb) -E- missing callback '$pkg\::$name'"
   unless ref($code) eq 'CODE';
  return $code
 })
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return _call_preserving_err(sub {
  return {
   trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
   extract_array_symbol_name => _require_pkg_cb($pkg, '_extract_array_symbol_name'),
   extract_hash_symbol_name => _require_pkg_cb($pkg, '_extract_hash_symbol_name'),
   extract_scalar_symbol_name => _require_pkg_cb($pkg, '_extract_scalar_symbol_name'),
   lower_method_value_expr => _require_pkg_cb($pkg, '_lower_method_value_expr'),
   parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
   normalize_method_args_with_optional_scope => _require_pkg_cb($pkg, '_normalize_method_args_with_optional_scope'),
  }
 })
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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');
 my $extract_array_symbol_name = _require_dep($deps, 'extract_array_symbol_name');

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
 return 1 if $method =~ /^(?:array|array_copy|array_values|sorted|sorted_keys|sorted_values|tail|drop_front|take|take_last|drop_last|drop_back|concat_arrays|split|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)$/o;

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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');
 my $extract_hash_symbol_name = _require_dep($deps, 'extract_hash_symbol_name');

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
 return 1 if $method =~ /^(?:hash|merge_hash|set_key|rename_key|drop_keys|pick_keys)$/o;

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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $extract_array_symbol_name = _require_dep($deps, 'extract_array_symbol_name');
 my $extract_hash_symbol_name = _require_dep($deps, 'extract_hash_symbol_name');
 my $extract_scalar_symbol_name = _require_dep($deps, 'extract_scalar_symbol_name');
 my $lower_method_value_expr = _require_dep($deps, 'lower_method_value_expr');

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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $lower_method_value_expr = _require_dep($deps, 'lower_method_value_expr');
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');

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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $lower_method_value_expr = _require_dep($deps, 'lower_method_value_expr');
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ /^(?:scalaref|scalar|array|hash|trim|lowercase|uppercase|length|replace_substr|rm_prefix|rm_suffix|concat|num_abs|num_floor|num_ceil|num_round|num_add|num_sub|num_mul|num_div|num_mod|num_clamp|num_min|num_max|starts_with|ends_with|contains_substr|matches|coalesce_nonempty|count|first|last|tail|drop_front|take|take_last|drop_last|drop_back|concat_arrays|sorted|contains|count_keys|sorted_keys|sorted_values|has_key|merge_hash|set_key|rename_key|drop_keys|pick_keys|join_values|coalesce|array_copy|array_values)\s*\(/o) {
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
