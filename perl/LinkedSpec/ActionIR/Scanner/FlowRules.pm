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
  'switch_flow' => \&_scan_contract_switch_flow,
  'case_flow' => \&_scan_contract_case_flow,
  'default_flow' => \&_scan_contract_default_flow,
  'endcase_flow' => \&_scan_contract_endcase_flow,
  'endswitch_flow' => \&_scan_contract_endswitch_flow,
  'say_stmt' => \&_scan_contract_say_stmt,
  'print_stmt' => \&_scan_contract_print_stmt,
  'exit_now' => \&_scan_contract_exit_now,
  'return_undef' => \&_scan_contract_return_undef,
  'return_array' => \&_scan_contract_return_array,
  'declare_typed' => \&_scan_contract_declare_typed,
  'declare_alias' => \&_scan_contract_declare_alias,
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
 return "$1()" if $expr =~ /^(else|endif|default|endcase|endswitch)$/o;
 return $expr
}

sub _scan_inline_switch_branch_events {
 my ($code, $target_method) = @_;
 my @events;

 while ($code =~ /\b(?<expr>switch\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
  my $switch_call = _parse_method_function_expr($+{expr});
  next unless $switch_call;
  my $switch_args = _normalize_method_args_with_optional_scope($switch_call->{args} || [], 1, undef);
  next unless $switch_args && @$switch_args >= 2;

  foreach my $branch_expr (@{$switch_args}[1 .. $#$switch_args]) {
   my $branch_call = _parse_method_function_expr($branch_expr);
   next unless $branch_call && ($branch_call->{method} // '') eq $target_method;

   if ($target_method eq 'case') {
    my $effective_args = _normalize_method_args_with_optional_scope($branch_call->{args} || [], 1, undef);
    next unless $effective_args && @$effective_args >= 1;
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
    my $effective_args = _normalize_method_args_with_optional_scope($branch_call->{args} || [], 0, undef);
    next unless $effective_args;
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
  my $call = _parse_method_function_expr($+{head});
  next unless $call;
  my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
  next unless $effective_args;
  my $raw = $+{head}.($+{block} // '');
  push @events, {raw => $raw, args => {value => _trim_action_ir_value($effective_args->[0])}};
  push @events, @{_scan_contract_case_marker_events($+{block})} if defined $+{block};
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
while ($code =~ /\b(?<head>(?:if|i)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
 my $call = _parse_method_function_expr($+{head});
 next unless $call;
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
 next unless $effective_args && @$effective_args >= 1;
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
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
 next unless $effective_args && @$effective_args >= 1;
 my $raw = $+{head}.($+{block} // '');
 push @events, {raw => $raw, args => {condition => _trim_action_ir_value($effective_args->[0])}};
}
 return \@events
}

sub _scan_contract_else_flow {
 my ($code) = @_;
 my @events;
 while ($code =~ /\b(?<head>else(?!\w)(?:\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))?)(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
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

sub _scan_contract_switch_flow {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<head>switch\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))(?<block>\s*(?<BRACE>\{(?:[^{}\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&BRACE))*\}))?/g) {
 my $call = _parse_method_function_expr($+{head});
 next unless $call;
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
 next unless $effective_args && @$effective_args >= 1;
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
 next unless $call;
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
 next unless $effective_args && @$effective_args;
 push @events, {raw => $+{expr}, args => {values => [map { _trim_action_ir_value($_) } @$effective_args]}};
}
 return \@events
}

sub _scan_contract_print_stmt {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>print\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $call = _parse_method_function_expr($+{expr});
 next unless $call;
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
 next unless $effective_args && @$effective_args;
 push @events, {raw => $+{expr}, args => {values => [map { _trim_action_ir_value($_) } @$effective_args]}};
}
 return \@events
}

sub _scan_contract_exit_now {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>exit_now\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $call = _parse_method_function_expr($+{expr});
 next unless $call;
 my @args = @{$call->{args} || []};
 next unless @args <= 1;
 push @events, {raw => $+{expr}, args => {payload => @args ? _trim_action_ir_value($args[0]) : ''}};
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

sub _scan_contract_return_array {
 my ($code) = @_;
 my @events;
while ($code =~ /\breturn_array\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<tag>(?:'[^']*'|\"[^\"]*\"|\w+))\s*,\s*(?<payload>(?:[^()]++|(?<P>\((?:[^()]++|(?&P))*\)))+)\s*\)/g) {
 push @events, {raw => $&, args => {scope => $+{scope}, tag => $+{tag}, payload => _trim_action_ir_value($+{payload})}};
}
 return \@events
}

sub _scan_contract_declare_typed {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>declare\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $decl = _extract_declare_statement_from_method_expr($+{expr});
 next unless $decl;
 my @parsed_entries = map { _parse_declare_binding_entry($_) } @{$decl->{entries} || []};
 next if grep { !defined($_) || !defined($_->{name}) } @parsed_entries;
 my @names = map { $_->{name} } @parsed_entries;
 my %initializers = map { defined($_->{init}) ? ($_->{name} => $_->{init}) : () } @parsed_entries;
 push @events, {
  raw => $+{expr},
  args => {
   declaration_type => $decl->{declaration_type},
   names            => [@names],
   initializers     => {%initializers},
  },
 };
}
 return \@events
}

sub _scan_contract_declare_alias {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>declare_(?:a|array|s|scalar|h|hash)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $decl = _extract_declare_statement_from_method_expr($+{expr});
 next unless $decl;
 my @parsed_entries = map { _parse_declare_binding_entry($_) } @{$decl->{entries} || []};
 next if grep { !defined($_) || !defined($_->{name}) } @parsed_entries;
 my @names = map { $_->{name} } @parsed_entries;
 my %initializers = map { defined($_->{init}) ? ($_->{name} => $_->{init}) : () } @parsed_entries;
 push @events, {
  raw => $+{expr},
  args => {
   declaration_type => $decl->{declaration_type},
   names            => [@names],
   initializers     => {%initializers},
  },
 };
}
 return \@events
}

1;
