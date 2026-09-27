# Post-Parity Structured-Text Program

LinkedSpec's next product program after current backend parity is a library of strong, accurate, fast,
Unicode-aware text-to-AST parsers. The initial scope is the 91 eligible rows in the project's structured-text
catalog: general configuration formats, documents and markup, RDF/graph syntaxes, schema and interface languages,
feeds and messaging text, geospatial text, and domain-specific JSON/XML/YAML serializations.

This work has two readiness requirements: `.spec` must express the selected parsing objectives clearly without
routine host-language escape hatches, and Perl, Rust, Dart, Julia, and Lua must have the required feature and
behavior parity. The broad campaign is not active. Planning it does not make any format currently supported or
relax an open backend obligation.

## Strengthen `.spec` before the campaign

The September 2026 priority is ordinary `.spec` expressiveness. The long-term ambition is parsing power comparable
to grammar-oriented tools through LinkedSpec's linked rules, explicit cursor control, captures and transformations.
That is a design goal, not a current equivalence claim. An optional EBNF-like frontend remains a separate later step.

The language already has admitted foundations for selecting and linking rules, composing seek/consume policies,
recognition-only transactions, Unicode source spans and lossless gap capture. Their neutral checks pass, but a
green feature inventory does not prove a difficult grammar is correct or pleasant to author. Known defects remain
tracked, including Perl's unfinished-recognition abort restoring private state without restoring the caller's
input cursor. That limitation must be resolved before relying on abort-safe speculative parsing.

Readiness work uses small representative objectives before committing to entire standards:

| Objective | What the evidence must show |
| --- | --- |
| Nested document grammar | Exact ASTs and source spans, malformed-input and trailing-text rejection, and advancing recursion. |
| Context-dependent syntax | Clearly scoped delimiter or indentation state, correct nested restoration, and useful rejection diagnostics. |
| Lossless extraction and child parsing | Exact prefix/interstitial/tail reconstruction, bounded child inputs, retained provenance and explicit dispatch authority. |

These are planned composition probes, not newly supported formats or confirmed missing primitives. If a probe
fails, its tools and minimized input must distinguish grammar mistakes, engine defects, missing general mechanisms,
and awkward authoring. The result then selects a bounded implementation slice with portable semantics and tests.

Recognition rollback covers cursor, boundaries and marks; it does not undo arbitrary AST or user-variable writes.
For example, a grammar that tentatively builds an AST must separate recognition from committed construction or
establish a different, explicitly accepted mechanism. Merely adding alternate syntax would not solve that requirement.

The owning task is `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1`; its first inventory records existing contracts and exact
backend consumers. The state/control/result inventory is also recorded; representative objective execution
follows before selecting new primitives.
The format program's `.1` readiness gate remains pending. The original catalog and parked language extension retain
all their conformance, Unicode, diagnostics, performance and backend obligations.

The state inventory distinguishes three existing forms that a grammar author can compose:

| Form | State and execution boundary |
| --- | --- |
| User function | Explicit positional/final-rest arguments and fresh function-local state; ordinary typed return values. No implicit caller capture or recursive function calls. |
| Callable block | Deferred construction, temporary copied parameters and invocation-time caller state for other bindings; block-local return. No lexical environment is captured. |
| Linked grammar rule | Recognition, cursor, capture and lifecycle behavior; advancing rule recursion is separate from function recursion. |

Typed bindings, lazy controls, structural writes and leaf transformations supply further building blocks. They
need composition proof: a logical helper's eager operands differ from a selected control branch, and a receiver
mutation's atomic publication does not roll back effects on other bindings. Known mixed-control and mutation-guard
defects remain repair obligations. Numeric AST tests must also distinguish JSON numbers from numeric-looking
strings; value equality alone can hide an incorrect result kind.

Named user-function arguments remain an approved, parked direction. Recording this limitation does not make
that syntax current or prove it is the next feature the format campaign needs.


### Bounded nesting trial

This readiness grammar parses zero or more parenthesized lists containing bare atoms or other lists. It accepts
ASCII whitespace between forms and records half-open Unicode scalar spans. It has no quoted-string syntax,
escape processing, comments or standard-format conformance claim; quote characters are ordinary atom characters.
A bare atom at document level, an unmatched parenthesis, or other text outside the lists is rejected with
`exit_now(1)`. The explicit prefix guard also rejects text that entry preprocessing might otherwise skip.

