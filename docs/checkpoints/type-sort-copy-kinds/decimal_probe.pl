use strict;
use warnings;
use B ();
use JSON::PP ();
use Storable ();
use LinkedSpec::BindingRuntime ();

sub flags {
 my ($values) = @_;
 return [map {
  my $bits = B::svref_2object(\$_)->FLAGS;
  +{iOK => ($bits & B::SVp_IOK()) ? 1 : 0,
    nOK => ($bits & B::SVp_NOK()) ? 1 : 0,
    pOK => ($bits & B::SVp_POK()) ? 1 : 0}
 } @$values];
}

my @rows;
for my $operation (qw(assignment copied-sort binding clone)) {
 my $input = [2.5,10.25,-1.5,0];
 my $before = flags($input);
 my $result;
 if ($operation eq 'assignment') {
  my @values = @$input;
  $result = \@values;
 } elsif ($operation eq 'copied-sort') {
  my @values = @$input;
  @values = sort {
   my ($left, $right) = ($a, $b);
   (defined($left) ? $left : '') cmp (defined($right) ? $right : '')
  } @values;
  $result = \@values;
 } elsif ($operation eq 'binding') {
  $result = LinkedSpec::BindingRuntime::array_transform($input, 'items', 'sorted');
 } else {
  $result = Storable::dclone($input);
 }
 push @rows, {operation => $operation, before => $before,
  input_flags => flags($input), result_flags => flags($result), value => $result};
}
print JSON::PP->new->canonical->encode({rows => \@rows, perl => "$^V"}), "\n";
