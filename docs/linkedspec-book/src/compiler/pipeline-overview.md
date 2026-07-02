# Pipeline Overview

At a high level, LinkedSpec’s compile/runtime flow looks like this:

1. validate and prepare the compile pipeline
2. extract top-level user-function definitions into the function registry
3. bootstrap-parse the stripped `.spec` rule source into parsed entries
4. build compiled rule-table state
5. attach the validated function registry to compiled state
6. build dependency-regex state
7. build compiled descriptor state
8. validate the generated descriptor state
9. project the outward descriptor or build the runtime parser wrapper

In text-diagram form:

```text
source .spec text
  -> prepare pipeline
  -> user-function registry extraction
  -> validate source envelope
  -> bootstrap parse
  -> helper/action AST
  -> compiled_spec_state
  -> attach function registry
  -> compiled_dependency_regex_state
  -> compiled_descriptor_state
  -> validate descriptor state
  -> outward descriptor or parser coderef
```

The stages above are a **backend-neutral** description of how any LinkedSpec backend turns `.spec` source into a parser or descriptor. The concrete module names, line counts, and signatures used as examples in this chapter (`LinkedSpec::Validation`, `LinkedSpec::Get(...)`, `Runtime::run_get`, `pos($$input_ref)`, …) are the **Perl reference backend's** realization of those stages; another backend implements the same stage sequence in its own language.

## Staged linked parsing

LinkedSpec does not require every useful grammar boundary to be swallowed by one
up-front parser. A stage may parse the structure that is easy to anchor, emit an AST
node containing an extracted text payload plus source span, and create a later parse job
for that payload. The next job can load the spec that owns the payload's sublanguage and
replace or augment the text field with a deeper AST.

For example, a stage can recognize a top-level function shell, preserve its body text
with source provenance, and route that body to the action/body grammar that owns helper
statements. The same stage might also extract regex payloads, annotations, or embedded
DSL fragments, each routed to a different next-stage spec. Stage N therefore maps to a
parse graph, not necessarily to one stage-N+1 spec.

A parse job is a neutral contract, not a host-language trick. The job records:

- job id
- parent AST path
- node kind
- payload kind
- parser spec identity
- optional top rule
- source text and source span
- result insertion policy
- failure policy and diagnostic owner

The accepted annotation design is a future portable helper:

```text
parse_job(text_expr, hash(
  "node_kind", "function_definition",
  "payload_kind", "function_body",
  "spec", "specs/action-body.spec",
  "top", "action_block",
  "into", "body_ast",
  "on_error", "fail"
))
```

The helper creates a marker value in the stage-N AST and a backend-neutral metadata
sidecar. It does not execute the next parser inline. Result policies define where the
later AST is stitched (`replace_marker`, `replace_field`, `sibling_field`, or
`append_child`). Failure policies define whether a next-stage failure aborts the composed
parse (`fail`), preserves the original text plus diagnostics (`keep_text`), or emits a
structured diagnostic node (`diagnostic_node`). Current shipped parsers do not yet accept
or execute `parse_job(...)`.

When implemented, parse jobs dispatch through a staged parser registry with neutral
`resolve`, `load`, `compile`, and `execute` operations. Resolution checks already-known
import aliases and composed spec identities, then paths relative to the declaring spec,
then configured search roots and registry providers in declared order. The scheduler
collects jobs after the current stage parse, orders them by parent AST path, source span,
and job id, executes them in that stable order, stitches their results, and queues any
new jobs emitted by stitched results at the next stage depth. Cache keys include the
normalized spec identity, content digest, import/include graph fingerprint, selected top
rule, `.spec` language version, helper/action contract version, staged parsing contract
version, and backend capability set. Active-chain repeats of spec identity, top rule,
payload digest, and source span are staged-dispatch cycles and must diagnose.

Spec imports/composition are a separate feature. Imports let a spec reuse definitions
from other spec files. Staged parse dispatch runs another parser over text produced by a
previous parse. Keeping those concepts separate lets diagnostics explain whether a
failure happened while loading grammar material or while refining a runtime payload.

The accepted import/composition design is deliberately file-scope and language-neutral:

```text
import "common/atoms.spec" as atoms
include "common/lifecycle.spec"
```

`import` loads reusable grammar material behind an explicit alias, so references use a
qualified rule name such as `atoms.Identifier`. `include` performs a structured merge of
another parsed `.spec` into the current unqualified namespace. It is not text
concatenation, and it does not parse runtime payloads. Resolution order, collision
diagnostics, cycle reporting, source provenance, and descriptor fingerprints are part of
the neutral contract. This is a design contract for upcoming implementation; current
shipped parsers do not yet accept those directives.

