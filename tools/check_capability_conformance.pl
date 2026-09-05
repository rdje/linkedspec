#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(abs_path);
use Digest::SHA qw(sha256_hex);
use File::Basename qw(dirname);
use File::Spec;
use JSON::PP qw(decode_json encode_json);

my $repo_root = abs_path(File::Spec->catdir(dirname(__FILE__), '..'));
my $manifest_path = File::Spec->catfile($repo_root, 'capability_conformance', 'manifest.json');
my @task_paths = (
 map(
  { File::Spec->catfile($repo_root, 'docs', 'tasks', $_) }
  qw(
   FUTURE-PARITY-BACKLOG.00-08.md
   FUTURE-PARITY-BACKLOG.09.md
   FUTURE-PARITY-BACKLOG.10.0-6.md
   FUTURE-PARITY-BACKLOG.10.7-10.md
   FUTURE-PARITY-BACKLOG.11-13.md
   FUTURE-PARITY-BACKLOG.14.md
   FUTURE-PARITY-BACKLOG.14.6.5-8.md
   FUTURE-PARITY-BACKLOG.15-24.md
  )
 ),
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
);
my %satisfied_exclusion_ids = map { $_ => 1 } qw(
 future.semantic_introspection_mcp
 future.rule_local_cursor_and_bare_edges
 future.general_parse_job_authoring
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
   "The manifest's exclusion ledger is schema v2 and currently contains exactly one governed record.",
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
   'The separate exclusion ledger is now schema v2 with exactly one governed record:',
   $public_close_marker,
  ],
 },
 {
  path => 'docs/linkedspec-book/src/overview/project-status.md',
  required_markers => ['schema v2 with exactly one status-fresh record:', $public_close_marker],
 },
 {
  path => 'docs/decisions/0067-live-achievement-status-history.md',
  required_markers => ['Capability exclusion public no-drift is closed', $public_close_marker],
 },
 {
  path => 'docs/TASK_TREE.md',
  required_markers => ['exclusion public closeout `.24.2`', $public_close_marker],
 },
 {
  path => 'docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md',
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
  path => 'docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md',
  text => "- ID: `FUTURE-PARITY-BACKLOG.24`\n  Status: `active`",
 },
 {
  path => 'docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md',
  text => "- ID: `FUTURE-PARITY-BACKLOG.24.2`\n  Status: `active`",
 },
 {
  path => 'docs/knowledge/capability-exclusion-freshness-model.md',
  text => 'final public closeout pending',
 },
);
my $language_surface_path = 'docs/linkedspec-book/src/appendix/formal-grammar.md';
my @expected_language_surface_markers = (
 'Attached and inline structured controls are current on all five backends.',
 'Inline value-form `if(...)` and `switch(...)` are portable on all five backends',
);
my @expected_language_surface_forbidden_claims = (
 'Round 2 is extending this surface. Perl and Rust now accept attached-block',
 'Inline value-form `if(...)` and `switch(...)` are portable on Perl and Rust',
);
my @expected_mutation_capabilities = (
 {
  id          => 'language.nested_write_vivification',
  category    => 'language-runtime',
  contract    => 'An authored bare-binding nested assignment evaluates typed path segments then its RHS once, creates only unambiguous missing dense containers on an isolated copy, publishes atomically, returns a detached updated root, and never turns reads into writes.',
  sources     => [
   'docs/decisions/0036-write-vivification-and-receiver-mutation.md',
   'capability_conformance/write_vivification_contract.json',
   'capability_conformance/write_map_leaves_composition_contract.json',
  ],
  references => {
   perl => [
    'perl/LinkedSpec/ActionIR/AST/Parser.pm',
    'perl/LinkedSpec/ActionIR/MethodLowering.pm',
    't/write_vivification_perl_contract.t',
   ],
   rust => [
    'rust/linkedspec-core/src/expr.rs',
    'rust/linkedspec-runtime/src/engine.rs',
    'rust/linkedspec-runtime/tests/write_vivification_contract.rs',
   ],
   dart => [
    'dart/lib/src/action/action_parser.dart',
    'dart/lib/src/runtime/interpreter.dart',
    'dart/test/write_vivification_contract_test.dart',
   ],
   julia => [
    'julia/src/action/ActionParser.jl',
    'julia/src/runtime/Interpreter.jl',
    'julia/test/write_vivification_contract_test.jl',
   ],
   lua => [
    'lua/src/linkedspec/action_parser.lua',
    'lua/src/linkedspec/interpreter.lua',
    'lua/test/write_vivification_contract_test.lua',
   ],
  },
 },
 {
  id          => 'language.map_leaves_receiver_mutation',
  category    => 'language-runtime',
  contract    => "The sole v1 bang method map_leaves! mutates only the resolved receiver binding's leaves through original-shape copied traversal, rejects callback writes to that identity, commits atomically, returns a detached root, and runs ordinary continuation afterward.",
  sources     => [
   'docs/decisions/0036-write-vivification-and-receiver-mutation.md',
   'capability_conformance/map_leaves_mutation_contract.json',
   'capability_conformance/write_map_leaves_composition_contract.json',
  ],
  references => {
   perl => [
    'perl/LinkedSpec/ActionIR/AST/Parser.pm',
    'perl/LinkedSpec/ActionIR/MethodLowering.pm',
    't/map_leaves_mutation_perl_contract.t',
   ],
   rust => [
    'rust/linkedspec-core/src/expr.rs',
    'rust/linkedspec-runtime/src/engine.rs',
    'rust/linkedspec-runtime/tests/map_leaves_mutation_contract.rs',
   ],
   dart => [
    'dart/lib/src/action/action_parser.dart',
    'dart/lib/src/runtime/interpreter.dart',
    'dart/test/map_leaves_mutation_contract_test.dart',
   ],
   julia => [
    'julia/src/action/ActionParser.jl',
    'julia/src/runtime/Interpreter.jl',
    'julia/test/map_leaves_mutation_contract_test.jl',
   ],
   lua => [
    'lua/src/linkedspec/action_parser.lua',
    'lua/src/linkedspec/interpreter.lua',
    'lua/test/map_leaves_mutation_contract_test.lua',
   ],
  },
 },
);
my $expected_lua_mutation_note =
 'The shared Lua implementation and permanent contract execute independently on PUC Lua and LuaJIT.';
