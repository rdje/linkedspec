"""Make source-line room only after complete rendered bytes and modes match."""
import copy
import json
import re
import common as c
import context
import booklib as b
import document

REGISTRY = "doctrine/readme_stability/routes.jsonl"


def main():
    packets = b.inputs()
    raw = c.decode(packets[b.FLOW]["base64"])
    planned = document.updated(raw)
    surfaces = {row["id"]: row for line in c.source(REGISTRY).read_text().splitlines()
        if (row := json.loads(line)).get("type") == "surface"}
    surface = surfaces["public_reference"]
    paths = {path for pattern in surface["members"] for path in c.ROOT.glob(pattern) if path.is_file()}
    before_lines = sum(len(path.read_bytes().splitlines()) for path in paths)
    limit = surface["limits"]["max_total_lines"]
    delta = len(planned.splitlines()) - len(raw.splitlines())
    count = max(0, before_lines + delta - limit) + 8
    lines = raw.splitlines(keepends=True)
    removable, fence = [], None
    for index, line in enumerate(lines):
        match = re.match(rb"^ {0,3}(`{3,}|~{3,})", line)
        if fence:
            if match and match[1][:1] == fence[:1] and len(match[1]) >= len(fence) and not line[match.end():].strip():
                fence = None
            continue
        if match:
            fence = match[1]
        elif index and re.match(rb"^#{1,6} ", line) and lines[index - 1] == b"\n":
            removable.append(index - 1)
    chosen = set(removable[:count])
    assert len(chosen) == count
    changed_raw = b"".join(line for index, line in enumerate(lines) if index not in chosen)
    assert [line for line in raw.splitlines() if line] == [line for line in changed_raw.splitlines() if line]
    changed = copy.deepcopy(packets)
    changed[b.FLOW].update(base64=c.encode(changed_raw), sha256=c.sha(changed_raw))
    epoch = context.snapshot()
    c.write_new("contain-inputs.json.gz", dict(context=epoch, producer=c.read(c.PREFIX + "contain_book.py"),
        renderer=c.read(b.RENDERER), registry=c.read(REGISTRY), inputs=packets, changed_page=changed[b.FLOW],
        removed_zero_based_lines=sorted(chosen), counts=dict(public_before=before_lines, limit=limit,
            planned_semantic_delta=delta, removed=count)))
    before = b.render(packets)
    c.write_new("contain-original-output.json.gz", before)
    after = b.render(changed)
    assert b.manifest(before) == b.manifest(after)
    assert all(before["files"][path]["base64"] == item["base64"] for path, item in after["files"].items())
    fault = copy.deepcopy(changed)
    heading = b"# Values, Containers, and Flow Helpers"
    assert changed_raw.count(heading) == 1
    fault_raw = changed_raw.replace(heading, b"# Changed literal-kind containment heading", 1)
    fault[b.FLOW].update(base64=c.encode(fault_raw), sha256=c.sha(fault_raw))
    c.write_new("contain-fault-input.json.gz", fault[b.FLOW])
    wrong = b.render(fault)
    assert b.manifest(wrong) != b.manifest(after) and b.page(wrong) != b.page(after)
    assert c.unchanged(epoch["inputs"])
    c.write_new("contain-runs.json.gz", dict(after={k: v for k, v in after.items() if k != "files"},
        after_manifest=b.manifest(after), fault={k: v for k, v in wrong.items() if k != "files"},
        fault_manifest=b.manifest(wrong), fault_page=wrong["files"][b.HTML], inputs_unchanged=True,
        output_files=len(after["files"]), output_bytes=sum(item["bytes"] for item in after["files"].values()),
        complete_bytes_modes_identical=True, planned_public_after=before_lines - count + delta))
    c.source(b.FLOW).write_bytes(changed_raw)
    print("Blank-only source containment:", count, "lines; all", len(after["files"]),
        "rendered files byte/mode-identical; changed heading differs; planned public lines", before_lines - count + delta, flush=True)


if __name__ == "__main__":
    main()
