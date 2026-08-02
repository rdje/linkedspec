#------------------------------------------------------------------------------
# Package: LinkedSpec::SourceLocation
# Purpose: Own decoded input and construct immutable source positions, direct
#          spans, and explicitly derived text provenance.
#------------------------------------------------------------------------------
package LinkedSpec::SourceLocation;

use 5.010;
use strict;
use warnings;
use utf8;

use Encode qw(encode FB_CROAK LEAVE_SRC);
use Hash::Util ();
use Scalar::Util qw(blessed refaddr);

my %AUTHORITY_STATE_BY_ADDRESS;
my %POSITION_STATE_BY_ADDRESS;
my %SPAN_STATE_BY_ADDRESS;
my %DERIVED_STATE_BY_ADDRESS;
my $NEXT_AUTHORITY_ID = 1;

sub new {
 my ($class, %args) = @_;
 my $sources = $args{sources};
 _internal_error('sources must be a hash reference') unless ref($sources) eq 'HASH';

 my %owned_sources;
 for my $source_id (keys %$sources) {
  my $decoded_text = $sources->{$source_id};
  _internal_error('source ids must be defined scalars')
   unless defined($source_id) && !ref($source_id);
  _internal_error("decoded source '$source_id' must be a defined scalar")
   unless defined($decoded_text) && !ref($decoded_text);

  my $owned_text = "$decoded_text";
  utf8::upgrade($owned_text);
  my (@line_at_offset, @column_at_offset, @byte_at_offset);
  my ($line, $column, $byte_offset) = (1, 1, 0);
  push @line_at_offset, $line;
  push @column_at_offset, $column;
  push @byte_at_offset, $byte_offset;
  for my $character (split //u, $owned_text) {
   my $bytes = eval { encode('UTF-8', $character, FB_CROAK | LEAVE_SRC) };
   _internal_error("decoded source '$source_id' is not strict Unicode text") if $@;
   $byte_offset += length($bytes);
   if ($character eq "\n") {
    ++$line;
    $column = 1;
   } else {
    ++$column;
   }
   push @line_at_offset, $line;
   push @column_at_offset, $column;
   push @byte_at_offset, $byte_offset;
  }
  $owned_sources{$source_id} = {
   text             => $owned_text,
   length           => length($owned_text),
   line_at_offset   => \@line_at_offset,
   column_at_offset => \@column_at_offset,
   byte_at_offset   => \@byte_at_offset,
  };
 }

 my $token = 0;
 my $self = bless \$token, $class;
 $AUTHORITY_STATE_BY_ADDRESS{refaddr($self)} = {
  authority_id => $NEXT_AUTHORITY_ID++,
  sources      => \%owned_sources,
 };
 return $self
}

sub position {
 my ($self, %args) = @_;
 my $authority = _authority_state($self);
 my $source_id = $args{source_id};
 my $offset = $args{offset};
 my $source = defined($source_id) && !ref($source_id)
  ? $authority->{sources}{$source_id}
  : undef;
 my $source_length = ref($source) eq 'HASH' ? $source->{length} : 0;
 unless (
  ref($source) eq 'HASH'
  && defined($offset)
  && !ref($offset)
  && $offset =~ /\A(?:0|[1-9][0-9]*)\z/
  && $offset <= $source_length
 ) {
  _throw_value_error(
   code            => 'source_location_position_out_of_range',
   context         => $args{context},
   source_id       => defined($source_id) && !ref($source_id) ? "$source_id" : '',
   position_offset => defined($offset) && !ref($offset) ? $offset : '',
   source_length   => $source_length,
  );
 }
 return _new_position({
  authority_id => $authority->{authority_id},
  source_id    => "$source_id",
  offset       => 0 + $offset,
 })
}

sub direct_span {
 my ($self, %args) = @_;
 my $authority = _authority_state($self);
 my $start = _position_state($args{start});
 my $end = _position_state($args{end});
 if ($start->{source_id} ne $end->{source_id}) {
  _throw_value_error(
   code            => 'source_location_source_mismatch',
   context         => $args{context},
   source_id       => $start->{source_id},
   other_source_id => $end->{source_id},
  );
 }
 _internal_error('direct span positions belong to another source authority')
  unless $start->{authority_id} == $authority->{authority_id}
   && $end->{authority_id} == $authority->{authority_id};
 if ($start->{offset} > $end->{offset}) {
  _throw_value_error(
   code         => 'source_location_reversed_span',
   context      => $args{context},
   source_id    => $start->{source_id},
   start_offset => $start->{offset},
   end_offset   => $end->{offset},
  );
 }
 my $provenance = $args{provenance};
 _internal_error('direct span provenance must be a non-empty scalar')
  unless defined($provenance) && !ref($provenance) && length($provenance);
 return _new_span({
  authority_id => $authority->{authority_id},
  source_id    => $start->{source_id},
  start        => $start->{offset},
  end          => $end->{offset},
  provenance   => "$provenance",
 })
}

