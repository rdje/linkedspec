# STRUCTURED-TEXT-FORMAT-PROGRAM: Unicode Structured Text to AST

## Metadata

- Tree ID: `STRUCTURED-TEXT-FORMAT-PROGRAM`
- Status: `proposed` (implementation dependency-gated on full current-backend parity)
- Roadmap lane: `Post-parity format coverage and evidence-driven .spec language evolution`
- Created: `2026-07-15`
- Last updated: `2026-07-15`
- Owner: repo-local workflow

## Goal

Use one backend-neutral `.spec` source/composition graph per syntax family to deliver strong, accurate, fast,
Unicode-aware text-to-AST parsers for every eligible entry in the director-provided 10 July 2026 Unicode
structured-text catalog. Treat authoritative real-format conformance as the requirements generator for future
`.spec` language evolution: when a format exposes a missing general parsing mechanism, specify it neutrally,
implement and prove it across Perl, Rust, Dart, Julia, and Lua, then resume that format.

## Non-Goals

- No format implementation begins before full feature and behavior parity among the five current backends.
- No binary wire format, database, packaged container, or excluded outer format is reclassified as text.
- Parsing a programming/configuration language to AST does not silently include evaluation, typechecking, package
  loading, domain validation, rendering, or execution.
- No host-language callback, backend-only grammar, or opaque native parser may hide a capability missing from the
  universal `.spec` contract.
- Additional host backends are not prerequisites and do not outrank this post-parity program.

## Program Invariants

1. **Parity first.** Leaf `.1` is a hard readiness gate; `.2+` may not activate while any current backend parity
   task remains open.
2. **One universal language.** Identical `.spec` sources, neutral fixtures, AST contracts, and required
   diagnostics execute on Perl, Rust, Dart, Julia, and Lua (PUC Lua and LuaJIT where the Lua gate requires both).
3. **Dynamic sole source of truth.** Each format's composed `.spec` graph is the only authoritative parser
   implementation. Every backend constructs/compiles it on demand and can immediately parse documents. Generated
   host code and compiled caches are reproducible, content-addressed derivatives, never parallel grammar owners.
4. **Formats drive general features.** Every discovered gap is classified by reusable mechanism. A new primitive
   lands through neutral contract, all-current-backend rollout, book examples, and recurring gates before the
   format consumes it.
5. **Layer rather than duplicate.** JSON-, XML-, YAML-, HTML-, Markdown-, and RDF-derived formats reuse their
   syntax-family parser and add profile, schema, projection, or validation stages. XHTML uses XML; ordinary HTML
   has its own WHATWG tokenizer/tree-builder path.
6. **Accuracy is executable.** Each format names its authoritative specification and conformance corpus, freezes
   a source-aware AST/trivia policy, proves valid and invalid documents, and uses differential oracles where an
   independent conforming implementation exists.
7. **Unicode is positional and adversarial.** Proof covers strict decoding policy, supplementary scalar values,
   combining sequences, escapes, legal Unicode names, restricted identifier classes, newlines, BOM rules,
   malformed input, and normalization preservation. Non-UTF-8 formats require an explicit governed decoder/input
   layer; they may not weaken the strict-UTF-8 primary CLI contract.
8. **Fast is measured.** Each foundation and family has separate cold dynamic-construction, warm cache-reuse, and
   document-parse benchmarks over representative large/adversarial inputs, fixed correctness checks, resource
   ceilings, and comparable measurements across current backends.
9. **Parsing scope stays honest.** Text-to-AST completion is distinct from evaluator, validator, schema engine,
   renderer, query engine, or domain-application completion.

## Shared Leaf Acceptance

Every format leaf must:

- cite a pinned authoritative specification/version and obtain or build a legally usable conformance corpus;
- define the AST, source spans, raw/normalized value boundary, comments/trivia policy, and portable diagnostics;
- use composed `.spec` sources with no backend-specific syntax or hidden host parser;
- prove on-demand parser construction from those sources, deterministic fingerprinted warm-cache reuse, and
  immediate parsing without a separately maintained generated parser;
- pass the same neutral valid/invalid/Unicode fixtures on all current backends and every supported route;
- prove derived-format reuse instead of cloning its base syntax;
- record any missing general mechanism as an owning child before implementation, then land that mechanism across
  all current backends before continuing;
- publish user-facing examples and limitations in the mdBook; and
- meet correctness-preserving benchmark/resource criteria before claiming `done`.

