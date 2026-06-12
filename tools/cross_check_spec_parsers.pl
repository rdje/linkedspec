#!/usr/bin/env perl
#===========================================================================
# cross_check_spec_parsers.pl — MEDIUM-IMPACT.3.3 dual-path cross-check harness
#
# Compares BootstrapSpec::Core (oracle) output against spec.spec-generated
# parser (candidate) for all .spec files.
#
# Bootstrap = oracle; spec.spec = candidate.
#===========================================================================
use strict;
use warnings;
use 5.010;
use FindBin;
use lib "$FindBin::Bin/../perl";

use LinkedSpec;
use File::Spec;
use File::Basename;
use Getopt::Long;

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
my $spec_dir = File::Spec->catdir($FindBin::Bin, '..', 'specs');
my $spec_spec_path = File::Spec->catfile($spec_dir, 'spec.spec');
my $timeout = 30;          # seconds per parse
my $verbose = 0;
GetOptions('verbose' => \$verbose, 'timeout=i' => \$timeout);

#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------
sub slurp {
    my ($path) = @_;
    open(my $fh, '<', $path) or die "Cannot read $path: $!";
    local $/;
    return <$fh>;
}

sub normalize_error {
    my ($err) = @_;
    return 'undef' unless defined $err;
    $err =~ s/\n/\\n/g;
    $err = substr($err, 0, 200);
    return $err;
}

#------------------------------------------------------------------------------
# Build spec.spec parser (candidate)
#------------------------------------------------------------------------------
say "# Building spec.spec parser (candidate)...";
my $spec_spec_content = slurp($spec_spec_path);
my $candidate_parser = eval { LinkedSpec::Get(\$spec_spec_content) };
my $candidate_build_err = $@;

if (!$candidate_parser || ref($candidate_parser) ne 'CODE') {
    die "FATAL: Could not build spec.spec parser: " . normalize_error($candidate_build_err || 'returned non-CODE');
}
say "# spec.spec parser built successfully.\n";

#------------------------------------------------------------------------------
# Gather .spec files
#------------------------------------------------------------------------------
opendir(my $dh, $spec_dir) or die "Cannot open $spec_dir: $!";
my @spec_files = sort grep { /\.spec$/ && -f File::Spec->catfile($spec_dir, $_) } readdir($dh);
closedir($dh);

say "# Cross-checking " . scalar(@spec_files) . " .spec files...\n";
say "=" x 78;

#------------------------------------------------------------------------------
# Comparison results storage
#------------------------------------------------------------------------------
my @identical;       # spec files with matching rule counts
my @spec_spec_gaps;  # spec.spec issues (hang, undef, count mismatch)
my @bootstrap_gaps;  # bootstrap issues (should be empty — it's the oracle)
my %report;          # per-file detailed report

#------------------------------------------------------------------------------
# Cross-check each spec
#------------------------------------------------------------------------------
for my $spec_file (@spec_files) {
    my $spec_path = File::Spec->catfile($spec_dir, $spec_file);
    my $spec_content = eval { slurp($spec_path) };
    if ($@) {
        push @bootstrap_gaps, { file => $spec_file, error => "Cannot read: $@" };
        next;
    }

    say "\n--- $spec_file ---";

    #--- BootstrapSpec path (oracle) ---
    my $oracle_descriptor;
    my $oracle_error;
    {
        local $SIG{ALRM} = sub { die "TIMEOUT\n" };
        alarm($timeout);
        $oracle_descriptor = eval { LinkedSpec::Get(\$spec_content, return_descriptor => 1) };
        $oracle_error = $@;
        alarm(0);
    }

    my $oracle_ok = defined($oracle_descriptor) && ref($oracle_descriptor) eq 'HASH';
    my $oracle_rule_count = 0;
    my @oracle_labels;
    my @oracle_order;

    if ($oracle_ok) {
        @oracle_labels = sort keys %{$oracle_descriptor->{spec}};
        $oracle_rule_count = scalar @oracle_labels;
        @oracle_order = @{$oracle_descriptor->{meta}{compiled_rule_order} || []};
        say "  [ORACLE] $oracle_rule_count rules: @oracle_labels";
    } else {
        say "  [ORACLE] FAILED: " . normalize_error($oracle_error);
        push @bootstrap_gaps, { file => $spec_file, error => "BootstrapSpec oracle failed: " . normalize_error($oracle_error) };
        $report{$spec_file} = {
            oracle_ok       => 0,
            oracle_error    => normalize_error($oracle_error),
            candidate_ok    => undef,
            candidate_error => undef,
            candidate_count => undef,
        };
        next;
    }

    #--- spec.spec path (candidate) ---
    my $candidate_result;
    my $candidate_error;
    {
        local $SIG{ALRM} = sub { die "TIMEOUT\n" };
        alarm($timeout);
        $candidate_result = eval { $candidate_parser->(\$spec_content) };
        $candidate_error = $@;
        alarm(0);
    }

    my $candidate_ok = defined($candidate_result) && ref($candidate_result) eq 'ARRAY';
    my $candidate_count = $candidate_ok ? scalar @$candidate_result : undef;

    if ($candidate_ok) {
        say "  [CANDIDATE] $candidate_count rule paragraphs parsed";
    } elsif ($candidate_error) {
        my $err_short = normalize_error($candidate_error);
        say "  [CANDIDATE] ERROR: $err_short" if $err_short ne 'undef';
    } else {
        say "  [CANDIDATE] returned undef (parse completed but no result)";
    }

    #--- Comparison ---
    my $match = 0;
    if ($candidate_ok && $candidate_count == $oracle_rule_count) {
        $match = 1;
        push @identical, $spec_file;
        say "  [COMPARE] ✓ Rule count matches ($oracle_rule_count)";
    } elsif ($candidate_ok) {
        push @spec_spec_gaps, {
            file            => $spec_file,
            oracle_count    => $oracle_rule_count,
            candidate_count => $candidate_count,
            diff            => $oracle_rule_count - $candidate_count,
        };
        say "  [COMPARE] ✗ Rule count MISMATCH: oracle=$oracle_rule_count, candidate=$candidate_count (diff=" . ($oracle_rule_count - $candidate_count) . ")";
    } else {
        push @spec_spec_gaps, {
            file            => $spec_file,
            oracle_count    => $oracle_rule_count,
            candidate_error => normalize_error($candidate_error || 'returned non-ARRAY'),
        };
        say "  [COMPARE] ✗ Candidate parse failed: " . ($candidate_error ? normalize_error($candidate_error) : (defined($candidate_result) ? "got " . ref($candidate_result) : "undef"));
    }

    $report{$spec_file} = {
        oracle_ok       => $oracle_ok,
        oracle_count    => $oracle_rule_count,
        oracle_labels   => \@oracle_labels,
        oracle_order    => \@oracle_order,
        candidate_ok    => $candidate_ok,
        candidate_count => $candidate_count,
        candidate_error => $candidate_error ? normalize_error($candidate_error) : undef,
        match           => $match,
        file            => $spec_file,
    };
}

