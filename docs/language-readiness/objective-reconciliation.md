# Three bounded language objectives: evidence and authoring costs

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4`, activated from clean
`7c8a240be8f444e314ad415fa9e963045fdd91ec` on 2026-10-01. This reconciles existing
milestones; it adds no runtime behavior, capability admission or new objective.

## What has been established

| Objective | Authored oracle | Established composition | Canonical evidence |
| --- | --- | --- | --- |
| Nesting | 6 accepts / 7 rejects | Advancing rule recursion, parent-local restoration, typed trees and Unicode scalar spans; strict recognition with explicit guards | `docs/language-readiness/nested-tree-native.md`; milestone `.1.1.3.1.2.3` |
| Context names | 11 accepts / 17 rejects | Opening capture, lexical closing-name comparison, recursive name/children/start restoration and grammar-specific typed statuses | `docs/language-readiness/context-names.md`; milestone `.1.1.3.2.7` |
| Lossless extraction / actual child | 13 segmentation cases / 39 segments; standalone child 4 accepts / 15 rejects | Exact item/gap classification and reconstruction, source-bound staged assignment, actual precompiled child grammar, selected authority/accounting denials, bounded provenance and detached results | `docs/language-readiness/lossless-child-parsing.md`; milestone `.1.1.3.3.5` |

The nesting and context cases are strict document probes. The lossless parent is an
extraction probe: malformed candidates deliberately remain gap text. Preserving a
document exactly does not validate its language. Its child recognizes canonical
unsigned decimal lexemes and preserves them as strings; it does not convert them.

The same authored cases are reused on supported carriers. They are not additional
independent inputs, distinct formats or a proof of unrestricted language closure.
Native text-adapter proof is separate from typed carrier proof: Rust's text adapter
uses Display, and all text adapters stop at rejection. The typed retained routes
below establish subsequent success using the existing parser after rejection.

| Runtime | Nesting / context typed routes | Retained parsers | Nesting / context immediate recoveries | Actual-child pairs | Retained pairs | Per-call pairs |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Perl | 2 | 2 | 28 / 68 | 4 | 4 | 0 |
| Rust | 6 | 4 | 56 / 136 | 6 | 4 | 2 |
| Dart | 6 | 4 | 56 / 136 | 6 | 4 | 2 |
| Julia | 5 | 2 | 28 / 68 | 5 | 2 | 3 |
| PUC Lua | 5 | 2 | 28 / 68 | 5 | 2 | 3 |
| LuaJIT | 5 | 2 | 28 / 68 | 5 | 2 | 3 |

Each retained nesting/context parser has two rounds of rejection/immediate-success
pairs, yielding 14/34 transitions. Other routes construct an engine per invocation
and establish isolation. Actual-child pair proof has its own exact failure/success
sequence; this ledger does not invent a comparable transition total. Perl's four
pairs include mixed native/emitted parent/child combinations. Other runtimes cover
matched native/reconstructed/generated/emitted forms as their individual ledgers
enumerate; mixed combinations are not inferred.

Nesting detects prefix/gap/span mutants; context detects comparison/state/span
mutants. Lossless detects four segmentation and three child mutants. Perl runs its
segmentation mutants separately from its four child pairs. Julia and Lua additionally
falsify result-isolation assertions with intentionally aliased returned objects.
No cross-language equality of error wrappers or every resource record is claimed.

## Costs and what gap selection may infer

| Observed cost | Where it occurs | Consequence for `.1.1.4` |
| --- | --- | --- |
| Explicit skipped-prefix handling | Nesting/context reject it; lossless retains it | Shared authoring concern with different required outcomes; do not assume one implicit strictness policy. |
| Explicit gap/final-cursor/missing-close guards | Both strict probes; child entry/end guards | Repeated authoring work, without evidence that the existing language cannot express it. |
| Explicit AST/span construction | 33-line nesting and 37-line context grammars | Predictable typed values; line counts are source descriptions, not usability or speed benchmarks. |
| Limited authored diagnostics | Nesting status 1; context statuses 1/2/3 | Exact typed rejection is proven; useful messages, expected tokens and failure spans require a separate objective. |
| Lifecycle choice matters | 21-line segment grammar / 27-line staged parent use the default loop and LX | OR/LX is not interchangeable. The earlier published example was repaired and its old-mode control recurs. |
| Caller prepares compiled authority and span projection | 21-line child plus frozen registry adapter | Integration boundary; recognition stays in `.spec`. Ambient loading is forbidden. |
| Public staged operands are source-bound | Entry/match/group expressions and admitted ordered composition | Copied strings, gaps and arbitrary spans remain excluded. Private `dispatch_span` is not a public substitute; need for a new operand is unassessed. |

None of these successful finite probes selects a missing primitive. `.1.1.4` must
classify observations against all nine inventoried dimensions, distinguish defects
from language gaps and authoring costs, and schedule requirements before proposing
semantics. Indentation, quoted/escaped text, comments, realistic complete standards,
richer diagnostics, in-document recovery, arbitrary-depth/resource guarantees,
performance and speculative AST/user-state rollback remain unassessed here.

## Repairs keep their owners

The earlier inventory remains authoritative for its repair routing:

- Recognition abort/current-state issues: startup `.38`/`.40`, from the grammar/cursor ledger.
- State/callable/aggregate/result defects: startup `.17`/`.58`/`.59`/`.94`/`.95`
  and Dart `.2.9`, from the state/control/results ledger. Constructor `.1.1.3.1.1`
  and generic-flat `.1.1.6` close their exact repaired cases, not the broad owners.
- Progressive ceilings: startup `.37`; staged target conflicts, returned markers
  and saturated counters: startup `.73`/`.74`/`.75`.
- Dart diagnostic/arithmetic/provenance/SDK owners `.2.17`/`.2.18`/`.2.19`/`.2.25`,
  Julia's copy-mutating consumer `.2.26`, and the Lua provenance/result/resource/
  regex obligations remain as enumerated in the lossless/backend ledgers.
- Stale general parse-mode capability prose: self-containment `.1.1.5`, coordinated
  with startup `.41.2`, before the general manifest becomes closure authority.
- Supplied-policy adoption: startup `.5`/`.29`; October1 donor hashes match the
  recorded September11 comparison. Reading the policies does not close adoption.

These are already scheduled repair obligations, not newly discovered defects or
waivers. The three-objective reconciliation closes only parent `.1.1.3` through
exact staged canonical acceptance. The broader inventory `.1.1`, format campaign
readiness gate and optional EBNF-like profile remain open.

## Verification and limits

Run `bash tools/run_python_project_data.sh tests/language-readiness/verify_objectives.py`.
The tracked read-only audit verifies producing checkpoint blobs, their historical
source identities, latest executable inputs and retained log hashes. Exact owner-bound Rust signed-selector source evolution is reported separately; the original source identities and runtime results stay historical. Fresh Rust nesting/context/lossless parent and emitted consumers provide the separate compatibility check. Successively
updated documentation is recorded separately with both hashes. It enumerates each
original oracle in both directions, independently checks scalar bounds/text slices
and lossless adjacency, and verifies retained recovery arithmetic from authored
reject cases. Corrupted checkpoint/source/log/oracle bytes and outside paths must
reject. Counts and complete enumerations are in the owning checkpoint's audit.

This is fresh evidence-integrity proof over historical runtime executions, not a
fresh six-runtime rerun. No objective is promoted. Each original ledger retains its
runtime commands; changed executable evidence must be rerun before a current claim
can advance. The exact staged canonical receipt and commit body govern this parent
closeout without claiming that optional backend gates all ran.
