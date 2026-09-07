---
id: unicode-rule-label-contract
title: Rule labels use pinned Unicode 17 XID_Continue with exact scalar identity
answers:
  - "what Unicode characters are allowed in a LinkedSpec rule label"
  - "can a LinkedSpec rule label start with a digit or underscore"
  - "does LinkedSpec normalize Unicode rule labels"
  - "are Töp and decomposed Töp the same rule label"
  - "are rule labels case sensitive"
  - "where is the Rust Unicode rule label classifier generated"
  - "where is the Dart Unicode rule label classifier generated"
  - "does the Dart Unicode label scanner split supplementary UTF-16 pairs"
  - "where is the portable self-hosted rule label regex class generated"
  - "is the self-hosted rule label class derived from host Unicode tables"
  - "does specs/spec.spec consume the pinned Unicode rule label class"
  - "how many self-hosted grammar sites consume the Unicode rule label class"
  - "which Rust parser routes consume the Unicode rule label contract"
  - "which Dart downstream routes preserve exact Unicode rule label identity"
  - "does Dart Unicode rule label expansion broaden other identifier grammars"
  - "is Dart native Unicode rule-label alignment closed"
  - "where is the Lua Unicode rule label classifier generated"
  - "which Lua downstream routes preserve exact Unicode rule label identity"
  - "is Lua positive Unicode rule-label identity aligned on PUC Lua and LuaJIT"
  - "which backends still need Unicode rule label alignment"
  - "where is the Perl named-slot Unicode classifier generated"
  - "does the Perl XID classifier enforce the named-slot digit reservation"
date: 2026-09-07
status: current
tags: [grammar, unicode, rule-labels, rust, dart, julia, lua, generated-data, validation, portability]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.5.0.2.0-.4, .10.6.1.0-.4, and .10.7.0-.1.3; docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/unicode_rule_label_contract.json; unicode_case/generate_unicode_rule_label_contract.py; unicode_case/unicode_rule_label_regex_class.txt; specs/spec.spec; tools/check_unicode_rule_label_contract.py; rust/linkedspec-core/src/unicode_rule_label.rs; dart/lib/src/parser/unicode_rule_label.dart; julia/src/spec/UnicodeRuleLabel.jl; lua/src/linkedspec/unicode_rule_label.lua; lua/test/unicode_rule_label_identity_routes_test.lua; lua/test/unicode_rule_label_negative_isolation_test.lua; docs/knowledge/lua-unicode-rule-label-implementation-plan.md
reverify: "bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py; bash tools/run_lua_local.sh; cd dart && bash ../tools/run_dart_project_data.sh test test/unicode_rule_label_classifier_test[.]dart test/unicode_rule_label_routes_test[.]dart test/unicode_rule_label_identity_routes_test[.]dart test/unicode_rule_label_negative_isolation_test[.]dart test/self_hosted_unicode_rule_label_test[.]dart test/runtime_matching_test.dart && cd ..; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-core --test unicode_rule_label_contract; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test unicode_rule_label_routes"
---

ADR `0051` defines a rule label as one or more Unicode 17.0.0 `XID_Continue` scalar values, with the same class at
every position. This preserves all historical `[A-Za-z0-9_]+` labels, including digit and underscore starts. The
normative repository-pinned `DerivedCoreProperties.txt` produces 806 maximally merged ranges; host `\w`, locale,
PCRE tables, and toolchain Unicode versions are not authorities.

Identity is the exact decoded scalar sequence and remains case-sensitive and normalization-sensitive. LinkedSpec
does no normalization, case mapping, or folding. Precomposed `Töp`, decomposed `To\u{0308}p`, and lowercase `töp`
are valid but distinct declarations, references, selectors, compiled keys, descriptor entries, generated-plan
labels, diagnostics, and trace identities. Strict UTF-8 decoding remains the boundary before scanning.

`unicode_case/generate_unicode_rule_label_contract.py` verifies the pinned upstream hashes and deterministically
writes the neutral JSON, `linkedspec-core`'s range-table classifier, and one portable UTF-8 literal-range class in
`unicode_case/unicode_rule_label_regex_class.txt`. That self-hosted artifact encodes the same 806 merged range
endpoints directly, not a host Unicode property escape. Its checker independently reconstructs and byte-compares
the class, rejects regex/delimiter membership that would need engine-specific escaping, compiles it, and exercises
every positive, negative, and distinct fixture. Leaf `.10.5.0.1.0` adds only this generated authority;
`.10.5.0.1.1` consumes it exactly 12 times in canonical `specs/spec.spec`: one declaration site and all action,
blind-call, and bare-edge block/fluent/plain target sites. The checker rejects a missing, extra, or substituted
site while function/helper/lifecycle/fluent-method/mark identifiers retain their separate grammars.