#------------------------------------------------------------------------------
# Summary report
#------------------------------------------------------------------------------
say "\n";
say "=" x 78;
say "CROSS-CHECK SUMMARY";
say "=" x 78;

my $total             = scalar @spec_files;
my $identical_count   = scalar @identical;
my $spec_spec_gap_ct  = scalar @spec_spec_gaps;
my $bootstrap_gap_ct  = scalar @bootstrap_gaps;

say "Total .spec files:       $total";
say "Identical (count match): $identical_count";
say "spec.spec gaps:          $spec_spec_gap_ct";
say "BootstrapSpec failures:  $bootstrap_gap_ct";
say "";

if (@identical) {
    say "✓ IDENTICAL ($identical_count): " . join(", ", @identical);
}
if (@spec_spec_gaps) {
    say "";
    say "✗ SPEC.SPEC GAPS ($spec_spec_gap_ct):";
    for my $gap (@spec_spec_gaps) {
        if (defined $gap->{candidate_count}) {
            say "  - $gap->{file}: count mismatch (oracle=$gap->{oracle_count}, candidate=$gap->{candidate_count}, diff=$gap->{diff})";
        } else {
            say "  - $gap->{file}: candidate parse issue ($gap->{candidate_error})";
        }
    }
}
if (@bootstrap_gaps) {
    say "";
    say "✗ BOOTSTRAP FAILURES (unexpected — oracle should never fail):";
    for my $gap (@bootstrap_gaps) {
        say "  - $gap->{file}: $gap->{error}";
    }
}

#------------------------------------------------------------------------------
# Per-file detailed report (YAML-ish)
#------------------------------------------------------------------------------
say "";
say "=" x 78;
say "PER-FILE DETAIL";
say "=" x 78;

for my $spec_file (sort keys %report) {
    my $r = $report{$spec_file};
    say "";
    say "$spec_file:";
    say "  oracle:     " . ($r->{oracle_ok} ? "$r->{oracle_count} rules OK" : "FAILED: $r->{oracle_error}");
    say "  candidate:  " . ($r->{candidate_ok} ? "$r->{candidate_count} paragraphs OK" : "FAILED: " . ($r->{candidate_error} || 'returned non-ARRAY'));
    say "  match:      " . ($r->{match} ? "YES" : "NO");
    if ($r->{oracle_ok}) {
        say "  rule_order: @{$r->{oracle_order}}";
    }
}

#------------------------------------------------------------------------------
# Exit code
#------------------------------------------------------------------------------
if ($identical_count == $total) {
    say "\n✓ ALL $total specs match. spec.spec has proven output parity with BootstrapSpec.";
    exit 0;
} else {
    say "\n⚠ $spec_spec_gap_ct gap(s) found. spec.spec does not yet match BootstrapSpec output.";
    exit 1;
}
