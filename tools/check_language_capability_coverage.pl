#!/usr/bin/env perl
use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(dirname);
use File::Find qw(find);
use File::Spec;
use FindBin qw($Bin);
use JSON::PP qw(decode_json);
use lib "$Bin/../perl";
use LinkedSpec::RuleIR::EmitContext ();

my $repo_root = abs_path(File::Spec->catdir(dirname(__FILE__), '..'));
my $report_only = 0;
for my $arg (@ARGV) {
 if ($arg eq '--report') {
  $report_only = 1;
  next;
 }
 fail("unknown argument '$arg'");
}

sub fail {
 my ($message) = @_;
 die "language-capability-coverage: ERROR: $message\n";
}

sub read_text {
 my ($relative) = @_;
 my $path = File::Spec->catfile($repo_root, split m{/}, $relative);
 open my $fh, '<:raw', $path or fail("cannot read $relative: $!");
 local $/;
 my $text = <$fh>;
 close $fh or fail("cannot close $relative: $!");
 return $text;
}

sub dart_names {
 my $text = read_text('dart/lib/src/action/action_contracts.dart');
 my @names;
 for my $constant (qw(supportedActionIrCallNames numericAliasActionIrCallNames currentAliasActionIrCallNames)) {
  $text =~ /const \Q$constant\E = <String>\{(.*?)\n\};/s
   or fail("cannot locate Dart $constant");
  push @names, $1 =~ /'([^']+)'/g;
 }
 return sort @names;
}

sub dart_source_boundary_compatibility_aliases {
 my $text = read_text('dart/lib/src/action/action_contracts.dart');
 $text =~ /const _sourceBoundaryCompatibilityAliasActionIrCallNames = <String>\{(.*?)\n\};/s
  or fail('cannot locate Dart source-boundary compatibility alias inventory');
 my @names = $1 =~ /'([^']+)'/g;
 $text =~ /const _currentAliasCanonicalNames = <String, String>\{(.*?)\n\};/s
  or fail('cannot locate Dart current alias canonical-name map');
 my %canonical_names = $1 =~ /'([^']+)'\s*:\s*'([^']+)'/g;
 my @aliases;
 for my $name (sort @names) {
  fail("Dart source-boundary compatibility alias '$name' has no canonical target")
   unless exists $canonical_names{$name};
  push @aliases, [$name, $canonical_names{$name}];
 }
 return @aliases;
}

sub julia_names {
 my $text = read_text('julia/src/action/ActionContracts.jl');
 my @names;
 for my $constant (qw(_SUPPORTED_ACTION_IR_CALL_NAMES _NUMERIC_ALIAS_ACTION_IR_CALL_NAMES _CURRENT_ALIAS_ACTION_IR_CALL_NAMES)) {
  $text =~ /const \Q$constant\E = Set\{String\}\(\[(.*?)\n\]\)/s
   or fail("cannot locate Julia $constant");
  push @names, $1 =~ /"([^"]+)"/g;
 }
 return sort @names;
}

