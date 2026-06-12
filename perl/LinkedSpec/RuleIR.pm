#------------------------------------------------------------------------------
# Package: LinkedSpec::RuleIR
# Purpose: Rule-IR planning owner for handler-shape selection, execution
#          metadata assembly, and emit-context preparation.
#------------------------------------------------------------------------------
package LinkedSpec::RuleIR;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

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
 return 'REP_AND_ACODE' if $node_type =~ /REP_AND/o && $acode_count;
 return 'REP_AND_BCODE' if $node_type =~ /REP_AND/o && $bcode_count;
 return 'REP_ACODE' if $node_type =~ /REP_/o && $acode_count;
 return 'REP_BCODE' if $node_type =~ /REP_/o && $bcode_count;
 return 'REP_BCODE' if $node_type eq 'default' && $bcode_count;

 if ($node_type =~ /AND/o && $acode_count) {
  return $regex_count == 1 ? 'AND_SINGLE_ACODE' : 'AND_ACODE';
 }
 return 'AND_BCODE' if $node_type =~ /AND/o && $bcode_count;
 return 'OR_ACODE'  if $node_type =~ /OR/o  && $acode_count;
 return 'OR_BCODE'  if $node_type =~ /OR/o  && $bcode_count;

 return '_default'
}

sub _require_trace_pkg {
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
 return 1
}

sub _trace_should_dump {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return LinkedSpec::Trace::should_dump(@args)
 })
}

sub _trace_log_output {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::log_output(@args)
 })
}

sub _trace_decision {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return LinkedSpec::Trace::trace_decision(@args)
 })
}

sub _dump_value {
 my ($value) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'Data::Dumper');
  return Data::Dumper::Dumper($value)
 })
}

sub _build_rule_execution_meta {
 my (%args) = @_;

 my $label = defined $args{label} ? $args{label} : '<undefined>';
 my $node_type = defined $args{node_type} ? $args{node_type} : 'default';
 my $regex_count = $args{regex_count} // 0;
 my $acode_count = $args{acode_count} // 0;
 my $bcode_count = $args{bcode_count} // 0;
 my $rep_min = $args{rep_min};
 my $rep_max = $args{rep_max};
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
 } elsif ($handler_variant eq 'REP_AND_ACODE') {
  ($execution_shape, $uses_loop) = ('repeat_and_sequence_loop', 1);
 } elsif ($handler_variant eq 'REP_AND_BCODE') {
  ($execution_shape, $uses_loop) = ('repeat_and_call_loop', 1);
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
  rep_min        => $rep_min,
  rep_max        => $rep_max,
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

sub _build_mark_trace_stmt {
 my (%args) = @_;
 return '_trace_runtime_mark_event('
  ."operation => '$args{operation}', "
  ."rule_label => '$args{rule_label}', "
  ."mark_name => '$args{mark_name}', "
  ."string_ref => \$STRING, "
  ."mark_pos => $args{mark_pos_expr}, "
  ."left_edge => \$LSPOS - length \$LMATCH, "
  ."parser_pos => pos \$\$STRING"
  .')'
}

sub _collect_rule_ir {
 my ($einfo) = @_;

 my $rule_ir = {
  label         => undef,
  node_type     => 'default',
  rep_min       => undef,
  rep_max       => undef,
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

 my $last_was_re = 0;
 my $pending_reidx = 0;
 foreach my $centry (@$einfo) {
  if ($$centry[0] =~ /ELABEL/o) {
   ($rule_ir->{label}, $rule_ir->{node_type}, $rule_ir->{rep_min}, $rule_ir->{rep_max}) = @$centry[1 .. 4];
  }

  my $entry_type = $$centry[0];
  if ($entry_type =~ /ELABEL_INITIAL/o) {
   $rule_ir->{top_rule} = $$centry[1];
  }
  elsif ($entry_type eq 'RE') {
   # RE entries checked before code_blocks so per-regex lifecycle code
   # becomes ACODE entries (with return()→assignment handled downstream).
   push @{$rule_ir->{REs}}, qr/$$centry[1]/;
   $last_was_re = 1;
   $pending_reidx = scalar(@{$rule_ir->{REs}}) - 1;
   next;
  }
  elsif ($last_was_re && exists $rule_ir->{code_blocks}{$entry_type}) {
   # Per-regex lifecycle code: for REP/OR/AND rules, convert to ACODE entry
   # so the handler dispatches it on regex match. For default rules,
   # keep as general lifecycle code (they run once at init).
   if ($rule_ir->{node_type} =~ /REP_|^OR|^AND/) {
    push @{$rule_ir->{acode_entries}}, {
     relabel => $rule_ir->{label} // 'rule',
     reidx   => $pending_reidx,
     code    => $$centry[1],
    };
   } else {
    push @{$rule_ir->{code_blocks}{$entry_type}}, $$centry[1];
   }
   $last_was_re = 0;
   next;
  }
  elsif (exists $rule_ir->{code_blocks}{$entry_type}) {
   # Standalone lifecycle code (no immediately preceding RE)
   push @{$rule_ir->{code_blocks}{$entry_type}}, $$centry[1];
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
  elsif ($entry_type eq 'MARK_POS') {
   my $mark_name = $$centry[1]{name};
   my $rule_label = defined($rule_ir->{label}) ? $rule_ir->{label} : '<unknown_rule>';
   my $mark_reidx = scalar(@{$rule_ir->{REs}}) - 1;
   $mark_reidx = 0 if $mark_reidx < 0;
   push @{$rule_ir->{code_blocks}{LECODE}},
    'if ($$minfo{index} == '.$mark_reidx.') { '.
    '$$info{marks}{\''.$rule_label.'\'} = {} unless ref($$info{marks}{\''.$rule_label.'\'}) eq "HASH"; '.
    '$$info{marks}{\''.$rule_label.'\'}{\''.$mark_name.'\'} = pos $$STRING; '.
    _build_mark_trace_stmt(
     operation => '@mark',
     rule_label => $rule_label,
     mark_name => $mark_name,
     mark_pos_expr => '$$info{marks}{\''.$rule_label.'\'}{\''.$mark_name.'\'}',
    ).'; }';
  }
  $last_was_re = 0;
 }

 return $rule_ir
}

sub _plan_rule_ir_meta {
 my ($rule_ir) = @_;

 return _build_rule_execution_meta(
  label       => $rule_ir->{label},
  node_type   => $rule_ir->{node_type},
  rep_min     => $rule_ir->{rep_min},
  rep_max     => $rule_ir->{rep_max},
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

1;
