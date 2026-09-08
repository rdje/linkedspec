# 0034 - Real Unicode structured-text formats drive post-parity `.spec` evolution

- Date: 2026-07-15
- Status: accepted
- Tags: architecture, roadmap, formats, parser, ast, unicode, performance, conformance, cross-variant-parity

## Context

LinkedSpec is converging Perl, Rust, Dart, Julia, and Lua on one universal `.spec` language, neutral AST/IR,
runtime semantics, native embedding contract, and executable conformance corpus. Lua remains the active backend
frontier; the director explicitly requires full parity among all five current backends before the project starts
another product program.

The director supplied a 10 July 2026 catalog of Unicode-capable structured text. It contains 91 eligible text
format rows across general configuration, documents/markup, RDF/graphs, schemas/IDLs, messaging, geospatial, and
domain-specific serializations, plus an explicit set of binary/database/container exclusions. The purpose is not
only to accumulate example parsers. Those real formats should expose the general mechanisms LinkedSpec still
needs to become a top-tier text-to-AST system.

The catalog includes important distinctions. Derived JSON/XML/YAML formats should reuse one syntax foundation;
conditional conventions such as CSV, INI, dotenv, and generic Markdown require named profiles; CUE, Dhall,
Jsonnet, Nickel, Pkl, and Nix parsing does not imply evaluation; and ordinary HTML requires the WHATWG tokenizer
and tree-construction/recovery algorithms rather than XML-style parsing. XML and HTML also expose format-native
byte-decoding questions that must not silently weaken ADR `0025`'s strict-UTF-8 primary CLI.

## Decision

1. **Adopt the catalog as a post-parity requirements program.** No format implementation begins until Perl,
   Rust, Dart, Julia, and Lua have full user-observable feature and behavior parity and all current parity owners
   are closed.
2. **Use real formats to drive general language evolution.** When an authoritative format or conformance corpus
   exposes a missing mechanism, create an owning task-tree child, specify the smallest reusable neutral contract,
   implement and prove it across every current backend, update the mdBook, then resume the format.
3. **Forbid hidden host parsers.** Backend-language callbacks, opaque native parsers, and per-backend `.spec`
   dialects may not carry syntax that the universal `.spec` contract cannot express. Host libraries may serve as
   independent differential oracles, not as the shipped parsing implementation behind a false parity claim.
4. **Make the `.spec` graph the sole parser source of truth.** A backend loads the same format `.spec` files and
   their imports/staged parse graph, constructs or compiles the parser on demand, and can immediately apply it to
   input documents. Handwritten host parsers and checked-in generated host source are never co-authoritative.
   Generated code and compiled parser caches are reproducible derivatives keyed by the complete `.spec` graph,
   language-contract version, and behavior-relevant options.
5. **Layer syntax families.** JSON-, XML-, YAML-, HTML-, Markdown-, and RDF-derived formats compose and project
   shared parser/AST foundations. Each catalog row still has an explicit owner, version, conformance source,
   AST/profile policy, examples, and completion evidence.
6. **Make accuracy executable.** Completion requires a pinned authoritative specification, valid/invalid corpus,
   source-aware AST and trivia policy, typed diagnostics and recovery boundary, Unicode adversarial proof,
   differential testing where possible, and exact execution on all current backends.
7. **Make performance measured.** “Fast” requires correctness-preserving cross-backend measurements for cold
   parser construction, warm content-addressed cache reuse, and document parsing, with resource ceilings over
   representative, large, streaming-shaped, and adversarial documents. Performance claims may not weaken the
   accepted AST or error contract.
8. **Keep scope honest.** Parsing a programming/configuration language, schema language, or domain serialization
   to AST does not silently include evaluation, typechecking, validation, rendering, querying, package loading, or
   domain execution. Binary formats and packaged/container formats remain excluded unless a later decision adopts
   a distinct byte/container program.
9. **Treat HTML as an early independent stress test.** Full HTML support means WHATWG tokenizer and tree-builder
   behavior, including error recovery and foreign content, proved with authoritative tokenizer/tree-construction
   corpora. XHTML reuses XML; ordinary HTML does not.
10. **Do not make more backends the prerequisite.** Additional backend ideas remain unadopted until they have a
   separate objective case. The format program uses the five current backends and follows, rather than delays,
   their parity closeout.

## Consequences

- `STRUCTURED-TEXT-FORMAT-PROGRAM` owns the exact 91-row decomposition, readiness gate, shared contracts,
  architecture-driving seed formats, derived families, and final no-drift closeout.
- The first executable post-parity work is a readiness/contract phase, not an immediate HTML/JSON implementation.
  It must define input decoding/provenance, neutral AST/trivia/diagnostics, conformance/fuzz/differential harnesses,
  reusable composition, and benchmarks.
- Any new `.spec` primitive discovered by a format temporarily pauses that format until the primitive reaches
  exact Perl/Rust/Dart/Julia/Lua parity. This preserves the universal-language doctrine instead of accumulating
  backend or format exceptions.
- Parser construction remains dynamic and in-memory. Generated host source and compiled parser caches may improve
  startup, but are disposable, fingerprinted products of the format's `.spec` graph and can never define behavior
  independently. Conformance includes cold construction, warm reuse, and immediate document parsing.
- ADRs `0011` (text-to-AST), `0012` (staged linked parsing), `0016` (language neutrality), `0023` (observable
  parity), `0025` (strict-UTF-8 primary CLI), and `0026` (strict-UTF-8 native spec loading) remain in force.
  Format-native byte decoding must use a new explicit governed seam rather than reinterpret those existing APIs.
- The mdBook becomes the public matrix of supported format/version/profile, AST/diagnostic contract, examples,
  Unicode behavior, conformance evidence, performance evidence, and honest limitations.

## Planning addendum — 2026-09-08, approved and parked

The director approves an explicit programming-language coverage track and a mechanism/authoring-difficulty matrix
within this program. `STRUCTURED-TEXT-FORMAT-PROGRAM.0.1` records the DBINP intake; `.2.8` owns the future matrix
and `.12` owns language coverage. The original 91 catalog rows retain their identity and scope. Language membership,
versions/dialects, corpus authority/licensing and bounded per-language ownership are selected later under `.12.1`.

The matrix separates conformance, mechanisms exercised, authoring difficulty, performance and confidence, with
unassessed/not-run states and reproducible evidence. Confirmed gaps gain minimal reproductions and owning repair
tasks; general mechanisms retain the neutral-contract/all-backend rollout before affected parsers resume.
Finite inventory coverage is not universal parsing completeness. This accepts a parked planning direction only:
readiness `.1` remains inactive, current startup/repair work continues, and no parser implementation or new current
API/DSL contract is admitted.

## Links

- Detailed task tree: `docs/tasks/STRUCTURED-TEXT-FORMAT-PROGRAM.md`
- Parent backlog owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` `.18`
- Multi-backend vision: ADR `0006`
- Text-to-AST doctrine: ADR `0011`
- Staged linked parsing: ADRs `0012`-`0016`
- Observable backend parity: ADR `0023`
- UTF-8 boundaries: ADRs `0025` and `0026`
