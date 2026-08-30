#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($RealBin);
use JSON::PP ();

my $ROOT = "$RealBin/..";
my $TASK_DIR = 'docs/tasks';
my $JSON = JSON::PP->new->utf8(1);
my @INDEX_REGISTRY = ('docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl');

chdir $ROOT or die "cannot enter repository root: $!\n";

run_self_tests();

my @errors;
my %immutable_history = registered_immutable_histories(\@errors);
my @task_paths = sort glob("$TASK_DIR/*.md");
push @errors, "task collection member is symbolic: $_" for grep { -l $_ } @task_paths;
my @task_files = grep { -f $_ && !-l $_ } @task_paths;
my %task_file = map { $_ => 1 } @task_files;

for my $path (sort keys %immutable_history) {
    push @errors, "registered immutable history is not a regular task file: $path"
        if !$task_file{$path};
}

my @current_files = current_task_paths(\@task_files, \%immutable_history);
my ($definitions, $locations) = census_current_ids(\@current_files, \@errors);
my @duplicates = sort grep { @{$locations->{$_}} > 1 } keys %$locations;

for my $id (@duplicates) {
    push @errors, "duplicate current task ID `$id`: " . join(', ', @{$locations->{$id}});
}

if (@errors) {
    print STDERR "[task-tree-current-ids] FAIL: $_\n" for @errors;
    exit 1;
}

my $history_count = scalar keys %immutable_history;
print "[task-tree-current-ids] PASS: $definitions definitions / "
    . scalar(keys %$locations) . " unique current IDs across " . scalar(@current_files)
    . " current task files; $history_count registered immutable history file"
    . ($history_count == 1 ? '' : 's') . " excluded\n";

