package LinkedSpec::ActionRewriter;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::MethodExpr ();

sub _trim_action_ir_value {
 my ($value) = @_;
 return undef unless defined $value;
 $value =~ s/^\s*|\s*$//go;
 return $value
}

sub _split_declare_symbol_names {
 my ($raw_names) = @_;
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
 my ($entry) = @_;
 return undef unless defined $entry;
 my $trimmed = _trim_action_ir_value($entry);
 return undef unless defined($trimmed) && length($trimmed);

 return {name => $1} if $trimmed =~ /^(?<name>\w+)$/o;
 if ($trimmed =~ /^(?<name>\w+)\s*=\s*(?<init>.+)$/s) {
  my $init = _trim_action_ir_value($+{init});
  return undef unless defined($init) && length($init);
  return {name => $+{name}, init => $init};
 }
 return undef
}

sub _lower_declare_value_expr {
 my ($expr) = @_;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);

 my $lowered = LinkedSpec::_lower_flow_composite_expr($trimmed);
 return $lowered if defined($lowered) && length($lowered) && $lowered ne $trimmed;

 $lowered = LinkedSpec::_lower_method_value_expr($trimmed);
 return $lowered if defined($lowered) && length($lowered);

 return $trimmed
}

sub _lower_declare_initializer_expr {
 my ($type, $expr) = @_;
 return undef unless defined $type;
 return undef unless defined $expr;
 my $trimmed = _trim_action_ir_value($expr);
 return undef unless defined($trimmed) && length($trimmed);

 if ($type eq 'array') {
  my $array_ctor = LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($trimmed);
  if ($array_ctor && $array_ctor->{method} eq 'array') {
   my $items = $array_ctor->{args} || [];
   return undef unless ref($items) eq 'ARRAY';
   my @lowered_items = map { _lower_declare_value_expr($_) } @$items;
   return undef if grep { !defined($_) || !length($_) } @lowered_items;
   return '('.join(', ', @lowered_items).')';
  }
  if ($trimmed =~ /^\[(?<payload>.*)\]$/s) {
   return '('.$+{payload}.')';
  }
 }

 if ($type eq 'hash') {
  my $hash_ctor = LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($trimmed);
  if ($hash_ctor && $hash_ctor->{method} eq 'hash') {
   my $items = $hash_ctor->{args} || [];
   return undef unless ref($items) eq 'ARRAY';
   return undef unless @$items % 2 == 0;
   my @pairs;
   for (my $i = 0; $i < @$items; $i += 2) {
    my $key_expr = _lower_declare_value_expr($items->[$i]);
    my $val_expr = _lower_declare_value_expr($items->[$i + 1]);
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

 return _lower_declare_value_expr($trimmed)
}

sub _extract_declare_statement_from_method_expr {
 my ($expr) = @_;
 my $call = LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($expr);
 return undef unless $call;
 my $method = $call->{method} // '';

 if ($method eq 'declare') {
  my @effective_args = @{$call->{args} || []};
  if (
   @effective_args >= 3 &&
   LinkedSpec::ActionIR::MethodExpr::_is_bare_method_scope_token($effective_args[0]) &&
   defined(_trim_action_ir_value($effective_args[1])) &&
   _trim_action_ir_value($effective_args[1]) =~ /^(array|scalar|hash)$/o
  ) {
   shift @effective_args;
  }

  return undef unless @effective_args >= 2;
  my $type = _trim_action_ir_value($effective_args[0]);
  return undef unless defined($type) && $type =~ /^(array|scalar|hash)$/o;
  my @entries = @effective_args[1 .. $#effective_args];
  return undef unless @entries;
  return {
   declaration_type => $type,
   entries          => \@entries,
  };
 }

 if ($method =~ /^declare_(?<alias>a|array|s|scalar|h|hash)$/o) {
  my $type = LinkedSpec::_declare_alias_to_type($+{alias});
  return undef unless defined $type;
  my $effective_args = LinkedSpec::ActionIR::MethodExpr::_normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
  return undef unless $effective_args && @$effective_args >= 1;
  return {
   declaration_type => $type,
   entries          => [@$effective_args],
  };
 }

 return undef
}

sub _lower_declare_method_statement {
 my ($expr) = @_;
 my $decl = _extract_declare_statement_from_method_expr($expr);
 return undef unless $decl;
 return LinkedSpec::_lower_typed_declare_statement($decl->{declaration_type}, $decl->{entries})
}

sub _lower_assign_method_statement {
 my ($expr) = @_;
 my $call = LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr($expr);
 return undef unless $call && $call->{method} eq 'assign';

 my $effective_args = LinkedSpec::ActionIR::MethodExpr::_normalize_method_args_with_optional_scope($call->{args} || [], 2, 2);
 return undef unless $effective_args;
 return LinkedSpec::_lower_assign_statement($effective_args->[0], $effective_args->[1])
}

sub _find_unresolved_action_helpers {
 my ($code, $rewrite_rules) = @_;

 my %hits;
 my $total = 0;
 my @events;
 my @statements = @{_split_action_ir_statements($code)};
 foreach my $rule (@$rewrite_rules) {
  my $helper_name = $rule->{diag_name} // $rule->{id};
  my $helper_re = $rule->{unresolved_pattern};
  next unless $helper_re;
  foreach my $statement (@statements) {
   my $count = () = ($statement =~ /$helper_re/g);
   next unless $count;
   $hits{$helper_name} += $count;
   $total += $count;
   push @events, map { +{helper => $helper_name, raw => $statement} } (1 .. $count);
  }
 }

 return {
  unresolved_helper_count => $total,
  unresolved_helper_hits  => \%hits,
  unresolved_helpers      => [sort keys %hits],
  unresolved_helper_events => \@events,
 }
}

sub _collect_action_helper_ir_nodes {
 my ($code, $rewrite_rules) = @_;

 my %hits;
 my $total = 0;
 my @events;
 foreach my $rule (@$rewrite_rules) {
  my $ir_node = $rule->{ir_node} // $rule->{id};
  my $rule_events = LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(
   $rule,
   $code,
   {
    split_action_ir_statements                 => \&_split_action_ir_statements,
    trim_action_ir_value                       => \&_trim_action_ir_value,
    parse_method_function_expr                 => \&LinkedSpec::ActionIR::MethodExpr::_parse_method_function_expr,
    normalize_method_args_with_optional_scope  => \&LinkedSpec::ActionIR::MethodExpr::_normalize_method_args_with_optional_scope,
    build_array_pipeline_plan_from_expr        => \&LinkedSpec::_build_array_pipeline_plan_from_expr,
    extract_declare_statement_from_method_expr => \&_extract_declare_statement_from_method_expr,
    parse_declare_binding_entry                => \&_parse_declare_binding_entry,
   }
  );
  next unless ref($rule_events) eq 'ARRAY' && @$rule_events;
  foreach my $event (@$rule_events) {
   push @events, {
    ir_node     => $ir_node,
    contract_id => $rule->{id},
    raw         => $event->{raw},
    args        => $event->{args} || {},
   };
   $hits{$ir_node} += 1;
   $total += 1;
  }
 }

 return {
  helper_action_ir_count => $total,
  helper_action_ir_hits  => \%hits,
  helper_action_ir_nodes => [sort keys %hits],
  helper_action_ir_events => \@events,
 }
}

sub _canonicalize_helper_action_ir_event {
 my ($label, $event) = @_;

 my $contract_id = $event->{contract_id} // '';
 my $ir_node = $event->{ir_node} // 'HELPER';
 my %args = %{(ref($event->{args}) eq 'HASH') ? $event->{args} : {}};

 my $kind = $ir_node;
 if ($contract_id eq 'call') {
  $kind = 'CALL';
 }
 elsif ($contract_id eq 'return_call') {
  $kind = 'CALL';
  $args{context} = 'return';
 }
 elsif ($contract_id eq 'return_bare') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'exit_bare') {
  $kind = 'EXIT';
 }
 elsif ($contract_id eq 'linecount_prefix_newline_matches') {
  $kind = 'LINE_COUNT';
 }
 elsif ($contract_id eq 'print_capture_substr') {
  $kind = 'PRINT';
 }
 elsif ($contract_id eq 'assign_match_my') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'destructure_imatch_list_my') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'regex_subst_assignment') {
  $kind = 'REGEX_SUBST';
 }
 elsif ($contract_id eq 'next_bare') {
  $kind = 'NEXT';
 }
 elsif ($contract_id eq 'ref_field_assign') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'position_tracking') {
  $kind = 'POSITION_TRACK';
 }
 elsif ($contract_id eq 'print_foreach_iterable') {
  $kind = 'PRINT';
 }
 elsif ($contract_id eq 'return_imatch' || $contract_id eq 'return_array') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'assign_value') {
  $kind = 'ASSIGN';
 }
 elsif ($contract_id eq 'regex_subst') {
  $kind = 'REGEX_SUBST';
 }
 elsif ($contract_id eq 'declare_typed' || $contract_id eq 'declare_alias') {
  $kind = 'DECLARE';
 }
 elsif ($contract_id eq 'push_single_arg') {
  $kind = 'PUSH';
  $args{target} = $label unless defined $args{target};
  $args{target_mode} = 'implicit_current_label';
 }
 elsif ($contract_id eq 'push_target_arg') {
  $kind = 'PUSH';
  $args{target_mode} = 'explicit';
 }
 elsif ($contract_id eq 'push_scope_target_arg') {
  $kind = 'PUSH';
  $args{target_mode} = 'explicit';
 }
 elsif ($contract_id eq 'return_a') {
  $kind = 'RETURN_A';
 }
 elsif ($contract_id eq 'return_general') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'return') {
  $kind = 'RETURN';
 }
 elsif ($contract_id eq 'return_ma') {
  $kind = 'RETURN_MA';
 }
 elsif ($contract_id eq 'return_m') {
  $kind = 'RETURN_M';
 }
 elsif ($contract_id eq 'capture_macro') {
  $kind = 'CAPTURE_MACRO';
 }
 elsif ($contract_id eq 'capture') {
  $kind = 'CAPTURE';
 }
 elsif ($contract_id eq 'capture_if' || $contract_id eq 'capture_if_macro') {
  $kind = 'CAPTURE_IF';
 }
 elsif ($contract_id eq 'ibacktrack' || $contract_id eq 'ibacktrack_macro') {
  $kind = 'IBACKTRACK';
 }
 elsif ($contract_id eq 'backtrack' || $contract_id eq 'backtrack_macro') {
  $kind = 'BACKTRACK';
 }
 elsif ($contract_id eq 'if_flow') {
  $kind = 'IF';
 }
 elsif ($contract_id eq 'elseif_flow') {
  $kind = 'ELIF';
 }
 elsif ($contract_id eq 'else_flow') {
  $kind = 'ELSE';
 }
 elsif ($contract_id eq 'endif_flow') {
  $kind = 'ENDIF';
 }
 elsif ($contract_id eq 'switch_flow') {
  $kind = 'SWITCH';
 }
 elsif ($contract_id eq 'case_flow') {
  $kind = 'CASE';
 }
 elsif ($contract_id eq 'default_flow') {
  $kind = 'DEFAULT';
 }
 elsif ($contract_id eq 'endcase_flow') {
  $kind = 'ENDCASE';
 }
 elsif ($contract_id eq 'endswitch_flow') {
  $kind = 'ENDSWITCH';
 }
 elsif ($contract_id eq 'say_stmt') {
  $kind = 'SAY';
 }
 elsif ($contract_id eq 'print_stmt') {
  $kind = 'PRINT';
 }
 elsif ($contract_id eq 'return_undef') {
  $kind = 'RETURN';
  $args{value} = 'undef';
 }

 return {
  kind        => $kind,
  source      => 'helper_contract',
  contract_id => $contract_id,
  raw         => $event->{raw},
  args        => \%args,
 }
}

