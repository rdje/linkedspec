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
# Purpose : Lower control-flow method argument values (`scalar(...)` etc.) into
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

 if ($trimmed =~ /^\w+$/o && $lowered eq $trimmed) {
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

 return "$1()" if $trimmed =~ /^(else|endif|default|endcase|endswitch)$/o;
 return $trimmed
}

#------------------------------------------------------------------------------
# Function: _lower_if_flow_statement
# Purpose : Lower `if(...)`/`i(...)` fluent control-flow markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_if_flow_statement {
 my ($expr, $ctx, $deps) = @_;
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
 return undef unless $parsed_expr && ref($parsed_expr->{call}) eq 'HASH';
 my $call = $parsed_expr->{call};
 my $attached_block = $parsed_expr->{attached_block};
 return undef unless $call && ($call->{method} eq 'if' || $call->{method} eq 'i');

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, undef);
 return undef unless $effective_args;
 my $cond_expr = _lower_control_flow_value_expr($effective_args->[0], $deps);
 return undef unless defined($cond_expr) && length($cond_expr);
 return undef if defined($attached_block) && @$effective_args > 1;

 if (defined $attached_block) {
  my $actions = _lower_flow_branch_action_list([$attached_block], $ctx, $deps);
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? ' '.join('; ', @$actions) : '';
  $ctx->{if_stack} ||= [];
  push @{$ctx->{if_stack}}, {else_seen => 0, implicit_close => 1, body_carrier => 'attached'};
  return "if ($cond_expr) {$body";
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
    return undef if $else_seen;
    my $clause = _lower_inline_if_branch_expr($arg, $ctx, $deps);
    return undef unless defined($clause) && length($clause);
    push @clauses, $clause;
    $seen_branch_header = 1;
    $else_seen = 1 if $arg_method eq 'else';
    next;
   }

   return undef if $seen_branch_header;
   push @if_action_exprs, $arg;
  }

  my $actions = _lower_flow_branch_action_list(\@if_action_exprs, $ctx, $deps);
  return undef unless ref($actions) eq 'ARRAY';

  my $body = @$actions ? ' '.join('; ', @$actions) : '';
  my $suffix = @clauses ? ' '.join(' ', @clauses) : '';
  return "do { if ($cond_expr) {$body$suffix } }";
 }

 $ctx->{if_stack} ||= [];
 push @{$ctx->{if_stack}}, {else_seen => 0, implicit_close => 0, body_carrier => 'marker'};
 return "if ($cond_expr) {"
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
  rewrite_rules  => $ctx->{rewrite_rules},
 }
}

sub _clone_flow_branch_rewrite_ctx {
 my ($ctx) = @_;
 return {
  if_stack       => [map { +{%$_} } @{$ctx->{if_stack} || []}],
  switch_stack   => [map { +{%$_} } @{$ctx->{switch_stack} || []}],
  switch_counter => ($ctx->{switch_counter} || 0),
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

 my $prefix = '';
 if (@{$branch_ctx->{if_stack} || []} && !_statement_continues_attached_if_flow($trimmed, $deps)) {
  $prefix = _flush_implicit_if_closures($branch_ctx);
 }

 my $direct_flow_lowered = _lower_flow_branch_direct_control_flow_statement($trimmed, $branch_ctx, $deps);
 if (defined($direct_flow_lowered) && length($direct_flow_lowered) && $direct_flow_lowered ne $trimmed) {
  return length($prefix) ? "$prefix $direct_flow_lowered" : $direct_flow_lowered;
 }

 my $rules = $branch_ctx->{rewrite_rules};
 unless ($rules && ref($rules) eq 'ARRAY') {
  return length($prefix) ? "$prefix $trimmed" : $trimmed;
 }

 foreach my $rule (@$rules) {
  my $candidate_ctx = _clone_flow_branch_rewrite_ctx($branch_ctx);
  my $lowered = $rule->{apply}->($trimmed, $candidate_ctx);
  next unless defined($lowered) && length($lowered);
  next if $lowered eq $trimmed;
  %$branch_ctx = %$candidate_ctx;
  return length($prefix) ? "$prefix $lowered" : $lowered;
 }

 return length($prefix) ? "$prefix $trimmed" : $trimmed
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
  my $effective_args = $normalize_method_args_with_optional_scope->($branch_call->{args} || [], 1, undef);
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
 return \@actions
}

#------------------------------------------------------------------------------
# Function: _lower_switch_flow_statement
# Purpose : Lower `switch(...)` fluent control-flow markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_switch_flow_statement {
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
 return undef unless $call && $call->{method} eq 'switch';
 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, undef);
 return undef unless $effective_args && @$effective_args >= 1;
 return undef if defined($attached_block) && @$effective_args > 1;
 my $switch_expr = _lower_control_flow_value_expr($effective_args->[0], $deps);
 return undef unless defined($switch_expr) && length($switch_expr);

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
   return undef unless defined($clause) && length($clause);
   push @clauses, $clause;
  }
  my $body = @clauses ? '; '.join('; ', @clauses) : '';
  return "do { my \$$switch_var = $switch_expr; my \$$hit_var = 0$body }";
 }

 if (defined $attached_block) {
  my $actions = _lower_attached_switch_body($attached_block, $ctx, $switch_state, $deps);
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? '; '.join('; ', @$actions) : '';
  return "do { my \$$switch_var = $switch_expr; my \$$hit_var = 0$body }";
 }

 $ctx->{switch_stack} ||= [];
 push @{$ctx->{switch_stack}}, $switch_state;

 return "do { my \$$switch_var = $switch_expr; my \$$hit_var = 0"
}

