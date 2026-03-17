package LinkedSpec::ActionIR::MethodLowering;

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
 die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
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
  die "(LinkedSpec::ActionIR::MethodLowering::_require_pkg_cb) -E- missing callback '$pkg\::$name'"
   unless ref($code) eq 'CODE';
  return $code
 })
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return _call_preserving_err(sub {
  return {
   trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
   split_declare_symbol_names => _require_pkg_cb($pkg, '_split_declare_symbol_names'),
   parse_declare_binding_entry => _require_pkg_cb($pkg, '_parse_declare_binding_entry'),
   lower_declare_initializer_expr => _require_pkg_cb($pkg, '_lower_declare_initializer_expr'),
   parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
   normalize_method_args_with_optional_scope => _require_pkg_cb($pkg, '_normalize_method_args_with_optional_scope'),
   lower_scalaref_value_expr => _require_pkg_cb($pkg, '_lower_scalaref_value_expr'),
   extract_array_symbol_name => _require_pkg_cb($pkg, '_extract_array_symbol_name'),
   extract_hash_symbol_name => _require_pkg_cb($pkg, '_extract_hash_symbol_name'),
   extract_scalar_symbol_name => _require_pkg_cb($pkg, '_extract_scalar_symbol_name'),
   lower_scalar_access_key_expr => _require_pkg_cb($pkg, '_lower_scalar_access_key_expr'),
   infer_scalar_container_kind => _require_pkg_cb($pkg, '_infer_scalar_container_kind'),
   split_top_level_csv => _require_pkg_cb($pkg, '_split_top_level_csv'),
   lower_array_pipeline_expr => _require_pkg_cb($pkg, '_lower_array_pipeline_expr'),
   lower_assignment_source_expr => _require_pkg_cb($pkg, '_lower_assignment_source_expr'),
   strip_literal_delimiters => _require_pkg_cb($pkg, '_strip_literal_delimiters'),
  }
 })
}

#------------------------------------------------------------------------------
# Function: _declare_sigil_for_type
# Purpose : Map canonical declaration type name to Perl declaration sigil.
# Args    : ($type, $deps)
# Returns : sigil scalar or undef
#------------------------------------------------------------------------------
sub _declare_sigil_for_type {
 my ($type, $deps) = @_;
 return '@' if defined($type) && $type eq 'array';
 return '$' if defined($type) && $type eq 'scalar';
 return '%' if defined($type) && $type eq 'hash';
 return undef
}

