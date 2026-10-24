"""One-shot authored public fixture production from frozen targets and old controls."""
import copy
import json
import re
from pathlib import Path
import common as c

TARGET = "tests/numeric-codeblocks/signed-array-selectors.json"
CONTRACT = "capability_conformance/signed_array_selector_contract.json"
contract = json.loads(c.source(CONTRACT).read_bytes())
explore = c.load("explore.json")
spans = c.load("span-runs.json.gz")
assert spans["inputs_unchanged"]
for route, run in spans["observations"].items():
    assert run["returncode"] == 0
    rows = json.loads(c.decode(run["stdout_base64"]))["rows"]
    expected = {"ordinary_gap": (5, 6), "callable_gap": (9, 10), "unicode_gap": (10, 11)}
    for row in rows:
        error = row["runtime_detail"] if route == "native" else row["generated_cause"]
        field = error["fields"]
        assert field["code"] == "nested_write_array_gap"
        span = field["source_span"]
        assert (span["start"], span["end"]) == expected[row["id"]]
        assert span["source_id"] == "action:Top" and span["unit"] == "unicode_scalar"

c.write_new("public-fixture-inputs.json.gz", dict(
    producer=c.read(c.PREFIX + "prepare_public.py"), common=c.read(c.PREFIX + "common.py"),
    contract=c.read(CONTRACT), explore=c.read(c.PREFIX + "explore.json"),
    calibration={name: c.read(c.PREFIX + name) for name in ("span-inputs.json.gz", "span-runs.json.gz")},
    scope="Gold values/errors come from the frozen signed authority, explicit director arithmetic and unchanged old coercion controls. Public span units are calibrated against existing positive failures before fixture construction. No post-fix result produces a target."))


def dsl(value):
    if value is None:
        return "undef"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, list):
        return "[" + ",".join(dsl(item) for item in value) + "]"
    if isinstance(value, dict):
        return "{" + ",".join(json.dumps(key, ensure_ascii=False) + ":" + dsl(value[key])
            for key in sorted(value)) + "}"
    return json.dumps(value, ensure_ascii=False, allow_nan=False)


cases = []


def add(name, body, *, expected=None, error=None, functions="", mode="ordinary", setup="", **extra):
    authored = setup
    if mode == "callable":
        authored += "runner={|| " + body + " }; return(runner())"
    else:
        authored += body
    row = dict(id=name, source=functions + "Top: /x/\n I { " + authored + " }\n", input="x", **extra)
    row["error" if error is not None else "expected"] = error if error is not None else expected
    cases.append(row)


def setup_values(case):
    result = []
    initial = case["initial_binding"]
    if initial["present"]:
        result.append("tree=" + dsl(initial["value"]))
    for operand in [*case["segments"], *([case["rhs"]] if "rhs" in case else [])]:
        source = operand["source"]
        if re.fullmatch(r"[A-Za-z_]\w*", source) and source not in ("null", "undef", "true", "false"):
            result.append(source + "=" + dsl(operand["value"]))
        elif "same_binding_after" in operand:
            name = source.removesuffix("()")
            assert re.fullmatch(r"[A-Za-z_]\w*", name)
            result.append(name + "={|| tree=" + dsl(operand["same_binding_after"])
                + "; return(" + dsl(operand["value"]) + ") }")
    return "; ".join(result) + ("; " if result else "")


for case in contract["read_cases"]:
    initial = case["initial_binding"]
    for mode in ("ordinary", "callable"):
        add("read/" + mode + "/" + case["id"], "return([" + case["source"] + ",tree])",
            setup=setup_values(case), mode=mode,
            expected=[case["expected_result"], initial.get("value")], authority_case=case["id"])

projection_only = []
for case in contract["write_cases"]:
    if case["guard"] is not None or any("evaluation_error" in item for item in [*case["segments"], case["rhs"]]):
        projection_only.append(case["id"])
        continue
    for mode in ("ordinary", "callable"):
        error = copy.deepcopy(case["expected"]["error"])
        if error is not None:
            error["source_span"]["source_id"] = "action:Top"
            if mode == "callable":
                error["source_span"]["start"] += 4
                error["source_span"]["end"] += 4
        add("write/" + mode + "/" + case["id"], case["source"] + "; return(tree)",
            setup=setup_values(case), mode=mode, error=error,
            expected=case["expected"]["binding"].get("value"), authority_case=case["id"])

explore_targets = {
    "ordinary_last": [30, [10, 20, 30]], "callable_last": 30,
    "result_path_positive": 1, "result_path_negative": 2,
    "callable_literal_kinds": [30, None, None], "callable_dynamic_float": [None, -1],
    "scalar_float": -1, "harray_collision": [None, 99, [99, 99]],
    "array_string_selector": [30, None, [None, None]],
}
for row in explore["cases"]:
    value = dict(id="control/" + row["id"], source=row["source"], input="x",
        expected=explore_targets[row["id"]],
        scope="Existing Perl coercions; only supported integer negative selections change.")
    if row["id"] == "scalar_float":
        value["expected_scalar_flags"] = dict(integer_flag=0, float_flag=1, string_flag=0)
    if row["id"].startswith("result_path_"):
        value["scope"] = "Existing callable-result compatibility form; raw marker1 remains unchanged."
    cases.append(value)

