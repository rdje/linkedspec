package LinkedSpec::ActionIR::MethodLowering;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub _require_dep {
 my ($deps, $name) = @_;
 my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
 die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
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
# Purpose : Lower method DSL value expressions (`scalar(...)`, `array(...)`)
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

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $method_call = $parse_method_function_expr->($trimmed);
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
#           `[]/{}` literals while lowering embedded scalar/array/hash helpers.
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
  ($trimmed =~ /^(?:scalaref|scalar|array|hash)\s*\(/o || $direct ne $trimmed)
 ) {
  return $direct;
 }

 my $rewritten = $trimmed;
 for (1 .. 64) {
  my $before = $rewritten;
  $rewritten =~ s/\b(?<helper>(?:scalaref|scalar|array|hash)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/do {
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
 my $lower_assignment_source_expr = _require_dep($deps, 'lower_assignment_source_expr');

 my $symbol = $extract_scalar_symbol_name->($target);
 return undef unless defined $symbol;
 my $source_expr = $lower_assignment_source_expr->($source);
 return undef unless defined $source_expr;
 return "\$$symbol = $source_expr"
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
