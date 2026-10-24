"""One-shot pending-contract teaching, without current backend admission."""
from pathlib import Path
import common as c

BOOK = "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md"
CARD = "docs/knowledge/signed-array-selector-neutral-contract.md"
HEADING = "#### Target signed-selector contract (backend implementation pending)"
MARKER = "Negative selectors resolve against the array encountered after selector and RHS evaluation."
TABLE = """| Existing array | Selector | Target read | Target write |
| --- | --- | --- | --- |
| `[10,20,30]` | `[-1]` | `30` | Replace the last entry |
| `[10,20,30]` | `[-2]` | `20` | Replace the middle entry |
| `[10,20,30]` | `[-3]` | `10` | Replace the first entry |
| `[10,20,30]` | `[-4]` | `null` | `nested_write_array_underflow` |
| `[]` | `[-1]` | `null` | `nested_write_array_underflow` |"""
before = c.read(BOOK)
text = c.decode(before["base64"]).decode()
old = "The current frozen write boundary still rejects negative selectors. The next implementation slice applies tail-relative array indexes: for size `L`, `[-n]` selects `[L-n]` when `L-n >= 0`. This requested extension is pending; it will preserve dense arrays and reject out-of-range writes."
new = "The current implementations still reject negative writes. A separate target contract now defines tail-relative array indexes: for size `L`, `[-n]` selects `[L-n]` when `L-n >= 0`. Backend implementation and portable admission remain pending; the frozen historical write-v1 authority stays unchanged."
assert text.count(old) == 1
text = text.replace(old, new, 1)
section = HEADING + "\n\n" + (
    "The following table describes the target rule, rather than the current runtime results above. "
    "Its authority is `capability_conformance/signed_array_selector_contract.json`; it introduces no new assignment syntax.\n\n"
) + TABLE + "\n\n" + (
    "A negative selector requires an existing array and an existing position. It cannot create an absent root, "
    "a missing child array, an append position or filler entries. A negative write aimed at missing state retains "
    "`nested_write_segment_invalid` with reason `negative_integer`. Present null or a wrong container kind retains "
    "`nested_write_kind_conflict`. Nonnegative replacement and exact-length append remain unchanged; "
    "quoted `\"-1\"` remains an harray key.\n\n"
) + MARKER + " " + (
    "For example, if the RHS grows `[10,20]` to `[10,20,30]`, an outer `[-1]` write selects the new last position. "
    "Each encountered nested array supplies its own length. Failure discards the isolated structural attempt while "
    "completed expression effects remain. Returned roots, committed bindings, initial trees and aggregate RHS values remain detached.\n\n"
    "The active receiver identity guard still wins before expressions. Expression failures then precede invalid selector kinds; "
    "the structural walk reports its first kind conflict, positive gap, missing negative target or negative underflow. "
    "A negative integer is conditionally valid, so a later globally invalid boolean selector is reported before an earlier latent underflow. "
    "Underflow reports the authored negative `index`, encountered `length`, `resolved_index = length + index`, "
    "the zero-based failing segment, authored Unicode-scalar source span and detached authored-value path prefix. "
    "Unchanged v1 diagnostics retain their existing fields and wording. "
    "Unrelated read coercions and effectful read receiver ordering are outside this extension.\n\n"
)
anchor = "#### Existing parameter and effect behavior"
assert text.count(anchor) == 1 and HEADING not in text
text = text.replace(anchor, section + anchor, 1)
c.write_new("documentation-before.json.gz", {"book": before, "producer": c.read(c.PREFIX + "document.py")})
Path(BOOK).write_text(text)
card = """---
id: signed-array-selector-neutral-contract
title: "Separate signed-index authority preserves frozen write-v1"
answers:
  - "which neutral authority defines tail-relative array selectors"
  - "what diagnostic identifies signed array write underflow"
  - "when does a negative write selector resolve its array length"
  - "does the signed contract admit current backend support"
date: "2026-10-24"
status: target frozen; backend implementation and admission pending
tags: [array, selectors, contract]
evidence: "TYPE-REFERENCE-BOOK.1.2.17.1; docs/checkpoints/signed-array-contract/."
reverify: "bash tools/run_python_project_data.sh tools/check_signed_array_selector_contract.py"
---

# Signed array target

`capability_conformance/signed_array_selector_contract.json` defines integer i<0
on an existing length-L array as L+i, valid only in [0,L). Negative selectors
never create or append. Positive dense writes and quoted harray keys remain.

Writes normalize during the isolated post-expression walk. Existing-array
underflow uses `nested_write_array_underflow` with authored index, encountered
length, resolved_index, segment, authored span and authored-value prefix.
Missing negative targets retain v1's invalid-segment diagnostic. Receiver
identity guard precedes expressions; global invalid kinds precede structure.
Atomicity, expression effects and value detachment remain v1 requirements.

The separate checker pins historical write/map/composition identities unchanged.
This is a neutral target; native/generated backend and portable admission are
owned by TYPE-REFERENCE-BOOK.1.2.17.2–7. Other read coercions/order stay separate.
"""
with Path(CARD).open("x") as output:
    output.write(card)
c.write_new("documentation.json.gz", {"book": c.read(BOOK), "card": c.read(CARD), "scope": "Pending target teaching only; current runtime table/examples remain unchanged."})
print("Documented pending signed contract; no backend admission")