sub derived_text {
 my ($self, %args) = @_;
 my $authority = _authority_state($self);
 my $policy = $args{policy};
 _internal_error("unsupported derived-text policy")
  unless defined($policy) && !ref($policy) && $policy eq 'concatenate_in_order';
 my $spans = $args{spans};
 _internal_error('derived-text spans must be an array reference') unless ref($spans) eq 'ARRAY';

 my @span_records;
 for (my $index = 0; $index < @$spans; ++$index) {
  my $span = _span_state($spans->[$index]);
  if ($span->{authority_id} != $authority->{authority_id}) {
   _throw_value_error(
    code             => 'source_location_invalid_derived_provenance',
    context          => $args{context},
    provenance_index => $index,
    source_id        => $span->{source_id},
   );
  }
  push @span_records, _span_record($span);
 }
 return _new_derived_text({
  authority_id => $authority->{authority_id},
  policy       => 'concatenate_in_order',
  spans        => \@span_records,
 })
}

sub coordinates {
 my ($self, $position, %args) = @_;
 my $authority = _authority_state($self);
 my $position_state = _position_state($position);
 _internal_error('position belongs to another source authority')
  unless $position_state->{authority_id} == $authority->{authority_id};
 my $source = $authority->{sources}{$position_state->{source_id}};
 _internal_error('position refers to an unknown decoded source') unless ref($source) eq 'HASH';
 my $offset = $position_state->{offset};
 return {
  source_id        => $position_state->{source_id},
  offset           => $offset,
  line             => $source->{line_at_offset}[$offset],
  column           => $source->{column_at_offset}[$offset],
  utf8_byte_offset => $source->{byte_at_offset}[$offset],
 }
}

sub materialize {
 my ($self, $value, %args) = @_;
 my $authority = _authority_state($self);
 if (blessed($value) && $value->isa('LinkedSpec::SourceLocation::Span')) {
  my $span = _span_state($value);
  _internal_error('span belongs to another source authority')
   unless $span->{authority_id} == $authority->{authority_id};
  return _materialize_span_record($authority, $span)
 }
 if (blessed($value) && $value->isa('LinkedSpec::SourceLocation::DerivedText')) {
  my $derived = _derived_state($value);
  _internal_error('derived text belongs to another source authority')
   unless $derived->{authority_id} == $authority->{authority_id};
  return join '', map {
   _materialize_span_record($authority, $_)
  } @{$derived->{spans}}
 }
 _internal_error('materialize requires a typed direct span or derived text')
}

sub _materialize_span_record {
 my ($authority, $span) = @_;
 my $source = $authority->{sources}{$span->{source_id}};
 _internal_error('span refers to an unknown decoded source') unless ref($source) eq 'HASH';
 return substr($source->{text}, $span->{start}, $span->{end} - $span->{start})
}

sub _new_position {
 my ($state) = @_;
 my $token = 0;
 my $position = bless \$token, 'LinkedSpec::SourceLocation::Position';
 $POSITION_STATE_BY_ADDRESS{refaddr($position)} = {%$state};
 return $position
}

sub _new_span {
 my ($state) = @_;
 my $token = 0;
 my $span = bless \$token, 'LinkedSpec::SourceLocation::Span';
 $SPAN_STATE_BY_ADDRESS{refaddr($span)} = {%$state};
 return $span
}

sub _new_derived_text {
 my ($state) = @_;
 my $token = 0;
 my $derived = bless \$token, 'LinkedSpec::SourceLocation::DerivedText';
 $DERIVED_STATE_BY_ADDRESS{refaddr($derived)} = {
  authority_id => $state->{authority_id},
  policy       => $state->{policy},
  spans        => [map { _span_record($_) } @{$state->{spans}}],
 };
 return $derived
}

sub _authority_state {
 my ($self) = @_;
 return _object_state($self, __PACKAGE__, \%AUTHORITY_STATE_BY_ADDRESS, 'source authority')
}

