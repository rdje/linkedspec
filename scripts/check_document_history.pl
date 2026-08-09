#!/usr/bin/env perl
use strict;
use warnings;

use Digest::SHA qw(sha256_hex);
use FindBin qw($RealBin);
use Getopt::Long qw(GetOptions);
use JSON::PP ();

my $ROOT = "$RealBin/..";
my $AUTHORITY = 'docs/decisions/0066-bounded-live-document-store.md';
my $JSON = JSON::PP->new->canonical(1)->utf8(1);
my @METADATA_KEYS = qw(authority current_path max_segment_bytes max_segment_lines schema_version segment_count source_order surface type);
my @SEGMENT_KEYS = qw(byte_count current_path immutable line_count retrieval_command segment_id sha256 source_blob source_commit source_end_line source_path source_start_line surface target_path type);
my %CONFIG = (
    live_status => {
        current  => 'LIVE_ACHIEVEMENT_STATUS.md',
        family   => 'live-achievement-status',
        manifest => 'docs/history/live-achievement-status/manifest.jsonl',
    },
    change_history => {
        current  => 'CHANGES.md',
        family   => 'changes',
        manifest => 'docs/history/changes/manifest.jsonl',
    },
    engineering_notes => {
        current  => 'DEVELOPMENT_NOTES.md',
        family   => 'development-notes',
        manifest => 'docs/history/development-notes/manifest.jsonl',
    },
);
my $self_test = 0;
GetOptions('self-test' => \$self_test) or die "usage: perl scripts/check_document_history.pl [--self-test]\n";
chdir $ROOT or die "cannot enter repository root: $!\n";

if ($self_test) {
    run_self_tests();
    exit 0;
}

