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

sub _trace_rule_label {
 my ($label) = @_;
 return (defined($label) && length($label)) ? $label : '<unknown_rule>'
}

sub _trace_rule_value {
 my ($value) = @_;
 return '<undef>' unless defined $value;
 return ref($value) ? ref($value) : $value
}

sub _trace_rule_ir_decision {
 my (%args) = @_;

 my $phase = defined($args{phase}) && length($args{phase}) ? $args{phase} : 'plan';
 my $label = _trace_rule_label($args{label});
 my $decision = defined($args{decision}) && length($args{decision}) ? $args{decision} : '<decision>';
 my $level = defined($args{level}) ? $args{level} : DUMP_DEBUG;

 my @reason;
 push @reason, $args{reason} if defined($args{reason}) && length($args{reason});
 if (ref($args{context}) eq 'HASH') {
  push @reason, map { $_.'='._trace_rule_value($args{context}{$_}) } sort keys %{$args{context}};
 }

 return _trace_decision(
  'rule_ir:'.$phase.':'.$label.':'.$decision,
  $args{taken} ? 1 : 0,
  join("\n", @reason),
  $level,
 )
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

 _trace_rule_ir_decision(
  phase => 'select',
  label => $label,
  decision => 'handler_variant_'.$handler_variant,
  taken => 1,
  reason => "selected handler variant '$handler_variant'",
  context => {
   node_type => $node_type,
   regex_count => $regex_count,
   acode_count => $acode_count,
   bcode_count => $bcode_count,
   rep_min => $rep_min,
   rep_max => $rep_max,
   handler_variant => $handler_variant,
  },
 );

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
  family          => $node_type =~ /AND/o ? 'and' : 'or_default',
  cursor_policy   => $node_type =~ /AND/o ? 'consume' : 'seek',
 };

 _trace_rule_ir_decision(
  phase => 'meta',
  label => $label,
  decision => 'action_mode_'.$action_mode,
  taken => 1,
  reason => "planned action mode '$action_mode'",
  context => {
   action_mode => $action_mode,
   handler_variant => $handler_variant,
   acode_count => $acode_count,
   bcode_count => $bcode_count,
  },
 );
 _trace_rule_ir_decision(
  phase => 'meta',
  label => $label,
  decision => 'execution_shape_'.$execution_shape,
  taken => 1,
  reason => "planned execution shape '$execution_shape'",
  context => {
   execution_shape => $execution_shape,
   handler_variant => $handler_variant,
   uses_loop => $uses_loop ? 1 : 0,
  },
 );

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
  ."left_edge => (defined(\$LSPOS) && defined(\$LMATCH) ? \$LSPOS - length \$LMATCH : pos \$\$STRING), "
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
  is_top        => 0,
  top_rule      => undef,
  REs           => [],
  regex_slots   => [],
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
  bare_edge_entries => [],
  edge_sequence => [],
  and_icode_entries => [],   # Per-regex I-blocks for AND rules (not acode_entries)
  capture_gaps_directives => [],
  legacy_gap_markers => [],
 };

 my $last_was_re = 0;
 my $pending_reidx = 0;
 foreach my $centry (@$einfo) {
  if ($$centry[0] =~ /ELABEL/o) {
   ($rule_ir->{label}, $rule_ir->{node_type}, $rule_ir->{rep_min}, $rule_ir->{rep_max}) = @$centry[1 .. 4];
   _trace_rule_ir_decision(
    phase => 'collect',
    label => $rule_ir->{label},
    decision => 'entry_label',
    taken => 1,
    reason => 'collected rule label metadata',
    context => {
     entry_type => $$centry[0],
     node_type => $rule_ir->{node_type},
     rep_min => $rule_ir->{rep_min},
     rep_max => $rule_ir->{rep_max},
    },
   );
  }

  my $entry_type = $$centry[0];
  if ($entry_type =~ /ELABEL_INITIAL/o) {
   $rule_ir->{is_top} = 1;
   $rule_ir->{top_rule} = $$centry[1];
   _trace_rule_ir_decision(
    phase => 'collect',
    label => $rule_ir->{label},
    decision => 'entry_top_rule',
    taken => 1,
    reason => 'collected initial entry rule',
    context => {
     top_rule => $rule_ir->{top_rule},
    },
   );
  }
  elsif ($entry_type eq 'RE') {
   # RE entries checked before code_blocks so per-regex lifecycle code
   # becomes ACODE entries (with return()→assignment handled downstream).
   push @{$rule_ir->{REs}}, qr/$$centry[1]/;
   push @{$rule_ir->{regex_slots}}, {
    regex_index => scalar(@{$rule_ir->{REs}}) - 1,
    slot_id => undef,
   };
   $last_was_re = 1;
   $pending_reidx = scalar(@{$rule_ir->{REs}}) - 1;
   _trace_rule_ir_decision(
    phase => 'collect',
    label => $rule_ir->{label},
    decision => 'regex_entry',
    taken => 1,
    reason => 'collected regex entry',
    context => {
     reidx => $pending_reidx,
     regex_count => scalar(@{$rule_ir->{REs}}),
    },
   );
   next;
  }
  elsif ($entry_type eq 'RE_SLOT') {
   my $slot = $$centry[1];
   my $pattern = ref($slot) eq 'HASH' ? $slot->{pattern} : undef;
   push @{$rule_ir->{REs}}, qr/$pattern/;
   push @{$rule_ir->{regex_slots}}, {
    regex_index => scalar(@{$rule_ir->{REs}}) - 1,
    slot_id => ref($slot) eq 'HASH' ? $slot->{name} : undef,
    line => ref($slot) eq 'HASH' ? $slot->{line} : undef,
   };
   $last_was_re = 1;
   $pending_reidx = scalar(@{$rule_ir->{REs}}) - 1;
   next;
  }
  elsif ($last_was_re && exists $rule_ir->{code_blocks}{$entry_type}) {
   # Per-regex lifecycle code: for REP/OR/AND rules, convert to ACODE entry
   # so the handler dispatches it on regex match. For default rules,
   # keep as general lifecycle code (they run once at init).
   if ($rule_ir->{node_type} =~ /REP_|^OR/) {
    push @{$rule_ir->{acode_entries}}, {
     relabel => $rule_ir->{label} // 'rule',
     reidx   => $pending_reidx,
     code    => $$centry[1],
    };
    _trace_rule_ir_decision(
     phase => 'collect',
     label => $rule_ir->{label},
     decision => 'per_regex_lifecycle_acode',
     taken => 1,
     reason => 'routed per-regex lifecycle block to ACODE dispatch',
     context => {
      entry_type => $entry_type,
      reidx => $pending_reidx,
      node_type => $rule_ir->{node_type},
      acode_count => scalar(@{$rule_ir->{acode_entries}}),
     },
    );
   } elsif ($rule_ir->{node_type} =~ /AND/) {
    # AND rules: route per-regex I-blocks to and_icode_entries (not acode_entries)
    # to avoid MIXED_ACTIONS conflict with bcode edges.  The and_icode is emitted
    # in the handler as IMATCH bridge + return->assignment after regex match.
    push @{$rule_ir->{and_icode_entries}}, {
     code    => $$centry[1],
    };
    _trace_rule_ir_decision(
     phase => 'collect',
     label => $rule_ir->{label},
     decision => 'per_regex_lifecycle_and_icode',
     taken => 1,
     reason => 'routed AND per-regex lifecycle block to and_icode_entries',
     context => {
      entry_type => $entry_type,
      reidx => $pending_reidx,
      node_type => $rule_ir->{node_type},
      and_icode_count => scalar(@{$rule_ir->{and_icode_entries}}),
     },
    );
   } else {
    push @{$rule_ir->{code_blocks}{$entry_type}}, $$centry[1];
    _trace_rule_ir_decision(
     phase => 'collect',
     label => $rule_ir->{label},
     decision => 'per_regex_lifecycle_standalone',
     taken => 1,
     reason => 'kept per-regex lifecycle block as rule lifecycle code',
     context => {
      entry_type => $entry_type,
      reidx => $pending_reidx,
      node_type => $rule_ir->{node_type},
      block_count => scalar(@{$rule_ir->{code_blocks}{$entry_type}}),
     },
    );
   }
   $last_was_re = 0;
   next;
  }
  elsif (exists $rule_ir->{code_blocks}{$entry_type}) {
   # Standalone lifecycle code (no immediately preceding RE)
   push @{$rule_ir->{code_blocks}{$entry_type}}, $$centry[1];
   _trace_rule_ir_decision(
    phase => 'collect',
    label => $rule_ir->{label},
    decision => 'standalone_lifecycle',
    taken => 1,
    reason => 'collected standalone lifecycle block',
    context => {
     entry_type => $entry_type,
     block_count => scalar(@{$rule_ir->{code_blocks}{$entry_type}}),
    },
   );
  }
  elsif ($entry_type eq 'ACODE') {
   push @{$rule_ir->{acode_entries}}, {
    relabel => $$centry[1]{relabel},
    reidx   => $$centry[1]{reidx},
    selector_kind => $$centry[1]{selector_kind},
    authored_selector => $$centry[1]{authored_selector},
    selector_provenance => exists($$centry[1]{selector_kind}) ? 1 : 0,
    line => $$centry[1]{line},
    code    => $$centry[1]{code},
   };
   if (ref($$centry[1]{descriptor_edge}) eq 'HASH') {
    push @{$rule_ir->{edge_sequence}}, { %{$$centry[1]{descriptor_edge}} };
   }
   _trace_rule_ir_decision(
    phase => 'collect',
    label => $rule_ir->{label},
    decision => 'explicit_acode',
    taken => 1,
    reason => 'collected explicit action edge',
    context => {
     relabel => $$centry[1]{relabel},
     reidx => $$centry[1]{reidx},
     acode_count => scalar(@{$rule_ir->{acode_entries}}),
    },
   );
  }
  elsif ($entry_type eq 'BCODE') {
   push @{$rule_ir->{bcode_entries}}, {
    call => $$centry[1]{call},
    code => $$centry[1]{code},
   };
   if (ref($$centry[1]{descriptor_edge}) eq 'HASH') {
    push @{$rule_ir->{edge_sequence}}, { %{$$centry[1]{descriptor_edge}} };
   }
   _trace_rule_ir_decision(
    phase => 'collect',
    label => $rule_ir->{label},
    decision => 'blind_call',
    taken => 1,
    reason => 'collected blind-call edge',
    context => {
     call => $$centry[1]{call},
     bcode_count => scalar(@{$rule_ir->{bcode_entries}}),
    },
   );
  }
  elsif ($entry_type eq 'BARE_EDGE') {
   push @{$rule_ir->{bare_edge_entries}}, $$centry[1];
   push @{$rule_ir->{edge_sequence}}, { bare_edge => $$centry[1] };
   _trace_rule_ir_decision(
    phase => 'collect',
    label => $rule_ir->{label},
    decision => 'bare_edge_candidate',
    taken => 1,
    reason => 'retained line-level bare edge for declared-rule normalization',
    context => {
     target_count => scalar(@{$$centry[1]{targets} || []}),
     bare_edge_count => scalar(@{$rule_ir->{bare_edge_entries}}),
    },
   );
  }
  elsif ($entry_type eq 'MOVE_POS') {
   push @{$rule_ir->{legacy_gap_markers}}, {
    marker => '@move_pos',
    line => ref($$centry[1]) eq 'HASH' ? $$centry[1]{line} : undef,
   };
   push @{$rule_ir->{code_blocks}{LECODE}},
    '$IPOS = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position('.
    '$info, $STRING, pos $$STRING, "rule_move_pos")';
   _trace_rule_ir_decision(
    phase => 'collect',
    label => $rule_ir->{label},
    decision => 'move_pos_lecode',
    taken => 1,
    reason => 'lowered move-position marker into LECODE',
    context => {
     lecode_count => scalar(@{$rule_ir->{code_blocks}{LECODE}}),
    },
   );
  }
  elsif ($entry_type eq 'MARK_POS') {
   my $mark_name = $$centry[1]{name};
   my $rule_label = defined($rule_ir->{label}) ? $rule_ir->{label} : '<unknown_rule>';
   my $mark_reidx = scalar(@{$rule_ir->{REs}}) - 1;
   $mark_reidx = 0 if $mark_reidx < 0;
   push @{$rule_ir->{code_blocks}{LECODE}},
    'if ($$minfo{index} == '.$mark_reidx.') { '.
    'LinkedSpec::SourceLocation::Runtime::mark_write_position('.
    '$info, $STRING, \''.$rule_label.'\', \''.$mark_name.'\', pos $$STRING, "rule_mark"); '.
    _build_mark_trace_stmt(
     operation => '@mark',
     rule_label => $rule_label,
     mark_name => $mark_name,
     mark_pos_expr => '$$info{marks}{\''.$rule_label.'\'}{\''.$mark_name.'\'}',
    ).'; }';
   _trace_rule_ir_decision(
    phase => 'collect',
    label => $rule_ir->{label},
    decision => 'mark_pos_lecode',
    taken => 1,
    reason => 'lowered named mark marker into LECODE',
    context => {
     mark_name => $mark_name,
     mark_reidx => $mark_reidx,
     lecode_count => scalar(@{$rule_ir->{code_blocks}{LECODE}}),
    },
   );
  }
  elsif ($entry_type eq 'CAPTURE_GAPS') {
   push @{$rule_ir->{capture_gaps_directives}}, {
    line => ref($$centry[1]) eq 'HASH' ? $$centry[1]{line} : undef,
   };
  }
  $last_was_re = 0;
 }

 return $rule_ir
}

