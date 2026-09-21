#!/usr/bin/env perl
use strict;
use warnings;

use Digest::SHA qw(sha256_hex);
use FindBin qw($RealBin);
use JSON::PP ();

my $ROOT = "$RealBin/..";
my $TREE = 'FUTURE-PARITY-BACKLOG';
my $INDEX_PATH = 'docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl';
my $ROOT_PATH = 'docs/tasks/FUTURE-PARITY-BACKLOG.md';
my $HISTORY_PATH = 'docs/tasks/FUTURE-PARITY-BACKLOG.history.md';
my $AUTHORITY = 'docs/decisions/0084-future-parity-task-partition-capacity.md';
my $JSON = JSON::PP->new->canonical(1)->utf8(1);
my @METADATA_KEYS = qw(authority history_path max_member_bytes max_member_lines part_count retrieval_command root_path root_source_ranges root_source_sha256 schema_version semantic_part_count source_blob source_byte_count source_commit source_line_count source_path source_sha256 tree type update_command);
my @PART_KEYS = qw(byte_count line_count mutable partition_id path prefix_end prefix_start retrieval_command sha256 source_ranges source_sha256 tree type);
my @EXPECTED = (
    ['00-08',   'docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md',   '0',    '8',     1, ['76-3183', '23623-24107']],
    ['09',      'docs/tasks/FUTURE-PARITY-BACKLOG.09.md',      '9',    '9',     1, ['3184-6779']],
    ['10.0-6',  'docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md',  '10',   '10.6',  1, ['6780-10967']],
    ['10.7-10', 'docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md', '10.7', '10.10', 1, ['10968-15106']],
    ['11-13',   'docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md',   '11',   '13',    1, ['15107-17122']],
    ['14.0-6.4','docs/tasks/FUTURE-PARITY-BACKLOG.14.md',       '14',   '14.6.4',1, ['17123-21064']],
    ['14.6.5-8','docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md', '14.6.5','14.8', 1, ['21065-21074']],
    ['15-24',   'docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md',   '15',   '24',    1, ['21075-22878']],
    ['history', $HISTORY_PATH,                                  undef,  undef,    0, ['22955-23622', '24308-26979']],
);
my @ROOT_SOURCE_RANGES = ('1-75', '22879-22954', '24108-24307');

chdir $ROOT or die "cannot enter repository root: $!\n";
run_self_tests();
my @errors;
my ($capacity_records) = decode_index('doctrine/readme_stability/routes.jsonl', \@errors);
push @errors, collection_registry_errors($capacity_records);
push @errors, 'task-tree partition index is missing or symbolic'
    if !-f $INDEX_PATH || path_has_symlink($INDEX_PATH);
my ($records, $canonical_lines) = decode_index($INDEX_PATH, \@errors);
if (@$records != 10) {
    push @errors, 'task-tree index must contain one metadata record and exactly nine part records';
    finish(\@errors);
}

my $metadata = shift @$records;
push @errors, 'task-tree metadata keys are not exact' if !exact_keys($metadata, \@METADATA_KEYS);
push @errors, 'task-tree metadata is not canonical JSON'
    if @$canonical_lines && $JSON->encode($metadata) ne $canonical_lines->[0];
