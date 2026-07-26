#!/usr/bin/env bash
# scripts/check_task_tree_metadata.sh — narrow task-tree metadata consistency gate.
#
# This check intentionally avoids historical prose and leaf commit backfill fields.
# It enforces only a low-noise invariant: a task file whose top-level metadata says
# done/completed/exhausted must not still advertise a live Current Frontier row.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$ROOT/scripts/check_task_tree_metadata.sh" "$@"
cd "$ROOT"

perl - <<'PERL' docs/tasks/*.md
use strict;
use warnings;

my @bad;

for my $file (@ARGV) {
    open my $fh, '<', $file or die "cannot read $file: $!\n";
    local $/;
    my $text = <$fh>;

    my ($top_status) = $text =~ /^- Status: `([^`]+)`/m;
    next unless defined $top_status;
    next unless $top_status =~ /^(?:done|completed|exhausted)\b/;

    next unless $text =~ /^## Current Frontier\n(.*?)(?:\n## |\z)/ms;
    my $frontier = $1;

    for my $line (split /\n/, $frontier) {
        next unless $line =~ /^\|/;
        next if $line =~ /^\|\s*-+/;

        my @cells = map {
            my $cell = $_;
            $cell =~ s/^\s+|\s+$//g;
            $cell;
        } split /\|/, $line;
        next unless @cells >= 5;

        my $status = $cells[3];
        next unless $status =~ /^`(?:pending|active|in_progress|blocked)`/;

        push @bad, "$file: completed top status `$top_status` but Current Frontier has live status cell: $line";
    }
}

if (@bad) {
    print STDERR "task-tree-metadata: completed task trees must not advertise live Current Frontier rows\n";
    print STDERR "task-tree-metadata: explicitly deferred rows should use `deferred`, and active work belongs in an active tree\n";
    print STDERR "$_\n" for @bad;
    exit 1;
}

print "task-tree-metadata: OK (completed trees have no live Current Frontier rows)\n";
PERL
