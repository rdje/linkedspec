"""Read-only, case-level review of retained Perl implementation evidence."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import common as c
import book
import oracle
import review_explore

FAULTS = ("inverse", "indexed-reader", "nested-reader", "result-reader", "float-spelling",
    "underflow-diagnostic", "missing-array", "aliased-result")


def packet(item):
    raw = c.decode(item["base64"])
    assert c.sha(raw) == item["sha256"]
    assert isinstance(item["mode"], int) and 0 <= item["mode"] <= 0o7777
    return raw


def source_epochs():
    epochs = {}
    for path in sorted((c.ROOT / c.PREFIX).glob("*-inputs.json.gz")):
        value = json.loads(gzip.decompress(path.read_bytes()))
        if "context" in value:
            epochs[path.name] = value["context"]
    tree = {}
    for row in subprocess.check_output(["git", "ls-tree", "-rz", c.BASE], cwd=c.ROOT).split(b"\0"):
        if row:
            meta, path = row.split(b"\t", 1)
            mode, kind, oid = meta.decode().split()
            if mode in ("100644", "100755"):
                assert kind == "blob"
                tree[path.decode()] = dict(mode=mode, oid=oid)
    oids = {tree[path]["oid"] for epoch in epochs.values() for path in epoch["inputs"]
        if path not in epoch["overrides"] and path in tree}
    digests = {}
    with tempfile.TemporaryFile(dir=os.environ["TMPDIR"]) as requests, tempfile.TemporaryFile(dir=os.environ["TMPDIR"]) as errors:
        requests.write(("\n".join(sorted(oids)) + "\n").encode())
        requests.seek(0)
        process = subprocess.Popen(["git", "cat-file", "--batch"], cwd=c.ROOT,
            stdin=requests, stdout=subprocess.PIPE, stderr=errors)
        try:
            for expected in sorted(oids):
                header = process.stdout.readline().decode().split()
                assert len(header) == 3 and header[:2] == [expected, "blob"]
                remaining = int(header[2])
                digest = hashlib.sha256()
                while remaining:
                    block = process.stdout.read(min(remaining, 1024 * 1024))
                    assert block
                    digest.update(block)
                    remaining -= len(block)
                assert process.stdout.read(1) == b"\n"
                digests[expected] = digest.hexdigest()
            assert process.wait() == 0
            errors.seek(0)
            assert not errors.read()
        finally:
            if process.poll() is None:
                process.kill()
            process.wait()
            process.stdout.close()
    for name, epoch in epochs.items():
        assert epoch["head"] == epoch["base"] == c.BASE, name
        assert set(epoch["overrides"]) <= set(epoch["inputs"])
        for path, item in epoch["inputs"].items():
            assert not Path(path).is_absolute() and ".." not in Path(path).parts
            if path in epoch["overrides"]:
                supplied = epoch["overrides"][path]
                packet(supplied)
                assert {key: supplied[key] for key in ("sha256", "mode")} == item
            elif path in tree:
                assert digests[tree[path]["oid"]] == item["sha256"], (name, path)
                assert bool(item["mode"] & 0o100) == (tree[path]["mode"] == "100755")
            else:
                assert path.startswith(c.PREFIX) and path.endswith((".gz", ".part")), (name, path)
                assert c.identity(path) == item
    required = {"before-inputs.json.gz", "after-inputs.json.gz", "green-inputs.json.gz", "book-inputs.json.gz",
        "focused-additional-inputs.json.gz"}
    required.update("verified-" + phase + "-" + name + "-inputs.json.gz" for name in FAULTS for phase in ("fault", "restore"))
    assert required <= set(epochs)
    return dict(epochs=len(epochs), accepted_git_blobs=len(oids), base=c.BASE)


def observations(name):
    value = c.load(name + "-runs.json.gz")
    assert value["inputs_unchanged"]
    return value["observations"]


def public():
    original = json.loads(packet(c.load("public-fixture.json.gz")["output"]))
    corrected = json.loads(packet(c.load("public-qualification.json.gz")["output"]))
    assert corrected == json.loads(packet(c.load("green-inputs.json.gz")["plan"]))
    qualifications = {row["id"] for row in c.load("public-qualification.json.gz")["changed"]}
    assert qualifications == {"write-order/ordinary", "write-order/callable"}
    assert len(original["cases"]) == len(corrected["cases"]) == 120
    assert [row["id"] for row in original["cases"]] == [row["id"] for row in corrected["cases"]]
    for before, after in zip(original["cases"], corrected["cases"]):
        if before["id"] not in qualifications:
            assert before == after
    before, after, green = (observations(name) for name in ("before", "after", "green"))
    source_before = c.load("before-inputs.json.gz")["sources"]
    for path, value in source_before.items():
        assert packet(value) == subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
    source_after = c.load("after-inputs.json.gz")["sources"]
    assert source_after == c.load("green-inputs.json.gz")["sources"]
    result = {}
    for route in ("native", "generated"):
        failures = oracle.check(original, route, before[route])
        assert len(failures) == 55
        assert len([row for row in failures if row["id"] not in qualifications]) == 53
        failures_after = oracle.check(original, route, after[route])
        assert {row["id"] for row in failures_after} == qualifications
        assert not oracle.check(corrected, route, green[route])
        for run in (before[route], after[route], green[route]):
            loaded = json.loads(c.decode(run["stdout_base64"]))["inc"]
            for module in ("LinkedSpec/BindingRuntime.pm", "LinkedSpec/CodeblockRuntime.pm"):
                assert loaded[module] == "perl/" + module or loaded[module].endswith("/perl/" + module)
        result[route] = dict(original_product_red=53, qualified_instruments=2, corrected_green=120)
    descriptor = {name: json.loads(c.decode(value["descriptor"]["stdout_base64"]))["rows"]
        for name, value in (("before", before), ("after", after), ("green", green))}
    assert all(len(rows) == 120 for rows in descriptor.values())
    for index, case in enumerate(corrected["cases"]):
        row = descriptor["green"][index]
        assert row["id"] == case["id"] and row["completed"]
        meta = row["value"]
        assert meta["canonical_action_ir_fallback_count"] == 0
        assert meta["raw_perl_dependency_count"] == (1 if case["id"].startswith("control/result_path_") else 0)
        assert descriptor["before"][index]["value"] == descriptor["after"][index]["value"]
        if case["id"] not in qualifications:
            assert descriptor["before"][index]["value"] == meta
    assert before["permanent"]["returncode"] != 0 and after["permanent"]["returncode"] != 0
    focused = green["focused"]
    assert focused["returncode"] == 0
    summary = re.findall(r"Files=(\d+), Tests=(\d+),", c.decode(focused["stdout_base64"]).decode())
    assert summary == [("9", "781")]
    return dict(public=result, focused_files=9, focused_top_level_tests=781,
        frozen_reads=14, frozen_writes=33, arithmetic=12,
        result_path="existing raw dependency marker1 retained; no pure-source promotion")


def faults():
    value = c.load("verified-faults.json.gz")
    assert value["exact_restoration"]
    bridge = c.load("verified-producer-bridge.json.gz")
    actual_path = c.PREFIX + "faults_verified.py"
    assert bridge["actual_path"] == actual_path
    actual = packet(bridge["actual_producer"])
    first = c.load("verified-fault-inverse-inputs.json.gz")["context"]
    assert first["overrides"][actual_path] == bridge["actual_producer"]
    old = packet(bridge["original_pointer"])
    expected = old.replace(b'"fault-controller-inputs.json.gz"', b'"verified-fault-controller-inputs.json.gz"')
    expected = expected.replace(b'observe("fault-" + name', b'observe("verified-fault-" + name')
    expected = expected.replace(b'observe("restore-" + name', b'observe("verified-restore-" + name')
    expected = expected.replace(b'"faults.json.gz"', b'"verified-faults.json.gz"')
    assert expected == actual
    interruption = c.load("fault-interruption.json.gz")
    assert interruption["runtime_restored"] and set(interruption["sole_change"]) == {c.PREFIX + "review.py"}
    packet(interruption["reviewer_before"])
    packet(interruption["reviewer_after"])
    assert not c.load("restore-nested-reader-runs.json.gz")["inputs_unchanged"]
    assert [row["name"] for row in value["outcomes"]] == list(FAULTS)
    for row in value["outcomes"]:
        name = row["name"]
        data = c.load("verified-fault-" + name + "-runs.json.gz")
        plan = c.load("verified-fault-" + name + "-inputs.json.gz")["plan"]
        assert data["inputs_unchanged"]
        for route in ("native", "generated"):
            actual = oracle.check(plan, route, data["observations"][route])
            normalize = lambda rows: [dict(id=item["id"], reasons=sorted(item["reasons"])) for item in rows]
            assert normalize(actual) == normalize(data["failures"][route])
            assert len(actual) == row["public_red"][route]
            if name == "inverse":
                assert len(actual) == 55
            elif name != "aliased-result":
                assert actual
        restored = c.load("verified-restore-" + name + "-runs.json.gz")
        restored_plan = c.load("verified-restore-" + name + "-inputs.json.gz")["plan"]
        assert restored["inputs_unchanged"]
        assert not any(oracle.check(restored_plan, route, restored["observations"][route])
            for route in ("native", "generated"))
        if name == "aliased-result":
            assert data["observations"]["permanent"]["returncode"] != 0
            assert restored["observations"]["permanent"]["returncode"] == 0
        assert row["restored"]
        assert c.load("verified-restore-" + name + "-inputs.json.gz")["sources"] == c.load("green-inputs.json.gz")["sources"]
    return dict(physical_variants=8, public_detected=7, detachment_detected=1, exact_restoration=True)


def book_check():
    inputs = c.load("book-inputs.json.gz")
    packets = inputs["inputs"]
    for path, item in packets.items():
        packet(item)
    runs = c.load("book-runs.json.gz")
    assert runs["inputs_unchanged"]
    book.validate(runs["healthy"], packets)
    assert set(runs["faults"]) == {"heading", "support", "example"}
    for name, value in runs["faults"].items():
        assert value["run"]["returncode"] == 0
        try:
            book.validate(value["run"], packets)
        except AssertionError as error:
            assert str(error) == value["reason"] and value["rejected"]
        else:
            raise AssertionError(name)
    for route, run in c.load("book-runtime.json.gz").items():
        assert not oracle.check(inputs["plan"], route, run)
    for route, run in runs["wrong_runs"].items():
        failures = oracle.check(runs["wrong_plan"], route, run)
        assert len(failures) == 1 and failures[0]["reasons"] == ["typed value"]
    return dict(inputs=len(packets), native_emitted_examples=4, rendered_source_denials=3, executed_selector_denial=True)


def custody():
    value = c.load("activation.json.gz")
    assert value["base"] == c.BASE and value["prior_readonly"]["returncode"] == 0
    assert len(value["prior_images"]) == 51
    for path, item in value["prior_images"].items():
        raw = subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
        assert c.sha(raw) == item["sha256"]
        assert c.identity(path) == {key: item[key] for key in ("sha256", "mode")}
    for record in value["live_claims"].values():
        packet(record["packet"])
        assert not set(record["inputs"]) & set(value["planned_paths"])
    for path in ("capability_conformance/write_vivification_contract.json",
            "capability_conformance/map_leaves_mutation_contract.json",
            "capability_conformance/write_map_leaves_composition_contract.json",
            "capability_conformance/signed_array_selector_contract.json",
            "tools/check_signed_array_selector_contract.py", "tools/check_write_vivification_contract.py"):
        assert c.source(path).read_bytes() == subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
    return dict(accepted_neutral_images=51, prior_live_records=len(value["live_claims"]), frozen_authorities_unchanged=True)


def additional():
    value = c.load("focused-additional-runs.json.gz")
    assert value["inputs_unchanged"] and value["run"]["returncode"] == 0
    assert value["run"]["command"] == ["bash", "tools/project_data_run.sh", "prove", "-v", "-Iperl",
        "t/map_leaves_mutation_perl_contract.t"]
    assert c.load("focused-additional-inputs.json.gz")["sources"] == c.load("green-inputs.json.gz")["sources"]
    summary = re.findall(r"Files=(\d+), Tests=(\d+),", c.decode(value["run"]["stdout_base64"]).decode())
    assert summary == [("1", "8")]
    return dict(files=1, top_level_tests=8, direct_total_files=10, direct_total_top_level_tests=789)


def check():
    return dict(custody=custody(), exploration=review_explore.check(), source=source_epochs(),
        implementation=public(), direct_dependent=additional(), faults=faults(), book=book_check(),
        limits="Dated finite Perl native/emitted public population and actual deferred fixture projection; unrelated coercions/read receiver order preserved. Two infix instrument errors and an interrupted original source-fault suite earn no product RED/completion credit. The distinct full rerun's inherited convenience producer pointer is resolved from its whole actual pre-command source epoch, without regenerating bytes or runs. SDK/OS/public dependency outputs are read-only prerequisites. No other-backend, exhaustive spelling or portable admission.")


if __name__ == "__main__":
    print(json.dumps(check(), sort_keys=True))
