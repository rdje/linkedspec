---
id: julia-unicode-rule-label-preflight
title: Julia rule labels retain exact pinned Unicode 17 identity through parser and downstream routes
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
  - "does Julia preserve exact Unicode rule labels through generated and emitted parsers"
  - "do Julia Unicode rule-label selectors diagnostics and traces preserve exact identity"
  - "does Julia leak resolved spec paths through compiled Unicode rule-label artifacts"
  - "does Julia reject every invalid Unicode rule label before artifact construction"
  - "do Julia rule labels change function helper lifecycle mark regex or mode identifiers"
  - "why does Julia ActionParser accept Töp but reject middle dot identifiers"
  - "is the Julia Unicode rule-label prerequisite composition closed"
date: 2026-07-22
status: current
tags: [julia, unicode, rule-labels, parser, validation, generated-source, semantic-introspection]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.6.1.0-.4; docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/unicode_rule_label_contract.json; unicode_case/generate_unicode_rule_label_contract.py; julia/src/spec/UnicodeRuleLabel.jl; julia/src/spec/Parser.jl; julia/src/spec/Validator.jl; julia/test/unicode_rule_label_classifier_test.jl; julia/test/unicode_rule_label_routes_test.jl; julia/test/unicode_rule_label_identity_routes_test.jl; julia/test/unicode_rule_label_negative_isolation_test.jl
reverify: "bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py; bash tools/run_julia_project_data.sh --project=julia -e 'using Test; using LinkedSpecJulia; using JSON3; const REPO_ROOT = pwd(); include(\"julia/test/unicode_rule_label_classifier_test.jl\"); include(\"julia/test/unicode_rule_label_routes_test.jl\"); include(\"julia/test/unicode_rule_label_identity_routes_test.jl\"); include(\"julia/test/unicode_rule_label_negative_isolation_test.jl\")'"
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

Core focused proof passes 1,755 assertions, and exact-identity `.10.6.1.2` adds 130 assertions derived from every
positive fixture and both distinct pairs. Those ten unique labels retain exact authored/compiled order and map
keys, JSON and descriptor identity, generated-plan rows, JSON-reconstructed execution, direct/generated selectors,
deterministic emitted-payload reconstruction, fresh offline emitted-host execution, strict loaded source without
resolved-path leakage, portable missing-selector diagnostics, native/generated trace identity, and inline/file
primary command behavior. Focused composition is 1,885, complete Julia is 5,596 package assertions plus primary
process conformance and corpus 105/105, and the five-backend default/POSIX primary matrix passes 5x2x66 plus the
self-hosted Unicode manifest on all ten legs. No production code, neutral contract, public API, generated format,
or semantic governance changes in `.2`. Canonical proof passes Rust semantic admission 1/1 in 80.21 seconds,
Dart admission 1/1, primary 66x2, and Phase 0 1,031/1,031 in 645 seconds; exact generated cleanup reclaims about
1.57 GB while preserving Pgen artifacts.

Negative/isolation `.10.6.1.3` consumes all eight neutral negatives without copying their labels. Its external
trust matrix crosses declaration/action/blind/bare roles, programmatic and JSON-reconstructed ASTs, and validation,
compilation, descriptor, generated-plan, and emitted-source attempts. All 1,609 assertions return exact portable
`invalid_rule_label` evidence before an artifact can exist. Complete-token/no-prefix/newline proof adds 131;
native/generated selector, strict-loader, and path-redacted primary proof adds 136; unrelated-grammar isolation
adds 70. The 1,946 new assertions compose with classifier/native/identity proof to focused 3,831, while complete
Julia is 7,542/primary/105. Full 5x2x66 and every Unicode-manifest leg pass without production change.

Canonical proof passes Rust semantic admission 1/1 in 79.56 seconds, Dart admission 1/1, primary 66x2, and Phase 0
1,031/1,031 in 645 seconds. Knowledge Map 682/5,150, mdBook, memory, task metadata, all four doctrines, and diff
hygiene pass. Exact cleanup removes the 12-MB rendered book, 826-MB Rust deps, 727-MB incremental state, and 28-KB
Python cache—about 1.57 GB—while preserving `rgx/pgen-issues/artifacts`.

