package LinkedSpec::SpecEntry;

use 5.010;
use Data::Dumper;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::Trace ();
use LinkedSpec::RuleIR ();

use constant {
 DUMP_NONE   => LinkedSpec::Trace::DUMP_NONE(),
 DUMP_LOW    => LinkedSpec::Trace::DUMP_LOW(),
 DUMP_MEDIUM => LinkedSpec::Trace::DUMP_MEDIUM(),
 DUMP_HIGH   => LinkedSpec::Trace::DUMP_HIGH(),
 DUMP_DEBUG  => LinkedSpec::Trace::DUMP_DEBUG(),
};

my $rep_nodes_minmax = {
 REP_PLUS=> [1, 10**9],
 REP_STAR=> [0, 10**9],
 REP_OPT => [0, 1]
};

sub _emit_parser_source_line {
 my ($deps, $chunk) = @_;
 my $emit = (ref($deps) eq 'HASH') ? $deps->{emit_parser_source_line} : undef;
 return unless ref($emit) eq 'CODE';
 $emit->($chunk);
 return
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
  my $minfo; eval q/$minfo = LinkedRE::or($STRING, $$descr{gdata}{'.$label.'})/;
  if($@) {
   print "\n(LinkedSpec) -E- Rule \''.$label.'\': Error during handler code generation\n";
   print "  Error: $@\n";
   print "  This usually indicates a syntax error in the generated Perl code\n";
   print "  Check your .spec file for malformed code blocks or invalid syntax\n";
   exit 1
  }

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

sub _build_and_bcode_variant {
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

sub _build_and_acode_variant {
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

sub _build_rep_bcode_variant {
 my (%args) = @_;
 my $bcodes = $args{bcodes} // '';
 return undef unless length $bcodes;
 my $label = $args{label};
 my $node_type = $args{node_type};
 return undef unless defined($node_type) && exists $rep_nodes_minmax->{$node_type};

 my $actual_lxcode = $args{actual_lxcode} // '';
 my $actual_lecode = $args{actual_lecode} // '';
 my $actual_itcode = $args{actual_itcode} // '';
 my $actual_excode = $args{actual_excode} // '';
 my $actual_ecode = $args{actual_ecode} // '';
 my $bcalls = $args{bcalls} // '';
 my ($min, $max) = @{$rep_nodes_minmax->{$node_type}};
 my $and_code = '

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

  return \@'.$label.'_collect
 ';

 return '
   my $min='.$min.';
   my $max='.$max.';
   my $'.$label.';
   my @'.$label.'_collect;

   my $ccount = 0;
   my $and_code = sub {eval \''.$and_code.'\'};

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
 my $node_type = $args{node_type};
 return undef unless defined($node_type) && exists $rep_nodes_minmax->{$node_type};

 my $actual_lscode = $args{actual_lscode} // '';
 my $actual_lecode = $args{actual_lecode} // '';
 my $actual_itcode = $args{actual_itcode} // '';
 my $actual_excode = $args{actual_excode} // '';
 my $actual_ecode = $args{actual_ecode} // '';
 my ($min, $max) = @{$rep_nodes_minmax->{$node_type}};

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
 if ($isREP && length($bcodes)) {
  my $v = _build_rep_bcode_variant(
   %args,
   label     => $label,
   node_type => $node_type,
   bcodes    => $bcodes,
   bcalls    => $bcalls,
  );
  $handlers{REP_BCODE} = $v if defined $v;
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

 return sub {
  my ($descr, $STRING, $info) = @_;
  my $runtime_scope = LinkedSpec::Trace::trace_enter(
   "LinkedSpec::rule_handler:$label",
   {
    handler_variant => $rule_meta->{selected_handler_variant},
    index => (ref($info) eq 'HASH') ? $info->{index} : undef,
    match => (ref($info) eq 'HASH') ? $info->{match} : undef,
   },
   DUMP_HIGH
  );
  my $retv = eval $handler;
  my $eval_error = $@;
  if ($eval_error) {
   LinkedSpec::Trace::trace_decision("rule_handler_eval:$label", 0, $eval_error, DUMP_NONE);
  } else {
   LinkedSpec::Trace::trace_decision("rule_handler_eval:$label", 1, 'handler eval completed', DUMP_DEBUG);
  }
  LinkedSpec::Trace::trace_exit(
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

 my $trace_scope = LinkedSpec::Trace::trace_enter('LinkedSpec::spec_entry', {
  token_count => (ref($einfo) eq 'ARRAY') ? scalar(@$einfo) : undef,
 }, DUMP_HIGH);

 my %info;
 my %handlers;

 if (LinkedSpec::Trace::should_dump(DUMP_HIGH)) {
  LinkedSpec::Trace::log_dump("=== SPEC ENTRY DUMP ===\n");
  LinkedSpec::Trace::log_dump(Dumper($einfo));
  LinkedSpec::Trace::log_dump("=== END SPEC ENTRY DUMP ===\n");
 }

 my $rule_ir = LinkedSpec::RuleIR::_collect_rule_ir($einfo);
 my $rule_meta = LinkedSpec::RuleIR::_plan_rule_ir_meta($rule_ir);
 unless (LinkedSpec::RuleIR::_validate_rule_ir_or_exit($rule_ir, $rule_meta)) {
  LinkedSpec::Trace::trace_exit($trace_scope, { status => 'error', stage => 'validate_rule_ir', label => $rule_ir->{label} }, DUMP_HIGH);
  return
 }

 my $emit_ctx = LinkedSpec::RuleIR::_build_rule_ir_emit_context($rule_ir);
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
 _emit_parser_source_line($deps, "\n $label => sub {\n$external_handler\n },\n");

 $info{handler} = _build_runtime_handler(
  label => $label,
  handler => $handler,
  rule_meta => $rule_meta,
 );
 $info{gdata} = [@GDATA];
 $info{meta} = $rule_meta;

 if (LinkedSpec::Trace::should_dump(DUMP_HIGH)) {
  LinkedSpec::Trace::log_dump("\n=== RULE INFO DUMP for $label ===\n");
  LinkedSpec::Trace::log_dump(Dumper(\%info));
  LinkedSpec::Trace::log_dump("=== END RULE INFO DUMP for $label ===\n");
  LinkedSpec::Trace::log_dump("=== HANDLER DUMP for $label ===\n");
  LinkedSpec::Trace::log_dump("{\n$handler\n}\n");
  LinkedSpec::Trace::log_dump("=== END HANDLER DUMP for $label ===\n");
 }
 LinkedSpec::Trace::trace_exit($trace_scope, { status => 'ok', label => $label, handler_variant => $rule_meta->{selected_handler_variant} }, DUMP_HIGH);

 return ($label, \%info, $rule_ir->{top_rule})
}

1;