## Task Tree

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM`
  Status: `proposed`
  Goal: Complete all 91 eligible catalog rows through reusable syntax families and close exact no-drift.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`, `.9`, `.10`, `.11`

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.0`
  Status: `done`
  Goal: Ratify the parity-gated program, architecture, exact catalog decomposition, and public roadmap direction.
  Acceptance: ADR, dedicated task tree, exact 91-row inventory, dynamic `.spec`-graph sole-source contract,
    roadmap/index/live-doc/mdBook/Knowledge Map sync, explicit full-current-backend dependency, and no behavior change.
  Verification: **PASS 2026-07-15.** Direct source/task table extraction reports 91 source rows, 91 owned rows,
    91 unique rows on each side, and zero missing/extra names before the explicit exclusions section. ADR `0034`, roadmap/index/live docs, the public
    architecture chapter, and Knowledge Map agree on parity-first sequencing, general-feature rollout, layered
    reuse, HTML's independent WHATWG path, parsing/evaluation separation, Unicode/decoder boundaries, measured
    performance, and no hidden host parsers. Memory architecture, Knowledge Map, doctrines, mdBook, task metadata,
    exact inventory count, and whitespace checks pass. No parser/compiler/runtime/helper/fixture/capability or
    format behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.18.0 - adopt structured text requirements program`

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.1`
  Status: `pending`
  Goal: Prove all current backend variants have full feature and behavior parity before format work begins.
  Dependencies: complete `LUA-BACKEND-PARITY` and every still-open cross-backend parity owner.
  Acceptance: Perl, Rust, Dart, Julia, and Lua pass the complete shared capability, behavior, native API, CLI,
    corpus, generated-route-where-supported, documentation, and no-drift gates with no delegated parity gap hidden
    as a format-program limitation.
  Verification: `pending`
  Commit: `pending`

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.2`
  Status: `pending`
  Goal: Establish the reusable contracts and measurement harness before the first format parser.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`, `.2.5`, `.2.6`

| Leaf | Contract/harness slice | Status |
| --- | --- | --- |
| `.2.1` | Repo-owned machine-readable 91-row catalog manifest, authoritative-source registry, licensing/provenance, version/update policy. | `pending` |
| `.2.2` | Decoded-Unicode input contract plus optional format-governed byte-decoder seam; preserve strict-UTF-8 primary CLI semantics. | `pending` |
| `.2.3` | Neutral source-aware AST, raw/cooked text, comments/trivia, spans, line/column, error/recovery, and partial-result contract. | `pending` |
| `.2.4` | Shared conformance, differential-oracle, mutation, Unicode fuzz/property, minimization, and reproducibility harness. | `pending` |
| `.2.5` | Cross-backend cold-construction, warm-cache, parse-throughput/latency, memory/resource protocol for representative, large, streaming-shaped, and adversarial inputs. | `pending` |
| `.2.6` | Reusable spec import/staged-parse/profile/projection architecture and syntax-family cache contract. | `pending` |

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.3`
  Status: `pending`
  Goal: Implement the seven architecture-driving seed formats before broad family rollout.
  Dependencies: `.1`, `.2.1-.2.6`

