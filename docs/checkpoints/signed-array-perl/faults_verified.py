"""Actual physical production inverses/faults with fresh-process RED and restoration."""
import json
import subprocess
import common as c
import context
import oracle

BINDING, READER = c.SOURCES[:2]
PATH = "tests/numeric-codeblocks/signed-array-selectors.json"


def replace_once(raw, old, new):
    assert raw.count(old) == 1, old
    return raw.replace(old, new, 1)


def observe(name, plan, permanent=False):
    epoch = context.snapshot()
    c.write_new(name + "-inputs.json.gz", dict(context=epoch, plan=plan,
        sources={path: c.read(path) for path in c.SOURCES}))
    observations = {route: c.run(["bash", "tools/project_data_run.sh", "perl", "-Iperl",
        c.PREFIX + "perl_probe.pl", route], input=json.dumps(plan, ensure_ascii=False).encode())
        for route in ("native", "generated")}
    if permanent:
        observations["permanent"] = c.run(["bash", "tools/project_data_run.sh", "prove", "-v", "-Iperl",
            "t/signed_array_selector_perl_contract.t"])
    failures = {route: oracle.check(plan, route, observations[route]) for route in ("native", "generated")}
    c.write_new(name + "-runs.json.gz", dict(observations=observations, failures=failures,
        inputs_unchanged=c.unchanged(epoch["inputs"])))
    assert c.unchanged(epoch["inputs"])
    return failures, observations


def main():
    green = c.load("green-runs.json.gz")
    assert green["observations"]["focused"]["returncode"] == 0 and green["inputs_unchanged"]
    original = {path: c.read(path) for path in (BINDING, READER)}
    raw = {path: c.decode(packet["base64"]) for path, packet in original.items()}
    full = json.loads(c.source(PATH).read_bytes())
    c.write_new("verified-fault-controller-inputs.json.gz", dict(producer=c.read(c.PREFIX + "faults.py"),
        oracle=c.read(c.PREFIX + "oracle.py"), sources=original, plan=c.read(PATH),
        scope="Only owned production files change, one physical variant at a time; all commands run in fresh processes. Every fault and restored epoch retains whole runtime overlays and actual channels. Gold and permanent consumer stay unchanged."))
    faults = [
        ("inverse", {path: subprocess.check_output(["git", "show", c.BASE + ":" + path], cwd=c.ROOT)
            for path in original}, None, False),
        ("indexed-reader", {READER: replace_once(raw[READER],
            b"return _read_array_entry($value, $key, $node->{index}) if ref($value) eq 'ARRAY';",
            b"return undef if ref($value) eq 'ARRAY';")}, ["control/callable_last"], False),
        ("nested-reader", {READER: replace_once(raw[READER],
            b"$value = _read_array_entry($value, $key, $segment->{expr});",
            b"$value = undef;")}, ["read/callable/mixed_nested"], False),
        ("result-reader", {READER: replace_once(raw[READER],
            b"$value = _read_array_entry($value, $key);", b"$value = undef;")},
            ["control/result_path_negative"], False),
        ("float-spelling", {READER: replace_once(raw[READER],
            b"if ($integer_literal && LinkedSpec::BindingRuntime::_runtime_kind($key) eq 'integer' && $key < 0)",
            b"if (LinkedSpec::BindingRuntime::_runtime_kind($key) eq 'integer' && $key < 0)")},
            ["control/callable_literal_kinds"], False),
        ("underflow-diagnostic", {BINDING: replace_once(raw[BINDING],
            b"resolved_index => $position,", b"resolved_index => 0,")},
            ["write/ordinary/underflow", "write/callable/underflow"], False),
        ("missing-array", {BINDING: replace_once(raw[BINDING],
            b"if ($selector->{expected} eq 'array' && $selector->{key} < 0)", b"if (0)")},
            ["missing-child/ordinary/absent", "missing-child/callable/present"], False),
        ("aliased-result", {BINDING: replace_once(raw[BINDING],
            b"return ($committed, _clone_value($work))", b"return ($work, $work)")},
            ["write/ordinary/aggregate_detachment", "write/callable/aggregate_detachment"], True),
    ]
    outcomes = []
    try:
        for name, overrides, ids, permanent in faults:
            for path, value in overrides.items():
                c.source(path).write_bytes(value)
            plan = full if ids is None else dict(cases=[case for case in full["cases"] if case["id"] in ids])
            if ids is not None:
                assert {case["id"] for case in plan["cases"]} == set(ids)
            failures, observations = observe("verified-fault-" + name, plan, permanent)
            if name == "aliased-result":
                assert observations["permanent"]["returncode"] != 0
                assert b"all four independent host mutations stay isolated" in c.decode(observations["permanent"]["stderr_base64"])
            else:
                assert all(failures.values()), (name, failures)
            for path, value in raw.items():
                c.source(path).write_bytes(value)
                c.source(path).chmod(original[path]["mode"])
            restored_plan = dict(cases=[case for case in full["cases"] if case["id"] in (
                ids or ["control/callable_last", "control/result_path_negative", "write/callable/last"])])
            restored, restored_observations = observe("verified-restore-" + name, restored_plan, permanent)
            assert not any(restored.values()), (name, restored)
            if permanent:
                assert restored_observations["permanent"]["returncode"] == 0
            assert all(c.read(path) == packet for path, packet in original.items())
            outcomes.append(dict(name=name, public_red={route: len(value) for route, value in failures.items()},
                permanent_red=permanent, restored=True))
            print(name, json.dumps(outcomes[-1]), flush=True)
    finally:
        for path, value in raw.items():
            c.source(path).write_bytes(value)
            c.source(path).chmod(original[path]["mode"])
    c.write_new("verified-faults.json.gz", dict(outcomes=outcomes, exact_restoration=
        all(c.read(path) == packet for path, packet in original.items())))
    assert len(outcomes) == 8


if __name__ == "__main__":
    main()
