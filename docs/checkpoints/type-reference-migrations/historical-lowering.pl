use strict;
use warnings;
use JSON::PP;
local $/;
my $input = decode_json(<STDIN>);
eval $input->{function};
die $@ if $@;
my $contracts = _build_return_contracts('Top', {});
my @rows;
for my $id (qw(return_a return_m return_ma)) {
 my ($contract) = grep { $_->{id} eq $id } @$contracts;
 my @bodies = $id eq 'return_a' ? ('return_a(Top)', 'return_a(Top, "extra")') : ($id . '(Top)');
 for my $body (@bodies) {
  my $lowered = $contract->{lower}->($body);
  my @Top = ('seed');
  my @IMATCH_LIST = ('ab', 'c');
  my $function = eval "sub { $lowered }";
  die $@ if $@;
  my $value = $function->();
  my $before = JSON::PP->new->canonical->encode($value);
  push @Top, 'later';
  push @IMATCH_LIST, 'group-later';
  push @rows, {body => $body, lowered => $lowered, before => decode_json($before), after => $value};
 }
}
print JSON::PP->new->canonical->encode(\@rows), "\n";
