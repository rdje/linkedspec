#------------------------------------------------------------------------------
# Package: LinkedSpec::SemanticQuery
# Purpose: Evaluate the exact immutable semantic-query-v1 protocol over a
#          private plain-data Perl semantic projection.
#------------------------------------------------------------------------------
package LinkedSpec::SemanticQuery;

use 5.010;
use strict;
use warnings;

use JSON::PP ();
use Scalar::Util qw(looks_like_number);

my $MODEL_ID = 'linkedspec-semantic-model-v1';
my $QUERY_ID = 'linkedspec-semantic-query-v1';

my @RECORD_KINDS = qw(
 capabilities spec source rule regex_slot edge lifecycle function helper
 binding call staged_artifact generated_artifact diagnostic decision
 execution event explanation_step
);
my @RELATION_KINDS = qw(
 declares contains depends_on dispatches_to selects_regex calls resolves_to
 reads writes consumes produces lowered_from staged_by generated_as diagnoses
 observed_as explained_by
);
my @SOURCE_DETAILS = qw(none identity span text);
my @REQUEST_FIELDS = qw(
 contract operation subjects record_kinds relation_kinds direction page budget source
);
my %RECORD_RANK = map { $RECORD_KINDS[$_] => $_ } 0 .. $#RECORD_KINDS;
my %RELATION_RANK = map { $RELATION_KINDS[$_] => $_ } 0 .. $#RELATION_KINDS;
my %SOURCE_RANK = map { $SOURCE_DETAILS[$_] => $_ } 0 .. $#SOURCE_DETAILS;
my %SOURCE_SENSITIVE_FACT_PATHS = (
 regex_slot => ['/facts/pattern'],
 diagnostic => ['/facts/message'],
 explanation_step => ['/facts/summary'],
);
my %BUDGET_DEFAULTS = (
 max_records => 1000,
 max_relations => 2000,
 max_depth => 4,
);
my %BUDGET_MAXIMA = (
 max_records => 10000,
 max_relations => 20000,
 max_depth => 8,
);

sub capabilities {
 my ($projection) = @_;
 return evaluate(
  $projection,
  {
   contract => $QUERY_ID,
   operation => 'capabilities',
   subjects => [],
   record_kinds => [],
   relation_kinds => [],
   direction => 'outgoing',
   page => {after_id => undef, limit => 100},
   budget => {%BUDGET_DEFAULTS},
   source => {detail => 'none', include_content_digest => JSON::PP::false},
  },
 )
}

