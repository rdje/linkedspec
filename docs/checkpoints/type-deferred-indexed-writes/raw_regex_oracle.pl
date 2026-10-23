use strict;
use warnings;
use JSON::PP ();
local $/;
my $plan=JSON::PP->new->utf8->decode(<STDIN>);
my @rows;
for my $case (@{$plan->{cases}}) {
 local $_=$case->{input};
 my $authored=/(14,2) \}\ntail/ ? 1 : 0;
 my $inserted=/(14,2) \};\ntail/ ? 1 : 0;
 push @rows,{id=>$case->{id},authored=>$authored,inserted_semicolon=>$inserted};
}
print JSON::PP->new->canonical->encode({rows=>\@rows}),"\n";
