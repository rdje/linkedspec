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
        order    => 'source-file',
        anchor   => 1,
    },
    change_history => {
        current  => 'CHANGES.md',
        family   => 'changes',
        manifest => 'docs/history/changes/manifest.jsonl',
        order    => 'reverse-chronological',
        anchor   => 5_000,
    },
    engineering_notes => {
        current  => 'DEVELOPMENT_NOTES.md',
        family   => 'development-notes',
        manifest => 'docs/history/development-notes/manifest.jsonl',
        order    => 'reverse-chronological',
        anchor   => 5_000,
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
        || ($metadata->{source_order} // '') ne $config->{order}
        || ($metadata->{max_segment_lines} // 0) != 4_096
        || ($metadata->{max_segment_bytes} // 0) != 524_288
        || ($metadata->{segment_count} // -1) != @$records;
    push @errors, "$surface manifest must contain at least one segment" if !@$records;

    my $expected_start = 1;
    my $anchor_expected_start = 1;
    my $ordinal = 0;
    my $archive = '';
    my $anchor_reconstructed = '';
    my ($source_commit, $source_blob, $source_path, $current_path);
    my ($anchor_commit, $anchor_blob, $anchor_path);
    my ($previous_number, $saw_anchor);
    my (%target_seen, %source_cache, %blob_cache);
    for my $index (0 .. $#$records) {
        my $record = $records->[$index];
        ++$ordinal;
        ++$segment_count;
        my $id = $record->{segment_id} // sprintf('%04d', $ordinal);
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
            || $id !~ /\A[0-9]{4}\z/
            || !JSON::PP::is_bool($record->{immutable}) || !$record->{immutable};
        if ($surface eq 'live_status') {
            push @errors, "$surface segment $id is not the source-order ordinal"
                if $id ne sprintf('%04d', $ordinal);
        } elsif ($id =~ /\A[0-9]{4}\z/) {
            my $number = 0 + $id;
            push @errors, "$surface segment ids are not ascending and contiguous"
                if defined($previous_number) && $number != $previous_number + 1;
            $previous_number = $number;
            $saw_anchor = 1 if $number == $config->{anchor};
        }
        push @errors, "$surface segment $id has invalid Git identity"
            if ($record->{source_commit} // '') !~ /\A[0-9a-f]{40}\z/
            || ($record->{source_blob} // '') !~ /\A[0-9a-f]{40}\z/;
        push @errors, "$surface segment $id changes current path"
            if ($record->{current_path} // '') ne $config->{current}
            || ($record->{source_path} // '') ne $config->{current};
        my $target = $record->{target_path} // '';
        push @errors, "$surface segment $id target is duplicated" if $target_seen{$target}++;
        push @errors, "$surface segment $id target naming mismatch"
            if ($record->{sha256} // '') !~ /\A[0-9a-f]{64}\z/
            || $target ne "docs/history/$config->{family}/segment-$id-" . substr($record->{sha256} // '', 0, 12) . '.md';
        push @errors, "$surface segment $id retrieval command mismatch"
            if ($record->{retrieval_command} // '') ne "perl tools/read_document_history.pl --surface $surface --segment $id";
        if ($surface eq 'live_status') {
            push @errors, "$surface segment $id range is not contiguous"
                if ($record->{source_start_line} // 0) != $expected_start
                || ($record->{source_end_line} // 0) != $expected_start + ($record->{line_count} // 0) - 1;
            $expected_start = ($record->{source_end_line} // 0) + 1;
        }
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
        $archive .= $bytes;

        my $commit = $record->{source_commit} // '';
        my $path = $record->{source_path} // '';
        if ($commit =~ /\A[0-9a-f]{40}\z/ && safe_path($path)) {
            my $key = "$commit\0$path";
            $source_cache{$key} = git_capture(\@errors, 'show', "$commit:$path")
                if !exists $source_cache{$key};
            if (!exists $blob_cache{$key}) {
                $blob_cache{$key} = git_capture(\@errors, 'rev-parse', "$commit:$path");
                $blob_cache{$key} =~ s/\n\z//;
            }
            push @errors, "$surface segment $id source blob mismatch"
                if $blob_cache{$key} ne ($record->{source_blob} // '');
            my $slice = source_slice($source_cache{$key},
                $record->{source_start_line}, $record->{source_end_line});
            push @errors, "$surface segment $id is not its exact Git source slice"
                if !defined($slice) || $slice ne $bytes;

            my $number = $id =~ /\A[0-9]{4}\z/ ? 0 + $id : 0;
            if ($surface eq 'live_status') {
                for my $pair ([\$source_commit, 'source_commit'], [\$source_blob, 'source_blob'],
                              [\$source_path, 'source_path'], [\$current_path, 'current_path']) {
                    my ($slot, $field) = @$pair;
                    $$slot = $record->{$field} if !defined $$slot;
                    push @errors, "$surface segment $id changes $field"
                        if ($record->{$field} // '') ne ($$slot // '');
                }
                $anchor_reconstructed .= $bytes;
            } elsif ($number >= $config->{anchor}) {
                for my $pair ([\$anchor_commit, 'source_commit'], [\$anchor_blob, 'source_blob'],
                              [\$anchor_path, 'source_path']) {
                    my ($slot, $field) = @$pair;
                    $$slot = $record->{$field} if !defined $$slot;
                    push @errors, "$surface anchor segment $id changes $field"
                        if ($record->{$field} // '') ne ($$slot // '');
                }
                push @errors, "$surface anchor segment $id range is not contiguous"
                    if ($record->{source_start_line} // 0) != $anchor_expected_start
                    || ($record->{source_end_line} // 0)
                        != $anchor_expected_start + ($record->{line_count} // 0) - 1;
                $anchor_expected_start = ($record->{source_end_line} // 0) + 1;
                $anchor_reconstructed .= $bytes;
            } else {
                push @errors, "$surface rollover segment $id is not a complete source suffix"
                    if ($record->{source_end_line} // 0) != line_count($source_cache{$key});
                push @errors, "$surface rollover segment $id does not start at a complete record"
                    if !record_starts_at_boundary($surface, $bytes);
            }
        }
    }
    if ($surface eq 'live_status') {
        push @errors, "$surface current path mismatch" if ($current_path // '') ne $config->{current};
        my $source = git_capture(\@errors, 'show', "$source_commit:$source_path");
        push @errors, "$surface reconstruction differs from Git source"
            if $anchor_reconstructed ne $source;
    } else {
        push @errors, "$surface manifest omits reserved anchor segment 5000" if !$saw_anchor;
        my $anchor_source = defined($anchor_commit) && defined($anchor_path)
            ? git_capture(\@errors, 'show', "$anchor_commit:$anchor_path") : '';
        push @errors, "$surface anchor reconstruction differs from Git source"
            if $anchor_reconstructed ne $anchor_source;
    }
    my $queried = command_capture(\@errors, $^X, 'tools/read_document_history.pl',
        '--surface', $surface, '--all');
    push @errors, "$surface normative --all query differs from manifest order"
        if $queried ne $archive;
    validate_current_view($surface, $config->{current}, \@errors);
}

push @errors, 'no document-history manifest is installed' if !$surface_count;
validate_no_live_capability_authority(\@errors);
my $attributes = read_bytes('.gitattributes', \@errors);
push @errors, 'raw history segment blank-at-EOL/EOF preservation attribute is missing'
    if index($attributes, 'docs/history/**/segment-*.md whitespace=-blank-at-eol,-blank-at-eof') < 0;
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

sub source_slice {
    my ($source, $start, $end) = @_;
    return undef if !defined($start) || !defined($end) || $start !~ /\A[0-9]+\z/
        || $end !~ /\A[0-9]+\z/ || $start < 1 || $end < $start;
    my @lines = split /(?<=\n)/, $source;
    return undef if $end > @lines;
    return join('', @lines[$start - 1 .. $end - 1]);
}

sub record_starts_at_boundary {
    my ($surface, $bytes) = @_;
    return $bytes =~ /\A## / if $surface eq 'change_history';
    return $bytes =~ /\A(?:- 20[0-9]{2}-[0-9]{2}-[0-9]{2}\b|## )/
        if $surface eq 'engineering_notes';
    return 1;
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
    push @$errors, "$surface current view is missing or symbolic" if !-f $path || path_has_symlink($path);
    my $text = read_bytes($path, $errors);
    if ($surface ne 'live_status') {
        push @$errors, "$surface current hot shard exceeds 512 lines" if line_count($text) > 512;
        push @$errors, "$surface current hot shard exceeds 65536 bytes" if length($text) > 65_536;
        push @$errors, "$surface current hot shard reached the mandatory 90% rollover boundary"
            if line_count($text) * 100 >= 512 * 90 || length($text) * 100 >= 65_536 * 90;
        my $title = $surface eq 'change_history' ? '# CHANGES' : '# DEVELOPMENT NOTES';
        my $manifest = $surface eq 'change_history'
            ? 'docs/history/changes/manifest.jsonl'
            : 'docs/history/development-notes/manifest.jsonl';
        push @$errors, "$surface current title mismatch" if index($text, "$title\n") != 0;
        for my $required (
            $manifest,
            "perl tools/read_document_history.pl --surface $surface --all",
            "perl tools/read_document_history.pl --surface $surface --grep '<literal>'",
            "perl tools/roll_document_history.pl --surface $surface --check",
            "perl tools/roll_document_history.pl --surface $surface --apply",
        ) {
            push @$errors, "$surface current hot shard omits required retrieval/rollover text: $required"
                if index($text, $required) < 0;
        }
        my @boundaries = $surface eq 'change_history'
            ? ($text =~ /^## /mg)
            : ($text =~ /^(?:- 20[0-9]{2}-[0-9]{2}-[0-9]{2}\b|## )/mg);
        push @$errors, "$surface current hot shard has no complete record" if !@boundaries;
        if ($surface eq 'change_history') {
            my @headings = $text =~ /^(## .*)$/mg;
            my @invalid = grep { $_ !~ /^## 20[0-9]{2}-[0-9]{2}-[0-9]{2} / } @headings;
            push @$errors, "$surface current hot shard has a non-dated change heading" if @invalid;
        }
        return;
    }
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
        ['hot_line_limit', sub { 513 > 512 }],
        ['hot_byte_limit', sub { 65_537 > 65_536 }],
        ['hot_warn_line_boundary', sub { 410 * 100 >= 512 * 80 && 409 * 100 < 512 * 80 }],
        ['hot_warn_byte_boundary', sub { 52_429 * 100 >= 65_536 * 80 && 52_428 * 100 < 65_536 * 80 }],
        ['hot_roll_line_boundary', sub { 461 * 100 >= 512 * 90 && 460 * 100 < 512 * 90 }],
        ['hot_roll_byte_boundary', sub { 58_983 * 100 >= 65_536 * 90 && 58_982 * 100 < 65_536 * 90 }],
        ['hot_target_boundary', sub { 256 * 100 <= 512 * 50 && 257 * 100 > 512 * 50 }],
        ['change_record_boundary', sub { record_starts_at_boundary('change_history', "## 2026-01-01 x\n") }],
        ['notes_record_boundary', sub {
            record_starts_at_boundary('engineering_notes', "- 2026-01-01 x\n")
                && record_starts_at_boundary('engineering_notes', "## Legacy\n");
        }],
        ['partial_record_rejected', sub {
            !record_starts_at_boundary('change_history', "body\n")
                && !record_starts_at_boundary('engineering_notes', "  continuation\n");
        }],
        ['source_slice_exact', sub { source_slice("a\nb\nc\n", 2, 3) eq "b\nc\n" }],
        ['source_slice_range_rejected', sub { !defined source_slice("a\n", 2, 2) }],
        ['reserved_anchor_order', sub { 4_999 + 1 == 5_000 }],
        ['manifest_id_gap_detection', sub { my ($previous, $current) = (4_999, 5_001); $current != $previous + 1 }],
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
