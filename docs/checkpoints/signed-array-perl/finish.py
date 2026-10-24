"""One-shot bounded live-document handoff before exact staged canonical acceptance."""
import json
import re
import common as c
import context
import control_review
import review

TREE = "docs/tasks/TYPE-REFERENCE-BOOK.md"
PATHS = ("CHANGES.md", "DEVELOPMENT_NOTES.md", "MEMORY.md", "LIVE_ACHIEVEMENT_STATUS.md",
    "ROADMAP.md", "ROADMAP_V2.md", "docs/TASK_TREE.md", TREE)
SUMMARY = ("120 authored native/emitted programs; 12 arithmetic/14 read/33 actual deferred write records; "
    "10 direct suites/789 top-level tests; eight physical source faults with restored controls; "
    "book93/four executed examples/three rendered denials and executed wrong-selector RED; "
    "input3/scope2 actual bypass/restoration. Perl scope only; no portable admission.")


def write(path, text):
    c.source(path).write_text(text)


def prepend(path, record):
    text = c.source(path).read_text()
    index = text.index("\n## ")
    write(path, text[:index] + "\n" + record.rstrip() + "\n" + text[index:])


def main():
    c.write_new("finalization-inputs.json.gz", dict(context=context.snapshot(),
        before={path: c.read(path) for path in PATHS}))
    result, controls = review.check(), control_review.check()
    prepend("CHANGES.md", "## 2026-10-24 — TYPE-REFERENCE-BOOK.1.2.17.2 — Perl signed array selectors\n\n"
        "Ordinary/deferred native and emitted Perl select existing array tails with L+index. Writes normalize against each encountered post-expression array, preserve authored negative prefixes, and distinguish underflow, missing arrays and wrong kinds. A shared callable reader covers single, nested and callable-result paths while preserving float/string coercion boundaries. Existing copy, atomicity, expression order, diagnostic spans and identity guards remain intact. The permanent frozen/public consumer is enrolled in local CI.\n\n"
        "Validation: " + SUMMARY + " Original53 genuine failures per route and the corrected inverse55 become GREEN. Two unsupported infix instruments, the interrupted first fault run, inherited controller pointer and derived reason-order check stay explicitly qualified with complete original sources/channels. Accepted51-image neutral custody precedes runtime changes; frozen authorities stay exact. Current Knowledge/book examples and both roadmap companions agree. Exact staged canonical CI and normal hooks govern landing; Rust17.3 follows clean Git. Read-only: docs/checkpoints/signed-array-perl/publish.py.")
    prepend("DEVELOPMENT_NOTES.md", "## 2026-10-24 — qualify negative Perl selectors at the encountered array\n\n"
        "BindingRuntime accepts negative integer selector kinds before structural validation. A missing-container helper preserves the old invalid-segment diagnostic instead of inferring an array for a negative index; existing arrays use a separate resolved position and retain raw diagnostic keys. Global invalid-kind precedence, the existing post-expression snapshot and isolated commit/copy geometry stay unchanged.\n\n"
        "CodeblockRuntime::_read_array_entry serves indexed_var, nested_access and read_path. Literal source spelling distinguishes -1 from -1.0 when serialized number values both become integer -1; dynamic NV/string values retain their old boundaries. Ordinary bare-binding coercions and retained read receivers remain independent. Callable-result paths retain their existing raw marker1, with no new pure-source classification. Whole source epochs, real callback effects/guard identity, host detachment mutations and actual physical faults/restorations support the bounded Perl extension. The checkpoint README preserves all instrument qualifications. Both roadmap companions now name the same current frontier.")
    text = c.source(TREE).read_text()
    start = text.index('- ID: `' + c.OWNER + '`')
    end = text.index('\n- ID:', start + 1)
    leaf = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
    leaf = leaf.replace('normal task/roadmap/continuity.', 'normal task/roadmap/continuity including ROADMAP_V2.md.', 1)
    leaf += ("\n  Completion: " + SUMMARY + " Read-only publication validates the dated complete source/input population; exact staged canonical receipt and normal hooks govern this commit. No optional whole-backend matrices or portable signed admission are inferred.\n"
        "\n  Owned continuity defect / verified repair: At accepted ed65, ROADMAP_V2.md still points to hygiene21 (last edit92c98fb3) while ROADMAP.md names17.1. This can misdirect a resumed session. The complete additional live-claim census precedes writes and has no intersections. Synchronize both bounded current paragraphs to verified Perl17.2/next Rust17.3 in this leaf; roadmap-census.json.gz retains both original files, exact Git history query and all live records.\n"
        "\n  Review qualification: Sorted-key packet transport reorders map-field failure reasons. The first reader's order-sensitive comparison rejects; every case/reason membership and multiplicity is independently identical across all eight variants. Preserve the original reader/log and normalize only derived field-name reports. Actual outcomes, typed diagnostics and authored effect/case order are unchanged.\n"
        "\n  Acceptance checklist:\n"
        "  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/dump_parser_source retains original53 genuine public signed failures per route, plus separately qualified two invalid instrument sources.\n"
        "  - [x] **ROOT CAUSE (WHY + WHERE)** — BindingRuntime.pm::_selector rejects negative writes; CodeblockRuntime.pm::indexed_var/nested_access/read_path use digit-only reads. Actual Get dump names the callable-result reader; serialized number spelling explains the float boundary.\n"
        "  - [x] **FIX** — Shared bounded callable lookup and encountered-array write normalization preserve missing/underflow distinctions and all earlier evaluation/copy/guard interfaces; enroll the permanent Perl consumer.\n"
        "  - [x] **ADDRESSED (verified)** — Corrected120 native/emitted GREEN, actual inverse55 RED per route, eight physical variants and exact restored controls; all33 frozen writes execute real deferred callbacks and host detachment mutations.\n"
        "  - [x] **NO REGRESSION** — Ten focused suites/789 top-level TAP pass, including old write/map contracts; exact staged canonical Phase0/local-CI receipt is required at commit.\n"
        "  - [x] **LOCKSTEP** — Book93/four native-emitted examples/three source denials and executed wrong selector, Knowledge/history/live pointers and both roadmaps agree; frozen authority bytes remain unchanged.\n")
    text = text[:start] + leaf + text[end:]
    text = text.replace('| 1 | `' + c.OWNER + '` | `active` | Perl ordinary/deferred implementation. |\n', '', 1)
    front = text.index('## Current Frontier')
    tail = text.index('\n## ', front + 1)
    rows = text[front:tail].splitlines()
    index = 0
    for position, row in enumerate(rows):
        if re.match(r'\| \d+ \|', row):
            index += 1
            rows[position] = re.sub(r'^\| \d+ \|', '| ' + str(index) + ' |', row)
    text = text[:front] + '\n'.join(rows) + '\n' + text[tail:]
    write(TREE, text)
    write("MEMORY.md", "# MEMORY\n\n"
        "- activation_commit: `" + c.BASE + "` — clean Perl17.2 base; derive current HEAD from Git.\n"
        "- latest_completed_leaf: `" + c.OWNER + "` — bounded signed reads/writes; exact canonical workflow governs landing.\n"
        "- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.17.3`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.\n"
        "- next_action: From clean Git activate Rust signed ordinary/deferred/native/generated reads/writes17.3. Read the frozen signed authority, public runtime contracts and relevant Knowledge records; preserve source-bound before/after/fault/effect/copy/guard/diagnostic proof and old-v1 consumers. Then17.4–7.\n"
        "- in_flight_uncommitted: none; no background job. Never rerun historical capture writers.\n"
        "- proof: docs/checkpoints/signed-array-perl/publish.py reviews120 native/emitted,12 arithmetic/14 read/33 actual deferred writes,10 suites/789 top-level TAP,eight physical faulty/restored variants,book93/four examples/three rendered denials and input3/scope2 controls. Original infix/epoch/controller-pointer/reason-order qualifications remain explicit. Whole accepted51-image neutral custody precedes changes; frozen authorities stay exact. No optional whole-backend or portable signed admission.\n"
        "- steering: [-n]=[size-n] when size-n>=0; negative selectors never create. After signed17 come14/16/19/raw-regex21/policy20 and complete inventory/references.\n"
        "- limits: Other repositories/submodules read-only black boxes; all project data on-volume. No push until PNT exhausted. Canonical receipts and commit hooks remain the Git acceptance authority.\n")
    text = c.source("LIVE_ACHIEVEMENT_STATUS.md").read_text()
    sections = {
        "Current Activity": "Perl signed-selector17.2 is complete at the exact canonical commit boundary. Rust17.3 is next from clean Git; other backends and portable admission remain separately owned.",
        "Latest Completed Slice": c.OWNER + ": " + SUMMARY + " Whole accepted51-image custody precedes changes; all original instrument qualifications remain explicit. Current book/Knowledge and both roadmap companions agree. Exact staged canonical CI, normal hooks and post-commit pointer checks govern landing.",
        "Next Action": "From clean Git activate Rust17.3 under the same frozen signed authority, then17.4–7. Deferred last14/with16, grouped assignment19, raw-regex21, policy20 and complete inventory/reference work remain owned.",
    }
    for heading, body in sections.items():
        text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda m: m[1] + body + '\n', text, count=1, flags=re.S)
        assert count == 1
    marker = '## Recent Completions\n\n'
    text = text.replace(marker, marker + '- `' + c.OWNER + '` — ' + SUMMARY + '\n', 1)
    begin = text.index(marker) + len(marker)
    end = text.index('\n## History', begin)
    recent = [row for row in text[begin:end].splitlines() if row.startswith('- ')]
    text = text[:begin] + '\n'.join(recent[:16]) + '\n' + text[end:]
    write("LIVE_ACHIEVEMENT_STATUS.md", text)
    current = ("October24 current PNT activity: [TYPE-REFERENCE-BOOK](docs/tasks/TYPE-REFERENCE-BOOK.md) implements Perl signed selectors17.2 after the separate frozen target17.1. " + SUMMARY + " Exact staged canonical CI and normal hooks govern landing; Rust17.3 then17.4–7 follow clean Git. Director rule: [-n] selects [size-n] only when size-n>=0; negative positions never create entries.")
    direction = ("October24 type-reference work: Deferred-write12, signed intake17.0, CLI17.8, neutral target17.1 and Perl17.2 are complete. Rust/Dart/Julia/Lua and admission17.3–7, deferred last14/with16, grouped assignment19, raw-regex21 and policy20 precede complete operation/spelling inventory1.2.1, mapping1.2.2 and layout1.3. Full per-type references and structured-format campaign admission remain unclaimed.")
    for path in ("ROADMAP.md", "ROADMAP_V2.md"):
        text = c.source(path).read_text()
        pattern = r'October(?:23|24) current PNT (?:activity|boundary):[^\n]+'
        text, count = re.subn(pattern, lambda m: current, text, count=1)
        assert count == 1
        text, count = re.subn(r'October(?:23|24) type-reference (?:work|direction):[^\n]+', lambda m: direction, text, count=1)
        assert count == 1
        write(path, text)
    text = c.source("docs/TASK_TREE.md").read_text()
    text, count = re.subn(r'Latest PNT slice: [^\n]+', lambda m: 'Latest PNT slice: ' + c.OWNER + ' — ' + SUMMARY + ' Exact staged canonical CI and normal hooks govern landing; Rust17.3 follows clean Git.', text, count=1)
    assert count == 1
    text = text.replace('`active` / next .1.2.17.2', '`active` / next .1.2.17.3', 1)
    old = 'Separate signed neutral authority/checker17.1 preserves frozen-v1 outcomes/identities and pending book teaching. Perl17.2 then Rust/Dart/Julia/Lua and independent admission17.7 precede remaining gaps and complete references.'
    assert text.count(old) == 1
    text = text.replace(old, 'Perl17.2 implements existing-array signed reads/writes with native/emitted/frozen/copy/guard proof and current book teaching. Rust/Dart/Julia/Lua17.3–6 and independent admission17.7 precede remaining gaps and complete references.', 1)
    write("docs/TASK_TREE.md", text)
    c.write_new("finalization.json.gz", dict(result=result, controls=controls,
        outputs={path: c.read(path) for path in PATHS},
        scope="Intended clean post-landing handoff, staged only after all selected behavior/book/source controls pass. Exact canonical receipt and normal hooks remain mandatory before commit; no canonical success is invented here."))
    print("Bounded live-doc handoff written; exact staged canonical acceptance remains required.")


if __name__ == "__main__":
    main()
