#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Spec;
use JSON::PP qw(decode_json encode_json);

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

my @expected_backends = qw(perl rust dart julia lua);
my @expected_exclusions = (
 {
  id                  => 'legacy.perl_plugin_registry',
  reason              => 'Deprecated Perl-only compatibility surface, explicitly outside the backend-neutral product contract.',
  owner               => 'FUTURE-PARITY-BACKLOG.6',
  disposition         => 'legacy',
  retention_authority => undef,
 },
 {
  id                  => 'future.general_parse_job_authoring',
  reason              => 'General provider search and recursive staged queues are a future language/API extension.',
  owner               => 'FUTURE-PARITY-BACKLOG.14',
  disposition         => 'future',
  retention_authority => undef,
 },
);
my %satisfied_exclusion_ids = map { $_ => 1 } qw(
 future.semantic_introspection_mcp
 future.rule_local_cursor_and_bare_edges
);
my %task_status_values = map { $_ => 1 } qw(
 proposed active pending in_progress blocked done deferred superseded
);
my %open_legacy_owner_status = map { $_ => 1 } qw(
 proposed active pending in_progress blocked
);
my %future_owner_status = map { $_ => 1 } qw(proposed active pending);
my $public_close_marker = 'Capability exclusion freshness is public-closed under `FUTURE-PARITY-BACKLOG.24`';
my @expected_public_projections = (
 {
  path => 'capability_conformance/README.md',
  required_markers => [
   "The manifest's exclusion ledger is schema v2 and currently contains exactly two ordered records.",
   $public_close_marker,
  ],
 },
 {
  path => 'ROADMAP.md',
  required_markers => ['Exclusion governance `.24.1` is signoff-complete', $public_close_marker],
 },
 {
  path => 'ROADMAP_V2.md',
  required_markers => ['Exclusion implementation `.24.1` is signoff-complete', $public_close_marker],
 },
 {
  path => 'ARCHITECTURE_STATE.md',
  required_markers => ['`2026-08-01 status-fresh capability exclusions`', $public_close_marker],
 },
 {
  path => 'docs/linkedspec-book/src/development/local-ci-and-regression.md',
  required_markers => [
   'The separate exclusion ledger is now schema v2 with exactly two ordered records:',
   $public_close_marker,
  ],
 },
 {
  path => 'docs/linkedspec-book/src/overview/project-status.md',
  required_markers => ['schema v2 with exactly two status-fresh records:', $public_close_marker],
 },
 {
  path => 'LIVE_ACHIEVEMENT_STATUS.md',
  required_markers => ['Capability exclusion public no-drift is closed', $public_close_marker],
 },
 {
  path => 'docs/TASK_TREE.md',
  required_markers => ['exclusion public closeout `.24.2`', $public_close_marker],
 },
 {
  path => 'docs/tasks/FUTURE-PARITY-BACKLOG.md',
  required_markers => [
   "- ID: `FUTURE-PARITY-BACKLOG.24`\n  Status: `done`",
   "- ID: `FUTURE-PARITY-BACKLOG.24.2`\n  Status: `done`",
   $public_close_marker,
  ],
 },
 {
  path => 'docs/knowledge/capability-exclusion-freshness-model.md',
  required_markers => ['status: public-closed under FUTURE-PARITY-BACKLOG.24', $public_close_marker],
 },
 {
  path => 'docs/knowledge/capability-exclusion-freshness-gap.md',
  required_markers => ['status: public-closed under FUTURE-PARITY-BACKLOG.24', $public_close_marker],
 },
 {
  path => 'KNOWLEDGE_MAP.md',
  required_markers => [
   '### capability-exclusion-freshness-gap',
   '### capability-exclusion-freshness-model',
   'public-closed under FUTURE-PARITY-BACKLOG.24',
  ],
 },
);
my @expected_forbidden_current_claims = (
 {path => 'capability_conformance/README.md', text => 'schema v1 with four stale records'},
 {path => 'ROADMAP.md', text => 'Clean `.24.2` public closeout follows.'},
 {path => 'ROADMAP.md', text => 'Final public no-drift/parent closeout `.24.2` remains.'},
 {path => 'ROADMAP_V2.md', text => 'public closeout `.24.2` remain.'},
 {path => 'ROADMAP_V2.md', text => 'Final public no-drift/parent closure `.24.2` remains.'},
 {path => 'docs/linkedspec-book/src/overview/project-status.md', text => 'schema v1 with four stale records'},
 {path => 'docs/TASK_TREE.md', text => 'exclusion public closeout `.24.2` active'},
 {
  path => 'docs/tasks/FUTURE-PARITY-BACKLOG.md',
  text => "- ID: `FUTURE-PARITY-BACKLOG.24`\n  Status: `active`",
 },
 {
  path => 'docs/tasks/FUTURE-PARITY-BACKLOG.md',
  text => "- ID: `FUTURE-PARITY-BACKLOG.24.2`\n  Status: `active`",
 },
 {
  path => 'docs/knowledge/capability-exclusion-freshness-model.md',
  text => 'final public closeout pending',
 },
);