sub evaluate {
 my ($projection, $request) = @_;
 my $snapshot = _snapshot($projection);
 my $error = _request_error($snapshot, $request);
 return $error if defined $error;

 my $operation = $request->{operation};
 my %record_by_id = map { $_->{id} => $_ } @{$projection->{records}};
 if (($operation eq 'get' || $operation eq 'relations')
  && grep { !exists $record_by_id{$_} } @{$request->{subjects}}) {
  return _empty_response(
   $snapshot,
   $request,
   _query_diagnostic('semantic_query_invalid', reason => 'unknown_subject'),
  )
 }

 my ($records, $relations, $diagnostics) = ([], [], []);
 my $page = {
  after_id => $request->{page}{after_id},
  next_after_id => undef,
  complete => JSON::PP::true,
 };
 my ($record_cost, $relation_cost, $depth) = (0, 0, 0);
 my ($budgeted, $budget_reason) = (0, undef);

 if ($operation eq 'capabilities') {
  my $stream = [_capabilities_record($snapshot)];
  my $paged = _page_stream($stream, $request, $request->{budget}{max_records});
  return _invalid_after_id($snapshot, $request) if $paged->{invalid_after_id};
  ($records, $page, $budgeted) = @{$paged}{qw(selected page limited_by_budget)};
  $record_cost = scalar @$records;
  $budget_reason = 'max_records' if $budgeted;
 } elsif ($operation eq 'list' || $operation eq 'get') {
  my @candidates = @{$projection->{records}};
  if ($operation eq 'list' && @{$request->{record_kinds}}) {
   my %wanted = map { $_ => 1 } @{$request->{record_kinds}};
   @candidates = grep { $wanted{$_->{kind}} } @candidates;
  }
  if ($operation eq 'get') {
   my %wanted = map { $_ => 1 } @{$request->{subjects}};
   @candidates = grep { $wanted{$_->{id}} } @candidates;
  }
  my $paged = _page_stream(\@candidates, $request, $request->{budget}{max_records});
  return _invalid_after_id($snapshot, $request) if $paged->{invalid_after_id};
  $page = $paged->{page};
  $budgeted = $paged->{limited_by_budget};
  $records = [map {
   _project_record($_, $projection, $request->{source}{detail}, $request->{source}{include_content_digest})
  } @{$paged->{selected}}];
  $record_cost = scalar @{$paged->{selected}};
  $budget_reason = 'max_records' if $budgeted;
 } elsif ($operation eq 'relations') {
  my $traversal = _traverse_relations($projection, $request);
  my $paged = _page_stream(
   $traversal->{relations},
   $request,
   $request->{budget}{max_relations},
  );
  return _invalid_after_id($snapshot, $request) if $paged->{invalid_after_id};
  $page = $paged->{page};
  my $relation_limited = $paged->{limited_by_budget};
  $budgeted = $relation_limited || $traversal->{depth_limited};
  $relations = [map {
   _project_relation($_, $projection, $request->{source}{detail}, $request->{source}{include_content_digest})
  } @{$paged->{selected}}];
  $relation_cost = scalar @{$paged->{selected}};
  foreach my $relation (@{$paged->{selected}}) {
   my $relation_depth = $traversal->{depth_by_id}{$relation->{id}};
   $depth = $relation_depth if $relation_depth > $depth;
  }
  $budget_reason = $relation_limited ? 'max_relations' : 'max_depth' if $budgeted;
 } else {
  my $subject = $request->{subjects}[0];
  my $decision = $record_by_id{$subject};
  $decision = undef if defined($decision) && $decision->{kind} ne 'decision';
  if (!defined $decision) {
   my @owned = grep {
    $_->{kind} eq 'decision' && defined($_->{owner_id}) && $_->{owner_id} eq $subject
   } @{$projection->{records}};
   $decision = $owned[0] if @owned == 1;
  }
  return _empty_response(
   $snapshot,
   $request,
   _query_diagnostic('semantic_query_invalid', reason => 'not_explainable'),
  ) unless defined $decision;

  my @steps = grep {
   $_->{kind} eq 'explanation_step'
    && defined($_->{owner_id})
    && $_->{owner_id} eq $decision->{id}
  } @{$projection->{records}};
  my $paged = _page_stream(
   \@steps,
   $request,
   $request->{budget}{max_records} - 1,
  );
  return _invalid_after_id($snapshot, $request) if $paged->{invalid_after_id};
  $page = $paged->{page};
  $budgeted = $paged->{limited_by_budget};
  $records = [
   _project_record($decision, $projection, $request->{source}{detail}, $request->{source}{include_content_digest}),
   map {
    _project_record($_, $projection, $request->{source}{detail}, $request->{source}{include_content_digest})
   } @{$paged->{selected}},
  ];
  my %selected_step = map { $_->{id} => 1 } @{$paged->{selected}};
  $relations = [map {
   _project_relation($_, $projection, $request->{source}{detail}, $request->{source}{include_content_digest})
  } grep {
   $_->{kind} eq 'explained_by'
    && $_->{from_id} eq $decision->{id}
    && $selected_step{$_->{to_id}}
  } @{$projection->{relations}}];
  $record_cost = scalar @$records;
  $relation_cost = scalar @$relations;
  $depth = @{$paged->{selected}} ? 1 : 0;
  $budget_reason = 'max_records' if $budgeted;
 }

 if ($budgeted) {
  $page->{complete} = JSON::PP::false;
  push @$diagnostics, _query_diagnostic(
   'semantic_query_budget_exceeded',
   reason => $budget_reason,
  );
 }

 return {
  contract => $QUERY_ID,
  model => $MODEL_ID,
  ok => JSON::PP::true,
  snapshot => _clone($snapshot),
  records => $records,
  relations => $relations,
  page => $page,
  cost => {
   records_examined => $record_cost,
   relations_examined => $relation_cost,
   depth_reached => $depth,
  },
  diagnostics => $diagnostics,
 }
}

