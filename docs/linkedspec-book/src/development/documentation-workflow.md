# Documentation Workflow

LinkedSpec needs both public documentation and internal continuity documentation.

Those two documentation families are intentionally separate.

The repository landing page is a third, deliberately smaller surface. Root `README.md` is for stable purpose,
one first-use path, top-level architecture, canonical navigation, contribution/support entry points, and accurate
notices. It is not another public manual, roadmap, status ledger, file inventory, or gate catalog. Route detail to
the book or continuity owner first, then link from README only when that destination is part of stable navigation.

ADR `0063` and `README_POLICY.md` govern that boundary. The adopted budget is at most 128 lines and 6,144 bytes,
derived from a reviewed 105-line / 5,072-byte lossless prototype. The registered `README-STABILITY` doctrine
enforces both limits; raising either requires a new accepted, indexed decision record rather than an ordinary
feature edit. Policy/checker admission was implemented by `README-STABILITY-POLICY.1`, recomposed unchanged and
closed by `.2`, and is checked with:

```bash
bash scripts/check_readme_stability.sh
```

The public book explains LinkedSpec to the outside world. The continuity docs help the project survive crashes, handoffs, and long refactoring sessions.

## Public book

This book is for:

- users
- adopters
- contributors
- evaluators
- future readers outside the immediate implementation loop

It should explain the project clearly and transparently.

The public book lives at:

```text
docs/linkedspec-book/
```

Its job is to answer questions like:

- What is LinkedSpec?
- How do I write and read `.spec` files?
- How do I call `Get(...)` and `get_parser(...)`?
- What does descriptor introspection expose?
- What helper DSL methods exist and why?
- How does compilation work internally?
- How does runtime context and tracing work?
- What shipped material exists?
- What are the real architectural boundaries?

If the outside world needs to understand it, it belongs in the book.

## Internal continuity docs

The repo continuity docs are for:

- crash recovery
- session handoff
- implementation continuity
- commit hygiene

Examples:

- `CHANGES.md`
- `DEVELOPMENT_NOTES.md`
- `MEMORY.md`
- `COMMIT.md`

Continuity docs answer different questions:

- What changed in this slice?
- Why was the implementation shaped this way?
- What should a future session remember after interruption?
- What validation was run before the commit?
- What workflow rules should be followed when committing?

They are optimized for execution continuity, not public onboarding.

## Definition of done

If a slice changes what the outside world needs to understand about LinkedSpec, the book should move too.

If a slice changes implementation continuity, rationale, or crash-recovery knowledge, the continuity docs should move too.

Those two obligations overlap sometimes, but they are not the same obligation.

Examples:

- Adding or renaming a public DSL helper should update the relevant public helper docs and continuity docs.
- Refactoring an internal owner boundary should update the architecture section if the public mental model changes, plus continuity docs.
- Tightening a diagnostics payload should update compiler/runtime docs if users can observe it, plus continuity docs.
- A purely internal cleanup with no public story may only need continuity docs and validation notes.
- A book-only documentation slice still needs continuity docs so future sessions know what public area was expanded.

## mdBook workflow

Build the book with:

```bash
bash tools/run_mdbook_local.sh
```

The wrapper derives the checkout at runtime, keeps default/generated output on the repository filesystem, and
rejects an external `MDBOOK_BUILD__BUILD_DIR` or `-d`/`--dest-dir` before mdBook starts.

The source files live under:

```text
docs/linkedspec-book/src/
```

The generated HTML output goes under:

```text
docs/linkedspec-book/book/
```

When adding a new chapter, update:

```text
docs/linkedspec-book/src/SUMMARY.md
```

When editing existing chapters, keep the chapter in the section where a reader would naturally look first. If a subject crosses boundaries, prefer a short cross-reference over duplicating a long explanation in several places.

## Documentation style

The public book should be:

- explicit about current behavior,
- transparent about historical or legacy surfaces,
- example-heavy for user-facing APIs and DSL methods,
- clear about maturity and caveats,
- honest about current backend limits such as generated Perl handlers,
- organized by reader need rather than implementation accident.

Avoid hiding transitional areas. If a surface is legacy, say so. If a spec is a placeholder, say so. If a chapter is only a map and deeper walkthroughs still need to be written, say so.

## DSL documentation bar

DSL methods need especially strong documentation.

For each public DSL method or method family, the public docs should eventually explain:

- rationale,
- semantics,
- when to use it,
- when not to use it,
- expected input/output shape,
- how it lowers conceptually,
- several worked `.spec` examples,
- interaction with related methods.

New methods are not fully landed until users can understand and adopt them from the docs. Older methods are held to the same bar as they are revisited.

## Continuity update pattern

For each committed slice, continuity docs usually need:

- a `CHANGES.md` entry with concrete changes and validation commands,
- a `DEVELOPMENT_NOTES.md` entry with rationale and future guidance,
- a `MEMORY.md` entry with interruption-safe resume context.

Keep these entries concise but specific. They should tell the next session what happened and what should be done next.

## Validation pattern

For documentation-only book work, run:

```bash
git diff --check
bash tools/run_mdbook_local.sh
```

For implementation work, run the relevant code/spec tests. The full shared gate is:

```bash
bash tools/run_ci_local.sh
```

If validation could not be run, say so in the final answer and record the limitation when appropriate.
