use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();

open my $fh, '<', 'tests/fixtures/count_result_guard_source_owner_cases.json' or die $!;
my $rows = JSON::PP->new->decode(do { local $/; <$fh> });
close $fh or die $!;
my $json = JSON::PP->new->canonical;
for my $row (@$rows) {
    my $source = $row->{source};
    my $native = LinkedSpec::Get(\$source);
    my $text = $row->{input};
    my $native_value = $native->(\$text);
    my $emitted = LinkedSpec::emit_generated_source(\$source,
        source_identity => 'count-source-owner.spec');
    eval 'package LinkedSpec::CountSourceOwnerReference; '.$emitted;
    die $@ if $@;
    my $fresh_text = $row->{input};
    my $fresh_value = LinkedSpec::CountSourceOwnerReference->can('Execute')->(\$fresh_text);
    print 'PERL_COUNT_SOURCE_OWNER '.$row->{id}.' '.$json->encode([$native_value, $fresh_value])."\n";
    die 'source owner mismatch' unless $json->encode($native_value) eq $json->encode($row->{expected})
        && $json->encode($fresh_value) eq $json->encode($row->{expected});
}