my %expected_mutation_authorities = (
 write_vivification => {
  path             => 'capability_conformance/write_vivification_contract.json',
  contract_id      => 'linkedspec-write-vivification-v1',
  canonical_sha256 => 'efabe777bf7fa5d7c3fa6e6fbe181bba89931b8c9b93a3631013c1f6009a2663',
 },
 map_leaves_mutation => {
  path             => 'capability_conformance/map_leaves_mutation_contract.json',
  contract_id      => 'linkedspec-map-leaves-mutation-v1',
  canonical_sha256 => 'a15c6dd363b4cb8cbd5d3d6781b4abc0bf0412b7ee3eb7576a3c674bf19d2db9',
 },
);
my $mutation_composition_path = 'capability_conformance/write_map_leaves_composition_contract.json';
my $mutation_recurring_owner = 'FUTURE-PARITY-BACKLOG.19.8';
my $mutation_recurring_driver = 'tools/check_mutation_six_runtime.sh';
my $mutation_recurring_switch = 'LINKEDSPEC_RUN_MUTATION_MATRIX';
my $mutation_recurring_storage_initializer = 'tools/project_data_env.sh';
my $mutation_public_owner = 'FUTURE-PARITY-BACKLOG.19.9';
my $mutation_public_checker = 'tools/check_mutation_public_surface.py';
my $mutation_public_command =
 'bash tools/run_python_project_data.sh tools/check_mutation_public_surface.py';
