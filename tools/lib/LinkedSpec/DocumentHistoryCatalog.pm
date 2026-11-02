package LinkedSpec::DocumentHistoryCatalog;
use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use Exporter 'import';
use File::Basename qw(dirname);
use File::Path qw(make_path);
use File::Temp qw(tempfile);
use JSON::PP ();

our @EXPORT_OK = qw(read_catalog write_catalog read_history_segment check_catalog_store);
my $JSON = JSON::PP->new->canonical(1)->utf8(1)->allow_nonref(1);
my @META = qw(authority current_path max_segment_bytes max_segment_lines schema_version segment_count source_order surface type);
my @SEGMENT = qw(byte_count current_path immutable line_count retrieval_command segment_id sha256 source_blob source_commit source_end_line source_path source_start_line surface target_path type);
my @REF = qw(byte_count first_id last_id segment_count sha256 target_path type);
my @PAGE = qw(bucket kind row_count schema_version segment_count surface type);

sub exact {
    my ($record, $keys) = @_;
    return ref($record) eq 'HASH' && join("\0", sort keys %$record) eq join("\0", sort @$keys);
}
sub number {
    my ($value) = @_;
    return defined($value) && !ref($value) && $JSON->encode($value) =~ /\A[0-9]+\z/;
}
sub safe {
    my ($path) = @_;
    return defined($path) && !ref($path) && $path ne '' && $path !~ m{\A/|\\|\0|//}
        && !grep { $_ eq '.' || $_ eq '..' || $_ eq '.git' } split m{/}, $path;
}
sub read_bytes {
    my ($path) = @_;
    die "unsafe catalog path: $path\n" unless safe($path);
    my $cursor = '';
    for my $part (split m{/}, $path) {
        $cursor = length($cursor) ? "$cursor/$part" : $part;
        die "symbolic catalog path: $path\n" if -l $cursor;
    }
    open my $fh, '<:raw', $path or die "cannot read $path: $!\n";
    local $/;
    my $raw = <$fh> // '';
    close $fh or die "cannot close $path: $!\n";
    return $raw;
}
sub decode_lines {
    my ($raw, $path, $bounded) = @_;
    die "catalog exceeds per-file byte bound: $path\n" if $bounded && length($raw) > 65_536;
    my @lines = split /\n/, $raw, -1;
    die "catalog lacks final newline: $path\n" unless @lines && pop(@lines) eq '';
    die "empty catalog: $path\n" unless @lines;
    die "catalog exceeds per-file row bound: $path\n" if $bounded && @lines > 33;
    my @records;
    for my $line (@lines) {
        die "blank catalog record: $path\n" if $line eq '';
        my $value = eval { $JSON->decode($line) };
        die "invalid catalog JSON: $path\n" if $@ || ref($value) ne 'HASH';
        die "noncanonical catalog JSON: $path\n" if $JSON->encode($value) ne $line;
        push @records, $value;
    }
    return \@records;
}
sub segment {
    my ($row, $surface, $directory) = @_;
    die "invalid history segment record\n" unless exact($row, \@SEGMENT)
        && ($row->{type} // '') eq 'segment' && ($row->{surface} // '') eq $surface
        && ($row->{segment_id} // '') =~ /\A[0-9]{4}\z/
        && ($row->{sha256} // '') =~ /\A[0-9a-f]{64}\z/
        && JSON::PP::is_bool($row->{immutable}) && $row->{immutable};
    for my $field (qw(byte_count line_count source_start_line source_end_line)) {
        die "invalid segment numeric field: $field\n" unless number($row->{$field}) && $row->{$field} > 0;
    }
    for my $field (qw(current_path source_path target_path)) {
        die "unsafe segment path: $field\n" unless safe($row->{$field});
    }
    die "segment target naming mismatch\n" unless $row->{target_path} eq
        "$directory/segment-$row->{segment_id}-".substr($row->{sha256}, 0, 12).'.md';
}
sub reference {
    my ($row, $directory) = @_;
    die "invalid catalog reference\n" unless exact($row, \@REF)
        && ($row->{type} // '') eq 'catalog_page'
        && ($row->{sha256} // '') =~ /\A[0-9a-f]{64}\z/
        && ($row->{first_id} // '') =~ /\A[0-9]{4}\z/
        && ($row->{last_id} // '') =~ /\A[0-9]{4}\z/
        && number($row->{byte_count}) && $row->{byte_count} > 0 && $row->{byte_count} <= 65_536
        && number($row->{segment_count}) && $row->{segment_count} > 0
        && safe($row->{target_path})
        && index($row->{target_path}, "$directory/catalog/") == 0;
}
sub walk_page {
    my ($ref, $surface, $directory, $reader, $kind, $seen) = @_;
    reference($ref, $directory);
    my $path = $ref->{target_path};
    die "duplicate or cyclic catalog reference: $path\n" if $seen->{$path}++;
    my $raw = $reader->($path);
    die "catalog page identity mismatch: $path\n"
        unless length($raw) == $ref->{byte_count} && sha256_hex($raw) eq $ref->{sha256};
    my $rows = decode_lines($raw, $path, 1);
    my $meta = shift @$rows;
    die "catalog page metadata mismatch: $path\n" unless exact($meta, \@PAGE)
        && ($meta->{type} // '') eq 'history_catalog_page'
        && number($meta->{schema_version}) && $meta->{schema_version} == 1
        && ($meta->{surface} // '') eq $surface && ($meta->{kind} // '') eq $kind
        && number($meta->{bucket}) && number($meta->{row_count})
        && number($meta->{segment_count}) && $meta->{row_count} == @$rows && @$rows;
    my $expected = "$directory/catalog/$kind-".sprintf('%04d', $meta->{bucket})."-$ref->{sha256}.jsonl";
    die "catalog page naming mismatch: $path\n" unless $path eq $expected;
    my @segments;
    if ($kind eq 'segments') {
        for my $row (@$rows) {
            segment($row, $surface, $directory);
            my $id = 0 + "$row->{segment_id}";
            die "segment outside catalog bucket: $path\n" unless int($id / 32) == $meta->{bucket};
            push @segments, $row;
        }
    } elsif ($kind eq 'index') {
        for my $child (@$rows) {
            my $items = walk_page($child, $surface, $directory, $reader, 'segments', $seen);
            for my $row (@$items) {
                my $id = 0 + "$row->{segment_id}";
                die "segment outside index bucket: $path\n" unless int($id / 1024) == $meta->{bucket};
            }
            push @segments, @$items;
        }
    } else {
        die "unknown catalog page kind\n";
    }
    die "catalog page counts or range differ: $path\n" unless
        @segments == $meta->{segment_count} && @segments == $ref->{segment_count}
        && $segments[0]{segment_id} eq $ref->{first_id} && $segments[-1]{segment_id} eq $ref->{last_id};
    return \@segments;
}
sub read_catalog {
    my ($path, $reader) = @_;
    die "unsafe manifest path\n" unless safe($path);
    $reader ||= \&read_bytes;
    my $directory = dirname($path);
    my $raw = $reader->($path);
    my $rows = decode_lines($raw, $path, 0);
    my $metadata = shift @$rows;
    die "history metadata schema mismatch\n" unless exact($metadata, \@META)
        && ($metadata->{type} // '') eq 'document_history'
        && number($metadata->{schema_version})
        && ($metadata->{schema_version} == 1 || $metadata->{schema_version} == 2)
        && number($metadata->{segment_count}) && $metadata->{segment_count} > 0;
    my @records;
    if ($metadata->{schema_version} == 1) {
        @records = @$rows;
        segment($_, $metadata->{surface}, $directory) for @records;
    } else {
        die "root catalog exceeds its row bound\n" if @$rows > 32;
        die "root catalog exceeds its byte bound\n" if length($raw) > 65_536;
        my %seen;
        for my $row (@$rows) {
            push @records, @{walk_page($row, $metadata->{surface}, $directory, $reader, 'index', \%seen)};
        }
    }
    die "history segment count mismatch\n" unless @records == $metadata->{segment_count};
    my %ids;
    my $previous;
    for my $row (@records) {
        die "duplicate segment identity\n" if $ids{$row->{segment_id}}++;
        my $id = 0 + "$row->{segment_id}";
        die "history IDs are not positive and contiguous\n"
            if !$id || (defined($previous) && $id != $previous + 1);
        $previous = $id;
    }
    $metadata = {%$metadata, schema_version => 1};
    return ($metadata, \@records);
}
sub atomic {
    my ($path, $raw, $immutable) = @_;
    die "unsafe catalog output\n" unless safe($path);
    if (-e $path || -l $path) {
        my $existing = read_bytes($path);
        return if $existing eq $raw;
        die "immutable catalog page changed: $path\n" if $immutable;
    }
    my $directory = dirname($path);
    # Check every existing ancestor before allocating a directory or file.
    my $cursor = '';
    for my $part (split m{/}, $directory) {
        $cursor = length($cursor) ? "$cursor/$part" : $part;
        die "symbolic output directory\n" if -l $cursor;
    }
    make_path($directory) unless -d $directory;
    my ($fh, $temporary) = tempfile('.catalog-XXXXXXXX', DIR => $directory, UNLINK => 1);
    binmode $fh;
    my $ok = eval {
        print {$fh} $raw or die "cannot write catalog: $!\n";
        close $fh or die "cannot close catalog: $!\n";
        rename $temporary, $path or die "cannot publish catalog: $!\n";
        1;
    };
    my $error = $@;
    unlink $temporary if -e $temporary;
    die $error unless $ok;
}
sub encode_rows {
    return join('', map { $JSON->encode($_)."\n" } @_);
}
sub write_page {
    my ($directory, $surface, $kind, $bucket, $rows, $segments) = @_;
    my $meta = {type => 'history_catalog_page', schema_version => 1, surface => $surface,
        kind => $kind, bucket => 0 + $bucket, row_count => scalar(@$rows), segment_count => scalar(@$segments)};
    my $raw = encode_rows($meta, @$rows);
    die "catalog page exceeds bound\n" if length($raw) > 65_536 || @$rows > 32;
    my $sha = sha256_hex($raw);
    my $path = "$directory/catalog/$kind-".sprintf('%04d', $bucket)."-$sha.jsonl";
    atomic($path, $raw, 1);
    return {type => 'catalog_page', target_path => $path, sha256 => $sha, byte_count => length($raw),
        segment_count => scalar(@$segments), first_id => "$segments->[0]{segment_id}",
        last_id => "$segments->[-1]{segment_id}"};
}
sub write_catalog {
    my ($path, $metadata, $records) = @_;
    die "catalog producer metadata schema mismatch\n" unless exact($metadata, \@META)
        && ($metadata->{type} // '') eq 'document_history'
        && number($metadata->{schema_version})
        && ($metadata->{schema_version} == 1 || $metadata->{schema_version} == 2);
    die "cannot publish an empty history catalog\n" unless @$records;
    die "catalog producer segment count differs\n"
        unless number($metadata->{segment_count}) && $metadata->{segment_count} == @$records;
    my $directory = dirname($path);
    my (%buckets, %parents);
    my $previous;
    for my $row (@$records) {
        segment($row, $metadata->{surface}, $directory);
        my $id = 0 + "$row->{segment_id}";
        die "catalog producer IDs are not positive and contiguous\n"
            if !$id || (defined($previous) && $id != $previous + 1);
        $previous = $id;
        push @{$buckets{int($id / 32)}}, $row;
    }
    for my $bucket (sort {$a <=> $b} keys %buckets) {
        my $rows = $buckets{$bucket};
        my $ref = write_page($directory, $metadata->{surface}, 'segments', $bucket, $rows, $rows);
        push @{$parents{int($bucket / 32)}}, [$ref, $rows];
    }
    my @root;
    for my $bucket (sort {$a <=> $b} keys %parents) {
        my @refs = map { $_->[0] } @{$parents{$bucket}};
        my @segments = map { @{$_->[1]} } @{$parents{$bucket}};
        push @root, write_page($directory, $metadata->{surface}, 'index', $bucket, \@refs, \@segments);
    }
    my $raw = encode_rows({%$metadata, schema_version => 2, segment_count => scalar(@$records)}, @root);
    # Validate the complete candidate against its already published immutable pages
    # before replacing the live root. A rejected producer must preserve readers.
    my ($actual_meta, $actual) = read_catalog($path, sub {
        return $_[0] eq $path ? $raw : read_bytes($_[0]);
    });
    die "published catalog changed ordered segment records\n"
        unless encode_rows(@$actual) eq encode_rows(@$records);
    atomic($path, $raw, 0);
    return 1;
}
sub read_history_segment {
    my ($record) = @_;
    my $raw = read_bytes($record->{target_path});
    my $lines = () = $raw =~ /\n/g;
    ++$lines if length($raw) && $raw !~ /\n\z/;
    die "history segment identity mismatch: $record->{target_path}\n"
        unless length($raw) == $record->{byte_count} && sha256_hex($raw) eq $record->{sha256}
            && $lines == $record->{line_count};
    return $raw;
}
sub check_catalog_store {
    my ($path, $records) = @_;
    my $directory = dirname($path);
    my %known = map { $_->{segment_id} => $JSON->encode($_) } @$records;
    for my $page (sort glob("$directory/catalog/*")) {
        die "unknown catalog store member: $page\n" unless $page =~ /\.jsonl\z/ && -f $page && !-l $page;
        my $raw = read_bytes($page);
        my $rows = decode_lines($raw, $page, 1);
        die "empty catalog page\n" unless @$rows > 1;
        my $meta = $rows->[0];
        my $sha = sha256_hex($raw);
        my $kind = $meta->{kind} // '';
        die "unknown archived catalog kind\n" unless $kind eq 'segments' || $kind eq 'index';
        my $items = $kind eq 'segments' ? [@$rows[1 .. $#$rows]] : [];
        if ($kind eq 'index') {
            my %seen;
            for my $child (@$rows[1 .. $#$rows]) {
                push @$items, @{walk_page($child, $meta->{surface}, $directory, \&read_bytes, 'segments', \%seen)};
            }
        }
        my $ref = {type => 'catalog_page', target_path => $page, sha256 => $sha,
            byte_count => length($raw), segment_count => scalar(@$items),
            first_id => "$items->[0]{segment_id}", last_id => "$items->[-1]{segment_id}"};
        my %seen;
        $items = walk_page($ref, $meta->{surface}, $directory, \&read_bytes, $kind, \%seen);
        for my $row (@$items) {
            die "archived catalog record is not retained by current history\n"
                unless exists($known{$row->{segment_id}}) && $known{$row->{segment_id}} eq $JSON->encode($row);
        }
    }
    return 1;
}
1;
