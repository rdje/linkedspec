"""Read-only census of the selected historical audit artifact inputs."""
import hashlib
import json
from pathlib import Path
import re
import stat
import subprocess
import zlib

ROOT = Path(__file__).resolve().parents[2]
BASE = "0f15e194febbe0e6099fba5ae5f9bca8a1b1d7be"
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0"
PREFIX = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3."
MILESTONES = [PREFIX + part + "-verification.json" for part in ("1.2.3", "2.7", "3.5")]
REFERENCE = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-verification.json"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def relative(name):
    require(isinstance(name, str) and bool(name), "invalid relative artifact path")
    path = Path(name)
    require(not path.is_absolute() and ".." not in path.parts and "\\" not in name and
            path.as_posix() == name and not any(ord(char) < 32 for char in name),
            "invalid relative artifact path")
    require(name.startswith(".linkedspec-data/scratch/"), "outside artifact population root")
    return path


def population():
    result, inputs, counts = {}, {}, {}
    for name in MILESTONES:
        data = (ROOT / name).read_bytes()
        historical = subprocess.check_output(["git", "show", BASE + ":" + name], cwd=ROOT)
        require(data == historical, "historical milestone changed")
        inputs[name] = sha(data)
        record = json.loads(data)
        logs = record.get("audit", record)["log_hashes"]
        counts[name] = len(logs)
        rows = logs.items() if isinstance(logs, dict) else (
            (row["path"], row.get("sha256", row.get("recorded"))) for row in logs)
        for path, value in rows:
            relative(path)
            require(isinstance(value, str) and re.fullmatch(r"[0-9a-f]{64}", value),
                    "invalid historical log identity")
            require(path not in result or result[path] == value, "conflicting historical log identity")
            result[path] = value
    return result, inputs, counts


def validate_population(expected, audited):
    require(expected == audited, "milestone population differs from audited population")


def read_artifact(name):
    path = ROOT / relative(name)
    require(not path.is_symlink() and stat.S_ISREG(path.stat().st_mode), "artifact is not regular")
    resolved = path.resolve(strict=True)
    require(resolved.is_relative_to(ROOT) and resolved.stat().st_dev == ROOT.stat().st_dev,
            "artifact escaped repository volume")
    return path.read_bytes()


def measure(expected, read=read_artifact):
    rows = []
    for name, identity in sorted(expected.items()):
        data = read(name)
        require(sha(data) == identity, "historical artifact hash mismatch")
        rows.append({"path": name, "sha256": identity, "bytes": len(data),
                     "zlib_level9_bytes": len(zlib.compress(data, 9))})
    return rows


def string_candidates(value):
    if isinstance(value, str):
        yield value.encode()
    elif isinstance(value, list):
        if value and all(isinstance(item, str) for item in value):
            yield "".join(value).encode()
        for item in value:
            yield from string_candidates(item)
    elif isinstance(value, dict):
        for item in value.values():
            yield from string_candidates(item)


def census():
    expected, inputs, counts = population()
    reference = json.loads((ROOT / REFERENCE).read_bytes())
    audited = reference["audit_report"]["retained_log_hashes"]
    validate_population(expected, audited)
    rows = measure(expected)
    coverage, selected_inputs = {}, {}
    checkpoints = reference["audit_report"]["checkpoints"]
    for name in checkpoints:
        data = (ROOT / name).read_bytes()
        require(sha(data) == checkpoints[name]["sha256"], "selected checkpoint changed")
        selected_inputs[name] = {"sha256": sha(data), "bytes": len(data)}
        for candidate in (data, *string_candidates(json.loads(data))):
            identity = sha(candidate)
            if identity in expected.values():
                coverage.setdefault(identity, set()).add(name)
    tracked = subprocess.check_output(["git", "ls-files", "docs/checkpoints", "docs/history",
                                      "tests/language-readiness"], cwd=ROOT, text=True).splitlines()
    archives = [name for name in tracked if name.endswith((".gz", ".zip", ".zst", ".tar", ".xz", ".bz2"))]
    first = rows[0]["path"]
    try:
        measure({first: expected[first]}, lambda name: read_artifact(name) + b" ")
    except ValueError as error:
        require(str(error) == "historical artifact hash mismatch", "unrelated corruption rejection")
    else:
        raise ValueError("actual-byte corruption accepted")
    for bad in ("../outside", "/outside", ".linkedspec-data/scratch/../outside"):
        try:
            relative(bad)
        except ValueError:
            pass
        else:
            raise ValueError("outside artifact path accepted")
    population_controls = []
    for mutation in ("remove-member", "change-identity"):
        altered = dict(expected)
        if mutation == "remove-member":
            del altered[first]
        else:
            altered[first] = "0" * 64 if expected[first] != "0" * 64 else "1" * 64
        try:
            validate_population(altered, audited)
        except ValueError as error:
            require(str(error) == "milestone population differs from audited population",
                    "unrelated population rejection")
            population_controls.append({"mutation": mutation, "path": first, "reason": str(error)})
        else:
            raise ValueError("changed population accepted")
    return {"format": 1, "owner": OWNER, "activation_commit": BASE,
        "producer_sha256": sha(Path(__file__).read_bytes()),
        "zlib_version": zlib.ZLIB_VERSION,
        "milestone_inputs": inputs, "milestone_log_counts": counts,
        "reference": {"path": REFERENCE,
            "sha256": sha((ROOT / REFERENCE).read_bytes())},
        "artifacts": rows, "summary": {"inputs": len(rows),
            "raw_bytes": sum(row["bytes"] for row in rows),
            "zlib_level9_bytes": sum(row["zlib_level9_bytes"] for row in rows),
            "selected_checkpoints": len(checkpoints),
            "selected_checkpoint_bytes": sum(item["bytes"] for item in selected_inputs.values()),
            "exact_log_identities_in_selected_candidates": len(coverage)},
        "selected_inputs": selected_inputs,
        "selected_coverage": {identity: sorted(names) for identity, names in sorted(coverage.items())},
        "archive_extensions_in_selected_surfaces": archives,
        "controls": {"actual_byte_corruption_rejected": first, "outside_paths_rejected": 3,
                     "population_rejections": population_controls},
        "limits": "Read-only population/size/hash and selected coverage census. UTF-8 strings/joined string arrays and archive extensions only; other encodings/surfaces unassessed. Compression is a sizing probe, not an archive. Required raw inputs remain local; byte recovery is not claimed."}


if __name__ == "__main__":
    print(json.dumps(census(), indent=2, sort_keys=True))
