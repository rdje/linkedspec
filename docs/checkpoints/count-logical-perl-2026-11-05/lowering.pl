use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my $base='tests/fixtures';
open my $input, '<', "$base/count_logical_source_cases.json" or die $!;
my $rows=JSON::PP->new->decode(do {local $/;<$input>});close $input or die $!;
my $json=JSON::PP->new->canonical;
for my $row (@$rows) {
    next unless $row->{id} =~ /\A(?:rejected_copy_logical|valid_null_copy_logical|rejected_not_with)\z/;
    my $body=$row->{source};
    $body =~ s/\AValue:: I \{// or die 'unexpected source prefix';
    $body =~ s/\}\z// or die 'unexpected source suffix';
    my $lowered=LinkedSpec::call_spec_handler_subst('Value',$body);
    print 'COUNT_LOGICAL_PERL_LOWERING '.$row->{id}.' '.$json->encode({source=>$row->{source},body=>$body,lowered=>$lowered})."\n";
}
