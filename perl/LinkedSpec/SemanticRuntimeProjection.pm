#------------------------------------------------------------------------------
# Package: LinkedSpec::SemanticRuntimeProjection
# Purpose: Derive an immutable runtime semantic projection from one static
#          projection and a completed caller-owned typed observation.
#------------------------------------------------------------------------------
package LinkedSpec::SemanticRuntimeProjection;

use 5.010;
use strict;
use warnings;

use JSON::PP ();

use LinkedSpec::RuntimeSemanticObservation ();
use LinkedSpec::SemanticStaticProjection ();

sub build {
 my ($static, $observation) = @_;
 _invalid('Static semantic projection is unavailable') unless ref($static) eq 'HASH';
 _invalid('Execution observation must be an array reference') unless ref($observation) eq 'ARRAY';
 _invalid('Execution observation must contain at least one event') unless @$observation;
 _invalid('Execution observations require a compiled semantic snapshot')
  unless ref($static->{snapshot}) eq 'HASH'
   && ($static->{snapshot}{state} // '') eq 'compiled'
   && !$static->{snapshot}{has_execution};

 my %record_by_id = map { $_->{id} => $_ } @{$static->{records} || []};
 my %rule_by_name = map { $_->{name} => $_ }
  grep { ($_->{kind} // '') eq 'rule' && defined($_->{name}) } @{$static->{records} || []};
 my %slot_by_key;
 foreach my $slot (grep { ($_->{kind} // '') eq 'regex_slot' } @{$static->{records} || []}) {
  my $owner = $record_by_id{$slot->{owner_id}};
  next unless ref($owner) eq 'HASH' && defined($owner->{name});
  $slot_by_key{$owner->{name} . "\0" . $slot->{order}} = $slot;
 }
 my %edge_for_selection;
 foreach my $relation (grep { ($_->{kind} // '') eq 'selects_regex' } @{$static->{relations} || []}) {
  my $edge = $record_by_id{$relation->{from_id}};
  next unless ref($edge) eq 'HASH' && ($edge->{kind} // '') eq 'edge';
  $edge_for_selection{$edge->{owner_id} . "\0" . $relation->{to_id}} ||= $edge;
 }

 my (@records, @relations);
 my @events = map { _event_row($_) } @$observation;
 my @result_events = grep { $_->{event_kind} eq 'rule_result' } @events;
 _invalid('Completed execution observation must contain exactly one final rule result')
  unless @result_events == 1 && $events[-1]{event_kind} eq 'rule_result';
 my $result_event = $result_events[0];
 _invalid('Final rule-result observation must report succeeded status')
  unless ($result_event->{status} // '') eq 'succeeded';
 _invalid('Final rule-result observation must carry a stable input identity')
  unless ($result_event->{input_identity} // '') =~ /\Ainput:sha256:[0-9a-f]{64}\z/;
 my $result_rule = $rule_by_name{$result_event->{rule_label}};
 _invalid("Observed result rule '$result_event->{rule_label}' does not exist in the semantic index")
  unless ref($result_rule) eq 'HASH';
 my $spec = $record_by_id{'spec:0'};
 _invalid('Static semantic projection has no spec record') unless ref($spec) eq 'HASH';
 _invalid('Observed final result does not belong to the selected entry rule')
  unless ($spec->{facts}{entry_rule_id} // '') eq $result_rule->{id};

 my $execution_id = 'execution:0';
 push @records, {
  id => $execution_id,
  kind => 'execution',
  name => 'caller observation',
  owner_id => 'spec:0',
  order => 0,
  source => undef,
  facts => {
   input_identity => $result_event->{input_identity},
   status => 'succeeded',
   result_shape => _clone_plain($result_rule->{facts}{value_shape}),
  },
  redactions => [],
 };

 for my $order (0 .. $#events) {
  my $event = $events[$order];
  my ($name, $source, $shape, $evidence_id);
  if ($event->{event_kind} eq 'regex_slot_selected') {
   my $rule = $rule_by_name{$event->{rule_label}};
   _invalid("Observed selecting rule '$event->{rule_label}' does not exist in the semantic index")
    unless ref($rule) eq 'HASH';
   my $slot = $slot_by_key{$event->{target_rule} . "\0" . $event->{regex_index}};
   _invalid(
    "Observed regex slot '"
     . $event->{target_rule}
     . '[' . $event->{regex_index}
     . "]' does not exist in the semantic index",
   )
    unless ref($slot) eq 'HASH';
   my $edge = $edge_for_selection{$rule->{id} . "\0" . $slot->{id}};
   _invalid(
    "Observed selecting rule '$event->{rule_label}' does not select regex slot '"
     . $event->{target_rule}
     . '[' . $event->{regex_index} . "]'",
   ) unless ref($edge) eq 'HASH';
   $name = 'slot selected';
   $source = $slot->{source};
   $shape = ref($edge) eq 'HASH' && ref($edge->{facts}{value_shape}) eq 'HASH'
    ? $edge->{facts}{value_shape}
    : _value_shape('unknown');
   $evidence_id = $slot->{id};
  } elsif ($event->{event_kind} eq 'rule_result') {
   _invalid('Rule-result event must be the final observation event') unless $order == $#events;
   $name = 'rule result';
   $source = $result_rule->{source};
   $shape = $result_rule->{facts}{value_shape};
   $evidence_id = $result_rule->{id};
  } else {
   _invalid("Unsupported semantic observation event '$event->{event_kind}'");
  }
  my $event_id = "event:$execution_id:$order";
  push @records, {
   id => $event_id,
   kind => 'event',
   name => $name,
   owner_id => $execution_id,
   order => $order,
   source => $source,
   facts => {
    event_kind => $event->{event_kind},
    position => $event->{position},
    value_shape => _clone_plain($shape),
   },
   redactions => [],
  };
  push @relations, {
   id => "relation:observed_as:$execution_id:$event_id:$order",
   kind => 'observed_as',
   from_id => $execution_id,
   to_id => $event_id,
   order => $order,
   source => $source,
   facts => {},
   evidence_ids => [$evidence_id],
  };
 }

 my $projection = _clone_plain($static);
 $projection->{snapshot}{has_execution} = JSON::PP::true;
 push @{$projection->{records}}, @records;
 push @{$projection->{relations}}, @relations;
 return LinkedSpec::SemanticStaticProjection::canonicalize($projection)
}

sub _event_row {
 my ($event) = @_;
 _invalid('Execution observation contains a non-native event')
  unless ref($event) eq 'LinkedSpec::RuntimeSemanticObservationEvent';
 my @expected = sort qw(
  contract_id event_kind input_identity position regex_index rule_label status target_rule
 );
 my @actual = sort keys %$event;
 _invalid('Execution observation event fields do not match the native v1 schema')
  unless join("\0", @actual) eq join("\0", @expected);
 _invalid('Execution observation event contract is unsupported')
  unless ($event->{contract_id} // '') eq $LinkedSpec::RuntimeSemanticObservation::CONTRACT_ID;
 _invalid('Execution observation event kind is missing')
  unless defined($event->{event_kind}) && !ref($event->{event_kind}) && length($event->{event_kind});
 _invalid('Execution observation rule label is missing')
  unless defined($event->{rule_label}) && !ref($event->{rule_label}) && length($event->{rule_label});
 _invalid('Execution observation position must be a non-negative integer')
  unless defined($event->{position}) && !ref($event->{position})
   && $event->{position} =~ /\A\d+\z/;
 if ($event->{event_kind} eq 'regex_slot_selected') {
  _invalid('Regex-slot observation target rule is missing')
   unless defined($event->{target_rule}) && !ref($event->{target_rule}) && length($event->{target_rule});
  _invalid('Regex-slot observation index must be a non-negative integer')
   unless defined($event->{regex_index}) && !ref($event->{regex_index})
    && $event->{regex_index} =~ /\A\d+\z/;
  _invalid('Regex-slot observation cannot carry result identity or status')
   if defined($event->{input_identity}) || defined($event->{status});
 } elsif ($event->{event_kind} eq 'rule_result') {
  _invalid('Rule-result observation cannot carry regex-slot identity')
   if defined($event->{target_rule}) || defined($event->{regex_index});
 }
 my %row = map { $_ => defined($event->{$_}) ? "$event->{$_}" : undef } @expected;
 $row{position} = 0 + $event->{position};
 $row{regex_index} = 0 + $event->{regex_index} if defined $event->{regex_index};
 return \%row
}

sub _value_shape {
 my ($kind) = @_;
 return {
  kind => $kind,
  element => undef,
  key => undef,
  value => undef,
  signature => undef,
  members => [],
 }
}

sub _clone_plain {
 my ($value) = @_;
 return $value unless ref $value;
 return $value ? JSON::PP::true : JSON::PP::false if ref($value) eq 'JSON::PP::Boolean';
 return [map { _clone_plain($_) } @$value] if ref($value) eq 'ARRAY';
 return {map { $_ => _clone_plain($value->{$_}) } keys %$value} if ref($value) eq 'HASH';
 _invalid('Non-plain value cannot enter a runtime semantic projection')
}

sub _invalid {
 my ($summary) = @_;
 die LinkedSpec::SemanticIndex::Error->new(
  stage => 'execution_observation',
  code => 'semantic_index_invalid_observation',
  summary => $summary,
 )
}

1;