| Leaf | Format | Architectural pressure | Status |
| --- | --- | --- | --- |
| `.3.1` | JSON | Escapes, numbers, recursive values, strict UTF-8, duplicate-key policy, exact diagnostics. | `pending` |
| `.3.2` | XML | Unicode names, entities, namespaces, declarations, source encoding, well-formedness. | `pending` |
| `.3.3` | HTML | WHATWG tokenizer states, tree-construction modes, reprocessing, recovery, foreign content, encoding sniffing. | `pending` |
| `.3.4` | TOML | Dotted keys, tables, date/time values, multiline strings, duplicate-definition constraints. | `pending` |
| `.3.5` | CSV | Explicit dialect/profile contract, quoted records, embedded newlines, encoding agreement, streaming scale. | `pending` |
| `.3.6` | CommonMark | Delimiter runs, block/inline staging, ambiguity, backtracking, source positions. | `pending` |
| `.3.7` | Turtle | Unicode RDF terms, prefixes, escapes, collections, blank nodes, graph AST. | `pending` |

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.4`
  Status: `pending`
  Goal: Complete general-purpose structured/configuration text and named conditional profiles.
  Dependencies: `.3` foundations as listed per row.

| Leaf | Catalog row | Reuse/scope | Status |
| --- | --- | --- | --- |
| `.4.1` | YAML | Independent indentation/context/anchor/scalar foundation. | `pending` |
| `.4.2` | JSON Lines | JSON plus exact one-value-per-line framing. | `pending` |
| `.4.3` | NDJSON | JSON plus pinned NDJSON framing/profile. | `pending` |
| `.4.4` | EDN | Tagged values, collections, characters, symbols/keywords. | `pending` |
| `.4.5` | KDL | UTF-8 nodes, arguments, properties, annotations. | `pending` |
| `.4.6` | JSON5 | JSON-family ECMAScript-style lexical extension. | `pending` |
| `.4.7` | Hjson | JSON-family human-oriented profile. | `pending` |
| `.4.8` | HOCON | Includes/substitutions remain AST unless separately evaluated. | `pending` |
| `.4.9` | CUE | Parse source to AST; evaluation/type constraints are separate. | `pending` |
| `.4.10` | Dhall | Parse source to AST; normalization/import evaluation is separate. | `pending` |
| `.4.11` | Jsonnet | Parse source to AST; evaluation/import execution is separate. | `pending` |
| `.4.12` | Nickel | Parse source to AST; contracts/evaluation are separate. | `pending` |
| `.4.13` | Pkl | Parse source to AST; evaluation/module loading is separate. | `pending` |
| `.4.14` | Nix language | Parse source to AST; evaluator/store semantics are separate. | `pending` |
| `.4.15` | TSV | Named tab-separated profile with explicit quoting/newline/encoding rules. | `pending` |
| `.4.16` | INI | One or more named dialect profiles; no false universal-INI claim. | `pending` |
| `.4.17` | dotenv / `.env` | One or more named implementation profiles; expansion is separately scoped. | `pending` |
| `.4.18` | Generic Markdown | Explicit named dialect/profile registry; CommonMark remains the foundation. | `pending` |
| `.4.19` | Java `.properties` | Classic byte/escape and Reader/Unicode profiles kept distinct. | `pending` |

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.5`
  Status: `pending`
  Goal: Complete document and markup rows through XML, HTML, CommonMark, or independent document grammars.

| Leaf | Catalog row | Reuse/scope | Status |
| --- | --- | --- | --- |
| `.5.1` | XHTML | XML foundation plus XHTML vocabulary/profile. | `pending` |
| `.5.2` | GitHub Flavored Markdown | CommonMark plus exact GFM extensions. | `pending` |
| `.5.3` | reStructuredText | Independent document grammar and named encoding policy. | `pending` |
| `.5.4` | AsciiDoc | Pinned AsciiDoc language/toolchain profile. | `pending` |
| `.5.5` | SVG | XML foundation plus SVG vocabulary/projection. | `pending` |
| `.5.6` | MathML | HTML/XML serialization profiles kept explicit. | `pending` |
| `.5.7` | DocBook | XML foundation plus pinned DocBook vocabulary. | `pending` |
| `.5.8` | DITA | XML foundation plus pinned DITA vocabulary. | `pending` |
| `.5.9` | TEI P5 | XML foundation plus pinned TEI vocabulary. | `pending` |
| `.5.10` | WebVTT | UTF-8 timed-text blocks, cue settings, payload structure. | `pending` |

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.6`
  Status: `pending`
  Goal: Complete RDF, linked-data, and graph text rows through shared JSON/XML/HTML/Turtle foundations.

| Leaf | Catalog row | Reuse/scope | Status |
| --- | --- | --- | --- |
| `.6.1` | RDF/XML | XML foundation plus RDF graph projection. | `pending` |
| `.6.2` | TriG | Turtle foundation plus dataset/named-graph syntax. | `pending` |
| `.6.3` | N-Triples | Line-oriented RDF term grammar. | `pending` |
| `.6.4` | N-Quads | N-Triples plus graph term. | `pending` |
| `.6.5` | JSON-LD | JSON foundation plus JSON-LD syntax projection; expansion algorithms separate unless owned. | `pending` |
| `.6.6` | RDFa | HTML/XML host parsing plus RDFa extraction stage. | `pending` |
| `.6.7` | Microdata | HTML tree plus Microdata extraction stage. | `pending` |
| `.6.8` | GraphML | XML foundation plus graph vocabulary. | `pending` |
| `.6.9` | GEXF | XML foundation plus graph vocabulary. | `pending` |
| `.6.10` | DOT | Pinned Graphviz grammar/encoding profile and graph AST. | `pending` |

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.7`
  Status: `pending`
  Goal: Complete schema, validation-language, and interface-description text rows without conflating parsing with
    validation, compilation, or wire-format execution.

