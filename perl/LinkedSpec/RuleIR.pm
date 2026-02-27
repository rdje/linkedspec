package LinkedSpec::RuleIR;

use 5.010;
use Data::Dumper;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::Trace ();

use constant {
 DUMP_NONE   => LinkedSpec::Trace::DUMP_NONE(),
 DUMP_LOW    => LinkedSpec::Trace::DUMP_LOW(),
 DUMP_MEDIUM => LinkedSpec::Trace::DUMP_MEDIUM(),
 DUMP_HIGH   => LinkedSpec::Trace::DUMP_HIGH(),
 DUMP_DEBUG  => LinkedSpec::Trace::DUMP_DEBUG(),
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

 if (LinkedSpec::Trace::should_dump(DUMP_DEBUG)) {
  LinkedSpec::Trace::log_output(DUMP_DEBUG, "(LinkedSpec.pm::_build_rule_execution_meta) Rule meta", Dumper($meta));
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
  LinkedSpec::Trace::trace_decision(
   "_validate_rule_ir_or_exit:$rule_ir->{label}",
   0,
   "mixed action mode detected (acode=$rule_meta->{acode_count}, bcode=$rule_meta->{bcode_count})",
   DUMP_HIGH
  );
  my $label = $rule_ir->{label};
  my $error_msg = "Rule '$label': Cannot mix ACTION (->) and BLIND CALL (=>) code blocks";
  my $context = "ACTION blocks: ".($rule_meta->{acode_count} // 0)." found, BLIND CALL blocks: ".($rule_meta->{bcode_count} // 0)." found";
  LinkedSpec::Trace::log_output(DUMP_NONE, $error_msg, $context);
  print "  Solution: Use either ACTION blocks OR BLIND CALL blocks, not both\n";
  print "  Example: Use '-> rule_name { code }' OR '=> function_name { code }'\n";
  return 0
 }
 LinkedSpec::Trace::trace_decision(
  "_validate_rule_ir_or_exit:$rule_ir->{label}",
  1,
  "rule action mode '$rule_meta->{action_mode}' is valid",
  DUMP_DEBUG
 );

 return 1
}

sub _normalize_rule_code_chunks {
 my ($label, $chunks, $rewrite_diag_acc, $rewrite_rules) = @_;

 my @normalized;
 foreach my $chunk (@$chunks) {
  my ($rewritten, $diag) = LinkedSpec::_rewrite_action_code_with_diagnostics($label, $chunk, $rewrite_rules);
  LinkedSpec::_accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag) if $rewrite_diag_acc;
  $rewritten =~ s/\s*;\s*$//o;
  push @normalized, $rewritten;
 }

 return join ";\n", @normalized
}

