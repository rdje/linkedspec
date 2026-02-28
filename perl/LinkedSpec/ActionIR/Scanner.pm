package LinkedSpec::ActionIR::Scanner;

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
 die "(LinkedSpec::ActionIR::Scanner::_require_dep) -E- missing dependency callback '$name'"
  unless ref($cb) eq 'CODE';
 return $cb
}

#------------------------------------------------------------------------------
# Function: scan_contract_ir_events
# Purpose : Contract-specific scanner that extracts helper invocation events
#           and parsed arguments from raw action code.
# Args    : ($contract, $code, $deps)
# Returns : arrayref of event hashes
#------------------------------------------------------------------------------
sub scan_contract_ir_events {
 my ($contract, $code, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';

 my $split_action_ir_statements = _require_dep($deps, 'split_action_ir_statements');
 my $trim_action_ir_value = _require_dep($deps, 'trim_action_ir_value');
 my $parse_method_function_expr = _require_dep($deps, 'parse_method_function_expr');
 my $normalize_method_args_with_optional_scope = _require_dep($deps, 'normalize_method_args_with_optional_scope');
 my $build_array_pipeline_plan_from_expr = _require_dep($deps, 'build_array_pipeline_plan_from_expr');
 my $extract_declare_statement_from_method_expr = _require_dep($deps, 'extract_declare_statement_from_method_expr');
 my $parse_declare_binding_entry = _require_dep($deps, 'parse_declare_binding_entry');

 local *_split_action_ir_statements = $split_action_ir_statements;
 local *_trim_action_ir_value = $trim_action_ir_value;
 local *_parse_method_function_expr = $parse_method_function_expr;
 local *_normalize_method_args_with_optional_scope = $normalize_method_args_with_optional_scope;
 local *_build_array_pipeline_plan_from_expr = $build_array_pipeline_plan_from_expr;
 local *_extract_declare_statement_from_method_expr = $extract_declare_statement_from_method_expr;
 local *_parse_declare_binding_entry = $parse_declare_binding_entry;

 my $id = $contract->{id} // '';

 my @events;
 if ($id eq 'assign_call_my') {
  while ($code =~ /\bmy\s+(?<target>\$\w+)\s*=\s*call\s*\(\s*(?<callee>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}, scope => 'my'}};
  }
 } elsif ($id eq 'assign_call') {
  while ($code =~ /(?<!\bmy\s)(?<target>\$\w+)\s*=\s*call\s*\(\s*(?<callee>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}, scope => 'existing'}};
  }
 } elsif ($id eq 'push_call_indexed_builtin') {
  while ($code =~ /\bpush\s+\@(?<target>\w+)\s*,\s*call\s*\(\s*(?<callee>\w+)\s*\)\s*->\s*\[\s*(?<index>\d+)\s*\]/g) {
   push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}, index => $+{index}}};
  }
 } elsif ($id eq 'push_call_builtin') {
  while ($code =~ /\bpush\s+\@(?<target>\w+)\s*,\s*call\s*\(\s*(?<callee>\w+)\s*\)(?!\s*->\s*\[)/g) {
   push @events, {raw => $&, args => {target => $+{target}, callee => $+{callee}}};
  }
 } elsif ($id eq 'return_call') {
  while ($code =~ /\breturn\s+call\s*\(\s*(?<callee>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {callee => $+{callee}, context => 'return'}};
  }
 } elsif ($id eq 'return_bare') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^return(?:\s+.+)?$/o;
   next if $trimmed =~ /^return\s*\(/o;
   next if $trimmed =~ /^return_/o;
   next if $trimmed =~ /^return\s+call\s*\(/o;
   my $payload = $trimmed;
   $payload =~ s/^return//o;
   $payload = _trim_action_ir_value($payload // '');
   push @events, {raw => $trimmed, args => {payload => $payload}};
  }
 } elsif ($id eq 'exit_bare') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^exit(?:\b|(?=\())/o;
   my $payload = $trimmed;
   $payload =~ s/^exit//o;
   $payload = _trim_action_ir_value($payload // '');
   push @events, {raw => $trimmed, args => {payload => $payload}};
  }
 } elsif ($id eq 'linecount_prefix_newline_matches') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^my\s+\@(?<target>\w+)\s*=\s*substr\(\s*\$\$STRING\s*,\s*0\s*,\s*(?<upto>(?:[^()]++|(?<P>\((?:[^()]++|(?&P))*\)))+)\)\s*=~\s*\/\\n\/g$/o;
   push @events, {raw => $trimmed, args => {target => $+{target}, upto => _trim_action_ir_value($+{upto})}};
  }
 } elsif ($id eq 'print_capture_substr') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^print\s*"<"\s*\.\s*substr\(\s*\$\$STRING\s*,\s*\$IPOS\s*,\s*\$LSPOS\s*-\s*\$IPOS\s*-\s*1\s*\)\s*\.\s*">\\n"\s*$/o;
   push @events, {raw => $trimmed, args => {source => 'capture_substr'}};
  }
 } elsif ($id eq 'my_declare_bare') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^my\s+(?<sigil>[\$\@\%])(?<name>\w+)$/o;
   my $declaration_type = $+{sigil} eq '$' ? 'scalar' : $+{sigil} eq '@' ? 'array' : 'hash';
   push @events, {raw => $trimmed, args => {declaration_type => $declaration_type, names => [$+{name}], scope => 'my'}};
  }
 } elsif ($id eq 'assign_match_my') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^my\s+\$(?<target>\w+)\s*=\s*\$(?<source>CAPTURE|IMATCH|LMATCH)$/o;
   push @events, {raw => $trimmed, args => {target => $+{target}, source => $+{source}, scope => 'my'}};
  }
 } elsif ($id eq 'destructure_imatch_list_my') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^my\s*\((?<targets>[^()]+)\)\s*=\s*\@IMATCH_LIST$/o;
   my @targets = grep { defined($_) && length($_) } map { _trim_action_ir_value($_) } split /\s*,\s*/o, $+{targets};
   next unless @targets;
   next if grep { $_ !~ /^\$\w+$/o } @targets;
   push @events, {
    raw  => $trimmed,
    args => {
     targets => [map { my $name = $_; $name =~ s/^\$//o; $name } @targets],
     source  => 'IMATCH_LIST',
     scope   => 'my',
    },
   };
  }
 } elsif ($id eq 'regex_subst_assignment') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^\$(?<target>\w+)\s*=~\s*s\/(?<pattern>(?:\\.|[^\/])*)\/(?<replacement>(?:\\.|[^\/])*)\/(?<flags>[a-z]*)$/o;
   push @events, {raw => $trimmed, args => {target => $+{target}, pattern => '/'.$+{pattern}.'/', replacement => '/'.$+{replacement}.'/', flags => ($+{flags} // ''), scope => undef}};
  }
 } elsif ($id eq 'next_bare') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^next(?:\s+\w+)?$/o;
   push @events, {raw => $trimmed, args => {}};
  }
 } elsif ($id eq 'ref_field_assign') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^(?<decl>my\s+)?\$(?<target>\w+)\s*=\s*\$(?<source>\w+)\s*->\s*(?<path>(?:\{[^{}]+\}|\[[^\[\]]+\])(?:\s*(?:\{[^{}]+\}|\[[^\[\]]+\]))*)$/o;
   push @events, {raw => $trimmed, args => {target => $+{target}, source => $+{source}, path => _trim_action_ir_value($+{path}), scope => ($+{decl} ? 'my' : 'existing')}};
  }
 } elsif ($id eq 'position_tracking') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless (
    $trimmed =~ /^\$\w+\s*=\s*pos(?:\s*\(\s*\$\$STRING\s*\)|\s+\$\$STRING)\s*$/o ||
    $trimmed =~ /^my\s+\$\w+\s*=\s*\$IPOS\s*$/o ||
    $trimmed =~ /^my\s+\$shift\s*=\s*\$LSPOS\s*-\s*\$last_pos\s*-\s*length(?:\s*\(\s*\$LMATCH\s*\)|\s+\$LMATCH)\s*$/o ||
    $trimmed =~ /^push\s+\@\w+\s*,\s*substr\(\s*\$\$STRING\s*,\s*\$last_pos\s*,\s*\$shift\s*\)\s*if\s*\$shift\s*$/o ||
    $trimmed =~ /^push\s+\@\w+\s*,\s*\{[^{}]*substr\(\s*\$\$STRING\s*,\s*\$last_pos\s*,\s*\$shift\s*\)[^{}]*\}\s*if\s*\$shift\s*$/o
   );
   push @events, {raw => $trimmed, args => {category => 'position_tracking'}};
  }
 } elsif ($id eq 'print_foreach_iterable') {
  foreach my $statement (@{_split_action_ir_statements($code)}) {
   my $trimmed = _trim_action_ir_value($statement);
   next unless defined($trimmed) && length($trimmed);
   next unless $trimmed =~ /^print\s+.+\s+foreach\s*\(\s*\@(?<iterable>\w+)\s*\)$/s;
   push @events, {raw => $trimmed, args => {iterable => $+{iterable}}};
  }
 } elsif ($id eq 'split_trim_filter_assignment') {
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
 } elsif ($id eq 'return_imatch') {
  while ($code =~ /\breturn_im(?:atch)?\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<tag>(?:'[^']*'|\"[^\"]*\"|\w+))\s*\)/g) {
   push @events, {raw => $&, args => {scope => $+{scope}, tag => $+{tag}}};
  }
 } elsif ($id eq 'assign_value') {
  while ($code =~ /\b(?<expr>assign\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
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
 } elsif ($id eq 'regex_subst') {
  while ($code =~ /\b(?:substr|regex_subst)\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<target>(?:scalar\s*\(\s*\w+\s*\)|\w+))\s*,\s*(?<pattern>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/(?:\\.|[^\/])*\/))\s*,\s*(?<replacement>(?:\"(?:\\.|[^\"])*\"|'(?:\\.|[^'])*'|\/\/|\/(?:\\.|[^\/])*\/))\s*,\s*(?<flags>\w*)\s*\)/g) {
   push @events, {raw => $&, args => {scope => $+{scope}, target => $+{target}, pattern => $+{pattern}, replacement => $+{replacement}, flags => $+{flags}}};
  }
 } elsif ($id eq 'split_array') {
  while ($code =~ /\b(?<expr>split\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
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
 } elsif ($id eq 'trim_each') {
  while ($code =~ /\b(?<expr>trim_each\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'trim_each';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'filter_nonempty') {
  while ($code =~ /\b(?<expr>filter_nonempty\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'filter_nonempty';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'lowercase_each') {
  while ($code =~ /\b(?<expr>lowercase_each\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'lowercase_each';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'uppercase_each') {
  while ($code =~ /\b(?<expr>uppercase_each\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'uppercase_each';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'uniq_array') {
  while ($code =~ /\b(?<expr>uniq\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $pipeline = _build_array_pipeline_plan_from_expr($+{expr});
   next unless $pipeline && @{$pipeline->{ops} || []};
   my $last_op = $pipeline->{ops}[-1];
   next unless $last_op->{op} && $last_op->{op} eq 'uniq';
   push @events, {raw => $+{expr}, args => {target => $pipeline->{target_symbol}}};
  }
 } elsif ($id eq 'filter_match') {
  while ($code =~ /\b(?<expr>filter_match\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
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
 } elsif ($id eq 'if_flow') {
  while ($code =~ /\b(?<expr>(?:if|i)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))(?!\s*\{))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {condition => _trim_action_ir_value($effective_args->[0])}};
  }
 } elsif ($id eq 'elseif_flow') {
  while ($code =~ /\b(?<expr>(?:elif|elseif)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\))(?!\s*\{))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {condition => _trim_action_ir_value($effective_args->[0])}};
  }
 } elsif ($id eq 'else_flow') {
  while ($code =~ /\b(?<expr>else\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'endif_flow') {
  while ($code =~ /\b(?<expr>endif\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'switch_flow') {
  while ($code =~ /\b(?<expr>switch\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
   next unless $effective_args && @$effective_args >= 1;
   push @events, {raw => $+{expr}, args => {expr => _trim_action_ir_value($effective_args->[0])}};
  }
 } elsif ($id eq 'case_flow') {
  while ($code =~ /\b(?<expr>case\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, 1);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {value => _trim_action_ir_value($effective_args->[0])}};
  }
 } elsif ($id eq 'default_flow') {
  while ($code =~ /\b(?<expr>default\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'endcase_flow') {
  while ($code =~ /\b(?<expr>endcase\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'endswitch_flow') {
  while ($code =~ /\b(?<expr>endswitch\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {}};
  }
 } elsif ($id eq 'say_stmt') {
  while ($code =~ /\b(?<expr>say\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
   next unless $effective_args && @$effective_args;
   push @events, {raw => $+{expr}, args => {values => [map { _trim_action_ir_value($_) } @$effective_args]}};
  }
 } elsif ($id eq 'print_stmt') {
  while ($code =~ /\b(?<expr>print\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 1, undef);
   next unless $effective_args && @$effective_args;
   push @events, {raw => $+{expr}, args => {values => [map { _trim_action_ir_value($_) } @$effective_args]}};
  }
 } elsif ($id eq 'return_undef') {
  while ($code =~ /\b(?<expr>return_undef\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call;
   my $effective_args = _normalize_method_args_with_optional_scope($call->{args} || [], 0, 0);
   next unless $effective_args;
   push @events, {raw => $+{expr}, args => {value => 'undef'}};
  }
 } elsif ($id eq 'return_array') {
  while ($code =~ /\breturn_array\s*\(\s*(?:(?<scope>\w+)\s*,\s*)?(?<tag>(?:'[^']*'|\"[^\"]*\"|\w+))\s*,\s*(?<payload>(?:[^()]++|(?<P>\((?:[^()]++|(?&P))*\)))+)\s*\)/g) {
   push @events, {raw => $&, args => {scope => $+{scope}, tag => $+{tag}, payload => _trim_action_ir_value($+{payload})}};
  }
 } elsif ($id eq 'declare_typed') {
  while ($code =~ /\b(?<expr>declare\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
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
 } elsif ($id eq 'declare_alias') {
  while ($code =~ /\b(?<expr>declare_(?:a|array|s|scalar|h|hash)\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
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
 } elsif ($id eq 'call') {
  while ($code =~ /\bcall\s*\(\s*(?<callee>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {callee => $+{callee}}};
  }
 } elsif ($id eq 'push_single_arg') {
  while ($code =~ /\bpush\s*\(\s*(?<source>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {source => $+{source}}};
  }
 } elsif ($id eq 'push_target_arg') {
  while ($code =~ /\bpush\s*\(\s*(?<source>\w+)\s*,\s*(?<target>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {source => $+{source}, target => $+{target}}};
  }
 } elsif ($id eq 'push_scope_target_arg') {
  while ($code =~ /\bpush\s*\(\s*(?<scope>\w+)\s*,\s*(?<source>\w+)\s*,\s*(?<target>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {scope => $+{scope}, source => $+{source}, target => $+{target}}};
  }
 } elsif ($id eq 'return_a') {
  while ($code =~ /\breturn_a\s*\(\s*(?<label>\w+)(?:\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+))?\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}, arg => _trim_action_ir_value($+{arg})}};
  }
 } elsif ($id eq 'return_general') {
  while ($code =~ /\b(?<expr>return\s*(?<PAREN>\((?:[^\(\)]++|(?&PAREN))*\)))/g) {
   my $call = _parse_method_function_expr($+{expr});
   next unless $call && $call->{method} eq 'return';
   my $args = $call->{args} || [];
   next unless ref($args) eq 'ARRAY' && @$args == 1;
   push @events, {raw => $+{expr}, args => {payload => _trim_action_ir_value($args->[0])}};
  }
 } elsif ($id eq 'return') {
  while ($code =~ /\breturn\s*\(\s*(?<label>\w+)\s*,(?<arg>\s*(?:[^\(\)]++|(?<par>\((?:[^\(\)]++|(?&par))+\)))+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}, arg => _trim_action_ir_value($+{arg})}};
  }
 } elsif ($id eq 'return_ma') {
  while ($code =~ /\breturn_ma\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'return_m') {
  while ($code =~ /\breturn_m\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'capture_macro') {
  while ($code =~ /\$CAPTURE\b/g) {
   push @events, {raw => $&, args => {}};
  }
 } elsif ($id eq 'capture') {
  while ($code =~ /\bcapture\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'capture_if') {
  while ($code =~ /\bcapture_if\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'capture_if_macro') {
  while ($code =~ /\bCAPTURE_IF\s*\(\s*\)/g) {
   push @events, {raw => $&, args => {}};
  }
 } elsif ($id eq 'ibacktrack_macro') {
  while ($code =~ /\bIBACKTRACK\s*\(\s*\)/g) {
   push @events, {raw => $&, args => {}};
  }
 } elsif ($id eq 'backtrack_macro') {
  while ($code =~ /\bBACKTRACK\s*\(\s*\)/g) {
   push @events, {raw => $&, args => {}};
  }
 } elsif ($id eq 'ibacktrack') {
  while ($code =~ /\bibacktrack\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 } elsif ($id eq 'backtrack') {
  while ($code =~ /\bbacktrack\s*\(\s*(?<label>\w+)\s*\)/g) {
   push @events, {raw => $&, args => {label => $+{label}}};
  }
 }

 return \@events
}

1;
