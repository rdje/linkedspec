package LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules;

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
  'print_foreach_iterable' => \&_scan_contract_print_foreach_iterable,
  'split_trim_filter_assignment' => \&_scan_contract_split_trim_filter_assignment,
  'push_value' => \&_scan_contract_push_value,
  'push_nonempty' => \&_scan_contract_push_nonempty,
  'assign_value' => \&_scan_contract_assign_value,
  'scalar_assignment_operator' => \&_scan_contract_scalar_assignment_operator,
  'array_append_operator' => \&_scan_contract_array_append_operator,
  'array_end_mutation_method' => \&_scan_contract_array_end_mutation_method,
  'hash_index_assignment_operator' => \&_scan_contract_hash_index_assignment_operator,
  'set_key_statement' => \&_scan_contract_set_key_statement,
  'regex_subst' => \&_scan_contract_regex_subst,
  'split_array' => \&_scan_contract_split_array,
  'split_each' => \&_scan_contract_split_each,
  'trim_each' => \&_scan_contract_trim_each,
  'filter_nonempty' => \&_scan_contract_filter_nonempty,
  'lowercase_each' => \&_scan_contract_lowercase_each,
  'uppercase_each' => \&_scan_contract_uppercase_each,
  'uniq_array' => \&_scan_contract_uniq_array,
  'filter_match' => \&_scan_contract_filter_match,
  'value_drop_statement' => \&_scan_contract_value_drop_statement,
 );
 my $handler = $dispatch{$id};
 return undef unless $handler;
 return $handler->($code)
}

sub _is_primitive_literal_token {
 my ($expr) = @_;
 my $trimmed = _trim_action_ir_value($expr);
 return 0 unless defined($trimmed) && length($trimmed);
 return 1 if $trimmed =~ /^-?\d+(?:\.\d+)?$/o;
 return 1 if $trimmed =~ /^\"(?:\\.|[^\"])*\"$/s || $trimmed =~ /^'(?:\\.|[^'])*'$/s;
 return 1 if $trimmed eq 'undef' || $trimmed eq 'true' || $trimmed eq 'false';
 return 0
}

sub _is_nonliteral_reserved_bare_token {
 my ($expr) = @_;
 my $trimmed = _trim_action_ir_value($expr);
 return 0 unless defined($trimmed) && length($trimmed);
 return 0 unless $trimmed =~ /^[A-Za-z_][A-Za-z0-9_]*$/o;
 return 0 if _is_primitive_literal_token($trimmed);
 return $trimmed =~ /^(?:descr|STRING|info|minfo|IMATCH|IMATCH_LIST|IMATCH_HASH|IINDEX|IPOS|LMATCH|LMATCH_LIST|LMATCH_HASH|LINDEX|LSPOS|CAPTURE)$/o ? 1 : 0
}

sub _scan_contract_print_foreach_iterable {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^print\s+.+\s+foreach\s*\(\s*\@(?<iterable>\w+)\s*\)$/s;
 push @events, {raw => $trimmed, args => {iterable => $+{iterable}}};
}
 return \@events
}

sub _scan_contract_split_trim_filter_assignment {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^my\s+\@(?<target>\w+)\s*=\s*grep\s*\{\s*length\(\$_\)\s*\}\s*map\s*\{\s*my\s+\$v\s*=\s*\$_\s*;\s*\$v\s*=~\s*s\/(?:\\.|[^\/])*\/(?:\\.|[^\/])*\/[a-z]*\s*;\s*\$v\s*\}\s*split\s*(?<delimiter>\/(?:\\.|[^\/])*\/[a-z]*)\s*,\s*\$(?<source>\w+)$/o;
 push @events, {
  raw  => $trimmed,
  args => {
   target    => $+{target},
   source    => $+{source},
   delimiter => $+{delimiter},
   transforms => ['split', 'trim_each', 'filter_nonempty'],
   scope     => 'my',
  },
 };
}
 return \@events
}

sub _scan_contract_push_value {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>(?:push_value|push)\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/g) {
 my $raw_expr = $+{expr};
 my $call = _parse_method_function_expr($raw_expr);
 next unless $call && ($call->{method} eq 'push_value' || $call->{method} eq 'push');
 my $raw_args = $call->{args} || [];
 my $effective_args;
 if ($call->{method} eq 'push_value') {
  $effective_args = _normalize_method_args_with_optional_scope($raw_args, 2, 2);
 } else {
  next unless @$raw_args == 2;
  my $first_expr = _trim_action_ir_value($raw_args->[0]);
  my $second_expr = _trim_action_ir_value($raw_args->[1]);
  next if defined($first_expr) && defined($second_expr)
       && $first_expr =~ /^\w+$/o && $second_expr =~ /^\w+$/o
       && !_is_primitive_literal_token($second_expr);
  $effective_args = $raw_args;
 }
 next unless $effective_args;
 my $target_expr = _trim_action_ir_value($effective_args->[0]);
 my $value_expr = _trim_action_ir_value($effective_args->[1]);
 next unless defined($target_expr) && length($target_expr);
 next unless defined($value_expr) && length($value_expr);
 my ($target_symbol) = $target_expr =~ /^array\s*\(\s*(\w+)\s*\)$/o;
 if (!defined($target_symbol) && $target_expr =~ /^(\w+)$/o) {
  $target_symbol = $1;
 }
 next unless defined($target_symbol) && length($target_symbol);
 push @events, {raw => $raw_expr, args => {target => $target_symbol, value => $value_expr}};
}
 return \@events
}

