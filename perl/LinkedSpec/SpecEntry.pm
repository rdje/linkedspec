#------------------------------------------------------------------------------
# Package: LinkedSpec::SpecEntry
# Purpose: Compile one parsed rule entry into runtime-ready handler structures
#          and generated handler source.
#------------------------------------------------------------------------------
package LinkedSpec::SpecEntry;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $perl_root = File::Basename::dirname($module_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();
use LinkedSpec::HandlerVariantEmitter ();

our $BACKEND;

# --- forward-progress / consume-before-recurse recursion guard state (ADR 0010,
# TOP-RULE-AS-NORMAL.2). Active (descriptor, rule-label, input-position) frames on the
# current recursion stack. A re-entry whose key is already active means the rule was
# re-entered without consuming any input since its enclosing entry — a non-progressing
# recursive cycle that would otherwise hang — so the guarded handler returns undef to
# terminate that branch. Keys are pushed on entry and popped on exit (balanced; the
# handler invocation is eval-wrapped), so the table is empty between top-level parses.
my %__ls_recursion_active;

use constant {
 DUMP_NONE   => 0,
 DUMP_LOW    => 100,
 DUMP_MEDIUM => 200,
 DUMP_HIGH   => 300,
 DUMP_DEBUG  => 500,
};

sub _trace_enter {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::trace_enter(@args)
 })
}

sub _trace_exit {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::trace_exit(@args)
 })
}

sub _trace_decision {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::trace_decision(@args)
 })
}

sub _trace_log_dump {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::Trace');
  return LinkedSpec::Trace::log_dump(@args)
 })
}

sub _trace_should_dump {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return LinkedSpec::Trace::should_dump(@args)
 })
}

sub _dump_value {
 my ($value) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'Data::Dumper');
  return Data::Dumper::Dumper($value)
 })
}

sub _call_runtime_ctx {
 my ($subname, @args) = @_;
 return LinkedSpec::OwnerDispatch::dispatch_owner_call(__PACKAGE__, 'LinkedSpec::RuntimeContext', $subname, @args)
}

sub _trace_runtime_mark_event {
 my (%args) = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return undef unless exists $INC{'LinkedSpec/Trace.pm'};
  return undef unless LinkedSpec::Trace::should_dump(DUMP_HIGH);
  return LinkedSpec::Trace::trace_mark_event(%args, caller_depth => 3);
 })
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
$$info{marks} = {} unless ref($$info{marks}) eq "HASH";

my @'.$label.';

'.$actual_icode;
}