#------------------------------------------------------------------------------
# Function: _declare_alias_to_type
# Purpose : Resolve declaration alias tokens to canonical declaration type.
# Args    : ($alias, $deps)
# Returns : canonical type string or undef
#------------------------------------------------------------------------------
sub _declare_alias_to_type {
 my ($alias, $deps) = @_;
 return 'array'  if defined($alias) && ($alias eq 'a' || $alias eq 'array');
 return 'scalar' if defined($alias) && ($alias eq 's' || $alias eq 'scalar');
 return 'hash'   if defined($alias) && ($alias eq 'h' || $alias eq 'hash');
 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_typed_declare_statement
# Purpose : Lower typed declaration methods into canonical Perl declaration
#           statements (`my @x`, `my $y`, `my %z`).
# Args    : ($type, $entries_or_names, $deps)
# Returns : lowered statement string or undef
#------------------------------------------------------------------------------
sub _lower_typed_declare_statement {
 my ($type, $entries_or_names, $deps) = @_;
 my $split_declare_symbol_names = _require_dep($deps, 'split_declare_symbol_names');
 my $parse_declare_binding_entry = _require_dep($deps, 'parse_declare_binding_entry');
 my $lower_declare_initializer_expr = _require_dep($deps, 'lower_declare_initializer_expr');

 my $sigil = _declare_sigil_for_type($type, $deps);
 return undef unless defined $sigil;
 my @entries;
 if (ref($entries_or_names) eq 'ARRAY') {
  @entries = @$entries_or_names;
 } else {
  my $names = $split_declare_symbol_names->($entries_or_names);
  return undef unless $names && @$names;
  @entries = @$names;
 }
 return undef unless @entries;

 my @decls;
 foreach my $entry (@entries) {
  my $binding = $parse_declare_binding_entry->($entry);
  return undef unless $binding && $binding->{name};

  my $decl = "my ${sigil}$binding->{name}";
  if (defined $binding->{init}) {
   my $init_expr = $lower_declare_initializer_expr->($type, $binding->{init});
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
# Args    : ($tag, $deps)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _normalize_method_tag_expr {
 my ($tag, $deps) = @_;
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');

 return undef unless defined $tag;
 $tag = $trim_action_ir_value->($tag);
 return undef unless defined($tag) && length($tag);
 return $tag if $tag =~ /^\".*\"$/s || $tag =~ /^'.*'$/s;
 return "\"$tag\"" if $tag =~ /^\w+$/o;
 return $tag
}

#------------------------------------------------------------------------------
# Function: _lower_method_value_expr
# Purpose : Lower method DSL value expressions (`call(...)`, `scalar(...)`,
#           `array(...)`, `merge_hash(...)`, `drop_keys(...)`,
#           `pick_keys(...)`, `sorted_keys(...)`, `sorted_values(...)`,
#           `contains(...)`,
#           `flat(...)`)
#           into Perl value expressions.
# Args    : ($expr, $deps)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_method_value_expr {
 my ($expr, $deps) = @_;
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');
 my $lower_scalaref_value_expr = _require_dep($deps, 'lower_scalaref_value_expr');
 my $extract_array_symbol_name = _require_dep($deps, 'extract_array_symbol_name');
 my $extract_hash_symbol_name = _require_dep($deps, 'extract_hash_symbol_name');
 my $lower_scalar_access_key_expr = _require_dep($deps, 'lower_scalar_access_key_expr');
 my $infer_scalar_container_kind = _require_dep($deps, 'infer_scalar_container_kind');
 my $split_top_level_csv = _require_dep($deps, 'split_top_level_csv');
 my $lower_array_pipeline_expr = _require_dep($deps, 'lower_array_pipeline_expr');
 my $lower_flat_list_value_expr = sub {
  my ($flat_expr) = @_;
  return undef unless defined $flat_expr;
  my $flat_trimmed = $trim_action_ir_value->($flat_expr);
  return undef unless defined($flat_trimmed) && length($flat_trimmed);
  my $flat_call = $parse_method_function_expr->($flat_trimmed);
  return undef unless $flat_call;

  my $method = $flat_call->{method} // '';
  if ($method eq 'flat' || $method eq 'flatten') {
   my $flat_args = $normalize_method_args_with_optional_scope->($flat_call->{args} || [], 1, 1);
   return undef unless $flat_args;
   my $container_expr = $trim_action_ir_value->($flat_args->[0]);
   return undef unless defined($container_expr) && length($container_expr);

   if ($container_expr =~ /^array\s*\(/o) {
    my $array_symbol = $extract_array_symbol_name->($container_expr);
    return undef unless defined($array_symbol) && length($array_symbol);
    return '@'.$array_symbol;
   }
   if ($container_expr =~ /^hash\s*\(/o) {
    my $hash_symbol = $extract_hash_symbol_name->($container_expr);
    return undef unless defined($hash_symbol) && length($hash_symbol);
    return '%'.$hash_symbol;
   }
   return undef;
  }

  if ($method eq 'flat_array') {
   my $flat_args = $normalize_method_args_with_optional_scope->($flat_call->{args} || [], 1, 1);
   return undef unless $flat_args;
   my $array_expr = $trim_action_ir_value->($flat_args->[0]);
   return undef unless defined($array_expr) && length($array_expr);
   my $array_symbol = $extract_array_symbol_name->($array_expr);
   return undef unless defined($array_symbol) && length($array_symbol);
   return '@'.$array_symbol;
  }

  if ($method eq 'flat_hash') {
   my $flat_args = $normalize_method_args_with_optional_scope->($flat_call->{args} || [], 1, 1);
   return undef unless $flat_args;
   my $hash_expr = $trim_action_ir_value->($flat_args->[0]);
   return undef unless defined($hash_expr) && length($hash_expr);
   my $hash_symbol = $extract_hash_symbol_name->($hash_expr);
   return undef unless defined($hash_symbol) && length($hash_symbol);
   return '%'.$hash_symbol;
  }

  return undef;
 };

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $method_call = $parse_method_function_expr->($trimmed);
 if ($method_call && $method_call->{method} eq 'call') {
  my $effective_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $effective_args;
  my $callee = $trim_action_ir_value->($effective_args->[0]);
  return undef unless defined($callee) && $callee =~ /^\w+$/o;
  return '&{$$descr{spec}{'.$callee.'}{handler}}($descr, $STRING, $minfo)';
 }
 if ($method_call && $method_call->{method} eq 'scalaref') {
  my $effective_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $effective_args;
  return $lower_scalaref_value_expr->($effective_args->[0], $effective_args->[1]);
 }
 if ($method_call && $method_call->{method} eq 'scalar') {
  my $scalar_args = $method_call->{args} || [];
  return undef unless ref($scalar_args) eq 'ARRAY';
  return undef unless @$scalar_args >= 1 && @$scalar_args <= 2;

  if (@$scalar_args == 1) {
   my $value = $trim_action_ir_value->($scalar_args->[0]);
   return undef unless defined($value) && length($value);
   if ($value =~ /^(\w+)$/o) {
    return '$'.$1;
   }
   my $nested = _lower_method_value_expr($value, $deps);
   return $nested if defined($nested) && length($nested) && $nested ne $trimmed;
   return $value;
  }

  my ($container_expr, $key_expr) = @$scalar_args;
  my $container_trimmed = $trim_action_ir_value->($container_expr);
  my $key_trimmed = $trim_action_ir_value->($key_expr);
  return undef unless defined($container_trimmed) && length($container_trimmed);
  return undef unless defined($key_trimmed) && length($key_trimmed);

  if ($container_trimmed eq 'IMATCH_LIST' && $key_trimmed =~ /^\d+$/o) {
   return '$IMATCH_LIST['.$key_trimmed.']';
  }

  my ($explicit_array_symbol) = $container_trimmed =~ /^array\s*\(\s*(\w+)\s*\)$/o;
  my ($explicit_hash_symbol) = $container_trimmed =~ /^hash\s*\(\s*(\w+)\s*\)$/o;
  my $array_symbol = $explicit_array_symbol || $extract_array_symbol_name->($container_trimmed);
  my $hash_symbol = $explicit_hash_symbol || $extract_hash_symbol_name->($container_trimmed);
  my $key_lowered = $lower_scalar_access_key_expr->($key_trimmed);
  return undef unless defined($key_lowered) && length($key_lowered);

  if (defined $explicit_array_symbol) {
   return '$'.$explicit_array_symbol.'['.$key_lowered.']';
  }
  if (defined $explicit_hash_symbol) {
   return '$'.$explicit_hash_symbol.'{'.$key_lowered.'}';
  }

  if (defined $array_symbol && defined $hash_symbol) {
   my $container_kind = $infer_scalar_container_kind->($container_trimmed, $key_trimmed);
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
}
 if ($method_call && $method_call->{method} eq 'trim') {
  my $trim_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $trim_args;

  my $value_expr = _lower_method_value_expr($trim_args->[0], $deps);
  $value_expr = $trim_action_ir_value->($trim_args->[0]) unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);

  return 'do { my $__ls_trim = '.$value_expr.'; if (defined($__ls_trim)) { $__ls_trim =~ s/^\s+|\s+$//g; } $__ls_trim }';
 }
 if ($method_call && $method_call->{method} eq 'lowercase') {
  my $lower_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $lower_args;

  my $value_expr = _lower_method_value_expr($lower_args->[0], $deps);
  $value_expr = $trim_action_ir_value->($lower_args->[0]) unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);

  return 'do { my $__ls_lower = '.$value_expr.'; defined($__ls_lower) ? lc($__ls_lower) : $__ls_lower }';
 }
 if ($method_call && $method_call->{method} eq 'uppercase') {
  my $upper_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $upper_args;

  my $value_expr = _lower_method_value_expr($upper_args->[0], $deps);
  $value_expr = $trim_action_ir_value->($upper_args->[0]) unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);

  return 'do { my $__ls_upper = '.$value_expr.'; defined($__ls_upper) ? uc($__ls_upper) : $__ls_upper }';
 }
 if ($method_call && $method_call->{method} eq 'count') {
  my $count_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $count_args;

  my $target_expr = $trim_action_ir_value->($count_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
   return 'scalar(@'.$array_symbol.')';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_count = '.$lowered_target.'; defined($__ls_count) ? scalar(@{$__ls_count}) : 0 }';
 }
 if ($method_call && $method_call->{method} eq 'contains') {
  my $contains_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $contains_args;

  my $target_expr = $trim_action_ir_value->($contains_args->[0]);
  my $needle_expr = _lower_method_value_expr($contains_args->[1], $deps);
  $needle_expr = $trim_action_ir_value->($contains_args->[1]) unless defined($needle_expr) && length($needle_expr);
  return undef unless defined($target_expr) && length($target_expr);
  return undef unless defined($needle_expr) && length($needle_expr);

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
   return 'do { my $__ls_contains_needle = '.$needle_expr.'; ((defined($__ls_contains_needle) ? scalar(grep { defined($_) && $_ eq $__ls_contains_needle } @'.$array_symbol.') : scalar(grep { !defined($_) } @'.$array_symbol.')) ? 1 : 0) }';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_contains_array = '.$lowered_target.'; my $__ls_contains_needle = '.$needle_expr.'; defined($__ls_contains_array) ? ((defined($__ls_contains_needle) ? scalar(grep { defined($_) && $_ eq $__ls_contains_needle } @{$__ls_contains_array}) : scalar(grep { !defined($_) } @{$__ls_contains_array})) ? 1 : 0) : 0 }';
 }
 if ($method_call && $method_call->{method} eq 'count_keys') {
  my $count_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $count_args;

  my $target_expr = $trim_action_ir_value->($count_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o) {
   return 'scalar(keys %'.$hash_symbol.')';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_count_keys = '.$lowered_target.'; defined($__ls_count_keys) ? scalar(keys %{$__ls_count_keys}) : 0 }';
 }
 if ($method_call && $method_call->{method} eq 'sorted_keys') {
  my $sorted_keys_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $sorted_keys_args;

  my $target_expr = $trim_action_ir_value->($sorted_keys_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o) {
   return '[sort keys %'.$hash_symbol.']';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_sorted_keys = '.$lowered_target.'; defined($__ls_sorted_keys) ? [sort keys %{$__ls_sorted_keys}] : [] }';
 }
 if ($method_call && $method_call->{method} eq 'sorted_values') {
  my $sorted_values_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $sorted_values_args;

  my $target_expr = $trim_action_ir_value->($sorted_values_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o) {
   return '[map { $'.$hash_symbol.'{$_} } sort keys %'.$hash_symbol.']';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_sorted_values = '.$lowered_target.'; defined($__ls_sorted_values) ? [map { $__ls_sorted_values->{$_} } sort keys %{$__ls_sorted_values}] : [] }';
 }
 if ($method_call && $method_call->{method} eq 'has_key') {
  my $has_key_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $has_key_args;

  my $target_expr = $trim_action_ir_value->($has_key_args->[0]);
  my $key_expr = $trim_action_ir_value->($has_key_args->[1]);
  return undef unless defined($target_expr) && length($target_expr);
  return undef unless defined($key_expr) && length($key_expr);

  my $key_lowered = $lower_scalar_access_key_expr->($key_expr);
  return undef unless defined($key_lowered) && length($key_lowered);

  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o) {
   return '((exists $'.$hash_symbol.'{'.$key_lowered.'}) ? 1 : 0)';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_has_key = '.$lowered_target.'; defined($__ls_has_key) ? ((exists $__ls_has_key->{'.$key_lowered.'}) ? 1 : 0) : 0 }';
 }
 if ($method_call && $method_call->{method} eq 'merge_hash') {
  my $merge_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, undef);
  return undef unless $merge_args && @$merge_args >= 1;

  my @parts;
  foreach my $arg (@$merge_args) {
   my $target_expr = $trim_action_ir_value->($arg);
   return undef unless defined($target_expr) && length($target_expr);

   my $hash_symbol = $extract_hash_symbol_name->($target_expr);
   if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o) {
    push @parts, '%'.$hash_symbol;
    next;
   }

   my $lowered_target = _lower_method_value_expr($target_expr, $deps);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
   return undef unless defined($lowered_target) && length($lowered_target);

   push @parts, 'do { my $__ls_merge_hash = '.$lowered_target.'; defined($__ls_merge_hash) ? %{$__ls_merge_hash} : () }';
  }

  return '{'.join(', ', @parts).'}';
 }
 if ($method_call && $method_call->{method} eq 'drop_keys') {
  my $drop_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, undef);
  return undef unless $drop_args && @$drop_args >= 2;

  my $target_expr = $trim_action_ir_value->($drop_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $lowered_target;
  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o) {
   $lowered_target = '\\%'.$hash_symbol;
  } else {
   $lowered_target = _lower_method_value_expr($target_expr, $deps);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  }
  return undef unless defined($lowered_target) && length($lowered_target);

  my @lowered_keys;
  foreach my $arg (@{$drop_args}[1 .. $#$drop_args]) {
   my $key_expr = $trim_action_ir_value->($arg);
   return undef unless defined($key_expr) && length($key_expr);
   my $key_lowered = $lower_scalar_access_key_expr->($key_expr);
   return undef unless defined($key_lowered) && length($key_lowered);
   push @lowered_keys, $key_lowered;
  }

  return 'do { my $__ls_drop_source = '.$lowered_target.'; if (defined($__ls_drop_source)) { my %__ls_drop = %{$__ls_drop_source}; delete @__ls_drop{'.join(', ', @lowered_keys).'}; \%__ls_drop } else { {} } }';
 }
 if ($method_call && $method_call->{method} eq 'pick_keys') {
  my $pick_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, undef);
  return undef unless $pick_args && @$pick_args >= 2;

  my $target_expr = $trim_action_ir_value->($pick_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);
  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  my $lowered_target;
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o) {
   $lowered_target = '\\%'.$hash_symbol;
  } else {
   $lowered_target = _lower_method_value_expr($target_expr, $deps);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  }
  return undef unless defined($lowered_target) && length($lowered_target);

  my @lowered_keys;
  foreach my $arg (@{$pick_args}[1 .. $#$pick_args]) {
   my $key_expr = $trim_action_ir_value->($arg);
   return undef unless defined($key_expr) && length($key_expr);
   my $key_lowered = $lower_scalar_access_key_expr->($key_expr);
   return undef unless defined($key_lowered) && length($key_lowered);
   push @lowered_keys, $key_lowered;
  }

  return 'do { my $__ls_pick_source = '.$lowered_target.'; if (defined($__ls_pick_source)) { my %__ls_pick; foreach my $__ls_pick_key ('.join(', ', @lowered_keys).') { $__ls_pick{$__ls_pick_key} = $__ls_pick_source->{$__ls_pick_key} if exists $__ls_pick_source->{$__ls_pick_key}; } \%__ls_pick } else { {} } }';
 }
 if ($method_call && $method_call->{method} eq 'join_values') {
  my $join_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $join_args;

  my $delimiter_expr = _lower_method_value_expr($join_args->[0], $deps);
  $delimiter_expr = $trim_action_ir_value->($join_args->[0]) unless defined($delimiter_expr) && length($delimiter_expr);
  return undef unless defined($delimiter_expr) && length($delimiter_expr);

  my $array_expr = $trim_action_ir_value->($join_args->[1]);
  return undef unless defined($array_expr) && length($array_expr);
  my $array_symbol = $extract_array_symbol_name->($array_expr);
  if (defined($array_symbol) && length($array_symbol) && $array_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
   return "join($delimiter_expr, \@$array_symbol)";
  }

  my $lowered_array = _lower_method_value_expr($array_expr, $deps);
  $lowered_array = $array_expr unless defined($lowered_array) && length($lowered_array);
  return undef unless defined($lowered_array) && length($lowered_array);

  return 'do { my $__ls_join_values = '.$lowered_array.'; defined($__ls_join_values) ? join('.$delimiter_expr.', @{$__ls_join_values}) : $__ls_join_values }';
 }
 if ($method_call && $method_call->{method} eq 'coalesce') {
  my $coalesce_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, undef);
  return undef unless $coalesce_args && @$coalesce_args >= 2;

  my @lowered_args;
  foreach my $arg (@$coalesce_args) {
   my $lowered_arg = _lower_method_value_expr($arg, $deps);
   $lowered_arg = $trim_action_ir_value->($arg) unless defined($lowered_arg) && length($lowered_arg);
   return undef unless defined($lowered_arg) && length($lowered_arg);
   push @lowered_args, $lowered_arg;
  }

  my $build_coalesce_expr;
  $build_coalesce_expr = sub {
   my (@parts) = @_;
   return $parts[0] if @parts == 1;

   my $head = shift @parts;
   my $tail_expr = $build_coalesce_expr->(@parts);
   return 'do { my $__ls_coalesce = '.$head.'; defined($__ls_coalesce) ? $__ls_coalesce : '.$tail_expr.' }';
  };

  return $build_coalesce_expr->(@lowered_args);
 }
 my $flat_list_expr = $lower_flat_list_value_expr->($trimmed);
 return $flat_list_expr if defined($flat_list_expr) && length($flat_list_expr);
 if ($method_call && ($method_call->{method} eq 'array_values' || $method_call->{method} eq 'array_copy')) {
  my $array_value_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $array_value_args;

  my $array_expr = $trim_action_ir_value->($array_value_args->[0]);
  return undef unless defined($array_expr) && length($array_expr);
  my $array_symbol = $extract_array_symbol_name->($array_expr);
  return undef unless defined($array_symbol) && length($array_symbol);

 return '[@'.$array_symbol.']';
 }
 my $pipeline_expr = $lower_array_pipeline_expr->($trimmed);
 return $pipeline_expr if defined($pipeline_expr) && length($pipeline_expr);
 if ($trimmed =~ /^hash\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))$/o) {
  my $payload = $+{PAREN};
  $payload =~ s/^\(|\)$//go;
  my $args = $split_top_level_csv->($payload);
  my @pairs;
  for (my $i = 0; $i < @$args; ) {
   my $flat_pair_expr = $lower_flat_list_value_expr->($args->[$i]);
   if (defined($flat_pair_expr) && length($flat_pair_expr)) {
    push @pairs, $flat_pair_expr;
    ++$i;
    next;
   }

   return undef unless $i + 1 < @$args;
   my $key_expr = _normalize_method_tag_expr($args->[$i], $deps);
   return undef unless defined($key_expr) && length($key_expr);
   my $val_expr = _lower_method_value_expr($args->[$i + 1], $deps);
   $val_expr = $trim_action_ir_value->($args->[$i + 1]) unless defined($val_expr) && length($val_expr);
   return undef unless defined($val_expr) && length($val_expr);
   push @pairs, $key_expr.' => '.$val_expr;
   $i += 2;
  }
  return '{'.join(', ', @pairs).'}';
 }
 if ($trimmed =~ /^array\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))$/o) {
  my $payload = $+{PAREN};
  $payload =~ s/^\(|\)$//go;
  my $args = $split_top_level_csv->($payload);
  my @lowered = map { _lower_method_value_expr($_, $deps) // $_ } @$args;
  return '['.join(', ', @lowered).']';
 }

 return $trimmed
}

