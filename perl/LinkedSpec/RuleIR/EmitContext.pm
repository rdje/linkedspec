package LinkedSpec::RuleIR::EmitContext;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $rule_ir_dir = File::Basename::dirname($module_dir);
 my $linked_spec_dir = File::Basename::dirname($rule_ir_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use constant {
 DUMP_LOW => 100,
};

sub _require_action_rewriter_pkg {
 require LinkedSpec::ActionRewriter;
 return 1
}

sub _require_trace_pkg {
 require LinkedSpec::Trace;
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

sub _trace_log_output {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_trace_pkg();
  return LinkedSpec::Trace::log_output(@args)
 })
}

sub _build_rewrite_diag_acc {
 return {
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
 }
}

sub _trim_action_ir_value {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_action_rewriter_pkg();
  return LinkedSpec::ActionRewriter::_trim_action_ir_value(@args)
 })
}

sub _rewrite_action_code_with_diagnostics {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_action_rewriter_pkg();
  return LinkedSpec::ActionRewriter::_rewrite_action_code_with_diagnostics(@args)
 })
}

sub _accumulate_action_rewrite_diagnostics {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_action_rewriter_pkg();
  return LinkedSpec::ActionRewriter::_accumulate_action_rewrite_diagnostics(@args)
 })
}

sub _build_action_rewrite_rules {
 my @args = @_;
 return _call_preserving_err(sub {
  _require_action_rewriter_pkg();
  return LinkedSpec::ActionRewriter::_build_action_rewrite_rules(@args)
 })
}

sub _normalize_rule_code_chunks {
 my ($label, $chunks, $rewrite_diag_acc, $rewrite_rules) = @_;

 my @normalized;
 foreach my $chunk (@$chunks) {
  my ($rewritten, $diag) = _rewrite_action_code_with_diagnostics($label, $chunk, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag) if $rewrite_diag_acc;
  $rewritten =~ s/\s*;\s*$//o;
  push @normalized, $rewritten;
 }

 return join ";\n", @normalized
}