sub _scan_contract_push_nonempty {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>push_nonempty\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/g) {
 my $raw_expr = $+{expr};
 my $call = _parse_method_function_expr($raw_expr);
 next unless $call && $call->{method} eq 'push_nonempty';
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 2, 2);
 if (!$effective_args) {
  push @events, {raw => $raw_expr, args => {}};
  next;
 }
 my $target_expr = _trim_action_ir_value($effective_args->[0]);
 my $value_expr = _trim_action_ir_value($effective_args->[1]);
 if (!defined($target_expr) || !length($target_expr) || !defined($value_expr) || !length($value_expr)) {
  push @events, {raw => $raw_expr, args => {}};
  next;
 }
 my ($target_symbol) = $target_expr =~ /^array\s*\(\s*(\w+)\s*\)$/o;
 if (!defined($target_symbol) && $target_expr =~ /^(\w+)$/o) {
  $target_symbol = $1;
 }
 if (!defined($target_symbol) || !length($target_symbol)) {
  push @events, {raw => $raw_expr, args => {}};
  next;
 }
 push @events, {raw => $raw_expr, args => {target => $target_symbol, value => $value_expr, predicate => 'nonempty'}};
}
 return \@events
}

sub _scan_contract_assign_value {
 my ($code) = @_;
 my @events;
# SPEC-FORMAT-TERSE.1.4.1 — also scan the terse `set(...)` rename of `assign(...)` (ADR 0007)
# so it produces the same ASSIGN canonical-IR event and lowers identically; the parse-time
# name normalization (set->assign) makes the `$call->{method} eq 'assign'` guard below pass.
while ($code =~ /\b(?<expr>(?:assign|set)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $call = _parse_method_function_expr($+{expr});
 next unless $call && $call->{method} eq 'assign';
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 2, 2);
 next unless $effective_args;
 push @events, {
  raw => $+{expr},
  args => {
   target => _trim_action_ir_value($effective_args->[0]),
   source => _trim_action_ir_value($effective_args->[1]),
  },
 };
}
 return \@events
}

sub _scan_contract_scalar_assignment_operator {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*=(?!=|>)\s*(.+)$/s;
 my ($target_expr, $source_expr) = ($1, _trim_action_ir_value($2));
 next unless defined($source_expr) && length($source_expr);
 push @events, {
  raw => $trimmed,
  args => {
   target => $target_expr,
   source => $source_expr,
  },
 };
}
 return \@events
}

sub _scan_contract_array_append_operator {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 next unless $trimmed =~ /^([A-Za-z_][A-Za-z0-9_]*)\s*\+=\s*(.+)$/s;
 my ($target_expr, $value_expr) = ($1, _trim_action_ir_value($2));
 next unless defined($value_expr) && length($value_expr);
 next if _is_nonliteral_reserved_bare_token($value_expr);
 push @events, {
  raw => $trimmed,
  args => {
   target => $target_expr,
   value  => $value_expr,
  },
 };
}
 return \@events
}

