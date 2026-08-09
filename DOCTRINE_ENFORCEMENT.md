# Doctrine Enforcement Architecture

A portable, **project-agnostic** standard for turning written rules ("doctrines") into
**mechanically enforced** ones — so compliance is *provable and re-checkable*, never a
"trust me" claim. Drop the kit (§8) into any repository and a non-compliant change cannot
land: a local git hook blocks it, and CI (here: the local CI gate) makes it un-mergeable.

> **👉 Adopting this in your project? THIS is the only document you need to follow.** Go straight to
> **§8 — The portable replay manifest**: copy the core files (Group A), adapt a handful of knobs
> (Group B), add your harness's bootstrap pointer (Group C), run the 3 setup commands. Sections 1–7
> are the rationale + the check-script contract; §9 is the honest limits; §10 is this repo's instance.

> One-line thesis: **a doctrine that is not mechanically checked is not enforced — it is a
> suggestion.** The fix is to pair every doctrine with a deterministic check, run all checks
> from one registry/driver, and gate commits + CI on it.

This file is the **4th portable architecture** LinkedSpec adopts, alongside the three it already has:

| # | Portable architecture | Owns | Standard |
|---|---|---|---|
| 1 | **Task-trees** | per-unit work memory (goal/frontier/acceptance/verification) | `docs/TASK_TREE.md` |
| 2 | **Memory-architecture** | durable harness-agnostic agent memory (4 layers) | `MEMORY_ARCHITECTURE.md` |
| 3 | **Knowledge-map** | a retrieval layer over fact cards | `knowledge-map/` |
| 4 | **Doctrine-enforcement** | turning every rule into a mechanically-gated check | **this file** |

All four are **project- and harness-agnostic**. This one is the sibling of `MEMORY_ARCHITECTURE.md` —
that standard mechanizes the *memory* doctrine; this one generalizes the *same E1→E4
defense-in-depth* to **every** doctrine. The enforcement is **git-level** (hooks + the local CI gate),
so it fires identically no matter which harness made the commit.

---

## 0. How to use this file

1. Read it once. Adopt the **check-script contract** (§4) and the **driver+registry** (§5).
2. Copy the agnostic kit (§8): the driver, the hook, the CI step.
3. For each doctrine you want enforced, write a `check_<doctrine>.sh` and register it.
4. Run the three setup commands (§8). From then on, non-compliance fails fast (hook) and cannot
   land (local CI gate).

If you remember one rule: **route every doctrine to a check, register it, gate on the driver.**

---

## 1. The problem

Most doctrines live as prose (a README section, a decision record, a code comment). Prose is
**discoverable but not enforceable** — an agent or human can read it and still ignore it, and
nothing catches the violation until much later (or never). The two failure modes:

- **"Trust me" compliance** — a change claims it followed the rule; no artifact proves it.
- **Silent drift** — a rule erodes one exception at a time because nothing re-checks it.

The cure is not more prose. It is to make the **compliant path the gated path**: every doctrine
gets a check that *re-derives the truth from the repository*, and the gates run that check.

---

## 2. The core idea

> **doctrine = a rule + a deterministic check that exits nonzero on any breach.**

Once a doctrine has such a check, enforcement is mechanical:

- one **driver** runs every registered check and reports per-doctrine PASS/FAIL (§5);
- the **git hook** runs the driver (fast local gate, E3);
- **the CI gate** runs the *same* driver (un-bypassable backstop, E4).

The check is the single source of truth for the rule; the prose doc explains *why*, the check
decides *whether*.

---

## 3. The three check archetypes (pick one per doctrine)

| Archetype | The check… | Proof strength | Cost / where to run | LinkedSpec example |
|---|---|---|---|---|
| **Structural** | re-derives an invariant from the tree (allowlist match, file presence, derived-artifact sync) | a fact about the files — cannot be faked | cheap → pre-commit | "`MEMORY.md` ≤ cap + bootstrap pointers present"; "the derived Knowledge Map is regenerated + staged" |
| **Oracle (re-run)** | re-EXECUTES a deterministic tool at fixed inputs and asserts the result | strongest — a fabricated claim does not reproduce | may be heavy → defer to the CI gate | "`t/phase0_regression.t` reaches its true stop with the expected failing-set"; "the all-spec ActionIR-ready ratio == 1.0000" |
| **Evidence (artifact)** | requires a re-checkable artifact for an action that cannot be re-derived (e.g. *how* a bug was diagnosed) — pasted tool output, ideally with the cited command re-run | medium → strong (strong when the cited command is re-run) | cheap (presence) / heavy (re-run) | "a code change's task leaf carries a tool-backed WHY+WHERE + a measured before→after (see `TOOLBOX.md`)" |

