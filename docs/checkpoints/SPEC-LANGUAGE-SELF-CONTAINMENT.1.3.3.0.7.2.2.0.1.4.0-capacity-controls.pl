use v5.20;
use strict;
use warnings;
use JSON::PP ();
use Digest::SHA qw(sha256_hex);

my $JSON = JSON::PP->new->canonical(1);
my $INDEX_MODE = 1;
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-';
sub read_bytes { open my $fh, '<:raw', $_[0] or die $!; local $/; return <$fh> }
my $source = read_bytes('scripts/check_readme_routing_pressure.pl');
my $code = '';
for my $name (qw(exceeds_limits canonical_object numeric_increase limit_change_permitted adr_authorizes_limit_change adr_authorizes_contract_change)) {
    $source =~ /(^sub \Q$name\E \{.*?)(?=^sub |\z)/ms or die "missing actual function $name";
    $code .= $1;
}
eval $code; die $@ if $@;
my $proposal = $JSON->decode(read_bytes($prefix.'capacity-proposal.json'));
my $registry = read_bytes('doctrine/readme_stability/routes.jsonl');
my ($route) = grep { ($_->{id} // '') eq 'engineering_notes' } map { $JSON->decode($_) } split /\n/, $registry;
my $adr_path = 'docs/decisions/0127-legacy-diagnosis-note-capacity.md';
my %files = map { $_ => read_bytes($_) } ($adr_path, 'docs/decisions/INDEX.md');
my @adrs = ($adr_path);
sub staged_new_adrs { return @adrs }
sub snapshot_content { return $files{$_[0]} }
my @thresholds;
for my $spec ([files => 'max_files', 43, 44], [lines => 'max_lines', 42, 43], [bytes => 'max_bytes', 25410, 26021]) {
    my ($metric, $key, $old, $new) = @$spec;
    for my $value ($new-1, $new, $new+1) {
        for my $limit ($old, $new) {
            my @errors = exceeds_limits({$metric=>$value}, {$key=>$limit});
            die "actual $key threshold oracle" if !!@errors != ($value > $limit);
            push @thresholds, {metric=>$metric, value=>$value, limit=>$limit, rejected=>@errors ? JSON::PP::true : JSON::PP::false};
        }
    }
}
my $old_contract = {map { $_=>$route->{$_} } qw(authority control lifecycle member_limits members owner route_targets state verifier)};
$old_contract->{transition_owners} = $route->{transition}{owners};
my $new_contract = $JSON->decode($JSON->encode($old_contract));
$old_contract->{member_limits} = $proposal->{old_member_limits};
my @controls;
my $check = sub {
    return (adr_authorizes_limit_change('engineering_notes', $proposal->{old_limits}, $proposal->{new_limits}),
            adr_authorizes_contract_change('engineering_notes', $old_contract, $new_contract));
};
my @positive = $check->();
die 'actual indexed authorization' if !$positive[0] || !$positive[1];
my %original = %files;
for my $case (qw(missing_new_record missing_index wrong_old_limits wrong_new_limits wrong_old_contract wrong_new_contract)) {
    %files = %original; @adrs = ($adr_path);
    if ($case eq 'missing_new_record') { @adrs = () }
    elsif ($case eq 'missing_index') { $files{'docs/decisions/INDEX.md'} = '' }
    else {
        my %marker = (wrong_old_limits=>'Previous routed limits', wrong_new_limits=>'New routed limits',
                      wrong_old_contract=>'Previous routed contract', wrong_new_contract=>'New routed contract');
        my $marker = $marker{$case};
        $files{$adr_path} =~ s/^- \Q$marker\E:.*$//m or die 'mutation did not apply';
    }
    my @actual = $check->();
    my $leg = $case =~ /contract/ ? 1 : 0;
    die "authority mutation admitted $case" if $actual[$leg];
    push @controls, {name=>$case, observed=>'RED', reason=>'actual production indexed authorization rejected missing exact admission authority'};
}
die 'unreviewed increase admitted' if limit_change_permitted($proposal->{old_limits}, $proposal->{new_limits}, 0);
die 'reviewed increase denied' if !limit_change_permitted($proposal->{old_limits}, $proposal->{new_limits}, 1);
push @controls, {name=>'unreviewed_increase', observed=>'RED', reason=>'actual production numeric increase rejects absent reviewed authority'};
open my $out, '>:raw', $prefix.'capacity-controls.json' or die $!;
print {$out} $JSON->pretty->encode({complete=>JSON::PP::true, instrument_sha256=>sha256_hex(read_bytes(__FILE__)),
    production_sha256=>sha256_hex($source), thresholds=>\@thresholds, controls=>\@controls,
    scope=>'Exact unchanged production functions; in-memory authority fixtures model added indexed ADR inputs. Normal resulting-tree gate remains mandatory.'});
print "Actual production18 threshold observations and7 authority RED controls PASS\n";
