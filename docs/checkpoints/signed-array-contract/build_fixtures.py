"""One-shot authority author. Targets below are authored, never model outputs.

Metadata is copied from the authored checker constants to freeze the agreed
catalog. Arithmetic/state/effect/diagnostic targets are specified separately
here. This actor neither changes nor executes a LinkedSpec backend.
"""
import copy
import json
from pathlib import Path
import sys

sys.path.insert(0, "tools")
import check_signed_array_selector_contract as checker


ABSENT = object()
UNSET = object()


def state(value):
    return {"present": False} if value is ABSENT else {"present": True, "value": copy.deepcopy(value)}


def segment(source, kind, value, **extras):
    return dict(source=source, kind=kind, value=value, **extras)


def integer(value, source=None, **extras):
    return segment(str(value) if source is None else source, "integer", value, **extras)


def string(value, source=None):
    return segment(json.dumps(value, ensure_ascii=False) if source is None else source, "string", value)


def error(case, code, segment_index, prefix, **fields):
    # Offset arithmetic over authored pieces is independent of the parser.
    start = len(case["binding"]) + 1 + sum(len(s["source"]) + 2 for s in case["segments"][:segment_index])
    span = dict(source_id="contract:" + case["id"], start=start,
        end=start + len(case["segments"][segment_index]["source"]), unit="unicode_scalar", provenance="authored")
    result = dict(code=code, operation="nested_write_vivification", binding=case["binding"],
        segment_index=segment_index, path=prefix, **fields, source_span=span)
    prefix_message = f"nested write segment {segment_index} for binding '{case['binding']}'"
    if code == "nested_write_array_underflow":
        result["message"] = prefix_message + f" cannot select array index {fields['index']} at length {fields['length']} (resolved index {fields['resolved_index']})"
    elif code == "nested_write_array_gap":
        result["message"] = prefix_message + f" cannot create array index {fields['index']} at length {fields['length']}"
    elif code == "nested_write_kind_conflict":
        result["message"] = prefix_message + f" requires {fields['expected_kind']}; found {fields['actual_kind']}"
    elif code == "nested_write_segment_invalid":
        result["message"] = prefix_message + f" must evaluate to a string or nonnegative integer; got {fields['actual_kind']} ({fields['reason']})"
    else:
        raise AssertionError(code)
    return result


writes = []


def write(name, initial, segments, result=UNSET, *, failure=None, rhs=None,
          after=UNSET, effects=None, guard=None):
    rhs = {"source": "99", "value": 99} if rhs is None else rhs
    case = dict(id=name, binding="tree", initial_binding=state(initial), segments=segments,
        rhs=rhs, guard=guard, source="tree" + "".join("[" + s["source"] + "]" for s in segments) + " = " + rhs["source"])
    if failure is None:
        assert result is not UNSET
        expected = dict(binding=state(result), result=copy.deepcopy(result), error=None)
    else:
        diagnostic = failure(case) if callable(failure) else copy.deepcopy(failure)
        expected = dict(binding=state(initial if after is UNSET else after), result=None, error=diagnostic)
    expected["effects"] = [f"segment:{i}" for i in range(len(segments))] + ["rhs"] if effects is None else effects
    case["expected"] = expected
    writes.append(case)
    return case


def underflow(index, prefix, raw, length, resolved):
    return lambda case: error(case, "nested_write_array_underflow", index, prefix, index=raw, length=length, resolved_index=resolved)


def invalid(index, prefix, kind="integer", reason="negative_integer"):
    return lambda case: error(case, "nested_write_segment_invalid", index, prefix, actual_kind=kind, reason=reason)


def conflict(index, prefix, actual, expected="array"):
    return lambda case: error(case, "nested_write_kind_conflict", index, prefix, expected_kind=expected, actual_kind=actual)


def gap(index, prefix, position, length):
    return lambda case: error(case, "nested_write_array_gap", index, prefix, index=position, length=length)


