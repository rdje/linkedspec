"""Complete book inputs and pure rendering, with repository-local scratch."""
from html.parser import HTMLParser
import importlib.util
from pathlib import Path
import re
import sys
import common as c
import context

FLOW = "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md"
HTML = "dsl/values-containers-and-flow-helpers.html"
RENDERER = "docs/checkpoints/signed-array-perl-ci/contain_book.py"

# Reuse only the pure renderer and manifest helper. Never invoke its historical main.
spec = importlib.util.spec_from_file_location("literal_book_renderer", c.ROOT / RENDERER)
renderer = importlib.util.module_from_spec(spec)
caller_path = sys.path[:]
try:
    spec.loader.exec_module(renderer)
finally:
    sys.path[:] = caller_path
render = renderer.render
manifest = renderer.manifest


def inputs():
    available = set(c.paths())
    names = {path for path in available if path.startswith("docs/linkedspec-book/src/")
        or path == "docs/linkedspec-book/book.toml"}
    pending = list(names)
    while pending:
        path = pending.pop()
        for include in re.findall(rb"\{\{#include\s+([^}\s]+)\s*\}\}", c.source(path).read_bytes()):
            target = ((c.ROOT / path).parent / include.decode().split(":", 1)[0]).resolve().relative_to(c.ROOT).as_posix()
            assert target in available, target
            if target not in names:
                names.add(target)
                pending.append(target)
    return {path: c.read(path) for path in sorted(names)}


class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.blocks = []
        self.text = []
        self.active = None

    def handle_starttag(self, tag, attrs):
        if tag == "code":
            self.active = []

    def handle_data(self, data):
        self.text.append(data)
        if self.active is not None:
            self.active.append(data)

    def handle_endtag(self, tag):
        if tag == "code" and self.active is not None:
            self.blocks.append("".join(self.active).rstrip("\n"))
            self.active = None


def page(run):
    assert run["returncode"] == 0
    return c.decode(run["files"][HTML]["base64"]).decode()
