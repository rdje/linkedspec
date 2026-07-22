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
  - "which backends still need Unicode rule label alignment"
date: 2026-07-21
status: current
tags: [grammar, unicode, rule-labels, rust, dart, generated-data, validation, portability]
evidence: docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/unicode_rule_label_contract.json; unicode_case/generate_unicode_rule_label_contract.py; unicode_case/unicode_rule_label_regex_class.txt; specs/spec.spec; tools/check_unicode_rule_label_contract.py; dart/lib/src/parser/unicode_rule_label.dart; dart/lib/src/runtime/matching.dart; dart/test/unicode_rule_label_classifier_test.dart; dart/test/self_hosted_unicode_rule_label_test.dart; rust/linkedspec-core/src/unicode_rule_label.rs; rust/linkedspec-core/src/parser.rs; rust/linkedspec-core/src/validation.rs; rust/linkedspec-core/tests/unicode_rule_label_contract.rs; rust/linkedspec-runtime/tests/unicode_rule_label_routes.rs
reverify: "python3 tools/check_unicode_rule_label_contract.py; cd dart && dart test test/unicode_rule_label_classifier_test.dart test/self_hosted_unicode_rule_label_test.dart test/runtime_matching_test.dart && cd ..; CARGO_TARGET_DIR=/private/tmp/linkedspec-unicode-label-reverify cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --test unicode_rule_label_contract; CARGO_TARGET_DIR=/private/tmp/linkedspec-unicode-label-reverify cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test unicode_rule_label_routes"
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
the algorithm topology; focused tests exercise every range boundary and neutral fixture. This `.10.5.0.2.0`
foundation is not imported by Dart's parser/validator until `.10.5.0.2.1`.

Dart's bounded self-hosted regex bridge derives that exact label atom from each canonical structural pattern
rather than owning another label table. It enables Unicode regex mode whenever a pattern contains supplementary
literal scalars, recognizes the canonical explicit lifecycle alternation and bare-edge structural families, and
directly executes current `specs/spec.spec` across all label edge forms. This shared grammar bridge does not repair
Dart's separate hardcoded header/reference scanner or external-AST validation; `.10.5.0.2` still owns those routes.

The Rust parser consumes its generated classifier
for headers and action, blind, and bare references; validation rechecks declarations and all edge targets so a
deserialized or programmatically constructed AST cannot bypass the policy. Focused proof covers positive/negative
membership, all syntax routes, exact compiled/descriptor/generated/emitted identities, explicit selectors, strict
loading, and traces.

This prerequisite removes the Rust semantic privacy fixture's former `Töp` blocker but does not advance semantic
rollout or claim exhaustive five-backend label membership. Perl already accepts the strict-decoded fixture route.
Dart, Julia, PUC Lua, and LuaJIT parser alignment is explicitly required by semantic backend leaves
`FUTURE-PARITY-BACKLOG.10.5-.10.7` before those backends admit the v1 privacy fixture. See
[[rust-semantic-introspection-authority-map]], [[unicode-17-case-contract-data]],
[[primary-cli-strict-utf8-text-contract]], and [[rust-native-spec-resolution]].
