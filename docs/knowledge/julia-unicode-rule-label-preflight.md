---
id: julia-unicode-rule-label-preflight
title: Julia rule labels use the generated pinned Unicode 17 classifier at parser and validator boundaries
answers:
  - "does Julia fully support the Unicode rule-label contract"
  - "does Julia use pinned Unicode 17 XID Continue for rule labels"
  - "which Julia parser patterns use host regex word classes for labels"
  - "what PCRE2 and Unicode versions back Julia rule label regexes"
  - "how many required Julia rule-label scalars does host word regex miss"
  - "how many forbidden rule-label scalars does Julia host word regex accept"
  - "can Julia parse the required middle dot rule label"
  - "can Julia compile a forbidden superscript rule label"
  - "does Julia reject invalid rule-label prefixes without truncation"
  - "does Julia validate complete rule labels after JSON reconstruction"
  - "can programmatic Julia ASTs bypass rule-label validation"
  - "which Julia rule-label roles bypass validation"
  - "what must happen before Julia semantic privacy fixture admission"
  - "where will the generated Julia Unicode rule-label classifier live"
  - "which Julia files and tests own Unicode rule-label implementation"
  - "what is the Julia Unicode rule-label implementation order"
  - "how will Julia reject rule-label prefix truncation"
  - "how does Julia validate rule labels now"
  - "where is the Julia Unicode rule-label classifier generated"
date: 2026-07-22
status: current
tags: [julia, unicode, rule-labels, parser, validation, generated-source, semantic-introspection]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.6.1.0-.1; docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/unicode_rule_label_contract.json; unicode_case/generate_unicode_rule_label_contract.py; julia/src/spec/UnicodeRuleLabel.jl; julia/src/spec/Parser.jl; julia/src/spec/Validator.jl; julia/test/unicode_rule_label_classifier_test.jl; julia/test/unicode_rule_label_routes_test.jl
reverify: "python3 tools/check_unicode_rule_label_contract.py; /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'using Test; using LinkedSpecJulia; include(\"julia/test/unicode_rule_label_classifier_test.jl\"); include(\"julia/test/unicode_rule_label_routes_test.jl\")'"
---

Julia now implements the parser/validator core of ADR `0051` with one generated pinned-data authority. Before
leaf `.10.6.1.1`, every native label-bearing parser route used host PCRE2 `\w`: `_HEADER_PATTERN`,
`_BODY_HEADER_PATTERN`, `_ACTION_PATTERN`, `_BLIND_PATTERN`, and `_BARE_EDGE_PATTERN`. The measured Julia 1.12.6
runtime uses PCRE2 10.47 (2025-10-21) with Unicode tables 16.0.0, while the repository contract pins Unicode
17.0.0 `XID_Continue` at every label position. That historical mismatch motivated the generated classifier; none
of those five host-property patterns remains a rule-label authority.

An exhaustive scalar census against the contract's 806 maximally merged ranges found two independent drifts:

- host `^\w+$` rejects 5,175 scalars required by pinned `XID_Continue`; the first include U+00B7 MIDDLE DOT,
  U+0387, U+088F, and multiple combining marks;
- host `^\w+$` accepts 923 scalars forbidden by pinned `XID_Continue`; the first include U+00B2, U+00B3, U+00B9,
  U+00BC, U+00BD, and U+00BE.

The preflight nine-positive fixture probe accepted eight and rejected required label `A·B`. `Töp`, decomposed
`Töp`, Greek, CJK, and supplementary labels worked only because the host table happened to include them.
Conversely, forbidden source label `²` parsed, validated, compiled, and could be selected explicitly. The colon
negative exposed prefix truncation: embedding label fixture `Top:` as a declaration produced `Top:::` and the
parser accepted `Top` instead of rejecting the complete token. Focused `.10.6.1.1` proof closes those native
scanner boundaries, including third-colon rejection and malformed-arrow preservation.

Before `.10.6.1.1`, the validator checked duplicate labels, target existence, function collisions, and structural
rules without one complete-label membership predicate. Programmatic or JSON-reconstructed ASTs therefore bypassed
parser membership entirely: probes accepted forbidden `Top-Rule` and parser-rejected-but-required `A·B` in
declaration, action, blind, and bare target roles through validation and downstream artifact construction. The
validator now runs `_check_rule_labels` immediately after the nonempty-spec check in traced and untraced paths and
emits portable `invalid_rule_label` / `validate_rule_labels` evidence before structural resolution.

The generated prerequisite now lives at `julia/src/spec/UnicodeRuleLabel.jl`, derived from the neutral 806 ranges
by `unicode_case/generate_unicode_rule_label_contract.py --julia-output`. It carries exact contract/version/hash/
range-count metadata, a half-open binary-search scalar predicate, complete-label validation, and a prefix scanner
that uses Julia string indices and `nextind`. `LinkedSpecJulia.jl` includes it before `Parser.jl` without exporting
a public name. The independent checker regenerates and byte-compares it, extracts all endpoints independently,
denies stale host-regex label sites, and locks test plus CI registration.

Parser routing replaces only the five historical label-bearing patterns. Header parsing and body-header
termination share one
complete header-field scanner with explicit third-colon rejection. Action, blind, and bare target lists share
scalar-safe label-at-offset, optional-index, delimiter, and remainder helpers; malformed arrow spellings remain raw
syntax instead of producing a partial edge. Validator routing adds one `_check_rule_labels` immediately after the
nonempty-spec check in both traced and untraced paths. It validates every declaration plus action, blind, and bare
target and returns portable `invalid_rule_label` / `validate_rule_labels` evidence. Regex, lifecycle, split/mark,
conditional, fluent, bounded-mode, function-shell, and ActionParser identifier patterns stay independently owned.

Focused proof passes 1,755 assertions, and complete Julia passes 5,466 package assertions, primary process
conformance, and corpus 105/105. The five-backend default/POSIX primary matrix passes 5x2x66, as does the
self-hosted Unicode manifest on all ten legs. This proves the generated classifier plus native parser/validator
core, not the entire Julia Unicode subtree. Staged canonical proof also passes Rust semantic admission 1/1 in
79.93 seconds, Dart admission 1/1, primary 66x2, and Phase 0 1,031/1,031 in 663 seconds.

The remaining dependency order is exact: `.2` drives the ten unique identities represented by all nine positives and both distinct pairs through AST,
compiled maps/order/JSON, descriptor, generated plan/direct execution, reconstructed state, independently emitted
host, selectors, diagnostics, traces, strict loader, and inline/file primary commands; `.3` drives all eight
negatives through four declaration/target roles from both programmatic and reconstructed ASTs, whole-token and
no-prefix source/primary failures, newline behavior, and unrelated identifier isolation; `.4` composes complete
Julia/canonical proof and closes without semantic promotion. Julia semantic construction and the `Töp` privacy
fixture remain unadmitted until that full route closure; this Unicode work does not move semantic rollout or
native admission.
