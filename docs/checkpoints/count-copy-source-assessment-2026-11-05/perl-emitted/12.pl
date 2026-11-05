# LinkedSpec generated parser source.
# contract_id: linkedspec-generated-source-v2
# format_version: 2
# source_identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY
no strict;
no warnings 'void';
use re 'eval';
use LinkedSpec::GeneratedSource ();
use LinkedSpec::Runtime ();
use LinkedSpec::Trace ();
use LinkedSpec::EntryRuleSelection ();
use LinkedSpec::RuntimeDiagnosticOutput ();
use LinkedSpec::RuntimeSemanticObservation ();
use LinkedSpec::Numeric ();
use LinkedSpec::UnicodeCaseMapping ();
use LinkedSpec::RecognitionTransactionRuntime ();
use LinkedSpec::InterMatchGapRuntime ();
use LinkedSpec::ProgressiveSpanDispatchRuntime ();
use LinkedSpec::StagedASTEnrichmentRuntime ();
sub _trace_runtime_mark_event { return LinkedSpec::GeneratedSource::trace_mark_event(@_) }
our $LINKEDSPEC_GENERATED_SOURCE_CONTRACT = 'linkedspec-generated-source-v2';
our $LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2;
our $LINKEDSPEC_GENERATED_SOURCE_IDENTITY = 'count-copy-source-assessment.spec';

