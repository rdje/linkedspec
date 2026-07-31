# ADR 0065: MEMORY records the clean activation commit, while Git owns current HEAD

- Date: 2026-07-30
- Status: accepted; enforcement pending under `MEMORY-COMMIT-POINTER-ENFORCEMENT.1`
- Tags: architecture, memory, continuity, git, commit-workflow, hooks, enforcement, task-tree

## Context

The bounded layer-A `MEMORY.md` template called its stored hash `latest_commit`. `COMMIT.md` requires that file
to be updated and staged before a leaf commit. Historical leaf `LINKEDSPEC-LOW-EFFORT.2` then added a
verification-only post-commit hook whose acceptance criterion requires the stored hash to equal the new `HEAD`.

That equality is not satisfiable by an ordinary Git commit. A commit hash covers its tree, including
`MEMORY.md`; inserting a predicted hash changes the tree and therefore changes the resulting hash. Rewriting
`MEMORY.md` after the commit would make the handoff dirty, and an additional metadata commit would merely create
another new `HEAD` with the same self-reference problem.

Repository history supplies the actual convention. The 31 consecutive first-parent commits from `4a044914`
through `b9c3e676` that contain a parseable hash all store the exact eight-character hash of their immediate
first parent. None stores its own hash. The branch has 2,418 commits and no merge commits at ratification time.
Older spellings such as `(this commit)` or a subject-only value were not machine-verifiable.

## Decision

### 1. Git is the sole authority for current commit identity

The current commit is obtained from `git rev-parse HEAD` or `git log`; a tracked file does not duplicate its own
content-addressed identity. Resume instructions may report the current `HEAD` dynamically, but must not require a
literal self-hash inside that commit.

### 2. Rename the stored field to `activation_commit`

`MEMORY.md` records the clean `HEAD` from which the active leaf was started. The field is named
`activation_commit`, not `latest_commit`, so its meaning remains truthful both immediately before and immediately
after the leaf commit:

- before commit, `activation_commit == HEAD`;
- after a normal leaf commit, the committed value satisfies `activation_commit == HEAD^1`;
- the current commit remains `HEAD`, derived from Git rather than copied into the tree.

LinkedSpec's commit-per-leaf workflow is first-parent based. A future merge workflow must preserve and validate
the first-parent activation boundary explicitly rather than silently broadening this rule to any ancestor.

### 3. Write the remaining resume state for the post-landing handoff

Before committing, the bounded pointer records the completed leaf, its planned commit subject, the next action,
and `in_flight_uncommitted: none` as the state that becomes durable if the commit succeeds. Until the commit
succeeds, the working tree itself and the agent's mandatory pause banner remain the immediate in-flight signal.
The leaf ID in the commit subject is the durable join key; exact landing hash is discovered from Git.

### 4. Enforce one invariant in two phases

A shared checker will parse the same field and produce the same diagnostics in both phases:

- pre-commit is a hard gate over the staged `MEMORY.md` and requires `activation_commit == current HEAD`;
- post-commit is a verification signal over committed `HEAD:MEMORY.md` and requires
  `activation_commit == HEAD^1`.

The post-commit hook cannot undo an already-created commit and therefore remains non-mutating. A failure must
identify the stated value, expected boundary, phase, and recovery action without asking the operator to manufacture
an impossible self-hash. Hermetic tests use only repository-volume disposable state.

### 5. Migrate canonical owners together

Implementation leaf `.1` will update `MEMORY.md`, `MEMORY_ARCHITECTURE.md`, `COMMIT.md`, both hooks as needed,
the shared memory checker, and focused tests as one atomic workflow change. Closeout `.2` will supersede the
contradictory historical acceptance wording and reconcile live/book/Knowledge owners.

## Consequences

- Every stored hash has a knowable value before commit and a stable meaning afterward.
- A clean committed handoff no longer emits a warning on every successful leaf.
- A forgotten or stale activation boundary can be rejected before commit and diagnosed again after commit.
- `MEMORY.md` remains bounded and overwrite-only; no post-commit mutation or metadata-only hash-chasing commit is
  introduced.
- Current-commit identity is never stale because it is derived from Git.
- The existing `latest_commit == HEAD` acceptance sentence is superseded as an invalid invariant, while the
  original goal—detecting resume-pointer drift—remains intact.

## Links

- Owning tree: `docs/tasks/MEMORY-COMMIT-POINTER-ENFORCEMENT.md`
- Memory standard: `MEMORY_ARCHITECTURE.md`
- Commit workflow: `COMMIT.md`
- Historical owner: `docs/tasks/LINKEDSPEC-LOW-EFFORT.md`
- Existing hook fact: `docs/knowledge/memory-post-commit-hook-verification-only.md`
