#------------------------------------------------------------------------------
# Package: LinkedSpec::StagedASTEnrichment
# Purpose: Apply one complete depth of dormant general staged-AST parse jobs
#          through caller-prepared immutable parser authority. Recursive queue
#          ownership deliberately remains outside this module's current API.
#------------------------------------------------------------------------------
package LinkedSpec::StagedASTEnrichment;

use 5.010;
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256_hex);
use Hash::Util ();
use JSON::PP ();
use Scalar::Util qw(blessed refaddr);
use LinkedSpec::StagedParseJob ();

my %STATE_BY_ADDRESS;

my $PARSER_ID_RE = qr/\A[a-z][a-z0-9]*(?:[._:\/-][a-z0-9]+)*\z/o;
my $TOP_RULE_RE = qr/\A[A-Za-z_][A-Za-z0-9_]*\z/o;
my $DIGEST_RE = qr/\Asha256:[0-9a-f]{64}\z/o;
my @SOURCE_DETAILS = qw(none identity span text);
my %SOURCE_DETAIL_RANK = map { ($SOURCE_DETAILS[$_] => $_) } 0 .. $#SOURCE_DETAILS;
my @VERSION_FIELDS = qw(
 spec_language_version helper_contract_version staged_contract_version
);
my @NUMERIC_CEILINGS = qw(max_steps max_result_nodes max_diagnostic_bytes);
my %LIVE_RESULT_KEY = map { ($_ => 1) } qw(
 parser parser_handle registry source_authority frame transaction cancellation
 callback host path live_handle
);
my $JSON = JSON::PP->new->canonical(1)->allow_nonref(1);
my $JSON_UTF8 = JSON::PP->new->canonical(1)->allow_nonref(1)->utf8(1);

sub new {
 my ($class, %args) = @_;
 my $snapshot = $args{snapshot};
 _internal_error('snapshot must be a hash reference') unless ref($snapshot) eq 'HASH';
 _internal_error('snapshot fields drifted') unless _has_exact_keys($snapshot, [qw(
  immutable prepared_before_authored_execution filesystem_access_during_dispatch
  aliases declaring_relative search_roots providers entries
 )]);
 _internal_error('snapshot must be immutable and prepared before authored execution')
  unless $snapshot->{immutable} && $snapshot->{prepared_before_authored_execution};
 _internal_error('dispatch-time filesystem access must be disabled')
  if $snapshot->{filesystem_access_during_dispatch};

 my %entry_by_id;
 my @entries;
 _internal_error('snapshot entries must be a nonempty array reference')
  unless ref($snapshot->{entries}) eq 'ARRAY' && @{$snapshot->{entries}};
 for my $entry (@{$snapshot->{entries}}) {
  my $owned = _validated_entry($entry);
  my $identity = $owned->{resolved_spec_id};
  _internal_error("duplicate resolved parser identity '$identity'")
   if exists $entry_by_id{$identity};
  Hash::Util::lock_hashref_recurse($owned);
  $entry_by_id{$identity} = $owned;
  push @entries, $owned;
 }

 my $aliases = _validated_direct_candidates(
  $snapshot->{aliases},
  'aliases',
  \%entry_by_id,
 );
 my $relative = _validated_direct_candidates(
  $snapshot->{declaring_relative},
  'declaring_relative',
  \%entry_by_id,
 );
 my $roots = _validated_ordered_candidates(
  $snapshot->{search_roots},
  'search_roots',
  'root_id',
  \%entry_by_id,
 );
 my $providers = _validated_ordered_candidates(
  $snapshot->{providers},
  'providers',
  'provider_id',
  \%entry_by_id,
 );

 my $logical_snapshot = {
  immutable => JSON::PP::true,
  prepared_before_authored_execution => JSON::PP::true,
  filesystem_access_during_dispatch => JSON::PP::false,
  aliases => $aliases,
  declaring_relative => $relative,
  search_roots => $roots,
  providers => $providers,
  entries => [map {
   my %logical = %$_;
   $logical{compiled_authority} = 'opaque:compiled:callback';
   \%logical
  } @entries],
 };
 my $snapshot_id = 'registry-snapshot:' . _digest($logical_snapshot);

 my $token = 0;
 my $self = bless \$token, $class;
 $STATE_BY_ADDRESS{refaddr($self)} = {
  entries => \%entry_by_id,
  aliases => $aliases,
  declaring_relative => $relative,
  search_roots => $roots,
  providers => $providers,
  snapshot_id => $snapshot_id,
  cache => {},
  cache_hits => 0,
  cache_misses => 0,
 };
 return $self
}

