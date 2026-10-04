package LinkedSpec::ActionIR::Scanner::FlowRules;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $action_ir_dir = File::Basename::dirname($module_dir);
 my $linked_spec_dir = File::Basename::dirname($action_ir_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

sub try_scan_contract_ir_events {
 my ($id, $code) = @_;
 my %dispatch = (
  'if_flow' => \&_scan_contract_if_flow,
  'elseif_flow' => \&_scan_contract_elseif_flow,
  'else_flow' => \&_scan_contract_else_flow,
  'endif_flow' => \&_scan_contract_endif_flow,
  'while_flow' => \&_scan_contract_while_flow,
  'switch_flow' => \&_scan_contract_switch_flow,
  'case_flow' => \&_scan_contract_case_flow,
  'default_flow' => \&_scan_contract_default_flow,
  'endcase_flow' => \&_scan_contract_endcase_flow,
  'endswitch_flow' => \&_scan_contract_endswitch_flow,
  'say_stmt' => \&_scan_contract_say_stmt,
  'print_each' => \&_scan_contract_print_each,
  'print_stmt' => \&_scan_contract_print_stmt,
  'exit_now' => \&_scan_contract_exit_now,
  'next_stmt' => \&_scan_contract_next_stmt,
  'return_undef' => \&_scan_contract_return_undef,
 );
 my $handler = $dispatch{$id};
 return undef unless $handler;
 return $handler->($code)
}

sub _normalize_bare_zero_arg_flow_marker_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 $expr =~ s/^\s+|\s+$//go;
 return undef unless length $expr;
 return 'else()' if $expr eq 'otherwise';
 return "$1()" if $expr =~ /^(else|endif|default|endcase|endswitch|next)$/o;
 return $expr
}

