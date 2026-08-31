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

The future-neutral contract now makes those details executable without making the feature current. Hash roots
recurse only through hashes in sorted-key depth-first order; arrays inside them are leaves. Array roots recurse
only through arrays in zero-based depth-first order; hashes inside them are leaves. Every callback gets its own
detached `value` and complete `path`, plus `depth` and the root-kind selector `key` or `index`. The callback's
returned value replaces that leaf. For example, a returned hash beneath a hash root is still a replacement—it is
not traversed again during the same call.

The receiver is protected by binding identity while callbacks run. A callback may update unrelated bindings, and
a function parameter or other scoped binding that happens to use the same spelling is a distinct identity. A
direct assignment, nested write, nested `map_leaves!`, or helper-mediated write to the active receiver itself is a
typed `receiver_mutation_reentrant` failure before the attempted write. Earlier unrelated callback effects remain,
but the receiver does not receive a partial mapped tree. Callback failures likewise propagate unchanged.

Commit and chaining have an explicit order:

```text
count = tree.map_leaves!() {
    return(normalize(value))
}.count_keys()
```

First every callback succeeds, then `tree` is rebound once, then a detached copy of that updated root feeds
`count_keys()`. If that later continuation fails, the already-completed `map_leaves!` commit is not rolled back.
Without a continuation, the detached updated tree is the expression result; statement-position use may discard
the result while retaining the receiver update.

### Composing nested writes with `map_leaves!`

The third future-neutral contract composes the two mechanisms rather than inventing another mutation rule. A
callback may vivify its detached `value` and return the updated result as the leaf replacement. For a hash-root
traversal, an array value is a cross-kind leaf, so this future example invokes the callback once and does not
revisit the newly returned array subtree:

```text
tree.map_leaves!() {
    value[0]["name"] = "normalized"
    return(value)
}
```

If `tree` begins as `{ "leaf" : [] }`, the callback-local nested write builds
`[{ "name" : "normalized" }]`; complete success commits
`{ "leaf" : [{ "name" : "normalized" }] }`. The callback copy, nested-write result, replacement, receiver
commit, and returned root remain detached. Mutating `value` alone still does not write the receiver—the callback
must return the updated value for it to become the replacement.

Writes to an unrelated binding retain ordinary nested-write semantics during the guarded callback interval:

```text
tree.map_leaves!() {
    journal["seen"][0] = path
    return(value)
}
```

The `journal` write commits independently. If a later callback fails, `tree` remains at its pre-call value but the
completed `journal` write persists. If the journal write itself hits an invalid selector, kind conflict, or dense-
array gap, its unchanged nested-write diagnostic aborts the bang call before receiver commit. Only its isolated
structural path is atomic: a segment or RHS side effect completed before that structural failure retains the
write contract's normal semantics.

The receiver guard has earlier precedence than nested-write evaluation:

```text
tree.map_leaves!() {
    tree[invalid_selector()] = failing_rhs()
    return(value)
}
```

Because the target resolves to the active receiver identity, this fails with `receiver_mutation_reentrant` before
`invalid_selector()` or `failing_rhs()` runs. A helper parameter also named `tree` is allowed when it resolves to a
distinct identity; vivifying that local value cannot bypass the guard or write the outer receiver.

After callback success, receiver commit releases the guard before continuation. A continuation helper may then
perform an ordinary nested write to `tree`. If that write fails, its own structural attempt rolls back, but the
earlier mapped receiver value remains committed. This is the same commit-before-continuation rule, now exercised
through both future mechanisms rather than through a generic failing method.

This contract also distinguishes existence from addressability. The authored receiver must be a bare non-reserved
uniform-binding name, and at runtime it must already hold an harray or array. An absent, null, or scalar receiver
gets an exact typed diagnostic rather than implicit creation or a silent `undef`. All syntax, receiver, and
re-entrancy diagnostics retain authored half-open Unicode-scalar spans.

`walk_leaves!`, `reduce_leaves!`, function-form bang calls, and arbitrary `!`-suffixed identifiers are not part of
that direction. They would save no meaningful ceremony or would advertise mutation without a distinct coherent
contract. Current nested writes still require every intermediate container to exist, and current parsers do not
accept `map_leaves!`. The verified non-bang control produces the same value on Perl, Rust, Dart, Julia, and Lua;
changing only the method token to `map_leaves!` remains rejected on all five because their fluent grammars still
accept identifier characters only. The exact composed control returns `{"leaf":[]}` on all six runtime routes;
its bang twin stops before callback nested-write lowering, producing null on Perl/Rust (with the Rust warning) and
generic parser-invocation failure on Dart/Julia/PUC Lua/LuaJIT. ADR `0036`, the two mechanism contracts plus their
shared composition contract under `capability_conformance/`, and backlog `.19.1-.19.7` own the future work.

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