sub _request_error {
 my ($snapshot, $request) = @_;
 return _empty_response(
  $snapshot,
  undef,
  _query_diagnostic('semantic_query_invalid', reason => 'request_not_object'),
 ) unless ref($request) eq 'HASH';

 return _empty_response(
  $snapshot,
  $request,
  _query_diagnostic(
   'semantic_query_contract_unsupported',
   requested => $request->{contract},
  ),
 ) unless defined($request->{contract})
  && !ref($request->{contract})
  && $request->{contract} eq $QUERY_ID;

 return _invalid($snapshot, $request, 'request_fields')
  unless _has_exact_keys($request, \@REQUEST_FIELDS);
 return _invalid($snapshot, $request, 'page_fields')
  unless ref($request->{page}) eq 'HASH'
   && _has_exact_keys($request->{page}, [qw(after_id limit)]);
 return _invalid($snapshot, $request, 'budget_fields')
  unless ref($request->{budget}) eq 'HASH'
   && _has_exact_keys($request->{budget}, [qw(max_records max_relations max_depth)]);
 return _invalid($snapshot, $request, 'source_fields')
  unless ref($request->{source}) eq 'HASH'
   && _has_exact_keys($request->{source}, [qw(detail include_content_digest)]);

 my %operation = map { $_ => 1 } qw(capabilities list get relations explain);
 return _invalid($snapshot, $request, 'operation')
  unless defined($request->{operation}) && !ref($request->{operation}) && $operation{$request->{operation}};

 foreach my $key (qw(subjects record_kinds relation_kinds)) {
  return _invalid($snapshot, $request, "${key}_type")
   unless ref($request->{$key}) eq 'ARRAY'
    && !grep { !defined($_) || ref($_) } @{$request->{$key}};
  my %seen;
  return _invalid($snapshot, $request, "${key}_duplicate")
   if grep { $seen{$_}++ } @{$request->{$key}};
 }

 return _invalid($snapshot, $request, 'record_kind')
  if grep { !exists $RECORD_RANK{$_} } @{$request->{record_kinds}};
 return _invalid($snapshot, $request, 'relation_kind')
  if grep { !exists $RELATION_RANK{$_} } @{$request->{relation_kinds}};
 return _invalid($snapshot, $request, 'record_kind_order')
  unless _is_rank_ordered($request->{record_kinds}, \%RECORD_RANK);
 return _invalid($snapshot, $request, 'relation_kind_order')
  unless _is_rank_ordered($request->{relation_kinds}, \%RELATION_RANK);

 my %direction = map { $_ => 1 } qw(outgoing incoming both);
 return _invalid($snapshot, $request, 'direction')
  unless defined($request->{direction}) && !ref($request->{direction}) && $direction{$request->{direction}};
 return _invalid($snapshot, $request, 'after_id')
  if defined($request->{page}{after_id})
   && (ref($request->{page}{after_id}) || looks_like_number($request->{page}{after_id}));
 return _invalid($snapshot, $request, 'page_limit')
  unless _is_integer_in_range($request->{page}{limit}, 1, 1000);
 foreach my $key (qw(max_records max_relations max_depth)) {
  my $minimum = $key eq 'max_depth' ? 0 : 1;
  return _invalid($snapshot, $request, $key)
   unless _is_integer_in_range($request->{budget}{$key}, $minimum, $BUDGET_MAXIMA{$key});
 }

 my $detail = $request->{source}{detail};
 return _invalid($snapshot, $request, 'source_policy')
  unless defined($detail)
   && !ref($detail)
   && exists($SOURCE_RANK{$detail})
   && _is_boolean($request->{source}{include_content_digest});
 return _invalid($snapshot, $request, 'digest_requires_text')
  if $request->{source}{include_content_digest} && $detail ne 'text';
 my $ceiling = $snapshot->{source_detail_ceiling};
 if ($SOURCE_RANK{$detail} > $SOURCE_RANK{$ceiling}
  || ($request->{source}{include_content_digest} && !$snapshot->{content_digest_available})) {
  return _empty_response(
   $snapshot,
   $request,
   _query_diagnostic(
    'semantic_query_source_detail_forbidden',
    requested => $detail,
    reason => $ceiling,
   ),
  )
 }

 my $operation_name = $request->{operation};
 my $valid_combination =
  (($operation_name eq 'capabilities' || $operation_name eq 'list')
    && !@{$request->{subjects}}
    && !@{$request->{relation_kinds}})
  || ($operation_name eq 'get'
    && @{$request->{subjects}} >= 1
    && !@{$request->{record_kinds}}
    && !@{$request->{relation_kinds}})
  || ($operation_name eq 'relations'
    && @{$request->{subjects}} >= 1
    && !@{$request->{record_kinds}})
  || ($operation_name eq 'explain'
    && @{$request->{subjects}} == 1
    && !@{$request->{record_kinds}}
    && !@{$request->{relation_kinds}});
 return _invalid($snapshot, $request, 'operation_combination') unless $valid_combination;
 return _invalid($snapshot, $request, 'capability_filter')
  if $operation_name eq 'capabilities' && @{$request->{record_kinds}};
 return undef
}