sub clone_value {
 my ($value) = @_;
 return decode_json(encode_json($value));
}

sub task_sources {
 return [map { +{path => $_, text => read_text($_)} } @task_paths];
}

sub expected_public_contract {
 return {
  projections              => clone_value(\@expected_public_projections),
  forbidden_current_claims => clone_value(\@expected_forbidden_current_claims),
 };
}

sub public_projection_sources {
 my %paths = map { $_->{path} => 1 } (@expected_public_projections, @expected_forbidden_current_claims);
 return {
  map {
   my $relative = $_;
   $relative => read_text(File::Spec->catfile($repo_root, split m{/}, $relative));
  } sort keys %paths
 };
}

sub normalize_space {
 my ($text) = @_;
 $text =~ s/\s+/ /g;
 $text =~ s/^ | $//g;
 return $text;
}

sub validate_public_contract {
 my ($contract, $sources) = @_;
 require_hash_keys('public_contract', $contract, qw(projections forbidden_current_claims));
 fail('public_contract.projections must be an array') unless ref($contract->{projections}) eq 'ARRAY';
 fail('public_contract.forbidden_current_claims must be an array')
  unless ref($contract->{forbidden_current_claims}) eq 'ARRAY';
 fail('public_contract projection count drifted')
  unless @{$contract->{projections}} == @expected_public_projections;
 fail('public_contract forbidden-current-claim count drifted')
  unless @{$contract->{forbidden_current_claims}} == @expected_forbidden_current_claims;

 for my $index (0 .. $#expected_public_projections) {
  my $actual = $contract->{projections}[$index];
  my $expected = $expected_public_projections[$index];
  require_hash_keys("public_contract.projections[$index]", $actual, qw(path required_markers));
  fail("public_contract.projections[$index].path drifted") unless $actual->{path} eq $expected->{path};
  fail("public_contract.projections[$index].required_markers must be an array")
   unless ref($actual->{required_markers}) eq 'ARRAY';
  fail("public_contract.projections[$index].required_markers drifted")
   unless join("\0", @{$actual->{required_markers}}) eq join("\0", @{$expected->{required_markers}});
  fail("public projection source is missing: $actual->{path}") unless exists $sources->{$actual->{path}};
  my $normalized_source = normalize_space($sources->{$actual->{path}});
  for my $marker (@{$actual->{required_markers}}) {
   fail("$actual->{path} is missing public marker: $marker")
    unless index($normalized_source, normalize_space($marker)) >= 0;
  }
 }

 for my $index (0 .. $#expected_forbidden_current_claims) {
  my $actual = $contract->{forbidden_current_claims}[$index];
  my $expected = $expected_forbidden_current_claims[$index];
  require_hash_keys("public_contract.forbidden_current_claims[$index]", $actual, qw(path text));
  fail("public_contract.forbidden_current_claims[$index] drifted")
   unless $actual->{path} eq $expected->{path} && $actual->{text} eq $expected->{text};
  fail("public projection source is missing: $actual->{path}") unless exists $sources->{$actual->{path}};
  fail("$actual->{path} retains forbidden current claim: $actual->{text}")
   if index(normalize_space($sources->{$actual->{path}}), normalize_space($actual->{text})) >= 0;
 }
}

sub parse_task_statuses {
 my ($sources) = @_;
 my %task_status;
 for my $source (@$sources) {
  my @lines = split /\n/, $source->{text}, -1;
  for my $index (0 .. $#lines) {
   next unless $lines[$index] =~ /^(\s*)- ID: `([^`]+)`\s*$/;
   my ($indent, $id) = ($1, $2);
   fail("duplicate task id '$id'") if exists $task_status{$id};
   my $status_line = $lines[$index + 1] // '';
   fail("task '$id' is missing a leading Status field")
    unless $status_line =~ /^\Q$indent\E  Status: `([a-z_]+)[^`]*`/;
   $task_status{$id} = $1;
  }
 }
 return \%task_status;
}

