"""Check scope admission, provenance, integrity, and unknown-growth rejection."""
import hashlib
import json
from reference_scope import AUTHORITY, INDEX, build, canonical, verify

OWNER = "REPAIR.1"


class Memory:
    def __init__(self, current, old=None, selected=OWNER):
        self.current = dict(current)
        self.old = dict(old or {})
        self.paths = set(current)
        self.base = "a" * 40
        self.selected = selected

    def read(self, path):
        return self.current[path]

    def head(self, path):
        return self.old.get(path)

    def selected_owner(self):
        return self.selected

    def owner_exists(self, owner):
        return owner in (OWNER, "OTHER.1")


def rejected(snapshot, reason):
    try:
        verify(snapshot)
    except ValueError as error:
        assert reason in str(error), (reason, error)
    else:
        raise AssertionError("accepted invalid scope: " + reason)


def replace_row(files, change):
    root_lines = files[INDEX].splitlines()
    descriptor = json.loads(root_lines[1])
    page = descriptor["path"]
    rows = [json.loads(line) for line in files[page].splitlines()]
    change(rows[1])
    raw = b"".join(canonical(row) for row in rows)
    files[page] = raw
    descriptor.update(sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw))
    files[INDEX] = root_lines[0] + b"\n" + canonical(descriptor) + b"".join(
        line + b"\n" for line in root_lines[2:])


def main():
    tick = chr(96)
    files = {
        "doctrine/readme_stability/routes.jsonl": canonical({
            "type": "surface", "id": "knowledge_cards", "control": "scoped_reference",
            "members": ["docs/knowledge/*.md"],
            "limits": {"max_bytes_per_file": 65536, "max_lines_per_file": 512}}),
        AUTHORITY: ("- Status: accepted\n- Scope adoption owner: " + tick + OWNER + tick + "\n").encode(),
    }
    for index in range(129):
        files[f"docs/knowledge/fact-{index:03d}.md"] = f"fact{index}\n".encode()
    initial = Memory(files)
    generated = build(initial, OWNER)
    files.update(generated)
    current = Memory(files)
    assert verify(current) == (129, 2)
    assert build(current, OWNER) == generated
    old = dict(files)

    candidate = dict(files)
    candidate["docs/knowledge/unindexed.md"] = b"new\n"
    rejected(Memory(candidate, old), "missing or unindexed")
    candidate = dict(files)
    candidate["docs/knowledge/fact-000.md"] = b"changed\n"
    rejected(Memory(candidate, old), "stale maintained-reference")
    adopted = build(Memory(candidate, old), OWNER)
    candidate.update(adopted)
    assert verify(Memory(candidate, old)) == (129, 2)
    candidate = dict(files)
    candidate.pop("docs/knowledge/fact-000.md")
    rejected(Memory(candidate, old), "missing or unindexed")
    try:
        build(Memory(candidate, old), OWNER)
    except ValueError as error:
        assert "retirement" in str(error)
    else:
        raise AssertionError("silently retired a canonical unit")

    candidate = dict(files)
    candidate["doctrine/readme_stability/reference-scope/rogue.jsonl"] = b"{}\n"
    rejected(Memory(candidate, old), "unknown or missing")
    candidate = dict(files)
    first_page = json.loads(candidate[INDEX].splitlines()[1])["path"]
    candidate[first_page] += b"changed\n"
    rejected(Memory(candidate, old), "digest/count")
    candidate = dict(files)
    replace_row(candidate, lambda row: row.update(bytes=str(row["bytes"])))
    rejected(Memory(candidate, old), "member schema")
    candidate = dict(files)
    replace_row(candidate, lambda row: row.update(owner="OTHER.1"))
    rejected(Memory(candidate, old), "foreign scope owner")
    candidate = dict(files)
    replace_row(candidate, lambda row: row.update(sha256="0" * 64))
    rejected(Memory(candidate, old), "stale maintained-reference")
    candidate = dict(files)
    candidate[AUTHORITY] = candidate[AUTHORITY].replace(b"accepted", b"proposed")
    rejected(Memory(candidate), "accepted adoption")
    candidate = dict(files)
    header, *descriptors = [json.loads(x) for x in candidate[INDEX].splitlines()]
    header["baseline_commit"] = "b" * 40
    candidate[INDEX] = b"".join(canonical(x) for x in (header, *descriptors))
    rejected(Memory(candidate, old), "adoption boundary")
    candidate = dict(files)
    header, *descriptors = [json.loads(x) for x in candidate[INDEX].splitlines()]
    header["update_owner"] = "OTHER.1"
    candidate[INDEX] = b"".join(canonical(x) for x in (header, *descriptors))
    rejected(Memory(candidate, old), "unchanged scope provenance")
    print("reference-scope controls: PASS admission, paging, identity, numeric kinds, provenance, loss and unknown growth")


if __name__ == "__main__":
    main()
