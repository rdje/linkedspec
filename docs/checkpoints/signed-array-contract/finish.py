"""One-shot continuity closeout; exact staged canonical CI still gates landing."""
from pathlib import Path
import re
import common as c
import review

result = review.check()
summary = "12 arithmetic/14 read/33 write targets,30 exact historical write outcomes,122 fixture denials; five actual physical source faults with healthy/restored controls;book91/three source denials;input3/scope2 bypass/restoration; no backend admission"
paths = ["CHANGES.md", "DEVELOPMENT_NOTES.md", "MEMORY.md", "LIVE_ACHIEVEMENT_STATUS.md",
    "ROADMAP.md", "docs/TASK_TREE.md", "docs/tasks/TYPE-REFERENCE-BOOK.md"]
c.write_new("final-continuity-before.json.gz", dict(
    inputs={path: c.read(path) for path in paths}, result=result,
    producer=c.read(c.PREFIX + "finish.py"),
    scope="Intended accepted handoff; canonical receipt and normal hooks remain required. Prior publications and all runtime/frozen authority sources stay unchanged.",
))
p = Path("docs/tasks/TYPE-REFERENCE-BOOK.md")
text = p.read_text().replace("- Last updated: `2026-10-23`", "- Last updated: `2026-10-24`", 1)
text = text.replace("- Status: `active` / signed contract17.1 next", "- Status: `active` / signed Perl17.2 next", 1)
text = text.replace("Status: `active` / intake17.0 and CLI17.8 complete; contract17.1 next",
    "Status: `active` / intake17.0, CLI17.8 and target17.1 complete; Perl17.2 next", 1)
start = text.index("- ID: `TYPE-REFERENCE-BOOK.1.2.17.1`")
end = text.index("- ID: ", start + 5)
node = text[start:end].replace("Status: `active`", "Status: `completed` / neutral target only", 1)
node += (
    "  Completion: " + summary + ". Read-only: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-contract/publish.py. New underflow code/fields, conditional-negative structural ordering and authored-value path prefixes are frozen before backend writes. Missing negative targets keep the v1 diagnostic; exact historical authorities/checker remain unchanged. Three unpublished builder/capture/document mistakes retain whole original source and distinct exact-source reproduction channels without product RED credit. Whole prior CLI outputs/actual clean readonly0 and72 Git-verified images precede writes; no live intersections. One bounded new Knowledge card/derived map and pending book teaching stay within existing budgets. Exact staged canonical CI and normal hooks govern landing.\n"
    "  Acceptance checklist:\n"
    "  - [x] **REPRODUCE / ISSUE** — Dependency intake17.0 retains LinkedSpec::Get/return_descriptor/dump_parser_source/native/fresh differences before runtime edits; this leaf defines their separately owned neutral target.\n"
    "  - [x] **ROOT CAUSE (WHY + WHERE)** — Frozen write-v1 rejects every negative selector; the separate signed model qualifies existing array positions during the post-expression structural walk while preserving all30 old outcomes.\n"
    "  - [x] **FIX** — Freeze a separate authority/checker with exact underflow/invalid/kind/gap/guard boundaries, arithmetic, read purity, effects and detachment. Runtime implementation remains17.2–6; portable admission remains17.7.\n"
    "  - [x] **ADDRESSED (verified)** — Five actual altered physical model sources exit1 at independent authored controls,122 fixture mutations reject, three changed book sources render but fail, and input3/scope2 controls distinguish actual bypass/restoration.\n"
    "  - [x] **NO REGRESSION** — All frozen-v1 outcome tuples and byte/digest identities agree; old write/map neutral checkers, current public-surface and capability consumers pass. Exact canonical receipt and normal hooks govern acceptance.\n"
    "  - [x] **LOCKSTEP** — Explicit pending book table/status/snapshot teaching, canonical Knowledge card/map, source-bound claim, roadmap/index/task/live pointer agree. No backend or generated support is inferred.\n"
    "  Commit: `TYPE-REFERENCE-BOOK.1.2.17.1 - freeze signed array selector target contract`\n\n"
)
text = text[:start] + node + text[end:]
text = text.replace("| 1 | `TYPE-REFERENCE-BOOK.1.2.17.1` | `active` | Freeze new signed authority/checker with historical-v1 boundary. |\n", "", 1)
for number in range(2, 8):
    text = text.replace("| " + str(number) + " | `TYPE-REFERENCE-BOOK.1.2.17." + str(number) + "`",
        "| " + str(number - 1) + " | `TYPE-REFERENCE-BOOK.1.2.17." + str(number) + "`", 1)
p.write_text(text)

def prepend(path, record):
    p = Path(path)
    text = p.read_text()
    position = text.index("\n## ")
    p.write_text(text[:position] + "\n\n" + record.rstrip() + "\n" + text[position:])

