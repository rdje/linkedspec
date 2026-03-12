package LinkedSpec::RuleIR;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use constant {
 DUMP_NONE   => 0,
 DUMP_LOW    => 100,
 DUMP_MEDIUM => 200,
 DUMP_HIGH   => 300,
 DUMP_DEBUG  => 500,
};

sub _select_rule_handler_variant {
 my ($node_type, $acode_count, $bcode_count, $regex_count) = @_;

 $node_type   = defined $node_type ? $node_type : 'default';
 $acode_count = $acode_count // 0;
 $bcode_count = $bcode_count // 0;
 $regex_count = $regex_count // 0;

 return 'MIXED_ACTIONS' if $acode_count && $bcode_count;

 if ($node_type =~ /AND/o && $acode_count) {
  return $regex_count == 1 ? 'AND_SINGLE_ACODE' : 'AND_ACODE';
 }
 return 'AND_BCODE' if $node_type =~ /AND/o && $bcode_count;
 return 'OR_ACODE'  if $node_type =~ /OR/o  && $acode_count;
 return 'OR_BCODE'  if $node_type =~ /OR/o  && $bcode_count;
 return 'REP_ACODE' if $node_type =~ /REP_/o && $acode_count;
 return 'REP_BCODE' if $node_type =~ /REP_/o && $bcode_count;

 return '_default'
}

sub _require_pkg {
 my ($pkg) = @_;
 my $file = $pkg;
 $file =~ s{::}{/}go;
 $file .= '.pm';
 my $ok = eval { require $file; 1 };
 die "(LinkedSpec::RuleIR::_require_pkg) -E- unable to load '$pkg': $@" unless $ok;
 return 1
}

sub _require_emit_context_pkg {
 _require_pkg('LinkedSpec::RuleIR::EmitContext') unless LinkedSpec::RuleIR::EmitContext->can('build_rule_ir_emit_context');
 return 1
}

sub _require_trace_pkg {
 _require_pkg('LinkedSpec::Trace');
 return 1
}

sub _require_data_dumper_pkg {
 require Data::Dumper;
 return 1
}

sub _trace_should_dump {
 return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
 return LinkedSpec::Trace::should_dump(@_)
}

sub _trace_log_output {
 _require_trace_pkg();
 return LinkedSpec::Trace::log_output(@_)
}

sub _trace_decision {
 return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
 return LinkedSpec::Trace::trace_decision(@_)
}

sub _dump_value {
 my ($value) = @_;
 _require_data_dumper_pkg();
 return Data::Dumper::Dumper($value)
}

sub _build_rule_execution_meta {
 my (%args) = @_;

 my $label = defined $args{label} ? $args{label} : '<undefined>';
 my $node_type = defined $args{node_type} ? $args{node_type} : 'default';
 my $regex_count = $args{regex_count} // 0;
 my $acode_count = $args{acode_count} // 0;
 my $bcode_count = $args{bcode_count} // 0;
 my $handler_variant = _select_rule_handler_variant($node_type, $acode_count, $bcode_count, $regex_count);

 my $action_mode =
    $acode_count && $bcode_count ? 'mixed'
  : $acode_count                 ? 'action'
  : $bcode_count                 ? 'blind_call'
  :                                'none';

 my ($execution_shape, $uses_loop) = ('default_scan_loop', 1);
 if ($handler_variant eq 'AND_SINGLE_ACODE') {
  ($execution_shape, $uses_loop) = ('single_match', 0);
 } elsif ($handler_variant eq 'AND_ACODE') {
  ($execution_shape, $uses_loop) = ('and_sequence_loop', 1);
 } elsif ($handler_variant eq 'AND_BCODE') {
  ($execution_shape, $uses_loop) = ('and_call_loop', 1);
 } elsif ($handler_variant eq 'OR_ACODE') {
  ($execution_shape, $uses_loop) = ('or_choice_dispatch', 0);
 } elsif ($handler_variant eq 'OR_BCODE') {
  ($execution_shape, $uses_loop) = ('or_call_loop', 1);
 } elsif ($handler_variant eq 'REP_ACODE' || $handler_variant eq 'REP_BCODE') {
  ($execution_shape, $uses_loop) = ('repeat_loop', 1);
 } elsif ($handler_variant eq 'MIXED_ACTIONS') {
  ($execution_shape, $uses_loop) = ('invalid_mixed_actions', 0);
 }

 my $meta = {
  label           => $label,
  node_type       => $node_type,
  regex_count     => $regex_count,
  acode_count     => $acode_count,
  bcode_count     => $bcode_count,
  action_mode     => $action_mode,
  handler_variant => $handler_variant,
  execution_shape => $execution_shape,
  uses_loop       => $uses_loop ? 1 : 0,
 };

 if (_trace_should_dump(DUMP_DEBUG)) {
  _trace_log_output(DUMP_DEBUG, "(LinkedSpec.pm::_build_rule_execution_meta) Rule meta", _dump_value($meta));
 }

 return $meta
}