#------------------------------------------------------------------------------
# Function: _lower_return_payload_expr
# Purpose : Lower generalized return payload expressions, preserving nested
#           `[]/{}` literals while lowering embedded scalar/array/hash/flat helpers.
# Args    : ($expr, $deps)
# Returns : Perl payload expression string or undef
#------------------------------------------------------------------------------
sub _lower_return_payload_expr {
 my ($expr, $deps) = @_;
 return undef unless defined $expr;
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $direct = _lower_method_value_expr($trimmed, $deps);
 if (
  defined($direct) &&
  length($direct) &&
  ($trimmed =~ /^(?:scalaref|scalar|array|hash|trim|lowercase|uppercase|count|contains|count_keys|sorted_keys|sorted_values|has_key|merge_hash|drop_keys|pick_keys|join_values|coalesce|array_copy|array_values|flat_array|flat_hash|flatten|flat)\s*\(/o || $direct ne $trimmed)
 ) {
  return $direct;
 }

 my $rewritten = $trimmed;
 for (1 .. 64) {
  my $before = $rewritten;
  $rewritten =~ s/\b(?<helper>(?:scalaref|scalar|array_copy|array_values|trim|lowercase|uppercase|count|contains|count_keys|sorted_keys|sorted_values|has_key|merge_hash|drop_keys|pick_keys|join_values|coalesce|flat_array|flat_hash|flatten|flat|array|hash)\s*(?<PAREN>\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/do {
   my $lowered = _lower_method_value_expr($+{helper}, $deps);
   (defined($lowered) && length($lowered)) ? $lowered : $+{helper};
  }/ge;
  last if $rewritten eq $before;
 }
 return $rewritten
}

#------------------------------------------------------------------------------
# Function: _lower_return_general_statement
# Purpose : Lower generalized `return(payload)` helper form.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_general_statement {
 my ($expr, $deps) = @_;
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'return';

 my $args = $call->{args} || [];
 return undef unless ref($args) eq 'ARRAY' && @$args == 1;
 my $payload = _lower_return_payload_expr($args->[0], $deps);
 return undef unless defined($payload) && length($payload);
 return "return $payload"
}

#------------------------------------------------------------------------------
# Function: _lower_return_imatch_statement
# Purpose : Lower `return_imatch(...)`/`return_im(...)` method helper calls.
# Args    : ($tag, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_imatch_statement {
 my ($tag, $deps) = @_;
 my $tag_expr = _normalize_method_tag_expr($tag, $deps);
 return undef unless defined $tag_expr;
 return "return [$tag_expr, \$IMATCH]"
}

#------------------------------------------------------------------------------
# Function: _lower_assign_statement
# Purpose : Lower `assign(target, source)` method helper calls.
# Args    : ($target, $source, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_assign_statement {
 my ($target, $source, $deps) = @_;
 my $extract_scalar_symbol_name = _require_dep($deps, 'extract_scalar_symbol_name');
 my $extract_array_symbol_name = _require_dep($deps, 'extract_array_symbol_name');
 my $extract_hash_symbol_name = _require_dep($deps, 'extract_hash_symbol_name');
 my $lower_assignment_source_expr = _require_dep($deps, 'lower_assignment_source_expr');
 my $lower_declare_initializer_expr = _require_dep($deps, 'lower_declare_initializer_expr');

 my $symbol = $extract_scalar_symbol_name->($target);
 if (defined $symbol) {
  my $source_expr = $lower_assignment_source_expr->($source);
  return undef unless defined $source_expr;
  return "\$$symbol = $source_expr";
 }

 my $array_symbol = $extract_array_symbol_name->($target);
 if (defined $array_symbol) {
  my $source_expr = $lower_declare_initializer_expr->('array', $source);
  return undef unless defined $source_expr;
  return "\@$array_symbol = $source_expr";
 }

 my $hash_symbol = $extract_hash_symbol_name->($target);
 if (defined $hash_symbol) {
  my $source_expr = $lower_declare_initializer_expr->('hash', $source);
  return undef unless defined $source_expr;
  return "\%$hash_symbol = $source_expr";
 }

 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_push_value_statement
# Purpose : Lower `push_value(array(target), value)` helper calls.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_push_value_statement {
 my ($expr, $deps) = @_;
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');
 my $extract_array_symbol_name = _require_dep($deps, 'extract_array_symbol_name');
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'push_value';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 2, 2);
 return undef unless $effective_args;

 my $target_expr = $trim_action_ir_value->($effective_args->[0]);
 return undef unless defined($target_expr) && length($target_expr);
 my $target_symbol = $extract_array_symbol_name->($target_expr);
 if (!defined($target_symbol) && $target_expr =~ /^(\w+)$/o) {
  $target_symbol = $1;
 }
 return undef unless defined($target_symbol) && length($target_symbol);

 my $value_expr = $trim_action_ir_value->($effective_args->[1]);
 return undef unless defined($value_expr) && length($value_expr);
 my $lowered_value = _lower_method_value_expr($value_expr, $deps);
 $lowered_value = $value_expr unless defined($lowered_value) && length($lowered_value);
 return "push \@$target_symbol, $lowered_value"
}