Composition closeout `.10.6.1.4` adds no code or replacement test. It reruns the committed generated classifier,
native routes/validator, positive identity, and negative/isolation suites at focused 3,831; complete Julia remains
7,542/primary/105. The full primary matrix passes 5x2x66 and the current-grammar Unicode manifest passes all ten
legs at 1/1. Unicode stays 806/9/8/2, semantic governance 6/20/81 at rollout 4/9 and admission 3/6, capability
80/0/0, generated source v1/10/80-0-0, and public surface 59/27/0. Canonical proof passes Rust admission 1/1 in
78.46 seconds, Dart 1/1, primary 66x2, and Phase 0 1,031/1,031 in 630 seconds. Knowledge Map 682/5,151, mdBook,
memory, task metadata, all four doctrines, and diff hygiene pass; exact cleanup reclaims about 1.57 GB while
preserving Pgen. Parent `.10.6.1` is composition-closed. The only dependency-ready successor is behavior-free
source/outcome plan `.10.6.2.0` after the clean closeout commit.

The adjacent-grammar result is intentionally not a new universal identifier policy. Function and parameter names
stay ASCII. ActionParser retains its existing ASCII-first host-word continuation: `Töp` remains a helper, variable,
fluent method, and assignment identifier, whereas `A·B` and a supplementary-first spelling remain raw. Lifecycle
markers, named marks, regex contents, and bounded-mode tokens keep their separate existing grammars. Strict loader
exceptions retain typed request/resolved-path fields, but detail remains path-free and primary output remains
redacted; no compiled or generated artifact contains the host path.

The remaining dependency order is exact: completed `.2` owns positive/distinct downstream identity and completed
`.3` owns exhaustive negative rejection plus adjacent-grammar isolation. `.4` composes complete Julia/canonical
proof and closes without semantic promotion. Julia semantic construction and the `Töp` privacy fixture remain
unadmitted until that full route closure; this Unicode work does not move semantic rollout or native admission.

## 2026-09-11 — all range rows physically read; classifier suffix still pending

Julia .1.31 reads UnicodeRuleLabel1-822, including metadata and all806 pinned
XID_Continue intervals from ASCII digits through U+E01EF. The final delimiter and
classifier/prefix functions823-872 remain owned by .1.32; executing their tests
adds no unread-source credit. Neutral regeneration preserves exact806/9/8/2.

Fresh classifier metadata/boundary1619, complete-label23 and prefix32 assertions
pass1674; parser/validator route7/54/8/8/4 adds81, for1755. Original frontend224
adds a separate selection assertion. New body-fluent Unicode truncation belongs
to its distinct method grammar and adapter, not the pinned rule-label ranges.
Exact contrasts and repair ownership are [[julia-spec-lexical-boundary-defects]].

## September 11 — classifier source reading complete

Julia .1.32 reads823-872, completing the table delimiter and binary-search,
whole-label and scalar-safe prefix functions. Out-of-range arbitrary-size integers
are rejected before Int conversion. All1674 existing classifier assertions and six
additional integer/prefix boundaries pass. Exact ranges and focused replay are in
[[julia-function-projection-metadata-gaps]]; this reading does not change the pinned
Unicode17 contract or close any existing parser repair.

## September 11 — classifier and identity consumer reading .1.50

Classifier1–62 and identity1–347 are fully read. Classifier1674 and identity130
assertions pass, including actual fresh offline emitted-host execution. Ten exact
labels retain ordering, map keys, JSON/descriptor identity, primary-command and
strict-loader behavior, selector diagnostics and trace spelling. Neutral pinned
Unicode17 regeneration remains806 ranges/9 positives/8 negatives/2 distinct pairs.
The classifier suite checks all endpoints and neutral fixtures, not an exhaustive
fresh scalar census. Negative-isolation1–218 is physically read through its first
complete external AST trust matrix and a partial source-token test; it is excluded
from this execution. .1.51 owns its suffix and native-route consumer. Earlier
adjacent-grammar findings remain open. Exact replay: [[julia-source-value-authority-reading]].

## September 11 — negative and native route consumer reading .1.51

Negative219–456 and routes1–163 complete both consumers. Exact eight-invalid
label matrices cover four declaration/edge roles, programmatic/reconstructed
trust and five validation/artifact attempts. The completed source-token tests
preserve legitimate colon/newline syntax boundaries; invalid selector identities
and path-redacted loader/primary errors remain exact. Adjacent function, action,
lifecycle, mark, regex and bounded-mode grammars keep separate policies. They do
not close the already measured identifier-terminal-LF or fluent lexical gaps.
Classifier1674, native routes81 and negative1946 pass3701 assertions. All identity
consumer source was read in .1.50; its130 assertions are not repeated here.
Neutral Unicode806/9/8/2 passes. Replay: [[write-vivification-julia-runtime]] .1.51.
