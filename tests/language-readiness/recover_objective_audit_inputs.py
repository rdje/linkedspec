"""Validate or explicitly restore the closed historical audit input archive.

Validation is read-only. Run through tools/run_python_project_data.sh; restoration
uses a new directory beneath repository-volume managed scratch, never extraction
paths supplied by ZIP metadata.
"""
import argparse
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import stat
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1"
ARCHIVE = "tests/language-readiness/artifacts/objective-audit-inputs.zip"
MANIFEST = "tests/language-readiness/artifacts/objective-audit-inputs.json"
CENSUS_PREFIX = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0-"
CENSUS = CENSUS_PREFIX + "verification.json"
SCRATCH = ".linkedspec-data/scratch/objective-artifact-recovery/"
MAX_ARCHIVE = 4 * 1024 * 1024
MAX_EXPANDED = 96 * 1024 * 1024


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def relative(name):
    require(isinstance(name, str) and bool(name), "invalid relative path")
    path = Path(name)
    require(not path.is_absolute() and path.as_posix() == name and
            ".." not in path.parts and "\\" not in name and
            not any(ord(char) < 32 for char in name), "invalid relative path")
    return path


def directory(name, create=False):
    path = ROOT
    device = ROOT.stat().st_dev
    for part in relative(name).parts:
        path = path / part
        require(not path.is_symlink(), "symlink directory rejected")
        if not path.exists() and create:
            path.mkdir()
        require(path.is_dir() and path.stat().st_dev == device,
                "directory outside repository volume")
    return path


def read_input(name):
    path = ROOT / relative(name)
    directory(path.parent.relative_to(ROOT).as_posix())
    require(not path.is_symlink() and stat.S_ISREG(path.stat().st_mode),
            "input is not a regular file")
    require(path.stat().st_dev == ROOT.stat().st_dev, "input outside repository volume")
    return path.read_bytes()


def strict_json(data):
    require(len(data) <= 128 * 1024, "manifest JSON exceeds bound")

    def pairs(items):
        result = {}
        for key, value in items:
            require(key not in result, "duplicate manifest key")
            result[key] = value
        return result

    def constant(value):
        raise ValueError("non-finite manifest number")

    return json.loads(data, object_pairs_hook=pairs, parse_constant=constant)


def keys(value, expected):
    require(isinstance(value, dict) and set(value) == set(expected), "manifest schema mismatch")


def census_inputs():
    data = read_input(CENSUS)
    census = strict_json(data)
    source = CENSUS_PREFIX + "census.py"
    require(digest(read_input(source)) == census["producer_sha256"], "census producer changed")
    spec = importlib.util.spec_from_file_location("objective_artifact_census", ROOT / source)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    population, milestones, counts = module.population()
    expected = {row["path"]: row for row in census["artifacts"]}
    require(len(expected) == len(census["artifacts"]) and
            {name: row["sha256"] for name, row in expected.items()} == population and
            milestones == census["milestone_inputs"] and counts == census["milestone_log_counts"],
            "census differs from independent milestone population")
    require(sum(row["bytes"] for row in expected.values()) <= MAX_EXPANDED,
            "expanded population exceeds bound")
    return expected, digest(data)


def validate(manifest_data, archive_data):
    expected, census_hash = census_inputs()
    manifest = strict_json(manifest_data)
    keys(manifest, ("version", "owner", "archive", "census", "entries"))
    require(type(manifest["version"]) is int and manifest["version"] == 1 and
            manifest["owner"] == OWNER, "manifest version/owner mismatch")
    keys(manifest["archive"], ("path", "sha256", "bytes"))
    keys(manifest["census"], ("path", "sha256"))
    require(manifest["census"] == {"path": CENSUS, "sha256": census_hash},
            "manifest census identity mismatch")
    require(manifest["archive"]["path"] == ARCHIVE and
            type(manifest["archive"]["bytes"]) is int and
            22 <= len(archive_data) <= MAX_ARCHIVE and
            manifest["archive"]["bytes"] == len(archive_data) and
            manifest["archive"]["sha256"] == digest(archive_data), "archive identity mismatch")
    require(isinstance(manifest["entries"], list), "manifest entries must be an array")
    rows = []
    for index, (name, old) in enumerate(sorted(expected.items())):
        rows.append({"path": name, "member": f"log{index:04d}",
                     "sha256": old["sha256"], "bytes": old["bytes"]})
    for row in manifest["entries"]:
        keys(row, ("path", "member", "sha256", "bytes"))
        relative(row["path"])
        require(type(row["bytes"]) is int, "manifest size must be an integer")
    require(manifest["entries"] == rows, "manifest differs from independent census")
    require(archive_data[-22:-18] == b"PK\x05\x06" and archive_data[-2:] == b"\0\0",
            "ZIP end record mismatch")
    recovered = {}
    with zipfile.ZipFile(io.BytesIO(archive_data)) as archive:
        members = archive.infolist()
        require([member.filename for member in members] == [row["member"] for row in rows],
                "ZIP membership mismatch")
        require(not archive.comment, "ZIP comment rejected")
        for member, row in zip(members, rows):
            require(member.compress_type == zipfile.ZIP_DEFLATED and not member.flag_bits & 1 and
                    not member.is_dir() and not member.extra and not member.comment,
                    "ZIP member metadata mismatch")
            require(member.file_size == row["bytes"], "ZIP member size mismatch")
            with archive.open(member) as stream:
                contents = stream.read(row["bytes"] + 1)
            require(len(contents) == row["bytes"] and digest(contents) == row["sha256"],
                    "ZIP member content mismatch")
            recovered[row["path"]] = contents
    return recovered


def restore(destination, recovered):
    relative(destination)
    require(destination.startswith(SCRATCH) and len(destination) > len(SCRATCH),
            "restore destination outside owned scratch")
    root = ROOT / destination
    require(not root.is_symlink(), "symlink destination rejected")
    require(not root.exists(), "restore destination already exists")
    directory(root.parent.relative_to(ROOT).as_posix(), create=True)
    root.mkdir()
    for name, contents in sorted(recovered.items()):
        output = root / relative(name)
        directory(output.parent.relative_to(ROOT).as_posix(), create=True)
        with output.open("xb") as stream:
            stream.write(contents)
        require(read_input(output.relative_to(ROOT).as_posix()) == contents,
                "restored bytes differ")
    return root


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--restore", metavar="RELATIVE_NEW_DIRECTORY")
    args = parser.parse_args()
    recovered = validate(read_input(MANIFEST), read_input(ARCHIVE))
    if args.restore:
        restore(args.restore, recovered)
    print(json.dumps({"owner": OWNER, "inputs": len(recovered),
                      "bytes": sum(map(len, recovered.values())), "restored": args.restore}, sort_keys=True))


if __name__ == "__main__":
    main()