For `.spec` language evolution, `specs/spec.spec` is the first authoritative grammar.
Other `.spec`-language stages derive from payloads produced through that self-hosted
path. The hardcoded bootstrap parser may bridge old behavior, but permanent syntax
should not fork into bootstrap-only grammar.

The staged model is implementation-language neutral. Perl5, Raku, Rust, Julia, Lua,
Dart, Zig, Go, and future backends must preserve the same parse-job semantics, source
provenance, deterministic parser resolution, and result stitching behavior.

Every backend must parse helper/action language text into typed AST/IR nodes before
lowering, interpretation, or code emission. Direct text-to-text helper rewriting into
host-language source is not a conforming architecture for new backend work. The Rust
backend already follows this model with expression and statement nodes. The Perl
reference now exposes an additive `LinkedSpec::ActionIR::AST` parser seam for the helper
expression surface. The Perl reference has also started consuming that seam for non-call
value expressions in `MethodLowering`: primitive literals, scoped bare scalar reads,
direct indexed/nested access, shape literals, and block values lower from AST nodes.
Value-only helper-call composition now also consumes AST `call` nodes recursively before
reusing the existing Perl helper catalog, covering scalar normalization, string
predicate/composition, coalesce/concat, and scalar-argument numeric helpers. Aggregate
helper-call families now consume AST `call` nodes too: canonical wrappers
(`scalar(...)`/`array(...)`/`hash(...)`), `copy`/`array_copy`/`hash_copy`, collection
helpers, numeric reducers over aggregate operands, and hash helpers rebuild their helper
surface from typed AST fields while preserving symbol slots and quoted-wrapper literal
boundaries before reusing the existing Perl helper catalog. Unsupported covered helper
forms now report through the existing unresolved-helper metadata instead of leaking as
generated host-language calls. Receiver-dot value chains now also consume AST
`fluent_chain` nodes for the array, hash, string, and number receiver families before the
legacy receiver-dot text normalizers run. Generalized return payloads now parse through
the same AST value traversal before the legacy raw fallback, preserving scalar source-slot
reads such as `return(count)` and narrow compatibility payloads that are still untyped.
Assignment and mutation operator statements (`name = value`, `items += value`, and
`meta[key] = value`) now also consume typed AST target/key/value fields before the legacy
statement-regex fallback. Helper-call statements now consume typed AST `call` fields for
`set`/`assign`, `set_key`, `push`, `push_value`, `push_nonempty`, `return`, and
`return_undef`, while array end-mutation receiver statements consume AST `fluent_chain`
receiver/call fields. Expression-valued block internals now consume AST `block_value`,
`action_block`, and `action_stmt` fields for side effects, block-local return payloads,
and final expressions. The parser seam now also represents attached-block and marker
structured-control statements as typed `control_*` nodes for `if`/`when`/`otherwise`,
`switch`/`case`/`default`, and `while` families, including attached bodies and switch
branches. `if`/`when`/`otherwise` statement lowering now consumes typed condition and
body nodes before reusing the existing branch engine. `switch`/`case`/`default` statement
lowering now consumes typed source, match, body, branch-list, and end-marker nodes before
reusing the existing switch stack engine. Attached `while(cond) { ... }` statement
lowering now consumes typed condition/body nodes before reusing the existing loop lowerer
and its deterministic 10000-iteration safety guard. Bodyless `while(...)` marker nodes
remain parser shape only because the current DSL has no `endwhile` product syntax. The
wrapper forms remain compatibility syntax, not the canonical destination surface.
Standalone supported value statements now lower through the same typed AST value
traversal and produce canonical `VALUE_DROP` events: their value is computed with the
covered helper/receiver semantics and then intentionally discarded. For example,
`trim(" x ")`, `concat("a","b")`, and `" x ".trim()` do not remain raw host calls.
Unknown typed calls and function-call receiver chains in return/value positions now
diagnose through unresolved-helper metadata instead of becoming generated host-language
calls. Top-level user-function definitions now have their own registry extraction seam:
`fn name(args) { body }` definitions are recorded before bootstrap parsing, body payloads
are parsed as ActionIR `action_block` AST, and the definitions are projected through the
public descriptor. During rule ActionIR lowering, the compiler threads that registry into
the value-expression lowerer so registered exact-arity calls execute as value-producing
expressions. Registered standalone calls and receiver chains are classified through the
same registry as canonical `VALUE_DROP` statements, so the call value is computed and
discarded without raw fallback. Recursion and unsupported function-body forms are fenced
as unresolved-helper diagnostics.

