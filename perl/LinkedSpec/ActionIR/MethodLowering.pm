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
#           `array(...)`, `merge_hash(...)`, `set_key(...)`,
#           `rename_key(...)`, `drop_keys(...)`, `pick_keys(...)`, `sorted_keys(...)`, `sorted_values(...)`,
#           `length(...)`, `replace_substr(...)`, `num_abs(...)`, `num_floor(...)`, `num_ceil(...)`, `num_round(...)`, `num_add(...)`, `num_sub(...)`, `num_mul(...)`, `num_div(...)`, `num_min(...)`, `num_max(...)`, `starts_with(...)`, `ends_with(...)`, `contains_substr(...)`, `matches(...)`, `is_empty(...)`, `is_nonempty(...)`, `first(...)`, `last(...)`, `tail(...)`, `drop_front(...)`, `take(...)`, `take_last(...)`, `drop_last(...)`, `drop_back(...)`, `concat_arrays(...)`, `contains(...)`,
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
 my $extract_scalar_symbol_name = _require_dep($deps, 'extract_scalar_symbol_name');
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
 my ($looks_like_array_value_expr, $looks_like_hash_value_expr);
 $looks_like_array_value_expr = sub {
  my ($candidate_expr) = @_;
  return 0 unless defined $candidate_expr;
  my $candidate_trimmed = $trim_action_ir_value->($candidate_expr);
  return 0 unless defined($candidate_trimmed) && length($candidate_trimmed);

  return 1 if $candidate_trimmed =~ /^array\s*\(/o;

  my $array_symbol = $extract_array_symbol_name->($candidate_trimmed);
  if (defined($array_symbol) && length($array_symbol) && $candidate_trimmed =~ /^\w+$/o) {
   return 1;
  }

  my $candidate_call = $parse_method_function_expr->($candidate_trimmed);
  return 0 unless $candidate_call;

  my $candidate_method = $candidate_call->{method} // '';
  return 1 if $candidate_method =~ /^(?:array|array_copy|array_values|sorted_keys|sorted_values|tail|drop_front|take|take_last|drop_last|drop_back|concat_arrays|split|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)$/o;

  if ($candidate_method eq 'coalesce') {
   my $candidate_args = $normalize_method_args_with_optional_scope->($candidate_call->{args} || [], 2, undef);
   return 0 unless $candidate_args && @$candidate_args;

   my $saw_array_like = 0;
   foreach my $arg (@$candidate_args) {
    next unless defined $arg;
    return 0 if $looks_like_hash_value_expr->($arg);
    $saw_array_like ||= $looks_like_array_value_expr->($arg);
   }
   return $saw_array_like ? 1 : 0;
  }

  return 0;
 };
 $looks_like_hash_value_expr = sub {
  my ($candidate_expr) = @_;
  return 0 unless defined $candidate_expr;
  my $candidate_trimmed = $trim_action_ir_value->($candidate_expr);
  return 0 unless defined($candidate_trimmed) && length($candidate_trimmed);

  return 1 if $candidate_trimmed =~ /^hash\s*\(/o;

  my $hash_symbol = $extract_hash_symbol_name->($candidate_trimmed);
  if (defined($hash_symbol) && length($hash_symbol) && $candidate_trimmed =~ /^\w+$/o) {
   return 1;
  }

  my $candidate_call = $parse_method_function_expr->($candidate_trimmed);
  return 0 unless $candidate_call;

  my $candidate_method = $candidate_call->{method} // '';
  return 1 if $candidate_method =~ /^(?:hash|merge_hash|set_key|rename_key|drop_keys|pick_keys)$/o;

  if ($candidate_method eq 'coalesce') {
   my $candidate_args = $normalize_method_args_with_optional_scope->($candidate_call->{args} || [], 2, undef);
   return 0 unless $candidate_args && @$candidate_args;

   my $saw_hash_like = 0;
   foreach my $arg (@$candidate_args) {
    next unless defined $arg;
    return 0 if $looks_like_array_value_expr->($arg);
    $saw_hash_like ||= $looks_like_hash_value_expr->($arg);
   }
   return $saw_hash_like ? 1 : 0;
  }

  return 0;
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
  if ($looks_like_array_value_expr->($container_trimmed)) {
   my $lowered_container = _lower_method_value_expr($container_trimmed, $deps);
   $lowered_container = $container_trimmed unless defined($lowered_container) && length($lowered_container);
   return undef unless defined($lowered_container) && length($lowered_container);
   return 'do { my $__ls_scalar_source = '.$lowered_container.'; (defined($__ls_scalar_source) && ref($__ls_scalar_source) eq \'ARRAY\') ? $__ls_scalar_source->['.$key_lowered.'] : undef }';
  }
  if ($looks_like_hash_value_expr->($container_trimmed)) {
   my $lowered_container = _lower_method_value_expr($container_trimmed, $deps);
   $lowered_container = $container_trimmed unless defined($lowered_container) && length($lowered_container);
   return undef unless defined($lowered_container) && length($lowered_container);
   return 'do { my $__ls_scalar_source = '.$lowered_container.'; (defined($__ls_scalar_source) && ref($__ls_scalar_source) eq \'HASH\') ? $__ls_scalar_source->{'.$key_lowered.'} : undef }';
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
 if ($method_call && $method_call->{method} eq 'length') {
  my $length_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $length_args;

 my $value_expr = _lower_method_value_expr($length_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($length_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_length = '.$value_expr.'; defined($__ls_length) ? length($__ls_length) : undef }';
}
if ($method_call && $method_call->{method} eq 'replace_substr') {
 my $replace_substr_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 3, 3);
 return undef unless $replace_substr_args;

 my $value_expr = _lower_method_value_expr($replace_substr_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($replace_substr_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 my $needle_expr = _lower_method_value_expr($replace_substr_args->[1], $deps);
 $needle_expr = $trim_action_ir_value->($replace_substr_args->[1]) unless defined($needle_expr) && length($needle_expr);
 return undef unless defined($needle_expr) && length($needle_expr);

 my $replacement_expr = _lower_method_value_expr($replace_substr_args->[2], $deps);
 $replacement_expr = $trim_action_ir_value->($replace_substr_args->[2]) unless defined($replacement_expr) && length($replacement_expr);
 return undef unless defined($replacement_expr) && length($replacement_expr);

 return 'do { my $__ls_replace_substr_value = '.$value_expr.'; my $__ls_replace_substr_needle = '.$needle_expr.'; my $__ls_replace_substr_replacement = '.$replacement_expr.'; if (defined($__ls_replace_substr_value) && defined($__ls_replace_substr_needle) && defined($__ls_replace_substr_replacement)) { length($__ls_replace_substr_needle) ? join($__ls_replace_substr_replacement, split(/\Q$__ls_replace_substr_needle\E/, $__ls_replace_substr_value, -1)) : $__ls_replace_substr_value } else { undef } }';
}
if ($method_call && $method_call->{method} eq 'num_abs') {
 my $num_abs_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_abs_args;

 my $value_expr = _lower_method_value_expr($num_abs_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($num_abs_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_num_abs_value = '.$value_expr.'; (defined($__ls_num_abs_value) && $__ls_num_abs_value =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/) ? ($__ls_num_abs_value < 0 ? -$__ls_num_abs_value : $__ls_num_abs_value) : undef }';
}
if ($method_call && $method_call->{method} eq 'num_floor') {
 my $num_floor_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_floor_args;

 my $value_expr = _lower_method_value_expr($num_floor_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($num_floor_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_num_floor_value = '.$value_expr.'; (defined($__ls_num_floor_value) && $__ls_num_floor_value =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/) ? (($__ls_num_floor_value >= 0 || $__ls_num_floor_value == int($__ls_num_floor_value)) ? int($__ls_num_floor_value) : int($__ls_num_floor_value) - 1) : undef }';
}
if ($method_call && $method_call->{method} eq 'num_ceil') {
 my $num_ceil_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_ceil_args;

 my $value_expr = _lower_method_value_expr($num_ceil_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($num_ceil_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_num_ceil_value = '.$value_expr.'; (defined($__ls_num_ceil_value) && $__ls_num_ceil_value =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/) ? (($__ls_num_ceil_value <= 0 || $__ls_num_ceil_value == int($__ls_num_ceil_value)) ? int($__ls_num_ceil_value) : int($__ls_num_ceil_value) + 1) : undef }';
}
if ($method_call && $method_call->{method} eq 'num_round') {
 my $num_round_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_round_args;

 my $value_expr = _lower_method_value_expr($num_round_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($num_round_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_num_round_value = '.$value_expr.'; (defined($__ls_num_round_value) && $__ls_num_round_value =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/) ? int($__ls_num_round_value + ($__ls_num_round_value >= 0 ? 0.5 : -0.5)) : undef }';
}
if ($method_call && $method_call->{method} eq 'num_add') {
  my $num_add_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, undef);
  return undef unless $num_add_args && @$num_add_args;

  my @lowered_terms;
  foreach my $arg (@$num_add_args) {
   my $term_expr = _lower_method_value_expr($arg, $deps);
   $term_expr = $trim_action_ir_value->($arg) unless defined($term_expr) && length($term_expr);
   return undef unless defined($term_expr) && length($term_expr);
   push @lowered_terms, $term_expr;
  }

  return 'do { my @__ls_num_add_terms = ('.join(', ', @lowered_terms).'); my $__ls_num_add_sum = 0; my $__ls_num_add_ok = 1; for my $__ls_num_add_term (@__ls_num_add_terms) { if (!(defined($__ls_num_add_term) && $__ls_num_add_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_add_ok = 0; last; } $__ls_num_add_sum += $__ls_num_add_term; } $__ls_num_add_ok ? $__ls_num_add_sum : undef }';
 }
 if ($method_call && $method_call->{method} eq 'num_sub') {
  my $num_sub_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $num_sub_args;

  my $lhs_expr = _lower_method_value_expr($num_sub_args->[0], $deps);
  $lhs_expr = $trim_action_ir_value->($num_sub_args->[0]) unless defined($lhs_expr) && length($lhs_expr);
  return undef unless defined($lhs_expr) && length($lhs_expr);

  my $rhs_expr = _lower_method_value_expr($num_sub_args->[1], $deps);
  $rhs_expr = $trim_action_ir_value->($num_sub_args->[1]) unless defined($rhs_expr) && length($rhs_expr);
  return undef unless defined($rhs_expr) && length($rhs_expr);

  return 'do { my $__ls_num_sub_lhs = '.$lhs_expr.'; my $__ls_num_sub_rhs = '.$rhs_expr.'; (defined($__ls_num_sub_lhs) && defined($__ls_num_sub_rhs) && $__ls_num_sub_lhs =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/ && $__ls_num_sub_rhs =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/) ? ($__ls_num_sub_lhs - $__ls_num_sub_rhs) : undef }';
 }
 if ($method_call && $method_call->{method} eq 'num_mul') {
  my $num_mul_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, undef);
  return undef unless $num_mul_args && @$num_mul_args;

  my @lowered_terms;
  foreach my $arg (@$num_mul_args) {
   my $term_expr = _lower_method_value_expr($arg, $deps);
   $term_expr = $trim_action_ir_value->($arg) unless defined($term_expr) && length($term_expr);
   return undef unless defined($term_expr) && length($term_expr);
   push @lowered_terms, $term_expr;
  }

  return 'do { my @__ls_num_mul_terms = ('.join(', ', @lowered_terms).'); my $__ls_num_mul_product = 1; my $__ls_num_mul_ok = 1; for my $__ls_num_mul_term (@__ls_num_mul_terms) { if (!(defined($__ls_num_mul_term) && $__ls_num_mul_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_mul_ok = 0; last; } $__ls_num_mul_product *= $__ls_num_mul_term; } $__ls_num_mul_ok ? $__ls_num_mul_product : undef }';
 }
 if ($method_call && $method_call->{method} eq 'num_div') {
  my $num_div_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $num_div_args;

  my $lhs_expr = _lower_method_value_expr($num_div_args->[0], $deps);
  $lhs_expr = $trim_action_ir_value->($num_div_args->[0]) unless defined($lhs_expr) && length($lhs_expr);
  return undef unless defined($lhs_expr) && length($lhs_expr);

  my $rhs_expr = _lower_method_value_expr($num_div_args->[1], $deps);
  $rhs_expr = $trim_action_ir_value->($num_div_args->[1]) unless defined($rhs_expr) && length($rhs_expr);
  return undef unless defined($rhs_expr) && length($rhs_expr);

  return 'do { my $__ls_num_div_lhs = '.$lhs_expr.'; my $__ls_num_div_rhs = '.$rhs_expr.'; (defined($__ls_num_div_lhs) && defined($__ls_num_div_rhs) && $__ls_num_div_lhs =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/ && $__ls_num_div_rhs =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/ && $__ls_num_div_rhs != 0) ? ($__ls_num_div_lhs / $__ls_num_div_rhs) : undef }';
 }
 if ($method_call && $method_call->{method} eq 'num_min') {
  my $num_min_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, undef);
  return undef unless $num_min_args && @$num_min_args;

  my @lowered_terms;
  foreach my $arg (@$num_min_args) {
   my $term_expr = _lower_method_value_expr($arg, $deps);
   $term_expr = $trim_action_ir_value->($arg) unless defined($term_expr) && length($term_expr);
   return undef unless defined($term_expr) && length($term_expr);
   push @lowered_terms, $term_expr;
  }

  return 'do { my @__ls_num_min_terms = ('.join(', ', @lowered_terms).'); my $__ls_num_min_value; my $__ls_num_min_ok = 1; for my $__ls_num_min_term (@__ls_num_min_terms) { if (!(defined($__ls_num_min_term) && $__ls_num_min_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_min_ok = 0; last; } $__ls_num_min_value = defined($__ls_num_min_value) ? ($__ls_num_min_term < $__ls_num_min_value ? $__ls_num_min_term : $__ls_num_min_value) : $__ls_num_min_term; } $__ls_num_min_ok ? $__ls_num_min_value : undef }';
 }
 if ($method_call && $method_call->{method} eq 'num_max') {
  my $num_max_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, undef);
  return undef unless $num_max_args && @$num_max_args;

  my @lowered_terms;
  foreach my $arg (@$num_max_args) {
   my $term_expr = _lower_method_value_expr($arg, $deps);
   $term_expr = $trim_action_ir_value->($arg) unless defined($term_expr) && length($term_expr);
   return undef unless defined($term_expr) && length($term_expr);
   push @lowered_terms, $term_expr;
  }

  return 'do { my @__ls_num_max_terms = ('.join(', ', @lowered_terms).'); my $__ls_num_max_value; my $__ls_num_max_ok = 1; for my $__ls_num_max_term (@__ls_num_max_terms) { if (!(defined($__ls_num_max_term) && $__ls_num_max_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_max_ok = 0; last; } $__ls_num_max_value = defined($__ls_num_max_value) ? ($__ls_num_max_term > $__ls_num_max_value ? $__ls_num_max_term : $__ls_num_max_value) : $__ls_num_max_term; } $__ls_num_max_ok ? $__ls_num_max_value : undef }';
 }
 if ($method_call && $method_call->{method} eq 'starts_with') {
  my $starts_with_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $starts_with_args;

  my $value_expr = _lower_method_value_expr($starts_with_args->[0], $deps);
  $value_expr = $trim_action_ir_value->($starts_with_args->[0]) unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);

  my $prefix_expr = _lower_method_value_expr($starts_with_args->[1], $deps);
  $prefix_expr = $trim_action_ir_value->($starts_with_args->[1]) unless defined($prefix_expr) && length($prefix_expr);
  return undef unless defined($prefix_expr) && length($prefix_expr);

 return 'do { my $__ls_starts_with_value = '.$value_expr.'; my $__ls_starts_with_prefix = '.$prefix_expr.'; (defined($__ls_starts_with_value) && defined($__ls_starts_with_prefix) && index($__ls_starts_with_value, $__ls_starts_with_prefix) == 0) ? 1 : 0 }';
}
 if ($method_call && $method_call->{method} eq 'ends_with') {
  my $ends_with_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $ends_with_args;

  my $value_expr = _lower_method_value_expr($ends_with_args->[0], $deps);
  $value_expr = $trim_action_ir_value->($ends_with_args->[0]) unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);

  my $suffix_expr = _lower_method_value_expr($ends_with_args->[1], $deps);
  $suffix_expr = $trim_action_ir_value->($ends_with_args->[1]) unless defined($suffix_expr) && length($suffix_expr);
  return undef unless defined($suffix_expr) && length($suffix_expr);

 return 'do { my $__ls_ends_with_value = '.$value_expr.'; my $__ls_ends_with_suffix = '.$suffix_expr.'; (defined($__ls_ends_with_value) && defined($__ls_ends_with_suffix) && ((length($__ls_ends_with_suffix) == 0) ? 1 : (length($__ls_ends_with_value) >= length($__ls_ends_with_suffix) && substr($__ls_ends_with_value, -length($__ls_ends_with_suffix)) eq $__ls_ends_with_suffix))) ? 1 : 0 }';
}
 if ($method_call && $method_call->{method} eq 'contains_substr') {
  my $contains_substr_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $contains_substr_args;

  my $value_expr = _lower_method_value_expr($contains_substr_args->[0], $deps);
  $value_expr = $trim_action_ir_value->($contains_substr_args->[0]) unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);

  my $needle_expr = _lower_method_value_expr($contains_substr_args->[1], $deps);
  $needle_expr = $trim_action_ir_value->($contains_substr_args->[1]) unless defined($needle_expr) && length($needle_expr);
  return undef unless defined($needle_expr) && length($needle_expr);

  return 'do { my $__ls_contains_substr_value = '.$value_expr.'; my $__ls_contains_substr_needle = '.$needle_expr.'; (defined($__ls_contains_substr_value) && defined($__ls_contains_substr_needle) && index($__ls_contains_substr_value, $__ls_contains_substr_needle) >= 0) ? 1 : 0 }';
 }
 if ($method_call && $method_call->{method} eq 'matches') {
  my $matches_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $matches_args;

  my $value_expr = _lower_method_value_expr($matches_args->[0], $deps);
  $value_expr = $trim_action_ir_value->($matches_args->[0]) unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);

  my $pattern_expr = _lower_method_value_expr($matches_args->[1], $deps);
  $pattern_expr = $trim_action_ir_value->($matches_args->[1]) unless defined($pattern_expr) && length($pattern_expr);
  return undef unless defined($pattern_expr) && length($pattern_expr);

  return 'do { my $__ls_matches_value = '.$value_expr.'; defined($__ls_matches_value) ? (($__ls_matches_value =~ '.$pattern_expr.') ? 1 : 0) : 0 }';
 }
 if ($method_call && ($method_call->{method} eq 'is_empty' || $method_call->{method} eq 'is_nonempty')) {
  my $emptiness_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $emptiness_args;

  my $target_expr = $trim_action_ir_value->($emptiness_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $empty_expr;
  if ($target_expr =~ /^array\s*\(/o) {
   my $array_symbol = $extract_array_symbol_name->($target_expr);
   return undef unless defined($array_symbol) && length($array_symbol);
   $empty_expr = '((!@'.$array_symbol.') ? 1 : 0)';
  } elsif ($target_expr =~ /^hash\s*\(/o) {
   my $hash_symbol = $extract_hash_symbol_name->($target_expr);
   return undef unless defined($hash_symbol) && length($hash_symbol);
   $empty_expr = '((!scalar(keys %'.$hash_symbol.')) ? 1 : 0)';
  } else {
   my $scalar_symbol = $extract_scalar_symbol_name->($target_expr);
   if (defined($scalar_symbol) && length($scalar_symbol)) {
    $empty_expr = '((!defined($'.$scalar_symbol.') || $'.$scalar_symbol.' eq \'\') ? 1 : 0)';
   } else {
    my $lowered_target = _lower_method_value_expr($target_expr, $deps);
    $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
    return undef unless defined($lowered_target) && length($lowered_target);

    if ($looks_like_array_value_expr->($target_expr)) {
     $empty_expr = 'do { my $__ls_is_empty_array = '.$lowered_target.'; (!defined($__ls_is_empty_array) || !@{$__ls_is_empty_array}) ? 1 : 0 }';
    } elsif ($looks_like_hash_value_expr->($target_expr)) {
     $empty_expr = 'do { my $__ls_is_empty_hash = '.$lowered_target.'; (!defined($__ls_is_empty_hash) || !scalar(keys %{$__ls_is_empty_hash})) ? 1 : 0 }';
    } else {
     $empty_expr = 'do { my $__ls_is_empty_value = '.$lowered_target.'; (!($__ls_is_empty_value)) ? 1 : 0 }';
    }
   }
  }

  return $empty_expr if $method_call->{method} eq 'is_empty';
  return 'do { my $__ls_is_nonempty_empty = '.$empty_expr.'; $__ls_is_nonempty_empty ? 0 : 1 }';
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
 if ($method_call && $method_call->{method} eq 'first') {
  my $first_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $first_args;

  my $target_expr = $trim_action_ir_value->($first_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
   return '$'.$array_symbol.'[0]';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_first = '.$lowered_target.'; defined($__ls_first) && @{$__ls_first} ? $__ls_first->[0] : undef }';
 }
 if ($method_call && $method_call->{method} eq 'last') {
  my $last_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $last_args;

  my $target_expr = $trim_action_ir_value->($last_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
   return '$'.$array_symbol.'[$#'.$array_symbol.']';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_last = '.$lowered_target.'; defined($__ls_last) && @{$__ls_last} ? $__ls_last->[-1] : undef }';
 }
 if ($method_call && ($method_call->{method} eq 'tail' || $method_call->{method} eq 'drop_front')) {
  my $tail_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 2);
  return undef unless $tail_args;

  my $target_expr = $trim_action_ir_value->($tail_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $tail_has_explicit_count = (@{$tail_args} > 1 && defined($tail_args->[1])) ? 1 : 0;
  my $tail_skip_expr = '1';
  if ($tail_has_explicit_count) {
   $tail_skip_expr = _lower_method_value_expr($tail_args->[1], $deps);
   $tail_skip_expr = $trim_action_ir_value->($tail_args->[1]) unless defined($tail_skip_expr) && length($tail_skip_expr);
   return undef unless defined($tail_skip_expr) && length($tail_skip_expr);
  }

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
   return 'do { my $__ls_tail_len = scalar(@'.$array_symbol.'); $__ls_tail_len > 1 ? [@'.$array_symbol.'[1 .. $__ls_tail_len - 1]] : [] }'
    unless $tail_has_explicit_count;
   return 'do { my $__ls_tail_skip = '.$tail_skip_expr.'; $__ls_tail_skip = 0 unless defined($__ls_tail_skip) && $__ls_tail_skip =~ /\A-?\d+\z/; $__ls_tail_skip = 0 if $__ls_tail_skip < 0; my $__ls_tail_len = scalar(@'.$array_symbol.'); $__ls_tail_len > $__ls_tail_skip ? [@'.$array_symbol.'[$__ls_tail_skip .. $__ls_tail_len - 1]] : [] }';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_tail = '.$lowered_target.'; if (defined($__ls_tail) && ref($__ls_tail) eq \'ARRAY\') { my $__ls_tail_len = scalar(@{$__ls_tail}); $__ls_tail_len > 1 ? [@{$__ls_tail}[1 .. $__ls_tail_len - 1]] : [] } else { [] } }'
   unless $tail_has_explicit_count;
  return 'do { my $__ls_tail = '.$lowered_target.'; if (defined($__ls_tail) && ref($__ls_tail) eq \'ARRAY\') { my $__ls_tail_skip = '.$tail_skip_expr.'; $__ls_tail_skip = 0 unless defined($__ls_tail_skip) && $__ls_tail_skip =~ /\A-?\d+\z/; $__ls_tail_skip = 0 if $__ls_tail_skip < 0; my $__ls_tail_len = scalar(@{$__ls_tail}); $__ls_tail_len > $__ls_tail_skip ? [@{$__ls_tail}[$__ls_tail_skip .. $__ls_tail_len - 1]] : [] } else { [] } }';
 }
 if ($method_call && $method_call->{method} eq 'take') {
  my $take_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 2);
  return undef unless $take_args;

  my $target_expr = $trim_action_ir_value->($take_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $take_has_explicit_count = (@{$take_args} > 1 && defined($take_args->[1])) ? 1 : 0;
  my $take_count_expr = '1';
  if ($take_has_explicit_count) {
   $take_count_expr = _lower_method_value_expr($take_args->[1], $deps);
   $take_count_expr = $trim_action_ir_value->($take_args->[1]) unless defined($take_count_expr) && length($take_count_expr);
   return undef unless defined($take_count_expr) && length($take_count_expr);
  }

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
   return 'do { my $__ls_take_len = scalar(@'.$array_symbol.'); $__ls_take_len ? [@'.$array_symbol.'[0 .. 0]] : [] }'
    unless $take_has_explicit_count;
   return 'do { my $__ls_take_count = '.$take_count_expr.'; $__ls_take_count = 0 unless defined($__ls_take_count) && $__ls_take_count =~ /\A-?\d+\z/; $__ls_take_count = 0 if $__ls_take_count < 0; my $__ls_take_len = scalar(@'.$array_symbol.'); if ($__ls_take_count > 0 && $__ls_take_len) { my $__ls_take_end = $__ls_take_count < $__ls_take_len ? $__ls_take_count - 1 : $__ls_take_len - 1; [@'.$array_symbol.'[0 .. $__ls_take_end]] } else { [] } }';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_take = '.$lowered_target.'; if (defined($__ls_take) && ref($__ls_take) eq \'ARRAY\') { my $__ls_take_len = scalar(@{$__ls_take}); $__ls_take_len ? [@{$__ls_take}[0 .. 0]] : [] } else { [] } }'
   unless $take_has_explicit_count;
  return 'do { my $__ls_take = '.$lowered_target.'; if (defined($__ls_take) && ref($__ls_take) eq \'ARRAY\') { my $__ls_take_count = '.$take_count_expr.'; $__ls_take_count = 0 unless defined($__ls_take_count) && $__ls_take_count =~ /\A-?\d+\z/; $__ls_take_count = 0 if $__ls_take_count < 0; my $__ls_take_len = scalar(@{$__ls_take}); if ($__ls_take_count > 0 && $__ls_take_len) { my $__ls_take_end = $__ls_take_count < $__ls_take_len ? $__ls_take_count - 1 : $__ls_take_len - 1; [@{$__ls_take}[0 .. $__ls_take_end]] } else { [] } } else { [] } }';
 }
 if ($method_call && $method_call->{method} eq 'take_last') {
  my $take_last_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 2);
  return undef unless $take_last_args;

  my $target_expr = $trim_action_ir_value->($take_last_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $take_last_has_explicit_count = (@{$take_last_args} > 1 && defined($take_last_args->[1])) ? 1 : 0;
  my $take_last_count_expr = '1';
  if ($take_last_has_explicit_count) {
   $take_last_count_expr = _lower_method_value_expr($take_last_args->[1], $deps);
   $take_last_count_expr = $trim_action_ir_value->($take_last_args->[1]) unless defined($take_last_count_expr) && length($take_last_count_expr);
   return undef unless defined($take_last_count_expr) && length($take_last_count_expr);
  }

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
   return 'do { my $__ls_take_last_len = scalar(@'.$array_symbol.'); $__ls_take_last_len ? [@'.$array_symbol.'[$__ls_take_last_len - 1 .. $__ls_take_last_len - 1]] : [] }'
    unless $take_last_has_explicit_count;
   return 'do { my $__ls_take_last_count = '.$take_last_count_expr.'; $__ls_take_last_count = 0 unless defined($__ls_take_last_count) && $__ls_take_last_count =~ /\A-?\d+\z/; $__ls_take_last_count = 0 if $__ls_take_last_count < 0; my $__ls_take_last_len = scalar(@'.$array_symbol.'); if ($__ls_take_last_count > 0 && $__ls_take_last_len) { my $__ls_take_last_start = $__ls_take_last_count < $__ls_take_last_len ? $__ls_take_last_len - $__ls_take_last_count : 0; [@'.$array_symbol.'[$__ls_take_last_start .. $__ls_take_last_len - 1]] } else { [] } }';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_take_last = '.$lowered_target.'; if (defined($__ls_take_last) && ref($__ls_take_last) eq \'ARRAY\') { my $__ls_take_last_len = scalar(@{$__ls_take_last}); $__ls_take_last_len ? [@{$__ls_take_last}[$__ls_take_last_len - 1 .. $__ls_take_last_len - 1]] : [] } else { [] } }'
   unless $take_last_has_explicit_count;
  return 'do { my $__ls_take_last = '.$lowered_target.'; if (defined($__ls_take_last) && ref($__ls_take_last) eq \'ARRAY\') { my $__ls_take_last_count = '.$take_last_count_expr.'; $__ls_take_last_count = 0 unless defined($__ls_take_last_count) && $__ls_take_last_count =~ /\A-?\d+\z/; $__ls_take_last_count = 0 if $__ls_take_last_count < 0; my $__ls_take_last_len = scalar(@{$__ls_take_last}); if ($__ls_take_last_count > 0 && $__ls_take_last_len) { my $__ls_take_last_start = $__ls_take_last_count < $__ls_take_last_len ? $__ls_take_last_len - $__ls_take_last_count : 0; [@{$__ls_take_last}[$__ls_take_last_start .. $__ls_take_last_len - 1]] } else { [] } } else { [] } }';
 }
 if ($method_call && ($method_call->{method} eq 'drop_last' || $method_call->{method} eq 'drop_back')) {
  my $drop_last_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 2);
  return undef unless $drop_last_args;

  my $target_expr = $trim_action_ir_value->($drop_last_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $drop_last_has_explicit_count = (@{$drop_last_args} > 1 && defined($drop_last_args->[1])) ? 1 : 0;
  my $drop_last_count_expr = '1';
  if ($drop_last_has_explicit_count) {
   $drop_last_count_expr = _lower_method_value_expr($drop_last_args->[1], $deps);
   $drop_last_count_expr = $trim_action_ir_value->($drop_last_args->[1]) unless defined($drop_last_count_expr) && length($drop_last_count_expr);
   return undef unless defined($drop_last_count_expr) && length($drop_last_count_expr);
  }

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
   return 'do { my $__ls_drop_last_len = scalar(@'.$array_symbol.'); $__ls_drop_last_len > 1 ? [@'.$array_symbol.'[0 .. $__ls_drop_last_len - 2]] : [] }'
    unless $drop_last_has_explicit_count;
   return 'do { my $__ls_drop_last_count = '.$drop_last_count_expr.'; $__ls_drop_last_count = 0 unless defined($__ls_drop_last_count) && $__ls_drop_last_count =~ /\A-?\d+\z/; $__ls_drop_last_count = 0 if $__ls_drop_last_count < 0; my $__ls_drop_last_len = scalar(@'.$array_symbol.'); if ($__ls_drop_last_len > $__ls_drop_last_count) { my $__ls_drop_last_end = $__ls_drop_last_len - $__ls_drop_last_count - 1; [@'.$array_symbol.'[0 .. $__ls_drop_last_end]] } elsif ($__ls_drop_last_count == 0 && $__ls_drop_last_len) { [@'.$array_symbol.'[0 .. $__ls_drop_last_len - 1]] } else { [] } }';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_drop_last = '.$lowered_target.'; if (defined($__ls_drop_last) && ref($__ls_drop_last) eq \'ARRAY\') { my $__ls_drop_last_len = scalar(@{$__ls_drop_last}); $__ls_drop_last_len > 1 ? [@{$__ls_drop_last}[0 .. $__ls_drop_last_len - 2]] : [] } else { [] } }'
   unless $drop_last_has_explicit_count;
 return 'do { my $__ls_drop_last = '.$lowered_target.'; if (defined($__ls_drop_last) && ref($__ls_drop_last) eq \'ARRAY\') { my $__ls_drop_last_count = '.$drop_last_count_expr.'; $__ls_drop_last_count = 0 unless defined($__ls_drop_last_count) && $__ls_drop_last_count =~ /\A-?\d+\z/; $__ls_drop_last_count = 0 if $__ls_drop_last_count < 0; my $__ls_drop_last_len = scalar(@{$__ls_drop_last}); if ($__ls_drop_last_len > $__ls_drop_last_count) { my $__ls_drop_last_end = $__ls_drop_last_len - $__ls_drop_last_count - 1; [@{$__ls_drop_last}[0 .. $__ls_drop_last_end]] } elsif ($__ls_drop_last_count == 0 && $__ls_drop_last_len) { [@{$__ls_drop_last}[0 .. $__ls_drop_last_len - 1]] } else { [] } } else { [] } }';
 }
 if ($method_call && $method_call->{method} eq 'concat_arrays') {
  my $concat_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, undef);
  return undef unless $concat_args && @$concat_args >= 1;

  my @parts;
  foreach my $arg (@$concat_args) {
   my $target_expr = $trim_action_ir_value->($arg);
   return undef unless defined($target_expr) && length($target_expr);

   my $array_symbol = $extract_array_symbol_name->($target_expr);
   if (defined($array_symbol) && length($array_symbol) && $target_expr =~ /^(?:array\s*\(\s*\w+\s*\)|\w+)$/o) {
    push @parts, '@'.$array_symbol;
    next;
   }

   return undef unless $looks_like_array_value_expr->($target_expr);

   my $lowered_target = _lower_method_value_expr($target_expr, $deps);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
   return undef unless defined($lowered_target) && length($lowered_target);

   push @parts, 'do { my $__ls_concat_arrays = '.$lowered_target.'; defined($__ls_concat_arrays) && ref($__ls_concat_arrays) eq \'ARRAY\' ? @{$__ls_concat_arrays} : () }';
  }

  return '['.join(', ', @parts).']';
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
 if ($method_call && $method_call->{method} eq 'set_key') {
  my $set_key_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 3, 3);
  return undef unless $set_key_args;

  my $target_expr = $trim_action_ir_value->($set_key_args->[0]);
  my $key_expr = $trim_action_ir_value->($set_key_args->[1]);
  my $value_expr = $trim_action_ir_value->($set_key_args->[2]);
  return undef unless defined($target_expr) && length($target_expr);
  return undef unless defined($key_expr) && length($key_expr);
  return undef unless defined($value_expr) && length($value_expr);

  my $key_lowered = $lower_scalar_access_key_expr->($key_expr);
  return undef unless defined($key_lowered) && length($key_lowered);

  my $value_lowered = _lower_method_value_expr($value_expr, $deps);
  $value_lowered = $value_expr unless defined($value_lowered) && length($value_lowered);
  return undef unless defined($value_lowered) && length($value_lowered);

  my $lowered_target;
  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o) {
   $lowered_target = '\\%'.$hash_symbol;
  } else {
   $lowered_target = _lower_method_value_expr($target_expr, $deps);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  }
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_set_key_source = '.$lowered_target.'; my %__ls_set_key = defined($__ls_set_key_source) ? %{$__ls_set_key_source} : (); $__ls_set_key{'.$key_lowered.'} = '.$value_lowered.'; \%__ls_set_key }';
 }
 if ($method_call && $method_call->{method} eq 'rename_key') {
  my $rename_key_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 3, 3);
  return undef unless $rename_key_args;

  my $target_expr = $trim_action_ir_value->($rename_key_args->[0]);
  my $old_key_expr = $trim_action_ir_value->($rename_key_args->[1]);
  my $new_key_expr = $trim_action_ir_value->($rename_key_args->[2]);
  return undef unless defined($target_expr) && length($target_expr);
  return undef unless defined($old_key_expr) && length($old_key_expr);
  return undef unless defined($new_key_expr) && length($new_key_expr);

  my $old_key_lowered = $lower_scalar_access_key_expr->($old_key_expr);
  my $new_key_lowered = $lower_scalar_access_key_expr->($new_key_expr);
  return undef unless defined($old_key_lowered) && length($old_key_lowered);
  return undef unless defined($new_key_lowered) && length($new_key_lowered);

  my $lowered_target;
  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ /^(?:hash\s*\(\s*\w+\s*\)|\w+)$/o) {
   $lowered_target = '\\%'.$hash_symbol;
  } else {
   $lowered_target = _lower_method_value_expr($target_expr, $deps);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  }
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_rename_key_source = '.$lowered_target.'; if (defined($__ls_rename_key_source)) { my %__ls_rename_key = %{$__ls_rename_key_source}; if (exists $__ls_rename_key{'.$old_key_lowered.'}) { my $__ls_rename_key_value = delete $__ls_rename_key{'.$old_key_lowered.'}; $__ls_rename_key{'.$new_key_lowered.'} = $__ls_rename_key_value; } \%__ls_rename_key } else { {} } }';
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
  ($trimmed =~ /^(?:scalaref|scalar|array|hash|trim|lowercase|uppercase|length|replace_substr|num_abs|num_floor|num_ceil|num_round|num_add|num_sub|num_mul|num_div|num_min|num_max|starts_with|ends_with|contains_substr|matches|is_empty|is_nonempty|count|first|last|tail|drop_front|take|take_last|drop_last|drop_back|concat_arrays|contains|count_keys|sorted_keys|sorted_values|has_key|merge_hash|set_key|rename_key|drop_keys|pick_keys|join_values|coalesce|array_copy|array_values|flat_array|flat_hash|flatten|flat)\s*\(/o || $direct ne $trimmed)
 ) {
  return $direct;
 }

 my $rewritten = $trimmed;
 for (1 .. 64) {
  my $before = $rewritten;
  $rewritten =~ s/\b(?<helper>(?:scalaref|scalar|array_copy|array_values|trim|lowercase|uppercase|length|replace_substr|num_abs|num_floor|num_ceil|num_round|num_add|num_sub|num_mul|num_div|num_min|num_max|starts_with|ends_with|contains_substr|matches|is_empty|is_nonempty|count|first|last|tail|drop_front|take|take_last|drop_last|drop_back|concat_arrays|contains|count_keys|sorted_keys|sorted_values|has_key|merge_hash|set_key|rename_key|drop_keys|pick_keys|join_values|coalesce|flat_array|flat_hash|flatten|flat|array|hash)\s*(?<PAREN>\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/do {
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
