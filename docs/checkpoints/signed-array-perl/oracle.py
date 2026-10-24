"""Typed, case-level oracle over independently authored public targets."""
import json
import common as c


def same(left, right):
    return json.dumps(left, sort_keys=True, ensure_ascii=False) == json.dumps(right, sort_keys=True, ensure_ascii=False)


def check(plan, route, run):
    assert route in ("native", "generated") and run["returncode"] == 0
    value = json.loads(c.decode(run["stdout_base64"]))
    assert value["route"] == route
    rows = value["rows"]
    assert [row["id"] for row in rows] == [case["id"] for case in plan["cases"]]
    failures = []
    for case, row in zip(plan["cases"], rows):
        reasons = []
        if "error" in case:
            observed = row["runtime_detail"] if route == "native" else row["generated_cause"]
            if not observed or observed.get("class") not in (
                    "LinkedSpec::BindingRuntime::NestedWriteError", "LinkedSpec::BindingRuntime::ReceiverMutationError"):
                reasons.append("typed runtime error")
            else:
                fields = observed["fields"]
                reasons += ["error:" + key for key, item in case["error"].items()
                    if key not in fields or not same(fields[key], item)]
            if route == "native":
                if not row["completed"] or row["exception"] is not None:
                    reasons.append("native boundary")
            elif row["completed"] or row["exception"] is None or row["exception"]["class"] != "HASH":
                reasons.append("generated boundary")
        else:
            if not row["completed"] or row["exception"] is not None or row["runtime_detail"] is not None:
                reasons.append("unexpected failure")
            if not same(row["value"], case["expected"]):
                reasons.append("typed value")
            if "expected_scalar_flags" in case:
                reasons += ["scalar:" + key for key, item in case["expected_scalar_flags"].items()
                    if row["scalar_flags"].get(key) != item]
        if reasons:
            failures.append(dict(id=case["id"], reasons=reasons))
    return failures