The Rust backend implements the same stage end to end for the MVP surface: it extracts
top-level function definitions into `SpecFile.functions`, validates their names and
params before runtime, compiles bodies into `CompiledUserFunction` records with parsed
`CodeBlock` bodies, resolves registered calls before helper fallback, executes them in
fresh function-local stores, and lets returned values continue through compatible
receiver-dot chains. Standalone registered calls execute and discard their result.
This closes the portable MVP surface: top-level `fn name(args) { ... }` with explicit
parentheses and a braced value-oriented body. Alternate spellings, optional zero-arg
parentheses, brace-less bodies, caller-state-mutating functions, recursion,
closures/lambdas/currying, and function namespaces are future extension topics, not
current parser/compiler/runtime behavior.

The current fallback boundary is deliberate. Malformed helper forms already covered by
the typed AST path report unresolved-helper metadata instead of silently becoming Perl
host calls. Retired helpers and non-DSL host-shaped statements remain explicit
compatibility debt, and a few narrow return payload compatibility shapes are still
fenced. Unknown typed calls and receiver chains are reserved for user-defined function
resolution; they must not become a broad host-language fallback. The Perl reference now
diagnoses those calls in return/value positions. In standalone statement position,
registered user-function calls/chains lower as `VALUE_DROP`; unregistered call-shaped
statements remain raw compatibility debt.

## Why the pipeline matters

Understanding the pipeline helps explain:

- where failures happen
- why diagnostics have stages
- how runtime/context metadata is preserved
- why internal state models exist

