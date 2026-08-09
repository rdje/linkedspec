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

Routing-pressure revision `.4.0` audited the next boundary before changing that checker. Implementation `.4.1`
adds `doctrine/readme_stability/routes.jsonl` and an unconditional core-Perl resulting-tree check. It classifies
reader navigation separately from author-overflow destinations, follows routes transitively, assigns
lifecycle-specific controls, and records legacy high-water marks as debt rather than healthy targets. Every focused run now
proves 62 exact routes over 20 surfaces and all 32 mutation classes before the README doctrine can pass.

The audit also found and traced a stale root `test_input/` layout entry introduced during the original README
trim. LinkedSpec's current fixture roots are `t/` and `tests/`; `.4.1` removes the false route and checks every local
target for existence and symlinks. Four already-large neighboring families—live status, task evidence, changes, and engineering
notes—have a separate `LIVE-DOCUMENT-PRESSURE-CONTAINMENT` owner so the README revision does not silently bless
their present size or mix semantic migration into doctrine admission.

The implementation's definitive local gate passes all seven doctrines, repository containment and moved-root
proof, primary CLI 66/66 in both option environments, and Phase 0 1,031/1,031 in 694 seconds. This closes
implementation signoff without changing parser, runtime, backend, fixture, MCP, or CLI behavior.

Closeout `.4.2` then byte-compares the seven admitted policy/README/registry/checker/doctrine/gate owners with
commit `5c570719` and reruns the full proof without a replacement implementation. The independent gate passes
primary CLI 66/66 twice and Phase 0 1,031/1,031 in 673 seconds, closing routing-pressure revision `.4` unchanged.
`LIVE-DOCUMENT-PRESSURE-CONTAINMENT.0` is the next documentation-sustainability owner after atomic clean handoff.

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

## Commit identity and the resume pointer

A tracked file cannot contain the literal hash of the Git commit that contains it: changing that literal changes
the tree and therefore changes the content-addressed commit identity. Current commit identity belongs to Git and
is obtained with `git rev-parse HEAD` or `git log`, never copied back into the same commit.

ADR `0065` adopts a satisfiable boundary for `MEMORY.md`. The bounded pointer names the clean
`activation_commit` from which a leaf started. That value equals `HEAD` while the leaf is being prepared and
equals `HEAD^1` after its normal commit lands. The leaf ID in the commit subject is the durable join key from the
activation boundary to the landing commit. Before committing, the rest of `MEMORY.md` is written as the intended
clean post-landing handoff: completed leaf, next action, and no uncommitted work.

`MEMORY-COMMIT-POINTER-ENFORCEMENT.0` ratifies this contract, and `.1` implements it through one
read-only phase-aware checker. The pre-commit hook is a hard gate over staged `MEMORY.md` and current
`HEAD`. The post-commit hook is a non-mutating verification signal over committed `HEAD:MEMORY.md`
and `HEAD^1`. The canonical local gate uses an automatic mode that selects a worktree, staged, or clean
committed view and rejects ambiguous staged-plus-unstaged pointer edits. Hermetic tests cover the initial
`root` sentinel, ordinary success, malformed/duplicate fields, genuine drift, and phase ambiguity.
Closeout `.2` independently recomposed the committed checker, both hook views, all eleven cases, and the current
and historical documentation owners without implementation change; it found no current contradiction and made
the only two unqualified historical task statements point explicitly to ADR `0065`.

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