sub _split_action_ir_statements {
 my ($code) = @_;

 my @statements;
 my $statement = '';
 my $paren_depth = 0;
 my $brace_depth = 0;
 my $bracket_depth = 0;
 my $in_single_quote = 0;
 my $in_double_quote = 0;
 my $in_backtick_quote = 0;
 my $in_slash_quote = 0;
 my $slash_quote_segments_remaining = 0;
 my $slash_quote_escape_next = 0;
 my $in_angle_quote = 0;
 my $angle_quote_segments_remaining = 0;
 my $angle_quote_depth = 0;
 my $angle_quote_escape_next = 0;
 my $in_pipe_quote = 0;
 my $pipe_quote_segments_remaining = 0;
 my $pipe_quote_escape_next = 0;
 my $in_line_comment = 0;
 my $escape_next = 0;

 foreach my $char (split //, $code) {
  if ($in_line_comment) {
   $statement .= $char;
   if ($char eq "\n") {
    $in_line_comment = 0;
   }
   next;
  }
  if ($in_single_quote) {
   $statement .= $char;
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
   $statement .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq '"') {
    $in_double_quote = 0;
   }
   next;
  }

  if ($in_slash_quote) {
   $statement .= $char;
   if ($slash_quote_escape_next) {
    $slash_quote_escape_next = 0;
   } elsif ($char eq '\\') {
    $slash_quote_escape_next = 1;
   } elsif ($char eq '/') {
    --$slash_quote_segments_remaining if $slash_quote_segments_remaining > 0;
    $in_slash_quote = 0 if $slash_quote_segments_remaining == 0;
   }
   next;
  }
  if ($in_angle_quote) {
   $statement .= $char;
   if ($angle_quote_escape_next) {
    $angle_quote_escape_next = 0;
   } elsif ($char eq '\\') {
    $angle_quote_escape_next = 1;
   } elsif ($char eq '<') {
    ++$angle_quote_depth;
   } elsif ($char eq '>') {
    --$angle_quote_depth if $angle_quote_depth > 0;
    if ($angle_quote_depth == 0) {
     --$angle_quote_segments_remaining if $angle_quote_segments_remaining > 0;
     $in_angle_quote = 0 if $angle_quote_segments_remaining == 0;
    }
   }
   next;
  }
  if ($in_pipe_quote) {
   $statement .= $char;
   if ($pipe_quote_escape_next) {
    $pipe_quote_escape_next = 0;
   } elsif ($char eq '\\') {
    $pipe_quote_escape_next = 1;
   } elsif ($char eq '|') {
    --$pipe_quote_segments_remaining if $pipe_quote_segments_remaining > 0;
    $in_pipe_quote = 0 if $pipe_quote_segments_remaining == 0;
   }
   next;
  }
  if ($char eq "'") {
   $in_single_quote = 1;
   $statement .= $char;
   next;
  }
  if ($in_backtick_quote) {
   $statement .= $char;
   if ($escape_next) {
    $escape_next = 0;
   } elsif ($char eq '\\') {
    $escape_next = 1;
   } elsif ($char eq '`') {
    $in_backtick_quote = 0;
   }
   next;
  }

  if ($char eq '"') {
   $in_double_quote = 1;
   $statement .= $char;
   next;
  }

  if ($char eq '`') {
   $in_backtick_quote = 1;
   $statement .= $char;
   next;
  }

  if ($char eq '#') {
   $in_line_comment = 1;
   $statement .= $char;
   next;
  }
  if ($char eq '/') {
   my $slash_context = $statement;
   $slash_context =~ s/\s+$//o;

   if ($slash_context =~ /(?:^|[^\w:])(?<op>s|tr|y|qr|qq|qx|q|m)\s*$/o) {
    my $op = $+{op};
    $in_slash_quote = 1;
    $slash_quote_segments_remaining = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
    $slash_quote_escape_next = 0;
    $statement .= $char;
    next;
   } elsif ($slash_context =~ /(?:=~|!~)\s*$/o) {
    $in_slash_quote = 1;
    $slash_quote_segments_remaining = 1;
    $slash_quote_escape_next = 0;
    $statement .= $char;
    next;
   }
  }
  if ($char eq '<') {
   my $angle_context = $statement;
   $angle_context =~ s/\s+$//o;

   if ($angle_context =~ /(?:^|[^\$\w:])(?<op>s|tr|y|qr|qq|qx|q)\s*$/o) {
    my $op = $+{op};
    $in_angle_quote = 1;
    $angle_quote_segments_remaining = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
    $angle_quote_depth = 1;
    $angle_quote_escape_next = 0;
    $statement .= $char;
    next;
   }
  }
  if ($char eq '|') {
   my $pipe_context = $statement;
   $pipe_context =~ s/\s+$//o;

   if ($pipe_context =~ /(?:^|[^\$\w:])(?<op>s|tr|y|qr|qq|qx|q|m)\s*$/o) {
    my $op = $+{op};
    $in_pipe_quote = 1;
    $pipe_quote_segments_remaining = ($op eq 's' || $op eq 'tr' || $op eq 'y') ? 2 : 1;
    $pipe_quote_escape_next = 0;
    $statement .= $char;
    next;
   } elsif ($pipe_context =~ /(?:=~|!~)\s*m?\s*$/o) {
    $in_pipe_quote = 1;
    $pipe_quote_segments_remaining = 1;
    $pipe_quote_escape_next = 0;
    $statement .= $char;
    next;
   }
  }

  if ($char eq '(') {
   ++$paren_depth;
   $statement .= $char;
   next;
  }

  if ($char eq ')') {
   --$paren_depth if $paren_depth > 0;
   $statement .= $char;
   next;
  }

  if ($char eq '{') {
   ++$brace_depth;
   $statement .= $char;
   next;
  }

  if ($char eq '}') {
   --$brace_depth if $brace_depth > 0;
   $statement .= $char;
   next;
  }

  if ($char eq '[') {
   ++$bracket_depth;
   $statement .= $char;
   next;
  }

  if ($char eq ']') {
   --$bracket_depth if $bracket_depth > 0;
   $statement .= $char;
   next;
  }

  if (
   $char eq ';' &&
   $paren_depth == 0 &&
   $brace_depth == 0 &&
   $bracket_depth == 0
  ) {
   my $trimmed = _trim_action_ir_value($statement);
   push @statements, $trimmed if defined($trimmed) && length($trimmed);
   $statement = '';
   next;
  }

  $statement .= $char;
 }

 my $trimmed = _trim_action_ir_value($statement);
 push @statements, $trimmed if defined($trimmed) && length($trimmed);
 return \@statements
}
sub _build_canonical_action_ir_events {
 my ($label, $code, $helper_events) = @_;

 my %helper_event_queue;
 foreach my $helper_event (@$helper_events) {
  my $raw_key = _trim_action_ir_value($helper_event->{raw});
  next unless defined($raw_key) && length($raw_key);
  my $canonical_event = _canonicalize_helper_action_ir_event($label, $helper_event);
  push @{$helper_event_queue{$raw_key}}, $canonical_event;
 }

 my @canonical_events;
 my $fallback_count = 0;
 foreach my $statement (@{_split_action_ir_statements($code)}) {
  if (exists $helper_event_queue{$statement} && @{$helper_event_queue{$statement}}) {
   push @canonical_events, shift @{$helper_event_queue{$statement}};
  } else {
   push @canonical_events, {
    kind        => 'RAW_PERL',
    source      => 'fallback_non_helper_statement',
    contract_id => undef,
    raw         => $statement,
    args        => {code => $statement},
   };
   ++$fallback_count;
  }
 }

 foreach my $raw_key (keys %helper_event_queue) {
  while (@{$helper_event_queue{$raw_key}}) {
   my $event = shift @{$helper_event_queue{$raw_key}};
   $event->{source} = 'unmatched_helper_scan_event';
   push @canonical_events, $event;
  }
 }

 my %hits;
 my $count = 0;
 foreach my $event (@canonical_events) {
  my $kind = $event->{kind} // 'UNKNOWN';
  $hits{$kind} += 1;
  ++$count;
 }

 return {
  canonical_action_ir_count => $count,
  canonical_action_ir_hits  => \%hits,
  canonical_action_ir_nodes => [sort keys %hits],
  canonical_action_ir_events => \@canonical_events,
  canonical_action_ir_fallback_count => $fallback_count,
 }
}