sub validate_manifest {
 my ($manifest, $task_status) = @_;
 require_hash_keys(
  'manifest', $manifest,
  qw(schema_version contract task_owner backends status_values capabilities excluded_or_future)
 );
 fail('schema_version must be 2') unless $manifest->{schema_version} == 2;
 require_repo_path('manifest.contract', $manifest->{contract});
 require_string('manifest.task_owner', $manifest->{task_owner});
 fail("task_owner '$manifest->{task_owner}' is not a tracked task id")
  unless exists $task_status->{$manifest->{task_owner}};
 fail("task_owner '$manifest->{task_owner}' has invalid status '$task_status->{$manifest->{task_owner}}'")
  unless $task_status_values{$task_status->{$manifest->{task_owner}}};

 fail('manifest.backends must be [perl, rust, dart, julia, lua]')
  unless ref($manifest->{backends}) eq 'ARRAY'
  && join("\0", @{$manifest->{backends}}) eq join("\0", @expected_backends);
 my %status = map { $_ => 1 } qw(pass partial gap);
 fail('manifest.status_values must be [pass, partial, gap]')
  unless ref($manifest->{status_values}) eq 'ARRAY'
  && join("\0", @{$manifest->{status_values}}) eq join("\0", qw(pass partial gap));

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
    unless exists $task_status->{$capability->{gap_owner}};
   fail("$where.gap_owner '$capability->{gap_owner}' has invalid status '$task_status->{$capability->{gap_owner}}'")
    unless $task_status_values{$task_status->{$capability->{gap_owner}}};
  } elsif (exists $capability->{gap_owner}) {
   fail("$where.gap_owner is only allowed when a backend is partial or gap");
  }
 }

 fail('manifest.excluded_or_future must be an array') unless ref($manifest->{excluded_or_future}) eq 'ARRAY';
 for my $index (0 .. $#{$manifest->{excluded_or_future}}) {
  my $entry = $manifest->{excluded_or_future}[$index];
  my $where = "excluded_or_future[$index]";
  require_hash_keys($where, $entry, qw(id reason owner disposition retention_authority));
  require_string("$where.id", $entry->{id});
  fail("satisfied exclusion '$entry->{id}' must not be present") if $satisfied_exclusion_ids{$entry->{id}};
  fail("duplicate capability/exclusion id '$entry->{id}'") if $seen_ids{$entry->{id}}++;
  require_string("$where.reason", $entry->{reason});
  require_string("$where.owner", $entry->{owner});
  require_string("$where.disposition", $entry->{disposition});
  fail("$where.disposition is unknown: $entry->{disposition}")
   unless $entry->{disposition} eq 'legacy' || $entry->{disposition} eq 'future';
  fail("$where.id must use the $entry->{disposition}. prefix")
   unless $entry->{id} =~ /^\Q$entry->{disposition}\E\./;
  fail("$where.owner '$entry->{owner}' is not a tracked task id")
   unless exists $task_status->{$entry->{owner}};
  fail("$where.owner '$entry->{owner}' has invalid status '$task_status->{$entry->{owner}}'")
   unless $task_status_values{$task_status->{$entry->{owner}}};
  require_repo_path("$where.retention_authority", $entry->{retention_authority})
   if defined $entry->{retention_authority};

  my $owner_status = $task_status->{$entry->{owner}};
  if ($entry->{disposition} eq 'future') {
   fail("$where future owner '$entry->{owner}' has disallowed status '$owner_status'")
    unless $future_owner_status{$owner_status};
   fail("$where future exclusion must not use retention_authority")
    if defined $entry->{retention_authority};
  } elsif ($open_legacy_owner_status{$owner_status}) {
   fail("$where open legacy exclusion must not use retention_authority")
    if defined $entry->{retention_authority};
  } else {
   fail("$where completed legacy exclusion requires retention_authority")
    unless defined $entry->{retention_authority};
  }
 }

 fail('manifest.excluded_or_future must contain exactly the two governed records')
  unless @{$manifest->{excluded_or_future}} == @expected_exclusions;
 for my $index (0 .. $#expected_exclusions) {
  my $actual = $manifest->{excluded_or_future}[$index];
  my $expected = $expected_exclusions[$index];
  for my $key (qw(id reason owner disposition)) {
   fail("excluded_or_future[$index].$key drifted from the governed value")
    unless $actual->{$key} eq $expected->{$key};
  }
  fail("excluded_or_future[$index].retention_authority drifted from the governed value")
   if defined($actual->{retention_authority}) != defined($expected->{retention_authority});
 }

 return \%counts;
}

