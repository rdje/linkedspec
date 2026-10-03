"""Capture the exact closed population; --check compares without writing."""
import argparse
import importlib.util
import io
import json
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = "tests/language-readiness/recover_objective_audit_inputs.py"


def capture(module, read):
    """Rebuild in memory from a selected reader, including isolated recovered bytes."""
    expected, census_hash = module.census_inputs()
    entries = []
    output = io.BytesIO()
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for index, (name, row) in enumerate(sorted(expected.items())):
            contents = read(name)
            module.require(len(contents) == row["bytes"] and module.digest(contents) == row["sha256"],
                           "original artifact changed")
            member = f"log{index:04d}"
            info = zipfile.ZipInfo(member, (1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            archive.writestr(info, contents, compresslevel=9)
            entries.append({"path": name, "member": member, "sha256": row["sha256"],
                            "bytes": len(contents)})
    data = output.getvalue()
    manifest = {"version": 1, "owner": module.OWNER,
                "archive": {"path": module.ARCHIVE, "sha256": module.digest(data), "bytes": len(data)},
                "census": {"path": module.CENSUS, "sha256": census_hash}, "entries": entries}
    manifest_data = (json.dumps(manifest, indent=2, sort_keys=True) + "\n").encode()
    module.validate(manifest_data, data)
    return manifest_data, data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    spec = importlib.util.spec_from_file_location("objective_artifact_recovery", ROOT / SOURCE)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    manifest_data, data = capture(module, module.read_input)
    if args.check:
        module.require(module.read_input(module.ARCHIVE) == data and
                       module.read_input(module.MANIFEST) == manifest_data,
                       "archive capture differs from original inputs")
    else:
        (ROOT / module.ARCHIVE).parent.mkdir(parents=True, exist_ok=True)
        (ROOT / module.ARCHIVE).write_bytes(data)
        (ROOT / module.MANIFEST).write_bytes(manifest_data)
    manifest = json.loads(manifest_data)
    print(json.dumps({"inputs": len(manifest["entries"]), "archive": manifest["archive"], "check_only": args.check},
                     sort_keys=True))


if __name__ == "__main__":
    main()
