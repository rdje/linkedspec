# MEMORY — resume pointer (memory layer A; overwrite-only, keep ≤ ~60 lines)

LinkedSpec is a progressive-extraction parser DSL. This file is layer A of
`MEMORY_ARCHITECTURE.md`: the bounded pointer to *now*, not a history log.

## How to resume
- Read `README.md`, `MEMORY_ARCHITECTURE.md`, and `SESSION_BOOTSTRAP.md`.
- Work is tracked under `docs/tasks/` (index: `docs/TASK_TREE.md`); commit per `COMMIT.md`.
- Check `KNOWLEDGE_MAP.md` before re-deriving facts; use `TOOLBOX.md` first for diagnosis.
- No change without an owning task-tree leaf; run `scripts/check_memory_architecture.sh` before commit.

## Current state (OVERWRITE this block each update — do not append)
- latest_completed_leaf: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.0` — exact Perl root-selection seams and safe `.1-.3`
  implementation order are durably mapped and canonically verified without behavior changes.
- latest_commit: `7abbc593` — `FUTURE-PARITY-BACKLOG.9.1.1.2.0 - ratify root rule selection`
  (ahead: 206; push at threshold 300).
- prepared_commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.0 - map Perl root selection`.
- active_work_unit: Perl root-selection preflight `.9.1.1.2.1.0` is complete and canonically verified in the dirty
  tree; its clean commit is the only boundary before implementation `.1.1`.
- next_action: prepare the exact brief, commit `.1.0`, clear and verify the brief, confirm clean, then activate
  `.9.1.1.2.1.1` task-tree-first.
- current_proof: Perl envelope validation requires a marker after finding a rule. Bootstrap preserves order and
  uses `ELABEL`/`ELABEL_INITIAL`, but RuleIR/SpecEntry omit authored `is_top`; Compiler finally chooses explicit
  `top_rule` or row zero. Descriptor order survives without marker identity; emitted v2 label/family plan hardcodes
  the compiler-selected label for direct/traced execution. Unknown explicit selection compiles and fails only at
  `resolve_top_rule_handler`. Direct strict validation remains defined-minus-authored-edge references and rejects
  unreferenced marked Top; Get does not forward strict_syntax. get_parser and primary forward the same selector,
  while request trace already preserves NAME versus `<default>`. Focused CLI is 2/2 twice; generated source 6/6;
  root checker 8/3/3/5 at 1/6 plus 24 mutations; Knowledge Map 595/4,248; four doctrines/mdBook/whitespace pass.
  Canonical CI passes cursor admission 288, primary 63x2, and Phase 0 1,031/1,031 in 632 seconds, exit 0. No
  executable behavior file changed and no background job is running.
- latest_bootstrap_read: 2026-07-18 — full roadmap, repository codebase, mdBook, active task, Knowledge Map,
  Toolbox, ADR `0044`, neutral/admitted references, Dart generated/live/descriptor/CLI seams, and gates reviewed.
- pivot_guard: never pivot while dirty; finish, verify, document, commit, and clean the current leaf first.
- push_policy: do not push mid-PNT unless explicitly instructed or the documented 300-commit threshold is reached.
- environment: always use `perl -Iperl`; clear `PERL5LIB` for phase0. Full phase0 needs a 20-minute timeout; allow
  at least 30 minutes for the complete canonical gate when the machine is under concurrent build load.
  Julia offline verification may use a writable depot stacked before the installed read-only package depot.
- deferred: root selection implementation `.9.1.1.2.1-.6`; generated parser+stimuli `.8.1`; cursor `.9.1.5.6-.9`;
  inter-match gap/named-slot contract `.1-.7` only
  after cursor completion and activation; semantic/MCP `.10.1`; inspector `.13.1`; authoring `.14`/`.15`;
  parenthesis-free conditions; lexical codeblock capture only if justified.
- blockers: none. in_flight_uncommitted: completed/verified behavior-free `.9.1.1.2.1.0` seam-map/docs/KM/live
  slice awaits only its commit. Parked ignored work is untouched.
