# Private construction sidecars. Ordinary lowerer results remain scalar strings;
# only an explicitly selected producer in the actual invocation may publish a
# fragment packet. Integration at the producer seams is separately owned.
package LinkedSpec::ActionIR::SourceEmissions;

use 5.010;
use strict;
use warnings;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}
use Scalar::Util ();
use LinkedSpec::ActionIR::SourceOrigins ();

our ($_producers, $_call);

sub _same_reference {
 my ($left, $right) = @_;
 return ref($left) && ref($right)
  && Scalar::Util::refaddr($left) == Scalar::Util::refaddr($right)
}

sub _current_source_token {
 return LinkedSpec::ActionIR::SourceOrigins::_invocation_token()
}

# The caller supplies actual known callbacks at their factory seam. Strong
# retention prevents refaddr reuse; nested producer/source scopes cannot borrow
# the enclosing registration. This is private authority, not a public registry.
sub _with_emission_producers {
 my ($callbacks, $work) = @_;
 my %known;
 for my $callback (@{ref($callbacks) eq 'ARRAY' ? $callbacks : []}) {
  $known{Scalar::Util::refaddr($callback)} = $callback if ref($callback) eq 'CODE';
 }
 local $_producers = {source_token => _current_source_token(), known => \%known, captures => {}};
 local $_call;
 if (!defined wantarray) { $work->(); return }
 return $work->()
}

sub _eligible_call {
 return ref($_call) eq 'HASH' && $_call->{known}
  && _same_reference($_call->{source_token}, _current_source_token())
  && _same_reference($_call->{producer_scope}, $_producers)
}

sub _copy_packet {
 my ($packet) = @_;
 return {
  text => $packet->{text},
  fragments => [map { +{kind => $_->{kind}, output_span => {%{$_->{output_span}}},
                  exists($_->{source_span}) ? (source_span => {%{$_->{source_span}}}) : ()} }
                @{$packet->{fragments}}],
  consumed => [map { +{source_span => {%{$_->{source_span}}}} } @{$packet->{consumed}}],
 }
}

# Always call once in scalar context, as the existing canonical apply seam does.
# shift preserves aliases of the remaining @_ entries as well as reference
# identity. No eval shields or extra calls may change callback error effects.
sub _capture_emission {
 my $callback = shift;
 my $source_token = _current_source_token();
 my $known = ref($_producers) eq 'HASH'
  && _same_reference($_producers->{source_token}, $source_token)
  && ref($callback) eq 'CODE'
  && _same_reference($_producers->{known}{Scalar::Util::refaddr($callback)}, $callback);
 local $_call = {source_token => $source_token, producer_scope => $_producers,
                 callback => $callback, known => $known, builders => {}, publications => []};
 my $value = $callback->(@_);
 my $callback_error = $@;
 my ($packet, $published);
 if (_eligible_call() && @{$_call->{publications}} == 1 && defined($value) && !ref($value)) {
  my $record = $_call->{publications}[0];
  if (!$record->{invalid} && $value eq $record->{text}
      && ${$record->{builder}} eq $record->{text}) {
   $packet = {
    text => $value,
    fragments => $record->{fragments}, consumed => $record->{consumed},
   };
   $published = $record;
  }
 }
 my $capture = {value => $value, emission => $packet ? _copy_packet($packet) : undef};
 if ($packet) {
  $_producers->{captures}{Scalar::Util::refaddr($capture)} = {
   capture => $capture, callback => $callback, event => $published->{event},
   origin => $published->{origin}, packet => _copy_packet($packet),
  };
 }
 $@ = $callback_error;
 return $capture
}

