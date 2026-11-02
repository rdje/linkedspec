"""Update derived reference-scope pages for the selected task leaf."""
import argparse
import os
from pathlib import Path
import tempfile
from reference_scope import ROOT, INDEX, Snapshot, build, load, path, verify

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--owner", required=True)
args = parser.parse_args()
snapshot = Snapshot()
try:
    if snapshot.staged:
        raise ValueError("update reference scope before staging the candidate")
    output = build(snapshot, args.owner)
    old_paths = {name for name in snapshot.paths
                 if name.startswith("doctrine/readme_stability/reference-scope/")}
    if old_paths:
        if INDEX not in old_paths:
            raise ValueError("scope store lacks its declared root")
        _, _, declared_pages = load(snapshot.read)
        if old_paths != set(declared_pages) | {INDEX}:
            raise ValueError("unknown scope store member; refusing cleanup")
    snapshot.finish()
    directory = ROOT / Path(INDEX).parent
    cursor = ROOT
    for part in Path(INDEX).parent.parts:
        cursor /= part
        if cursor.is_symlink():
            raise ValueError("symbolic scope output directory")
    directory.mkdir(parents=True, exist_ok=True)
    for name in sorted(output, key=lambda name: name == INDEX):
        target = ROOT / name
        if target.is_symlink():
            raise ValueError("symbolic scope output")
        raw = output[name]
        if target.exists() and target.read_bytes() == raw:
            continue
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(dir=target.parent, prefix=".scope-", delete=False) as stream:
                temporary = Path(stream.name)
                stream.write(raw)
            os.replace(temporary, target)
        finally:
            if temporary and temporary.exists():
                temporary.unlink()
    for name in old_paths - output.keys():
        (ROOT / name).unlink()
    after = Snapshot()
    try:
        count, pages = verify(after)
        after.finish()
    except Exception:
        after.abort()
        raise
except Exception as error:
    snapshot.abort()
    parser.exit(1, f"reference-scope-update: FAIL: {error}\n")
print(f"reference-scope-update: PASS {count} members / {pages} pages owned by {args.owner}")
