"""Independently review dedicated producer diagnosis and effective evidence RED."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix("review.py")
REVISION = "3482a5d220bd7063a910c09de883faa903d24135"
TESTS = [
    "t/staged_ast_enrichment_perl_contract.t",
    "t/progressive_span_dispatch_perl_contract.t",
    "t/recognition_transaction_perl_contract.t",
    "t/recursive_observation_perl_contract.t",
    "t/actionir_helper_source_provenance.t",
    "t/actionir_statement_source_frames.t",
    "t/actionir_ast_parser.t",
    "t/canonical_event_occurrence_order.t",
    "t/actionir_nested_block_source_spans.t",
]
PLANS = [143, 129, 51, 7, 128, 28, 23, 15, 20]
MARKERS = {
    "staged": ("STAGED_PARSE_JOB_MARKER", "LinkedSpec::StagedParseJob::construct_marker"),
    "progressive": ("PROGRESSIVE_DISPATCH_SPAN", "LinkedSpec::ProgressiveSpanDispatchRuntime::dispatch"),
    "recognition": ("RECOGNIZE_ONCE", "LinkedSpec::RecognitionTransactionRuntime::attempt_static"),
    "observation": ("OBSERVE_RECOGNITION", "LinkedSpec::RecognitionTransactionRuntime::observe_static"),
}
spec = importlib.util.spec_from_file_location("original_dedicated_oracle", PREFIX + "oracle.py")
oracle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(oracle)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(channel):
    assert channel["encoding"] == "gzip-base64", "channel encoding"
    raw = gzip.decompress(base64.b64decode(channel["data"], validate=True))
    assert len(raw) == channel["bytes"] and sha(raw) == channel["sha256"], "complete channel bytes"
    return raw


def envelope(raw):
    return {"encoding": "gzip-base64", "bytes": len(raw), "sha256": sha(raw),
            "data": base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def check_inputs(manifest):
    assert manifest["revision"] == REVISION, "activation revision"
    original, excluded = {}, []
    listing = subprocess.check_output(["git", "ls-tree", "-rlz", REVISION], cwd=ROOT)
    for row in filter(None, listing.split(b"\0")):
        metadata, path = row.split(b"\t", 1)
        mode, kind, oid, size = metadata.split()
        if kind == b"blob" and mode in (b"100644", b"100755"):
            original[path.decode()] = (mode.decode(), oid.decode(), int(size))
        else:
            excluded.append({"path": path.decode(), "mode": mode.decode(), "kind": kind.decode()})
    entries = {entry["path"]: entry for entry in manifest["entries"]}
    assert len(entries) == len(manifest["entries"]) and entries.keys() == original.keys(), "complete unique original Git population"
    assert manifest["excluded_metadata"] == excluded, "black-box metadata exclusion"
    process = subprocess.Popen(["git", "cat-file", "--batch"], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, identity in original.items():
            entry = entries[path]
            assert (entry["mode"], entry["oid"], entry["bytes"]) == identity, "original Git metadata"
            process.stdin.write((entry["oid"] + "\n").encode())
            process.stdin.flush()
            assert process.stdout.readline().split() == [
                entry["oid"].encode(), b"blob", str(entry["bytes"]).encode()
            ], "original blob framing"
            raw = process.stdout.read(entry["bytes"])
            assert process.stdout.read(1) == b"\n" and sha(raw) == entry["sha256"], "original input bytes"
            if path.startswith(("perl/", "specs/", "t/")):
                assert raw == (ROOT / path).read_bytes(), "unchanged production and fixtures"
    finally:
        process.stdin.close()
        process.stdout.close()
        assert process.wait() == 0
    expected = [Path(PREFIX + name).relative_to(ROOT).as_posix()
                for name in ("cases.json", "probe.pl", "oracle.py")]
    assert [item["path"] for item in manifest["overlays"]] == expected, "exact authored overlay population"
    for item in manifest["overlays"]:
        raw = (ROOT / item["path"]).read_bytes()
        assert (item["mode"], item["bytes"], item["sha256"]) == ("100644", len(raw), sha(raw)), "authored overlay bytes"


def check_document(document, authored):
    measured = oracle.check(document, authored)
    for row in document["toolbox"]:
        node, spelling = MARKERS[row["id"]]
        assert node in row["descriptor"]["canonical_action_ir_nodes"], "dedicated compiler node"
        assert spelling in row["substitution"], "dedicated substitution constructor"
        assert spelling in row["dump"], "dedicated emitted constructor"
    return measured


def check_report(report, manifest, authored):
    assert report["complete"] is True and report["revision"] == REVISION, "complete diagnosis boundary"
    assert report["instrument_sha256"] == sha(Path(PREFIX + "capture.py").read_bytes()), "actual capture producer"
    stream = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py"
    assert report["stream_instrument_sha256"] == sha((ROOT / stream).read_bytes()), "actual stream producer"
    assert [(run["kind"], run["seed"]) for run in report["runs"]] == [
        ("fixtures", 0), ("dedicated", 0), ("dedicated", 1), ("dedicated", 42)
    ], "complete command population"
    channels = []
    total = len(manifest["entries"]) + len(manifest["overlays"])
    for run in report["runs"]:
        tail = ["prove", "-v", "-Iperl"] + TESTS if run["kind"] == "fixtures" else [
            "perl", "-Iperl", Path(PREFIX + "probe.pl").relative_to(ROOT).as_posix()
        ]
        assert run["command"] == ["bash", "tools/project_data_run.sh"] + tail, "actual command identity"
        assert run["exit"] == 0 and run.get("inputs_before") == run.get("inputs_after") == total, "complete runtime guards"
        assert decode(run["stderr"]) == b"", "empty outer stderr"
        raw = decode(run["stdout"])
        if run["kind"] == "dedicated":
            check_document(json.loads(raw), authored)
            channels.append(raw)
        else:
            text = raw.decode()
            assert not re.search(r"^\s*not ok\b", text, re.M), "all nested fixture assertions pass"
            assert re.findall(r"^(t/\S+\.t) \.\.", text, re.M) == TESTS, "complete ordered fixture population"
            assert re.findall(r"^1\.\.(\d+)\s*$", text, re.M) == [str(plan) for plan in PLANS], "complete original fixture plans"
            for test, plan in zip(TESTS, PLANS):
                part = text.split(test + " ..", 1)[1].split("\n1.." + str(plan), 1)[0]
                assert re.findall(r"^ok (\d+)\b", part, re.M) == [
                    str(index) for index in range(1, plan + 1)
                ], "complete ordered positive fixture reach"
            assert "All tests successful." in text and "Result: PASS" in text, "complete successful fixture summary"
    assert channels[0] == channels[1] == channels[2], "complete original channels identical across seeds"


def main():
    manifest = json.loads(Path(PREFIX + "inputs.json").read_bytes())
    report = json.loads(Path(PREFIX + "observations.json").read_bytes())
    authored = json.loads(Path(PREFIX + "cases.json").read_bytes())
    inventory = json.loads(Path(PREFIX + "inventory.json").read_bytes())
    assert inventory["contracts"] == authored["contracts"], "complete original dedicated contract census"
    assert len(set(inventory["contracts"])) == 7, "unique original dedicated contracts"
    for owner in inventory["owners"]:
        raw = (ROOT / owner["path"]).read_bytes()
        assert sha(raw) == owner["sha256"] and len(raw) == owner["bytes"], "exact original producer"
        assert owner["private_source_recorder_calls"] == 0, "original producer recorder gap"
    check_inputs(manifest)
    check_report(report, manifest, authored)
    document = json.loads(decode(report["runs"][1]["stdout"]))
    measured = check_document(document, authored)
    controls = []

    def reject(name, target, mutation, validator, reason):
        bad = copy.deepcopy(target)
        mutation(bad)
        assert bad != target, "effective changed control: " + name
        try:
            validator(bad)
        except AssertionError as error:
            assert str(error) == reason, "reason-specific control: " + name + ": " + str(error)
            controls.append({"name": name, "observed": "RED", "reason": reason})
            return
        raise AssertionError("accepted corruption: " + name)

    validate = lambda value: check_document(value, authored)
    for case_index, case in enumerate(authored["cases"]):
        for row_index, expected in enumerate(case["rows"]):
            if not expected["expected_events"]:
                continue
            reject(case["id"] + "/" + expected["contract"] + " omitted event", document,
                   lambda value, i=case_index, j=row_index: value["cases"][i]["rows"][j]["public"]["result"].pop(),
                   validate, "literal original events and arguments")
    for contract_index, contract in enumerate(authored["contracts"]):
        case_index = contract_index * 2
        for channel in ("public", "private"):
            for identity in ("event", "args"):
                reject(contract + "/" + channel + " forged " + identity, document,
                       lambda value, i=case_index, c=channel, k=identity:
                           value["cases"][i]["rows"][0][c]["identity"][0].update({k: False}),
                       validate, "actual dispatcher event and argument identities")
            reject(contract + "/" + channel + " cloned return array", document,
                   lambda value, i=case_index, c=channel:
                       value["cases"][i]["rows"][0][c].update(returned_array=False),
                   validate, "actual dispatcher returned-array identity")
        reject(contract + " invented source origin", document,
               lambda value, i=case_index:
                   value["cases"][i]["rows"][0]["private"]["result"]["source_origins"].append({}),
               validate, "original dedicated source-origin gap")
        reject(contract + " paired wrong repeated interval", document,
               lambda value, i=case_index:
                   value["cases"][i]["statement_frames"][2].update(
                       source_span=value["cases"][i]["statement_frames"][1]["source_span"]),
               validate, "independent original statement intervals")
        reject(contract + " lost callback", document,
               lambda value, i=case_index: value["cases"][i]["rows"][0]["private"]["calls"].pop(),
               validate, "exact original callback channels")
    for index, row in enumerate(document["toolbox"]):
        node, spelling = MARKERS[row["id"]]
        reject(row["id"] + " lost dedicated node", document,
               lambda value, i=index, n=node:
                   value["toolbox"][i]["descriptor"]["canonical_action_ir_nodes"].remove(n),
               validate, "dedicated compiler node")
        for channel, reason in (("substitution", "dedicated substitution constructor"),
                                ("dump", "dedicated emitted constructor")):
            reject(row["id"] + " changed " + channel, document,
                   lambda value, i=index, c=channel, s=spelling:
                       value["toolbox"][i].update({c: value["toolbox"][i][c].replace(s, "omitted_constructor")}),
                   validate, reason)
    report_validator = lambda value: check_report(value, manifest, authored)
    report_controls = [
        ("lost command", lambda value: value["runs"].pop(), "complete command population"),
        ("lost guard", lambda value: value["runs"][1].pop("inputs_after"), "complete runtime guards"),
        ("failed actual exit", lambda value: value["runs"][1].update(exit=1), "complete runtime guards"),
        ("changed actual command", lambda value: value["runs"][1]["command"].append("--invented"), "actual command identity"),
        ("forged channel", lambda value: value["runs"][1]["stdout"].update(sha256="0" * 64), "complete channel bytes"),
        ("forged capture", lambda value: value.update(instrument_sha256="0" * 64), "actual capture producer"),
        ("forged stream", lambda value: value.update(stream_instrument_sha256="0" * 64), "actual stream producer"),
        ("incomplete capture", lambda value: value.update(complete=False), "complete diagnosis boundary"),
    ]
    for name, mutation, reason in report_controls:
        reject(name, report, mutation, report_validator, reason)
    fixture_text = decode(report["runs"][0]["stdout"])
    shortened = fixture_text.replace(b"ok 143 - ", b"ok 144 - ", 1)
    reject("shortened positive TAP reach", report,
           lambda value: value["runs"][0].update(stdout=envelope(shortened)),
           report_validator, "complete ordered positive fixture reach")
    nested_failure = fixture_text.replace(b"    ok 1 - ", b"    not ok 1 - ", 1)
    reject("hidden nested TAP failure", report,
           lambda value: value["runs"][0].update(stdout=envelope(nested_failure)),
           report_validator, "all nested fixture assertions pass")
    reject("lost original Git input", manifest, lambda value: value["entries"].pop(),
           check_inputs, "complete unique original Git population")
    reject("lost authored overlay", manifest, lambda value: value["overlays"].pop(),
           check_inputs, "exact authored overlay population")
    result = {
        "complete": True, "revision": REVISION, "regular_inputs": len(manifest["entries"]),
        "overlays": len(manifest["overlays"]), "commands": len(report["runs"]),
        "contracts": len(inventory["contracts"]), "seeds": 3, **measured,
        "fixture_suites": len(TESTS), "fixture_groups": sum(PLANS),
        "controls": controls, "instrument_sha256": sha(Path(__file__).read_bytes()),
        "scope": "Original seven dedicated syntactic contracts, dispatcher-returned identities and compiler construction only. No production change or executable membership; selected direct consumers run once. Complete supplied Git superset is not minimal observed I/O. Existing separately owned runtime defects and global historical audits stay open.",
    }
    Path(PREFIX + "verification.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({key: value for key, value in result.items() if key != "controls"}))
    print(str(len(controls)) + " effective reason-specific evidence controls RED")


if __name__ == "__main__":
    main()
