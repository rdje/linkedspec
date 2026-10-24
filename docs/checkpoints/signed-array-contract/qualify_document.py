"""Preserve and repair a pre-publication Markdown escaping mistake."""
from pathlib import Path
import common as c

path = c.PREFIX + "document.py"
book = "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md"
before = c.read(path)
book_before = c.read(book)
assert not (c.ROOT / c.PREFIX / "documentation.json.gz").exists()
run = c.run(["bash", "tools/run_python_project_data.sh", path])
assert run["returncode"] == 1 and b"AssertionError" in c.decode(run["stderr_base64"])
assert c.read(path) == before and c.read(book) == book_before
raw = c.decode(before["base64"])
escaped = bytes([92, 96])
assert escaped in raw
c.write_new("document-qualification.json.gz", dict(
    producer_before=before, book_before=book_before, reproduction=run,
    scope="The authored actor accidentally retained JavaScript template escaping before Markdown backticks. Its exact-text assertion stopped before any book/card output. This separate reproduction retains actual warnings/channels; no product, book-render or falsifier credit. Remove only those escaping bytes before the first documentation write.",
))
Path(path).write_bytes(raw.replace(escaped, bytes([96])))
print("Qualified pre-write document escaping; no book/runtime result changed")
