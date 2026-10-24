#!/usr/bin/env python3
"""Check the pending signed-selector authority, without admitting a backend.

The frozen write-v1 parser and diagnostics are reused only after their exact
source identities have been checked. The signed structural walk is separate.
Fixture observations describe completed expression evaluation, not a second DSL
interpreter. Runtime/native/generated execution belongs to the backend leaves.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
from pathlib import Path

import check_write_vivification_contract as v1


ROOT = Path(__file__).resolve().parents[1]
PATH = "capability_conformance/signed_array_selector_contract.json"
STATUS = "target-neutral-contract; backend implementation and portable admission pending"
AUTHORITIES = {
    "write": {
        "path": "capability_conformance/write_vivification_contract.json",
        "contract_id": "linkedspec-write-vivification-v1",
        "sha256": "c6332b7154e557a414121a0f6d49f1fa09ccefd1913f7dd56c7ee95de32adfc2",
        "canonical_json_sha256": "efabe777bf7fa5d7c3fa6e6fbe181bba89931b8c9b93a3631013c1f6009a2663",
    },
    "map": {
        "path": "capability_conformance/map_leaves_mutation_contract.json",
        "contract_id": "linkedspec-map-leaves-mutation-v1",
        "sha256": "ae88d4167f31c0e8034f02ae68c73cf3a6c721503c86f54a02e9b1a50f37f4b0",
        "canonical_json_sha256": "a15c6dd363b4cb8cbd5d3d6781b4abc0bf0412b7ee3eb7576a3c674bf19d2db9",
    },
    "composition": {
        "path": "capability_conformance/write_map_leaves_composition_contract.json",
        "contract_id": "linkedspec-write-map-leaves-composition-v1",
        "sha256": "4be81636f11c3968d036c1653dcd37ca565971a35deba1d17ea8154892ff8ab5",
        "canonical_json_sha256": "a7d20c825cb3d8362d6f278586b6bb65c215e4a84ba64f5bb15bd10b1b82ba2f",
    },
}
WRITE_CHECKER_SHA = "5850e6892e375828fab95f2e4e4a53b8aa433a0e46d7e0a50bb6b233de5a6f88"
POLICY = {
    "arithmetic": "For an existing array of length L and a supported integer i<0, resolve j=L+i; selection requires 0<=j<L.",
    "positive": "Nonnegative replacement and exact-length append retain write-v1 semantics; negative indexes never append or invent fillers.",
    "missing": "A negative selector cannot create its required array. An absent root or missing child at that selector retains nested_write_segment_invalid with reason negative_integer.",
    "kinds": "Integer selectors require arrays; write strings, including dynamic and quoted negative numeric strings, remain harray keys. Present null and other wrong kinds are never coerced.",
    "snapshot": "Evaluate segments left to right once, then RHS once. Resolve each negative position during the isolated structural walk against its encountered post-expression array.",
    "atomicity": "Commit the isolated root once on success. Failure discards partial structural creation but preserves completed expression effects.",
    "detachment": "Write-v1 detachment of initial input, aggregate RHS, committed binding and returned root remains required.",
    "path": "Diagnostic path is the detached prefix of authored evaluated selector values, retaining negative values rather than normalized offsets.",
    "reads": "Integer array reads apply the same existing-array arithmetic, return null outside bounds and never create state. Explicit quoted key steps remain keys.",
    "precedence": ["resolved_receiver_identity_guard", "expression_evaluation_failure", "first_invalid_typed_segment", "first_structural_failure"],
    "structural_order": "Walk left to right: kind conflict, positive gap, negative underflow or negative missing-target failure occurs at the first encountered failing segment.",
    "negative_validation": "Negative integers are conditionally valid array selectors, so their existence and lower bound are structural checks after globally invalid selector kinds.",
    "history": "Supersede only the blanket rejection of negative integer selectors by permitting existing in-range array positions. Frozen write-v1, map/composition authorities, statuses, digests and historical consumers remain unchanged.",
    "non_goals": ["unrelated read coercions", "effectful read receiver evaluation order", "expanded numeric range", "new assignment syntax", "current backend admission"],
}
UNDERFLOW_FIELDS = [
    "code", "operation", "binding", "segment_index", "path", "index", "length",
    "resolved_index", "source_span", "message",
]
DIAGNOSTICS = {
    "underflow": {
        "code": "nested_write_array_underflow",
        "fields": UNDERFLOW_FIELDS,
        "index": "authored evaluated negative integer",
        "length": "encountered existing array length after expression evaluation",
        "resolved_index": "length + index, strictly below zero",
        "message": "nested write segment {segment_index} for binding '{binding}' cannot select array index {index} at length {length} (resolved index {resolved_index})",
    },
    "unchanged": ["nested_write_segment_invalid", "nested_write_kind_conflict", "nested_write_array_gap", "receiver_mutation_reentrant"],
    "span": "Offending authored segment expression, half-open Unicode-scalar typed span; receiver guard uses the bare binding span.",
}
IDS = {
    "arithmetic_cases": {
        "last", "first", "underflow", "positive_zero", "positive_last", "append",
        "positive_gap", "empty_negative", "empty_append", "singleton_last",
        "singleton_underflow", "far_underflow",
    },
    "read_cases": {
        "last", "first", "underflow", "empty", "absent", "null", "wrong_kind",
        "positive", "positive_outside", "dynamic_negative", "mixed_nested",
        "quoted_negative_key", "missing_nested", "negative_zero",
    },
    "write_cases": {
        "last", "first", "dynamic_negative", "mixed_nested", "negative_then_create",
        "positive_append", "positive_replace", "absent_positive", "quoted_negative_key",
        "dynamic_negative_string_key", "negative_zero", "selector_resize", "rhs_resize",
        "underflow", "empty", "absent_negative", "missing_nested_negative",
        "null", "wrong_kind", "nested_null", "positive_gap", "gap_after_negative",
        "underflow_after_negative", "invalid_after_underflow", "invalid_before_conflict",
        "fractional", "segment_failure", "rhs_failure", "failure_keeps_rhs_effect",
        "guard_precedes_evaluation", "distinct_identity", "aggregate_detachment",
        "unicode_span",
    },
}


def require(condition, detail):
    if not condition:
        raise v1.ContractError("invalid_signed_contract", detail)


def historical_inputs():
    values = {}
    for name, identity in AUTHORITIES.items():
        raw = (ROOT / identity["path"]).read_bytes()
        require(hashlib.sha256(raw).hexdigest() == identity["sha256"], "historical bytes: " + name)
        value = json.loads(raw)
        require(value["contract_id"] == identity["contract_id"], "historical id: " + name)
        require(v1.canonical_json_sha256(value) == identity["canonical_json_sha256"], "historical digest: " + name)
        values[name] = value
    require(
        hashlib.sha256((ROOT / "tools/check_write_vivification_contract.py").read_bytes()).hexdigest()
        == WRITE_CHECKER_SHA,
        "historical checker bytes",
    )
    return values


def normalized_index(index, length):
    return length + index if index < 0 else index


def selector(observation):
    if observation.get("kind") == "integer":
        value = observation.get("value")
        require(isinstance(value, int) and not isinstance(value, bool), "integer observation")
        return "array", value, None
    return v1.selector(observation)


def underflow(case, parsed, index, prefix, key, length):
    resolved = normalized_index(key, length)
    return {
        "code": "nested_write_array_underflow",
        "operation": v1.OPERATION,
        "binding": case["binding"],
        "segment_index": index,
        "path": copy.deepcopy(prefix),
        "index": key,
        "length": length,
        "resolved_index": resolved,
        "source_span": v1.typed_span(case, parsed, index),
        "message": DIAGNOSTICS["underflow"]["message"].format(
            segment_index=index, binding=case["binding"], index=key,
            length=length, resolved_index=resolved,
        ),
    }


def execute_write(case, reserved):
    parsed = v1.validate_case_source(case, reserved)
    state = v1.state_from(case["initial_binding"])
    effects = []
    guard = case.get("guard")
    if guard is not None:
        require(set(guard) == {"active_identity", "target_identity"}, "guard fields")
        require(all(isinstance(value, str) and value for value in guard.values()), "guard identities")
        if guard["active_identity"] == guard["target_identity"]:
            start = case["source"].index(case["binding"])
            return state, None, {
                "code": "receiver_mutation_reentrant",
                "operation": "map_leaves_mutation",
                "binding": case["binding"], "method": "map_leaves", "attempt": "nested_write",
                "source_span": {
                    "source_id": "contract:" + case["id"], "start": start,
                    "end": start + len(case["binding"]), "unit": "unicode_scalar",
                    "provenance": "authored",
                },
                "message": f"cannot write active map_leaves! receiver binding '{case['binding']}' from its callback",
            }, effects
    for index, observation in enumerate(case["segments"]):
        effects.append(f"segment:{index}")
        if "evaluation_error" in observation:
            return state, None, copy.deepcopy(observation["evaluation_error"]), effects
        v1.apply_same_binding(state, observation)
    rhs = case["rhs"]
    effects.append("rhs")
    if "evaluation_error" in rhs:
        return state, None, copy.deepcopy(rhs["evaluation_error"]), effects
    v1.apply_same_binding(state, rhs)

    selectors = []
    prefix = []
    for index, observation in enumerate(case["segments"]):
        kind, key, reason = selector(observation)
        if reason is not None:
            error = v1.invalid_diagnostic(case, parsed, index, prefix, observation["kind"], reason)
            return state, None, error, effects
        selectors.append((kind, copy.deepcopy(key)))
        prefix.append(copy.deepcopy(key))

    def missing_negative(index, prefix):
        return v1.invalid_diagnostic(case, parsed, index, prefix, "integer", "negative_integer")

    if not state["present"]:
        if selectors[0][0] == "array" and selectors[0][1] < 0:
            return state, None, missing_negative(0, []), effects
        work = [] if selectors[0][0] == "array" else {}
    else:
        work = copy.deepcopy(state["value"])
    cursor = work
    prefix = []
    for index, (kind, key) in enumerate(selectors):
        actual = v1.runtime_kind(cursor)
        if actual != kind:
            return state, None, v1.conflict_diagnostic(case, parsed, index, prefix, kind, actual), effects
        last = index == len(selectors) - 1
        if kind == "array":
            length = len(cursor)
            position = normalized_index(key, length)
            if key < 0 and position < 0:
                return state, None, underflow(case, parsed, index, prefix, key, length), effects
            if key >= 0 and position > length:
                return state, None, v1.gap_diagnostic(case, parsed, index, prefix, key, length), effects
            missing = position == length
        else:
            position = key
            missing = key not in cursor
        if last:
            value = copy.deepcopy(rhs["value"])
        elif missing:
            next_kind, next_key = selectors[index + 1]
            if next_kind == "array" and next_key < 0:
                return state, None, missing_negative(index + 1, prefix + [key]), effects
            value = [] if next_kind == "array" else {}
        if last or missing:
            if kind == "array" and missing:
                cursor.append(value)
            else:
                cursor[position] = value
        if not last:
            cursor = cursor[position]
        prefix.append(copy.deepcopy(key))
    return {"present": True, "value": copy.deepcopy(work)}, copy.deepcopy(work), None, effects


def execute_read(case):
    # Synthetic assignment parses only the fixture's bracket/source alignment.
    # This does not assert a new read AST, coercion rule or receiver effect order.
    holder = {
        "id": case["id"], "source": case["source"] + " = null",
        "binding": case["binding"], "segments": case["segments"],
        "rhs": {"source": "null", "value": None},
    }
    v1.validate_case_source(holder, set(v1.CANONICAL_SYNTAX["reserved_root_names"]))
    state = v1.state_from(case["initial_binding"])
    if not state["present"]:
        return state, None
    cursor = state["value"]
    for observation in case["segments"]:
        kind, key, reason = selector(observation)
        require(reason is None, "read fixture outside signed integer/quoted-key scope")
        if observation["kind"] == "string":
            require(observation["source"].startswith('"'), "read key must be explicitly quoted")
        if v1.runtime_kind(cursor) != kind:
            return state, None
        if kind == "array":
            position = normalized_index(key, len(cursor))
            if not 0 <= position < len(cursor):
                return state, None
        else:
            position = key
            if key not in cursor:
                return state, None
        cursor = cursor[position]
    return state, copy.deepcopy(cursor)


def validate(contract):
    require(set(contract) == {
        "format", "contract_id", "status", "historical_authorities", "write_checker_sha256",
        "policy", "diagnostics", "arithmetic_cases", "read_cases", "write_cases", "detachment_probe",
    }, "top-level fields")
    require(type(contract["format"]) is int and contract["format"] == 1, "format")
    require(contract["contract_id"] == "linkedspec-signed-array-selector-v1", "id")
    require(contract["status"] == STATUS, "pending admission status")
    require(contract["historical_authorities"] == AUTHORITIES, "authority bindings")
    require(contract["write_checker_sha256"] == WRITE_CHECKER_SHA, "checker binding")
    require(contract["policy"] == POLICY, "policy")
    require(contract["diagnostics"] == DIAGNOSTICS, "diagnostic catalog")
    old = historical_inputs()
    reserved = set(old["write"]["syntax"]["reserved_root_names"])
    for field, ids in IDS.items():
        cases = contract[field]
        require(isinstance(cases, list), field + " array")
        found = [case.get("id") for case in cases]
        require(len(found) == len(set(found)) and set(found) == ids, field + " population")
    for case in contract["arithmetic_cases"]:
        require(set(case) == {"id", "length", "index", "expected"}, "arithmetic fields")
        length, index = case["length"], case["index"]
        require(type(length) is int and length >= 0 and type(index) is int, "arithmetic domain")
        resolved = normalized_index(index, length)
        observed = {
            "resolved_index": resolved,
            "readable": 0 <= resolved < length,
            "writable": 0 <= resolved < length or (index >= 0 and resolved == length),
        }
        require(observed == case["expected"], "arithmetic: " + case["id"])
    for case in contract["read_cases"]:
        require(set(case) == {"id", "source", "binding", "initial_binding", "segments", "expected_binding", "expected_result"}, "read fields")
        before = copy.deepcopy(case)
        state, result = execute_read(case)
        require(case == before, "read mutated fixture: " + case["id"])
        require(state == case["expected_binding"] and result == case["expected_result"], "read: " + case["id"])
    for case in contract["write_cases"]:
        require(set(case) == {"id", "source", "binding", "initial_binding", "segments", "rhs", "guard", "expected"}, "write fields")
        require(set(case["expected"]) == {"binding", "result", "error", "effects"}, "write expected fields")
        before = copy.deepcopy(case)
        state, result, error, effects = execute_write(case, reserved)
        require(case == before, "write mutated fixture: " + case["id"])
        require(
            {"binding": state, "result": result, "error": error, "effects": effects} == case["expected"],
            "write: " + case["id"],
        )
    probe = contract["detachment_probe"]
    require(set(probe) == {"case_id", "mutations", "expected"}, "detachment fields")
    case = copy.deepcopy(next(item for item in contract["write_cases"] if item["id"] == probe["case_id"]))
    state, result, error, _ = execute_write(case, reserved)
    require(error is None, "detachment setup")
    targets = {"initial": case["initial_binding"]["value"], "rhs": case["rhs"]["value"], "binding": state["value"], "result": result}
    require(set(probe["expected"]) == set(targets), "detachment target population")
    for mutation in probe["mutations"]:
        require(set(mutation) == {"target", "path", "value"}, "detachment mutation")
        v1.set_path(targets[mutation["target"]], mutation["path"], copy.deepcopy(mutation["value"]))
    require(targets == probe["expected"], "detachment")
    # Compare complete old outcomes, including exact diagnostics and effects.
    compatible = 0
    for group in ("success_cases", "failure_cases", "evaluation_failure_cases"):
        for case in old["write"][group]:
            require(execute_write(case, reserved) == v1.execute_write(case, reserved), "historical compatibility: " + case["id"])
            compatible += 1
    for case in old["write"]["read_exclusion_cases"]:
        # No new read syntax or string coercion is inferred from these old cases.
        require(v1.read_path(case["initial_binding"], case["segments"])[0] == case["expected_binding"], "historical read purity")
    return {
        "arithmetic_cases": len(contract["arithmetic_cases"]),
        "read_cases": len(contract["read_cases"]),
        "write_cases": len(contract["write_cases"]),
        "historical_write_outcomes": compatible,
        "status": STATUS,
    }


def mutations(contract):
    for field in ("status", "policy", "diagnostics", "historical_authorities"):
        candidate = copy.deepcopy(contract)
        candidate[field] = None
        yield field, candidate
    for field in IDS:
        for index, case in enumerate(contract[field]):
            candidate = copy.deepcopy(contract)
            candidate[field].pop(index)
            yield field + ":omit:" + case["id"], candidate
            candidate = copy.deepcopy(contract)
            item = candidate[field][index]
            target = "expected_result" if field == "read_cases" else "expected"
            item[target] = {"deliberately": "wrong"}
            yield field + ":target:" + case["id"], candidate


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--contract", default=PATH)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    path = Path(args.contract)
    require(not path.is_absolute() and ".." not in path.parts, "repository-relative contract")
    contract = json.loads((ROOT / path).read_bytes())
    summary = validate(contract)
    denials = []
    for name, candidate in mutations(contract):
        try:
            validate(candidate)
        except v1.ContractError as error:
            denials.append({"name": name, "code": error.code, "reason": str(error)})
        else:
            raise v1.ContractError("mutation_survived", name)
    summary["mutation_denials"] = denials
    if args.json:
        print(json.dumps(summary, ensure_ascii=False, sort_keys=True))
    else:
        print(
            f"signed-selector target contract: {summary['arithmetic_cases']} arithmetic, "
            f"{summary['read_cases']} reads, {summary['write_cases']} writes, "
            f"{summary['historical_write_outcomes']} exact historical write outcomes; "
            f"{len(denials)} rejected mutations; backend admission pending"
        )


if __name__ == "__main__":
    main()
