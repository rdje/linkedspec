"""Capture full historical replay and independent registration/source controls."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "docs/checkpoints/signed-array-perl"))
import common as c
import context

AUDITOR = "tests/language-readiness/verify_objectives.py"
CI = "tools/run_ci_local.sh"
OBSERVER = "docs/checkpoints/signed-array-perl-ci/observe.py"
PROOF = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py"


def save(name, value):
    with (HERE / name).open("xb") as output:
        output.write(gzip.compress((json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode(), mtime=0))


def main():
    original = json.loads(gzip.decompress((HERE / "before.json.gz").read_bytes()))
    raw = c.source(CI).read_bytes()
    cases = [dict(id="healthy", ci_base64=c.encode(raw), expected_accepted=True)]
    atoms = {
        "test-input": b"require_tracked_file t/signed_array_selector_perl_contract.t\n",
        "fixture-input": b"require_tracked_file tests/numeric-codeblocks/signed-array-selectors.json\n",
        "syntax": b"perl -c -Iperl t/signed_array_selector_perl_contract.t\n",
        "execution": b"PERL5LIB= prove -Iperl t/signed_array_selector_perl_contract.t\n",
    }
    def add(name, value):
        assert value != raw
        cases.append(dict(id=name, ci_base64=c.encode(value), expected_accepted=False))
    for name, atom in atoms.items():
        assert raw.count(atom) == 1
        add("missing-" + name, raw.replace(atom, b"", 1))
        add("duplicate-" + name, raw.replace(atom, atom * 2, 1))
    add("disabled-execution", raw.replace(atoms["execution"], b"PERL5LIB= true t/signed_array_selector_perl_contract.t\n", 1))
    add("disabled-syntax", raw.replace(atoms["syntax"], b"true t/signed_array_selector_perl_contract.t\n", 1))
    add("foreign-fixture", raw.replace(atoms["fixture-input"], b"require_tracked_file tests/numeric-codeblocks/missing-signed-array-selectors.json\n", 1))
    add("unrelated-source", raw + b"# unreviewed source edit\n")
    block = b'\nlog "running Perl signed-array selector contract and public route fixture"\n' + atoms["execution"]
    assert raw.count(block) == 1
    add("moved-registration", raw.replace(block, b"", 1) + block)
    plan = dict(historical_hash=original["historical_hash"], cases=cases)
    source = c.source(AUDITOR).read_bytes()
    inverse_atom = b"        SIGNED_ARRAY_SELECTOR_CI_INSERTIONS\n        + PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS\n"
    assert source.count(inverse_atom) == 1
    inverse = source.replace(inverse_atom, b"        PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS\n", 1)
    marker = b"def verify_governance_evolution(source, contents, historical_hash):\n"
    assert source.count(marker) == 1
    bypass = source.replace(marker, marker + b'    return {"bypassed": True}\n', 1)
    epoch = context.snapshot()
    save("after-inputs.json.gz", dict(context=epoch, plan=plan, producer=c.read(Path(__file__).relative_to(ROOT).as_posix()),
        observer=c.read(OBSERVER), auditor=c.read(AUDITOR), ci=c.read(CI),
        physical_sources={"inverse": c.encode(inverse), "bypass": c.encode(bypass)},
        scope="Whole actual producer/inputs precede full unchanged isolated historical recovery. Independent CI mutations use explicit required command/input atoms, not the auditor's own insertion table. Two actual source copies run in fresh processes; their verifier scope accepts supplied CI bytes/hash and uses no relocated ROOT-dependent helper."))
    runs = {"healthy": c.run(["bash", "tools/run_python_project_data.sh", OBSERVER, AUDITOR], input=json.dumps(plan).encode())}
    with tempfile.TemporaryDirectory(prefix="signed-ci-auditor-", dir=os.environ["TMPDIR"]) as folder:
        assert Path(folder).stat().st_dev == ROOT.stat().st_dev
        for name, value in (("inverse", inverse), ("bypass", bypass)):
            target = Path(folder) / (name + ".py")
            target.write_bytes(value)
            target.chmod(0o644)
            runs[name] = c.run(["bash", "tools/run_python_project_data.sh", OBSERVER, str(target)],
                input=json.dumps(plan).encode())
    runs["restored"] = c.run(["bash", "tools/run_python_project_data.sh", OBSERVER, AUDITOR], input=json.dumps(plan).encode())
    runs["historical"] = c.run(["bash", "tools/run_python_project_data.sh", PROOF])
    save("after-runs.json.gz", dict(runs=runs, inputs_unchanged=c.unchanged(epoch["inputs"])))
    assert c.unchanged(epoch["inputs"])
    for name, run in runs.items():
        assert run["returncode"] == 0, (name, c.decode(run["stderr_base64"]).decode())
        if name == "historical":
            value = json.loads(c.decode(run["stdout_base64"]))
            print("historical PASS", value["restored_inputs"], value["restored_bytes"], len(value["controls"]),
                value["audit_controls"]["governance_mutations_rejected"], flush=True)
            continue
        value = json.loads(c.decode(run["stdout_base64"]))
        assert [row["id"] for row in value["rows"]] == [case["id"] for case in cases]
        if name in ("healthy", "restored"):
            assert all(row["accepted"] == case["expected_accepted"] for row, case in zip(value["rows"], cases))
        elif name == "inverse":
            assert not value["rows"][0]["accepted"]
        else:
            assert all(row["accepted"] for row in value["rows"])
        print(name, sum(row["accepted"] for row in value["rows"]), "accepted /", len(cases), flush=True)


if __name__ == "__main__":
    main()