sub registered_immutable_histories {
    my ($errors) = @_;
    my %histories;
    my @tracked_indexes = tracked_index_paths($errors);
    if (join("\0", @tracked_indexes) ne join("\0", @INDEX_REGISTRY)) {
        push @$errors, 'tracked task-tree index registry drift: expected [' . join(', ', @INDEX_REGISTRY)
            . '] but found [' . join(', ', @tracked_indexes) . ']';
    }

    for my $index_path (@INDEX_REGISTRY) {
        if (!-f $index_path || -l $index_path) {
            push @$errors, "tracked task-tree index is not a regular file: $index_path";
            next;
        }
        open my $fh, '<:raw', $index_path or do {
            push @$errors, "cannot read task-tree index $index_path: $!";
            next;
        };
        my @records;
        my $line_number = 0;
        while (my $line = <$fh>) {
            ++$line_number;
            $line =~ s/\r?\n\z//;
            if ($line eq '') {
                push @$errors, "$index_path:$line_number is blank";
                next;
            }
            my $record = eval { $JSON->decode($line) };
            if (!$record || $@ || ref($record) ne 'HASH') {
                push @$errors, "$index_path:$line_number is not one JSON object";
                next;
            }
            push @records, $record;
        }
        close $fh or push @$errors, "cannot close task-tree index $index_path: $!";

        my @metadata = grep { ($_->{type} // '') eq 'task_tree_index' } @records;
        if (@metadata != 1) {
            push @$errors, "$index_path must contain exactly one task_tree_index record";
            next;
        }
        my $history_path = $metadata[0]->{history_path};
        next if !defined($history_path) || $history_path eq '';
        if (!safe_task_path($history_path)) {
            push @$errors, "$index_path has unsafe history_path: $history_path";
            next;
        }

        my @owners = grep {
            ($_->{type} // '') eq 'task_tree_part'
                && ($_->{path} // '') eq $history_path
                && exists($_->{mutable})
                && JSON::PP::is_bool($_->{mutable})
                && !$_->{mutable}
        } @records;
        if (@owners != 1) {
            push @$errors,
                "$index_path history_path must have exactly one immutable task_tree_part owner: $history_path";
            next;
        }
        if (exists $histories{$history_path}) {
            push @$errors,
                "immutable history is registered by multiple task-tree indexes: $history_path";
            next;
        }
        $histories{$history_path} = $index_path;
    }

    return %histories;
}

sub tracked_index_paths {
    my ($errors) = @_;
    open my $fh, '-|', 'git', 'ls-files', '--', "$TASK_DIR/*.index.jsonl" or do {
        push @$errors, 'cannot enumerate tracked task-tree indexes';
        return;
    };
    my @paths = map { chomp; $_ } <$fh>;
    if (!close $fh) {
        push @$errors, 'git ls-files failed while enumerating task-tree indexes';
        return;
    }
    return sort grep { $_ ne '' } @paths;
}

sub safe_task_path {
    my ($path) = @_;
    return defined($path) && !ref($path)
        && $path =~ m{\Adocs/tasks/[A-Za-z0-9][A-Za-z0-9._-]*\.history\.md\z};
}

sub census_current_ids {
    my ($paths, $errors, $fixture_bytes) = @_;
    my (%locations, $definitions);

    for my $path (@$paths) {
        my $bytes;
        if (defined $fixture_bytes) {
            if (!exists $fixture_bytes->{$path}) {
                push @$errors, "fixture bytes missing for $path";
                next;
            }
            $bytes = $fixture_bytes->{$path};
        } else {
            open my $fh, '<:raw', $path or do {
                push @$errors, "cannot read current task file $path: $!";
                next;
            };
            local $/;
            $bytes = <$fh>;
            close $fh or push @$errors, "cannot close current task file $path: $!";
            $bytes = '' if !defined $bytes;
        }

        my $line_number = 0;
        for my $line (split /(?<=\n)/, $bytes) {
            ++$line_number;
            $line =~ s/\r?\n\z//;
            next unless $line =~ /\A- ID: `([^`]+)`\s*\z/;
            my $id = $1;
            ++$definitions;
            push @{$locations{$id}}, "$path:$line_number";
        }
    }

    return ($definitions, \%locations);
}

sub current_task_paths {
    my ($paths, $immutable_history) = @_;
    return grep { !$immutable_history->{$_} } @$paths;
}

sub duplicate_ids {
    my ($paths, $bytes) = @_;
    my @errors;
    my (undef, $locations) = census_current_ids($paths, \@errors, $bytes);
    die "current-ID self-test fixture failed: @errors\n" if @errors;
    return sort grep { @{$locations->{$_}} > 1 } keys %$locations;
}

sub run_self_tests {
    my @tests = (
        ['unique_current_ids', sub {
            my %bytes = (
                'docs/tasks/A.md' => "- ID: `A`\n- ID: `A.1`\n",
                'docs/tasks/B.md' => "- ID: `B`\n",
            );
            my @duplicates = duplicate_ids([sort keys %bytes], \%bytes);
            return !@duplicates;
        }],
        ['duplicate_within_unpartitioned_file', sub {
            my %bytes = ('docs/tasks/A.md' => "- ID: `A.1`\n- ID: `A.1`\n");
            return join(',', duplicate_ids([keys %bytes], \%bytes)) eq 'A.1';
        }],
        ['duplicate_across_unpartitioned_files', sub {
            my %bytes = (
                'docs/tasks/A.md' => "- ID: `SHARED.1`\n",
                'docs/tasks/B.md' => "- ID: `SHARED.1`\n",
            );
            return join(',', duplicate_ids([sort keys %bytes], \%bytes)) eq 'SHARED.1';
        }],
        ['duplicate_across_partitioned_and_unpartitioned_files', sub {
            my %bytes = (
                'docs/tasks/FUTURE.00-08.md' => "- ID: `FUTURE.7`\n",
                'docs/tasks/LEGACY.md' => "- ID: `FUTURE.7`\n",
            );
            return join(',', duplicate_ids([sort keys %bytes], \%bytes)) eq 'FUTURE.7';
        }],
        ['multiple_duplicate_ids', sub {
            my %bytes = (
                'docs/tasks/A.md' => "- ID: `A.1`\n- ID: `B.1`\n",
                'docs/tasks/B.md' => "- ID: `B.1`\n- ID: `A.1`\n",
            );
            return join(',', duplicate_ids([sort keys %bytes], \%bytes)) eq 'A.1,B.1';
        }],
        ['only_exact_definition_lines_count', sub {
            my %bytes = (
                'docs/tasks/A.md' => " - ID: `A.1`\n- ID: `A.1` trailing\n- ID: `A.1`\n",
                'docs/tasks/B.md' => "prose `A.1`\n",
            );
            my @duplicates = duplicate_ids([sort keys %bytes], \%bytes);
            return !@duplicates;
        }],
        ['registered_immutable_history_is_excluded', sub {
            my @paths = ('docs/tasks/A.md', 'docs/tasks/FUTURE.history.md');
            my %history = ('docs/tasks/FUTURE.history.md' => 'docs/tasks/FUTURE.index.jsonl');
            return join(',', current_task_paths(\@paths, \%history)) eq 'docs/tasks/A.md';
        }],
        ['unregistered_history_is_current', sub {
            my @paths = ('docs/tasks/A.md', 'docs/tasks/UNREGISTERED.history.md');
            my %history;
            return join(',', current_task_paths(\@paths, \%history))
                eq 'docs/tasks/A.md,docs/tasks/UNREGISTERED.history.md';
        }],
        ['registered_history_path_shape', sub {
            return safe_task_path('docs/tasks/FUTURE.history.md')
                && !safe_task_path('/tmp/FUTURE.history.md')
                && !safe_task_path('docs/tasks/../FUTURE.history.md')
                && !safe_task_path('docs/tasks/FUTURE.md');
        }],
        ['index_registry_is_closed', sub {
            return @INDEX_REGISTRY == 1
                && $INDEX_REGISTRY[0] eq 'docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl';
        }],
    );

    my @failed;
    for my $test (@tests) {
        my ($name, $code) = @$test;
        my $ok = eval { $code->() };
        push @failed, $name if !$ok || $@;
    }
    die "task-tree current-ID mutation self-tests failed: @failed\n" if @failed;
    print "[task-tree-current-ids] mutation self-tests: " . scalar(@tests) . '/'
        . scalar(@tests) . " pass\n";
}