sub _position_state {
 my ($position) = @_;
 return _object_state(
  $position,
  'LinkedSpec::SourceLocation::Position',
  \%POSITION_STATE_BY_ADDRESS,
  'position',
 )
}

sub _span_state {
 my ($span) = @_;
 return _object_state($span, 'LinkedSpec::SourceLocation::Span', \%SPAN_STATE_BY_ADDRESS, 'span')
}

sub _derived_state {
 my ($derived) = @_;
 return _object_state(
  $derived,
  'LinkedSpec::SourceLocation::DerivedText',
  \%DERIVED_STATE_BY_ADDRESS,
  'derived text',
 )
}

sub _object_state {
 my ($object, $class, $states, $label) = @_;
 _internal_error("invalid $label object") unless blessed($object) && $object->isa($class);
 my $state = $states->{refaddr($object)};
 _internal_error("expired $label object") unless ref($state) eq 'HASH';
 return $state
}

sub _position_record {
 my ($state) = @_;
 return {
  source_id => $state->{source_id},
  offset    => $state->{offset},
 }
}

sub _span_record {
 my ($state) = @_;
 return {
  source_id  => $state->{source_id},
  start      => $state->{start},
  end        => $state->{end},
  provenance => $state->{provenance},
 }
}

sub _derived_record {
 my ($state) = @_;
 return {
  policy => $state->{policy},
  spans  => [map { _span_record($_) } @{$state->{spans}}],
 }
}

sub _error_context {
 my ($context) = @_;
 return () unless ref($context) eq 'HASH';
 return map {
  exists($context->{$_})
   ? ($_ => defined($context->{$_}) && !ref($context->{$_}) ? "$context->{$_}" : '')
   : ()
 } qw(rule_role invocation_role)
}

sub _throw_value_error {
 my (%args) = @_;
 my %fields = (
  code  => delete($args{code}),
  phase => 'validate_value',
  _error_context(delete($args{context})),
  %args,
 );
 die LinkedSpec::SourceLocation::Error->new(%fields)
}

sub _internal_error {
 my ($detail) = @_;
 die "(LinkedSpec::SourceLocation) -E- $detail\n"
}

sub DESTROY {
 my ($self) = @_;
 delete $AUTHORITY_STATE_BY_ADDRESS{refaddr($self)} if ref($self);
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::SourceLocation::Position
# Purpose: Immutable source identity plus zero-based Unicode-scalar offset.
#------------------------------------------------------------------------------
package LinkedSpec::SourceLocation::Position;

use 5.010;
use strict;
use warnings;

sub as_record {
 return LinkedSpec::SourceLocation::_position_record(
  LinkedSpec::SourceLocation::_position_state($_[0]),
 )
}

sub DESTROY {
 my ($self) = @_;
 delete $POSITION_STATE_BY_ADDRESS{Scalar::Util::refaddr($self)} if ref($self);
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::SourceLocation::Span
# Purpose: Immutable same-source half-open interval plus provenance label.
#------------------------------------------------------------------------------
package LinkedSpec::SourceLocation::Span;

use 5.010;
use strict;
use warnings;

sub as_record {
 return LinkedSpec::SourceLocation::_span_record(
  LinkedSpec::SourceLocation::_span_state($_[0]),
 )
}

sub DESTROY {
 my ($self) = @_;
 delete $SPAN_STATE_BY_ADDRESS{Scalar::Util::refaddr($self)} if ref($self);
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::SourceLocation::DerivedText
# Purpose: Immutable ordered direct-span provenance with explicit policy.
#------------------------------------------------------------------------------
package LinkedSpec::SourceLocation::DerivedText;

use 5.010;
use strict;
use warnings;

sub as_record {
 return LinkedSpec::SourceLocation::_derived_record(
  LinkedSpec::SourceLocation::_derived_state($_[0]),
 )
}

sub DESTROY {
 my ($self) = @_;
 delete $DERIVED_STATE_BY_ADDRESS{Scalar::Util::refaddr($self)} if ref($self);
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::SourceLocation::Error
# Purpose: Structured privacy-preserving immutable-value validation failure.
#------------------------------------------------------------------------------
package LinkedSpec::SourceLocation::Error;

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
 my $code = $self->{code} // 'source_location_error';
 return "LINKEDSPEC_SOURCE_LOCATION_ERROR:$code"
}

1;
