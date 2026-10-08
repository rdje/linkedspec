use v5.20;
use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my $JSON = JSON::PP->new->canonical(1);
my $INDEX_MODE = 1;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-';
my $adr_path = 'docs/decisions/0128-replacement-note-history-capacity.md';
sub read_bytes {
    open my $fh, '<:raw', $_[0] or die "$_[0]: $!";
    local $/;
    return <$fh>;
}
my $source = read_bytes('scripts/check_readme_routing_pressure.pl');
my $code = '';
for my $name (qw(exceeds_limits canonical_object numeric_increase limit_change_permitted adr_authorizes_limit_change adr_authorizes_contract_change)) {
    $source =~ /(^sub \Q$name\E \{.*?)(?=^sub |\z)/ms or die "missing actual function $name";
    $code .= $1;
}
eval $code;
die $@ if $@;
my $plan = $JSON->decode(read_bytes($prefix.'capacity-plan.json'));
my %files = map { $_ => read_bytes($_) } ($adr_path, 'docs/decisions/INDEX.md');
my @adrs = ($adr_path);
sub staged_new_adrs { return @adrs }
sub snapshot_content { return $files{$_[0]} }
my @thresholds;
my $manifest = 'docs/history/development-notes/manifest.jsonl';
for my $spec ([files => 'max_files', $plan->{old_limits}{max_files}, $plan->{new_limits}{max_files}],
              [lines => 'max_lines', $plan->{old_member_limits}{$manifest}{max_lines}, $plan->{new_member_limits}{$manifest}{max_lines}],
              [bytes => 'max_bytes', $plan->{old_member_limits}{$manifest}{max_bytes}, $plan->{new_member_limits}{$manifest}{max_bytes}]) {
    my ($metric, $key, $old, $new) = @$spec;
    for my $value ($new-1, $new, $new+1) {
        for my $limit ($old, $new) {
            my @errors = exceeds_limits({$metric=>$value}, {$key=>$limit});
            die "actual $key independent threshold oracle" if !!@errors != ($value > $limit);
            push @thresholds, {metric=>$metric, value=>$value, limit=>$limit,
                              rejected=>@errors ? JSON::PP::true : JSON::PP::false, reasons=>\@errors};
        }
    }
}
my $check = sub {
    return (adr_authorizes_limit_change('engineering_notes', $plan->{old_limits}, $plan->{new_limits}),
            adr_authorizes_contract_change('engineering_notes', $plan->{old_contract}, $plan->{new_contract}));
};
my @positive = $check->();
die 'actual indexed exact authorization' unless $positive[0] && $positive[1];
my %original = %files;
my @controls;
for my $case (qw(missing_new_record missing_index wrong_old_limits wrong_new_limits wrong_old_contract wrong_new_contract)) {
    %files = %original;
    @adrs = ($adr_path);
    if ($case eq 'missing_new_record') { @adrs = () }
    elsif ($case eq 'missing_index') { $files{'docs/decisions/INDEX.md'} = '' }
    else {
        my %marker = (wrong_old_limits=>'Previous routed limits', wrong_new_limits=>'New routed limits',
                      wrong_old_contract=>'Previous routed contract', wrong_new_contract=>'New routed contract');
        $files{$adr_path} =~ s/^- \Q$marker{$case}\E:.*$//m or die "mutation did not apply: $case";
    }
    my @actual = $check->();
    my $leg = $case =~ /contract/ ? 1 : 0;
    die "authority mutation admitted: $case" if $actual[$leg];
    push @controls, {name=>$case, observed=>'RED', reason=>'actual exact indexed authorization rejected the distinguishing missing/mismatched input'};
}
die 'unreviewed increase admitted' if limit_change_permitted($plan->{old_limits}, $plan->{new_limits}, 0);
die 'reviewed increase denied' unless limit_change_permitted($plan->{old_limits}, $plan->{new_limits}, 1);
push @controls, {name=>'unreviewed_increase', observed=>'RED', reason=>'actual numeric increase rejects absent reviewed authority'};

# Observe the accepted-state requirement independently of exact routing markers.
# These are retained diagnostics, not claimed rejection controls or a checker repair.
my @status_observations;
for my $case (qw(proposed_status missing_status)) {
    %files = %original;
    @adrs = ($adr_path);
    if ($case eq 'proposed_status') {
        $files{$adr_path} =~ s/^- Status:.*$/- Status: proposed; not accepted/m or die 'proposed status mutation';
    } else {
        $files{$adr_path} =~ s/^- Status:.*$//m or die 'missing status mutation';
    }
    my @actual = $check->();
    push @status_observations, {name=>$case,
        limit_authorized=>$actual[0] ? JSON::PP::true : JSON::PP::false,
        contract_authorized=>$actual[1] ? JSON::PP::true : JSON::PP::false,
        source_location=>'scripts/check_readme_routing_pressure.pl:adr_authorizes_limit_change/adr_authorizes_contract_change'};
}
my $result = {complete=>JSON::PP::true, instrument_sha256=>sha256_hex(read_bytes(__FILE__)),
              production_sha256=>sha256_hex($source), thresholds=>\@thresholds, controls=>\@controls,
              status_observations=>\@status_observations,
              scope=>'Actual unchanged production functions and in-memory exact ADR/index fixtures. Status diagnostics remain separate from the seven rejecting controls; resulting-tree doctrines and canonical admission remain required.'};
open my $out, '>:raw', $prefix.'capacity-controls.json' or die $!;
print {$out} $JSON->pretty->encode($result);
print "Actual production18 changed-threshold observations and7 exact-authority RED controls retained; accepted-state diagnostics retained separately.\n";