sub _rule_ir_diagnostic {
 my (%args) = @_;
 my $code = $args{code} // 'rule_ir_normalization_failed';
 my $stage = $args{stage} // 'normalize_edges';
 return {
  type => 'compiler_pipeline',
  code => $code,
  stage => $stage,
  summary => $args{summary} // $code,
  detail => $args{detail} // $code,
  map { exists($args{$_}) ? ($_ => $args{$_}) : () }
   qw/rule_label source_id line slot_name first_line target target_rule targets
      authored_selector regex_index regex_count ownerships family cursor_policy
      edge_ownership execution_shape marker marker_line/,
 }
}

sub _normalize_descriptor_edge_fluent {
 my ($fluent) = @_;
 return undef unless defined $fluent;
 $fluent =~ s/^\s*\.\s*//o;
 $fluent =~ s/\s+\z//o;
 return $fluent
}

sub _validate_rule_regex_slots {
 my ($rule_ir) = @_;
 LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::UnicodeXIDContinue');
 my $label = $rule_ir->{label} // '<undefined>';
 my %first_line;
 for my $slot (@{$rule_ir->{regex_slots} || []}) {
  my $name = $slot->{slot_id};
  next unless defined $name;
  my $line = $slot->{line};
  unless (LinkedSpec::UnicodeXIDContinue::is_xid_continue_string($name)
      && $name !~ /\A[0-9]+\z/o) {
   die _rule_ir_diagnostic(
    code => 'regex_slot_name_invalid',
    stage => 'parse_declaration',
    rule_label => $label,
    source_id => $rule_ir->{source_id},
    line => $line,
    slot_name => $name,
   )
  }
  if (exists $first_line{$name}) {
   die _rule_ir_diagnostic(
    code => 'regex_slot_duplicate_name',
    stage => 'resolve_declaration',
    rule_label => $label,
    source_id => $rule_ir->{source_id},
    line => $line,
    slot_name => $name,
    first_line => $first_line{$name},
   )
  }
  $first_line{$name} = $line;
 }
 return 1
}

