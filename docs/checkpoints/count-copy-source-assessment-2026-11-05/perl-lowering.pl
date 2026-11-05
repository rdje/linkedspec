use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my $base='docs/checkpoints/count-copy-source-assessment-2026-11-05';
open my $input, '<', "$base/cases.json" or die $!;
my $rows=JSON::PP->new->decode(do {local $/;<$input>});close $input or die $!;
my $json=JSON::PP->new->canonical;
for my $row (@$rows) {
    next unless $row->{id} =~ /\A(?:rejection_through_copy|legitimate_null_through_copy|repeated_count_after_copy)\z/;
    my $body=$row->{source};
    $body =~ s/\AValue:: I \{// or die 'unexpected source prefix';
    $body =~ s/\}\z// or die 'unexpected source suffix';
    my $lowered=LinkedSpec::call_spec_handler_subst('Value',$body);
    print 'COUNT_COPY_PERL_LOWERING '.$row->{id}.' '.$json->encode({source=>$row->{source},body=>$body,lowered=>$lowered})."\n";
}