Rule of thumb: prefer **structural** (cannot be faked) → then **oracle** (re-run beats trust) →
use **evidence** only where the thing being enforced is an *action/process* that leaves no other
re-derivable trace. Make evidence checks as oracle-like as possible (re-run the cited command).

---

## 4. The check-script contract (precise — this is what makes it portable)

A doctrine check is **any executable** that obeys this contract:

1. **Exit code is the verdict.** `exit 0` ⟺ the doctrine holds; **any nonzero** ⟺ a breach.
2. **Explain on breach.** On nonzero, print a human-actionable message to **stderr**. On pass, stay
   quiet or print one OK line.
3. **Deterministic.** Same repository state → same verdict. No clocks, no network, no randomness
   (or pin the seed).
4. **Reads the repository (+ `git`), mutates nothing** (a *derive-and-stage* step — like regenerating
   a derived artifact — is allowed but must be idempotent and explicit).
5. **Scope-aware where relevant.** A check about a *change* should look at the staged set
   (`git diff --cached --name-only`) and **exempt** changes it does not govern.
6. **Self-contained + path-agnostic.** Resolve the repo root from the script's own location
   (`ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"`); reference repo-relative paths only.
7. **Fast, or deferred.** If a check is too slow for pre-commit, keep it in the registry but mark it
   CI-only (run the cheap structural proxy locally, the full oracle in the CI gate).

A check that obeys (1)–(7) is portable: the driver does not care what it checks or how.

---

## 5. The registry + driver (the general enforcer)

One driver owns the list of doctrines and runs them all. The **registry is the source of truth**
for "which doctrines are enforced by what"; this file's §10 mirrors it.

- **Registry**: a list of `id | what-it-proves | path/to/check.sh`.
- **Driver**: runs every check (collecting *all* results, not stopping at the first failure), prints a
  per-doctrine report, and exits nonzero iff any failed. It also **meta-checks** that every registered
  check exists and is executable — so a registry entry can never be a dangling promise.
- **Adding a doctrine** = write a `check_*.sh` obeying §4 + add one registry line. Nothing else.

LinkedSpec ships the reference driver at [`scripts/check_doctrines.sh`](scripts/check_doctrines.sh).
The reference EVIDENCE-archetype check is
[`scripts/check_diagnosis_evidence.sh`](scripts/check_diagnosis_evidence.sh): a staged
task-acceptance gate keyed off `TOOLBOX.md`. It checks checklist presence and evidence signatures for
governed staged changes; the phase0/local-CI oracle remains the re-run leg.

---

## 6. The "reasoned-from-evidence" pattern (process made checkable)

