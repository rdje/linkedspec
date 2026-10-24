"""Complete book input capture, actual examples and rendered-source denials."""
import copy
import html
from html.parser import HTMLParser
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import common as c
import context
import document
import oracle

MARKER = "Signed array selectors in Perl"
SUPPORT = "Perl native and independently emitted execution implement tail-relative reads and writes"
EXAMPLES = {
    "examples/negative-array-current-perl.spec": [30, [10, 20, 30]],
    "examples/negative-array-current-callable-perl.spec": [30, [10, 20, 30]],
    "examples/negative-array-write-perl.spec": [30, [10, 99, 30]],
    "examples/negative-array-write-callable-perl.spec": {"rows": [[1], [99, 3]]},
}


class Code(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.active = False
        self.current = []
        self.blocks = []

    def handle_starttag(self, tag, attrs):
        if tag == "code":
            self.active = True
            self.current = []

    def handle_data(self, data):
        if self.active:
            self.current.append(data)

    def handle_endtag(self, tag):
        if tag == "code" and self.active:
            self.blocks.append("".join(self.current).rstrip("\n"))
            self.active = False


def validate(run, original):
    assert run["returncode"] == 0, "book command"
    page = c.decode(run["page_base64"]).decode()
    assert MARKER in html.unescape(page), "signed heading"
    assert SUPPORT in html.unescape(page), "current Perl support"
    parser = Code()
    parser.feed(page)
    for path in EXAMPLES:
        text = c.decode(original[path]["base64"]).decode().rstrip("\n")
        assert parser.blocks.count(text) == 1, "exact executable source: " + path


def render(packets):
    with tempfile.TemporaryDirectory(prefix="signed-perl-book-", dir=os.environ["TMPDIR"]) as folder:
        root = Path(folder)
        assert root.stat().st_dev == c.ROOT.stat().st_dev
        for path, item in packets.items():
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            raw = c.decode(item["base64"])
            assert c.sha(raw) == item["sha256"]
            target.write_bytes(raw)
            target.chmod(item["mode"])
        command = ["mdbook", "build", "docs/linkedspec-book", "-d", "output"]
        env = {key: value for key, value in os.environ.items() if not key.startswith("MDBOOK_")}
        result = subprocess.run(command, cwd=root, env=env, capture_output=True)
        page = root / "output/dsl/values-containers-and-flow-helpers.html"
        return dict(command=command, returncode=result.returncode,
            stdout_base64=c.encode(result.stdout), stderr_base64=c.encode(result.stderr),
            page_base64=c.encode(page.read_bytes()) if page.exists() else "")


def changed(packets, path, old, new):
    result = copy.deepcopy(packets)
    packet = result[path]
    raw = c.decode(packet["base64"])
    assert raw.count(old) == 1
    raw = raw.replace(old, new, 1)
    packet.update(base64=c.encode(raw), sha256=c.sha(raw))
    return result


def main():
    epoch = context.snapshot()
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
    assert set(EXAMPLES) <= set(packets)
    plan = dict(cases=[dict(id=path, source=c.decode(packets[path]["base64"]).decode(),
        input="x", expected=expected) for path, expected in EXAMPLES.items()])
    c.write_new("book-inputs.json.gz", dict(context=epoch, inputs=packets, plan=plan,
        scope="Whole book configuration/source/recursive include bytes and modes; four exact executable examples, all project data on-volume. Installed mdBook/OS are read-only prerequisites."))
    runs = {route: c.run(["bash", "tools/project_data_run.sh", "perl", "-Iperl",
        c.PREFIX + "perl_probe.pl", route], input=json.dumps(plan).encode()) for route in ("native", "generated")}
    c.write_new("book-runtime.json.gz", runs)
    for route, run in runs.items():
        assert not oracle.check(plan, route, run), route
    healthy = render(packets)
    validate(healthy, packets)
    mutations = {
        "heading": changed(packets, document.FLOW, MARKER.encode(), b"Changed signed heading"),
        "support": changed(packets, document.FLOW, SUPPORT.encode(), b"Perl support is unavailable"),
        "example": changed(packets, "examples/negative-array-write-perl.spec", b"items[-2]=99", b"items[-1]=99"),
    }
    c.write_new("book-fault-inputs.json.gz", dict(overrides={name: {path: item for path, item in value.items()
        if item != packets[path]} for name, value in mutations.items()}))
    faults = {}
    for name, source in mutations.items():
        run = render(source)
        assert run["returncode"] == 0
        try:
            validate(run, packets)
        except AssertionError as error:
            reason = str(error)
        else:
            raise AssertionError("rendered source fault admitted: " + name)
        faults[name] = dict(run=run, rejected=True, reason=reason)
    wrong_plan = copy.deepcopy(plan)
    wrong_plan["cases"] = [row for row in wrong_plan["cases"] if row["id"] == "examples/negative-array-write-perl.spec"]
    wrong_plan["cases"][0]["source"] = c.decode(mutations["example"]["examples/negative-array-write-perl.spec"]["base64"]).decode()
    wrong_runs = {route: c.run(["bash", "tools/project_data_run.sh", "perl", "-Iperl",
        c.PREFIX + "perl_probe.pl", route], input=json.dumps(wrong_plan).encode()) for route in ("native", "generated")}
    c.write_new("book-runs.json.gz", dict(healthy=healthy, faults=faults, wrong_plan=wrong_plan,
        wrong_runs=wrong_runs, inputs_unchanged=c.unchanged(epoch["inputs"])))
    assert all(oracle.check(wrong_plan, route, run) for route, run in wrong_runs.items())
    assert c.unchanged(epoch["inputs"])
    print("Book PASS:", len(packets), "whole inputs; four native/emitted examples; three rendered faults and executed selector fault rejected")


if __name__ == "__main__":
    main()