# Mapping must retrieve the retained packet for the actual capture/callback/event
# triple. Detached descriptive packets cannot grant authority in another call.
sub _emission_for {
 my ($capture, $callback, $event) = @_;
 return undef unless ref($_producers) eq 'HASH'
  && _same_reference($_producers->{source_token}, _current_source_token())
  && ref($capture) eq 'HASH';
 my $entry = $_producers->{captures}{Scalar::Util::refaddr($capture)};
 return undef unless $entry && _same_reference($entry->{capture}, $capture)
  && _same_reference($entry->{callback}, $callback) && _same_reference($entry->{event}, $event)
  && defined($capture->{value}) && !ref($capture->{value})
  && $capture->{value} eq $entry->{packet}{text};
 my $origin = LinkedSpec::ActionIR::SourceOrigins::_origin_for($event);
 return undef unless $origin && $origin->{source} eq $entry->{origin}{source}
  && $origin->{source_span}{start} == $entry->{origin}{source_span}{start}
  && $origin->{source_span}{end} == $entry->{origin}{source_span}{end};
 return _copy_packet($entry->{packet})
}

# Builder text works without a collector or source authority. Metadata lives in
# the actual call's sidecar, so copied/foreign/stale builder objects have none.
sub _new_builder {
 my ($event) = @_;
 my $text = '';
 my $builder = bless \$text, 'LinkedSpec::ActionIR::SourceEmissions::Builder';
 if (_eligible_call()) {
  my $origin = LinkedSpec::ActionIR::SourceOrigins::_origin_for($event);
  $_call->{builders}{Scalar::Util::refaddr($builder)} = {
   builder => $builder, event => $event, origin => $origin, text => '',
   fragments => [], consumed => [],
  } if $origin;
 }
 return $builder
}

sub _builder_record {
 my ($builder) = @_;
 return undef unless _eligible_call() && ref($builder) eq 'LinkedSpec::ActionIR::SourceEmissions::Builder';
 my $record = $_call->{builders}{Scalar::Util::refaddr($builder)};
 return $record && _same_reference($record->{builder}, $builder) ? $record : undef
}

sub _valid_span {
 my ($span, $start, $end) = @_;
 return defined($start) && !ref($start) && $start =~ /\A[0-9]+\z/o
  && defined($end) && !ref($end) && $end =~ /\A[0-9]+\z/o
  && $span->{start} <= $start && $start <= $end && $end <= $span->{end}
}

sub _append_piece {
 my ($builder, $text, $start, $end) = @_;
 die "private emission piece must be a scalar string\n" unless defined($text) && !ref($text);
 my $record = _builder_record($builder);
 if ($record) {
  $record->{invalid} = 1 if $record->{published} || $$builder ne $record->{text};
  my $offset = length($record->{text});
  my $fragment = {kind => 'generated', output_span => {start => $offset, end => $offset + length($text)}};
  my $origin = $record->{origin};
  if (_valid_span($origin->{source_span}, $start, $end)
      && substr($origin->{source}, $start, $end - $start) eq $text) {
   $fragment->{kind} = 'source';
   $fragment->{source_span} = {start => 0 + $start, end => 0 + $end};
  }
  push @{$record->{fragments}}, $fragment if length($text);
  $record->{text} .= $text;
 }
 $$builder .= $text;
 return $builder
}

sub _append_generated {
 my ($builder, $text) = @_;
 return _append_piece($builder, $text, undef, undef)
}

# Explicit construction coordinates validate a selected original frame. Equal
# text alone does not grant a frame or choose an occurrence.
sub _append_source {
 return _append_piece(@_)
}

sub _consume_source {
 my ($builder, $event) = @_;
 my $record = _builder_record($builder);
 return $builder unless $record;
 $record->{invalid} = 1 if $record->{published};
 my $origin = LinkedSpec::ActionIR::SourceOrigins::_origin_for($event);
 return $builder unless $origin && $origin->{source} eq $record->{origin}{source};
 my ($start, $end) = @{$origin->{source_span}}{qw(start end)};
 return $builder unless _valid_span($record->{origin}{source_span}, $start, $end);
 push @{$record->{consumed}}, {event => $event, source_span => {start => $start, end => $end}};
 return $builder
}

sub _finish_emission {
 my ($builder) = @_;
 my $record = _builder_record($builder);
 if ($record) {
  $record->{invalid} = 1 if $record->{published} || $$builder ne $record->{text};
  $record->{published} = 1;
  push @{$_call->{publications}}, $record;
 }
 return $$builder
}

1;