```text
{{#include ../../../../tests/language-readiness/nested-tree/grammar.spec}}
```

For `(a (β) c)`, the result is:

```json
[{"kind":"list","span":[0,9],"items":[
  {"kind":"atom","span":[1,2],"text":"a"},
  {"kind":"list","span":[3,6],"items":[{"kind":"atom","span":[4,5],"text":"β"}]},
  {"kind":"atom","span":[7,8],"text":"c"}
]}]
```

Recursive rule calls restore the enclosing list's `start` and `items` bindings. The two constructor forms
`hash("span", [start, cursor_pos()])` and `{"span":[start, cursor_pos()]}` must preserve the same bound values.
The trial exposed and repairs a Perl constructor lowering defect; the original expected spans remain unchanged.
The bounded native proof passes the same six accepted and seven rejected inputs on Perl, Rust, Dart, Julia,
Lua and LuaJIT, including CRLF and a supplementary Unicode character. Each public-loaded engine returns exact
ASTs and spans for twelve accepted parses. The Perl proof also covers fresh-process emitted parsers, five-rule ActionIR readiness and immediate recovery after each typed rejection. Prefix/gap/span mutations demonstrate sensitivity to each claimed boundary.

To repeat a prepared runtime's public-loader check, run from the repository root:

```sh
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime rust
```

Replace `rust` with `perl`, `dart`, `julia`, `puc` or `luajit` for the other routes. Prepare the selected example
using its [public integration guide](../public-api/integration.md). The text adapters stop at the first rejected
input; this check does not establish same-engine recovery after rejection. Rust's adapter prints its error as
text, while the others preserve typed JSON.

A separate Rust regression covers native and JSON-reconstructed engines, generated-plan execution, serialized
v2 execution and freshly compiled emitted modules. All six routes preserve the same values, JSON kinds and
Unicode spans, reject malformed inputs with typed status1 exits, and detect prefix/gap/span grammar mutations.
Four routes retain their engine across14 rejection-to-success transitions each; the serialized and emitted entry
functions construct an engine per call, so their subsequent successful calls do not prove retained-engine recovery.
Run this proof with:

```sh
bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml \
  -p linkedspec-runtime --test nested_tree_readiness
```

The emitted test builds four independent modules in repository-local storage and requires their process to exit
successfully with all four tests executed.

Dart now has the same six-route nesting proof, using a JSON roundtrip of `SpecFile` before recompilation for its
reconstructed routes. Its retained native/generated engines also prove 56 rejection-to-success transitions.
Public v2 and emitted entry functions create an engine per call. A separate emitted package validates and runs
four modules after offline dependency resolution and strict analysis. Repeat the two regression tests with:

```sh
cd dart
bash ../tools/run_dart_project_data.sh test test/nested_tree_readiness_test.dart
```

These are bounded nesting results. Package-wide Dart analysis still reports two separately owned SDK deprecations
in its regex adapters; the new test and emitted package pass strict analysis.

Julia's proof covers five public routes: native and JSON-reconstructed `SpecFile` engines, generated v2 entry for
each compiled form, and fresh emitted modules. Only the two native routes retain an engine, proving 28 immediate
rejection-to-success transitions. All five preserve exact JSON kinds and Unicode spans and detect the three
grammar mutations. The existing emitter suite includes this proof:

```sh
bash tools/run_julia_project_data.sh --project=julia -e \
  'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include("julia/test/source_emitter_test.jl")'
```

The child process loads four emitted modules using the retained offline dependencies and checks their metadata,
plans and results. Lua carrier proof remains a separate next step.
This example does not open the structured-format campaign or establish arbitrary-depth resource safety.


## Approved and parked: language coverage and authoring difficulty

On 8 September 2026, the director approved an extension of this program: an explicit programming-language
coverage track and a matrix showing which parsing mechanisms are exercised and how difficult the grammars are
to author. This is recorded direction for future work. The readiness gate remains inactive; no language parser,
corpus campaign, or matrix implementation starts with this approval.