sub _build_handler_variants {
 my (%args) = @_;
 my $label = $args{label};
 my $node_type = $args{node_type} // '';
 my $acodes_ref = $args{acodes_ref};
 my $bcodes_ref = $args{bcodes_ref};
 my $bcalls_ref = $args{bcalls_ref};

 my $isAND = $node_type =~ /AND/o;
 my $isOR  = $node_type =~ /OR/o;
 my $isREP = $node_type =~ /REP_/o;
 my $isREP_AND = $node_type =~ /REP_AND/o;
 my $has_acodes = ref($acodes_ref) eq 'ARRAY' && @$acodes_ref;
 my $has_bcodes = ref($bcodes_ref) eq 'HASH' && keys %$bcodes_ref && ref($bcalls_ref) eq 'ARRAY' && @$bcalls_ref;
 my $isDEFAULT_BCODE_REP = !$isAND && !$isOR && !$isREP && $has_bcodes;

 # Map caller arg names (actual_*) to HandlerIR field names
 my %ir_args = (
  label      => $label,
  parse_mode => $args{parse_mode} // 'seek',
  preamble   => $args{actual_icode} // '',
  lxcode     => $args{actual_lxcode} // '',
  lscode     => $args{actual_lscode} // '',
  lecode     => $args{actual_lecode} // '',
  ecode      => $args{actual_ecode}  // '',
  excode     => $args{actual_excode} // '',
  itcode     => $args{actual_itcode} // '',
  node_type  => $node_type,
  rep_min    => $args{rep_min},
  rep_max    => $args{rep_max},
 );

 my %handlers;
	 my $backend = $args{backend} // $BACKEND;
	 my $emit_handler = sub {
	  my ($ir) = @_;
	  return undef unless defined $ir;
	  return LinkedSpec::HandlerVariantEmitter::_emit_handler($ir, defined($backend) ? (backend => $backend) : ());
	 };
 my $ir = LinkedSpec::HandlerVariantEmitter::_build_default_handler_variant(
  %ir_args, acodes_ref => $acodes_ref,
 );
 $handlers{_default} = $emit_handler->($ir) if defined $ir;

 if ($isAND && $has_bcodes) {
  my $ir_v = LinkedSpec::HandlerVariantEmitter::_build_and_bcode_variant(
   %ir_args, bcodes_ref => $bcodes_ref, bcalls_ref => $bcalls_ref,
   REs => \@REs,
   defined($and_icode) ? (and_icode => $and_icode) : (),
  );
  $handlers{AND_BCODE} = $emit_handler->($ir_v) if defined $ir_v;
 }
	# AND single-regex handler: build when ICODE, edges, or both present.
	# The and_icode (per-regex I-block, extracted from ACODEs by the caller)
	# runs after the regex match with return->assignment applied.
	my $and_icode_arg = $args{and_icode};
	my $regex_count = $args{regex_count} // 0;
	if ($isAND && $regex_count == 1 && ($has_acodes || defined($and_icode_arg))) {
	 my $ir_v = LinkedSpec::HandlerVariantEmitter::_build_and_single_acode_variant(
	  %ir_args, acodes_ref => $acodes_ref,
	  defined($and_icode_arg) ? (and_icode => $and_icode_arg) : (),
	 );
	 $handlers{AND_SINGLE_ACODE} = $emit_handler->($ir_v) if defined $ir_v;
	}
 # AND multi-regex: sequential matching (only when > 1 regex and > 1 acode)
 if ($isAND && $has_acodes && @$acodes_ref > 1 && ($args{regex_count} // 0) > 1) {
  my $ir_v = LinkedSpec::HandlerVariantEmitter::_build_and_acode_variant(
   %ir_args, acodes_ref => $acodes_ref, acode_count => scalar(@$acodes_ref),
  );
  $handlers{AND_ACODE} = $emit_handler->($ir_v) if defined $ir_v;
 }
 if ($isOR && $has_acodes) {
  my $ir_v = LinkedSpec::HandlerVariantEmitter::_build_or_acode_variant(
   %ir_args, acodes_ref => $acodes_ref,
  );
  $handlers{OR_ACODE} = $emit_handler->($ir_v) if defined $ir_v;
 }
 if ($isOR && $has_bcodes) {
  my $ir_v = LinkedSpec::HandlerVariantEmitter::_build_or_bcode_variant(
   %ir_args, bcodes_ref => $bcodes_ref, bcalls_ref => $bcalls_ref,
  );
  $handlers{OR_BCODE} = $emit_handler->($ir_v) if defined $ir_v;
 }
 if (($isREP || $isDEFAULT_BCODE_REP) && $has_bcodes) {
  my $ir_v = LinkedSpec::HandlerVariantEmitter::_build_rep_bcode_variant(
   %ir_args, bcodes_ref => $bcodes_ref, bcalls_ref => $bcalls_ref,
  );
  $handlers{REP_BCODE} = $emit_handler->($ir_v) if defined $ir_v;
 }
 if ($isREP_AND && $has_bcodes) {
  my $ir_v = LinkedSpec::HandlerVariantEmitter::_build_rep_and_bcode_variant(
   %ir_args, bcodes_ref => $bcodes_ref, bcalls_ref => $bcalls_ref,
  );
  $handlers{REP_AND_BCODE} = $emit_handler->($ir_v) if defined $ir_v;
 }
 if ($isREP && $has_acodes) {
  my $ir_v = LinkedSpec::HandlerVariantEmitter::_build_rep_acode_variant(
   %ir_args, acodes_ref => $acodes_ref,
  );
  $handlers{REP_ACODE} = $emit_handler->($ir_v) if defined $ir_v;
 }
 if ($isREP_AND && $has_acodes) {
  my $ir_v = LinkedSpec::HandlerVariantEmitter::_build_rep_and_acode_variant(
   %ir_args, acodes_ref => $acodes_ref,
  );
  $handlers{REP_AND_ACODE} = $emit_handler->($ir_v) if defined $ir_v;
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
 my $handler_source_label = _call_runtime_ctx(
  'build_rule_meta_handler_source_label',
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
 _trace_decision("rule_handler_compile:$label", 1, "compiled with warnings: $compile_warning", DUMP_NONE)
  if ref($compiled_handler) eq 'CODE' && length($compile_warning);
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
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'runtime_handler',
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
  # --- forward-progress / consume-before-recurse termination guard (ADR 0010,
  # TOP-RULE-AS-NORMAL.2). Cut a non-progressing recursive cycle so recursion
  # into/through the top rule (or any rule) terminates instead of hanging. A rule
  # re-entered at an input position already active on its own recursion stack has
  # consumed no input since that enclosing entry; legitimate consume-before-recurse
  # recursion always advances pos() first, so this never fires for a terminating
  # grammar (proven: phase0 stays 960/960).
  my $progress_pos = (ref($STRING) eq 'SCALAR' || ref($STRING) eq 'REF') ? pos($$STRING) : undef;
  my $progress_key = (ref($descr) eq 'HASH')
   ? ("$descr\0$label\0" . (defined($progress_pos) ? $progress_pos : -1))
   : undef;
  if (defined($progress_key) && $__ls_recursion_active{$progress_key}) {
   _trace_decision("rule_handler_forward_progress:$label", 0,
    "non-progressing recursive re-entry at pos " . (defined($progress_pos) ? $progress_pos : -1) . "; cut to terminate", DUMP_NONE);
   _trace_exit($runtime_scope, { returned_defined => 0, return_ref => '', return_size => undef }, DUMP_HIGH);
   return undef
  }
  $__ls_recursion_active{$progress_key} = 1 if defined($progress_key);

  my $retv = eval { $compiled_handler->($descr, $STRING, $info) };
  my $eval_error = $@;
  delete $__ls_recursion_active{$progress_key} if defined($progress_key);
  if ($eval_error) {
   _call_runtime_ctx(
    'set_runtime_ctx_last_error_for_owner',
    $runtime_ctx,
    'runtime_handler',
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
 local $BACKEND = $deps->{backend};
 my $runtime_ctx = ref($deps->{runtime_ctx}) eq 'HASH' ? $deps->{runtime_ctx} : undef;
 LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, 'LinkedSpec::RuleIR', '_collect_rule_ir');

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

 LinkedSpec::OwnerDispatch::require_pkg_cb(__PACKAGE__, 'LinkedSpec::RuleIR::EmitContext', 'build_rule_ir_emit_context');
 my $emit_ctx = LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context($rule_ir);
 $rule_meta->{action_rewriter} = $emit_ctx->{action_rewriter_meta};
 my $label = $emit_ctx->{label};
 my $node_type = $emit_ctx->{node_type};
 my @REs = @{$emit_ctx->{REs}};
 my @ACODEs = @{$emit_ctx->{ACODEs}};
 my %BCODEs = %{$emit_ctx->{BCODEs}};
 my @BCALLs = @{$emit_ctx->{BCALLs}};
 my @dependency_refs = @{$emit_ctx->{DEPENDENCY_REFS}};
 my %ab_count = %{$emit_ctx->{ab_count}};

 # For AND rules: per-regex I-blocks are routed to and_icode_entries by RuleIR
 # (not acode_entries, to avoid MIXED_ACTIONS with bcode edges).  The emit context
 # rewrites them into a single and_icode string.  The handler places it after regex
 # match with return->assignment + IMATCH bridge.
 my $and_icode = $emit_ctx->{and_icode};

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
   parse_mode     => (defined($deps->{parse_mode}) && length($deps->{parse_mode})) ? $deps->{parse_mode} : 'seek',
   node_type      => $node_type,
   rep_min        => $rule_meta->{rep_min},
   rep_max        => $rule_meta->{rep_max},
   acodes_ref     => \@ACODEs,
   bcodes_ref     => \%BCODEs,
   bcalls_ref     => \@BCALLs,
   ab_count_ref   => \%ab_count,
   dependency_refs => \@dependency_refs,
   regex_count    => $rule_meta->{regex_count},
   and_icode      => $and_icode,
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

 if ($BACKEND && $BACKEND eq 'json') {
  $info{handler_json} = $handler;
 } else {
  my $external_handler = $handler;
  $external_handler =~ s/&{\$\$descr{spec}{(\w+)}{handler}}/&{\$\$descr{spec}{$1}}/g;
  _call_runtime_ctx('emit_runtime_ctx_parser_source_line', $runtime_ctx, "\n $label => sub {\n$external_handler\n },\n");

  $info{handler} = _build_runtime_handler(
   label => $label,
   handler => $handler,
   rule_meta => $rule_meta,
   runtime_ctx => $runtime_ctx,
  );
 }
 $info{dependency_refs} = [@dependency_refs];
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
  _call_runtime_ctx('set_runtime_ctx_top_rule', $runtime_ctx, $rule_ir->{top_rule});
 }
 _trace_exit($trace_scope, { status => 'ok', label => $label, handler_variant => $rule_meta->{selected_handler_variant} }, DUMP_HIGH);

 return ($label, \%info, $rule_ir->{top_rule})
}

1;