sub _build_rule_ir_emit_context {
 my ($rule_ir) = @_;
 my $label = $rule_ir->{label};
 my $rewrite_rules = LinkedSpec::_build_action_rewrite_rules($label);
 my $rewrite_diag_acc = {
  unresolved_helper_hits  => {},
  unresolved_helper_count => 0,
  unresolved_helper_events => [],
  helper_action_ir_hits   => {},
  helper_action_ir_count  => 0,
  helper_action_ir_events => [],
  canonical_action_ir_hits   => {},
  canonical_action_ir_count  => 0,
  canonical_action_ir_events => [],
  canonical_action_ir_fallback_count => 0,
 };

 my @ACODEs;
 my @GDATA;
 foreach my $acode_entry (@{$rule_ir->{acode_entries}}) {
  my ($rewritten_acode, $diag) = LinkedSpec::_rewrite_action_code_with_diagnostics($label, $acode_entry->{code}, $rewrite_rules);
  LinkedSpec::_accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @ACODEs, $rewritten_acode;
  push @GDATA, {label => $acode_entry->{relabel}, idx => $acode_entry->{reidx}};
 }

 my @BCALLs;
 my %BCODEs;
 foreach my $bcode_entry (@{$rule_ir->{bcode_entries}}) {
  my ($rewritten_bcode, $diag) = LinkedSpec::_rewrite_action_code_with_diagnostics($label, $bcode_entry->{code}, $rewrite_rules);
  LinkedSpec::_accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @BCALLs, $bcode_entry->{call};
  $BCODEs{$bcode_entry->{call}} = $rewritten_bcode;
 }

 my %ab_count = (
  ACODE => scalar(@{$rule_ir->{acode_entries}}),
  BCODE => scalar(@{$rule_ir->{bcode_entries}}),
 );

 my $icode  = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{ICODE},  $rewrite_diag_acc, $rewrite_rules);
 my $ecode  = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{ECODE},  $rewrite_diag_acc, $rewrite_rules);
 my $excode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{EXCODE}, $rewrite_diag_acc, $rewrite_rules);
 my $itcode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{ITCODE}, $rewrite_diag_acc, $rewrite_rules);
 my $lxcode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{LXCODE}, $rewrite_diag_acc, $rewrite_rules);
 my $lscode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{LSCODE}, $rewrite_diag_acc, $rewrite_rules);
 my $lecode = _normalize_rule_code_chunks($label, $rule_ir->{code_blocks}{LECODE}, $rewrite_diag_acc, $rewrite_rules);

 my @rewrite_contract_ids = map { $_->{id} } @$rewrite_rules;
 my @unresolved_helper_statements;
 my %seen_unresolved_helper_statement;
 foreach my $event (@{$rewrite_diag_acc->{unresolved_helper_events}}) {
  my $raw_code = LinkedSpec::_trim_action_ir_value($event->{raw});
  next unless defined($raw_code) && length($raw_code);
  next if $seen_unresolved_helper_statement{$raw_code}++;
  push @unresolved_helper_statements, $raw_code;
 }
 my @raw_perl_dependency_statements;
 my %seen_raw_perl_dependency_statement;
 foreach my $event (@{$rewrite_diag_acc->{canonical_action_ir_events}}) {
  next unless ($event->{kind} // '') eq 'RAW_PERL';
  my $raw_code = (ref($event->{args}) eq 'HASH') ? $event->{args}{code} : $event->{raw};
  $raw_code = LinkedSpec::_trim_action_ir_value($raw_code);
  next unless defined($raw_code) && length($raw_code);
  next if $seen_raw_perl_dependency_statement{$raw_code}++;
  push @raw_perl_dependency_statements, $raw_code;
 }
 my $raw_perl_dependency_count = $rewrite_diag_acc->{canonical_action_ir_fallback_count} || 0;
 my @language_agnostic_action_ir_blocker_statements;
 my %seen_language_agnostic_action_ir_blocker_statement;
 foreach my $statement (@raw_perl_dependency_statements, @unresolved_helper_statements) {
  next unless defined($statement) && length($statement);
  next if $seen_language_agnostic_action_ir_blocker_statement{$statement}++;
  push @language_agnostic_action_ir_blocker_statements, $statement;
 }
 my $language_agnostic_action_ir_blocker_statement_count = scalar @language_agnostic_action_ir_blocker_statements;
 my $language_agnostic_action_ir_ready = (
  $raw_perl_dependency_count == 0 &&
  ($rewrite_diag_acc->{unresolved_helper_count} || 0) == 0
 ) ? 1 : 0;

 my $action_rewriter_meta = {
  unresolved_helper_count => $rewrite_diag_acc->{unresolved_helper_count},
  unresolved_helpers      => [sort keys %{$rewrite_diag_acc->{unresolved_helper_hits}}],
  unresolved_helper_hits  => {%{$rewrite_diag_acc->{unresolved_helper_hits}}},
  unresolved_helper_events => [@{$rewrite_diag_acc->{unresolved_helper_events}}],
  unresolved_helper_statements => \@unresolved_helper_statements,
  helper_action_ir_count  => $rewrite_diag_acc->{helper_action_ir_count},
  helper_action_ir_nodes  => [sort keys %{$rewrite_diag_acc->{helper_action_ir_hits}}],
  helper_action_ir_hits   => {%{$rewrite_diag_acc->{helper_action_ir_hits}}},
  helper_action_ir_events => [@{$rewrite_diag_acc->{helper_action_ir_events}}],
  canonical_action_ir_count => $rewrite_diag_acc->{canonical_action_ir_count},
  canonical_action_ir_nodes => [sort keys %{$rewrite_diag_acc->{canonical_action_ir_hits}}],
  canonical_action_ir_hits  => {%{$rewrite_diag_acc->{canonical_action_ir_hits}}},
  canonical_action_ir_events => [@{$rewrite_diag_acc->{canonical_action_ir_events}}],
  canonical_action_ir_fallback_count => $rewrite_diag_acc->{canonical_action_ir_fallback_count},
  raw_perl_dependency_count => $raw_perl_dependency_count,
  raw_perl_dependency_statements => \@raw_perl_dependency_statements,
  language_agnostic_action_ir_blocker_statement_count => $language_agnostic_action_ir_blocker_statement_count,
  language_agnostic_action_ir_blocker_statements => \@language_agnostic_action_ir_blocker_statements,
  language_agnostic_action_ir_ready => $language_agnostic_action_ir_ready,
  rewrite_contract_ids    => \@rewrite_contract_ids,
 };

 if ($action_rewriter_meta->{unresolved_helper_count}) {
  LinkedSpec::Trace::log_output(
   DUMP_LOW,
   "Rule '$label': unresolved action helper(s) after rewrite pipeline",
   "helpers=" . join(', ', @{$action_rewriter_meta->{unresolved_helpers}})
  );
 }

 return {
  label     => $label,
  node_type => $rule_ir->{node_type},
  REs       => $rule_ir->{REs},
  ACODEs    => \@ACODEs,
  BCODEs    => \%BCODEs,
  BCALLs    => \@BCALLs,
  GDATA     => \@GDATA,
  ab_count  => \%ab_count,
  icode     => $icode,
  ecode     => $ecode,
  excode    => $excode,
  itcode    => $itcode,
  lxcode    => $lxcode,
  lscode    => $lscode,
  lecode    => $lecode,
  action_rewriter_meta => $action_rewriter_meta,
 }
}

1;