The original 91 catalog rows retain their identities and scope. Programming-language coverage will have a
separate, explicitly selected inventory, reusing existing foundations and catalog entries without double counting.
The purpose is to expose both capability gaps and unnecessary difficulty in expressing correct parsers.

A format count alone cannot show this. Many formats reuse JSON or XML, while one language can exercise several
different mechanisms. The future matrix will keep these dimensions separate:

| Dimension | Evidence to record when work is activated |
| --- | --- |
| Conformance | Exact format/language version and dialect, parsing boundary, valid/invalid cases, AST and diagnostic expectations, and results for each backend and route. |
| Parsing mechanisms | Cases exercising recursion, precedence and associativity, lexical context, indentation, contextual syntax, embedded languages, Unicode, recovery, and resource/progress boundaries. |
| Authoring difficulty | Straightforward, awkward, or blocked authoring, supported by a representative rule excerpt, duplicated logic or workaround, diagnostic experience, and an improvement owner where needed. |
| Performance | Separate cold construction, warm reuse, and document-parsing measurements over representative and adversarial inputs. |
| Confidence | Pinned oracle/corpus, source revision, reproducible command, proof scope, and remaining untested boundaries. |

Untried cases stay **unassessed**. A passing parser can still be awkward to write; an untested feature is not
evidence of a missing capability. A finite corpus also cannot prove that every possible parsing task is covered.
Completion claims will name the admitted inventory and the precise evidence supporting it.

For example, a parser might pass its expression corpus but repeat substantial precedence-handling logic. Its
conformance result can be passing while authoring remains awkward, linked to the relevant excerpt and an
improvement task. If a minimized input instead demonstrates an incorrect AST, that case records a defect and its
repair owner. These are examples of future reporting, not assessments of current LinkedSpec capabilities.

The language track will first select representative syntax families and pin versions, dialects, preprocessing
boundaries, corpus authority, and usable licensing. Operator precedence, indentation, context-dependent token
interpretation, comments/trivia, and mixed embedded languages are selection pressures, not a promised language
list. Each selected parser receives bounded task ownership before implementation and follows the same neutral
contract and all-current-backend proof as the format parsers. Parsing source to AST does not implicitly add
evaluation, typechecking, module loading, or execution.

Every confirmed gap will retain a minimal reproduction and an owning repair task. Diagnosis must distinguish a
grammar defect, an engine defect, a missing general mechanism, an authoring/documentation problem, and a
performance limit. A missing general mechanism follows the existing neutral-contract and all-backend rollout
before the affected parser resumes. The matrix will link the original difficulty to the repair and its verified
result, so recording a problem leads to accountable follow-through.

The durable routes are `STRUCTURED-TEXT-FORMAT-PROGRAM.2.8` for the matrix and rubric and `.12` for language
coverage; `.0.1` records this approval. ADR `0034` carries the dated planning addendum. Readiness `.1` remains the
activation gate. The September language-readiness work above is now the immediate feature direction; separately
owned startup defects remain queued and must be resolved when they block a selected objective.

## One dynamic parser source

For each format, the composed `.spec` files are the sole executable source of truth for grammar, parser
orchestration, AST construction, and recovery behavior. A backend loads the same `.spec` graph, dynamically
constructs or compiles the parser in memory, and can immediately apply it to documents for that format.

There is no separately maintained Perl, Rust, Dart, Julia, or Lua parser. If a backend emits host source or stores
a compiled parser cache, that artifact is a reproducible derivative keyed by the complete `.spec`/import graph,
the LinkedSpec language-contract version, and behavior-relevant options. It may accelerate startup but cannot
become a second grammar or define behavior independently.

The standards and external conformance suites remain the correctness oracles. They say what the format means;
the `.spec` graph is the single parser implementation that must satisfy them on every backend. Performance proof
therefore measures three distinct paths: cold dynamic parser construction, warm cache reuse, and document parsing.

## Optional native acceleration

After a realistic dynamic format parser is complete and measured, LinkedSpec may optionally derive a faster
backend-native artifact from its normalized compiled state. This is a third deployment tier after immediate
dynamic construction and warm cache reuse, not a replacement parser. Loading `foo.spec` must still produce a
usable parser without a native compiler or prebuilt artifact, and the dynamic route remains the correctness oracle
and fallback.

