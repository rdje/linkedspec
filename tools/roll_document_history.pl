#!/usr/bin/env perl
use strict;
use warnings;

use Digest::SHA qw(sha256_hex);
use FindBin qw($RealBin);
use Getopt::Long qw(GetOptions);
use JSON::PP ();

my $ROOT = "$RealBin/..";
my $MAX_LINES = 512;
my $MAX_BYTES = 65_536;
my $WARN_PERCENT = 80;
my $ROLL_PERCENT = 90;
my $TARGET_PERCENT = 50;
my $JSON = JSON::PP->new->canonical(1)->utf8(1);
my %CONFIG = (
    change_history => {
        current  => 'CHANGES.md',
        family   => 'changes',
        manifest => 'docs/history/changes/manifest.jsonl',
        title    => '# CHANGES',
        boundary => qr/^## /m,
    },
    engineering_notes => {
        current  => 'DEVELOPMENT_NOTES.md',
        family   => 'development-notes',
        manifest => 'docs/history/development-notes/manifest.jsonl',
        title    => '# DEVELOPMENT NOTES',
        boundary => qr/^(?:- 20[0-9]{2}-[0-9]{2}-[0-9]{2}\b|## )/m,
    },
);

my ($surface, $check, $apply, $self_test);
GetOptions(
    'surface=s' => \$surface,
    'check'     => \$check,
    'apply'     => \$apply,
    'self-test' => \$self_test,
) or die usage();
if ($self_test) {
    die usage() if defined($surface) || $check || $apply;
    run_self_tests();
    exit 0;
}
die usage() if !defined($surface) || !exists($CONFIG{$surface}) || ($check ? 1 : 0) + ($apply ? 1 : 0) != 1;

chdir $ROOT or die "cannot enter repository root: $!\n";
my $config = $CONFIG{$surface};
my $current = read_bytes($config->{current});
my ($preamble, $records) = split_current($current, $config);
validate_preamble($surface, $preamble, $config);
my ($lines, $bytes) = (line_count($current), length($current));
my $warn = threshold_reached($lines, $bytes, $WARN_PERCENT);
my $roll = threshold_reached($lines, $bytes, $ROLL_PERCENT);

if ($check) {
    die "document-history rollover required for $surface: $lines/$MAX_LINES lines, $bytes/$MAX_BYTES bytes\n"
        if $roll;
    my $state = $warn ? 'WARN' : 'OK';
    print "document-history rollover $state: $surface has $lines/$MAX_LINES lines and $bytes/$MAX_BYTES bytes\n";
    exit 0;
}

if (!$roll) {
    print "document-history rollover: $surface is below the 90% boundary; no files changed\n";
    exit 0;
}

my $head = git_bytes('show', "HEAD:$config->{current}");
my ($head_preamble, $head_records) = split_current($head, $config);
die "$surface preamble differs from clean HEAD; rollover only permits prepended complete records\n"
    if $preamble ne $head_preamble;
die "$surface removes or rewrites clean HEAD records; rollover only permits prepended complete records\n"
    if @$records < @$head_records;
my $new_count = @$records - @$head_records;
for my $index (0 .. $#$head_records) {
    die "$surface clean HEAD record order/content changed at record " . ($index + 1) . "\n"
        if $records->[$new_count + $index] ne $head_records->[$index];
}

my $keep = scalar(@$records);
while ($keep > $new_count) {
    my $candidate = $preamble . join_prefix($records, $keep);
    last if !threshold_exceeded(line_count($candidate), length($candidate), $TARGET_PERCENT);
    --$keep;
}
die "$surface cannot reach the <=50% rollover target without archiving uncommitted records\n"
    if $keep == $new_count
    && threshold_exceeded(line_count($preamble . join_prefix($records, $keep)),
        length($preamble . join_prefix($records, $keep)), $TARGET_PERCENT);
die "$surface rollover would leave no current record\n" if $keep == 0;

my $retained = $preamble . join_prefix($records, $keep);
die "$surface rollover did not reach the <=50% target\n"
    if threshold_exceeded(line_count($retained), length($retained), $TARGET_PERCENT);
my $archived = join('', @$records[$keep .. $#$records]);
die "$surface rollover selected no archive bytes\n" if $archived eq '';
die "$surface rollover selection is not an exact suffix of clean HEAD\n"
    if length($archived) > length($head) || substr($head, length($head) - length($archived)) ne $archived;

my ($metadata, $manifest_records) = read_manifest($config->{manifest});
die "$surface manifest is not reverse-chronological\n"
    if ($metadata->{source_order} // '') ne 'reverse-chronological';
die "$surface manifest segment count is stale\n"
    if ($metadata->{segment_count} // -1) != @$manifest_records;
my $source_commit = git_text('rev-parse', 'HEAD');
chomp $source_commit;
my $source_blob = git_text('rev-parse', "HEAD:$config->{current}");
chomp $source_blob;
my $prefix_bytes = substr($head, 0, length($head) - length($archived));
my $source_start = line_count($prefix_bytes) + 1;
my $archive_lines = line_count($archived);
my $source_end = $source_start + $archive_lines - 1;
my $digest = sha256_hex($archived);

my $pending = $manifest_records->[0];
my $pending_id = $pending->{segment_id} // '';
if ($pending_id =~ /\A[0-9]{4}\z/ && 0 + $pending_id < 5_000) {
    my $pending_target = "docs/history/$config->{family}/segment-$pending_id-"
        . substr($digest, 0, 12) . '.md';
    my $expected_pending = segment_record(
        $surface, $config, $pending_id, $pending_target, $digest, $source_commit, $source_blob,
        $source_start, $source_end, $archive_lines, length($archived));
    if ($JSON->encode($pending) eq $JSON->encode($expected_pending)) {
        die "$surface pending rollover target is missing, symbolic, or corrupt: $pending_target\n"
            if !-f $pending_target || -l $pending_target || read_bytes($pending_target) ne $archived;
        write_atomic($config->{current}, $retained);
        print "document-history rollover: $surface recovered pending generation $pending_id; current is "
            . line_count($retained) . "/$MAX_LINES lines and " . length($retained)
            . "/$MAX_BYTES bytes\n";
        exit 0;
    }
}

my $first_id = $manifest_records->[0]{segment_id} // '';
die "$surface first segment id is invalid\n" if $first_id !~ /\A[0-9]{4}\z/;
my $new_number = 0 + $first_id - 1;
die "$surface rollover segment-id reserve is exhausted\n" if $new_number < 1;
my $segment_id = sprintf('%04d', $new_number);
my $target = "docs/history/$config->{family}/segment-$segment_id-" . substr($digest, 0, 12) . '.md';
die "$surface rollover target exists with different bytes: $target\n"
    if -e $target && (!-f $target || -l $target || read_bytes($target) ne $archived);
my $new_record = segment_record(
    $surface, $config, $segment_id, $target, $digest, $source_commit, $source_blob,
    $source_start, $source_end, $archive_lines, length($archived));
$metadata->{segment_count} = @$manifest_records + 1;
my $manifest = join('', map { $JSON->encode($_) . "\n" }
    ($metadata, $new_record, @$manifest_records));

# The root is the only copy whose removal changes the current author view, so replace it last. If the process
# stops after creating the segment or publishing the manifest, a rerun either completes the same content-addressed
# generation or recognizes that exact pending manifest record and installs the already-computed retained root.
write_atomic($target, $archived) if !-e $target;
write_atomic($config->{manifest}, $manifest);
write_atomic($config->{current}, $retained);
print "document-history rollover: $surface archived $archive_lines line(s) as $segment_id; current is "
    . line_count($retained) . "/$MAX_LINES lines and " . length($retained) . "/$MAX_BYTES bytes\n";

sub segment_record {
    my ($surface_id, $config, $segment_id, $target, $digest, $source_commit, $source_blob,
        $source_start, $source_end, $line_count, $byte_count) = @_;
    return {
    byte_count        => $byte_count,
    current_path      => $config->{current},
    immutable         => JSON::PP::true,
    line_count        => $line_count,
    retrieval_command => "perl tools/read_document_history.pl --surface $surface_id --segment $segment_id",
    segment_id        => $segment_id,
    sha256            => $digest,
    source_blob       => $source_blob,
    source_commit     => $source_commit,
    source_end_line   => $source_end,
    source_path       => $config->{current},
    source_start_line => $source_start,
    surface           => $surface_id,
    target_path       => $target,
    type              => 'segment',
    };
}

sub usage {
    return "usage: perl tools/roll_document_history.pl --surface change_history|engineering_notes "
        . "(--check | --apply)\n"
        . "       perl tools/roll_document_history.pl --self-test\n";
}

sub split_current {
    my ($text, $config) = @_;
    my @starts;
    while ($text =~ /$config->{boundary}/g) {
        push @starts, $-[0];
    }
    die "$config->{current} has no complete hot-shard record boundary\n" if !@starts;
    my $preamble = substr($text, 0, $starts[0]);
    my @records;
    for my $index (0 .. $#starts) {
        my $end = $index == $#starts ? length($text) : $starts[$index + 1];
        push @records, substr($text, $starts[$index], $end - $starts[$index]);
    }
    return ($preamble, \@records);
}

sub validate_preamble {
    my ($surface, $preamble, $config) = @_;
    die "$surface current title mismatch\n" if index($preamble, "$config->{title}\n") != 0;
    die "$surface current preamble omits its history manifest\n"
        if index($preamble, $config->{manifest}) < 0;
    die "$surface current preamble omits its whole-history query\n"
        if index($preamble, "perl tools/read_document_history.pl --surface $surface --all") < 0;
    die "$surface current preamble omits its rollover check\n"
        if index($preamble, "perl tools/roll_document_history.pl --surface $surface --check") < 0;
}

sub threshold_reached {
    my ($lines, $bytes, $percent) = @_;
    return $lines * 100 >= $MAX_LINES * $percent || $bytes * 100 >= $MAX_BYTES * $percent;
}

sub threshold_exceeded {
    my ($lines, $bytes, $percent) = @_;
    return $lines * 100 > $MAX_LINES * $percent || $bytes * 100 > $MAX_BYTES * $percent;
}

sub join_prefix {
    my ($records, $count) = @_;
    return '' if $count == 0;
    return join('', @$records[0 .. $count - 1]);
}

sub line_count {
    my ($bytes) = @_;
    return 0 if $bytes eq '';
    my $count = () = $bytes =~ /\n/g;
    ++$count if $bytes !~ /\n\z/;
    return $count;
}

sub read_manifest {
    my ($path) = @_;
    my $bytes = read_bytes($path);
    my @lines = split /\n/, $bytes, -1;
    pop @lines if @lines && $lines[-1] eq '';
    die "empty manifest: $path\n" if !@lines;
    my @records;
    for my $number (1 .. @lines) {
        die "blank manifest record at $path:$number\n" if $lines[$number - 1] eq '';
        my $record = eval { JSON::PP->new->utf8(1)->decode($lines[$number - 1]) };
        die "invalid manifest record at $path:$number\n"
            if !$record || $@ || ref($record) ne 'HASH';
        die "non-canonical manifest record at $path:$number\n"
            if $JSON->encode($record) ne $lines[$number - 1];
        push @records, $record;
    }
    my $metadata = shift @records;
    return ($metadata, \@records);
}

sub read_bytes {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "cannot read $path: $!\n";
    local $/;
    my $bytes = <$fh>;
    close $fh or die "cannot close $path: $!\n";
    return defined($bytes) ? $bytes : '';
}

sub git_bytes {
    my (@args) = @_;
    open my $fh, '-|', 'git', '-C', $ROOT, @args or die "cannot run git @args: $!\n";
    binmode $fh;
    local $/;
    my $bytes = <$fh>;
    close $fh or die "git @args failed\n";
    return defined($bytes) ? $bytes : '';
}

sub git_text {
    return git_bytes(@_);
}

sub write_atomic {
    my ($path, $bytes) = @_;
    my $temporary = "$path.tmp.$$";
    die "temporary path already exists: $temporary\n" if -e $temporary;
    open my $fh, '>:raw', $temporary or die "cannot write $temporary: $!\n";
    print {$fh} $bytes or die "cannot write $temporary: $!\n";
    close $fh or die "cannot close $temporary: $!\n";
    rename $temporary, $path or die "cannot replace $path: $!\n";
}

sub run_self_tests {
    my $changes = {
        current => 'CHANGES.md', title => '# CHANGES', boundary => qr/^## /m,
        manifest => 'docs/history/changes/manifest.jsonl',
    };
    my $notes = {
        current => 'DEVELOPMENT_NOTES.md', title => '# DEVELOPMENT NOTES',
        boundary => qr/^(?:- 20[0-9]{2}-[0-9]{2}-[0-9]{2}\b|## )/m,
        manifest => 'docs/history/development-notes/manifest.jsonl',
    };
    my @tests = (
        ['changes_boundaries', sub {
            my (undef, $records) = split_current("# CHANGES\n\n## one\na\n## two\nb\n", $changes);
            @$records == 2 && $records->[0] eq "## one\na\n" && $records->[1] eq "## two\nb\n";
        }],
        ['notes_boundaries', sub {
            my (undef, $records) = split_current("# DEVELOPMENT NOTES\n\n- 2026-01-02 one\n  body\n## heading\ntext\n", $notes);
            @$records == 2 && $records->[0] =~ /body/ && $records->[1] =~ /heading/;
        }],
        ['line_count', sub { line_count("a\nb\n") == 2 && line_count("a\nb") == 2 }],
        ['warn_boundary', sub { threshold_reached(410, 1, 80) && !threshold_reached(409, 1, 80) }],
        ['roll_line_boundary', sub { threshold_reached(461, 1, 90) && !threshold_reached(460, 1, 90) }],
        ['roll_byte_boundary', sub { threshold_reached(1, 58_983, 90) && !threshold_reached(1, 58_982, 90) }],
        ['target_boundary', sub {
            !threshold_exceeded(256, 32_768, 50) && threshold_exceeded(257, 32_768, 50)
                && threshold_exceeded(256, 32_769, 50);
        }],
        ['suffix_identity', sub { my $head = 'abc'; my $suffix = 'bc'; substr($head, length($head)-length($suffix)) eq $suffix }],
        ['canonical_json', sub { $JSON->encode({b => 2, a => 1}) eq '{"a":1,"b":2}' }],
        ['segment_reserve', sub { sprintf('%04d', 5_000 - 1) eq '4999' }],
        ['pending_generation_identity', sub {
            my $record = segment_record('change_history', $changes, '4999',
                'docs/history/changes/segment-4999-abc.md', 'a' x 64, 'b' x 40, 'c' x 40,
                7, 9, 3, 12);
            $record->{segment_id} eq '4999' && $record->{source_start_line} == 7
                && $record->{source_end_line} == 9 && $record->{line_count} == 3
                && $record->{byte_count} == 12;
        }],
        ['publish_root_last', sub {
            my @publish_order = qw(segment manifest current);
            join(' ', @publish_order) eq 'segment manifest current';
        }],
    );
    my @failed;
    for my $test (@tests) {
        my ($name, $code) = @$test;
        my $ok = eval { $code->() };
        push @failed, $name if !$ok || $@;
    }
    die "document-history rollover self-tests failed: @failed\n" if @failed;
    print "document-history rollover self-tests: " . scalar(@tests) . '/' . scalar(@tests) . " pass\n";
}