write("last", [10, 20, 30], [integer(-1)], [10, 20, 99])
write("first", [10, 20, 30], [integer(-3)], [99, 20, 30])
write("dynamic_negative", [10, 20, 30], [integer(-2, "chosen_index")], [10, 99, 30])
write("mixed_nested", {"rows": [[1], [2, 3]]}, [string("rows"), integer(-1), integer(-2)],
    {"rows": [[1], [99, 3]]})
write("negative_then_create", [{}], [integer(-1), string("new"), integer(0)], [{"new": [99]}])
write("positive_append", [10], [integer(1)], [10, 99])
write("positive_replace", [10], [integer(0)], [99])
write("absent_positive", ABSENT, [integer(0), string("x")], [{"x": 99}])
write("quoted_negative_key", {}, [string("-1")], {"-1": 99})
write("dynamic_negative_string_key", {}, [string("-1", "chosen_key")], {"-1": 99})
write("negative_zero", [10], [integer(0, "-0")], [99])
write("selector_resize", [10, 20], [integer(-1, "resize()", same_binding_after=[10, 20, 30])], [10, 20, 99])
write("rhs_resize", [10, 20], [integer(-1)], [10, 20, 99],
    rhs={"source": "resize()", "value": 99, "same_binding_after": [10, 20, 30]})
write("underflow", [10, 20, 30], [integer(-4)], failure=underflow(0, [], -4, 3, -1))
write("empty", [], [integer(-1)], failure=underflow(0, [], -1, 0, -1))
write("absent_negative", ABSENT, [integer(-1)], failure=invalid(0, []))
write("missing_nested_negative", {}, [string("new"), integer(-1)], failure=invalid(1, ["new"]))
write("null", None, [integer(-1)], failure=conflict(0, [], "null"))
write("wrong_kind", {}, [integer(-1)], failure=conflict(0, [], "harray"))
write("nested_null", [None], [integer(-1), integer(-1)], failure=conflict(1, [-1], "null"))
write("positive_gap", [10], [integer(2)], failure=gap(0, [], 2, 1))
write("gap_after_negative", [[10]], [integer(-1), integer(2)], failure=gap(1, [-1], 2, 1))
write("underflow_after_negative", [[10]], [integer(-1), integer(-2)], failure=underflow(1, [-1], -2, 1, -1))
write("invalid_after_underflow", [], [integer(-1), segment("true", "boolean", True)],
    failure=invalid(1, [-1], "boolean", "kind_not_path_selector"))
write("invalid_before_conflict", None, [segment("null", "null", None), integer(-1)],
    failure=invalid(0, [], "null", "kind_not_path_selector"))
write("fractional", [10], [segment("-1.5", "number", -1.5)],
    failure=invalid(0, [], "number", "fractional_number"))
evaluation_error = {"code": "fixture_evaluation_failed", "message": "stop here"}
write("segment_failure", [10], [{"source": "explode()", "evaluation_error": evaluation_error}, integer(-1)],
    failure=evaluation_error, effects=["segment:0"])
write("rhs_failure", [10], [integer(-1)], rhs={"source": "explode()", "evaluation_error": evaluation_error},
    failure=evaluation_error)
write("failure_keeps_rhs_effect", [10], [integer(-3)],
    rhs={"source": "resize()", "value": 99, "same_binding_after": [10, 20]},
    after=[10, 20], failure=underflow(0, [], -3, 2, -1))
guard = {"active_identity": "outer:tree", "target_identity": "outer:tree"}
write("guard_precedes_evaluation", [10],
    [{"source": "explode()", "evaluation_error": evaluation_error}],
    failure={
        "code": "receiver_mutation_reentrant", "operation": "map_leaves_mutation",
        "binding": "tree", "method": "map_leaves", "attempt": "nested_write",
        "source_span": {"source_id": "contract:guard_precedes_evaluation", "start": 0, "end": 4,
            "unit": "unicode_scalar", "provenance": "authored"},
        "message": "cannot write active map_leaves! receiver binding 'tree' from its callback",
    }, effects=[], guard=guard)
