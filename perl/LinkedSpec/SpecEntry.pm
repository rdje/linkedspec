package LinkedSpec::SpecEntry;

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

my $rep_nodes_minmax = {
 REP_PLUS   => [1, 10**9],
 REP_STAR   => [0, 10**9],
 REP_OPT    => [0, 1],
 REP_OR_PLUS => [1, 10**9],
};

sub _resolve_rep_bounds {
 my (%args) = @_;
 my $node_type = $args{node_type};
 my $rep_min = $args{rep_min};
 my $rep_max = $args{rep_max};

 if (defined($rep_min) || defined($rep_max)) {
  $rep_min = defined($rep_min) ? $rep_min : 0;
  $rep_max = defined($rep_max) ? $rep_max : 10**9;
  return ($rep_min, $rep_max);
 }

 return unless defined($node_type) && exists $rep_nodes_minmax->{$node_type};
 return @{$rep_nodes_minmax->{$node_type}};
}

sub _require_pkg {
 my ($pkg) = @_;
 my $file = $pkg;
 $file =~ s{::}{/}go;
 $file .= '.pm';
 my $ok = eval { require $file; 1 };
 die "(LinkedSpec::SpecEntry::_require_pkg) -E- unable to load '$pkg': $@" unless $ok;
 return 1
}

sub _require_rule_ir_pkg {
 _require_pkg('LinkedSpec::RuleIR') unless LinkedSpec::RuleIR->can('_collect_rule_ir');
 return 1
}

sub _require_emit_context_pkg {
 _require_pkg('LinkedSpec::RuleIR::EmitContext')
  unless LinkedSpec::RuleIR::EmitContext->can('build_rule_ir_emit_context');
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

sub _trace_enter {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::trace_enter(@args)
 })
}

sub _trace_exit {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::trace_exit(@args)
 })
}

sub _trace_decision {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::trace_decision(@args)
 })
}

sub _trace_log_dump {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::log_dump(@args)
 })
}

sub _trace_should_dump {
 my @args = @_;
 return _call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return LinkedSpec::Trace::should_dump(@args)
 })
}

sub _dump_value {
 my ($value) = @_;
 return _call_preserving_err(sub {
  _require_data_dumper_pkg();
  return Data::Dumper::Dumper($value)
 })
}

sub _runtime_ctx_from_deps {
 my ($deps) = @_;
 return undef unless ref($deps) eq 'HASH';
 return $deps->{runtime_ctx} if ref($deps->{runtime_ctx}) eq 'HASH';
 return undef
}

sub _call_runtime_ctx {
 my ($subname, @args) = @_;
 return _call_preserving_err(sub {
  _require_pkg('LinkedSpec::RuntimeContext') unless LinkedSpec::RuntimeContext->can($subname);
  no strict 'refs';
  return &{"LinkedSpec::RuntimeContext::${subname}"}(@args);
 })
}

sub _set_runtime_ctx_last_error {
 my ($runtime_ctx, %args) = @_;
 return _call_runtime_ctx('set_runtime_ctx_last_error_for_owner', $runtime_ctx, 'runtime_handler', %args)
}

sub _emit_runtime_ctx_parser_source_line {
 my ($runtime_ctx, $chunk) = @_;
 return _call_runtime_ctx('emit_runtime_ctx_parser_source_line', $runtime_ctx, $chunk)
}

sub _set_runtime_ctx_top_rule {
 my ($runtime_ctx, $top_rule) = @_;
 return _call_runtime_ctx('set_runtime_ctx_top_rule', $runtime_ctx, $top_rule)
}

sub _generated_handler_source_label {
 my (%args) = @_;
 my $rule_meta = $args{rule_meta};
 my $variant = (ref($rule_meta) eq 'HASH') ? $rule_meta->{selected_handler_variant} : undef;
 return _call_runtime_ctx(
  'build_generated_handler_source_label',
  label => $args{label},
  handler_variant => $variant,
 )
}

sub _quote_source_label_for_line_directive {
 my ($source_label) = @_;
 $source_label = '' unless defined $source_label;
 $source_label =~ s/\\/\\\\/g;
 $source_label =~ s/"/\\"/g;
 $source_label =~ s/[\r\n]+/ /g;
 return $source_label
}