sub _scan_inline_switch_branch_events {
 my ($code, $target_method) = @_;
 my @events;

 while ($code =~ /\b(?<expr>switch\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
  my $switch_call = _parse_method_function_expr($+{expr});
  next unless $switch_call;
  my $switch_args = $switch_call->{args} || [];
  next unless ref($switch_args) eq 'ARRAY' && @$switch_args >= 2;

  foreach my $branch_expr (@{$switch_args}[1 .. $#$switch_args]) {
   my $branch_call = _parse_method_function_expr($branch_expr);
   next unless $branch_call && ($branch_call->{method} // '') eq $target_method;

   if ($target_method eq 'case') {
    my $effective_args = $branch_call->{args} || [];
    next unless ref($effective_args) eq 'ARRAY' && @$effective_args >= 1;
    push @events, {
     raw  => _trim_action_ir_value($branch_expr),
     args => {value => _trim_action_ir_value($effective_args->[0])},
    };
    if (@$effective_args > 1) {
     foreach my $nested_expr (@{$effective_args}[1 .. $#$effective_args]) {
      push @events, @{_scan_contract_case_marker_events($nested_expr)};
     }
    }
    next;
   }

   if ($target_method eq 'default') {
    my $effective_args = $branch_call->{args} || [];
    next unless ref($effective_args) eq 'ARRAY';
    push @events, {
     raw  => _trim_action_ir_value($branch_expr),
     args => {},
    };
    foreach my $nested_expr (@$effective_args) {
     push @events, @{_scan_contract_default_marker_events($nested_expr)};
    }
   }
  }
 }

 return \@events
}

sub _scan_contract_case_marker_events {
 my ($code) = @_;
 my @events;
 while ($code =~ /\b(?<head>case\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
  my $head = $+{head};
  my $block = $+{block};
  my $call = _parse_method_function_expr($head);
  next unless $call;
  my $raw_args = $call->{args} || [];
  next unless ref($raw_args) eq 'ARRAY';
  my $effective_args;
  if (@$raw_args == 1) {
   $effective_args = [$raw_args->[0]];
  } elsif (@$raw_args == 2 && defined($raw_args->[0]) && $raw_args->[0] =~ /^[A-Z_][A-Za-z0-9_]*$/o) {
   $effective_args = [$raw_args->[1]];
  }
  next unless $effective_args;
  my $raw = $head.($block // '');
  push @events, {raw => $raw, args => {value => _trim_action_ir_value($effective_args->[0])}};
  push @events, @{_scan_contract_case_marker_events($block)} if defined $block;
 }
 return \@events
}

sub _scan_contract_default_marker_events {
 my ($code) = @_;
 my @events;
 while ($code =~ /\b(?<head>default(?!\w)(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
  my $call = _parse_method_function_expr(_normalize_bare_zero_arg_flow_marker_expr($+{head}));
  next unless $call;
  my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
  next unless $effective_args;
  my $raw = $+{head}.($+{block} // '');
  push @events, {raw => $raw, args => {}};
  push @events, @{_scan_contract_default_marker_events($+{block})} if defined $+{block};
 }
 return \@events
}

sub _scan_contract_if_flow {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<head>(?:if|i|when)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
 my $call = _parse_method_function_expr($+{head});
 next unless $call;
 my $effective_args = $call->{args} || [];
 next unless ref($effective_args) eq 'ARRAY' && @$effective_args >= 1;
 my $raw = $+{head}.($+{block} // '');
 push @events, {raw => $raw, args => {condition => _trim_action_ir_value($effective_args->[0])}};
}
 return \@events
}

sub _scan_contract_elseif_flow {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<head>(?:elif|elseif)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
 my $call = _parse_method_function_expr($+{head});
 next unless $call;
 my $effective_args = $call->{args} || [];
 next unless ref($effective_args) eq 'ARRAY' && @$effective_args >= 1;
 my $raw = $+{head}.($+{block} // '');
 push @events, {raw => $raw, args => {condition => _trim_action_ir_value($effective_args->[0])}};
}
 return \@events
}

sub _scan_contract_else_flow {
 my ($code) = @_;
 my @events;
 while ($code =~ /\b(?<head>(?:else|otherwise)(?!\w)(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
 my $call = _parse_method_function_expr(_normalize_bare_zero_arg_flow_marker_expr($+{head}));
 next unless $call;
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, undef);
 next unless $effective_args;
 my $raw = $+{head}.($+{block} // '');
 push @events, {raw => $raw, args => {}};
}
 return \@events
}

sub _scan_contract_endif_flow {
 my ($code) = @_;
 my @events;
 while ($code =~ /\b(?<expr>endif(?!\w)(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)/g) {
 my $call = _parse_method_function_expr(_normalize_bare_zero_arg_flow_marker_expr($+{expr}));
 next unless $call;
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 next unless $effective_args;
 push @events, {raw => $+{expr}, args => {}};
}
 return \@events
}

sub _scan_contract_while_flow {
 my ($code) = @_;
 my @events;
 while ($code =~ /\b(?<head>while\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
  my $call = _parse_method_function_expr($+{head});
  next unless $call;
  my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
  next unless $effective_args && @$effective_args == 1;
  next unless defined $+{block};
  my $raw = $+{head}.$+{block};
  push @events, {raw => $raw, args => {condition => _trim_action_ir_value($effective_args->[0])}};
 }
 return \@events
}

sub _scan_contract_switch_flow {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<head>switch\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
 my $call = _parse_method_function_expr($+{head});
 next unless $call;
 my $effective_args = $call->{args} || [];
 next unless ref($effective_args) eq 'ARRAY' && @$effective_args >= 1;
 my $raw = $+{head}.($+{block} // '');
 push @events, {raw => $raw, args => {expr => _trim_action_ir_value($effective_args->[0])}};
}
 return \@events
}

sub _scan_contract_case_flow {
 my ($code) = @_;
 my @events = @{_scan_contract_case_marker_events($code)};
 push @events, @{_scan_inline_switch_branch_events($code, 'case')};
 return \@events
}

sub _scan_contract_default_flow {
 my ($code) = @_;
 my @events = @{_scan_contract_default_marker_events($code)};
 push @events, @{_scan_inline_switch_branch_events($code, 'default')};
 return \@events
}

sub _scan_contract_endcase_flow {
 my ($code) = @_;
 my @events;
 while ($code =~ /\b(?<expr>endcase(?!\w)(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)/g) {
 my $call = _parse_method_function_expr(_normalize_bare_zero_arg_flow_marker_expr($+{expr}));
 next unless $call;
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 next unless $effective_args;
 push @events, {raw => $+{expr}, args => {}};
}
 return \@events
}

sub _scan_contract_endswitch_flow {
 my ($code) = @_;
 my @events;
 while ($code =~ /\b(?<expr>endswitch(?!\w)(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)/g) {
 my $call = _parse_method_function_expr(_normalize_bare_zero_arg_flow_marker_expr($+{expr}));
 next unless $call;
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 next unless $effective_args;
 push @events, {raw => $+{expr}, args => {}};
}
 return \@events
}

sub _scan_contract_say_stmt {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>say\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $call = _parse_method_function_expr($+{expr});
 next unless $call && ($call->{method} // '') eq 'say';
 my $effective_args = $call->{args} || [];
 next unless ref($effective_args) eq 'ARRAY';
 push @events, {raw => $+{expr}, args => {values => [map { _trim_action_ir_value($_) } @$effective_args]}};
}
 return \@events
}

sub _scan_contract_print_stmt {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>print\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $call = _parse_method_function_expr($+{expr});
 next unless $call && ($call->{method} // '') eq 'print';
 my $effective_args = $call->{args} || [];
 next unless ref($effective_args) eq 'ARRAY';
 push @events, {raw => $+{expr}, args => {values => [map { _trim_action_ir_value($_) } @$effective_args]}};
}
 return \@events
}

sub _scan_contract_print_each {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>print_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $call = _parse_method_function_expr($+{expr});
 next unless $call && $call->{method} eq 'print_each';
 my $effective_args = $call->{args} || [];
 next unless ref($effective_args) eq 'ARRAY';
 push @events, {
  raw  => $+{expr},
  args => {target => @$effective_args ? _trim_action_ir_value($effective_args->[0]) : ''},
 };
}
 return \@events
}

sub _scan_contract_exit_now {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>exit_now\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $call = _parse_method_function_expr($+{expr});
 next unless $call && ($call->{method} // '') eq 'exit_now';
 my @args = @{$call->{args} || []};
 push @events, {raw => $+{expr}, args => {payload => @args ? _trim_action_ir_value($args[0]) : ''}};
}
 return \@events
}

sub _scan_contract_next_stmt {
 my ($code) = @_;
 my @events;
 foreach my $statement (@{_split_action_ir_statements($code)}) {
  my $trimmed = _trim_action_ir_value($statement);
  next unless defined($trimmed) && length($trimmed);
  next unless $trimmed =~ /^next(?:\s*\(\s*\))?$/o;
  push @events, {raw => $trimmed, args => {}};
 }
 return \@events
}

sub _scan_contract_return_undef {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>return_undef\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $call = _parse_method_function_expr($+{expr});
 next unless $call;
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
 next unless $effective_args;
 push @events, {raw => $+{expr}, args => {value => 'undef'}};
}
 return \@events
}

1;

1;
