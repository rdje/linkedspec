"""Render the complete current book with the newly disclosed producer limitation."""
import base64
import gzip
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "docs/checkpoints/signed-array-perl"))
import common as c
import context
import book


def save(name, value):
    with (HERE / name).open("xb") as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True) + "\n").encode(), mtime=0))


epoch = context.snapshot()
packets = {path: c.read(path) for path in c.load("book-inputs.json.gz")["inputs"]}
save("book-inputs.json.gz", dict(context=epoch, producer=c.read("docs/checkpoints/perl-literal-number-intake/book.py"),
    inputs=packets, scope="Complete current93 book inputs, including the explicit pre-existing whole-float/boolean producer limitation. Four executable includes remain byte-identical to the sealed signed proof. No producer repair/admission."))
render = book.render(packets)
book.validate(render, packets)
page = c.decode(render["page_base64"]).decode()
assert "Current callable literal-kind limitation" in page
assert "pre-existing producer defect" in page
for path in book.EXAMPLES:
    assert packets[path] == c.load("book-inputs.json.gz")["inputs"][path]
save("book-runs.json.gz", dict(run=render, inputs_unchanged=c.unchanged(epoch["inputs"])))
assert c.unchanged(epoch["inputs"])
print("Current book93 render PASS; explicit scalar-kind limitation and four unchanged executable sources present.")
