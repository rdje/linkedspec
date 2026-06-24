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
  'regex_subst' => \&_scan_contract_regex_subst,
  'split_array' => \&_scan_contract_split_array,
  'split_each' => \&_scan_contract_split_each,
  'trim_each' => \&_scan_contract_trim_each,
  'filter_nonempty' => \&_scan_contract_filter_nonempty,
  'lowercase_each' => \&_scan_contract_lowercase_each,
  'uppercase_each' => \&_scan_contract_uppercase_each,
  'uniq_array' => \&_scan_contract_uniq_array,
  'filter_match' => \&_scan_contract_filter_match,
 );
 my $handler = $dispatch{$id};
 return undef unless $handler;
 return $handler->($code)
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
while ($code =~ /\b(?<expr>push_value\s*(?<PAREN>\((?:[^\(\)\"\\']++|\"(?:\\.|[^\"])*\"|\'(?:\\.|[^'])*\'|(?&PAREN))*\)))/g) {
 my $raw_expr = $+{expr};
 my $call = _parse_method_function_expr($raw_expr);
 next unless $call && $call->{method} eq 'push_value';
 my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 2, 2);
 next unless $effective_args;
 my $target_expr = _trim_action_ir_value($effective_args->[0]);
 my $value_expr = _trim_action_ir_value($effective_args->[1]);
 next unless defined($target_expr) && length($target_expr);
 next unless defined($value_expr) && length($value_expr);
 my ($target_symbol) = $target_expr =~ /^(?:array|a)\s*\(\s*(\w+)\s*\)$/o;
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
 next unless $effective_args;
 my $target_expr = _trim_action_ir_value($effective_args->[0]);
 my $value_expr = _trim_action_ir_value($effective_args->[1]);
 next unless defined($target_expr) && length($target_expr);
 next unless defined($value_expr) && length($value_expr);
 my ($target_symbol) = $target_expr =~ /^(?:array|a)\s*\(\s*(\w+)\s*\)$/o;
 if (!defined($target_symbol) && $target_expr =~ /^(\w+)$/o) {
  $target_symbol = $1;
 }
 next unless defined($target_symbol) && length($target_symbol);
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

sub _scan_contract_regex_subst {
 my ($code) = @_;
 my @events;
while ($code =~ /\b(?:substr|regex_subst)\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<target>(?:(?:scalar|s)\s*\(\s*\w+\s*\)|\w+))\s*,\s*(?<pattern>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/(?:\\.|[^\/])*\/))\s*,\s*(?<replacement>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/\/|\/(?:\\.|[^\/])*\/))\s*,\s*(?<flags>\w*)\s*\)/g) {
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

1;
