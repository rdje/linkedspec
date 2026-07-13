#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::ControlFlow
# Purpose: Control-flow lowering owner for method-like if/switch markers and
#          attached-block flow normalization on the ActionIR path.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::ControlFlow;

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

use constant ACTIONIR_TRACE_OWNER => 'control_flow';

sub _trace_control_decision {
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

sub _trace_control_enter {
 my ($phase, $label, $details) = @_;
 return LinkedSpec::ActionIR::Trace::enter(
  package => __PACKAGE__,
  owner => ACTIONIR_TRACE_OWNER,
  phase => $phase,
  label => $label,
  details => $details,
 );
}

sub _trace_control_exit {
 my ($scope, $details) = @_;
 return LinkedSpec::ActionIR::Trace::exit_scope($scope, $details);
}

#------------------------------------------------------------------------------
# Function: default_deps_for_package
# Purpose : Build the default control-flow dependency bundle for one owner
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
   'split_action_ir_statements',
   'normalize_method_tag_expr',
   'lower_flow_composite_expr',
   'parse_method_function_expr',
   'normalize_method_args_with_optional_scope',
   { dep => 'extract_array_symbol_name', pkg => 'LinkedSpec::ActionIR::ValueExpr' },
  ],
 )
}

#------------------------------------------------------------------------------
# Function: _lower_control_flow_value_expr
# Purpose : Lower control-flow method argument values (bare reads, helpers, etc.) into
#           Perl expression form while allowing raw expressions.
# Args    : ($expr, $deps)
# Returns : Perl expression string or undef
#------------------------------------------------------------------------------
sub _lower_control_flow_value_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $lower_flow_composite_expr = $require_dep->('lower_flow_composite_expr');
 return undef unless defined $expr;
 my $lowered = $lower_flow_composite_expr->($expr);
 return undef unless defined($lowered) && length($lowered);
 return $lowered
}

#------------------------------------------------------------------------------
# Function: _lower_switch_case_value_expr
# Purpose : Normalize switch-case match values into either `eq` or regex match
#           comparison payloads.
# Args    : ($expr, $deps)
# Returns : hashref { mode => 'eq'|'regex', expr => ... } or undef
#------------------------------------------------------------------------------
sub _lower_switch_case_value_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $lower_flow_composite_expr = $require_dep->('lower_flow_composite_expr');
 my $normalize_method_tag_expr = $require_dep->('normalize_method_tag_expr');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($trimmed =~ m{^/(?:\\.|[^/])*/[a-z]*$}io) {
  return {mode => 'regex', expr => $trimmed}
 }
 my $lowered = $lower_flow_composite_expr->($trimmed);
 return undef unless defined($lowered) && length($lowered);

 # SPEC-FORMAT-TERSE.15.2.2 — a bare word in switch-case LABEL position is a literal
 # tag, not a variable read: it is a label/key position, analogous to the hash-literal
 # key exemption in ADR 0019. `switch(kind)` reads the variable kind, but `case(foo)`
 # matches the literal "foo"; use a quoted/compound expression for a non-literal case
 # value. `true`/`false` keep their boolean lowering. Before .15.2.2 this was
 # detected by `$lowered eq $trimmed` (the composite lowerer returned bare words
 # verbatim); now the composite lowerer reads a bare identifier as a variable, so the
 # literal-tag decision is made here directly on the source token.
 if ($trimmed =~ /^\w+$/o && $trimmed !~ /^(?:true|false)$/o) {
  return {mode => 'eq', expr => $normalize_method_tag_expr->($trimmed)}
 }
 return {mode => 'eq', expr => $lowered}
}

sub _normalize_bare_zero_arg_flow_marker_expr {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 return 'else()' if $trimmed eq 'otherwise';
 return "$1()" if $trimmed =~ /^(else|endif|default|endcase|endswitch)$/o;
 return $trimmed
}

sub _parse_control_flow_ast_expr {
 my ($expr, $deps) = @_;
 return undef if ref($expr);
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::ActionIR::AST');
 return LinkedSpec::ActionIR::AST::parse_action_expr($expr, { deps => $deps || {} })
}

sub _control_ast_quote_string_source {
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

sub _control_ast_value_source_expr {
 my ($node) = @_;
 return undef unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';

 if ($kind eq 'number') {
  my $source = $node->{source};
  return $source if defined($source) && $source =~ /\A-?\d+(?:\.\d+)?\z/o;
  return defined($node->{value}) ? (''.$node->{value}) : undef;
 }
 return _control_ast_quote_string_source($node->{value}, $node->{quote})
  if $kind eq 'string';
 return 'undef' if $kind eq 'undef';
 return $node->{value} ? 'true' : 'false'
  if $kind eq 'boolean';
 return '/'.($node->{pattern} // '').'/'.($node->{flags} // '')
  if $kind eq 'regex';
 return $node->{name}
  if $kind eq 'variable' && defined($node->{name}) && $node->{name} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 if ($kind eq 'indexed_var') {
  return undef unless defined($node->{name}) && $node->{name} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  my $index = _control_ast_value_source_expr($node->{index});
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
    $expr .= '['._control_ast_quote_string_source($segment->{value}, $quote).']';
    next;
   }
   return undef unless ($segment->{kind} // '') eq 'index';
   my $index = _control_ast_value_source_expr($segment->{expr});
   return undef unless defined($index) && length($index);
   $expr .= '['.$index.']';
  }
  return $expr
 }
 if ($kind eq 'assign_nested_access') {
  my $target = _control_ast_value_source_expr({
   kind => 'nested_access',
   base => $node->{base},
   segments => $node->{segments},
  });
  my $value = _control_ast_value_source_expr($node->{value});
  return undef unless defined($target) && length($target);
  return undef unless defined($value) && length($value);
  return $target.' = '.$value
 }
 if ($kind eq 'array_literal') {
  my @items;
  foreach my $item (@{$node->{items} || []}) {
   my $item_expr = _control_ast_value_source_expr($item);
   return undef unless defined($item_expr) && length($item_expr);
   push @items, $item_expr;
  }
  return '['.join(', ', @items).']'
 }
 if ($kind eq 'hash_literal') {
  my @pairs;
  foreach my $entry (@{$node->{entries} || []}) {
   return undef unless ref($entry) eq 'HASH';
   my $key_expr = _control_ast_value_source_expr($entry->{key});
   my $value_expr = _control_ast_value_source_expr($entry->{value});
   return undef unless defined($key_expr) && length($key_expr);
   return undef unless defined($value_expr) && length($value_expr);
   push @pairs, $key_expr.' => '.$value_expr;
  }
  return '{'.join(', ', @pairs).'}'
 }
 if ($kind eq 'call') {
  my $method = $node->{name};
	  $method = $node->{source_method}
   if defined($node->{source_method}) && $node->{source_method} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  return undef unless defined($method) && $method =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  my @args;
  foreach my $arg (@{$node->{args} || []}) {
   my $arg_expr = _control_ast_value_source_expr($arg);
   return undef unless defined($arg_expr) && length($arg_expr);
   push @args, $arg_expr;
  }
  return $method.'('.join(', ', @args).')'
 }
 if ($kind eq 'fluent_chain') {
  my $receiver = _control_ast_value_source_expr($node->{receiver});
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
    my $arg_expr = _control_ast_value_source_expr($arg);
    return undef unless defined($arg_expr) && length($arg_expr);
    push @args, $arg_expr;
   }
   $expr .= '.'.$method.'('.join(', ', @args).')';
  }
  return $expr
 }
 return undef
}