It also makes clear that the reference implementation is no longer best understood as one giant monolithic script (historically the Perl backend's `LinkedSpec.pm`).

## Stage 1: prepare the compile pipeline

Pipeline preparation normalizes options and callback ownership before real parsing begins.

This is where the compiler knows about requested options such as:

- `top_rule`
- `parse_mode`
- `return_descriptor`
- runtime context plumbing

Two specialty compilation modes are also set here: `parse_only` (build compiled rule-table state without generating handlers or emitting parser code) and `generate_only` (regenerate handlers from an already-compiled rule table without re-parsing). These modes support introspection and tooling workflows that need intermediate compiler artifacts.

The preparation stage also makes diagnostics better. If an invalid option or malformed callback surface is detected before parsing starts, the error can still be attributed to `compiler_pipeline:prepare_pipeline` instead of escaping as an arbitrary low-level failure.

## Stage 2: extract user-function registry

Before ordinary rule validation/bootstrap, the Perl reference extracts top-level user-function definitions into a
registry. This bridge recognizes only top-level `fn name(args) { body }` declarations, parses each body into an
ActionIR action-block AST, and blanks the original source region while preserving newlines. The stripped source
then flows through the existing rule-validation and bootstrap-parser path.

This stage rejects malformed definitions, duplicate function names, reserved names, built-in helper/control-name
collisions including numeric word aliases, invalid or duplicate parameters, and later rule-label collisions. Execution is not done in this
extraction stage; the registry is passed forward so the rule action-lowering stage can resolve value-position
calls.

## Stage 3: validate the source envelope

Before bootstrap parsing, LinkedSpec validates obvious `.spec` source-shape problems through a dedicated validation owner (in the Perl reference backend, `LinkedSpec::Validation` — 1,368 lines, its largest single-purpose validation owner).

This stage exists to reject malformed input early and clearly. The validation owner provides three layers of defense:

**Envelope validation** (`validate_spec_content`): checks the input is a non-empty SCALAR ref, verifies the first content line is a valid rule label, and requires at least one top rule (`RuleName::`) as the parser entry point.

**Paragraph-level validation** (`validate_dsl_syntax`): the deepest layer. It detects duplicate rule definitions, rejects rule definitions inside still-open blocks, checks that action edges (`->`) and blind-call edges (`=>`) have valid target labels and block-depth balance, rejects mixed action/blind-call modes within one rule, validates Perl regex literals for compile-ability, verifies rule-header right-hand-side content, checks split-marker syntax, and reports unused/undefined rule references. When `strict_syntax => 1` is set, unused-rule and undefined-reference warnings become hard errors, which is useful for CI regressions.

**Cross-reference validation** (`validate_dependency_regex_references`): checks that every dependency-regex entry references a rule that exists, every rule reference targets a valid regex index, and every rule's `dependency_refs` entries carry the required `label`/`idx` keys.

Errors from any layer carry structured payloads with `summary`, `detail`, and `rule_label` fields routed through the `on_failure` callback. Context-aware helpers like `get_dsl_context` correlate error positions with line numbers and surrounding source lines.

The high-level principle: malformed input should be rejected with targeted, debuggable messages before it reaches the bootstrap parser, the compiler state models, or (worst) the generated handler runtime.

## Stage 4: bootstrap parse

The bootstrap parser reads the `.spec` source and produces parsed rule entries.

This stage is still special because LinkedSpec uses a bootstrap grammar to parse the language that defines LinkedSpec parsers. That bootstrap layer is owned separately from the main compiler state model.

**Dual-path parse**: LinkedSpec also runs a second parse through the self-hosted `spec.spec` grammar as a diagnostic side channel. `BootstrapSpec::run_bootstrap_parse()` executes both the hardcoded bootstrap parser (always the primary output for format compatibility) and the `spec.spec`-generated parser, enabling cross-check comparisons via `tools/cross_check_spec_parsers.pl`. A recursion guard prevents infinite loops when `spec.spec` tries to parse itself. The self-hosted `spec.spec` is a faithful description of the format the bootstrap recognizes — it reproduces the bootstrap oracle's paragraph grouping across all shipped specs — so the two paths agree on structure even though the hardcoded bootstrap remains the primary parser.

Top-level `fn name(args) { ... }` function definitions are active in `spec.spec`, and the Perl reference records
them through a temporary pre-bootstrap registry bridge before this parse stage. The bridge removes function
definitions from the source handed to the hardcoded bootstrap parser while preserving newlines, then attaches the
validated registry to compiled state. This keeps the permanent grammar owner in `spec.spec` without making the
bootstrap parser the lasting owner of `fn` syntax. The registry is also made available to rule ActionIR lowering,
where registered value calls and standalone discard calls are compiled on the Perl reference.

## Stage 5: build compiled rule-table state

The active low-level compiler seam is:

```text
build_compiled_rule_table(...)
```

Its job is to convert parsed rule entries into `compiled_spec_state`.

That state owns:

- deterministic definition information
- compiled rule order
- the user-function registry used by rule action lowering and descriptor projection
- rules by label
- redefinition metadata
- per-rule compiled info such as regexes, handlers, dependency refs, and rule metadata

This is the compiler’s rule source of truth.

## Stage 6: build dependency-regex state

The next derived stage is:

```text
build_dependency_regex_map(...)
```

Despite the public name, the active internal path can build an explicit `compiled_dependency_regex_state`.

That state is derived from compiled rules. It exists because generated handlers need efficient combined regex dispatch for referenced child-rule regexes.

## Stage 7: build compiled descriptor state

Once compiled rule state and dependency-regex state exist, the compiler builds:

```text
compiled_descriptor_state
```

This internal state composes the two earlier state records.

It is important that validation happens against this internal state before projecting the outward descriptor. That keeps the compiler on explicit, owned structures rather than bouncing back into older loose hash shapes too early.

## Stage 8: validate descriptor state

Generated-descriptor validation checks that the compiled rule state and dependency-regex state agree.

For example, dependency references must point to rules and regex indexes that actually exist.

When validation fails, the compiler can preserve structured attribution such as:

- owner/stage
- selected top rule
- rule label
- handler source label
- specific summary/detail text

## Stage 9: project descriptor or return parser

The final public result depends on options. The entry point shown below (`LinkedSpec::Get(...)`) is the Perl reference backend's surface — see [`Get(...)` and `get_parser(...)`](../public-api/get-and-get-parser.md) for the backend-neutral roles and options.

Default behavior returns a parser coderef:

```perl
my $parser = LinkedSpec::Get(\$spec);
```

Descriptor mode returns the outward descriptor:

```perl
my $descr = LinkedSpec::Get(
  \$spec,
  return_descriptor => 1,
);
```

The outward descriptor is not the compiler’s only internal truth. It is a public/tooling projection of the state-first model.

## Runtime wrapper

Parser invocation is wrapped with a comment and blank-line skip loop. Before each match attempt the wrapper advances the cursor past any leading whitespace-only lines or `#`-to-end-of-line comment lines, so grammar rules do not need to handle these themselves. This skip wrapper is applied at runtime on every generated handler invocation, keeping the grammar surface clean. (In the Perl reference backend this is `Runtime::run_get` advancing `pos($$input_ref)`.)
