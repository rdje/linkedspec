package LinkedSpec::BindingRuntime;

use strict;
use warnings;

use LinkedSpec::OwnerDispatch ();

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

1;
