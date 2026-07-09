package LinkedSpec::ActionIR::DeclareMethod;

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

use constant ACTIONIR_TRACE_OWNER => 'declare_method';

sub _trace_declare_decision {
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

sub _trace_declare_enter {
 my ($phase, $label, $details) = @_;
 return LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => ACTIONIR_TRACE_OWNER,
  phase => $phase,
  label => $label,
  details => $details,
 );
}

sub _trace_declare_exit {
 my ($scope, $details) = @_;
 return LinkedSpec::ActionIR::Trace::exit_scope($scope, $details);
}

#------------------------------------------------------------------------------
# Package : LinkedSpec::ActionIR::DeclareMethod
# Purpose : ActionIR owner for current set(...) lowering and backend declaration
#           initializer helpers.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function: default_deps_for_package
# Purpose : Build the default callback map exported by this owner for current
#           assignment lowering and backend declaration initializers.
# Args    : ($pkg)
# Returns : hashref dependency map
#------------------------------------------------------------------------------
sub default_deps_for_package {
 my ($pkg) = @_;
 return LinkedSpec::OwnerDispatch::build_dep_map(
  __PACKAGE__,
  $pkg,
  [
   'trim_action_ir_value',
   { dep => 'parse_method_function_expr', pkg => 'LinkedSpec::ActionIR::MethodExpr' },
   { dep => 'normalize_method_args_with_optional_scope', pkg => 'LinkedSpec::ActionIR::MethodExpr' },
   { dep => 'split_top_level_csv', pkg => 'LinkedSpec::ActionIR::MethodExpr' },
   'lower_flow_composite_expr',
   'lower_method_value_expr',
   'lower_assign_statement',
  ],
 )
}

sub _split_declare_symbol_names {
 my ($raw_names, $deps) = @_;
 return [] unless defined $raw_names;

 my @names = grep { length($_) } map {
  my $name = $_;
  $name =~ s/^\s*|\s*$//go;
  $name;
 } split /\s*,\s*/o, $raw_names;
 @names = grep { /^\w+$/o } @names;
 return \@names
}

sub _parse_declare_binding_entry {
 my ($entry, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::DeclareMethod::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 return undef unless defined $entry;
 my $trimmed = $trim_action_ir_value->($entry);
 return undef unless defined($trimmed) && length($trimmed);

 return {name => $1} if $trimmed =~ /^(?<name>\w+)$/o;
 if ($trimmed =~ /^(?<name>\w+)\s*=\s*(?<init>.+)$/s) {
  my $init = $trim_action_ir_value->($+{init});
  return undef unless defined($init) && length($init);
  return {name => $+{name}, init => $init};
 }
 return undef
}

sub _lower_declare_value_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::DeclareMethod::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_flow_composite_expr = $require_dep->('lower_flow_composite_expr');
 my $lower_method_value_expr = $require_dep->('lower_method_value_expr');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $lowered = $lower_flow_composite_expr->($trimmed);
 return $lowered if defined($lowered) && length($lowered) && $lowered ne $trimmed;

 $lowered = $lower_method_value_expr->($trimmed);
 return $lowered if defined($lowered) && length($lowered);

 return $trimmed
}

