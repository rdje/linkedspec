#!/usr/bin/env perl
use strict;
use warnings;

use Digest::SHA qw(sha256_hex);
use FindBin qw($RealBin);
use JSON::PP ();

# ADR 0125: this second registered tree has a deliberately closed topology.
# FUTURE's existing source, topology and verifier remain independent.
my $ROOT = "$RealBin/..";
my $TREE = 'SESSION-STARTUP-READING';
my $BASE = "docs/tasks/$TREE";
my $SOURCE_COMMIT = '58a5ff936e54f0699da2b33c35641a5e0155ed81';
my $SOURCE_BLOB = 'f1aed39e1f7cb00d228642fed1b5ac49356747b9';
my $SOURCE_SHA = 'e5a1199d0a15fbbd29ada47fb9a262dbeeefd831e971bc08cb084a7e8a7b6209';
my $AUTHORITY = 'docs/decisions/0125-startup-task-partitions.md';
my $JSON = JSON::PP->new->canonical(1)->utf8(1);
my @PARTS = (
    ['01-03', '1', '3',  ['41-2205', '5076-5574', '5826-7515']],
    ['04-49', '4', '49', ['2206-3416', '5575-5825']],
    ['50-99', '50', '99', ['3417-5040']],
    ['history', undef, undef, ['1-40', '5041-5075', '7516-7994']],
);

chdir $ROOT or die "cannot enter repository root: $!\n";
die "usage: perl scripts/check_startup_task_partitions.pl\n" if @ARGV;
my %state = (files => {}, unsafe => {});
$state{members} = [sort glob("$BASE*.md")];
for my $path ("$BASE.md", "$BASE.index.jsonl", map { "$BASE.$_->[0].md" } @PARTS) {
    $state{unsafe}{$path} = 1 if path_has_symlink($path);
    $state{files}{$path} = read_bytes($path) if -f $path && !$state{unsafe}{$path};
}
$state{source} = git_bytes('show', "$SOURCE_COMMIT:$BASE.md");
$state{source_blob} = git_bytes('rev-parse', "$SOURCE_COMMIT:$BASE.md");
chomp $state{source_blob};
$state{registry} = read_bytes('doctrine/readme_stability/routes.jsonl');

my @errors = validate(\%state);
if (@errors) {
    print STDERR "[startup-task-partitions] FAIL: $_\n" for @errors;
    exit 1;
}
run_mutations(\%state);

# Exercise the real repository-rooted entry point, not only the validator model.
for my $part (@PARTS[0 .. 2]) {
    my $id = "$TREE.$part->[1]";
    my $actual = command_bytes($^X, 'tools/read_task_tree.pl', '--tree', $TREE, '--id', $id);
    die "stable-ID lookup returned the wrong owner for $id\n"
        if $actual ne $state{files}{"$BASE.$part->[0].md"};
}
print "[startup-task-partitions] PASS: 3 semantic parts, 1 immutable history, "
    . "395 preserved child IDs; exact source identity, topology, current snapshots and bounded root\n";