sub _lower_action_code_from_canonical_ir {
 my ($label, $code, $rewrite_rules, $canonical_ir_diag) = @_;

 my %rewrite_by_id = map { $_->{id} => $_ } @$rewrite_rules;
 my $rewritten = $code;
 my $lower_ctx = {
  if_stack      => [],
  switch_stack  => [],
  switch_counter => 0,
  rewrite_rules => $rewrite_rules,
 };
 foreach my $event (@{$canonical_ir_diag->{canonical_action_ir_events}}) {
  my $kind = $event->{kind} // '';
  next if $kind eq 'RAW_PERL';

  my $contract_id = $event->{contract_id};
  next unless defined $contract_id && exists $rewrite_by_id{$contract_id};

  my $source_stmt = $event->{raw};
  next unless defined($source_stmt) && length($source_stmt);
  my $lowered_stmt = $rewrite_by_id{$contract_id}{apply}->($source_stmt, $lower_ctx);
  next unless defined($lowered_stmt) && length($lowered_stmt);
  next if $lowered_stmt eq $source_stmt;

  my $pos = index($rewritten, $source_stmt);
  next if $pos < 0;
  substr($rewritten, $pos, length($source_stmt), $lowered_stmt);
 }
 if (@{$lower_ctx->{if_stack}} || @{$lower_ctx->{switch_stack}}) {
  return $code;
 }

 return $rewritten
}

