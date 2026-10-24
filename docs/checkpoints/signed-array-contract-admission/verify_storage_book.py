"""Capture the actual complete current book build after storage teaching changes."""
import gzip
import json
from pathlib import Path
import re
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c
import book

PREFIX = "docs/checkpoints/signed-array-contract-admission/"
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
inputs = dict(packets={path: c.read(path) for path in sorted(paths)},
    sources={path: c.read(path) for path in (PREFIX + "verify_storage_book.py", c.PREFIX + "common.py",
        c.PREFIX + "book.py", "tools/run_mdbook_local.sh", "tools/project_data_env.sh", "tools/project_data_run.sh")},
    contract=c.read("capability_conformance/signed_array_selector_contract.json"),
    version=c.run(["mdbook", "--version"]))
with (c.ROOT / PREFIX / "storage-book-inputs.json.gz").open("xb") as output:
    output.write(gzip.compress((json.dumps(inputs, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))
run = c.run(["bash", "tools/run_mdbook_local.sh", "--dest-dir",
    "../../.linkedspec-data/verification/signed-storage-book"])
root = ".linkedspec-data/verification/signed-storage-book/"
pages = {name: c.read(root + name) for name in
    ("development/local-ci-and-regression.html", book.PAGE)} if run["returncode"] == 0 else {}
with (c.ROOT / PREFIX / "storage-book.json.gz").open("xb") as output:
    output.write(gzip.compress((json.dumps(dict(run=run, pages=pages), sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))
assert run["returncode"] == 0
content = book.Content()
content.feed(c.decode(pages["development/local-ci-and-regression.html"]["base64"]).decode())
assert "A new Python checker entrypoint must be enrolled" in "".join(content.text)
assert "hostile scratch/cache overrides" in "".join(content.text)
book.validate(dict(returncode=run["returncode"], page_base64=pages[book.PAGE]["base64"]),
    json.loads(c.decode(inputs["contract"]["base64"])))
assert all(c.read(path) == packet for path, packet in inputs["packets"].items())
print("Current complete book build PASS:", len(paths), "inputs; storage teaching and signed pending table rendered")