#------------------------------------------------------------------------------
# Function: _lower_case_flow_statement
# Purpose : Lower `case(...)` fluent switch-branch markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_case_flow_statement {
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
 return undef unless $call && $call->{method} eq 'case';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
 return undef unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return undef unless @$switch_stack;
 my $switch_state = $switch_stack->[-1];
 return undef if $switch_state->{default_seen};

 my $case_value = _lower_switch_case_value_expr($effective_args->[0], $deps);
 return undef unless $case_value && defined($case_value->{expr});
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
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? '; '.join('; ', @$actions) : '';
  $switch_state->{open_case} = 0;
  return $prefix."if (!\$$hit_var && $match_expr) { \$$hit_var = 1$body }";
 }

 $switch_state->{open_case} = 1;
 return $prefix."if (!\$$hit_var && $match_expr) { \$$hit_var = 1"
}

#------------------------------------------------------------------------------
# Function: _lower_default_flow_statement
# Purpose : Lower `default()` fluent switch default-branch markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_default_flow_statement {
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
 return undef unless $call && $call->{method} eq 'default';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $switch_stack = $ctx->{switch_stack} || [];
 return undef unless @$switch_stack;
 my $switch_state = $switch_stack->[-1];
 return undef if $switch_state->{default_seen};

 my $prefix = '';
 if ($switch_state->{open_case}) {
  $prefix = '} ';
 }
 $switch_state->{default_seen} = 1;

 my $hit_var = $switch_state->{hit_var};
 if (defined $attached_block) {
  my $actions = _lower_flow_branch_action_list([$attached_block], $ctx, $deps);
  return undef unless ref($actions) eq 'ARRAY';
  my $body = @$actions ? '; '.join('; ', @$actions) : '';
  $switch_state->{open_case} = 0;
  return $prefix."if (!\$$hit_var) { \$$hit_var = 1$body }";
 }

 $switch_state->{open_case} = 1;
 return $prefix."if (!\$$hit_var) { \$$hit_var = 1"
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

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 2, 3);
 return undef unless $effective_args && @$effective_args >= 2;

 my $array_expr = $trim_action_ir_value->($effective_args->[0]);
 return undef unless defined($array_expr) && length($array_expr);
 my $array_symbol = $extract_array_symbol_name->($array_expr, $deps);
 return undef unless defined($array_symbol) && length($array_symbol);

 my $prefix_expr = _lower_control_flow_value_expr($effective_args->[1], $deps);
 return undef unless defined($prefix_expr) && length($prefix_expr);

 my @parts = ($prefix_expr, '$_');
 if (@$effective_args > 2) {
  my $suffix_expr = _lower_control_flow_value_expr($effective_args->[2], $deps);
  return undef unless defined($suffix_expr) && length($suffix_expr);
  push @parts, $suffix_expr;
 }

 return 'print '.join(', ', @parts).' foreach (@'.$array_symbol.')'
}

1;
