"""Retain actual source epochs without recursively copying immutable archives."""
import subprocess
import common as c


def snapshot(extras=()):
    names = sorted(set(c.paths()) | set(extras))
    inputs = {path: c.identity(path) for path in names}
    tracked = set(subprocess.check_output(["git", "ls-files", "-z"], cwd=c.ROOT).decode().split("\0"))
    changed = set(subprocess.check_output(
        ["git", "diff", "--name-only", "-z", c.BASE], cwd=c.ROOT).decode().split("\0"))
    overrides = {path: c.read(path) for path in names
        if (path in changed or path not in tracked) and not path.endswith((".gz", ".part"))}
    head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=c.ROOT).decode().strip()
    assert head == c.BASE
    return dict(base=c.BASE, head=head, inputs=inputs, overrides=overrides,
        scope="All regular main-repository tracked/nonignored inputs precede commands. Accepted Git supplies unchanged bytes; mutable plain overlays are retained whole. Immutable gzip/chunk inputs retain byte/mode identities. Gitlinks and dependency implementation are excluded; installed SDK/OS and published dependency outputs are read-only prerequisites. Project data remains on-volume.")
