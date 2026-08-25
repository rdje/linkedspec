#------------------------------------------------------------------------------
# Package: LinkedSpec::StagedParseJob
# Purpose: Construct opaque inert staged-parse markers and validate/materialize
#          their direct or ordered-derived typed source provenance. This module
#          deliberately owns no parser registry, cache, scheduler, or stitch.
#------------------------------------------------------------------------------
package LinkedSpec::StagedParseJob;

use 5.010;
use strict;
use warnings;

use Hash::Util ();
use JSON::PP ();
use Scalar::Util qw(blessed refaddr);
use LinkedSpec::SourceLocation ();

my %MARKER_STATE_BY_ADDRESS;

sub construct_marker {
 my ($string_ref, $entry_info, $match_info, $origin, $encoded) = @_;
 _throw(
  code => 'staged_source_provenance_invalid',
  phase => 'declare',
  origin => defined($origin) ? $origin : '<runtime>',
  source_id => '<runtime>',
  provenance => '<runtime-input>',
 ) unless ref($string_ref) eq 'SCALAR' && ref($entry_info) eq 'HASH';
 my $payload = eval { JSON::PP->new->decode($encoded) };
 _throw(
  code => 'staged_parse_job_options_required',
  phase => 'declare',
  origin => defined($origin) ? $origin : '<runtime>',
  operand => '<invalid-lowering-payload>',
 ) if $@ || ref($payload) ne 'HASH';
 my $plan = $payload->{text_plan};
 my $options = $payload->{options};
 _throw(
  code => 'staged_parse_job_options_required',
  phase => 'declare',
  origin => defined($origin) ? $origin : '<runtime>',
  operand => '<invalid-lowering-options>',
 ) unless ref($options) eq 'HASH';

 my $authority = LinkedSpec::SourceLocation::Runtime::ensure_authority(
  $entry_info,
  $string_ref,
 );
 my $provenance = _provenance_from_runtime_plan(
  $plan,
  $entry_info,
  $match_info,
  defined($origin) ? $origin : '<runtime>',
 );
 my $validated = validate_and_materialize_provenance(
  $authority,
  $provenance,
  origin => defined($origin) ? $origin : '<runtime>',
 );

 my %sidecar = (
  kind => 'staged_parse_job_v2',
  version => 2,
  state => 'declared',
  effect => 'staged_parse_job_declaration',
  node_kind => $options->{node_kind},
  payload_kind => $options->{payload_kind},
  parser_spec_id => $options->{spec},
  result_policy => $options->{result_policy},
  failure_policy => $options->{on_error},
  required_capabilities => [@{$options->{required_capabilities} // []}],
  text => $validated->{text},
  provenance => $validated->{provenance},
  origin => defined($origin) ? "$origin" : '<runtime>',
 );
 $sidecar{top_rule} = $options->{top} if exists($options->{top});
 $sidecar{into} = $options->{into} if exists($options->{into});
 return _new_marker(\%sidecar)
}

sub validate_and_materialize_provenance {
 my ($authority, $record, %args) = @_;
 my $origin = defined($args{origin}) && !ref($args{origin})
  ? "$args{origin}"
  : '<runtime>';
 my $kind = ref($record) eq 'HASH' ? ($record->{kind} // '') : '';
 my $source_id = ref($record) eq 'HASH' && defined($record->{source_id})
  && !ref($record->{source_id}) ? "$record->{source_id}" : '<derived>';
 my $result = eval {
  die 'authority' unless blessed($authority) && $authority->isa('LinkedSpec::SourceLocation');
  if ($kind eq 'direct_span') {
   my $span = _typed_direct_span($authority, $record, $origin);
   return {
    provenance => {kind => 'direct_span', %{$span->as_record}},
    text => $authority->materialize($span),
   }
  }
  die 'derived-shape' unless $kind eq 'derived_text'
   && _has_exact_keys($record, qw(kind policy segments))
   && ($record->{policy} // '') eq 'concatenate_in_order'
   && ref($record->{segments}) eq 'ARRAY'
   && @{$record->{segments}};
  my @spans = map {
   _typed_direct_span($authority, $_, $origin)
  } @{$record->{segments}};
  my $derived = $authority->derived_text(
   policy => 'concatenate_in_order',
   spans => \@spans,
   context => {
    rule_role => $origin,
    invocation_role => 'staged_parse_job_declaration',
   },
  );
  return {
   provenance => {
    kind => 'derived_text',
    policy => 'concatenate_in_order',
    segments => [map { +{kind => 'direct_span', %{$_->as_record}} } @spans],
   },
   text => $authority->materialize($derived),
  }
 };
 return $result if !$@ && ref($result) eq 'HASH';
 _throw(
  code => 'staged_source_provenance_invalid',
  phase => 'declare',
  origin => $origin,
  source_id => $source_id,
  provenance => length($kind) ? $kind : '<invalid>',
 )
}

sub is_marker {
 my ($value) = @_;
 return blessed($value)
  && $value->isa('LinkedSpec::StagedParseJob::Marker')
  && ref($MARKER_STATE_BY_ADDRESS{refaddr($value)}) eq 'HASH'
  ? 1 : 0
}

sub marker_record {
 my ($marker) = @_;
 _require_marker($marker);
 return {
  kind => 'STAGED_PARSE_JOB_MARKER',
  version => 2,
  sidecar_kind => 'staged_parse_job_v2',
  effect => 'staged_parse_job_declaration',
 }
}

sub sidecar_record {
 my ($marker) = @_;
 my $state = _require_marker($marker);
 return _clone_plain($state->{sidecar})
}

sub is_error {
 my ($value) = @_;
 return blessed($value) && $value->isa('LinkedSpec::StagedParseJob::Error') ? 1 : 0
}

sub _new_marker {
 my ($sidecar) = @_;
 my $token = 0;
 my $marker = bless \$token, 'LinkedSpec::StagedParseJob::Marker';
 $MARKER_STATE_BY_ADDRESS{refaddr($marker)} = {
  sidecar => _clone_plain($sidecar),
 };
 return $marker
}

sub _require_marker {
 my ($marker) = @_;
 die '(LinkedSpec::StagedParseJob) -E- invalid or expired marker' . "\n"
  unless is_marker($marker);
 return $MARKER_STATE_BY_ADDRESS{refaddr($marker)}
}

sub _provenance_from_runtime_plan {
 my ($plan, $entry_info, $match_info, $origin) = @_;
 unless (ref($plan) eq 'HASH') {
  _throw(
   code => 'staged_source_provenance_invalid',
   phase => 'declare',
   origin => $origin,
   source_id => '<runtime>',
   provenance => '<invalid-plan>',
  )
 }
 if (($plan->{kind} // '') eq 'direct_span') {
  return _direct_runtime_record($plan, $entry_info, $match_info, $origin)
 }
 unless (
  ($plan->{kind} // '') eq 'derived_text'
  && ($plan->{policy} // '') eq 'concatenate_in_order'
  && ref($plan->{segments}) eq 'ARRAY'
  && @{$plan->{segments}}
 ) {
  _throw(
   code => 'staged_source_provenance_invalid',
   phase => 'declare',
   origin => $origin,
   source_id => '<runtime>',
   provenance => '<invalid-derived-plan>',
  )
 }
 return {
  kind => 'derived_text',
  policy => 'concatenate_in_order',
  segments => [map {
   _direct_runtime_record($_, $entry_info, $match_info, $origin)
  } @{$plan->{segments}}],
 }
}

sub _direct_runtime_record {
 my ($plan, $entry_info, $match_info, $origin) = @_;
 my $source = ref($plan) eq 'HASH' ? ($plan->{source} // '') : '';
 my $uses_entry = $source =~ /\Aentry_(?:text|group)\z/o;
 my $info = $uses_entry ? $entry_info : $match_info;
 my $span;
 if (ref($info) eq 'HASH') {
  if ($source eq 'entry_text' || $source eq 'match_text') {
   $span = $info->{match_span}
  } elsif ($source eq 'entry_group' || $source eq 'match_group') {
   my $index = $plan->{index};
   $span = ref($info->{match_spans}) eq 'ARRAY'
    && defined($index) && !ref($index) && $index =~ /\A(?:0|[1-9][0-9]*)\z/o
    ? $info->{match_spans}[$index]
    : undef;
  }
 }
 my $source_id = ref($entry_info) eq 'HASH'
  && defined($entry_info->{source_location_source_id})
  && !ref($entry_info->{source_location_source_id})
  ? "$entry_info->{source_location_source_id}"
  : 'input';
 unless (
  ref($span) eq 'HASH'
  && defined($span->{start}) && !ref($span->{start})
  && defined($span->{end}) && !ref($span->{end})
 ) {
  _throw(
   code => 'staged_source_provenance_invalid',
   phase => 'declare',
   origin => $origin,
   source_id => $source_id,
   provenance => length($source) ? $source : '<invalid-runtime-source>',
  )
 }
 return {
  kind => 'direct_span',
  source_id => $source_id,
  start => 0 + $span->{start},
  end => 0 + $span->{end},
  provenance => $source,
 }
}

sub _typed_direct_span {
 my ($authority, $record, $origin) = @_;
 die 'direct-shape' unless ref($record) eq 'HASH'
  && _has_exact_keys($record, qw(kind source_id start end provenance))
  && ($record->{kind} // '') eq 'direct_span'
  && defined($record->{source_id}) && !ref($record->{source_id}) && length($record->{source_id})
  && defined($record->{start}) && !ref($record->{start})
  && defined($record->{end}) && !ref($record->{end})
  && defined($record->{provenance}) && !ref($record->{provenance}) && length($record->{provenance});
 my $context = {
  rule_role => $origin,
  invocation_role => 'staged_parse_job_declaration',
 };
 return $authority->direct_span(
  start => $authority->position(
   source_id => $record->{source_id},
   offset => $record->{start},
   context => $context,
  ),
  end => $authority->position(
   source_id => $record->{source_id},
   offset => $record->{end},
   context => $context,
  ),
  provenance => $record->{provenance},
  context => $context,
 )
}

sub _has_exact_keys {
 my ($value, @expected) = @_;
 return 0 unless ref($value) eq 'HASH';
 my @actual = sort keys %$value;
 @expected = sort @expected;
 return 0 unless @actual == @expected;
 for my $index (0 .. $#expected) {
  return 0 unless $actual[$index] eq $expected[$index]
 }
 return 1
}

sub _clone_plain {
 my ($value) = @_;
 return JSON::PP->new->decode(JSON::PP->new->canonical(1)->encode($value))
}

sub _throw {
 my (%fields) = @_;
 die LinkedSpec::StagedParseJob::Error->new(%fields)
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::StagedParseJob::Marker
# Purpose: Opaque marker identity; logical state remains in its private owner.
#------------------------------------------------------------------------------
package LinkedSpec::StagedParseJob::Marker;

use 5.010;
use strict;
use warnings;

sub DESTROY {
 my ($self) = @_;
 delete $MARKER_STATE_BY_ADDRESS{Scalar::Util::refaddr($self)} if ref($self);
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::StagedParseJob::Error
# Purpose: Typed privacy-preserving declaration/provenance failure.
#------------------------------------------------------------------------------
package LinkedSpec::StagedParseJob::Error;

use 5.010;
use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub new {
 my ($class, %fields) = @_;
 my $self = bless {%fields}, $class;
 Hash::Util::lock_hashref($self);
 return $self
}

sub as_string {
 my ($self) = @_;
 return 'LINKEDSPEC_STAGED_PARSE_JOB_ERROR:'
  .($self->{code} // 'staged_parse_job_error')
}

1;
