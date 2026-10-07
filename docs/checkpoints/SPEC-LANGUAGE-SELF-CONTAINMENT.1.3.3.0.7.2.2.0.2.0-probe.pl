use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec ();
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Scanner ();
use LinkedSpec::ActionIR::ScannerCore ();

my $mode = shift @ARGV // '';
die "mode must be before or after\n" unless $mode eq 'before' || $mode eq 'after';
require LinkedSpec::ActionIR::SourceMembership if $mode eq 'after';
my $prefix = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-';
open my $file, '<:raw', $prefix.'cases.json' or die $!;
my $json = JSON::PP->new->canonical->utf8;
my $cases = $json->decode(do { local $/; <$file> });
close $file or die $!;
my $deps = LinkedSpec::ActionIR::Scanner::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my @rows;
for my $case (@$cases) {
    my $source = $case->{source};
    my $scan = LinkedSpec::ActionIR::ScannerCore::_scan_contract_ir_events_with_provenance(
        {id => $case->{contract}}, $source, $deps);
    my $original = $json->encode($scan);
    my $selected = $mode eq 'before' ? $scan
        : LinkedSpec::ActionIR::SourceMembership::_select_executable_source_events($source, $scan);
    my (@indices, @identities);
    for my $event (@{$selected->{events}}) {
        my @matches = grep { refaddr($scan->{events}[$_]) == refaddr($event) } 0 .. $#{$scan->{events}};
        push @indices, @matches == 1 ? $matches[0] : undef;
        push @identities, @matches == 1
            && refaddr($event->{args}) == refaddr($scan->{events}[$matches[0]]{args}) ? 1 : 0;
    }
    push @rows, {id => $case->{id}, source => $source,
        original_scan => $json->decode($original), selected_scan => $selected,
        selected_indices => \@indices, original_argument_references => \@identities,
        original_untouched => $original eq $json->encode($scan) ? 1 : 0,
        source_untouched => $source eq $case->{source} ? 1 : 0,
        unchanged_result_reference => refaddr($selected) == refaddr($scan) ? 1 : 0};
}
binmode STDOUT, ':raw';
print $json->encode({mode => $mode, cases => \@rows}), "\n";
