use v5.20;
use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my $JSON = JSON::PP->new->canonical(1);
my $INDEX_MODE = 1;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0-';
my $adr = 'docs/decisions/0129-producer-residual-change-history-capacity.md';
sub read_bytes {
    open my $fh, '<:raw', $_[0] or die "$_[0]: $!";
    local $/;
    return <$fh>;
}
my $source = read_bytes('scripts/check_readme_routing_pressure.pl');
my $code = '';
for my $name (qw(exceeds_limits canonical_object numeric_increase limit_change_permitted adr_is_accepted adr_authorizes_limit_change adr_authorizes_contract_change)) {
    $source =~ /(^sub \Q$name\E \{.*?)(?=^sub |\z)/ms or die "missing actual function $name";
    $code .= $1;
}
eval $code;
die $@ if $@;
my $plan = $JSON->decode(read_bytes($prefix.'plan.json'));
my %files = map { $_ => read_bytes($_) } ($adr, 'docs/decisions/INDEX.md');
my %original = %files;
my @adrs = ($adr);
sub staged_new_adrs { return @adrs }
sub snapshot_content { return $files{$_[0]} }
my $check = sub {
    my $old_contract = {map { $_ => $plan->{old_change}{$_} } qw(authority control lifecycle member_limits members owner route_targets state verifier)};
    my $new_contract = {map { $_ => $plan->{new_change}{$_} } qw(authority control lifecycle member_limits members owner route_targets state verifier)};
    $old_contract->{transition_owners} = undef;
    $new_contract->{transition_owners} = undef;
    return (adr_authorizes_limit_change('change_history', $plan->{old_change}{limits}, $plan->{new_change}{limits}),
            adr_authorizes_contract_change('change_history', $old_contract, $new_contract),
            adr_authorizes_limit_change('decisions', $plan->{old_decisions}{limits}, $plan->{new_decisions}{limits}));
};
die 'positive exact accepted authority' if grep { !$_ } $check->();
my @controls;
for my $name (qw(missing_new_adr missing_index proposed_status missing_status duplicate_status malformed_status wrong_limits wrong_contract)) {
    %files = %original;
    @adrs = ($adr);
    if ($name eq 'missing_new_adr') { @adrs = () }
    elsif ($name eq 'missing_index') { $files{'docs/decisions/INDEX.md'} = '' }
    elsif ($name eq 'proposed_status') { $files{$adr} =~ s/^- Status:.*$/- Status: proposed/m or die $name }
    elsif ($name eq 'missing_status') { $files{$adr} =~ s/^- Status:.*$//m or die $name }
    elsif ($name eq 'duplicate_status') { $files{$adr} .= "\n- Status: accepted\n" }
    elsif ($name eq 'malformed_status') { $files{$adr} =~ s/^- Status:.*$/- Status: acceptedness/m or die $name }
    elsif ($name eq 'wrong_limits') { $files{$adr} =~ s/^- New routed limits:.*$//mg or die $name }
    elsif ($name eq 'wrong_contract') { $files{$adr} =~ s/^- New routed contract:.*$//m or die $name }
    my @actual = $check->();
    my @selected = $name eq 'wrong_limits' ? @actual[0,2] : $name eq 'wrong_contract' ? ($actual[1]) : @actual;
    die "authority mutation admitted: $name" if grep { $_ } @selected;
    push @controls, {name=>$name, observed=>'RED', actual_authorizations=>\@actual};
}
my @thresholds;
my $manifest = 'docs/history/changes/manifest.jsonl';
for my $spec (
    ['files','max_files',$plan->{old_change}{limits}{max_files},$plan->{new_change}{limits}{max_files}],
    ['lines','max_lines',$plan->{old_change}{member_limits}{$manifest}{max_lines},$plan->{new_change}{member_limits}{$manifest}{max_lines}],
    ['bytes','max_bytes',$plan->{old_change}{member_limits}{$manifest}{max_bytes},$plan->{new_change}{member_limits}{$manifest}{max_bytes}],
    ['files','max_files',$plan->{old_decisions}{limits}{max_files},$plan->{new_decisions}{limits}{max_files}],
    ['lines','max_total_lines',$plan->{old_decisions}{limits}{max_total_lines},$plan->{new_decisions}{limits}{max_total_lines}]) {
    my ($metric,$key,$old,$new) = @$spec;
    for my $limit ($old,$new) {
        for my $value ($new-1,$new,$new+1) {
            my @errors = exceeds_limits({$metric=>$value}, {$key=>$limit});
            die "threshold oracle $key" if !!@errors != ($value > $limit);
            push @thresholds, {metric=>$metric,key=>$key,value=>$value,limit=>$limit,rejected=>@errors ? JSON::PP::true : JSON::PP::false};
        }
    }
}
die 'unreviewed increase admitted' if limit_change_permitted($plan->{old_change}{limits},$plan->{new_change}{limits},0);
my $result = {complete=>JSON::PP::true, controls=>\@controls, thresholds=>\@thresholds,
              production_sha256=>sha256_hex($source), producer_sha256=>sha256_hex(read_bytes(__FILE__))};
open my $out, '>:raw', $prefix.'controls.json' or die $!;
print {$out} $JSON->pretty->encode($result);
print "Actual production: 30 threshold observations and 8 authority RED controls pass.\n";
