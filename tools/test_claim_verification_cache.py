"""Exercise immutable claim reads, bounded caching and current-owner snapshot rules."""
import collections
import contextlib
import hashlib
import io
import json
from pathlib import Path
import runpy

ROOT = Path(__file__).resolve().parent.parent
module = runpy.run_path(str(ROOT / "tools/check_claim_verification.py"), run_name="claim_cache_test")
InputSnapshot = module["InputSnapshot"]


class Store:
    def __init__(self):
        self.blobs = {}
        self.historical = {}
        self.calls = collections.Counter()

    def blob(self, raw):
        identity = hashlib.sha1(raw).hexdigest()
        self.blobs[identity] = raw
        return identity

    def git(self, *args):
        self.calls[args[0]] += 1
        if args[0] == "cat-file":
            return self.blobs[args[2]]
        if args[0] == "ls-tree":
            revision, source = args[2], args[4]
            if (revision, source) not in self.historical:
                return b""
            mode, kind, identity = self.historical[revision, source]
            return f"{mode} {kind} {identity}\t{source}".encode() + b"\0"
        if args[0] == "diff":
            return b""
        raise AssertionError(args)


def reject(function, reason):
    try:
        function()
    except ValueError as error:
        assert reason in str(error), str(error)
    else:
        raise AssertionError("accepted invalid input: " + reason)


def legacy_read(store, files, source, revision=None):
    # Frozen pre-cache resolver: path/mode/kind checks and one Git blob read per call.
    module["path"](source)
    if revision is None:
        module["require"](source in files, "untracked input")
        mode, identity = files[source]
    else:
        rows = store.git("ls-tree", "-z", revision, "--", source).split(b"\0")
        module["require"](len(rows) == 2 and rows[0], "missing historical input")
        header, name = rows[0].split(b"\t", 1)
        mode, kind, identity = header.decode().split()
        module["require"](kind == "blob" and name.decode() == source, "historical input is not a file")
    module["require"](mode in ("100644", "100755"), "input is not a tracked regular file")
    return store.git("cat-file", "blob", identity)


def main():
    store = Store()
    a, b = store.blob(b"alpha"), store.blob(b"bravo")
    files = {"producer.py": ("100644", a), "alias.py": ("120000", a)}
    store.historical["a" * 40, "producer.py"] = ("100644", "blob", a)
    store.historical["b" * 40, "producer.py"] = ("100755", "blob", b)
    snapshot = InputSnapshot(files, store.git)
    for _ in range(20):
        assert snapshot.read("producer.py", "a" * 40) == b"alpha"
    cached_calls = dict(store.calls)
    assert cached_calls == {"ls-tree": 1, "cat-file": 1}, cached_calls
    store.calls.clear()
    expected = [legacy_read(store, files, "producer.py", "a" * 40) for _ in range(20)]
    assert expected == [b"alpha"] * 20
    legacy_calls = dict(store.calls)
    assert legacy_calls == {"ls-tree": 20, "cat-file": 20}, legacy_calls
    assert snapshot.read("producer.py", "b" * 40) == b"bravo"
    assert snapshot.read("producer.py") == b"alpha"
    reject(lambda: snapshot.read("alias.py"), "not a tracked regular file")
    reject(lambda: snapshot.read("missing.py"), "untracked input")
    reject(lambda: snapshot.read("../escape"), "unsafe repository-relative path")
    reject(lambda: snapshot.read("missing.py", "a" * 40), "missing historical input")
    store.historical["c" * 40, "producer.py"] = ("040000", "tree", a)
    reject(lambda: snapshot.read("producer.py", "c" * 40), "historical input is not a file")

    files["producer.py"] = ("100644", b)
    assert snapshot.read("producer.py") == b"alpha"
    assert InputSnapshot(files, store.git).read("producer.py") == b"bravo"

    limited = InputSnapshot({"a": ("100644", a), "b": ("100644", b)}, store.git, cache_bytes=8)
    count = store.calls["cat-file"]
    for path in ("a", "b", "a"):
        limited.read(path)
        assert limited.blob_bytes <= 8
    assert store.calls["cat-file"] == count + 3
    huge = store.blob(b"x" * 20)
    limited.files["huge"] = ("100644", huge)
    count = store.calls["cat-file"]
    assert limited.read("huge") == limited.read("huge") == b"x" * 20
    assert store.calls["cat-file"] == count + 2 and huge not in limited.blobs

    tick = chr(96)
    current = store.blob(f"- ID: {tick}REPAIR.1{tick}\n  Status: {tick}active{tick}\n".encode())
    historical = store.blob(f"- ID: {tick}REPAIR.1{tick}\n  Status: {tick}done{tick}\n".encode())
    index = store.blob(json.dumps({"type": "task_tree_part", "mutable": False,
                                  "path": "docs/tasks/T.history.md"}).encode() + b"\n")
    tasks = {"docs/tasks/T.md": ("100644", current),
             "docs/tasks/T.history.md": ("100644", historical),
             "docs/tasks/T.index.jsonl": ("100644", index)}
    owners = InputSnapshot(tasks, store.git)
    owners.check_owner("REPAIR.1")
    count = store.calls["cat-file"]
    for _ in range(20):
        owners.check_owner("REPAIR.1")
    assert store.calls["cat-file"] == count
    duplicate = dict(tasks, **{"docs/tasks/U.md": ("100644", current)})
    reject(lambda: InputSnapshot(duplicate, store.git).check_owner("REPAIR.1"), "not open")
    for status in ("pending", "active", "blocked", "done", "implemented"):
        identity = store.blob(f"- ID: {tick}REPAIR.1{tick}\n  Status: {tick}{status}{tick}\n".encode())
        candidate = InputSnapshot({"docs/tasks/T.md": ("100644", identity)}, store.git)
        if status in ("pending", "active", "blocked"):
            candidate.check_owner("REPAIR.1")
        else:
            reject(lambda: candidate.check_owner("REPAIR.1"), "not open")
    reject(lambda: owners.check_owner("invalid"), "invalid gap repair owner")

    policy = store.blob(b"## 12. Claim verification " + "\u2014".encode() + b" local publishing contract\n")
    review = store.blob(b"## Publishing measured claims\n")
    minimal = {"DOCTRINE_ENFORCEMENT.md": ("100644", policy), "COMMIT.md": ("100644", review)}
    globals_ = module["run_check"].__globals__
    saved = {key: globals_[key] for key in ("index_files", "git")}
    try:
        globals_["git"] = store.git
        snapshots = iter((minimal, dict(minimal, changed=("100644", a))))
        globals_["index_files"] = lambda: next(snapshots)
        reject(module["run_check"], "index changed during claim verification")
        globals_["index_files"] = lambda: dict(minimal)
        with contextlib.redirect_stdout(io.StringIO()) as out:
            module["run_check"]()
        assert "PASS 0 records" in out.getvalue()
    finally:
        globals_.update(saved)
    print(json.dumps({"immutable_reads": {"legacy": legacy_calls, "cached": cached_calls},
                      "revision_mode_kind_snapshot_owner_budget_drift_controls": "PASS"}, sort_keys=True))


if __name__ == "__main__":
    main()
