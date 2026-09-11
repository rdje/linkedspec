---
id: julia-semantic-call-core-projection
title: Julia retains the exact private typed call core before staged artifact completion
answers:
  - "does Julia implement the private semantic call core"
  - "where is the Julia semantic call core implemented"
  - "how many records and relations are in the Julia typed call core"
  - "which Julia semantic records are in the typed call core"
  - "which Julia semantic relations are in the typed call core"
  - "how does Julia merge function and rule authored call order"
  - "how does Julia verify retained staged function body_ast"
  - "how does Julia correlate typed calls to authored source"
  - "does Julia semantic call scanning skip strings"
  - "does Julia semantic call scanning skip regex literals"
  - "how are nested Julia semantic calls ordered"
  - "does Julia resolve user functions before helpers"
  - "which Julia semantic helpers are governed"
  - "how does Julia infer call and binding shapes"
  - "does the Julia typed call core include staged artifacts"
  - "is the Julia typed call core public"
  - "does Julia typed call projection execute target code"
  - "what Julia semantic call task followed the typed core"
date: 2026-07-22
status: current
tags: [julia, semantic-introspection, actionir, calls, bindings, source-correlation, privacy]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.6.4.1; julia/src/semantic/SemanticCallProjection.jl; julia/src/semantic/SemanticStaticProjection.jl; julia/src/semantic/SemanticCompilationOutcome.jl; julia/src/action/ActionAst.jl; julia/src/action/ActionParser.jl; julia/src/action/ActionContracts.jl; julia/src/action/FunctionRegistry.jl; julia/src/parser/StagedParserRegistry.jl; julia/test/semantic_index_call_core_test.jl; capability_conformance/semantic_introspection_model.json snapshot calls
reverify: "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py; bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test, JSON3; include(\"julia/test/semantic_index_source_foundation_test.jl\"); include(\"julia/test/semantic_index_compilation_foundation_test.jl\"); include(\"julia/test/semantic_index_static_graph_test.jl\"); include(\"julia/test/semantic_index_static_remaining_test.jl\"); include(\"julia/test/semantic_index_call_core_test.jl\")'; rg -n '_semantic_call_extend_core|semantic_call_records|semantic_call_relations|semantic_call_regex_start|resolve_action_block_contracts' julia/src/semantic/SemanticCallProjection.jl julia/test/semantic_index_call_core_test.jl"
---

Julia's `.10.6.4.1` call projection is an additive private extension of the already-retained semantic graph. The
static projector calls `_semantic_call_extend_core!` before its one canonicalize-and-freeze boundary. The exact
`calls_and_staging` non-staged target is 18 records / 16 relations: one spec, one source, two rules, one regex slot,
one edge, one function, three helpers, one binding, and four calls, with their containment, reference, resolution,
read, and write relations. Staged payload/job/result and generated handler-plan records are deliberately absent
until `.10.6.4.2`.

The projector uses typed authorities throughout. It merges function shells with compiled rules by exact authored
source start. For each function, it reparses only the already-retained body payload as an `ActionBlock`, requires
its JSON form to equal the staged registry's retained `body_ast`, and resolves contracts against the accepted user
function registry. Compiled edge `action_ast` supplies typed edge calls and bindings directly. No caller target,
generated target, trace channel, runtime observer, loader, or emitter is invoked.

Typed traversal is deterministic: statements retain authored order, an outer call precedes nested argument calls,
call ids are local to each owner, and the record order is global across owners. An occurrence-safe scanner searches
only the bounded raw function shell or edge member. It balances parentheses and skips escaped quoted strings plus
context-valid regex literals, so text such as `/trim(fake())/i` cannot steal the source occurrence belonging to a
real `trim(value)` call. Exact ranges are reproduced through the retained byte/scalar source map.

Resolution checks an exact registered user function before the neutral helper table. The governed helpers are only
`trim`, `match_text`, and action-edge `return`, with exact fixed signatures, effects, and return shapes. Function
signatures cover both fixed arity and retained variadic `CallableSignature` rest parameters. A conservative fixed
point propagates literal, binding, user-return, and helper shapes; unsupported cases remain `unknown` rather than
being guessed. Binding reads and writes become explicit relations.

The private proof seam returns fresh detached JSON-compatible values while the owner remains tuple-backed and
opaque. New proof is 79 assertions and the five-suite source/outcome/static/call composition is 468. Complete Julia
is 8,010/primary/105; primary 5x2x66, all ten Unicode legs, unchanged governance ledgers, and canonical local CI
pass. mdBook/KM 685/5,252 and exact 1,618,660-KiB cleanup preserving 517 Pgen artifacts pass. No public semantic
record/query accessor or backend admission exists yet. `.10.6.4.2` now extends this same owner with normalized
staged artifacts and the selected generated plan to the complete 22-record / 25-relation target; `.10.6.4.3` is
the next no-change composition task.

See [[julia-semantic-call-staged-projection-plan]], [[julia-semantic-introspection-authority-map]],
[[semantic-introspection-staged-artifact-schema]], and [[semantic-introspection-neutral-contract]].

## September 11 complete call-core consumer reading (.1.44)

All408 source lines are read and79 existing assertions pass. Filtering staged/
generated records and materializing source references yields the exact18/16
neutral target; current full projection retains the separate four-record/nine-
relation addition. Tests preserve authored/outer-before-inner occurrence order,
Unicode bytes versus scalar columns, conservative rest shapes, detached copies,
immutable tuple owners and private API boundaries. Static forbidden-token checks
are source guards, not dynamic instrumentation of every possible execution path.

The assigned `/trim(fake())/i` fixture proves its tested lexical context. Earlier
general regex-skipping claims are qualified by the grouped/whitespace source
correlation counterexamples in [[julia-semantic-regex-call-source-gap]], owned
by .2.15. The passing79 does not close that defect or promote semantic admission.
Staged consumer1–42 only begins reconstruction helpers; its tests remain unread.
Exact main396/core79 and neutral replay: [[julia-full-corpus-gate]], .1.44 above.