sub _lower_declare_initializer_expr {
 my ($type, $expr, $deps) = @_;
 my $scope = _trace_declare_enter(
  'lower_declare_initializer_expr',
  defined($type) ? $type : '<undef>',
  {
   type => defined($type) ? $type : '<undef>',
   expr => defined($expr) ? $expr : '<undef>',
  },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_declare_decision(
   phase => 'lower_declare_initializer_expr',
   label => defined($type) ? $type : '<undef>',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_declare_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::DeclareMethod::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 return $finish->(undef, 'missing_type', {}) unless defined $type;
 return $finish->(undef, 'missing_expr', { type => $type }) unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return $finish->(undef, 'empty_expr', { type => $type }) unless defined($trimmed) && length($trimmed);

 if ($type eq 'array') {
  my $array_ctor = $parse_method_function_expr->($trimmed);
  if ($array_ctor && $array_ctor->{method} eq 'array') {
   my $items = $array_ctor->{args} || [];
   return $finish->(undef, 'array_ctor_args_invalid', { type => $type }) unless ref($items) eq 'ARRAY';
   my @lowered_items = map { _lower_declare_value_expr($_, $deps) } @$items;
   return $finish->(undef, 'array_ctor_item_failed', { type => $type }) if grep { !defined($_) || !length($_) } @lowered_items;
   return $finish->('('.join(', ', @lowered_items).')', 'array_constructor', { item_count => scalar(@lowered_items) });
  }
  if ($trimmed =~ /^\[.*\]$/s) {
   my $shape_expr = _lower_declare_value_expr($trimmed, $deps);
   return $finish->(undef, 'array_shape_lowering_failed', { type => $type }) unless defined($shape_expr) && length($shape_expr);
   return $finish->('('.$+{payload}.')', 'array_shape', { type => $type }) if $shape_expr =~ /^\[(?<payload>.*)\]$/s;
   return $finish->(undef, 'array_shape_unwrap_failed', { type => $type });
  }
  # `copy` is scalar-context ambiguous when parsed as a method value. In array
  # declarations, prefer array snapshot semantics.
  if ($array_ctor && ($array_ctor->{method} eq 'copy' || $array_ctor->{method} eq 'sorted' || $array_ctor->{method} eq 'reversed' || $array_ctor->{method} eq 'sorted_keys' || $array_ctor->{method} eq 'sorted_values' || $array_ctor->{method} eq 'concat_arrays' || $array_ctor->{method} eq 'split_tagged_records' || $array_ctor->{method} eq 'entry_groups' || $array_ctor->{method} eq 'match_groups')) {
   my $derived_expr = _lower_declare_value_expr($trimmed, $deps);
   return $finish->(undef, 'array_derived_lowering_failed', { method => $array_ctor->{method} }) unless defined($derived_expr) && length($derived_expr);
   return $finish->('('.$+{payload}.')', 'array_derived_unwrapped', { method => $array_ctor->{method} }) if $derived_expr =~ /^\[(?<payload>.*)\]$/s;
   return $finish->('(do { my $__ls_array_init = '.$derived_expr.'; defined($__ls_array_init) ? @{$__ls_array_init} : () })', 'array_derived_guarded', { method => $array_ctor->{method} });
  }
 }

 if ($type eq 'hash') {
  my $hash_ctor = $parse_method_function_expr->($trimmed);
  if ($hash_ctor && $hash_ctor->{method} eq 'hash') {
   my $items = $hash_ctor->{args} || [];
   return $finish->(undef, 'hash_ctor_args_invalid', { type => $type }) unless ref($items) eq 'ARRAY';
   return $finish->(undef, 'hash_ctor_odd_arity', { item_count => scalar(@$items) }) unless @$items % 2 == 0;
   my @pairs;
   for (my $i = 0; $i < @$items; $i += 2) {
    my $key_expr = _lower_declare_value_expr($items->[$i], $deps);
    my $val_expr = _lower_declare_value_expr($items->[$i + 1], $deps);
    return $finish->(undef, 'hash_ctor_key_failed', { pair_index => $i / 2 }) unless defined($key_expr) && length($key_expr);
    return $finish->(undef, 'hash_ctor_value_failed', { pair_index => $i / 2 }) unless defined($val_expr) && length($val_expr);
    push @pairs, $key_expr.' => '.$val_expr;
   }
   return $finish->('('.join(', ', @pairs).')', 'hash_constructor', { pair_count => scalar(@pairs) });
  }
  if ($trimmed =~ /^\{.*\}$/s) {
   my $shape_expr = _lower_declare_value_expr($trimmed, $deps);
   return $finish->(undef, 'hash_shape_lowering_failed', { type => $type }) unless defined($shape_expr) && length($shape_expr);
   return $finish->('('.$+{payload}.')', 'hash_shape', { type => $type }) if $shape_expr =~ /^\{(?<payload>.*)\}$/s;
   return $finish->(undef, 'hash_shape_unwrap_failed', { type => $type });
  }
  # `copy` is ambiguous in scalar context. Hash declarations prefer hash
  # snapshot semantics and unwrap to list initializer form.
  if ($hash_ctor && ($hash_ctor->{method} eq 'copy' || $hash_ctor->{method} eq 'merge_hash' || $hash_ctor->{method} eq 'set_key' || $hash_ctor->{method} eq 'rename_key' || $hash_ctor->{method} eq 'drop_keys' || $hash_ctor->{method} eq 'pick_keys' || $hash_ctor->{method} eq 'entry_map' || $hash_ctor->{method} eq 'match_map')) {
   my $derived_expr = _lower_declare_value_expr($trimmed, $deps);
   return $finish->(undef, 'hash_derived_lowering_failed', { method => $hash_ctor->{method} }) unless defined($derived_expr) && length($derived_expr);
   return $finish->('('.$+{payload}.')', 'hash_derived_unwrapped', { method => $hash_ctor->{method} }) if $derived_expr =~ /^\{(?<payload>.*)\}$/s;
   return $finish->('(do { my $__ls_hash_init = '.$derived_expr.'; defined($__ls_hash_init) ? %{$__ls_hash_init} : () })', 'hash_derived_guarded', { method => $hash_ctor->{method} });
  }
 }

 return $finish->(_lower_declare_value_expr($trimmed, $deps), 'scalar_or_passthrough', { type => $type })
}

sub _lower_assign_method_statement {
 my ($expr, $deps) = @_;
 my $scope = _trace_declare_enter(
  'lower_assign_method_statement',
  'expr',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_declare_decision(
   phase => 'lower_assign_method_statement',
   label => 'expr',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_declare_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::DeclareMethod::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $split_top_level_csv = $require_dep->('split_top_level_csv');
 my $lower_assign_statement = $require_dep->('lower_assign_statement');

 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::MethodLowering');
 my $ast_node = LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr($expr, $deps);
 if (ref($ast_node) eq 'HASH' && ($ast_node->{kind} // '') eq 'call') {
	  my $method = LinkedSpec::ActionIR::MethodLowering::_actionir_ast_statement_method($ast_node->{name}, $ast_node->{source});
	  if (defined($method) && $method eq 'set') {
   my @args;
   my $all_args_supported = 1;
   foreach my $arg (@{$ast_node->{args} || []}) {
    my $arg_expr = LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr($arg);
    if (!defined($arg_expr) || !length($arg_expr)) {
     $all_args_supported = 0;
     last;
   }
   push @args, $arg_expr;
  }
  if ($all_args_supported) {
    my $effective_args = $normalize_method_args_with_optional_scope->(\@args, 2, 2);
    if ($effective_args) {
     my $ast_lowered = $lower_assign_statement->($effective_args->[0], $effective_args->[1]);
     return $finish->($ast_lowered, 'ast_set_lowered', { arg_count => scalar(@$effective_args) })
      if defined($ast_lowered) && length($ast_lowered);
    }
    _trace_declare_decision(
     phase => 'lower_assign_method_statement',
     label => 'expr',
     decision => 'ast_set_bad_arity',
     taken => 0,
     context => { arg_count => scalar(@args) },
    );
   } else {
    _trace_declare_decision(
     phase => 'lower_assign_method_statement',
     label => 'expr',
     decision => 'ast_set_unsupported_arg',
     taken => 0,
     context => { arg_count => scalar(@args) },
    );
   }
  }
 }

 my $call = $parse_method_function_expr->($expr);
 if (!$call) {
  my $trimmed_expr = defined($expr) ? $expr : '';
  $trimmed_expr =~ s/^\s*|\s*$//go;
  if ($trimmed_expr =~ /^set\s*\(/o && substr($trimmed_expr, -1) eq ')') {
   my $open_idx = index($trimmed_expr, '(');
   my $payload = substr($trimmed_expr, $open_idx + 1, length($trimmed_expr) - $open_idx - 2);
   $call = {
    method => 'set',
    args   => $split_top_level_csv->($payload),
   };
  }
 }
 return $finish->(undef, 'not_set_call', {}) unless $call && $call->{method} eq 'set' && $expr =~ /^\s*set\s*\(/o;

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 2, 2);
 return $finish->(undef, 'set_bad_arity', {}) unless $effective_args;
 return $finish->(
  $lower_assign_statement->($effective_args->[0], $effective_args->[1]),
  'set_lowered',
  { arg_count => scalar(@$effective_args) },
 )
}

1;