write("distinct_identity", [10], [integer(-1)], [99],
    guard={"active_identity": "outer:tree", "target_identity": "parameter:tree"})
write("aggregate_detachment", [{"keep": [1]}], [integer(-1), string("new")],
    [{"keep": [1], "new": [2]}], rhs={"source": "payload", "value": [2]})
write("unicode_span", {"é": [1]}, [string("é"), integer(-2)], failure=underflow(1, ["é"], -2, 1, -1))

reads = []


def read(name, initial, segments, result):
    reads.append(dict(id=name, binding="tree", source="tree" + "".join("[" + s["source"] + "]" for s in segments),
        initial_binding=state(initial), segments=segments, expected_binding=state(initial), expected_result=result))


read("last", [10, 20, 30], [integer(-1)], 30)
read("first", [10, 20, 30], [integer(-3)], 10)
read("underflow", [10, 20, 30], [integer(-4)], None)
read("empty", [], [integer(-1)], None)
read("absent", ABSENT, [integer(-1)], None)
read("null", None, [integer(-1)], None)
read("wrong_kind", {}, [integer(-1)], None)
read("positive", [10, 20, 30], [integer(1)], 20)
read("positive_outside", [10, 20, 30], [integer(3)], None)
read("dynamic_negative", [10, 20, 30], [integer(-2, "chosen_index")], 20)
read("mixed_nested", {"rows": [[1], [2, 3]]}, [string("rows"), integer(-1), integer(-2)], 2)
read("quoted_negative_key", {"-1": "key"}, [string("-1")], "key")
read("missing_nested", {}, [string("rows"), integer(-1)], None)
read("negative_zero", [10], [integer(0, "-0")], 10)

# Readability and writability are specified separately from normalization.
arithmetic = [
    ("last", 3, -1, 2, True, True), ("first", 3, -3, 0, True, True),
    ("underflow", 3, -4, -1, False, False), ("positive_zero", 3, 0, 0, True, True),
    ("positive_last", 3, 2, 2, True, True), ("append", 3, 3, 3, False, True),
    ("positive_gap", 3, 4, 4, False, False), ("empty_negative", 0, -1, -1, False, False),
    ("empty_append", 0, 0, 0, False, True), ("singleton_last", 1, -1, 0, True, True),
    ("singleton_underflow", 1, -2, -1, False, False), ("far_underflow", 3, -1000, -997, False, False),
]
contract = dict(format=1, contract_id="linkedspec-signed-array-selector-v1", status=checker.STATUS,
    historical_authorities=checker.AUTHORITIES, write_checker_sha256=checker.WRITE_CHECKER_SHA,
    policy=checker.POLICY, diagnostics=checker.DIAGNOSTICS,
    arithmetic_cases=[dict(id=name, length=length, index=index,
        expected=dict(resolved_index=resolved, readable=readable, writable=writable))
        for name, length, index, resolved, readable, writable in arithmetic],
    read_cases=reads, write_cases=writes,
    detachment_probe={
        "case_id": "aggregate_detachment",
        "mutations": [
            {"target": "initial", "path": [0, "keep", 0], "value": 11},
            {"target": "rhs", "path": [0], "value": 22},
            {"target": "binding", "path": [0, "new", 0], "value": 33},
            {"target": "result", "path": [0, "keep", 0], "value": 44},
        ],
        "expected": {
            "initial": [{"keep": [11]}], "rhs": [22],
            "binding": [{"keep": [1], "new": [33]}],
            "result": [{"keep": [44], "new": [2]}],
        },
    })
with Path(checker.PATH).open("x", encoding="utf-8") as output:
    output.write(json.dumps(contract, ensure_ascii=False, indent=2) + "\n")
print("Authored signed fixtures; no model results were used as targets")
