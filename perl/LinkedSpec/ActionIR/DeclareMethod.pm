package LinkedSpec::ActionIR::DeclareMethod;

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
 die "(LinkedSpec::ActionIR::DeclareMethod::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $lower_flow_composite_expr = _require_dep($deps, 'lower_flow_composite_expr');
 my $lower_method_value_expr = _require_dep($deps, 'lower_method_value_expr');

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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 return undef unless defined $type;
 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($type eq 'array') {
  my $array_ctor = $parse_method_function_expr->($trimmed);
  if ($array_ctor && $array_ctor->{method} eq 'array') {
   my $items = $array_ctor->{args} || [];
   return undef unless ref($items) eq 'ARRAY';
   my @lowered_items = map { _lower_declare_value_expr($_, $deps) } @$items;
   return undef if grep { !defined($_) || !length($_) } @lowered_items;
   return '('.join(', ', @lowered_items).')';
  }
  if ($trimmed =~ /^\[(?<payload>.*)\]$/s) {
   return '('.$+{payload}.')';
  }
 }

 if ($type eq 'hash') {
  my $hash_ctor = $parse_method_function_expr->($trimmed);
  if ($hash_ctor && $hash_ctor->{method} eq 'hash') {
   my $items = $hash_ctor->{args} || [];
   return undef unless ref($items) eq 'ARRAY';
   return undef unless @$items % 2 == 0;
   my @pairs;
   for (my $i = 0; $i < @$items; $i += 2) {
    my $key_expr = _lower_declare_value_expr($items->[$i], $deps);
    my $val_expr = _lower_declare_value_expr($items->[$i + 1], $deps);
    return undef unless defined($key_expr) && length($key_expr);
    return undef unless defined($val_expr) && length($val_expr);
    push @pairs, $key_expr.' => '.$val_expr;
   }
   return '('.join(', ', @pairs).')';
  }
  if ($trimmed =~ /^\{(?<payload>.*)\}$/s) {
   return '('.$+{payload}.')';
  }
 }

 return _lower_declare_value_expr($trimmed, $deps)
}

sub _extract_declare_statement_from_method_expr {
 my ($expr, $deps) = @_;
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $is_bare_method_scope_token = _require_dep($deps, 'is_bare_method_scope_token');
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $declare_alias_to_type = _require_dep($deps, 'declare_alias_to_type');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call;
 my $method = $call->{method} // '';

 if ($method eq 'declare') {
  my @effective_args = @{$call->{args} || []};
  if (
   @effective_args >= 3 &&
   $is_bare_method_scope_token->($effective_args[0]) &&
   defined($trim_action_ir_value->($effective_args[1])) &&
   $trim_action_ir_value->($effective_args[1]) =~ /^(array|scalar|hash)$/o
  ) {
   shift @effective_args;
  }

  return undef unless @effective_args >= 2;
  my $type = $trim_action_ir_value->($effective_args[0]);
  return undef unless defined($type) && $type =~ /^(array|scalar|hash)$/o;
  my @entries = @effective_args[1 .. $#effective_args];
  return undef unless @entries;
  return {
   declaration_type => $type,
   entries          => \@entries,
  };
 }

 if ($method =~ /^declare_(?<alias>a|array|s|scalar|h|hash)$/o) {
  my $type = $declare_alias_to_type->($+{alias});
  return undef unless defined $type;
  my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, undef);
  return undef unless $effective_args && @$effective_args >= 1;
  return {
   declaration_type => $type,
   entries          => [@$effective_args],
  };
 }

 return undef
}

sub _lower_declare_method_statement {
 my ($expr, $deps) = @_;
 my $lower_typed_declare_statement = _require_dep($deps, 'lower_typed_declare_statement');
 my $decl = _extract_declare_statement_from_method_expr($expr, $deps);
 return undef unless $decl;
 return $lower_typed_declare_statement->($decl->{declaration_type}, $decl->{entries})
}

sub _lower_assign_method_statement {
 my ($expr, $deps) = @_;
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');
 my $lower_assign_statement = _require_dep($deps, 'lower_assign_statement');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'assign';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 2, 2);
 return undef unless $effective_args;
 return $lower_assign_statement->($effective_args->[0], $effective_args->[1])
}

1;