Generated-source artifacts supply important foundations—deterministic identity, independently loadable host source,
normalized state, trace roles, and interpreter-first equivalence—but does not itself claim optimizing compilation
or higher speed. A native accelerator must separately match ASTs, spans, diagnostics, Unicode behavior, recovery,
limits, and trace semantics; correlate compile/runtime behavior back to `.spec` rules; use complete deterministic
fingerprints and invalidation; isolate explicit toolchain/trust boundaries; and demonstrate an objective benefit
including build/load and break-even costs. Strategies may differ internally by backend. Acceleration is not a
format-support or semantic-parity requirement, and Perl need not provide it. ADR `0038` and the separate
`NATIVE-PARSER-ACCELERATOR` task tree govern this non-blocking horizon.

## Observe what was built and what ran

A dynamic parser must be explainable from its first `.spec` load through its final AST. The normal native API must
accept one trace configuration/emitter across spec resolution and imports, validation, function and staged parsing,
contract/dependency planning, cache fingerprint and hit/miss decisions, compilation, and document execution.
Runtime events must expose rule entry/exit, parsing and branch decisions, cursor/capture transitions, AST/value
emission, recovery, and diagnostics where applicable. Stable spec-graph/cache identity and rule/source/position
fields correlate the constructed parser with its execution.

The existing `none`, `low`, `medium`, `high`, `full`, and `debug` levels and quiet/stdout/routed/mirrored behavior
remain the base contract. ADR `0037` adds a future exact rule-label allowlist for focused diagnosis. Global pipeline
scopes remain visible, while rule-owned events are emitted only for selected labels. This filter changes emission
only: traced and untraced construction, parsing, ASTs, recovery, diagnostics, and caches must remain identical.
Payloads and excerpts use explicit limits/redaction controls so debug tracing remains safe for large or adversarial
documents. `STRUCTURED-TEXT-FORMAT-PROGRAM.2.7` owns the shared executable contract after current backend parity.

## Terse, readable, and highly expressive

The format program also treats the quality of the `.spec` source as part of the result. A parser is not a success
if it passes a corpus only by turning its grammar into unreadable punctuation, repeated boilerplate, or opaque
format-specific escape hatches.

Here, **terse** means that redundant ceremony is absent. It does not mean that the shortest spelling always wins.
Names retain the words needed to communicate semantics. For example, `walk_leaves`, `map_leaves`, and
`reduce_leaves` deliberately keep `_leaves`: those methods recursively visit leaves, while plain `map` or
`reduce` would normally suggest immediate elements. Removing that suffix would save characters but lose meaning.

**Readable** means that rule structure, value flow, evaluation order, mutation, scope, and recovery remain visible
from the source and the documented contract. Equivalent concepts use equivalent forms; distinct concepts remain
distinguishable. Invalid or wrong-kind operations produce precise typed diagnostics instead of relying on hidden
coercion.

**Highly expressive** means that a small set of typed, orthogonal mechanisms can compose into difficult parsers.
It does not mean adding one built-in for every format. When HTML, YAML, CommonMark, or another format exposes a
missing capability, LinkedSpec extracts the reusable mechanism and proves it across every current backend.

Uniform value binding is the existing precedent. One identifier can hold scalar, array, harray, or codeblock;
runtime kind determines valid operations, and a wrong-kind mutation fails explicitly. Authors do not select a
parallel backend storage namespace. That design is concise because one abstraction composes uniformly while
preserving typed meaning.

Every later language proposal must therefore include representative format excerpts and ambiguous or invalid
boundaries. The review asks both whether the mechanism can express the format and whether the resulting `.spec`
is a clear, compact source of truth.

## Formats are requirements evidence

The catalog is not only a list of parsers to accumulate. Each authoritative format is an acceptance test for the
`.spec` language itself. When a format exposes a missing general mechanism, the format pauses while LinkedSpec:

1. identifies the reusable parsing mechanism rather than naming a format-specific exception;
2. specifies the smallest backend-neutral syntax, AST, runtime, diagnostic, and Unicode contract;
3. implements and verifies that contract on Perl, Rust, Dart, Julia, and Lua;
4. documents it with worked `.spec` examples; and
5. resumes the format parser using the newly portable capability.