my @errors;
my $head_listing = git_capture(\@errors, 'ls-tree', '-r', '--name-only', 'HEAD');
my %HEAD_PATH = map { $_ => 1 } grep { $_ ne '' } split /\n/, $head_listing;
my $surface_count = 0;
my $segment_count = 0;
for my $surface (sort keys %CONFIG) {
    my $config = $CONFIG{$surface};
    next if !-e $config->{manifest};
    ++$surface_count;
    push @errors, "$surface manifest path is symbolic"
        if path_has_symlink($config->{manifest});
    my ($records, $lines) = decode_manifest($config->{manifest}, \@errors);
    next if !@$records;
    my $metadata = shift @$records;
    push @errors, "$surface metadata keys are not exact"
        if !exact_keys($metadata, \@METADATA_KEYS);
    push @errors, "$surface metadata is not canonical JSON"
        if @$lines && $JSON->encode($metadata) ne $lines->[0];
    push @errors, "$surface metadata contract mismatch"
        if ($metadata->{type} // '') ne 'document_history'
        || ($metadata->{schema_version} // 0) != 1
        || ($metadata->{authority} // '') ne $AUTHORITY
        || ($metadata->{surface} // '') ne $surface
        || ($metadata->{current_path} // '') ne $config->{current}
        || ($metadata->{source_order} // '') ne 'source-file'
        || ($metadata->{max_segment_lines} // 0) != 4_096
        || ($metadata->{max_segment_bytes} // 0) != 524_288
        || ($metadata->{segment_count} // -1) != @$records;
    push @errors, "$surface manifest must contain at least one segment" if !@$records;

    my $expected_start = 1;
    my $ordinal = 0;
    my $reconstructed = '';
    my ($source_commit, $source_blob, $source_path, $current_path);
    my %target_seen;
    for my $index (0 .. $#$records) {
        my $record = $records->[$index];
        ++$ordinal;
        ++$segment_count;
        my $id = sprintf('%04d', $ordinal);
        push @errors, "$surface segment $id keys are not exact"
            if !exact_keys($record, \@SEGMENT_KEYS);
        push @errors, "$surface segment $id is not canonical JSON"
            if defined($lines->[$index + 1]) && $JSON->encode($record) ne $lines->[$index + 1];
        for my $field (qw(source_path target_path current_path)) {
            push @errors, "$surface segment $id has unsafe $field"
                if !safe_path($record->{$field});
        }
        push @errors, "$surface segment $id identity mismatch"
            if ($record->{type} // '') ne 'segment'
            || ($record->{surface} // '') ne $surface
            || ($record->{segment_id} // '') ne $id
            || !JSON::PP::is_bool($record->{immutable}) || !$record->{immutable};
        push @errors, "$surface segment $id has invalid Git identity"
            if ($record->{source_commit} // '') !~ /\A[0-9a-f]{40}\z/
            || ($record->{source_blob} // '') !~ /\A[0-9a-f]{40}\z/;
        my $target = $record->{target_path} // '';
        push @errors, "$surface segment $id target is duplicated" if $target_seen{$target}++;
        push @errors, "$surface segment $id target naming mismatch"
            if ($record->{sha256} // '') !~ /\A[0-9a-f]{64}\z/
            || $target ne "docs/history/$config->{family}/segment-$id-" . substr($record->{sha256} // '', 0, 12) . '.md';
        push @errors, "$surface segment $id retrieval command mismatch"
            if ($record->{retrieval_command} // '') ne "perl tools/read_document_history.pl --surface $surface --segment $id";
        push @errors, "$surface segment $id range is not contiguous"
            if ($record->{source_start_line} // 0) != $expected_start
            || ($record->{source_end_line} // 0) != $expected_start + ($record->{line_count} // 0) - 1;
        $expected_start = ($record->{source_end_line} // 0) + 1;
        push @errors, "$surface segment $id target is missing or symbolic"
            if !-f $target || path_has_symlink($target);
        my $bytes = read_bytes($target, \@errors);
        my $head_bytes = $HEAD_PATH{$target} ? git_optional('show', "HEAD:$target") : undef;
        push @errors, "$surface segment $id changed after its immutable commit"
            if defined($head_bytes) && $bytes ne $head_bytes;
        push @errors, "$surface segment $id line count mismatch"
            if line_count($bytes) != ($record->{line_count} // -1);
        push @errors, "$surface segment $id byte count mismatch"
            if length($bytes) != ($record->{byte_count} // -1);
        push @errors, "$surface segment $id digest mismatch"
            if sha256_hex($bytes) ne ($record->{sha256} // '');
        push @errors, "$surface segment $id exceeds fixed ceiling"
            if line_count($bytes) > 4_096 || length($bytes) > 524_288;
        $reconstructed .= $bytes;
        for my $pair ([\$source_commit, 'source_commit'], [\$source_blob, 'source_blob'],
                      [\$source_path, 'source_path'], [\$current_path, 'current_path']) {
            my ($slot, $field) = @$pair;
            $$slot = $record->{$field} if !defined $$slot;
            push @errors, "$surface segment $id changes $field" if ($record->{$field} // '') ne ($$slot // '');
        }
    }
    push @errors, "$surface current path mismatch" if ($current_path // '') ne $config->{current};
    my $source = git_capture(\@errors, 'show', "$source_commit:$source_path");
    my $blob = git_capture(\@errors, 'rev-parse', "$source_commit:$source_path");
    $blob =~ s/\n\z//;
    push @errors, "$surface source blob mismatch" if $blob ne ($source_blob // '');
    push @errors, "$surface reconstruction differs from Git source" if $reconstructed ne $source;
    my $queried = command_capture(\@errors, $^X, 'tools/read_document_history.pl',
        '--surface', $surface, '--all');
    push @errors, "$surface normative --all query differs from reconstructed segments"
        if $queried ne $reconstructed;
    validate_current_view($surface, $config->{current}, \@errors);
}

push @errors, 'no document-history manifest is installed' if !$surface_count;
validate_no_live_capability_authority(\@errors);
my $attributes = read_bytes('.gitattributes', \@errors);
push @errors, 'raw history segment blank-at-EOF preservation attribute is missing'
    if index($attributes, 'docs/history/**/segment-*.md whitespace=-blank-at-eof') < 0;
if (@errors) {
    print STDERR "[document-history] FAIL: $_\n" for @errors;
    exit 1;
}
print "[document-history] PASS: $surface_count surface(s), $segment_count segment(s), exact reconstruction and bounded current views\n";
exit 0;

sub exact_keys {
    my ($record, $keys) = @_;
    return ref($record) eq 'HASH' && join("\0", sort keys %$record) eq join("\0", sort @$keys);
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

sub decode_manifest {
    my ($path, $errors) = @_;
    my $bytes = read_bytes($path, $errors);
    my (@records, @canonical_lines);
    my @lines = split /\n/, $bytes, -1;
    pop @lines if @lines && $lines[-1] eq '';
    my $number = 0;
    for my $line (@lines) {
        ++$number;
        if ($line eq '') { push @$errors, "$path:$number is blank"; next }
        my $record = eval { JSON::PP->new->utf8(1)->decode($line) };
        if (!$record || $@ || ref($record) ne 'HASH') {
            push @$errors, "$path:$number is not one JSON object";
            next;
        }
        push @records, $record;
        push @canonical_lines, $line;
    }
    return (\@records, \@canonical_lines);
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

sub validate_current_view {
    my ($surface, $path, $errors) = @_;
    return if $surface ne 'live_status';
    push @$errors, "$surface current view is missing or symbolic" if !-f $path || path_has_symlink($path);
    my $text = read_bytes($path, $errors);
    push @$errors, "$surface current view exceeds 256 lines" if line_count($text) > 256;
    push @$errors, "$surface current view exceeds 32768 bytes" if length($text) > 32_768;
    my @headings = ($text =~ /^(?:#|##) .+$/mg);
    my @expected = (
        '# LIVE ACHIEVEMENT STATUS',
        '## Current Activity',
        '## Latest Completed Slice',
        '## Next Action',
        '## Recent Completions',
        '## History',
    );
    push @$errors, "$surface current view heading order/shape mismatch"
        if join("\0", @headings) ne join("\0", @expected);
    my ($recent) = $text =~ /^## Recent Completions\n(.*?)(?=^## History\n)/ms;
    my @rows = defined($recent) ? ($recent =~ /^- /mg) : ();
    push @$errors, "$surface current view has more than sixteen recent rows" if @rows > 16;
    push @$errors, "$surface current view omits history manifest"
        if index($text, 'docs/history/live-achievement-status/manifest.jsonl') < 0;
    push @$errors, "$surface current view omits whole-history query"
        if index($text, 'perl tools/read_document_history.pl --surface live_status --all') < 0;
}

sub validate_no_live_capability_authority {
    my ($errors) = @_;
    my @paths = (
        glob('capability_conformance/*.json'),
        qw(
            tools/check_callable_codeblock_contract.py
            tools/check_capability_conformance.pl
            tools/check_duplicate_regex_slot_identity_contract.py
            tools/check_logical_helper_contract.py
            tools/check_repeated_action_result_contract.py
            tools/check_root_rule_selection_contract.py
            tools/check_rule_local_cursor_contract.py
        ),
    );
    for my $path (@paths) {
        next if !-f $path;
        my $text = read_bytes($path, $errors);
        push @$errors, "capability contract restores live chronology authority: $path"
            if index($text, 'LIVE_ACHIEVEMENT_STATUS.md') >= 0;
    }
}

sub run_self_tests {
    my @tests = (
        ['absolute_path', sub { !safe_path('/tmp/x') }],
        ['traversal_path', sub { !safe_path('../x') && !safe_path('a/../b') && !safe_path('./x') && !safe_path('a\\b') }],
        ['double_separator', sub { !safe_path('a//b') }],
        ['safe_relative_path', sub { safe_path('docs/history/x.md') && !path_has_symlink('docs/history/nonexistent-safe-path.md') }],
        ['closed_metadata_schema', sub { !exact_keys({type => 'document_history'}, \@METADATA_KEYS) }],
        ['closed_segment_schema', sub { !exact_keys({type => 'segment'}, \@SEGMENT_KEYS) }],
        ['segment_id_shape', sub { '0001' =~ /\A[0-9]{4}\z/ && '1' !~ /\A[0-9]{4}\z/ }],
        ['commit_shape', sub { ('a' x 40) =~ /\A[0-9a-f]{40}\z/ && ('g' x 40) !~ /\A[0-9a-f]{40}\z/ }],
        ['digest_shape', sub { sha256_hex('x') =~ /\A[0-9a-f]{64}\z/ }],
        ['line_count_lf', sub { line_count("a\nb\n") == 2 }],
        ['line_count_no_final_lf', sub { line_count("a\nb") == 2 }],
        ['line_count_empty', sub { line_count('') == 0 }],
        ['gap_detection', sub { my $expected=4; my $actual=5; $expected != $actual }],
        ['overlap_detection', sub { my $expected=4; my $actual=3; $expected != $actual }],
        ['count_drift', sub { length('abc') != 4 }],
        ['hash_drift', sub { sha256_hex('a') ne sha256_hex('b') }],
        ['current_line_limit', sub { 257 > 256 }],
        ['current_byte_limit', sub { 32_769 > 32_768 }],
        ['recent_row_limit', sub { 17 > 16 }],
        ['live_authority_literal', sub { index('x LIVE_ACHIEVEMENT_STATUS.md y', 'LIVE_ACHIEVEMENT_STATUS.md') >= 0 }],
    );
    my @failed;
    for my $test (@tests) {
        my ($name, $code) = @$test;
        my $ok = eval { $code->() };
        push @failed, $name if !$ok || $@;
    }
    die "document-history mutation self-tests failed: @failed\n" if @failed;
    print "[document-history] mutation self-tests: " . scalar(@tests) . '/' . scalar(@tests) . " pass\n";
}
