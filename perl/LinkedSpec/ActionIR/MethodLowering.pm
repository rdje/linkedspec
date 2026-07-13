package LinkedSpec::ActionIR::MethodLowering;

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
use LinkedSpec::Numeric ();
use LinkedSpec::UnicodeCaseMapping ();

use constant ACTIONIR_TRACE_OWNER => 'method_lowering';

sub _trace_method_decision {
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

sub _trace_method_enter {
 my ($phase, $label, $details) = @_;
 return LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => ACTIONIR_TRACE_OWNER,
  phase => $phase,
  label => $label,
  details => $details,
 );
}

sub _trace_method_exit {
 my ($scope, $details) = @_;
 return LinkedSpec::ActionIR::Trace::exit_scope($scope, $details);
}

sub _trace_method_finish {
 my ($scope, $phase, $label, $result, $decision, $context) = @_;
 _trace_method_decision(
  phase => $phase,
  label => $label,
  decision => $decision,
  taken => defined($result) ? 1 : 0,
  context => $context,
 );
 _trace_method_exit($scope, { status => defined($result) ? 'ok' : 'undef', decision => $decision });
 return $result
}

sub _method_value_helper_family {
 my ($method) = @_;
 return 'unknown' unless defined($method) && length($method);
 return 'control' if $method eq 'if' || $method eq 'switch';
 return 'rule_call' if $method eq 'call';
 return 'input' if $method =~ /^input_/o || $method =~ /^cursor_/o;
 return 'entry_match' if $method =~ /^(?:entry_|match_)/o;
 return 'string' if $method =~ /^(?:trim|lowercase|uppercase|length|substr|replace_substr|rm_prefix|rm_suffix|cat|str_|starts_with|ends_with|contains_substr|matches|coalesce|coalesce_nonempty)$/o;
 return 'numeric' if defined(_numeric_word_alias_helper_name($method)) || $method =~ /^num_/o;
 return 'array' if $method =~ /^(?:array|copy|flat|flat_array|count|first|last|drop_front|take|slice|take_last|drop_back|concat_arrays|split|split_tagged_records|sorted|reversed|contains|index_of|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match|join_values|entry_groups|match_groups)$/o;
 return 'hash' if $method =~ /^(?:hash|flat_hash|count_keys|sorted_keys|sorted_values|has_key|merge_hash|set_key|rename_key|drop_keys|pick_keys|entry_map|entry_named_map|match_map|match_named_map)$/o;
 return 'capture' if $method =~ /^(?:capture|start_capture|mark_|clear_mark)/o;
 return 'flow' if $method =~ /^(?:is_empty|is_nonempty|is_defined|is_undefined|and|or|not|eq|ne|gt|ge|lt|le)$/o;
 return 'unknown'
}

#------------------------------------------------------------------------------
# Package : LinkedSpec::ActionIR::MethodLowering
# Purpose : ActionIR owner for method/value/assignment/return lowering and the
#           default callback map that exposes those helpers to active callers.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Function: default_deps_for_package
# Purpose : Build the default callback map exported by this owner for active
#           ActionIR lowering callers.
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
   'split_declare_symbol_names',
   'parse_declare_binding_entry',
   'lower_declare_initializer_expr',
   'parse_method_function_expr',
   'normalize_method_args_with_optional_scope',
   'lower_direct_nested_access_value_expr',
   'extract_array_symbol_name',
   'extract_hash_symbol_name',
   'extract_scalar_symbol_name',
   'lower_scalar_access_key_expr',
   'lower_primitive_literal_expr',
   'infer_scalar_container_kind',
   'split_top_level_csv',
   'split_action_ir_statements',
   'lower_array_pipeline_expr',
   'lower_assignment_source_expr',
   'lower_flow_composite_expr',
   'strip_literal_delimiters',
  ],
 )
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
# Function: _infer_direct_shape_literal_kind
# Purpose : Classify an accepted direct [] / {} DSL value literal as an array or
#           hash source. This delegates acceptance to _lower_method_value_expr so
#           target inference cannot drift from shape-literal value lowering.
# Args    : ($expr, $deps)
# Returns : 'array', 'hash', or undef
#------------------------------------------------------------------------------
sub _infer_direct_shape_literal_kind {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed) >= 2;

 my $open = substr($trimmed, 0, 1);
 my $close = $open eq '[' ? ']' : $open eq '{' ? '}' : undef;
 return undef unless defined($close) && substr($trimmed, -1, 1) eq $close;

 my $lowered = _lower_method_value_expr($trimmed, $deps);
 return undef unless defined($lowered) && length($lowered);
 return 'array' if $open eq '[' && $lowered =~ /^\[.*\]$/s;
 return 'hash'  if $open eq '{' && $lowered =~ /^\{.*\}$/s;
 return undef
}

sub _infer_assignment_source_container_kind {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')
  ? $deps->{bare_symbol_kind}
  : sub { return undef };

 my $direct_kind = _infer_direct_shape_literal_kind($expr, $deps);
 return $direct_kind if defined($direct_kind);

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $call = $parse_method_function_expr->($trimmed);
 return undef unless $call;
 my $method = $call->{method} // '';
 return 'array' if $method =~ /^(?:array|flat_array|sorted|reversed|sorted_keys|sorted_values|drop_front|take|slice|take_last|drop_back|concat_arrays|split|split_tagged_records|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match|entry_groups|match_groups)$/o;
 return 'hash' if $method =~ /^(?:hash|flat_hash|merge_hash|set_key|rename_key|drop_keys|pick_keys|entry_map|entry_named_map|match_map|match_named_map)$/o;

 if ($method eq 'flat') {
  my $args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
  return undef unless $args;
  return _infer_assignment_source_container_kind($args->[0], $deps);
 }

 if ($method eq 'copy') {
  my $args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
  return undef unless $args;
  my $inner = $trim_action_ir_value->($args->[0]);
  return undef unless defined($inner) && length($inner);
  return 'array' if $inner =~ /^array\s*\(/o;
  return 'hash' if $inner =~ /^hash\s*\(/o;
  if ($inner =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
   my $kind = $bare_symbol_kind->($1);
   return $kind if defined($kind) && ($kind eq 'array' || $kind eq 'hash');
   return undef;
  }
  return _infer_assignment_source_container_kind($inner, $deps);
 }

 return undef
}

sub _lower_value_binding_source_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_assignment_source_expr = $require_dep->('lower_assignment_source_expr');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $bare_scalar_read = _lower_source_slot_bare_scalar_read_expr($trimmed, $deps);
 return $bare_scalar_read if defined($bare_scalar_read) && length($bare_scalar_read);

 my $value_expr = _lower_method_value_expr($trimmed, $deps);
 if (defined($value_expr) && length($value_expr) && $value_expr ne $trimmed) {
  my $container_kind = _infer_assignment_source_container_kind($trimmed, $deps);
  return '['.$value_expr.']'
   if defined($container_kind) && $container_kind eq 'array' && $value_expr =~ /^\s*\@/s;
  return '{'.$value_expr.'}'
   if defined($container_kind) && $container_kind eq 'hash' && $value_expr =~ /^\s*\%/s;
  return $value_expr;
 }

 return $lower_assignment_source_expr->($trimmed)
}

sub _extract_outer_brace_payload {
 my ($expr, $trim_action_ir_value) = @_;
 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed) >= 2;
 return undef unless substr($trimmed, 0, 1) eq '{';

 my $depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $escape_next = 0;
 my $len = length($trimmed);
 for (my $idx = 0; $idx < $len; ++$idx) {
  my $char = substr($trimmed, $idx, 1);
  if ($in_single_quote) {
   if ($escape_next) { $escape_next = 0; }
   elsif ($char eq '\\') { $escape_next = 1; }
   elsif ($char eq "'") { $in_single_quote = 0; }
   next;
  }
  if ($in_double_quote) {
   if ($escape_next) { $escape_next = 0; }
   elsif ($char eq '\\') { $escape_next = 1; }
   elsif ($char eq '"') { $in_double_quote = 0; }
   next;
  }
  if ($char eq "'") { $in_single_quote = 1; next; }
  if ($char eq '"') { $in_double_quote = 1; next; }
  if ($char eq '{') { ++$depth; next; }
  if ($char eq '}') {
   --$depth if $depth > 0;
   return undef if $depth == 0 && $idx != $len - 1;
  }
 }
 return undef unless $depth == 0 && substr($trimmed, -1, 1) eq '}';
 return substr($trimmed, 1, $len - 2)
}

sub _has_top_level_fat_arrow {
 my ($text) = @_;
 return 0 unless defined $text;

 my $paren_depth = 0;
 my $brace_depth = 0;
 my $bracket_depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $escape_next = 0;
 my $len = length($text);
 for (my $idx = 0; $idx < $len; ++$idx) {
  my $char = substr($text, $idx, 1);
  if ($in_single_quote) {
   if ($escape_next) { $escape_next = 0; }
   elsif ($char eq '\\') { $escape_next = 1; }
   elsif ($char eq "'") { $in_single_quote = 0; }
   next;
  }
  if ($in_double_quote) {
   if ($escape_next) { $escape_next = 0; }
   elsif ($char eq '\\') { $escape_next = 1; }
   elsif ($char eq '"') { $in_double_quote = 0; }
   next;
  }
  if ($char eq "'") { $in_single_quote = 1; next; }
  if ($char eq '"') { $in_double_quote = 1; next; }
  if ($char eq '(') { ++$paren_depth; next; }
  if ($char eq ')') { --$paren_depth if $paren_depth > 0; next; }
  if ($char eq '{') { ++$brace_depth; next; }
  if ($char eq '}') { --$brace_depth if $brace_depth > 0; next; }
  if ($char eq '[') { ++$bracket_depth; next; }
  if ($char eq ']') { --$bracket_depth if $bracket_depth > 0; next; }
  next unless $paren_depth == 0 && $brace_depth == 0 && $bracket_depth == 0;
  return 1 if $char eq '=' && $idx + 1 < $len && substr($text, $idx + 1, 1) eq '>';
  if ($char eq ':') {
   my $prev = $idx > 0 ? substr($text, $idx - 1, 1) : '';
   my $next = $idx + 1 < $len ? substr($text, $idx + 1, 1) : '';
   return 1 unless $prev eq ':' || $next eq ':';
  }
 }
 return 0
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
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $split_declare_symbol_names = $require_dep->('split_declare_symbol_names');
 my $parse_declare_binding_entry = $require_dep->('parse_declare_binding_entry');
 my $lower_declare_initializer_expr = $require_dep->('lower_declare_initializer_expr');

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
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return undef unless defined $tag;
 $tag = $trim_action_ir_value->($tag);
 return undef unless defined($tag) && length($tag);
 return $tag if $tag =~ /^\".*\"$/s || $tag =~ /^'.*'$/s;
 return "\"$tag\"" if $tag =~ /^\w+$/o;
 return $tag
}

sub _lower_inline_value_branch_payload_expr {
 my ($expr, $deps) = @_;
 my $payload_expr = _lower_return_payload_expr($expr, $deps);
 return undef unless defined($payload_expr) && length($payload_expr);
 return $payload_expr
}

sub _lower_inline_switch_case_value_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 # SPEC-FORMAT-TERSE.15.2.3 — inline value switch shares the statement-switch
 # case-label rule: a bare label is a literal tag, not a variable read. Branch
 # payloads still use normal value-position lowering.
 if ($trimmed =~ /^\w+$/o && $trimmed !~ /^(?:true|false)$/o) {
  return _normalize_method_tag_expr($trimmed, $deps);
 }

 return _lower_inline_value_branch_payload_expr($trimmed, $deps)
}