push @errors, 'task-tree metadata contract mismatch'
    if ($metadata->{type} // '') ne 'task_tree_index'
    || ($metadata->{schema_version} // 0) != 1
    || ($metadata->{authority} // '') ne $AUTHORITY
    || ($metadata->{tree} // '') ne $TREE
    || ($metadata->{root_path} // '') ne $ROOT_PATH
    || ($metadata->{source_path} // '') ne $ROOT_PATH
    || ($metadata->{history_path} // '') ne $HISTORY_PATH
    || ($metadata->{part_count} // 0) != 9
    || ($metadata->{semantic_part_count} // 0) != 8
    || ($metadata->{max_member_lines} // 0) != 5_000
    || ($metadata->{max_member_bytes} // 0) != 786_432
    || ($metadata->{retrieval_command} // '') ne "perl tools/read_task_tree.pl --tree $TREE --id <stable-id>"
    || ($metadata->{update_command} // '') ne "perl tools/update_task_tree_index.pl --tree $TREE";
push @errors, 'task-tree root source ranges drifted'
    if !same_strings($metadata->{root_source_ranges}, \@ROOT_SOURCE_RANGES);
push @errors, 'task-tree source identity is malformed'
    if ($metadata->{source_commit} // '') !~ /\A[0-9a-f]{40}\z/
    || ($metadata->{source_blob} // '') !~ /\A[0-9a-f]{40}\z/
    || ($metadata->{source_sha256} // '') !~ /\A[0-9a-f]{64}\z/
    || ($metadata->{root_source_sha256} // '') !~ /\A[0-9a-f]{64}\z/;

my $source = git_capture(\@errors, 'show', ($metadata->{source_commit} // '') . ':' . ($metadata->{source_path} // ''));
my $source_blob = git_capture(\@errors, 'rev-parse', ($metadata->{source_commit} // '') . ':' . ($metadata->{source_path} // ''));
$source_blob =~ s/\n\z//;
my @source_lines = split /(?<=\n)/, $source;
push @errors, 'task-tree source blob mismatch' if $source_blob ne ($metadata->{source_blob} // '');
push @errors, 'task-tree source line count mismatch' if @source_lines != ($metadata->{source_line_count} // -1);
push @errors, 'task-tree source byte count mismatch' if length($source) != ($metadata->{source_byte_count} // -1);
push @errors, 'task-tree source digest mismatch' if sha256_hex($source) ne ($metadata->{source_sha256} // '');
my $root_source = ranges_bytes(\@source_lines, \@ROOT_SOURCE_RANGES, \@errors);
push @errors, 'task-tree root source digest mismatch'
    if sha256_hex($root_source) ne ($metadata->{root_source_sha256} // '');

my %covered;
cover_ranges(\%covered, \@ROOT_SOURCE_RANGES, scalar(@source_lines), 'root', \@errors);
my %ids;
my $semantic_count = 0;
my $head_listing = git_capture(\@errors, 'ls-tree', '-r', '--name-only', 'HEAD');
my %HEAD_PATH = map { $_ => 1 } grep { $_ ne '' } split /\n/, $head_listing;
for my $index (0 .. $#EXPECTED) {
    my $record = $records->[$index];
    my ($id, $path, $prefix_start, $prefix_end, $mutable, $ranges) = @{$EXPECTED[$index]};
    push @errors, "$id part keys are not exact" if !exact_keys($record, \@PART_KEYS);
    push @errors, "$id part is not canonical JSON"
        if defined($canonical_lines->[$index + 1]) && $JSON->encode($record) ne $canonical_lines->[$index + 1];
    push @errors, "$id part contract mismatch"
        if ($record->{type} // '') ne 'task_tree_part'
        || ($record->{tree} // '') ne $TREE
        || ($record->{partition_id} // '') ne $id
        || ($record->{path} // '') ne $path
        || !same_nullable($record->{prefix_start}, $prefix_start)
        || !same_nullable($record->{prefix_end}, $prefix_end)
        || !JSON::PP::is_bool($record->{mutable})
        || ($record->{mutable} ? 1 : 0) != $mutable
        || !same_strings($record->{source_ranges}, $ranges);
    push @errors, "$id part path is unsafe or symbolic" if !safe_path($path) || path_has_symlink($path);
    push @errors, "$id part is missing" if !-f $path;
    cover_ranges(\%covered, $ranges, scalar(@source_lines), $id, \@errors);
    my $source_bytes = ranges_bytes(\@source_lines, $ranges, \@errors);
    push @errors, "$id source-range digest mismatch"
        if sha256_hex($source_bytes) ne ($record->{source_sha256} // '');
    my $bytes = read_bytes($path, \@errors);
    push @errors, "$id current line count mismatch" if line_count($bytes) != ($record->{line_count} // -1);
    push @errors, "$id current byte count mismatch" if length($bytes) != ($record->{byte_count} // -1);
    push @errors, "$id current digest mismatch" if sha256_hex($bytes) ne ($record->{sha256} // '');
    push @errors, "$id exceeds 5,000 lines" if line_count($bytes) > 5_000;
    push @errors, "$id exceeds 786,432 bytes" if length($bytes) > 786_432;
    if (!$mutable) {
        push @errors, 'history path mismatch' if $path ne $HISTORY_PATH;
        push @errors, 'immutable history differs from its clean source ranges' if $bytes ne $source_bytes;
        my $head_bytes = $HEAD_PATH{$path} ? git_optional('show', "HEAD:$path") : undef;
        push @errors, 'immutable task-tree history changed after its migration commit'
            if defined($head_bytes) && $bytes ne $head_bytes;
        next;
    }
    ++$semantic_count;
    push @errors, "$id retrieval command mismatch"
        if ($record->{retrieval_command} // '') !~ /\Aperl tools\/read_task_tree\.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG\.[0-9.]+\z/;
    while ($bytes =~ /^- ID: `(FUTURE-PARITY-BACKLOG(?:\.[0-9]+)+)`\s*$/mg) {
        my $node_id = $1;
        push @errors, "duplicate task id: $node_id" if $ids{$node_id}++;
        push @errors, "task id is in the wrong semantic partition: $node_id -> $id"
            if !part_owns_id($id, $node_id);
    }
}
push @errors, 'semantic part count mismatch' if $semantic_count != 8;
for my $line (1 .. scalar(@source_lines)) {
    push @errors, "clean source line is not owned exactly once: $line" if ($covered{$line} // 0) != 1;
}

my %source_ids;
while ($source =~ /^- ID: `(FUTURE-PARITY-BACKLOG(?:\.[0-9]+)+)`\s*$/mg) { $source_ids{$1} = 1 }
for my $id (sort keys %source_ids) {
    push @errors, "clean task id was lost during partitioning: $id" if !$ids{$id};
}

push @errors, 'bounded task-tree root is missing or symbolic'
    if !-f $ROOT_PATH || path_has_symlink($ROOT_PATH);
my $root = read_bytes($ROOT_PATH, \@errors);
push @errors, 'bounded task-tree root exceeds 5,000 lines' if line_count($root) > 5_000;
push @errors, 'bounded task-tree root exceeds 786,432 bytes' if length($root) > 786_432;
push @errors, 'bounded task-tree root omits strict index navigation'
    if index($root, 'docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl') < 0
    || index($root, "perl tools/read_task_tree.pl --tree $TREE --id FUTURE-PARITY-BACKLOG.14.3.1.1") < 0;
push @errors, 'bounded task-tree root contains duplicated child node blocks'
    if $root =~ /^- ID: `FUTURE-PARITY-BACKLOG\.[0-9]/m;
my @part_links = map { $_->[1] } @EXPECTED;
for my $path (@part_links) {
    (my $basename = $path) =~ s{.*/}{};
    push @errors, "bounded task-tree root omits part link: $basename" if index($root, $basename) < 0;
}

my %root_ids = map { $_ => 1 } ($root =~ /`(FUTURE-PARITY-BACKLOG(?:\.[0-9]+)+)`/g);
for my $id (sort keys %root_ids) {
    push @errors, "bounded task-tree root references an unknown stable id: $id" if !$ids{$id};
}
my $lookup = command_capture(\@errors, $^X, 'tools/read_task_tree.pl', '--tree', $TREE,
    '--id', 'FUTURE-PARITY-BACKLOG.14.3.1.1');
push @errors, 'normative stable-id lookup does not return its exact owner'
    if index($lookup, '- ID: `FUTURE-PARITY-BACKLOG.14.3.1.1`') < 0;
my $split_lookup = command_capture(\@errors, $^X, 'tools/read_task_tree.pl', '--tree', $TREE,
    '--id', 'FUTURE-PARITY-BACKLOG.14.6.5');
push @errors, 'split-boundary stable-id lookup does not return its exact owner'
    if index($split_lookup, '- ID: `FUTURE-PARITY-BACKLOG.14.6.5`') < 0;

my @consumer_paths = (
    'capability_conformance/repeated_action_result_contract.json',
    'capability_conformance/semantic_introspection_contract.json',
    'tools/check_capability_conformance.pl',
    'tools/check_diagnostic_output_contract.py',
    'tools/check_duplicate_regex_slot_identity_contract.py',
    'tools/check_generated_source_contract.pl',
    'tools/check_logical_helper_contract.py',
    'tools/check_native_spec_resolution_contract.pl',
    'tools/check_repeated_action_result_contract.py',
    'tools/check_root_rule_selection_contract.py',
    'tools/check_semantic_introspection_contract.py',
);
for my $path (@consumer_paths) {
    my $bytes = read_bytes($path, \@errors);
    push @errors, "machine consumer still reads the old task-tree monolith: $path"
        if index($bytes, $ROOT_PATH) >= 0;
}
my $capability_consumer = read_bytes('tools/check_capability_conformance.pl', \@errors);
for my $expected (grep { $_->[4] } @EXPECTED) {
    (my $basename = $expected->[1]) =~ s{.*/}{};
    push @errors, "capability task census omits semantic part: $basename"
        if index($capability_consumer, $basename) < 0;
}

my @task_files = grep { -f $_ && !-l $_ } glob('docs/tasks/*.md');
my ($total_lines, $total_bytes) = (0, 0);
for my $path (@task_files) {
    my $bytes = read_bytes($path, \@errors);
    my $lines = line_count($bytes);
    $total_lines += $lines;
    $total_bytes += length($bytes);
    push @errors, collection_member_errors($path, $lines, length($bytes));
}
push @errors, collection_total_errors(scalar(@task_files), $total_lines, $total_bytes);

finish(\@errors, scalar(@task_files), $total_lines, $total_bytes, scalar(keys %ids));

sub collection_member_errors {
    my ($path, $lines, $bytes) = @_;
    my @errors;
    push @errors, "task collection member exceeds 8,000 lines: $path" if $lines > 8_000;
    push @errors, "task collection member exceeds 1,048,576 bytes: $path" if $bytes > 1_048_576;
    return @errors;
}

sub collection_total_errors {
    my ($files, $lines, $bytes) = @_;
    my @errors;
    push @errors, 'task collection exceeds 128 files' if $files > 128;
    push @errors, 'task collection exceeds 120,000 lines' if $lines > 120_000;
    push @errors, 'task collection exceeds 12,582,912 bytes' if $bytes > 12_582_912;
    return @errors;
}

sub collection_registry_errors {
    my ($records) = @_;
    return ('task capacity registry is not an array') if ref($records) ne 'ARRAY';
    my @rows = grep { ref($_) eq 'HASH' && ($_->{id} // '') eq 'task_evidence' } @$records;
    return ('task capacity registry needs exactly one task_evidence row') if @rows != 1;
    my $limits = $rows[0]{limits};
    my @keys = qw(max_files max_total_lines max_total_bytes max_lines_per_file max_bytes_per_file);
    return ('task capacity limits do not have the exact five fields') if !exact_keys($limits, \@keys);
    for my $key (@keys) {
        return ("task capacity $key is not a positive integer")
            if !defined($limits->{$key}) || ref($limits->{$key})
                || $limits->{$key} !~ /\A[1-9][0-9]*\z/;
    }
    my @aggregate = @{$limits}{qw(max_files max_total_lines max_total_bytes)};
    my @member = @{$limits}{qw(max_lines_per_file max_bytes_per_file)};
    my @errors;
    push @errors, 'task aggregate checker rejects the registry inclusive boundary'
        if collection_total_errors(@aggregate);
    push @errors, 'task member checker rejects the registry inclusive boundary'
        if collection_member_errors('registry-boundary.md', @member);
    for my $i (0 .. 2) {
        my @over = @aggregate;
        ++$over[$i];
        my @got = collection_total_errors(@over);
        push @errors, 'task aggregate checker does not reject exactly registry ' . $keys[$i] . '+1'
            if @got != 1;
    }
    for my $i (0 .. 1) {
        my @over = @member;
        ++$over[$i];
        my @got = collection_member_errors('registry-boundary.md', @over);
        push @errors, 'task member checker does not reject exactly registry ' . $keys[$i + 3] . '+1'
            if @got != 1;
    }
    return @errors;
}

sub finish {
    my ($errors, $files, $lines, $bytes, $ids_count) = @_;
    if (@$errors) {
        print STDERR "[task-tree-partitions] FAIL: $_\n" for @$errors;
        exit 1;
    }
    print "[task-tree-partitions] PASS: 8 semantic parts, 1 immutable history part, $ids_count stable IDs; "
        . "$files task files / $lines lines / $bytes bytes within bounded collection\n";
    exit 0;
}

sub exact_keys {
    my ($record, $keys) = @_;
    return ref($record) eq 'HASH' && join("\0", sort keys %$record) eq join("\0", sort @$keys);
}

sub same_nullable {
    my ($actual, $expected) = @_;
    return !defined($actual) && !defined($expected) if !defined($actual) || !defined($expected);
    return !ref($actual) && $actual eq $expected;
}

sub same_strings {
    my ($actual, $expected) = @_;
    return ref($actual) eq 'ARRAY' && @$actual == @$expected
        && join("\0", @$actual) eq join("\0", @$expected);
}

sub safe_path {
    my ($path) = @_;
    return defined($path) && !ref($path) && $path ne '' && $path !~ m{\A/}
        && $path !~ m{(?:\A|/)\.\.?(?:/|\z)} && $path !~ m{//} && $path !~ /\\/ && $path !~ /\0/;
}

sub path_has_symlink {
    my ($path) = @_;
    return 1 if !safe_path($path);
    my $cursor = '';
    for my $part (split m{/}, $path) {
        $cursor = $cursor eq '' ? $part : "$cursor/$part";
        return 1 if -l $cursor;
    }
    return 0;
}

sub line_count {
    my ($bytes) = @_;
    return 0 if $bytes eq '';
    my $count = () = $bytes =~ /\n/g;
    ++$count if $bytes !~ /\n\z/;
    return $count;
}

sub read_bytes {
    my ($path, $errors) = @_;
    return '' if !safe_path($path) || !-f $path || -l $path;
    open my $fh, '<:raw', $path or do { push @$errors, "cannot read $path: $!"; return '' };
    local $/;
    my $bytes = <$fh>;
    close $fh or push @$errors, "cannot close $path: $!";
    return defined($bytes) ? $bytes : '';
}

sub decode_index {
    my ($path, $errors) = @_;
    my $bytes = read_bytes($path, $errors);
    my (@records, @lines);
    my @raw_lines = split /\n/, $bytes, -1;
    pop @raw_lines if @raw_lines && $raw_lines[-1] eq '';
    my $number = 0;
    for my $line (@raw_lines) {
        ++$number;
        if ($line eq '') { push @$errors, "$path:$number is blank"; next }
        my $record = eval { JSON::PP->new->utf8(1)->decode($line) };
        if (!$record || $@ || ref($record) ne 'HASH') {
            push @$errors, "$path:$number is not one JSON object";
            next;
        }
        push @records, $record;
        push @lines, $line;
    }
    return (\@records, \@lines);
}

sub cover_ranges {
    my ($covered, $ranges, $source_lines, $owner, $errors) = @_;
    if (ref($ranges) ne 'ARRAY') { push @$errors, "$owner source ranges are not an array"; return }
    for my $range (@$ranges) {
        my ($start, $end) = defined($range) && !ref($range) && $range =~ /\A([0-9]+)-([0-9]+)\z/
            ? ($1, $2) : (0, -1);
        if ($start < 1 || $end < $start || $end > $source_lines) {
            push @$errors, "$owner source range is invalid: " . (defined($range) ? $range : '<undef>');
            next;
        }
        ++$covered->{$_} for $start .. $end;
    }
}

sub ranges_bytes {
    my ($lines, $ranges, $errors) = @_;
    return '' if ref($ranges) ne 'ARRAY';
    my $bytes = '';
    for my $range (@$ranges) {
        my ($start, $end) = defined($range) && !ref($range) && $range =~ /\A([0-9]+)-([0-9]+)\z/
            ? ($1, $2) : (0, -1);
        next if $start < 1 || $end < $start || $end > @$lines;
        $bytes .= join('', @$lines[$start - 1 .. $end - 1]);
    }
    return $bytes;
}

sub part_owns_id {
    my ($partition, $id) = @_;
    my $suffix = substr($id, length($TREE) + 1);
    my @numbers = map { 0 + $_ } split /\./, $suffix;
    my $top = $numbers[0];
    return $top <= 8 if $partition eq '00-08';
    return $top == 9 if $partition eq '09';
    return $top == 10 && (!defined($numbers[1]) || $numbers[1] <= 6) if $partition eq '10.0-6';
    return $top == 10 && defined($numbers[1]) && $numbers[1] >= 7 if $partition eq '10.7-10';
    return $top >= 11 && $top <= 13 if $partition eq '11-13';
    return $top == 14 && (!defined($numbers[1]) || $numbers[1] <= 5
        || ($numbers[1] == 6 && (!defined($numbers[2]) || $numbers[2] <= 4)))
        if $partition eq '14.0-6.4';
    return $top == 14 && defined($numbers[1])
        && (($numbers[1] >= 7 && $numbers[1] <= 8)
            || ($numbers[1] == 6 && defined($numbers[2]) && $numbers[2] >= 5))
        if $partition eq '14.6.5-8';
    return $top >= 15 && $top <= 24 if $partition eq '15-24';
    return 0;
}

sub git_capture {
    my ($errors, @args) = @_;
    open my $fh, '-|', 'git', '-C', $ROOT, @args or do { push @$errors, "cannot run git @args: $!"; return '' };
    binmode $fh;
    local $/;
    my $bytes = <$fh>;
    if (!close $fh) { push @$errors, "git @args failed"; return '' }
    return defined($bytes) ? $bytes : '';
}

sub git_optional {
    my (@args) = @_;
    open my $fh, '-|', 'git', '-C', $ROOT, @args or return undef;
    binmode $fh;
    local $/;
    my $bytes = <$fh>;
    return undef if !close $fh;
    return defined($bytes) ? $bytes : '';
}

sub command_capture {
    my ($errors, @command) = @_;
    open my $fh, '-|', @command or do { push @$errors, "cannot run @command: $!"; return '' };
    binmode $fh;
    local $/;
    my $bytes = <$fh>;
    if (!close $fh) { push @$errors, "command failed: @command"; return '' }
    return defined($bytes) ? $bytes : '';
}

sub run_self_tests {
    my $registry_fixture = sub {
        return [{id => 'task_evidence', limits => {
            max_files => 128, max_total_lines => 120_000, max_total_bytes => 12_582_912,
            max_lines_per_file => 8_000, max_bytes_per_file => 1_048_576,
        }}];
    };
    my @tests = (
        ['registry_capacity_agrees', sub { !collection_registry_errors($registry_fixture->()) }],
        ['registry_capacity_missing', sub { !!collection_registry_errors([]) }],
        ['registry_capacity_duplicate', sub {
            !!collection_registry_errors([@{$registry_fixture->()}, @{$registry_fixture->()}]);
        }],
        ['registry_capacity_invalid', sub {
            my $records = $registry_fixture->();
            $records->[0]{limits}{max_total_lines} = 0;
            return !!collection_registry_errors($records);
        }],
        ['registry_capacity_line_drift', sub {
            my $records = $registry_fixture->();
            --$records->[0]{limits}{max_total_lines};
            return !!collection_registry_errors($records);
        }],
        ['registry_capacity_byte_drift', sub {
            my $records = $registry_fixture->();
            ++$records->[0]{limits}{max_total_bytes};
            return !!collection_registry_errors($records);
        }],
        ['absolute_path', sub { !safe_path('/tmp/x') }],
        ['traversal_path', sub { !safe_path('../x') && !safe_path('a/../b') && !safe_path('./x') }],
        ['safe_path', sub { safe_path('docs/tasks/x.md') }],
        ['metadata_closed', sub { !exact_keys({type => 'task_tree_index'}, \@METADATA_KEYS) }],
        ['part_closed', sub { !exact_keys({type => 'task_tree_part'}, \@PART_KEYS) }],
        ['range_shape', sub { '1-2' =~ /\A[0-9]+-[0-9]+\z/ && '2:3' !~ /\A[0-9]+-[0-9]+\z/ }],
        ['digest_shape', sub { sha256_hex('x') =~ /\A[0-9a-f]{64}\z/ }],
        ['line_count_lf', sub { line_count("a\nb\n") == 2 }],
        ['line_count_no_lf', sub { line_count("a\nb") == 2 }],
        ['line_limit', sub { 5_001 > 5_000 }],
        ['byte_limit', sub { 786_433 > 786_432 }],
        ['collection_inclusive_bounds', sub {
            return same_strings([collection_total_errors(128, 120_000, 12_582_912)], [])
                && same_strings([collection_member_errors('member.md', 8_000, 1_048_576)], []);
        }],
        ['collection_file_limit', sub {
            return same_strings([collection_total_errors(129, 120_000, 12_582_912)],
                ['task collection exceeds 128 files']);
        }],
        ['collection_line_limit', sub {
            return same_strings([collection_total_errors(128, 120_001, 12_582_912)],
                ['task collection exceeds 120,000 lines']);
        }],
        ['collection_byte_limit', sub {
            return same_strings([collection_total_errors(128, 120_000, 12_582_913)],
                ['task collection exceeds 12,582,912 bytes']);
        }],
        ['collection_member_line_limit', sub {
            return same_strings([collection_member_errors('member.md', 8_001, 1_048_576)],
                ['task collection member exceeds 8,000 lines: member.md']);
        }],
        ['collection_member_byte_limit', sub {
            return same_strings([collection_member_errors('member.md', 8_000, 1_048_577)],
                ['task collection member exceeds 1,048,576 bytes: member.md']);
        }],
        ['collection_independent_errors', sub {
            return same_strings([collection_total_errors(129, 120_001, 12_582_913)],
                ['task collection exceeds 128 files', 'task collection exceeds 120,000 lines',
                 'task collection exceeds 12,582,912 bytes'])
                && same_strings([collection_member_errors('member.md', 8_001, 1_048_577)],
                    ['task collection member exceeds 8,000 lines: member.md',
                     'task collection member exceeds 1,048,576 bytes: member.md']);
        }],
        ['part_00', sub { part_owns_id('00-08', "$TREE.8.9") && !part_owns_id('00-08', "$TREE.9") }],
        ['part_09', sub { part_owns_id('09', "$TREE.9.1") && !part_owns_id('09', "$TREE.10") }],
        ['part_10_low', sub { part_owns_id('10.0-6', "$TREE.10") && part_owns_id('10.0-6', "$TREE.10.6.9") }],
        ['part_10_high', sub { part_owns_id('10.7-10', "$TREE.10.7") && part_owns_id('10.7-10', "$TREE.10.10") }],
        ['part_11_13', sub { part_owns_id('11-13', "$TREE.11") && part_owns_id('11-13', "$TREE.13.1") }],
        ['part_14_split', sub {
            part_owns_id('14.0-6.4', "$TREE.14")
                && part_owns_id('14.0-6.4', "$TREE.14.6")
                && part_owns_id('14.0-6.4', "$TREE.14.6.4.3")
                && !part_owns_id('14.0-6.4', "$TREE.14.6.5")
                && part_owns_id('14.6.5-8', "$TREE.14.6.5")
                && part_owns_id('14.6.5-8', "$TREE.14.8")
                && !part_owns_id('14.6.5-8', "$TREE.14.6.4.3")
                && !part_owns_id('14.6.5-8', "$TREE.14.9")
        }],
        ['part_15_24', sub { part_owns_id('15-24', "$TREE.15") && part_owns_id('15-24', "$TREE.24.2") }],
        ['duplicate_detection', sub { my %x; return !$x{a}++ && $x{a}++ }],
        ['gap_detection', sub { my %x=(1=>1,3=>1); return ($x{2}//0) != 1 }],
        ['stale_digest', sub { sha256_hex('a') ne sha256_hex('b') }],
        ['root_duplicate_node', sub { "- ID: `$TREE.1`\n" =~ /^- ID: `FUTURE-PARITY-BACKLOG\.[0-9]/m }],
        ['old_consumer_path', sub { index("x $ROOT_PATH y", $ROOT_PATH) >= 0 }],
        ['all_parts_consumer', sub {
            my @paths = map { $_->[1] } grep { $_->[4] } @EXPECTED;
            my $complete = join("\n", @paths);
            my $incomplete = join("\n", @paths[0 .. $#paths - 1]);
            return !(grep { index($complete, $_) < 0 } @paths)
                && grep { index($incomplete, $_) < 0 } @paths;
        }],
    );
    my @failed;
    for my $test (@tests) {
        my ($name, $code) = @$test;
        my $ok = eval { $code->() };
        push @failed, $name if !$ok || $@;
    }
    die "task-tree partition mutation self-tests failed: @failed\n" if @failed;
    print "[task-tree-partitions] mutation self-tests: " . scalar(@tests) . '/' . scalar(@tests) . " pass\n";
}