The hardest doctrine to enforce is a *process* ("you followed a root-cause procedure and reasoned
from the evidence"). Reframe it into something mechanical:

> **A correct diagnosis is one whose documented cause→fix→effect chain REPRODUCES under
> independent re-execution.**

Mechanize it as a **two-signal evidence check**:

1. **DIAGNOSIS signal (WHY+WHERE)** — the leaf pastes output from the tool that *located and
   explained* the cause (an engine got-value dump, a generated-source line, a `furthest_position`,
   the exact toolbox command — see `TOOLBOX.md`).
2. **VERIFICATION signal (effect)** — the leaf pastes the *measured before→after* (a failing-subtest
   count delta + a `comm` name set-diff, a REJECT→PASS, determinism).

The gate requires **both**; the **oracle leg** re-runs the cited deterministic commands, so a
fabricated chain fails. A reproducible cause→fix→effect chain is, operationally, a correct diagnosis.

### 6.1 A box is EARNED, not ticked (self-ticking is not proof)

A checklist `[x]` an author writes is a **claim**, not proof. **Ticking must never be the proof; the
oracle re-run is.** Three legs of increasing strength: (1) **presence** (the box + a signature exists —
self-tickable, necessary not sufficient); (2) **evidence-shape** (the box co-occurs with a string only
the real tool emits); (3) **oracle re-run** (the gate re-executes the named oracle — e.g. re-running
`t/phase0_regression.t` and the `comm` set-diff — which a self-ticked-but-false box fails). Therefore
every gated box **must cite a NAMED, re-runnable oracle**. **Honest limit:** leg 3 lives at the CI gate
(E4); if the gate is run manually, the un-fakeable re-run only happens at the next run.

---

## 7. Enforcement layering (E1→E4 — defense in depth)

Same model as `MEMORY_ARCHITECTURE.md` §9.

- **E1 — Discovery.** The doctrine is unmissable: named in `README.md`, `TOOLBOX.md`,
  `docs/decisions/`, and the bootstrap pointers (`AGENTS.md`/`CLAUDE.md`). Discovery alone is not
  enforcement.
- **E2 — Self-check.** Each `check_*.sh` (single source of truth for one doctrine) + the driver.
- **E3 — Git hook.** `.githooks/pre-commit` runs the driver; a non-compliant tree cannot commit
  locally. *Honest limit:* a local hook can be `--no-verify`'d or skipped if `core.hooksPath` is not
  set — it catches the common case cheaply; it is **not** the backstop.
- **E4 — CI gate.** The **same** driver runs in `tools/run_ci_local.sh`. **LinkedSpec reality:**
  hosted GitHub Actions is disabled to conserve Actions minutes (`docs/decisions/0004`), so the local
  CI gate is the source of truth — the un-bypassable leg is only as strong as the next local-gate run.
  Re-enabling an auto CI doctrine-gate job is the true "no matter what".

To land non-compliant work, an author would have to defeat all four.

---

## 8. The portable replay manifest (any project, any harness)

### A — CORE, copy VERBATIM (project- and harness-neutral)
| Artifact | Role |
|---|---|
| `scripts/check_doctrines.sh` | the registry+driver — runs every check, reports, exits nonzero on any breach |
| `.githooks/pre-commit` | E3 local gate: regenerate derived artifacts, then run the driver |
| `.githooks/commit-msg` | E3: require a work-unit id in the subject (LinkedSpec scheme — see `COMMIT.md`) |
| `DOCTRINE_ENFORCEMENT.md` | this standard |
| `TOOLBOX.md` | the debug-toolbox catalog + the **acceptance-checklist template** a code change should satisfy |
| `scripts/check_diagnosis_evidence.sh` | reference EVIDENCE check (the task-acceptance gate) |

### B — ADAPT (the only project-specific knobs)
- `scripts/check_doctrines.sh`: the `DOCTRINES=(…)` array (your doctrine ids → your check scripts).
- `TOOLBOX.md`: your project's tools + the required checklist boxes.
- which heavy checks are CI-only vs pre-commit.

### C — DISCOVERY, one bootstrap pointer per harness (identical content; each points at README +
MEMORY_ARCHITECTURE + TOOLBOX + this file): `AGENTS.md`, `CLAUDE.md`, `.cursorrules`,
`.github/copilot-instructions.md`, … Ship whichever harnesses your team uses; keep them in sync.

### D — PER-PROJECT, write your own
- `scripts/check_<doctrine>.sh` per doctrine (the §4 contract) + one registry line in the driver.
- `docs/decisions/<id>.md` for the human "why".

### The three commands (once)
```bash
chmod +x scripts/check_*.sh
git config core.hooksPath .githooks          # activate the local gate (E3)
# the CI leg (E4) already runs the driver via tools/run_ci_local.sh
```

**Harness-agnostic guarantee.** The ENFORCEMENT (A) is git-level: `.githooks/pre-commit` + the local
CI gate run `check_doctrines.sh` regardless of which harness (Claude Code, Codex, Gemini, a human)
made the commit. DISCOVERY (C) is per-harness via the bootstrap pointer files.

---

## 9. Honest limits (state them; do not over-claim)

- **Local hooks are bypassable** (`--no-verify`, unset `hooksPath`). The CI gate is the backstop; with
  hosted CI disabled (`docs/decisions/0004`), enforcement is only as strong as the next local-gate run.