| Leaf | Catalog row | Reuse/scope | Status |
| --- | --- | --- | --- |
| `.7.1` | XML DTD | XML lexical foundation; declaration AST and entity constraints. | `pending` |
| `.7.2` | XML Schema (XSD) | XML foundation plus XSD vocabulary. | `pending` |
| `.7.3` | RELAX NG XML syntax | XML foundation plus RELAX NG vocabulary. | `pending` |
| `.7.4` | RELAX NG compact syntax | Independent compact grammar. | `pending` |
| `.7.5` | Schematron | XML foundation plus Schematron vocabulary. | `pending` |
| `.7.6` | JSON Schema | JSON foundation plus schema AST; validation execution separate. | `pending` |
| `.7.7` | JSON Type Definition | JSON foundation plus RFC 8927 schema AST. | `pending` |
| `.7.8` | CDDL | Text schema AST for CBOR/JSON models; binary CBOR parsing excluded. | `pending` |
| `.7.9` | SHACL Turtle | Turtle foundation plus SHACL graph projection. | `pending` |
| `.7.10` | SHACL RDF/XML | RDF/XML foundation plus SHACL graph projection. | `pending` |
| `.7.11` | ShEx compact syntax | Independent RDF shape grammar. | `pending` |
| `.7.12` | ShEx JSON syntax | JSON foundation plus ShEx AST projection. | `pending` |
| `.7.13` | OpenAPI JSON | JSON foundation plus OpenAPI document projection. | `pending` |
| `.7.14` | OpenAPI YAML | YAML foundation plus the same OpenAPI projection. | `pending` |
| `.7.15` | AsyncAPI JSON/YAML | Shared AsyncAPI projection over both JSON and YAML serializations. | `pending` |
| `.7.16` | GraphQL SDL and operations | Unicode source with restricted names; SDL/operation ASTs. | `pending` |
| `.7.17` | Protocol Buffers `.proto` | Schema-language AST; binary wire format excluded. | `pending` |
| `.7.18` | Protocol Buffers Text Format | Text message AST; binary wire format excluded. | `pending` |
| `.7.19` | Avro JSON schema | JSON foundation plus Avro schema projection. | `pending` |
| `.7.20` | Avro JSON encoding | JSON foundation plus Avro value projection; binary encoding excluded. | `pending` |
| `.7.21` | Thrift IDL | IDL AST; binary/compact protocols excluded. | `pending` |
| `.7.22` | ASN.1 notation | Schema AST with exact identifier/string-type repertoire; BER/CER/DER/PER excluded. | `pending` |

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.8`
  Status: `pending`
  Goal: Complete feeds, calendars, contacts, and messaging-related text rows with explicit carrier/encoding scope.

| Leaf | Catalog row | Reuse/scope | Status |
| --- | --- | --- | --- |
| `.8.1` | RSS 2.0 | XML foundation plus RSS vocabulary/profile. | `pending` |
| `.8.2` | Atom | XML foundation plus RFC 4287 vocabulary. | `pending` |
| `.8.3` | iCalendar | RFC 5545 content lines, folding, parameters, UTF-8/ASCII input policy. | `pending` |
| `.8.4` | vCard 4.0 | RFC 6350 content lines, folding, parameters, UTF-8. | `pending` |
| `.8.5` | ActivityStreams 2.0 JSON-LD | JSON/JSON-LD foundation plus ActivityStreams projection. | `pending` |
| `.8.6` | Internet Message Format / email | RFC 5322 plus explicitly owned internationalized-header/address extensions. | `pending` |
| `.8.7` | MIME | Structural carrier grammar and declared body-part charsets; no claim of one MIME text encoding. | `pending` |

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.9`
  Status: `pending`
  Goal: Complete geospatial text rows through JSON/XML foundations.

