#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($RealBin);

# Moving an unchanged node must not manufacture another completed slice.
my $ROOT = "$RealBin/..";
my @FIELDS = ('Verification tier', 'Focused checks', 'Canonical trigger');
die "usage: perl tools/check_task_verification_fields.pl [--self-test]\n"
    if @ARGV && (@ARGV != 1 || $ARGV[0] ne '--self-test');
run_self_tests();
if (@ARGV) { print "task-verification-fields: PASS 14 identity/relocation controls\n"; exit 0 }

chdir $ROOT or die "cannot enter repository root: $!\n";
my @paths = grep { $_ ne '' } split /\0/, git_bytes(
    'diff', '--cached', '--no-renames', '--name-only', '-z', '--', 'docs/tasks/*.md');
my %head_paths = map { $_ => 1 } split /\0/, git_bytes(
    'ls-tree', '-r', '--name-only', '-z', 'HEAD', '--', 'docs/tasks/');
my %index_paths = map { $_ => 1 } split /\0/, git_bytes('ls-files', '-z', '--', 'docs/tasks/*.md');
my (%before, %after);
for my $path (@paths) {
    $before{$path} = git_bytes('show', "HEAD:$path") if $head_paths{$path};
    $after{$path} = git_bytes('show', ":$path") if $index_paths{$path};
}
my ($owner, $tier) = changed_owner(\%before, \%after);
print "$tier\n";

sub declarations {
    my ($files) = @_;
    my %declarations;
    for my $path (sort keys %$files) {
        my $owner;
        for my $line (split /\n/, $files->{$path}) {
            if ($line =~ /^- ID: `([^`]+)`[ \t]*$/) { $owner = $1; next }
            $owner = undef if $line =~ /^## /;
            next if $line !~ /^  (Verification tier|Focused checks|Canonical trigger):[ \t]*(.*)$/;
            my ($field, $value) = ($1, $2);
            # A newly introduced unowned declaration must not become invisible.
            my $key = defined($owner) ? $owner : "unowned:$path";
            push @{$declarations{$key}{$field}}, $value;
        }
    }
    return \%declarations;
}

sub changed_owner {
    my ($old_files, $new_files) = @_;
    my $old = declarations($old_files);
    my $new = declarations($new_files);
    my %ids = map { $_ => 1 } (keys %$old, keys %$new);
    my @changed;
    for my $id (sort keys %ids) {
        my $changed = 0;
        for my $field (@FIELDS) {
            my $a = $old->{$id}{$field} // [];
            my $b = $new->{$id}{$field} // [];
            $changed = 1 if @$a != @$b || join("\0", @$a) ne join("\0", @$b);
        }
        push @changed, $id if $changed;
    }
    die "verification declarations must change for exactly one owning leaf; found "
        . scalar(@changed) . " [" . join(', ', @changed) . "]\n" if @changed != 1;
    my $owner = $changed[0];
    die "verification owner must be a stable leaf ID: $owner\n"
        if $owner !~ /\A[A-Z][A-Z0-9-]*(?:\.[0-9]+)+\z/;
    for my $field (@FIELDS) {
        my $values = $new->{$owner}{$field} // [];
        die "$owner must contain exactly one nonempty $field declaration\n"
            if @$values != 1 || $values->[0] !~ /\S/;
    }
    my ($tier) = $new->{$owner}{'Verification tier'}[0] =~ /\A`(focused|canonical)`\z/;
    die "$owner has an invalid Verification tier\n" if !defined $tier;
    return ($owner, $tier);
}

sub node {
    my ($id, $tier) = @_;
    return "- ID: `$id`\n  Status: `done`\n  Verification tier: `$tier`\n"
        . "  Focused checks: exact contract proof\n  Canonical trigger: declared boundary\n";
}

sub run_self_tests {
    my $old = node('EXAMPLE.1', 'focused');
    my $next = node('EXAMPLE.2', 'canonical');
    my @tests = (
        ['new_leaf', {}, {'tree.md' => $next}, 'canonical'],
        ['relocation_and_leaf', {'tree.md' => $old}, {'part.md' => $old, 'tree.md' => $next}, 'canonical'],
        ['relocation_only', {'tree.md' => $old}, {'part.md' => $old}, undef],
        ['missing_tier', {}, {'tree.md' => ($next =~ s/^  Verification tier:.*\n//mr)}, undef],
        ['duplicate_tier', {}, {'tree.md' => $next . "  Verification tier: `canonical`\n"}, undef],
        ['missing_focus', {}, {'tree.md' => ($next =~ s/^  Focused checks:.*\n//mr)}, undef],
        ['empty_focus', {}, {'tree.md' => ($next =~ s/  Focused checks:.*/  Focused checks:/r)}, undef],
        ['duplicate_trigger', {}, {'tree.md' => $next . "  Canonical trigger: second\n"}, undef],
        ['split_ownership', {}, {'tree.md' => $old . $next}, undef],
        ['unowned', {}, {'tree.md' => "  Verification tier: `focused`\n"}, undef],
        ['invalid_tier', {}, {'tree.md' => node('EXAMPLE.2', 'skip')}, undef],
        ['deleted_fields', {'tree.md' => $old}, {'tree.md' => "- ID: `EXAMPLE.1`\n"}, undef],
        ['altered_moved_node', {'tree.md' => $old},
            {'part.md' => node('EXAMPLE.1', 'canonical'), 'tree.md' => $next}, undef],
        ['duplicated_moved_node', {'tree.md' => $old},
            {'part.md' => $old . $old, 'tree.md' => $next}, undef],
    );
    for my $test (@tests) {
        my ($name, $before, $after, $expected) = @$test;
        my (undef, $tier) = eval { changed_owner($before, $after) };
        my $error = $@;
        die "task verification self-test failed: $name\n"
            if defined($expected) ? ($error || !defined($tier) || $tier ne $expected) : !$error;
    }
}

sub git_bytes {
    open my $fh, '-|', 'git', '-C', $ROOT, @_ or die "cannot run git @_: $!\n";
    binmode $fh; local $/; my $bytes = <$fh>;
    close $fh or die "git @_ failed\n";
    return $bytes // '';
}