sub _parse_array_end_mutation_method_statement {
 my ($statement) = @_;
 my $trimmed = _trim_action_ir_value($statement);
 return undef unless defined($trimmed) && length($trimmed);

 my ($paren_depth, $bracket_depth, $brace_depth) = (0, 0, 0);
 my ($in_single_quote, $in_double_quote, $escape_next) = (0, 0, 0);
 my ($receiver_expr, $call_expr);
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
  next unless $paren_depth == 0 && $bracket_depth == 0 && $brace_depth == 0;
  $receiver_expr = _trim_action_ir_value(substr($trimmed, 0, $idx));
  $call_expr = _trim_action_ir_value(substr($trimmed, $idx + 1));
  last;
 }
 return undef unless defined($receiver_expr) && length($receiver_expr);
 return undef unless defined($call_expr) && length($call_expr);
 return undef unless $receiver_expr =~ /^(?:[A-Za-z_][A-Za-z0-9_]*|array\s*\()/o;

 my ($target_symbol) = defined($receiver_expr)
  ? ($receiver_expr =~ /^array\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o)
  : ();
 if (!defined($target_symbol) && defined($receiver_expr) && $receiver_expr =~ /^([A-Za-z_][A-Za-z0-9_]*)$/o) {
  $target_symbol = $1;
 }
 return undef unless defined($target_symbol) && length($target_symbol);

 my $call = _parse_method_function_expr($call_expr);
 return undef unless $call && ($call->{method} // '') =~ /^(?:push_front|push_back|pop_front|pop_back)$/o;
 my $args = $call->{args} || [];
 return undef if $call->{method} =~ /^push_/o && @$args != 1;
 return undef if $call->{method} =~ /^pop_/o && @$args != 0;
 my $value_expr;
 if ($call->{method} =~ /^push_/o) {
  $value_expr = _trim_action_ir_value($args->[0]);
  return undef unless defined($value_expr) && length($value_expr);
  return undef if _is_nonliteral_reserved_bare_token($value_expr);
 }

 return {
  target => $target_symbol,
  method => $call->{method},
  value  => $value_expr,
 };
}

sub _scan_contract_array_end_mutation_method {
 my ($code) = @_;
 my @events;
 foreach my $statement (@{_split_action_ir_statements($code)}) {
  my $trimmed = _trim_action_ir_value($statement);
  next unless defined($trimmed) && length($trimmed);
  my $parsed = _parse_array_end_mutation_method_statement($trimmed);
  next unless $parsed;
  my %args = (
   target => $parsed->{target},
   method => $parsed->{method},
  );
  $args{value} = $parsed->{value} if defined $parsed->{value};
  push @events, {raw => $trimmed, args => \%args};
 }
 return \@events
}

sub _parse_hash_index_assignment_operator_statement {
 my ($statement) = @_;
 my $trimmed = _trim_action_ir_value($statement);
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
 my $value = _trim_action_ir_value($1);
 $key = _trim_action_ir_value($key);
 return undef unless defined($key) && length($key);
 return undef unless defined($value) && length($value);
 return undef if _is_nonliteral_reserved_bare_token($value);
 return {
  target => $target,
  key    => $key,
  value  => $value,
 };
}

sub _scan_contract_hash_index_assignment_operator {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 my $parsed = _parse_hash_index_assignment_operator_statement($trimmed);
 next unless $parsed;
 push @events, {
  raw => $trimmed,
  args => {
   target => $parsed->{target},
   key    => $parsed->{key},
   value  => $parsed->{value},
  },
 };
}
 return \@events
}

sub _scan_contract_set_key_statement {
 my ($code) = @_;
 my @events;
foreach my $statement (@{_split_action_ir_statements($code)}) {
 my $trimmed = _trim_action_ir_value($statement);
 next unless defined($trimmed) && length($trimmed);
 my $call = _parse_method_function_expr($trimmed);
 next unless $call && $call->{method} eq 'set_key';
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 3, 3);
 next unless $effective_args;
 my $target_expr = _trim_action_ir_value($effective_args->[0]);
 my $key_expr = _trim_action_ir_value($effective_args->[1]);
 my $value_expr = _trim_action_ir_value($effective_args->[2]);
 next unless defined($target_expr) && length($target_expr);
 my ($target_symbol) = $target_expr =~ /^hash\s*\(\s*(\w+)\s*\)$/o;
 if (!defined($target_symbol) && $target_expr =~ /^(\w+)$/o) {
  $target_symbol = $1;
 }
 next unless defined($target_symbol) && length($target_symbol);
 push @events, {
  raw => $trimmed,
  args => {
   target => $target_symbol,
   key    => $key_expr,
   value  => $value_expr,
  },
 };
}
 return \@events
}

sub _scan_contract_regex_subst {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?:substr|regex_subst)\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<target>(?:scalar\s*\(\s*\w+\s*\)|\w+))\s*,\s*(?<pattern>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/(?:\\.|[^\/])*\/))\s*,\s*(?<replacement>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/\/|\/(?:\\.|[^\/])*\/))\s*,\s*(?<flags>\w*)\s*\)/g) {
 push @events, {raw => $&, args => {scope => $+{scope}, target => $+{target}, pattern => $+{pattern}, replacement => $+{replacement}, flags => $+{flags}}};
}
 return \@events
}

sub _scan_contract_split_array {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>split\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
 next unless $pipeline && @{$pipeline->{ops} || []};
 my $last_op = $pipeline->{ops}[-1];
 next unless $last_op->{op} && $last_op->{op} eq 'split';
 push @events, {
  raw => $+{expr},
  args => {
   target    => $pipeline->{target_symbol},
   source    => $last_op->{source_symbol},
   delimiter => $last_op->{delimiter_expr},
  },
 };
}
 return \@events
}

