"""Complete current book render with a distinguishing CI-heading source fault."""
import copy
import gzip
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "docs/checkpoints/signed-array-perl"))
import common as c
import context
import book as old_book

CI_PAGE = "docs/linkedspec-book/src/development/local-ci-and-regression.md"
MARKER = b"Perl signed-array selector regression"


def save(name, value):
    with (HERE / name).open("xb") as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True) + "\n").encode(), mtime=0))


def render(packets):
    with tempfile.TemporaryDirectory(prefix="signed-ci-book-", dir=os.environ["TMPDIR"]) as folder:
        root = Path(folder)
        assert root.stat().st_dev == ROOT.stat().st_dev
        for path, item in packets.items():
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            raw = c.decode(item["base64"])
            assert c.sha(raw) == item["sha256"]
            target.write_bytes(raw)
            target.chmod(item["mode"])
        command = ["mdbook", "build", "docs/linkedspec-book", "-d", "output"]
        env = {key: value for key, value in os.environ.items() if not key.startswith("MDBOOK_")}
        run = subprocess.run(command, cwd=root, env=env, capture_output=True)
        return dict(command=command, returncode=run.returncode,
            stdout_base64=c.encode(run.stdout), stderr_base64=c.encode(run.stderr),
            page_base64=c.encode((root / "output/dsl/values-containers-and-flow-helpers.html").read_bytes()),
            ci_page_base64=c.encode((root / "output/development/local-ci-and-regression.html").read_bytes()))


epoch = context.snapshot()
packets = {path: c.read(path) for path in c.load("book-inputs.json.gz")["inputs"]}
save("book-inputs.json.gz", dict(context=epoch, inputs=packets,
    scope="Complete current93 book inputs, scalar-kind limitation and CI-registration teaching. All four executable include images stay identical to the sealed signed runtime proof."))
healthy = render(packets)
old_book.validate(healthy, packets)
assert MARKER.decode() in c.decode(healthy["ci_page_base64"]).decode()
assert "prove -Iperl t/signed_array_selector_perl_contract.t" in c.decode(healthy["ci_page_base64"]).decode()
changed = copy.deepcopy(packets)
raw = c.decode(changed[CI_PAGE]["base64"])
assert raw.count(MARKER) == 1
raw = raw.replace(MARKER, b"Changed CI heading", 1)
changed[CI_PAGE].update(base64=c.encode(raw), sha256=c.sha(raw))
save("book-fault-inputs.json.gz", {CI_PAGE: changed[CI_PAGE]})
fault = render(changed)
assert fault["returncode"] == 0 and MARKER.decode() not in c.decode(fault["ci_page_base64"]).decode()
for path in old_book.EXAMPLES:
    assert packets[path] == c.load("book-inputs.json.gz")["inputs"][path]
save("book-runs.json.gz", dict(healthy=healthy, fault=fault, inputs_unchanged=c.unchanged(epoch["inputs"])))
assert c.unchanged(epoch["inputs"])
print("Current book93 PASS; CI heading fault rejects; scalar limitation and four exact unchanged executable sources retained.")