The same generator now writes `dart/lib/src/parser/unicode_rule_label.dart`: one internal table with exact
binary-search scalar membership, complete-label validation, and longest-prefix scanning. Dart iterates runes but
must slice UTF-16 strings, so the generated scanner advances two code units for a supplementary scalar and one for
all other accepted scalars. The checker regenerates the file, independently compares all 806 endpoints, and locks
the algorithm topology; focused tests exercise every range boundary and neutral fixture. Dart's native parser now
uses this scanner for header discovery plus action, blind, and bare targets. Its validator applies the complete
predicate to every declaration and target, including JSON-reconstructed and programmatic ASTs. Invalid suffixes
remain whole failures instead of becoming valid prefixes; unrelated identifier grammars keep their own policies.

Dart's bounded self-hosted regex bridge derives that exact label atom from each canonical structural pattern
rather than owning another label table. It enables Unicode regex mode whenever a pattern contains supplementary
literal scalars, recognizes the canonical explicit lifecycle alternation and bare-edge structural families, and
directly executes current `specs/spec.spec` across all label edge forms. This shared grammar bridge and the native
Dart scanner deliberately consume the same generated scalar authority. The exact-identity suite now drives all
nine positive labels and both distinct pairs through compiled maps/order, JSON and descriptors, generated plans,
AST and emitted-payload reconstruction, an isolated emitted caller package, native/generated selectors,
diagnostics, traces, strict loading, and primary inline/file commands. Exact scalar sequence, case, and
normalization form survive every route.

All eight negative fixtures fail every programmatic and JSON-reconstructed Dart declaration/action/blind/bare
role with the same portable diagnostic. Source proof locks header/action/blind/bare token boundaries, `$Top`
no-prefix rejection, primary compilation failure, and the deliberate structural cases: `Top:` may introduce rule
`Top`, while `Top\nRule` is two tokens. Function names/parameters, ActionIR helper and fluent names, lifecycle
markers, and named-mark variables retain their existing narrower spellings; label membership never broadens them.

The Rust parser consumes its generated classifier
for headers and action, blind, and bare references; validation rechecks declarations and all edge targets so a
deserialized or programmatically constructed AST cannot bypass the policy. Focused proof covers positive/negative
membership, all syntax routes, exact compiled/descriptor/generated/emitted identities, explicit selectors, strict
loading, and traces.

The same neutral generator writes `lua/src/linkedspec/unicode_rule_label.lua` as a private Lua-5.1-compatible
classifier. Strict UTF-8 decoding, binary-search membership, complete labels, and one-based byte-prefix scanning
run unchanged on PUC Lua and LuaJIT. Exactly five header/action/blind/bare parser roles consume it, and the first
AST validator pass rechecks declarations plus all three target kinds. The identity suite derives ten unique labels
from all positive/distinct fixtures and compares exact bytes through parsed/reconstructed AST, compiled JSON and
maps/order, descriptors, generated plans, loaded/reconstructed/direct-generated runtimes, emitted modules in
process and under a fresh selected-ABI host, strict loaders, selectors, diagnostics, traces, and inline/file
primary commands. Normalization-sensitive labels remain different rules; portable artifacts deny paths and Lua
table/userdata identity. All 359 assertions pass unchanged on both ABIs.

This prerequisite removes the semantic privacy fixture's former `Töp` blocker without independently advancing
semantic rollout. Perl accepts the strict-decoded fixture route. Rust, Dart, and Julia native parsing/validation,
positive/distinct downstream identity, negative/identifier isolation, and composed signoff are aligned and closed.
PUC Lua and LuaJIT now align the generated classifier, parser/validator trust boundary, exact positive/distinct
downstream identity, and exhaustive negative/isolation proof. The `.10.7.1.3.0` audit found a pre-existing body-
fluent adapter that discarded a same-line suffix after an ASCII method prefix; `.3.1` propagates that existing
remainder and proves exact rejection plus control/valid-route preservation at 166 assertions per ABI. `.3.2`
derives all eight neutral negatives and proves source, four-role/two-trust-path, artifact, loaded/generated/emitted/
fresh runtime, selector, diagnostic, trace, loader, primary, host-denial, and adjacent-grammar boundaries at 1,542
assertions per ABI. Parent `.3` is closed; `.10.7.1.4` recomposes every committed owner unchanged and closes the
Lua prerequisite. Source/outcome planning `.10.7.2.0` follows. See
[[rust-semantic-introspection-authority-map]], [[unicode-17-case-contract-data]],
[[julia-unicode-rule-label-preflight]], [[lua-unicode-rule-label-preflight]],
[[lua-body-fluent-suffix-loss]], [[lua-unicode-rule-label-negative-isolation]],
[[primary-cli-strict-utf8-text-contract]], and
[[rust-native-spec-resolution]].