sub _scan_contract_split_each {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>split_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
 next unless $pipeline && @{$pipeline->{ops} || []};
 my $last_op = $pipeline->{ops}[-1];
 next unless $last_op->{op} && $last_op->{op} eq 'split_each';
 push @events, {
  raw => $+{expr},
  args => {
   target    => $pipeline->{target_symbol},
   delimiter => $last_op->{delimiter_expr},
  },
 };
}
 return \@events
}
sub _scan_contract_trim_each {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>trim_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
 next unless $pipeline && @{$pipeline->{ops} || []};
 my $last_op = $pipeline->{ops}[-1];
 next unless $last_op->{op} && $last_op->{op} eq 'trim_each';
 push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
}
 return \@events
}

sub _scan_contract_filter_nonempty {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>filter_nonempty\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
 next unless $pipeline && @{$pipeline->{ops} || []};
 my $last_op = $pipeline->{ops}[-1];
 next unless $last_op->{op} && $last_op->{op} eq 'filter_nonempty';
 push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
}
 return \@events
}

sub _scan_contract_lowercase_each {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>lowercase_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
 next unless $pipeline && @{$pipeline->{ops} || []};
 my $last_op = $pipeline->{ops}[-1];
 next unless $last_op->{op} && $last_op->{op} eq 'lowercase_each';
 push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
}
 return \@events
}

sub _scan_contract_uppercase_each {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>uppercase_each\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
 next unless $pipeline && @{$pipeline->{ops} || []};
 my $last_op = $pipeline->{ops}[-1];
 next unless $last_op->{op} && $last_op->{op} eq 'uppercase_each';
 push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
}
 return \@events
}

sub _scan_contract_uniq_array {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>uniq\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
 next unless $pipeline && @{$pipeline->{ops} || []};
 my $last_op = $pipeline->{ops}[-1];
 next unless $last_op->{op} && $last_op->{op} eq 'uniq';
 push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
}
 return \@events
}

sub _scan_contract_filter_match {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?<expr>filter_match\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\)))/g) {
 my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
 next unless $pipeline && @{$pipeline->{ops} || []};
 my $last_op = $pipeline->{ops}[-1];
 next unless $last_op->{op} && $last_op->{op} eq 'filter_match';
 push @events, {
  raw => $+{expr},
  args => {
   target  => $pipeline->{target_symbol},
   pattern => $last_op->{pattern_expr},
  },
 };
}
 return \@events
}

sub _scan_contract_value_drop_statement {
 my ($code) = @_;
 my @events;
 my $value_call_re = qr/(?:trim|lowercase|uppercase|length|substr|replace_substr|rm_prefix|rm_suffix|concat|cat|str_eq|str_ne|str_gt|str_ge|str_lt|str_le|starts_with|ends_with|contains_substr|matches|coalesce|coalesce_nonempty|num_abs|num_floor|num_ceil|num_round|num_add|num_sub|num_mul|num_div|num_mod|num_clamp|num_min|num_max|num_eq|num_ne|num_gt|num_ge|num_lt|num_le|abs|floor|ceil|round|sum|avg|median|range|add|sub|mul|div|mod|clamp|min|max|eq|ne|gt|ge|lt|le|scalar|s|array|a|hash|h|array_copy|hash_copy|copy|flat|flat_array|flat_hash|count|first|last|drop_front|take|slice|take_last|drop_back|concat_arrays|split|split_tagged_records|sorted|reversed|contains|index_of|split_each|trim_each|filter_nonempty|lowercase_each|uppercase_each|uniq|filter_match|count_keys|sorted_keys|sorted_values|has_key|merge_hash|rename_key|drop_keys|pick_keys|join_values|entry_groups|match_groups|entry_map|entry_named_map|match_map|match_named_map|num_sum|num_avg|num_median|num_range)/;
 my $receiver_method_re = qr/(?:trim|lowercase|uppercase|length|sorted|reversed|count|first|last|is_empty|is_nonempty|hash_copy|flat_hash|count_keys|sorted_keys|sorted_values|abs|floor|ceil|round)/;
 my $literal_receiver_re = qr/(?:"(?:\\.|[^\"])*"|'(?:\\.|[^'])*'|-?\d+(?:\.\d+)?|[A-Za-z_][A-Za-z0-9_]*(?!\s*\())/;
 foreach my $statement (@{_split_action_ir_statements($code)}) {
  my $trimmed = _trim_action_ir_value($statement);
  next unless defined($trimmed) && length($trimmed);
  if ($trimmed =~ /^(?:$value_call_re)\s*(?<PAREN>\((?:[^\(\)\"\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\'|(?&PAREN))*\))\z/so) {
   push @events, {raw => $trimmed, args => {expr => $trimmed}};
   next;
  }
  if ($trimmed =~ /^(?:$literal_receiver_re)\s*\.\s*(?:$receiver_method_re)\s*\(\s*\)\z/so) {
   push @events, {raw => $trimmed, args => {expr => $trimmed}};
  }
 }
 return \@events
}

1;
