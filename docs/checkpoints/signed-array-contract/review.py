"""Read-only semantic review of the finite target proof and actual channels."""
import ast
import json
import subprocess
import sys
import common as c
import book

SOURCE = "tools/check_signed_array_selector_contract.py"
CONTRACT = "capability_conformance/signed_array_selector_contract.json"


def packet_check(packet):
    raw = c.decode(packet["base64"])
    assert c.sha(raw) == packet["sha256"]
    assert isinstance(packet["mode"], int)
    return raw


def artifact_detail():
    """Check payloads and the actual harness, beyond aggregate denials."""
    import copy
    import publish
    supplied = c.load("artifact-controls-inputs.json.gz")
    import import_epoch
    source_bundle = c.load("validator-import-sources.json.gz")
    import_epoch.verify_sources(source_bundle, supplied)
    custody = import_epoch.verify_replays(source_bundle, c.load("validator-import-replays.json.gz"), c.load("artifact-controls.json.gz"))
    required = {c.PREFIX + name for name in ("import_epoch.py", "repair_import_epoch.py",
        "validator-import-before.json.gz", "validator-import-sources.json.gz", "validator-import-replays.json.gz",
        "publication1-inputs.json.gz", "publication1.json", "publication1-claim.json")}
    assert required <= set(publish.input_paths()), "validator import required inputs"
    actor = ast.parse(packet_check(supplied["actor"]))
    runner = next(node.value for node in actor.body if isinstance(node, ast.Assign)
        and any(isinstance(target, ast.Name) and target.id == "RUNNER" for target in node.targets))
    assert ast.literal_eval(runner).encode() == c.decode(supplied["runner_base64"])
    target = "capability_conformance/signed_array_selector_contract.json"
    identity = {target: c.identity(target)}
    for name, case in supplied["cases"]["identity"].items():
        assert case["good"] == dict(declared=identity, actual=identity)
        altered = copy.deepcopy(identity)
        if name == "missing":
            altered = {}
        elif name == "bytes":
            altered[target]["sha256"] = "0" * 64
        elif name == "mode":
            altered[target]["mode"] ^= 0o100
        else:
            raise AssertionError("unknown identity case")
        assert case["bad"] == dict(declared=altered, actual=identity)
    omissions = dict(model_producer="tools/check_signed_array_selector_contract.py",
        neutral_observations=c.PREFIX + "neutral-runs.json.gz")
    assert set(supplied["cases"]["scope"]) == set(omissions)
    for name, case in supplied["cases"]["scope"].items():
        assert case["omitted"] == omissions[name]
        good = case["good"]["actual"]
        publish.validate_scope(good, controls_ready=False)
        altered = dict(good)
        del altered[omissions[name]]
        assert case["bad"] == dict(actual=altered)
    observed = c.load("artifact-controls.json.gz")
    for category, controls in observed.items():
        for name, phases in controls.items():
            case = supplied["cases"][category][name]
            for phase, row in phases.items():
                assert row["payload"] == case["good" if phase == "restored" else "bad"]
                assert row["mode"] == supplied["publisher"]["mode"]
                command = row["run"]["command"]
                assert len(command) == 6 and command[:2] == ["python3", "-B"] and command[-1] == category
                for path, basename in zip(command[2:5], ("runner.py", "publisher.py", "inputs.json"), strict=True):
                    from pathlib import Path
                    assert not Path(path).is_absolute() and ".." not in Path(path).parts
                    assert Path(path).name == basename

    return custody


