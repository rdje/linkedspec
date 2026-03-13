package LinkedSpec::ActionIR::ControlFlow;

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
 die "(LinkedSpec::ActionIR::ControlFlow::_require_dep) -E- missing dependency callback '$name'"
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
  my $code = $pkg->can($name);
  die "(LinkedSpec::ActionIR::ControlFlow::_require_pkg_cb) -E- missing callback '$pkg\::$name'"
   unless ref($code) eq 'CODE';
  return $code
 })
}

sub default_deps_for_package {
 my ($pkg) = @_;
 return _call_preserving_err(sub {
  return {
   trim_action_ir_value => _require_pkg_cb($pkg, '_trim_action_ir_value'),
   normalize_method_tag_expr => _require_pkg_cb($pkg, '_normalize_method_tag_expr'),
   lower_flow_composite_expr => _require_pkg_cb($pkg, '_lower_flow_composite_expr'),
   parse_method_function_expr => _require_pkg_cb($pkg, '_parse_method_function_expr'),
   normalize_method_args_with_optional_scope => _require_pkg_cb($pkg, '_normalize_method_args_with_optional_scope'),
  }
 })
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
 my $lower_flow_composite_expr = _require_dep($deps, 'lower_flow_composite_expr');
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
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $lower_flow_composite_expr = _require_dep($deps, 'lower_flow_composite_expr');
 my $normalize_method_tag_expr = _require_dep($deps, 'normalize_method_tag_expr');

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

#------------------------------------------------------------------------------
# Function: _lower_if_flow_statement
# Purpose : Lower `if(...)`/`i(...)` fluent control-flow markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_if_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && ($call->{method} eq 'if' || $call->{method} eq 'i');

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
 return undef unless $effective_args;
 my $cond_expr = _lower_control_flow_value_expr($effective_args->[0], $deps);
 return undef unless defined($cond_expr) && length($cond_expr);

 $ctx->{if_stack} ||= [];
 push @{$ctx->{if_stack}}, {else_seen => 0};
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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && ($call->{method} eq 'elif' || $call->{method} eq 'elseif');

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, 1);
 return undef unless $effective_args;
 my $cond_expr = _lower_control_flow_value_expr($effective_args->[0], $deps);
 return undef unless defined($cond_expr) && length($cond_expr);

 my $if_stack = $ctx->{if_stack} || [];
 return undef unless @$if_stack;
 my $current_if = $if_stack->[-1];
 return undef if $current_if->{else_seen};

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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'else';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $if_stack = $ctx->{if_stack} || [];
 return undef unless @$if_stack;
 my $current_if = $if_stack->[-1];
 return undef if $current_if->{else_seen};
 $current_if->{else_seen} = 1;

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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'endif';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 0, 0);
 return undef unless $effective_args;

 my $if_stack = $ctx->{if_stack} || [];
 return undef unless @$if_stack;
 pop @$if_stack;
 return '}'
}

#------------------------------------------------------------------------------
# Function: _lower_flow_branch_action_expr
# Purpose : Lower one branch action expression used in inline-composite switch
#           branch arguments (`case(..., action1, action2, ...)`).
# Args    : ($expr, $ctx, $deps)
# Returns : lowered Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_flow_branch_action_expr {
 my ($expr, $ctx, $deps) = @_;
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');

 return undef unless defined $expr;
 my $trimmed = $trim_action_ir_value->($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $rules = $ctx->{rewrite_rules};
 return $trimmed unless $rules && ref($rules) eq 'ARRAY';

 foreach my $rule (@$rules) {
  my $sub_ctx = {
   if_stack       => [],
   switch_stack   => [],
   switch_counter => ($ctx->{switch_counter} || 0),
   rewrite_rules  => $ctx->{rewrite_rules},
  };
  my $lowered = $rule->{apply}->($trimmed, $sub_ctx);
  next unless defined($lowered) && length($lowered);
  next if $lowered eq $trimmed;
  next if @{$sub_ctx->{if_stack} || []};
  next if @{$sub_ctx->{switch_stack} || []};
  $ctx->{switch_counter} = $sub_ctx->{switch_counter} if defined $sub_ctx->{switch_counter};
  return $lowered;
 }

 return $trimmed
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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $branch_call = $parse_method_function_expr->($branch_expr);
 return undef unless $branch_call;
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

  my @actions;
  foreach my $action_expr (@$effective_args[1 .. $#$effective_args]) {
   my $lowered_action = _lower_flow_branch_action_expr($action_expr, $ctx, $deps);
   return undef unless defined($lowered_action) && length($lowered_action);
   push @actions, $lowered_action;
  }
  my $body = @actions ? '; '.join('; ', @actions) : '';
  return "if (!\$$hit_var && $match_expr) { \$$hit_var = 1$body }";
 }

 if ($method eq 'default') {
  my $effective_args = $normalize_method_args_with_optional_scope->($branch_call->{args} || [], 0, undef);
  return undef unless $effective_args;
  return undef if $switch_state->{default_seen};
  $switch_state->{default_seen} = 1;

  my @actions;
  foreach my $action_expr (@$effective_args) {
   my $lowered_action = _lower_flow_branch_action_expr($action_expr, $ctx, $deps);
   return undef unless defined($lowered_action) && length($lowered_action);
   push @actions, $lowered_action;
  }
  my $body = @actions ? '; '.join('; ', @actions) : '';
  return "if (!\$$hit_var) { \$$hit_var = 1$body }";
 }

 return undef
}

#------------------------------------------------------------------------------
# Function: _lower_switch_flow_statement
# Purpose : Lower `switch(...)` fluent control-flow markers.
# Args    : ($expr, $ctx, $deps)
# Returns : Perl statement string or undef
#------------------------------------------------------------------------------
sub _lower_switch_flow_statement {
 my ($expr, $ctx, $deps) = @_;
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'switch';
 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, undef);
 return undef unless $effective_args && @$effective_args >= 1;
 return undef unless $effective_args;
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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
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
 $switch_state->{open_case} = 1;
 $switch_state->{default_seen} = 1;

 my $hit_var = $switch_state->{hit_var};
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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

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
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');

 my $call = $parse_method_function_expr->($expr);
 return undef unless $call && $call->{method} eq 'print';

 my $effective_args = $normalize_method_args_with_optional_scope->($call->{args} || [], 1, undef);
 return undef unless $effective_args && @$effective_args;
 my @values = map { _lower_control_flow_value_expr($_, $deps) } @$effective_args;
 return undef unless @values && !grep { !defined($_) || !length($_) } @values;
 return 'print '.join(', ', @values)
}

1;