sub _accumulate_action_rewrite_diagnostics {
 my ($acc, $diag) = @_;
 return $acc unless $acc && $diag && ref($diag) eq 'HASH';

 my $hits = $diag->{unresolved_helper_hits};
 return $acc unless $hits && ref($hits) eq 'HASH';

 foreach my $helper_name (keys %$hits) {
  my $count = $hits->{$helper_name} || 0;
  next unless $count;
  $acc->{unresolved_helper_hits}{$helper_name} += $count;
  $acc->{unresolved_helper_count} += $count;
 }
 my $unresolved_events = $diag->{unresolved_helper_events};
 if ($unresolved_events && ref($unresolved_events) eq 'ARRAY' && @$unresolved_events) {
  push @{$acc->{unresolved_helper_events}}, @$unresolved_events;
 }

 my $ir_hits = $diag->{helper_action_ir_hits};
 if ($ir_hits && ref($ir_hits) eq 'HASH') {
  foreach my $ir_node (keys %$ir_hits) {
   my $count = $ir_hits->{$ir_node} || 0;
   next unless $count;
   $acc->{helper_action_ir_hits}{$ir_node} += $count;
   $acc->{helper_action_ir_count} += $count;
  }
 }

 my $ir_events = $diag->{helper_action_ir_events};
 if ($ir_events && ref($ir_events) eq 'ARRAY' && @$ir_events) {
  push @{$acc->{helper_action_ir_events}}, @$ir_events;
 }

 my $canonical_hits = $diag->{canonical_action_ir_hits};
 if ($canonical_hits && ref($canonical_hits) eq 'HASH') {
  foreach my $kind (keys %$canonical_hits) {
   my $count = $canonical_hits->{$kind} || 0;
   next unless $count;
   $acc->{canonical_action_ir_hits}{$kind} += $count;
   $acc->{canonical_action_ir_count} += $count;
  }
 }

 my $canonical_events = $diag->{canonical_action_ir_events};
 if ($canonical_events && ref($canonical_events) eq 'ARRAY' && @$canonical_events) {
  push @{$acc->{canonical_action_ir_events}}, @$canonical_events;
 }

 $acc->{canonical_action_ir_fallback_count} += ($diag->{canonical_action_ir_fallback_count} || 0);

 return $acc
}

