# Post-Parity Structured-Text Program

LinkedSpec's next product program after current backend parity is a library of strong, accurate, fast,
Unicode-aware text-to-AST parsers. The initial scope is the 91 eligible rows in the project's structured-text
catalog: general configuration formats, documents and markup, RDF/graph syntaxes, schema and interface languages,
feeds and messaging text, geospatial text, and domain-specific JSON/XML/YAML serializations.

This work has a strict dependency: it does not begin until Perl, Rust, Dart, Julia, and Lua have full feature and
behavior parity. Planning the program does not make any format currently supported and does not relax an open
backend obligation.

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