for spelling in ("-1.0", '"-1"'):
    add("control/result_path_" + ("float" if spelling == "-1.0" else "string"),
        "pick={|| return([[10],[20,30]]) }; return(pick()[" + spelling + "].count())", expected=0,
        scope="Preserve the result-path reader's existing noninteger negative coercion boundary.")

for mode in ("ordinary", "callable"):
    add("value-kinds/" + mode, "return([tree[-5],tree[-4],tree[-3],tree[-2],tree[-1]])",
        setup='tree=[0,false,undef,"0",true]; ', mode=mode, expected=[0, False, None, "0", True])
    add("read-purity/" + mode + "/absent", "seen=tree[-1]; tree[0]=99; return(tree)", mode=mode, expected=[99])
    add("read-purity/" + mode + "/null", "seen=tree[-1]; tree[0]=99; return(tree)",
        setup="tree=undef; ", mode=mode, error=dict(code="nested_write_kind_conflict", binding="tree",
            segment_index=0, path=[], expected_kind="array", actual_kind="null"))
    add("read-order/" + mode, "observed=tree[resize()]; return([observed,tree])",
        setup="tree=[10,20]; resize={|| tree=[10,20,30]; return(-1) }; ", mode=mode,
        expected=[20, [10, 20, 30]], scope="Preserve Perl's retained read receiver; no portable effect-order admission.")
    add("write-order/" + mode,
        "tree[key()][row_index()][column_index()]=replacement(); return([tree,trail])",
        setup='tree={"rows":[[1],[2,3]]}; trail=0; '
            'key={|| trail=trail*10+1; return("rows") }; '
            'row_index={|| trail=trail*10+2; return(-1) }; '
            'column_index={|| trail=trail*10+3; return(-2) }; '
            'replacement={|| trail=trail*10+4; return(99) }; ',
        mode=mode, expected=[{"rows": [[1], [99, 3]]}, 1234])
    add("post-expression-presence/" + mode, "tree[resize()]=99; return(tree)",
        setup="resize={|| tree=[10,20]; return(-1) }; ", mode=mode, expected=[10, 99])
    for present in (False, True):
        operation = "tree[0][-1] = 99"
        start = operation.index("-1") + (4 if mode == "callable" else 0)
        add("missing-child/" + mode + ("/present" if present else "/absent"), operation + "; return(tree)",
            setup="tree=[]; " if present else "", mode=mode,
            error=dict(code="nested_write_segment_invalid", operation="nested_write_vivification",
                binding="tree", segment_index=1, path=[0], actual_kind="integer", reason="negative_integer",
                source_span=dict(source_id="action:Top", start=start, end=start + 2,
                    unit="unicode_scalar", provenance="authored"),
                message="nested write segment 1 for binding 'tree' must evaluate to a string or nonnegative integer; got integer (negative_integer)"))
    add("copy/" + mode + "/fixed", "updated=replace(items); return([items,updated])",
        functions="fn replace(items) { items[-1]=99; return(items) }\n",
        setup="items=[10,20]; ", mode=mode, expected=[[10, 20], [10, 99]])
    add("copy/" + mode + "/callable", "updated=change(items); return([items,updated])",
        setup="items=[10,20]; change={|items| items[-1]=99; return(items) }; ",
        mode=mode, expected=[[10, 20], [10, 99]])
    add("copy/" + mode + "/rest", "updated=replace_rest(first,second); return([first,second,updated])",
        functions="fn replace_rest(...items) { items[-1][0]=99; return(items) }\n",
        setup="first=[1]; second=[2]; ", mode=mode, expected=[[1], [2], [[1], [99]]])

add("guard/native-and-emitted", "tree=[10]; key={|| return(-1) }; rhs={|| return(99) }; "
    "cb={|| tree[key()] = rhs() }; return(tree.map_leaves!() { return(cb()) })",
    error=dict(code="receiver_mutation_reentrant", operation="map_leaves_mutation", binding="tree",
        method="map_leaves", attempt="nested_write",
        source_span=dict(source_id="action:Top", start=4, end=8, unit="unicode_scalar", provenance="authored"),
        message="cannot write active map_leaves! receiver binding 'tree' from its callback"))

assert len({row["id"] for row in cases}) == len(cases)
plan = dict(version=1, authority=contract["contract_id"],
    scope="Perl native/emitted programs. All33 frozen writes separately run through actual deferred registered callbacks; four guard/evaluation records use that exact API projection instead of inventing DSL fixture exceptions. Unrelated read coercions/receiver order retain their dated controls.",
    projection_only=projection_only, cases=cases)
with (c.ROOT / TARGET).open("xb") as output:
    output.write((json.dumps(plan, ensure_ascii=False, indent=2) + "\n").encode())
c.write_new("public-fixture.json.gz", dict(output=c.read(TARGET), cases=len(cases),
    projection_only=projection_only, scope="Authored targets frozen before runtime changes; no post-fix observations were used."))
print("Public signed fixture authored:", len(cases), "programs;", len(projection_only), "exact-API projection records")