sub julia_source_boundary_compatibility_aliases {
 my $text = read_text('julia/src/action/ActionContracts.jl');
 $text =~ /const _SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES = Dict\{String,String\}\((.*?)\n\)/s
  or fail('cannot locate Julia source-boundary compatibility alias canonical-name map');
 my %canonical_names = $1 =~ /"([^"]+)"\s*=>\s*"([^"]+)"/g;
 $text =~ /function canonical_action_helper_name\(name::AbstractString\).*?get\(\s*_SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES,/s
  or fail('Julia canonical helper resolver does not consume the source-boundary compatibility alias map');
 $text =~ /const _KNOWN_ACTION_IR_CALL_NAMES = union\(.*?Set\(keys\(_SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES\)\),.*?\n\)/s
  or fail('Julia known-name inventory does not consume the source-boundary compatibility alias map');
 return map { [$_, $canonical_names{$_}] } sort keys %canonical_names;
}

sub lua_names {
 my $text = read_text('lua/src/linkedspec/action_call_names.lua');
 $text =~ /local CURRENT_CALL_NAMES = \{(.*?)\n\}/s
  or fail('cannot locate Lua CURRENT_CALL_NAMES');
 return sort $1 =~ /\["([^"]+)"\]\s*=\s*true/g;
}

sub lua_source_boundary_compatibility_aliases {
 my $names_text = read_text('lua/src/linkedspec/action_call_names.lua');
 $names_text =~ /local SOURCE_BOUNDARY_COMPATIBILITY_CALL_NAMES = \{(.*?)\n\}/s
  or fail('cannot locate Lua source-boundary compatibility alias inventory');
 my @names = $1 =~ /\["([^"]+)"\]\s*=\s*true/g;
 $names_text =~ /function M[.]is_known\(name\).*?SOURCE_BOUNDARY_COMPATIBILITY_CALL_NAMES\[name\]/s
  or fail('Lua known-name resolver does not consume the source-boundary compatibility alias inventory');

 my $contracts_text = read_text('lua/src/linkedspec/action_contracts.lua');
 $contracts_text =~ /local SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES = \{(.*?)\n\}/s
  or fail('cannot locate Lua source-boundary compatibility alias canonical-name map');
 my %canonical_names = $1 =~ /\["([^"]+)"\]\s*=\s*"([^"]+)"/g;
 $contracts_text =~ /function M[.]canonical_action_helper_name\(name\).*?return\s+SOURCE_BOUNDARY_COMPATIBILITY_ALIAS_CANONICAL_NAMES\[name\]/s
  or fail('Lua canonical helper resolver does not consume the source-boundary compatibility alias map');
 my @aliases;
 for my $name (sort @names) {
  fail("Lua source-boundary compatibility alias '$name' has no canonical target")
   unless exists $canonical_names{$name};
  push @aliases, [$name, $canonical_names{$name}];
 }
 fail('Lua source-boundary compatibility alias map contains a non-inventory name')
  unless @aliases == keys %canonical_names;
 return @aliases;
}

my @dart = dart_names();
my @julia = julia_names();
my @lua = lua_names();
fail('Dart and Julia current ActionIR call-name inventories differ')
 unless join("\0", @dart) eq join("\0", @julia);
fail('Dart and Lua current ActionIR call-name inventories differ')
 unless join("\0", @dart) eq join("\0", @lua);

my $typed_source_contract = decode_json(
 read_text('capability_conformance/typed_source_location_contract.json')
);
fail('typed-source compatibility aliases must be an array')
 unless ref($typed_source_contract->{compatibility_aliases}) eq 'ARRAY';
my @neutral_source_boundary_aliases = map {
 fail('typed-source compatibility alias must be a name/target pair')
  unless ref($_) eq 'ARRAY' && @{$_} == 2 && !grep { !defined($_) || ref($_) } @{$_};
 [@{$_}];
} @{$typed_source_contract->{compatibility_aliases}};
my @dart_source_boundary_aliases = dart_source_boundary_compatibility_aliases();
my @julia_source_boundary_aliases = julia_source_boundary_compatibility_aliases();
my @lua_source_boundary_aliases = lua_source_boundary_compatibility_aliases();
my $serialize_aliases = sub {
 return join("\n", map { join("\0", @{$_}) } sort { $a->[0] cmp $b->[0] } @_);
};
fail('Dart source-boundary compatibility aliases differ from the neutral typed-source contract')
 unless $serialize_aliases->(@dart_source_boundary_aliases)
  eq $serialize_aliases->(@neutral_source_boundary_aliases);
fail('Julia source-boundary compatibility aliases differ from the neutral typed-source contract')
 unless $serialize_aliases->(@julia_source_boundary_aliases)
  eq $serialize_aliases->(@neutral_source_boundary_aliases);
fail('Lua source-boundary compatibility aliases differ from the neutral typed-source contract')
 unless $serialize_aliases->(@lua_source_boundary_aliases)
  eq $serialize_aliases->(@neutral_source_boundary_aliases);

my %seen;
for my $name (@dart) {
 fail("duplicate current call name '$name'") if $seen{$name}++;
}

my $complete_mark_contract = decode_json(read_text('capability_conformance/complete_named_mark_contract.json'));
fail('complete named-mark helpers must be an array')
 unless ref($complete_mark_contract->{helpers}) eq 'ARRAY';
my @complete_mark_names = map {
 fail('complete named-mark helper must be an object') unless ref($_) eq 'HASH';
 my $name = $_->{name};
 fail('complete named-mark helper name must be an identifier')
  if !defined($name) || ref($name) || $name !~ /^[A-Za-z_]\w*\z/;
 $name;
} @{$complete_mark_contract->{helpers}};
fail('complete named-mark contract must contain exactly seven helpers')
 unless @complete_mark_names == 7;
my @missing_complete_mark = grep { !$seen{$_} } @complete_mark_names;

my $perl_contracts = LinkedSpec::RuleIR::EmitContext::_build_action_lowering_contracts('Top');
my %perl_current_contract;
for my $contract (@{$perl_contracts}) {
 next if $contract->{compatibility_surface};
 my $name = $contract->{diag_name};
 $perl_current_contract{$name} = 1 if defined($name) && $name =~ /^[A-Za-z_]\w*\z/;
}

# These fifteen identifier-shaped diagnostics are deliberately not ordinary
# public current calls. Keeping the classification next to the independent
# reverse check means a newly added Perl current contract cannot disappear
# symmetrically from every backend inventory merely because no corpus fixture
# happens to call it. The five recognition forms and Perl-only progressive
# dispatch are dedicated intrinsics with ActionIR nodes, not members of the
# shared helper-call surface.
my %classified_non_public_perl_contract = (
 array_append_operator => 'internal lowering operation',
 array_end_mutation_method => 'internal lowering operation',
 capture => 'legacy capture surface',
 capture_macro => 'legacy capture surface',
 dispatch_span => 'Perl-only dedicated intrinsic pending shared backend recurrence',
 entry_named_map => 'documented compatibility alias',
 hash_index_assignment_operator => 'internal lowering operation',
 match_named_map => 'documented compatibility alias',
 observe_recognition => 'grammar-owned dedicated intrinsic',
 recognition_checkpoint => 'grammar-owned dedicated intrinsic',
 recognition_commit => 'grammar-owned dedicated intrinsic',
 recognition_rollback => 'grammar-owned dedicated intrinsic',
 recognize_once => 'grammar-owned dedicated intrinsic',
 scalar_assignment_operator => 'internal lowering operation',
 value_drop => 'internal lowering operation',
);
my @classified_name_missing_from_perl = grep {
 !$perl_current_contract{$_}
} sort keys %classified_non_public_perl_contract;
my @classified_name_admitted = grep {
 $seen{$_}
} sort keys %classified_non_public_perl_contract;
my @public_perl_contract = grep {
 !$classified_non_public_perl_contract{$_}
} sort keys %perl_current_contract;
my @missing_public_perl_contract = grep { !$seen{$_} } @public_perl_contract;
my @complete_mark_missing_from_perl = grep {
 !$perl_current_contract{$_}
} @complete_mark_names;

my $book_source = '';
my $book_root = File::Spec->catdir($repo_root, 'docs', 'linkedspec-book', 'src');
find(
 sub {
  return unless -f $_ && $_ =~ /\.md\z/;
  open my $fh, '<:raw', $File::Find::name or fail("cannot read $File::Find::name: $!");
  local $/;
  $book_source .= <$fh> . "\n";
  close $fh or fail("cannot close $File::Find::name: $!");
 },
 $book_root,
);
my $manifest = decode_json(read_text('rust/linkedspec-runtime/tests/corpus/manifest.json'));
fail('oracle manifest cases must be an array') unless ref($manifest->{cases}) eq 'ARRAY';
my $corpus_source = '';
for my $case (@{$manifest->{cases}}) {
 fail('oracle manifest case must be a non-empty string') if ref($case) || !defined($case) || $case eq '';
 $corpus_source .= read_text("rust/linkedspec-runtime/tests/corpus/$case/input.spec");
 $corpus_source .= "\n";
}
fail('complete named-mark fixture must be an object')
 unless ref($complete_mark_contract->{fixture}) eq 'HASH';
my $complete_mark_source = $complete_mark_contract->{fixture}{spec_source};
fail('complete named-mark fixture spec_source must be a non-empty string')
 if !defined($complete_mark_source) || ref($complete_mark_source) || $complete_mark_source eq '';
my $gap_contract = decode_json(read_text('capability_conformance/inter_match_gap_capture_contract.json'));
fail('inter-match gap public contract must be current')
 unless ref($gap_contract->{public_contract}) eq 'HASH'
  && $gap_contract->{public_contract}{status} eq 'current';
my @gap_public_names = map {
 fail('inter-match gap public call row must be current')
  unless ref($_) eq 'HASH' && $_->{status} eq 'current' && defined($_->{name}) && !ref($_->{name});
 $_->{name};
} @{$gap_contract->{public_contract}{current_calls} // []};
fail('inter-match gap public call inventory drifted')
 unless join("\0", @gap_public_names) eq join("\0", qw(entry_slot gap_kind gap_span gap_text));
my $gap_public_source = $gap_contract->{public_contract}{executable_example}{spec_source};
fail('inter-match gap public fixture spec_source must be a non-empty string')
 if !defined($gap_public_source) || ref($gap_public_source) || $gap_public_source eq '';
my $governed_fixture_source =
 $corpus_source . $complete_mark_source . "\n" . $gap_public_source . "\n";

my (@missing_book, @missing_governed_fixture);
for my $name (@dart) {
 my $quoted = quotemeta($name);
 my $word_prefix = $name =~ /^[A-Za-z_]/ ? '\\b' : '';
 my $word_suffix = $name =~ /[A-Za-z0-9_]\z/ ? '\\b' : '';
 push @missing_book, $name unless $book_source =~ /$word_prefix$quoted$word_suffix/;
 my $corpus_pattern = $name eq 'otherwise'
  ? qr/$word_prefix$quoted$word_suffix/
  : qr/$word_prefix$quoted\s*\(/;
 push @missing_governed_fixture, $name unless $governed_fixture_source =~ $corpus_pattern;
}

my %neutral_perl_contract_call;
while ($corpus_source =~ /\b([A-Za-z_]\w*)\s*\(/g) {
 my $name = $1;
 $neutral_perl_contract_call{$name} = 1 if $perl_current_contract{$name};
}
my @missing_reference_contract = grep { !$seen{$_} } sort keys %neutral_perl_contract_call;

if ($report_only) {
 printf "language-capability-coverage: REPORT (%d current call names; %d neutral corpus fixtures + 1 exact named-mark fixture)\n",
  scalar(@dart), scalar(@{$manifest->{cases}});
 printf "  missing from mdBook: %d%s\n", scalar(@missing_book),
  @missing_book ? ' (' . join(', ', @missing_book) . ')' : '';
 printf "  missing from governed fixture sources: %d%s\n", scalar(@missing_governed_fixture),
  @missing_governed_fixture ? ' (' . join(', ', @missing_governed_fixture) . ')' : '';
 printf "  complete named-mark contract calls missing from backend inventories: %d%s\n",
  scalar(@missing_complete_mark),
  @missing_complete_mark ? ' (' . join(', ', @missing_complete_mark) . ')' : '';
 printf "  independently derived public Perl contracts missing from backend inventories: %d/%d%s\n",
  scalar(@missing_public_perl_contract), scalar(@public_perl_contract),
  @missing_public_perl_contract ? ' (' . join(', ', @missing_public_perl_contract) . ')' : '';
 printf "  classified non-public Perl names admitted by backend inventories: %d%s\n",
  scalar(@classified_name_admitted),
  @classified_name_admitted ? ' (' . join(', ', @classified_name_admitted) . ')' : '';
 printf "  neutral Perl contract calls missing from backend inventories: %d%s\n",
  scalar(@missing_reference_contract),
  @missing_reference_contract ? ' (' . join(', ', @missing_reference_contract) . ')' : '';
 exit 0;
}

fail('complete named-mark calls missing from backend inventories: ' . join(', ', @missing_complete_mark))
 if @missing_complete_mark;
fail('complete named-mark calls missing from Perl current contracts: ' .
 join(', ', @complete_mark_missing_from_perl)) if @complete_mark_missing_from_perl;
fail('classified non-public names missing from Perl current contracts: ' .
 join(', ', @classified_name_missing_from_perl)) if @classified_name_missing_from_perl;
fail('classified non-public Perl names admitted by backend inventories: ' .
 join(', ', @classified_name_admitted)) if @classified_name_admitted;
fail('independently derived public Perl contracts missing from backend inventories: ' .
 join(', ', @missing_public_perl_contract)) if @missing_public_perl_contract;
fail('current call names missing from the mdBook: ' . join(', ', @missing_book)) if @missing_book;
fail('current call names missing from governed fixture sources: ' .
 join(', ', @missing_governed_fixture)) if @missing_governed_fixture;
fail('neutral current Perl contract calls missing from Dart/Julia inventories: ' .
 join(', ', @missing_reference_contract)) if @missing_reference_contract;

printf "language-capability-coverage: OK (%d current call names; %d corpus + 1 exact named-mark fixture; %d public Perl contracts independently covered)\n",
 scalar(@dart), scalar(@{$manifest->{cases}}), scalar(@public_perl_contract);