For example, an HTML tree-construction case might expose a need for explicit token reprocessing or a structured
recovery event. YAML might expose indentation/context state. CommonMark might expose delimiter-run or controlled
backtracking requirements. Those become universal `.spec` features only when the mechanism is general and all
current backends agree. The difficult part may not be hidden in a Perl, Rust, Dart, Julia, or Lua callback.

## Reuse syntax foundations

Many catalog rows are serializations or vocabularies layered over a smaller number of syntax families. Their
parsers should compose rather than clone grammar code:

| Foundation | Examples that reuse it |
| --- | --- |
| JSON | JSON Lines, NDJSON, GeoJSON, JSON-LD, JSON Schema, OpenAPI JSON, FHIR JSON, SARIF |
| XML | XHTML, SVG, MathML, DocBook, DITA, RDF/XML, RSS, Atom, KML, GPX, FHIR XML, MusicXML |
| YAML | OpenAPI YAML, AsyncAPI YAML, SPDX YAML |
| CommonMark | GitHub Flavored Markdown and explicitly named generic-Markdown profiles |
| Turtle/RDF terms | TriG, SHACL Turtle, related RDF graph projections |
| HTML tree | RDFa and Microdata extraction stages |

Reuse does not erase format ownership. Every row still pins a specification/version, AST or projection, profile,
conformance evidence, Unicode behavior, examples, limitations, and re-verification command.

Conditional conventions need named profiles. There is no honest universal INI, dotenv, CSV, TSV, generic
Markdown, or JUnit XML grammar. LinkedSpec will identify the dialect it implements instead of turning one library's
behavior into an unstated standard.

## HTML is not XML

XHTML is XML and can reuse the XML foundation. Ordinary HTML requires the WHATWG tokenizer and tree-construction
algorithms: tokenizer states, character references, insertion modes, implied elements, token reprocessing, foster
parenting, active formatting elements, foreign SVG/MathML content, and defined error recovery. Full HTML support
must be proved with authoritative tokenizer and tree-construction corpora. Accepting only clean, well-nested
markup is not an HTML completion claim.

HTML is therefore one of seven early architecture-driving formats alongside JSON, XML, TOML, a named CSV profile,
CommonMark, and Turtle. It is an explicit stress test for the expressiveness and efficiency of `.spec`.

## Unicode and input boundaries

The parsers operate on Unicode text and expose source-aware ASTs. Their proof must cover, as applicable:

- strict malformed-input behavior;
- supplementary scalar values and combining sequences;
- escapes and character references;
- legal Unicode names and intentionally restricted identifier classes;
- byte, character, line, and column provenance;
- LF/CRLF and format-specific newline rules;
- BOM rules and normalization preservation; and
- Unicode data in every syntactic position where the format permits it.

Some formats, notably XML and HTML, can arrive in encodings other than UTF-8. A future format-native byte-decoder
or input layer must make that handling explicit and preserve source provenance. It must not reinterpret the
existing primary CLI or native spec-loading contracts, which remain strict UTF-8.

## Parsing is not evaluation

For CUE, Dhall, Jsonnet, Nickel, Pkl, and the Nix language, the program initially means source text to an accurate
AST. It does not automatically include imports, evaluation, normalization, typechecking, package loading, or host
execution. Likewise, parsing JSON Schema, XSD, GraphQL, Protocol Buffers schema text, or ASN.1 notation does not
by itself promise a validator, compiler, query engine, or binary codec.

Binary wire formats, databases, and packaged containers remain outside this text program. Examples include CBOR,
MessagePack, protobuf binary data, Avro object containers, Parquet, PDF, EPUB, OOXML, and glTF `.glb`.

## What completion means

A format is complete only when it has:

- a pinned authoritative specification and usable conformance corpus;
- a documented source-aware AST, trivia/raw-text policy, and typed diagnostic/recovery boundary;
- identical neutral fixtures on every current backend and supported execution route;
- correlated construction/runtime trace proof, exact rule-focused output, and traced/untraced semantic identity;
- Unicode adversarial and mutation/property proof;
- differential comparison with an independent implementation where practical;
- public examples and honest limitations; and
- correctness-preserving performance and resource measurements on representative, large, and adversarial input.

“Fast” is a measured result, not an assumption. “Supported” means the documented contract passes, not merely that
a friendly example was accepted.