sub _resolve_target_selector {
 my ($rule_ir, $target, $slot_catalog) = @_;
 my $label = $rule_ir->{label} // '<undefined>';
 my $target_rule = $target->{label} // $target->{target};
 my $kind = $target->{selector_kind};
 if (!defined($kind) || !length($kind)) {
  $kind = defined($target->{index}) || defined($target->{regex_index})
   ? 'numeric'
   : 'unindexed';
 }
 my $authored = exists($target->{authored_selector})
  ? $target->{authored_selector}
  : $kind eq 'numeric'
   ? (defined($target->{index}) ? $target->{index} : $target->{regex_index})
   : undef;
 my $slots = ref($slot_catalog->{$target_rule}) eq 'ARRAY'
  ? $slot_catalog->{$target_rule}
  : [];
 my $catalog_authoritative = exists $slot_catalog->{$target_rule};
 my ($regex_index, $target_slot_id);
 unless ($catalog_authoritative) {
  $regex_index = $kind eq 'numeric'
   ? 0 + $authored
   : defined($target->{index})
    ? 0 + $target->{index}
    : defined($target->{regex_index})
     ? 0 + $target->{regex_index}
     : 0;
  return {
   selector_kind => $kind,
   authored_selector => $authored,
   target_rule => $target_rule,
   regex_index => $regex_index,
   target_slot_id => undef,
  }
 }
 if ($kind eq 'named') {
  my ($slot) = grep {
   defined($_->{slot_id}) && defined($authored) && $_->{slot_id} eq $authored
  } @$slots;
  unless ($slot) {
   die _rule_ir_diagnostic(
    code => 'regex_slot_unknown_name',
    stage => 'resolve_selector',
    rule_label => $label,
    source_id => $rule_ir->{source_id},
    line => $target->{line},
    target_rule => $target_rule,
    authored_selector => $authored,
   )
  }
  $regex_index = 0 + $slot->{regex_index};
  $target_slot_id = $slot->{slot_id};
 } else {
  $regex_index = $kind eq 'numeric'
   ? 0 + $authored
   : 0;
  if ($kind ne 'unindexed' && $regex_index >= @$slots) {
   die _rule_ir_diagnostic(
    code => 'regex_slot_index_out_of_range',
    stage => 'resolve_selector',
    rule_label => $label,
    source_id => $rule_ir->{source_id},
    line => $target->{line},
    target_rule => $target_rule,
    regex_index => $regex_index,
    regex_count => scalar(@$slots),
   )
  }
  $target_slot_id = @$slots ? $slots->[$regex_index]{slot_id} : undef;
 }
 return {
  selector_kind => $kind,
  authored_selector => $authored,
  target_rule => $target_rule,
  regex_index => $regex_index,
  target_slot_id => $target_slot_id,
 }
}

