# Design Rationale

LinkedSpec makes a few strong bets. Each one shapes the architecture, the DSL surface, and the project direction.

## 1. Progressive extraction is a first-class parsing style

Many practical parsing jobs are not best modeled as one pure, contiguous, token-stream pass. Real-world inputs often contain large uninteresting regions, variable formatting, and structure that emerges only after you find the right anchor.

LinkedSpec leans into:

- anchor-first parsing (find a strong signature, then parse inward)
- staged interpretation (coarse structure first, fine structure second)
- recursive descent into interesting regions
- extraction-oriented workflows (skip what you don't need)

That is why the project talks about parse modes (`seek` vs `consume`), rule paragraphs, and nested dispatch so much. Those are not incidental details — they are the design center.

The most explicit form of this bet is staged linked parsing. A stage-N spec should not be
forced to parse the whole language in one pass when the useful shape is "easy outer
anchors, hard inner island." The stage can capture the island text with source span and
semantic intent, then a later spec can parse that payload into a deeper AST. Different
payload fields from the same stage may route to different next-stage specs.

The planned authoring marker for those deferred payloads is `parse_job(text_expr,
options)`. It records the parent AST path, node kind, payload kind, exact text, source
span, parser spec identity, optional top rule, insertion policy, and failure policy as
metadata. It is not implemented yet; the design exists so every backend can agree on the
same annotation shape before scheduler code is written.

The scheduler side has the same bias toward explicitness. A staged parser registry
resolves spec ids in a declared order, caches compiled parsers by content and capability
fingerprints, processes jobs in a stable AST-path/source-span/job-id queue, and diagnoses
cycles by repeated active parser/payload/source tuples. That keeps dynamic loading
predictable rather than magical.

This is separate from spec-file inclusion. Inclusion or imports compose spec definitions.
Staged dispatch parses runtime text payloads carried by AST nodes. Both are useful, but
they solve different problems and must remain distinguishable in diagnostics and
descriptors.

The planned import/composition surface follows that split. A file-scope
`import "path.spec" as alias` directive reuses another spec through qualified names like
`alias.Rule`; a file-scope `include "path.spec"` directive structurally merges parsed
spec material into the current unqualified namespace. Neither directive performs runtime
payload parsing. They describe the grammar graph, preserve source provenance, and fail
deterministically on cycles, duplicate aliases, duplicate included rule names, or
ambiguous unqualified references. The current implementation does not yet accept those
directives; the point of the design is to reserve neutral semantics before code.

## 2. Concision matters, but not at the expense of trust

The `.spec` language is intentionally compact. A few lines of rules with attached actions should express a useful parser.

But concision must not hide what is happening. The project direction is toward:

- fewer accidental behaviors (explicit parse modes, explicit rule modes)
- more deterministic validation (reject malformed input early with clear messages)
- clearer runtime ownership (each module owns its state and its diagnostics)
- stronger documentation expectations (every surface explained, every contract explicit)

The same principle governs two planned mutation extensions. They are accepted directions, not current syntax or
runtime behavior.

First, the future-neutral nested-write contract now fixes how assignment may eventually create missing path
containers, but it does not enable that behavior on a backend. The authored form stays ordinary assignment:

```text
document["sections"][0]["title"] = title
document[segment_name][position] = make_value()
```

Every bracket remains an ordinary typed expression. Its evaluated value—not whether the source was a literal or
variable—selects the path kind: string means harray and nonnegative integer means zero-based array. Thus a dynamic
string can select an harray, a dynamic integer can select an array, and quoted `"0"` remains an harray key. A
boolean, null, negative/fractional number, aggregate, or codeblock cannot select a path kind.

One and many segments share one future `assign_nested_access` ActionIR shape; every segment retains its exact
expression and authored half-open Unicode-scalar span. Segments evaluate once from left to right, then the RHS
evaluates once. Only afterward does isolated structural validation begin. An absent root is chosen by the first
segment; a missing intermediate is chosen by the next one. Existing wrong-kind values are never coerced, and arrays
remain dense: an existing index may be replaced and index `length` may append, while a larger gap fails without
inventing null leaves.

Expression failures propagate unchanged. Completed expression side effects are ordinary state: if a segment or
RHS updates the same root binding, the outer write snapshots that post-evaluation value. Success composes the path
write onto it; a later structural failure preserves the completed expression side effect but cannot leave a
partial path build. Successful binding/result/RHS/initial aggregates are detached. Exact syntax and structural
diagnostics identify the authored segment; structural codes distinguish invalid selector, kind conflict, and
dense-array gap.

Reads remain pure and never create a root, child, cache, or other state. Temporary/literal/helper/property roots,
an invented `vivify(...)` helper, and an invented `:=` operator are excluded. Current backends still require every
intermediate container to exist; the neutral contract is implementation input, not a current-feature claim.

Second, LinkedSpec reserves a Ruby-style trailing `!` for a method that genuinely updates its receiver. The only
version-1 candidate is:

```text
tree.map_leaves!() {
    return(normalize(value))
}
```

The current `map_leaves()` returns a rebuilt tree without changing `tree`. The planned `map_leaves!()` will require
a bare named receiver, traverse an isolated snapshot using the receiver's existing root-kind rules, commit the
rebuilt tree only after complete success, rebind `tree`, and return the updated value. The callback's `path` stays
a complete copied root-to-leaf path; `value` stays a scoped value rather than a writable reference. Replacements
are based on the original tree shape and are not recursively revisited in the same call.

`walk_leaves!`, `reduce_leaves!`, function-form bang calls, and arbitrary `!`-suffixed identifiers are not part of
that direction. They would save no meaningful ceremony or would advertise mutation without a distinct coherent
contract. Current nested writes still require every intermediate container to exist, and current parsers do not
accept `map_leaves!`; ADR `0036` and backlog `.19.1-.19.7` own the future neutral and five-backend work.

## 3. Actions are moving toward backend-neutral semantics

Historically, LinkedSpec tolerated raw Perl-shaped behavior inside `.spec` action blocks. The long-term direction is cleaner:

- less raw embedded host-language code in `.spec` files
- more explicit helper DSL (`set(...)`, `return(hash(...))`, `push(...)`)
- canonical ActionIR lowering (helpers lower to a structured intermediate representation)
- portability across backends — the same helper DSL must execute identically in the Perl reference backend, the Rust backend, and any future backend

The goal is not "Perl, but cleaner." The goal is a backend-neutral `.spec` language: one contract, many execution platforms.

The same neutrality applies to staged parsing. The model is not "Perl can load another
parser" or "Rust can call another parser." It is a language-neutral parse-job contract
that any backend can implement: Perl5, Raku, Rust, Julia, Lua, Dart, Zig, Go, or a later
target all receive the same source spans, parser identities, top-rule selection, result
stitching rules, and failure semantics.

The import/composition graph follows the same rule. A backend may use its own module
loader or filesystem APIs internally, but the observable contract is the `.spec`
directive graph: normalized spec identities, alias namespaces, structured includes,
cycle diagnostics, and content-based descriptor fingerprints.

## 4. The compiler is state-first, not hash-first

Internally, the compiler prefers explicit state models over loose hash access:

- `compiled_spec_state` — the rule-table source of truth
- `compiled_dependency_regex_state` — derived regex dispatch data
- `compiled_descriptor_state` — composed state for validation and projection

The outward descriptor (the public `spec`/`dependency_regex_map`/`meta` hash) is a projection, not the compiler's internal working model. This state-first design makes validation, diagnostics, and future backend work cleaner.

## 5. Transparency matters

This project should be explainable — not only what it does, but why:

- why parse modes exist (seek: match anywhere for progressive extraction; consume: match contiguously for strict parsing)
- why compiled state models exist (separate concerns, enable structured validation, project only at the boundary)
- why runtime context exists (carry structured last_error payloads, not raw Perl error strings)
- why diagnostics are structured (owner/stage attribution, rule labels, handler source labels)
- why a backend keeps a thin public facade over focused owner modules (a small public surface; the real work is isolated and replaceable, which keeps each backend's internals from leaking into the `.spec` contract)

Understanding the "why" makes the "what" easier to trust and easier to change later.
