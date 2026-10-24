"""Before-change live-claim census and exact companion-roadmap drift evidence."""
import json
import subprocess
import common as c

paths = {"ROADMAP.md", "ROADMAP_V2.md"}
records = {}
for path in subprocess.check_output(["git", "ls-files", "docs/claims"], cwd=c.ROOT).decode().splitlines():
    value = json.loads(c.source(path).read_bytes())
    live = [claim for claim in value["claims"] if claim["durability"].get("status") == "checked"
        and claim["durability"].get("mode") == "live"]
    if live:
        names = {item["path"] for claim in live for item in claim["durability"]["inputs"]}
        assert not paths & names, (path, paths & names)
        records[path] = dict(packet=c.read(path), inputs=sorted(names))
assert c.source("ROADMAP_V2.md").read_bytes() == subprocess.check_output(
    ["git", "show", c.BASE + ":ROADMAP_V2.md"], cwd=c.ROOT)
assert "October23 current PNT boundary: REPO-HYGIENE.21" in c.source("ROADMAP_V2.md").read_text()
assert "October24 current PNT activity:" in c.source("ROADMAP.md").read_text()
c.write_new("roadmap-census.json.gz", dict(producer=c.read(c.PREFIX + "census_extension.py"),
    before={path: c.read(path) for path in sorted(paths)}, live_records=records,
    last_companion_commit=c.run(["git", "log", "-1", "--format=%H %s", "--", "ROADMAP_V2.md"]),
    scope="At accepted ed65 the companion's latest status still points to hygiene21 while ROADMAP.md names completed17.1. Own and repair this bounded continuity defect under17.2 by synchronizing both current paragraphs before landing; no roadmap priority changes or dirty task pivot."))
print("Companion-roadmap sync owned; full live census has no intersections:", len(records), "records")