## September 6 Perl classifier checkpoint

`SESSION-STARTUP-READING.3.2.52` reconciles the complete .31 reading of
`perl/LinkedSpec/UnicodeXIDContinue.pm`: 855 lines / 17,340 bytes; baseline SHA-256
`db2185e0a2366849c126d76b27ad5591eee9463ea5e825e815e9feabe97b8947`.
ADR 0051's August 13 addition makes this generated Perl table a shared identifier authority for named
regex-slot declarations and selectors. Validation and RuleIR call the complete-string predicate, then
separately reject ASCII digit-only slot names. The classifier itself admits digit-only labels under
the rule-label policy. Its production string path unpacks scalar codepoints before binary search;
this is not a claim about accepting arbitrary caller-supplied numeric strings at the internal point API.

Current managed regeneration passes at 806 ranges, nine positive/eight negative fixtures, and two
distinct pairs. A direct in-memory Perl control independently invokes every range start/end and both
adjacent gaps (3,224 checks), all 17 fixtures, and both identity pairs. It passes without warnings.
This is direct classifier proof; public parser/generated/CLI routes retain their existing owners.
The current checker byte-compares JSON, five backend classifiers, and the portable regex class;
its Perl topology/range checks alone do not execute the Perl classifier.

Exact direct control:

```sh
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'STARTUP56_XID_CONTROL'
use strict;
use warnings;
use JSON::PP ();
use LinkedSpec::UnicodeXIDContinue ();
open my $fh, '<:raw', 'capability_conformance/unicode_rule_label_contract.json' or die $!;
my $contract = JSON::PP->new->utf8(1)->decode(do { local $/; <$fh> });
close $fh or die $!;
my $boundary_checks = 0;
for my $range (@{$contract->{xid_continue_ranges}}) {
 my ($start, $end) = map { hex($_) } @$range;
 for my $check ([$start, 1], [$end, 1], [$start - 1, 0], [$end + 1, 0]) {
  my ($point, $expected) = @$check;
  my $actual = LinkedSpec::UnicodeXIDContinue::is_xid_continue_codepoint($point);
  die "boundary $point differs" unless $actual == $expected;
  ++$boundary_checks;
 }
}
my $fixture_checks = 0;
for my $group (['positive_fixtures', 1], ['negative_fixtures', 0]) {
 for my $fixture (@{$contract->{$group->[0]}}) {
  my $actual = LinkedSpec::UnicodeXIDContinue::is_xid_continue_string($fixture->{label});
  die "fixture $fixture->{id} differs" unless $actual == $group->[1];
  ++$fixture_checks;
 }
}
for my $pair (@{$contract->{distinct_fixtures}}) {
 die 'identity collision' unless $pair->{left} ne $pair->{right};
 for my $side (qw(left right)) {
  die 'distinct label rejected' unless LinkedSpec::UnicodeXIDContinue::is_xid_continue_string($pair->{$side});
 }
}
print JSON::PP->new->canonical(1)->encode({ranges=>scalar(@{$contract->{xid_continue_ranges}}),boundary_checks=>$boundary_checks,fixture_checks=>$fixture_checks,distinct_pairs=>scalar(@{$contract->{distinct_fixtures}}),result=>'PASS'}),"\n";
STARTUP56_XID_CONTROL
```

## September 7 Rust classifier checkpoint

`SESSION-STARTUP-READING.3.3.11` reads every line of the 850-line / 20,086-byte Rust
classifier, including all 806 range rows. Its baseline SHA-256 is
`28f1a8ffefd324a9191e8cd1bc26dad85ffa7eb6d97edf58106156311d3d114c`.
Membership binary-searches the pinned inclusive intervals. Complete labels reject
empty strings; prefix scanning walks `char_indices`, advances by `len_utf8`, and
splits only after an accepted complete scalar. It neither normalizes nor folds.

The validator prefix rechecks the complete declaration and action/blind/bare
target labels, preserving exact spelling and the declaration/edge-target role in
portable diagnostics. Fresh managed regeneration passes all 806 ranges, nine
positive/eight negative fixtures and two distinct pairs. This is source and neutral
generated-artifact proof, not a fresh Rust parser/runtime route suite.
