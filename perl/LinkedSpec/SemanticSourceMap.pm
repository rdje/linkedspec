#------------------------------------------------------------------------------
# Package: LinkedSpec::SemanticSourceMap
# Purpose: Convert exact decoded-source character ranges and strict-UTF-8 byte
#          ranges into deterministic semantic source spans.
#------------------------------------------------------------------------------
package LinkedSpec::SemanticSourceMap;

use 5.010;
use strict;
use warnings;
use utf8;

use Encode qw(decode encode FB_CROAK LEAVE_SRC);
use Scalar::Util qw(refaddr);

my %STATE_BY_ADDRESS;

sub new {
 my ($class, %args) = @_;
 my $source_text = $args{source_text};
 my $source_bytes = $args{source_bytes};
 die "(LinkedSpec::SemanticSourceMap::new) -E- source_text must be a scalar\n"
  if !defined($source_text) || ref($source_text);
 die "(LinkedSpec::SemanticSourceMap::new) -E- source_bytes must be a scalar\n"
  if !defined($source_bytes) || ref($source_bytes) || utf8::is_utf8($source_bytes);

 my $encoded = eval { encode('UTF-8', $source_text, FB_CROAK | LEAVE_SRC) };
 die "(LinkedSpec::SemanticSourceMap::new) -E- source_text is not encodable as strict UTF-8\n" if $@;
 die "(LinkedSpec::SemanticSourceMap::new) -E- source_text/source_bytes mismatch\n"
  unless $encoded eq $source_bytes;

 my (@byte_at_character, @line_at_character, @column_at_character);
 my ($byte, $line, $column) = (0, 1, 1);
 push @byte_at_character, $byte;
 push @line_at_character, $line;
 push @column_at_character, $column;

 foreach my $character (split //u, $source_text) {
  $byte += length(encode('UTF-8', $character, FB_CROAK | LEAVE_SRC));
  if ($character eq "\n") {
   ++$line;
   $column = 1;
  } else {
   ++$column;
  }
  push @byte_at_character, $byte;
  push @line_at_character, $line;
  push @column_at_character, $column;
 }

 my %character_at_byte;
 @character_at_byte{@byte_at_character} = (0 .. $#byte_at_character);
 my $token = 0;
 my $self = bless \$token, $class;
 $STATE_BY_ADDRESS{refaddr($self)} = {
  source_text => "$source_text",
  source_bytes => "$source_bytes",
  byte_at_character => \@byte_at_character,
  character_at_byte => \%character_at_byte,
  line_at_character => \@line_at_character,
  column_at_character => \@column_at_character,
 };
 return $self
}

sub byte_length {
 my ($self) = @_;
 return length(_state($self)->{source_bytes})
}

sub character_length {
 my ($self) = @_;
 return scalar(@{_state($self)->{byte_at_character}}) - 1
}

sub span_from_character_range {
 my ($self, $start_character, $end_character) = @_;
 my $state = _state($self);
 _validate_nonnegative_integer($start_character, 'start_character');
 _validate_nonnegative_integer($end_character, 'end_character');
 my $character_length = @{$state->{byte_at_character}} - 1;
 die "(LinkedSpec::SemanticSourceMap::span_from_character_range) -E- invalid character range\n"
  if $start_character > $end_character || $end_character > $character_length;
 return _span_for_character_boundaries($state, $start_character, $end_character)
}

sub span_from_byte_range {
 my ($self, $start_byte, $end_byte) = @_;
 my $state = _state($self);
 _validate_nonnegative_integer($start_byte, 'start_byte');
 _validate_nonnegative_integer($end_byte, 'end_byte');
 die "(LinkedSpec::SemanticSourceMap::span_from_byte_range) -E- invalid byte range\n"
  if $start_byte > $end_byte || $end_byte > length($state->{source_bytes});
 my $start_character = $state->{character_at_byte}{$start_byte};
 my $end_character = $state->{character_at_byte}{$end_byte};
 die "(LinkedSpec::SemanticSourceMap::span_from_byte_range) -E- byte range splits a UTF-8 character\n"
  unless defined($start_character) && defined($end_character);
 return _span_for_character_boundaries($state, $start_character, $end_character)
}

sub excerpt_for_byte_range {
 my ($self, $start_byte, $end_byte) = @_;
 my $state = _state($self);
 my $span = $self->span_from_byte_range($start_byte, $end_byte);
 my $start_character = $state->{character_at_byte}{$span->{start_byte}};
 my $end_character = $state->{character_at_byte}{$span->{end_byte}};
 return substr($state->{source_text}, $start_character, $end_character - $start_character)
}

sub locate_exact {
 my ($self, $needle, %args) = @_;
 my $state = _state($self);
 die "(LinkedSpec::SemanticSourceMap::locate_exact) -E- needle must be a non-empty scalar\n"
  if !defined($needle) || ref($needle) || !length($needle);
 my $needle_text;
 if (utf8::is_utf8($needle)) {
  $needle_text = "$needle";
  eval { encode('UTF-8', $needle_text, FB_CROAK | LEAVE_SRC); 1 }
   or die "(LinkedSpec::SemanticSourceMap::locate_exact) -E- needle is not strict Unicode text\n";
 } else {
  my $needle_bytes = "$needle";
  $needle_text = eval { decode('UTF-8', $needle_bytes, FB_CROAK | LEAVE_SRC) };
  die "(LinkedSpec::SemanticSourceMap::locate_exact) -E- needle is not strict UTF-8\n" if $@;
 }
 my $after_byte = exists($args{after_byte}) ? $args{after_byte} : 0;
 _validate_nonnegative_integer($after_byte, 'after_byte');
 die "(LinkedSpec::SemanticSourceMap::locate_exact) -E- after_byte is beyond the source\n"
  if $after_byte > length($state->{source_bytes});
 my $start_character = $state->{character_at_byte}{$after_byte};
 die "(LinkedSpec::SemanticSourceMap::locate_exact) -E- after_byte splits a UTF-8 character\n"
  unless defined $start_character;
 my $found_character = index($state->{source_text}, $needle_text, $start_character);
 return undef if $found_character < 0;
 my $end_character = $found_character + length($needle_text);
 return _span_for_character_boundaries($state, $found_character, $end_character)
}

sub _span_for_character_boundaries {
 my ($state, $start_character, $end_character) = @_;
 return {
  start_byte => $state->{byte_at_character}[$start_character],
  end_byte => $state->{byte_at_character}[$end_character],
  start_line => $state->{line_at_character}[$start_character],
  start_column => $state->{column_at_character}[$start_character],
  end_line => $state->{line_at_character}[$end_character],
  end_column => $state->{column_at_character}[$end_character],
 }
}

sub _validate_nonnegative_integer {
 my ($value, $name) = @_;
 die "(LinkedSpec::SemanticSourceMap) -E- $name must be a nonnegative integer\n"
  unless defined($value) && !ref($value) && $value =~ /\A(?:0|[1-9][0-9]*)\z/;
 return
}

sub _state {
 my ($self) = @_;
 die "(LinkedSpec::SemanticSourceMap) -E- invalid source-map object\n"
  unless ref($self) && $self->isa(__PACKAGE__);
 my $state = $STATE_BY_ADDRESS{refaddr($self)};
 die "(LinkedSpec::SemanticSourceMap) -E- expired source-map object\n" unless ref($state) eq 'HASH';
 return $state
}

sub DESTROY {
 my ($self) = @_;
 delete $STATE_BY_ADDRESS{refaddr($self)} if ref($self);
 return
}

1;
