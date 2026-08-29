# ADR 0094: Standalone rule blocks normalize directly to lifecycle `I`

- Date: 2026-08-29
- Status: accepted; Perl/Rust implemented under `.15.1`; remaining rollout pending under `.15.2`
- Tags: architecture, grammar, lifecycle, codeblock, parser, source-provenance, portability, parity

## Context

The terse-format direction accepted blocks as a first-class authoring form, and the formal-grammar appendix said a
standalone `{ ... }` block was rule lifecycle code. The executable implementations did not support that statement
consistently:

- the Perl reference validator rejects a rule-item-leading block as `Unsupported top-level rule paragraph
  content`; its bootstrap brace scanner balances the text but emits no lifecycle entry;
- Rust, Dart, Julia, and Lua source parsers create a distinct `PlainBlock` body node, but Rust drops it during
  compilation and the other three retain only inert `plain_action_payloads` metadata that no runtime executes;
- `specs/spec.spec` has no standalone-block production and currently classifies an explicit line-start
  `I { ... }` as a bare edge in direct self-hosted output because its generic bare-edge block also matches the
  reserved lifecycle label; and
- Rust stores each lifecycle role in one optional compiled slot, so a later explicit `I` replaces an earlier one,
  while Perl joins repeated lifecycle chunks and Dart, Julia, and Lua execute ordered payload lists.

Therefore there is no current portable or reference-backed standalone lifecycle behavior. The four native
`PlainBlock` types are parser-ahead compatibility data, not proof of an implemented language feature. The book's
unqualified current-tense statement was ahead of the code and is corrected in the decision slice.

## Decision

### 1. A rule-item-leading block is shorthand for `I`, not a new lifecycle

At a rule-body item boundary, a balanced block beginning with `{` is accepted wherever the explicit twin
`I { ... }` is accepted. Source parsing immediately produces the existing lifecycle code-block semantic shape
with marker `I` and the same interior code. It must not survive source parsing as `PlainBlock`, acquire a new
runtime phase, or enter `plain_action_payloads`.

Normalization retains actual authorship rather than fabricating source bytes. The body element keeps the bare
block's exact authored source and the one-based line of its opening brace. Its code field is the exact interior
that the explicit twin would pass to ActionIR. Existing ActionIR statement/expression spans remain relative to that
interior; a synthetic semantic marker has no source span. Semantic equivalence therefore compares lifecycle kind,
marker, and code, while provenance continues to distinguish `{ ... }` from `I { ... }`.

### 2. Ownership is decided before the shorthand

The shorthand applies only when `{` begins a new rule-body item. Earlier or already-entered constructs retain
their braces:

- `-> Child { ... }` remains an action-edge suffix owned by that edge;
- `=> Child { ... }` and a resolved bare child edge keep their existing edge ownership;
- `fn name(...) { ... }` remains a top-level function body;
- contextual callable blocks such as `with(value) { ... }` and `{|params| ... }` remain call/expression values;
- braces inside lifecycle/action code remain nested control, value, hash, or expression blocks; and
- quoted braces remain text under the existing balanced, string-aware scanners.

Edge and lifecycle recognition retain precedence over generic brace recognition. Reserved lifecycle labels must
also be excluded from self-hosted bare-edge matching so `I { ... }` remains lifecycle syntax.

### 3. Placement and duplicates inherit the explicit twin

Normalization occurs at the exact authored body position. OR/AND family and zero-, one-, or two-regex structure
do not change recognition: replace each shorthand with `I` at that same position to obtain its semantic twin.
This preserves the Perl reference's established placement-sensitive lowering rather than redesigning lifecycle
placement inside an alias leaf.

More than one `I` block is legal. Explicit and shorthand `I` blocks participate in authored order, and a shorthand
does not overwrite an earlier explicit block or vice versa. Rust's current last-slot-wins behavior is an existing
duplicate-lifecycle defect and is repaired in `.15.1`; the repair is limited to preserving ordered explicit/shorthand
payloads and does not reopen the wider lifecycle handler-shape caveat governed by ADR `0020`.

### 4. Malformed syntax follows the explicit-twin diagnostic

An empty balanced block is valid. Nested braces and quoted braces use the same scanner as explicit `I`. A missing
closing brace, unmatched closing brace, or unsupported remainder after a balanced block fails at the same parser/
validation boundary with the same diagnostic code, stage, fields, and opening line as the explicit twin, allowing
only the inevitable source-column difference caused by the absent `I` marker. No separate permissive recovery or
plain-block runtime fallback is added.

### 5. Dormant plain nodes stay inert compatibility data

Existing Rust/Dart/Julia/Lua `PlainBlock` AST variants and Dart/Julia/Lua compiled `plain_action_payloads` may
remain readable for programmatic or serialized compatibility during this rollout, but source parsers stop emitting
them and runtimes do not begin executing them. Removing or assigning semantics to those legacy carrier fields
would be a separate versioned migration. New parsed, reconstructed, emitted, and generated artifacts represent
the shorthand through the existing lifecycle `I` path.

## Consequences

- `.15.1` implements the Perl/Rust normalization and Rust duplicate-order repair with explicit/bare twin tests.
- `.15.2` aligns Dart, Julia, shared Lua on both ABIs, the self-hosted grammar, available generated carriers,
  capability/public docs, and final no-drift.
- The language gains syntactic economy without a second runtime phase or a new public semantic AST kind.
- Action/blind ownership, callable blocks, nested block semantics, explicit `I`, and historical Perl lifecycle
  placement remain unchanged.
- Perl and Rust accept the shorthand after `.15.1`; authors targeting every backend must continue to write
  `I { ... }` until `.15.2` aligns Dart, Julia, Lua, and the self-hosted grammar.

## Links

- Owning task: `docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md` (`FUTURE-PARITY-BACKLOG.15.0-.2`)
- Audit fact: `docs/knowledge/standalone-lifecycle-block-audit.md`
- Lifecycle placement caveat: ADR `0020`
- Reserved lifecycle precedence and edge ownership: ADR `0044`
- Typed span model: ADR `0056`
- Terse direction: ADR `0007`