def check():
    inputs = c.load("neutral-inputs.json.gz")
    assert inputs["base"] == c.BASE
    packets = inputs["packets"]
    for path, packet in packets.items():
        packet_check(packet)
        assert c.read(path) == packet, "neutral source identity: " + path
    # Import the actual, identity-checked consumer; no writer modules execute.
    sys.path.insert(0, str(c.ROOT / "tools"))
    import check_signed_array_selector_contract as model
    contract = json.loads(packet_check(packets[CONTRACT]))
    summary = model.validate(contract)
    denials = []
    for name, candidate in model.mutations(contract):
        try:
            model.validate(candidate)
        except model.v1.ContractError as error:
            denials.append(dict(name=name, code=error.code, reason=str(error)))
        else:
            raise AssertionError("fixture mutation survived: " + name)
    summary["mutation_denials"] = denials
    actual = c.load("neutral-runs.json.gz")
    assert actual["summary"] == summary
    native = actual["native"]
    assert native["command"] == ["bash", "tools/run_python_project_data.sh", SOURCE, "--json"]
    assert native["returncode"] == 0 and not c.decode(native["stderr_base64"])
    assert json.loads(c.decode(native["stdout_base64"])) == summary
    for path, run in zip(
        ("tools/check_write_vivification_contract.py", "tools/check_map_leaves_mutation_contract.py"),
        actual["compatibility"], strict=True,
    ):
        assert run["command"] == ["bash", "tools/run_python_project_data.sh", path]
        assert run["returncode"] == 0 and not c.decode(run["stderr_base64"])
    # Derive fault memberships/replacements from the actual retained actor.
    actor = packet_check(packets[c.PREFIX + "capture.py"])
    tree = ast.parse(actor)
    assignment = next(node for node in tree.body if isinstance(node, ast.Assign)
        and any(isinstance(target, ast.Name) and target.id == "changes" for target in node.targets))
    changes = ast.literal_eval(assignment.value)
    raw = packet_check(packets[SOURCE])
    rows = actual["isolated_sources"]
    assert set(rows) == set(changes) | {"healthy", "restored"}
    for name, row in rows.items():
        source = c.decode(row["source_base64"])
        assert c.sha(source) == row["source_sha256"]
        assert row["command"] == ["python3", "-B", SOURCE, "--json"]
        if name in ("healthy", "restored"):
            assert source == raw
            assert row["returncode"] == 0 and not c.decode(row["stderr_base64"])
            assert json.loads(c.decode(row["stdout_base64"])) == summary
        else:
            before, after, marker = changes[name]
            assert raw.count(before) == 1 and source == raw.replace(before, after, 1)
            assert row["returncode"] == 1 and not c.decode(row["stdout_base64"])
            assert c.decode(row["stderr_base64"]).rstrip().endswith(marker)
    expected_copies = [
        path for path in packets if path.startswith(("tools/check_", "capability_conformance/"))
    ]
    assert len(actual["copied_inputs"]) == len(expected_copies)
    assert set(actual["copied_inputs"]) == set(expected_copies)

    activation = c.load("activation.json.gz")
    assert activation["base"] == c.BASE
    assert activation["prior_readonly"]["returncode"] == 0
    assert not c.decode(activation["prior_readonly"]["stderr_base64"])
    assert not c.decode(activation["status"]["stdout_base64"])
    images = activation["prior_images"]
    git_tree = {}
    for entry in subprocess.check_output(["git", "ls-tree", "-rz", c.BASE], cwd=c.ROOT).split(b"\0"):
        if entry:
            metadata, name = entry.split(b"\t", 1)
            mode, kind, oid = metadata.decode().split()
            if mode in ("100644", "100755"):
                git_tree[name.decode()] = dict(mode=mode, oid=oid)
    for path, item in images.items():
        assert item["git"] == git_tree[path]
        assert c.identity(path) == {key: item[key] for key in ("sha256", "mode")}
    verification = c.run(["git", "hash-object", "--stdin-paths"],
        input=("\n".join(sorted(images)) + "\n").encode())
    assert verification["returncode"] == 0 and not c.decode(verification["stderr_base64"])
    assert c.decode(verification["stdout_base64"]).decode().splitlines() == [
        images[path]["git"]["oid"] for path in sorted(images)
    ]
    for path, packet in activation["prior_outputs"].items():
        assert c.read(path) == packet
    planned = set(activation["planned_paths"])
    for claim in activation["live_claims"].values():
        packet_check(claim["packet"])
        assert not planned & set(claim["inputs"])

    teaching = c.load("book-inputs.json.gz")
    assert teaching["producer"] == c.read(c.PREFIX + "book.py")
    assert teaching["contract"] == packets[CONTRACT]
    for packet in teaching["packets"].values():
        packet_check(packet)
    book_runs = c.load("book-runs.json.gz")
    book.validate(book_runs["healthy"], contract)
    reasons = dict(pending="pending heading", bounds="target arithmetic table", snapshot="post-expression normalization")
    assert book_runs["denials"] == reasons
    faults = c.load("book-fault-inputs.json.gz")
    tick = bytes([96])
    expected_faults = {
        "pending": book.changed(teaching["packets"], book.HEADING.encode(), b"Signed selectors admitted on all backends"),
        "bounds": book.changed(teaching["packets"], tick + b"[-4]" + tick + b" | " + tick + b"null" + tick,
            tick + b"[-4]" + tick + b" | " + tick + b"10" + tick),
        "snapshot": book.changed(teaching["packets"], book.MARKER.encode(), b"Negative selectors resolve before selector and RHS evaluation."),
    }
    assert faults == expected_faults
    for name, run in book_runs["faults"].items():
        assert run["returncode"] == 0
        try:
            book.validate(run, contract)
        except AssertionError as error:
            assert str(error) == reasons[name]
        else:
            raise AssertionError("book fault admitted: " + name)
    # Preserve the three unpublished instrument qualifications separately.
    builder = c.load("builder-qualification.json.gz")
    assert builder["reproduction"]["returncode"] == 1
    assert b"got multiple values for argument 'index'" in c.decode(builder["reproduction"]["stderr_base64"])
    capture = c.load("capture-qualification.json.gz")
    assert capture["reproduction"]["returncode"] == 1
    assert b"AssertionError: ('reject_all_negative'" in c.decode(capture["reproduction"]["stderr_base64"])
    document = c.load("document-qualification.json.gz")
    assert document["reproduction"]["returncode"] == 1
    assert b"AssertionError" in c.decode(document["reproduction"]["stderr_base64"])
    for value in (builder, capture, document):
        packet_check(value["producer_before"])
    custody = artifact_detail()
    return dict(
        arithmetic_cases=summary["arithmetic_cases"], read_cases=summary["read_cases"],
        write_cases=summary["write_cases"], historical_write_outcomes=summary["historical_write_outcomes"],
        fixture_mutation_denials=len(denials), actual_source_denials=len(changes),
        book_inputs=len(teaching["packets"]), book_source_denials=len(reasons),
        prior_git_images=len(images), validator_import=custody,
        limits="Neutral target and finite physical model controls only; no new backend, generated route, broad read-coercion or portable support admission. Frozen authorities/history remain unchanged. Three unpublished authoring/capture/document failures remain qualified without product RED credit.",
    )


if __name__ == "__main__":
    print(json.dumps(check(), sort_keys=True))
