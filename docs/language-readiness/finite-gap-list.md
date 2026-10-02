# Finite language-readiness gap list

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4`, activated from clean
`f84d794fb18475cb78d5fbd4aec3e37e57514b88` on 2026-10-01.
This classifies the two inventories and three bounded probes. It changes no
semantic contract, capability admission, runtime or repair priority.

## Evidence and classification

The source-located foundations are [grammar/cursor/capture](grammar-cursor-capture.md)
and [state/control/results](state-control-results.md). The current composed evidence
is [the three-objective reconciliation](objective-reconciliation.md), with its
exact runtime/carrier/recovery boundaries and source/log audit. Earlier inventories
describe their measurement date; their then-unassessed nesting, context-name and
lossless objectives now have that bounded proof. Indentation remains unassessed.

**Implemented** means an existing contract or bounded objective has evidence within
its recorded scope. **Partial** identifies a narrower implementation/proof defect.
**Missing** requires a demonstrated absent feature against an agreed requirement.
**Compatibility-only**, **backend-host** and **forbidden** retain the inventories'
portable/authority boundaries. **Unassessed** is a separate requirement status.
Explicit authoring work can accompany an implemented mechanism; it is not evidence
that a primitive is missing. A green capability census is not a zero-defect census.

## Nine areas and their next use

All contracts below are under `capability_conformance/`. Backend consumer locations
and historical admission are in the two inventories; this slice adds no backend run.

| Area | Implemented evidence / exact authority | Finite limitation and classification | Next owner |
| --- | --- | --- | --- |
| Grammar | `root_rule_selection_contract.json`; both strict probes select and link rules | Implemented entry selection; explicit selection does not itself match the root regex. Whole standards remain unassessed. | `.1.2` preserves this boundary; `.1.3` covers exact entry/rejection. |
| Recursion | `recognition_transaction_contract.json`; nesting/context advance and restore parent-local state | Implemented advancing rule recursion. Function/callback recursion is outside current contracts; unrestricted depth, left recursion and automatic speculative user-state rollback are unassessed requirements. | `.1.2` states exclusions/progress; `.1.3` tests selected cycles. |
| Cursor | `rule_local_cursor_contract.json`; strict prefix/gap/end guards in both probes | Implemented intrinsic family policy; partial abort/obsolete-token implementation and stale general description below. Repeated guards are an authoring cost. | Existing repair owners; `.1.2` separates recognition and user state. |
| Capture | `typed_source_location_contract.json`, `inter_match_gap_capture_contract.json`; original scalar spans and lossless reconstruction | Implemented source-bound capture. Public staged operands exclude copied text, gaps and arbitrary spans; need for an additional operand is unassessed. | `.1.2` records authority; `.1.3` preserves source-bound negative controls. |
| State | `uniform_binding_contract.json`; recursive name/children/start restoration | Implemented typed bindings and bounded authored restoration; partial Perl host-slot isolation below. No general automatic AST/user-state rollback claim. | Existing `.17`; `.1.2` scopes mutation/failure effects. |
| Callable | `callable_signature_contract.json`, `callable_codeblock_contract.json` | Implemented positional/final-rest calls and deferred blocks with distinct scope. Missing named fixed-parameter binding is approved direction but parked; defaults, lexical closures and recursive calls are not selected extensions. | `PARSER-AUTHORING-APIS.4`; `.1.2` retains current callable boundaries. |
| Control | `logical_helper_contract.json`; loops/branches compose the bounded probes | Implemented selected controls versus eager helpers; partial Dart mixed-control boundary below. Arbitrary control combinations remain unassessed. | Existing Dart `.2.9`; `.1.3` selects independent composition controls. |
| Transformation | `write_vivification_contract.json`, `map_leaves_mutation_contract.json` | Admitted typed writes/root-kind leaf mutation; partial guard/substitution below. These three probes do not establish a realistic mixed-tree transformation objective. | Existing `.58/.59`; `.1.3` selects a bounded transform oracle. |
| Result | Binding/callable authorities and `scalar_numeric_contract.json`; exact typed AST/child lexeme results | Implemented bounded construction/detachment. Partial Perl numeric constructor/reducer kinds and Julia proof defect below; rich errors/recovery remain unassessed. | Existing `.94/.95`, Julia `.2.26`; `.1.2/.1.3` define and test failures. |

Self-containment IDs in this ledger abbreviate `SPEC-LANGUAGE-SELF-CONTAINMENT`.
Startup IDs abbreviate `SESSION-STARTUP-READING`; Dart/Julia/Lua IDs refer to their
respective `*-STARTUP-READING` trees. Resolve partitioned startup owners with
`perl tools/read_task_tree.pl --tree SESSION-STARTUP-READING --id <full-id>`.

## Existing repairs: dependencies, not new primitives

These owners remain pending at this review. Their original priorities, dependencies,
reproductions and backend order govern repairs. Selected successful probes avoid or
bound these cases; they neither waive defects nor close broad owners. A future proof
depending on an affected behavior must first run that owner's repair and recurrence.

| Partial boundary | Existing repair owner | Claim withheld until verified |
| --- | --- | --- |
| Invalidated recognition tokens / actual-state abort synchronization | Startup `.38`, `.40.1/.40.2` | Abort-safe speculative recognition and obsolete-snapshot safety |
| Wrong-kind/absent Perl collection helpers using host slots | Startup `.17` | Broad host-slot independence; constructor `.1.1.3.1.1` and flat `.1.1.6` close only their exact repairs |
| Rust receiver final assignment / Perl-Rust substitution | Startup `.58`, `.59` | Complete receiver guard and statement-substitution composition |
| Perl single numeric array constructor / numeric-string reducer result kinds | Startup `.94`, `.95` | Correct constructor and reducer JSON kinds beyond the probe's direct literals/lexemes |
| Dart attached controls in marker-selected value ranges | Dart `.2.9` | General mixed-control return locality and branch selection |
| Dart lexical helper supplementary-character order | Dart `.2.13.1-.3` | Portable Unicode lexical key/value ordering; serializer and unmeasured callback order are distinct |
| Progressive ceilings | Startup `.37` | Complete numeric/resource and diagnostic-ceiling enforcement |
| Staged destination reservation / returned Rust markers / saturated Rust calls | Startup `.73`, `.74`, `.75` | Conflicting target safety, complete marker validation and extreme counter safety |
| Dart staged diagnostic bytes / extreme arithmetic / provenance / SDK adapters | Dart `.2.17`, `.2.18`, `.2.19`, `.2.25` | Adversarial staged boundaries and whole-package SDK signoff |
| Julia registry patterns / diagnostic bytes / copy-mutating consumer proof | Julia `.2.13`, `.2.14`, `.2.26` | Complete registry/diagnostic admission and repaired general isolation assertions; `.2.26` is a test defect, not established runtime aliasing |
| Lua malformed arrays / diagnostic bytes / marker cycles-null / private ranges / provenance | Lua `.2.25`, `.2.26`, `.2.27`, `.2.28`, `.2.29` | Complete private host-record admission; ordinary authored-carrier impact is not inferred |
| Lua supplied call seeds / supported-host baseline and guidance | Lua `.2.8.15/.16`, `.2.2`, `.2.1` | Invalid seed rejection, independent exhaustion recurrence and unfiltered supported-host signoff |
| General manifest advertises removed global parse-mode controls | Self-containment `.1.1.5`; coordinate startup `.41.2` | Accurate inventory authority and recurrence guard before `.1.2` |

The lossless/backend ledgers retain the complete route-specific exclusions. This
table routes the observations used here, not all defects in the repository. Supplied
policy adoption stays with startup `.5/.29`; unchanged donor hashes do not close it.

Subsequent `.1.1.5` repairs the general capability description and its missing
recurrence guard, retaining the stable ID and adding fifteen exact-reason mutations.
It also registers two new token-bearing cursor inventory inputs at79/8/0/60.
All other owners above retain the status and dependency obligations recorded here.

## Host and compatibility boundaries

| Classification | Evidence / consequence | Owner |
| --- | --- | --- |
| Compatibility-only | Raw host fallback, legacy Perl plugin registry, old marker behavior and typed-source aliases are outside the preferred portable authored surface. A legacy spelling is not a new portable capability. | `.1.2` names exclusions using the existing inventories/contracts. |
| Backend-host | Runtime matching, caller input/result transfer, precompiled child registry and authorized span projection are substrate/integration. The child `.spec` still recognizes its language; no probe requires a host callback to implement its grammar. | `.1.2` defines the boundary; `.1.3` keeps authored recognition separate from authority adapters. |
| Forbidden | Default `.spec` gains no filesystem, process, network, environment, clock, randomness, package-loading or FFI authority. This design rule is not a sandbox-security proof. | ADR0064 / `.1.2`; an external effect needs separate explicit authorization and contracts. |

## Costs and unassessed requirements: scheduled next actions

No new missing parsing primitive is selected. Named arguments retain their parked
owner; the successful finite probes supply no reason to activate them as a campaign
prerequisite. Additional semantics must follow an agreed objective, minimized public
failure against existing mechanisms, independent oracle, compatibility rules and
Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT proof before `.1.4` creates implementation leaves.

| Observation / requirement | Current status | Scheduled next action |
| --- | --- | --- |
| Prefix/gap/end/missing-close guards, AST/span constructors, loop/LX choice | Implemented with repeated authoring work | `.1.2` documents explicit policies; `.1.3` preserves distinguishing mutations. Later `.4` may assess frontend convenience without changing semantics. |
| Messages, expected tokens, failure spans and in-document recovery | Unassessed composed objective; typed status rejection alone is proven | `.1.2` defines the admitted failure boundary; `.1.3` selects a small diagnostic objective and independent negative oracle before claiming richer support. |
| Indentation, quotes/escapes/comments and realistic complete formats | Unassessed by these probes | `.1.3` records bounded requirement/probe selection; format-catalog and later `.4.4` trials supply realistic requirements. Whole-format readiness remains gated. |
| Useful callable/control/structural-transformation composition beyond the three probes | Contracts exist; composed objective unassessed | `.1.3` selects explicit state/effect/result-kind oracles and negative controls; affected repair owners precede dependent promotion. |
| Depth/steps/calls, regex substrate limits, extreme arithmetic, determinism and performance | Only recorded finite progress/selected accounting is proven | `.1.2` specifies each existing policy and unresolved limit; `.1.3` supplies bounded controls. Existing resource repairs precede guarantees; performance requires measurements. |
| Speculative AST/user-state rollback or expanded staged operands | Outside current rollback/operand contract; need unassessed | `.1.2` states current exclusions; `.1.4` may propose reusable semantics only after an agreed failing objective. No inferred extension approval. |

After canonical inventory closeout605276027, `.1.2.1` supplies the source-located
closure matrix in `docs/language-readiness/closure-contract-matrix.md`. Next
`.1.2.2` subsequently freezes operation/scope/reference structure; `.1.2.3` freezes scoped determinism/resource/failure/ambient policy,
preserving all 66 original bindings and adding 24 inherited-policy anchors. Known resource and Dart lexical-order
repairs retain their owners and prerequisites; the dated review is docs/language-readiness/closure-policy-boundaries.md.
`.1.2.4` next independently reconciles the definition;
then `.1.2.4` reconciles the definition before `.1.3` neutral objectives/mutations
and `.1.4` evidence-backed gap audit. This is a finite evidence plan, not exhaustive
grammar coverage, campaign admission or implementation of the optional frontend.

## Verification

Run the existing three-objective audit from `objective-reconciliation.md`. It verifies
historical runtime evidence and current executable identities, not a fresh runtime
rerun. This slice additionally checks the nine authority paths and each named repair
owner's current task metadata, renders the book, and runs ordinary documentation
gates. Reverify affected public behavior through its canonical owner before relying
on a repaired or changed boundary.
