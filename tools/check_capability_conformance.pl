#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Spec;
use JSON::PP qw(decode_json);

my $repo_root = abs_path(File::Spec->catdir(dirname(__FILE__), '..'));
my $manifest_path = File::Spec->catfile($repo_root, 'capability_conformance', 'manifest.json');
my @task_paths = (
 File::Spec->catfile($repo_root, 'docs', 'tasks', 'FUTURE-PARITY-BACKLOG.md'),
 File::Spec->catfile($repo_root, 'docs', 'tasks', 'LUA-BACKEND-PARITY.md'),
);

sub fail {
 my ($message) = @_;
 die "capability-conformance: ERROR: $message\n";
}

sub read_text {
 my ($path) = @_;
 open my $fh, '<:raw', $path or fail("cannot read $path: $!");
 local $/;
 my $text = <$fh>;
 close $fh or fail("cannot close $path: $!");
 return $text;
}

sub require_hash_keys {
 my ($where, $value, @keys) = @_;
 fail("$where must be an object") unless ref($value) eq 'HASH';
 my %allowed = map { $_ => 1 } @keys;
 for my $key (keys %$value) {
  fail("$where has unknown key '$key'") unless $allowed{$key};
 }
 for my $key (@keys) {
  next if $key eq 'gap_owner' || $key eq 'note';
  fail("$where is missing '$key'") unless exists $value->{$key};
 }
}

sub require_string {
 my ($where, $value) = @_;
 fail("$where must be a non-empty string") if ref($value) || !defined($value) || $value eq '';
}

sub require_repo_path {
 my ($where, $path) = @_;
 require_string($where, $path);
 fail("$where must be repo-relative: $path") if File::Spec->file_name_is_absolute($path) || $path =~ m{(?:^|/)\.\.(?:/|$)};
 fail("$where does not exist: $path") unless -e File::Spec->catfile($repo_root, split m{/}, $path);
}

my $manifest = eval { decode_json(read_text($manifest_path)) };
fail("invalid JSON in capability_conformance/manifest.json: $@") if $@;
require_hash_keys(
 'manifest', $manifest,
 qw(schema_version contract task_owner backends status_values capabilities excluded_or_future)
);
fail('schema_version must be 1') unless $manifest->{schema_version} == 1;
require_repo_path('manifest.contract', $manifest->{contract});
require_string('manifest.task_owner', $manifest->{task_owner});

my @expected_backends = qw(perl rust dart julia lua);
fail('manifest.backends must be [perl, rust, dart, julia, lua]')
 unless ref($manifest->{backends}) eq 'ARRAY'
 && join("\0", @{$manifest->{backends}}) eq join("\0", @expected_backends);
my %status = map { $_ => 1 } qw(pass partial gap);
fail('manifest.status_values must be [pass, partial, gap]')
 unless ref($manifest->{status_values}) eq 'ARRAY'
 && join("\0", @{$manifest->{status_values}}) eq join("\0", qw(pass partial gap));

my %owner_ids;
for my $task_path (@task_paths) {
 my $task_text = read_text($task_path);
 $owner_ids{$_} = 1 for $task_text =~ /^- ID: `([^`]+)`/mg;
}
$owner_ids{'FUTURE-PARITY-BACKLOG.2'} = 1;
$owner_ids{'FUTURE-PARITY-BACKLOG.3'} = 1;
$owner_ids{'FUTURE-PARITY-BACKLOG.6'} = 1;
fail("task_owner '$manifest->{task_owner}' is not in FUTURE-PARITY-BACKLOG") unless $owner_ids{$manifest->{task_owner}};

fail('manifest.capabilities must be a non-empty array')
 unless ref($manifest->{capabilities}) eq 'ARRAY' && @{$manifest->{capabilities}};
my %seen_ids;
my %counts = map { $_ => 0 } keys %status;
for my $index (0 .. $#{$manifest->{capabilities}}) {
 my $capability = $manifest->{capabilities}[$index];
 my $where = "capabilities[$index]";
 require_hash_keys($where, $capability, qw(id category contract sources backends gap_owner));
 require_string("$where.id", $capability->{id});
 fail("duplicate capability id '$capability->{id}'") if $seen_ids{$capability->{id}}++;
 require_string("$where.category", $capability->{category});
 require_string("$where.contract", $capability->{contract});
 fail("$where.sources must be a non-empty array")
  unless ref($capability->{sources}) eq 'ARRAY' && @{$capability->{sources}};
 require_repo_path("$where.sources", $_) for @{$capability->{sources}};
 fail("$where.backends must be an object") unless ref($capability->{backends}) eq 'HASH';
 fail("$where.backends has the wrong backend set")
  unless join("\0", sort keys %{$capability->{backends}}) eq join("\0", sort @expected_backends);

 my $needs_owner = 0;
 for my $backend (@expected_backends) {
  my $entry = $capability->{backends}{$backend};
  my $entry_where = "$where.backends.$backend";
  require_hash_keys($entry_where, $entry, qw(status references note));
  fail("$entry_where.status is unknown: $entry->{status}") unless $status{$entry->{status}};
  $counts{$entry->{status}}++;
  $needs_owner = 1 unless $entry->{status} eq 'pass';
  fail("$entry_where.references must be a non-empty array")
   unless ref($entry->{references}) eq 'ARRAY' && @{$entry->{references}};
  require_repo_path("$entry_where.references", $_) for @{$entry->{references}};
  require_string("$entry_where.note", $entry->{note}) if exists $entry->{note};
 }
 if ($needs_owner) {
  require_string("$where.gap_owner", $capability->{gap_owner});
  fail("$where.gap_owner '$capability->{gap_owner}' is not a tracked task id")
   unless $owner_ids{$capability->{gap_owner}};
 } elsif (exists $capability->{gap_owner}) {
  fail("$where.gap_owner is only allowed when a backend is partial or gap");
 }
}

fail('manifest.excluded_or_future must be an array') unless ref($manifest->{excluded_or_future}) eq 'ARRAY';
for my $index (0 .. $#{$manifest->{excluded_or_future}}) {
 my $entry = $manifest->{excluded_or_future}[$index];
 my $where = "excluded_or_future[$index]";
 require_hash_keys($where, $entry, qw(id reason owner));
 require_string("$where.id", $entry->{id});
 fail("duplicate capability/exclusion id '$entry->{id}'") if $seen_ids{$entry->{id}}++;
 require_string("$where.reason", $entry->{reason});
 require_string("$where.owner", $entry->{owner});
 fail("$where.owner '$entry->{owner}' is not a tracked task id") unless $owner_ids{$entry->{owner}};
}

printf "capability-conformance: OK (%d capabilities; backend states pass=%d partial=%d gap=%d)\n",
 scalar(@{$manifest->{capabilities}}), @counts{qw(pass partial gap)};
