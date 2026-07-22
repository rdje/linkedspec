---
id: julia-unicode-rule-label-preflight
title: Julia host regex labels diverge from pinned Unicode 17 and external AST routes bypass membership checks
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
date: 2026-07-22
status: current
tags: [julia, unicode, rule-labels, parser, validation, generated-source, semantic-introspection]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.6.0; docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/unicode_rule_label_contract.json; julia/src/spec/Parser.jl; julia/src/spec/Validator.jl; julia/src/spec/Ast.jl; julia/src/compiler/CompiledSpec.jl; julia/src/source/SourceEmitter.jl
reverify: "python3 tools/check_unicode_rule_label_contract.py; rg -n '_HEADER_PATTERN|_BODY_HEADER_PATTERN|_ACTION_PATTERN|_BLIND_PATTERN|_BARE_EDGE_PATTERN|validate_spec' julia/src/spec; /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'using PCRE2_jll; for (n,c) in ((\"PCRE2\",UInt32(11)),(\"Unicode\",UInt32(10))); b=zeros(UInt8,64); ccall((:pcre2_config_8,libpcre2_8),Cint,(UInt32,Ref{UInt8}),c,b); println(n,\"=\",unsafe_string(pointer(b))); end'"
---

Julia does not yet implement ADR `0051` even though several familiar Unicode labels happen to work. Every native
label-bearing parser route uses host PCRE2 `\w`: `_HEADER_PATTERN`, `_BODY_HEADER_PATTERN`, `_ACTION_PATTERN`,
`_BLIND_PATTERN`, and `_BARE_EDGE_PATTERN` in `julia/src/spec/Parser.jl`. The measured Julia 1.12.6 runtime uses
PCRE2 10.47 (2025-10-21) with Unicode tables 16.0.0, while the repository contract pins Unicode 17.0.0
`XID_Continue` at every label position.

An exhaustive scalar census against the contract's 806 maximally merged ranges found two independent drifts:

- host `^\w+$` rejects 5,175 scalars required by pinned `XID_Continue`; the first include U+00B7 MIDDLE DOT,
  U+0387, U+088F, and multiple combining marks;
- host `^\w+$` accepts 923 scalars forbidden by pinned `XID_Continue`; the first include U+00B2, U+00B3, U+00B9,
  U+00BC, U+00BD, and U+00BE.

The exact nine-positive fixture probe accepts eight and rejects required label `A·B`. `Töp`, decomposed `Töp`,
Greek, CJK, and supplementary labels work only because the current host table happens to include them. Conversely,
forbidden source label `²` parses, validates, compiles, and can be selected explicitly. The colon negative exposes
prefix truncation: embedding label fixture `Top:` as a declaration produces `Top:::` and the parser accepts `Top`
instead of rejecting the complete token.

The validator currently checks duplicate labels, target existence, function collisions, and structural rules, but
does not apply one complete-label membership predicate to declarations and references. Programmatic or
JSON-reconstructed ASTs therefore bypass parser membership entirely. Exact mutation probes accepted forbidden
`Top-Rule` and parser-rejected-but-required `A·B` in action, blind, and bare target roles through validation,
compilation, descriptor projection, generated-plan construction, and emitted-source generation.

The prerequisite is one generated Julia classifier/scanner from the pinned 806 ranges, consumed at all five parser
sites and at the authoritative validator boundary for parsed, programmatic, and reconstructed declarations and
targets. It must reject invalid suffixes instead of accepting a valid prefix, preserve exact case- and
normalization-sensitive scalar identity through compiled/descriptor/generated/emitted/selector/diagnostic/trace/
loader/primary routes, and leave unrelated function, parameter, helper, lifecycle, fluent, and mark identifier
grammars unchanged. Julia semantic construction and the `Töp` privacy fixture cannot be admitted before that route
closure, and the Unicode prerequisite itself must not promote semantic rollout/admission.

Leaf `.10.6.1.0` freezes the implementation so later code is mechanical. The existing pinned-data generator gains
only `--julia-output`, targeting internal `julia/src/spec/UnicodeRuleLabel.jl`; the neutral JSON, Unicode version,
806 ranges, 9/8/2 fixtures, and original contract owner do not change. The generated artifact carries exact
contract/version/hash/range-count metadata, binary-search integer/scalar membership, nonempty complete-label
validation, and a longest-prefix scan based on Julia character indices/`nextind`. `LinkedSpecJulia.jl` includes it
before `Parser.jl`; it is not a new public API. The independent checker regenerates and byte-compares it, extracts
all 806 endpoints, locks the algorithm/integration markers, and requires its tests and CI registration.

Parser routing replaces only the five label-bearing patterns. Header parsing and body-header termination share one
complete header-field scanner with explicit third-colon rejection. Action, blind, and bare target lists share
scalar-safe label-at-offset, optional-index, delimiter, and remainder helpers; malformed arrow spellings remain raw
syntax instead of producing a partial edge. Validator routing adds one `_check_rule_labels` immediately after the
nonempty-spec check in both traced and untraced paths. It validates every declaration plus action, blind, and bare
target and returns portable `invalid_rule_label` / `validate_rule_labels` evidence. Regex, lifecycle, split/mark,
conditional, fluent, bounded-mode, function-shell, and ActionParser identifier patterns stay independently owned.

The dependency order is exact: `.10.6.1.1` generates/routes the classifier and adds classifier/native route tests;
`.2` drives the ten unique identities represented by all nine positives and both distinct pairs through AST,
compiled maps/order/JSON, descriptor, generated plan/direct execution, reconstructed state, independently emitted
host, selectors, diagnostics, traces, strict loader, and inline/file primary commands; `.3` drives all eight
negatives through four declaration/target roles from both programmatic and reconstructed ASTs, whole-token and
no-prefix source/primary failures, newline behavior, and unrelated identifier isolation; `.4` composes complete
Julia/canonical proof and closes without semantic promotion. The exact complete commands are
`tools/run_julia_local.sh`, `tools/run_primary_cli_matrix.sh`, the Unicode/semantic/generated/public checkers,
mdBook/doctrines, and `tools/run_ci_local.sh`.