sub _lower_inline_if_value_expr {
 my ($method_call, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $lower_flow_composite_expr = $require_dep->('lower_flow_composite_expr');

 return undef unless ref($method_call) eq 'HASH' && ($method_call->{method} // '') eq 'if';
 my $effective_args = $method_call->{args} || [];
 return undef unless ref($effective_args) eq 'ARRAY' && @$effective_args >= 2;

 my $cond_expr = $lower_flow_composite_expr->($effective_args->[0]);
 return undef unless defined($cond_expr) && length($cond_expr);
 my $then_expr = _lower_inline_value_branch_payload_expr($effective_args->[1], $deps);
 return undef unless defined($then_expr) && length($then_expr);

 my @clauses = ('if ('.$cond_expr.') { $__ls_if_value = '.$then_expr.'; }');
 my $else_seen = 0;
 for (my $idx = 2; $idx < @$effective_args; ++$idx) {
  my $arg = $effective_args->[$idx];
  my $branch_call = $parse_method_function_expr->($arg);
  my $branch_method = $branch_call ? ($branch_call->{method} // '') : '';

  if ($branch_method eq 'elseif') {
   return undef if $else_seen;
   my $branch_args = $normalize_method_args_with_optional_scope->($branch_call->{args} || [], 2, 2);
   return undef unless $branch_args;
   my $branch_cond = $lower_flow_composite_expr->($branch_args->[0]);
   return undef unless defined($branch_cond) && length($branch_cond);
   my $branch_value = _lower_inline_value_branch_payload_expr($branch_args->[1], $deps);
   return undef unless defined($branch_value) && length($branch_value);
   push @clauses, 'elsif ('.$branch_cond.') { $__ls_if_value = '.$branch_value.'; }';
   next;
  }

  if ($branch_method eq 'else') {
   return undef if $else_seen;
   my $branch_args = $normalize_method_args_with_optional_scope->($branch_call->{args} || [], 1, 1);
   return undef unless $branch_args;
   my $branch_value = _lower_inline_value_branch_payload_expr($branch_args->[0], $deps);
   return undef unless defined($branch_value) && length($branch_value);
   push @clauses, 'else { $__ls_if_value = '.$branch_value.'; }';
   $else_seen = 1;
   next;
  }

  return undef if $else_seen || $idx != $#$effective_args;
  my $fallback_value = _lower_inline_value_branch_payload_expr($arg, $deps);
  return undef unless defined($fallback_value) && length($fallback_value);
  push @clauses, 'else { $__ls_if_value = '.$fallback_value.'; }';
  $else_seen = 1;
 }

 return 'do { my $__ls_if_value; '.join(' ', @clauses).' $__ls_if_value }'
}

sub _lower_inline_switch_value_expr {
 my ($method_call, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');

 return undef unless ref($method_call) eq 'HASH' && ($method_call->{method} // '') eq 'switch';
 my $effective_args = $method_call->{args} || [];
 return undef unless ref($effective_args) eq 'ARRAY' && @$effective_args >= 1;

 my $switch_expr = _lower_inline_value_branch_payload_expr($effective_args->[0], $deps);
 return undef unless defined($switch_expr) && length($switch_expr);

 my @statements = (
  'my $__ls_switch_source = '.$switch_expr.';',
  'my $__ls_switch_value;',
  'my $__ls_switch_done = 0;',
 );
 my $default_seen = 0;
 for (my $idx = 1; $idx < @$effective_args; ++$idx) {
  my $branch_call = $parse_method_function_expr->($effective_args->[$idx]);
  return undef unless $branch_call;
  my $branch_method = $branch_call->{method} // '';

  if ($branch_method eq 'case') {
   return undef if $default_seen;
   my $branch_args = $normalize_method_args_with_optional_scope->($branch_call->{args} || [], 2, 2);
   return undef unless $branch_args;
   my $case_expr = _lower_inline_switch_case_value_expr($branch_args->[0], $deps);
   return undef unless defined($case_expr) && length($case_expr);
   my $branch_value = _lower_inline_value_branch_payload_expr($branch_args->[1], $deps);
   return undef unless defined($branch_value) && length($branch_value);
   push @statements,
    'if (!$__ls_switch_done) { my $__ls_switch_case = '.$case_expr.'; if ((defined($__ls_switch_source) ? $__ls_switch_source : "") eq (defined($__ls_switch_case) ? $__ls_switch_case : "")) { $__ls_switch_value = '.$branch_value.'; $__ls_switch_done = 1; } }';
   next;
  }

  if ($branch_method eq 'default') {
   return undef if $default_seen;
   my $branch_args = $normalize_method_args_with_optional_scope->($branch_call->{args} || [], 1, 1);
   return undef unless $branch_args;
   my $branch_value = _lower_inline_value_branch_payload_expr($branch_args->[0], $deps);
   return undef unless defined($branch_value) && length($branch_value);
   push @statements,
    'if (!$__ls_switch_done) { $__ls_switch_value = '.$branch_value.'; $__ls_switch_done = 1; }';
   $default_seen = 1;
   next;
  }

  return undef;
 }

 push @statements, '$__ls_switch_value';
 return 'do { '.join(' ', @statements).' }'
}

sub _lower_block_value_component_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
 return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_primitive_literal_expr = $require_dep->('lower_primitive_literal_expr');
 my $lower_flow_composite_expr = $require_dep->('lower_flow_composite_expr');
 my $lower_direct_nested_access_value_expr = $require_dep->('lower_direct_nested_access_value_expr');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $block = _lower_block_value_expr($trimmed, $deps);
 return $block if defined($block) && length($block);

 my $bare_scalar_read = _lower_source_slot_bare_scalar_read_expr($trimmed, $deps);
 return $bare_scalar_read if defined($bare_scalar_read) && length($bare_scalar_read);

 my $literal = $lower_primitive_literal_expr->($trimmed);
 return $literal if defined($literal);

 my $direct_access = $lower_direct_nested_access_value_expr->($trimmed);
 return $direct_access if defined($direct_access) && length($direct_access);

 my $lowered = _lower_method_value_expr($trimmed, $deps);
 return undef unless defined($lowered) && length($lowered);
 return $lowered if $lowered ne $trimmed;
 return $lowered if $trimmed =~ /^\s*(?:\[\s*\]|\{\s*\})\s*$/s;
 return $lowered if $trimmed =~ /^\s*[\[\{]/s && $lowered =~ /^\s*[\[\{]/s;
 return undef
}

sub _lower_block_side_effect_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
 return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $ast_assign_lowered = _lower_ast_call_statement($trimmed, 'set', $deps);
 return $ast_assign_lowered if defined($ast_assign_lowered) && length($ast_assign_lowered);

 my $call = $parse_method_function_expr->($trimmed);
 return undef if $call && ($call->{method} // '') eq 'return';

 for my $lowerer (
  \&_lower_scalar_assignment_operator_statement,
  \&_lower_array_append_operator_statement,
  \&_lower_array_end_mutation_method_statement,
  \&_lower_hash_index_assignment_operator_statement,
  \&_lower_set_key_statement,
  \&_lower_push_statement,
 ) {
  my $lowered = $lowerer->($trimmed, $deps);
  return $lowered if defined($lowered) && length($lowered);
 }

 if ($call && (($call->{method} // '') eq 'set') && $trimmed =~ /^\s*set\s*\(/o) {
  my $args = $normalize_method_args_with_optional_scope->($call->{args} || [], 2, 2);
  return undef unless $args;
  my $lowered = _lower_assign_statement($args->[0], $args->[1], $deps);
  return $lowered if defined($lowered) && length($lowered);
 }

 return _lower_block_value_component_expr($trimmed, $deps)
}

sub _lower_ast_block_side_effect_statement {
 my ($stmt_or_node, $deps) = @_;
 my $node = ref($stmt_or_node) eq 'HASH' && ($stmt_or_node->{kind} // '') eq 'action_stmt'
  ? $stmt_or_node->{expr}
  : $stmt_or_node;
 return undef unless ref($node) eq 'HASH';

 my $kind = $node->{kind} // '';
 foreach my $candidate_kind ('assign_scalar', 'assign_array_append', 'assign_hash_index', 'assign_nested_access') {
  next unless $kind eq $candidate_kind;
  my $lowered = _lower_ast_assignment_operator_statement($node, $deps, $candidate_kind);
  return $lowered if defined($lowered) && length($lowered);
 }

 if ($kind eq 'fluent_chain') {
  my $lowered = _lower_ast_array_end_mutation_method_statement($node, $deps);
  return $lowered if defined($lowered) && length($lowered);
 }

 if ($kind eq 'call') {
  my $method = _actionir_ast_statement_method($node->{name}, $node->{source});
  return undef if defined($method) && $method eq 'return';
  if (defined($method) && $method =~ /^(?:set|set_key|push)$/o) {
   my $lowered = _lower_ast_call_statement(
    $node,
    ['set', 'set_key', 'push'],
    $deps,
   );
   return $lowered if defined($lowered) && length($lowered);
  }
 }

 my $source = _actionir_ast_value_source_expr($node);
 return undef unless defined($source) && length($source);
 return _lower_block_value_component_expr($source, $deps)
}

sub _lower_block_local_return_payload_expr {
 my ($statement, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($statement);
 return undef unless $call && ($call->{method} // '') eq 'return';

 my $args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
 return undef unless $args;
 my $payload_expr = _lower_return_payload_expr($args->[0], $deps);
 return undef unless defined($payload_expr) && length($payload_expr);
 $payload_expr = '+'.$payload_expr if $payload_expr =~ /^\s*\{/s;
 return $payload_expr
}

sub _lower_block_value_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $split_action_ir_statements = $require_dep->('split_action_ir_statements');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 unless (ref($deps) eq 'HASH' && $deps->{__actionir_ast_block_value_bridge}) {
  my $ast_node = _parse_method_value_ast_expr($expr, $deps);
  if (ref($ast_node) eq 'HASH' && ($ast_node->{kind} // '') eq 'block_value') {
   my $bridge_deps = ref($deps) eq 'HASH'
    ? { %$deps, __actionir_ast_block_value_bridge => 1 }
    : { __actionir_ast_block_value_bridge => 1 };
   my $ast_lowered = _lower_method_value_expr($expr, $bridge_deps);
   return $ast_lowered if defined($ast_lowered) && length($ast_lowered);
  }
 }

 my $payload = _extract_outer_brace_payload($expr, $trim_action_ir_value);
 return undef unless defined $payload;
 $payload = $trim_action_ir_value->($payload);
 return undef unless defined($payload) && length($payload);
 return undef if _has_top_level_fat_arrow($payload);

 my $statements = $split_action_ir_statements->($payload);
 return undef unless ref($statements) eq 'ARRAY' && @$statements;

 my @statements;
 foreach my $raw_statement (@$statements) {
  my $statement = $trim_action_ir_value->($raw_statement);
  push @statements, $statement if defined($statement) && length($statement);
 }
 return undef unless @statements;

 my @return_payloads;
 my $has_nonfinal_return = 0;
 for (my $idx = 0; $idx < @statements; ++$idx) {
  my $call = $parse_method_function_expr->($statements[$idx]);
  next unless $call && ($call->{method} // '') eq 'return';
  my $payload_expr = _lower_block_local_return_payload_expr($statements[$idx], $deps);
  return undef unless defined($payload_expr) && length($payload_expr);
  $return_payloads[$idx] = $payload_expr;
  $has_nonfinal_return = 1 if $idx < $#statements;
 }

 if ($has_nonfinal_return) {
  my @lowered = (
   'my $__ls_block_done = 0;',
   'my $__ls_block_value;',
  );
  for (my $idx = 0; $idx < @statements; ++$idx) {
   if (defined $return_payloads[$idx]) {
    push @lowered,
     'unless ($__ls_block_done) { $__ls_block_value = '.$return_payloads[$idx].'; $__ls_block_done = 1; };';
    next;
   }

   my $is_last = ($idx == $#statements);
   if ($is_last) {
    my $value_expr = _lower_block_value_component_expr($statements[$idx], $deps);
    return undef unless defined($value_expr) && length($value_expr);
    $value_expr = '+'.$value_expr if $value_expr =~ /^\s*\{/s;
    push @lowered,
     'unless ($__ls_block_done) { $__ls_block_value = '.$value_expr.'; $__ls_block_done = 1; };';
    next;
   }

   my $lowered_statement = _lower_block_side_effect_statement($statements[$idx], $deps);
   return undef unless defined($lowered_statement) && length($lowered_statement);
   push @lowered, 'unless ($__ls_block_done) { '.$lowered_statement.'; };';
  }

  return 'do { '.join(' ', @lowered).' $__ls_block_value }'
 }

 my @lowered;
 for (my $idx = 0; $idx < @statements; ++$idx) {
  my $statement = $statements[$idx];
  my $is_last = ($idx == $#statements);

  if ($is_last) {
   if (defined $return_payloads[$idx]) {
    push @lowered, $return_payloads[$idx];
    next;
   }

   my $value_expr = _lower_block_value_component_expr($statement, $deps);
   return undef unless defined($value_expr) && length($value_expr);
   $value_expr = '+'.$value_expr if $value_expr =~ /^\s*\{/s;
   push @lowered, $value_expr;
   next;
  }

  my $lowered_statement = _lower_block_side_effect_statement($statement, $deps);
  return undef unless defined($lowered_statement) && length($lowered_statement);
  push @lowered, $lowered_statement.';';
 }

 return undef unless @lowered;
 return 'do { '.join(' ', @lowered).' }'
}

sub _parse_method_value_ast_expr {
 my ($expr, $deps) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::AST');
 return LinkedSpec::ActionIR::AST::parse_action_expr($expr, { deps => $deps || {} })
}

sub _actionir_ast_quote_string_source {
 my ($value, $quote) = @_;
 $quote = '"' unless defined($quote) && ($quote eq '"' || $quote eq "'");
 $value = '' unless defined $value;
 $value =~ s/\\/\\\\/go;
 if ($quote eq "'") {
  $value =~ s/'/\\'/go;
 } else {
  $value =~ s/"/\\"/go;
 }
 return $quote.$value.$quote
}

sub _actionir_ast_plain_data_expr {
 my ($value) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'JSON::PP');
 my $json = JSON::PP->new->canonical(1)->allow_nonref(1)->utf8(1);
 my $hex = unpack('H*', $json->encode($value));
 return 'do { require JSON::PP; JSON::PP->new->utf8(1)->decode(pack("H*", "'.$hex.'")) }'
}

sub _actionir_ast_value_source_expr {
 my ($node) = @_;
 return undef unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';

 if ($kind eq 'number') {
  my $source = $node->{source};
  return $source if defined($source) && $source =~ /\A-?\d+(?:\.\d+)?\z/o;
  return defined($node->{value}) ? (''.$node->{value}) : undef;
 }
 return _actionir_ast_quote_string_source($node->{value}, $node->{quote})
  if $kind eq 'string';
 return 'undef' if $kind eq 'undef';
 return $node->{value} ? 'true' : 'false'
  if $kind eq 'boolean';
 return $node->{name}
  if $kind eq 'variable' && defined($node->{name}) && $node->{name} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return ':'.$node->{name}
  if $kind eq 'colon_scalar_slot_removed'
  && defined($node->{name})
  && $node->{name} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return _actionir_ast_retired_hash_literal_fat_arrow_expr()
  if $kind eq 'hash_literal_fat_arrow_removed';
 return $node->{source_text}
  if $kind eq 'codeblock_literal'
  && defined($node->{source_text})
  && length($node->{source_text});
 return _actionir_ast_unsupported_helper_expr($node->{code})
  if $kind eq 'codeblock_literal_error';
 if ($kind eq 'indexed_var') {
  return undef unless defined($node->{name}) && $node->{name} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  my $index = _actionir_ast_value_source_expr($node->{index});
  return undef unless defined($index) && length($index);
  return $node->{name}.'['.$index.']'
 }
 if ($kind eq 'nested_access') {
  return undef unless defined($node->{base}) && $node->{base} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  my $expr = $node->{base};
  foreach my $segment (@{$node->{segments} || []}) {
   return undef unless ref($segment) eq 'HASH';
   if (($segment->{kind} // '') eq 'key') {
    my $quote = '"';
    $quote = $1 if defined($segment->{source}) && $segment->{source} =~ /\A\[\s*(['"])/s;
    $expr .= '['._actionir_ast_quote_string_source($segment->{value}, $quote).']';
    next;
   }
   return undef unless ($segment->{kind} // '') eq 'index';
   my $index = _actionir_ast_value_source_expr($segment->{expr});
   return undef unless defined($index) && length($index);
   $expr .= '['.$index.']';
  }
  return $expr
 }
 if ($kind eq 'array_literal') {
  my @items;
  foreach my $item (@{$node->{items} || []}) {
   my $item_expr = _actionir_ast_value_source_expr($item);
   return undef unless defined($item_expr) && length($item_expr);
   push @items, $item_expr;
  }
  return '['.join(', ', @items).']'
 }
 if ($kind eq 'hash_literal') {
  my @pairs;
  foreach my $entry (@{$node->{entries} || []}) {
   return undef unless ref($entry) eq 'HASH';
   my $key_expr = _actionir_ast_value_source_expr($entry->{key});
   my $value_expr = _actionir_ast_value_source_expr($entry->{value});
   return undef unless defined($key_expr) && length($key_expr);
   return undef unless defined($value_expr) && length($value_expr);
   push @pairs, $key_expr.' : '.$value_expr;
  }
  return '{'.join(', ', @pairs).'}'
 }
 if ($kind eq 'call') {
  my $name = $node->{name};
  $name = $node->{source_method}
   if defined($node->{source_method}) && $node->{source_method} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  return undef unless defined($name) && $name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  my @args;
  foreach my $arg (@{$node->{args} || []}) {
   my $arg_expr = _actionir_ast_value_source_expr($arg);
   return undef unless defined($arg_expr) && length($arg_expr);
   push @args, $arg_expr;
  }
  return $name.'('.join(', ', @args).')'
 }
 if ($kind eq 'fluent_chain') {
  my $receiver = _actionir_ast_value_source_expr($node->{receiver});
  return undef unless defined($receiver) && length($receiver);
  my $expr = $receiver;
  foreach my $call (@{$node->{calls} || []}) {
   return undef unless ref($call) eq 'HASH';
   my $method = $call->{method};
   $method = $call->{source_method}
    if defined($call->{source_method}) && $call->{source_method} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
   return undef unless defined($method) && $method =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
   my @args;
   foreach my $arg (@{$call->{args} || []}) {
    my $arg_expr = _actionir_ast_value_source_expr($arg);
    return undef unless defined($arg_expr) && length($arg_expr);
    push @args, $arg_expr;
   }
   $expr .= '.'.$method.'('.join(', ', @args).')';
  }
  return $expr
 }
 return undef
}

sub _lower_ast_nested_access_assignment_value_node {
 my ($node, $deps) = @_;
 return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'assign_nested_access';

 my $base = $node->{base};
 return undef unless defined($base) && $base =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 my $segments = $node->{segments};
 return undef unless ref($segments) eq 'ARRAY' && @$segments > 1;

 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $lower_scalar_access_key_expr = $require_dep->('lower_scalar_access_key_expr');

 my $value_source = _actionir_ast_value_source_expr($node->{value});
 $value_source = $node->{value}{source}
  if ref($node->{value}) eq 'HASH' && !(defined($value_source) && length($value_source));
 return undef unless defined($value_source) && length($value_source);
 my $value_lowered = _lower_mutation_slot_value_expr($value_source, $deps);
 return undef unless defined($value_lowered) && length($value_lowered);

 my @prefix;
 my @compiled_segments;
 for (my $idx = 0; $idx < @$segments; ++$idx) {
  my $segment = $segments->[$idx];
  return undef unless ref($segment) eq 'HASH';
  if (($segment->{kind} // '') eq 'key') {
   my $quote = '"';
   $quote = $1 if defined($segment->{source}) && $segment->{source} =~ /\A\[\s*(['"])/s;
   my $var = '$__ls_path_key_'.$idx;
   push @prefix, 'my '.$var.' = '._actionir_ast_quote_string_source($segment->{value}, $quote).';';
   push @compiled_segments, { kind => 'key', var => $var };
   next;
  }
  return undef unless ($segment->{kind} // '') eq 'index';
  my $index_source = _actionir_ast_value_source_expr($segment->{expr});
  $index_source = $segment->{expr}{source}
   if ref($segment->{expr}) eq 'HASH' && !(defined($index_source) && length($index_source));
  return undef unless defined($index_source) && length($index_source);
  my $index_lowered = $lower_scalar_access_key_expr->($index_source);
  return undef unless defined($index_lowered) && length($index_lowered);
  my $var = '$__ls_path_idx_'.$idx;
  push @prefix, 'my '.$var.' = int(('.$index_lowered.') // 0);';
  push @compiled_segments, { kind => 'index', var => $var };
 }
 push @prefix, 'my $__ls_path_value = '.$value_lowered.';';
 push @prefix, 'my $__ls_path_cursor = $'.$base.';';
 push @prefix, 'my $__ls_path_ok = (ref($__ls_path_cursor) eq "HASH" || ref($__ls_path_cursor) eq "ARRAY") ? 1 : 0;';

 my @body = @prefix;
 for (my $idx = 0; $idx < $#compiled_segments; ++$idx) {
  my $segment = $compiled_segments[$idx];
  my $var = $segment->{var};
  if ($segment->{kind} eq 'key') {
   push @body,
    'if ($__ls_path_ok) { if (ref($__ls_path_cursor) eq "HASH" && exists $__ls_path_cursor->{'.$var.'}) { $__ls_path_cursor = $__ls_path_cursor->{'.$var.'}; } else { $__ls_path_ok = 0; } }';
  } else {
   push @body,
    'if ($__ls_path_ok) { if (ref($__ls_path_cursor) eq "ARRAY" && '.$var.' >= 0 && '.$var.' < @{$__ls_path_cursor}) { $__ls_path_cursor = $__ls_path_cursor->['.$var.']; } else { $__ls_path_ok = 0; } }';
  }
 }

 my $final = $compiled_segments[-1];
 my $final_var = $final->{var};
 if ($final->{kind} eq 'key') {
  push @body,
   'if ($__ls_path_ok) { if (ref($__ls_path_cursor) eq "HASH") { $__ls_path_cursor->{'.$final_var.'} = $__ls_path_value; } else { $__ls_path_ok = 0; } }';
 } else {
  push @body,
   'if ($__ls_path_ok) { if (ref($__ls_path_cursor) eq "ARRAY" && '.$final_var.' >= 0 && '.$final_var.' <= @{$__ls_path_cursor}) { if ('.$final_var.' == @{$__ls_path_cursor}) { push @{$__ls_path_cursor}, $__ls_path_value; } else { splice @{$__ls_path_cursor}, '.$final_var.', 1, $__ls_path_value; } } else { $__ls_path_ok = 0; } }';
 }
 push @body, '$__ls_path_ok ? $'.$base.' : undef';
 return 'do { '.join(' ', @body).' }'
}

sub _lower_ast_scalar_held_hash_index_assignment_value_node {
 my ($node, $deps) = @_;
 return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'assign_hash_index';
 my $target = $node->{name};
 return undef unless defined($target) && $target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;

 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $lower_scalar_access_key_expr = $require_dep->('lower_scalar_access_key_expr');

 my $key_source = _actionir_ast_value_source_expr($node->{key});
 $key_source = $node->{key}{source}
  if ref($node->{key}) eq 'HASH' && !(defined($key_source) && length($key_source));
 my $value_source = _actionir_ast_value_source_expr($node->{value});
 $value_source = $node->{value}{source}
  if ref($node->{value}) eq 'HASH' && !(defined($value_source) && length($value_source));
 return undef unless defined($key_source) && length($key_source);
 return undef unless defined($value_source) && length($value_source);

 my $key_lowered = $lower_scalar_access_key_expr->($key_source);
 return undef unless defined($key_lowered) && length($key_lowered);
 my $value_lowered = _lower_mutation_slot_value_expr($value_source, $deps);
 return undef unless defined($value_lowered) && length($value_lowered);
 return _uniform_binding_hash_index_set_expr($target, $key_lowered, $value_lowered)
}

sub _actionir_ast_unsupported_helper_expr {
 my ($method) = @_;
 return undef unless defined($method) && $method =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 _trace_method_decision(
  phase => 'unsupported_helper_expr',
  label => 'helper',
  decision => 'unsupported_helper',
  taken => 1,
  context => { method => $method },
 );
 return 'do { my $__ls_actionir_unsupported_helper = "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:'.$method.'"; undef }'
}

sub _uniform_binding_array_push_expr {
 my ($target, $value_expr) = @_;
 return undef unless defined($target) && $target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return undef unless defined($value_expr) && length($value_expr);
 return 'do { require LinkedSpec::BindingRuntime; $'.$target.' = '
  .'LinkedSpec::BindingRuntime::push_value($'.$target.', "'.$target.'", '.$value_expr.') }'
}

sub _uniform_binding_target_symbol {
 my ($target_expr, $container, $deps) = @_;
 return undef unless defined($target_expr) && defined($container);
 return $1 if $target_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o;
 return undef unless $target_expr =~ /^\Q$container\E\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o;
 my $name = $1;
 my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')
  ? $deps->{bare_symbol_kind}
  : sub { return undef };
 return (($bare_symbol_kind->($name) // '') eq 'scalar') ? $name : undef
}

sub _uniform_binding_hash_index_set_expr {
 my ($target, $key_expr, $value_expr) = @_;
 return undef unless defined($target) && $target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return undef unless defined($key_expr) && length($key_expr);
 return undef unless defined($value_expr) && length($value_expr);
 return 'do { require LinkedSpec::BindingRuntime; $'.$target.' = '
  .'LinkedSpec::BindingRuntime::index_set($'.$target.', "'.$target.'", '.$key_expr.', '.$value_expr.') }'
}

sub _uniform_binding_array_end_expr {
 my ($target, $operation, $value_expr) = @_;
 return undef unless defined($target) && $target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return undef unless defined($operation) && $operation =~ /\A(?:push_front|push_back|pop_front|pop_back)\z/o;
 my $args = (defined($value_expr) && length($value_expr)) ? ', '.$value_expr : '';
 return 'do { require LinkedSpec::BindingRuntime; $'.$target.' = '
  .'LinkedSpec::BindingRuntime::array_end_mutation($'.$target.', "'.$target.'", "'.$operation.'"'.$args.') }'
}

sub _uniform_binding_ambiguous_push_expr {
 my ($rule_or_target, $destination_or_value) = @_;
 return undef unless defined($rule_or_target) && $rule_or_target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return undef unless defined($destination_or_value) && $destination_or_value =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return 'do { require LinkedSpec::BindingRuntime; '
  .'my $__ls_push_entry = $$descr{spec}{'.$rule_or_target.'}; '
  .'my $__ls_push_handler = ref($__ls_push_entry) eq "CODE" ? $__ls_push_entry : '
  .'ref($__ls_push_entry) eq "HASH" ? $__ls_push_entry->{handler} : undef; '
  .'if (ref($__ls_push_handler) eq "CODE") { '
  .'$'.$destination_or_value.' = LinkedSpec::BindingRuntime::push_value($'.$destination_or_value.', "'.$destination_or_value.'", '
  .'$__ls_push_handler->($descr, $STRING, $minfo)) '
  .'} else { $'.$rule_or_target.' = LinkedSpec::BindingRuntime::push_value($'.$rule_or_target.', "'.$rule_or_target.'", $'.$destination_or_value.') } }'
}

sub _actionir_ast_retired_colon_scalar_slot_expr {
 my ($name) = @_;
 $name = '<unknown>' unless defined($name) && length($name);
 _trace_method_decision(
  phase => 'retired_colon_scalar_slot_expr',
  label => 'expr',
  decision => 'colon_scalar_slot_use_bare_read',
  taken => 1,
  context => { symbol => $name },
 );
 return 'do { my $__ls_actionir_unsupported_helper = "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read"; undef }'
}

sub _actionir_ast_retired_hash_literal_fat_arrow_expr {
 _trace_method_decision(
  phase => 'retired_hash_literal_fat_arrow_expr',
  label => 'expr',
  decision => 'hash_literal_use_colon',
  taken => 1,
  context => {},
 );
 return 'do { my $__ls_actionir_unsupported_helper = "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon"; undef }'
}

sub _actionir_ast_statement_method {
 my ($method, $source) = @_;
 return undef unless defined($method) && length($method);
 return $method
}

sub _actionir_ast_call_arg_sources {
 my ($node) = @_;
 return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'call';
 my @args;
 foreach my $arg (@{$node->{args} || []}) {
  my $arg_expr = _actionir_ast_value_source_expr($arg);
  return undef unless defined($arg_expr) && length($arg_expr);
  push @args, $arg_expr;
 }
 return \@args
}

sub _actionir_ast_expected_statement_method {
 my ($method, $expected) = @_;
 return 1 unless defined($expected);
 my @expected = ref($expected) eq 'ARRAY' ? @$expected : ($expected);
 foreach my $candidate (@expected) {
  return 1 if defined($candidate) && $method eq $candidate;
 }
 return 0
}

sub _actionir_ast_known_value_call_method {
 my ($method) = @_;
 return undef unless defined($method) && length($method);
 return '=' if $method eq '=';
 my $numeric_alias = _numeric_word_alias_helper_name($method);
 return $numeric_alias if defined($numeric_alias) && length($numeric_alias);
 state %known = map { $_ => 1 } qw(
  _trace_runtime_mark_event
  CAPTURE CAPTURE_IF save_cursor restore_cursor rewind_match_start rewind_entry_start
  if i when elseif elif else otherwise endif switch case default endcase endswitch while
  or and not eq ne gt ge lt le is_defined is_undefined is_empty is_nonempty
  return return_undef
  set
  call push push_back push_front pop_back pop_front set_key print say exit_now exit next
  trim lowercase uppercase length substr replace_substr rm_prefix rm_suffix cat
  str_eq str_ne str_gt str_ge str_lt str_le starts_with ends_with contains_substr matches coalesce coalesce_nonempty
  num_abs num_floor num_ceil num_round num_add num_sub num_mul num_div num_mod num_clamp
  num_min num_max num_eq num_ne num_gt num_ge num_lt num_le num_sum num_avg num_median num_range
  array hash copy flat flat_array flat_hash
  count first last drop_front take slice take_last drop_back concat_arrays split split_tagged_records
  sorted reversed contains index_of split_each trim_each filter_nonempty lowercase_each uppercase_each
  __array_value_split_each __array_value_trim_each __array_value_filter_nonempty __array_value_lowercase_each
  __array_value_uppercase_each __array_value_uniq __array_value_filter_match
  uniq filter_match count_keys sorted_keys sorted_values has_key merge_hash rename_key drop_keys pick_keys
  join_values
  input_slice input_text input_len input_end_pos input_end_line input_end_col
  entry_text entry_group entry_groups entry_named entry_has entry_map entry_named_map
  entry_line entry_start_line entry_col entry_start_col entry_len entry_start_pos entry_end_pos
  entry_end_line entry_end_col
  match_text match_group match_groups match_named match_has match_map match_named_map match_len
  match_start_pos match_end_pos match_start_line match_start_col match_end_line match_end_col match_line match_col
  cursor_pos cursor_line cursor_col cursor_rest cursor_rest_len
  capture capture_if capture_slice capture_slice_len capture_slice_length capture_slice_until_cursor
  capture_slice_until_cursor_len capture_until_boundary capture_take_until_cursor capture_take_until_cursor_len
  capture_slice_pos capture_slice_line capture_slice_col capture_slice_here
  start_capture_slice capture_rest capture_rest_len capture_rest_length capture_take_rest capture_take_rest_len
  capture_from_rule_start capture_len_from_rule_start capture_take_slice capture_take_slice_len capture_take_len
  start_capture_slice_from capture_from capture_len_from capture_take capture_take_len_from
  capture_rest_from capture_rest_len_from capture_take_rest_from capture_take_rest_len_from
  capture_until_cursor_from capture_until_cursor_len_from capture_take_until_cursor_from
  capture_take_until_cursor_len_from capture_between capture_len_between capture_take_between
  capture_take_between_len
  mark_here mark_input_start mark_input_end mark_entry_start mark_entry_end mark_match_start mark_match_end
  mark_copy mark_capture_slice clear_mark mark_exists mark_pos mark_line mark_col
 );
 return $method if $known{$method};
 return undef
}

sub _user_function_registry_by_name {
 my ($deps) = @_;
 return undef unless ref($deps) eq 'HASH';
 my $registry = $deps->{user_function_registry};
 return undef unless ref($registry) eq 'HASH';
 return ref($registry->{by_name}) eq 'HASH' ? $registry->{by_name} : undef
}

sub _user_function_definition_for_name {
 my ($deps, $name) = @_;
 return undef unless defined($name) && $name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 my $by_name = _user_function_registry_by_name($deps);
 return undef unless ref($by_name) eq 'HASH';
 my $definition = $by_name->{$name};
 return undef unless ref($definition) eq 'HASH'
              && ($definition->{kind} // '') eq 'user_function_definition';
 return $definition
}

sub _contextual_codeblock_contract {
 my ($deps, $surface, $name) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::CallableContract');
 my $contract = LinkedSpec::CallableContract::builtin_contract($surface, $name);
 return $contract if ref($contract) eq 'HASH';
 return undef unless $surface eq 'helper';
 my $definition = _user_function_definition_for_name($deps, $name);
 return LinkedSpec::CallableContract::user_function_contract($definition)
}

sub _normalize_contextual_codeblock_call_node {
 my ($deps, $surface, $node, $name) = @_;
 return { node => $node } unless ref($node) eq 'HASH';
 my $args = $node->{args};
 return { node => $node } unless ref($args) eq 'ARRAY';
 my $contract = _contextual_codeblock_contract($deps, $surface, $name);
 my $attached = $surface eq 'receiver'
  ? ($node->{receiver_trailing_block_arg} ? 1 : 0)
  : ($node->{trailing_block_arg} ? 1 : 0);
 return { error => $name } if $attached && ref($contract) ne 'HASH';
 return { node => $node } unless ref($contract) eq 'HASH' && @$args;
 my $final = $args->[-1];
 my $kind = ref($final) eq 'HASH' ? ($final->{kind} // '') : '';
 my $before_count = @$args - 1;
 my $accepted_count = LinkedSpec::CallableContract::accepts_argument_count($contract, $before_count);
 if ($surface eq 'receiver' && $kind ne 'block_value' && $accepted_count) {
  my %normalized = %$node;
  $normalized{trailing_block_arg} = 1;
  $normalized{receiver_trailing_block_arg} = 1;
  return { node => \%normalized, contract => $contract }
 }
 return { node => $node } unless $kind eq 'block_value';
 return { error => $name } unless $accepted_count;
 my $argument = LinkedSpec::CallableContract::contextual_argument_from_block($final);
 return { error => $name } unless ref($argument) eq 'HASH';
 my %normalized = %$node;
 my @normalized_args = @$args;
 $normalized_args[-1] = $argument;
 $normalized{args} = \@normalized_args;
 $normalized{trailing_block_arg} = 1;
 $normalized{receiver_trailing_block_arg} = 1 if $surface eq 'receiver';
 $normalized{contextual_codeblock_arg} = 1;
 return { node => \%normalized, contract => $contract }
}

sub _contextual_codeblock_runtime_record {
 my ($node) = @_;
 return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'codeblock_argument';
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::CallableContract');
 return LinkedSpec::CallableContract::runtime_record_from_argument($node)
}

sub _codeblock_variable_call_candidate {
 my ($deps, $name) = @_;
 return 0 unless defined($name) && $name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 my $parameter_kinds = ref($deps) eq 'HASH' ? $deps->{__user_function_parameter_kinds} : undef;
 return 1 if ref($parameter_kinds) eq 'HASH' && ($parameter_kinds->{$name} // '') eq 'codeblock';
 return 0 unless ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE';
 return (($deps->{bare_symbol_kind}->($name) // '') eq 'scalar') ? 1 : 0
}

sub _codeblock_runtime_binding_expr {
 my ($deps, $required_name) = @_;
 my %names;
 if (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_names}) eq 'ARRAY') {
  foreach my $name (@{$deps->{bare_symbol_names}}) {
   next unless defined($name) && $name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
   next unless _codeblock_variable_call_candidate($deps, $name);
   $names{$name} = 1;
  }
 }
 if (ref($deps) eq 'HASH' && ref($deps->{__user_function_scalar_value_names}) eq 'HASH') {
  $names{$_} = 1 for grep { defined($_) && /\A[A-Za-z_][A-Za-z0-9_]*\z/o }
   keys %{$deps->{__user_function_scalar_value_names}};
 }
 $names{$required_name} = 1
  if defined($required_name) && $required_name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return '{'.join(', ', map { _actionir_ast_quote_string_source($_).' => \\$'.$_ } sort keys %names).'}'
}

sub _split_leading_call_suffix {
 my ($source) = @_;
 return undef unless defined($source)
  && $source =~ /\A\s*([A-Za-z_][A-Za-z0-9_]*)\s*\(/o;
 my $open = index($source, '(');
 return undef if $open < 0;
 my ($depth, $quote, $escape) = (0, '', 0);
 for (my $idx = $open; $idx < length($source); ++$idx) {
  my $ch = substr($source, $idx, 1);
  if (length($quote)) {
   if ($escape) { $escape = 0; next; }
   if ($ch eq '\\') { $escape = 1; next; }
   if ($ch eq $quote) { $quote = ''; }
   next;
  }
  if ($ch eq '"' || $ch eq "'") { $quote = $ch; next; }
  if ($ch eq '(') { ++$depth; next; }
  next unless $ch eq ')';
  --$depth;
  next unless $depth == 0;
  return {
   call_source => substr($source, 0, $idx + 1),
   suffix => substr($source, $idx + 1),
  }
 }
 return undef
}

sub _user_function_call_signature {
 my ($definition) = @_;
 return undef unless ref($definition) eq 'HASH';
 my $version = $definition->{version};
 if (defined($version) && !ref($version) && $version == 1) {
  my $params = $definition->{params};
  my $arity = $definition->{arity};
  return undef unless ref($params) eq 'ARRAY'
                   && defined($arity) && !ref($arity) && $arity =~ /\A\d+\z/o
                   && $arity == @$params;
  return {
   positional_params => $params,
   rest_param => undef,
   min_arity => 0 + $arity,
   max_arity => 0 + $arity,
  }
 }
 return undef unless defined($version) && !ref($version) && $version == 2;
 my $signature = $definition->{signature};
 return undef unless ref($signature) eq 'HASH'
                  && ($signature->{kind} // '') eq 'callable_signature'
                  && ($signature->{version} // 0) == 1;
 my $params = $signature->{positional_params};
 my $rest_param = $signature->{rest_param};
 my $min_arity = $signature->{min_arity};
 return undef unless ref($params) eq 'ARRAY'
                  && defined($rest_param) && !ref($rest_param)
                  && $rest_param =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o
                  && defined($min_arity) && !ref($min_arity) && $min_arity =~ /\A\d+\z/o
                  && $min_arity == @$params
                  && exists($signature->{max_arity}) && !defined($signature->{max_arity});
 return {
  positional_params => $params,
  rest_param => $rest_param,
  min_arity => 0 + $min_arity,
  max_arity => undef,
 }
}

sub _user_function_call_stack_contains {
 my ($deps, $name) = @_;
 return 0 unless defined($name) && length($name);
 my $stack = ref($deps) eq 'HASH' ? $deps->{__user_function_call_stack} : undef;
 return 0 unless ref($stack) eq 'ARRAY';
 foreach my $active_name (@$stack) {
  return 1 if defined($active_name) && $active_name eq $name;
 }
 return 0
}

sub _user_function_deps_with_call {
 my ($deps, $name) = @_;
 my $base = ref($deps) eq 'HASH' ? { %$deps } : {};
 my $stack = ref($base->{__user_function_call_stack}) eq 'ARRAY'
  ? [@{$base->{__user_function_call_stack}}]
  : [];
 push @$stack, $name if defined($name) && length($name);
 $base->{__user_function_call_stack} = $stack;
 return $base
}

sub _user_function_record_local_decl {
 my ($decls, $params, $sigil, $name) = @_;
 return unless ref($decls) eq 'HASH';
 return unless defined($sigil) && $sigil =~ /\A[\$\@\%]\z/o;
 return unless defined($name) && $name =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return if _is_reserved_actionir_value_symbol($name);
 return if ref($params) eq 'HASH' && $params->{$name};
 return if ref($decls->{$name}) eq 'HASH'
        && $decls->{$name}{sigil} eq '$'
        && $sigil ne '$';
 $decls->{$name} = { sigil => $sigil, name => $name };
}

sub _user_function_collect_local_decls_from_node {
 my ($node, $decls, $params) = @_;
 return unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';

 if ($kind eq 'variable') {
  _user_function_record_local_decl($decls, $params, '$', $node->{name});
  return;
 }
 if ($kind eq 'colon_scalar_slot_removed') {
  return;
 }
 if ($kind eq 'hash_literal_fat_arrow_removed') {
  return;
 }

 if ($kind eq 'indexed_var') {
  _user_function_record_local_decl($decls, $params, '$', $node->{name});
  _user_function_collect_local_decls_from_node($node->{index}, $decls, $params);
  return;
 }

 if ($kind eq 'nested_access') {
  _user_function_record_local_decl($decls, $params, '$', $node->{base});
  foreach my $segment (@{$node->{segments} || []}) {
   next unless ref($segment) eq 'HASH' && ($segment->{kind} // '') eq 'index';
   _user_function_collect_local_decls_from_node($segment->{expr}, $decls, $params);
  }
  return;
 }

 if ($kind eq 'assign_scalar') {
  _user_function_record_local_decl($decls, $params, '$', $node->{name});
  _user_function_collect_local_decls_from_node($node->{value}, $decls, $params);
  return;
 }

 if ($kind eq 'assign_array_append') {
  _user_function_record_local_decl($decls, $params, '$', $node->{name});
  _user_function_collect_local_decls_from_node($node->{value}, $decls, $params);
  return;
 }

 if ($kind eq 'assign_hash_index') {
  _user_function_record_local_decl($decls, $params, '$', $node->{name});
  _user_function_collect_local_decls_from_node($node->{key}, $decls, $params);
  _user_function_collect_local_decls_from_node($node->{value}, $decls, $params);
  return;
 }

 if ($kind eq 'assign_nested_access') {
  _user_function_record_local_decl($decls, $params, '$', $node->{base});
  foreach my $segment (@{$node->{segments} || []}) {
   next unless ref($segment) eq 'HASH' && ($segment->{kind} // '') eq 'index';
   _user_function_collect_local_decls_from_node($segment->{expr}, $decls, $params);
  }
  _user_function_collect_local_decls_from_node($node->{value}, $decls, $params);
  return;
 }

 if ($kind eq 'call') {
  my $name = $node->{name} // '';
  my $args = $node->{args} || [];
  if ($name eq 'set' && ref($args) eq 'ARRAY' && @$args >= 2) {
   my $target = $args->[0];
   if (ref($target) eq 'HASH') {
    if (($target->{kind} // '') eq 'variable') {
     _user_function_record_local_decl($decls, $params, '$', $target->{name});
    } elsif (($target->{kind} // '') eq 'call') {
     my $target_name = $target->{name} // '';
     my $target_args = $target->{args} || [];
     if (ref($target_args) eq 'ARRAY' && @$target_args) {
      my $target_arg = $target_args->[0];
      if (ref($target_arg) eq 'HASH' && ($target_arg->{kind} // '') eq 'variable') {
       _user_function_record_local_decl($decls, $params, '$', $target_arg->{name})
        if $target_name eq 'array';
       _user_function_record_local_decl($decls, $params, '$', $target_arg->{name})
        if $target_name eq 'hash';
      }
     }
    }
   }
  } elsif ($name eq 'set_key' && ref($args) eq 'ARRAY' && @$args >= 1) {
   my $target = $args->[0];
   if (ref($target) eq 'HASH' && ($target->{kind} // '') eq 'variable') {
    _user_function_record_local_decl($decls, $params, '$', $target->{name});
   }
  } elsif ($name eq 'push' && ref($args) eq 'ARRAY' && @$args >= 1) {
   my $target = $args->[0];
   if (ref($target) eq 'HASH') {
    if (($target->{kind} // '') eq 'variable') {
     _user_function_record_local_decl($decls, $params, '$', $target->{name});
    } elsif (($target->{kind} // '') eq 'call' && ($target->{name} // '') eq 'array') {
     my $target_args = $target->{args} || [];
     my $target_arg = ref($target_args) eq 'ARRAY' ? $target_args->[0] : undef;
     _user_function_record_local_decl($decls, $params, '$', $target_arg->{name})
      if ref($target_arg) eq 'HASH' && ($target_arg->{kind} // '') eq 'variable';
    }
   }
  } elsif ($name =~ /^(?:array|flat_array|copy)$/o && ref($args) eq 'ARRAY' && @$args == 1) {
   my $arg = $args->[0];
   if (ref($arg) eq 'HASH' && ($arg->{kind} // '') eq 'variable') {
    _user_function_record_local_decl($decls, $params, '$', $arg->{name});
    return;
   }
  } elsif ($name =~ /^(?:hash|flat_hash)$/o && ref($args) eq 'ARRAY' && @$args == 1) {
   my $arg = $args->[0];
   if (ref($arg) eq 'HASH' && ($arg->{kind} // '') eq 'variable') {
    _user_function_record_local_decl($decls, $params, '$', $arg->{name});
    return;
   }
  }

  foreach my $arg (@$args) {
   _user_function_collect_local_decls_from_node($arg, $decls, $params);
  }
  return;
 }

 if ($kind eq 'fluent_chain') {
  _user_function_collect_local_decls_from_node($node->{receiver}, $decls, $params);
  foreach my $call (@{$node->{calls} || []}) {
   next unless ref($call) eq 'HASH';
   foreach my $arg (@{$call->{args} || []}) {
    _user_function_collect_local_decls_from_node($arg, $decls, $params);
   }
  }
  return;
 }

 if ($kind eq 'array_literal') {
  foreach my $item (@{$node->{items} || []}) {
   _user_function_collect_local_decls_from_node($item, $decls, $params);
  }
  return;
 }

 if ($kind eq 'hash_literal') {
  foreach my $entry (@{$node->{entries} || []}) {
   next unless ref($entry) eq 'HASH';
   _user_function_collect_local_decls_from_node($entry->{key}, $decls, $params);
   _user_function_collect_local_decls_from_node($entry->{value}, $decls, $params);
  }
  return;
 }

 if ($kind eq 'block_value') {
  my $block = $node->{block};
  return unless ref($block) eq 'HASH';
  foreach my $stmt (@{$block->{statements} || []}) {
   _user_function_collect_local_decls_from_node($stmt, $decls, $params);
  }
  return;
 }

 if ($kind eq 'action_stmt') {
  _user_function_collect_local_decls_from_node($node->{expr}, $decls, $params);
  return;
 }
}

sub _user_function_local_decl_statements {
 my ($definition) = @_;
 return [] unless ref($definition) eq 'HASH';
 my $signature = _user_function_call_signature($definition);
 my @binding_names = ref($signature) eq 'HASH'
  ? (@{$signature->{positional_params}}, defined($signature->{rest_param}) ? $signature->{rest_param} : ())
  : ();
 my %params = map { $_ => 1 } @binding_names;
 my %decls;
 my $body_ast = $definition->{body_ast};
 if (ref($body_ast) eq 'HASH') {
  foreach my $stmt (@{$body_ast->{statements} || []}) {
   _user_function_collect_local_decls_from_node($stmt, \%decls, \%params);
  }
 }
 my @ordered;
 foreach my $key (sort keys %decls) {
  my $decl = $decls{$key};
  push @ordered, 'my '.$decl->{sigil}.$decl->{name}.';';
 }
 return \@ordered
}

sub _user_function_scalar_value_name {
 my ($deps, $name) = @_;
 return 0 unless defined($name) && length($name);
 my $names = ref($deps) eq 'HASH' ? $deps->{__user_function_scalar_value_names} : undef;
 return 0 unless ref($names) eq 'HASH';
 return $names->{$name} ? 1 : 0
}

sub _actionir_ast_first_unknown_value_call_name {
 my ($node, $deps) = @_;
 return undef unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';

 if ($kind eq 'call') {
  my $method = _actionir_ast_known_value_call_method($node->{name});
  my $definition = _user_function_definition_for_name($deps, $node->{name});
  return $node->{name}
   unless (defined($method) && length($method))
       || ref($definition) eq 'HASH'
       || _codeblock_variable_call_candidate($deps, $node->{name});
  foreach my $arg (@{$node->{args} || []}) {
   my $unknown = _actionir_ast_first_unknown_value_call_name($arg, $deps);
   return $unknown if defined($unknown) && length($unknown);
  }
  return undef
 }

 if ($kind eq 'fluent_chain') {
  my $unknown = _actionir_ast_first_unknown_value_call_name($node->{receiver}, $deps);
  return $unknown if defined($unknown) && length($unknown);
  foreach my $call (@{$node->{calls} || []}) {
   next unless ref($call) eq 'HASH';
   my $method = $call->{method};
   return $method
    unless _is_array_receiver_value_chain_method($method)
        || _is_hash_receiver_value_chain_method($method)
        || _is_string_receiver_value_chain_method($method)
        || _is_number_receiver_value_chain_method($method)
        || defined(_actionir_ast_known_value_call_method($method));
   foreach my $arg (@{$call->{args} || []}) {
    my $arg_unknown = _actionir_ast_first_unknown_value_call_name($arg, $deps);
    return $arg_unknown if defined($arg_unknown) && length($arg_unknown);
   }
  }
  return undef
 }

 if ($kind eq 'array_literal') {
  foreach my $item (@{$node->{items} || []}) {
   my $unknown = _actionir_ast_first_unknown_value_call_name($item, $deps);
   return $unknown if defined($unknown) && length($unknown);
  }
  return undef
 }

 if ($kind eq 'hash_literal') {
  foreach my $entry (@{$node->{entries} || []}) {
   foreach my $slot (qw(key value)) {
    my $unknown = _actionir_ast_first_unknown_value_call_name($entry->{$slot}, $deps);
    return $unknown if defined($unknown) && length($unknown);
   }
  }
  return undef
 }

 if ($kind eq 'indexed_var') {
  return _actionir_ast_first_unknown_value_call_name($node->{index}, $deps)
 }

 if ($kind eq 'nested_access') {
  foreach my $segment (@{$node->{segments} || []}) {
   next unless ref($segment) eq 'HASH' && ($segment->{kind} // '') eq 'index';
   my $unknown = _actionir_ast_first_unknown_value_call_name($segment->{expr}, $deps);
   return $unknown if defined($unknown) && length($unknown);
  }
  return undef
 }

 if ($kind eq 'block_value') {
  my $block = $node->{block};
  return undef unless ref($block) eq 'HASH';
  my $statements = $block->{statements};
  return undef unless ref($statements) eq 'ARRAY';
  foreach my $stmt (@$statements) {
   next unless ref($stmt) eq 'HASH';
   my $unknown = _actionir_ast_first_unknown_value_call_name($stmt->{expr}, $deps);
   return $unknown if defined($unknown) && length($unknown);
  }
  return undef
 }

 return undef
}

sub _lower_dropped_value_statement {
 my ($expr, $deps) = @_;
 return undef unless defined $expr;
 my $trim_action_ir_value = (ref($deps) eq 'HASH' && ref($deps->{trim_action_ir_value}) eq 'CODE')
  ? $deps->{trim_action_ir_value}
  : undef;
 die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback 'trim_action_ir_value'"
  unless ref($trim_action_ir_value) eq 'CODE';

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $ast_node = _parse_method_value_ast_expr($trimmed, $deps);
 return undef unless ref($ast_node) eq 'HASH' && ($ast_node->{kind} // '') ne 'raw_perl';

 my $unknown = _actionir_ast_first_unknown_value_call_name($ast_node, $deps);
 return _actionir_ast_unsupported_helper_expr($unknown)
  if defined($unknown) && length($unknown);

 my $lowered = _lower_method_value_expr($trimmed, $deps);
 return undef unless defined($lowered) && length($lowered);
 return undef if $lowered eq $trimmed;
 $lowered = '+'.$lowered if $lowered =~ /^\s*\{/s;
 return 'do { '.$lowered.'; undef }'
}

sub _lower_ast_call_statement {
 my ($expr_or_node, $expected_method, $deps) = @_;
 my $node = ref($expr_or_node) eq 'HASH'
  ? $expr_or_node
  : _parse_method_value_ast_expr($expr_or_node, $deps);
 return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'call';

 my $method = _actionir_ast_statement_method($node->{name}, $node->{source});
 return undef unless defined($method) && length($method);
 return undef unless _actionir_ast_expected_statement_method($method, $expected_method);

 my $args = _actionir_ast_call_arg_sources($node);
 return undef unless $args;
 _trace_method_decision(
  phase => 'lower_ast_call_statement',
  label => 'call',
  decision => 'ast_statement_'.$method,
  taken => 1,
  context => { method => $method, argc => scalar(@$args) },
 );

 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 if ($method eq 'return') {
  _trace_method_decision(
   phase => 'lower_ast_call_statement',
   label => 'call',
   decision => 'ast_return_statement',
   taken => 1,
   context => { argc => scalar(@$args) },
  );
  if (@$args >= 2) {
   my $label = $trim_action_ir_value->($args->[0]);
   return _actionir_ast_unsupported_helper_expr($method)
    unless defined($label) && $label =~ /^\w+$/o;
   my @payloads;
   foreach my $payload_arg (@{$args}[1 .. $#$args]) {
    my $payload = _lower_return_payload_expr($payload_arg, $deps);
    $payload = $trim_action_ir_value->($payload_arg) unless defined($payload) && length($payload);
    return _actionir_ast_unsupported_helper_expr($method)
     unless defined($payload) && length($payload);
    push @payloads, $payload;
   }
   return "return ['?$label:',  ".join(', ', @payloads)."]"
  }

  return _actionir_ast_unsupported_helper_expr($method) unless @$args == 1;
  my $payload = _lower_return_payload_expr($args->[0], $deps);
  return _actionir_ast_unsupported_helper_expr($method) unless defined($payload) && length($payload);
  return "return $payload"
 }

 if ($method eq 'return_undef') {
  _trace_method_decision(
   phase => 'lower_ast_call_statement',
   label => 'call',
   decision => 'ast_return_undef_statement',
   taken => 1,
   context => {},
  );
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 0, 0);
  return _actionir_ast_unsupported_helper_expr($method) unless $effective_args;
  return 'return undef'
 }

 if ($method eq 'set') {
  _trace_method_decision(
   phase => 'lower_ast_call_statement',
   label => 'call',
   decision => 'ast_set_statement',
   taken => 1,
   context => {},
  );
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);
  return _actionir_ast_unsupported_helper_expr($method) unless $effective_args;
  my $lower_assign_statement = (ref($deps) eq 'HASH' && ref($deps->{lower_assign_statement}) eq 'CODE')
   ? $deps->{lower_assign_statement}
   : sub { return _lower_assign_statement($_[0], $_[1], $deps) };
  my $lowered = $lower_assign_statement->($effective_args->[0], $effective_args->[1]);
  return defined($lowered) && length($lowered) ? $lowered : _actionir_ast_unsupported_helper_expr($method)
 }

 if ($method eq 'set_key') {
  _trace_method_decision(
   phase => 'lower_ast_call_statement',
   label => 'call',
   decision => 'ast_set_key_statement',
   taken => 1,
   context => {},
  );
  my $effective_args = $normalize_method_args_with_optional_scope->($args, 3, 3);
  return _actionir_ast_unsupported_helper_expr($method) unless $effective_args;
  my $extract_hash_symbol_name = $require_dep->('extract_hash_symbol_name');
  my $lower_scalar_access_key_expr = $require_dep->('lower_scalar_access_key_expr');
  my $target_expr = $trim_action_ir_value->($effective_args->[0]);
  my $key_expr = $trim_action_ir_value->($effective_args->[1]);
  my $value_expr = $trim_action_ir_value->($effective_args->[2]);
  return _actionir_ast_unsupported_helper_expr($method)
   unless defined($target_expr) && length($target_expr)
       && defined($key_expr) && length($key_expr)
       && defined($value_expr) && length($value_expr);
  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  return _actionir_ast_unsupported_helper_expr($method)
   unless defined($hash_symbol) && length($hash_symbol);
  my $key_lowered = $lower_scalar_access_key_expr->($key_expr);
  return _actionir_ast_unsupported_helper_expr($method)
   unless defined($key_lowered) && length($key_lowered);
  my $value_lowered = _lower_mutation_slot_value_expr($value_expr, $deps);
  return _actionir_ast_unsupported_helper_expr($method)
   unless defined($value_lowered) && length($value_lowered);
  my $binding_symbol = _uniform_binding_target_symbol($target_expr, 'hash', $deps);
  return _uniform_binding_hash_index_set_expr($binding_symbol, $key_lowered, $value_lowered)
   if defined($binding_symbol);
  return '$'.$hash_symbol.'{'.$key_lowered.'} = '.$value_lowered
 }

 if ($method eq 'push') {
  _trace_method_decision(
   phase => 'lower_ast_call_statement',
   label => 'call',
   decision => 'ast_push_statement',
   taken => 1,
   context => { method => $method },
  );
  my $extract_array_symbol_name = $require_dep->('extract_array_symbol_name');
  my $effective_args;
  if (@$args == 2) {
   $effective_args = $args;
  } elsif ($method eq 'push' && @$args == 3) {
   my $scoped_target_expr = $trim_action_ir_value->($args->[1]);
   return undef unless defined($scoped_target_expr) && length($scoped_target_expr);
   return undef unless defined($extract_array_symbol_name->($scoped_target_expr))
                    || $scoped_target_expr =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
   $effective_args = [ $args->[1], $args->[2] ];
  } else {
   return _actionir_ast_unsupported_helper_expr($method);
  }
  my $lower_primitive_literal_expr = $require_dep->('lower_primitive_literal_expr');
  my $first_expr = $trim_action_ir_value->($effective_args->[0]);
  my $second_expr = $trim_action_ir_value->($effective_args->[1]);
  my $second_literal = $lower_primitive_literal_expr->($second_expr);
  if (defined($first_expr) && defined($second_expr)
   && $first_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o
   && $second_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o
   && !defined($second_literal)) {
   return _uniform_binding_ambiguous_push_expr($first_expr, $second_expr)
  }

  my $target_expr = $trim_action_ir_value->($effective_args->[0]);
  return _actionir_ast_unsupported_helper_expr($method)
   unless defined($target_expr) && length($target_expr);
  my $target_symbol = $extract_array_symbol_name->($target_expr);
  if (!defined($target_symbol) && $target_expr =~ /^(\w+)$/o) {
   $target_symbol = $1;
  }
  return _actionir_ast_unsupported_helper_expr($method)
   unless defined($target_symbol) && length($target_symbol);
  my $value_expr = $trim_action_ir_value->($effective_args->[1]);
  return _actionir_ast_unsupported_helper_expr($method)
   unless defined($value_expr) && length($value_expr);
  my $lowered_value = _lower_method_value_expr($value_expr, $deps);
  $lowered_value = $value_expr unless defined($lowered_value) && length($lowered_value);
  my $binding_symbol = _uniform_binding_target_symbol($target_expr, 'array', $deps);
  return _uniform_binding_array_push_expr($binding_symbol, $lowered_value)
   if defined($binding_symbol);
  return "push \@$target_symbol, $lowered_value"
 }

 return undef
}

sub _lower_ast_array_end_mutation_method_statement {
 my ($node, $deps) = @_;
 return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'fluent_chain';
 my $calls = $node->{calls};
 return undef unless ref($calls) eq 'ARRAY' && @$calls == 1;
 my $call = $calls->[0];
 return undef unless ref($call) eq 'HASH';
 my $method = $call->{method};
 return undef unless defined($method) && $method =~ /^(?:push_front|push_back|pop_front|pop_back)$/o;
 _trace_method_decision(
  phase => 'lower_ast_array_end_mutation_method_statement',
  label => 'fluent_chain',
  decision => 'ast_array_end_'.$method,
  taken => 1,
  context => { method => $method },
 );

 my $args = $call->{args} || [];
 return _actionir_ast_unsupported_helper_expr($method)
  if $method =~ /^push_/o && @$args != 1;
 return _actionir_ast_unsupported_helper_expr($method)
  if $method =~ /^pop_/o && @$args != 0;

 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $extract_array_symbol_name = $require_dep->('extract_array_symbol_name');

 my $receiver_expr = _actionir_ast_value_source_expr($node->{receiver});
 return _actionir_ast_unsupported_helper_expr($method)
  unless defined($receiver_expr) && length($receiver_expr);
 my $target_symbol = $extract_array_symbol_name->($receiver_expr);
 if (!defined($target_symbol) && $receiver_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
  $target_symbol = $1;
 }
 return _actionir_ast_unsupported_helper_expr($method)
  unless defined($target_symbol) && length($target_symbol);

 if ($method eq 'push_back' || $method eq 'push_front') {
  my $value_expr = _actionir_ast_value_source_expr($args->[0]);
  return _actionir_ast_unsupported_helper_expr($method)
   unless defined($value_expr) && length($value_expr);
  my $lowered_value = _lower_mutation_slot_value_expr($value_expr, $deps);
  return _actionir_ast_unsupported_helper_expr($method)
   unless defined($lowered_value) && length($lowered_value);
  my $binding_symbol = _uniform_binding_target_symbol($receiver_expr, 'array', $deps);
  return _uniform_binding_array_end_expr($binding_symbol, $method, $lowered_value)
   if defined($binding_symbol);
  return ($method eq 'push_back' ? 'push @' : 'unshift @').$target_symbol.', '.$lowered_value
 }

 my $binding_symbol = _uniform_binding_target_symbol($receiver_expr, 'array', $deps);
 return _uniform_binding_array_end_expr($binding_symbol, $method, undef)
  if defined($binding_symbol);
 return 'pop @'.$target_symbol if $method eq 'pop_back';
 return 'shift @'.$target_symbol if $method eq 'pop_front';
 return undef
}

sub _lower_ast_assignment_operator_statement {
 my ($node, $deps, $expected_kind) = @_;
 return undef unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';
 return undef unless defined($expected_kind) && $kind eq $expected_kind;
 _trace_method_decision(
  phase => 'lower_ast_assignment_operator_statement',
  label => 'assignment',
  decision => 'ast_'.$kind,
  taken => 1,
  context => { kind => $kind },
 );

 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $ast_value_source = sub {
  my ($value_node) = @_;
  return undef unless ref($value_node) eq 'HASH';
  if (($value_node->{kind} // '') eq 'variable' && _user_function_scalar_value_name($deps, $value_node->{name})) {
   my $scalar_read = _lower_source_slot_bare_scalar_read_expr($value_node->{name}, $deps);
   return $scalar_read if defined($scalar_read) && length($scalar_read);
  }
  return _actionir_ast_value_source_expr($value_node)
 };

 if ($kind eq 'assign_scalar') {
  _trace_method_decision(
   phase => 'lower_ast_assignment_operator_statement',
   label => 'assignment',
   decision => 'ast_scalar_assignment',
   taken => 1,
   context => { target => $node->{name} },
  );
  my $target = $node->{name};
  return undef unless defined($target) && $target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  my $source = $ast_value_source->($node->{value});
  return undef unless defined($source) && length($source);
  my $source_expr = _lower_value_binding_source_expr($source, $deps);
  return undef unless defined($source_expr) && length($source_expr);
  return '$'.$target.' = '.$source_expr
 }

 if ($kind eq 'assign_array_append') {
  _trace_method_decision(
   phase => 'lower_ast_assignment_operator_statement',
   label => 'assignment',
   decision => 'ast_array_append_assignment',
   taken => 1,
   context => { target => $node->{name} },
  );
  my $target = $node->{name};
  return undef unless defined($target) && $target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  my $value = $ast_value_source->($node->{value});
  return undef unless defined($value) && length($value);
  my $lowered_value = _lower_mutation_slot_value_expr($value, $deps);
  return undef unless defined($lowered_value) && length($lowered_value);
  return _uniform_binding_array_push_expr($target, $lowered_value)
 }

 if ($kind eq 'assign_hash_index') {
  _trace_method_decision(
   phase => 'lower_ast_assignment_operator_statement',
   label => 'assignment',
   decision => 'ast_hash_index_assignment',
   taken => 1,
   context => { target => $node->{name} },
  );
  my $target = $node->{name};
  return undef unless defined($target) && $target =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  my $scalar_held = _lower_ast_scalar_held_hash_index_assignment_value_node($node, $deps);
  return $scalar_held if defined($scalar_held) && length($scalar_held);
  my $key = $ast_value_source->($node->{key});
  my $value = $ast_value_source->($node->{value});
  return undef unless defined($key) && length($key);
  return undef unless defined($value) && length($value);
  my $lower_scalar_access_key_expr = $require_dep->('lower_scalar_access_key_expr');
  my $key_lowered = $lower_scalar_access_key_expr->($key);
  return undef unless defined($key_lowered) && length($key_lowered);
	  my $value_lowered = _lower_mutation_slot_value_expr($value, $deps);
	  return undef unless defined($value_lowered) && length($value_lowered);
	  return '$'.$target.'{'.$key_lowered.'} = '.$value_lowered
 }

 if ($kind eq 'assign_nested_access') {
  _trace_method_decision(
   phase => 'lower_ast_assignment_operator_statement',
   label => 'assignment',
   decision => 'ast_nested_access_assignment',
   taken => 1,
   context => { target => $node->{base} },
  );
  return _lower_ast_nested_access_assignment_value_node($node, $deps)
 }

 return undef
}

sub _is_reserved_actionir_value_symbol {
 my ($name) = @_;
 return 0 unless defined($name) && length($name);
 return $name =~ /^(?:undef|true|false|descr|STRING|info|minfo|IMATCH|IMATCH_LIST|IMATCH_HASH|IINDEX|IPOS|LMATCH|LMATCH_LIST|LMATCH_HASH|LINDEX|LSPOS|CAPTURE)$/o ? 1 : 0
}

#------------------------------------------------------------------------------
# Function: _lower_method_value_expr
# Purpose : Lower method DSL value expressions (`call(...)`, bare scalar reads,
#           `array(...)`, `input_slice(...)`, `copy(...)`, `merge_hash(...)`, `set_key(...)`,
#           `rename_key(...)`, `drop_keys(...)`, `pick_keys(...)`, `sorted(...)`, `reversed(...)`, `sorted_keys(...)`, `sorted_values(...)`,
#           `length(...)`, `substr(...)`, `replace_substr(...)`, `rm_prefix(...)`, `rm_suffix(...)`, `cat(...)`, `split(...)`, `num_abs(...)`, `num_floor(...)`, `num_ceil(...)`, `num_round(...)`, `num_sum(...)`, `num_avg(...)`, `num_median(...)`, `num_range(...)`, `num_add(...)`, `num_sub(...)`, `num_mul(...)`, `num_div(...)`, `num_mod(...)`, `num_clamp(...)`, `num_min(...)`, `num_max(...)`, `starts_with(...)`, `ends_with(...)`, `contains_substr(...)`, `matches(...)`, `coalesce_nonempty(...)`, `is_empty(...)`, `is_nonempty(...)`, `first(...)`, `last(...)`, `drop_front(...)`, `take(...)`, `slice(...)`, `take_last(...)`, `drop_back(...)`, `concat_arrays(...)`, `sorted(...)`, `reversed(...)`, `contains(...)`, `index_of(...)`,
#           `split_tagged_records(...)`, `flat(...)`)
#           into Perl value expressions.
# Args    : ($expr, $deps)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_method_value_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $split_action_ir_statements = $require_dep->('split_action_ir_statements');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $normalize_collection_args = sub {
  my ($args, $min_arity, $max_arity) = @_;
  return undef unless ref($args) eq 'ARRAY';
  my $count = scalar(@$args);
  return [@$args]
   if $count >= $min_arity && (!defined($max_arity) || $count <= $max_arity);
  return $normalize_method_args_with_optional_scope->($args, $min_arity, $max_arity)
 };
 my $lower_direct_nested_access_value_expr = $require_dep->('lower_direct_nested_access_value_expr');
 my $raw_extract_array_symbol_name = $require_dep->('extract_array_symbol_name');
 my $raw_extract_hash_symbol_name = $require_dep->('extract_hash_symbol_name');
 my $extract_scalar_symbol_name = $require_dep->('extract_scalar_symbol_name');
 my $lower_scalar_access_key_expr = $require_dep->('lower_scalar_access_key_expr');
 my $lower_primitive_literal_expr = $require_dep->('lower_primitive_literal_expr');
 my $infer_scalar_container_kind = $require_dep->('infer_scalar_container_kind');
 my $split_top_level_csv = $require_dep->('split_top_level_csv');
 my $lower_array_pipeline_expr = $require_dep->('lower_array_pipeline_expr');
 my $strip_literal_delimiters = $require_dep->('strip_literal_delimiters');
 my $base_bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')
  ? $deps->{bare_symbol_kind}
  : sub { return undef };
 my $bare_symbol_kind = sub {
  my ($name) = @_;
  return 'scalar' if _user_function_scalar_value_name($deps, $name);
  return $base_bare_symbol_kind->($name)
 };
 my $extract_array_symbol_name = sub {
  my ($candidate_expr) = @_;
  my $candidate = $trim_action_ir_value->($candidate_expr);
  if (defined($candidate) && $candidate =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
   return undef if (($bare_symbol_kind->($1) // '') eq 'scalar');
  }
  if (defined($candidate) && $candidate =~ /^array\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o) {
   return undef if (($bare_symbol_kind->($1) // '') eq 'scalar');
  }
  return $raw_extract_array_symbol_name->($candidate_expr);
 };
 my $extract_hash_symbol_name = sub {
  my ($candidate_expr) = @_;
  my $candidate = $trim_action_ir_value->($candidate_expr);
  if (defined($candidate) && $candidate =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
   return undef if (($bare_symbol_kind->($1) // '') eq 'scalar');
  }
  if (defined($candidate) && $candidate =~ /^hash\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o) {
   return undef if (($bare_symbol_kind->($1) // '') eq 'scalar');
  }
  return $raw_extract_hash_symbol_name->($candidate_expr);
 };
 my $remembered_bare_symbol_kind = sub {
  my ($candidate_expr) = @_;
  my $candidate = $trim_action_ir_value->($candidate_expr);
  return undef unless defined($candidate) && $candidate =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o;
  return $bare_symbol_kind->($1)
 };
 my $lower_scalar_bound_array_snapshot_expr = sub {
  my ($name) = @_;
  return undef unless defined($name) && $name =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  return 'do { my $__ls_array_value = $'.$name.'; (defined($__ls_array_value) && ref($__ls_array_value) eq \'ARRAY\') ? [@{$__ls_array_value}] : [] }'
 };
 my $lower_scalar_bound_hash_snapshot_expr = sub {
  my ($name) = @_;
  return undef unless defined($name) && $name =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  return 'do { my $__ls_hash_value = $'.$name.'; (defined($__ls_hash_value) && ref($__ls_hash_value) eq \'HASH\') ? { %{$__ls_hash_value} } : {} }'
 };
 my $array_container_prefix_re = qr/^array\s*\(/;
 my $hash_container_prefix_re = qr/^hash\s*\(/;
 my $array_symbol_expr_re = qr/^(?:array\s*\(\s*\w+\s*\)|\w+)$/;
 my $hash_symbol_expr_re = qr/^(?:hash\s*\(\s*\w+\s*\)|\w+)$/;
 my ($looks_like_array_value_expr, $looks_like_hash_value_expr);
 my ($lower_shape_literal_value_expr, $lower_shape_member_expr);
 my $split_top_level_fat_arrow = sub {
  my ($text) = @_;
  return undef unless defined $text;

  my $paren_depth = 0;
  my $brace_depth = 0;
  my $bracket_depth = 0;
  my $in_single_quote = 0;
  my $in_double_quote = 0;
  my $escape_next = 0;
  my $len = length($text);
  for (my $idx = 0; $idx < $len; ++$idx) {
   my $char = substr($text, $idx, 1);
   if ($in_single_quote) {
    if ($escape_next) { $escape_next = 0; }
    elsif ($char eq '\\') { $escape_next = 1; }
    elsif ($char eq "'") { $in_single_quote = 0; }
    next;
   }
   if ($in_double_quote) {
    if ($escape_next) { $escape_next = 0; }
    elsif ($char eq '\\') { $escape_next = 1; }
    elsif ($char eq '"') { $in_double_quote = 0; }
    next;
   }
   if ($char eq "'") { $in_single_quote = 1; next; }
   if ($char eq '"') { $in_double_quote = 1; next; }
   if ($char eq '(') { ++$paren_depth; next; }
   if ($char eq ')') { --$paren_depth if $paren_depth > 0; next; }
   if ($char eq '{') { ++$brace_depth; next; }
   if ($char eq '}') { --$brace_depth if $brace_depth > 0; next; }
   if ($char eq '[') { ++$bracket_depth; next; }
   if ($char eq ']') { --$bracket_depth if $bracket_depth > 0; next; }
   next unless $paren_depth == 0 && $brace_depth == 0 && $bracket_depth == 0;
   my $separator_len;
   if ($char eq '=' && $idx + 1 < $len && substr($text, $idx + 1, 1) eq '>') {
    return { retired_hash_literal_fat_arrow => 1 };
   } elsif ($char eq ':') {
    my $prev = $idx > 0 ? substr($text, $idx - 1, 1) : '';
    my $next = $idx + 1 < $len ? substr($text, $idx + 1, 1) : '';
    next if $prev eq ':' || $next eq ':';
    $separator_len = 1;
   } else {
    next;
   }
   my $lhs = $trim_action_ir_value->(substr($text, 0, $idx));
   my $rhs = $trim_action_ir_value->(substr($text, $idx + $separator_len));
   return undef unless defined($lhs) && length($lhs);
   return undef unless defined($rhs) && length($rhs);
   return [$lhs, $rhs];
  }
  return undef;
 };
 $lower_shape_member_expr = sub {
  my ($member_expr) = @_;
  return undef unless defined $member_expr;
  my $member = $trim_action_ir_value->($member_expr);
  return undef unless defined($member) && length($member);

  my $shape = $lower_shape_literal_value_expr->($member);
  return $shape if defined($shape) && length($shape);

  my $block = _lower_block_value_expr($member, $deps);
  return $block if defined($block) && length($block);

  my $bare_scalar_read = _lower_source_slot_bare_scalar_read_expr($member, $deps);
  return $bare_scalar_read if defined($bare_scalar_read) && length($bare_scalar_read);

  my $literal = $lower_primitive_literal_expr->($member);
  return $literal if defined($literal);

  my $direct_access = $lower_direct_nested_access_value_expr->($member);
  return $direct_access if defined($direct_access) && length($direct_access);

  my $member_call = $parse_method_function_expr->($member);
  if ($member_call) {
   my $lowered_call = _lower_method_value_expr($member, $deps);
   return $lowered_call if defined($lowered_call) && length($lowered_call) && $lowered_call ne $member;
  }

  return undef;
 };
 $lower_shape_literal_value_expr = sub {
  my ($shape_expr) = @_;
  return undef unless defined $shape_expr;
  my $shape = $trim_action_ir_value->($shape_expr);
  return undef unless defined($shape) && length($shape);
  return undef unless length($shape) >= 2;

  my $open = substr($shape, 0, 1);
  my $close = $open eq '[' ? ']' : $open eq '{' ? '}' : undef;
  return undef unless defined $close && substr($shape, -1, 1) eq $close;
  my $payload = substr($shape, 1, length($shape) - 2);
  $payload = $trim_action_ir_value->($payload);

  if ($open eq '[') {
   return '[]' unless defined($payload) && length($payload);
   my $items = $split_top_level_csv->($payload);
   return undef unless $items;
   my @lowered_items;
   foreach my $item (@$items) {
    my $lowered_item = $lower_shape_member_expr->($item);
    return undef unless defined($lowered_item) && length($lowered_item);
    push @lowered_items, $lowered_item;
   }
   return '['.join(', ', @lowered_items).']';
  }

  return '{}' unless defined($payload) && length($payload);
  my $entries = $split_top_level_csv->($payload);
  return undef unless $entries;
  my @lowered_pairs;
  foreach my $entry (@$entries) {
   my $pair = $split_top_level_fat_arrow->($entry);
   return _actionir_ast_retired_hash_literal_fat_arrow_expr()
    if ref($pair) eq 'HASH' && $pair->{retired_hash_literal_fat_arrow};
   return undef unless ref($pair) eq 'ARRAY';
   my $key_expr = $lower_shape_member_expr->($pair->[0]);
   my $value_expr = $lower_shape_member_expr->($pair->[1]);
   return undef unless defined($key_expr) && length($key_expr);
   return undef unless defined($value_expr) && length($value_expr);
   push @lowered_pairs, $key_expr.' => '.$value_expr;
  }
  return '{'.join(', ', @lowered_pairs).'}';
 };
 my $lower_flat_list_value_expr = sub {
  my ($flat_expr) = @_;
  return undef unless defined $flat_expr;
  my $flat_trimmed = $trim_action_ir_value->($flat_expr);
  return undef unless defined($flat_trimmed) && length($flat_trimmed);
  my $flat_call = $parse_method_function_expr->($flat_trimmed);
  return undef unless $flat_call;

  my $method = $flat_call->{method} // '';
  if ($method eq 'flat') {
   my $flat_args = $normalize_method_args_with_optional_scope->($flat_call->{args} || [], 1, 1);
   return undef unless $flat_args;
   my $container_expr = $trim_action_ir_value->($flat_args->[0]);
   return undef unless defined($container_expr) && length($container_expr);

   if ($container_expr =~ $array_container_prefix_re) {
    if ($container_expr =~ /^array\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o
     && (($bare_symbol_kind->($1) // '') eq 'scalar')) {
     return 'do { my $__ls_flat_array = $'.$1.'; (defined($__ls_flat_array) && ref($__ls_flat_array) eq \'ARRAY\') ? @{$__ls_flat_array} : () }';
    }
    my $array_symbol = $extract_array_symbol_name->($container_expr);
    return '@'.$array_symbol if defined($array_symbol) && length($array_symbol);
   }
   if ($looks_like_array_value_expr->($container_expr)) {
    my $lowered_array = _lower_method_value_expr($container_expr, $deps);
    return undef unless defined($lowered_array) && length($lowered_array);
    return 'do { my $__ls_flat_array = '.$lowered_array.'; (defined($__ls_flat_array) && ref($__ls_flat_array) eq \'ARRAY\') ? @{$__ls_flat_array} : () }';
   }
   if ($container_expr =~ $hash_container_prefix_re) {
    if ($container_expr =~ /^hash\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o
     && (($bare_symbol_kind->($1) // '') eq 'scalar')) {
     return 'do { my $__ls_flat_hash = $'.$1.'; (defined($__ls_flat_hash) && ref($__ls_flat_hash) eq \'HASH\') ? %{$__ls_flat_hash} : () }';
    }
    my $hash_symbol = $extract_hash_symbol_name->($container_expr);
    return '%'.$hash_symbol if defined($hash_symbol) && length($hash_symbol);
   }
   if ($looks_like_hash_value_expr->($container_expr)) {
    my $lowered_hash = _lower_method_value_expr($container_expr, $deps);
    return undef unless defined($lowered_hash) && length($lowered_hash);
    return 'do { my $__ls_flat_hash = '.$lowered_hash.'; (defined($__ls_flat_hash) && ref($__ls_flat_hash) eq \'HASH\') ? %{$__ls_flat_hash} : () }';
   }
   return undef;
  }

  if ($method eq 'flat_array') {
   my $flat_args = $normalize_method_args_with_optional_scope->($flat_call->{args} || [], 1, 1);
   return undef unless $flat_args;
   my $array_expr = $trim_action_ir_value->($flat_args->[0]);
   return undef unless defined($array_expr) && length($array_expr);
   if ($array_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o
    && (($bare_symbol_kind->($1) // '') eq 'scalar')) {
    return 'do { my $__ls_flat_array = $'.$1.'; (defined($__ls_flat_array) && ref($__ls_flat_array) eq \'ARRAY\') ? @{$__ls_flat_array} : () }';
   }
   my $array_symbol = $extract_array_symbol_name->($array_expr);
   return '@'.$array_symbol if defined($array_symbol) && length($array_symbol);
   my $lowered_array = _lower_method_value_expr($array_expr, $deps);
   $lowered_array = $array_expr unless defined($lowered_array) && length($lowered_array);
   return undef unless defined($lowered_array) && length($lowered_array);
   return 'do { my $__ls_flat_array = '.$lowered_array.'; (defined($__ls_flat_array) && ref($__ls_flat_array) eq \'ARRAY\') ? @{$__ls_flat_array} : () }';
  }

  if ($method eq 'flat_hash') {
   my $flat_args = $normalize_method_args_with_optional_scope->($flat_call->{args} || [], 1, 1);
   return undef unless $flat_args;
   my $hash_expr = $trim_action_ir_value->($flat_args->[0]);
   return undef unless defined($hash_expr) && length($hash_expr);
   if ($hash_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o
    && (($bare_symbol_kind->($1) // '') eq 'scalar')) {
    return 'do { my $__ls_flat_hash = $'.$1.'; (defined($__ls_flat_hash) && ref($__ls_flat_hash) eq \'HASH\') ? %{$__ls_flat_hash} : () }';
   }
   my $hash_symbol = $extract_hash_symbol_name->($hash_expr);
   return '%'.$hash_symbol if defined($hash_symbol) && length($hash_symbol);
   my $lowered_hash = _lower_method_value_expr($hash_expr, $deps);
   $lowered_hash = $hash_expr unless defined($lowered_hash) && length($lowered_hash);
   return undef unless defined($lowered_hash) && length($lowered_hash);
   return 'do { my $__ls_flat_hash = '.$lowered_hash.'; (defined($__ls_flat_hash) && ref($__ls_flat_hash) eq \'HASH\') ? %{$__ls_flat_hash} : () }';
  }

 return undef;
 };
 my ($block_exit_looks_array_like, $block_value_exit_exprs);
 $block_value_exit_exprs = sub {
  my ($block_expr) = @_;
  my $payload = _extract_outer_brace_payload($block_expr, $trim_action_ir_value);
  return undef unless defined $payload;
  $payload = $trim_action_ir_value->($payload);
  return undef unless defined($payload) && length($payload);
  return undef if _has_top_level_fat_arrow($payload);

  my $statements = $split_action_ir_statements->($payload);
  return undef unless ref($statements) eq 'ARRAY' && @$statements;

  my @statements;
  foreach my $raw_statement (@$statements) {
   my $statement = $trim_action_ir_value->($raw_statement);
   push @statements, $statement if defined($statement) && length($statement);
  }
  return undef unless @statements;

  my @exits;
  for (my $idx = 0; $idx < @statements; ++$idx) {
   my $statement = $statements[$idx];
   my $call = $parse_method_function_expr->($statement);
   if ($call && ($call->{method} // '') eq 'return') {
    my $return_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
    return undef unless $return_args;
    push @exits, $return_args->[0];
    next;
   }
   push @exits, $statement if $idx == $#statements;
  }

  return @exits ? \@exits : undef;
 };
 $block_exit_looks_array_like = sub {
  my ($exit_expr) = @_;
  return 0 unless defined $exit_expr;
  my $exit_trimmed = $trim_action_ir_value->($exit_expr);
  return 0 unless defined($exit_trimmed) && length($exit_trimmed);

  if (substr($exit_trimmed, 0, 1) eq '[') {
   my $shape = $lower_shape_literal_value_expr->($exit_trimmed);
   return 1 if defined($shape) && length($shape);
   return 0;
  }

  if (substr($exit_trimmed, 0, 1) eq '{') {
   my $nested_exits = $block_value_exit_exprs->($exit_trimmed);
   return 0 unless $nested_exits && @$nested_exits;
   foreach my $nested_exit (@$nested_exits) {
    return 0 unless $block_exit_looks_array_like->($nested_exit);
   }
   return 1;
  }

  return 1 if $exit_trimmed =~ $array_container_prefix_re;

  my $exit_call = $parse_method_function_expr->($exit_trimmed);
  return 0 unless $exit_call;
  my $exit_method = $exit_call->{method} // '';
  return 1 if $exit_method =~ /^(?:array|sorted|reversed|sorted_keys|sorted_values|drop_front|take|slice|take_last|drop_back|concat_arrays|split_tagged_records|split|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match|__array_value_split_each|__array_value_trim_each|__array_value_filter_nonempty|__array_value_lowercase_each|__array_value_uppercase_each|__array_value_uniq|__array_value_filter_match|entry_groups|match_groups)$/o;
  if ($exit_method eq 'copy') {
   my $copy_args = $normalize_method_args_with_optional_scope->($exit_call->{args} || [], 1, 1);
   return 0 unless $copy_args;
   return $looks_like_array_value_expr->($copy_args->[0]) ? 1 : 0;
  }

  if ($exit_method eq 'coalesce') {
   my $exit_args = $normalize_method_args_with_optional_scope->($exit_call->{args} || [], 2, undef);
   return 0 unless $exit_args && @$exit_args;
   foreach my $arg (@$exit_args) {
    next unless defined $arg;
    return 0 unless $block_exit_looks_array_like->($arg);
   }
   return 1;
  }

  return 0;
 };
 $looks_like_array_value_expr = sub {
  my ($candidate_expr) = @_;
  return 0 unless defined $candidate_expr;
  my $candidate_trimmed = $trim_action_ir_value->($candidate_expr);
  return 0 unless defined($candidate_trimmed) && length($candidate_trimmed);

  if (substr($candidate_trimmed, 0, 1) eq '{') {
   my $exits = $block_value_exit_exprs->($candidate_trimmed);
   return 0 unless $exits && @$exits;
   foreach my $exit (@$exits) {
    return 0 unless $block_exit_looks_array_like->($exit);
   }
   return 1;
  }

  if (substr($candidate_trimmed, 0, 1) eq '[') {
   my $shape = $lower_shape_literal_value_expr->($candidate_trimmed);
   return 1 if defined($shape) && length($shape);
  }

  return 1 if $candidate_trimmed =~ $array_container_prefix_re;

  my $remembered_kind = $remembered_bare_symbol_kind->($candidate_trimmed);
  return 0 if defined($remembered_kind) && $remembered_kind eq 'hash';
  return 1 if defined($remembered_kind) && $remembered_kind eq 'array';

  my $array_symbol = $extract_array_symbol_name->($candidate_trimmed);
  if (defined($array_symbol) && length($array_symbol) && $candidate_trimmed =~ /^\w+$/o) {
   return 1;
  }

  my $candidate_call = $parse_method_function_expr->($candidate_trimmed);
  return 0 unless $candidate_call;

  my $candidate_method = $candidate_call->{method} // '';
  return 1 if $candidate_method =~ /^(?:array|sorted|reversed|sorted_keys|sorted_values|drop_front|take|slice|take_last|drop_back|concat_arrays|split_tagged_records|split|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match|__array_value_split_each|__array_value_trim_each|__array_value_filter_nonempty|__array_value_lowercase_each|__array_value_uppercase_each|__array_value_uniq|__array_value_filter_match|entry_groups|match_groups)$/o;

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

  # `copy(X)` remains admissible to array-consuming helpers when X is known as
  # an array or is not statically typed; the emitted copy itself still checks
  # the one runtime binding's actual reference kind.
  if ($candidate_method eq 'copy') {
   my $copy_args = $normalize_method_args_with_optional_scope->($candidate_call->{args} || [], 1, 1);
   return 0 unless $copy_args;
   my $inner = $trim_action_ir_value->($copy_args->[0]);
   return 0 unless defined($inner) && length($inner);
   my $inner_kind = $remembered_bare_symbol_kind->($inner);
   return 0 if defined($inner_kind) && $inner_kind eq 'hash';
   return 1 if defined($inner_kind) && $inner_kind eq 'array';
   my $sym = $extract_array_symbol_name->($inner);
   return 1 if defined($sym) && length($sym) && $inner =~ $array_symbol_expr_re;
   return 0;
  }

  return 0;
 };
 $looks_like_hash_value_expr = sub {
  my ($candidate_expr) = @_;
  return 0 unless defined $candidate_expr;
  my $candidate_trimmed = $trim_action_ir_value->($candidate_expr);
  return 0 unless defined($candidate_trimmed) && length($candidate_trimmed);

  if (substr($candidate_trimmed, 0, 1) eq '{') {
   my $shape = $lower_shape_literal_value_expr->($candidate_trimmed);
   return 1 if defined($shape) && length($shape);
  }

  return 1 if $candidate_trimmed =~ $hash_container_prefix_re;

  my $remembered_kind = $remembered_bare_symbol_kind->($candidate_trimmed);
  return 0 if defined($remembered_kind) && $remembered_kind eq 'array';
  return 1 if defined($remembered_kind) && $remembered_kind eq 'hash';

  my $hash_symbol = $extract_hash_symbol_name->($candidate_trimmed);
  if (defined($hash_symbol) && length($hash_symbol) && $candidate_trimmed =~ /^\w+$/o) {
   return 1;
  }

  my $candidate_call = $parse_method_function_expr->($candidate_trimmed);
  return 0 unless $candidate_call;

  my $candidate_method = $candidate_call->{method} // '';
  return 1 if $candidate_method =~ /^(?:hash|merge_hash|set_key|rename_key|drop_keys|pick_keys|entry_map|entry_named_map|match_map|match_named_map)$/o;

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

  # Hash-consuming contexts accept `copy(X)` when X is statically known as a
  # hash. Untyped copies remain runtime-checked and explicit `flat_hash(...)`
  # supplies the hash-consuming context when needed.
  if ($candidate_method eq 'copy') {
   my $copy_args = $normalize_method_args_with_optional_scope->($candidate_call->{args} || [], 1, 1);
   return 0 unless $copy_args;
   my $inner = $trim_action_ir_value->($copy_args->[0]);
   return 0 unless defined($inner) && length($inner);
   my $inner_kind = $remembered_bare_symbol_kind->($inner);
   return 0 if defined($inner_kind) && $inner_kind eq 'array';
   return 1 if defined($inner_kind) && $inner_kind eq 'hash';
   my $array_sym = $extract_array_symbol_name->($inner);
   return 0 if defined($array_sym) && length($array_sym) && $inner =~ $array_symbol_expr_re;
   my $hash_sym = $extract_hash_symbol_name->($inner);
   return 1 if defined($hash_sym) && length($hash_sym) && $inner =~ $hash_symbol_expr_re;
   return 0;
  }

 return 0;
 };
 my $normalize_array_value_regex_expr = sub {
  my ($pattern_expr) = @_;
  my $pattern = $trim_action_ir_value->($pattern_expr // '');
  return undef unless defined($pattern) && length($pattern);
  return $pattern if $pattern =~ m{^/(?:\\.|[^/])*/[a-z]*$}io;

  my $literal = $strip_literal_delimiters->($pattern);
  return undef unless defined $literal;
  return '/'.quotemeta($literal).'/'
 };
 my $lower_array_value_source_expr = sub {
  my ($source_expr) = @_;
  my $target_expr = $trim_action_ir_value->($source_expr);
  return undef unless defined($target_expr) && length($target_expr);

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
   return '[@'.$array_symbol.']';
  }

  return undef unless $looks_like_array_value_expr->($target_expr);
  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_array_value_source = '.$lowered_target.'; (defined($__ls_array_value_source) && ref($__ls_array_value_source) eq \'ARRAY\') ? [@{$__ls_array_value_source}] : [] }'
 };
 my $lower_array_pipeline_value_expr = sub {
  my ($call) = @_;
  return undef unless $call;
  my $method = $call->{method} // '';
  return undef unless $method =~ /^__array_value_(split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)$/o;
  my $op = $1;

  my $args = $call->{args} || [];
  return undef unless ref($args) eq 'ARRAY';

  if ($op eq 'split_each') {
   my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);
   return undef unless $effective_args;
   my $source_expr = $lower_array_value_source_expr->($effective_args->[0]);
   my $delimiter_expr = $normalize_array_value_regex_expr->($effective_args->[1]);
   return undef unless defined($source_expr) && length($source_expr);
   return undef unless defined($delimiter_expr) && length($delimiter_expr);
   return 'do { my $__ls_array_pipeline_source = '.$source_expr.'; (defined($__ls_array_pipeline_source) && ref($__ls_array_pipeline_source) eq \'ARRAY\') ? [map { split '.$delimiter_expr.', (defined($_) ? $_ : \'\') } @{$__ls_array_pipeline_source}] : [] }';
  }

  if ($op eq 'filter_match') {
   my $effective_args = $normalize_method_args_with_optional_scope->($args, 2, 2);
   return undef unless $effective_args;
   my $source_expr = $lower_array_value_source_expr->($effective_args->[0]);
   my $pattern_expr = $normalize_array_value_regex_expr->($effective_args->[1]);
   return undef unless defined($source_expr) && length($source_expr);
   return undef unless defined($pattern_expr) && length($pattern_expr);
   return 'do { my $__ls_array_pipeline_source = '.$source_expr.'; (defined($__ls_array_pipeline_source) && ref($__ls_array_pipeline_source) eq \'ARRAY\') ? [grep { defined($_) && $_ =~ '.$pattern_expr.' } @{$__ls_array_pipeline_source}] : [] }';
  }

  my $effective_args = $normalize_method_args_with_optional_scope->($args, 1, 1);
  return undef unless $effective_args;
  my $source_expr = $lower_array_value_source_expr->($effective_args->[0]);
  return undef unless defined($source_expr) && length($source_expr);

  if ($op eq 'trim_each') {
   return 'do { my $__ls_array_pipeline_source = '.$source_expr.'; (defined($__ls_array_pipeline_source) && ref($__ls_array_pipeline_source) eq \'ARRAY\') ? [map { my $__ls_array_pipeline_item = defined($_) ? $_ : \'\'; $__ls_array_pipeline_item =~ s/^\s+|\s+$//g; $__ls_array_pipeline_item } @{$__ls_array_pipeline_source}] : [] }';
  }
  if ($op eq 'filter_nonempty') {
   return 'do { my $__ls_array_pipeline_source = '.$source_expr.'; (defined($__ls_array_pipeline_source) && ref($__ls_array_pipeline_source) eq \'ARRAY\') ? [grep { defined($_) && length($_) } @{$__ls_array_pipeline_source}] : [] }';
  }
  if ($op eq 'lowercase_each') {
   return 'do { my $__ls_array_pipeline_source = '.$source_expr.'; (defined($__ls_array_pipeline_source) && ref($__ls_array_pipeline_source) eq \'ARRAY\') ? [map { defined($_) ? LinkedSpec::UnicodeCaseMapping::lowercase($_) : undef } @{$__ls_array_pipeline_source}] : [] }';
  }
  if ($op eq 'uppercase_each') {
   return 'do { my $__ls_array_pipeline_source = '.$source_expr.'; (defined($__ls_array_pipeline_source) && ref($__ls_array_pipeline_source) eq \'ARRAY\') ? [map { defined($_) ? LinkedSpec::UnicodeCaseMapping::uppercase($_) : undef } @{$__ls_array_pipeline_source}] : [] }';
  }
  if ($op eq 'uniq') {
   return 'do { my $__ls_array_pipeline_source = '.$source_expr.'; if (defined($__ls_array_pipeline_source) && ref($__ls_array_pipeline_source) eq \'ARRAY\') { my %__ls_array_pipeline_seen; [grep { my $__ls_array_pipeline_key = defined($_) ? "S$_" : "U"; !$__ls_array_pipeline_seen{$__ls_array_pipeline_key}++ } @{$__ls_array_pipeline_source}] } else { [] } }';
 }

 return undef
};
my $lower_internal_array_pipeline_target_expr = sub {
 my ($target_expr) = @_;
 return undef unless defined($target_expr) && $target_expr =~ /^\s*__array_value_/o;
 my $pipeline_deps = ref($deps) eq 'HASH' ? { %$deps } : {};
 delete $pipeline_deps->{__actionir_ast_value_lowering_compat_bridge};
 return _lower_method_value_expr($target_expr, $pipeline_deps)
};
my $lower_numeric_array_reducer_source_expr = sub {
 my ($method, $source_expr) = @_;
 return undef unless defined($method) && defined($source_expr) && length($source_expr);
 return 'do { my $__ls_num_sum_source = '.$source_expr.'; if (defined($__ls_num_sum_source) && ref($__ls_num_sum_source) eq \'ARRAY\') { my $__ls_num_sum_total = 0; my $__ls_num_sum_ok = 1; for my $__ls_num_sum_term (@{$__ls_num_sum_source}) { if (!(defined($__ls_num_sum_term) && $__ls_num_sum_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_sum_ok = 0; last; } $__ls_num_sum_total += $__ls_num_sum_term; } $__ls_num_sum_ok ? $__ls_num_sum_total : undef } else { undef } }'
  if $method eq 'num_sum';
 return 'do { my $__ls_num_avg_source = '.$source_expr.'; if (defined($__ls_num_avg_source) && ref($__ls_num_avg_source) eq \'ARRAY\') { my $__ls_num_avg_total = 0; my $__ls_num_avg_count = 0; my $__ls_num_avg_ok = 1; for my $__ls_num_avg_term (@{$__ls_num_avg_source}) { if (!(defined($__ls_num_avg_term) && $__ls_num_avg_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_avg_ok = 0; last; } $__ls_num_avg_total += $__ls_num_avg_term; $__ls_num_avg_count++; } $__ls_num_avg_ok ? ($__ls_num_avg_count ? ($__ls_num_avg_total / $__ls_num_avg_count) : undef) : undef } else { undef } }'
  if $method eq 'num_avg';
 return 'do { my $__ls_num_median_source = '.$source_expr.'; if (defined($__ls_num_median_source) && ref($__ls_num_median_source) eq \'ARRAY\') { my @__ls_num_median_terms = @{$__ls_num_median_source}; my $__ls_num_median_ok = 1; for my $__ls_num_median_term (@__ls_num_median_terms) { if (!(defined($__ls_num_median_term) && $__ls_num_median_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_median_ok = 0; last; } } if ($__ls_num_median_ok && @__ls_num_median_terms) { @__ls_num_median_terms = sort { $a <=> $b } @__ls_num_median_terms; my $__ls_num_median_count = scalar(@__ls_num_median_terms); my $__ls_num_median_mid = int($__ls_num_median_count / 2); ($__ls_num_median_count % 2) ? $__ls_num_median_terms[$__ls_num_median_mid] : (($__ls_num_median_terms[$__ls_num_median_mid - 1] + $__ls_num_median_terms[$__ls_num_median_mid]) / 2) } else { undef } } else { undef } }'
  if $method eq 'num_median';
 return 'do { my $__ls_num_range_source = '.$source_expr.'; if (defined($__ls_num_range_source) && ref($__ls_num_range_source) eq \'ARRAY\') { my $__ls_num_range_min; my $__ls_num_range_max; my $__ls_num_range_seen = 0; my $__ls_num_range_ok = 1; for my $__ls_num_range_term (@{$__ls_num_range_source}) { if (!(defined($__ls_num_range_term) && $__ls_num_range_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_range_ok = 0; last; } if ($__ls_num_range_seen) { $__ls_num_range_min = $__ls_num_range_term if $__ls_num_range_term < $__ls_num_range_min; $__ls_num_range_max = $__ls_num_range_term if $__ls_num_range_term > $__ls_num_range_max; } else { $__ls_num_range_min = $__ls_num_range_term; $__ls_num_range_max = $__ls_num_range_term; $__ls_num_range_seen = 1; } } $__ls_num_range_ok ? ($__ls_num_range_seen ? ($__ls_num_range_max - $__ls_num_range_min) : undef) : undef } else { undef } }'
  if $method eq 'num_range';
 return 'do { my $__ls_num_min_source = '.$source_expr.'; if (defined($__ls_num_min_source) && ref($__ls_num_min_source) eq \'ARRAY\') { my $__ls_num_min_value; my $__ls_num_min_ok = 1; for my $__ls_num_min_term (@{$__ls_num_min_source}) { if (!(defined($__ls_num_min_term) && $__ls_num_min_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_min_ok = 0; last; } $__ls_num_min_value = defined($__ls_num_min_value) ? ($__ls_num_min_term < $__ls_num_min_value ? $__ls_num_min_term : $__ls_num_min_value) : $__ls_num_min_term; } $__ls_num_min_ok ? $__ls_num_min_value : undef } else { undef } }'
  if $method eq 'num_min';
 return 'do { my $__ls_num_max_source = '.$source_expr.'; if (defined($__ls_num_max_source) && ref($__ls_num_max_source) eq \'ARRAY\') { my $__ls_num_max_value; my $__ls_num_max_ok = 1; for my $__ls_num_max_term (@{$__ls_num_max_source}) { if (!(defined($__ls_num_max_term) && $__ls_num_max_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_max_ok = 0; last; } $__ls_num_max_value = defined($__ls_num_max_value) ? ($__ls_num_max_term > $__ls_num_max_value ? $__ls_num_max_term : $__ls_num_max_value) : $__ls_num_max_term; } $__ls_num_max_ok ? $__ls_num_max_value : undef } else { undef } }'
  if $method eq 'num_max';
 return undef
};
 my $legacy_method_value_expr = sub {
  my ($source_expr) = @_;
  return undef unless defined $source_expr;
  my $source_trimmed = $trim_action_ir_value->($source_expr);
  return undef unless defined($source_trimmed) && length($source_trimmed);
  my $compat_deps = ref($deps) eq 'HASH'
   ? { %$deps, __actionir_ast_value_lowering_compat_bridge => 1 }
   : { __actionir_ast_value_lowering_compat_bridge => 1 };
  return _lower_method_value_expr($source_trimmed, $compat_deps)
 };
 my %ast_value_only_call_arity = (
  trim             => [1, 1],
  lowercase        => [1, 1],
  uppercase        => [1, 1],
  length           => [1, 1],
  substr           => [2, 3],
  replace_substr   => [3, 3],
  rm_prefix        => [2, 2],
  rm_suffix        => [2, 2],
  cat              => [2, undef],
  str_eq           => [2, 2],
  str_ne           => [2, 2],
  str_gt           => [2, 2],
  str_ge           => [2, 2],
  str_lt           => [2, 2],
  str_le           => [2, 2],
  starts_with      => [2, 2],
  ends_with        => [2, 2],
  contains_substr  => [2, 2],
  matches          => [2, 2],
  coalesce         => [2, undef],
  coalesce_nonempty => [2, undef],
  is_defined       => [1, 1],
  is_undefined     => [1, 1],
  num_abs          => [1, 1],
  num_floor        => [1, 1],
  num_ceil         => [1, 1],
  num_round        => [1, 1],
  num_add          => [2, undef],
  num_sub          => [2, 2],
  num_mul          => [2, undef],
  num_div          => [2, 2],
  num_mod          => [2, 2],
  num_clamp        => [3, 3],
  num_min          => [2, undef],
  num_max          => [2, undef],
  num_eq           => [2, 2],
  num_ne           => [2, 2],
  num_gt           => [2, 2],
  num_ge           => [2, 2],
  num_lt           => [2, 2],
  num_le           => [2, 2],
 );
 my %ast_aggregate_call_arity = (
  array                => [0, undef],
  hash                 => [0, undef],
  copy                 => [1, 1],
  flat                 => [1, 1],
  flat_array           => [1, 1],
  flat_hash            => [1, 1],
  count                => [1, 1],
  first                => [1, 1],
  last                 => [1, 1],
  drop_front           => [1, 2],
  take                 => [1, 2],
  slice                => [2, 3],
  take_last            => [1, 2],
  drop_back            => [1, 2],
  concat_arrays        => [1, undef],
  split                => [2, 2],
  split_tagged_records => [3, undef],
  sorted               => [1, 1],
  reversed             => [1, 1],
  contains             => [2, 2],
  index_of             => [2, 2],
  split_each           => [2, 2],
  trim_each            => [1, 1],
  filter_nonempty      => [1, 1],
  lowercase_each       => [1, 1],
  uppercase_each       => [1, 1],
  uniq                 => [1, 1],
  filter_match         => [2, 2],
  count_keys           => [1, 1],
  sorted_keys          => [1, 1],
  sorted_values        => [1, 1],
  has_key              => [2, 2],
  merge_hash           => [1, undef],
  set_key              => [3, 3],
  rename_key           => [3, 3],
  drop_keys            => [2, undef],
  pick_keys            => [2, undef],
  join_values          => [2, 2],
  entry_groups         => [0, 0],
  match_groups         => [0, 0],
  entry_map            => [0, 0],
  entry_named_map      => [0, 0],
  match_map            => [0, 0],
  match_named_map      => [0, 0],
  num_sum              => [1, 1],
  num_avg              => [1, 1],
  num_median           => [1, 1],
  num_range            => [1, 1],
  num_min              => [1, undef],
  num_max              => [1, undef],
 );
 my $normalize_ast_call_method = sub {
  my ($method) = @_;
  return undef unless defined($method) && length($method);
  my $numeric_alias = _numeric_word_alias_helper_name($method);
  return $numeric_alias if defined($numeric_alias) && length($numeric_alias);
  return $method
 };
 my $ast_call_method_with_arity = sub {
  my ($method, $argc, $arity_map) = @_;
  $method = $normalize_ast_call_method->($method);
  return undef unless defined($method) && length($method);
  my $arity = $arity_map->{$method};
  return undef unless ref($arity) eq 'ARRAY';
  return undef if $argc < $arity->[0];
  return undef if defined($arity->[1]) && $argc > $arity->[1];
  return $method
 };
 my $ast_value_only_call_method = sub {
  my ($method, $argc) = @_;
  return $ast_call_method_with_arity->($method, $argc, \%ast_value_only_call_arity)
 };
 my $ast_aggregate_call_method = sub {
  my ($method, $argc) = @_;
  return $ast_call_method_with_arity->($method, $argc, \%ast_aggregate_call_arity)
 };
 my $ast_known_call_method = sub {
  my ($method) = @_;
  $method = $normalize_ast_call_method->($method);
  return undef unless defined($method) && length($method);
  return $method
   if exists $ast_value_only_call_arity{$method}
   || exists $ast_aggregate_call_arity{$method};
  return undef
 };
 my $unsupported_ast_helper_expr = sub {
  my ($method) = @_;
  $method = $ast_known_call_method->($method);
  return undef unless defined($method) && $method =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  return 'do { my $__ls_actionir_unsupported_helper = "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:'.$method.'"; undef }'
 };
 my $lower_ast_value_node;
 my $lower_ast_value_only_call_node;
 my $lower_ast_aggregate_call_node;
 my $lower_ast_fluent_chain_node;
 my $lower_ast_scalar_assignment_value_node;
 my $lower_ast_user_function_call_node;
 my $lower_ast_codeblock_variable_call_node;
 my $lower_ast_with_trailing_block_call_node;
 my $ast_expr_source_node;
 my $lower_ast_supported_call_source_node;
 my $lower_user_function_node_source_expr = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH';
  my $source = _actionir_ast_value_source_expr($node);
  $source = $node->{source} if !(defined($source) && length($source)) && defined($node->{source});
  return $source
 };
 my $lower_user_function_body_value_expr = sub {
  my ($node, $body_deps) = @_;
  return undef unless ref($node) eq 'HASH';
  return undef if ($node->{kind} // '') eq 'raw_perl';
  if (($node->{kind} // '') eq 'variable' && _user_function_scalar_value_name($body_deps, $node->{name})) {
   my $scalar_read = _lower_source_slot_bare_scalar_read_expr($node->{name}, $body_deps);
   return $scalar_read if defined($scalar_read) && length($scalar_read);
  }
  my $source = $lower_user_function_node_source_expr->($node);
  return undef unless defined($source) && length($source);
  my $value_expr = _lower_method_value_expr($source, $body_deps);
  $value_expr = $source unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);
  $value_expr = '+'.$value_expr if $value_expr =~ /^\s*\{/s;
  return $value_expr
 };
 my $lower_user_function_body_return_payload = sub {
  my ($stmt, $body_deps) = @_;
  return undef unless ref($stmt) eq 'HASH';
  my $expr_node = $stmt->{expr};
  return undef unless ref($expr_node) eq 'HASH'
              && ($expr_node->{kind} // '') eq 'call'
              && ($expr_node->{name} // '') eq 'return';
  my $args = $expr_node->{args} || [];
  return undef unless ref($args) eq 'ARRAY' && @$args == 1;
  return $lower_user_function_body_value_expr->($args->[0], $body_deps)
 };
 $lower_ast_user_function_call_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'call';
  my $name = $node->{name};
  my $definition = _user_function_definition_for_name($deps, $name);
  return undef unless ref($definition) eq 'HASH';
  my $normalized = _normalize_contextual_codeblock_call_node($deps, 'helper', $node, $name);
  return _actionir_ast_unsupported_helper_expr($name) if defined($normalized->{error});
  $node = $normalized->{node};
  return _actionir_ast_unsupported_helper_expr($name)
   if _user_function_call_stack_contains($deps, $name);

  my $args = $node->{args} || [];
  my $signature = _user_function_call_signature($definition);
  my $params = ref($signature) eq 'HASH' ? $signature->{positional_params} : undef;
  my $rest_param = ref($signature) eq 'HASH' ? $signature->{rest_param} : undef;
  return _actionir_ast_unsupported_helper_expr($name)
   unless ref($args) eq 'ARRAY' && ref($params) eq 'ARRAY'
       && @$args >= $signature->{min_arity}
       && (!defined($signature->{max_arity}) || @$args <= $signature->{max_arity});

  my @lowered_args;
  for (my $arg_idx = 0; $arg_idx < @$args; ++$arg_idx) {
   my $arg = $args->[$arg_idx];
   my $arg_source = $lower_user_function_node_source_expr->($arg);
   my $arg_expr;
   if (ref($arg) eq 'HASH' && ($arg->{kind} // '') eq 'codeblock_argument') {
    my $record = _contextual_codeblock_runtime_record($arg);
    $arg_expr = _actionir_ast_plain_data_expr($record) if ref($record) eq 'HASH';
   } elsif (ref($arg) eq 'HASH'
    && ($arg->{kind} // '') eq 'variable'
    && _user_function_scalar_value_name($deps, $arg->{name})) {
    $arg_expr = _lower_source_slot_bare_scalar_read_expr($arg->{name}, $deps);
   }
   $arg_expr = _lower_method_value_expr($arg_source, $deps)
    unless defined($arg_expr) && length($arg_expr);
   $arg_expr = $arg_source unless defined($arg_expr) && length($arg_expr);
   return _actionir_ast_unsupported_helper_expr($name)
    unless defined($arg_expr) && length($arg_expr);
   $arg_expr = '+'.$arg_expr if $arg_expr =~ /^\s*\{/s;
   my $parameter_kinds = $definition->{parameter_kinds};
   if (ref($parameter_kinds) eq 'HASH'
    && $arg_idx == $#$args
    && ($parameter_kinds->{$params->[-1]} // '') eq 'codeblock') {
    $arg_expr = 'do { require LinkedSpec::CodeblockRuntime; '
     .'LinkedSpec::CodeblockRuntime::require_codeblock_value('.$arg_expr.') }';
   }
   push @lowered_args, $arg_expr;
  }

  my $body_ast = $definition->{body_ast};
  my $statements = ref($body_ast) eq 'HASH' ? $body_ast->{statements} : undef;
  return _actionir_ast_unsupported_helper_expr($name)
   unless ref($statements) eq 'ARRAY';

  my $body_deps = _user_function_deps_with_call($deps, $name);
  my $local_decl_statements = _user_function_local_decl_statements($definition);
  my %scalar_value_names = map { $_ => 1 } @$params;
  $scalar_value_names{$rest_param} = 1 if defined($rest_param);
  foreach my $decl (@$local_decl_statements) {
   $scalar_value_names{$1} = 1 if defined($decl) && $decl =~ /\Amy \$([A-Za-z_][A-Za-z0-9_]*);/o;
  }
  $body_deps->{__user_function_scalar_value_names} = \%scalar_value_names;
  $body_deps->{__user_function_parameter_kinds} = { %{$definition->{parameter_kinds}} }
   if ref($definition->{parameter_kinds}) eq 'HASH';
  my @lowered = @$local_decl_statements;
  for (my $idx = 0; $idx < @lowered_args; ++$idx) {
   push @lowered, 'my $__ls_user_fn_arg_'.$idx.' = '.$lowered_args[$idx].';';
  }
  for (my $idx = 0; $idx < @$params; ++$idx) {
   push @lowered, 'my $'.$params->[$idx].' = $__ls_user_fn_arg_'.$idx.';';
  }
  if (defined($rest_param)) {
   my @rest_args = map { '$__ls_user_fn_arg_'.$_ } @$params .. $#lowered_args;
   push @lowered, 'my $'.$rest_param.' = ['.join(', ', @rest_args).'];';
  }

  unless (@$statements) {
   push @lowered, 'undef';
   return 'do { '.join(' ', @lowered).' }'
  }

  my @return_payloads;
  my $has_nonfinal_return = 0;
  for (my $idx = 0; $idx < @$statements; ++$idx) {
   my $stmt = $statements->[$idx];
   my $expr_node = ref($stmt) eq 'HASH' ? $stmt->{expr} : undef;
   next unless ref($expr_node) eq 'HASH'
    && ($expr_node->{kind} // '') eq 'call'
    && ($expr_node->{name} // '') eq 'return';
   my $payload_expr = $lower_user_function_body_return_payload->($stmt, $body_deps);
   return _actionir_ast_unsupported_helper_expr($name)
    unless defined($payload_expr) && length($payload_expr);
   $return_payloads[$idx] = $payload_expr;
   $has_nonfinal_return = 1 if $idx < $#$statements;
  }

  if ($has_nonfinal_return) {
   push @lowered, (
    'my $__ls_user_fn_done = 0;',
    'my $__ls_user_fn_value;',
   );
   for (my $idx = 0; $idx < @$statements; ++$idx) {
    if (defined $return_payloads[$idx]) {
     push @lowered,
      'unless ($__ls_user_fn_done) { $__ls_user_fn_value = '.$return_payloads[$idx].'; $__ls_user_fn_done = 1; };';
     next;
    }
    my $stmt = $statements->[$idx];
    my $is_last = ($idx == $#$statements);
    if ($is_last) {
     my $value_expr = $lower_user_function_body_value_expr->($stmt->{expr}, $body_deps);
     return _actionir_ast_unsupported_helper_expr($name)
      unless defined($value_expr) && length($value_expr);
     push @lowered,
      'unless ($__ls_user_fn_done) { $__ls_user_fn_value = '.$value_expr.'; $__ls_user_fn_done = 1; };';
     next;
    }
    my $lowered_statement = _lower_ast_block_side_effect_statement($stmt, $body_deps);
    $lowered_statement = _lower_block_side_effect_statement($stmt->{source}, $body_deps)
     unless defined($lowered_statement) && length($lowered_statement);
    return _actionir_ast_unsupported_helper_expr($name)
     unless defined($lowered_statement) && length($lowered_statement);
    push @lowered, 'unless ($__ls_user_fn_done) { '.$lowered_statement.'; };';
   }
   push @lowered, '$__ls_user_fn_value';
   return 'do { '.join(' ', @lowered).' }'
  }

  for (my $idx = 0; $idx < @$statements; ++$idx) {
   my $stmt = $statements->[$idx];
   my $is_last = ($idx == $#$statements);
   if ($is_last) {
    if (defined $return_payloads[$idx]) {
     push @lowered, $return_payloads[$idx];
     next;
    }
    my $value_expr = $lower_user_function_body_value_expr->($stmt->{expr}, $body_deps);
    return _actionir_ast_unsupported_helper_expr($name)
     unless defined($value_expr) && length($value_expr);
    push @lowered, $value_expr;
    next;
   }

   my $lowered_statement = _lower_ast_block_side_effect_statement($stmt, $body_deps);
   $lowered_statement = _lower_block_side_effect_statement($stmt->{source}, $body_deps)
    unless defined($lowered_statement) && length($lowered_statement);
   return _actionir_ast_unsupported_helper_expr($name)
    unless defined($lowered_statement) && length($lowered_statement);
   push @lowered, $lowered_statement.';';
  }

  return 'do { '.join(' ', @lowered).' }'
 };
 $lower_ast_codeblock_variable_call_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'call';
  my $name = $node->{name};
  return undef unless _codeblock_variable_call_candidate($deps, $name);

  my $keyword_count = grep {
   ref($_) eq 'HASH'
    && ($_->{kind} // '') eq 'raw_perl'
    && defined($_->{source})
    && $_->{source} =~ /\A\s*[A-Za-z_][A-Za-z0-9_]*\s*:/s
  } @{$node->{args} || []};
  if ($keyword_count) {
   return 'do { require LinkedSpec::CodeblockRuntime; '
    .'LinkedSpec::CodeblockRuntime::reject_keyword_arguments('.$keyword_count.') }'
  }

  my @lowered_args;
  foreach my $arg (@{$node->{args} || []}) {
   my $arg_expr = $lower_ast_value_node->($arg, { bare_scalar_read => 1 })
    if ref($lower_ast_value_node) eq 'CODE';
   $arg_expr = $ast_expr_source_node->($arg)
    if !(defined($arg_expr) && length($arg_expr)) && ref($ast_expr_source_node) eq 'CODE';
   $arg_expr = $arg->{source}
    if ref($arg) eq 'HASH' && !(defined($arg_expr) && length($arg_expr));
   return _actionir_ast_unsupported_helper_expr($name)
    unless defined($arg_expr) && length($arg_expr);
   $arg_expr = '+'.$arg_expr if $arg_expr =~ /^\s*\{/s;
   push @lowered_args, $arg_expr;
  }

  my $bindings = _codeblock_runtime_binding_expr($deps, $name);
  return 'do { require LinkedSpec::CodeblockRuntime; '
   .'LinkedSpec::CodeblockRuntime::invoke($'.$name.', ['.join(', ', @lowered_args).'], '
   .$bindings.', '._actionir_ast_quote_string_source($name).') }'
 };
 my $ast_string_source_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH';
  my $source = $node->{source};
  return $source if defined($source) && $source =~ /\A(['"])(?:\\.|(?!\1).)*\1\z/s;
  my $quote = $node->{quote};
  $quote = '"' unless defined($quote) && ($quote eq '"' || $quote eq "'");
  my $payload = defined($node->{value}) ? $node->{value} : '';
  $payload =~ s/\\/\\\\/g;
  $payload =~ s/\Q$quote\E/\\$quote/g;
  return $quote.$payload.$quote
 };
 my $ast_regex_source_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH';
  my $source = $node->{source};
  return $source if defined($source) && $source =~ m{\A/(?:\\.|[^/])*/[A-Za-z]*\z}s;
  my $pattern = defined($node->{pattern}) ? $node->{pattern} : '';
  my $flags = defined($node->{flags}) ? $node->{flags} : '';
  $pattern =~ s{/}{\\/}g;
  return '/'.$pattern.'/'.$flags
 };
 $ast_expr_source_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH';
  my $kind = $node->{kind} // '';

  if ($kind eq 'number') {
   my $source = $node->{source};
   return $source if defined($source) && $source =~ /\A-?\d+(?:\.\d+)?\z/o;
   return defined($node->{value}) ? (''.$node->{value}) : undef;
  }
  return $ast_string_source_node->($node) if $kind eq 'string';
  return $ast_regex_source_node->($node) if $kind eq 'regex';
  return 'undef' if $kind eq 'undef';
  return $node->{value} ? 'true' : 'false' if $kind eq 'boolean';
  if ($kind eq 'variable' && defined($node->{name}) && length($node->{name})) {
   my $scalar_read = _lower_source_slot_bare_scalar_read_expr($node->{name}, $deps)
    if _user_function_scalar_value_name($deps, $node->{name});
   return $scalar_read if defined($scalar_read) && length($scalar_read);
   return $node->{name}
  }
  return ':'.$node->{name}
   if $kind eq 'colon_scalar_slot_removed'
   && defined($node->{name})
   && $node->{name} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  return _actionir_ast_retired_hash_literal_fat_arrow_expr()
   if $kind eq 'hash_literal_fat_arrow_removed';
  return $node->{source_text}
   if $kind eq 'codeblock_literal'
   && defined($node->{source_text})
   && length($node->{source_text});
  return _actionir_ast_unsupported_helper_expr($node->{code})
   if $kind eq 'codeblock_literal_error';
  if ($kind eq 'assign_scalar') {
   return undef unless defined($node->{name}) && $node->{name} =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
   my $value_expr = $ast_expr_source_node->($node->{value});
   return undef unless defined($value_expr) && length($value_expr);
   return $node->{name}.' = '.$value_expr;
  }
  if ($kind eq 'indexed_var') {
   return undef unless defined($node->{name}) && length($node->{name});
   my $index_expr = $ast_expr_source_node->($node->{index});
   return undef unless defined($index_expr) && length($index_expr);
   return $node->{name}.'['.$index_expr.']';
  }
  if ($kind eq 'nested_access') {
   return undef unless defined($node->{base}) && length($node->{base});
   my $expr = $node->{base};
   foreach my $segment (@{$node->{segments} || []}) {
    my $segment_kind = $segment->{kind} // '';
    if ($segment_kind eq 'key') {
     my $segment_source = $segment->{source};
     if (defined($segment_source) && $segment_source =~ /\A\[(?:['"])(?:\\.|.)*(?:['"])\]\z/s) {
      $expr .= $segment_source;
      next;
     }
     my $key_node = {
      kind => 'string',
      value => $segment->{value},
      quote => '"',
      source => undef,
     };
     my $key_expr = $ast_string_source_node->($key_node);
     return undef unless defined($key_expr) && length($key_expr);
     $expr .= '['.$key_expr.']';
     next;
    }
    return undef unless $segment_kind eq 'index';
    my $index_expr = $ast_expr_source_node->($segment->{expr});
    return undef unless defined($index_expr) && length($index_expr);
    $expr .= '['.$index_expr.']';
   }
   return $expr
  }
  if ($kind eq 'array_literal') {
   my @items;
   foreach my $item (@{$node->{items} || []}) {
    my $item_expr = $ast_expr_source_node->($item);
    return undef unless defined($item_expr) && length($item_expr);
    push @items, $item_expr;
   }
   return '['.join(', ', @items).']';
  }
  if ($kind eq 'hash_literal') {
   my @pairs;
   foreach my $entry (@{$node->{entries} || []}) {
    my $key_expr = $ast_expr_source_node->($entry->{key});
    my $value_expr = $ast_expr_source_node->($entry->{value});
    return undef unless defined($key_expr) && length($key_expr);
    return undef unless defined($value_expr) && length($value_expr);
    push @pairs, $key_expr.' : '.$value_expr;
   }
   return '{'.join(', ', @pairs).'}';
  }
  if ($kind eq 'block_value') {
   my $source = $node->{source};
   return $source if defined($source) && length($source);
   return undef;
  }
  if ($kind eq 'call') {
   return $node->{source}
    if $node->{trailing_block_arg}
    && defined($node->{source})
    && length($node->{source});
   if (($node->{name} // '') eq '=') {
    my @args;
    foreach my $arg (@{$node->{args} || []}) {
     my $arg_expr = $ast_expr_source_node->($arg);
     $arg_expr = $arg->{source}
      if ref($arg) eq 'HASH' && !(defined($arg_expr) && length($arg_expr));
     return undef unless defined($arg_expr) && length($arg_expr);
     push @args, $arg_expr;
    }
    return '=('.join(', ', @args).')';
   }
   my $user_function_call = $lower_ast_user_function_call_node->($node);
   return $user_function_call if defined($user_function_call) && length($user_function_call);
   my $call_expr = $lower_ast_supported_call_source_node->($node);
   return $call_expr if defined($call_expr) && length($call_expr);
   my $codeblock_call = $lower_ast_codeblock_variable_call_node->($node);
   return $codeblock_call if defined($codeblock_call) && length($codeblock_call);
   my $unsupported_call = $unsupported_ast_helper_expr->($node->{name});
   return $unsupported_call if defined($unsupported_call) && length($unsupported_call);
   my $legacy_call = $legacy_method_value_expr->($node->{source});
   return $legacy_call
    if defined($legacy_call) && length($legacy_call) && $legacy_call ne ($node->{source} // '');
   unless (defined(_actionir_ast_known_value_call_method($node->{name}))) {
    my $unknown_call = _actionir_ast_unsupported_helper_expr($node->{name});
    return $unknown_call if defined($unknown_call) && length($unknown_call);
   }
   my $source = $node->{source};
   return $source if defined($source) && length($source);
  }
  if ($kind eq 'fluent_chain') {
   my $chain_expr = ref($lower_ast_fluent_chain_node) eq 'CODE'
    ? $lower_ast_fluent_chain_node->($node)
    : undef;
   return $chain_expr if defined($chain_expr) && length($chain_expr);
   my $unknown = _actionir_ast_first_unknown_value_call_name($node, $deps);
   my $unknown_expr = _actionir_ast_unsupported_helper_expr($unknown);
   return $unknown_expr if defined($unknown_expr) && length($unknown_expr);
   my $legacy_chain = $legacy_method_value_expr->($node->{source});
   return $legacy_chain
    if defined($legacy_chain) && length($legacy_chain) && $legacy_chain ne ($node->{source} // '');
   my $source = $node->{source};
   return $source if defined($source) && length($source);
  }
  return undef
 };
 $lower_ast_scalar_assignment_value_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH';

  my ($target_name, $target_sigil, $value_node);
  my $kind = $node->{kind} // '';
  if ($kind eq 'assign_array_append') {
   my $target = $node->{name};
   return undef unless defined($target) && $target =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
   my $value_source = $ast_expr_source_node->($node->{value});
   $value_source = $node->{value}{source}
    if ref($node->{value}) eq 'HASH' && !(defined($value_source) && length($value_source));
   return undef unless defined($value_source) && length($value_source);
   my $lowered_value = _lower_mutation_slot_value_expr($value_source, $deps);
   return undef unless defined($lowered_value) && length($lowered_value);
   return _uniform_binding_array_push_expr($target, $lowered_value)
  }

  if ($kind eq 'assign_hash_index') {
   my $target = $node->{name};
   return undef unless defined($target) && $target =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
   my $scalar_held = _lower_ast_scalar_held_hash_index_assignment_value_node($node, $deps);
   return $scalar_held if defined($scalar_held) && length($scalar_held);
   my $key_source = $ast_expr_source_node->($node->{key});
   $key_source = $node->{key}{source}
    if ref($node->{key}) eq 'HASH' && !(defined($key_source) && length($key_source));
   my $value_source = $ast_expr_source_node->($node->{value});
   $value_source = $node->{value}{source}
    if ref($node->{value}) eq 'HASH' && !(defined($value_source) && length($value_source));
   return undef unless defined($key_source) && length($key_source);
   return undef unless defined($value_source) && length($value_source);
   my $lower_scalar_access_key_expr = $require_dep->('lower_scalar_access_key_expr');
   my $key_lowered = $lower_scalar_access_key_expr->($key_source);
   return undef unless defined($key_lowered) && length($key_lowered);
   my $value_lowered = _lower_mutation_slot_value_expr($value_source, $deps);
   return undef unless defined($value_lowered) && length($value_lowered);
   return 'do { $'.$target.'{'.$key_lowered.'} = '.$value_lowered.'; +{%'.$target.'} }'
  }

  if ($kind eq 'assign_nested_access') {
   return _lower_ast_nested_access_assignment_value_node($node, $deps)
  }

  if ($kind eq 'assign_scalar') {
   $target_name = $node->{name};
   $target_sigil = '$';
   $value_node = $node->{value};
  } elsif ($kind eq 'call') {
   my $method = $node->{name} // '';
   return undef unless $method eq '=' || $method eq 'set';
   my $args = $node->{args} || [];
   return undef unless ref($args) eq 'ARRAY' && @$args == 2;
   my $target_node = $args->[0];
   $value_node = $args->[1];

   if (ref($target_node) eq 'HASH' && ($target_node->{kind} // '') eq 'variable') {
    $target_name = $target_node->{name};
    $target_sigil = '$';
   } elsif (ref($target_node) eq 'HASH'
       && ($target_node->{kind} // '') eq 'colon_scalar_slot_removed') {
    return _actionir_ast_retired_colon_scalar_slot_expr($target_node->{name});
   } elsif (ref($target_node) eq 'HASH'
       && ($target_node->{kind} // '') eq 'call'
       && (($target_node->{name} // '') eq 'array' || ($target_node->{name} // '') eq 'hash')) {
    my $target_args = $target_node->{args} || [];
    if (ref($target_args) eq 'ARRAY'
     && @$target_args == 1
     && ref($target_args->[0]) eq 'HASH'
     && ($target_args->[0]{kind} // '') eq 'variable') {
     $target_name = $target_args->[0]{name};
     $target_sigil = ($target_node->{name} // '') eq 'array' ? '@' : '%';
     my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')
      ? $deps->{bare_symbol_kind}
      : sub { return undef };
     $target_sigil = '$' if (($bare_symbol_kind->($target_name) // '') eq 'scalar');
    }
   }

   unless (defined($target_name) && length($target_name)) {
    my $target_source = $ast_expr_source_node->($target_node);
    $target_source = $target_node->{source}
     if ref($target_node) eq 'HASH' && !(defined($target_source) && length($target_source));
    $target_name = $extract_scalar_symbol_name->($target_source)
     if defined($target_source) && length($target_source);
    $target_sigil = '$' if defined($target_name) && length($target_name);
   }
  } else {
   return undef;
  }

  return undef unless defined($target_name) && $target_name =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  return undef unless ref($value_node) eq 'HASH';
  $target_sigil = '$' unless defined($target_sigil) && $target_sigil =~ /^[\$\@\%]$/o;

  my $value_kind = $value_node->{kind} // '';
  my $direct_shape_sigil = $value_kind eq 'array_literal' ? '@'
                         : $value_kind eq 'hash_literal'  ? '%'
                         : undef;
  if (defined($direct_shape_sigil)) {
   return undef if $target_sigil eq '@' && $direct_shape_sigil ne '@';
   return undef if $target_sigil eq '%' && $direct_shape_sigil ne '%';

   my $source_expr = $ast_expr_source_node->($value_node);
   $source_expr = $value_node->{source}
    unless defined($source_expr) && length($source_expr);
   return undef unless defined($source_expr) && length($source_expr);

   if ($target_sigil eq '$') {
    my $value_expr = $lower_ast_value_node->($value_node, { bare_scalar_read => 1 });
    $value_expr = $legacy_method_value_expr->($value_node->{source})
     unless defined($value_expr) && length($value_expr);
    $value_expr = $source_expr unless defined($value_expr) && length($value_expr);
    return undef unless defined($value_expr) && length($value_expr);
    return 'do { $'.$target_name.' = '.$value_expr.'; $'.$target_name.' }'
   }

   my $lower_declare_initializer_expr = $require_dep->('lower_declare_initializer_expr');
   if ($target_sigil eq '@') {
    my $initializer = $lower_declare_initializer_expr->('array', $source_expr);
    return undef unless defined($initializer) && length($initializer);
   return 'do { @'.$target_name.' = '.$initializer.'; [@'.$target_name.'] }'
   }
   if ($target_sigil eq '%') {
    my $initializer = $lower_declare_initializer_expr->('hash', $source_expr);
    return undef unless defined($initializer) && length($initializer);
    return 'do { %'.$target_name.' = '.$initializer.'; +{%'.$target_name.'} }'
   }
  }

  return undef unless $target_sigil eq '$';
  my $value_expr = $lower_ast_value_node->($value_node, { bare_scalar_read => 1 });
  $value_expr = $legacy_method_value_expr->($value_node->{source})
   unless defined($value_expr) && length($value_expr);
  $value_expr = $value_node->{source}
   if !(defined($value_expr) && length($value_expr)) && defined($value_node->{source});
  return undef unless defined($value_expr) && length($value_expr);

  return 'do { $'.$target_name.' = '.$value_expr.'; $'.$target_name.' }'
 };
	$lower_ast_supported_call_source_node = sub {
	 my ($node) = @_;
	 return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'call';
	 my $args = $node->{args} || [];
  return undef unless ref($args) eq 'ARRAY';
  my $method = $ast_value_only_call_method->($node->{name}, scalar(@$args));
  $method = $ast_aggregate_call_method->($node->{name}, scalar(@$args))
   unless defined($method) && length($method);
  return undef unless defined($method) && length($method);

  my @arg_exprs;
  foreach my $arg (@$args) {
   my $arg_expr = $ast_expr_source_node->($arg);
   return undef unless defined($arg_expr) && length($arg_expr);
   push @arg_exprs, $arg_expr;
  }
	 return $method.'('.join(', ', @arg_exprs).')'
 };
 my $lower_ast_direct_access_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH';
  my $kind = $node->{kind} // '';
  my $base = $kind eq 'indexed_var' ? $node->{name} : $node->{base};
  return undef if _is_reserved_actionir_value_symbol($base);
  return undef unless defined($base) && $base =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;

  my @segments;
  if ($kind eq 'indexed_var') {
   push @segments, { kind => 'index', expr => $node->{index} };
  } elsif ($kind eq 'nested_access') {
   @segments = @{$node->{segments} || []};
  } else {
   return undef;
  }
  return undef unless @segments;

  my $lowered = '$'.$base;
  foreach my $segment (@segments) {
   my $segment_kind = $segment->{kind} // '';
   if ($segment_kind eq 'key') {
    my $segment_source = $segment->{source};
    return undef unless defined($segment_source) && length($segment_source) >= 2;
    my $key_source = substr($segment_source, 1, length($segment_source) - 2);
    return undef unless defined($key_source) && length($key_source);
    $lowered .= '->{'.$key_source.'}';
    next;
   }
   return undef unless $segment_kind eq 'index';
   my $index_node = $segment->{expr};
   if (ref($index_node) eq 'HASH') {
    my $index_kind = $index_node->{kind} // '';
    return undef if $index_kind eq 'undef' || $index_kind eq 'boolean';
    return undef if $index_kind eq 'variable' && _is_reserved_actionir_value_symbol($index_node->{name});
   }
   my $index_expr = $lower_ast_value_node->($segment->{expr}, { bare_scalar_read => 1 });
   $index_expr = $legacy_method_value_expr->($segment->{expr}{source})
    unless defined($index_expr) && length($index_expr);
   return undef unless defined($index_expr) && length($index_expr);
   $lowered .= '->['.$index_expr.']';
  }
  return $lowered
 };
 my $lower_ast_block_value_node;
 $lower_ast_block_value_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'block_value';
  my $statements = $node->{block}{statements};
  return undef unless ref($statements) eq 'ARRAY' && @$statements;

  my @return_payloads;
  my $has_nonfinal_return = 0;
  for (my $idx = 0; $idx < @$statements; ++$idx) {
   my $stmt = $statements->[$idx];
   my $expr_node = ref($stmt) eq 'HASH' ? $stmt->{expr} : undef;
   next unless ref($expr_node) eq 'HASH'
    && ($expr_node->{kind} // '') eq 'call'
    && ($expr_node->{name} // '') eq 'return';
   my $args = $expr_node->{args} || [];
   my $payload_expr;
   if (ref($args) eq 'ARRAY' && @$args == 1) {
    $payload_expr = $lower_ast_value_node->($args->[0], { bare_scalar_read => 1 });
    $payload_expr = $legacy_method_value_expr->($args->[0]{source})
     unless defined($payload_expr) && length($payload_expr);
   } else {
    $payload_expr = _lower_block_local_return_payload_expr($stmt->{source}, $deps);
   }
   return undef unless defined($payload_expr) && length($payload_expr);
   $payload_expr = '+'.$payload_expr if $payload_expr =~ /^\s*\{/s;
   $return_payloads[$idx] = $payload_expr;
   $has_nonfinal_return = 1 if $idx < $#$statements;
  }

  if ($has_nonfinal_return) {
   my @lowered = (
    'my $__ls_block_done = 0;',
    'my $__ls_block_value;',
   );
   for (my $idx = 0; $idx < @$statements; ++$idx) {
    if (defined $return_payloads[$idx]) {
     push @lowered,
      'unless ($__ls_block_done) { $__ls_block_value = '.$return_payloads[$idx].'; $__ls_block_done = 1; };';
     next;
    }

    my $stmt = $statements->[$idx];
    my $is_last = ($idx == $#$statements);
    if ($is_last) {
     my $value_expr = $lower_ast_value_node->($stmt->{expr}, { bare_scalar_read => 1 });
     $value_expr = $legacy_method_value_expr->($stmt->{expr}{source})
      unless defined($value_expr) && length($value_expr);
     return undef unless defined($value_expr) && length($value_expr);
     $value_expr = '+'.$value_expr if $value_expr =~ /^\s*\{/s;
     push @lowered,
      'unless ($__ls_block_done) { $__ls_block_value = '.$value_expr.'; $__ls_block_done = 1; };';
     next;
    }

    my $lowered_statement = _lower_ast_block_side_effect_statement($stmt, $deps);
    $lowered_statement = _lower_block_side_effect_statement($stmt->{source}, $deps)
     unless defined($lowered_statement) && length($lowered_statement);
    return undef unless defined($lowered_statement) && length($lowered_statement);
    push @lowered, 'unless ($__ls_block_done) { '.$lowered_statement.'; };';
   }
   return 'do { '.join(' ', @lowered).' $__ls_block_value }'
  }

  my @lowered;
  for (my $idx = 0; $idx < @$statements; ++$idx) {
   my $stmt = $statements->[$idx];
   my $is_last = ($idx == $#$statements);

   if ($is_last) {
    if (defined $return_payloads[$idx]) {
     push @lowered, $return_payloads[$idx];
     next;
    }
    my $value_expr = $lower_ast_value_node->($stmt->{expr}, { bare_scalar_read => 1 });
    $value_expr = $legacy_method_value_expr->($stmt->{expr}{source})
     unless defined($value_expr) && length($value_expr);
    return undef unless defined($value_expr) && length($value_expr);
    $value_expr = '+'.$value_expr if $value_expr =~ /^\s*\{/s;
    push @lowered, $value_expr;
    next;
   }

   my $lowered_statement = _lower_ast_block_side_effect_statement($stmt, $deps);
   $lowered_statement = _lower_block_side_effect_statement($stmt->{source}, $deps)
    unless defined($lowered_statement) && length($lowered_statement);
   return undef unless defined($lowered_statement) && length($lowered_statement);
   push @lowered, $lowered_statement.';';
  }
  return undef unless @lowered;
  return 'do { '.join(' ', @lowered).' }'
 };
 $lower_ast_with_trailing_block_call_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'call';
  my $name = $node->{name} // '';
  return undef unless $name eq 'with';

  my $normalized = _normalize_contextual_codeblock_call_node($deps, 'helper', $node, $name);
  return _actionir_ast_unsupported_helper_expr($name) if defined($normalized->{error});
  $node = $normalized->{node};

  my $args = $node->{args} || [];
  return _actionir_ast_unsupported_helper_expr('with')
   unless ref($args) eq 'ARRAY' && (@$args == 1 || @$args == 2);

  my $block_node = $args->[-1];
  return _actionir_ast_unsupported_helper_expr('with') unless ref($block_node) eq 'HASH';

  my $value_expr = 'undef';
  if (@$args == 2) {
   $value_expr = $lower_ast_value_node->($args->[0], { bare_scalar_read => 1 });
   $value_expr = $legacy_method_value_expr->($args->[0]{source})
    unless defined($value_expr) && length($value_expr);
   $value_expr = $args->[0]{source}
    if !(defined($value_expr) && length($value_expr)) && defined($args->[0]{source});
   return _actionir_ast_unsupported_helper_expr('with')
    unless defined($value_expr) && length($value_expr);
   $value_expr = '+'.$value_expr if $value_expr =~ /^\s*\{/s;
  }

  my $block_kind = $block_node->{kind} // '';
  if ($block_kind eq 'codeblock_argument') {
   my $block_value = {
    kind => 'block_value',
    block => $block_node->{body_ast},
    source => $block_node->{source_text},
    source_span => $block_node->{source_span},
   };
   my $block_expr = $lower_ast_block_value_node->($block_value);
   return _actionir_ast_unsupported_helper_expr('with')
    unless defined($block_expr) && length($block_expr);
   return 'do { my $__ls_with_value = '.$value_expr.'; my $value = $__ls_with_value; '.$block_expr.' }'
  }

  my $record_expr;
  if ($block_kind eq 'codeblock_literal') {
   my $record = $block_node;
   return _actionir_ast_unsupported_helper_expr('with') unless ref($record) eq 'HASH';
   $record_expr = _actionir_ast_plain_data_expr($record);
  } else {
   my $candidate_expr = $lower_ast_value_node->($block_node, { bare_scalar_read => 1 });
   $candidate_expr = $ast_expr_source_node->($block_node)
    unless defined($candidate_expr) && length($candidate_expr);
   return _actionir_ast_unsupported_helper_expr('with')
    unless defined($candidate_expr) && length($candidate_expr);
   $candidate_expr = '+'.$candidate_expr if $candidate_expr =~ /^\s*\{/s;
   $record_expr = 'LinkedSpec::CodeblockRuntime::require_codeblock_value('.$candidate_expr.')';
  }
  my $invoke_args = $block_kind ne 'codeblock_argument' && @$args == 2
   ? '[$__ls_with_value]' : '[]';
  my $bindings = _codeblock_runtime_binding_expr($deps, 'value');
  return 'do { my $__ls_with_value = '.$value_expr.'; my $value = $__ls_with_value; '
   .'require LinkedSpec::CodeblockRuntime; LinkedSpec::CodeblockRuntime::invoke('
   .$record_expr.', '.$invoke_args.', '.$bindings.', "with") }'
 };
 $lower_ast_value_node = sub {
  my ($node, $opts) = @_;
  $opts = {} unless ref($opts) eq 'HASH';
  return undef unless ref($node) eq 'HASH';
  my $kind = $node->{kind} // '';

  if ($kind eq 'number') {
   my $source = $node->{source};
   return $source if defined($source) && $source =~ /\A-?\d+(?:\.\d+)?\z/o;
   return defined($node->{value}) ? (''.$node->{value}) : undef;
  }
  return $ast_string_source_node->($node) if $kind eq 'string';
  return $ast_regex_source_node->($node) if $kind eq 'regex';
  return 'undef' if $kind eq 'undef';
  return $node->{value} ? 'do { require JSON::PP; JSON::PP::true }' : 'do { require JSON::PP; JSON::PP::false }'
   if $kind eq 'boolean';
  if ($kind eq 'raw_perl') {
   my $source = $node->{source};
   if (defined($source) && $source =~ /^\((.*)\)$/s) {
    my $inner = $trim_action_ir_value->($1);
    if (defined($inner) && length($inner) && $inner ne $source) {
     my $inner_node = _parse_method_value_ast_expr($inner, $deps);
     my $inner_expr = $lower_ast_value_node->($inner_node, $opts)
      if ref($inner_node) eq 'HASH';
     return $inner_expr if defined($inner_expr) && length($inner_expr);
    }
   }
   my $bare_scalar_read = _lower_source_slot_bare_scalar_read_expr($node->{source}, $deps);
   return $bare_scalar_read if defined($bare_scalar_read) && length($bare_scalar_read);
   return undef;
  }
  return $node->{source}
   if $kind eq 'variable' && $opts->{variable_source};
  return $opts->{bare_scalar_read} ? _lower_source_slot_bare_scalar_read_expr($node->{name}, $deps) : undef
   if $kind eq 'variable';
	  return _actionir_ast_retired_colon_scalar_slot_expr($node->{name})
	   if $kind eq 'colon_scalar_slot_removed'
	   && defined($node->{name}) && length($node->{name});
  return _actionir_ast_retired_hash_literal_fat_arrow_expr()
   if $kind eq 'hash_literal_fat_arrow_removed';
  return _actionir_ast_plain_data_expr($node)
   if $kind eq 'codeblock_literal';
  return _actionir_ast_unsupported_helper_expr($node->{code})
   if $kind eq 'codeblock_literal_error';
  return $lower_ast_scalar_assignment_value_node->($node)
   if $kind eq 'assign_scalar' || $kind eq 'assign_array_append' || $kind eq 'assign_hash_index' || $kind eq 'assign_nested_access';
  return $lower_ast_direct_access_node->($node)
   if $kind eq 'indexed_var' || $kind eq 'nested_access';
  if ($kind eq 'array_literal') {
   my @lowered_items;
   foreach my $item (@{$node->{items} || []}) {
    my $lowered_item = $lower_ast_value_node->($item, { bare_scalar_read => 1 });
    $lowered_item = $legacy_method_value_expr->($item->{source})
     unless defined($lowered_item) && length($lowered_item);
    return undef unless defined($lowered_item) && length($lowered_item);
    push @lowered_items, $lowered_item;
   }
   return '['.join(', ', @lowered_items).']';
  }
  if ($kind eq 'hash_literal') {
   my @lowered_pairs;
   foreach my $entry (@{$node->{entries} || []}) {
    my $key_expr = $lower_ast_value_node->($entry->{key}, { bare_scalar_read => 1 });
    $key_expr = $legacy_method_value_expr->($entry->{key}{source})
     unless defined($key_expr) && length($key_expr);
    my $value_expr = $lower_ast_value_node->($entry->{value}, { bare_scalar_read => 1 });
    $value_expr = $legacy_method_value_expr->($entry->{value}{source})
     unless defined($value_expr) && length($value_expr);
    return undef unless defined($key_expr) && length($key_expr);
    return undef unless defined($value_expr) && length($value_expr);
    push @lowered_pairs, $key_expr.' => '.$value_expr;
   }
   return '{'.join(', ', @lowered_pairs).'}';
  }
  return $lower_ast_block_value_node->($node)
   if $kind eq 'block_value';
  return $lower_ast_fluent_chain_node->($node)
   if $kind eq 'fluent_chain';
  if ($kind eq 'call') {
   my $normalized = _normalize_contextual_codeblock_call_node($deps, 'helper', $node, $node->{name});
   return _actionir_ast_unsupported_helper_expr($node->{name}) if defined($normalized->{error});
   $node = $normalized->{node};
   my $with_call = $lower_ast_with_trailing_block_call_node->($node);
   return $with_call if defined($with_call) && length($with_call);
   my $scalar_assignment = $lower_ast_scalar_assignment_value_node->($node);
   return $scalar_assignment if defined($scalar_assignment) && length($scalar_assignment);
   my $user_function_call = $lower_ast_user_function_call_node->($node);
   return $user_function_call if defined($user_function_call) && length($user_function_call);
   my $lowered_call = $lower_ast_value_only_call_node->($node, $opts);
   return $lowered_call if defined($lowered_call) && length($lowered_call);
   $lowered_call = $lower_ast_aggregate_call_node->($node);
   return $lowered_call if defined($lowered_call) && length($lowered_call);
   my $codeblock_call = $lower_ast_codeblock_variable_call_node->($node);
   return $codeblock_call if defined($codeblock_call) && length($codeblock_call);
   my $unsupported_call = $unsupported_ast_helper_expr->($node->{name});
   return $unsupported_call if defined($unsupported_call) && length($unsupported_call);
   my $legacy_call = $legacy_method_value_expr->($node->{source});
   return $legacy_call
    if defined($legacy_call) && length($legacy_call) && $legacy_call ne ($node->{source} // '');
	  return _actionir_ast_unsupported_helper_expr($node->{name})
	   unless defined(_actionir_ast_known_value_call_method($node->{name}));
   return undef;
  }
  return undef
 };
	$lower_ast_value_only_call_node = sub {
	 my ($node, $opts) = @_;
	 $opts = {} unless ref($opts) eq 'HASH';
	 return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'call';
	 my $args = $node->{args} || [];
  return undef unless ref($args) eq 'ARRAY';
  my $method = $ast_value_only_call_method->($node->{name}, scalar(@$args));
  return undef unless defined($method) && length($method);

  my @lowered_args;
  foreach my $arg (@$args) {
   my $lowered_arg;
   if (ref($arg) eq 'HASH' && ($arg->{kind} // '') eq 'call') {
    $lowered_arg = $lower_ast_scalar_assignment_value_node->($arg);
    $lowered_arg = $lower_ast_value_node->($arg, { bare_scalar_read => 1 })
     if !(defined($lowered_arg) && length($lowered_arg)) && $arg->{trailing_block_arg};
    $lowered_arg = $lower_ast_value_only_call_node->($arg, $opts)
     unless defined($lowered_arg) && length($lowered_arg);
    $lowered_arg = $ast_expr_source_node->($arg)
     unless defined($lowered_arg) && length($lowered_arg);
    $lowered_arg = $arg->{source} unless defined($lowered_arg) && length($lowered_arg);
   } else {
    if (ref($arg) eq 'HASH'
     && ($arg->{kind} // '') eq 'variable'
     && _user_function_scalar_value_name($deps, $arg->{name})) {
     $lowered_arg = _lower_source_slot_bare_scalar_read_expr($arg->{name}, $deps);
    } else {
     my $arg_opts = $opts->{bare_scalar_read} ? { bare_scalar_read => 1 } : { variable_source => 1 };
     $lowered_arg = $lower_ast_value_node->($arg, $arg_opts);
    }
    $lowered_arg = $ast_expr_source_node->($arg)
     unless defined($lowered_arg) && length($lowered_arg);
    $lowered_arg = $arg->{source} unless defined($lowered_arg) && length($lowered_arg);
   }
   return undef unless defined($lowered_arg) && length($lowered_arg);
   push @lowered_args, $lowered_arg;
  }

	 return 'defined('.$lowered_args[0].')'
	  if $method eq 'is_defined';
	 return '(!defined('.$lowered_args[0].'))'
	  if $method eq 'is_undefined';
	 return $legacy_method_value_expr->($method.'('.join(', ', @lowered_args).')')
	};
	$lower_ast_aggregate_call_node = sub {
	 my ($node) = @_;
	 return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'call';
	 my $args = $node->{args} || [];
  return undef unless ref($args) eq 'ARRAY';
  my $method = $ast_aggregate_call_method->($node->{name}, scalar(@$args));
  return undef unless defined($method) && length($method);

  if ($method eq 'copy' && @$args == 1 && ref($args->[0]) eq 'HASH'
   && ($args->[0]{kind} // '') eq 'call') {
   my $container = $args->[0];
   my $container_args = $container->{args} || [];
   if (ref($container_args) eq 'ARRAY'
    && @$container_args == 1
    && ref($container_args->[0]) eq 'HASH'
    && ($container_args->[0]{kind} // '') eq 'variable'
    && (($bare_symbol_kind->($container_args->[0]{name}) // '') eq 'scalar')) {
    return $lower_scalar_bound_array_snapshot_expr->($container_args->[0]{name})
     if ($container->{name} // '') eq 'array';
    return $lower_scalar_bound_hash_snapshot_expr->($container_args->[0]{name})
     if ($container->{name} // '') eq 'hash';
   }
  }

  my @arg_exprs;
  my @internal_array_pipeline_arg_exprs;
  foreach my $arg (@$args) {
   my $arg_expr = $lower_ast_scalar_assignment_value_node->($arg);
   my $internal_array_pipeline_arg_expr;
   if (!(defined($arg_expr) && length($arg_expr))
       && ref($arg) eq 'HASH'
       && ($arg->{kind} // '') eq 'variable'
       && _user_function_scalar_value_name($deps, $arg->{name})) {
    # Aggregate helpers own the runtime typed-value interpretation of a bare
    # binding. Preserve its spec-level name here instead of exposing the Perl
    # scalar spelling to the compatibility lowerer.
    $arg_expr = $arg->{name};
   }
   if (!(defined($arg_expr) && length($arg_expr))
       && ref($arg) eq 'HASH'
       && ($arg->{kind} // '') eq 'call'
       && defined($arg->{name})
       && $arg->{name} =~ /^__array_value_/o) {
    my @pipeline_args;
    foreach my $pipeline_arg (@{$arg->{args} || []}) {
     my $pipeline_arg_expr = $ast_expr_source_node->($pipeline_arg);
     $pipeline_arg_expr = $pipeline_arg->{source}
      if ref($pipeline_arg) eq 'HASH' && !(defined($pipeline_arg_expr) && length($pipeline_arg_expr));
     return undef unless defined($pipeline_arg_expr) && length($pipeline_arg_expr);
     push @pipeline_args, $pipeline_arg_expr;
    }
    $internal_array_pipeline_arg_expr = $lower_array_pipeline_value_expr->({
     method => $arg->{name},
     args => \@pipeline_args,
    });
   }
   if (!(defined($arg_expr) && length($arg_expr)) && $method eq 'array' && @$args != 1) {
    $arg_expr = $lower_ast_value_node->($arg, { bare_scalar_read => 1 })
     if ref($arg) eq 'HASH';
   }
   $arg_expr = $ast_expr_source_node->($arg)
    unless defined($arg_expr) && length($arg_expr);
   $arg_expr = $arg->{source} unless defined($arg_expr) && length($arg_expr);
   return undef unless defined($arg_expr) && length($arg_expr);
   push @arg_exprs, $arg_expr;
   push @internal_array_pipeline_arg_exprs, $internal_array_pipeline_arg_expr;
  }

  if (@arg_exprs == 1 && $method =~ /^(?:num_sum|num_avg|num_median|num_range|num_min|num_max)$/o) {
   my $pipeline_target = $internal_array_pipeline_arg_exprs[0];
   $pipeline_target = $lower_internal_array_pipeline_target_expr->($arg_exprs[0])
    unless defined($pipeline_target) && length($pipeline_target);
   my $pipeline_reducer = $lower_numeric_array_reducer_source_expr->($method, $pipeline_target);
   return $pipeline_reducer if defined($pipeline_reducer) && length($pipeline_reducer);
  }

  if (@$args == 1
   && ref($args->[0]) eq 'HASH'
   && ($args->[0]{kind} // '') eq 'variable'
   && (($bare_symbol_kind->($args->[0]{name}) // '') eq 'scalar')) {
   return $lower_scalar_bound_array_snapshot_expr->($args->[0]{name}) if $method eq 'array';
   return $lower_scalar_bound_hash_snapshot_expr->($args->[0]{name}) if $method eq 'hash';
  }

  return '['.join(', ', @arg_exprs).']'
   if $method eq 'array' && @arg_exprs != 1;

  return $legacy_method_value_expr->($method.'('.join(', ', @arg_exprs).')')
 };
 $lower_ast_fluent_chain_node = sub {
  my ($node) = @_;
  return undef unless ref($node) eq 'HASH' && ($node->{kind} // '') eq 'fluent_chain';
  my $receiver = $node->{receiver};
  my $calls = $node->{calls} || [];
  return undef unless ref($receiver) eq 'HASH' && ref($calls) eq 'ARRAY' && @$calls;
  my @normalized_calls;
  foreach my $call (@$calls) {
   return undef unless ref($call) eq 'HASH';
   my $method = $call->{method} // '';
   my $normalized = _normalize_contextual_codeblock_call_node($deps, 'receiver', $call, $method);
   return _actionir_ast_unsupported_helper_expr($method) if defined($normalized->{error});
   push @normalized_calls, $normalized->{node};
  }
  $calls = \@normalized_calls;

  my $receiver_expr;
  $receiver_expr = $lower_ast_value_node->($receiver, { bare_scalar_read => 1 })
   if ($receiver->{kind} // '') eq 'call' && $receiver->{trailing_block_arg};
  $receiver_expr = $lower_ast_scalar_assignment_value_node->($receiver)
   if ($receiver->{kind} // '') eq 'call'
   && (($receiver->{name} // '') eq 'set' || ($receiver->{name} // '') eq '=');
  if (($receiver->{kind} // '') eq 'raw_perl') {
   my $leading = _split_leading_call_suffix($receiver->{source});
   if (ref($leading) eq 'HASH') {
    my $call_node = _parse_method_value_ast_expr($leading->{call_source}, $deps);
    my $call_expr = $lower_ast_codeblock_variable_call_node->($call_node)
     if ref($call_node) eq 'HASH';
    if (defined($call_expr) && length($call_expr)) {
     my $suffix = $leading->{suffix};
     if (defined($suffix) && $suffix =~ /\A\s*\[/s) {
      my @segments;
      pos($suffix) = 0;
      while ($suffix =~ /\G\s*\[\s*([^\[\]]+?)\s*\]/gc) {
       my $segment_node = _parse_method_value_ast_expr($1, $deps);
       my $segment_expr = $lower_ast_value_node->($segment_node, { bare_scalar_read => 1 })
        if ref($segment_node) eq 'HASH';
       $segment_expr = $ast_expr_source_node->($segment_node)
        if ref($segment_node) eq 'HASH' && !(defined($segment_expr) && length($segment_expr));
       @segments = () unless defined($segment_expr) && length($segment_expr);
       last unless defined($segment_expr) && length($segment_expr);
       push @segments, $segment_expr;
      }
      if (@segments && defined(pos($suffix)) && pos($suffix) == length($suffix)) {
       $receiver_expr = 'do { require LinkedSpec::CodeblockRuntime; '
        .'LinkedSpec::CodeblockRuntime::read_path('.$call_expr.', ['.join(', ', @segments).']) }';
      }
     } else {
      $receiver_expr = '('.$call_expr.')'.($suffix // '');
     }
    }
   }
  }
  $receiver_expr = $ast_expr_source_node->($receiver)
   unless defined($receiver_expr) && length($receiver_expr);
  $receiver_expr = $receiver->{source} unless defined($receiver_expr) && length($receiver_expr);
  return undef unless defined($receiver_expr) && length($receiver_expr);
  if (($receiver->{kind} // '') eq 'raw_perl' && $receiver_expr =~ /^\((.*)\)$/s) {
   my $inner = $1;
   my $inner_node = _parse_method_value_ast_expr($inner, $deps);
   my $inner_expr = $lower_ast_value_node->($inner_node, { bare_scalar_read => 1 })
    if ref($inner_node) eq 'HASH';
   $receiver_expr = $inner_expr if defined($inner_expr) && length($inner_expr);
  }

  if (grep { ref($_) eq 'HASH' && $_->{receiver_trailing_block_arg} && !_is_tree_traversal_receiver_method($_->{method} // '') } @$calls) {
   _trace_method_decision(
    phase => 'lower_ast_fluent_chain_node',
    label => 'fluent_chain',
    decision => 'ast_receiver_with_trailing_block_chain',
    taken => 1,
    context => { steps => scalar(@$calls) },
   );

   my $synthetic_expr = $receiver_expr;
   foreach my $call (@$calls) {
    return undef unless ref($call) eq 'HASH';
    my $method = $call->{method} // '';
    if ($call->{receiver_trailing_block_arg}) {
     my $args = $call->{args} || [];
     return _actionir_ast_unsupported_helper_expr('with')
      unless ref($args) eq 'ARRAY' && @$args == 1;
     my $block_node = $args->[0];
     return _actionir_ast_unsupported_helper_expr('with') unless ref($block_node) eq 'HASH';
     my $block_kind = $block_node->{kind} // '';
     my $block_source = $block_node->{source_text};
     $block_source = $block_node->{source}
      unless defined($block_source) && length($block_source);
     return _actionir_ast_unsupported_helper_expr('with')
      unless defined($block_source) && length($block_source);
     $synthetic_expr = $block_kind eq 'codeblock_argument'
      ? 'with('.$synthetic_expr.') '.$block_source
      : 'with('.$synthetic_expr.', '.$block_source.')';
     next;
    }
    my $source = $call->{source};
    return undef unless defined($source) && length($source);
    $synthetic_expr .= '.'.$source;
   }

   my $lowered = _lower_method_value_expr($synthetic_expr, $deps);
   return $lowered if defined($lowered) && length($lowered);
   return $legacy_method_value_expr->($synthetic_expr)
  }

  my $receiver_is_with_trailing_block = (($receiver->{kind} // '') eq 'call'
   && ($receiver->{name} // '') eq 'with'
   && $receiver->{trailing_block_arg}) ? 1 : 0;
  unless ($receiver_is_with_trailing_block) {
   my $unknown = _actionir_ast_first_unknown_value_call_name($node, $deps);
   my $unknown_expr = _actionir_ast_unsupported_helper_expr($unknown);
   return $unknown_expr if defined($unknown_expr) && length($unknown_expr);
  }

  my $chain_arg_exprs = sub {
   my ($args) = @_;
   return undef unless ref($args) eq 'ARRAY';
   my @arg_exprs;
   foreach my $arg (@$args) {
    my $arg_expr = $lower_ast_scalar_assignment_value_node->($arg);
    $arg_expr = $ast_expr_source_node->($arg)
     unless defined($arg_expr) && length($arg_expr);
    $arg_expr = $arg->{source}
     if ref($arg) eq 'HASH' && !(defined($arg_expr) && length($arg_expr));
    return undef unless defined($arg_expr) && length($arg_expr);
    push @arg_exprs, $arg_expr;
   }
   return \@arg_exprs
  };

	  my $array_chain_return_family = sub {
	   my ($method) = @_;
	   return 'array' if defined($method)
	    && $method =~ /^(?:copy|sorted|reversed|take|take_last|drop_front|drop_back|slice|concat_arrays|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)$/o;
   return 'terminal'
  };

  my $append_array_chain_call = sub {
   my ($current_expr, $call) = @_;
   my $method = $call->{method} // '';
   return undef if $method =~ /^(?:push_front|push_back|pop_front|pop_back)$/o;
   return undef unless _is_array_receiver_value_chain_method($method);
   my $arg_exprs = $chain_arg_exprs->($call->{args} || []);
   return undef unless ref($arg_exprs) eq 'ARRAY';

   if ($method eq 'join_values') {
    return undef unless @$arg_exprs == 1;
    return ['join_values('.$arg_exprs->[0].', '.$current_expr.')', 'terminal'];
   }
   if ($method =~ /^(?:sum|avg|median|range|min|max)$/o) {
    return undef unless @$arg_exprs == 0;
    return [$method.'('.$current_expr.')', 'terminal'];
   }
   if (($method eq 'sorted' || $method eq 'reversed') && $current_expr =~ /^do\s*\{/s) {
    return undef unless @$arg_exprs == 0;
    return [
     'do { require LinkedSpec::BindingRuntime; LinkedSpec::BindingRuntime::array_transform('
      .$current_expr.', "<receiver>", "'.$method.'") }',
     'array',
    ];
   }
   if ($method =~ /^(?:split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)$/o) {
    return ['__array_value_'.$method.'('.join(', ', ($current_expr, @$arg_exprs)).')', 'array'];
   }
   return [
    $method.'('.join(', ', ($current_expr, @$arg_exprs)).')',
    $array_chain_return_family->($method),
   ]
  };
  my $lower_synthetic_chain_expr = sub {
   my ($current_expr) = @_;
   my $lowered = _lower_method_value_expr($current_expr, $deps);
   return $lowered if defined($lowered) && length($lowered);
   return $legacy_method_value_expr->($current_expr)
  };
  my $copy_starts_hash_receiver_chain = sub {
   my ($candidate_receiver, $candidate_calls) = @_;
   my $receiver_trimmed = $trim_action_ir_value->($candidate_receiver);
   return 0 unless defined($receiver_trimmed) && length($receiver_trimmed);
   return 1 if $receiver_trimmed =~ /^hash\s*\(/o;
   return 0 if $receiver_trimmed =~ /^array\s*\(/o;
   my $remembered_kind = $remembered_bare_symbol_kind->($receiver_trimmed);
   return 1 if defined($remembered_kind) && $remembered_kind eq 'hash';
   return 0 if defined($remembered_kind) && $remembered_kind eq 'array';
   if (ref($candidate_calls) eq 'ARRAY' && @$candidate_calls > 1) {
    my $next_method = $candidate_calls->[1]{method} // '';
    return 1 if defined(_hash_receiver_value_chain_return_family($next_method));
    return 0 if _is_array_receiver_value_chain_method($next_method);
   }
   return 0
  };
  my $tree_receiver_target_expr = sub {
   my ($candidate_expr, $candidate_calls, $call_idx) = @_;
   my $candidate_trimmed = $trim_action_ir_value->($candidate_expr);
   return $candidate_expr unless defined($candidate_trimmed) && length($candidate_trimmed);
   return $candidate_expr unless $candidate_trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o;
   my $name = $1;
   my $remembered_kind = $remembered_bare_symbol_kind->($candidate_trimmed);
   return 'array('.$name.')' if defined($remembered_kind) && $remembered_kind eq 'array';
   return 'hash('.$name.')' if defined($remembered_kind) && $remembered_kind eq 'hash';
   return $candidate_expr if defined($remembered_kind) && $remembered_kind eq 'scalar';
   my $next_method = (ref($candidate_calls) eq 'ARRAY' && defined($call_idx) && $call_idx + 1 < @$candidate_calls)
    ? ($candidate_calls->[$call_idx + 1]{method} // '')
    : '';
   return 'array('.$name.')' if _is_array_receiver_value_chain_method($next_method);
   return 'hash('.$name.')' if defined(_hash_receiver_value_chain_return_family($next_method));
   return 'hash('.$name.')'
  };

  my $tree_receiver_return_family = sub {
   my ($method, $target_expr, $candidate_calls, $call_idx) = @_;
   return 'terminal' if ($method // '') eq 'reduce_leaves';
   my $next_method = (ref($candidate_calls) eq 'ARRAY' && defined($call_idx) && $call_idx + 1 < @$candidate_calls)
    ? ($candidate_calls->[$call_idx + 1]{method} // '')
    : '';
   if (_is_tree_traversal_receiver_method($next_method)) {
    my $after_next_method = ($call_idx + 2 < @$candidate_calls) ? ($candidate_calls->[$call_idx + 2]{method} // '') : '';
    return 'array' if _is_array_receiver_value_chain_method($after_next_method);
    return 'hash' if defined(_hash_receiver_value_chain_return_family($after_next_method));
   }
   return 'array' if _is_array_receiver_value_chain_method($next_method);
   return 'hash' if defined(_hash_receiver_value_chain_return_family($next_method));
   return 'array' if $looks_like_array_value_expr->($target_expr);
   return 'hash' if $looks_like_hash_value_expr->($target_expr);
   return 'hash'
  };

  my $lower_tree_receiver_block_call = sub {
   my ($method, $target_expr, $call, $return_family) = @_;
   return undef unless _is_tree_traversal_receiver_method($method);
   my $unsupported = sub {
    return [_actionir_ast_unsupported_helper_expr($method), 'terminal']
   };
   return $unsupported->() unless ref($call) eq 'HASH' && $call->{receiver_trailing_block_arg};
   my $args = $call->{args} || [];
   return $unsupported->() unless ref($args) eq 'ARRAY';
   my $expected_argc = $method eq 'reduce_leaves' ? 2 : 1;
   return $unsupported->() unless @$args == $expected_argc;
   my $block_node = $args->[-1];
   if (ref($block_node) eq 'HASH' && ($block_node->{kind} // '') eq 'codeblock_argument') {
    $block_node = {
     kind => 'block_value',
     block => $block_node->{body_ast},
     source => $block_node->{source_text},
     source_span => $block_node->{source_span},
    };
   }
   return $unsupported->()
    unless ref($block_node) eq 'HASH' && ($block_node->{kind} // '') eq 'block_value';
   my $block_expr = $lower_ast_block_value_node->($block_node);
   return $unsupported->() unless defined($block_expr) && length($block_expr);

   my $lowered_target = _lower_method_value_expr($target_expr, $deps);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
   return undef unless defined($lowered_target) && length($lowered_target);

   $return_family = 'terminal' if $method eq 'reduce_leaves';
   $return_family = 'hash' unless defined($return_family) && length($return_family);

   my $hash_leaf_bindings = 'my $value = $__ls_hash_tree_leaf_value; my @value = (defined($value) && ref($value) eq \'ARRAY\') ? @{$value} : (); my %value = (defined($value) && ref($value) eq \'HASH\') ? %{$value} : (); my $key = $__ls_hash_tree_leaf_key; my $path = [@{$__ls_hash_tree_leaf_path}]; my @path = @{$path}; my $depth = scalar(@{$__ls_hash_tree_leaf_path}); ';
   my $hash_leaf_block = 'do { '.$hash_leaf_bindings.$block_expr.' }';
   my $array_leaf_bindings = 'my $value = $__ls_array_tree_leaf_value; my @value = (defined($value) && ref($value) eq \'ARRAY\') ? @{$value} : (); my %value = (defined($value) && ref($value) eq \'HASH\') ? %{$value} : (); my $index = $__ls_array_tree_leaf_index; my $path = [@{$__ls_array_tree_leaf_path}]; my @path = @{$path}; my $depth = scalar(@{$__ls_array_tree_leaf_path}); ';
   my $array_leaf_block = 'do { '.$array_leaf_bindings.$block_expr.' }';
   if ($method eq 'walk_leaves') {
    my $hash_expr = 'do { my $__ls_hash_tree_source = $__ls_tree_source; my $__ls_hash_tree_walk; $__ls_hash_tree_walk = sub { my ($__ls_hash_tree_node, $__ls_hash_tree_path) = @_; foreach my $__ls_hash_tree_leaf_key (sort keys %{$__ls_hash_tree_node}) { my $__ls_hash_tree_leaf_value = $__ls_hash_tree_node->{$__ls_hash_tree_leaf_key}; my @__ls_hash_tree_next_path = (@{$__ls_hash_tree_path}, $__ls_hash_tree_leaf_key); if (defined($__ls_hash_tree_leaf_value) && ref($__ls_hash_tree_leaf_value) eq \'HASH\') { $__ls_hash_tree_walk->($__ls_hash_tree_leaf_value, \@__ls_hash_tree_next_path); } else { my $__ls_hash_tree_leaf_path = \@__ls_hash_tree_next_path; my $__ls_hash_tree_ignored = '.$hash_leaf_block.'; } } return undef }; $__ls_hash_tree_walk->($__ls_hash_tree_source, []); $__ls_hash_tree_source }';
    my $array_expr = 'do { my $__ls_array_tree_source = $__ls_tree_source; my $__ls_array_tree_walk; $__ls_array_tree_walk = sub { my ($__ls_array_tree_node, $__ls_array_tree_path) = @_; for (my $__ls_array_tree_leaf_index = 0; $__ls_array_tree_leaf_index < @{$__ls_array_tree_node}; ++$__ls_array_tree_leaf_index) { my $__ls_array_tree_leaf_value = $__ls_array_tree_node->[$__ls_array_tree_leaf_index]; my @__ls_array_tree_next_path = (@{$__ls_array_tree_path}, $__ls_array_tree_leaf_index); if (defined($__ls_array_tree_leaf_value) && ref($__ls_array_tree_leaf_value) eq \'ARRAY\') { $__ls_array_tree_walk->($__ls_array_tree_leaf_value, \@__ls_array_tree_next_path); } else { my $__ls_array_tree_leaf_path = \@__ls_array_tree_next_path; my $__ls_array_tree_ignored = '.$array_leaf_block.'; } } return undef }; $__ls_array_tree_walk->($__ls_array_tree_source, []); $__ls_array_tree_source }';
    my $expr = 'do { my $__ls_tree_source = '.$lowered_target.'; if (defined($__ls_tree_source) && ref($__ls_tree_source) eq \'HASH\') { '.$hash_expr.' } elsif (defined($__ls_tree_source) && ref($__ls_tree_source) eq \'ARRAY\') { '.$array_expr.' } else { undef } }';
    return [$expr, $return_family];
   }
   if ($method eq 'map_leaves') {
    my $hash_expr = 'do { my $__ls_hash_tree_source = $__ls_tree_source; my $__ls_hash_tree_map; $__ls_hash_tree_map = sub { my ($__ls_hash_tree_node, $__ls_hash_tree_path) = @_; my %__ls_hash_tree_out; foreach my $__ls_hash_tree_leaf_key (sort keys %{$__ls_hash_tree_node}) { my $__ls_hash_tree_leaf_value = $__ls_hash_tree_node->{$__ls_hash_tree_leaf_key}; my @__ls_hash_tree_next_path = (@{$__ls_hash_tree_path}, $__ls_hash_tree_leaf_key); if (defined($__ls_hash_tree_leaf_value) && ref($__ls_hash_tree_leaf_value) eq \'HASH\') { $__ls_hash_tree_out{$__ls_hash_tree_leaf_key} = $__ls_hash_tree_map->($__ls_hash_tree_leaf_value, \@__ls_hash_tree_next_path); } else { my $__ls_hash_tree_leaf_path = \@__ls_hash_tree_next_path; $__ls_hash_tree_out{$__ls_hash_tree_leaf_key} = '.$hash_leaf_block.'; } } return \%__ls_hash_tree_out }; $__ls_hash_tree_map->($__ls_hash_tree_source, []) }';
    my $array_expr = 'do { my $__ls_array_tree_source = $__ls_tree_source; my $__ls_array_tree_map; $__ls_array_tree_map = sub { my ($__ls_array_tree_node, $__ls_array_tree_path) = @_; my @__ls_array_tree_out; for (my $__ls_array_tree_leaf_index = 0; $__ls_array_tree_leaf_index < @{$__ls_array_tree_node}; ++$__ls_array_tree_leaf_index) { my $__ls_array_tree_leaf_value = $__ls_array_tree_node->[$__ls_array_tree_leaf_index]; my @__ls_array_tree_next_path = (@{$__ls_array_tree_path}, $__ls_array_tree_leaf_index); if (defined($__ls_array_tree_leaf_value) && ref($__ls_array_tree_leaf_value) eq \'ARRAY\') { push @__ls_array_tree_out, $__ls_array_tree_map->($__ls_array_tree_leaf_value, \@__ls_array_tree_next_path); } else { my $__ls_array_tree_leaf_path = \@__ls_array_tree_next_path; push @__ls_array_tree_out, '.$array_leaf_block.'; } } return \@__ls_array_tree_out }; $__ls_array_tree_map->($__ls_array_tree_source, []) }';
    my $expr = 'do { my $__ls_tree_source = '.$lowered_target.'; if (defined($__ls_tree_source) && ref($__ls_tree_source) eq \'HASH\') { '.$hash_expr.' } elsif (defined($__ls_tree_source) && ref($__ls_tree_source) eq \'ARRAY\') { '.$array_expr.' } else { undef } }';
    return [$expr, $return_family];
   }
   if ($method eq 'reduce_leaves') {
    my $initial_expr = $lower_ast_value_node->($args->[0], { bare_scalar_read => 1 });
    $initial_expr = $legacy_method_value_expr->($args->[0]{source})
     unless defined($initial_expr) && length($initial_expr);
    $initial_expr = $args->[0]{source}
     if !(defined($initial_expr) && length($initial_expr)) && defined($args->[0]{source});
    return $unsupported->() unless defined($initial_expr) && length($initial_expr);
    $initial_expr = '+'.$initial_expr if $initial_expr =~ /^\s*\{/s;
    my $hash_reduce_block = 'do { my $acc = $__ls_hash_tree_acc; my @acc = (defined($acc) && ref($acc) eq \'ARRAY\') ? @{$acc} : (); my %acc = (defined($acc) && ref($acc) eq \'HASH\') ? %{$acc} : (); '.$hash_leaf_bindings.$block_expr.' }';
    my $array_reduce_block = 'do { my $acc = $__ls_array_tree_acc; my @acc = (defined($acc) && ref($acc) eq \'ARRAY\') ? @{$acc} : (); my %acc = (defined($acc) && ref($acc) eq \'HASH\') ? %{$acc} : (); '.$array_leaf_bindings.$block_expr.' }';
    my $hash_expr = 'do { my $__ls_hash_tree_source = $__ls_tree_source; my $__ls_hash_tree_acc = '.$initial_expr.'; my $__ls_hash_tree_reduce; $__ls_hash_tree_reduce = sub { my ($__ls_hash_tree_node, $__ls_hash_tree_path) = @_; foreach my $__ls_hash_tree_leaf_key (sort keys %{$__ls_hash_tree_node}) { my $__ls_hash_tree_leaf_value = $__ls_hash_tree_node->{$__ls_hash_tree_leaf_key}; my @__ls_hash_tree_next_path = (@{$__ls_hash_tree_path}, $__ls_hash_tree_leaf_key); if (defined($__ls_hash_tree_leaf_value) && ref($__ls_hash_tree_leaf_value) eq \'HASH\') { $__ls_hash_tree_reduce->($__ls_hash_tree_leaf_value, \@__ls_hash_tree_next_path); } else { my $__ls_hash_tree_leaf_path = \@__ls_hash_tree_next_path; $__ls_hash_tree_acc = '.$hash_reduce_block.'; } } return undef }; $__ls_hash_tree_reduce->($__ls_hash_tree_source, []); $__ls_hash_tree_acc }';
    my $array_expr = 'do { my $__ls_array_tree_source = $__ls_tree_source; my $__ls_array_tree_acc = '.$initial_expr.'; my $__ls_array_tree_reduce; $__ls_array_tree_reduce = sub { my ($__ls_array_tree_node, $__ls_array_tree_path) = @_; for (my $__ls_array_tree_leaf_index = 0; $__ls_array_tree_leaf_index < @{$__ls_array_tree_node}; ++$__ls_array_tree_leaf_index) { my $__ls_array_tree_leaf_value = $__ls_array_tree_node->[$__ls_array_tree_leaf_index]; my @__ls_array_tree_next_path = (@{$__ls_array_tree_path}, $__ls_array_tree_leaf_index); if (defined($__ls_array_tree_leaf_value) && ref($__ls_array_tree_leaf_value) eq \'ARRAY\') { $__ls_array_tree_reduce->($__ls_array_tree_leaf_value, \@__ls_array_tree_next_path); } else { my $__ls_array_tree_leaf_path = \@__ls_array_tree_next_path; $__ls_array_tree_acc = '.$array_reduce_block.'; } } return undef }; $__ls_array_tree_reduce->($__ls_array_tree_source, []); $__ls_array_tree_acc }';
    my $expr = 'do { my $__ls_tree_source = '.$lowered_target.'; if (defined($__ls_tree_source) && ref($__ls_tree_source) eq \'HASH\') { '.$hash_expr.' } elsif (defined($__ls_tree_source) && ref($__ls_tree_source) eq \'ARRAY\') { '.$array_expr.' } else { undef } }';
    return [$expr, 'terminal'];
   }
   return undef
  };

  my $first_method = $calls->[0]{method} // '';
  if (_is_tree_traversal_receiver_method($first_method)) {
   _trace_method_decision(
    phase => 'lower_ast_fluent_chain_node',
    label => 'fluent_chain',
    decision => 'ast_tree_receiver_block_chain',
    taken => 1,
    context => { first_method => $first_method, steps => scalar(@$calls) },
   );
   my $current_expr = $tree_receiver_target_expr->($receiver_expr, $calls, 0);
   my $current_family = $tree_receiver_return_family->($first_method, $current_expr, $calls, 0);
   for (my $idx = 0; $idx < @$calls; ++$idx) {
    my $call = $calls->[$idx];
    my $method = $call->{method} // '';
    my $is_last = ($idx == $#$calls) ? 1 : 0;
    return 'undef' if $current_family eq 'terminal' && !$is_last;

    if (_is_tree_traversal_receiver_method($method)) {
     my $return_family = $tree_receiver_return_family->($method, $current_expr, $calls, $idx);
     my $applied = $lower_tree_receiver_block_call->($method, $current_expr, $call, $return_family);
     return undef unless ref($applied) eq 'ARRAY';
     ($current_expr, $current_family) = @$applied;
     next;
    }

    my $arg_exprs = $chain_arg_exprs->($call->{args} || []);
    return undef unless ref($arg_exprs) eq 'ARRAY';
    if ($current_family eq 'hash') {
     my $return_family = _hash_receiver_value_chain_return_family($method);
     return undef unless defined($return_family);
	     if ($method eq 'copy') {
      return undef unless @$arg_exprs == 0;
      $current_expr = 'copy('.$current_expr.')';
     } elsif ($method eq 'flat_hash') {
      return undef unless @$arg_exprs == 0;
      $current_expr = 'copy('.$current_expr.')';
     } else {
      $current_expr = $method.'('.join(', ', ($current_expr, @$arg_exprs)).')';
     }
     return undef if $return_family eq 'terminal' && !$is_last;
     $current_family = $return_family;
     next;
    }
    if ($current_family eq 'array') {
     my $applied = $append_array_chain_call->($current_expr, $call);
     return undef unless ref($applied) eq 'ARRAY';
     ($current_expr, $current_family) = @$applied;
     return 'undef' if $current_family eq 'terminal' && !$is_last;
     next;
    }
    return undef;
   }
   return $lower_synthetic_chain_expr->($current_expr)
  }

  if (_is_hash_receiver_value_chain_method($first_method)
   && ($first_method ne 'copy' || $copy_starts_hash_receiver_chain->($receiver_expr, $calls))) {
   _trace_method_decision(
    phase => 'lower_ast_fluent_chain_node',
    label => 'fluent_chain',
    decision => 'ast_hash_receiver_chain',
    taken => 1,
    context => { first_method => $first_method, steps => scalar(@$calls) },
   );
   my $current_expr = $receiver_expr;
   if (($receiver->{kind} // '') eq 'variable'
    && $current_expr =~ /^[A-Za-z_][A-Za-z0-9_]*$/o) {
    my $receiver_kind = $remembered_bare_symbol_kind->($current_expr);
    $current_expr = 'hash('.$current_expr.')'
     unless _is_tree_traversal_receiver_method($first_method) && (($receiver_kind // '') eq 'scalar');
   }
   my $current_family = 'hash';
   for (my $idx = 0; $idx < @$calls; ++$idx) {
    my $call = $calls->[$idx];
    my $method = $call->{method} // '';
    my $arg_exprs = $chain_arg_exprs->($call->{args} || []);
    return undef unless ref($arg_exprs) eq 'ARRAY';
    my $is_last = ($idx == $#$calls) ? 1 : 0;

    if ($current_family eq 'hash') {
     my $return_family = _hash_receiver_value_chain_return_family($method);
     return undef unless defined($return_family);

     if (_is_tree_traversal_receiver_method($method)) {
      my $tree_return_family = $tree_receiver_return_family->($method, $current_expr, $calls, $idx);
      my $applied = $lower_tree_receiver_block_call->($method, $current_expr, $call, $tree_return_family);
      return undef unless ref($applied) eq 'ARRAY';
      ($current_expr, $current_family) = @$applied;
	     } elsif ($method eq 'copy') {
      return undef unless @$arg_exprs == 0;
      $current_expr = 'copy('.$current_expr.')';
     } elsif ($method eq 'flat_hash') {
      return undef unless @$arg_exprs == 0;
      $current_expr = 'copy('.$current_expr.')';
     } else {
      $current_expr = $method.'('.join(', ', ($current_expr, @$arg_exprs)).')';
     }

     return undef if $current_family eq 'terminal' && !$is_last;
     $current_family = $return_family unless _is_tree_traversal_receiver_method($method);
     next;
    }

    if ($current_family eq 'array') {
     my $applied = $append_array_chain_call->($current_expr, $call);
     return undef unless ref($applied) eq 'ARRAY';
     ($current_expr, $current_family) = @$applied;
     next;
    }

    return undef;
   }
   return $lower_synthetic_chain_expr->($current_expr)
  }

  if (_is_string_receiver_value_chain_method($first_method)) {
   _trace_method_decision(
    phase => 'lower_ast_fluent_chain_node',
    label => 'fluent_chain',
    decision => 'ast_string_receiver_chain',
    taken => 1,
    context => { first_method => $first_method, steps => scalar(@$calls) },
   );
   my $current_expr = $receiver_expr;
   my $current_family = 'string';
   for (my $idx = 0; $idx < @$calls; ++$idx) {
    my $call = $calls->[$idx];
    my $method = $call->{method} // '';
    my $arg_exprs = $chain_arg_exprs->($call->{args} || []);
    return undef unless ref($arg_exprs) eq 'ARRAY';
    my $is_last = ($idx == $#$calls) ? 1 : 0;

    if ($current_family eq 'string') {
     my $return_family = _string_receiver_value_chain_return_family($method);
     return undef unless defined($return_family);

     if ($method =~ /^(?:trim|lowercase|uppercase|length)$/o) {
      return undef unless @$arg_exprs == 0;
      $current_expr = $method.'('.$current_expr.')';
     } elsif ($method eq 'cat') {
      return undef unless @$arg_exprs >= 1;
      $current_expr = 'cat('.join(', ', ($current_expr, @$arg_exprs)).')';
     } else {
      $current_expr = $method.'('.join(', ', ($current_expr, @$arg_exprs)).')';
     }

     return 'undef' if $return_family eq 'terminal' && !$is_last;
     $current_family = $return_family;
     next;
    }

    if ($current_family eq 'array') {
     my $applied = $append_array_chain_call->($current_expr, $call);
     return undef unless ref($applied) eq 'ARRAY';
     ($current_expr, $current_family) = @$applied;
     next;
    }

    return 'undef' if $current_family eq 'terminal';
    return undef;
   }
   return $lower_synthetic_chain_expr->($current_expr)
  }

  if (_is_number_receiver_value_chain_method($first_method)) {
   _trace_method_decision(
    phase => 'lower_ast_fluent_chain_node',
    label => 'fluent_chain',
    decision => 'ast_number_receiver_chain',
    taken => 1,
    context => { first_method => $first_method, steps => scalar(@$calls) },
   );
	  my $current_expr = $receiver_expr;
   my $current_family = 'number';
   for (my $idx = 0; $idx < @$calls; ++$idx) {
    my $call = $calls->[$idx];
    my $method = $call->{method} // '';
    my $arg_exprs = $chain_arg_exprs->($call->{args} || []);
    return undef unless ref($arg_exprs) eq 'ARRAY';
    my $is_last = ($idx == $#$calls) ? 1 : 0;

    return 'undef' if $current_family eq 'terminal';
    return undef unless $current_family eq 'number';

    my $return_family = _number_receiver_value_chain_return_family($method);
    return undef unless defined($return_family);
    my $helper = _number_receiver_method_helper_name($method);
    return undef unless defined($helper) && length($helper);

    if ($method =~ /^(?:abs|floor|ceil|round)$/o) {
     return undef unless @$arg_exprs == 0;
    } elsif ($method =~ /^(?:sub|div|mod|eq|ne|gt|ge|lt|le)$/o) {
     return undef unless @$arg_exprs == 1;
    } elsif ($method eq 'clamp') {
     return undef unless @$arg_exprs == 2;
    } elsif ($method =~ /^(?:add|mul|min|max)$/o) {
     return undef unless @$arg_exprs >= 1;
    } else {
     return undef;
    }

    $current_expr = $helper.'('.join(', ', ($current_expr, @$arg_exprs)).')';
    return 'undef' if $return_family eq 'terminal' && !$is_last;
    $current_family = $return_family;
   }
   return $lower_synthetic_chain_expr->($current_expr)
  }

  if (_is_array_receiver_value_chain_method($first_method)) {
   _trace_method_decision(
    phase => 'lower_ast_fluent_chain_node',
    label => 'fluent_chain',
    decision => 'ast_array_receiver_chain',
    taken => 1,
   context => { first_method => $first_method, steps => scalar(@$calls) },
  );
  return undef if defined($receiver_expr) && $receiver_expr =~ /^hash\s*\(/o;
  my $current_expr = $receiver_expr;
  $current_expr = 'array('.$current_expr.')'
   if ($receiver->{kind} // '') eq 'variable'
   && $current_expr =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  my $current_family = 'array';
   for (my $idx = 0; $idx < @$calls; ++$idx) {
    return 'undef' if $current_family eq 'terminal';
    my $call = $calls->[$idx];
    my $method = $call->{method} // '';
    if (_is_tree_traversal_receiver_method($method)) {
     my $return_family = $tree_receiver_return_family->($method, $current_expr, $calls, $idx);
     my $applied = $lower_tree_receiver_block_call->($method, $current_expr, $call, $return_family);
     return undef unless ref($applied) eq 'ARRAY';
     ($current_expr, $current_family) = @$applied;
     return 'undef' if $current_family eq 'terminal' && $idx != $#$calls;
     next;
    }
    my $applied = $append_array_chain_call->($current_expr, $call);
    return undef unless ref($applied) eq 'ARRAY';
    ($current_expr, $current_family) = @$applied;
    return 'undef' if $current_family eq 'terminal' && $idx != $#$calls;
   }
   return $lower_synthetic_chain_expr->($current_expr)
  }

  return undef
 };

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 unless (ref($deps) eq 'HASH' && $deps->{__actionir_ast_value_lowering_compat_bridge}) {
  my $ast_node = _parse_method_value_ast_expr($trimmed, $deps);
  if (ref($ast_node) eq 'HASH') {
   my $ast_kind = $ast_node->{kind} // '';
   if ($ast_kind ne 'raw_perl') {
    my $ast_lowered = $lower_ast_value_node->($ast_node);
    if (defined($ast_lowered) && length($ast_lowered)) {
     _trace_method_decision(
      phase => 'lower_method_value_expr',
      label => 'expr',
      decision => 'ast_value_lowered',
      taken => 1,
      context => { ast_kind => $ast_kind },
     );
     return $ast_lowered;
    }
    my $unknown = _actionir_ast_first_unknown_value_call_name($ast_node, $deps);
    my $unknown_expr = _actionir_ast_unsupported_helper_expr($unknown);
    if (defined($unknown_expr) && length($unknown_expr)) {
     _trace_method_decision(
      phase => 'lower_method_value_expr',
      label => 'expr',
      decision => 'ast_unknown_helper',
      taken => 1,
      context => { ast_kind => $ast_kind, method => $unknown },
     );
     return $unknown_expr;
    }
   } else {
    _trace_method_decision(
     phase => 'lower_method_value_expr',
     label => 'expr',
     decision => 'ast_raw_perl_fallback',
     taken => 1,
     context => { ast_kind => $ast_kind },
    );
   }
  }
 } else {
  _trace_method_decision(
   phase => 'lower_method_value_expr',
   label => 'expr',
   decision => 'ast_compat_bridge_bypass',
   taken => 1,
   context => {},
  );
 }
 my $literal = $lower_primitive_literal_expr->($trimmed);
 if (defined($literal)) {
  _trace_method_decision(
   phase => 'lower_method_value_expr',
   label => 'expr',
   decision => 'primitive_literal',
   taken => 1,
   context => {},
  );
  return $literal;
 }
 my $hash_receiver_chain = _normalize_hash_receiver_value_chain_expr($trimmed, $deps);
 if (defined($hash_receiver_chain) && length($hash_receiver_chain) && $hash_receiver_chain ne $trimmed) {
  my $lowered_chain = _lower_method_value_expr($hash_receiver_chain, $deps);
  if (defined($lowered_chain) && length($lowered_chain)) {
   _trace_method_decision(
    phase => 'lower_method_value_expr',
    label => 'expr',
    decision => 'hash_receiver_chain_lowered',
    taken => 1,
    context => {},
   );
   return $lowered_chain;
  }
 }
 my $string_receiver_chain = _normalize_string_receiver_value_chain_expr($trimmed, $deps);
 if (defined($string_receiver_chain) && length($string_receiver_chain) && $string_receiver_chain ne $trimmed) {
  my $lowered_chain = _lower_method_value_expr($string_receiver_chain, $deps);
  if (defined($lowered_chain) && length($lowered_chain)) {
   _trace_method_decision(
    phase => 'lower_method_value_expr',
    label => 'expr',
    decision => 'string_receiver_chain_lowered',
    taken => 1,
    context => {},
   );
   return $lowered_chain;
  }
 }
 my $number_receiver_chain = _normalize_number_receiver_value_chain_expr($trimmed, $deps);
 if (defined($number_receiver_chain) && length($number_receiver_chain) && $number_receiver_chain ne $trimmed) {
  my $lowered_chain = _lower_method_value_expr($number_receiver_chain, $deps);
  if (defined($lowered_chain) && length($lowered_chain)) {
   _trace_method_decision(
    phase => 'lower_method_value_expr',
    label => 'expr',
    decision => 'number_receiver_chain_lowered',
    taken => 1,
    context => {},
   );
   return $lowered_chain;
  }
 }
 my $bare_scalar_read = _lower_source_slot_bare_scalar_read_expr($trimmed, $deps);
 if (defined($bare_scalar_read) && length($bare_scalar_read)) {
  _trace_method_decision(
   phase => 'lower_method_value_expr',
   label => 'expr',
   decision => 'bare_scalar_read',
   taken => 1,
   context => {},
  );
  return $bare_scalar_read;
 }
 my $direct_access = $lower_direct_nested_access_value_expr->($trimmed);
 if (defined($direct_access) && length($direct_access)) {
  _trace_method_decision(
   phase => 'lower_method_value_expr',
   label => 'expr',
   decision => 'direct_access_lowered',
   taken => 1,
   context => {},
  );
  return $direct_access;
 }
 my $shape_literal = $lower_shape_literal_value_expr->($trimmed);
 if (defined($shape_literal) && length($shape_literal)) {
  _trace_method_decision(
   phase => 'lower_method_value_expr',
   label => 'expr',
   decision => 'shape_literal_lowered',
   taken => 1,
   context => {},
  );
  return $shape_literal;
 }
 my $block_value = _lower_block_value_expr($trimmed, $deps);
 if (defined($block_value) && length($block_value)) {
  _trace_method_decision(
   phase => 'lower_method_value_expr',
   label => 'expr',
   decision => 'block_value_lowered',
   taken => 1,
   context => {},
  );
  return $block_value;
 }
 my $array_receiver_chain = _normalize_array_receiver_value_chain_expr($trimmed, $deps);
 if (defined($array_receiver_chain) && length($array_receiver_chain) && $array_receiver_chain ne $trimmed) {
  my $lowered_chain = _lower_method_value_expr($array_receiver_chain, $deps);
  if (defined($lowered_chain) && length($lowered_chain)) {
   _trace_method_decision(
    phase => 'lower_method_value_expr',
    label => 'expr',
    decision => 'array_receiver_chain_lowered',
    taken => 1,
    context => {},
   );
   return $lowered_chain;
  }
 }
 my $method_call = $parse_method_function_expr->($trimmed);
 if ($method_call) {
  my $method_for_family = $method_call->{method};
  my $numeric_alias_for_family = _numeric_word_alias_helper_name($method_for_family);
  $method_for_family = $numeric_alias_for_family if defined($numeric_alias_for_family) && length($numeric_alias_for_family);
  my $family = _method_value_helper_family($method_for_family);
  _trace_method_decision(
   phase => 'lower_method_value_expr',
   label => 'expr',
   decision => 'helper_family_'.$family,
   taken => 1,
   context => { method => $method_for_family },
  );
 }
 if ($method_call && $method_call->{method} eq 'if') {
  my $if_value = _lower_inline_if_value_expr($method_call, $deps);
  if (defined($if_value) && length($if_value)) {
   _trace_method_decision(
    phase => 'lower_method_value_expr',
    label => 'expr',
    decision => 'inline_if_value',
    taken => 1,
    context => {},
   );
   return $if_value;
  }
 }
 if ($method_call && $method_call->{method} eq 'switch') {
  my $switch_value = _lower_inline_switch_value_expr($method_call, $deps);
  if (defined($switch_value) && length($switch_value)) {
   _trace_method_decision(
    phase => 'lower_method_value_expr',
    label => 'expr',
    decision => 'inline_switch_value',
    taken => 1,
    context => {},
   );
   return $switch_value;
  }
 }
 if ($method_call) {
  my $numeric_alias = _numeric_word_alias_helper_name($method_call->{method});
  $method_call = { %{$method_call}, method => $numeric_alias }
   if defined($numeric_alias) && length($numeric_alias);
 }
 if ($method_call) {
  my $array_pipeline_value = $lower_array_pipeline_value_expr->($method_call);
  if (defined($array_pipeline_value) && length($array_pipeline_value)) {
   _trace_method_decision(
    phase => 'lower_method_value_expr',
    label => 'expr',
    decision => 'array_pipeline_value',
    taken => 1,
    context => { method => $method_call->{method} },
   );
   return $array_pipeline_value;
  }
 }
 if ($method_call && $method_call->{method} eq 'call') {
  my $effective_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $effective_args;
  my $callee = $trim_action_ir_value->($effective_args->[0]);
  return undef unless defined($callee) && $callee =~ /^\w+$/o;
  _trace_method_decision(
   phase => 'lower_method_value_expr',
   label => 'expr',
   decision => 'rule_call_helper',
   taken => 1,
   context => { callee => $callee },
  );
  return '&{$$descr{spec}{'.$callee.'}{handler}}($descr, $STRING, $minfo)';
 }
 if ($method_call && $method_call->{method} eq 'input_slice') {
  my $input_slice_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $input_slice_args;

  my $start_expr = _lower_method_value_expr($input_slice_args->[0], $deps);
  $start_expr = $trim_action_ir_value->($input_slice_args->[0]) unless defined($start_expr) && length($start_expr);
  return undef unless defined($start_expr) && length($start_expr);

  my $width_expr = _lower_method_value_expr($input_slice_args->[1], $deps);
  $width_expr = $trim_action_ir_value->($input_slice_args->[1]) unless defined($width_expr) && length($width_expr);
  return undef unless defined($width_expr) && length($width_expr);

  return 'do { my $__ls_input_slice_start = '.$start_expr.'; my $__ls_input_slice_width = '.$width_expr.'; (defined($__ls_input_slice_start) && defined($__ls_input_slice_width)) ? substr($$STRING, $__ls_input_slice_start, $__ls_input_slice_width) : undef }';
 }
 if ($method_call && $method_call->{method} eq 'entry_text') {
  my $entry_text_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 0, 0);
  return undef unless $entry_text_args;
  return $trimmed
   if ref($deps->{__user_function_call_stack}) eq 'ARRAY'
   && @{$deps->{__user_function_call_stack}};
  return 'do { $IMATCH }';
 }
 if ($method_call && $method_call->{method} eq 'entry_group') {
  my $entry_group_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $entry_group_args;
  my $index = $trim_action_ir_value->($entry_group_args->[0]);
  return undef unless defined($index) && $index =~ /^\d+$/o;
  return 'do { scalar(@IMATCH_LIST) > '.$index.' ? $IMATCH_LIST['.$index.'] : undef }';
 }
 if ($method_call && $method_call->{method} eq 'entry_groups') {
  my $entry_groups_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 0, 0);
  return undef unless $entry_groups_args;
  return 'do { [@IMATCH_LIST] }';
 }
 if ($method_call && ($method_call->{method} eq 'entry_map' || $method_call->{method} eq 'entry_named_map')) {
  my $entry_map_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 0, 0);
  return undef unless $entry_map_args;
  return 'do { +{%IMATCH_HASH} }';
 }
 if ($method_call && $method_call->{method} eq 'match_text') {
  my $match_text_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 0, 0);
  return undef unless $match_text_args;
  return $trimmed
   if ref($deps->{__user_function_call_stack}) eq 'ARRAY'
   && @{$deps->{__user_function_call_stack}};
  return 'do { $LMATCH }';
 }
 if ($method_call && $method_call->{method} eq 'match_group') {
  my $match_group_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $match_group_args;
  my $index = $trim_action_ir_value->($match_group_args->[0]);
  return undef unless defined($index) && $index =~ /^\d+$/o;
  return 'do { scalar(@LMATCH_LIST) > '.$index.' ? $LMATCH_LIST['.$index.'] : undef }';
 }
 if ($method_call && $method_call->{method} eq 'match_groups') {
  my $match_groups_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 0, 0);
  return undef unless $match_groups_args;
  return 'do { [@LMATCH_LIST] }';
 }
 if ($method_call && ($method_call->{method} eq 'match_map' || $method_call->{method} eq 'match_named_map')) {
  my $match_map_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 0, 0);
  return undef unless $match_map_args;
  return 'do { +{%LMATCH_HASH} }';
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

  return 'do { my $__ls_lower = '.$value_expr.'; defined($__ls_lower) ? LinkedSpec::UnicodeCaseMapping::lowercase($__ls_lower) : $__ls_lower }';
 }
 if ($method_call && $method_call->{method} eq 'uppercase') {
  my $upper_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $upper_args;

  my $value_expr = _lower_method_value_expr($upper_args->[0], $deps);
  $value_expr = $trim_action_ir_value->($upper_args->[0]) unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);

  return 'do { my $__ls_upper = '.$value_expr.'; defined($__ls_upper) ? LinkedSpec::UnicodeCaseMapping::uppercase($__ls_upper) : $__ls_upper }';
 }
 if ($method_call && $method_call->{method} eq 'length') {
  my $length_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $length_args;

 my $value_expr = _lower_method_value_expr($length_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($length_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_length = '.$value_expr.'; defined($__ls_length) ? (ref($__ls_length) eq \'ARRAY\' ? scalar(@{$__ls_length}) : length($__ls_length)) : undef }';
}
if ($method_call && $method_call->{method} eq 'substr') {
 my $substr_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 3);
 return undef unless $substr_args;

 my $value_expr = _lower_method_value_expr($substr_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($substr_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 my $start_expr = _lower_method_value_expr($substr_args->[1], $deps);
 $start_expr = $trim_action_ir_value->($substr_args->[1]) unless defined($start_expr) && length($start_expr);
 return undef unless defined($start_expr) && length($start_expr);

 if (@$substr_args == 2) {
  return 'do { my $__ls_substr_value = '.$value_expr.'; my $__ls_substr_start = '.$start_expr.'; if (defined($__ls_substr_value) && defined($__ls_substr_start)) { $__ls_substr_start = 0 unless $__ls_substr_start =~ /\A-?\d+\z/; $__ls_substr_start = 0 if $__ls_substr_start < 0; substr($__ls_substr_value, $__ls_substr_start) } else { undef } }';
 }

 my $len_expr = _lower_method_value_expr($substr_args->[2], $deps);
 $len_expr = $trim_action_ir_value->($substr_args->[2]) unless defined($len_expr) && length($len_expr);
 return undef unless defined($len_expr) && length($len_expr);

 return 'do { my $__ls_substr_value = '.$value_expr.'; my $__ls_substr_start = '.$start_expr.'; my $__ls_substr_len = '.$len_expr.'; if (defined($__ls_substr_value) && defined($__ls_substr_start) && defined($__ls_substr_len)) { $__ls_substr_start = 0 unless $__ls_substr_start =~ /\A-?\d+\z/; $__ls_substr_start = 0 if $__ls_substr_start < 0; $__ls_substr_len = 0 unless $__ls_substr_len =~ /\A-?\d+\z/; $__ls_substr_len = 0 if $__ls_substr_len < 0; substr($__ls_substr_value, $__ls_substr_start, $__ls_substr_len) } else { undef } }';
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
if ($method_call && $method_call->{method} eq 'rm_prefix') {
 my $rm_prefix_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
 return undef unless $rm_prefix_args;

 my $value_expr = _lower_method_value_expr($rm_prefix_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($rm_prefix_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 my $prefix_expr = _lower_method_value_expr($rm_prefix_args->[1], $deps);
 $prefix_expr = $trim_action_ir_value->($rm_prefix_args->[1]) unless defined($prefix_expr) && length($prefix_expr);
 return undef unless defined($prefix_expr) && length($prefix_expr);

 return 'do { my $__ls_rm_prefix_value = '.$value_expr.'; my $__ls_rm_prefix_prefix = '.$prefix_expr.'; if (defined($__ls_rm_prefix_value) && defined($__ls_rm_prefix_prefix)) { length($__ls_rm_prefix_prefix) ? ((index($__ls_rm_prefix_value, $__ls_rm_prefix_prefix) == 0) ? substr($__ls_rm_prefix_value, length($__ls_rm_prefix_prefix)) : $__ls_rm_prefix_value) : $__ls_rm_prefix_value } else { undef } }';
}
if ($method_call && $method_call->{method} eq 'rm_suffix') {
 my $rm_suffix_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
 return undef unless $rm_suffix_args;

 my $value_expr = _lower_method_value_expr($rm_suffix_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($rm_suffix_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 my $suffix_expr = _lower_method_value_expr($rm_suffix_args->[1], $deps);
 $suffix_expr = $trim_action_ir_value->($rm_suffix_args->[1]) unless defined($suffix_expr) && length($suffix_expr);
 return undef unless defined($suffix_expr) && length($suffix_expr);

 return 'do { my $__ls_rm_suffix_value = '.$value_expr.'; my $__ls_rm_suffix_suffix = '.$suffix_expr.'; if (defined($__ls_rm_suffix_value) && defined($__ls_rm_suffix_suffix)) { if (length($__ls_rm_suffix_suffix) == 0) { $__ls_rm_suffix_value } elsif (length($__ls_rm_suffix_value) >= length($__ls_rm_suffix_suffix) && substr($__ls_rm_suffix_value, -length($__ls_rm_suffix_suffix)) eq $__ls_rm_suffix_suffix) { substr($__ls_rm_suffix_value, 0, length($__ls_rm_suffix_value) - length($__ls_rm_suffix_suffix)) } else { $__ls_rm_suffix_value } } else { undef } }';
}
if ($method_call && $method_call->{method} eq 'cat') {
 my $cat_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, undef);
 return undef unless $cat_args && @$cat_args >= 2;

 my @lowered_parts = ();
 foreach my $arg (@$cat_args) {
  my $part_expr = _lower_method_value_expr($arg, $deps);
  $part_expr = $trim_action_ir_value->($arg) unless defined($part_expr) && length($part_expr);
  return undef unless defined($part_expr) && length($part_expr);
  push @lowered_parts, $part_expr;
 }

 return 'do { my @__ls_cat_parts = ('.join(', ', @lowered_parts).'); my $__ls_cat_ok = 1; for my $__ls_cat_part (@__ls_cat_parts) { if (!defined($__ls_cat_part)) { $__ls_cat_ok = 0; last; } if (ref($__ls_cat_part)) { if (ref($__ls_cat_part) eq \'JSON::PP::Boolean\') { $__ls_cat_part = $__ls_cat_part ? \'1\' : \'0\'; } else { $__ls_cat_ok = 0; last; } } else { $__ls_cat_part = "$__ls_cat_part"; $__ls_cat_part = \'0\' if $__ls_cat_part =~ /\A-0(?:\.0+)?\z/; } } $__ls_cat_ok ? join(\'\', @__ls_cat_parts) : undef }';
}
if ($method_call && $method_call->{method} eq 'num_abs') {
 my $num_abs_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_abs_args;

 my $value_expr = _lower_method_value_expr($num_abs_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($num_abs_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_num_abs_value = '.$value_expr.'; LinkedSpec::Numeric::evaluate(\'num_abs\', $__ls_num_abs_value) }';
}
if ($method_call && $method_call->{method} eq 'num_floor') {
 my $num_floor_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_floor_args;

 my $value_expr = _lower_method_value_expr($num_floor_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($num_floor_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_num_floor_value = '.$value_expr.'; LinkedSpec::Numeric::evaluate(\'num_floor\', $__ls_num_floor_value) }';
}
if ($method_call && $method_call->{method} eq 'num_ceil') {
 my $num_ceil_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_ceil_args;

 my $value_expr = _lower_method_value_expr($num_ceil_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($num_ceil_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_num_ceil_value = '.$value_expr.'; LinkedSpec::Numeric::evaluate(\'num_ceil\', $__ls_num_ceil_value) }';
}
if ($method_call && $method_call->{method} eq 'num_round') {
 my $num_round_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_round_args;

 my $value_expr = _lower_method_value_expr($num_round_args->[0], $deps);
 $value_expr = $trim_action_ir_value->($num_round_args->[0]) unless defined($value_expr) && length($value_expr);
 return undef unless defined($value_expr) && length($value_expr);

 return 'do { my $__ls_num_round_value = '.$value_expr.'; LinkedSpec::Numeric::evaluate(\'num_round\', $__ls_num_round_value) }';
}
if ($method_call && $method_call->{method} eq 'num_sum') {
 my $num_sum_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_sum_args;

 my $target_expr = $trim_action_ir_value->($num_sum_args->[0]);
 return undef unless defined($target_expr) && length($target_expr);
 my $target_call = $parse_method_function_expr->($target_expr);
 my $pipeline_target = $lower_array_pipeline_value_expr->($target_call);
 $pipeline_target = $lower_internal_array_pipeline_target_expr->($target_expr)
  unless defined($pipeline_target) && length($pipeline_target);
 return undef unless $looks_like_array_value_expr->($target_expr)
                  || (defined($pipeline_target) && length($pipeline_target));

 my $array_symbol = $extract_array_symbol_name->($target_expr);
 if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
  return 'do { my $__ls_num_sum_total = 0; my $__ls_num_sum_ok = 1; for my $__ls_num_sum_term (@'.$array_symbol.') { if (!(defined($__ls_num_sum_term) && $__ls_num_sum_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_sum_ok = 0; last; } $__ls_num_sum_total += $__ls_num_sum_term; } $__ls_num_sum_ok ? $__ls_num_sum_total : undef }';
 }

 my $lowered_target = $pipeline_target;
 $lowered_target = _lower_method_value_expr($target_expr, $deps) unless defined($lowered_target) && length($lowered_target);
 $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
 return undef unless defined($lowered_target) && length($lowered_target);

 return 'do { my $__ls_num_sum_source = '.$lowered_target.'; if (defined($__ls_num_sum_source) && ref($__ls_num_sum_source) eq \'ARRAY\') { my $__ls_num_sum_total = 0; my $__ls_num_sum_ok = 1; for my $__ls_num_sum_term (@{$__ls_num_sum_source}) { if (!(defined($__ls_num_sum_term) && $__ls_num_sum_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_sum_ok = 0; last; } $__ls_num_sum_total += $__ls_num_sum_term; } $__ls_num_sum_ok ? $__ls_num_sum_total : undef } else { undef } }';
}
if ($method_call && $method_call->{method} eq 'num_avg') {
 my $num_avg_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_avg_args;

 my $target_expr = $trim_action_ir_value->($num_avg_args->[0]);
 return undef unless defined($target_expr) && length($target_expr);
 my $target_call = $parse_method_function_expr->($target_expr);
 my $pipeline_target = $lower_array_pipeline_value_expr->($target_call);
 $pipeline_target = $lower_internal_array_pipeline_target_expr->($target_expr)
  unless defined($pipeline_target) && length($pipeline_target);
 return undef unless $looks_like_array_value_expr->($target_expr)
                  || (defined($pipeline_target) && length($pipeline_target));

 my $array_symbol = $extract_array_symbol_name->($target_expr);
 if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
  return 'do { my $__ls_num_avg_total = 0; my $__ls_num_avg_count = 0; my $__ls_num_avg_ok = 1; for my $__ls_num_avg_term (@'.$array_symbol.') { if (!(defined($__ls_num_avg_term) && $__ls_num_avg_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_avg_ok = 0; last; } $__ls_num_avg_total += $__ls_num_avg_term; $__ls_num_avg_count++; } $__ls_num_avg_ok ? ($__ls_num_avg_count ? ($__ls_num_avg_total / $__ls_num_avg_count) : undef) : undef }';
 }

 my $lowered_target = $pipeline_target;
 $lowered_target = _lower_method_value_expr($target_expr, $deps) unless defined($lowered_target) && length($lowered_target);
 $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
 return undef unless defined($lowered_target) && length($lowered_target);

 return 'do { my $__ls_num_avg_source = '.$lowered_target.'; if (defined($__ls_num_avg_source) && ref($__ls_num_avg_source) eq \'ARRAY\') { my $__ls_num_avg_total = 0; my $__ls_num_avg_count = 0; my $__ls_num_avg_ok = 1; for my $__ls_num_avg_term (@{$__ls_num_avg_source}) { if (!(defined($__ls_num_avg_term) && $__ls_num_avg_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_avg_ok = 0; last; } $__ls_num_avg_total += $__ls_num_avg_term; $__ls_num_avg_count++; } $__ls_num_avg_ok ? ($__ls_num_avg_count ? ($__ls_num_avg_total / $__ls_num_avg_count) : undef) : undef } else { undef } }';
}
if ($method_call && $method_call->{method} eq 'num_median') {
 my $num_median_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_median_args;

 my $target_expr = $trim_action_ir_value->($num_median_args->[0]);
 return undef unless defined($target_expr) && length($target_expr);

 my $array_symbol = $extract_array_symbol_name->($target_expr);
 if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
  return 'do { my @__ls_num_median_terms = @'.$array_symbol.'; my $__ls_num_median_ok = 1; for my $__ls_num_median_term (@__ls_num_median_terms) { if (!(defined($__ls_num_median_term) && $__ls_num_median_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_median_ok = 0; last; } } if ($__ls_num_median_ok && @__ls_num_median_terms) { @__ls_num_median_terms = sort { $a <=> $b } @__ls_num_median_terms; my $__ls_num_median_count = scalar(@__ls_num_median_terms); my $__ls_num_median_mid = int($__ls_num_median_count / 2); ($__ls_num_median_count % 2) ? $__ls_num_median_terms[$__ls_num_median_mid] : (($__ls_num_median_terms[$__ls_num_median_mid - 1] + $__ls_num_median_terms[$__ls_num_median_mid]) / 2) } else { undef } }';
 }

 my $target_call = $parse_method_function_expr->($target_expr);
 my $lowered_target = $lower_array_pipeline_value_expr->($target_call);
 $lowered_target = $lower_internal_array_pipeline_target_expr->($target_expr)
  unless defined($lowered_target) && length($lowered_target);
 $lowered_target = _lower_method_value_expr($target_expr, $deps) unless defined($lowered_target) && length($lowered_target);
 $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
 return undef unless defined($lowered_target) && length($lowered_target);

 return 'do { my $__ls_num_median_source = '.$lowered_target.'; if (defined($__ls_num_median_source) && ref($__ls_num_median_source) eq \'ARRAY\') { my @__ls_num_median_terms = @{$__ls_num_median_source}; my $__ls_num_median_ok = 1; for my $__ls_num_median_term (@__ls_num_median_terms) { if (!(defined($__ls_num_median_term) && $__ls_num_median_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_median_ok = 0; last; } } if ($__ls_num_median_ok && @__ls_num_median_terms) { @__ls_num_median_terms = sort { $a <=> $b } @__ls_num_median_terms; my $__ls_num_median_count = scalar(@__ls_num_median_terms); my $__ls_num_median_mid = int($__ls_num_median_count / 2); ($__ls_num_median_count % 2) ? $__ls_num_median_terms[$__ls_num_median_mid] : (($__ls_num_median_terms[$__ls_num_median_mid - 1] + $__ls_num_median_terms[$__ls_num_median_mid]) / 2) } else { undef } } else { undef } }';
}
if ($method_call && $method_call->{method} eq 'num_range') {
 my $num_range_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
 return undef unless $num_range_args;

 my $target_expr = $trim_action_ir_value->($num_range_args->[0]);
 return undef unless defined($target_expr) && length($target_expr);

 my $array_symbol = $extract_array_symbol_name->($target_expr);
 if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
  return 'do { my $__ls_num_range_min; my $__ls_num_range_max; my $__ls_num_range_seen = 0; my $__ls_num_range_ok = 1; for my $__ls_num_range_term (@'.$array_symbol.') { if (!(defined($__ls_num_range_term) && $__ls_num_range_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_range_ok = 0; last; } if ($__ls_num_range_seen) { $__ls_num_range_min = $__ls_num_range_term if $__ls_num_range_term < $__ls_num_range_min; $__ls_num_range_max = $__ls_num_range_term if $__ls_num_range_term > $__ls_num_range_max; } else { $__ls_num_range_min = $__ls_num_range_term; $__ls_num_range_max = $__ls_num_range_term; $__ls_num_range_seen = 1; } } $__ls_num_range_ok ? ($__ls_num_range_seen ? ($__ls_num_range_max - $__ls_num_range_min) : undef) : undef }';
 }

 my $target_call = $parse_method_function_expr->($target_expr);
 my $lowered_target = $lower_array_pipeline_value_expr->($target_call);
 $lowered_target = $lower_internal_array_pipeline_target_expr->($target_expr)
  unless defined($lowered_target) && length($lowered_target);
 $lowered_target = _lower_method_value_expr($target_expr, $deps) unless defined($lowered_target) && length($lowered_target);
 $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
 return undef unless defined($lowered_target) && length($lowered_target);

 return 'do { my $__ls_num_range_source = '.$lowered_target.'; if (defined($__ls_num_range_source) && ref($__ls_num_range_source) eq \'ARRAY\') { my $__ls_num_range_min; my $__ls_num_range_max; my $__ls_num_range_seen = 0; my $__ls_num_range_ok = 1; for my $__ls_num_range_term (@{$__ls_num_range_source}) { if (!(defined($__ls_num_range_term) && $__ls_num_range_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_range_ok = 0; last; } if ($__ls_num_range_seen) { $__ls_num_range_min = $__ls_num_range_term if $__ls_num_range_term < $__ls_num_range_min; $__ls_num_range_max = $__ls_num_range_term if $__ls_num_range_term > $__ls_num_range_max; } else { $__ls_num_range_min = $__ls_num_range_term; $__ls_num_range_max = $__ls_num_range_term; $__ls_num_range_seen = 1; } } $__ls_num_range_ok ? ($__ls_num_range_seen ? ($__ls_num_range_max - $__ls_num_range_min) : undef) : undef } else { undef } }';
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

  return 'do { my @__ls_num_add_terms = ('.join(', ', @lowered_terms).'); LinkedSpec::Numeric::evaluate(\'num_add\', @__ls_num_add_terms) }';
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

  return 'do { my $__ls_num_sub_lhs = '.$lhs_expr.'; my $__ls_num_sub_rhs = '.$rhs_expr.'; LinkedSpec::Numeric::evaluate(\'num_sub\', $__ls_num_sub_lhs, $__ls_num_sub_rhs) }';
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

  return 'do { my @__ls_num_mul_terms = ('.join(', ', @lowered_terms).'); LinkedSpec::Numeric::evaluate(\'num_mul\', @__ls_num_mul_terms) }';
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

 return 'do { my $__ls_num_div_lhs = '.$lhs_expr.'; my $__ls_num_div_rhs = '.$rhs_expr.'; LinkedSpec::Numeric::evaluate(\'num_div\', $__ls_num_div_lhs, $__ls_num_div_rhs) }';
 }
 if ($method_call && $method_call->{method} eq 'num_mod') {
  my $num_mod_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $num_mod_args;

  my $lhs_expr = _lower_method_value_expr($num_mod_args->[0], $deps);
  $lhs_expr = $trim_action_ir_value->($num_mod_args->[0]) unless defined($lhs_expr) && length($lhs_expr);
  return undef unless defined($lhs_expr) && length($lhs_expr);

  my $rhs_expr = _lower_method_value_expr($num_mod_args->[1], $deps);
  $rhs_expr = $trim_action_ir_value->($num_mod_args->[1]) unless defined($rhs_expr) && length($rhs_expr);
  return undef unless defined($rhs_expr) && length($rhs_expr);

 return 'do { my $__ls_num_mod_lhs = '.$lhs_expr.'; my $__ls_num_mod_rhs = '.$rhs_expr.'; LinkedSpec::Numeric::evaluate(\'num_mod\', $__ls_num_mod_lhs, $__ls_num_mod_rhs) }';
 }
 if ($method_call && $method_call->{method} =~ /^num_(eq|ne|gt|ge|lt|le)$/o) {
  my $op_name = $1;
  my $num_cmp_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $num_cmp_args;

  my $lhs_expr = _lower_method_value_expr($num_cmp_args->[0], $deps);
  $lhs_expr = $trim_action_ir_value->($num_cmp_args->[0]) unless defined($lhs_expr) && length($lhs_expr);
  return undef unless defined($lhs_expr) && length($lhs_expr);

  my $rhs_expr = _lower_method_value_expr($num_cmp_args->[1], $deps);
  $rhs_expr = $trim_action_ir_value->($num_cmp_args->[1]) unless defined($rhs_expr) && length($rhs_expr);
  return undef unless defined($rhs_expr) && length($rhs_expr);

  my %ops = (
   eq => '==',
   ne => '!=',
   gt => '>',
   ge => '>=',
   lt => '<',
   le => '<=',
  );
  my $op = $ops{$op_name};
  return undef unless defined($op);

  return 'do { my $__ls_num_cmp_lhs = '.$lhs_expr.'; my $__ls_num_cmp_rhs = '.$rhs_expr.'; LinkedSpec::Numeric::evaluate(\'num_'.$op_name.'\', $__ls_num_cmp_lhs, $__ls_num_cmp_rhs) }';
 }
 if ($method_call && $method_call->{method} eq 'num_clamp') {
  my $num_clamp_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 3, 3);
  return undef unless $num_clamp_args;

  my $value_expr = _lower_method_value_expr($num_clamp_args->[0], $deps);
  $value_expr = $trim_action_ir_value->($num_clamp_args->[0]) unless defined($value_expr) && length($value_expr);
  return undef unless defined($value_expr) && length($value_expr);

  my $lower_expr = _lower_method_value_expr($num_clamp_args->[1], $deps);
  $lower_expr = $trim_action_ir_value->($num_clamp_args->[1]) unless defined($lower_expr) && length($lower_expr);
  return undef unless defined($lower_expr) && length($lower_expr);

  my $upper_expr = _lower_method_value_expr($num_clamp_args->[2], $deps);
  $upper_expr = $trim_action_ir_value->($num_clamp_args->[2]) unless defined($upper_expr) && length($upper_expr);
  return undef unless defined($upper_expr) && length($upper_expr);

 return 'do { my $__ls_num_clamp_value = '.$value_expr.'; my $__ls_num_clamp_lower = '.$lower_expr.'; my $__ls_num_clamp_upper = '.$upper_expr.'; LinkedSpec::Numeric::evaluate(\'num_clamp\', $__ls_num_clamp_value, $__ls_num_clamp_lower, $__ls_num_clamp_upper) }';
 }
 if ($method_call && $method_call->{method} eq 'num_min') {
  my $num_min_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, undef);
  return undef unless $num_min_args && @$num_min_args;

  if (@$num_min_args == 1) {
   my $target_expr = $trim_action_ir_value->($num_min_args->[0]);
   return undef unless defined($target_expr) && length($target_expr);

   my $array_symbol = $extract_array_symbol_name->($target_expr);
   if (defined($array_symbol)
    && length($array_symbol)
    && $target_expr =~ $array_symbol_expr_re
    && (($bare_symbol_kind->($array_symbol) // '') ne 'scalar')) {
    return 'do { my $__ls_num_min_value; my $__ls_num_min_ok = 1; for my $__ls_num_min_term (@'.$array_symbol.') { if (!(defined($__ls_num_min_term) && $__ls_num_min_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_min_ok = 0; last; } $__ls_num_min_value = defined($__ls_num_min_value) ? ($__ls_num_min_term < $__ls_num_min_value ? $__ls_num_min_term : $__ls_num_min_value) : $__ls_num_min_term; } $__ls_num_min_ok ? $__ls_num_min_value : undef }';
   }

   my $target_call = $parse_method_function_expr->($target_expr);
   my $lowered_target = $lower_array_pipeline_value_expr->($target_call);
   $lowered_target = $lower_internal_array_pipeline_target_expr->($target_expr)
    unless defined($lowered_target) && length($lowered_target);
   $lowered_target = _lower_method_value_expr($target_expr, $deps) unless defined($lowered_target) && length($lowered_target);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
   return undef unless defined($lowered_target) && length($lowered_target);

   return 'do { my $__ls_num_min_source = '.$lowered_target.'; if (defined($__ls_num_min_source) && ref($__ls_num_min_source) eq \'ARRAY\') { my $__ls_num_min_value; my $__ls_num_min_ok = 1; for my $__ls_num_min_term (@{$__ls_num_min_source}) { if (!(defined($__ls_num_min_term) && $__ls_num_min_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_min_ok = 0; last; } $__ls_num_min_value = defined($__ls_num_min_value) ? ($__ls_num_min_term < $__ls_num_min_value ? $__ls_num_min_term : $__ls_num_min_value) : $__ls_num_min_term; } $__ls_num_min_ok ? $__ls_num_min_value : undef } else { undef } }';
  }

  my @lowered_terms;
  foreach my $arg (@$num_min_args) {
   my $term_expr = _lower_method_value_expr($arg, $deps);
   $term_expr = $trim_action_ir_value->($arg) unless defined($term_expr) && length($term_expr);
   return undef unless defined($term_expr) && length($term_expr);
   push @lowered_terms, $term_expr;
  }

  return 'do { my @__ls_num_min_terms = ('.join(', ', @lowered_terms).'); LinkedSpec::Numeric::evaluate(\'num_min\', @__ls_num_min_terms) }';
 }
 if ($method_call && $method_call->{method} eq 'num_max') {
  my $num_max_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, undef);
  return undef unless $num_max_args && @$num_max_args;

  if (@$num_max_args == 1) {
   my $target_expr = $trim_action_ir_value->($num_max_args->[0]);
   return undef unless defined($target_expr) && length($target_expr);

   my $array_symbol = $extract_array_symbol_name->($target_expr);
   if (defined($array_symbol)
    && length($array_symbol)
    && $target_expr =~ $array_symbol_expr_re
    && (($bare_symbol_kind->($array_symbol) // '') ne 'scalar')) {
    return 'do { my $__ls_num_max_value; my $__ls_num_max_ok = 1; for my $__ls_num_max_term (@'.$array_symbol.') { if (!(defined($__ls_num_max_term) && $__ls_num_max_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_max_ok = 0; last; } $__ls_num_max_value = defined($__ls_num_max_value) ? ($__ls_num_max_term > $__ls_num_max_value ? $__ls_num_max_term : $__ls_num_max_value) : $__ls_num_max_term; } $__ls_num_max_ok ? $__ls_num_max_value : undef }';
   }

   my $target_call = $parse_method_function_expr->($target_expr);
   my $lowered_target = $lower_array_pipeline_value_expr->($target_call);
   $lowered_target = $lower_internal_array_pipeline_target_expr->($target_expr)
    unless defined($lowered_target) && length($lowered_target);
   $lowered_target = _lower_method_value_expr($target_expr, $deps) unless defined($lowered_target) && length($lowered_target);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
   return undef unless defined($lowered_target) && length($lowered_target);

   return 'do { my $__ls_num_max_source = '.$lowered_target.'; if (defined($__ls_num_max_source) && ref($__ls_num_max_source) eq \'ARRAY\') { my $__ls_num_max_value; my $__ls_num_max_ok = 1; for my $__ls_num_max_term (@{$__ls_num_max_source}) { if (!(defined($__ls_num_max_term) && $__ls_num_max_term =~ /\A-?(?:\d+(?:\.\d+)?|\.\d+)\z/)) { $__ls_num_max_ok = 0; last; } $__ls_num_max_value = defined($__ls_num_max_value) ? ($__ls_num_max_term > $__ls_num_max_value ? $__ls_num_max_term : $__ls_num_max_value) : $__ls_num_max_term; } $__ls_num_max_ok ? $__ls_num_max_value : undef } else { undef } }';
  }

  my @lowered_terms;
  foreach my $arg (@$num_max_args) {
   my $term_expr = _lower_method_value_expr($arg, $deps);
   $term_expr = $trim_action_ir_value->($arg) unless defined($term_expr) && length($term_expr);
   return undef unless defined($term_expr) && length($term_expr);
   push @lowered_terms, $term_expr;
  }

  return 'do { my @__ls_num_max_terms = ('.join(', ', @lowered_terms).'); LinkedSpec::Numeric::evaluate(\'num_max\', @__ls_num_max_terms) }';
 }
 if ($method_call && $method_call->{method} =~ /^(?:str_eq|str_ne|str_gt|str_ge|str_lt|str_le)$/o) {
  my %string_compare_ops = (
   str_eq => 'eq',
   str_ne => 'ne',
   str_gt => 'gt',
   str_ge => 'ge',
   str_lt => 'lt',
   str_le => 'le',
  );
  my $string_compare_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $string_compare_args;

  my $lhs_expr = _lower_method_value_expr($string_compare_args->[0], $deps);
  $lhs_expr = $trim_action_ir_value->($string_compare_args->[0]) unless defined($lhs_expr) && length($lhs_expr);
  return undef unless defined($lhs_expr) && length($lhs_expr);

  my $rhs_expr = _lower_method_value_expr($string_compare_args->[1], $deps);
  $rhs_expr = $trim_action_ir_value->($string_compare_args->[1]) unless defined($rhs_expr) && length($rhs_expr);
  return undef unless defined($rhs_expr) && length($rhs_expr);

  my $op = $string_compare_ops{$method_call->{method}};
  return 'do { my $__ls_str_cmp_lhs = '.$lhs_expr.'; my $__ls_str_cmp_rhs = '.$rhs_expr.'; ($__ls_str_cmp_lhs '.$op.' $__ls_str_cmp_rhs) ? 1 : 0 }';
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
  if ($target_expr =~ $array_container_prefix_re) {
   if ($target_expr =~ /^array\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o
    && (($bare_symbol_kind->($1) // '') eq 'scalar')) {
    my $name = $1;
    $empty_expr = 'do { my $__ls_is_empty_array = $'.$name.'; (!defined($__ls_is_empty_array) || ref($__ls_is_empty_array) ne \'ARRAY\' || !@{$__ls_is_empty_array}) ? 1 : 0 }';
   } else {
   my $array_symbol = $extract_array_symbol_name->($target_expr);
   return undef unless defined($array_symbol) && length($array_symbol);
   $empty_expr = '((!@'.$array_symbol.') ? 1 : 0)';
   }
  } elsif ($target_expr =~ $hash_container_prefix_re) {
   if ($target_expr =~ /^hash\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o
    && (($bare_symbol_kind->($1) // '') eq 'scalar')) {
    my $name = $1;
    $empty_expr = 'do { my $__ls_is_empty_hash = $'.$name.'; (!defined($__ls_is_empty_hash) || ref($__ls_is_empty_hash) ne \'HASH\' || !scalar(keys %{$__ls_is_empty_hash})) ? 1 : 0 }';
   } else {
   my $hash_symbol = $extract_hash_symbol_name->($target_expr);
   return undef unless defined($hash_symbol) && length($hash_symbol);
   $empty_expr = '((!scalar(keys %'.$hash_symbol.')) ? 1 : 0)';
   }
  } else {
   my $scalar_symbol = $extract_scalar_symbol_name->($target_expr);
   if (defined($scalar_symbol) && length($scalar_symbol)) {
    $empty_expr = 'do { my $__ls_is_empty_value = $'.$scalar_symbol.'; '
     .'(!defined($__ls_is_empty_value) '
     .'|| (ref($__ls_is_empty_value) eq \'ARRAY\' && !@{$__ls_is_empty_value}) '
     .'|| (ref($__ls_is_empty_value) eq \'HASH\' && !scalar(keys %{$__ls_is_empty_value})) '
     .'|| (!ref($__ls_is_empty_value) && $__ls_is_empty_value eq \'\')) ? 1 : 0 }';
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
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
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
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
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
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
   return '$'.$array_symbol.'[$#'.$array_symbol.']';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_last = '.$lowered_target.'; defined($__ls_last) && @{$__ls_last} ? $__ls_last->[-1] : undef }';
 }
 if ($method_call && $method_call->{method} eq 'drop_front') {
  my $tail_args = $normalize_collection_args->($method_call->{args} || [], 1, 2);
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
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
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
  my $take_args = $normalize_collection_args->($method_call->{args} || [], 1, 2);
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
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
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
 if ($method_call && $method_call->{method} eq 'slice') {
  my $slice_args = $normalize_collection_args->($method_call->{args} || [], 2, 3);
  return undef unless $slice_args;

  my $target_expr = $trim_action_ir_value->($slice_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $slice_start_expr = _lower_method_value_expr($slice_args->[1], $deps);
  $slice_start_expr = $trim_action_ir_value->($slice_args->[1]) unless defined($slice_start_expr) && length($slice_start_expr);
  return undef unless defined($slice_start_expr) && length($slice_start_expr);

  my $slice_has_explicit_count = (@{$slice_args} > 2 && defined($slice_args->[2])) ? 1 : 0;
  my $slice_count_expr;
  if ($slice_has_explicit_count) {
   $slice_count_expr = _lower_method_value_expr($slice_args->[2], $deps);
   $slice_count_expr = $trim_action_ir_value->($slice_args->[2]) unless defined($slice_count_expr) && length($slice_count_expr);
   return undef unless defined($slice_count_expr) && length($slice_count_expr);
  }

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
   return 'do { my $__ls_slice_start = '.$slice_start_expr.'; $__ls_slice_start = 0 unless defined($__ls_slice_start) && $__ls_slice_start =~ /\A-?\d+\z/; $__ls_slice_start = 0 if $__ls_slice_start < 0; my $__ls_slice_len = scalar(@'.$array_symbol.'); $__ls_slice_len > $__ls_slice_start ? [@'.$array_symbol.'[$__ls_slice_start .. $__ls_slice_len - 1]] : [] }'
    unless $slice_has_explicit_count;
   return 'do { my $__ls_slice_start = '.$slice_start_expr.'; $__ls_slice_start = 0 unless defined($__ls_slice_start) && $__ls_slice_start =~ /\A-?\d+\z/; $__ls_slice_start = 0 if $__ls_slice_start < 0; my $__ls_slice_count = '.$slice_count_expr.'; $__ls_slice_count = 0 unless defined($__ls_slice_count) && $__ls_slice_count =~ /\A-?\d+\z/; $__ls_slice_count = 0 if $__ls_slice_count < 0; my $__ls_slice_len = scalar(@'.$array_symbol.'); if ($__ls_slice_count > 0 && $__ls_slice_len > $__ls_slice_start) { my $__ls_slice_end = $__ls_slice_start + $__ls_slice_count - 1; $__ls_slice_end = $__ls_slice_len - 1 if $__ls_slice_end >= $__ls_slice_len; [@'.$array_symbol.'[$__ls_slice_start .. $__ls_slice_end]] } else { [] } }';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_slice = '.$lowered_target.'; if (defined($__ls_slice) && ref($__ls_slice) eq \'ARRAY\') { my $__ls_slice_start = '.$slice_start_expr.'; $__ls_slice_start = 0 unless defined($__ls_slice_start) && $__ls_slice_start =~ /\A-?\d+\z/; $__ls_slice_start = 0 if $__ls_slice_start < 0; my $__ls_slice_len = scalar(@{$__ls_slice}); $__ls_slice_len > $__ls_slice_start ? [@{$__ls_slice}[$__ls_slice_start .. $__ls_slice_len - 1]] : [] } else { [] } }'
   unless $slice_has_explicit_count;
  return 'do { my $__ls_slice = '.$lowered_target.'; if (defined($__ls_slice) && ref($__ls_slice) eq \'ARRAY\') { my $__ls_slice_start = '.$slice_start_expr.'; $__ls_slice_start = 0 unless defined($__ls_slice_start) && $__ls_slice_start =~ /\A-?\d+\z/; $__ls_slice_start = 0 if $__ls_slice_start < 0; my $__ls_slice_count = '.$slice_count_expr.'; $__ls_slice_count = 0 unless defined($__ls_slice_count) && $__ls_slice_count =~ /\A-?\d+\z/; $__ls_slice_count = 0 if $__ls_slice_count < 0; my $__ls_slice_len = scalar(@{$__ls_slice}); if ($__ls_slice_count > 0 && $__ls_slice_len > $__ls_slice_start) { my $__ls_slice_end = $__ls_slice_start + $__ls_slice_count - 1; $__ls_slice_end = $__ls_slice_len - 1 if $__ls_slice_end >= $__ls_slice_len; [@{$__ls_slice}[$__ls_slice_start .. $__ls_slice_end]] } else { [] } } else { [] } }';
 }
 if ($method_call && $method_call->{method} eq 'take_last') {
  my $take_last_args = $normalize_collection_args->($method_call->{args} || [], 1, 2);
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
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
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
 if ($method_call && $method_call->{method} eq 'drop_back') {
  my $drop_last_args = $normalize_collection_args->($method_call->{args} || [], 1, 2);
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
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
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
  my $concat_args = $normalize_collection_args->($method_call->{args} || [], 1, undef);
  return undef unless $concat_args && @$concat_args >= 1;

  my @parts;
  foreach my $arg (@$concat_args) {
   my $target_expr = $trim_action_ir_value->($arg);
   return undef unless defined($target_expr) && length($target_expr);

   my $array_symbol = $extract_array_symbol_name->($target_expr);
   if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
    push @parts, '@'.$array_symbol;
    next;
   }

   my $lowered_target = _lower_method_value_expr($target_expr, $deps);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
   return undef unless defined($lowered_target) && length($lowered_target);

   push @parts, 'do { my $__ls_concat_arrays = '.$lowered_target.'; defined($__ls_concat_arrays) && ref($__ls_concat_arrays) eq \'ARRAY\' ? @{$__ls_concat_arrays} : () }';
  }

  return '['.join(', ', @parts).']';
 }
 if ($method_call && $method_call->{method} eq 'split') {
  my $split_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
  return undef unless $split_args;

  my $source_expr = _lower_method_value_expr($split_args->[0], $deps);
  $source_expr = $trim_action_ir_value->($split_args->[0]) unless defined($source_expr) && length($source_expr);
  return undef unless defined($source_expr) && length($source_expr);

  my $delimiter_trimmed = $trim_action_ir_value->($split_args->[1]);
  return undef unless defined($delimiter_trimmed) && length($delimiter_trimmed);
  if ($delimiter_trimmed =~ m{^/(?:\\.|[^/])*/[a-z]*$}io) {
   return 'do { my $__ls_split_value = '.$source_expr.'; defined($__ls_split_value) ? [split '.$delimiter_trimmed.', $__ls_split_value, -1] : [] }';
  }

  my $delimiter_expr = _lower_method_value_expr($split_args->[1], $deps);
  $delimiter_expr = $delimiter_trimmed unless defined($delimiter_expr) && length($delimiter_expr);
  return 'do { my $__ls_split_value = '.$source_expr.'; my $__ls_split_delimiter = '.$delimiter_expr.'; (defined($__ls_split_value) && defined($__ls_split_delimiter)) ? [split /\Q$__ls_split_delimiter\E/, $__ls_split_value, -1] : [] }';
 }
 if ($method_call && $method_call->{method} eq 'split_tagged_records') {
  my $record_args = $method_call->{args} || [];
  return undef unless ref($record_args) eq 'ARRAY' && @$record_args >= 3;

  my $source_expr = _lower_method_value_expr($record_args->[0], $deps);
  $source_expr = $trim_action_ir_value->($record_args->[0]) unless defined($source_expr) && length($source_expr);
  return undef unless defined($source_expr) && length($source_expr);

  my $delimiter_expr = $trim_action_ir_value->($record_args->[1]);
  return undef unless defined($delimiter_expr) && length($delimiter_expr);
  if ($delimiter_expr !~ m{^/(?:\\.|[^/])*/[a-z]*$}io) {
   my $literal = $strip_literal_delimiters->($delimiter_expr);
   return undef unless defined $literal;
   $delimiter_expr = '/'.quotemeta($literal).'/';
  }

  my $tag_expr = _normalize_method_tag_expr($record_args->[2], $deps);
  return undef unless defined($tag_expr) && length($tag_expr);

  my @payload = ($tag_expr, '$_');
  foreach my $arg (@{$record_args}[3 .. $#$record_args]) {
   my $field_expr = _lower_method_value_expr($arg, $deps);
   $field_expr = $trim_action_ir_value->($arg) unless defined($field_expr) && length($field_expr);
   return undef unless defined($field_expr) && length($field_expr);
   push @payload, $field_expr;
  }
  return '[map { ['.join(', ', @payload).'] } split '.$delimiter_expr.', '.$source_expr.']';
 }
 if ($method_call && $method_call->{method} eq 'sorted') {
  my $sorted_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $sorted_args;

  my $target_expr = $trim_action_ir_value->($sorted_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
   return '[sort { (defined($a) ? $a : "") cmp (defined($b) ? $b : "") } @'.$array_symbol.']';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_sorted = '.$lowered_target.'; defined($__ls_sorted) && ref($__ls_sorted) eq \'ARRAY\' ? [sort { (defined($a) ? $a : "") cmp (defined($b) ? $b : "") } @{$__ls_sorted}] : [] }';
 }
 if ($method_call && $method_call->{method} eq 'reversed') {
  my $reversed_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $reversed_args;

  my $target_expr = $trim_action_ir_value->($reversed_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $array_symbol = $extract_array_symbol_name->($target_expr);
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
   return '[reverse @'.$array_symbol.']';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_reversed = '.$lowered_target.'; defined($__ls_reversed) && ref($__ls_reversed) eq \'ARRAY\' ? [reverse @{$__ls_reversed}] : [] }';
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
  if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
   return 'do { my $__ls_contains_needle = '.$needle_expr.'; ((defined($__ls_contains_needle) ? scalar(grep { defined($_) && $_ eq $__ls_contains_needle } @'.$array_symbol.') : scalar(grep { !defined($_) } @'.$array_symbol.')) ? 1 : 0) }';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

 return 'do { my $__ls_contains_array = '.$lowered_target.'; my $__ls_contains_needle = '.$needle_expr.'; defined($__ls_contains_array) ? ((defined($__ls_contains_needle) ? scalar(grep { defined($_) && $_ eq $__ls_contains_needle } @{$__ls_contains_array}) : scalar(grep { !defined($_) } @{$__ls_contains_array})) ? 1 : 0) : 0 }';
}
if ($method_call && $method_call->{method} eq 'index_of') {
 my $index_of_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, 2);
 return undef unless $index_of_args;

 my $target_expr = $trim_action_ir_value->($index_of_args->[0]);
 my $needle_expr = _lower_method_value_expr($index_of_args->[1], $deps);
 $needle_expr = $trim_action_ir_value->($index_of_args->[1]) unless defined($needle_expr) && length($needle_expr);
 return undef unless defined($target_expr) && length($target_expr);
 return undef unless defined($needle_expr) && length($needle_expr);

 my $array_symbol = $extract_array_symbol_name->($target_expr);
 if (defined($array_symbol) && length($array_symbol) && $target_expr =~ $array_symbol_expr_re) {
  return 'do { my $__ls_index_of_needle = '.$needle_expr.'; my $__ls_index_of_found; for (my $__ls_index_of_i = 0; $__ls_index_of_i < scalar(@'.$array_symbol.'); $__ls_index_of_i++) { my $__ls_index_of_item = $'.$array_symbol.'[$__ls_index_of_i]; if (defined($__ls_index_of_needle) ? (defined($__ls_index_of_item) && $__ls_index_of_item eq $__ls_index_of_needle) : !defined($__ls_index_of_item)) { $__ls_index_of_found = $__ls_index_of_i; last; } } $__ls_index_of_found }';
 }

 my $lowered_target = _lower_method_value_expr($target_expr, $deps);
 $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
 return undef unless defined($lowered_target) && length($lowered_target);

 return 'do { my $__ls_index_of_array = '.$lowered_target.'; my $__ls_index_of_needle = '.$needle_expr.'; if (defined($__ls_index_of_array) && ref($__ls_index_of_array) eq \'ARRAY\') { my $__ls_index_of_found; for (my $__ls_index_of_i = 0; $__ls_index_of_i < scalar(@{$__ls_index_of_array}); $__ls_index_of_i++) { my $__ls_index_of_item = $__ls_index_of_array->[$__ls_index_of_i]; if (defined($__ls_index_of_needle) ? (defined($__ls_index_of_item) && $__ls_index_of_item eq $__ls_index_of_needle) : !defined($__ls_index_of_item)) { $__ls_index_of_found = $__ls_index_of_i; last; } } $__ls_index_of_found } else { undef } }';
}
 if ($method_call && $method_call->{method} eq 'count_keys') {
  my $count_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $count_args;

  my $target_expr = $trim_action_ir_value->($count_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  my $target_kind = $remembered_bare_symbol_kind->($target_expr);
  if (
   defined($hash_symbol) &&
   length($hash_symbol) &&
   $target_expr =~ $hash_symbol_expr_re &&
   (($target_kind // '') ne 'scalar')
  ) {
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
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ $hash_symbol_expr_re) {
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
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ $hash_symbol_expr_re) {
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
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ $hash_symbol_expr_re) {
   return '((exists $'.$hash_symbol.'{'.$key_lowered.'}) ? 1 : 0)';
  }

  my $lowered_target = _lower_method_value_expr($target_expr, $deps);
  $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_has_key = '.$lowered_target.'; defined($__ls_has_key) ? ((exists $__ls_has_key->{'.$key_lowered.'}) ? 1 : 0) : 0 }';
 }
 if ($method_call && $method_call->{method} eq 'merge_hash') {
  my $merge_args = $normalize_collection_args->($method_call->{args} || [], 1, undef);
  return undef unless $merge_args && @$merge_args >= 1;

  my @parts;
  foreach my $arg (@$merge_args) {
   my $target_expr = $trim_action_ir_value->($arg);
   return undef unless defined($target_expr) && length($target_expr);

   my $hash_symbol = $extract_hash_symbol_name->($target_expr);
   if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ $hash_symbol_expr_re) {
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
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ $hash_symbol_expr_re) {
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
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ $hash_symbol_expr_re) {
   $lowered_target = '\\%'.$hash_symbol;
  } else {
   $lowered_target = _lower_method_value_expr($target_expr, $deps);
   $lowered_target = $target_expr unless defined($lowered_target) && length($lowered_target);
  }
  return undef unless defined($lowered_target) && length($lowered_target);

  return 'do { my $__ls_rename_key_source = '.$lowered_target.'; if (defined($__ls_rename_key_source)) { my %__ls_rename_key = %{$__ls_rename_key_source}; if (exists $__ls_rename_key{'.$old_key_lowered.'}) { my $__ls_rename_key_value = delete $__ls_rename_key{'.$old_key_lowered.'}; $__ls_rename_key{'.$new_key_lowered.'} = $__ls_rename_key_value; } \%__ls_rename_key } else { {} } }';
 }
 if ($method_call && $method_call->{method} eq 'drop_keys') {
  my $drop_args = $normalize_collection_args->($method_call->{args} || [], 2, undef);
  return undef unless $drop_args && @$drop_args >= 2;

  my $target_expr = $trim_action_ir_value->($drop_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);

  my $lowered_target;
  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ $hash_symbol_expr_re) {
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
  my $pick_args = $normalize_collection_args->($method_call->{args} || [], 2, undef);
  return undef unless $pick_args && @$pick_args >= 2;

  my $target_expr = $trim_action_ir_value->($pick_args->[0]);
  return undef unless defined($target_expr) && length($target_expr);
  my $hash_symbol = $extract_hash_symbol_name->($target_expr);
  my $lowered_target;
  if (defined($hash_symbol) && length($hash_symbol) && $target_expr =~ $hash_symbol_expr_re) {
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
  if (defined($array_symbol) && length($array_symbol) && $array_expr =~ $array_symbol_expr_re) {
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
 if ($method_call && $method_call->{method} eq 'coalesce_nonempty') {
  my $coalesce_nonempty_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 2, undef);
  return undef unless $coalesce_nonempty_args && @$coalesce_nonempty_args >= 2;

  my @lowered_args;
  foreach my $arg (@$coalesce_nonempty_args) {
   my $lowered_arg = _lower_method_value_expr($arg, $deps);
   $lowered_arg = $trim_action_ir_value->($arg) unless defined($lowered_arg) && length($lowered_arg);
   return undef unless defined($lowered_arg) && length($lowered_arg);
   push @lowered_args, $lowered_arg;
  }

  my $build_coalesce_nonempty_expr;
  $build_coalesce_nonempty_expr = sub {
   my (@parts) = @_;
   return $parts[0] if @parts == 1;

   my $head = shift @parts;
   my $tail_expr = $build_coalesce_nonempty_expr->(@parts);
   return 'do { my $__ls_coalesce_nonempty = '.$head.'; (defined($__ls_coalesce_nonempty) && $__ls_coalesce_nonempty ne \'\') ? $__ls_coalesce_nonempty : '.$tail_expr.' }';
  };

  return $build_coalesce_nonempty_expr->(@lowered_args);
 }
 my $flat_list_expr = $lower_flat_list_value_expr->($trimmed);
 return $flat_list_expr if defined($flat_list_expr) && length($flat_list_expr);
 # `copy(NAME)` snapshots the one runtime-typed binding. Temporary selector
 # recognition remains below only until the hard-retirement leaf removes it.
 if ($method_call && $method_call->{method} eq 'copy') {
  my $copy_args = $normalize_method_args_with_optional_scope->($method_call->{args} || [], 1, 1);
  return undef unless $copy_args;

  my $container_expr = $trim_action_ir_value->($copy_args->[0]);
  return undef unless defined($container_expr) && length($container_expr);

  my $remembered_kind = $remembered_bare_symbol_kind->($container_expr);
  if (defined($remembered_kind) && $remembered_kind eq 'hash') {
   my $hash_symbol = $extract_hash_symbol_name->($container_expr);
   return '{%'.$hash_symbol.'}' if defined($hash_symbol) && length($hash_symbol);
  }
  if (defined($remembered_kind) && $remembered_kind eq 'array') {
   my $array_symbol = $extract_array_symbol_name->($container_expr);
   return '[@'.$array_symbol.']' if defined($array_symbol) && length($array_symbol);
  }
  if ((!defined($remembered_kind) || $remembered_kind eq 'scalar')
      && $container_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
   my $name = $1;
   return 'do { my $__ls_copy_value = $'.$name.'; '
    .'(defined($__ls_copy_value) && ref($__ls_copy_value) eq \'ARRAY\') ? [@{$__ls_copy_value}] : '
    .'(defined($__ls_copy_value) && ref($__ls_copy_value) eq \'HASH\') ? { %{$__ls_copy_value} } : [] }';
  }
  if ($container_expr =~ /^array\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o) {
   my $name = $1;
   return $lower_scalar_bound_array_snapshot_expr->($name)
    if (($bare_symbol_kind->($name) // '') eq 'scalar');
  }
  if ($container_expr =~ /^hash\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o) {
   my $name = $1;
   return $lower_scalar_bound_hash_snapshot_expr->($name)
    if (($bare_symbol_kind->($name) // '') eq 'scalar');
  }

  my $array_symbol = $extract_array_symbol_name->($container_expr);
  if (defined($array_symbol) && length($array_symbol) && $container_expr =~ $array_symbol_expr_re) {
   return '[@'.$array_symbol.']';
  }
  my $hash_symbol = $extract_hash_symbol_name->($container_expr);
  if (defined($hash_symbol) && length($hash_symbol) && $container_expr =~ $hash_symbol_expr_re) {
   return '{%'.$hash_symbol.'}';
  }
  my $container_kind = _infer_assignment_source_container_kind($container_expr, $deps);
  if (defined($container_kind) && $container_kind eq 'array') {
   my $lowered_container = _lower_method_value_expr($container_expr, $deps);
   return undef unless defined($lowered_container) && length($lowered_container);
   return 'do { my $__ls_array_snapshot = '.$lowered_container.'; (defined($__ls_array_snapshot) && ref($__ls_array_snapshot) eq \'ARRAY\') ? [@{$__ls_array_snapshot}] : [] }';
  }
  if (defined($container_kind) && $container_kind eq 'hash') {
   my $lowered_container = _lower_method_value_expr($container_expr, $deps);
   return undef unless defined($lowered_container) && length($lowered_container);
   return 'do { my $__ls_hash_snapshot = '.$lowered_container.'; (defined($__ls_hash_snapshot) && ref($__ls_hash_snapshot) eq \'HASH\') ? { %{$__ls_hash_snapshot} } : {} }';
  }
  return undef;
 }
 my $pipeline_expr = $lower_array_pipeline_expr->($trimmed);
 return $pipeline_expr if defined($pipeline_expr) && length($pipeline_expr);
 if ($trimmed =~ /^hash\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))$/o) {
  my $payload = $+{PAREN};
  $payload =~ s/^\(|\)$//go;
  my $args = $split_top_level_csv->($payload);
  if (@$args == 1) {
   my $arg_expr = $trim_action_ir_value->($args->[0]);
   if (defined($arg_expr) && $arg_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
    my $name = $1;
    return $lower_scalar_bound_hash_snapshot_expr->($name)
     if (($bare_symbol_kind->($name) // '') eq 'scalar');
   }
   my $hash_symbol = $extract_hash_symbol_name->($trimmed);
   return '{%'.$hash_symbol.'}' if defined($hash_symbol) && length($hash_symbol) && $trimmed =~ $hash_symbol_expr_re;
  }
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
   my $val_expr = $lower_shape_member_expr->($args->[$i + 1]);
   $val_expr = _lower_method_value_expr($args->[$i + 1], $deps)
    unless defined($val_expr) && length($val_expr);
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
  if (@$args == 1) {
   my $arg_expr = $trim_action_ir_value->($args->[0]);
   if (defined($arg_expr) && $arg_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
    my $name = $1;
    return $lower_scalar_bound_array_snapshot_expr->($name)
     if (($bare_symbol_kind->($name) // '') eq 'scalar');
   }
   my $array_symbol = $extract_array_symbol_name->($trimmed);
   return '[@'.$array_symbol.']' if defined($array_symbol) && length($array_symbol) && $trimmed =~ $array_symbol_expr_re;
  }
  my @lowered = map {
   my $ast_arg = _parse_method_value_ast_expr($_, $deps);
   my $lowered_arg = ref($ast_arg) eq 'HASH'
    ? $lower_ast_value_node->($ast_arg, { bare_scalar_read => 1 })
    : undef;
   $lowered_arg = $lower_shape_member_expr->($_)
    unless defined($lowered_arg) && length($lowered_arg);
   $lowered_arg = _lower_method_value_expr($_, $deps)
    unless defined($lowered_arg) && length($lowered_arg);
   defined($lowered_arg) && length($lowered_arg) ? $lowered_arg : $_;
  } @$args;
  return '['.join(', ', @lowered).']';
 }

 if ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o
  && (($bare_symbol_kind->($1) // '') eq 'scalar')) {
  return '$'.$1;
 }

 return $trimmed
}

#------------------------------------------------------------------------------
# Function: _lower_source_slot_bare_scalar_read_expr
# Purpose : Lower one accepted source-slot identifier using initialized bare-name
#           type memory. Bare `NAME` reads the remembered array/hash/scalar kind,
#           defaulting to scalar; retired `:NAME` emits the migration diagnostic.
# Args    : ($expr, $deps)
# Returns : Perl value expression, or undef for non-source-slot bare reads
#------------------------------------------------------------------------------
sub _lower_source_slot_bare_scalar_read_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
	  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
	  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
	   unless ref($cb) eq 'CODE';
	  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')
  ? $deps->{bare_symbol_kind}
  : sub { return undef };

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $name;
 if ($trimmed =~ /^:([A-Za-z_][A-Za-z0-9_]*)$/o) {
  return _actionir_ast_retired_colon_scalar_slot_expr($1);
 } elsif ($trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
  $name = $1;
 } else {
  return undef;
 }
 return undef if $name =~ /^(?:undef|true|false|descr|STRING|info|minfo|IMATCH|IMATCH_LIST|IMATCH_HASH|IINDEX|IPOS|LMATCH|LMATCH_LIST|LMATCH_HASH|LINDEX|LSPOS|CAPTURE)$/o;
 my $kind = $bare_symbol_kind->($name);
 return '[@'.$name.']' if defined($kind) && $kind eq 'array';
 return '{%'.$name.'}' if defined($kind) && $kind eq 'hash';
 return '$'.$name
}

#------------------------------------------------------------------------------
# Function: _lower_mutation_slot_value_expr
# Purpose : Lower one accepted mutation value slot. A non-reserved bare identifier
#           is a scalar working-variable read for SPEC-FORMAT-TERSE.1.2.3.3.2;
#           primitive literals and explicit helper/value expressions keep their
#           existing lowering. Reserved engine locals are not claimed here.
# Args    : ($expr, $deps)
# Returns : Perl value expression string or undef when this slot is not accepted
#------------------------------------------------------------------------------
sub _lower_mutation_slot_value_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_primitive_literal_expr = $require_dep->('lower_primitive_literal_expr');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ /^:([A-Za-z_][A-Za-z0-9_]*)$/o) {
  _trace_method_decision(
   phase => 'lower_mutation_slot_value_expr',
   label => 'value',
   decision => 'retired_colon_scalar_slot',
   taken => 1,
   context => { symbol => $1 },
  );
  return _actionir_ast_retired_colon_scalar_slot_expr($1);
 }

 my $bare_scalar_read = _lower_source_slot_bare_scalar_read_expr($trimmed, $deps);
 if (defined($bare_scalar_read) && length($bare_scalar_read)) {
  _trace_method_decision(
   phase => 'lower_mutation_slot_value_expr',
   label => 'value',
   decision => 'bare_scalar_read',
   taken => 1,
   context => {},
  );
  return $bare_scalar_read;
 }

 my $literal = $lower_primitive_literal_expr->($trimmed);
 if (defined($literal)) {
  _trace_method_decision(
   phase => 'lower_mutation_slot_value_expr',
   label => 'value',
   decision => 'primitive_literal',
   taken => 1,
   context => {},
  );
  return $literal;
 }
 return undef if $trimmed =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;

 if (ref($lower_flow_composite_expr) eq 'CODE') {
  my $flow_expr = $lower_flow_composite_expr->($trimmed);
  if (defined($flow_expr) && length($flow_expr) && $flow_expr ne $trimmed) {
   _trace_method_decision(
    phase => 'lower_mutation_slot_value_expr',
    label => 'value',
    decision => 'flow_value_source',
    taken => 1,
    context => {},
   );
   return $flow_expr;
  }
 }

 my $lowered = _lower_method_value_expr($trimmed, $deps);
 $lowered = $trimmed unless defined($lowered) && length($lowered);
 _trace_method_decision(
  phase => 'lower_mutation_slot_value_expr',
  label => 'value',
  decision => 'method_value_source',
  taken => 1,
  context => {},
 );
 return $lowered
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
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $ast_node = _parse_method_value_ast_expr($trimmed, $deps);
 my $ast_kind = ref($ast_node) eq 'HASH' ? ($ast_node->{kind} // '') : '';
 my $direct = _lower_method_value_expr($trimmed, $deps);
 if (defined($direct) && length($direct) && $ast_kind ne '' && $ast_kind ne 'raw_perl' && $ast_kind ne 'variable') {
  _trace_method_decision(
   phase => 'lower_return_payload_expr',
   label => 'payload',
   decision => 'ast_direct_payload',
   taken => 1,
   context => { ast_kind => $ast_kind },
  );
  return $direct;
 }
 if (
  defined($direct) &&
  length($direct) &&
  ($trimmed =~ /^(?:array|hash|input_slice|trim|lowercase|uppercase|length|substr|replace_substr|rm_prefix|rm_suffix|cat|split|num_abs|num_floor|num_ceil|num_round|num_sum|num_avg|num_median|num_range|num_add|num_sub|num_mul|num_div|num_mod|num_clamp|num_min|num_max|abs|floor|ceil|round|sum|avg|median|range|add|sub|mul|div|mod|clamp|min|max|eq|ne|gt|ge|lt|le|str_eq|str_ne|str_gt|str_ge|str_lt|str_le|starts_with|ends_with|contains_substr|matches|coalesce_nonempty|is_empty|is_nonempty|count|first|last|drop_front|take|slice|take_last|drop_back|concat_arrays|split_tagged_records|sorted|reversed|contains|index_of|count_keys|sorted_keys|sorted_values|has_key|merge_hash|set_key|rename_key|drop_keys|pick_keys|join_values|coalesce|copy|flat_array|flat_hash|flat)\s*\(/o || $direct ne $trimmed)
 ) {
 _trace_method_decision(
  phase => 'lower_return_payload_expr',
  label => 'payload',
  decision => 'method_payload',
  taken => 1,
  context => { ast_kind => $ast_kind },
 );
 return $direct;
 }

 my $bare_scalar_read = _lower_source_slot_bare_scalar_read_expr($trimmed, $deps);
 if (defined($bare_scalar_read) && length($bare_scalar_read)) {
  _trace_method_decision(
   phase => 'lower_return_payload_expr',
   label => 'payload',
   decision => 'bare_scalar_payload',
   taken => 1,
   context => {},
  );
  return $bare_scalar_read;
 }

 # Legacy raw fallback: shipped compatibility payloads such as
 # `\(my $capt = capture_slice())` are not typed ActionIR values yet.
 my $rewritten = $trimmed;
 for (1 .. 64) {
  my $before = $rewritten;
  $rewritten =~ s/\b(?<helper>(?:copy|input_slice|trim|lowercase|uppercase|length|substr|replace_substr|rm_prefix|rm_suffix|cat|split|num_abs|num_floor|num_ceil|num_round|num_sum|num_avg|num_median|num_range|num_add|num_sub|num_mul|num_div|num_mod|num_clamp|num_min|num_max|abs|floor|ceil|round|sum|avg|median|range|add|sub|mul|div|mod|clamp|min|max|eq|ne|gt|ge|lt|le|str_eq|str_ne|str_gt|str_ge|str_lt|str_le|starts_with|ends_with|contains_substr|matches|coalesce_nonempty|is_empty|is_nonempty|count|first|last|drop_front|take|slice|take_last|drop_back|concat_arrays|split_tagged_records|sorted|reversed|contains|index_of|count_keys|sorted_keys|sorted_values|has_key|merge_hash|set_key|rename_key|drop_keys|pick_keys|join_values|coalesce|flat_array|flat_hash|flat|array|hash)\s*(?<PAREN>\((?:[^\(\)\"']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/do {
   my $lowered = _lower_method_value_expr($+{helper}, $deps);
   (defined($lowered) && length($lowered)) ? $lowered : $+{helper};
  }/ge;
 last if $rewritten eq $before;
 }
 _trace_method_decision(
  phase => 'lower_return_payload_expr',
  label => 'payload',
  decision => $rewritten eq $trimmed ? 'legacy_raw_payload' : 'legacy_rewritten_payload',
  taken => 1,
  context => {},
 );
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
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');

 my $ast_lowered = _lower_ast_call_statement($expr, 'return', $deps);
 return $ast_lowered if defined($ast_lowered) && length($ast_lowered);

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'return';

 my $args = $call->{args} || [];
 return undef unless ref($args) eq 'ARRAY';

 if (@$args >= 2) {
  my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
  my $label = $trim_action_ir_value->($args->[0]);
  return undef unless defined($label) && $label =~ /^\w+$/o;
  my @payloads;
  foreach my $payload_arg (@{$args}[1 .. $#$args]) {
   my $payload = _lower_return_payload_expr($payload_arg, $deps);
   $payload = $trim_action_ir_value->($payload_arg) unless defined($payload) && length($payload);
   return undef unless defined($payload) && length($payload);
   push @payloads, $payload;
  }
  return "return ['?$label:',  ".join(', ', @payloads)."]"
 }

 return undef unless @$args == 1;
 my $payload = _lower_return_payload_expr($args->[0], $deps);
 return undef unless defined($payload) && length($payload);
 return "return $payload"
}

#------------------------------------------------------------------------------
# Function: _lower_assign_statement
# Purpose : Lower assignment-helper target/source pairs for `set(target, source)`.
# Args    : ($target, $source, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_assign_statement {
 my ($target, $source, $deps) = @_;
 my $scope = _trace_method_enter(
  'lower_assign_statement',
  'assignment',
  { target => defined($target) ? $target : '<undef>', source => defined($source) ? $source : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  return _trace_method_finish($scope, 'lower_assign_statement', 'assignment', $result, $decision, $context);
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $extract_scalar_symbol_name = $require_dep->('extract_scalar_symbol_name');
 my $extract_array_symbol_name = $require_dep->('extract_array_symbol_name');
 my $extract_hash_symbol_name = $require_dep->('extract_hash_symbol_name');
 my $lower_assignment_source_expr = $require_dep->('lower_assignment_source_expr');
 my $lower_declare_initializer_expr = $require_dep->('lower_declare_initializer_expr');
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 my $target_trimmed = $trim_action_ir_value->($target);
 if (defined($target_trimmed) && $target_trimmed =~ /^:([A-Za-z_][A-Za-z0-9_]*)$/o) {
  my $diagnostic = _actionir_ast_retired_colon_scalar_slot_expr($1);
  return $finish->($diagnostic, 'retired_colon_scalar_slot_target', { target => $1 });
 }
 if (defined($target_trimmed) && $target_trimmed =~ /^[A-Za-z_][A-Za-z0-9_]*$/o) {
  my $source_expr = _lower_value_binding_source_expr($source, $deps);
  return $finish->(undef, 'bare_value_target_failed', { target => $target_trimmed }) unless defined($source_expr) && length($source_expr);
  return $finish->("\$$target_trimmed = $source_expr", 'bare_value_target', { target => $target_trimmed });
 }
 if (defined($target_trimmed)
  && $target_trimmed =~ /^(?:array|hash)\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o) {
  my $target_name = $1;
  my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')
   ? $deps->{bare_symbol_kind}
   : sub { return undef };
  if (($bare_symbol_kind->($target_name) // '') eq 'scalar') {
   my $source_expr = _lower_value_binding_source_expr($source, $deps);
   return $finish->(undef, 'scalar_held_wrapper_target_failed', { target => $target_name })
    unless defined($source_expr) && length($source_expr);
   return $finish->('$'.$target_name.' = '.$source_expr, 'scalar_held_wrapper_target', { target => $target_name });
  }
 }

 my $symbol = $extract_scalar_symbol_name->($target);
 if (defined $symbol) {
  my $source_expr = $lower_assignment_source_expr->($source);
  return $finish->(undef, 'scalar_target_failed', { target => $symbol }) unless defined $source_expr;
  return $finish->("\$$symbol = $source_expr", 'scalar_target', { target => $symbol });
 }

 my $array_symbol = $extract_array_symbol_name->($target);
 if (defined $array_symbol) {
  my $source_expr = $lower_declare_initializer_expr->('array', $source);
  return $finish->(undef, 'array_target_failed', { target => $array_symbol }) unless defined $source_expr;
  return $finish->("\@$array_symbol = $source_expr", 'array_target', { target => $array_symbol });
 }

 my $hash_symbol = $extract_hash_symbol_name->($target);
 if (defined $hash_symbol) {
  my $source_expr = $lower_declare_initializer_expr->('hash', $source);
  return $finish->(undef, 'hash_target_failed', { target => $hash_symbol }) unless defined $source_expr;
  return $finish->("\%$hash_symbol = $source_expr", 'hash_target', { target => $hash_symbol });
 }

 return $finish->(undef, 'unsupported_assignment_target', {})
}

#------------------------------------------------------------------------------
# Function: _lower_scalar_assignment_operator_statement
# Purpose : Lower the statement form `name = value` to the same scalar mutation
#           emitted for `set(name, value)`.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_scalar_assignment_operator_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $ast_lowered = _lower_ast_assignment_operator_statement(
  _parse_method_value_ast_expr($trimmed, $deps),
  $deps,
  'assign_scalar',
 );
 if (defined($ast_lowered) && length($ast_lowered)) {
  _trace_method_decision(
   phase => 'lower_scalar_assignment_operator_statement',
   label => 'assignment',
   decision => 'ast_scalar_assignment_operator',
   taken => 1,
   context => {},
  );
  return $ast_lowered;
 }
 return undef unless $trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=|>)\s*(.+)$/s;

 my ($target_symbol, $source) = ($1, $2);
 $source = $trim_action_ir_value->($source);
 return undef unless defined($source) && length($source);

 my $source_expr = _lower_value_binding_source_expr($source, $deps);
 return undef unless defined($source_expr) && length($source_expr);
 _trace_method_decision(
  phase => 'lower_scalar_assignment_operator_statement',
  label => 'assignment',
  decision => 'scalar_assignment_operator',
  taken => 1,
  context => { target => $target_symbol },
 );
 return '$'.$target_symbol.' = '.$source_expr
}

#------------------------------------------------------------------------------
# Function: _lower_array_append_operator_statement
# Purpose : Lower the statement form `items += value` to the same explicit array
#           append emitted for accepted `push(items, value)` shapes. Bare RHS
#           identifiers are scoped scalar reads in this
#           mutation value slot.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_array_append_operator_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $ast_lowered = _lower_ast_assignment_operator_statement(
  _parse_method_value_ast_expr($trimmed, $deps),
  $deps,
  'assign_array_append',
 );
 if (defined($ast_lowered) && length($ast_lowered)) {
  _trace_method_decision(
   phase => 'lower_array_append_operator_statement',
   label => 'assignment',
   decision => 'ast_array_append_operator',
   taken => 1,
   context => {},
  );
  return $ast_lowered;
 }
 return undef unless $trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*\+=\s*(.+)$/s;

 my ($target_symbol, $value) = ($1, $2);
 $value = $trim_action_ir_value->($value);
 return undef unless defined($value) && length($value);
 my $lowered_value = _lower_mutation_slot_value_expr($value, $deps);
 return undef unless defined($lowered_value) && length($lowered_value);
 _trace_method_decision(
  phase => 'lower_array_append_operator_statement',
  label => 'assignment',
  decision => 'array_append_operator',
  taken => 1,
  context => { target => $target_symbol },
 );
 return _uniform_binding_array_push_expr($target_symbol, $lowered_value)
}

sub _split_receiver_dot_method_expr {
 my ($expr, $trim_action_ir_value) = @_;
 return undef unless defined($expr) && length($expr);
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my ($paren_depth, $bracket_depth, $brace_depth) = (0, 0, 0);
 my ($in_single_quote, $in_double_quote, $escape_next) = (0, 0, 0);
 my $len = length($trimmed);
 for (my $idx = 0; $idx < $len; ++$idx) {
  my $ch = substr($trimmed, $idx, 1);
  if ($in_single_quote) {
   if ($escape_next) { $escape_next = 0; }
   elsif ($ch eq '\\') { $escape_next = 1; }
   elsif ($ch eq "'") { $in_single_quote = 0; }
   next;
  }
  if ($in_double_quote) {
   if ($escape_next) { $escape_next = 0; }
   elsif ($ch eq '\\') { $escape_next = 1; }
   elsif ($ch eq '"') { $in_double_quote = 0; }
   next;
  }
  if ($ch eq "'") { $in_single_quote = 1; next; }
  if ($ch eq '"') { $in_double_quote = 1; next; }
  if ($ch eq '(') { ++$paren_depth; next; }
  if ($ch eq ')') { --$paren_depth if $paren_depth > 0; next; }
 if ($ch eq '[') { ++$bracket_depth; next; }
 if ($ch eq ']') { --$bracket_depth if $bracket_depth > 0; next; }
 if ($ch eq '{') { ++$brace_depth; next; }
 if ($ch eq '}') { --$brace_depth if $brace_depth > 0; next; }
  next unless $ch eq '.';
  if ($idx > 0 && $idx + 1 < $len) {
   my $prev_ch = substr($trimmed, $idx - 1, 1);
   my $next_ch = substr($trimmed, $idx + 1, 1);
   next if $prev_ch =~ /\d/o && $next_ch =~ /\d/o;
  }
  next unless $paren_depth == 0 && $bracket_depth == 0 && $brace_depth == 0;
  my $receiver = $trim_action_ir_value->(substr($trimmed, 0, $idx));
  my $call_expr = $trim_action_ir_value->(substr($trimmed, $idx + 1));
  return undef unless defined($receiver) && length($receiver);
  return undef unless defined($call_expr) && length($call_expr);
  return [$receiver, $call_expr];
 }
 return undef;
}

sub _is_array_receiver_value_chain_method {
 my ($method) = @_;
 return 0 unless defined $method;
 return $method =~ /^(?:copy|sorted|reversed|take|take_last|drop_front|drop_back|slice|concat_arrays|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match|count|first|last|contains|index_of|is_empty|is_nonempty|join_values|sum|avg|median|range|min|max)$/o ? 1 : 0
}

sub _hash_receiver_value_chain_return_family {
 my ($method) = @_;
 return undef unless defined $method;
 return 'hash' if $method =~ /^(?:copy|merge_hash|set_key|rename_key|drop_keys|pick_keys|flat_hash|walk_leaves|map_leaves)$/o;
 return 'array' if $method =~ /^(?:sorted_keys|sorted_values)$/o;
 return 'terminal' if $method =~ /^(?:count_keys|has_key|reduce_leaves)$/o;
 return undef
}

sub _is_hash_receiver_value_chain_method {
 my ($method) = @_;
 return defined(_hash_receiver_value_chain_return_family($method)) ? 1 : 0
}

sub _is_tree_traversal_receiver_method {
 my ($method) = @_;
 return 0 unless defined $method;
 return $method =~ /^(?:walk_leaves|map_leaves|reduce_leaves)$/o ? 1 : 0
}

sub _string_receiver_value_chain_return_family {
 my ($method) = @_;
 return undef unless defined $method;
 return 'string' if $method =~ /^(?:trim|lowercase|uppercase|replace_substr|rm_prefix|rm_suffix|substr|cat|coalesce_nonempty)$/o;
 return 'array' if $method =~ /^(?:split)$/o;
 return 'terminal' if $method =~ /^(?:length|starts_with|ends_with|contains_substr|matches)$/o;
 return undef
}

sub _is_string_receiver_value_chain_method {
 my ($method) = @_;
 return defined(_string_receiver_value_chain_return_family($method)) ? 1 : 0
}

sub _number_receiver_method_helper_name {
 my ($method) = @_;
 return undef unless defined $method;
 return 'num_'.$method if $method =~ /^(?:abs|floor|ceil|round|add|sub|mul|div|mod|min|max|clamp|eq|ne|gt|ge|lt|le)$/o;
 return undef
}

sub _numeric_word_alias_helper_name {
 my ($method) = @_;
 return undef unless defined $method;
 state %symbol_alias = (
  '+' => 'num_add',
  '-' => 'num_sub',
  '*' => 'num_mul',
  '/' => 'num_div',
  '%' => 'num_mod',
  '==' => 'num_eq',
  '!=' => 'num_ne',
  '>' => 'num_gt',
  '>=' => 'num_ge',
  '<' => 'num_lt',
  '<=' => 'num_le',
 );
 return $symbol_alias{$method} if exists $symbol_alias{$method};
 return 'num_'.$method if $method =~ /^(?:abs|floor|ceil|round|sum|avg|median|range|add|sub|mul|div|mod|clamp|min|max|eq|ne|gt|ge|lt|le)$/o;
 return undef
}

sub _number_receiver_value_chain_return_family {
 my ($method) = @_;
 return undef unless defined $method;
 return 'number' if $method =~ /^(?:abs|floor|ceil|round|add|sub|mul|div|mod|min|max|clamp)$/o;
 return 'terminal' if $method =~ /^(?:eq|ne|gt|ge|lt|le)$/o;
 return undef
}

sub _is_number_receiver_value_chain_method {
 my ($method) = @_;
 return defined(_number_receiver_value_chain_return_family($method)) ? 1 : 0
}

sub _normalize_array_receiver_value_chain_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')
  ? $deps->{bare_symbol_kind}
  : sub { return undef };

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $split = _split_receiver_dot_method_expr($trimmed, $trim_action_ir_value);
 return undef unless $split;
 my ($receiver_expr, $tail_expr) = @$split;
 return undef if defined($receiver_expr) && $receiver_expr =~ /^hash\s*\(/o;

 my @calls;
 while (defined($tail_expr) && length($tail_expr)) {
  my $tail_split = _split_receiver_dot_method_expr($tail_expr, $trim_action_ir_value);
  my $call_expr = $tail_split ? $tail_split->[0] : $tail_expr;
  my $call = $parse_method_function_expr->($call_expr);
  return undef unless $call;
  my $method = $call->{method} // '';
  return undef if $method =~ /^(?:push_front|push_back|pop_front|pop_back)$/o;
  return undef unless _is_array_receiver_value_chain_method($method);
  push @calls, $call;
  last unless $tail_split;
  $tail_expr = $tail_split->[1];
 }
 return undef unless @calls;
 _trace_method_decision(
  phase => 'normalize_array_receiver_value_chain_expr',
  label => 'receiver_chain',
  decision => 'array_receiver_chain',
  taken => 1,
  context => { first_method => $calls[0]{method}, steps => scalar(@calls) },
 );

 my $current_expr = $receiver_expr;
 my $current_family = 'array';
 for (my $idx = 0; $idx < @calls; ++$idx) {
  return 'undef' if $current_family eq 'terminal';
  my $call = $calls[$idx];
  my $method = $call->{method} // '';
  my @args = @{$call->{args} || []};
  _trace_method_decision(
   phase => 'normalize_array_receiver_value_chain_expr',
   label => 'receiver_chain',
   decision => 'array_chain_step',
   taken => 1,
   context => { method => $method, from_family => $current_family },
  );
  if ($method eq 'join_values') {
   return undef unless @args == 1;
   $current_expr = 'join_values('.$args[0].', '.$current_expr.')';
   $current_family = 'terminal';
   next;
  }
  if ($method =~ /^(?:sum|avg|median|range|min|max)$/o) {
   return undef unless @args == 0;
   $current_expr = $method.'('.$current_expr.')';
   $current_family = 'terminal';
   next;
  }
  if ($method =~ /^(?:split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)$/o) {
   $current_expr = '__array_value_'.$method.'('.join(', ', ($current_expr, @args)).')';
   $current_family = 'array';
   next;
  }
  $current_expr = $method.'('.join(', ', ($current_expr, @args)).')';
  $current_family = ($method =~ /^(?:copy|sorted|reversed|take|take_last|drop_front|drop_back|slice|concat_arrays)$/o)
   ? 'array'
   : 'terminal';
 }

 return $current_expr;
}

sub _normalize_number_receiver_value_chain_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $split = _split_receiver_dot_method_expr($trimmed, $trim_action_ir_value);
 return undef unless $split;
 my ($receiver_expr, $tail_expr) = @$split;
 return undef unless defined($receiver_expr) && length($receiver_expr);

 my @calls;
 while (defined($tail_expr) && length($tail_expr)) {
  my $tail_split = _split_receiver_dot_method_expr($tail_expr, $trim_action_ir_value);
  my $call_expr = $tail_split ? $tail_split->[0] : $tail_expr;
  my $call = $parse_method_function_expr->($call_expr);
  return undef unless $call;
  push @calls, $call;
  last unless $tail_split;
  $tail_expr = $tail_split->[1];
 }
 return undef unless @calls;
 return undef unless _is_number_receiver_value_chain_method($calls[0]->{method} // '');
 _trace_method_decision(
  phase => 'normalize_number_receiver_value_chain_expr',
  label => 'receiver_chain',
  decision => 'number_receiver_chain',
  taken => 1,
  context => { first_method => $calls[0]{method}, steps => scalar(@calls) },
 );

 my $current_expr = $receiver_expr;
 my $current_family = 'number';
 for (my $idx = 0; $idx < @calls; ++$idx) {
  my $call = $calls[$idx];
  my $method = $call->{method} // '';
  my @args = @{$call->{args} || []};
  my $is_last = ($idx == $#calls) ? 1 : 0;
  _trace_method_decision(
   phase => 'normalize_number_receiver_value_chain_expr',
   label => 'receiver_chain',
   decision => 'number_chain_step',
   taken => 1,
   context => { method => $method, from_family => $current_family },
  );

  return 'undef' if $current_family eq 'terminal';
  return undef unless $current_family eq 'number';

  my $return_family = _number_receiver_value_chain_return_family($method);
  return undef unless defined($return_family);
  my $helper = _number_receiver_method_helper_name($method);
  return undef unless defined($helper) && length($helper);

  if ($method =~ /^(?:abs|floor|ceil|round)$/o) {
   return undef unless @args == 0;
  } elsif ($method =~ /^(?:sub|div|mod|eq|ne|gt|ge|lt|le)$/o) {
   return undef unless @args == 1;
  } elsif ($method eq 'clamp') {
   return undef unless @args == 2;
  } elsif ($method =~ /^(?:add|mul|min|max)$/o) {
   return undef unless @args >= 1;
  } else {
   return undef;
  }

  $current_expr = $helper.'('.join(', ', ($current_expr, @args)).')';
  return 'undef' if $return_family eq 'terminal' && !$is_last;
  $current_family = $return_family;
 }

 return $current_expr;
}

sub _normalize_string_receiver_value_chain_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $split = _split_receiver_dot_method_expr($trimmed, $trim_action_ir_value);
 return undef unless $split;
 my ($receiver_expr, $tail_expr) = @$split;
 return undef unless defined($receiver_expr) && length($receiver_expr);

 my @calls;
 while (defined($tail_expr) && length($tail_expr)) {
  my $tail_split = _split_receiver_dot_method_expr($tail_expr, $trim_action_ir_value);
  my $call_expr = $tail_split ? $tail_split->[0] : $tail_expr;
  my $call = $parse_method_function_expr->($call_expr);
  return undef unless $call;
  $call->{__source_expr} = $call_expr;
  push @calls, $call;
  last unless $tail_split;
  $tail_expr = $tail_split->[1];
 }
 return undef unless @calls;
 return undef unless _is_string_receiver_value_chain_method($calls[0]->{method} // '');
 _trace_method_decision(
  phase => 'normalize_string_receiver_value_chain_expr',
  label => 'receiver_chain',
  decision => 'string_receiver_chain',
  taken => 1,
  context => { first_method => $calls[0]{method}, steps => scalar(@calls) },
 );

 my $current_expr = $receiver_expr;
 my $current_family = 'string';
 for (my $idx = 0; $idx < @calls; ++$idx) {
  my $call = $calls[$idx];
  my $method = $call->{method} // '';
  my @args = @{$call->{args} || []};
  my $is_last = ($idx == $#calls) ? 1 : 0;
  _trace_method_decision(
   phase => 'normalize_string_receiver_value_chain_expr',
   label => 'receiver_chain',
   decision => 'string_chain_step',
   taken => 1,
   context => { method => $method, from_family => $current_family },
  );

  if ($current_family eq 'string') {
   my $return_family = _string_receiver_value_chain_return_family($method);
   return undef unless defined($return_family);

   if ($method =~ /^(?:trim|lowercase|uppercase|length)$/o) {
    return undef unless @args == 0;
    $current_expr = $method.'('.$current_expr.')';
   } elsif ($method eq 'cat') {
    return undef unless @args >= 1;
    $current_expr = 'cat('.join(', ', ($current_expr, @args)).')';
   } else {
    $current_expr = $method.'('.join(', ', ($current_expr, @args)).')';
   }

   return 'undef' if $return_family eq 'terminal' && !$is_last;
   $current_family = $return_family;
   next;
  }

  if ($current_family eq 'array') {
   return undef unless _is_array_receiver_value_chain_method($method);
   if ($method eq 'join_values') {
    return undef unless @args == 1;
    $current_expr = 'join_values('.$args[0].', '.$current_expr.')';
    $current_family = 'terminal';
    next;
   }
   if ($method =~ /^(?:sum|avg|median|range|min|max)$/o) {
    return undef unless @args == 0;
    $current_expr = $method.'('.$current_expr.')';
    $current_family = 'terminal';
    next;
   }
   if ($method =~ /^(?:split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)$/o) {
    $current_expr = '__array_value_'.$method.'('.join(', ', ($current_expr, @args)).')';
    $current_family = 'array';
    next;
   }
   $current_expr = $method.'('.join(', ', ($current_expr, @args)).')';
   $current_family = ($method =~ /^(?:copy|sorted|reversed|take|take_last|drop_front|drop_back|slice|concat_arrays)$/o)
    ? 'array'
    : 'terminal';
   next;
  }

  return 'undef' if $current_family eq 'terminal';
  return undef;
 }

 return $current_expr;
}

sub _normalize_hash_receiver_value_chain_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $split = _split_receiver_dot_method_expr($trimmed, $trim_action_ir_value);
 return undef unless $split;
 my ($receiver_expr, $tail_expr) = @$split;
 return undef unless defined($receiver_expr) && length($receiver_expr);

 my @calls;
 while (defined($tail_expr) && length($tail_expr)) {
  my $tail_split = _split_receiver_dot_method_expr($tail_expr, $trim_action_ir_value);
  my $call_expr = $tail_split ? $tail_split->[0] : $tail_expr;
  my $call = $parse_method_function_expr->($call_expr);
  return undef unless $call;
  push @calls, $call;
  last unless $tail_split;
  $tail_expr = $tail_split->[1];
 }
 return undef unless @calls;
 return undef unless _is_hash_receiver_value_chain_method($calls[0]->{method} // '');
 if (($calls[0]->{method} // '') eq 'copy') {
  my $receiver_trimmed = $trim_action_ir_value->($receiver_expr);
  return undef unless defined($receiver_trimmed) && length($receiver_trimmed);
  my $copy_is_hash = 0;
  $copy_is_hash = 1 if $receiver_trimmed =~ /^hash\s*\(/o;
  $copy_is_hash = 0 if $receiver_trimmed =~ /^array\s*\(/o;
  if (!$copy_is_hash && $receiver_trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
   my $remembered_kind = $bare_symbol_kind->($1);
   $copy_is_hash = 1 if defined($remembered_kind) && $remembered_kind eq 'hash';
   return undef if defined($remembered_kind) && $remembered_kind eq 'array';
  }
  if (!$copy_is_hash && @calls > 1) {
   my $next_method = $calls[1]{method} // '';
   $copy_is_hash = 1 if defined(_hash_receiver_value_chain_return_family($next_method));
   return undef if !$copy_is_hash && _is_array_receiver_value_chain_method($next_method);
  }
  return undef unless $copy_is_hash;
 }
 _trace_method_decision(
  phase => 'normalize_hash_receiver_value_chain_expr',
  label => 'receiver_chain',
  decision => 'hash_receiver_chain',
  taken => 1,
  context => { first_method => $calls[0]{method}, steps => scalar(@calls) },
 );

 my $current_expr = $receiver_expr;
 my $current_family = 'hash';
 for (my $idx = 0; $idx < @calls; ++$idx) {
  my $call = $calls[$idx];
  my $method = $call->{method} // '';
  my @args = @{$call->{args} || []};
  my $is_last = ($idx == $#calls) ? 1 : 0;
  _trace_method_decision(
   phase => 'normalize_hash_receiver_value_chain_expr',
   label => 'receiver_chain',
   decision => 'hash_chain_step',
   taken => 1,
   context => { method => $method, from_family => $current_family },
  );

  if ($current_family eq 'hash') {
   my $return_family = _hash_receiver_value_chain_return_family($method);
   return undef unless defined($return_family);

	  if ($method eq 'copy') {
    return undef unless @args == 0;
    $current_expr = 'copy('.$current_expr.')';
   } elsif ($method eq 'flat_hash') {
    return undef unless @args == 0;
    $current_expr = 'copy('.$current_expr.')';
   } else {
    $current_expr = $method.'('.join(', ', ($current_expr, @args)).')';
   }

   return undef if $return_family eq 'terminal' && !$is_last;
   $current_family = $return_family;
   next;
  }

  if ($current_family eq 'array') {
   return undef unless _is_array_receiver_value_chain_method($method);
   if ($method eq 'join_values') {
    return undef unless @args == 1;
    $current_expr = 'join_values('.$args[0].', '.$current_expr.')';
    $current_family = 'terminal';
    next;
   }
   if ($method =~ /^(?:sum|avg|median|range|min|max)$/o) {
    return undef unless @args == 0;
    $current_expr = $method.'('.$current_expr.')';
    $current_family = 'terminal';
    next;
   }
   if ($method =~ /^(?:split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match)$/o) {
    $current_expr = '__array_value_'.$method.'('.join(', ', ($current_expr, @args)).')';
    $current_family = 'array';
    next;
   }
   $current_expr = $method.'('.join(', ', ($current_expr, @args)).')';
   $current_family = ($method =~ /^(?:copy|sorted|reversed|take|take_last|drop_front|drop_back|slice|concat_arrays)$/o)
    ? 'array'
    : 'terminal';
   next;
  }

  return undef;
 }

 return $current_expr;
}

sub _parse_array_end_mutation_method_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $extract_array_symbol_name = $require_dep->('extract_array_symbol_name');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $split = _split_receiver_dot_method_expr($trimmed, $trim_action_ir_value);
 return undef unless $split;
 my ($receiver_expr, $call_expr) = @$split;
 return undef unless defined($receiver_expr) && $receiver_expr =~ /^(?:[A-Za-z_][A-Za-z0-9_]*|array\s*\()/o;
 my $target_symbol = $extract_array_symbol_name->($receiver_expr);
 if (!defined($target_symbol) && defined($receiver_expr) && $receiver_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
  $target_symbol = $1;
 }
 return undef unless defined($target_symbol) && length($target_symbol);

 my $call = $parse_method_function_expr->($call_expr);
 return undef unless $call && ($call->{method} // '') =~ /^(?:push_front|push_back|pop_front|pop_back)$/o;
 my $args = $call->{args} || [];
 return undef if $call->{method} =~ /^push_/o && @$args != 1;
 return undef if $call->{method} =~ /^pop_/o && @$args != 0;

 my $value_expr;
 if ($call->{method} =~ /^push_/o) {
  $value_expr = $trim_action_ir_value->($args->[0]);
  return undef unless defined($value_expr) && length($value_expr);
 }

 return {
  target   => $target_symbol,
  method   => $call->{method},
  value    => $value_expr,
  receiver => $receiver_expr,
 };
}

#------------------------------------------------------------------------------
# Function: _lower_array_end_mutation_method_statement
# Purpose : Lower statement-level receiver-dot array end mutations:
#           `items.push_back(value)`, `items.push_front(value)`,
#           `items.pop_back()`, and `items.pop_front()`.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_array_end_mutation_method_statement {
 my ($expr, $deps) = @_;
 my $ast_lowered = _lower_ast_array_end_mutation_method_statement(
  _parse_method_value_ast_expr($expr, $deps),
  $deps,
 );
 if (defined($ast_lowered) && length($ast_lowered)) {
  _trace_method_decision(
   phase => 'lower_array_end_mutation_method_statement',
   label => 'fluent_chain',
   decision => 'ast_array_end_mutation',
   taken => 1,
   context => {},
  );
  return $ast_lowered;
 }

 my $parsed = _parse_array_end_mutation_method_statement($expr, $deps);
 return undef unless $parsed;

 if ($parsed->{method} eq 'push_back') {
  my $lowered_value = _lower_mutation_slot_value_expr($parsed->{value}, $deps);
  return undef unless defined($lowered_value) && length($lowered_value);
  _trace_method_decision(
   phase => 'lower_array_end_mutation_method_statement',
   label => 'fluent_chain',
   decision => 'push_back_mutation',
   taken => 1,
   context => { target => $parsed->{target} },
  );
  my $binding_symbol = _uniform_binding_target_symbol($parsed->{receiver}, 'array', $deps);
  return _uniform_binding_array_end_expr($binding_symbol, 'push_back', $lowered_value)
   if defined($binding_symbol);
  return 'push @'.$parsed->{target}.', '.$lowered_value;
 }
 if ($parsed->{method} eq 'push_front') {
  my $lowered_value = _lower_mutation_slot_value_expr($parsed->{value}, $deps);
  return undef unless defined($lowered_value) && length($lowered_value);
  _trace_method_decision(
   phase => 'lower_array_end_mutation_method_statement',
   label => 'fluent_chain',
   decision => 'push_front_mutation',
   taken => 1,
   context => { target => $parsed->{target} },
  );
  my $binding_symbol = _uniform_binding_target_symbol($parsed->{receiver}, 'array', $deps);
  return _uniform_binding_array_end_expr($binding_symbol, 'push_front', $lowered_value)
   if defined($binding_symbol);
  return 'unshift @'.$parsed->{target}.', '.$lowered_value;
 }
 if ($parsed->{method} eq 'pop_back') {
  _trace_method_decision(
   phase => 'lower_array_end_mutation_method_statement',
   label => 'fluent_chain',
   decision => 'pop_back_mutation',
   taken => 1,
   context => { target => $parsed->{target} },
  );
  my $binding_symbol = _uniform_binding_target_symbol($parsed->{receiver}, 'array', $deps);
  return _uniform_binding_array_end_expr($binding_symbol, 'pop_back', undef)
   if defined($binding_symbol);
  return 'pop @'.$parsed->{target};
 }
 if ($parsed->{method} eq 'pop_front') {
  _trace_method_decision(
   phase => 'lower_array_end_mutation_method_statement',
   label => 'fluent_chain',
   decision => 'pop_front_mutation',
   taken => 1,
   context => { target => $parsed->{target} },
  );
  my $binding_symbol = _uniform_binding_target_symbol($parsed->{receiver}, 'array', $deps);
  return _uniform_binding_array_end_expr($binding_symbol, 'pop_front', undef)
   if defined($binding_symbol);
  return 'shift @'.$parsed->{target};
 }
 return undef
}

sub _parse_hash_index_assignment_operator_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 return undef unless $trimmed =~ /\G([A-Za-z_][A-Za-z0-9_]*)/gc;
 my $target = $1;
 $trimmed =~ /\G\s*/gc;
 return undef unless substr($trimmed, pos($trimmed) || 0, 1) eq '[';
 pos($trimmed) = (pos($trimmed) || 0) + 1;

 my $key = '';
 my @stack = (']');
 my ($in_single_quote, $in_double_quote, $escape_next) = (0, 0, 0);
 while ((pos($trimmed) || 0) < length($trimmed) && @stack) {
  my $idx = pos($trimmed) || 0;
  my $ch = substr($trimmed, $idx, 1);
  pos($trimmed) = $idx + 1;

  if ($in_single_quote) {
   $key .= $ch;
   if ($escape_next) { $escape_next = 0 }
   elsif ($ch eq '\\') { $escape_next = 1 }
   elsif ($ch eq "'") { $in_single_quote = 0 }
   next;
  }
  if ($in_double_quote) {
   $key .= $ch;
   if ($escape_next) { $escape_next = 0 }
   elsif ($ch eq '\\') { $escape_next = 1 }
   elsif ($ch eq '"') { $in_double_quote = 0 }
   next;
  }
  if ($ch eq "'") {
   $in_single_quote = 1;
   $key .= $ch;
   next;
  }
  if ($ch eq '"') {
   $in_double_quote = 1;
   $key .= $ch;
   next;
  }
  if ($ch eq '(') { push @stack, ')'; $key .= $ch; next; }
  if ($ch eq '[') { push @stack, ']'; $key .= $ch; next; }
  if ($ch eq '{') { push @stack, '}'; $key .= $ch; next; }
  if ($ch eq $stack[-1]) {
   if (@stack == 1) {
    pop @stack;
    last;
   }
   pop @stack;
   $key .= $ch;
   next;
  }
  $key .= $ch;
 }
 return undef if @stack;

 my $after_idx = pos($trimmed) || 0;
 my $after = substr($trimmed, $after_idx);
 return undef unless $after =~ /^\s*=(?!=|>)\s*(.+)$/s;
 my $value = $trim_action_ir_value->($1);
 $key = $trim_action_ir_value->($key);
 return undef unless defined($key) && length($key);
 return undef unless defined($value) && length($value);
 return {
  target => $target,
  key    => $key,
  value  => $value,
 };
}

#------------------------------------------------------------------------------
# Function: _lower_hash_index_assignment_operator_statement
# Purpose : Lower the statement form `meta["key"] = value` to the same direct
#           named-hash mutation emitted for `set_key(meta, "key", value)`.
#           Bare key/RHS identifiers are scoped scalar reads in this mutation
#           key/value slot.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_hash_index_assignment_operator_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $lower_scalar_access_key_expr = $require_dep->('lower_scalar_access_key_expr');

 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 my $ast_lowered = _lower_ast_assignment_operator_statement(
  _parse_method_value_ast_expr($trimmed, $deps),
  $deps,
  'assign_hash_index',
 );
 $ast_lowered = _lower_ast_assignment_operator_statement(
  _parse_method_value_ast_expr($trimmed, $deps),
  $deps,
  'assign_nested_access',
 ) unless defined($ast_lowered) && length($ast_lowered);
 if (defined($ast_lowered) && length($ast_lowered)) {
  _trace_method_decision(
   phase => 'lower_hash_index_assignment_operator_statement',
   label => 'assignment',
   decision => 'ast_hash_or_nested_access_assignment',
   taken => 1,
   context => {},
  );
  return $ast_lowered;
 }

 my $parsed = _parse_hash_index_assignment_operator_statement($expr, $deps);
 return undef unless $parsed;

 my $key_lowered = $lower_scalar_access_key_expr->($parsed->{key});
 return undef unless defined($key_lowered) && length($key_lowered);

 my $value_lowered = _lower_mutation_slot_value_expr($parsed->{value}, $deps);
 return undef unless defined($value_lowered) && length($value_lowered);

 _trace_method_decision(
  phase => 'lower_hash_index_assignment_operator_statement',
  label => 'assignment',
  decision => 'hash_index_assignment_operator',
  taken => 1,
  context => { target => $parsed->{target} },
 );
 return _uniform_binding_hash_index_set_expr($parsed->{target}, $key_lowered, $value_lowered)
}

#------------------------------------------------------------------------------
# Function: _lower_set_key_statement
# Purpose : Lower the statement form `set_key(target, key, value)` to a direct
#           hash-entry mutation. The pure value helper with the same name remains
#           in _lower_method_value_expr and is used when nested in return/source
#           expressions.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_set_key_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $extract_hash_symbol_name = $require_dep->('extract_hash_symbol_name');
 my $lower_scalar_access_key_expr = $require_dep->('lower_scalar_access_key_expr');
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 my $ast_lowered = _lower_ast_call_statement($expr, 'set_key', $deps);
 if (defined($ast_lowered) && length($ast_lowered)) {
  _trace_method_decision(
   phase => 'lower_set_key_statement',
   label => 'statement',
   decision => 'ast_set_key_statement',
   taken => 1,
   context => {},
  );
  return $ast_lowered;
 }

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'set_key';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 3, 3);
 return undef unless $effective_args;

 my $target_expr = $trim_action_ir_value->($effective_args->[0]);
 my $key_expr = $trim_action_ir_value->($effective_args->[1]);
 my $value_expr = $trim_action_ir_value->($effective_args->[2]);
 return undef unless defined($target_expr) && length($target_expr);
 return undef unless defined($key_expr) && length($key_expr);
 return undef unless defined($value_expr) && length($value_expr);

 my $hash_symbol = $extract_hash_symbol_name->($target_expr);
 return undef unless defined($hash_symbol) && length($hash_symbol);

 my $key_lowered = $lower_scalar_access_key_expr->($key_expr);
 return undef unless defined($key_lowered) && length($key_lowered);

 my $value_lowered = _lower_mutation_slot_value_expr($value_expr, $deps);
 return undef unless defined($value_lowered) && length($value_lowered);

 _trace_method_decision(
  phase => 'lower_set_key_statement',
  label => 'statement',
  decision => 'set_key_statement',
  taken => 1,
  context => { target => $hash_symbol },
 );
 my $binding_symbol = _uniform_binding_target_symbol($target_expr, 'hash', $deps);
 return _uniform_binding_hash_index_set_expr($binding_symbol, $key_lowered, $value_lowered)
  if defined($binding_symbol);
 return '$'.$hash_symbol.'{'.$key_lowered.'} = '.$value_lowered
}

#------------------------------------------------------------------------------
# Function: _lower_push_statement
# Purpose : Lower explicit value append helper calls for current `push(target, value)`
#           spelling in non-child-call shapes.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_push_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
 return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $extract_array_symbol_name = $require_dep->('extract_array_symbol_name');
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_primitive_literal_expr = $require_dep->('lower_primitive_literal_expr');

 my $ast_lowered = _lower_ast_call_statement($expr, 'push', $deps);
 if (defined($ast_lowered) && length($ast_lowered)) {
  _trace_method_decision(
   phase => 'lower_push_statement',
   label => 'statement',
   decision => 'ast_push_statement',
   taken => 1,
   context => {},
  );
  return $ast_lowered;
 }

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'push';

 my $raw_args = $call->{args} || [];
 my $effective_args;
 # SPEC-FORMAT-TERSE.1.3.2 / .8.3 — preserve child-call precedence for
 # `push(Child, target)` and `push(Child, index)`.
 if (@$raw_args == 2) {
  $effective_args = $raw_args;
 } elsif (@$raw_args == 3) {
  my $scoped_target_expr = $trim_action_ir_value->($raw_args->[1]);
  return undef unless defined($scoped_target_expr) && length($scoped_target_expr);
  return undef unless defined($extract_array_symbol_name->($scoped_target_expr))
                   || $scoped_target_expr =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
  $effective_args = [ $raw_args->[1], $raw_args->[2] ];
 } else {
  return undef;
 }

 my $first_expr = $trim_action_ir_value->($effective_args->[0]);
 my $second_expr = $trim_action_ir_value->($effective_args->[1]);
 my $second_literal = $lower_primitive_literal_expr->($second_expr);
 if (defined($first_expr) && defined($second_expr)
  && $first_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o
  && $second_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o
  && !defined($second_literal)) {
  return _uniform_binding_ambiguous_push_expr($first_expr, $second_expr)
 }
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
 _trace_method_decision(
  phase => 'lower_push_statement',
  label => 'statement',
  decision => 'push_statement',
  taken => 1,
  context => { target => $target_symbol, method => $call->{method} },
 );
 my $binding_symbol = _uniform_binding_target_symbol($target_expr, 'array', $deps);
 return _uniform_binding_array_push_expr($binding_symbol, $lowered_value)
  if defined($binding_symbol);
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
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $extract_scalar_symbol_name = $require_dep->('extract_scalar_symbol_name');
 my $strip_literal_delimiters = $require_dep->('strip_literal_delimiters');
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

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
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $ast_lowered = _lower_ast_call_statement($expr, 'return_undef', $deps);
 return $ast_lowered if defined($ast_lowered) && length($ast_lowered);

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'return_undef';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return undef unless $effective_args;
 return 'return undef'
}

1;
