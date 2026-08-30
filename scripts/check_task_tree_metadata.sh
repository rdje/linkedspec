#!/usr/bin/env bash
# scripts/check_task_tree_metadata.sh — narrow task-tree metadata consistency gate.
#
# This check intentionally avoids broad historical prose and leaf commit backfill.
# It enforces four low-noise invariant groups:
#   1. a completed task file must not advertise a live Current Frontier row; and
#   2. a pending node must not claim task-tree-first activation or name another
#      node from the same tree as its own Commit evidence; and
#   3. every exact current task ID is repository-wide unique across partitioned
#      and unpartitioned storage, excluding only index-registered immutable history; and
#   4. checker-owned closed-capability facts stay in their stable task-index
#      section, outside mutable current-frontier rows.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$ROOT/scripts/check_task_tree_metadata.sh" "$@"
cd "$ROOT"

perl scripts/check_task_tree_partitions.pl
perl scripts/check_task_tree_current_ids.pl

perl - <<'PERL' docs/tasks/*.md
use strict;
use warnings;

my @bad;

sub pending_node_errors {
    my ($file, $text) = @_;
    my @errors;

    while ($text =~ /^- ID: `([^`]+)`\n(.*?)(?=^- ID: `|\z)/msg) {
        my ($id, $body) = ($1, $2);
        next unless $body =~ /^  Status: `pending`\s*$/m;

        my ($verification) = $body =~ /^  Verification:[ \t]*(.*(?:\n[ \t]{4,}\S.*)*)/m;
        if (defined $verification && $verification =~ /activated task-tree-first/i) {
            push @errors,
                "$file: pending node `$id` claims task-tree-first activation in Verification";
        }

        my ($tree_id) = $id =~ /^([A-Z][A-Z0-9-]*)/;
        my ($commit) = $body =~ /^  Commit: (.*)$/m;
        next unless defined $tree_id && defined $commit;

        my %foreign_ids;
        while ($commit =~ /(\Q$tree_id\E(?:\.[0-9]+)+)/g) {
            $foreign_ids{$1} = 1 if $1 ne $id;
        }
        if (%foreign_ids) {
            push @errors,
                "$file: pending node `$id` names foreign same-tree Commit id(s): "
                . join(', ', map { "`$_`" } sort keys %foreign_ids);
        }
    }

    return @errors;
}

sub assert_pending_fixture {
    my ($name, $text, $expected_errors) = @_;
    my @errors = pending_node_errors("fixture:$name", $text);
    die "task-tree-metadata self-test `$name` expected $expected_errors error(s), got "
        . scalar(@errors) . "\n"
        unless @errors == $expected_errors;
}

assert_pending_fixture('ordinary-pending', <<'FIXTURE', 0);
- ID: `EXAMPLE.1`
  Status: `pending`
  Goal: Wait for EXAMPLE.0.
  Verification: `pending`
  Commit: `pending`
  Finding: Dependency EXAMPLE.0 was activated task-tree-first before this leaf became eligible.
FIXTURE

assert_pending_fixture('activated-pending', <<'FIXTURE', 1);
- ID: `EXAMPLE.1`
  Status: `pending`
  Verification: activated task-tree-first after dependency EXAMPLE.0.
  Commit: `pending`
FIXTURE

assert_pending_fixture('foreign-commit', <<'FIXTURE', 1);
- ID: `EXAMPLE.1`
  Status: `pending`
  Verification: `pending`
  Commit: `EXAMPLE.9 - unrelated leaf`
FIXTURE

assert_pending_fixture('superseded-replacement', <<'FIXTURE', 0);
- ID: `EXAMPLE.1`
  Status: `superseded`
  Superseded by: `EXAMPLE.9`
  Verification: No implementation landed under this placeholder.
  Commit: `none - superseded without implementation`
FIXTURE

for my $file (@ARGV) {
    open my $fh, '<', $file or die "cannot read $file: $!\n";
    local $/;
    my $text = <$fh>;

    push @bad, pending_node_errors($file, $text);

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
    print STDERR "task-tree-metadata: task status/evidence invariants failed\n";
    print STDERR "task-tree-metadata: completed trees cannot advertise live frontiers; pending nodes cannot claim activation or another same-tree Commit id\n";
    print STDERR "$_\n" for @bad;
    exit 1;
}

print "task-tree-metadata: OK (completed frontiers and pending-node evidence are consistent)\n";
PERL

bash tools/run_python_project_data.sh tools/check_task_tree_closed_capability_markers.py