sub validate_candidate {
 my ($manifest, $sources) = @_;
 return validate_manifest($manifest, parse_task_statuses($sources));
}

sub expect_mutation_failure {
 my ($name, $check) = @_;
 my $passed = eval {
  $check->();
  1;
 };
 fail("governance mutation '$name' unexpectedly passed") if $passed;
 die $@ unless $@ =~ /^capability-conformance: ERROR:/;
}

sub mutate_task_status_line {
 my ($sources, $id, $replacement) = @_;
 my $candidate = clone_value($sources);
 my $changed = 0;
 for my $source (@$candidate) {
  $changed += ($source->{text} =~ s{^(- ID: `\Q$id\E`\n)  Status: `[^\n]+\n}{$1$replacement}m);
 }
 die "mutation setup could not find task '$id' exactly once\n" unless $changed == 1;
 return $candidate;
}

sub governance_mutation_checks {
 my ($manifest, $sources) = @_;
 my @mutations;
 my $add_manifest_mutation = sub {
  my ($name, $mutate) = @_;
  push @mutations, [$name, sub {
   my $candidate = clone_value($manifest);
   $mutate->($candidate);
   validate_candidate($candidate, $sources);
  }];
 };

 $add_manifest_mutation->('schema_version_downgrade', sub { $_[0]{schema_version} = 1 });
 $add_manifest_mutation->('missing_disposition', sub { delete $_[0]{excluded_or_future}[0]{disposition} });
 $add_manifest_mutation->('unknown_disposition', sub { $_[0]{excluded_or_future}[0]{disposition} = 'parked' });
 $add_manifest_mutation->('legacy_id_future_disposition', sub { $_[0]{excluded_or_future}[0]{disposition} = 'future' });
 $add_manifest_mutation->('future_id_legacy_disposition', sub { $_[0]{excluded_or_future}[1]{disposition} = 'legacy' });
 $add_manifest_mutation->('future_retention_authority', sub {
  $_[0]{excluded_or_future}[1]{retention_authority} = 'docs/decisions/0056-typed-source-location-and-cursor-algebra.md';
 });
 $add_manifest_mutation->('open_legacy_retention_authority', sub {
  $_[0]{excluded_or_future}[0]{retention_authority} = 'docs/knowledge/pplugin-pluginbridge-transition-machinery.md';
 });
 $add_manifest_mutation->('completed_legacy_without_retention', sub {
  $_[0]{excluded_or_future}[0]{owner} = 'FUTURE-PARITY-BACKLOG.1.6';
 });
 $add_manifest_mutation->('completed_future_even_with_retention', sub {
  $_[0]{excluded_or_future}[1]{owner} = 'FUTURE-PARITY-BACKLOG.1.6';
  $_[0]{excluded_or_future}[1]{retention_authority} = 'docs/decisions/0056-typed-source-location-and-cursor-algebra.md';
 });
 $add_manifest_mutation->('missing_owner_task', sub {
  $_[0]{excluded_or_future}[0]{owner} = 'FUTURE-PARITY-BACKLOG.missing';
 });
 push @mutations, ['missing_owner_status', sub {
  my $candidate_sources = mutate_task_status_line($sources, 'FUTURE-PARITY-BACKLOG.6', '');
  validate_candidate($manifest, $candidate_sources);
 }];
 push @mutations, ['duplicate_owner_id', sub {
  my $candidate_sources = clone_value($sources);
  $candidate_sources->[0]{text} .= "\n- ID: `FUTURE-PARITY-BACKLOG.6`\n  Status: `pending`\n";
  validate_candidate($manifest, $candidate_sources);
 }];
 push @mutations, ['invalid_owner_status', sub {
  my $candidate_sources = mutate_task_status_line(
   $sources,
   'FUTURE-PARITY-BACKLOG.6',
   "  Status: `invalid`\n",
  );
  validate_candidate($manifest, $candidate_sources);
 }];
 $add_manifest_mutation->('missing_retention_authority', sub {
  delete $_[0]{excluded_or_future}[0]{retention_authority};
 });
 $add_manifest_mutation->('extra_exclusion', sub {
  push @{$_[0]{excluded_or_future}}, {
   id                  => 'future.extra',
   reason              => 'Unexpected extra exclusion.',
   owner               => 'FUTURE-PARITY-BACKLOG.14',
   disposition         => 'future',
   retention_authority => undef,
  };
 });
 $add_manifest_mutation->('omitted_exclusion', sub { pop @{$_[0]{excluded_or_future}} });
 $add_manifest_mutation->('duplicated_exclusion', sub {
  push @{$_[0]{excluded_or_future}}, clone_value($_[0]{excluded_or_future}[0]);
 });
 $add_manifest_mutation->('reordered_exclusions', sub {
  $_[0]{excluded_or_future} = [reverse @{$_[0]{excluded_or_future}}];
 });
 $add_manifest_mutation->('legacy_reason_drift', sub { $_[0]{excluded_or_future}[0]{reason} .= ' drift' });
 $add_manifest_mutation->('future_reason_drift', sub { $_[0]{excluded_or_future}[1]{reason} .= ' drift' });
 $add_manifest_mutation->('legacy_owner_drift', sub { $_[0]{excluded_or_future}[0]{owner} = 'FUTURE-PARITY-BACKLOG.14' });
 $add_manifest_mutation->('future_owner_drift', sub { $_[0]{excluded_or_future}[1]{owner} = 'FUTURE-PARITY-BACKLOG.6' });
 for my $id (qw(future.semantic_introspection_mcp future.rule_local_cursor_and_bare_edges)) {
  $add_manifest_mutation->("satisfied_${id}_resurrection", sub {
   push @{$_[0]{excluded_or_future}}, {
    id                  => $id,
    reason              => 'Satisfied exclusion must stay absent.',
    owner               => 'FUTURE-PARITY-BACKLOG.14',
    disposition         => 'future',
    retention_authority => undef,
   };
  });
 }

 expect_mutation_failure(@$_) for @mutations;
 return scalar @mutations;
}

sub public_projection_mutation_checks {
 my ($contract, $sources) = @_;
 my @mutations;

 push @mutations, ['public_projection_omission', sub {
  my $candidate = clone_value($contract);
  pop @{$candidate->{projections}};
  validate_public_contract($candidate, $sources);
 }];
 push @mutations, ['public_marker_omission', sub {
  my $candidate = clone_value($contract);
  pop @{$candidate->{projections}[0]{required_markers}};
  validate_public_contract($candidate, $sources);
 }];
 push @mutations, ['forbidden_current_claim_omission', sub {
  my $candidate = clone_value($contract);
  pop @{$candidate->{forbidden_current_claims}};
  validate_public_contract($candidate, $sources);
 }];
 push @mutations, ['public_marker_contract_drift', sub {
  my $candidate = clone_value($contract);
  $candidate->{projections}[0]{required_markers}[0] .= ' drift';
 validate_public_contract($candidate, $sources);
 }];
 push @mutations, ['rendered_book_marker_drift', sub {
  my $candidate_sources = clone_value($sources);
  my $path = 'docs/linkedspec-book/src/overview/project-status.md';
  my $marker = 'schema v2 with exactly two status-fresh records:';
  my $position = index($candidate_sources->{$path}, $marker);
  die "mutation setup could not find rendered-book marker exactly once\n"
   unless $position >= 0 && index($candidate_sources->{$path}, $marker, $position + 1) < 0;
  substr($candidate_sources->{$path}, $position, length($marker), 'schema v1 with four stale records:');
  validate_public_contract($contract, $candidate_sources);
 }];
 push @mutations, ['forbidden_current_claim_injection', sub {
  my $candidate_sources = clone_value($sources);
  my $entry = $expected_forbidden_current_claims[0];
  $candidate_sources->{$entry->{path}} .= "\n$entry->{text}\n";
  validate_public_contract($contract, $candidate_sources);
 }];

 expect_mutation_failure(@$_) for @mutations;
 return scalar @mutations;
}

my $manifest = eval { decode_json(read_text($manifest_path)) };
fail("invalid JSON in capability_conformance/manifest.json: $@") if $@;
my $sources = task_sources();
my $counts = validate_candidate($manifest, $sources);
my $mutation_count = governance_mutation_checks($manifest, $sources);
my $public_contract = expected_public_contract();
my $public_sources = public_projection_sources();
validate_public_contract($public_contract, $public_sources);
my $public_mutation_count = public_projection_mutation_checks($public_contract, $public_sources);

printf "capability-conformance: OK (schema v2; %d capabilities; backend states pass=%d partial=%d gap=%d; %d exclusions; %d governance mutations; %d governed projections; %d public mutations)\n",
 scalar(@{$manifest->{capabilities}}), @{$counts}{qw(pass partial gap)}, scalar(@{$manifest->{excluded_or_future}}),
 $mutation_count, scalar(@expected_public_projections), $public_mutation_count;
