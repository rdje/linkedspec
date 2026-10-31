"""Read-only verification of the dated Perl definedness scalar capture."""

import argparse
import base64
import gzip
import hashlib
import json
from pathlib import Path
import sys


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"))


def review():
    directory = Path(__file__).resolve().parent
    packet = json.loads(gzip.decompress((directory / "intake.json.gz").read_bytes()))
    inputs = {}
    for item in packet["inputs"]:
        path = item["path"]
        assert path not in inputs, path
        data = base64.b64decode(item["base64"], validate=True)
        assert len(data) == item["bytes"]
        assert hashlib.sha256(data).hexdigest() == item["sha256"], path
        inputs[path] = data

    prefix = ".linkedspec-data/verification/definedness-numeric-calibration"
    assert inputs[".linkedspec-data/verification/probe_definedness_numeric_calibration.pl"] == (
        directory / "probe.pl"
    ).read_bytes()
    rows = []
    for suffix, count in (("", 12), ("-inverse", 3)):
        assert json.loads(inputs[prefix + suffix + "-exit.json"]) == {"exit": 0}
        batch = json.loads(inputs[prefix + suffix + "-observations.json"])
        assert len(batch) == count
        rows.extend(batch)

    indexed = {row["fixture"]["id"]: row for row in rows}
    assert len(indexed) == len(rows) == 15
    versions = set()
    constants = None
    for row in rows:
        assert row["loaded"] and not row["warnings"]
        assert not any(row.get(key) for key in (
            "build_error", "descriptor_error", "emission_error", "load_error", "substitution_error"
        ))
        meta = row["metadata"]
        assert meta["language_agnostic_action_ir_ready"]
        assert meta["raw_perl_dependency_count"] == meta["canonical_action_ir_fallback_count"] == meta["unresolved_helper_count"] == 0
        assert {result["route"] for result in row["results"]} == {"native", "fresh"}
        assert canonical(row["results"][0]["value"]) == canonical(row["results"][1]["value"])
        for result in row["results"]:
            assert result["executed"] and result["cursor"] == 0
            assert result["error"] is None and result["context_error"] is None
            host = result["host_scalar"]
            versions.add(host["perl_version"])
            if constants is None:
                constants = host["constants"]
            assert host["constants"] == constants
            for name, mask in constants.items():
                assert host["validity"][name] == int(bool(host["flags"] & mask))
    assert versions == {"v5.34.1"}

    native_false = (
        "native_false", "receiver_false", "copied_native_false", "copied_receiver_false",
        "inverse_false", "receiver_inverse_false",
    )
    for name in native_false:
        for result in indexed[name]["results"]:
            assert result["value"] == "" and result["host_scalar"]["reference"] == ""
            assert all(result["host_scalar"]["validity"][slot] == 1 for slot in (
                "SVf_IOK", "SVf_NOK", "SVf_POK"
            ))
    for result in indexed["literal_empty"]["results"]:
        assert result["value"] == "" and result["host_scalar"]["reference"] == ""
        assert result["host_scalar"]["validity"]["SVf_POK"] == 1
        assert result["host_scalar"]["validity"]["SVf_IOK"] == result["host_scalar"]["validity"]["SVf_NOK"] == 0
    for name, expected in (("typed_false", False), ("typed_true", True)):
        for result in indexed[name]["results"]:
            assert result["value"] is expected
            assert result["host_scalar"]["reference"] == "JSON::PP::Boolean"
    assert indexed["number_zero"]["results"][0]["value"] == 0
    assert type(indexed["number_zero"]["results"][0]["value"]) is int
    assert indexed["string_zero"]["results"][0]["value"] == "0"

    expected_routes = [1, 1, 1, 1, None, None, None, None, 1, 1, 1, 1, 2, 2]
    for name, expected in (
        ("numeric_routes", expected_routes), ("inverse_numeric_routes", [1, 1, 1, 1]),
        ("snapshot", ["", "", 1, "!"]),
    ):
        for result in indexed[name]["results"]:
            assert canonical(result["value"]) == canonical(expected), name
    numeric = indexed["numeric_routes"]["results"][0]["value"]
    report = {
        "source_epoch": packet["base"], "perl_version": "v5.34.1",
        "programs": len(rows), "native_fresh_observations": sum(len(row["results"]) for row in rows),
        "native_false_public_slots": ["SVf_IOK", "SVf_NOK", "SVf_POK"],
        "literal_empty_has_only_public_string": True, "typed_booleans_remain_references": True,
        "nested_fluent_copy_numeric_routes": numeric, "inverse_numeric_routes": [1, 1, 1, 1],
        "snapshot": ["", "", 1, "!"], "verified_retained_inputs": len(inputs),
        "limits": "Dated finite Perl5.34.1 capture; total/private flags are retained diagnostics, not portable/cache invariants. No production change or cross-backend kind normalization.",
    }
    return report, indexed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--falsify-json-kind", action="store_true")
    args = parser.parse_args()
    try:
        report, indexed = review()
        if args.falsify_json_kind:
            native = indexed["native_false"]["results"][0]["value"]
            literal = indexed["literal_empty"]["results"][0]["value"]
            numeric = indexed["numeric_routes"]["results"][0]["value"]
            assert canonical(native) == canonical(literal)
            assert canonical(numeric[0]) != canonical(numeric[4])
            print(json.dumps({"observed_red": True, "hypothesis": "equal serialized empty text implies equal numeric classification", "native_add": numeric[0], "literal_add": numeric[4]}, sort_keys=True))
            return 1
        print(json.dumps(report, sort_keys=True))
        return 0
    except (AssertionError, KeyError, OSError, ValueError) as error:
        print("capture review failed: " + repr(error), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