sub _rewrite_acode_entries {
 my ($label, $acode_entries, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @ACODEs;
 my @GDATA;
 foreach my $acode_entry (@$acode_entries) {
  my ($rewritten_acode, $diag) = _rewrite_action_code_with_diagnostics($label, $acode_entry->{code}, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @ACODEs, $rewritten_acode;
  push @GDATA, {label => $acode_entry->{relabel}, idx => $acode_entry->{reidx}};
 }

 return (\@ACODEs, \@GDATA)
}

sub _rewrite_bcode_entries {
 my ($label, $bcode_entries, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @BCALLs;
 my %BCODEs;
 foreach my $bcode_entry (@$bcode_entries) {
  my ($rewritten_bcode, $diag) = _rewrite_action_code_with_diagnostics($label, $bcode_entry->{code}, $rewrite_rules);
  _accumulate_action_rewrite_diagnostics($rewrite_diag_acc, $diag);
  push @BCALLs, $bcode_entry->{call};
  $BCODEs{$bcode_entry->{call}} = $rewritten_bcode;
 }

 return (\@BCALLs, \%BCODEs)
}

sub _normalize_rule_lifecycle_code {
 my ($label, $code_blocks, $rewrite_diag_acc, $rewrite_rules) = @_;
 return {
  icode  => _normalize_rule_code_chunks($label, $code_blocks->{ICODE},  $rewrite_diag_acc, $rewrite_rules),
  ecode  => _normalize_rule_code_chunks($label, $code_blocks->{ECODE},  $rewrite_diag_acc, $rewrite_rules),
  excode => _normalize_rule_code_chunks($label, $code_blocks->{EXCODE}, $rewrite_diag_acc, $rewrite_rules),
  itcode => _normalize_rule_code_chunks($label, $code_blocks->{ITCODE}, $rewrite_diag_acc, $rewrite_rules),
  lxcode => _normalize_rule_code_chunks($label, $code_blocks->{LXCODE}, $rewrite_diag_acc, $rewrite_rules),
  lscode => _normalize_rule_code_chunks($label, $code_blocks->{LSCODE}, $rewrite_diag_acc, $rewrite_rules),
  lecode => _normalize_rule_code_chunks($label, $code_blocks->{LECODE}, $rewrite_diag_acc, $rewrite_rules),
 }
}

sub _collect_unresolved_helper_statements {
 my ($rewrite_diag_acc) = @_;

 my @unresolved_helper_statements;
 my %seen_unresolved_helper_statement;
 foreach my $event (@{$rewrite_diag_acc->{unresolved_helper_events}}) {
  my $raw_code = _trim_action_ir_value($event->{raw});
  next unless defined($raw_code) && length($raw_code);
  next if $seen_unresolved_helper_statement{$raw_code}++;
  push @unresolved_helper_statements, $raw_code;
 }
 return @unresolved_helper_statements
}

sub _collect_raw_perl_dependency_statements {
 my ($rewrite_diag_acc) = @_;

 my @raw_perl_dependency_statements;
 my %seen_raw_perl_dependency_statement;
 foreach my $event (@{$rewrite_diag_acc->{canonical_action_ir_events}}) {
  next unless ($event->{kind} // '') eq 'RAW_PERL';
  my $raw_code = (ref($event->{args}) eq 'HASH') ? $event->{args}{code} : $event->{raw};
  $raw_code = _trim_action_ir_value($raw_code);
  next unless defined($raw_code) && length($raw_code);
  next if $seen_raw_perl_dependency_statement{$raw_code}++;
  push @raw_perl_dependency_statements, $raw_code;
 }
 return @raw_perl_dependency_statements
}

sub _build_language_agnostic_blocker_statements {
 my ($raw_perl_dependency_statements, $unresolved_helper_statements) = @_;

 my @language_agnostic_action_ir_blocker_statements;
 my %seen_language_agnostic_action_ir_blocker_statement;
 foreach my $statement (@$raw_perl_dependency_statements, @$unresolved_helper_statements) {
  next unless defined($statement) && length($statement);
  next if $seen_language_agnostic_action_ir_blocker_statement{$statement}++;
  push @language_agnostic_action_ir_blocker_statements, $statement;
 }
 return @language_agnostic_action_ir_blocker_statements
}

sub _build_action_rewriter_meta {
 my ($label, $rewrite_rules, $rewrite_diag_acc) = @_;

 my @rewrite_contract_ids = map { $_->{id} } @$rewrite_rules;
 my @unresolved_helper_statements = _collect_unresolved_helper_statements($rewrite_diag_acc);
 my @raw_perl_dependency_statements = _collect_raw_perl_dependency_statements($rewrite_diag_acc);
 my $raw_perl_dependency_count = $rewrite_diag_acc->{canonical_action_ir_fallback_count} || 0;
 my @language_agnostic_action_ir_blocker_statements = _build_language_agnostic_blocker_statements(
  \@raw_perl_dependency_statements,
  \@unresolved_helper_statements,
 );
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
  _trace_log_output(
   DUMP_LOW,
   "Rule '$label': unresolved action helper(s) after rewrite pipeline",
   "helpers=" . join(', ', @{$action_rewriter_meta->{unresolved_helpers}})
  );
 }

 return $action_rewriter_meta
}

#------------------------------------------------------------------------------
# Function: build_rule_ir_emit_context
# Purpose : Build fully-rewritten emit context (ACODE/BCODE/gdata/lifecycle
#           chunks) plus rich action-rewriter diagnostics metadata.
# Args    : ($rule_ir)
# Returns : hashref emit context
#------------------------------------------------------------------------------
sub build_rule_ir_emit_context {
 my ($rule_ir) = @_;
 my $label = $rule_ir->{label};
 my $rewrite_rules = _build_action_rewrite_rules($label);
 my $rewrite_diag_acc = _build_rewrite_diag_acc();

 my ($acodes, $gdata) = _rewrite_acode_entries(
  $label,
  $rule_ir->{acode_entries},
  $rewrite_rules,
  $rewrite_diag_acc,
 );
 my ($bcalls, $bcodes) = _rewrite_bcode_entries(
  $label,
  $rule_ir->{bcode_entries},
  $rewrite_rules,
  $rewrite_diag_acc,
 );
 my $lifecycle_code = _normalize_rule_lifecycle_code(
  $label,
  $rule_ir->{code_blocks},
  $rewrite_diag_acc,
  $rewrite_rules,
 );

 my %ab_count = (
  ACODE => scalar(@{$rule_ir->{acode_entries}}),
  BCODE => scalar(@{$rule_ir->{bcode_entries}}),
 );
 my $action_rewriter_meta = _build_action_rewriter_meta(
  $label,
  $rewrite_rules,
  $rewrite_diag_acc,
 );

 return {
  label     => $label,
  node_type => $rule_ir->{node_type},
  REs       => $rule_ir->{REs},
  ACODEs    => $acodes,
  BCODEs    => $bcodes,
  BCALLs    => $bcalls,
  GDATA     => $gdata,
  ab_count  => \%ab_count,
  icode     => $lifecycle_code->{icode},
  ecode     => $lifecycle_code->{ecode},
  excode    => $lifecycle_code->{excode},
  itcode    => $lifecycle_code->{itcode},
  lxcode    => $lifecycle_code->{lxcode},
  lscode    => $lifecycle_code->{lscode},
  lecode    => $lifecycle_code->{lecode},
  action_rewriter_meta => $action_rewriter_meta,
 }
}

1;
