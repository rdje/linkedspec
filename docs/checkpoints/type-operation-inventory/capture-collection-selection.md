# Read-only capture collection result selection

Owner: TYPE-REFERENCE-BOOK.1.2.23.1.5; implementation family23.3.25.
Status: frozen bounded ordinary target; Perl25.1/Rust25.2/Dart25.3/Julia25.4 implemented/targeted-checked, safe Lua25.5 next; complete admission remains23.4.

## Existing authority and scope

The helper catalog and typed source contract already define entry_groups() and
match_groups() as compacted capture Arrays, and entry_map()/match_map() as named
capture Hash snapshots. Entry and local registers are distinct. Existing accepted
entry_named_map()/match_named_map() compatibility aliases retain their ownership;
they do not become new primary helpers or receiver methods.

Computed-selection24 deliberately excluded context helpers. This target admits
only these existing zero-argument collection producers as ordinary read sources.
It adds no helper, type, capture operation, cursor behavior or callback right.
The existing helper signatures, missing/empty capture rules, String kinds,
compaction, copying and entry/local identity remain authoritative.

## Frozen bounded behavior

- entry_groups()[-1].uppercase() selects the final captured String; quoted keys
  select named fields from entry_map()/match_map(). Existing compatible methods
  and repeated bracket/method transitions consume the actual selected kind.
- Preserve String "0", empty captured text and missing values without coercing
  captures to Bool/Number. Keep the producer's existing empty/compaction rules.
- Reuse existing whole signed Array positions and quoted Hash-key classification.
  Missing/wrong-kind/out-of-range reads yield null without creating storage.
  Dynamic-key, fractional/String-index and unrelated coercion policies do not move.
- Evaluate the collection once, then selectors left-to-right once, including
  remaining selectors after a missing path. Keep existing source snapshots and
  error propagation. Incompatible container consumers reject before operands.
- Known helper ownership wins over same-named variables; unknown bound-call
  readers, values, coercions and raw markers stay unchanged. Use static source
  ownership, never runtime value kinds to decide whether a call is a helper.
- Preserve named binding readers, source spans, context/register reads, grouping,
  write/mutation targets and copying depth. No parser-state/cursor/control helper
  allowlist is inferred beyond these collection sources.
- Explicit and registered contextual callbacks retain their deferred vocabulary.
  Repair prerequisite25.0 before adding source names; this feature does not make
  value_access executable in Perl's CodeblockRuntime.
- Reuse existing AST fields and lowerer/readers. No serialized field, readiness
  waiver, provider/submodule assumption or generated-format change is authorized.

The shared capture_collection_selection_values.spec/json is the independent
ordinary target: entry/local divergence, direct producers/aliases, signed/missing
reads, ordered missing selectors, actual-kind guards, bridges and unchanged
collections on input `name=Alpha`. Perl advances first; Rust/Dart/Julia/safe Lua assess independently.
Each bounded child uses small native/generated/direct checks and commits. Complete
source/domain/context/portable/generated/canonical admission remains23.4.

## Public intake and corrected teaching

capture-collection-selection-intake.json retains six public native/fresh cases.
Producers, named readers, existing fluent methods, copy bridges and compatibility
aliases agree with their expected values and are raw0/unresolved0/ready1. Direct
four-helper postfix selection instead fails native child-handler/fresh-source
compilation; its descriptor retains raw4/unresolved0/ready0. Native [null] is a
failed child handler here, not a successful missing-field read. Substitution shows
the capture getter lowered to do {...} while its raw bracket suffix remains.

The first probe reused the older AND-child teaching and all controls returned
[null]. The retained entry-mode control and scoped runtime trace show why: the
parent has consumed `name`, then an AND child starts its required slot0 at cursor4.
ADR0044 requires the child's own policy at that cursor. A default/seeking child
correctly reads the later local slots. Three actual book examples are corrected
and execute native/fresh; the July8 fact is explicitly superseded for current use.
The helper catalog's retired-alias wording is also corrected against accepted
source-boundary authority and actual alias controls. No runtime cursor change.

## Contextual callback preservation prerequisite

contextual-selection-boundary-intake.json compares two expressions across three
already-admitted callback spellings. Explicit literals retain
unsupported_codeblock_actionir/raw_perl, raw1 and ready0. Attached/parenthesized
registered final blocks instead carry unsupported value_access, raw0 and ready1.
Their existing registry fence removes registered names only; helpers/noncall
computed reads still pass.25.0 must restore the explicit-literal grammar/error/
metadata boundary using the actual final-slot signature/count owner, while keeping
ordinary arguments and immediate/inline helpers supported. This is a P1 repair,
not admission of a new deferred operation. Full callback/context proof remains23.4.


## Bounded Perl implementation

Preservation25.0 restores the registered callback grammar before source expansion.
Perl25.1 recognizes only the six existing capture collection names through its
static known-helper owner, then reuses the current typed reader and kind guards.
The unchanged shared fixture and finite String/empty/compaction/static-name/no-
local-capture/span/deferred controls pass on native/fresh routes with typed ready
metadata. No getter/cursor/schema/evaluator change or wider context classification.
Independent backend work and complete source/context admission remain separate.


## Bounded Rust implementation

Rust25.2 already parses the existing helper calls and selection fields. Extending
only the static computed-source result guard to those six boxed collection names
prevents incompatible operands and legacy count fallthrough. The frozen target,
alias/with guard controls, String zero/empty/compaction/static names and absent-
capture versus bound/context/flat count controls pass native/restored/plan. No
parser/getter/read/serde field or standalone emitted-source admission changes.


## Bounded Dart implementation

Dart25.3 likewise reuses its existing parser, unmodifiable capture getters and
readers. Four canonical collection names join _isOrdinaryComputedRead; the
existing canonical alias owner supplies both named-map aliases. Persistent
actual-kind guards then cover wrong consumers and with/bridges. Four capture
cases and seven direct computed cases pass native/restoredSpec/generated plan;
format/fatal analyze pass. No schema, getter or standalone source admission.


## Bounded Julia implementation

Julia25.4 independently confirms the same classifier boundary. Four canonical
capture sources reuse existing alias normalization and actual-kind guarding
through with/bridges. New strict capture12 and direct computed25 pass native,
generated plan and freshly loaded emitted module. Named capture stores, readers,
parser, compiled representation and deferred vocabulary remain unchanged.
