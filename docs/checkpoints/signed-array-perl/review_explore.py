"""Read-only review of the unchanged-runtime mechanism/coercion baseline."""
import json
import subprocess
import common as c

EXPECTED = {
    "ordinary_last": [30, [10, 20, 30]],
    "callable_last": None,
    "result_path_positive": 1,
    "result_path_negative": 0,
    "callable_literal_kinds": [None, None, None],
    "callable_dynamic_float": [None, -1],
    "scalar_float": -1,
    "harray_collision": [None, 99, [99, 99]],
    "array_string_selector": [30, None, [None, None]],
}


def check():
    inputs, runs = c.load("explore-inputs.json.gz"), c.load("explore-runs.json.gz")
    assert inputs["context"]["base"] == c.BASE and runs["inputs_unchanged"]
    for path, packet in inputs["sources"].items():
        raw = c.decode(packet["base64"])
        assert c.sha(raw) == packet["sha256"]
        assert all(inputs["context"]["inputs"][path][key] == packet[key] for key in ("sha256", "mode"))
        assert inputs["context"]["overrides"][path] == packet
    for path in c.SOURCES:
        raw = subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
        assert c.sha(raw) == inputs["context"]["inputs"][path]["sha256"]
        assert path not in inputs["context"]["overrides"]
    plan_raw = c.decode(inputs["plan"]["base64"])
    assert c.sha(plan_raw) == inputs["plan"]["sha256"]
    plan = json.loads(plan_raw)
    assert {row["id"] for row in plan["cases"]} == set(EXPECTED)
    assert len(plan["cases"]) == len(EXPECTED)
    assert set(runs["observations"]) == {"descriptor", "native", "generated"}
    for route, run in runs["observations"].items():
        assert run["returncode"] == 0 and not c.decode(run["stderr_base64"])
        observed = json.loads(c.decode(run["stdout_base64"]))
        assert observed["route"] == route
        rows = {row["id"]: row for row in observed["rows"]}
        assert len(rows) == len(observed["rows"]) and set(rows) == set(EXPECTED)
        for name, row in rows.items():
            assert row["completed"] and row["exception"] is None and row["runtime_detail"] is None
            if route == "descriptor":
                value = row["value"]
                assert value["canonical_action_ir_fallback_count"] == 0
                assert value["raw_perl_dependency_count"] == (1 if name.startswith("result_path_") else 0)
            else:
                assert row["value"] == EXPECTED[name], (route, name)
        if route != "descriptor":
            source_field = "dump" if route == "native" else "source"
            assert "LinkedSpec::CodeblockRuntime::read_path" in rows["result_path_negative"][source_field]
            flags = rows["scalar_float"]["scalar_flags"]
            assert flags["float_flag"] == 1 and flags["integer_flag"] == flags["string_flag"] == 0
    return dict(cases=len(EXPECTED), routes=3, runtime_sources=len(c.SOURCES),
        result_path="existing compatibility marker1; negative result0 versus positive1",
        scope="Dated preimplementation observations and preserved coercion boundaries; no signed runtime admission.")


if __name__ == "__main__":
    print(json.dumps(check(), sort_keys=True))
