"""One publication capture; default execution only reviews dated retained evidence."""
import json
import sys
import common as c
import review

MANIFEST = c.PREFIX + "publication-inputs.json.gz"
PUBLICATION = c.PREFIX + "publication.json"
CLAIM = "docs/claims/" + c.OWNER + ".json"
WRAPPERS = ("tools/project_data_env.sh", "tools/project_data_run.sh",
    "tools/run_python_project_data.sh", "tools/run_mdbook_local.sh")
FIXED = ("capability_conformance/write_vivification_contract.json",
    "capability_conformance/map_leaves_mutation_contract.json",
    "capability_conformance/write_map_leaves_composition_contract.json",
    "capability_conformance/signed_array_selector_contract.json",
    "tools/check_signed_array_selector_contract.py", "tools/check_write_vivification_contract.py")


def input_paths():
    owned = {path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir() if path.is_file()}
    return sorted((owned | set(WRAPPERS) | set(FIXED)) - {MANIFEST, PUBLICATION, CLAIM})


def validate_inputs(declared, actual):
    assert set(declared) == set(actual), "input population"
    for path, item in actual.items():
        assert declared[path]["sha256"] == item["sha256"], "input bytes: " + path
        assert declared[path]["mode"] == item["mode"], "input mode: " + path


def validate_scope(actual):
    required = set(WRAPPERS) | set(FIXED)
    required.update(c.PREFIX + name for name in (
        "common.py", "context.py", "perl_probe.pl", "oracle.py", "review.py", "publish.py",
        "green-inputs.json.gz", "green-runs.json.gz", "verified-faults.json.gz",
        "verified-producer-bridge.json.gz", "book-inputs.json.gz", "book-runs.json.gz",
        "artifact_controls.py", "artifact-inputs.json.gz", "control_review.py"))
    for path in (c.ROOT / c.PREFIX).glob("*-inputs.json.gz"):
        value = c.load(path.name)
        if "context" in value:
            required.add(c.PREFIX + path.name)
            required.update(name for name in value["context"]["inputs"] if name.startswith(c.PREFIX))
    missing = sorted(required - set(actual))
    assert not missing, "required input: " + ",".join(missing)


def controls():
    supplied = c.load("artifact-inputs.json.gz")
    actual = {path: c.identity(path) for path in supplied["actual"]}
    assert actual == supplied["actual"]
    result = {}
    for name, declared in supplied["cases"].items():
        try:
            validate_inputs(declared, actual)
        except AssertionError as error:
            result[name] = dict(rejected=True, reason=str(error))
        else:
            result[name] = dict(rejected=False, reason="")
    return result


def record(result, control_result):
    bindings = [dict(path=path, sha256=c.identity(path)["sha256"],
        role="producer" if path.endswith((".py", ".pl", ".sh")) else "input")
        for path in input_paths() + [MANIFEST]]
    claim = dict(name="dated-perl-signed-selector-implementation",
        statement="At the recorded Perl17.2 source epochs based on " + c.BASE +
            ", corrected120 public programs pass both native and independently emitted execution; all33 frozen signed writes execute actual deferred callbacks, guards and detachment controls.",
        scope="Dated finite Perl implementation proof, preserved unrelated coercions/order, frozen-v1 compatibility, exact diagnostic fields/spans, source faults and complete book inputs. Current behavior is also exercised by the enrolled permanent Perl consumer. Other backends, exhaustive spelling coverage and portable admission remain separately owned; canonical CI/commit receipts are separate Git-bound acceptance.",
        rederive=dict(status="checked", command="bash tools/run_python_project_data.sh " + c.PREFIX + "publish.py",
            granularity="Each exact source/route, all frozen signed read/write/arithmetic records, actual command channels, conservative complete source epochs, physical faulty/restored producers and whole rendered-book source population.",
            result=json.dumps(result, sort_keys=True)),
        falsify=dict(status="checked", hypothesis="Host coercion, shallow copies, aggregate pass counts, stale book prose or omitted/altered proof inputs could conceal an incomplete signed implementation.",
            oracle="Frozen independent signed authority and director length-plus-index arithmetic; complete old-v1 consumer; explicit typed/coercion/side-effect/guard/copy controls; actual original runtime inverse, seven further physical variants, rendered-source and input/scope validators.",
            red_control="Original53 genuine public failures per route become120 corrected GREEN; two original invalid infix instrument programs earn no product RED. Corrected full old-source inverse55 per route, seven targeted variants and actual restoration distinguish each repair. Three book source faults and executed wrong selector reject. Partial overlapped fault run, inherited producer pointer and reason-list presentation order remain explicitly qualified. " + json.dumps(control_result, sort_keys=True)),
        durability=dict(status="checked", mode="live", inputs=bindings))
    return dict(version=1, owner=c.OWNER, claims=[claim])


def main():
    if sys.argv[1:] == ["--identity-controls"]:
        print(json.dumps(controls(), sort_keys=True))
        return
    if sys.argv[1:] == ["--scope-check"]:
        validate_scope({path: c.identity(path) for path in input_paths()})
        print("Required-input scope PASS")
        return
    assert sys.argv[1:] in ([], ["--capture"])
    capture = sys.argv[1:] == ["--capture"]
    inputs = {path: c.identity(path) for path in input_paths()}
    validate_scope(inputs)
    if capture:
        assert not (c.ROOT / CLAIM).exists()
        c.write_new("publication-inputs.json.gz", dict(base=c.BASE, inputs=inputs,
            scope="All owned retained producers/evidence, actual wrappers and frozen authorities. Whole mutable source overlays and accepted Git recover dated runtime/test/book inputs; immutable archives remain byte/mode-gated, without recursive copies. Later runtime and live-continuity edits do not replace these dated epochs."))
    validate_inputs(c.load("publication-inputs.json.gz")["inputs"], inputs)
    result = review.check()
    import control_review
    control_result = control_review.check()
    validate_inputs(inputs, {path: c.identity(path) for path in input_paths()})
    raw = (json.dumps(record(result, control_result), separators=(",", ":")) + "\n").encode()
    publication = dict(result=result, controls=control_result, record_base64=c.encode(raw))
    if capture:
        c.write_new("publication.json", publication)
        with (c.ROOT / CLAIM).open("xb") as output:
            output.write(raw)
    assert c.source(CLAIM).read_bytes() == raw
    assert c.load("publication.json") == publication
    print(json.dumps(dict(inputs=len(inputs), result=result, controls=control_result), sort_keys=True))


if __name__ == "__main__":
    main()
