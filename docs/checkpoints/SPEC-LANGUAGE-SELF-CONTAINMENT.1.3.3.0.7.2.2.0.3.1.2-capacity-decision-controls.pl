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
for my $name (qw(exceeds_limits canonical_object numeric_increase limit_change_permitted adr_authorizes_limit_change)) {
    $source =~ /(^sub \Q$name\E \{.*?)(?=^sub |\z)/ms or die "missing actual function $name";
    $code .= $1;
}
eval $code;
die $@ if $@;
my $composition = $JSON->decode(read_bytes($prefix.'capacity-composition.json'));
my $old = $composition->{old_decision_limits};
my $new = $composition->{new_decision_limits};
my %files = map { $_ => read_bytes($_) } ($adr_path, 'docs/decisions/INDEX.md');
my @adrs = ($adr_path);
sub staged_new_adrs { return @adrs }
sub snapshot_content { return $files{$_[0]} }
my @thresholds;
for my $spec ([files => 'max_files'], [lines => 'max_total_lines']) {
    my ($metric, $key) = @$spec;
    for my $value ($new->{$key}-1, $new->{$key}, $new->{$key}+1) {
        for my $limit ($old->{$key}, $new->{$key}) {
            my @errors = exceeds_limits({$metric=>$value}, {$key=>$limit});
            die "actual $key independent threshold oracle" if !!@errors != ($value > $limit);
            push @thresholds, {metric=>$metric, value=>$value, limit=>$limit,
                              rejected=>@errors ? JSON::PP::true : JSON::PP::false, reasons=>\@errors};
        }
    }
}
my $check = sub { adr_authorizes_limit_change('decisions', $old, $new) };
die 'actual indexed exact decision authorization' unless $check->();
my %original = %files;
my @controls;
for my $case (qw(missing_new_record missing_index wrong_old_limits wrong_new_limits wrong_surface)) {
    %files = %original;
    @adrs = ($adr_path);
    if ($case eq 'missing_new_record') { @adrs = () }
    elsif ($case eq 'missing_index') { $files{'docs/decisions/INDEX.md'} = '' }
    elsif ($case eq 'wrong_surface') {
        $files{$adr_path} =~ s/^- Routed surface: `decisions`$/- Routed surface: `unrelated`/m or die 'surface mutation';
    } else {
        my $label = $case eq 'wrong_old_limits' ? 'Previous routed limits' : 'New routed limits';
        my $object = $case eq 'wrong_old_limits' ? $old : $new;
        my $marker = '- '.$label.': `'.$JSON->encode($object).'`';
        $files{$adr_path} =~ s/^\Q$marker\E$//m or die "mutation did not apply: $case";
    }
    die "authority mutation admitted: $case" if $check->();
    push @controls, {name=>$case, observed=>'RED', reason=>'actual exact indexed decision authorization rejects this missing/mismatched input'};
}
die 'unreviewed increase admitted' if limit_change_permitted($old, $new, 0);
die 'reviewed increase denied' unless limit_change_permitted($old, $new, 1);
push @controls, {name=>'unreviewed_increase', observed=>'RED', reason=>'actual numeric increase rejects absent reviewed authority'};
my $result = {complete=>JSON::PP::true, instrument_sha256=>sha256_hex(read_bytes(__FILE__)),
              production_sha256=>sha256_hex($source), thresholds=>\@thresholds, controls=>\@controls,
              scope=>'Actual unchanged production functions with exact in-memory decision fixtures. Twelve boundary observations and six rejecting controls; accepted-state diagnostics remain separately owned .3.1.3. Full resulting-tree and canonical admission remain required.'};
open my $out, '>:raw', $prefix.'capacity-decision-controls.json' or die $!;
print {$out} $JSON->pretty->encode($result);
print "Actual decision controls: twelve threshold observations and six authority RED controls PASS.\n";
