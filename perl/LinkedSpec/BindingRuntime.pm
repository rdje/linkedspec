package LinkedSpec::BindingRuntime;

use strict;
use warnings;

use B ();
use JSON::PP ();
use Scalar::Util qw(looks_like_number);
use LinkedSpec::OwnerDispatch ();

sub _clone_value {
 my ($value) = @_;
 return $value ? JSON::PP::true : JSON::PP::false if JSON::PP::is_bool($value);
 return [map { _clone_value($_) } @$value] if ref($value) eq 'ARRAY';
 return {map { $_ => _clone_value($value->{$_}) } keys %$value} if ref($value) eq 'HASH';
 return $value
}

sub _runtime_kind {
 my ($value) = @_;
 return 'null' unless defined $value;
 return 'boolean' if JSON::PP::is_bool($value);
 return 'array' if ref($value) eq 'ARRAY';
 return 'codeblock'
  if ref($value) eq 'HASH'
  && ($value->{kind} // '') eq 'codeblock_literal';
 return 'harray' if ref($value) eq 'HASH';
 return 'scalar' if ref($value);
 my $flags = B::svref_2object(\$value)->FLAGS;
 return 'string' if $flags & B::SVp_POK();
 if (looks_like_number($value)) {
  return 'integer' if $flags & B::SVp_IOK();
  return 'number' if $flags & B::SVp_NOK();
  return 'integer' if int($value) == $value;
  return 'number';
 }
 return 'string'
}

sub _selector {
 my ($segment) = @_;
 my $value = $segment->{value};
 my $hint = $segment->{kind_hint} // 'dynamic';
 my $kind = $hint eq 'dynamic' ? _runtime_kind($value) : $hint;
 return ('harray', "".$value, $kind, undef) if $kind eq 'string' && defined($value) && !ref($value);
 if ($kind eq 'integer' && defined($value) && !ref($value) && looks_like_number($value)) {
  return (undef, $value, $kind, 'negative_integer') if $value < 0;
  return ('array', 0 + $value, $kind, undef) if int($value) == $value;
 }
 return (undef, $value, 'number', 'fractional_number') if $kind eq 'number';
 return (undef, $value, $kind, 'kind_not_path_selector')
}

sub _nested_write_error {
 my (%fields) = @_;
 die bless(\%fields, 'LinkedSpec::BindingRuntime::NestedWriteError')
}

sub is_nested_write_error {
 my ($value) = @_;
 return ref($value) eq 'LinkedSpec::BindingRuntime::NestedWriteError' ? 1 : 0
}

sub nested_write {
 my ($binding, $present, $identifier, $segments, $rhs) = @_;
 $identifier = '<unknown>' unless defined($identifier) && length($identifier);
 die "nested write requires at least one evaluated segment\n"
  unless ref($segments) eq 'ARRAY' && @$segments;

 my @selectors;
 my @selector_path;
 for (my $index = 0; $index < @$segments; ++$index) {
  my $segment = $segments->[$index];
  die "nested write segment record is invalid\n" unless ref($segment) eq 'HASH';
  my ($expected, $key, $actual, $reason) = _selector($segment);
  if (defined $reason) {
   _nested_write_error(
    code => 'nested_write_segment_invalid',
    operation => 'nested_write_vivification',
    binding => $identifier,
    segment_index => $index,
    path => _clone_value(\@selector_path),
    actual_kind => $actual,
    reason => $reason,
    source_span => _clone_value($segment->{source_span}),
    message => "nested write segment $index for binding '$identifier' must evaluate to a string or nonnegative integer; got $actual ($reason)",
   );
  }
  push @selectors, { expected => $expected, key => _clone_value($key), source_span => $segment->{source_span} };
  push @selector_path, _clone_value($key);
 }

 my $work = $present
  ? _clone_value($binding)
  : ($selectors[0]{expected} eq 'array' ? [] : {});
 my $cursor = $work;
 my @prefix;
 my $rhs_value = _clone_value($rhs);
 for (my $index = 0; $index < @selectors; ++$index) {
  my $selector = $selectors[$index];
  my $expected = $selector->{expected};
  my $key = $selector->{key};
  my $actual = _runtime_kind($cursor);
  if ($actual ne $expected) {
   _nested_write_error(
    code => 'nested_write_kind_conflict',
    operation => 'nested_write_vivification',
    binding => $identifier,
    segment_index => $index,
    path => _clone_value(\@prefix),
    expected_kind => $expected,
    actual_kind => $actual,
    source_span => _clone_value($selector->{source_span}),
    message => "nested write segment $index for binding '$identifier' requires $expected; found $actual",
   );
  }

  my $last = $index == $#selectors;
  if ($expected eq 'harray') {
   if ($last) {
    $cursor->{$key} = _clone_value($rhs_value);
   } else {
    $cursor->{$key} = $selectors[$index + 1]{expected} eq 'array' ? [] : {}
     unless exists $cursor->{$key};
    $cursor = $cursor->{$key};
   }
  } else {
   my $length = scalar @$cursor;
   if ($key > $length) {
    _nested_write_error(
     code => 'nested_write_array_gap',
     operation => 'nested_write_vivification',
     binding => $identifier,
     segment_index => $index,
     path => _clone_value(\@prefix),
     index => 0 + $key,
     length => $length,
     source_span => _clone_value($selector->{source_span}),
     message => "nested write segment $index for binding '$identifier' cannot create array index $key at length $length",
    );
   }
   if ($last) {
    if ($key == $length) {
     push @$cursor, _clone_value($rhs_value);
    } else {
     $cursor->[$key] = _clone_value($rhs_value);
    }
   } else {
    push @$cursor, ($selectors[$index + 1]{expected} eq 'array' ? [] : {}) if $key == $length;
    $cursor = $cursor->[$key];
   }
  }
  push @prefix, _clone_value($key);
 }

 my $committed = _clone_value($work);
 return ($committed, _clone_value($work))
}

sub _kind {
 my ($value) = @_;
 return 'array' if ref($value) eq 'ARRAY';
 return 'codeblock'
  if ref($value) eq 'HASH'
  && ($value->{kind} // '') eq 'codeblock_literal';
 return 'harray' if ref($value) eq 'HASH';
 return 'scalar'
}

sub _kind_mismatch {
 my ($identifier, $expected, $value) = @_;
 $identifier = '<unknown>' unless defined($identifier) && length($identifier);
 my $actual = _kind($value);
 die "binding_kind_mismatch identifier=$identifier expected_kind=$expected actual_kind=$actual\n"
}

sub push_value {
 my ($binding, $identifier, $value) = @_;
 $binding = [] unless defined $binding;
 _kind_mismatch($identifier, 'array', $binding) unless ref($binding) eq 'ARRAY';
 my @updated = @$binding;
 push @updated, $value;
 return \@updated
}

sub split_value {
 my ($binding, $identifier, $source, $delimiter) = @_;
 _kind_mismatch($identifier, 'array', $binding)
  if defined($binding) && ref($binding) ne 'ARRAY';
 $source = '' unless defined $source;
 my @parts;
 if (ref($delimiter) eq 'Regexp') {
  @parts = split $delimiter, $source;
 } else {
  my $literal = defined($delimiter) ? $delimiter : '';
  @parts = length($literal) ? split(/\Q$literal\E/, $source) : ($source);
 }
 return \@parts
}

sub index_set {
 my ($binding, $identifier, $key, $value) = @_;
 $binding = {} unless defined $binding;
 if (ref($binding) eq 'HASH') {
  my %updated = %$binding;
  $updated{$key} = $value;
  return \%updated;
 } elsif (ref($binding) eq 'ARRAY'
       && defined($key)
       && $key =~ /\A\d+\z/
       && $key >= 0
       && $key <= @$binding) {
  my @updated = @$binding;
  if ($key == @updated) {
   push @updated, $value;
  } else {
   splice @updated, $key, 1, $value;
  }
  return \@updated;
 } else {
  _kind_mismatch($identifier, 'harray', $binding);
 }
 return $binding
}

sub array_transform {
 my ($binding, $identifier, $operation, @args) = @_;
 $binding = [] unless defined $binding;
 _kind_mismatch($identifier, 'array', $binding) unless ref($binding) eq 'ARRAY';
 my @values = @$binding;

 if ($operation eq 'trim_each') {
  @values = map { my $value = defined($_) ? $_ : ''; $value =~ s/^\s+|\s+$//g; $value } @values;
 } elsif ($operation eq 'filter_nonempty') {
  @values = grep { defined($_) && length($_) } @values;
 } elsif ($operation eq 'lowercase_each') {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::UnicodeCaseMapping');
  @values = map { LinkedSpec::UnicodeCaseMapping::lowercase($_) } @values;
 } elsif ($operation eq 'uppercase_each') {
  LinkedSpec::OwnerDispatch::require_pkg(__PACKAGE__, 'LinkedSpec::UnicodeCaseMapping');
  @values = map { LinkedSpec::UnicodeCaseMapping::uppercase($_) } @values;
 } elsif ($operation eq 'uniq') {
  my %seen;
  @values = grep { !$seen{defined($_) ? "D\0$_" : "U\0"}++ } @values;
 } elsif ($operation eq 'sorted') {
  @values = sort { (defined($a) ? $a : '') cmp (defined($b) ? $b : '') } @values;
 } elsif ($operation eq 'reversed') {
  @values = reverse @values;
 } elsif ($operation eq 'filter_match') {
  my $pattern = $args[0];
  die "binding array filter requires a regex pattern\n" unless ref($pattern) eq 'Regexp';
  @values = grep { defined($_) && $_ =~ $pattern } @values;
 } elsif ($operation eq 'split_each') {
  my $delimiter = $args[0];
  my @split_values;
  foreach my $value (@values) {
   $value = '' unless defined $value;
   if (ref($delimiter) eq 'Regexp') {
    push @split_values, split $delimiter, $value;
   } else {
    my $literal = defined($delimiter) ? $delimiter : '';
    push @split_values, length($literal) ? split(/\Q$literal\E/, $value) : $value;
   }
  }
  @values = @split_values;
 } else {
  die "unsupported binding array transform '$operation'\n";
 }

 return \@values
}

sub array_end_mutation {
 my ($binding, $identifier, $operation, @args) = @_;
 $binding = [] unless defined $binding;
 _kind_mismatch($identifier, 'array', $binding) unless ref($binding) eq 'ARRAY';
 my @updated = @$binding;
 if ($operation eq 'push_back') {
  push @updated, $args[0];
 } elsif ($operation eq 'push_front') {
  unshift @updated, $args[0];
 } elsif ($operation eq 'pop_back') {
  pop @updated;
 } elsif ($operation eq 'pop_front') {
  shift @updated;
 } else {
  die "unsupported binding array end mutation '$operation'\n";
 }
 return \@updated
}

package LinkedSpec::BindingRuntime::NestedWriteError;

use overload '""' => sub { return $_[0]{message} // $_[0]{code} // 'nested write failed' }, fallback => 1;

1;