sub _control_ast_action_block_source {
 my ($block) = @_;
 return undef unless ref($block) eq 'HASH' && ($block->{kind} // '') eq 'action_block';
 my @statements;
 foreach my $stmt (@{$block->{statements} || []}) {
  my $source = _control_ast_statement_source_expr($stmt);
  return undef unless defined($source) && length($source);
  push @statements, $source;
 }
 return join('; ', @statements)
}

sub _control_ast_statement_source_expr {
 my ($stmt_or_node) = @_;
 return undef unless ref($stmt_or_node) eq 'HASH';
 my $node = (($stmt_or_node->{kind} // '') eq 'action_stmt') ? $stmt_or_node->{expr} : $stmt_or_node;
 return undef unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';

 if ($kind eq 'assign_scalar') {
  my $value = _control_ast_value_source_expr($node->{value});
  return undef unless defined($node->{name}) && $node->{name} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  return undef unless defined($value) && length($value);
  return $node->{name}.' = '.$value
 }
 if ($kind eq 'assign_array_append') {
  my $value = _control_ast_value_source_expr($node->{value});
  return undef unless defined($node->{name}) && $node->{name} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  return undef unless defined($value) && length($value);
  return $node->{name}.' += '.$value
 }
 if ($kind eq 'assign_hash_index') {
  my $key = _control_ast_value_source_expr($node->{key});
  my $value = _control_ast_value_source_expr($node->{value});
  return undef unless defined($node->{name}) && $node->{name} =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
  return undef unless defined($key) && length($key) && defined($value) && length($value);
  return $node->{name}.'['.$key.'] = '.$value
 }
 if ($kind =~ /\Acontrol_/o) {
  return _control_ast_flow_node_source_expr($node)
 }
 return _control_ast_value_source_expr($node)
}

sub _control_ast_flow_node_source_expr {
 my ($node) = @_;
 return undef unless ref($node) eq 'HASH';
 my $kind = $node->{kind} // '';

 if ($kind eq 'control_if') {
  my $keyword = $node->{keyword};
  $keyword = (($node->{branch_role} // '') eq 'elseif') ? 'elseif' : 'if'
   unless defined($keyword) && $keyword =~ /\A(?:if|i|when|elseif|elif)\z/o;
  my $condition = _control_ast_value_source_expr($node->{condition});
  return undef unless defined($condition) && length($condition);
  my $head = $keyword.'('.$condition.')';
  if (ref($node->{body}) eq 'HASH') {
   my $body = _control_ast_action_block_source($node->{body});
   return undef unless defined $body;
   return $head.' { '.$body.' }'
  }
  return $head
 }

 if ($kind eq 'control_else') {
  my $keyword = $node->{keyword};
  $keyword = 'else' unless defined($keyword) && $keyword =~ /\A(?:else|otherwise)\z/o;
  if (ref($node->{body}) eq 'HASH') {
   my $body = _control_ast_action_block_source($node->{body});
   return undef unless defined $body;
   return $keyword.' { '.$body.' }'
  }
  return $keyword
 }

 return 'endif()' if $kind eq 'control_endif';
 if ($kind eq 'control_switch') {
  my $source = _control_ast_value_source_expr($node->{source_expr});
  return undef unless defined($source) && length($source);
  my $head = 'switch('.$source.')';

  if (exists $node->{cases} || exists $node->{default}) {
   my @branches;
   return undef unless !exists($node->{cases}) || ref($node->{cases}) eq 'ARRAY';
   foreach my $case (@{$node->{cases} || []}) {
    my $branch = _control_ast_flow_node_source_expr($case);
    return undef unless defined($branch) && length($branch);
    push @branches, $branch;
   }
   if (defined $node->{default}) {
    my $default = _control_ast_flow_node_source_expr($node->{default});
    return undef unless defined($default) && length($default);
    push @branches, $default;
   }
   return $head.' { '.join(' ', @branches).' }'
  }

  if (ref($node->{body}) eq 'HASH') {
   my $body = _control_ast_action_block_source($node->{body});
   return undef unless defined $body;
   return $head.' { '.$body.' }'
  }
  return $head
 }

 if ($kind eq 'control_case') {
  my $match = _control_ast_value_source_expr($node->{match});
  return undef unless defined($match) && length($match);
  my $head = 'case('.$match.')';
  if (ref($node->{body}) eq 'HASH') {
   my $body = _control_ast_action_block_source($node->{body});
   return undef unless defined $body;
   return $head.' { '.$body.' }'
  }
  return $head
 }

 if ($kind eq 'control_default') {
  if (ref($node->{body}) eq 'HASH') {
   my $body = _control_ast_action_block_source($node->{body});
   return undef unless defined $body;
   return 'default { '.$body.' }'
  }
  return 'default()'
 }

 return 'endcase()' if $kind eq 'control_endcase';
 return 'endswitch()' if $kind eq 'control_endswitch';

 if ($kind eq 'control_while') {
  my $condition = _control_ast_value_source_expr($node->{condition});
  return undef unless defined($condition) && length($condition);
  my $head = 'while('.$condition.')';
  if (ref($node->{body}) eq 'HASH') {
   my $body = _control_ast_action_block_source($node->{body});
   return undef unless defined $body;
   return $head.' { '.$body.' }'
  }
  return $head
 }
 return undef
}

sub _control_ast_flow_source_expr {
 my ($expr, $deps) = @_;
 my $node = ref($expr) eq 'HASH' ? $expr : _parse_control_flow_ast_expr($expr, $deps);
 return undef unless ref($node) eq 'HASH' && (($node->{kind} // '') =~ /\Acontrol_(?:if|else|endif|switch|case|default|endcase|endswitch|while)\z/o);
 return _control_ast_flow_node_source_expr($node)
}

#------------------------------------------------------------------------------
# Function: _lower_if_flow_statement
# Purpose : Lower `if(...)`/`i(...)` fluent control-flow markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _if_arg_starts_inline_action_or_branch {
 my ($expr) = @_;
 return 0 unless defined $expr;
 return 1 if $expr =~ /^\s*\{/s;
 return $expr =~ /^\s*(?:elif|elseif|else|if|i|when|while|switch|case|default|endcase|endswitch|return|return_undef|set|push|say|print|print_each|exit_now|next)\s*(?:\(|\{|\z)/o ? 1 : 0
}

sub _lower_if_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $scope = _trace_control_enter(
  'lower_if_flow_statement',
  'if',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_control_decision(
   phase => 'lower_if_flow_statement',
   label => 'if',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_control_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return $finish->(undef, 'parse_failed', {}) unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $call = $parsed_expr->{call};
 my $attached_block = $parsed_expr->{attached_block};
 return $finish->(undef, 'wrong_method', { method => $call ? ($call->{method} // '') : '<undef>' })
  unless $call && ($call->{method} eq 'if' || $call->{method} eq 'i' || $call->{method} eq 'when');

 my $raw_args = $call->{args} || [];
 my $effective_args = (
  ref($raw_args) eq 'ARRAY' &&
  @$raw_args > 1 &&
  _if_arg_starts_inline_action_or_branch($raw_args->[1])
 )
  ? [@$raw_args]
  : $normalize_method_args_with_optional_scope->($raw_args, 1, undef);
 return $finish->(undef, 'bad_arity', { method => $call->{method} }) unless $effective_args;
 my $cond_expr = _lower_control_flow_value_expr($effective_args->[0], $deps);
 return $finish->(undef, 'condition_lowering_failed', { method => $call->{method} }) unless defined($cond_expr) && length($cond_expr);
 return $finish->(undef, 'attached_block_with_inline_args', { arg_count => scalar(@$effective_args) })
  if defined($attached_block) && @$effective_args > 1;

 if (defined $attached_block) {
  my $actions = _lower_flow_branch_action_list([$attached_block], $ctx, $deps);
  return $finish->(undef, 'attached_actions_failed', {}) unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? ' '.join('; ', @$actions) : '';
  $ctx->{if_stack} ||= [];
  push @{$ctx->{if_stack}}, {else_seen => 0, implicit_close => 1, body_carrier => 'attached'};
  return $finish->("if ($cond_expr) {$body", 'attached_if', { action_count => scalar(@$actions) });
 }

 if (@$effective_args > 1) {
  my @if_action_exprs;
  my @clauses;
  my $seen_branch_header = 0;
  my $else_seen = 0;

  foreach my $arg (@$effective_args[1 .. $#$effective_args]) {
   my $arg_call = $parse_method_function_expr->($arg);
   my $arg_method = $arg_call ? ($arg_call->{method} // '') : '';

   if ($arg_method eq 'elseif' || $arg_method eq 'elif' || $arg_method eq 'else') {
    return $finish->(undef, 'inline_branch_after_else', { method => $arg_method }) if $else_seen;
    my $clause = _lower_inline_if_branch_expr($arg, $ctx, $deps);
    return $finish->(undef, 'inline_branch_lowering_failed', { method => $arg_method })
     unless defined($clause) && length($clause);
    push @clauses, $clause;
    $seen_branch_header = 1;
    $else_seen = 1 if $arg_method eq 'else';
    next;
   }

   return $finish->(undef, 'action_after_inline_branch_header', {}) if $seen_branch_header;
   push @if_action_exprs, $arg;
  }

  my $actions = _lower_flow_branch_action_list(\@if_action_exprs, $ctx, $deps);
  return $finish->(undef, 'inline_actions_failed', {}) unless ref($actions) eq 'ARRAY';

  my $body = @$actions ? ' '.join('; ', @$actions) : '';
  my $suffix = @clauses ? ' '.join(' ', @clauses) : '';
  return $finish->("do { if ($cond_expr) {$body$suffix } }", 'inline_if', {
   action_count => scalar(@$actions),
   clause_count => scalar(@clauses),
  });
 }

 $ctx->{if_stack} ||= [];
 push @{$ctx->{if_stack}}, {else_seen => 0, implicit_close => 0, body_carrier => 'marker'};
 return $finish->("if ($cond_expr) {", 'marker_if', {})
}

#------------------------------------------------------------------------------
# Function: _lower_elseif_flow_statement
# Purpose : Lower `elif(...)`/`elseif(...)` fluent control-flow markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_elseif_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return undef unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $call = $parsed_expr->{call};
 my $attached_block = $parsed_expr->{attached_block};
 return undef unless $call && ($call->{method} eq 'elif' || $call->{method} eq 'elseif');

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
 return undef unless $effective_args;
 my $cond_expr = _lower_control_flow_value_expr($effective_args->[0], $deps);
 return undef unless defined($cond_expr) && length($cond_expr);

 my $if_stack = $ctx->{if_stack} || [];
 return undef unless @$if_stack;
 my $current_if = $if_stack->[-1];
 return undef if $current_if->{else_seen};
 if (defined $attached_block) {
  my $actions = _lower_flow_branch_action_list([$attached_block], $ctx, $deps);
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? ' '.join('; ', @$actions) : '';
  $current_if->{body_carrier} = 'attached';
  $current_if->{implicit_close} = 1;
  return "} elsif ($cond_expr) {$body";
 }

 $current_if->{body_carrier} = 'marker';
 $current_if->{implicit_close} = 0;

 return "} elsif ($cond_expr) {"
}

#------------------------------------------------------------------------------
# Function: _lower_else_flow_statement
# Purpose : Lower `else()` fluent control-flow markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_else_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return undef unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $call = $parsed_expr->{call};
 my $attached_block = $parsed_expr->{attached_block};
 return undef unless $call && $call->{method} eq 'else';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $if_stack = $ctx->{if_stack} || [];
 return undef unless @$if_stack;
 my $current_if = $if_stack->[-1];
 return undef if $current_if->{else_seen};
 $current_if->{else_seen} = 1;
 if (defined $attached_block) {
  my $actions = _lower_flow_branch_action_list([$attached_block], $ctx, $deps);
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? ' '.join('; ', @$actions) : '';
  pop @$if_stack;
  return "} else {$body }";
 }

 $current_if->{body_carrier} = 'marker';
 $current_if->{implicit_close} = 0;

 return '} else {'
}

#------------------------------------------------------------------------------
# Function: _lower_endif_flow_statement
# Purpose : Lower `endif()` fluent control-flow markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_endif_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return undef unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 return undef if defined $parsed_expr->{attached_block};
 my $call = $parsed_expr->{call};
 return undef unless $call && $call->{method} eq 'endif';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $if_stack = $ctx->{if_stack} || [];
 return undef unless @$if_stack;
 return undef if ($if_stack->[-1]{body_carrier} || '') eq 'attached';
 pop @$if_stack;
 return '}'
}

sub _new_flow_branch_rewrite_ctx {
 my ($ctx) = @_;
 return {
  if_stack       => [],
  switch_stack   => [],
  switch_counter => ($ctx->{switch_counter} || 0),
  while_counter  => ($ctx->{while_counter} || 0),
  rewrite_rules  => $ctx->{rewrite_rules},
 }
}

sub _clone_flow_branch_rewrite_ctx {
 my ($ctx) = @_;
 return {
  if_stack       => [map { +{%$_} } @{$ctx->{if_stack} || []}],
  switch_stack   => [map { +{%$_} } @{$ctx->{switch_stack} || []}],
  switch_counter => ($ctx->{switch_counter} || 0),
  while_counter  => ($ctx->{while_counter} || 0),
  rewrite_rules  => $ctx->{rewrite_rules},
 }
}

sub _expand_flow_branch_action_exprs {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $split_action_ir_statements = $require_dep->('split_action_ir_statements');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);
 return [$trimmed] unless $trimmed =~ /^\{(?<body>.*)\}$/s;

 my $statements = $split_action_ir_statements->($+{body});
 return undef unless ref($statements) eq 'ARRAY';
 return $statements
}

sub _parse_method_expr_with_optional_attached_block {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');

 my $ast_expr = _control_ast_flow_source_expr($expr, $deps);
 $expr = $ast_expr if defined($ast_expr) && length($ast_expr);

 my $trimmed = _normalize_bare_zero_arg_flow_marker_expr($expr, $deps);
 return undef unless defined($trimmed) && length($trimmed);

 my $call = $parse_method_function_expr->($trimmed);
 return { call => $call, attached_block => undef } if $call;

 my @chars = split //, $trimmed;
 my $paren_depth = 0;
 my $brace_depth = 0;
 my $bracket_depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $in_slash_quote = 0;
 my $slash_escape_next = 0;
 my $escape_next = 0;

 for (my $idx = 0; $idx < @chars; ++$idx) {
  my $char = $chars[$idx];

  if ($in_slash_quote) {
   if ($slash_escape_next) {
    $slash_escape_next = 0;
   } elsif ($char eq '\\') {
    $slash_escape_next = 1;
   } elsif ($char eq '/') {
    $in_slash_quote = 0;
   }
   next;
  }

  if ($in_single_quote) {
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq "'") {
    $in_single_quote = 0;
   }
   next;
  }

  if ($in_double_quote) {
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq '"') {
    $in_double_quote = 0;
   }
   next;
  }

  if ($char eq "'") {
   $in_single_quote = 1;
   next;
  }
  if ($char eq '"') {
   $in_double_quote = 1;
   next;
  }
  if ($char eq '/') {
   my $prefix = substr($trimmed, 0, $idx);
   $prefix =~ s/\s+$//o;
   if (!length($prefix)) {
    $in_slash_quote = 1;
    $slash_escape_next = 0;
    next;
   }
  }
  if ($char eq '(') {
   ++$paren_depth;
   next;
  }
  if ($char eq ')') {
   --$paren_depth if $paren_depth > 0;
   next;
  }
  if ($char eq '[') {
   ++$bracket_depth;
   next;
  }
  if ($char eq ']') {
   --$bracket_depth if $bracket_depth > 0;
   next;
  }
  next unless $char eq '{';
  next if $paren_depth || $brace_depth || $bracket_depth;

  my $head = $trim_action_ir_value->(substr($trimmed, 0, $idx));
  next unless defined($head) && length($head);
  my $body = substr($trimmed, $idx);
  next unless $body =~ /^\{(?<inner>.*)\}$/s;

  my $normalized_head = _normalize_bare_zero_arg_flow_marker_expr($head, $deps);
  $call = $parse_method_function_expr->($normalized_head);
  next unless $call;

  return {
   call => $call,
   attached_block => '{' . $+{inner} . '}',
  };
 }

 return undef
}

sub _statement_continues_attached_if_flow {
 my ($expr, $deps) = @_;
 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return 0 unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $method = $parsed_expr->{call}{method} // '';
 return ($method eq 'elif' || $method eq 'elseif' || $method eq 'else') ? 1 : 0
}

sub _flush_implicit_if_closures {
 my ($ctx) = @_;
 my $if_stack = $ctx->{if_stack} || [];
 my @closures;
 while (@$if_stack && $if_stack->[-1]{implicit_close}) {
  pop @$if_stack;
  push @closures, '}';
 }
 return join(' ', @closures)
}

sub _lower_flow_branch_direct_control_flow_statement {
 my ($expr, $ctx, $deps) = @_;

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return undef unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $method = $parsed_expr->{call}{method} // '';

 my %dispatch = (
  if        => \&_lower_if_flow_statement,
  i         => \&_lower_if_flow_statement,
  elif      => \&_lower_elseif_flow_statement,
  elseif    => \&_lower_elseif_flow_statement,
  else      => \&_lower_else_flow_statement,
  endif     => \&_lower_endif_flow_statement,
  while     => \&_lower_while_flow_statement,
  switch    => \&_lower_switch_flow_statement,
  case      => \&_lower_case_flow_statement,
  default   => \&_lower_default_flow_statement,
  endcase   => \&_lower_endcase_flow_statement,
  endswitch => \&_lower_endswitch_flow_statement,
 );

 my $lower = $dispatch{$method};
 return undef unless ref($lower) eq 'CODE';
 return $lower->($expr, $ctx, $deps)
}

sub _lower_flow_branch_single_statement {
 my ($expr, $branch_ctx, $deps) = @_;
 my $scope = _trace_control_enter(
  'lower_flow_branch_single_statement',
  'branch',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_control_decision(
   phase => 'lower_flow_branch_single_statement',
   label => 'branch',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_control_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');

 return $finish->(undef, 'missing_expr', {}) unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return $finish->(undef, 'empty_expr', {}) unless defined($trimmed) && length($trimmed);

 my $prefix = '';
 if (@{$branch_ctx->{if_stack} || []} && !_statement_continues_attached_if_flow($trimmed, $deps)) {
  $prefix = _flush_implicit_if_closures($branch_ctx);
  _trace_control_decision(
   phase => 'lower_flow_branch_single_statement',
   label => 'branch',
   decision => 'implicit_if_closures_flushed',
   taken => length($prefix) ? 1 : 0,
   context => { closure_text => $prefix },
  );
 }

 my $direct_flow_lowered = _lower_flow_branch_direct_control_flow_statement($trimmed, $branch_ctx, $deps);
 if (defined($direct_flow_lowered) && length($direct_flow_lowered) && $direct_flow_lowered ne $trimmed) {
  return $finish->(length($prefix) ? "$prefix $direct_flow_lowered" : $direct_flow_lowered, 'direct_control_flow', {});
 }

 my $rules = $branch_ctx->{rewrite_rules};
 unless ($rules && ref($rules) eq 'ARRAY') {
  return $finish->(length($prefix) ? "$prefix $trimmed" : $trimmed, 'passthrough_without_rules', {});
 }

 foreach my $rule (@$rules) {
  my $candidate_ctx = _clone_flow_branch_rewrite_ctx($branch_ctx);
  my $lowered = $rule->{apply}->($trimmed, $candidate_ctx);
  next unless defined($lowered) && length($lowered);
  next if $lowered eq $trimmed;
  %$branch_ctx = %$candidate_ctx;
  return $finish->(length($prefix) ? "$prefix $lowered" : $lowered, 'rewrite_rule_lowered', {
   contract_id => $rule->{id} // '',
  });
 }

 return $finish->(length($prefix) ? "$prefix $trimmed" : $trimmed, 'passthrough_no_rule_match', {})
}

#------------------------------------------------------------------------------
# Function: _lower_flow_branch_action_expr
# Purpose : Lower one branch action expression used in inline-composite switch
#           branch arguments (`case(..., action1, action2, ...)`).
# Args    : ($expr, $ctx, $deps)
# Returns : arrayref of lowered Perl statements or undef
#------------------------------------------------------------------------------
sub _lower_flow_branch_action_expr {
 my ($expr, $ctx, $deps, $branch_ctx) = @_;
 $branch_ctx //= _new_flow_branch_rewrite_ctx($ctx);

 my $action_exprs = _expand_flow_branch_action_exprs($expr, $deps);
 return undef unless ref($action_exprs) eq 'ARRAY';

 my @lowered_actions;
 foreach my $action_expr (@$action_exprs) {
  my $lowered_action = _lower_flow_branch_single_statement($action_expr, $branch_ctx, $deps);
  return undef unless defined($lowered_action) && length($lowered_action);
  push @lowered_actions, $lowered_action;
 }

 return \@lowered_actions
}

sub _lower_flow_branch_action_list {
 my ($action_exprs, $ctx, $deps, $branch_ctx) = @_;
 $branch_ctx //= _new_flow_branch_rewrite_ctx($ctx);
 return undef unless ref($action_exprs) eq 'ARRAY';

 my @actions;
 foreach my $action_expr (@$action_exprs) {
  my $lowered_actions = _lower_flow_branch_action_expr($action_expr, $ctx, $deps, $branch_ctx);
  return undef unless ref($lowered_actions) eq 'ARRAY';
 push @actions, @$lowered_actions;
 }

 my $implicit_closures = _flush_implicit_if_closures($branch_ctx);
 push @actions, $implicit_closures if length($implicit_closures);

 return undef if @{$branch_ctx->{if_stack} || []};
 return undef if @{$branch_ctx->{switch_stack} || []};
 $ctx->{switch_counter} = $branch_ctx->{switch_counter} if defined $branch_ctx->{switch_counter};
 $ctx->{while_counter} = $branch_ctx->{while_counter} if defined $branch_ctx->{while_counter};
 return \@actions
}

sub _lower_inline_if_branch_expr {
 my ($branch_expr, $ctx, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_branch = _parse_method_expr_with_optional_attached_block($branch_expr, $deps);
 return undef unless $parsed_branch && ref($parsed_branch->{call}) eq 'HASH';
 my $branch_call = $parsed_branch->{call};
 my $attached_block = $parsed_branch->{attached_block};
 return undef unless $branch_call;
 my $method = $branch_call->{method} // '';

 if ($method eq 'elseif' || $method eq 'elif') {
  my $raw_args = $branch_call->{args} || [];
  my $effective_args = (
   ref($raw_args) eq 'ARRAY' &&
   @$raw_args > 1 &&
   _if_arg_starts_inline_action_or_branch($raw_args->[1])
  )
   ? [@$raw_args]
   : $normalize_method_args_with_optional_scope->($raw_args, 1, undef);
  return undef unless $effective_args && @$effective_args >= 1;

  my $cond_expr = _lower_control_flow_value_expr($effective_args->[0], $deps);
  return undef unless defined($cond_expr) && length($cond_expr);

  return undef if defined($attached_block) && @$effective_args > 1;
  my @branch_action_exprs = defined($attached_block)
   ? ($attached_block)
   : (@$effective_args > 1 ? @$effective_args[1 .. $#$effective_args] : ());
  my $actions = _lower_flow_branch_action_list(\@branch_action_exprs, $ctx, $deps);
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? ' '.join('; ', @$actions) : '';
  return "} elsif ($cond_expr) {$body";
 }

 if ($method eq 'else') {
  my $effective_args = $normalize_method_args_with_optional_scope->($branch_call->{args} || [], 0, undef);
  return undef unless $effective_args;

  return undef if defined($attached_block) && @$effective_args;
  my @branch_action_exprs = defined($attached_block) ? ($attached_block) : @$effective_args;
  my $actions = _lower_flow_branch_action_list(\@branch_action_exprs, $ctx, $deps);
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? ' '.join('; ', @$actions) : '';
  return "} else {$body";
 }

 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_inline_switch_branch_expr
# Purpose : Lower a single inline switch branch expression (`case(...)` or
#           `default(...)`) in composite switch syntax.
# Args    : ($branch_expr, $switch_var, $hit_var, $ctx, $switch_state, $deps)
# Returns : Perl clause string or undef
#------------------------------------------------------------------------------
sub _lower_inline_switch_branch_expr {
 my ($branch_expr, $switch_var, $hit_var, $ctx, $switch_state, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_branch = _parse_method_expr_with_optional_attached_block($branch_expr, $deps);
 return undef unless $parsed_branch && ref($parsed_branch->{call}) eq 'HASH';
 my $branch_call = $parsed_branch->{call};
 my $attached_block = $parsed_branch->{attached_block};
 my $method = $branch_call->{method} // '';

 if ($method eq 'case') {
  my $effective_args = $normalize_method_args_with_optional_scope->($branch_call->{args} || [], 1, undef);
  return undef unless $effective_args && @$effective_args >= 1;
  return undef if $switch_state->{default_seen};

 my $case_value = _lower_switch_case_value_expr($effective_args->[0], $deps);
 return undef unless $case_value && defined($case_value->{expr});
  my $match_expr = $case_value->{mode} eq 'regex'
   ? "\$$switch_var =~ $case_value->{expr}"
   : "\$$switch_var eq $case_value->{expr}";

  return undef if defined($attached_block) && @$effective_args > 1;
  my @branch_action_exprs = defined($attached_block)
   ? ($attached_block)
   : (@$effective_args > 1 ? @$effective_args[1 .. $#$effective_args] : ());

  my $actions = _lower_flow_branch_action_list(\@branch_action_exprs, $ctx, $deps);
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? '; '.join('; ', @$actions) : '';
  return "if (!\$$hit_var && $match_expr) { \$$hit_var = 1$body }";
 }

 if ($method eq 'default') {
  my $effective_args = $normalize_method_args_with_optional_scope->($branch_call->{args} || [], 0, undef);
  return undef unless $effective_args;
  return undef if $switch_state->{default_seen};
  $switch_state->{default_seen} = 1;
  return undef if defined($attached_block) && @$effective_args;

  my @branch_action_exprs = defined($attached_block) ? ($attached_block) : @$effective_args;
  my $actions = _lower_flow_branch_action_list(\@branch_action_exprs, $ctx, $deps);
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? '; '.join('; ', @$actions) : '';
  return "if (!\$$hit_var) { \$$hit_var = 1$body }";
 }

 return undef
}

sub _lower_attached_switch_body {
 my ($attached_block, $ctx, $switch_state, $deps) = @_;

 my $action_exprs = _expand_flow_branch_action_exprs($attached_block, $deps);
 return undef unless ref($action_exprs) eq 'ARRAY';

 my $branch_ctx = _new_flow_branch_rewrite_ctx($ctx);
 push @{$branch_ctx->{switch_stack}}, $switch_state;

 my @actions;
 foreach my $action_expr (@$action_exprs) {
  my $lowered_action = _lower_flow_branch_single_statement($action_expr, $branch_ctx, $deps);
  return undef unless defined($lowered_action) && length($lowered_action);
  push @actions, $lowered_action;
 }

 my $implicit_if_closures = _flush_implicit_if_closures($branch_ctx);
 push @actions, $implicit_if_closures if length($implicit_if_closures);
 return undef if @{$branch_ctx->{if_stack} || []};

 my $switch_stack = $branch_ctx->{switch_stack} || [];
 return undef unless @$switch_stack;
 my $active_switch = pop @$switch_stack;
 return undef unless ref($active_switch) eq 'HASH';
 return undef if @$switch_stack;

 push @actions, '}' if $active_switch->{open_case};
 $ctx->{switch_counter} = $branch_ctx->{switch_counter} if defined $branch_ctx->{switch_counter};
 $ctx->{while_counter} = $branch_ctx->{while_counter} if defined $branch_ctx->{while_counter};
 return \@actions
}

#------------------------------------------------------------------------------
# Function: _lower_while_flow_statement
# Purpose : Lower attached `while(cond) { ... }` statement loops with a
#           deterministic iteration safety guard.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_while_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $scope = _trace_control_enter(
  'lower_while_flow_statement',
  'while',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_control_decision(
   phase => 'lower_while_flow_statement',
   label => 'while',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_control_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return $finish->(undef, 'parse_failed', {}) unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $call = $parsed_expr->{call};
 my $attached_block = $parsed_expr->{attached_block};
 return $finish->(undef, 'wrong_method', { method => $call ? ($call->{method} // '') : '<undef>' })
  unless $call && $call->{method} eq 'while';
 return $finish->(undef, 'missing_attached_block', {}) unless defined $attached_block;

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
 return $finish->(undef, 'bad_arity', { arg_count => ref($effective_args) eq 'ARRAY' ? scalar(@$effective_args) : 0 })
  unless $effective_args && @$effective_args == 1;
 my $cond_expr = _lower_control_flow_value_expr($effective_args->[0], $deps);
 return $finish->(undef, 'condition_lowering_failed', {}) unless defined($cond_expr) && length($cond_expr);

 my $actions = _lower_flow_branch_action_list([$attached_block], $ctx, $deps);
 return $finish->(undef, 'actions_failed', {}) unless ref($actions) eq 'ARRAY';

 $ctx->{while_counter} = ($ctx->{while_counter} || 0) + 1;
 my $guard_var = '__ls_while_guard_'.$ctx->{while_counter};
 my $body = @$actions ? '; '.join('; ', @$actions) : '';
 return $finish->(
  'do { my $'.$guard_var.' = 0; for (; '.$cond_expr.'; ) { die "LinkedSpec while iteration safety limit exceeded after 10000 iterations" if ++$'.$guard_var.' > 10000'.$body.' } }',
  'attached_while',
  { guard_var => $guard_var, action_count => scalar(@$actions) },
 )
}

#------------------------------------------------------------------------------
# Function: _lower_switch_flow_statement
# Purpose : Lower `switch(...)` fluent control-flow markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _switch_arg_starts_inline_branch {
 my ($expr) = @_;
 return 0 unless defined $expr;
 return $expr =~ /^\s*(?:case|default)\s*(?:\(|\{|\z)/o ? 1 : 0
}

sub _lower_switch_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $scope = _trace_control_enter(
  'lower_switch_flow_statement',
  'switch',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_control_decision(
   phase => 'lower_switch_flow_statement',
   label => 'switch',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_control_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return $finish->(undef, 'parse_failed', {}) unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $call = $parsed_expr->{call};
 my $attached_block = $parsed_expr->{attached_block};
 return $finish->(undef, 'wrong_method', { method => $call ? ($call->{method} // '') : '<undef>' })
  unless $call && $call->{method} eq 'switch';
 my $raw_args = $call->{args} || [];
 my $effective_args = (
  ref($raw_args) eq 'ARRAY' &&
  @$raw_args > 1 &&
  _switch_arg_starts_inline_branch($raw_args->[1])
 )
  ? [@$raw_args]
  : $normalize_method_args_with_optional_scope->($raw_args, 1, undef);
 return $finish->(undef, 'bad_arity', { arg_count => ref($effective_args) eq 'ARRAY' ? scalar(@$effective_args) : 0 })
  unless $effective_args && @$effective_args >= 1;
 return $finish->(undef, 'attached_block_with_inline_args', { arg_count => scalar(@$effective_args) })
  if defined($attached_block) && @$effective_args > 1;
 my $switch_expr = _lower_control_flow_value_expr($effective_args->[0], $deps);
 return $finish->(undef, 'switch_expr_lowering_failed', {}) unless defined($switch_expr) && length($switch_expr);

 $ctx->{switch_stack} ||= [];
 $ctx->{switch_counter} = ($ctx->{switch_counter} || 0) + 1;
 my $suffix = $ctx->{switch_counter};
 my $switch_var = "__ls_switch_value_$suffix";
 my $hit_var = "__ls_switch_hit_$suffix";
 my $switch_state = {
  switch_var   => $switch_var,
  hit_var      => $hit_var,
  open_case    => 0,
  default_seen => 0,
 };

 if (@$effective_args > 1) {
  my @clauses;
  foreach my $branch_expr (@$effective_args[1 .. $#$effective_args]) {
   my $clause = _lower_inline_switch_branch_expr($branch_expr, $switch_var, $hit_var, $ctx, $switch_state, $deps);
   return $finish->(undef, 'inline_branch_lowering_failed', { branch_count => scalar(@clauses) })
    unless defined($clause) && length($clause);
   push @clauses, $clause;
  }
  my $body = @clauses ? '; '.join('; ', @clauses) : '';
  return $finish->("do { my \$$switch_var = $switch_expr; my \$$hit_var = 0$body }", 'inline_switch', {
   switch_var => $switch_var,
   hit_var => $hit_var,
   clause_count => scalar(@clauses),
  });
 }

 if (defined $attached_block) {
  my $actions = _lower_attached_switch_body($attached_block, $ctx, $switch_state, $deps);
  return $finish->(undef, 'attached_actions_failed', {}) unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? '; '.join('; ', @$actions) : '';
  return $finish->("do { my \$$switch_var = $switch_expr; my \$$hit_var = 0$body }", 'attached_switch', {
   switch_var => $switch_var,
   hit_var => $hit_var,
   action_count => scalar(@$actions),
  });
 }

 $ctx->{switch_stack} ||= [];
 push @{$ctx->{switch_stack}}, $switch_state;

 return $finish->("do { my \$$switch_var = $switch_expr; my \$$hit_var = 0", 'marker_switch', {
  switch_var => $switch_var,
  hit_var => $hit_var,
 })
}

#------------------------------------------------------------------------------
# Function: _lower_case_flow_statement
# Purpose : Lower `case(...)` fluent switch-branch markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_case_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $scope = _trace_control_enter(
  'lower_case_flow_statement',
  'case',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_control_decision(
   phase => 'lower_case_flow_statement',
   label => 'case',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_control_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return $finish->(undef, 'parse_failed', {}) unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $call = $parsed_expr->{call};
 my $attached_block = $parsed_expr->{attached_block};
 return $finish->(undef, 'wrong_method', { method => $call ? ($call->{method} // '') : '<undef>' })
  unless $call && $call->{method} eq 'case';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
 return $finish->(undef, 'bad_arity', {}) unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return $finish->(undef, 'missing_switch_stack', {}) unless @$switch_stack;
 my $switch_state = $switch_stack->[-1];
 return $finish->(undef, 'case_after_default', {}) if $switch_state->{default_seen};

 my $case_value = _lower_switch_case_value_expr($effective_args->[0], $deps);
 return $finish->(undef, 'case_value_lowering_failed', {}) unless $case_value && defined($case_value->{expr});
 my $switch_var = $switch_state->{switch_var};
 my $hit_var = $switch_state->{hit_var};
 my $match_expr = $case_value->{mode} eq 'regex'
  ? "\$$switch_var =~ $case_value->{expr}"
  : "\$$switch_var eq $case_value->{expr}";

 my $prefix = '';
 if ($switch_state->{open_case}) {
  $prefix = '} ';
 }

 if (defined $attached_block) {
  my $actions = _lower_flow_branch_action_list([$attached_block], $ctx, $deps);
  return $finish->(undef, 'attached_actions_failed', {}) unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? '; '.join('; ', @$actions) : '';
  $switch_state->{open_case} = 0;
  return $finish->($prefix."if (!\$$hit_var && $match_expr) { \$$hit_var = 1$body }", 'attached_case', {
   mode => $case_value->{mode},
   action_count => scalar(@$actions),
  });
 }

 $switch_state->{open_case} = 1;
 return $finish->($prefix."if (!\$$hit_var && $match_expr) { \$$hit_var = 1", 'marker_case', {
  mode => $case_value->{mode},
 })
}

#------------------------------------------------------------------------------
# Function: _lower_default_flow_statement
# Purpose : Lower `default()` fluent switch default-branch markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_default_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $scope = _trace_control_enter(
  'lower_default_flow_statement',
  'default',
  { expr => defined($expr) ? $expr : '<undef>' },
 );
 my $finish = sub {
  my ($result, $decision, $context) = @_;
  _trace_control_decision(
   phase => 'lower_default_flow_statement',
   label => 'default',
   decision => $decision,
   taken => defined($result) && length($result) ? 1 : 0,
   context => $context,
  );
  _trace_control_exit($scope, { status => defined($result) && length($result) ? 'ok' : 'undef', decision => $decision });
  return $result
 };
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return $finish->(undef, 'parse_failed', {}) unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $call = $parsed_expr->{call};
 my $attached_block = $parsed_expr->{attached_block};
 return $finish->(undef, 'wrong_method', { method => $call ? ($call->{method} // '') : '<undef>' })
  unless $call && $call->{method} eq 'default';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return $finish->(undef, 'bad_arity', {}) unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return $finish->(undef, 'missing_switch_stack', {}) unless @$switch_stack;
 my $switch_state = $switch_stack->[-1];
 return $finish->(undef, 'duplicate_default', {}) if $switch_state->{default_seen};

 my $prefix = '';
 if ($switch_state->{open_case}) {
  $prefix = '} ';
 }
 $switch_state->{default_seen} = 1;

 my $hit_var = $switch_state->{hit_var};
 if (defined $attached_block) {
  my $actions = _lower_flow_branch_action_list([$attached_block], $ctx, $deps);
  return $finish->(undef, 'attached_actions_failed', {}) unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? '; '.join('; ', @$actions) : '';
  $switch_state->{open_case} = 0;
  return $finish->($prefix."if (!\$$hit_var) { \$$hit_var = 1$body }", 'attached_default', {
   action_count => scalar(@$actions),
  });
 }

 $switch_state->{open_case} = 1;
 return $finish->($prefix."if (!\$$hit_var) { \$$hit_var = 1", 'marker_default', {})
}

#------------------------------------------------------------------------------
# Function: _lower_endcase_flow_statement
# Purpose : Lower explicit `endcase()` markers (optional in fluent switch).
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_endcase_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return undef unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 return undef if defined $parsed_expr->{attached_block};
 my $call = $parsed_expr->{call};
 return undef unless $call && $call->{method} eq 'endcase';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return undef unless @$switch_stack;
 my $switch_state = $switch_stack->[-1];
 return undef unless $switch_state->{open_case};
 $switch_state->{open_case} = 0;
 return '}'
}

#------------------------------------------------------------------------------
# Function: _lower_endswitch_flow_statement
# Purpose : Lower `endswitch()` fluent switch terminator markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_endswitch_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $parsed_expr = _parse_method_expr_with_optional_attached_block($expr, $deps);
 return undef unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 return undef if defined $parsed_expr->{attached_block};
 my $call = $parsed_expr->{call};
 return undef unless $call && $call->{method} eq 'endswitch';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return undef unless @$switch_stack;
 my $switch_state = pop @$switch_stack;
 my $prefix = $switch_state->{open_case} ? '} ' : '';
 return $prefix.'}'
}

#------------------------------------------------------------------------------
# Function: _lower_say_statement
# Purpose : Lower `say(...)` fluent output helper calls.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_say_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'say';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, undef);
 return undef unless $effective_args && @$effective_args;
 my @values = map { _lower_control_flow_value_expr($_, $deps) } @$effective_args;
 return undef unless @values && !grep { !defined($_) || !length($_) } @values;
 return 'say '.join(', ', @values)
}

#------------------------------------------------------------------------------
# Function: _lower_print_statement
# Purpose : Lower `print(...)` fluent output helper calls.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_print_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'print';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, undef);
 return undef unless $effective_args && @$effective_args;
 my @values = map { _lower_control_flow_value_expr($_, $deps) } @$effective_args;
 return undef unless @values && !grep { !defined($_) || !length($_) } @values;
 return 'print '.join(', ', @values)
}

#------------------------------------------------------------------------------
# Function: _lower_print_each_statement
# Purpose : Lower `print_each(array(target), prefix, suffix?)` iterable output.
# Args    : ($expr, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_print_each_statement {
 my ($expr, $deps) = @_;
 my $require_dep = sub {
  my ($name) = @_;
  my $cb = (ref($deps) eq 'HASH') ? $deps->{$name} : undef;
  die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
   unless ref($cb) eq 'CODE';
  return $cb;
 };
 my $parse_method_function_expr = $require_dep->('parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = $require_dep->('normalize_method_args_with_optional_scope');
 my $trim_action_ir_value = $require_dep->('trim_action_ir_value');
 my $extract_array_symbol_name = $require_dep->('extract_array_symbol_name');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'print_each';

 my $raw_args = $call->{args} || [];
 my $effective_args = (
  ref($raw_args) eq 'ARRAY'
  && @$raw_args >= 2
  && @$raw_args <= 3
  && !(
   @$raw_args == 3
   && defined($raw_args->[0])
   && $raw_args->[0] =~ /^\s*[A-Za-z_][A-Za-z0-9_]*\s*$/o
   && defined($raw_args->[1])
   && $raw_args->[1] =~ /^\s*array\s*\(/o
  )
 ) ? $raw_args : $normalize_method_args_with_optional_scope->($raw_args, 2, 3);
 return undef unless $effective_args && @$effective_args >= 2;

 my $array_expr = $trim_action_ir_value->($effective_args->[0]);
 return undef unless defined($array_expr) && length($array_expr);
 my $array_symbol = $extract_array_symbol_name->($array_expr, $deps);
 return undef unless defined($array_symbol) && length($array_symbol);
 my $bare_symbol_kind = (ref($deps) eq 'HASH' && ref($deps->{bare_symbol_kind}) eq 'CODE')
  ? $deps->{bare_symbol_kind}
  : sub { return undef };
 my $iterable_expr = '@'.$array_symbol;
 if (($array_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o
      || $array_expr =~ /^array\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o)
  && (($bare_symbol_kind->($1) // '') eq 'scalar')) {
  $iterable_expr = '@{$'.$1.' // []}';
 }

 my $prefix_expr = _lower_control_flow_value_expr($effective_args->[1], $deps);
 return undef unless defined($prefix_expr) && length($prefix_expr);

 my @parts = ($prefix_expr, '$_');
 if (@$effective_args > 2) {
  my $suffix_expr = _lower_control_flow_value_expr($effective_args->[2], $deps);
  return undef unless defined($suffix_expr) && length($suffix_expr);
  push @parts, $suffix_expr;
 }

 return 'print '.join(', ', @parts).' foreach ('.$iterable_expr.')'
}

1;
