package LinkedSpecTest::MethodLocations;
use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my ($coordinates, %original);
sub _coordinates {
 return $coordinates if $coordinates;
 local $@;
 open my $pipe, '-|', 'bash', 'tools/run_python_project_data.sh', 't/lib/method_locations.py'
  or die "start method coordinate reader: $!";
 my $raw = do { local $/; <$pipe> };
 close $pipe or die "method coordinate reader failed: $?";
 my $value = JSON::PP->new->decode($raw);
 open my $source, '<:raw', $value->{source} or die "read method source: $!";
 my $bytes = do { local $/; <$source> };
 close $source or die "close method source: $!";
 die 'method coordinate/source identity mismatch'
  unless sha256_hex($bytes) eq $value->{current_sha256};
 for my $range (@{$value->{ranges}}) {
  for my $offset (0 .. $range->{count} - 1) {
   my $line = $range->{current} + $offset;
   die 'duplicate current source coordinate' if exists $original{$line};
   $original{$line} = $range->{before} + $offset;
  }
 }
 $coordinates = $value;
 return $coordinates;
}

sub original_line {
 my ($line) = @_;
 _coordinates();
 die "no unchanged MethodLowering statement for current line $line"
  unless exists $original{$line};
 return $original{$line};
}

sub original_coordinates {
 my ($value, $error_context) = @_;
 return [map {original_coordinates($_, $error_context)} @$value] if ref($value) eq 'ARRAY';
 return {map {$_ => original_coordinates($value->{$_}, /(?:^|_)error\z/ ? 1 : 0)} keys %$value}
  if ref($value) eq 'HASH';
 return $value if ref($value) || !defined($value) || !$error_context;
 my $copy = $value;
 $copy =~ s{(\bat [^\n]*?\bperl/LinkedSpec/ActionIR/MethodLowering\.pm line )(\d+)}{$1.original_line($2)}ge;
 return $copy;
}

1;
