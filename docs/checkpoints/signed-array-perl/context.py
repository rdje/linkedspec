"""Whole source epochs with immutable archive identities instead of recursive copies."""
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
        scope="Every regular main-repository tracked/nonignored input precedes the command. Accepted Git supplies unchanged bytes; changed/new plain sources are retained whole. Immutable gzip/chunk inputs stay byte/mode-gated and are never recursively copied. Gitlinks/nested implementations are not inspected; installed SDK/OS and published dependency outputs are read-only prerequisites. All project data stays on-volume.")