- **Evidence-presence can be gamed** by pasting fake tool output — *unless* the check re-runs the cited
  command. Prefer structural and oracle checks.
- **A check cannot prove intent / understanding** — only that the *artifacts and oracles reproduce*.
- **Goal is expensive-and-visible non-compliance, not literal impossibility** — defense in depth.

---

## 10. The LinkedSpec instance (this repo's registry)

Enforced by [`scripts/check_doctrines.sh`](scripts/check_doctrines.sh) via
[`.githooks/pre-commit`](.githooks/pre-commit) (E3) + `tools/run_ci_local.sh` (E4).

| Doctrine | Archetype | Check | Proves |
|---|---|---|---|
| `MEMORY-ARCH` | structural | `scripts/check_memory_architecture.sh` | the durable 4-layer memory architecture invariants (`MEMORY_ARCHITECTURE.md` §9) |
| `KNOWLEDGE-MAP` | structural | `knowledge-map/scripts/check_knowledge_map.sh` | the derived Knowledge Map is in sync with its fact sources |
| `TASK-TREE-METADATA` | structural | `scripts/check_task_tree_metadata.sh` | completed task trees do not advertise live `Current Frontier` rows, and pending nodes claim neither task-tree-first activation nor another same-tree node as their own commit |
| `TASK-ACCEPTANCE` | evidence | `scripts/check_diagnosis_evidence.sh` | staged governed code/spec/test/tooling changes carry a task-tree acceptance checklist with LinkedSpec-tool evidence signatures |
| `REPO-ROOT-PATHS` | structural | `scripts/check_repo_root_path_portability.sh` | tracked parent-repository text contains no checkout/developer/private-session identity, Rust primary discovery is runtime-rooted, and all five primary commands retain their dynamic anchors |
| `PROJECT-DATA-STORAGE` | structural | `scripts/check_project_data_storage_locality.sh` | tracked project-storage defaults and current documented output commands stay repository-filesystem rooted while explicit caller/inert/tool/system paths remain legal |
| `README-STABILITY` | structural | `scripts/check_readme_stability.sh` | root `README.md` stays within reviewed line/byte budgets and stable landing scope; all 62 reader/overflow routes close across 20 lifecycle-controlled surfaces in the resulting tree; debt growth and threshold increases require their exact owners/decisions |

Deterministic-oracle doctrine run via the broader gate (`tools/run_ci_local.sh`): the phase0
regression suite `t/phase0_regression.t` (the cross-variant baseline + the all-spec ActionIR-ready
invariant, `docs/decisions/0002`) re-executes the real engine, so cited results are independently
re-verified. `TASK-ACCEPTANCE` is intentionally a staged evidence-shape check, not a hook-time
executor for arbitrary Markdown commands.

If `TASK-ACCEPTANCE` fires unexpectedly, inspect the exact staged set with
`git diff --cached --name-only`. The valid exits are to unstage unrelated governed files,
stage/update the owning task-tree checklist, or split the work into a leaf that can carry honest
evidence. Do not satisfy the gate with a dummy checklist: the script can only prove the staged
evidence shape, while focused validation and `tools/run_ci_local.sh` remain the truth test.

To add a doctrine here: write `scripts/check_<id>.sh` (§4 contract), add one line to the driver's
`DOCTRINES` array, and add a row above. The driver's meta-check fails if the script is missing.

---

## 11. Anti-patterns

- ❌ A doctrine that lives only as prose, with no check.
- ❌ "Trust me, I followed the procedure" with no re-checkable artifact.
- ❌ An evidence check that greps for a signature but never re-runs the oracle (fakeable).
- ❌ A registry entry pointing at a check that does not exist (the meta-check catches this).
- ❌ A check with side effects / nondeterminism (then the gate cannot be trusted).
- ❌ Relying on the local hook as the backstop (it is bypassable — the CI gate is the backstop).
- ❌ Over-claiming "impossible to violate" — the honest claim is "expensive, visible, and blocked at every active gate."

---

*This document is itself an instance of the architecture it describes: a portable, in-repo,
git-tracked standard backed by a runnable driver and mechanical gates — adoptable by any project by
following §8.*
