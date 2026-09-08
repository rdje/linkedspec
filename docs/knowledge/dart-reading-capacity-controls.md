---
id: dart-reading-capacity-controls
title: Approved Dart reading capacity preserves bounded members and tests the real validators
answers:
  - what are the current task and Knowledge capacity limits for Dart reading
  - which guard enforces the approved Dart task collection capacity
  - how do I verify task and Knowledge boundaries at their exact limits
  - did the director approve the capacity exception before full codebase reading
  - does the Dart capacity exception permit parser repairs or artifact purge
date: 2026-09-08
status: implemented under LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.2; canonical proof required before landing
tags: [capacity, task-tree, knowledge, doctrine, continuity]
evidence: "The director approved ADR 0108 with I greenlight the exception. ADR 0109 authorizes exactly four aggregate scalar changes. The task main census and 31 self-test classes share the real collection validators; new boundary expectations reject the old guards and pass after the two aggregate adjustments. The registry-bound audit below also exercises the unchanged routing validator directly. Canonical completion evidence belongs to the .7.2 commit and exact receipt; independent .7.3 and admission .7.4 remain pending."
reverify:
  - "bash tools/project_data_run.sh perl scripts/check_task_tree_partitions.pl"
  - "Run the repository-managed CAPACITY_BOUNDARY_AUDIT block below."
  - "bash tools/project_data_run.sh perl scripts/check_readme_routing_pressure.pl --report"
---

# Exact scope and actual validator proof

ADR `0109` authorizes task totals of 88,000 lines / 9,437,184 bytes and Knowledge totals of
1,152 files / 72,000 lines. Task file count remains 128, task members remain 8,000 lines /
1,048,576 bytes, and Knowledge members remain 512 lines / 65,536 bytes with 6,291,456 total bytes.
Knowledge Map limits and all FUTURE partition/member/source/identity contracts remain unchanged.

The scope is capacity infrastructure and direct verification/continuity. It does not authorize parser
repairs, a mutation campaign, recovery/purge, parked authoring ideas or Dart source-reading credit.
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.3` independently recomposes the controls; `.7.4` owns admission
before the separate Dart tree decomposes its source-reading children.

The partition checker main census calls `collection_member_errors` and `collection_total_errors`.
The partition census covers Markdown members; the routing census also includes the registered JSONL index.
That existing scope difference is preserved; agreement means matching ceilings, not identical census counts.
Its seven collection self-test classes exercise equality, independent and simultaneous overflow
through those same functions. The original non-capacity tests are retained; the total is now 31.

The audit below loads the exact pure validator definitions from the tracked checkers without executing
their repository scans, and passes the real approved registry objects. It checks two collections with
eight cases each: below all ceilings, equal to all ceilings, five independent overflows, and all five
overflows together. Task cases also execute the independent partition validators: sixteen cases and
twenty-four validator executions. This isolated boundary proof complements the full resulting-tree
checker and its unchanged 32 mutation classes; it is not a substitute for that integration check.

```bash
bash tools/project_data_run.sh perl - <<'CAPACITY_BOUNDARY_AUDIT'
use strict;
use warnings;
use JSON::PP ();
sub read_source {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "$path: $!\n";
    local $/;
    my $source = <$fh>;
    close $fh or die "$path: $!\n";
    return $source;
}
my $routing = read_source('scripts/check_readme_routing_pressure.pl');
my ($route_function) = $routing =~ /(^sub exceeds_limits \{.*?^\})/ms;
die "routing validator definition missing\n" unless defined $route_function;
my $partition = read_source('scripts/check_task_tree_partitions.pl');
my @task_functions = $partition =~ /(^sub collection_(?:member|total)_errors \{.*?^\})/msg;
die "task validator definitions missing\n" unless @task_functions == 2;
eval(join("\n", $route_function, @task_functions) . "\n1;") or die $@;
my $json = JSON::PP->new->canonical(1);
my @records = map { $json->decode($_) } split /\n/, read_source('doctrine/readme_stability/routes.jsonl');
my %expected = (
    task_evidence => {max_files=>128, max_lines_per_file=>8000, max_bytes_per_file=>1048576,
        max_total_lines=>88000, max_total_bytes=>9437184},
    knowledge_cards => {max_files=>1152, max_lines_per_file=>512, max_bytes_per_file=>65536,
        max_total_lines=>72000, max_total_bytes=>6291456},
);
my ($cases, $executions) = (0, 0);
for my $name (sort keys %expected) {
    my @surface = grep { $_->{type} eq 'surface' && $_->{id} eq $name } @records;
    die "$name registry identity is not unique\n" unless @surface == 1;
    my $limits = $surface[0]{limits};
    die "$name approved limits changed; review the new capacity owner\n"
        unless $json->encode($limits) eq $json->encode($expected{$name});
    my $ceiling = {
        files=>$limits->{max_files}, lines=>$limits->{max_total_lines}, bytes=>$limits->{max_total_bytes},
        members=>['boundary.md'], per_file=>{'boundary.md'=>{
            lines=>$limits->{max_lines_per_file}, bytes=>$limits->{max_bytes_per_file}}},
    };
    my @labels = ('files', 'aggregate lines', 'aggregate bytes', 'boundary.md lines', 'boundary.md bytes');
    for my $case (-2 .. 5) {
        my $m = $json->decode($json->encode($ceiling));
        my @slots = (\$m->{files}, \$m->{lines}, \$m->{bytes},
            \$m->{per_file}{'boundary.md'}{lines}, \$m->{per_file}{'boundary.md'}{bytes});
        if ($case == -2) { --$$_ for @slots }
        elsif ($case == 5) { ++$$_ for @slots }
        elsif ($case >= 0) { ++${$slots[$case]} }
        my @actual = exceeds_limits($m, $limits);
        my @wanted = $case == 5 ? @labels : $case >= 0 ? ($labels[$case]) : ();
        my @actual_labels = map { my $s=$_; $s =~ s/ \d+\/\d+\z//; $s } @actual;
        die "$name case $case routing mismatch: @actual\n"
            unless $json->encode(\@actual_labels) eq $json->encode(\@wanted);
        ++$executions;
        if ($name eq 'task_evidence') {
            my @task = (collection_total_errors(@$m{qw(files lines bytes)}),
                collection_member_errors('boundary.md', @{$m->{per_file}{'boundary.md'}}{qw(lines bytes)}));
            die "$name case $case task/routing disagreement: @task\n" unless @task == @wanted;
            ++$executions;
        }
        ++$cases;
    }
}
die "boundary census changed\n" unless $cases == 16 && $executions == 24;
print "PASS $cases registry-bound cases / $executions actual validator executions; all independent limits preserved\n";
CAPACITY_BOUNDARY_AUDIT
```
