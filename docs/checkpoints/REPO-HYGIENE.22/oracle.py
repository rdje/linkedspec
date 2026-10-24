"""Independent scandir population oracle, separate from the retained os.walk helper."""
import os
from pathlib import Path
import stat
import common as c


def enumerate_metadata(start, excluded, gitlinks):
    root = c.ROOT
    device = root.lstat().st_dev
    start = root / start
    assert start.is_relative_to(root)
    current = root
    for component in start.relative_to(root).parts:
        current = current / component
        relative = current.relative_to(root).as_posix()
        if relative in excluded or relative in gitlinks or current.is_symlink():
            return []
        try:
            details = current.lstat()
        except FileNotFoundError:
            return []
        if details.st_dev != device or not stat.S_ISDIR(details.st_mode):
            return []
        if (current / '.git').exists():
            return []
    pending = [start]
    rows = []
    while pending:
        directory = pending.pop()
        with os.scandir(directory) as entries:
            for entry in entries:
                path = Path(entry.path)
                relative = path.relative_to(root).as_posix()
                if relative in excluded or relative in gitlinks or entry.is_symlink():
                    continue
                details = entry.stat(follow_symlinks=False)
                if details.st_dev != device:
                    continue
                if stat.S_ISDIR(details.st_mode):
                    if not (path / '.git').exists():
                        pending.append(path)
                    continue
                if not stat.S_ISREG(details.st_mode):
                    continue
                suffix = next((suffix for suffix in ('.log', '.bin', '.DS_Store')
                    if entry.name.endswith(suffix)), None)
                if suffix is not None:
                    rows.append(dict(path=relative, bytes=details.st_size, suffix=suffix))
    return sorted(rows, key=lambda row: row['path'])


def population(data, gitlinks):
    return dict(parent=enumerate_metadata('.', set(data['excluded_paths']), set(gitlinks)),
        rust={path: enumerate_metadata(path, set(), set(gitlinks)) for path in data['rust_log_bin']})