sub _capabilities_record {
 my ($snapshot) = @_;
 return {
  id => 'capabilities:0',
  kind => 'capabilities',
  name => 'semantic introspection v1',
  owner_id => undef,
  order => 0,
  source => undef,
  facts => {
   model_ids => [$MODEL_ID],
   query_ids => [$QUERY_ID],
   record_kinds => [@RECORD_KINDS],
   relation_kinds => [@RELATION_KINDS],
   source_detail_ceiling => $snapshot->{source_detail_ceiling},
   page_default => 100,
   page_max => 1000,
   budget_defaults => {%BUDGET_DEFAULTS},
   budget_maxima => {%BUDGET_MAXIMA},
   execution_observation => _boolean($snapshot->{has_execution}),
   features => [],
  },
  redactions => [],
 }
}

sub _page_stream {
 my ($items, $request, $budget_limit) = @_;
 my @remaining = @$items;
 my $after_id = $request->{page}{after_id};
 if (defined $after_id) {
  my $after_index;
  for my $index (0 .. $#remaining) {
   if ($remaining[$index]{id} eq $after_id) {
    $after_index = $index;
    last
   }
  }
  return {invalid_after_id => 1} unless defined $after_index;
  if ($after_index < $#remaining) {
   @remaining = @remaining[($after_index + 1) .. $#remaining];
  } else {
   @remaining = ();
  }
 }
 my $limited_by_budget = @remaining > $budget_limit ? 1 : 0;
 my $limit = $request->{page}{limit} < $budget_limit
  ? $request->{page}{limit}
  : $budget_limit;
 my @selected = $limit > 0 && @remaining
  ? @remaining[0 .. ($#remaining < $limit - 1 ? $#remaining : $limit - 1)]
  : ();
 my $complete = @selected == @remaining && !$limited_by_budget;
 return {
  invalid_after_id => 0,
  selected => \@selected,
  page => {
   after_id => $after_id,
   next_after_id => @selected && !$complete ? $selected[-1]{id} : undef,
   complete => _boolean($complete),
  },
  limited_by_budget => $limited_by_budget,
 }
}

sub _traverse_relations {
 my ($projection, $request) = @_;
 my %wanted_kind = map { $_ => 1 } @{$request->{relation_kinds}};
 my $direction = $request->{direction};
 my %frontier = map { $_ => 1 } @{$request->{subjects}};
 my %visited = %frontier;
 my %depth_by_id;

 for my $depth (1 .. $request->{budget}{max_depth}) {
  my @layer = _relation_layer(
   $projection->{relations},
   \%frontier,
   \%wanted_kind,
   $direction,
   \%depth_by_id,
  );
  last unless @layer;
  my %next_frontier;
  foreach my $relation (@layer) {
   $depth_by_id{$relation->{id}} = $depth;
   $next_frontier{$relation->{to_id}} = 1
    if ($direction eq 'outgoing' || $direction eq 'both') && $frontier{$relation->{from_id}};
   $next_frontier{$relation->{from_id}} = 1
    if ($direction eq 'incoming' || $direction eq 'both') && $frontier{$relation->{to_id}};
  }
  delete @next_frontier{keys %visited};
  $visited{$_} = 1 for keys %next_frontier;
  %frontier = %next_frontier;
  last unless %frontier;
 }

 my $depth_limited = %frontier && _relation_layer(
  $projection->{relations},
  \%frontier,
  \%wanted_kind,
  $direction,
  \%depth_by_id,
 ) ? 1 : 0;
 my @relations = grep { exists $depth_by_id{$_->{id}} } @{$projection->{relations}};
 return {
  relations => \@relations,
  depth_by_id => \%depth_by_id,
  depth_limited => $depth_limited,
 }
}

sub _relation_layer {
 my ($relations, $frontier, $wanted_kind, $direction, $selected) = @_;
 return grep {
  (!%$wanted_kind || $wanted_kind->{$_->{kind}})
   && (($direction eq 'outgoing' || $direction eq 'both') && $frontier->{$_->{from_id}}
    || ($direction eq 'incoming' || $direction eq 'both') && $frontier->{$_->{to_id}})
   && !exists($selected->{$_->{id}})
 } @$relations
}

sub _project_record {
 my ($record, $projection, $detail, $include_digest) = @_;
 my $result = _clone($record);
 $result->{source} = _project_source($record->{source}, $projection, $detail, $include_digest);
 if ($detail ne 'text') {
  my $paths = $SOURCE_SENSITIVE_FACT_PATHS{$record->{kind}} || [];
  foreach my $path (@$paths) {
   my $key = $path;
   $key =~ s{^/facts/}{};
   $result->{facts}{$key} = undef;
  }
  $result->{redactions} = _clone($paths);
 }
 return $result
}

sub _project_relation {
 my ($relation, $projection, $detail, $include_digest) = @_;
 my $result = _clone($relation);
 $result->{source} = _project_source($relation->{source}, $projection, $detail, $include_digest);
 return $result
}

sub _project_source {
 my ($source_key, $projection, $detail, $include_digest) = @_;
 return undef if !defined($source_key) || $detail eq 'none';
 my $full = $projection->{source_refs}{$source_key};
 return {
  source_id => $full->{source_id},
  logical_name => $full->{logical_name},
  span => $detail eq 'span' || $detail eq 'text' ? _clone($full->{span}) : undef,
  excerpt => $detail eq 'text' ? $full->{excerpt} : undef,
  content_digest => $detail eq 'text' && $include_digest ? $full->{content_digest} : undef,
  provenance_ids => _clone($full->{provenance_ids}),
 }
}

sub _query_diagnostic {
 my ($code, %args) = @_;
 return {
  code => $code,
  severity => 'warning',
  message => 'Semantic query budget was reached; returning the deterministic prefix.',
  fields => {limit => $args{reason}},
 } if $code eq 'semantic_query_budget_exceeded';
 return {
  code => $code,
  severity => 'error',
  message => 'Unsupported semantic query contract.',
  fields => {requested => $args{requested}, supported => [$QUERY_ID]},
 } if $code eq 'semantic_query_contract_unsupported';
 return {
  code => $code,
  severity => 'error',
  message => 'Requested source detail exceeds the index ceiling.',
  fields => {requested => $args{requested}, ceiling => $args{reason}},
 } if $code eq 'semantic_query_source_detail_forbidden';
 return {
  code => 'semantic_query_invalid',
  severity => 'error',
  message => 'Invalid semantic query request.',
  fields => {reason => $args{reason}},
 }
}

sub _empty_response {
 my ($snapshot, $request, $diagnostic) = @_;
 my $after_id = ref($request) eq 'HASH'
  && ref($request->{page}) eq 'HASH'
  ? $request->{page}{after_id}
  : undef;
 return {
  contract => $QUERY_ID,
  model => $MODEL_ID,
  ok => JSON::PP::false,
  snapshot => _clone($snapshot),
  records => [],
  relations => [],
  page => {after_id => $after_id, next_after_id => undef, complete => JSON::PP::true},
  cost => {records_examined => 0, relations_examined => 0, depth_reached => 0},
  diagnostics => [$diagnostic],
 }
}

sub _invalid {
 my ($snapshot, $request, $reason) = @_;
 return _empty_response(
  $snapshot,
  $request,
  _query_diagnostic('semantic_query_invalid', reason => $reason),
 )
}

sub _invalid_after_id {
 my ($snapshot, $request) = @_;
 return _invalid($snapshot, $request, 'after_id_not_in_primary_stream')
}

sub _snapshot {
 my ($projection) = @_;
 die "(LinkedSpec::SemanticQuery::_snapshot) -E- invalid private semantic projection\n"
  unless ref($projection) eq 'HASH'
   && ref($projection->{snapshot}) eq 'HASH'
   && ref($projection->{records}) eq 'ARRAY'
   && ref($projection->{relations}) eq 'ARRAY'
   && ref($projection->{source_refs}) eq 'HASH';
 return _clone($projection->{snapshot})
}

sub _has_exact_keys {
 my ($value, $fields) = @_;
 return 0 unless ref($value) eq 'HASH';
 return 0 unless keys(%$value) == @$fields;
 return !grep { !exists($value->{$_}) } @$fields
}

sub _is_rank_ordered {
 my ($values, $rank) = @_;
 for my $index (1 .. $#$values) {
  return 0 if $rank->{$values->[$index - 1]} > $rank->{$values->[$index]};
 }
 return 1
}

sub _is_integer_in_range {
 my ($value, $minimum, $maximum) = @_;
 return 0 if !defined($value) || ref($value) || "$value" !~ /\A(?:0|[1-9][0-9]*)\z/;
 return $value >= $minimum && $value <= $maximum
}

sub _is_boolean {
 my ($value) = @_;
 return ref($value) eq 'JSON::PP::Boolean'
}

sub _boolean {
 my ($value) = @_;
 return $value ? JSON::PP::true : JSON::PP::false
}

sub _clone {
 my ($value) = @_;
 return $value unless ref $value;
 return $value ? JSON::PP::true : JSON::PP::false if ref($value) eq 'JSON::PP::Boolean';
 return [map { _clone($_) } @$value] if ref($value) eq 'ARRAY';
 return {map { $_ => _clone($value->{$_}) } keys %$value} if ref($value) eq 'HASH';
 die "(LinkedSpec::SemanticQuery::_clone) -E- non-plain value cannot cross the semantic query boundary\n"
}

1;