my $descr = {
 spec => {

 Value => sub {
my ($descr, $STRING, $info) = @_;
$info = {} unless ref($info) eq "HASH";
require LinkedSpec::SourceLocation;
LinkedSpec::SourceLocation::Runtime::ensure_authority($info, $STRING);
my $IMATCH      = $$info{match};
my @IMATCH_LIST = @{$$info{match_list} // []};
my %IMATCH_HASH = %{$$info{match_hash} // {}};
my $IINDEX      = $$info{index};
# I and blind handlers have no selected local match. Bind their registers here
# so they cannot resolve to package globals outside a matching branch.
my ($LMATCH, $LINDEX, $LSPOS);
my (@LMATCH_LIST, %LMATCH_HASH);
my $IPOS        = LinkedSpec::SourceLocation::Runtime::capture_boundary_write_position(
 $info, $STRING, pos $$STRING, "handler_entry"
);
$$info{marks} = {} unless ref($$info{marks}) eq "HASH";
my $__ls_recognition_invocation = LinkedSpec::RecognitionTransactionRuntime::enter_invocation(
 $descr, $STRING, $info, \$IPOS, "Value"
);


my @Value;

my $items;
my %__ls_binding_presence;
do { $items = []; $__ls_binding_presence{"items"} = 1; scalar($items) };return do { my $__ls_selected_default = do { my $__ls_scalar_source = do { my $__ls_copy_value = do { my $__ls_count = do { do { $items = "text"; $__ls_binding_presence{"items"} = 1; scalar($items) }; do { require LinkedSpec::BindingRuntime; $items = LinkedSpec::BindingRuntime::push_value($items, "items", "a") } }; ref($__ls_count) eq 'ARRAY' ? scalar(@{$__ls_count}) : 0 }; ref($__ls_copy_value) eq 'ARRAY' ? [@{$__ls_copy_value}] : ref($__ls_copy_value) eq 'HASH' ? { %{$__ls_copy_value} } : !ref($__ls_copy_value) ? $__ls_copy_value : do { require JSON::PP; JSON::PP::is_bool($__ls_copy_value) ? $__ls_copy_value : [] } }; $__ls_scalar_source }; do { my $__ls_coalesce = $__ls_selected_default; defined($__ls_coalesce) ? $__ls_coalesce : "masked" } };
 },
 },
 dependency_regex_map => {

 },
 dependency_slot_map => {

 },
 recognition_regex_map => {
 Value => []
 }
};

for my $linkedspec_rule_label (sort keys %{$descr->{spec}}) {
 $descr->{spec}{$linkedspec_rule_label} =
  LinkedSpec::RecognitionTransactionRuntime::guard_rule_handler(
   $linkedspec_rule_label, $descr->{spec}{$linkedspec_rule_label},
  );
}

my $LINKEDSPEC_GENERATED_EXPECTED_PLAN = [
 { label => 'Value', family => 'default' },
];
my $LINKEDSPEC_GENERATED_ACTIVE_PLAN = LinkedSpec::GeneratedSource::clone_plan($LINKEDSPEC_GENERATED_EXPECTED_PLAN);
my $LINKEDSPEC_GENERATED_ENTRY_RULES = [
 { label => 'Value', is_top => 1 },
];
my $LINKEDSPEC_GENERATED_CONFIGURED_ENTRY_RULE = undef;

sub LinkedSpecGeneratedMetadata {
 return {
  contract_id => $LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
  format_version => $LINKEDSPEC_GENERATED_SOURCE_FORMAT,
  source_identity => $LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  plan => LinkedSpec::GeneratedSource::clone_plan($LINKEDSPEC_GENERATED_EXPECTED_PLAN),
  entry_rule_contract => $LinkedSpec::EntryRuleSelection::CONTRACT_ID,
  entry_rules => LinkedSpec::GeneratedSource::clone_entry_rules($LINKEDSPEC_GENERATED_ENTRY_RULES),
 }
}

sub LinkedSpecGeneratedPlan {
 return LinkedSpec::GeneratedSource::clone_plan($LINKEDSPEC_GENERATED_EXPECTED_PLAN)
}

sub ValidateGeneratedPlan {
 my ($plan, $actual_contract) = @_;
 $plan = $LINKEDSPEC_GENERATED_ACTIVE_PLAN unless defined $plan;
 $actual_contract = $LINKEDSPEC_GENERATED_SOURCE_CONTRACT unless defined $actual_contract;
 return LinkedSpec::GeneratedSource::validate_plan(
  expected => $LINKEDSPEC_GENERATED_EXPECTED_PLAN,
  actual => $plan,
  source_identity => $LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  expected_contract => 'linkedspec-generated-source-v2',
  actual_contract => $actual_contract,
 )
}

sub Execute {
 my ($input_ref, $invocation_options) = @_;
 ValidateGeneratedPlan();
 LinkedSpec::Runtime::_prepare_public_input($input_ref);
 my $diagnostic_sink = LinkedSpec::RuntimeDiagnosticOutput::validate_invocation_options(
  $invocation_options,
 );
 my $semantic_observation_sink = LinkedSpec::RuntimeSemanticObservation::validate_invocation_options(
  $invocation_options,
 );
 my $progressive_dispatch_state = LinkedSpec::ProgressiveSpanDispatchRuntime::begin_invocation(
  $input_ref,
  $invocation_options,
 );
 my $staged_enrichment_state = LinkedSpec::StagedASTEnrichmentRuntime::begin_invocation(
  $input_ref,
  $invocation_options,
 );
 my $explicit_entry_rule = $LINKEDSPEC_GENERATED_CONFIGURED_ENTRY_RULE;
 if (ref($invocation_options) eq 'HASH'
  && defined($invocation_options->{top_rule})
  && length($invocation_options->{top_rule})) {
  $explicit_entry_rule = $invocation_options->{top_rule};
 }
 my $entry_selection = LinkedSpec::EntryRuleSelection::select_entry_rule(
  $LINKEDSPEC_GENERATED_ENTRY_RULES,
  $explicit_entry_rule,
 );
 unless ($entry_selection->{ok}) {
  my $entry_rule = $entry_selection->{entry_rule};
  LinkedSpec::GeneratedSource::trace_role(
   role => 'generated_entry_selection',
   source_identity => $LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
   rule_label => defined($entry_rule) ? $entry_rule : '',
   status => 'error',
  );
  die LinkedSpec::GeneratedSource::new_error(
   stage => $entry_selection->{stage},
   code => $entry_selection->{code},
   summary => 'Generated parser entry-rule selection failed',
   source_identity => $LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
   defined($entry_rule) ? (entry_rule => $entry_rule, rule_label => $entry_rule) : (),
   detail => defined($entry_rule)
    ? "No declared rule matches explicit entry selector '$entry_rule'"
    : 'Generated parser source has no declared entry rule',
  )
 }
 my $entry_rule = $entry_selection->{entry_rule};
 my $entry_family = LinkedSpec::GeneratedSource::family_for_rule(
  $LINKEDSPEC_GENERATED_EXPECTED_PLAN,
  $entry_rule,
 );
 my $sink_slot = LinkedSpec::RuntimeDiagnosticOutput::sink_slot_name();
 my $control_error_slot = LinkedSpec::RuntimeDiagnosticOutput::control_error_slot_name();
 my $semantic_sink_slot = LinkedSpec::RuntimeSemanticObservation::sink_slot_name();
 my $semantic_control_error_slot = LinkedSpec::RuntimeSemanticObservation::control_error_slot_name();
 my $progressive_dispatch_slot = LinkedSpec::ProgressiveSpanDispatchRuntime::descriptor_slot_name();
 local $descr->{$sink_slot} = $diagnostic_sink;
 local $descr->{$control_error_slot} = undef;
 local $descr->{$semantic_sink_slot} = $semantic_observation_sink;
 local $descr->{$semantic_control_error_slot} = undef;
 local $descr->{$progressive_dispatch_slot} = $progressive_dispatch_state;
 my $semantic_input_identity = defined($semantic_observation_sink)
  ? LinkedSpec::RuntimeSemanticObservation::input_identity($input_ref)
  : undef;
 LinkedSpec::GeneratedSource::trace_role(
  role => 'generated_entry_selection',
  source_identity => $LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  rule_label => $entry_rule,
  handler_family => $entry_family,
  selection_basis => $entry_selection->{basis},
  status => 'ok',
 );
 LinkedSpec::GeneratedSource::trace_role(
  role => 'generated_rule_enter',
  source_identity => $LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  rule_label => $entry_rule,
  handler_family => $entry_family,
 );
 LinkedSpec::GeneratedSource::trace_role(
  role => 'generated_family_decision',
  source_identity => $LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  rule_label => $entry_rule,
  handler_family => $entry_family,
 );
 my ($result, $execution_error);
 my $ok = eval {
  $result = &{$descr->{spec}{$entry_rule}}($descr, $input_ref);
  $result = LinkedSpec::StagedASTEnrichmentRuntime::complete_invocation(
   $staged_enrichment_state,
   $descr,
   $input_ref,
   $result,
  );
  1
 };
 $execution_error = $@;
 LinkedSpec::GeneratedSource::trace_role(
  role => 'generated_rule_exit',
  source_identity => $LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  rule_label => $entry_rule,
  handler_family => $entry_family,
  status => $ok ? 'ok' : 'error',
 );
 die $execution_error
  if !$ok && (
   LinkedSpec::RuntimeDiagnosticOutput::is_marked_control_error(
    $descr,
    $execution_error,
   )
   || LinkedSpec::RuntimeSemanticObservation::is_marked_control_error(
    $descr,
    $execution_error,
   )
  );
 die $execution_error
  if !$ok && (
   LinkedSpec::RecognitionTransactionRuntime::is_error($execution_error)
   || LinkedSpec::RecognitionTransactionRuntime::is_recursive_observation_error($execution_error)
   || LinkedSpec::InterMatchGapRuntime::is_error($execution_error)
   || LinkedSpec::ProgressiveSpanDispatchRuntime::is_error($execution_error)
   || LinkedSpec::StagedASTEnrichmentRuntime::is_error($execution_error)
  );
 die LinkedSpec::GeneratedSource::new_error(
  stage => 'execute_generated',
  code => 'generated_execution_failed',
  summary => 'Generated parser execution failed',
  source_identity => $LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
  rule_label => $entry_rule,
  handler_family => $entry_family,
  detail => $execution_error,
 ) unless $ok;
 LinkedSpec::RuntimeSemanticObservation::emit_rule_result(
  $descr,
  rule_label => $entry_rule,
  position => pos($$input_ref),
  input_identity => $semantic_input_identity,
 );
 return $result
}

sub ExecuteWithTrace {
 my ($input_ref, $trace_config, $invocation_options) = @_;
 require LinkedSpec::Trace;
 LinkedSpec::Trace::configure_trace(%$trace_config) if ref($trace_config) eq 'HASH';
 return Execute($input_ref, $invocation_options)
}

sub Get { return Execute(@_) }
