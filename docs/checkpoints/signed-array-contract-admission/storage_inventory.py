"""Read-only review of the dated signed-checker storage enrollment."""
import copy
import gzip
import json
from pathlib import Path
import re
import subprocess
import sys

sys.path.insert(0, "docs/checkpoints/signed-array-contract")
import common as c

PREFIX = "docs/checkpoints/signed-array-contract-admission/"
RULE = "tools/test_tool_project_data_storage.sh"
CHECKER = "tools/check_signed_array_selector_contract.py"
SELF = PREFIX + "storage_inventory.py"
ACTOR = PREFIX + "repair_storage_inventory.py"


def load(name):
    return json.loads(gzip.decompress((c.ROOT / PREFIX / name).read_bytes()))


def raw(packet):
    value = c.decode(packet["base64"])
    assert c.sha(value) == packet["sha256"]
    return value


def repaired_rule(original):
    replacements = {
        b"${#python_tool_entrypoints[@]} == 42": b"${#python_tool_entrypoints[@]} == 43",
        b"inventory drifted from 42 to": b"inventory drifted from 43 to",
        b"for checker in tools/check_callable_codeblock_contract.py tools/check_composed_objective_contract.py tools/check_claim_verification.py; do":
            b"for checker in tools/check_callable_codeblock_contract.py tools/check_composed_objective_contract.py tools/check_claim_verification.py tools/check_signed_array_selector_contract.py; do",
    }
    for old, new in replacements.items():
        assert original.count(old) == 1
        original = original.replace(old, new, 1)
    return original


def validate(before, after):
    assert before["base"] == c.BASE
    assert before["gate"]["returncode"] == 1
    failure = c.decode(before["gate"]["stdout_base64"]) + c.decode(before["gate"]["stderr_base64"])
    assert b"inventory drifted from 42 to 43" in failure
    assert after["gate"]["returncode"] == 0
    output = c.decode(after["gate"]["stdout_base64"])
    assert b"signed-selector target contract: 12 arithmetic, 14 reads, 33 writes" in output
    assert b"[tool-project-data-test] PASS:" in output
    assert raw(after["rule"]) == repaired_rule(raw(before["rule"]))
    assert before["patch"]["returncode"] == 0
    assert c.sha(c.decode(before["patch"]["stdout_base64"])) == before["patch_sha256"]
    for packet in before["sources"].values():
        raw(packet)
    python = {name: raw(packet) for name, packet in before["python_sources"].items()}
    shell = {name: raw(packet) for name, packet in before["shell_sources"].items()}
    # Git supplies the independent, accepted old population and bytes. The
    # candidate adds one explicitly named checker, not an arbitrary extra file.
    entries = subprocess.check_output(["git", "ls-tree", "-rz", c.BASE, "tools", "knowledge-map/scripts"], cwd=c.ROOT)
    expected = {}
    expected_shell = {}
    for row in entries.split(b"\0"):
        if not row:
            continue
        metadata, path = row.split(b"\t", 1)
        mode, kind, oid = metadata.decode().split()
        name = path.decode()
        if name.count("/") == 1 and name.endswith(".py") and kind == "blob":
            value = subprocess.check_output(["git", "cat-file", "blob", oid], cwd=c.ROOT)
            expected[name] = value
            assert python[name] == value
            assert before["python_sources"][name]["mode"] == (0o755 if mode == "100755" else 0o644)
        if kind == "blob" and name.endswith(".sh") and (
                name.startswith("tools/") and name.count("/") == 1
                or name.startswith("knowledge-map/scripts/") and name.count("/") == 2):
            value = subprocess.check_output(["git", "cat-file", "blob", oid], cwd=c.ROOT)
            expected_shell[name] = value
            assert shell[name] == value
    assert set(python) == set(expected) | {CHECKER}
    assert set(shell) == set(expected_shell)
    manifest = json.loads(gzip.decompress(raw(before["neutral_outputs"][c.PREFIX + "publication-inputs.json.gz"])))
    assert before["python_sources"][CHECKER]["sha256"] == manifest["inputs"][CHECKER]["sha256"]
    assert before["python_sources"][CHECKER]["mode"] == manifest["inputs"][CHECKER]["mode"]
    entrypoints = sorted(name for name, value in python.items()
        if re.search(rb"^#!/usr/bin/env python3$", value, re.M))
    old_entrypoints = sorted(name for name, value in expected.items()
        if re.search(rb"^#!/usr/bin/env python3$", value, re.M))
    assert len(old_entrypoints) == 42 and len(entrypoints) == 43
    assert set(entrypoints) - set(old_entrypoints) == {CHECKER}
    assert entrypoints == before["entrypoints"]
    temporary = sorted(name for name, value in python.items()
        if re.search(rb"tempfile[.](NamedTemporaryFile|TemporaryDirectory)", value))
    allocators = sorted(name for name, value in shell.items()
        if re.search(rb"\$\(mktemp\b", value))
    def names(variable):
        match = re.search(rb"^" + variable + rb"=\(\n(.*?)\n\)", raw(before["rule"]), re.M | re.S)
        assert match
        return match[1].decode().split()
    assert temporary == names(b"expected_python_temp_owners") and len(temporary) == 4
    assert allocators == names(b"expected_shell_temp_owners") and len(allocators) == 15
    assert CHECKER not in temporary
    assert before["neutral_readonly"]["returncode"] == after["neutral_readonly"]["returncode"] == 0
    assert all(c.read(path) == packet for path, packet in before["neutral_outputs"].items())
    assert all(c.identity(path) == item for path, item in before["neutral_inputs"].items())
    assert c.read(SELF) == before["sources"][SELF]
    assert c.read(ACTOR) == before["sources"][ACTOR]
    assert c.read(c.PREFIX + "common.py") == before["sources"][c.PREFIX + "common.py"]
    return dict(entrypoints=len(entrypoints), old_entrypoints=len(old_entrypoints),
        added=[CHECKER], python_temporary_owners=len(temporary), shell_allocators=len(allocators))


def check():
    before, after = load("storage-before.json.gz"), load("storage-result.json.gz")
    result = validate(before, after)
    corruptions = []
    missing = copy.deepcopy(before)
    del missing["python_sources"][CHECKER]
    corruptions.append(("missing_new_checker", missing))
    wrong = copy.deepcopy(before)
    wrong["entrypoints"] = wrong["entrypoints"][:-1]
    corruptions.append(("incomplete_observed_population", wrong))
    false_red = copy.deepcopy(before)
    false_red["gate"]["returncode"] = 0
    corruptions.append(("relabelled_failure", false_red))
    for name, candidate in corruptions:
        try:
            validate(candidate, after)
        except (AssertionError, KeyError):
            continue
        raise AssertionError("storage reader admitted " + name)
    result["record_denials"] = [name for name, _ in corruptions]
    return result


if __name__ == "__main__":
    print(json.dumps(check(), sort_keys=True))