my @expected_mutation_recurring_authority_order = qw(
 write_vivification
 map_leaves_mutation
 composition
);
my %expected_mutation_recurring_authorities = (
 write_vivification => {
  path                  => 'capability_conformance/write_vivification_contract.json',
  contract_id           => 'linkedspec-write-vivification-v1',
  status                => 'future-neutral-contract; no backend behavior admitted',
  canonical_json_sha256 => 'efabe777bf7fa5d7c3fa6e6fbe181bba89931b8c9b93a3631013c1f6009a2663',
 },
 map_leaves_mutation => {
  path                  => 'capability_conformance/map_leaves_mutation_contract.json',
  contract_id           => 'linkedspec-map-leaves-mutation-v1',
  status                => 'future-neutral-contract; no backend behavior admitted',
  canonical_json_sha256 => 'a15c6dd363b4cb8cbd5d3d6781b4abc0bf0412b7ee3eb7576a3c674bf19d2db9',
 },
 composition => {
  path                  => 'capability_conformance/write_map_leaves_composition_contract.json',
  contract_id           => 'linkedspec-write-map-leaves-composition-v1',
  status                => 'future-neutral-composition; no backend behavior admitted',
  canonical_json_sha256 => 'a7d20c825cb3d8362d6f278586b6bb65c215e4a84ba64f5bb15bd10b1b82ba2f',
 },
);
my @expected_mutation_recurring_authority_checks = (
 'bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py',
 'bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py',
);
my @expected_mutation_recurring_routes = (
 {
  id       => 'perl',
  commands => [
   'PERL5OPT=-Mwarnings=FATAL PERL5LIB= prove -Iperl t/write_vivification_perl_contract.t t/map_leaves_mutation_perl_contract.t',
  ],
 },
 {
  id       => 'rust',
  commands => [
   '"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test write_vivification_contract --test map_leaves_mutation_contract',
  ],
 },
 {
  id       => 'dart',
  commands => [
   '( cd dart && bash ../tools/run_dart_project_data.sh pub get --offline )',
   '( cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/write_vivification_contract_test.dart )',
   '( cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/map_leaves_mutation_contract_test.dart )',
  ],
 },
 {
  id       => 'julia',
  commands => [
   q{bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --compiled-modules=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include("julia/test/write_vivification_contract_test.jl"); include("julia/test/map_leaves_mutation_contract_test.jl")'},
  ],
 },
 {
  id       => 'puc_lua',
  commands => [
   'bash tools/run_lua_project_data.sh puc lua/test/write_vivification_contract_test.lua',
   'bash tools/run_lua_project_data.sh puc lua/test/map_leaves_mutation_contract_test.lua',
  ],
 },
 {
  id       => 'luajit',
  commands => [
   'bash tools/run_lua_project_data.sh luajit lua/test/write_vivification_contract_test.lua',
   'bash tools/run_lua_project_data.sh luajit lua/test/map_leaves_mutation_contract_test.lua',
  ],
 },
);
my @expected_mutation_recurring_support_checks = (
 'perl tools/check_generated_source_contract.pl',
 'perl tools/check_capability_conformance.pl',
 'perl tools/check_language_capability_coverage.pl',
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

sub require_exact_string_array {
 my ($where, $actual, $expected) = @_;
 fail("$where must be an array") unless ref($actual) eq 'ARRAY';
 fail("$where drifted") unless join("\0", @$actual) eq join("\0", @$expected);
}

sub canonical_json_sha256 {
 my ($value) = @_;
 return sha256_hex(JSON::PP->new->canonical(1)->utf8(1)->encode($value));
}

sub expected_mutation_recurring_gate {
 return {
  owner               => $mutation_recurring_owner,
  driver              => $mutation_recurring_driver,
  local_ci_switch     => $mutation_recurring_switch,
  storage_initializer => $mutation_recurring_storage_initializer,
  authority_order     => clone_value(\@expected_mutation_recurring_authority_order),
  authorities         => clone_value(\%expected_mutation_recurring_authorities),
  authority_checks    => clone_value(\@expected_mutation_recurring_authority_checks),
  runtime_routes      => clone_value(\@expected_mutation_recurring_routes),
  support_checks      => clone_value(\@expected_mutation_recurring_support_checks),
 };
}

sub substring_count {
 my ($source, $needle) = @_;
 fail('cannot count an empty recurring marker') unless length $needle;
 my $count = 0;
 my $offset = 0;
 while (1) {
  my $position = index($source, $needle, $offset);
  last if $position < 0;
  $count++;
  $offset = $position + length($needle);
 }
 return $count;
}

sub require_exact_markers_in_order {
 my ($where, $source, $markers) = @_;
 my $prior = -1;
 for my $marker (@$markers) {
  my $count = substring_count($source, $marker);
  fail("$where marker must appear exactly once: $marker") unless $count == 1;
  my $position = index($source, $marker);
  fail("$where marker order drifted at: $marker") unless $position > $prior;
  $prior = $position;
 }
}

sub validate_mutation_recurring_gate {
 my ($gate, $task_status, $artifacts, $driver_source, $ci_source, $check_files) = @_;
 require_hash_keys(
  'mutation recurring gate',
  $gate,
  qw(
   owner
   driver
   local_ci_switch
   storage_initializer
   authority_order
   authorities
   authority_checks
   runtime_routes
   support_checks
  ),
 );
 fail('mutation recurring owner drifted') unless $gate->{owner} eq $mutation_recurring_owner;
 fail("mutation recurring owner '$gate->{owner}' is not tracked") unless exists $task_status->{$gate->{owner}};
 fail("mutation recurring owner '$gate->{owner}' must be active or done")
  unless $task_status->{$gate->{owner}} eq 'active' || $task_status->{$gate->{owner}} eq 'done';
 fail('mutation recurring driver drifted') unless $gate->{driver} eq $mutation_recurring_driver;
 fail('mutation recurring local-CI switch drifted') unless $gate->{local_ci_switch} eq $mutation_recurring_switch;
 fail('mutation recurring storage initializer drifted')
  unless $gate->{storage_initializer} eq $mutation_recurring_storage_initializer;
 require_exact_string_array(
  'mutation recurring authority order',
  $gate->{authority_order},
  \@expected_mutation_recurring_authority_order,
 );
 require_exact_string_array(
  'mutation recurring authority checks',
  $gate->{authority_checks},
  \@expected_mutation_recurring_authority_checks,
 );
 require_exact_string_array(
  'mutation recurring support checks',
  $gate->{support_checks},
  \@expected_mutation_recurring_support_checks,
 );

 require_hash_keys(
  'mutation recurring authorities',
  $gate->{authorities},
  @expected_mutation_recurring_authority_order,
 );
 for my $name (@expected_mutation_recurring_authority_order) {
  my $actual = $gate->{authorities}{$name};
  my $expected = $expected_mutation_recurring_authorities{$name};
  require_hash_keys(
   "mutation recurring authorities.$name",
   $actual,
   qw(path contract_id status canonical_json_sha256),
  );
  for my $field (qw(path contract_id status canonical_json_sha256)) {
   fail("mutation recurring $name $field drifted") unless $actual->{$field} eq $expected->{$field};
  }
  my $artifact = $artifacts->{$name};
  fail("mutation recurring $name artifact must be an object") unless ref($artifact) eq 'HASH';
  fail("mutation recurring $name artifact id is stale")
   unless $artifact->{contract_id} eq $actual->{contract_id};
  fail("mutation recurring $name artifact status is stale")
   unless $artifact->{status} eq $actual->{status};
  fail("mutation recurring $name artifact digest is stale")
   unless canonical_json_sha256($artifact) eq $actual->{canonical_json_sha256};
 }

 fail('mutation recurring runtime routes must be an array') unless ref($gate->{runtime_routes}) eq 'ARRAY';
 fail('mutation recurring runtime route count drifted')
  unless @{$gate->{runtime_routes}} == @expected_mutation_recurring_routes;
 for my $index (0 .. $#expected_mutation_recurring_routes) {
  my $actual = $gate->{runtime_routes}[$index];
  my $expected = $expected_mutation_recurring_routes[$index];
  require_hash_keys("mutation recurring runtime_routes[$index]", $actual, qw(id commands));
  fail("mutation recurring runtime route $index id drifted") unless $actual->{id} eq $expected->{id};
  require_exact_string_array(
   "mutation recurring runtime route $actual->{id} commands",
   $actual->{commands},
   $expected->{commands},
  );
 }

 if ($check_files) {
  require_repo_path('mutation recurring driver', $gate->{driver});
  require_repo_path('mutation recurring storage initializer', $gate->{storage_initializer});
  fail('mutation recurring driver must be executable')
   unless -x File::Spec->catfile($repo_root, split m{/}, $gate->{driver});
 }

 my @driver_commands = (
  @{$gate->{authority_checks}},
  map({ @{$_->{commands}} } @{$gate->{runtime_routes}}),
  @{$gate->{support_checks}},
 );
 require_exact_markers_in_order('mutation recurring driver', $driver_source, \@driver_commands);
 require_exact_markers_in_order(
  'mutation recurring storage route',
  $driver_source,
  [
   'source "$REPO_ROOT/tools/project_data_env.sh"',
   'linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_mutation_six_runtime.sh" "$@"',
  ],
 );

 my $ci_if = 'if [[ "${LINKEDSPEC_RUN_MUTATION_MATRIX:-0}" == "1" ]]; then';
 my $ci_run = 'bash "$REPO_ROOT/tools/check_mutation_six_runtime.sh"';
 my $ci_syntax = 'bash -n tools/check_mutation_six_runtime.sh';
 my $ci_audit = 'mutation_driver_matches=$(grep -nE';
 fail('mutation recurring canonical-CI condition must appear exactly once')
  unless substring_count($ci_source, $ci_if) == 1;
 fail('mutation recurring driver must execute exactly once in canonical CI')
  unless substring_count($ci_source, $ci_run) == 1;
 fail('mutation recurring driver syntax registration must appear exactly once')
  unless substring_count($ci_source, $ci_syntax) == 1;
 fail('mutation recurring driver path audit must appear exactly once')
  unless substring_count($ci_source, $ci_audit) == 1;
 fail('mutation recurring driver must have one inventory and one execution-time tracked-file check')
  unless substring_count($ci_source, "require_tracked_file $mutation_recurring_driver") == 2;
}

sub validate_mutation_public_gate {
 my ($task_status, $ci_source, $check_file) = @_;
 fail("mutation public owner '$mutation_public_owner' is not tracked")
  unless exists $task_status->{$mutation_public_owner};
 fail("mutation public owner '$mutation_public_owner' must be active or done")
  unless $task_status->{$mutation_public_owner} eq 'active'
   || $task_status->{$mutation_public_owner} eq 'done';
 require_repo_path('mutation public checker', $mutation_public_checker) if $check_file;
 fail('mutation public checker must be executable')
  if $check_file && !-x File::Spec->catfile($repo_root, split m{/}, $mutation_public_checker);
 fail('mutation public checker must have exactly one tracked-file registration')
  unless substring_count($ci_source, "require_tracked_file $mutation_public_checker") == 1;
 fail('mutation public checker must execute exactly once in canonical CI')
  unless substring_count($ci_source, $mutation_public_command) == 1;
}

sub validate_mutation_capabilities {
 my ($manifest, $task_status, $artifacts) = @_;
 my $owner = 'FUTURE-PARITY-BACKLOG.19.7';
 fail("mutation capability owner '$owner' is not tracked") unless exists $task_status->{$owner};
 fail("mutation capability owner '$owner' must be active or done")
  unless $task_status->{$owner} eq 'active' || $task_status->{$owner} eq 'done';

 my @ids = map { $_->{id} } @{$manifest->{capabilities}};
 my %index;
 for my $position (0 .. $#ids) {
  $index{$ids[$position]} = $position;
 }
 for my $expected (@expected_mutation_capabilities) {
  fail("mutation capability '$expected->{id}' is missing") unless exists $index{$expected->{id}};
 }
 my $standalone_index = $index{'language.standalone_lifecycle_block'};
 fail('standalone lifecycle capability row is missing') unless defined $standalone_index;
 fail('mutation capability rows must immediately follow standalone lifecycle in exact order')
  unless $index{$expected_mutation_capabilities[0]{id}} == $standalone_index + 1
  && $index{$expected_mutation_capabilities[1]{id}} == $standalone_index + 2;

 for my $expected (@expected_mutation_capabilities) {
  my $row = $manifest->{capabilities}[$index{$expected->{id}}];
  fail("$expected->{id}.category drifted") unless $row->{category} eq $expected->{category};
  fail("$expected->{id}.contract drifted") unless $row->{contract} eq $expected->{contract};
  require_exact_string_array("$expected->{id}.sources", $row->{sources}, $expected->{sources});
  for my $backend (@expected_backends) {
   my $entry = $row->{backends}{$backend};
   fail("$expected->{id} is not admitted on $backend") unless $entry->{status} eq 'pass';
   require_exact_string_array(
    "$expected->{id}.backends.$backend.references",
    $entry->{references},
    $expected->{references}{$backend},
   );
   if ($backend eq 'lua') {
    fail("$expected->{id}.backends.lua.note drifted")
     unless exists $entry->{note} && $entry->{note} eq $expected_lua_mutation_note;
   } else {
    fail("$expected->{id}.backends.$backend must not carry an admission note") if exists $entry->{note};
   }
  }
 }

 for my $name (sort keys %expected_mutation_authorities) {
  my $expected = $expected_mutation_authorities{$name};
  my $artifact = $artifacts->{$name};
  fail("$name authority must be an object") unless ref($artifact) eq 'HASH';
  fail("$name authority format drifted") unless $artifact->{format} == 1;
  fail("$name authority id drifted") unless $artifact->{contract_id} eq $expected->{contract_id};
  fail("$name authority freeze status drifted")
   unless $artifact->{status} eq 'future-neutral-contract; no backend behavior admitted';
  fail("$name authority canonical JSON drifted")
   unless canonical_json_sha256($artifact) eq $expected->{canonical_sha256};
 }

 my $composition = $artifacts->{composition};
 fail('mutation composition authority must be an object') unless ref($composition) eq 'HASH';
 fail('mutation composition authority format drifted') unless $composition->{format} == 1;
 fail('mutation composition authority id drifted')
  unless $composition->{contract_id} eq 'linkedspec-write-map-leaves-composition-v1';
 fail('mutation composition authority freeze status drifted')
  unless $composition->{status} eq 'future-neutral-composition; no backend behavior admitted';
 require_hash_keys(
  'mutation composition requires',
  $composition->{requires},
  qw(write_vivification map_leaves_mutation),
 );
 for my $name (qw(write_vivification map_leaves_mutation)) {
  my $required = $composition->{requires}{$name};
  my $expected = $expected_mutation_authorities{$name};
  require_hash_keys("mutation composition requires.$name", $required, qw(contract_id path canonical_json_sha256));
  fail("mutation composition $name contract id drifted") unless $required->{contract_id} eq $expected->{contract_id};
  fail("mutation composition $name path drifted") unless $required->{path} eq $expected->{path};
  fail("mutation composition $name digest drifted")
   unless $required->{canonical_json_sha256} eq $expected->{canonical_sha256};
 }
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

sub expected_language_surface_contract {
 return {
  capability_id            => 'language.current_mdbook_surface',
  path                     => $language_surface_path,
  required_markers         => clone_value(\@expected_language_surface_markers),
  forbidden_current_claims => clone_value(\@expected_language_surface_forbidden_claims),
 };
}

sub validate_language_surface_contract {
 my ($contract, $manifest, $source) = @_;
 require_hash_keys(
  'language_surface_contract', $contract,
  qw(capability_id path required_markers forbidden_current_claims)
 );
 fail('language-surface capability id drifted')
  unless $contract->{capability_id} eq 'language.current_mdbook_surface';
 fail('language-surface path drifted') unless $contract->{path} eq $language_surface_path;
 fail('language-surface markers drifted')
  unless ref($contract->{required_markers}) eq 'ARRAY'
  && join("\0", @{$contract->{required_markers}}) eq join("\0", @expected_language_surface_markers);
 fail('language-surface stale-claim denials drifted')
  unless ref($contract->{forbidden_current_claims}) eq 'ARRAY'
  && join("\0", @{$contract->{forbidden_current_claims}}) eq join("\0", @expected_language_surface_forbidden_claims);

 my @capabilities = grep { $_->{id} eq $contract->{capability_id} } @{$manifest->{capabilities}};
 fail('language-surface capability row must exist exactly once') unless @capabilities == 1;
 my $capability = $capabilities[0];
 fail('language-surface formal grammar source is not capability-owned')
  unless grep { $_ eq $contract->{path} } @{$capability->{sources}};
 for my $backend (@expected_backends) {
  fail("language-surface backend is not admitted: $backend")
   unless $capability->{backends}{$backend}{status} eq 'pass';
 }

 my $normalized_source = normalize_space($source);
 for my $marker (@{$contract->{required_markers}}) {
  fail("language surface is missing current marker: $marker")
   unless index($normalized_source, normalize_space($marker)) >= 0;
 }
 for my $forbidden (@{$contract->{forbidden_current_claims}}) {
  fail("language surface retains stale claim: $forbidden")
   if index($normalized_source, normalize_space($forbidden)) >= 0;
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

 fail('manifest.excluded_or_future must contain exactly the one governed record')
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
 $add_manifest_mutation->('open_legacy_retention_authority', sub {
  $_[0]{excluded_or_future}[0]{retention_authority} = 'docs/knowledge/pplugin-pluginbridge-transition-machinery.md';
 });
 $add_manifest_mutation->('completed_legacy_without_retention', sub {
  $_[0]{excluded_or_future}[0]{owner} = 'FUTURE-PARITY-BACKLOG.1.6';
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
 $add_manifest_mutation->('legacy_reason_drift', sub { $_[0]{excluded_or_future}[0]{reason} .= ' drift' });
 $add_manifest_mutation->('legacy_owner_drift', sub { $_[0]{excluded_or_future}[0]{owner} = 'FUTURE-PARITY-BACKLOG.14' });
 for my $id (qw(future.semantic_introspection_mcp future.rule_local_cursor_and_bare_edges future.general_parse_job_authoring)) {
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

sub mutation_capability_admission_checks {
 my ($manifest, $task_sources, $artifacts) = @_;
 my $task_status = parse_task_statuses($task_sources);
 my @mutations;
 my $add_manifest_mutation = sub {
  my ($name, $mutate) = @_;
  push @mutations, [$name, sub {
   my $candidate = clone_value($manifest);
   $mutate->($candidate);
   validate_manifest($candidate, $task_status);
   validate_mutation_capabilities($candidate, $task_status, $artifacts);
  }];
 };
 my $find_index = sub {
  my ($candidate, $id) = @_;
  for my $index (0 .. $#{$candidate->{capabilities}}) {
   return $index if $candidate->{capabilities}[$index]{id} eq $id;
  }
  die "mutation setup could not find capability '$id'\n";
 };

 $add_manifest_mutation->('mutation_capability_omission', sub {
  my ($candidate) = @_;
  my $index = $find_index->($candidate, $expected_mutation_capabilities[0]{id});
  splice @{$candidate->{capabilities}}, $index, 1;
 });
 $add_manifest_mutation->('mutation_capability_duplication', sub {
  my ($candidate) = @_;
  my $index = $find_index->($candidate, $expected_mutation_capabilities[1]{id});
  push @{$candidate->{capabilities}}, clone_value($candidate->{capabilities}[$index]);
 });
 $add_manifest_mutation->('mutation_capability_order', sub {
  my ($candidate) = @_;
  my $first = $find_index->($candidate, $expected_mutation_capabilities[0]{id});
  my $second = $find_index->($candidate, $expected_mutation_capabilities[1]{id});
  @{$candidate->{capabilities}}[$first, $second] = @{$candidate->{capabilities}}[$second, $first];
 });
 $add_manifest_mutation->('mutation_capability_contract_text', sub {
  my ($candidate) = @_;
  my $index = $find_index->($candidate, $expected_mutation_capabilities[0]{id});
  $candidate->{capabilities}[$index]{contract} .= ' drift';
 });
 $add_manifest_mutation->('mutation_capability_source_order', sub {
  my ($candidate) = @_;
  my $index = $find_index->($candidate, $expected_mutation_capabilities[1]{id});
  @{$candidate->{capabilities}[$index]{sources}}[0, 1] = @{$candidate->{capabilities}[$index]{sources}}[1, 0];
 });
 $add_manifest_mutation->('mutation_capability_backend_status', sub {
  my ($candidate) = @_;
  my $index = $find_index->($candidate, $expected_mutation_capabilities[0]{id});
  $candidate->{capabilities}[$index]{backends}{rust}{status} = 'partial';
  $candidate->{capabilities}[$index]{gap_owner} = 'FUTURE-PARITY-BACKLOG.19.8';
 });
 $add_manifest_mutation->('mutation_capability_backend_reference', sub {
  my ($candidate) = @_;
  my $index = $find_index->($candidate, $expected_mutation_capabilities[1]{id});
  $candidate->{capabilities}[$index]{backends}{dart}{references}[0] = 'dart/lib/src/action/action_ast.dart';
 });
 $add_manifest_mutation->('mutation_capability_lua_dual_abi_note', sub {
  my ($candidate) = @_;
  my $index = $find_index->($candidate, $expected_mutation_capabilities[0]{id});
  delete $candidate->{capabilities}[$index]{backends}{lua}{note};
 });

 push @mutations, ['mutation_capability_owner_status', sub {
  my $candidate_sources = mutate_task_status_line(
   $task_sources,
   'FUTURE-PARITY-BACKLOG.19.7',
   "  Status: `pending`\n",
  );
  my $candidate_status = parse_task_statuses($candidate_sources);
  validate_manifest($manifest, $candidate_status);
  validate_mutation_capabilities($manifest, $candidate_status, $artifacts);
 }];

 my $add_artifact_mutation = sub {
  my ($name, $mutate) = @_;
  push @mutations, [$name, sub {
   my $candidate = clone_value($artifacts);
   $mutate->($candidate);
   validate_mutation_capabilities($manifest, $task_status, $candidate);
  }];
 };
 $add_artifact_mutation->('write_authority_id', sub {
  $_[0]{write_vivification}{contract_id} = 'linkedspec-write-vivification-v2';
 });
 $add_artifact_mutation->('map_authority_format', sub {
  $_[0]{map_leaves_mutation}{format} = 2;
 });
 $add_artifact_mutation->('write_authority_content_digest', sub {
  $_[0]{write_vivification}{policy}{atomic_commit} .= ' drift';
 });
 $add_artifact_mutation->('map_authority_content_digest', sub {
  $_[0]{map_leaves_mutation}{policy}{atomic_commit} .= ' drift';
 });
 $add_artifact_mutation->('composition_authority_id', sub {
  $_[0]{composition}{contract_id} = 'linkedspec-write-map-leaves-composition-v2';
 });
 $add_artifact_mutation->('composition_write_digest', sub {
  $_[0]{composition}{requires}{write_vivification}{canonical_json_sha256} = '0' x 64;
 });
 $add_artifact_mutation->('composition_map_digest', sub {
  $_[0]{composition}{requires}{map_leaves_mutation}{canonical_json_sha256} = '0' x 64;
 });

 expect_mutation_failure(@$_) for @mutations;
 return scalar @mutations;
}

sub mutation_recurring_gate_checks {
 my ($gate, $task_sources, $artifacts, $driver_source, $ci_source) = @_;
 my $task_status = parse_task_statuses($task_sources);
 my @mutations;
 my $add_gate_mutation = sub {
  my ($name, $mutate) = @_;
  push @mutations, [$name, sub {
   my $candidate = clone_value($gate);
   $mutate->($candidate);
   validate_mutation_recurring_gate(
    $candidate, $task_status, $artifacts, $driver_source, $ci_source, 0,
   );
  }];
 };

 $add_gate_mutation->('mutation_recurring_authority_omission', sub {
  pop @{$_[0]{authority_order}};
 });
 $add_gate_mutation->('mutation_recurring_authority_order', sub {
  @{$_[0]{authority_order}}[0, 1] = @{$_[0]{authority_order}}[1, 0];
 });
 $add_gate_mutation->('mutation_recurring_write_digest', sub {
  $_[0]{authorities}{write_vivification}{canonical_json_sha256} = '0' x 64;
 });
 $add_gate_mutation->('mutation_recurring_map_status', sub {
  $_[0]{authorities}{map_leaves_mutation}{status} = 'portable-current';
 });
 $add_gate_mutation->('mutation_recurring_composition_digest', sub {
  $_[0]{authorities}{composition}{canonical_json_sha256} = '0' x 64;
 });
 $add_gate_mutation->('mutation_recurring_route_omission', sub {
  pop @{$_[0]{runtime_routes}};
 });
 $add_gate_mutation->('mutation_recurring_route_substitution', sub {
  $_[0]{runtime_routes}[1]{commands}[0] =
   '"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test write_vivification_contract';
 });
 $add_gate_mutation->('mutation_recurring_route_order', sub {
  @{$_[0]{runtime_routes}}[0, 1] = @{$_[0]{runtime_routes}}[1, 0];
 });
 $add_gate_mutation->('mutation_recurring_support_omission', sub {
  pop @{$_[0]{support_checks}};
 });
 $add_gate_mutation->('mutation_recurring_support_order', sub {
  @{$_[0]{support_checks}}[0, 1] = @{$_[0]{support_checks}}[1, 0];
 });
 $add_gate_mutation->('mutation_recurring_storage_initializer', sub {
  $_[0]{storage_initializer} = 'tools/missing_project_data_env.sh';
 });

 push @mutations, ['mutation_recurring_owner_status', sub {
  my $candidate_sources = mutate_task_status_line(
   $task_sources,
   $mutation_recurring_owner,
   "  Status: `pending`\n",
  );
  validate_mutation_recurring_gate(
   $gate,
   parse_task_statuses($candidate_sources),
   $artifacts,
   $driver_source,
   $ci_source,
   0,
  );
 }];

 push @mutations, ['mutation_recurring_driver_command_omission', sub {
  my $candidate_source = $driver_source;
  my $marker = $expected_mutation_recurring_routes[0]{commands}[0];
  my $position = index($candidate_source, $marker);
  die "mutation setup could not find recurring driver command exactly once\n"
   unless $position >= 0 && substring_count($candidate_source, $marker) == 1;
  substr($candidate_source, $position, length($marker), '');
  validate_mutation_recurring_gate(
   $gate, $task_status, $artifacts, $candidate_source, $ci_source, 0,
  );
 }];
 push @mutations, ['mutation_recurring_ci_registration_omission', sub {
  my $candidate_source = $ci_source;
  my $marker = 'bash "$REPO_ROOT/tools/check_mutation_six_runtime.sh"';
  my $position = index($candidate_source, $marker);
  die "mutation setup could not find recurring CI registration exactly once\n"
   unless $position >= 0 && substring_count($candidate_source, $marker) == 1;
  substr($candidate_source, $position, length($marker), '');
  validate_mutation_recurring_gate(
   $gate, $task_status, $artifacts, $driver_source, $candidate_source, 0,
  );
 }];
 push @mutations, ['mutation_recurring_ci_registration_duplication', sub {
  my $candidate_source = $ci_source . "\nbash \"\$REPO_ROOT/tools/check_mutation_six_runtime.sh\"\n";
  validate_mutation_recurring_gate(
   $gate, $task_status, $artifacts, $driver_source, $candidate_source, 0,
  );
 }];
 push @mutations, ['mutation_recurring_artifact_status', sub {
  my $candidate = clone_value($artifacts);
  $candidate->{map_leaves_mutation}{status} = 'portable-current';
  validate_mutation_recurring_gate(
   $gate, $task_status, $candidate, $driver_source, $ci_source, 0,
  );
 }];
 push @mutations, ['mutation_recurring_artifact_digest', sub {
  my $candidate = clone_value($artifacts);
  $candidate->{composition}{format} = 2;
  validate_mutation_recurring_gate(
   $gate, $task_status, $candidate, $driver_source, $ci_source, 0,
  );
 }];

 expect_mutation_failure(@$_) for @mutations;
 return scalar @mutations;
}

sub mutation_public_gate_checks {
 my ($task_sources, $ci_source) = @_;
 my $task_status = parse_task_statuses($task_sources);
 my @mutations;

 push @mutations, ['mutation_public_owner_status', sub {
  my $candidate_sources = mutate_task_status_line(
   $task_sources,
   $mutation_public_owner,
   "  Status: `pending`\n",
  );
  validate_mutation_public_gate(parse_task_statuses($candidate_sources), $ci_source, 0);
 }];
 push @mutations, ['mutation_public_tracking_omission', sub {
  my $candidate_source = $ci_source;
  my $marker = "require_tracked_file $mutation_public_checker";
  my $position = index($candidate_source, $marker);
  die "mutation setup could not find public checker registration exactly once\n"
   unless $position >= 0 && substring_count($candidate_source, $marker) == 1;
  substr($candidate_source, $position, length($marker), '');
  validate_mutation_public_gate($task_status, $candidate_source, 0);
 }];
 push @mutations, ['mutation_public_ci_omission', sub {
  my $candidate_source = $ci_source;
  my $position = index($candidate_source, $mutation_public_command);
  die "mutation setup could not find public checker command exactly once\n"
   unless $position >= 0 && substring_count($candidate_source, $mutation_public_command) == 1;
  substr($candidate_source, $position, length($mutation_public_command), '');
  validate_mutation_public_gate($task_status, $candidate_source, 0);
 }];
 push @mutations, ['mutation_public_ci_duplication', sub {
  my $candidate_source = $ci_source . "\n$mutation_public_command\n";
  validate_mutation_public_gate($task_status, $candidate_source, 0);
 }];

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
  my $marker = 'schema v2 with exactly one status-fresh record:';
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

sub language_surface_mutation_checks {
 my ($contract, $manifest, $source) = @_;
 my @mutations;
 push @mutations, ['language_surface_capability_drift', sub {
  my $candidate = clone_value($contract);
  $candidate->{capability_id} = 'language.missing';
  validate_language_surface_contract($candidate, $manifest, $source);
 }];
 push @mutations, ['language_surface_marker_omission', sub {
  my $candidate = clone_value($contract);
  pop @{$candidate->{required_markers}};
  validate_language_surface_contract($candidate, $manifest, $source);
 }];
 push @mutations, ['language_surface_source_omission', sub {
  my $candidate_source = $source;
  my $marker = $expected_language_surface_markers[0];
  my $changed = ($candidate_source =~ s/\Q$marker\E//);
  die "mutation setup could not find the language-surface marker\n" unless $changed == 1;
  validate_language_surface_contract($contract, $manifest, $candidate_source);
 }];
 push @mutations, ['language_surface_stale_claim_injection', sub {
  my $candidate_source = $source . "\n$expected_language_surface_forbidden_claims[0]\n";
  validate_language_surface_contract($contract, $manifest, $candidate_source);
 }];
 expect_mutation_failure(@$_) for @mutations;
 return scalar @mutations;
}

my $manifest = eval { decode_json(read_text($manifest_path)) };
fail("invalid JSON in capability_conformance/manifest.json: $@") if $@;
my $sources = task_sources();
my $task_status = parse_task_statuses($sources);
my $counts = validate_manifest($manifest, $task_status);
my $mutation_count = governance_mutation_checks($manifest, $sources);
my %mutation_artifact_paths = (
 map { $_ => $expected_mutation_authorities{$_}{path} } keys %expected_mutation_authorities
);
$mutation_artifact_paths{composition} = $mutation_composition_path;
my $mutation_artifacts = {
 map {
  my $name = $_;
  my $path = File::Spec->catfile($repo_root, split m{/}, $mutation_artifact_paths{$name});
  my $value = eval { decode_json(read_text($path)) };
  fail("invalid JSON in $mutation_artifact_paths{$name}: $@") if $@;
  $name => $value;
 } sort keys %mutation_artifact_paths
};
validate_mutation_capabilities($manifest, $task_status, $mutation_artifacts);
my $mutation_admission_count = mutation_capability_admission_checks($manifest, $sources, $mutation_artifacts);
my $mutation_recurring_gate = expected_mutation_recurring_gate();
my $mutation_recurring_driver_source = read_text(
 File::Spec->catfile($repo_root, split m{/}, $mutation_recurring_driver)
);
my $canonical_ci_source = read_text(File::Spec->catfile($repo_root, 'tools', 'run_ci_local.sh'));
validate_mutation_recurring_gate(
 $mutation_recurring_gate,
 $task_status,
 $mutation_artifacts,
 $mutation_recurring_driver_source,
 $canonical_ci_source,
 1,
);
my $mutation_recurring_count = mutation_recurring_gate_checks(
 $mutation_recurring_gate,
 $sources,
 $mutation_artifacts,
 $mutation_recurring_driver_source,
 $canonical_ci_source,
);
validate_mutation_public_gate($task_status, $canonical_ci_source, 1);
my $mutation_public_count = mutation_public_gate_checks($sources, $canonical_ci_source);
my $public_contract = expected_public_contract();
my $public_sources = public_projection_sources();
validate_public_contract($public_contract, $public_sources);
my $public_mutation_count = public_projection_mutation_checks($public_contract, $public_sources);
my $language_surface_contract = expected_language_surface_contract();
my $language_surface_source = read_text(File::Spec->catfile($repo_root, split m{/}, $language_surface_path));
validate_language_surface_contract($language_surface_contract, $manifest, $language_surface_source);
my $language_surface_mutation_count = language_surface_mutation_checks(
 $language_surface_contract, $manifest, $language_surface_source
);

printf "capability-conformance: OK (schema v2; %d capabilities; backend states pass=%d partial=%d gap=%d; %d exclusions; %d governance mutations; %d mutation capabilities; %d mutation-admission mutations; %d mutation-recurring mutations; %d mutation-public-gate mutations; %d governed projections; %d public mutations; %d language-surface mutations)\n",
 scalar(@{$manifest->{capabilities}}), @{$counts}{qw(pass partial gap)}, scalar(@{$manifest->{excluded_or_future}}),
 $mutation_count, scalar(@expected_mutation_capabilities), $mutation_admission_count, $mutation_recurring_count,
 $mutation_public_count, scalar(@expected_public_projections), $public_mutation_count,
 $language_surface_mutation_count;