| Leaf | Catalog row | Reuse/scope | Status |
| --- | --- | --- | --- |
| `.9.1` | GeoJSON | JSON foundation plus RFC 7946 projection. | `pending` |
| `.9.2` | KML | XML foundation plus OGC KML projection. | `pending` |
| `.9.3` | GML | XML foundation plus pinned OGC GML profile. | `pending` |
| `.9.4` | GPX | XML foundation plus GPX 1.1 projection. | `pending` |

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.10`
  Status: `pending`
  Goal: Complete domain-specific Unicode text rows through reusable JSON/XML/YAML foundations.

| Leaf | Catalog row | Reuse/scope | Status |
| --- | --- | --- | --- |
| `.10.1` | HL7 FHIR JSON | JSON foundation plus pinned FHIR release projection. | `pending` |
| `.10.2` | HL7 FHIR XML | XML foundation plus the same pinned FHIR release projection. | `pending` |
| `.10.3` | MusicXML | XML foundation plus MusicXML 4.0 projection; compressed `.mxl` excluded. | `pending` |
| `.10.4` | glTF `.gltf` | JSON foundation plus glTF 2.0 manifest projection; buffers and `.glb` excluded. | `pending` |
| `.10.5` | COLLADA `.dae` | XML foundation plus pinned COLLADA vocabulary. | `pending` |
| `.10.6` | SPDX tag/value | Plain-text SPDX serialization AST. | `pending` |
| `.10.7` | SPDX JSON | JSON foundation plus pinned SPDX projection. | `pending` |
| `.10.8` | SPDX YAML | YAML foundation plus the same SPDX projection. | `pending` |
| `.10.9` | CycloneDX JSON | JSON foundation plus pinned CycloneDX projection. | `pending` |
| `.10.10` | CycloneDX XML | XML foundation plus the same CycloneDX projection. | `pending` |
| `.10.11` | SARIF | JSON foundation plus OASIS SARIF 2.1.0 projection. | `pending` |
| `.10.12` | JUnit XML | XML foundation plus explicitly named producer/consumer profiles; no false universal schema. | `pending` |

- ID: `STRUCTURED-TEXT-FORMAT-PROGRAM.11`
  Status: `pending`
  Goal: Close exact catalog coverage, exclusions, cross-backend parity, Unicode, performance, and public no-drift.
  Children: `.11.1`, `.11.2`, `.11.3`, `.11.4`

| Leaf | Closeout slice | Status |
| --- | --- | --- |
| `.11.1` | Audit every catalog row: 91 eligible rows each map once to an executable owner; binary/container exclusions remain exact and reasoned. | `pending` |
| `.11.2` | Run complete five-backend conformance/Unicode/differential corpus and ensure no format depends on a hidden host parser. | `pending` |
| `.11.3` | Run cross-backend performance/resource signoff and document measured tradeoffs without weakening accuracy. | `pending` |
| `.11.4` | Publish complete mdBook format matrix, examples, AST/diagnostic contracts, versions, limitations, reverify commands, and final roadmap/KM closeout. | `pending` |

## Current Frontier

| Order | Leaf | Status | Why next |
| ---: | --- | --- | --- |
| 1 | `STRUCTURED-TEXT-FORMAT-PROGRAM.0` | `done` | Ratified and durably decomposed without starting implementation. |
| 2 | `STRUCTURED-TEXT-FORMAT-PROGRAM.1` | `pending` | Hard-gated until every current backend reaches full parity. |

## Decisions

- `2026-07-15`: The format catalog is a post-parity requirements program for `.spec`, not merely a parser wish
  list. Missing capabilities become general neutral language/runtime features and roll through every current
  backend before the discovering format continues.
- `2026-07-15`: HTML is not an XML derivative. Full WHATWG tokenizer/tree-construction/error-recovery behavior is
  an early architecture-driving seed and must use authoritative tokenizer/tree-construction corpora.
- `2026-07-15`: Derived JSON/XML/YAML/HTML/Markdown/RDF formats reuse foundations. Text-to-AST does not silently
  include evaluators, schema engines, renderers, or domain semantics.
- `2026-07-15`: The composed format `.spec` graph is the sole parser source of truth. Backends dynamically compile
  it for immediate document use; generated host source and warm caches are fingerprinted derivatives only.

## Open Questions

- Exact AST normalization/trivia and recovery contracts are deliberately owned by `.2.3`, after parity and before
  a format parser.
- The format-native decoder API for XML/HTML and other non-UTF-8-capable inputs is deliberately owned by `.2.2`;
  it may not weaken ADR `0025` strict-UTF-8 CLI behavior.
- Official conformance corpus licensing/storage/caching is owned by `.2.1` and `.2.4` before downloads or vendoring.

## Blockers

- Full feature and behavior parity among Perl, Rust, Dart, Julia, and Lua is mandatory before `.1` can complete or
  `.2+` can activate.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-15` | `.0` | Source/task extraction 91/91 unique, missing/extra 0; ADR/task/roadmap/index/live-doc/book/KM sync; memory architecture; Knowledge Map; doctrines; mdBook; task metadata; whitespace. | PASS — complete parity gate is explicit and no behavior changed. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.0` | `FUTURE-PARITY-BACKLOG.18.0 - adopt structured text requirements program` | ADR, exact 91-row decomposition, hard parity gate, roadmap/book/KM/live-doc synchronization. |

## Changelog

- `2026-07-15`: Created the parity-gated structured-text format program and exact catalog ownership map.
