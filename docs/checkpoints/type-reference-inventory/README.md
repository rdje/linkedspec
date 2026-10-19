# Authority population and value model — October19

Owner: `TYPE-REFERENCE-BOOK.1.2.0`. This is the authority/model prerequisite;
complete operation/spelling enumeration and book mapping remain `.1.2.1`/`.1.2.2`.
Current readonly entrypoint: `bash tools/run_python_project_data.sh docs/checkpoints/type-reference-inventory/publish.py`.
One-shot preservation/capture/document producers are never resume commands.

## Source authority ledger

`source-inputs.json.gz` retains 1300 owned source/contract/test/book inputs with
bytes, SHA-256, filesystem modes and accepted Git identities before commands.
The collector records its explicit selection: owned Perl and native backend
source/tests, neutral contracts/fixtures, tools, nonhistorical `.spec` inputs,
decision records, complete book/config and recursive tracked includes. This is
a conservative custody population, not a full-reading audit or operation count.
Submodule and other-repository implementations are excluded. OS Perl and mdBook
are read-only external prerequisites, not project-owned source authorities.

| Question | Canonical authority | Role and limits |
| --- | --- | --- |
| One identifier, current kinds, constructors/mutation | `capability_conformance/uniform_binding_contract.json` | One observable binding; scalar/array/harray/codeblock. Host sigils/storage are not public namespaces. |
| Strings, boolean/null normalization | `capability_conformance/scalar_text_contract.json`; ADR0028 | Scalar text accepts contracted primitives, propagates null for unsupported values. Not all scalar operations accept every primitive. |
| Integer/real inputs and numeric results | `capability_conformance/scalar_numeric_contract.json`; ADR0029 | Finite numeric/decimal-string normalization; rejects boolean/null/containers/codeblocks. Numeric comparison 1/0 is distinct from logical boolean. |
| Logical boolean kind | `capability_conformance/logical_helper_contract.json` | Keep boolean identity distinct from numeric equality in the reviewer. |
| Codeblock literal, dynamic caller, copied parameters | `capability_conformance/callable_codeblock_contract.json`; ADR0031 | Deferred plain-data literal; eager expression block is separate. Public execution reveals defects beyond fixture coverage. |
| Signatures/final callback | `capability_conformance/callable_signature_contract.json`; ADR0030/0032; `perl/LinkedSpec/CallableContract.pm` | Named functions and invocation are not receiver methods; typed final callback says value kind, not its signature. |
| Actual current vocabulary/classification | `tools/check_language_capability_coverage.pl`; native registries; `perl/LinkedSpec/RuleIR/EmitContext.pm` | Strict and report modes both captured. Current 250 shared call names; 105 neutral corpus sources plus exact named-mark source; 126 independently derived public generic Perl contracts covered. Presence is not semantic execution or complete operation coverage. |
| Current grammar and descriptions | `docs/linkedspec-book/src/appendix/formal-grammar.md`, `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`, value/reference chapters | Public explanatory source, reconciled with contracts and observed behavior. Book-wide mapping still pending. |
| Private and historical names | Checker non-generic classification; progressive/staged contracts; dated KMap cards | Private dispatch/intrinsics, compatibility maps, dedicated annotations and assignments have distinct roles. Name discovery grants no public generic helper. July4 aliases and old gap counts are dated. |

`vocabulary.json` records both actual command channels. The strict command passes;
the report command's successful exit alone would not reject missing rows. Neither
establishes per-type documentation depth or cross-backend semantic parity.

## Reconciled value model

Scalars include distinct string, number, boolean and null values. Integer/real
notation does not establish separate binding namespaces or method tables. Arrays
and harrays are containers; codeblocks are deferred callable values. One binding
can be rebound across these kinds. An eager block executes during evaluation;
a deferred literal reads current caller slots when invoked. Receiver operations
on a call or eager block use the result's kind. There is no demonstrated separate
codeblock dot-method family. `cb.sorted()` returning an empty array is not proof
of one, nor of a universal wrong-kind error rule.

The initial 14 cases retain descriptor metadata, live parser values, independent
generated parser values/source, warnings, module inventory and Perl version.
They include exact unchanged scalar-text/numeric neutral fixture sources. Every
route has zero recorded canonical fallback; that metric alone misses the scoped
unsupported-call defect below. Boolean `false.cat("q")` yields `"0q"` and generic
`false.with()` preserves false; the July4 blanket terminal assertion is obsolete.

## Owned defects, distinguishing controls and repair schedule

Both defects are observed through Get and separately loaded generated source,
not inferred from a failed documentation grep. `distinguish-inputs.json.gz` and
`distinguish-run.json.gz` preserve all 11 follow-up cases without refreshing the
initial model observations. Source inputs stayed unchanged throughout.

1. **P1 `.1.2.3`, immediately after `.1.2.0`: early scalar values change during later calls.**
   `[marker, cb(), marker]` yields three `"inside"` values when `cb` rebinds marker.
   `array(...)` and codeblock arguments share this behavior. A scalar rvalue,
   separate saved binding and registered named-function arguments retain `"before"`.
   Emitted source puts `$marker` directly on Perl's list stack around `invoke`;
   the array-literal and codeblock-argument lowerers join expressions without
   per-value temporaries, unlike named-function arguments. Repair the evaluated
   value boundary without changing deliberate shared container mutation or caller
   slot semantics; expand scope only from distinguishing observations.
2. **P1 `.1.2.4`, next: attached `with` drops callable scoped `value`.**
   `cb.with() { return(value()) }` silently returns null with zero fallback.
   Emitted source creates `my $value` then uses the unsupported-helper sentinel.
   `lower_ast_with_trailing_block_call_node` lowers the attached body using the
   original dependency vocabulary, while `_codeblock_variable_call_candidate`
   requires the scalar-kind projection. Copying to a named binding, calling the
   outer name, or using an explicit `callback`/`value` parameter returns `"yes"`.
   Repair scoped dependency projection, preserve helper/function precedence and
   nested scope, and check current unsupported-call diagnostics independently.

These are uncorrected behavior observations, not acceptance expectations. The
repair leaves require RED/GREEN and canonical proof before runtime landing.
Known earlier receiver guards/boolean-literal defects retain their own owners;
this inventory does not reopen or close them. Deferred metadata rendering QA and
legacy task contradictions remain scheduled. No method completeness, backend
parity, private/parent admission or runtime fix is claimed here.

## Continuity

`preservation.json.gz` and `baseline.json` precede intersecting writes and preserve
whole accepted migration396/full68960 with all live guards. Only that claim is
frozen, by mode/revision at real accepted `cf4dceccd24bc6642fc9c7d8d10b329e136849b6`.
`replay_migrations.py` restores the whole original live target, all396 inputs and
nested materialized graph from accepted bytes; the unchanged original publisher
reproduces exact channels without changing supplied source bytes or modes.
Original native and failed instruments remain immutable. Current documentation
proposals and later independent current graph/book checks are separate epochs.
