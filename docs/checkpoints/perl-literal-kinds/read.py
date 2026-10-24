"""Read-only review of dated literal-kind observations and their actual source epochs."""
import functools
import json
import re
import subprocess
import common as c
import capture
import book
import booklib as b
import review_precision

RUNTIMES = ("perl/LinkedSpec/CodeblockRuntime.pm", "perl/LinkedSpec/BindingRuntime.pm")
WORKER = "t/callable_codeblock_literal_contract.t"


def verify_inventory(expected, supplied, required):
    assert set(supplied) == set(expected), "inventory scope"
    assert set(required) <= set(expected), "required producer/input scope"
    for path, identity in expected.items():
        item = supplied[path]
        assert c.sha(c.decode(item["base64"])) == identity["sha256"], "inventory bytes: " + path
        assert item["mode"] == identity["mode"], "inventory mode: " + path
    return True


def packet(item):
    raw = c.decode(item["base64"])
    assert c.sha(raw) == item["sha256"], "packet bytes"
    if "mode" in item:
        assert type(item["mode"]) is int and 0 <= item["mode"] <= 0o7777, "packet mode"
    return raw


@functools.lru_cache(None)
def load(name):
    return c.load(name)


class Sources:
    """Hash accepted regular blobs once; never traverse a Gitlink."""
    def __init__(self, epochs):
        self.tree = {}
        for row in subprocess.check_output(["git", "ls-tree", "-rz", c.BASE], cwd=c.ROOT).split(b"\0"):
            if row:
                meta, name = row.split(b"\t", 1)
                mode, kind, oid = meta.split()
                if kind == b"blob" and mode in (b"100644", b"100755"):
                    self.tree[name.decode()] = (int(mode, 8) & 0o777, oid.decode())
        wanted = {path for epoch in epochs for path in epoch["inputs"]
            if path in self.tree and path not in epoch["overrides"] and not path.endswith((".gz", ".part"))}
        self.hashes = {}
        self.small = {}
        process = subprocess.Popen(["git", "cat-file", "--batch"], cwd=c.ROOT,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            for path in sorted(wanted):
                oid = self.tree[path][1]
                process.stdin.write((oid + "\n").encode())
                process.stdin.flush()
                actual, kind, length = process.stdout.readline().split()
                assert actual.decode() == oid and kind == b"blob"
                raw = process.stdout.read(int(length))
                assert len(raw) == int(length) and process.stdout.read(1) == b"\n"
                self.hashes[path] = c.sha(raw)
                if len(raw) < 200000:
                    self.small[path] = raw
        finally:
            process.stdin.close()
            assert not process.stderr.read()
            assert process.wait() == 0
        self.identities = {}

    def recover(self, epoch, path):
        expected = epoch["inputs"][path]
        if path in epoch["overrides"]:
            item = epoch["overrides"][path]
            raw = packet(item)
            assert {key: item[key] for key in ("sha256", "mode")} == expected, path
            return raw
        if path.endswith((".gz", ".part")):
            if path not in self.identities:
                self.identities[path] = c.identity(path)
            assert self.identities[path] == expected, path
            return None
        assert path in self.tree, ("unretained new source", path)
        assert expected["sha256"] == self.hashes[path], path
        # Git retains executable status, not the checkout's complete permissions.
        # Preserve captured filesystem modes; never replace them with Git's mode.
        assert type(expected["mode"]) is int and 0 <= expected["mode"] <= 0o7777, path
        assert bool(expected["mode"] & 0o100) == bool(self.tree[path][0] & 0o100), path
        return self.small.get(path)

    def verify(self, epoch):
        assert epoch["base"] == epoch["head"] == c.BASE
        assert set(self.tree) <= set(epoch["inputs"]), "incomplete main-repository census"
        assert set(epoch["overrides"]) <= set(epoch["inputs"])
        for path in epoch["inputs"]:
            assert not path.startswith("/") and ".." not in path.split("/")
            self.recover(epoch, path)


def rows(name, population):
    value = load(name + "-runs.json.gz")
    assert value["inputs_unchanged"]
    run = value["run"]
    result = capture.summarize(run, population)
    return run, capture.observations(run), result


def checked_green(name):
    run, observations, result = rows(name, 37)
    assert run["returncode"] == 0 and not result["instrument_errors"] and not result["mismatches"]
    assert re.search(r"^1\.\.28$", c.decode(run["stdout_base64"]).decode(), re.MULTILINE)
    return observations


def literal_proof(sources):
    old_run, old_rows, old = rows("before", 35)
    first_run, first_rows, first = rows("after", 35)
    baseline_run, baseline_rows, baseline = rows("verified-before", 37)
    green_rows = checked_green("verified-after")
    assert old_run["returncode"] and len(old["mismatches"]) == 46 and not old["instrument_errors"]
    assert first_run["returncode"] and len(first["mismatches"]) == 7 and not first["instrument_errors"]
    cache_only = {"visible_fractional_difference/native", "numeric_boolean_rejection/native", "numeric_boolean_rejection/generated"}
    indexed = {r["id"] + "/" + r["route"]: r for r in first_rows}
    for key in cache_only:
        assert capture.value_same(indexed[key]["value"], indexed[key]["expected"])
    assert cache_only <= set(first["mismatches"])
    assert baseline_run["returncode"] and len(baseline["mismatches"]) == 47 and not baseline["instrument_errors"]
    assert {(r["id"], r["route"]): r["source"] for r in old_rows} == {
        (r["id"], r["route"]): r["source"] for r in baseline_rows if (r["id"], r["route"]) in
        {(x["id"], x["route"]) for x in old_rows}}
    for before, after in zip(baseline_rows, green_rows):
        for field in ("id", "route", "source", "expected", "expected_flags"):
            assert capture.value_same(before[field], after[field]), field
        assert after["raw_storage"] is not None
        assert (after.get("dump") or after.get("emitted")) and after["instrument"] == "public-validity-v2"
    controller = load("verified-baseline-controller-inputs.json.gz")
    restored = load("verified-baseline-controller-runs.json.gz")
    assert restored["inputs_restored"] and restored["run"]["returncode"] == 0
    for path in RUNTIMES:
        accepted = subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
        assert packet(controller["accepted_sources"][path]) == accepted
        assert sources.recover(load("verified-before-inputs.json.gz")["context"], path) == accepted
        candidate = packet(controller["candidate_sources"][path])
        assert restored["restored_sources"][path] == {key:controller["candidate_sources"][path][key] for key in ("sha256","mode")}
        assert candidate == sources.recover(load("verified-after-inputs.json.gz")["context"], path)
    return dict(public_programs=37, routes=2, corrected_original_red=47, corrected_green=74,
        callable_roots=28, first_original_red=46, first_after_unresolved=7, first_after_cache_only_qualifications=3)


def source_faults(sources):
    inputs = load("fault-controller-inputs.json.gz")
    runs = load("fault-controller-runs.json.gz")
    assert runs["sources_restored"] and set(inputs["variants"]) == set(runs["results"])
    summaries = {}
    for name, variants in inputs["variants"].items():
        fault_epoch = load("fault-" + name + "-inputs.json.gz")["context"]
        restore_epoch = load("restore-" + name + "-inputs.json.gz")["context"]
        for path in RUNTIMES:
            healthy = packet(inputs["healthy_sources"][path])
            faulty = c.decode(variants[path]["base64"]) if path in variants else healthy
            if path in variants:
                assert c.sha(faulty) == variants[path]["sha256"]
            assert sources.recover(fault_epoch, path) == faulty
            assert sources.recover(restore_epoch, path) == healthy
            assert restore_epoch["inputs"][path]["mode"] == inputs["healthy_sources"][path]["mode"]
        run, observed, summary = rows("fault-" + name, 37)
        assert re.search(r"^1\.\.28$", c.decode(run["stdout_base64"]).decode(), re.MULTILINE)
        checked_green("restore-" + name)
        recorded = runs["results"][name]["fault"]
        assert recorded == dict(exit_code=run["returncode"], **summary)
        if name != "fresh-token-necessity":
            assert run["returncode"] != 0
        summaries[name] = dict(exit_code=run["returncode"], public_mismatches=len(summary["mismatches"]),
            instrument_errors=len(summary["instrument_errors"]))
    return dict(required_red=8, complete_restored_green=9, variants=summaries,
        optional_fresh_token_credit=bool(summaries["fresh-token-necessity"]["exit_code"]))


def diagnosis():
    inputs = load("validity-inputs.json.gz")
    runs = load("validity-runs.json.gz")
    assert inputs["planned_intersections"] == 0 and runs["inputs_unchanged"]
    assert set(runs["runs"]) == {"current", "accepted_runtime_shadow"}
    for name, run in runs["runs"].items():
        assert run["returncode"] == 0 and not c.decode(run["stderr_base64"])
        value = json.loads(c.decode(run["stdout_base64"]))
        assert value["perl_version"] == "v5.34.1"
        public = value["public"]
        assert [row["route"] for row in public] == ["native","generated","native","generated"]
        assert [row["value"] for row in public] == [[-0.5,30],[-0.5,None],[-0.5,None],[-0.5,None]]
        assert public[0]["index_flags"] == dict(private=[1,1,0], public=[0,1,0])
        assert [row["public"] for row in value["copies"]["before"]] == [[0,1,0]] * 3
        assert [row["public"] for row in value["copies"]["cloned"]] == [[1,0,0],[1,0,0],[0,1,0]]
        assert value["copies"]["after"][2] == dict(private=[1,1,0], public=[0,1,0])
        if name == "accepted_runtime_shadow":
            for path in RUNTIMES:
                module = path.removeprefix("perl/")
                assert "literal-validity-accepted-" in value["inc"][module]
                assert value["inc"][module].endswith("/" + module)
    return dict(installed_perl="5.34.1", accepted_runtime_reproduces_fractional_selector=True,
        private_lossy_cache_distinguished=True, storable_source_and_copy_kind_change=True)


def fixture_and_compatibility():
    inputs = load("numeric-control-inputs.json.gz")
    after = load("numeric-control-after-inputs.json.gz")
    runs = load("numeric-control-runs.json.gz")
    path = "tests/numeric-codeblocks/cases.json"
    old_raw = packet(inputs["before"])
    new_raw = packet(after["after"])
    original, updated = json.loads(old_raw), json.loads(new_raw)
    assert len(original["cases"]) == len(updated["cases"]) == 431
    old_row = dict(id="control/boolean-literal-owned-startup35", body="cb = {|| return(true) }; return(cb())", expected=1)
    new_row = dict(old_row, expected=True)
    def compact(value):
        return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
    assert old_raw.count(compact(old_row)) == 1 and new_raw == old_raw.replace(compact(old_row), compact(new_row), 1)
    historical = "docs/checkpoints/type-numeric-codeblocks/build_cases.py"
    assert packet(inputs["historical_producer"]) == c.source(historical).read_bytes()
    assert old_raw == subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
    assert runs["inputs_unchanged"] and runs["run"]["returncode"] == 0
    output = c.decode(runs["run"]["stdout_base64"]).decode()
    assert "Files=1, Tests=10," in output and "    1..1008\n" in output and output.endswith("Result: PASS\n")
    focused = load("focused-runs.json.gz")
    assert focused["inputs_unchanged"] and focused["run"]["returncode"] == 1
    text = c.decode(focused["run"]["stdout_base64"]).decode()
    assert "Files=11, Tests=784," in text
    report = text.split("Test Summary Report\n", 1)[1]
    assert re.findall(r"^t/\S+", report, re.MULTILINE) == ["t/scalar_numeric_contract.t"]
    return dict(direct_files=11, top_level_roots=784, unaffected_passing_files=10,
        corrected_numeric_roots=10, corrected_numeric_program_cases=1008, fixture_rows=431, changed_expected_fields=1)


def book_proof():
    inputs = load("book-inputs.json.gz")
    runs = load("book-runs.json.gz")
    original = load("book-original-output.json.gz")
    assert runs["inputs_unchanged"] and runs["pressure"]["returncode"] == 0
    assert len(inputs["inputs"]) == 95
    for item in inputs["inputs"].values():
        packet(item)
    book.validate(original, inputs["inputs"])
    for route, run in runs["executions"].items():
        assert route in ("native", "generated") and run["returncode"] == 0
        data = json.loads(c.decode(run["stdout_base64"]))["rows"]
        assert len(data) == 6
        for row, case in zip(data, inputs["plan"]["cases"]):
            assert row["id"] == case["id"] and capture.value_same(row["value"], case["expected"])
            assert row["completed"] and not row["warnings"] and not row["stdout"]
            assert row["exception"] is None and row["last_error"] is None
    assert set(runs["faults"]) == {"heading", "boolean-teaching", "example"}
    faults = load("book-fault-inputs.json.gz")
    for name, value in runs["faults"].items():
        assert value["run"]["returncode"] == 0 and value["rejected"]
        assert value["page"]["sha256"] != original["files"][b.HTML]["sha256"]
        packet(value["page"])
        fake = dict(files={b.HTML: value["page"]}, returncode=0)
        try:
            book.validate(fake, inputs["inputs"])
        except AssertionError as error:
            assert str(error) == value["reason"]
        else:
            raise AssertionError("book denial ineffective")
        assert len(faults["overrides"][name]) == 1
    for run in runs["wrong_runs"].values():
        assert run["returncode"] == 0
        row, = json.loads(c.decode(run["stdout_base64"]))["rows"]
        assert row["completed"] and not row["warnings"] and not row["exception"]
        assert not capture.value_same(row["value"], runs["wrong_plan"]["cases"][0]["expected"])
    containment = load("contain-inputs.json.gz")
    retained = load("contain-original-output.json.gz")
    result = load("contain-runs.json.gz")
    raw = packet(containment["inputs"][b.FLOW])
    changed = packet(containment["changed_page"])
    removed = set(containment["removed_zero_based_lines"])
    lines = raw.splitlines(keepends=True)
    assert len(removed) == 18 and all(lines[i] == b"\n" and lines[i+1].startswith(b"#") for i in removed)
    assert changed == b"".join(line for i,line in enumerate(lines) if i not in removed)
    manifest = {}
    for path,item in retained["files"].items():
        assert len(packet(item)) == item["bytes"]
        manifest[path] = {key:item[key] for key in ("sha256","bytes","mode")}
    assert len(manifest) == result["output_files"] == 90
    assert manifest == result["after_manifest"] and manifest != result["fault_manifest"]
    assert result["complete_bytes_modes_identical"] and result["inputs_unchanged"]
    assert result["planned_public_after"] == 49992
    qualification = load("book-import-qualification.json.gz")
    assert qualification["original_exit"] == 1 and qualification["source_unchanged"]
    assert "AttributeError" in packet(qualification["original_log"]).decode()
    assert qualification["actual_diagnostic"]["returncode"] == 0
    return dict(whole_book_inputs=95, output_files=90, native_emitted_examples=6,
        rendered_denials=3, executed_selector_denial=True, blank_only_removed=18,
        all_containment_bytes_modes_equal=True, import_setup_failure_qualified=True)


def inventory_controls():
    inputs = load("input-controls-inputs.json.gz")
    runs = load("input-controls-runs.json.gz")
    assert runs["inputs_unchanged"]
    plan = inputs["plan"]
    assert len(plan["expected"]) == 3 and len(plan["cases"]) == 6
    original = packet(inputs["reader"])
    assert c.decode(inputs["physical_sources"]["healthy"]) == original
    assert c.decode(inputs["physical_sources"]["restored"]) == original
    for name, run in runs["runs"].items():
        source = c.decode(inputs["physical_sources"][name])
        namespace = dict(__file__=str(c.ROOT / c.PREFIX / "read.py"), __name__="literal_retained_inventory_validator")
        exec(compile(source, namespace["__file__"], "exec"), namespace)
        assert run["returncode"] == 0 and not c.decode(run["stderr_base64"])
        observed = json.loads(c.decode(run["stdout_base64"]))
        assert observed["validator_sha256"] == c.sha(source)
        actual = []
        for case in plan["cases"]:
            try:
                assert namespace["verify_inventory"](plan["expected"],case["supplied"],plan["required"]) is True
            except AssertionError as error:
                actual.append(dict(id=case["id"],accepted=False,reason=str(error)))
            else:
                actual.append(dict(id=case["id"],accepted=True))
        assert actual == observed["rows"]
        if name in ("healthy","restored"):
            assert [row["accepted"] for row in actual] == [True,False,False,False,False,False]
        elif name == "inverse":
            assert not actual[0]["accepted"]
        else:
            assert all(row["accepted"] for row in actual)
    return dict(input_denials=3, producer_artifact_scope_denials=2, actual_inverse_bypass_restoration=True)


def check():
    packets = {path.name: load(path.name) for path in (c.ROOT / c.PREFIX).glob("*.json.gz")}
    epochs = [value["context"] for value in packets.values() if "context" in value]
    sources = Sources(epochs)
    for epoch in epochs:
        sources.verify(epoch)
    for name, value in packets.items():
        if "context" not in value:
            continue
        epoch = value["context"]
        for key in ("producer", "worker", "observer", "renderer", "registry"):
            if key in value:
                item = value[key]
                raw = packet(item)
                matching = [path for path,identity in epoch["inputs"].items()
                    if identity == {field:item[field] for field in ("sha256","mode")}]
                assert matching and any(sources.recover(epoch,path) == raw for path in matching), (name,key)
    assert load("activation-inputs.json.gz")["checked_live_claims"] == 10
    assert len(load("activation-inputs.json.gz")["live_records"]) == 8
    assert load("activation-runs.json.gz")["previous_intake"]["returncode"] == 0
    qualification = load("reader-mode-qualification.json.gz")
    assert qualification["original_exit"] == 1
    assert qualification["actual_original_predicate_rejection"] == "noncore/AmbiTiming.pm"
    assert qualification["captured_filesystem"]["mode"] == 0o640
    assert qualification["accepted_git"]["tree_row"].startswith("100644 blob ")
    assert qualification["captured_filesystem"]["sha256"] == qualification["accepted_git"]["sha256"]
    assert packet(qualification["original_reader"]) == packet(load("input-controls-inputs.json.gz")["reader"])
    assert b"AssertionError: noncore/AmbiTiming.pm" in packet(qualification["original_log"])
    return dict(source=dict(base=c.BASE, epochs=len(epochs), accepted_plain_blobs=len(sources.hashes)),
        implementation=literal_proof(sources), precision=review_precision.check(), diagnosis=diagnosis(),
        faults=source_faults(sources), compatibility=fixture_and_compatibility(), book=book_proof(), inventory=inventory_controls(),
        limits="Dated finite Perl5.34.1 native/emitted snapshot; no exhaustive programs, other-runtime parity, historical environment reconstruction or portable admission. Three first-after cache-oracle mismatches, the pre-epoch import setup failure and the first readonly Git/full-filesystem-mode comparison failure earn no product RED credit. Git supplies bytes/executable status; captured full filesystem permissions stay separate and no chmod occurs. Original observations and all source epochs remain recoverable. Canonical CI and normal commit hooks remain separate acceptance.")


if __name__ == "__main__":
    print(json.dumps(check(), sort_keys=True))
