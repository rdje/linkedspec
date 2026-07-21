# 0051 - Rule labels use pinned Unicode 17 XID_Continue scalars

- Date: 2026-07-21
- Status: accepted; Rust implemented
- Tags: architecture, grammar, unicode, identifiers, rust, validation, generated-data, portability, parity

## Context

The accepted semantic-introspection v1 privacy fixture and admitted Perl implementation use the rule label `Töp`.
The published grammar nevertheless described labels as ASCII `[A-Za-z0-9_]+`, and Rust implemented its rule-header,
action-edge, blind-call, and bare-edge scanners with project-ASCII `\w+`. Rust therefore rejected the accepted
fixture before validation or semantic projection.

Silently inheriting a host regex engine's `\w` is not a stable language contract. Its Unicode membership depends
on engine flags, engine version, and Unicode data version. Requiring identifier-start syntax would also narrow the
existing contract, which permits ASCII digits and `_` at the first position. The project already pins verified
Unicode 17.0.0 `DerivedCoreProperties.txt` for exact, offline, generated behavior under ADR `0027`.

The director selected Unicode expansion rather than revising the admitted v1 fixture and response digests.

## Decision

1. A rule label is a nonempty sequence of Unicode 17.0.0 `XID_Continue` scalar values. The same class applies at
   every position, including the first, so every formerly valid ASCII `[A-Za-z0-9_]+` label remains valid.
2. The class is pinned to the repository's verified Unicode 17 `DerivedCoreProperties.txt`; host `\w`, locale,
   PCRE tables, and toolchain Unicode versions are not semantic authorities.
3. Label identity is the exact decoded Unicode scalar sequence. Comparison is case-sensitive and
   normalization-sensitive. LinkedSpec performs no NFC/NFD/NFKC normalization and no case conversion or folding;
   for example, `Töp`, `To\u{0308}p`, and `töp` are three distinct labels.
4. Source and CLI boundaries remain strict UTF-8. Invalid UTF-8 is rejected by the existing loader/primary owners
   before label scanning.
5. The policy applies identically to rule declarations, action-edge targets, blind-call targets, bare-edge targets,
   explicit entry selectors, compiled labels, descriptors, generated plans/source, diagnostics, and trace identity.
   Selectors and later typed artifacts compare exact strings and must not reinterpret or normalize labels.
6. Rust consumes one generated range table and classifier in `linkedspec-core`. Parsed and externally constructed
   ASTs are both validated against the same classifier. A deterministic contract checker regenerates and
   byte-compares the neutral inventory and Rust table, tests positive/negative/equality fixtures, and guards the
   published grammar.
7. This prerequisite does not create a semantic-introspection API or advance its rollout/admission ledgers.
   Exhaustive native semantic projection remains owned by `.10.4.1-.10.4.6`.

## Consequences

- The admitted `Töp` fixture becomes valid Rust source without changing its bytes, model, ids, or response digests.
- Combining marks and other Unicode 17 `XID_Continue` scalars are legal. Emoji, whitespace, hyphen, slash, colon,
  and other non-members remain delimiters or invalid label content.
- Canonically equivalent spellings may coexist as distinct labels. This is deliberate and avoids invisible source
  rewriting; authors who want normalized identity must spell labels consistently.
- Unicode upgrades are explicit contract changes with regenerated ranges and reviewed fixture deltas.
- Other backend scanners must consume or prove this exact universal policy before a future recurring label-syntax
  admission can claim exhaustive cross-backend membership parity.

## Links

- Task owner: `FUTURE-PARITY-BACKLOG.10.4.0.2`
- Accepted semantic model: ADR `0049`
- Pinned Unicode inputs and no-normalization precedent: ADR `0027`
- Strict UTF-8 boundaries: ADRs `0025` and `0026`
- Neutral fixture: `capability_conformance/semantic_introspection/privacy.spec`