sub enrich_ast {
 my ($self, $ast, %args) = @_;
 my $state = _state($self);
 my $declaring_spec_id = _required_scalar(
  $args{declaring_spec_id},
  'declaring_spec_id',
 );
 _internal_error("invalid declaring_spec_id '$declaring_spec_id'")
  unless $declaring_spec_id =~ $PARSER_ID_RE
   && index($declaring_spec_id, '..') < 0
   && substr($declaring_spec_id, 0, 1) ne '/';
 my $caller_capabilities = _normalized_string_set(
  $args{caller_capabilities},
  'caller_capabilities',
 );
 my $caller_policy_modes = _normalized_string_set(
  $args{caller_policy_modes},
  'caller_policy_modes',
 );
 my $caller_ceilings = _validated_ceilings(
  $args{caller_ceilings},
  'caller_ceilings',
 );
 my $required_versions = _validated_versions(
  $args{required_versions},
  'required_versions',
 );
 my $required_source_detail = _required_scalar(
  $args{required_source_detail},
  'required_source_detail',
 );
 _internal_error("invalid required_source_detail '$required_source_detail'")
  unless exists $SOURCE_DETAIL_RANK{$required_source_detail};

 my $working = _clone_ast($ast);
 my @discovered;
 _discover_current_depth($working, [], \@discovered);
 my @plans;
 for my $row (@discovered) {
  my $sidecar = LinkedSpec::StagedParseJob::sidecar_record($row->{marker});
  _internal_error('only declared staged_parse_job_v2 markers may be enriched')
   unless ($sidecar->{kind} // '') eq 'staged_parse_job_v2'
    && ($sidecar->{version} // 0) == 2
    && ($sidecar->{state} // '') eq 'declared';
  my $provisional_top = exists($sidecar->{top_rule})
   ? $sidecar->{top_rule}
   : '<unresolved-default>';
  my $provisional_job_id = _job_identity({
   declaring_spec_id => $declaring_spec_id,
   parent_ast_path => $row->{path},
   node_kind => $sidecar->{node_kind},
   payload_kind => $sidecar->{payload_kind},
   parser_spec_id => $sidecar->{parser_spec_id},
   top_rule => $provisional_top,
   provenance => $sidecar->{provenance},
  });
  my $resolved_spec_id = $self->resolve_pre_registered(
   declaring_spec_id => $declaring_spec_id,
   parser_spec_id => $sidecar->{parser_spec_id},
   job_id => $provisional_job_id,
  );
  my $entry = $state->{entries}{$resolved_spec_id};
  my $top_rule = exists($sidecar->{top_rule})
   ? $sidecar->{top_rule}
   : $entry->{default_top_rule};
  my $job_id = _job_identity({
   declaring_spec_id => $declaring_spec_id,
   parent_ast_path => $row->{path},
   node_kind => $sidecar->{node_kind},
   payload_kind => $sidecar->{payload_kind},
   parser_spec_id => $sidecar->{parser_spec_id},
   top_rule => $top_rule,
   provenance => $sidecar->{provenance},
  });
  my $effective = $self->effective_authority(
   entry_id => $resolved_spec_id,
   job_id => $job_id,
   top_rule => $top_rule,
   caller_capabilities => $caller_capabilities,
   required_capabilities => $sidecar->{required_capabilities},
   caller_policy_modes => $caller_policy_modes,
   required_policy_modes => [
    $sidecar->{result_policy},
    $sidecar->{failure_policy},
   ],
   caller_ceilings => $caller_ceilings,
   required_source_detail => $required_source_detail,
   required_versions => $required_versions,
  );
  my $cache_fields = {
   normalized_spec_id => $resolved_spec_id,
   content_digest => $entry->{content_digest},
   import_graph_fingerprint => $entry->{import_graph_fingerprint},
   top_rule => $top_rule,
   spec_language_version => $entry->{spec_language_version},
   helper_contract_version => $entry->{helper_contract_version},
   staged_contract_version => $entry->{staged_contract_version},
   backend_capabilities => $effective->{capabilities},
  };
  my $cache_key = cache_identity(__PACKAGE__, $cache_fields);
  my $scheduler_sidecar = {
   %$sidecar,
   state => 'prepared',
   declaring_spec_id => $declaring_spec_id,
   parent_ast_path => _clone_plain($row->{path}),
   resolved_spec_id => $resolved_spec_id,
   top_rule => $top_rule,
   job_id => $job_id,
   cache_key => $cache_key,
   effective => _clone_plain($effective),
  };
  push @plans, {
   marker => $row->{marker},
   path => _clone_plain($row->{path}),
   sidecar => $scheduler_sidecar,
   entry => $entry,
   cache_fields => $cache_fields,
   provenance_order => _provenance_order($sidecar->{provenance}),
  };
 }

 @plans = sort { _compare_plans($a, $b) } @plans;
 for my $plan (@plans) {
  _validate_stitch_target($working, $plan)
 }

 my @diagnostics;
 for my $plan (@plans) {
  _validate_stitch_target($working, $plan);
  my $sidecar = $plan->{sidecar};
  my $cached = _cached_execution_plan($state, $plan);
  my $request = {
   stage_depth => 1,
   stage_chain => [],
   job_id => $sidecar->{job_id},
   parent_ast_path => _clone_plain($sidecar->{parent_ast_path}),
   node_kind => $sidecar->{node_kind},
   payload_kind => $sidecar->{payload_kind},
   parser_spec_id => $sidecar->{parser_spec_id},
   resolved_spec_id => $sidecar->{resolved_spec_id},
   top_rule => $sidecar->{top_rule},
   text => $sidecar->{text},
   source_provenance => _clone_plain($sidecar->{provenance}),
   result_policy => $sidecar->{result_policy},
   failure_policy => $sidecar->{failure_policy},
   effective => _clone_plain($sidecar->{effective}),
   runtime_context => {
    cursor => 0,
    marks => {},
    captures => {},
    variables => {},
   },
  };
  my ($returned, $callback_error);
  {
   local $@;
   my $ok = eval {
    $returned = $cached->{compiled_authority}->($request);
    1
   };
   $callback_error = $@ unless $ok;
  }

  my ($result, $diagnostic);
  if (defined($callback_error) && length("$callback_error")) {
   $diagnostic = _child_failure_diagnostic($sidecar, $callback_error)
  } elsif (!defined($returned)) {
   $diagnostic = _child_failure_diagnostic(
    $sidecar,
    {code => 'staged_child_returned_undefined'},
   )
  } else {
   my ($accepted, $detached, $failure) = _detach_result(
    $returned,
    $sidecar->{effective}{max_result_nodes},
    $sidecar,
   );
   if ($accepted) {
    $result = $detached
   } else {
    $diagnostic = $failure
   }
  }

  if (!defined($diagnostic)) {
   _stitch_value($working, $plan, $result);
   $sidecar->{state} = 'succeeded';
   next
  }

  push @diagnostics, _clone_plain($diagnostic);
  $sidecar->{diagnostic} = _clone_plain($diagnostic);
  if ($sidecar->{failure_policy} eq 'fail') {
   _throw(%$diagnostic)
  } elsif ($sidecar->{failure_policy} eq 'keep_text') {
   _materialize_marker_text($working, $plan);
   $sidecar->{state} = 'failed_keep_text';
  } elsif ($sidecar->{failure_policy} eq 'diagnostic_node') {
   _stitch_value(
    $working,
    $plan,
    {
     kind => 'staged_parse_diagnostic',
     diagnostic => _clone_plain($diagnostic),
    },
   );
   $sidecar->{state} = 'failed_diagnostic_node';
  } else {
   _internal_error('validated failure policy drifted during execution')
  }
 }

 return {
  ast => $working,
  sidecars => [map { _clone_plain($_->{sidecar}) } @plans],
  diagnostics => \@diagnostics,
  cache => $self->cache_stats,
 }
}

sub resolve_pre_registered {
 my ($self, %args) = @_;
 my $state = _state($self);
 my $declaring = _required_scalar($args{declaring_spec_id}, 'declaring_spec_id');
 my $authored = _required_scalar($args{parser_spec_id}, 'parser_spec_id');
 my $job_id = defined($args{job_id}) && !ref($args{job_id})
  ? "$args{job_id}"
  : '<unassigned>';
 unless ($authored =~ $PARSER_ID_RE && index($authored, '..') < 0 && substr($authored, 0, 1) ne '/') {
  _throw(
   code => 'staged_parser_identity_invalid',
   phase => 'resolve',
   origin => 'post_ast',
   parser_spec_id => $authored,
  )
 }

 my @aliases = map { $_->{resolved_spec_id} } grep {
  $_->{declaring_spec_id} eq $declaring && $_->{authored_id} eq $authored
 } @{$state->{aliases}};
 my @relative = map { $_->{resolved_spec_id} } grep {
  $_->{declaring_spec_id} eq $declaring && $_->{authored_id} eq $authored
 } @{$state->{declaring_relative}};
 if (@aliases && @relative) {
  _throw(
   code => 'staged_registry_collision',
   phase => 'resolve',
   job_id => $job_id,
   parser_spec_id => $authored,
   aliases => \@aliases,
   relative_candidates => \@relative,
  )
 }
 if (@aliases > 1 || @relative > 1) {
  my ($priority, $candidates) = @aliases > 1
   ? ('alias', \@aliases)
   : ('declaring_relative', \@relative);
  _throw(
   code => 'staged_registry_ambiguous',
   phase => 'resolve',
   job_id => $job_id,
   parser_spec_id => $authored,
   priority => $priority,
   candidates => $candidates,
  )
 }
 return $aliases[0] if @aliases;
 return $relative[0] if @relative;

 for my $root (@{$state->{search_roots}}) {
  my @candidates = map { $_->{resolved_spec_id} } grep {
   $_->{authored_id} eq $authored
  } @{$root->{candidates}};
  if (@candidates > 1) {
   _throw(
    code => 'staged_registry_ambiguous',
    phase => 'resolve',
    job_id => $job_id,
    parser_spec_id => $authored,
    priority => $root->{root_id},
    candidates => \@candidates,
   )
  }
  return $candidates[0] if @candidates
 }
 for my $provider (@{$state->{providers}}) {
  my @candidates = map { $_->{resolved_spec_id} } grep {
   $_->{authored_id} eq $authored
  } @{$provider->{candidates}};
  if (@candidates > 1) {
   _throw(
    code => 'staged_registry_ambiguous',
    phase => 'resolve',
    job_id => $job_id,
    parser_spec_id => $authored,
    priority => $provider->{provider_id},
    candidates => \@candidates,
   )
  }
  return $candidates[0] if @candidates
 }
 _throw(
  code => 'staged_registry_missing',
  phase => 'resolve',
  job_id => $job_id,
  parser_spec_id => $authored,
  declaring_spec_id => $declaring,
 )
}

sub effective_authority {
 my ($self, %args) = @_;
 my $state = _state($self);
 my $entry_id = _required_scalar($args{entry_id}, 'entry_id');
 my $job_id = defined($args{job_id}) && !ref($args{job_id})
  ? "$args{job_id}"
  : '<unassigned>';
 my $entry = $state->{entries}{$entry_id};
 _throw(
  code => 'staged_registry_missing',
  phase => 'resolve',
  job_id => $job_id,
  parser_spec_id => $entry_id,
  declaring_spec_id => '<prepared-snapshot>',
 ) unless ref($entry) eq 'HASH';

 my $required_versions = _validated_versions(
  $args{required_versions},
  'required_versions',
 );
 for my $name (@VERSION_FIELDS) {
  next if $entry->{$name} eq $required_versions->{$name};
  _throw(
   code => 'staged_version_mismatch',
   phase => 'compile',
   job_id => $job_id,
   resolved_spec_id => $entry_id,
   version_kind => $name,
   required => $required_versions->{$name},
   actual => $entry->{$name},
  )
 }
 my $top_rule = _required_scalar($args{top_rule}, 'top_rule');
 unless (grep { $_ eq $top_rule } @{$entry->{allowed_top_rules}}) {
  _throw(
   code => 'staged_top_rule_forbidden',
   phase => 'compile',
   job_id => $job_id,
   resolved_spec_id => $entry_id,
   top_rule => $top_rule,
  )
 }

 my $caller_capabilities = _normalized_string_set(
  $args{caller_capabilities},
  'caller_capabilities',
 );
 my $required_capabilities = _normalized_string_set(
  $args{required_capabilities},
  'required_capabilities',
 );
 my %entry_capability = map { ($_ => 1) } @{$entry->{capabilities}};
 my @capabilities = grep { $entry_capability{$_} } @$caller_capabilities;
 my %effective_capability = map { ($_ => 1) } @capabilities;
 for my $required (@$required_capabilities) {
  next if $effective_capability{$required};
  _throw(
   code => 'staged_capability_denied',
   phase => 'compile',
   job_id => $job_id,
   resolved_spec_id => $entry_id,
   capability => $required,
  )
 }

 my $caller_modes = _normalized_string_set(
  $args{caller_policy_modes},
  'caller_policy_modes',
 );
 my $required_modes = _normalized_string_set(
  $args{required_policy_modes},
  'required_policy_modes',
 );
 my %entry_mode = map { ($_ => 1) } @{$entry->{policy_modes}};
 my @policy_modes = grep { $entry_mode{$_} } @$caller_modes;
 my %effective_mode = map { ($_ => 1) } @policy_modes;
 for my $required (@$required_modes) {
  next if $effective_mode{$required};
  _throw(
   code => 'staged_policy_denied',
   phase => 'compile',
   job_id => $job_id,
   resolved_spec_id => $entry_id,
   policy => $required,
  )
 }

 my $caller_ceilings = _validated_ceilings(
  $args{caller_ceilings},
  'caller_ceilings',
 );
 my $source_rank = $SOURCE_DETAIL_RANK{$caller_ceilings->{source_detail}}
  < $SOURCE_DETAIL_RANK{$entry->{ceilings}{source_detail}}
  ? $SOURCE_DETAIL_RANK{$caller_ceilings->{source_detail}}
  : $SOURCE_DETAIL_RANK{$entry->{ceilings}{source_detail}};
 my $source_detail = $SOURCE_DETAILS[$source_rank];
 my $required_detail = _required_scalar(
  $args{required_source_detail},
  'required_source_detail',
 );
 _internal_error("invalid required_source_detail '$required_detail'")
  unless exists $SOURCE_DETAIL_RANK{$required_detail};
 if ($SOURCE_DETAIL_RANK{$source_detail} < $SOURCE_DETAIL_RANK{$required_detail}) {
  _throw(
   code => 'staged_source_detail_denied',
   phase => 'compile',
   job_id => $job_id,
   resolved_spec_id => $entry_id,
   required => $required_detail,
   effective => $source_detail,
  )
 }
 my %effective = (
  capabilities => \@capabilities,
  policy_modes => \@policy_modes,
  source_detail => $source_detail,
 );
 for my $name (@NUMERIC_CEILINGS) {
  $effective{$name} = $caller_ceilings->{$name} < $entry->{ceilings}{$name}
   ? $caller_ceilings->{$name}
   : $entry->{ceilings}{$name};
 }
 return \%effective
}

sub job_identity {
 my ($class, $fields) = @_;
 return _job_identity($fields)
}

sub cache_identity {
 my ($class, $fields) = @_;
 _cache_identity_error($fields, '<shape>') unless ref($fields) eq 'HASH';
 _cache_identity_error($fields, '<shape>') unless _has_exact_keys($fields, [qw(
  normalized_spec_id content_digest import_graph_fingerprint top_rule
  spec_language_version helper_contract_version staged_contract_version
  backend_capabilities
 )]);
 my $identity = _diagnostic_scalar($fields->{normalized_spec_id});
 _cache_identity_error($fields, 'normalized_spec_id')
  unless $identity =~ $PARSER_ID_RE
   && index($identity, '..') < 0
   && substr($identity, 0, 1) ne '/';
 for my $name (qw(content_digest import_graph_fingerprint)) {
  _cache_identity_error($fields, $name)
   unless defined($fields->{$name})
    && !ref($fields->{$name})
    && $fields->{$name} =~ $DIGEST_RE;
 }
 _cache_identity_error($fields, 'top_rule')
  unless defined($fields->{top_rule})
   && !ref($fields->{top_rule})
   && $fields->{top_rule} =~ $TOP_RULE_RE;
 _cache_identity_error($fields, 'spec_language_version')
  unless _is_nonnegative_integer($fields->{spec_language_version})
   && $fields->{spec_language_version} > 0;
 _cache_identity_error($fields, 'helper_contract_version')
  unless defined($fields->{helper_contract_version})
   && !ref($fields->{helper_contract_version})
   && length($fields->{helper_contract_version});
 _cache_identity_error($fields, 'staged_contract_version')
  unless _is_nonnegative_integer($fields->{staged_contract_version})
   && $fields->{staged_contract_version} > 0;
 _cache_identity_error($fields, 'backend_capabilities')
  unless ref($fields->{backend_capabilities}) eq 'ARRAY';
 my $normalized = _clone_plain($fields);
 my $capabilities = eval {
  _normalized_string_set(
   $normalized->{backend_capabilities},
   'cache backend_capabilities',
  )
 };
 _cache_identity_error($fields, 'backend_capabilities') if $@;
 $normalized->{backend_capabilities} = $capabilities;
 return _digest($normalized)
}

sub cache_stats {
 my ($self) = @_;
 my $state = _state($self);
 return {
  snapshot_id => $state->{snapshot_id},
  entries => scalar(keys %{$state->{cache}}),
  hits => $state->{cache_hits},
  misses => $state->{cache_misses},
 }
}

sub register {
 my ($self, %args) = @_;
 _state($self);
 _throw(
  code => 'staged_registry_mutation_forbidden',
  phase => 'resolve',
  job_id => '<unassigned>',
  parser_spec_id => _diagnostic_scalar($args{parser_spec_id}),
  operation => 'register',
 )
}

sub load {
 my ($self, %args) = @_;
 _state($self);
 _throw(
  code => 'staged_implicit_load_forbidden',
  phase => 'resolve',
  job_id => '<unassigned>',
  parser_spec_id => _diagnostic_scalar($args{parser_spec_id}),
  operation => 'load',
 )
}

sub is_error {
 my ($value) = @_;
 return blessed($value)
  && $value->isa('LinkedSpec::StagedASTEnrichment::Error')
  ? 1
  : 0
}

sub _validated_entry {
 my ($entry) = @_;
 _internal_error('registry entry must be a hash reference') unless ref($entry) eq 'HASH';
 _internal_error('registry entry fields drifted') unless _has_exact_keys($entry, [qw(
  resolved_spec_id compiled_authority content_digest import_graph_fingerprint
  default_top_rule allowed_top_rules spec_language_version helper_contract_version
  staged_contract_version capabilities policy_modes ceilings
 )]);
 my $identity = _required_scalar($entry->{resolved_spec_id}, 'resolved_spec_id');
 _internal_error("invalid resolved parser identity '$identity'")
  unless $identity =~ $PARSER_ID_RE && index($identity, '..') < 0;
 _internal_error("compiled authority for '$identity' must be an already-compiled callback")
  unless ref($entry->{compiled_authority}) eq 'CODE';
 for my $field (qw(content_digest import_graph_fingerprint)) {
  my $value = _required_scalar($entry->{$field}, "$identity $field");
  _internal_error("invalid $field for '$identity'") unless $value =~ $DIGEST_RE
 }
 my $tops = _normalized_string_set($entry->{allowed_top_rules}, "$identity allowed_top_rules");
 _internal_error("entry '$identity' must allow at least one top rule") unless @$tops;
 for my $top (@$tops) {
  _internal_error("invalid top rule '$top' for '$identity'") unless $top =~ $TOP_RULE_RE
 }
 my $default_top = _required_scalar($entry->{default_top_rule}, "$identity default_top_rule");
 _internal_error("default top '$default_top' is not allowed for '$identity'")
  unless grep { $_ eq $default_top } @$tops;
 my $versions = _validated_versions($entry, "$identity versions", 1);
 _internal_error("entry '$identity' does not implement staged contract version 2")
  unless $versions->{staged_contract_version} == 2;
 my $capabilities = _normalized_string_set($entry->{capabilities}, "$identity capabilities");
 my $policy_modes = _normalized_string_set($entry->{policy_modes}, "$identity policy_modes");
 my $ceilings = _validated_ceilings($entry->{ceilings}, "$identity ceilings");
 return {
  resolved_spec_id => $identity,
  compiled_authority => $entry->{compiled_authority},
  content_digest => "$entry->{content_digest}",
  import_graph_fingerprint => "$entry->{import_graph_fingerprint}",
  default_top_rule => $default_top,
  allowed_top_rules => $tops,
  %$versions,
  capabilities => $capabilities,
  policy_modes => $policy_modes,
  ceilings => $ceilings,
 }
}

sub _validated_direct_candidates {
 my ($rows, $context, $entries) = @_;
 _internal_error("$context must be an array reference") unless ref($rows) eq 'ARRAY';
 my @owned;
 for my $row (@$rows) {
  _internal_error("$context candidate fields drifted")
   unless _has_exact_keys($row, [qw(declaring_spec_id authored_id resolved_spec_id)]);
  my $declaring = _required_scalar($row->{declaring_spec_id}, "$context declaring_spec_id");
  my $authored = _required_scalar($row->{authored_id}, "$context authored_id");
  my $resolved = _required_scalar($row->{resolved_spec_id}, "$context resolved_spec_id");
  _internal_error("$context declaring identity '$declaring' is invalid")
   unless $declaring =~ $PARSER_ID_RE
    && index($declaring, '..') < 0
    && substr($declaring, 0, 1) ne '/';
  _internal_error("$context authored parser identity '$authored' is invalid")
   unless $authored =~ $PARSER_ID_RE && index($authored, '..') < 0;
  _internal_error("$context refers to absent entry '$resolved'") unless $entries->{$resolved};
  push @owned, {
   declaring_spec_id => $declaring,
   authored_id => $authored,
   resolved_spec_id => $resolved,
  };
 }
 Hash::Util::lock_hashref_recurse($_) for @owned;
 return \@owned
}

sub _validated_ordered_candidates {
 my ($rows, $context, $identity_field, $entries) = @_;
 _internal_error("$context must be an array reference") unless ref($rows) eq 'ARRAY';
 my @owned;
 my $expected_order = 1;
 for my $row (@$rows) {
  _internal_error("$context row fields drifted")
   unless _has_exact_keys($row, [$identity_field, 'order', 'candidates']);
  my $identity = _required_scalar($row->{$identity_field}, "$context $identity_field");
  _internal_error("$context order must be contiguous from one")
   unless _is_nonnegative_integer($row->{order}) && $row->{order} == $expected_order++;
  _internal_error("$context candidates must be an array reference")
   unless ref($row->{candidates}) eq 'ARRAY';
  my @candidates;
  for my $candidate (@{$row->{candidates}}) {
   _internal_error("$context candidate fields drifted")
    unless _has_exact_keys($candidate, [qw(authored_id resolved_spec_id)]);
   my $authored = _required_scalar($candidate->{authored_id}, "$context authored_id");
   my $resolved = _required_scalar($candidate->{resolved_spec_id}, "$context resolved_spec_id");
   _internal_error("$context authored parser identity '$authored' is invalid")
    unless $authored =~ $PARSER_ID_RE && index($authored, '..') < 0;
   _internal_error("$context refers to absent entry '$resolved'") unless $entries->{$resolved};
   push @candidates, {
    authored_id => $authored,
    resolved_spec_id => $resolved,
   };
  }
  my $owned = {
   $identity_field => $identity,
   order => 0 + $row->{order},
   candidates => \@candidates,
  };
  Hash::Util::lock_hashref_recurse($owned);
  push @owned, $owned;
 }
 return \@owned
}

sub _validated_versions {
 my ($value, $context, $allow_superset) = @_;
 _internal_error("$context must be a hash reference") unless ref($value) eq 'HASH';
 unless ($allow_superset) {
  _internal_error("$context fields drifted") unless _has_exact_keys($value, \@VERSION_FIELDS)
 }
 for my $name (@VERSION_FIELDS) {
  _internal_error("$context is missing $name") unless exists $value->{$name};
 }
 _internal_error("$context spec_language_version must be a positive integer")
  unless _is_nonnegative_integer($value->{spec_language_version})
   && $value->{spec_language_version} > 0;
 _internal_error("$context helper_contract_version must be a nonempty scalar")
  unless defined($value->{helper_contract_version})
   && !ref($value->{helper_contract_version})
   && length($value->{helper_contract_version});
 _internal_error("$context staged_contract_version must be a positive integer")
  unless _is_nonnegative_integer($value->{staged_contract_version})
   && $value->{staged_contract_version} > 0;
 return {
  spec_language_version => 0 + $value->{spec_language_version},
  helper_contract_version => "$value->{helper_contract_version}",
  staged_contract_version => 0 + $value->{staged_contract_version},
 }
}

sub _validated_ceilings {
 my ($value, $context) = @_;
 _internal_error("$context must be a hash reference") unless ref($value) eq 'HASH';
 _internal_error("$context fields drifted") unless _has_exact_keys($value, [
  'source_detail', @NUMERIC_CEILINGS,
 ]);
 my $detail = _required_scalar($value->{source_detail}, "$context source_detail");
 _internal_error("$context source_detail '$detail' is invalid")
  unless exists $SOURCE_DETAIL_RANK{$detail};
 my %owned = (source_detail => $detail);
 for my $name (@NUMERIC_CEILINGS) {
  _internal_error("$context $name must be a positive integer")
   unless _is_nonnegative_integer($value->{$name}) && $value->{$name} > 0;
  $owned{$name} = 0 + $value->{$name};
 }
 return \%owned
}

sub _discover_current_depth {
 my ($value, $path, $out) = @_;
 if (LinkedSpec::StagedParseJob::is_marker($value)) {
  _internal_error('a root staged marker has no typed parent AST path') unless @$path;
  push @$out, {marker => $value, path => _clone_plain($path)};
  return
 }
 if (ref($value) eq 'HASH') {
  for my $key (sort keys %$value) {
   _discover_current_depth($value->{$key}, [@$path, "$key"], $out)
  }
 } elsif (ref($value) eq 'ARRAY') {
  for my $index (0 .. $#$value) {
   _discover_current_depth($value->[$index], [@$path, 0 + $index], $out)
  }
 }
 return
}

sub _compare_plans {
 my ($left, $right) = @_;
 my $path = _compare_typed_sequences($left->{path}, $right->{path});
 return $path if $path;
 my $provenance = _compare_typed_sequences(
  $left->{provenance_order},
  $right->{provenance_order},
 );
 return $provenance if $provenance;
 return $left->{sidecar}{job_id} cmp $right->{sidecar}{job_id}
}

sub _compare_typed_sequences {
 my ($left, $right) = @_;
 my $last = @$left < @$right ? $#$left : $#$right;
 for my $index (0 .. $last) {
  my $left_integer = _is_nonnegative_integer($left->[$index]);
  my $right_integer = _is_nonnegative_integer($right->[$index]);
  return -1 if !$left_integer && $right_integer;
  return 1 if $left_integer && !$right_integer;
  my $cmp = $left_integer
   ? $left->[$index] <=> $right->[$index]
   : "$left->[$index]" cmp "$right->[$index]";
  return $cmp if $cmp
 }
 return @$left <=> @$right
}

sub _provenance_order {
 my ($provenance) = @_;
 my @segments = ($provenance->{kind} // '') eq 'direct_span'
  ? ($provenance)
  : @{$provenance->{segments} // []};
 return [map {
  ($_->{source_id}, 0 + $_->{start}, 0 + $_->{end}, $_->{provenance})
 } @segments]
}

sub _cached_execution_plan {
 my ($state, $plan) = @_;
 my $key = $plan->{sidecar}{cache_key};
 if (exists $state->{cache}{$key}) {
  ++$state->{cache_hits};
  return $state->{cache}{$key}
 }
 my $cached = {
  cache_key => $key,
  compiled_authority => $plan->{entry}{compiled_authority},
  resolved_spec_id => $plan->{sidecar}{resolved_spec_id},
  top_rule => $plan->{sidecar}{top_rule},
  effective_capabilities => _clone_plain($plan->{sidecar}{effective}{capabilities}),
 };
 Hash::Util::lock_hashref_recurse($cached);
 $state->{cache}{$key} = $cached;
 ++$state->{cache_misses};
 return $cached
}

sub _validate_stitch_target {
 my ($ast, $plan) = @_;
 my ($parent, $component, $actual) = _locate_slot($ast, $plan->{path});
 unless (LinkedSpec::StagedParseJob::is_marker($actual)
  && refaddr($actual) == refaddr($plan->{marker})) {
  _stitch_error(
   $plan,
   'staged_marker_mismatch',
   actual_marker => _marker_diagnostic($actual),
  )
 }
 my $sidecar = $plan->{sidecar};
 return if $sidecar->{result_policy} eq 'replace_marker';
 my $into = $sidecar->{into};
 unless (ref($parent) eq 'HASH' && defined($into) && !ref($into) && length($into)) {
  _stitch_error($plan, 'staged_stitch_target_missing', into => _diagnostic_scalar($into))
 }
 if ($sidecar->{result_policy} eq 'replace_field') {
  _stitch_error($plan, 'staged_stitch_target_missing', into => $into)
   unless exists $parent->{$into};
 } elsif ($sidecar->{result_policy} eq 'sibling_field') {
  _stitch_error($plan, 'staged_stitch_target_collision', into => $into)
   if exists $parent->{$into};
 } elsif ($sidecar->{result_policy} eq 'append_child') {
  _stitch_error($plan, 'staged_append_target_invalid', into => $into)
   unless ref($parent->{$into}) eq 'ARRAY';
 }
 return
}

sub _stitch_value {
 my ($ast, $plan, $result) = @_;
 _validate_stitch_target($ast, $plan);
 my ($parent, $component) = _locate_slot($ast, $plan->{path});
 my $sidecar = $plan->{sidecar};
 if ($sidecar->{result_policy} eq 'replace_marker') {
  _set_slot($parent, $component, $result);
  return
 }
 _set_slot($parent, $component, $sidecar->{text});
 my $into = $sidecar->{into};
 if ($sidecar->{result_policy} eq 'replace_field'
  || $sidecar->{result_policy} eq 'sibling_field') {
  $parent->{$into} = $result
 } elsif ($sidecar->{result_policy} eq 'append_child') {
  push @{$parent->{$into}}, $result
 }
 return
}

sub _materialize_marker_text {
 my ($ast, $plan) = @_;
 my ($parent, $component, $actual) = _locate_slot($ast, $plan->{path});
 unless (LinkedSpec::StagedParseJob::is_marker($actual)
  && refaddr($actual) == refaddr($plan->{marker})) {
  _stitch_error(
   $plan,
   'staged_marker_mismatch',
   actual_marker => _marker_diagnostic($actual),
  )
 }
 _set_slot($parent, $component, $plan->{sidecar}{text});
 return
}

sub _locate_slot {
 my ($ast, $path) = @_;
 _internal_error('typed parent AST path must be nonempty') unless ref($path) eq 'ARRAY' && @$path;
 my $current = $ast;
 for my $index (0 .. $#$path - 1) {
  my $component = $path->[$index];
  if (ref($current) eq 'HASH') {
   _internal_error('parent AST path is missing') unless exists $current->{$component};
   $current = $current->{$component}
  } elsif (ref($current) eq 'ARRAY') {
   _internal_error('parent AST array path is invalid')
    unless _is_nonnegative_integer($component) && $component <= $#$current;
   $current = $current->[$component]
  } else {
   _internal_error('parent AST path crosses a scalar')
  }
 }
 my $component = $path->[-1];
 if (ref($current) eq 'HASH') {
  _internal_error('parent AST marker slot is missing') unless exists $current->{$component};
  return ($current, $component, $current->{$component})
 }
 if (ref($current) eq 'ARRAY') {
  _internal_error('parent AST marker array slot is invalid')
   unless _is_nonnegative_integer($component) && $component <= $#$current;
  return ($current, 0 + $component, $current->[$component])
 }
 _internal_error('parent AST marker has no aggregate parent')
}

sub _set_slot {
 my ($parent, $component, $value) = @_;
 if (ref($parent) eq 'HASH') {
  $parent->{$component} = $value
 } elsif (ref($parent) eq 'ARRAY') {
  $parent->[$component] = $value
 } else {
  _internal_error('cannot set a staged marker outside an aggregate')
 }
 return
}

sub _child_failure_diagnostic {
 my ($sidecar, $child_error) = @_;
 my $child = _portable_child_diagnostic($child_error);
 return {
  code => 'staged_child_failed',
  phase => 'execute',
  stage_chain => [],
  job_id => $sidecar->{job_id},
  parent_ast_path => _clone_plain($sidecar->{parent_ast_path}),
  node_kind => $sidecar->{node_kind},
  payload_kind => $sidecar->{payload_kind},
  parser_spec_id => $sidecar->{parser_spec_id},
  resolved_spec_id => $sidecar->{resolved_spec_id},
  top_rule => $sidecar->{top_rule},
  cache_key => $sidecar->{cache_key},
  source_provenance => _clone_plain($sidecar->{provenance}),
  result_policy => $sidecar->{result_policy},
  failure_policy => $sidecar->{failure_policy},
  child_diagnostic => $child,
 }
}

sub _portable_child_diagnostic {
 my ($value) = @_;
 if (ref($value) eq 'HASH') {
  my ($accepted, $copy) = _detach_plain($value, 256, 0);
  return $copy if $accepted
 }
 if (blessed($value) && eval { exists $value->{code} }) {
  return {code => _diagnostic_scalar($value->{code})}
 }
 return {code => 'staged_child_exception'}
}

sub _detach_result {
 my ($value, $maximum, $sidecar) = @_;
 my ($accepted, $copy, $nodes, $reason) = _detach_plain($value, $maximum, 1);
 return (1, $copy, undef) if $accepted;
 if ($reason eq 'node_limit') {
  return (0, undef, {
   code => 'staged_result_node_limit_exceeded',
   phase => 'execute',
   stage_chain => [],
   job_id => $sidecar->{job_id},
   nodes => $nodes,
   maximum => $maximum,
  })
 }
 return (0, undef, {
  code => 'staged_result_not_detached',
  phase => 'execute',
  stage_chain => [],
  job_id => $sidecar->{job_id},
  field => defined($reason) ? $reason : '<result>',
 })
}

sub _detach_plain {
 my ($value, $maximum, $allow_markers) = @_;
 my $nodes = 0;
 my %active;
 my $walk;
 $walk = sub {
  my ($item) = @_;
  ++$nodes;
  return (0, undef, 'node_limit') if $nodes > $maximum;
  if (!ref($item)) {
   my $encoded = eval { $JSON->encode($item) };
   return (0, undef, '<nonfinite>') unless defined $encoded;
   return (1, $item, undef)
  }
  if (JSON::PP::is_bool($item)) {
   return (1, $item ? JSON::PP::true : JSON::PP::false, undef)
  }
  if ($allow_markers && LinkedSpec::StagedParseJob::is_marker($item)) {
   return (1, $item, undef)
  }
  my $type = ref($item);
  return (0, undef, '<reference>') unless $type eq 'HASH' || $type eq 'ARRAY';
  my $address = refaddr($item);
  return (0, undef, '$cycle') if $active{$address};
  $active{$address} = 1;
  if ($type eq 'ARRAY') {
   my @copy;
   for my $child (@$item) {
    my ($ok, $owned, $reason) = $walk->($child);
    unless ($ok) {
     delete $active{$address};
     return (0, undef, $reason)
    }
    push @copy, $owned;
   }
   delete $active{$address};
   return (1, \@copy, undef)
  }
  for my $key (keys %$item) {
   if ($key eq '$ref' || $LIVE_RESULT_KEY{$key}) {
    delete $active{$address};
    return (0, undef, $key)
   }
  }
  my %copy;
  for my $key (keys %$item) {
   my ($ok, $owned, $reason) = $walk->($item->{$key});
   unless ($ok) {
    delete $active{$address};
    return (0, undef, $reason)
   }
   $copy{$key} = $owned;
  }
  delete $active{$address};
  return (1, \%copy, undef)
 };
 my ($accepted, $copy, $reason) = $walk->($value);
 return ($accepted, $copy, $nodes, $reason)
}

sub _stitch_error {
 my ($plan, $code, %extra) = @_;
 _throw(
  code => $code,
  phase => 'stitch',
  stage_chain => [],
  job_id => $plan->{sidecar}{job_id},
  parent_ast_path => _clone_plain($plan->{path}),
  %extra,
 )
}

sub _marker_diagnostic {
 my ($value) = @_;
 return LinkedSpec::StagedParseJob::marker_record($value)
  if LinkedSpec::StagedParseJob::is_marker($value);
 return '<missing>' unless defined $value;
 return '<reference>' if ref $value;
 return "$value"
}

sub _job_identity {
 my ($fields) = @_;
 _internal_error('job identity fields must be a hash reference') unless ref($fields) eq 'HASH';
 _internal_error('job identity fields drifted') unless _has_exact_keys($fields, [qw(
  declaring_spec_id parent_ast_path node_kind payload_kind parser_spec_id
  top_rule provenance
 )]);
 my $identity = {
  contract_version => 2,
  declaring_spec_id => $fields->{declaring_spec_id},
  parent_ast_path => $fields->{parent_ast_path},
  node_kind => $fields->{node_kind},
  payload_kind => $fields->{payload_kind},
  parser_spec_id => $fields->{parser_spec_id},
  top_rule => $fields->{top_rule},
  provenance => $fields->{provenance},
 };
 return 'parse_job:v2:' . _digest($identity)
}

sub _cache_identity_error {
 my ($fields, $component) = @_;
 my $resolved = ref($fields) eq 'HASH'
  ? _diagnostic_scalar($fields->{normalized_spec_id})
  : '<missing>';
 _throw(
  code => 'staged_cache_identity_invalid',
  phase => 'compile',
  job_id => '<unassigned>',
  resolved_spec_id => $resolved,
  cache_component => $component,
 )
}

sub _digest {
 my ($value) = @_;
 return 'sha256:' . sha256_hex($JSON_UTF8->encode($value))
}

sub _clone_ast {
 my ($value) = @_;
 my %active;
 my $walk;
 $walk = sub {
  my ($item) = @_;
  return $item unless ref($item);
  return $item ? JSON::PP::true : JSON::PP::false if JSON::PP::is_bool($item);
  return $item if LinkedSpec::StagedParseJob::is_marker($item);
  my $type = ref($item);
  _internal_error('AST must contain only plain data and inert staged markers')
   unless $type eq 'HASH' || $type eq 'ARRAY';
  my $address = refaddr($item);
  _internal_error('AST must be acyclic') if $active{$address};
  $active{$address} = 1;
  my $copy;
  if ($type eq 'HASH') {
   $copy = {map { ($_ => $walk->($item->{$_})) } keys %$item}
  } else {
   $copy = [map { $walk->($_) } @$item]
  }
  delete $active{$address};
  return $copy
 };
 return $walk->($value)
}

sub _clone_plain {
 my ($value) = @_;
 return JSON::PP->new->decode($JSON->encode($value))
}

sub _normalized_string_set {
 my ($values, $context) = @_;
 _internal_error("$context must be an array reference") unless ref($values) eq 'ARRAY';
 my %seen;
 my @owned;
 for my $value (@$values) {
  _internal_error("$context must contain nonempty scalars")
   unless defined($value) && !ref($value) && length($value);
  push @owned, "$value" unless $seen{"$value"}++
 }
 return [sort @owned]
}

sub _required_scalar {
 my ($value, $context) = @_;
 _internal_error("$context must be a nonempty scalar")
  unless defined($value) && !ref($value) && length($value);
 return "$value"
}

sub _diagnostic_scalar {
 my ($value) = @_;
 return '<missing>' unless defined $value;
 return '<reference>' if ref $value;
 return "$value"
}

sub _is_nonnegative_integer {
 my ($value) = @_;
 return 0 unless defined($value) && !ref($value);
 my $encoded = eval { $JSON->encode($value) };
 return defined($encoded) && $encoded =~ /\A(?:0|[1-9][0-9]*)\z/o ? 1 : 0
}

sub _has_exact_keys {
 my ($value, $fields) = @_;
 return 0 unless ref($value) eq 'HASH';
 my %expected = map { ($_ => 1) } @$fields;
 return 0 unless keys(%$value) == keys(%expected);
 return !grep { !$expected{$_} } keys %$value
}

sub _state {
 my ($self) = @_;
 _internal_error('invalid staged-AST enrichment authority')
  unless blessed($self) && $self->isa(__PACKAGE__);
 my $state = $STATE_BY_ADDRESS{refaddr($self)};
 _internal_error('staged-AST enrichment authority is unavailable')
  unless ref($state) eq 'HASH';
 return $state
}

sub _throw {
 my (%fields) = @_;
 die LinkedSpec::StagedASTEnrichment::Error->new(%fields)
}

sub _internal_error {
 my ($message) = @_;
 die "(LinkedSpec::StagedASTEnrichment) -E- $message\n"
}

sub DESTROY {
 my ($self) = @_;
 delete $STATE_BY_ADDRESS{refaddr($self)} if ref $self;
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::StagedASTEnrichment::Error
# Purpose: Typed portable failure for private post-AST resolution and stitching.
#------------------------------------------------------------------------------
package LinkedSpec::StagedASTEnrichment::Error;

use 5.010;
use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub new {
 my ($class, %fields) = @_;
 my $self = bless \%fields, $class;
 Hash::Util::lock_hashref_recurse($self);
 return $self
}

sub as_string {
 my ($self) = @_;
 my @fields;
 for my $key (sort keys %$self) {
  my $value = $self->{$key};
  my $rendered = ref($value)
   ? eval { $JSON->encode($value) }
   : defined($value) ? "$value" : '<undefined>';
  $rendered = '<reference>' unless defined $rendered;
  push @fields, "$key=$rendered";
 }
 return 'LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:' . join(';', @fields)
}

1;