sub _collect_rule_ir {
 my ($einfo) = @_;

 my $rule_ir = {
  label         => undef,
  node_type     => 'default',
  top_rule      => undef,
  REs           => [],
  code_blocks   => {
   ICODE  => [],
   ECODE  => [],
   EXCODE => [],
   ITCODE => [],
   LXCODE => [],
   LSCODE => [],
   LECODE => [],
  },
  acode_entries => [],
  bcode_entries => [],
 };

 foreach my $centry (@$einfo) {
  ($rule_ir->{label}, $rule_ir->{node_type}) = @$centry[1 .. 2] if $$centry[0] =~ /ELABEL/o;

  my $entry_type = $$centry[0];
  if ($entry_type =~ /ELABEL_INITIAL/o) {
   $rule_ir->{top_rule} = $$centry[1];
  }
  elsif (exists $rule_ir->{code_blocks}{$entry_type}) {
   push @{$rule_ir->{code_blocks}{$entry_type}}, $$centry[1];
  }
  elsif ($entry_type eq 'RE') {
   push @{$rule_ir->{REs}}, qr/$$centry[1]/;
  }
  elsif ($entry_type eq 'ACODE') {
   push @{$rule_ir->{acode_entries}}, {
    relabel => $$centry[1]{relabel},
    reidx   => $$centry[1]{reidx},
    code    => $$centry[1]{code},
   };
  }
  elsif ($entry_type eq 'BCODE') {
   push @{$rule_ir->{bcode_entries}}, {
    call => $$centry[1]{call},
    code => $$centry[1]{code},
   };
  }
  elsif ($entry_type eq 'MOVE_POS') {
   push @{$rule_ir->{code_blocks}{LECODE}}, '$IPOS = pos $$STRING';
  }
 }

 return $rule_ir
}

sub _plan_rule_ir_meta {
 my ($rule_ir) = @_;

 return _build_rule_execution_meta(
  label       => $rule_ir->{label},
  node_type   => $rule_ir->{node_type},
  regex_count => scalar(@{$rule_ir->{REs}}),
  acode_count => scalar(@{$rule_ir->{acode_entries}}),
  bcode_count => scalar(@{$rule_ir->{bcode_entries}}),
 )
}

sub _validate_rule_ir_or_exit {
 my ($rule_ir, $rule_meta) = @_;

 if ($rule_meta->{action_mode} eq 'mixed') {
  _trace_decision(
   "_validate_rule_ir_or_exit:$rule_ir->{label}",
   0,
   "mixed action mode detected (acode=$rule_meta->{acode_count}, bcode=$rule_meta->{bcode_count})",
   DUMP_HIGH
  );
  my $label = $rule_ir->{label};
  my $error_msg = "Rule '$label': Cannot mix ACTION (->) and BLIND CALL (=>) code blocks";
  my $context = "ACTION blocks: ".($rule_meta->{acode_count} // 0)." found, BLIND CALL blocks: ".($rule_meta->{bcode_count} // 0)." found";
  _trace_log_output(DUMP_NONE, $error_msg, $context);
  print "  Solution: Use either ACTION blocks OR BLIND CALL blocks, not both\n";
  print "  Example: Use '-> rule_name { code }' OR '=> function_name { code }'\n";
  return 0
 }
 _trace_decision(
  "_validate_rule_ir_or_exit:$rule_ir->{label}",
  1,
  "rule action mode '$rule_meta->{action_mode}' is valid",
  DUMP_DEBUG
 );

 return 1
}

sub _normalize_rule_code_chunks {
 _require_emit_context_pkg();
 return LinkedSpec::RuleIR::EmitContext::_normalize_rule_code_chunks(@_)
}

sub _build_rule_ir_emit_context {
 _require_emit_context_pkg();
 return LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context(@_)
}

1;