sub _normalize_rule_ir_edges {
 my ($rule_ir, %args) = @_;
 my $declared = ref($args{declared_rule_labels}) eq 'HASH'
  ? $args{declared_rule_labels}
  : {};
 my $slot_catalog = ref($args{declared_rule_slots}) eq 'HASH'
  ? $args{declared_rule_slots}
  : {};
 my $label = $rule_ir->{label} // '<undefined>';
 my $family = ($rule_ir->{node_type} // '') =~ /AND/o ? 'and' : 'or_default';
 my $ownership = $family eq 'and' ? 'blind' : 'action';

 $rule_ir->{family} = $family;
 $rule_ir->{cursor_policy} = $family eq 'and' ? 'consume' : 'seek';
 $rule_ir->{normalized_edges} = [];
 _validate_rule_regex_slots($rule_ir);

 for my $bare (@{$rule_ir->{bare_edge_entries} || []}) {
  my $targets = ref($bare->{targets}) eq 'ARRAY' ? $bare->{targets} : [];
  for my $target (@$targets) {
   my $target_label = $target->{label};
   unless (defined($target_label) && exists($declared->{$target_label})) {
    die _rule_ir_diagnostic(
     code => 'bare_edge_target_undefined',
     stage => 'normalize_edges',
     summary => "Bare edge in rule '$label' targets undefined rule '$target_label'",
     detail => "Declare rule '$target_label' before compiling bare edges or use an explicit non-rule construct",
     rule_label => $label,
     target => $target_label,
    )
   }
  }

  if ($ownership eq 'blind') {
   my ($indexed) = grep { defined($_->{index}) } @$targets;
   if ($indexed) {
    die _rule_ir_diagnostic(
     code => 'bare_edge_index_requires_action',
     stage => 'normalize_edges',
     summary => "Indexed bare edge in AND rule '$label' requires explicit action ownership",
     detail => "Use '-> " . $indexed->{label} . '[' . $indexed->{index} . "]' for an indexed action edge",
     rule_label => $label,
     target => $indexed->{label},
     regex_index => $indexed->{index},
    )
   }
   if (@$targets > 1) {
    my @labels = map { $_->{label} } @$targets;
    die _rule_ir_diagnostic(
     code => 'bare_edge_group_requires_action',
     stage => 'normalize_edges',
     summary => "Grouped bare edge in AND rule '$label' requires explicit action ownership",
     detail => "Use '-> " . join(' | ', @labels) . " { ... }' for a grouped action edge",
     rule_label => $label,
     targets => \@labels,
    )
   }
  }

  if ($ownership eq 'action') {
   for my $target (@$targets) {
    push @{$rule_ir->{acode_entries}}, {
     relabel => $target->{label},
     reidx => defined($target->{index}) ? $target->{index} : 0,
     selector_kind => $target->{selector_kind},
     authored_selector => $target->{authored_selector},
     selector_provenance => exists($target->{selector_kind}) ? 1 : 0,
     line => $target->{line},
     code => $bare->{action_code},
    };
   }
  } else {
   my $target = $targets->[0];
   push @{$rule_ir->{bcode_entries}}, {
    call => $target->{label},
    code => $bare->{blind_code},
   };
  }

  push @{$rule_ir->{normalized_edges}}, {
   kind => 'edge',
   ownership => $ownership,
   source_form => 'bare',
   has_block => $bare->{has_block} ? 1 : 0,
   fluent => _normalize_descriptor_edge_fluent($bare->{fluent}),
   targets => [map {
    {
     label => $_->{label},
     index => $_->{index},
     fluent => _normalize_descriptor_edge_fluent($bare->{fluent}),
    }
   } @$targets],
  };
 }

 for my $acode (@{$rule_ir->{acode_entries} || []}) {
  my $resolved = _resolve_target_selector(
   $rule_ir,
   {
    label => $acode->{relabel},
    regex_index => $acode->{reidx},
    selector_kind => $acode->{selector_kind},
    authored_selector => $acode->{authored_selector},
    line => $acode->{line},
   },
   $slot_catalog,
  );
  $acode->{reidx} = $resolved->{regex_index};
  $acode->{selector_kind} = $resolved->{selector_kind};
  $acode->{authored_selector} = $resolved->{authored_selector};
  $acode->{target_slot_id} = $resolved->{target_slot_id};
 }

 my @ownerships;
 push @ownerships, 'action' if @{$rule_ir->{acode_entries}};
 push @ownerships, 'blind' if @{$rule_ir->{bcode_entries}};
 if (@ownerships > 1) {
  die _rule_ir_diagnostic(
   code => 'mixed_edge_ownership',
   stage => 'validate_rule',
   summary => "Rule '$label' mixes action and blind edge ownership",
   detail => "Choose one edge ownership for every edge in rule '$label'",
   rule_label => $label,
   ownerships => \@ownerships,
  )
 }

 $rule_ir->{edge_ownership} = @ownerships ? $ownerships[0] : 'none';
 my @resolved_edges;
 my @resolved_slot_edges;
 for my $edge (@{$rule_ir->{edge_sequence} || []}) {
  if (ref($edge->{bare_edge}) eq 'HASH') {
   my $bare = $edge->{bare_edge};
   my $targets = ref($bare->{targets}) eq 'ARRAY' ? $bare->{targets} : [];
   for my $target (@$targets) {
    my $resolved = $ownership eq 'action'
     ? _resolve_target_selector($rule_ir, $target, $slot_catalog)
     : undef;
    push @resolved_edges, {
     ownership => $ownership,
     target => $target->{label},
     regex_index => $ownership eq 'action'
      ? $resolved->{regex_index}
      : undef,
     block => $bare->{has_block} ? 1 : 0,
     fluent => _normalize_descriptor_edge_fluent($bare->{fluent}),
     source_form => 'bare',
    };
    push @resolved_slot_edges, { %$resolved } if $resolved;
   }
   next;
  }
  my $resolved = ($edge->{ownership} // '') eq 'action'
   ? _resolve_target_selector(
      $rule_ir,
      {
       label => $edge->{target},
       regex_index => $edge->{regex_index},
       selector_kind => $edge->{selector_kind},
       authored_selector => $edge->{authored_selector},
       line => $edge->{line},
      },
      $slot_catalog,
     )
   : undef;
  push @resolved_edges, {
   ownership => $edge->{ownership},
   target => $edge->{target},
   regex_index => $resolved ? $resolved->{regex_index} : undef,
   block => $edge->{block} ? 1 : 0,
   fluent => _normalize_descriptor_edge_fluent($edge->{fluent}),
   source_form => $edge->{source_form} // 'explicit',
  };
  push @resolved_slot_edges, { %$resolved } if $resolved;
 }
 $rule_ir->{resolved_edges} = \@resolved_edges;
 $rule_ir->{resolved_slot_edges} = \@resolved_slot_edges;
 $rule_ir->{bare_edge_entries} = [];
 return $rule_ir
}

sub _plan_rule_ir_meta {
 my ($rule_ir) = @_;

 my $meta = _build_rule_execution_meta(
  label       => $rule_ir->{label},
  node_type   => $rule_ir->{node_type},
  rep_min     => $rule_ir->{rep_min},
  rep_max     => $rule_ir->{rep_max},
  regex_count => scalar(@{$rule_ir->{REs}}),
  acode_count => scalar(@{$rule_ir->{acode_entries}}),
  bcode_count => scalar(@{$rule_ir->{bcode_entries}}),
 );
 $meta->{family} = $rule_ir->{family} if defined $rule_ir->{family};
 $meta->{is_top} = $rule_ir->{is_top} ? 1 : 0;
 $meta->{cursor_policy} = $rule_ir->{cursor_policy} if defined $rule_ir->{cursor_policy};
 $meta->{edge_ownership} = $rule_ir->{edge_ownership} if defined $rule_ir->{edge_ownership};
 $meta->{resolved_edges} = [map { { %$_ } } @{$rule_ir->{resolved_edges} || []}];
 $meta->{resolved_slot_edges} = [map { { %$_ } } @{$rule_ir->{resolved_slot_edges} || []}];
 $meta->{regex_slots} = [map {
  {
   regex_index => 0 + $_->{regex_index},
   slot_id => $_->{slot_id},
  }
 } @{$rule_ir->{regex_slots} || []}];

 my $directives = $rule_ir->{capture_gaps_directives} || [];
 if (@$directives > 1) {
  die _rule_ir_diagnostic(
   code => 'capture_gaps_duplicate_directive',
   stage => 'parse_directive',
   rule_label => $rule_ir->{label},
   source_id => $rule_ir->{source_id},
   line => $directives->[1]{line},
   first_line => $directives->[0]{line},
  )
 }
 if (@$directives) {
  my $directive = $directives->[0];
  my $legacy = $rule_ir->{legacy_gap_markers}[0];
  if ($legacy) {
   die _rule_ir_diagnostic(
    code => 'capture_gaps_legacy_marker_conflict',
    stage => 'validate_directive',
    rule_label => $rule_ir->{label},
    source_id => $rule_ir->{source_id},
    line => $directive->{line},
    marker => $legacy->{marker},
    marker_line => $legacy->{line},
   )
  }
  my $eligible = $meta->{family} eq 'or_default'
   && $meta->{cursor_policy} eq 'seek'
   && $meta->{edge_ownership} eq 'action'
   && $meta->{uses_loop}
   && ($meta->{execution_shape} eq 'default_scan_loop'
       || $meta->{execution_shape} eq 'repeat_loop')
   && $meta->{acode_count} >= 1;
  unless ($eligible) {
   die _rule_ir_diagnostic(
    code => 'capture_gaps_rule_ineligible',
    stage => 'validate_directive',
    rule_label => $rule_ir->{label},
    source_id => $rule_ir->{source_id},
    line => $directive->{line},
    family => $meta->{family},
    cursor_policy => $meta->{cursor_policy},
    edge_ownership => $meta->{edge_ownership},
    execution_shape => $meta->{execution_shape},
   )
  }
  $meta->{capture_gaps} = {
   enabled => 1,
   directive => '@capture_gaps',
   line => $directive->{line},
  };
 }
 return $meta
}

sub _validate_rule_ir_or_exit {
 my ($rule_ir, $rule_meta) = @_;

 if ($rule_meta->{action_mode} eq 'mixed') {
  _trace_rule_ir_decision(
   phase => 'validate',
   label => $rule_ir->{label},
   decision => 'mixed_action_mode',
   taken => 0,
   reason => 'mixed action mode detected',
   context => {
    acode_count => $rule_meta->{acode_count},
    bcode_count => $rule_meta->{bcode_count},
   },
   level => DUMP_HIGH,
  );
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
 _trace_rule_ir_decision(
  phase => 'validate',
  label => $rule_ir->{label},
  decision => 'action_mode_valid',
  taken => 1,
  reason => "rule action mode '$rule_meta->{action_mode}' is valid",
  context => {
   action_mode => $rule_meta->{action_mode},
  },
 );
 _trace_decision(
  "_validate_rule_ir_or_exit:$rule_ir->{label}",
  1,
  "rule action mode '$rule_meta->{action_mode}' is valid",
  DUMP_DEBUG
 );

 return 1
}

1;