sub _build_handler_preamble {
 my ($label, $actual_icode) = @_;
 return
'my ($descr, $STRING, $info) = @_;
my $IMATCH      = $$info{match};
my @IMATCH_LIST = @{$$info{match_list} // []};
my %IMATCH_HASH = %{$$info{match_hash} // {}};
my $IINDEX      = $$info{index};
my $IPOS        = pos $$STRING;

my @'.$label.';

'.$actual_icode;
}

sub _build_acodes_dispatch_block {
 my ($acodes_ref) = @_;
 return '' unless ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
 my $once = 0;
 my $idx = 0;
 my $acodes = '';
 $acodes .= ($once++ ? " elsif " : "\n   if").'($$minfo{index} == '.$idx++.") {\n    $_\n   }" foreach (@$acodes_ref);
 return $acodes
}

sub _build_bcodes_dispatch_block {
 my ($bcalls_ref, $bcodes_ref) = @_;
 return '' unless ref($bcalls_ref) eq 'ARRAY' && @$bcalls_ref;
 return '' unless ref($bcodes_ref) eq 'HASH';
 my $once = 0;
 my $bcodes = '';
 foreach my $call (@$bcalls_ref) {
  my $call_code = defined($bcodes_ref->{$call}) ? $bcodes_ref->{$call} : '';
  $bcodes .= ($once++ ? " elsif " : "\n   if")."(\$call eq \"$call\") {\n    $call_code\n   }";
 }
 return $bcodes
}

sub _build_default_handler_variant {
 my (%args) = @_;
 my $acodes = $args{acodes} // '';
 return undef unless length $acodes;
 my $label = $args{label};
 my $actual_lxcode = $args{actual_lxcode} // '';
 my $actual_lscode = $args{actual_lscode} // '';
 my $actual_lecode = $args{actual_lecode} // '';
 return '

 while (1) {
  my $minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'});

  unless($minfo) {
  '.($actual_lxcode || 'return undef').'
  }

  my $LMATCH      = $$minfo{match};
  my @LMATCH_LIST = @{$$minfo{match_list} // []};
  my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
  my $LINDEX      = $$minfo{index};
  my $LSPOS       = pos $$STRING;

  '.$actual_lscode.'

  '.   $acodes     .'

  '.$actual_lecode.'

 }'
}

sub _build_and_bcode_sequence_body {
 my (%args) = @_;
 my $bcodes = $args{bcodes} // '';
 return undef unless length $bcodes;
 my $label = $args{label};
 my $actual_lxcode = $args{actual_lxcode} // '';
 my $actual_lecode = $args{actual_lecode} // '';
 my $actual_ecode = $args{actual_ecode} // '';
 my $bcalls = $args{bcalls} // '';
 return '

  my $'.$label.';
  my @'.$label.'_collect;
  foreach my $call (qw('.$bcalls.')) {
   my $current_call = $call;

   '.$bcodes.'

   unless ($'.$label.') {
    '.($actual_lxcode || 'return undef').'
   }

   '.($actual_lecode || 'push @'.$label.'_collect, $'.$label).'
  }

  '.($actual_ecode || 'return \@'.$label.'_collect').'
 '
}

sub _build_and_bcode_variant {
 my (%args) = @_;
 return _build_and_bcode_sequence_body(%args)
}

sub _build_and_single_acode_variant {
 my (%args) = @_;
 my $acodes = $args{acodes} // '';
 return undef unless length $acodes;
 my $label = $args{label};
 my $actual_lxcode = $args{actual_lxcode} // '';
 my $actual_lscode = $args{actual_lscode} // '';
 my $actual_lecode = $args{actual_lecode} // '';
 return '

 my @'.$label.'_collect;
 my $minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'});
 unless($minfo) {
  '.($actual_lxcode || 'return undef').'
 }

 unless($$minfo{index} == 0) {
  '.($actual_lxcode || 'return undef').'
 }

 my $LMATCH      = $$minfo{match};
 my @LMATCH_LIST = @{$$minfo{match_list} // []};
 my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
 my $LINDEX      = $$minfo{index};
 my $LSPOS       = pos $$STRING;

 '.$actual_lscode.'

 '.   $acodes     .'

 '.$actual_lecode.'

 return \@'.$label.'_collect;
 '
}

sub _build_and_acode_sequence_body {
 my (%args) = @_;
 my $acodes = $args{acodes} // '';
 return undef unless length $acodes;
 my $label = $args{label};
 my $actual_lxcode = $args{actual_lxcode} // '';
 my $actual_lscode = $args{actual_lscode} // '';
 my $actual_lecode = $args{actual_lecode} // '';
 my $acode_count = $args{acode_count} // 0;
 return '

 my @'.$label.'_collect;
 my $idx = 0;

 while ($idx < '.$acode_count.') {
  my $minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'});
  unless($minfo) {
   '.($actual_lxcode || 'return undef').'
  }

  # Only proceed if we match the expected index in sequence
  unless($$minfo{index} == $idx) {
   '.($actual_lxcode || 'return undef').'
  }

  my $LMATCH      = $$minfo{match};
  my @LMATCH_LIST = @{$$minfo{match_list} // []};
  my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
  my $LINDEX      = $$minfo{index};
  my $LSPOS       = pos $$STRING;

  '.$actual_lscode.'

  '.   $acodes     .'

  '.$actual_lecode.'

  $idx++;
 }

 return \@'.$label.'_collect;
 '
}

sub _build_and_acode_variant {
 my (%args) = @_;
 return _build_and_acode_sequence_body(%args)
}

sub _build_or_bcode_choice_body {
 my (%args) = @_;
 my $bcodes = $args{bcodes} // '';
 return undef unless length $bcodes;
 my $label = $args{label};
 my $actual_lxcode = $args{actual_lxcode} // '';
 my $actual_ecode = $args{actual_ecode} // '';
 my $bcalls = $args{bcalls} // '';
 return '

  my $'.$label.';
  foreach my $call (qw('.$bcalls.')) {
   my $current_call = $call;

   '.$bcodes.'

   if ($'.$label.') {
    '.($actual_lxcode || 'return $'.$label).'
   }
  }

  '.($actual_ecode || 'return undef').'
 '
}

sub _build_or_acode_variant {
 my (%args) = @_;
 my $acodes = $args{acodes} // '';
 return undef unless length $acodes;
 my $label = $args{label};
 my $actual_lxcode = $args{actual_lxcode} // '';
 return '

 my $minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'});
 unless($minfo) {
 '.($actual_lxcode || 'return undef').'
 }

 my $LMATCH      = $$minfo{match};
 my @LMATCH_LIST = @{$$minfo{match_list} // []};
 my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
 my $LINDEX      = $$minfo{index};
 my $LSPOS       = pos $$STRING;

 '.   $acodes .'
 '
}

sub _build_or_bcode_variant {
 my (%args) = @_;
 return _build_or_bcode_choice_body(%args)
}

sub _build_rep_bcode_variant {
 my (%args) = @_;
 my ($min, $max) = _resolve_rep_bounds(%args);
 if (!defined($min) || !defined($max)) {
  my $node_type = $args{node_type} // '';
  if ($node_type eq 'default') {
   ($min, $max) = (1, 10**9);
  }
 }
 return undef unless defined $min && defined $max;

 my $label = $args{label};
 my $actual_itcode = $args{actual_itcode} // '';
 my $actual_excode = $args{actual_excode} // '';
 my $actual_ecode = $args{actual_ecode} // '';
 my $or_code = _build_or_bcode_choice_body(
  %args,
  actual_ecode => 'return undef',
 );
 return undef unless defined $or_code;

 return '
   my $min='.$min.';
   my $max='.$max.';
   my $'.$label.';
   my @'.$label.'_collect;

   my $ccount = 0;
   my $or_code = sub {'.$or_code.'
   };

   while(1) {
    my $loop_start_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    my $or_ret = $or_code->();
    unless ($or_ret) {
     if ($ccount >= $min) {
      '.($actual_excode || 'return \@'.$label.'_collect').'
     } else {
      return undef
     }
    }

    my $loop_end_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    if ($loop_end_pos == $loop_start_pos) {
     if ($ccount >= $min) {
      '.($actual_excode || 'return \@'.$label.'_collect').'
     } else {
      return undef
     }
    }

    ++$ccount;

    '.($actual_itcode || 'push @'.$label.'_collect, $or_ret;').'

    last unless $ccount < $max
   }

   '.($actual_ecode || 'return \@'.$label.'_collect').'
   '
}

sub _build_rep_and_bcode_variant {
 my (%args) = @_;
 my ($min, $max) = _resolve_rep_bounds(%args);
 return undef unless defined $min && defined $max;

 my $label = $args{label};
 my $actual_itcode = $args{actual_itcode} // '';
 my $actual_excode = $args{actual_excode} // '';
 my $actual_ecode = $args{actual_ecode} // '';
 my $and_code = _build_and_bcode_sequence_body(
  %args,
  actual_ecode => 'return \@'.$label.'_collect',
 );
 return undef unless defined $and_code;

 return '
   my $min='.$min.';
   my $max='.$max.';
   my $'.$label.';
   my @'.$label.'_collect;

   my $ccount = 0;
   my $and_code = sub {'.$and_code.'
   };

   while(1) {
    my $loop_start_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    my $and_ret = $and_code->();
    unless ($and_ret) {
     if ($ccount >= $min) {
      '.($actual_excode || 'return \@'.$label.'_collect').'
     } else {
      return undef
     }
    }

    my $loop_end_pos = defined(pos $$STRING) ? pos $$STRING : -1;
    if ($loop_end_pos == $loop_start_pos) {
     if ($ccount >= $min) {
      '.($actual_excode || 'return \@'.$label.'_collect').'
     } else {
      return undef
     }
    }

    ++$ccount;

    '.($actual_itcode || 'push @'.$label.'_collect, $and_ret;').'

    last unless $ccount < $max
   }

   '.($actual_ecode || 'return \@'.$label.'_collect').'
   '
}

sub _build_rep_and_acode_variant {
 my (%args) = @_;
 my ($min, $max) = _resolve_rep_bounds(%args);
 return undef unless defined $min && defined $max;

 my $label = $args{label};
 my $actual_itcode = $args{actual_itcode} // '';
 my $actual_excode = $args{actual_excode} // '';
 my $actual_ecode = $args{actual_ecode} // '';
 my $acode_count = (ref($args{acodes_ref}) eq 'ARRAY') ? scalar(@{$args{acodes_ref}}) : 0;
 return undef unless $acode_count;

 my $and_code = _build_and_acode_sequence_body(
  %args,
  acode_count  => $acode_count,
  actual_ecode => 'return \@'.$label.'_collect',
 );
 return undef unless defined $and_code;

 return '

   my $min='.$min.';
   my $max='.$max.';
   my @'.$label.'_collect;
   my $ccount = 0;
   my $and_code = sub {'.$and_code.'
   };

   while(1) {
    my $and_ret = $and_code->();
    unless ($and_ret) {
     if ($ccount >= $min) {
      '.($actual_excode || 'return \@'.$label.'_collect').'
     } else {
      return undef
     }
    }

    ++$ccount;

    '.($actual_itcode || 'push @'.$label.'_collect, $and_ret;').'

    last unless $ccount < $max
   }

   '.($actual_ecode || 'return \@'.$label.'_collect').'
 '
}

sub _build_rep_acode_variant {
 my (%args) = @_;
 my $acodes = $args{acodes} // '';
 return undef unless length $acodes;
 my $label = $args{label};
 my ($min, $max) = _resolve_rep_bounds(%args);
 return undef unless defined $min && defined $max;

 my $actual_lscode = $args{actual_lscode} // '';
 my $actual_lecode = $args{actual_lecode} // '';
 my $actual_itcode = $args{actual_itcode} // '';
 my $actual_excode = $args{actual_excode} // '';
 my $actual_ecode = $args{actual_ecode} // '';

 return '

   my $min='.$min.';
   my $max='.$max.';
   my @'.$label.'_collect;
   my $ccount = 0;

   while(1) {
    my $minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'});
    unless($minfo) {
     if ($ccount >= $min) {
      '.($actual_excode || 'return \@'.$label.'_collect').'
     } else {
      return undef
     }
    }

    my $LMATCH      = $$minfo{match};
    my @LMATCH_LIST = @{$$minfo{match_list} // []};
    my %LMATCH_HASH = %{$$minfo{match_hash} // {}};
    my $LINDEX      = $$minfo{index};
    my $LSPOS       = pos $$STRING;

    '.$actual_lscode.'

    '.   $acodes     .'

    '.$actual_lecode.'

    ++$ccount;

    '.($actual_itcode || 'push @'.$label.'_collect, $'.$label.';').'

    last unless $ccount < $max
   }

   '.($actual_ecode || 'return \@'.$label.'_collect').'
 '
}

sub _build_handler_variants {
 my (%args) = @_;
 my $label = $args{label};
 my $node_type = $args{node_type} // '';
 my $acodes_ref = $args{acodes_ref};
 my $bcodes_ref = $args{bcodes_ref};
 my $bcalls_ref = $args{bcalls_ref};
 my $ab_count_ref = $args{ab_count_ref};

 my $acodes = _build_acodes_dispatch_block($acodes_ref);
 my $bcodes = _build_bcodes_dispatch_block($bcalls_ref, $bcodes_ref);
 my $bcalls = join(' ', @$bcalls_ref);

 my $isAND = $node_type =~ /AND/o;
 my $isOR  = $node_type =~ /OR/o;
 my $isREP = $node_type =~ /REP_/o;
 my $isREP_AND = $node_type =~ /REP_AND/o;
 my $isDEFAULT_BCODE_REP = !$isAND && !$isOR && !$isREP && length($bcodes);

 my %handlers;
 my $default = _build_default_handler_variant(
  %args,
  label => $label,
  acodes => $acodes,
 );
 $handlers{_default} = $default if defined $default;

 if ($isAND && length($bcodes)) {
  my $v = _build_and_bcode_variant(
   %args,
   label  => $label,
   bcodes => $bcodes,
   bcalls => $bcalls,
  );
  $handlers{AND_BCODE} = $v if defined $v;
 }
 if ($isAND && length($acodes) && ref($acodes_ref) eq 'ARRAY' && @$acodes_ref == 1) {
  my $v = _build_and_single_acode_variant(
   %args,
   label  => $label,
   acodes => $acodes,
  );
  $handlers{AND_SINGLE_ACODE} = $v if defined $v;
 }
 if ($isAND && length($acodes) && ref($acodes_ref) eq 'ARRAY' && @$acodes_ref > 1) {
  my $v = _build_and_acode_variant(
   %args,
   label       => $label,
   acodes      => $acodes,
   acode_count => scalar(@$acodes_ref),
  );
  $handlers{AND_ACODE} = $v if defined $v;
 }
 if ($isOR && length($acodes)) {
  my $v = _build_or_acode_variant(
   %args,
   label  => $label,
   acodes => $acodes,
  );
  $handlers{OR_ACODE} = $v if defined $v;
 }
 if ($isOR && length($bcodes)) {
  my $v = _build_or_bcode_variant(
   %args,
   label  => $label,
   bcodes => $bcodes,
   bcalls => $bcalls,
  );
  $handlers{OR_BCODE} = $v if defined $v;
 }
 if (($isREP || $isDEFAULT_BCODE_REP) && length($bcodes)) {
  my $v = _build_rep_bcode_variant(
   %args,
   label     => $label,
   node_type => $node_type,
   bcodes    => $bcodes,
   bcalls    => $bcalls,
  );
  $handlers{REP_BCODE} = $v if defined $v;
 }
 if ($isREP_AND && length($bcodes)) {
  my $v = _build_rep_and_bcode_variant(
   %args,
   label     => $label,
   node_type => $node_type,
   bcodes    => $bcodes,
   bcalls    => $bcalls,
  );
  $handlers{REP_AND_BCODE} = $v if defined $v;
 }
 if ($isREP && length($acodes)) {
  my $v = _build_rep_acode_variant(
   %args,
   label     => $label,
   node_type => $node_type,
   acodes    => $acodes,
  );
  $handlers{REP_ACODE} = $v if defined $v;
 }
 if ($isREP_AND && length($acodes)) {
  my $v = _build_rep_and_acode_variant(
   %args,
   label     => $label,
   node_type => $node_type,
   acodes    => $acodes,
  );
  $handlers{REP_AND_ACODE} = $v if defined $v;
 }
 return \%handlers
}

sub _select_handler_variant {
 my ($rule_meta, $handlers) = @_;
 return undef unless ref($rule_meta) eq 'HASH';
 return undef unless ref($handlers) eq 'HASH';
 return $rule_meta->{handler_variant} if exists $handlers->{$rule_meta->{handler_variant}};
 return '_default' if exists $handlers->{_default};
 return undef
}

sub _build_runtime_handler {
 my (%args) = @_;
 my $label = $args{label};
 my $handler = $args{handler};
 my $rule_meta = $args{rule_meta};
 my $runtime_ctx = $args{runtime_ctx};
 my $handler_variant = (ref($rule_meta) eq 'HASH') ? $rule_meta->{selected_handler_variant} : undef;
 my $handler_source_label = _generated_handler_source_label(
  label => $label,
  rule_meta => $rule_meta,
 );
 my $handler_source_directive_label = _quote_source_label_for_line_directive($handler_source_label);
 my $handler_source = qq{#line 1 "$handler_source_directive_label"\nsub {\n$handler\n}};
 my $compiled_handler;
 my $compile_warning = '';
 {
  local $SIG{__WARN__} = sub { $compile_warning .= join('', @_); };
  $compiled_handler = eval $handler_source;
 }
 warn $compile_warning if ref($compiled_handler) eq 'CODE' && length($compile_warning);
 my $compile_error = ref($compiled_handler) eq 'CODE'
  ? undef
  : ((length($compile_warning) ? $compile_warning : '') . ($@ || 'Unknown rule handler compilation failure'));

 return sub {
  my ($descr, $STRING, $info) = @_;
  my $runtime_scope = _trace_enter(
  "LinkedSpec::rule_handler:$label",
   {
    handler_variant => $handler_variant,
    index => (ref($info) eq 'HASH') ? $info->{index} : undef,
    match => (ref($info) eq 'HASH') ? $info->{match} : undef,
   },
   DUMP_HIGH
  );
  if ($compile_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'rule_handler_compile',
    summary => 'Rule handler compilation failed',
    detail => $compile_error,
    rule_label => $label,
    handler_variant => $handler_variant,
    handler_source_label => $handler_source_label,
   );
   _trace_decision("rule_handler_compile:$label", 0, $compile_error, DUMP_NONE);
   _trace_exit(
    $runtime_scope,
    {
     returned_defined => 0,
     return_ref => '',
     return_size => undef,
    },
    DUMP_HIGH
   );
   return undef
  }
  my $retv = eval { $compiled_handler->($descr, $STRING, $info) };
  my $eval_error = $@;
  if ($eval_error) {
   _set_runtime_ctx_last_error(
    $runtime_ctx,
    stage => 'rule_handler_eval',
    summary => 'Rule handler execution failed',
    detail => $eval_error,
    rule_label => $label,
    handler_variant => $handler_variant,
    handler_source_label => $handler_source_label,
   );
   _trace_decision("rule_handler_eval:$label", 0, $eval_error, DUMP_NONE);
  } else {
   _trace_decision("rule_handler_eval:$label", 1, 'handler eval completed', DUMP_DEBUG);
  }
  _trace_exit(
   $runtime_scope,
   {
    returned_defined => defined($retv) ? 1 : 0,
    return_ref => ref($retv) || '',
    return_size => (ref($retv) eq 'ARRAY') ? scalar(@$retv) : undef,
   },
   DUMP_HIGH
  );
  return $retv
 }
}

#------------------------------------------------------------------------------
# Function: compile_spec_entry
# Purpose : Compile one parsed rule entry through staged RuleIR flow and return
#           a final (label, rule_info_hashref, top_rule?) tuple.
# Args    : ($einfo, $deps)
# Returns : ($label, $rule_info_hashref, $top_rule?) | empty on failure
#------------------------------------------------------------------------------
sub compile_spec_entry {
 my ($einfo, $deps) = @_;
 $deps = {} unless ref($deps) eq 'HASH';
 my $runtime_ctx = _runtime_ctx_from_deps($deps);
 _require_rule_ir_pkg();

 my $trace_scope = _trace_enter('LinkedSpec::spec_entry', {
  token_count => (ref($einfo) eq 'ARRAY') ? scalar(@$einfo) : undef,
 }, DUMP_HIGH);

 my %info;
 my %handlers;

 if (_trace_should_dump(DUMP_HIGH)) {
  _trace_log_dump("=== SPEC ENTRY DUMP ===\n");
  _trace_log_dump(_dump_value($einfo));
  _trace_log_dump("=== END SPEC ENTRY DUMP ===\n");
 }

 my $rule_ir = LinkedSpec::RuleIR::_collect_rule_ir($einfo);
 my $rule_meta = LinkedSpec::RuleIR::_plan_rule_ir_meta($rule_ir);
 unless (LinkedSpec::RuleIR::_validate_rule_ir_or_exit($rule_ir, $rule_meta)) {
  _trace_exit($trace_scope, { status => 'error', stage => 'validate_rule_ir', label => $rule_ir->{label} }, DUMP_HIGH);
  return
 }

 _require_emit_context_pkg();
 my $emit_ctx = LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context($rule_ir);
 $rule_meta->{action_rewriter} = $emit_ctx->{action_rewriter_meta};
 my $label = $emit_ctx->{label};
 my $node_type = $emit_ctx->{node_type};
 my @REs = @{$emit_ctx->{REs}};
 my @ACODEs = @{$emit_ctx->{ACODEs}};
 my %BCODEs = %{$emit_ctx->{BCODEs}};
 my @BCALLs = @{$emit_ctx->{BCALLs}};
 my @GDATA = @{$emit_ctx->{GDATA}};
 my %ab_count = %{$emit_ctx->{ab_count}};

 my $icode = $emit_ctx->{icode};
 my $ecode = $emit_ctx->{ecode};
 my $excode = $emit_ctx->{excode};
 my $itcode = $emit_ctx->{itcode};
 my $lxcode = $emit_ctx->{lxcode};
 my $lscode = $emit_ctx->{lscode};
 my $lecode = $emit_ctx->{lecode};

 my $actual_icode = $icode && "$icode;" || "";
 my $actual_ecode = $ecode && "$ecode;" || "";
 my $actual_excode = $excode && "$excode;" || "";
 my $actual_itcode = $itcode && "$itcode;" || "";

 my $handler = _build_handler_preamble($label, $actual_icode);

 my $notvalid_lcodes = qr/^\s*$/o;
 if ($ab_count{ACODE} || $ab_count{BCODE} || $lxcode !~ $notvalid_lcodes || $lscode !~ $notvalid_lcodes || $lecode !~ $notvalid_lcodes) {
  my $actual_lxcode = $lxcode && "$lxcode;" || "";
  my $actual_lscode = $lscode && "$lscode;" || "";
  my $actual_lecode = $lecode && "$lecode;" || "";
  my $variants = _build_handler_variants(
   label          => $label,
   node_type      => $node_type,
   rep_min        => $rule_meta->{rep_min},
   rep_max        => $rule_meta->{rep_max},
   acodes_ref     => \@ACODEs,
   bcodes_ref     => \%BCODEs,
   bcalls_ref     => \@BCALLs,
   ab_count_ref   => \%ab_count,
   actual_lxcode  => $actual_lxcode,
   actual_lscode  => $actual_lscode,
   actual_lecode  => $actual_lecode,
   actual_ecode   => $actual_ecode,
   actual_excode  => $actual_excode,
   actual_itcode  => $actual_itcode,
  );
  %handlers = %$variants if ref($variants) eq 'HASH';
 }

 if(@REs) {
  $info{re}      = [@REs];
 }

 my $selected_handler_variant = _select_handler_variant($rule_meta, \%handlers);
 $handler .= defined $selected_handler_variant ? ($handlers{$selected_handler_variant} || "") : "";
 $rule_meta->{selected_handler_variant} = $selected_handler_variant // '<none>';

 my $external_handler = $handler;
 $external_handler =~ s/&{\$\$descr{spec}{(\w+)}{handler}}/&{\$\$descr{spec}{$1}}/g;
 _emit_runtime_ctx_parser_source_line($runtime_ctx, "\n $label => sub {\n$external_handler\n },\n");

 $info{handler} = _build_runtime_handler(
  label => $label,
  handler => $handler,
  rule_meta => $rule_meta,
  runtime_ctx => $runtime_ctx,
 );
 $info{gdata} = [@GDATA];
 $info{meta} = $rule_meta;

 if (_trace_should_dump(DUMP_HIGH)) {
  _trace_log_dump("\n=== RULE INFO DUMP for $label ===\n");
  _trace_log_dump(_dump_value(\%info));
  _trace_log_dump("=== END RULE INFO DUMP for $label ===\n");
  _trace_log_dump("=== HANDLER DUMP for $label ===\n");
 _trace_log_dump("{\n$handler\n}\n");
 _trace_log_dump("=== END HANDLER DUMP for $label ===\n");
 }
 if (defined $rule_ir->{top_rule}) {
  _set_runtime_ctx_top_rule($runtime_ctx, $rule_ir->{top_rule});
 }
 _trace_exit($trace_scope, { status => 'ok', label => $label, handler_variant => $rule_meta->{selected_handler_variant} }, DUMP_HIGH);

 return ($label, \%info, $rule_ir->{top_rule})
}

1;