prepend("CHANGES.md", """## 2026-10-24 — TYPE-REFERENCE-BOOK.1.2.17.1 — freeze signed array target

Separate pending signed-selector authority/checker defines L+i for a negative integer on an existing length-L array. Negative positions never create or append; positive dense writes and quoted keys stay unchanged. Freeze underflow identity/fields, authored diagnostic prefixes/spans, post-expression normalization, guard/invalid/structural precedence and value detachment before backend changes. Historical write/map/composition bytes, statuses, digests and old checker stay exact.

Validation: """ + summary + """. Original instrument mistakes remain separate qualified packets, with no product RED credit. Whole accepted CLI publication, actual clean readonly0 and72 independently Git-verified images precede writes. Old neutral/public/capability consumers pass; one bounded new card and pending table render agree with the target. Exact staged canonical CI and normal hooks govern landing. Runtime/generated children17.2–6 and admission17.7 follow clean Git. Read-only: docs/checkpoints/signed-array-contract/publish.py.""")
prepend("DEVELOPMENT_NOTES.md", """## 2026-10-24 — signed selectors qualify against encountered existing arrays

A negative integer is conditionally valid, so global invalid typed selectors still precede the structural walk. The walk qualifies L+i against each encountered post-expression array; existing-array underflow, absent negative target, kind conflict and positive gap remain distinct. An absent-root negative fixture retains its exact v1 error. Prefix diagnostics retain authored evaluated negative values, independently of normalized offsets. Existing messages/fields remain stable; only underflow adds index/length/resolved_index.

The separate model reuses the identity-checked v1 source parser and unchanged diagnostics, without pretending to interpret DSL expressions. Fixture observations supply completed expression values/effects. Authored state/effect/diagnostic targets and five actual physical source faults distinguish blanket rejection, clamping, early snapshot, guard bypass and returned-root aliasing. Full frozen-v1 tuples match; backend/native/generated execution remains separately owned. Three unpublished instrument failures are preserved and qualified rather than counted as product RED. Default publication is read-only and binds all retained producers/inputs; pending public teaching is source-sensitive.""")
Path("MEMORY.md").write_text("""# MEMORY

- activation_commit: `""" + c.BASE + """` — clean signed target17.1 base; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.17.1` — signed neutral authority/checker; exact canonical workflow governs landing.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.17.2`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean Git activate Perl signed ordinary/deferred/native/fresh reads/writes17.2; read the frozen signed authority and Toolbox, preserve source-bound before/after/inverse/effect/copy/guard diagnostics and old-v1 consumers. Then17.3–7.
- in_flight_uncommitted: none; no background job. Neutral17.1 is committed; backend implementation/admission remains pending. Never rerun historical capture writers.
- proof: docs/checkpoints/signed-array-contract/publish.py is read-only by default:12 arithmetic/14 read/33 write,30 exact old outcomes,122 fixture/five actual source denials,book91/three denials and input3/scope2 controls; prior72-image custody. Three instrument qualifications earn no product RED.
- steering: [-n]=[size-n] when size-n>=0; negative selectors never create. After signed17 come14/16/19/raw-regex21/policy20 and complete inventory/references.
- limits: Frozen write/map/composition/checker identities remain unchanged. Other repositories/submodules read-only black boxes; all data on-volume. No push until PNT exhausted.
""")
live = Path("LIVE_ACHIEVEMENT_STATUS.md")
old = live.read_text()
history = old[old.index("## History"):]
recent = [line for line in old.splitlines() if line.startswith("- `") and " — " in line]
recent = ["- `TYPE-REFERENCE-BOOK.1.2.17.1` — " + summary + "."] + recent
live.write_text("""# LIVE ACHIEVEMENT STATUS

## Current Activity

Signed-selector17 remains active. Neutral target17.1 is complete after CLI17.8; Perl17.2 is next before Rust/Dart/Julia/Lua and independent portable admission.

## Latest Completed Slice

TYPE-REFERENCE-BOOK.1.2.17.1: """ + summary + """. Whole prior CLI custody precedes writes; three instrument mistakes remain qualified. Exact staged canonical CI/normal hooks govern admission.

## Next Action

From clean Git activate Perl17.2 under the separate signed authority, preserving frozen-v1 identity and current consumer coverage. Then17.3–7;14/16/19/21/20 and complete inventory/reference work remain owned.

## Recent Completions

""" + "\n".join(recent[:16]) + "\n\n" + history)
p = Path("ROADMAP.md")
text = p.read_text()
text = re.sub(r"October23 current PNT activity: .*", "October24 current PNT activity: [TYPE-REFERENCE-BOOK](docs/tasks/TYPE-REFERENCE-BOOK.md) freezes the separate signed target17.1 after CLI17.8. " + summary + ". Exact staged canonical workflow governs landing; Perl17.2 then owned17.3–7 are next. Director rule: [-n] selects [size-n] only when size-n>=0; negative positions never create entries.", text, count=1)
text = re.sub(r"October23 type-reference work: .*", "October24 type-reference work: Deferred-write12, signed intake17.0, CLI17.8 and neutral target17.1 are complete. Backend/admission17.2–7, deferred last14/with16, grouped assignment19, raw-regex21 and policy20 precede complete operation/spelling inventory1.2.1, mapping1.2.2 and layout1.3. Full per-type references and structured-format campaign admission remain unclaimed.", text, count=1)
p.write_text(text)
p = Path("docs/TASK_TREE.md")
text = p.read_text()
text = re.sub(r"Latest PNT slice: .*", "Latest PNT slice: TYPE-REFERENCE-BOOK.1.2.17.1 freezes the separate signed target: " + summary + ". Exact staged canonical workflow governs landing; Perl17.2 follows clean Git.", text, count=1)
text = text.replace("`active` / next .1.2.17.1", "`active` / next .1.2.17.2", 1)
text = text.replace("P1 CLI17.8 observes both failure channels; fixed11-pair/22-command proof, actual permanent inverse/restoration and current book/source controls. Signed neutral contract17.1 then owned backend/admission17.2–7 precede remaining gaps and complete references.",
    "Separate signed neutral authority/checker17.1 preserves frozen-v1 outcomes/identities and pending book teaching. Perl17.2 then Rust/Dart/Julia/Lua and independent admission17.7 precede remaining gaps and complete references.", 1)
p.write_text(text)
c.write_new("finalization.json.gz", dict(result=result, summary=summary,
    producer=c.read(c.PREFIX + "finish.py"),
    scope="Continuity only; canonical proof and normal hooks remain required before accepted commit. No runtime/backend admission."))
print("Neutral17.1 closeout prepared; exact staged canonical CI is next")