sub validate {
    my ($state) = @_;
    my @errors;
    my $files = $state->{files};
    my @paths = ("$BASE.md", "$BASE.index.jsonl", map { "$BASE.$_->[0].md" } @PARTS);
    my @expected_members = sort grep { /\.md\z/ } @paths;
    push @errors, 'startup Markdown member collection differs'
        if !same($state->{members}, \@expected_members);
    for my $path (@paths) {
        push @errors, "missing or unsafe member: $path"
            if !exists($files->{$path}) || $state->{unsafe}{$path};
    }
    return @errors if @errors;

    my $source = $state->{source};
    push @errors, 'frozen source identity differs'
        if ($state->{source_blob} // '') ne $SOURCE_BLOB
        || sha256_hex($source) ne $SOURCE_SHA
        || length($source) != 960_362 || line_count($source) != 7_994;
    return @errors if @errors;
    my @source_lines = split /(?<=\n)/, $source;

    my $records = decode_lines($files->{"$BASE.index.jsonl"}, \@errors);
    push @errors, 'index needs exactly five records' if @$records != 5;
    push @errors, pressure_errors('index', line_count($files->{"$BASE.index.jsonl"}),
        length($files->{"$BASE.index.jsonl"}), 5, 16_384);
    return @errors if @errors;

    my $metadata = {
        authority => $AUTHORITY, history_path => "$BASE.history.md",
        max_member_bytes => 786_432, max_member_lines => 5_000,
        part_count => 4, semantic_part_count => 3, schema_version => 1,
        retrieval_command => "perl tools/read_task_tree.pl --tree $TREE --id <stable-id>",
        update_command => "perl tools/update_task_tree_index.pl --tree $TREE",
        root_path => "$BASE.md", root_source_ranges => [], root_source_sha256 => sha256_hex(''),
        source_path => "$BASE.md", source_commit => $SOURCE_COMMIT, source_blob => $SOURCE_BLOB,
        source_sha256 => $SOURCE_SHA, source_line_count => 7_994, source_byte_count => 960_362,
        tree => $TREE, type => 'task_tree_index',
    };
    push @errors, 'metadata schema or frozen contract differs' if !same($records->[0], $metadata);

    my (%covered, %ids, %statuses);
    for my $i (0 .. $#PARTS) {
        my ($name, $lo, $hi, $ranges) = @{$PARTS[$i]};
        my $path = "$BASE.$name.md";
        my $bytes = $files->{$path};
        my $payload = '';
        for my $range (@$ranges) {
            my ($start, $end) = split /-/, $range;
            $payload .= join('', @source_lines[$start - 1 .. $end - 1]);
            ++$covered{$_} for $start .. $end;
        }
        my $mutable = defined $lo;
        my $expected = {
            byte_count => length($bytes), line_count => line_count($bytes),
            mutable => $mutable ? JSON::PP::true : JSON::PP::false,
            partition_id => $name, path => $path, prefix_start => $lo, prefix_end => $hi,
            retrieval_command => $mutable
                ? "perl tools/read_task_tree.pl --tree $TREE --id $TREE.$lo"
                : "sed -n '1,160p' $BASE.history.md",
            sha256 => sha256_hex($bytes), source_ranges => $ranges,
            source_sha256 => sha256_hex($payload), tree => $TREE, type => 'task_tree_part',
        };
        push @errors, "$name schema, ownership, source or current snapshot differs"
            if !same($records->[$i + 1], $expected);
        push @errors, pressure_errors($name, line_count($bytes), length($bytes), 5_000, 786_432);
        if (!$mutable) {
            push @errors, 'immutable history differs from its exact original payload'
                if $bytes ne history_header() . $payload;
            next;
        }
        while ($bytes =~ /^- ID: `([^`]+)`[ \t]*$/mg) {
            my $id = $1;
            push @errors, "duplicate current child: $id" if $ids{$id}++;
            push @errors, "foreign or wrong-range child: $id in $name"
                if $id !~ /\A\Q$TREE\E\.([0-9]+)(?:\.[0-9]+)*\z/ || $1 < $lo || $1 > $hi;
        }
        while ($bytes =~ /^- ID: `([^`]+)`\n  Status: `([^`]+)`/mg) {
            $statuses{$1} = $2;
        }
    }
    push @errors, 'source range coverage is not exact'
        if keys(%covered) != @source_lines || grep { $covered{$_} != 1 } keys %covered;
    my @original_ids = $source =~ /^- ID: `(\Q$TREE\E(?:\.[0-9]+)+)`[ \t]*$/mg;
    push @errors, "original child lost: $_" for grep { !$ids{$_} } @original_ids;

    my $root = $files->{"$BASE.md"};
    push @errors, pressure_errors('root', line_count($root), length($root), 256, 32_768);
    my @root_definitions = $root =~ /^- ID: `([^`]+)`[ \t]*$/mg;
    push @errors, 'current root must define only the tree root'
        if @root_definitions != 1 || $root_definitions[0] ne $TREE;
    for my $heading ('Metadata', 'Task Tree', 'Current Frontier', 'Semantic Part Index',
            'Current Decisions and Blockers', 'Retrieval') {
        push @errors, "missing root heading: $heading" if $root !~ /^## \Q$heading\E$/m;
    }
    for my $path (@paths[1 .. $#paths]) {
        (my $basename = $path) =~ s{.*/}{};
        push @errors, "missing root navigation: $basename" if index($root, $basename) < 0;
    }
    push @errors, 'missing root lookup command'
        if index($root, "perl tools/read_task_tree.pl --tree $TREE --id $TREE.") < 0;
    push @errors, 'missing root refresh command'
        if index($root, "perl tools/update_task_tree_index.pl --tree $TREE") < 0;
    my @references = $root =~ /`(\Q$TREE\E(?:\.[0-9]+)+)`/g;
    push @errors, "root references an unknown child: $_" for grep { !$ids{$_} } @references;
    my ($frontier) = $root =~ /^## Current Frontier\n(.*?)(?=^## |\z)/ms;
    my @frontier = ($frontier // '') =~ /^\|[^\n]*?`(\Q$TREE\E(?:\.[0-9]+)+)`\s*\|\s*`([^`]+)`/mg;
    push @errors, 'root frontier lacks a stable child/status row' if !@frontier;
    while (@frontier) {
        my ($id, $status) = splice @frontier, 0, 2;
        push @errors, "root frontier status differs: $id" if ($statuses{$id} // '') ne $status;
    }
    push @errors, registry_errors($state->{registry});
    return @errors;
}

sub registry_errors {
    my ($bytes) = @_;
    my @errors;
    my $rows = decode_lines($bytes, \@errors, 0);
    my @task = grep { ($_->{id} // '') eq 'task_evidence' } @$rows;
    return (@errors, 'registry must have one task_evidence owner') if @task != 1;
    my $r = $task[0];
    push @errors, 'startup route ownership differs'
        if ($r->{authority} // '') ne $AUTHORITY || ($r->{owner} // '') ne 'LIVE-DOCUMENT-PRESSURE-CONTAINMENT.16.2'
        || ($r->{verifier} // '') ne 'task_tree_metadata' || ($r->{state} // '') ne 'current';
    push @errors, 'startup index is not a routed member'
        if ref($r->{members}) ne 'ARRAY' || grep($_ eq "$BASE.index.jsonl", @{$r->{members}}) != 1;
    my %expected = (
        "$BASE.md" => {max_lines => 256, max_bytes => 32_768},
        "$BASE.index.jsonl" => {max_lines => 5, max_bytes => 16_384},
        map { ("$BASE.$_->[0].md" => {max_lines => 5_000, max_bytes => 786_432}) } @PARTS,
    );
    for my $path (sort keys %expected) {
        push @errors, "registry member limit differs: $path"
            if !same($r->{member_limits}{$path}, $expected{$path});
    }
    # The existing collection checker owns aggregate limits and its equality guard.
    return @errors;
}

sub history_header {
    return "# $TREE: immutable pre-partition snapshot\n\n"
        . "Historical evidence only; do not edit or append. Current state is in $BASE.md.\n"
        . "Current AGENTS.md and ADR0123 supersede contrary historical reading or dependency instructions.\n\n";
}

sub decode_lines {
    my ($bytes, $errors, $canonical) = @_;
    $canonical = 1 if !defined $canonical;
    my @records;
    push @$errors, 'JSONL must end in LF' if $bytes !~ /\n\z/;
    my @lines = split /\n/, $bytes, -1;
    pop @lines if @lines && $lines[-1] eq '';
    for my $line (@lines) {
        my $r = eval { $JSON->decode($line) };
        if ($@ || ref($r) ne 'HASH') { push @$errors, 'invalid JSON object'; next }
        push @$errors, 'noncanonical JSON object' if $canonical && $JSON->encode($r) ne $line;
        push @records, $r;
    }
    return \@records;
}

sub pressure_errors {
    my ($name, $lines, $bytes, $max_lines, $max_bytes) = @_;
    my @errors;
    push @errors, "$name line limit exceeded" if $lines > $max_lines;
    push @errors, "$name byte limit exceeded" if $bytes > $max_bytes;
    return @errors;
}

sub same { return $JSON->encode($_[0]) eq $JSON->encode($_[1]) }
sub line_count { my $n = () = $_[0] =~ /\n/g; return $n + ($_[0] ne '' && $_[0] !~ /\n\z/ ? 1 : 0) }

sub path_has_symlink {
    my ($path) = @_;
    my $cursor = '';
    for my $part (split m{/}, $path) {
        $cursor = $cursor eq '' ? $part : "$cursor/$part";
        return 1 if -l $cursor;
    }
    return 0;
}

sub read_bytes {
    my ($path) = @_;
    die "unsafe or missing input: $path\n" if path_has_symlink($path) || !-f $path;
    open my $fh, '<:raw', $path or die "cannot read $path: $!\n";
    local $/; my $bytes = <$fh>;
    close $fh or die "cannot close $path: $!\n";
    return $bytes // '';
}

sub git_bytes { return command_bytes('git', '-C', $ROOT, @_) }
sub command_bytes {
    open my $fh, '-|', @_ or die "cannot run @_: $!\n";
    binmode $fh; local $/; my $bytes = <$fh>;
    close $fh or die "command failed: @_\n";
    return $bytes // '';
}

sub run_mutations {
    my ($valid) = @_;
    my @cases;
    # Mutate complete production inputs; each case must fail the actual validator.
    for my $field (qw(authority tree source_commit source_blob source_sha256 root_source_sha256
            source_line_count source_byte_count part_count semantic_part_count max_member_lines
            max_member_bytes root_path history_path retrieval_command update_command schema_version)) {
        push @cases, ["metadata_$field", sub {
            my ($s) = @_; edit_records($s, sub { $_[0][0]{$field} = 'invalid' });
        }];
    }
    for my $field (qw(partition_id path prefix_start prefix_end source_sha256 sha256 line_count byte_count retrieval_command)) {
        push @cases, ["part_$field", sub {
            my ($s) = @_; edit_records($s, sub { $_[0][1]{$field} = 'invalid' });
        }];
    }
    push @cases,
        ['extra_key', sub { edit_records($_[0], sub { $_[0][1]{extra} = 1 }) }],
        ['missing_record', sub { edit_records($_[0], sub { pop @{$_[0]} }) }],
        ['duplicate_record', sub { edit_records($_[0], sub { push @{$_[0]}, $_[0][1] }) }],
        ['reordered_records', sub { edit_records($_[0], sub { @{$_[0]}[1, 2] = @{$_[0]}[2, 1] }) }],
        ['malformed_json', sub { $_[0]{files}{"$BASE.index.jsonl"} = "not json\n" }],
        ['noncanonical_json', sub { $_[0]{files}{"$BASE.index.jsonl"} =~ s/\{/\{ / }],
        ['blank_record', sub { $_[0]{files}{"$BASE.index.jsonl"} .= "\n" }],
        ['range_gap', sub { edit_records($_[0], sub { $_[0][1]{source_ranges}[0] = '42-2205' }) }],
        ['range_overlap', sub { edit_records($_[0], sub { $_[0][2]{source_ranges}[0] = '2205-3416' }) }],
        ['range_shape', sub { edit_records($_[0], sub { $_[0][1]{source_ranges} = {} }) }],
        ['root_provenance', sub { edit_records($_[0], sub { $_[0][0]{root_source_ranges} = ['1-40'] }) }],
        ['mutable_history', sub { edit_records($_[0], sub { $_[0][4]{mutable} = JSON::PP::true }) }],
        ['nonboolean_mutability', sub { edit_records($_[0], sub { $_[0][1]{mutable} = 1 }) }],
        ['history_bytes', sub { $_[0]{files}{"$BASE.history.md"} .= "changed\n"; refresh_fixture($_[0]) }],
        ['source_bytes', sub { $_[0]{source} .= "changed\n" }],
        ['source_blob', sub { $_[0]{source_blob} = '0' x 40 }],
        ['missing_member', sub { delete $_[0]{files}{"$BASE.01-03.md"} }],
        ['unregistered_member', sub { push @{$_[0]{members}}, "$BASE.extra.md" }],
        ['symlink_member', sub { $_[0]{unsafe}{"$BASE.01-03.md"} = 1 }],
        ['symlink_index', sub { $_[0]{unsafe}{"$BASE.index.jsonl"} = 1 }],
        ['unsafe_absolute', sub { edit_records($_[0], sub { $_[0][1]{path} = '/outside/member.md' }) }],
        ['unsafe_traversal', sub { edit_records($_[0], sub { $_[0][1]{path} = 'docs/../member.md' }) }],
        ['lost_id', sub { $_[0]{files}{"$BASE.50-99.md"} =~ s/^- ID: `\Q$TREE\E\.89`\n//m; refresh_fixture($_[0]) }],
        ['duplicate_id', sub { $_[0]{files}{"$BASE.50-99.md"} .= "\n- ID: `$TREE.89`\n"; refresh_fixture($_[0]) }],
        ['wrong_partition', sub { $_[0]{files}{"$BASE.01-03.md"} .= "\n- ID: `$TREE.90`\n"; refresh_fixture($_[0]) }],
        ['foreign_id', sub { $_[0]{files}{"$BASE.01-03.md"} .= "\n- ID: `OTHER.1`\n"; refresh_fixture($_[0]) }],
        ['root_child_definition', sub { $_[0]{files}{"$BASE.md"} .= "\n- ID: `$TREE.89`\n" }],
        ['root_unknown_reference', sub { $_[0]{files}{"$BASE.md"} .= "\n`$TREE.100`\n" }],
        ['root_navigation', sub { $_[0]{files}{"$BASE.md"} =~ s/\Q$TREE.50-99.md\E/absent.md/g }],
        ['root_frontier_status', sub { $_[0]{files}{"$BASE.md"} =~ s/(`\Q$TREE\E(?:\.[0-9]+)+`\s*\|\s*)`[^`]+`/${1}`invalid-status`/ }],
        ['root_missing_heading', sub { $_[0]{files}{"$BASE.md"} =~ s/^## Retrieval\n//m }],
        ['root_pressure', sub { $_[0]{files}{"$BASE.md"} .= "x\n" x 257 }],
        ['registry_index', sub { edit_registry($_[0], sub { @{$_[0]{members}} = grep { $_ ne "$BASE.index.jsonl" } @{$_[0]{members}} }) }],
        ['registry_member_limit', sub { edit_registry($_[0], sub { $_[0]{member_limits}{"$BASE.md"}{max_lines}++ }) }];
    for my $test (@cases) {
        my $copy = $JSON->decode($JSON->encode($valid));
        $test->[1]->($copy);
        die "startup partition mutation was not applied: $test->[0]\n" if same($copy, $valid);
        my @errors = validate($copy);
        die "startup partition mutation survived: $test->[0]\n" if !@errors;
    }
    my $boundaries = 0;
    for my $caps ([256, 32_768], [5, 16_384], [5_000, 786_432]) {
        die 'inclusive pressure boundary rejected' if pressure_errors('fixture', @$caps, @$caps);
        for my $axis (0, 1) {
            my @values = @$caps; ++$values[$axis];
            my @errors = pressure_errors('fixture', @values, @$caps);
            die 'independent pressure overflow not rejected' if @errors != 1;
        }
        $boundaries += 3;
    }
    print '[startup-task-partitions] PASS: ' . scalar(@cases) . " input mutations; $boundaries pressure controls\n";
}

sub edit_records {
    my ($state, $edit) = @_;
    my @records = map { $JSON->decode($_) } split /\n/, $state->{files}{"$BASE.index.jsonl"};
    $edit->(\@records);
    $state->{files}{"$BASE.index.jsonl"} = join('', map { $JSON->encode($_) . "\n" } @records);
}

sub refresh_fixture {
    my ($state) = @_;
    edit_records($state, sub {
        for my $r (@{$_[0]}[1 .. 4]) {
            my $bytes = $state->{files}{$r->{path}};
            $r->{sha256} = sha256_hex($bytes); $r->{byte_count} = length($bytes);
            $r->{line_count} = line_count($bytes);
        }
    });
}

sub edit_registry {
    my ($state, $edit) = @_;
    my @records = map { $JSON->decode($_) } split /\n/, $state->{registry};
    $edit->($_) for grep { ($_->{id} // '') eq 'task_evidence' } @records;
    $state->{registry} = join('', map { $JSON->encode($_) . "\n" } @records);
}
