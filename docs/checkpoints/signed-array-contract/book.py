"""Source-sensitive pending-contract teaching and actual rendered controls."""
import copy
from html.parser import HTMLParser
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import common as c

BOOK = "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md"
PAGE = "dsl/values-containers-and-flow-helpers.html"
HEADING = "Target signed-selector contract (backend implementation pending)"
MARKER = "Negative selectors resolve against the array encountered after selector and RHS evaluation."


class Content(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.text = []
        self.tables = []
        self.table = None
        self.row = None
        self.cell = None

    def handle_starttag(self, tag, attrs):
        if tag == "table":
            self.table = []
        elif tag == "tr" and self.table is not None:
            self.row = []
        elif tag in ("th", "td") and self.row is not None:
            self.cell = []

    def handle_data(self, data):
        self.text.append(data)
        if self.cell is not None:
            self.cell.append(data)

    def handle_endtag(self, tag):
        if tag in ("th", "td") and self.cell is not None:
            self.row.append("".join(self.cell).strip())
            self.cell = None
        elif tag == "tr" and self.row is not None:
            self.table.append(self.row)
            self.row = None
        elif tag == "table" and self.table is not None:
            self.tables.append(self.table)
            self.table = None


def validate(run, contract):
    assert run["returncode"] == 0, "book build"
    content = Content()
    content.feed(c.decode(run["page_base64"]).decode())
    text = "".join(content.text)
    assert HEADING in text, "pending heading"
    assert MARKER in text, "post-expression normalization"
    reads = {case["id"]: case for case in contract["read_cases"]}
    rows = [["Existing array", "Selector", "Target read", "Target write"]]
    for case_id, selector, action in [
        ("last", "[-1]", "Replace the last entry"),
        ("dynamic_negative", "[-2]", "Replace the middle entry"),
        ("first", "[-3]", "Replace the first entry"),
        ("underflow", "[-4]", "nested_write_array_underflow"),
        ("empty", "[-1]", "nested_write_array_underflow"),
    ]:
        case = reads[case_id]
        array = json.dumps(case["initial_binding"]["value"], separators=(",", ":"))
        result = json.dumps(case["expected_result"], separators=(",", ":"))
        rows.append([array, selector, result, action])
    assert content.tables.count(rows) == 1, "target arithmetic table"


def render(packets):
    with tempfile.TemporaryDirectory(prefix="signed-contract-book-", dir=os.environ["TMPDIR"]) as directory:
        root = Path(directory)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        for path, packet in packets.items():
            raw = c.decode(packet["base64"])
            assert c.sha(raw) == packet["sha256"]
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod(packet["mode"])
        command = ["mdbook", "build", "docs/linkedspec-book", "-d", "output"]
        env = {key: value for key, value in os.environ.items() if not key.startswith("MDBOOK_")}
        result = subprocess.run(command, cwd=root, env=env, capture_output=True)
        return dict(command=command, returncode=result.returncode,
            stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr),
            page_base64=c.encode((root / "output" / PAGE).read_bytes()))


def changed(packets, before, after):
    result = copy.deepcopy(packets)
    packet = result[BOOK]
    raw = c.decode(packet["base64"])
    assert raw.count(before) == 1
    raw = raw.replace(before, after, 1)
    packet.update(base64=c.encode(raw), sha256=c.sha(raw))
    return result


def main():
    available = set(c.paths())
    paths = {path for path in available if path.startswith("docs/linkedspec-book/src/")
        or path == "docs/linkedspec-book/book.toml"}
    pending = list(paths)
    while pending:
        path = pending.pop()
        for include in re.findall(rb"\{\{#include\s+([^}\s]+)\s*\}\}", c.source(path).read_bytes()):
            target = ((c.ROOT / path).parent / include.decode().split(":", 1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert target in available
            if target not in paths:
                paths.add(target)
                pending.append(target)
    packets = {path: c.read(path) for path in sorted(paths)}
    contract = json.loads(c.source("capability_conformance/signed_array_selector_contract.json").read_bytes())
    inputs = dict(packets=packets, contract=c.read("capability_conformance/signed_array_selector_contract.json"),
        producer=c.read(c.PREFIX + "book.py"), version=c.run(["mdbook", "--version"]),
        wrapper=c.read("tools/run_mdbook_local.sh"))
    c.write_new("book-inputs.json.gz", inputs)
    healthy = render(packets)
    validate(healthy, contract)
    tick = bytes([96])
    faults = {
        "pending": changed(packets, HEADING.encode(), b"Signed selectors admitted on all backends"),
        "bounds": changed(packets, tick + b"[-4]" + tick + b" | " + tick + b"null" + tick,
            tick + b"[-4]" + tick + b" | " + tick + b"10" + tick),
        "snapshot": changed(packets, MARKER.encode(), b"Negative selectors resolve before selector and RHS evaluation."),
    }
    c.write_new("book-fault-inputs.json.gz", faults)
    runs = {name: render(value) for name, value in faults.items()}
    denials = {}
    reasons = dict(pending="pending heading", bounds="target arithmetic table", snapshot="post-expression normalization")
    for name, run in runs.items():
        assert run["returncode"] == 0
        try:
            validate(run, contract)
        except AssertionError as error:
            assert str(error) == reasons[name]
            denials[name] = str(error)
        else:
            raise AssertionError("changed book source admitted: " + name)
    assert all(c.read(path) == packet for path, packet in packets.items())
    c.write_new("book-runs.json.gz", dict(healthy=healthy, faults=runs, denials=denials,
        scope="Actual complete-source builds; three altered sources render successfully but violate pending status, target arithmetic or post-expression teaching. No future DSL/backend execution is claimed."))
    print("Book PASS:", len(packets), "complete inputs; three actual source/render denials; target teaching only")


if __name__ == "__main__":
    main()
