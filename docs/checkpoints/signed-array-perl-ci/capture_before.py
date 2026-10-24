"""Preserve canonical2 and reproduce the exact owned CI insertion mismatch."""
import base64
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "docs/checkpoints/signed-array-perl"))
import common as c
import context

AUDITOR = "tests/language-readiness/verify_objectives.py"
CI = "tools/run_ci_local.sh"
MILESTONE = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5-verification.json"


def save(name, value):
    with (HERE / name).open("xb") as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))


def main():
    spec = importlib.util.spec_from_file_location("signed_ci_original_audit", ROOT / AUDITOR)
    audit = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(audit)
    expected = json.loads(c.source(MILESTONE).read_bytes())["audit"]["current_source_hashes"][CI]
    before = subprocess.check_output(["git", "show", c.BASE + ":" + CI], cwd=ROOT)
    baseline = audit.verify_governance_evolution(CI, before, expected)
    try:
        audit.verify_governance_evolution(CI, c.source(CI).read_bytes(), expected)
    except ValueError as error:
        reason = str(error)
    else:
        raise AssertionError("new CI registration unexpectedly admitted")
    assert reason == "governance registration mismatch: " + CI
    diff = subprocess.run(["git", "diff", "--cached", "--full-index", "--binary"], cwd=ROOT, capture_output=True)
    assert diff.returncode == 0
    fingerprint = c.sha(diff.stdout)
    assert fingerprint == "179d413b1d6c2fa2c24aa7059821630cb5124cb24f851a878b19ad8985711bfa"
    names = subprocess.check_output(["git", "diff", "--cached", "--name-only"], cwd=ROOT).decode().splitlines()
    assert len(names) == 143
    packets = {}
    index = subprocess.check_output(["git", "ls-files", "--stage", "-z"], cwd=ROOT)
    for row in index.split(b"\0"):
        if row:
            meta, name = row.split(b"\t", 1)
            path = name.decode()
            if path in names:
                mode, oid, stage = meta.decode().split()
                assert stage == "0"
                raw = subprocess.check_output(["git", "show", ":" + path], cwd=ROOT)
                item = dict(mode=mode, git_oid=oid, sha256=c.sha(raw))
                if path.endswith((".gz", ".part")):
                    assert c.identity(path)["sha256"] == item["sha256"]
                else:
                    item["base64"] = c.encode(raw)
                packets[path] = item
    planned = {AUDITOR, "docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md",
        "docs/linkedspec-book/src/development/local-ci-and-regression.md"}
    census = {}
    for path in subprocess.check_output(["git", "ls-files", "docs/claims"], cwd=ROOT).decode().splitlines():
        record = json.loads(c.source(path).read_bytes())
        live = [claim for claim in record["claims"] if claim["durability"].get("status") == "checked"
            and claim["durability"].get("mode") == "live"]
        if live:
            paths = {item["path"] for claim in live for item in claim["durability"]["inputs"]}
            assert not planned & paths
            census[path] = dict(packet=c.read(path), inputs=sorted(paths))
    save("before.json.gz", dict(context=context.snapshot(), producer=c.read(Path(__file__).relative_to(ROOT).as_posix()),
        auditor=c.read(AUDITOR), ci=c.read(CI), milestone=c.read(MILESTONE), historical_hash=expected,
        accepted_ci_base64=c.encode(before), accepted_baseline=baseline, actual_rejection=reason,
        candidate=dict(base=c.BASE, fingerprint=fingerprint, index_base64=c.encode(index), files=packets),
        actual_ci_log=c.read(".linkedspec-data/verification/signed-perl-canonical2.log"), actual_ci_exit=1,
        census=census, scope="No historical hash, input, runtime observation or prior publication is refreshed. All original143 staged source images/immutable identities and whole channels precede the bounded auditor registration extension."))
    print("CI enrollment RED:", reason, "; accepted CI reconstructs frozen hash", expected, "; no live intersections")


if __name__ == "__main__":
    main()
