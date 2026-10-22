"""Close every supplied source epoch without recursively embedding immutable data."""
import subprocess
import common as c


def snapshot(extras=()):
    paths = sorted(set(c.paths()) | set(extras))
    inputs = {path: c.identity(path) for path in paths}
    tracked = set(subprocess.check_output(['git', 'ls-files', '-z'], cwd=c.ROOT).decode().split('\0'))
    changed = set(subprocess.check_output(
        ['git', 'diff', '--name-only', '-z', c.BASE], cwd=c.ROOT).decode().split('\0'))
    packets = {path: c.read(path) for path in paths
        if (path in changed or path not in tracked) and not path.endswith(('.gz', '.part'))}
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=c.ROOT).decode().strip()
    return dict(base=c.BASE, head=head, inputs=inputs, overrides=packets,
        scope='All regular tracked and nonignored new main-repository sources/fixtures/book/artifacts precede the measurement. Changed/new plain sources are retained whole; immutable gzip/chunk inputs stay at exact byte/full-mode identities, without recursive embedding. Unchanged files recover from real accepted Git. Gitlinks and symlink targets are not inspected; installed tools/core and published dependency outputs are read-only prerequisites. All project data stays on the repository volume.')