#------------------------------------------------------------------------------
# Function: _lower_regex_subst_statement
# Purpose : Lower regex substitution method helper calls for scalar targets.
# Args    : ($target, $pattern, $replacement, $flags, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_regex_subst_statement {
 my ($target, $pattern, $replacement, $flags, $deps) = @_;
 my $extract_scalar_symbol_name = _require_dep($deps, 'extract_scalar_symbol_name');
 my $strip_literal_delimiters = _require_dep($deps, 'strip_literal_delimiters');
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');

 my $symbol = $extract_scalar_symbol_name->($target);
 return undef unless defined $symbol;

 my $pattern_raw = $strip_literal_delimiters->($pattern);
 my $replacement_raw = $strip_literal_delimiters->($replacement);
 return undef unless defined($pattern_raw) && defined($replacement_raw);

 $flags = $trim_action_ir_value->($flags // '');
 $flags = '' unless defined $flags;
 return "\$$symbol =~ s{$pattern_raw}{$replacement_raw}$flags"
}

#------------------------------------------------------------------------------
# Function: _lower_return_undef_statement
# Purpose : Lower `return_undef()` fluent helper calls.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_undef_statement {
 my ($expr, $deps) = @_;
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'return_undef';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return undef unless $effective_args;
 return 'return undef'
}

#------------------------------------------------------------------------------
# Function: _lower_return_array_statement
# Purpose : Lower `return_array(tag, payload)` method helper calls.
# Args    : ($tag, $payload, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_return_array_statement {
 my ($tag, $payload, $deps) = @_;
 my $tag_expr = _normalize_method_tag_expr($tag, $deps);
 return undef unless defined $tag_expr;
 my $payload_expr = _lower_method_value_expr($payload, $deps);
 return undef unless defined $payload_expr;
 return "return [$tag_expr, $payload_expr]"
}

1;