sub _rewrite_action_code_with_diagnostics {
 my ($label, $code, $rewrite_rules) = @_;

 $rewrite_rules //= _build_action_rewrite_rules($label);
 my $ir_diag = _collect_action_helper_ir_nodes($code, $rewrite_rules);
 my $canonical_ir_diag = _build_canonical_action_ir_events($label, $code, $ir_diag->{helper_action_ir_events});
 my $rewritten = _lower_action_code_from_canonical_ir($label, $code, $rewrite_rules, $canonical_ir_diag);
 my $diag = _find_unresolved_action_helpers($rewritten, $rewrite_rules);
 return ($rewritten, {
  %$diag,
  helper_action_ir_count => $ir_diag->{helper_action_ir_count},
  helper_action_ir_hits  => $ir_diag->{helper_action_ir_hits},
  helper_action_ir_nodes => $ir_diag->{helper_action_ir_nodes},
  helper_action_ir_events => $ir_diag->{helper_action_ir_events},
  canonical_action_ir_count => $canonical_ir_diag->{canonical_action_ir_count},
  canonical_action_ir_hits  => $canonical_ir_diag->{canonical_action_ir_hits},
  canonical_action_ir_nodes => $canonical_ir_diag->{canonical_action_ir_nodes},
  canonical_action_ir_events => $canonical_ir_diag->{canonical_action_ir_events},
  canonical_action_ir_fallback_count => $canonical_ir_diag->{canonical_action_ir_fallback_count},
 })
}

sub _build_action_rewrite_rules {
 my ($label) = @_;

 my $contracts = LinkedSpec::_build_action_lowering_contracts($label);
 return [map {{
  id                 => $_->{id},
  ir_node            => $_->{ir_node},
  diag_name          => $_->{diag_name},
  unresolved_pattern => $_->{unresolved_pattern},
  apply              => $_->{lower},
 }} @$contracts]
}

sub call_spec_handler_subst {
my ($label, $code) = @_;

 ($code) = _rewrite_action_code_with_diagnostics($label, $code);
 return $code
}

1;
