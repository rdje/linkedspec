"""Capture once; default review is read-only and never recaptures evidence."""
import json
import sys
import common as c
import review

MANIFEST = c.PREFIX + "publication-inputs.json.gz"
PUBLICATION = c.PREFIX + "publication.json"
CLAIM = "docs/claims/" + c.OWNER + ".json"
DIRECT = [
    "tools/check_signed_array_selector_contract.py",
    "capability_conformance/signed_array_selector_contract.json",
    "tools/check_write_vivification_contract.py",
    "tools/check_map_leaves_mutation_contract.py",
    "capability_conformance/write_vivification_contract.json",
    "capability_conformance/map_leaves_mutation_contract.json",
    "capability_conformance/write_map_leaves_composition_contract.json",
    "tools/project_data_env.sh", "tools/project_data_run.sh", "tools/run_python_project_data.sh",
    "tools/run_mdbook_local.sh",
]
FLOOR = [
    "activate.py", "activation.json.gz", "common.py", "build_fixtures.py",
    "qualify_builder.py", "builder-qualification.json.gz",
    "qualify_capture.py", "capture-qualification.json.gz",
    "qualify_document.py", "document-qualification.json.gz",
    "capture.py", "neutral-inputs.json.gz", "neutral-runs.json.gz",
    "document.py", "documentation-before.json.gz", "documentation.json.gz",
    "book.py", "book-inputs.json.gz", "book-fault-inputs.json.gz", "book-runs.json.gz",
    "review.py", "publish.py", "artifact_controls.py", "README.md",
]


def input_paths():
    owned = {path.relative_to(c.ROOT).as_posix()
        for path in (c.ROOT / c.PREFIX).iterdir() if path.is_file()}
    return sorted((owned | set(DIRECT)) - {MANIFEST, PUBLICATION, CLAIM})


def validate_inputs(declared, actual):
    assert set(declared) == set(actual), "input population"
    for path, item in actual.items():
        assert declared[path]["sha256"] == item["sha256"], "input bytes: " + path
        assert declared[path]["mode"] == item["mode"], "input mode: " + path


def validate_scope(actual, controls_ready=True):
    required = set(DIRECT) | {c.PREFIX + name for name in FLOOR}
    if controls_ready:
        required.update(c.PREFIX + name for name in ("artifact-controls-inputs.json.gz", "artifact-controls.json.gz"))
    missing = sorted(required - set(actual))
    assert not missing, "required input: " + ",".join(missing)


def control_review():
    inputs = c.load("artifact-controls-inputs.json.gz")
    actual = c.load("artifact-controls.json.gz")
    original = c.decode(inputs["publisher"]["base64"])
    assert inputs["publisher"] == c.read(c.PREFIX + "publish.py")
    assert inputs["actor"] == c.read(c.PREFIX + "artifact_controls.py")
    assert c.sha(original) == inputs["publisher"]["sha256"]
    result = dict(identity_denials=0, identity_bypass_admissions=0,
        scope_denials=0, scope_bypass_admissions=0)
    for category, controls in actual.items():
        assert category in ("identity", "scope")
        marker = b"def validate_inputs(declared, actual):\n" if category == "identity" else b"def validate_scope(actual, controls_ready=True):\n"
        faulty = original.replace(marker, marker + b"    return\n", 1)
        assert faulty != original
        for name, phases in controls.items():
            assert set(phases) == {"healthy", "bypass", "validator_restored", "restored"}
            for phase, row in phases.items():
                source = c.decode(row["source_base64"])
                assert source == (faulty if phase == "bypass" else original)
                assert c.sha(source) == row["source_sha256"]
                observed = json.loads(c.decode(row["run"]["stdout_base64"]))
                assert not c.decode(row["run"]["stderr_base64"])
                if phase in ("healthy", "validator_restored"):
                    assert row["run"]["returncode"] == 1 and not observed["admitted"]
                    expected = inputs["cases"][category][name]["reason"]
                    assert observed["reason"] == expected
                else:
                    assert row["run"]["returncode"] == 0 and observed == {"admitted": True}
            result[category + "_denials"] += 1
            result[category + "_bypass_admissions"] += 1
    assert set(actual["identity"]) == {"missing", "bytes", "mode"}
    assert set(actual["scope"]) == {"model_producer", "neutral_observations"}
    return result


def record(result, controls):
    bindings = [
        dict(path=path, sha256=c.identity(path)["sha256"],
            role="producer" if path.endswith((".py", ".pl", ".sh")) else "input")
        for path in input_paths() + [MANIFEST]
    ]
    return dict(version=1, owner=c.OWNER, claims=[dict(
        name="signed-selector-neutral-target",
        statement="A separate pending authority/checker defines length-plus-index arithmetic, noncreating negative positions, post-expression writes and exact diagnostics while preserving all30 frozen-v1 write outcomes and authority identities.",
        scope="Finite neutral12 arithmetic/14 read/33 write fixtures and122 fixture denials, five actual isolated model-source faults, complete91-input book and three actual source/render denials, prior72-image Git custody. No native/generated backend, new read coercion/range or portable admission.",
        rederive=dict(status="checked", command="bash tools/run_python_project_data.sh " + c.PREFIX + "publish.py",
            granularity="Each authored fixture/outcome/effect/full diagnostic; actual source variant and command channels; exact historical outcome and identities; complete book-source population and rendered table.",
            result=json.dumps(result, sort_keys=True)),
        falsify=dict(status="checked",
            hypothesis="A blanket negative rejection, clamped underflow, pre-expression snapshot, bypassed identity guard or aliased return could appear compatible with positive indexing; rendered teaching or a jointly incomplete manifest could conceal the distinction.",
            oracle="Independently authored numeric/state/effect/diagnostic/detachment targets, unchanged historical-v1 outcomes, pending rendered teaching and an independent finite required-input floor.",
            red_control="Five altered physical model sources actually exit1 at named controls while healthy/restored sources pass;122 altered fixture contracts reject. Three altered book sources render but reject. Three identity and two scope cases reject, admit under actual isolated validator bypass, and reject after restoring the validator. " + json.dumps(controls, sort_keys=True)),
        durability=dict(status="checked", mode="live", inputs=bindings),
    )])


def main():
    assert sys.argv[1:] in ([], ["--capture"])
    capture = sys.argv[1:] == ["--capture"]
    inputs = {path: c.identity(path) for path in input_paths()}
    validate_scope(inputs)
    if capture:
        assert not (c.ROOT / CLAIM).exists()
        c.write_new("publication-inputs.json.gz", dict(base=c.BASE, inputs=inputs,
            scope="Bounded actual actors, retained channels, whole model/book source packets and direct neutral producers/frozen authorities. Future mutable book/continuity is not a live input; target tool/JSON and frozen sources remain identity-gated. Python/mdBook/OS are read-only prerequisites."))
    validate_inputs(c.load("publication-inputs.json.gz")["inputs"], inputs)
    result = review.check()
    controls = control_review()
    validate_inputs(inputs, {path: c.identity(path) for path in input_paths()})
    raw = (json.dumps(record(result, controls), separators=(",", ":")) + "\n").encode()
    publication = dict(result=result, controls=controls, record_base64=c.encode(raw))
    if capture:
        c.write_new("publication.json", publication)
        with (c.ROOT / CLAIM).open("xb") as output:
            output.write(raw)
    else:
        assert c.load("publication.json") == publication
        assert (c.ROOT / CLAIM).read_bytes() == raw
    print("Signed target publication PASS:", len(inputs), "bounded inputs; backend admission pending")


if __name__ == "__main__":
    main()
