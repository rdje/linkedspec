#!/usr/bin/env python3
"""Check independent composed-objective fixtures; never execute or evaluate DSL."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import math
from pathlib import Path
from typing import Any, Callable

from check_memory_handoff_state import task_statuses


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = "capability_conformance/composed_objective_contract.json"
CONTRACT_ID = "linkedspec-composed-objectives-v1"
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2"
SELECTION_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1"
SELECTION = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1-selection.json"
SELECTION_SHA = "b9e54e21dff39b08a098ea882a513d507730e0cdd7e4d6199c6374f8dbc30fe7"
SOURCE_CORRECTION_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1"
CI_CALL = "bash tools/run_python_project_data.sh tools/check_composed_objective_contract.py"
PERL_REGRESSION_CALL = "PERL5LIB= prove -Iperl t/composed_normalization_perl.t"
PERL_REGRESSION_INPUTS = (
    "t/composed_normalization_perl.t",
    "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-fresh.pl",
)
SOURCES = {
    "diagnostic": {
        "path": "tests/language-readiness/composed/diagnostic.spec",
        "sha256": "fba66e47d14b1a236deb1136ec2c515fa629f8a1d8dce36812431ebe8bc62fc0",
    },
    "normalization": {
        "path": "tests/language-readiness/composed/normalization-calls.spec",
        "sha256": "f4e45215d893a3c159eb146dd4c37b5008e6670bb52e180e3deebd8139e6a83e",
    },
    "diagnostic_invalid_arity": {
        "path": "tests/language-readiness/composed/diagnostic-invalid-arity.spec",
        "sha256": "bd474ebe5e927111b46163b217da66e3d75802f264558800b3bfeebd14ad773a",
    },
}
SOURCE_CORRECTIONS = {
    "normalization": {
        "owner": SOURCE_CORRECTION_OWNER,
        "original": {
            "path": "tests/language-readiness/composed/normalization.spec",
            "sha256": "ba9953c282e5e66956dc4b7d22c2acc7b1e879734654e7cb467ad41275cc4249",
        },
        "successor": dict(SOURCES["normalization"]),
        "change": {
            "from": "while(i < count(pieces)) { visited = visited + 1; i = i + 1 }",
            "to": "while(num_lt(i,count(pieces))) { visited = num_add(visited,1); i = num_add(i,1) }",
        },
    },
}


def source_input_paths() -> list[str]:
    return [*(source["path"] for source in SOURCES.values()),
            *(row["original"]["path"] for row in SOURCE_CORRECTIONS.values())]


# Independent input/mode register from the selected requirements, not the artifact.
CASES = (
    ("D_ordered_go", "diagnostic", "go", "collect"),
    ("D_ordered_wait", "diagnostic", "wait", "collect"),
    ("D_quiet_go", "diagnostic", "go", "absent"),
    ("D_exit_stop", "diagnostic", "stop", "collect"),
    ("D_sink_failure_after2", "diagnostic", "go", "throw_after2"),
    ("D_prefix_bad", "diagnostic", "!go", "collect"),
    ("D_suffix_bad", "diagnostic", "go!", "collect"),
    ("D_empty", "diagnostic", "", "collect"),
    ("D_bad_arity", "diagnostic_invalid_arity", "go", "collect"),
    ("P_ab_cd", "normalization", "ab-cd", "collect"),
    ("P_mixed_case", "normalization", "AB-cd", "collect"),
    ("P_short", "normalization", "x-y", "collect"),
    ("P_quiet", "normalization", "ab-cd", "absent"),
    ("P_prefix_bad", "normalization", "!ab-cd", "collect"),
    ("P_suffix_bad", "normalization", "ab-cd!", "collect"),
    ("P_empty", "normalization", "", "collect"),
)
DIMENSIONS = {
    "natural_recursion": ["foundation:nested-tree", "foundation:context-names"],
    "cursor_algebra": ["foundation:nested-tree", "foundation:lossless-segments", "D", "P"],
    "interval_boundary_capture": ["foundation:lossless-segments", "foundation:lossless-child"],
    "nested_state": ["foundation:context-names", "P"],
    "callable_composition": ["P"],
    "branching_iteration": ["D", "P"],
    "structural_transformation": ["P"],
    "typed_result_construction": ["D", "P"],
}
POLICY = {
    "oracle": "ordinary ASCII word/pair operations and explicit shape/event construction; no DSL evaluator or runtime-derived expectations",
    "failure": "portable test predicates preserve separate native compile/runtime failure evidence; no global runtime error wrapper",
    "quiet": "valid arguments still evaluate; no sink means no rich delivery or host diagnostic output",
    "detachment": "actual returned objects and deliberately aliased falsifiers are required in execution lanes; JSON consumer copies are insufficient",
    "mutations": "neutral corruption proves oracle/schema integrity only; runtime semantic variants require a healthy baseline and intended oracle rejection",
    "admission": "neutral governance only; existing runtime admission and all repair prerequisites remain unchanged",
}
EXECUTION_OWNERS = {
    "perl": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.1",
    "rust": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.4",
    "dart": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.5",
    "julia": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.6",
    "puc_lua": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.7",
    "luajit": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.7",
}
REPAIRS = [
    "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0",
    "SESSION-STARTUP-READING.87.2",
    "SESSION-STARTUP-READING.87.3",
]
MUTATIONS = (
    ("D_operand_order", "D_ordered_go", "argument effect order"),
    ("D_omitted_effect", "D_ordered_go", "complete argument effects"),
    ("D_item_order", "D_ordered_go", "ordered item delivery"),
    ("D_output_in_result", "D_ordered_go", "result/output separation"),
    ("D_boolean_as_number", "D_ordered_go", "typed boolean result"),
    ("D_work_after_exit", "D_exit_stop", "immediate authored exit"),
    ("D_wrapped_caller_failure", "D_sink_failure_after2", "identical caller failure"),
    ("D_effect_before_arity", "D_bad_arity", "arity before argument effects"),
    ("P_frozen_prefix", "P_ab_cd", "live caller prefix"),
    ("P_skipped_function", "P_ab_cd", "pure function computation"),
    ("P_parameter_restore", "P_ab_cd", "temporary parameter restoration"),
    ("P_mapped_alias", "P_ab_cd", "actual receiver/result detachment"),
    ("P_original_alias", "P_ab_cd", "actual original-copy detachment"),
    ("P_reversed_visits", "P_ab_cd", "original-shape visitation order"),
    ("P_wrong_count", "P_ab_cd", "finite attached iteration"),
    ("P_missing_publication", "P_ab_cd", "post-transform nested write"),
)


class ContractError(ValueError):
    """Only an exact reason from this checker can discharge a falsifier."""

    def __init__(self, code: str, message: str):
        self.code = code
        super().__init__(f"{code}: {message}")


def require(condition: bool, code: str, message: str) -> None:
    if not condition:
        raise ContractError(code, message)


def digest(contents: bytes) -> str:
    return hashlib.sha256(contents).hexdigest()


def read_relative(path: str) -> bytes:
    candidate = Path(path)
    require(not candidate.is_absolute() and ".." not in candidate.parts,
            "path", "evidence must be repository-relative")
    resolved = (ROOT / candidate).resolve()
    require(resolved.is_relative_to(ROOT) and resolved.is_file(),
            "path", "evidence must be a repository file")
    return resolved.read_bytes()


def load_json(contents: bytes) -> Any:
    def pairs(items: list[tuple[str, Any]]) -> dict[str, Any]:
        result = {}
        for key, value in items:
            require(key not in result, "json", f"duplicate object key {key}")
            result[key] = value
        return result

    def nonfinite(text: str) -> None:
        raise ContractError("json", f"nonfinite number {text}")

    return json.loads(contents, object_pairs_hook=pairs, parse_constant=nonfinite)


def value_kind(value: Any) -> str:
    if value is None:
        return "null"
    if type(value) is bool:
        return "boolean"
    if type(value) in (int, float):
        require(not isinstance(value, float) or math.isfinite(value),
                "value_kind", "nonfinite portable number")
        return "number"
    if type(value) is str:
        return "string"
    if type(value) is list:
        return "array"
    if type(value) is dict:
        return "harray"
    raise ContractError("value_kind", f"unsupported observation type {type(value).__name__}")


def equal_typed(actual: Any, expected: Any, code: str, path: str = "$") -> None:
    actual_kind, expected_kind = value_kind(actual), value_kind(expected)
    require(actual_kind == expected_kind, code, f"{path} kind {actual_kind} != {expected_kind}")
    if expected_kind == "harray":
        require(set(actual) == set(expected), code, f"{path} object fields differ")
        for key in expected:
            equal_typed(actual[key], expected[key], code, f"{path}.{key}")
    elif expected_kind == "array":
        require(len(actual) == len(expected), code, f"{path} array length differs")
        for index, (left, right) in enumerate(zip(actual, expected)):
            equal_typed(left, right, code, f"{path}[{index}]")
    else:
        require(actual == expected, code, f"{path} scalar differs")


def event(helper: str, message: str) -> dict[str, str]:
    return {"helper_name": helper, "rule_label": "Top", "message": message}


def expected_observation(case: tuple[str, str, str, str]) -> dict[str, Any]:
    """Domain oracle: explicit values/events, with no authored-language execution."""
    _, source, text, sink = case
    result = {
        "outcome": "value", "value": None, "events": [], "host_output": "",
        "exit_status": None, "caller_error_identity": None, "helper_arity": None,
        "detachment": None,
    }
    if source == "diagnostic_invalid_arity":
        result.update(outcome="helper_arity",
                      helper_arity={"helper": "print_each", "actual": 4, "accepted": [2, 3]})
        return result
    valid_word = bool(text) and all("a" <= c <= "z" for c in text)
    pieces = text.split("-")
    valid_pair = len(pieces) == 2 and all(
        part and all("a" <= c <= "z" or "A" <= c <= "Z" for c in part) for part in pieces
    )
    if not (valid_pair if source == "normalization" else valid_word):
        result.update(outcome="authored_exit", exit_status=1)
        return result
    if source == "diagnostic":
        events = [event("print", "begin:" + text)]
        if text == "stop":
            events.append(event("say", "stop\n"))
            result.update(outcome="authored_exit", exit_status=7)
        else:
            events += [event("print_each", "part:" + fragment + "!")
                       for fragment in ("α", "", "", "🙂")]
            events.append(event("say", "done\n"))
            result["value"] = {"word": text, "effects": ["left", "right"], "payload": False}
        if sink == "throw_after2":
            result.update(outcome="caller_failure", value=None, caller_error_identity=True)
            events = events[:2]
        result["events"] = [] if sink == "absent" else events
    else:
        first, second = pieces
        original = {"a": first, "b": {"c": second}}
        mapped = {"a": "new:" + first.upper(), "b": {"c": "new:" + second.upper()}}
        tree = copy.deepcopy(mapped)
        tree["meta"] = {"count": 2}
        result["value"] = {
            "tree": tree, "mapped": mapped, "original": original,
            "seen": pieces, "text": "outside", "visits": 2,
        }
        result["events"] = [] if sink == "absent" else [
            event("print_each", "leaf:" + first + "!"),
            event("print_each", "leaf:" + second + "!"),
            event("say", "done:2\n"),
        ]
        result["detachment"] = {
            "actual_result_checked": True, "mapped_unchanged": True,
            "original_unchanged": True, "deliberately_aliased_control_rejected": True,
        }
    return result


def expected_case(case: tuple[str, str, str, str]) -> dict[str, Any]:
    case_id, source, text, sink = case
    return {
        "id": case_id, "source_id": source, "input": text, "sink_mode": sink,
        "expected": expected_observation(case),
    }


def compare_observation(actual: Any, expected: dict[str, Any]) -> None:
    require(type(actual) is dict and set(actual) == set(expected),
            "observation_schema", "portable observation fields differ")
    for key in ("outcome", "value", "events", "host_output", "exit_status",
                "caller_error_identity", "helper_arity", "detachment"):
        equal_typed(actual[key], expected[key], "observation_" + key)


def selection_foundation(read: Callable[[str], bytes] = read_relative) -> dict[str, str]:
    contents = read(SELECTION)
    require(digest(contents) == SELECTION_SHA, "selection_binding", "selection checkpoint changed")
    selection = load_json(contents)
    return selection["retained_foundation"]["latest_original_source_identities"]


def expected_contract(read: Callable[[str], bytes] = read_relative) -> dict[str, Any]:
    return {
        "format": 1, "contract_id": CONTRACT_ID, "fixture_owner": OWNER,
        "selection_owner": SELECTION_OWNER,
        "selection": {"path": SELECTION, "sha256": SELECTION_SHA},
        "sources": copy.deepcopy(SOURCES), "foundation_sources": selection_foundation(read),
        "source_corrections": copy.deepcopy(SOURCE_CORRECTIONS),
        "dimensions": copy.deepcopy(DIMENSIONS), "policy": copy.deepcopy(POLICY),
        "execution_owners": copy.deepcopy(EXECUTION_OWNERS), "repair_owners": list(REPAIRS),
        "cases": [expected_case(case) for case in CASES],
        "mutation_requirements": [
            {"id": mutation, "case_id": case, "role": role} for mutation, case, role in MUTATIONS
        ],
        "unassessed": [
            "indentation width/tabs/dedent", "quoted-string escaping",
            "comments inside versus outside strings", "whole formats",
            "richer diagnostics/recovery", "general resources/performance",
            "supplementary-character key ordering", "sandbox security",
        ],
    }


def validate_contract(actual: Any, read: Callable[[str], bytes] = read_relative) -> None:
    expected = expected_contract(read)
    require(type(actual) is dict and set(actual) == set(expected),
            "contract_schema", "closed contract fields differ")
    require(type(actual["format"]) is int and actual["format"] == 1,
            "contract_format", "format must be integer1")
    for key in expected:
        if key not in ("cases",):
            equal_typed(actual[key], expected[key], "contract_" + key)
    require(type(actual["cases"]) is list and len(actual["cases"]) == len(CASES),
            "case_register", "case count differs")
    for row, case in zip(actual["cases"], CASES):
        model = expected_case(case)
        require(type(row) is dict and set(row) == set(model),
                "case_register", "case fields differ")
        for key in ("id", "source_id", "input", "sink_mode"):
            equal_typed(row[key], model[key], "case_register")
        compare_observation(row["expected"], model["expected"])
    for source in SOURCES.values():
        require(digest(read(source["path"])) == source["sha256"],
                "source_binding", f"source changed: {source['path']}")
    for correction in SOURCE_CORRECTIONS.values():
        original = read(correction["original"]["path"])
        require(digest(original) == correction["original"]["sha256"],
                "source_history_binding", "original normalization source changed")
        before = correction["change"]["from"].encode()
        after = correction["change"]["to"].encode()
        require(original.count(before) == 1 and original.replace(before, after, 1)
                == read(correction["successor"]["path"]),
                "source_correction", "successor differs beyond the one diagnosed loop")
    for path, checksum in expected["foundation_sources"].items():
        require(digest(read(path)) == checksum, "foundation_binding", f"original source changed: {path}")
    validate_owners(task_statuses(ROOT / "docs/tasks"))
    ci = read("tools/run_ci_local.sh").decode().splitlines()
    for call in (CI_CALL, PERL_REGRESSION_CALL):
        require(ci.count(call) == 1, "ci_registration", "proof needs exactly one canonical call: " + call)
    inputs = [CONTRACT, "tools/check_composed_objective_contract.py", *source_input_paths(),
              *PERL_REGRESSION_INPUTS]
    for path in inputs:
        require(ci.count("require_tracked_file " + path) == 1,
                "ci_registration", f"input needs exactly one registration: {path}")


def validate_owners(statuses: dict[str, str | None]) -> None:
    for owner in [OWNER, SELECTION_OWNER, SOURCE_CORRECTION_OWNER,
                  *EXECUTION_OWNERS.values(), *REPAIRS]:
        require(owner in statuses, "owner", f"missing task owner {owner}")
    require(statuses[SELECTION_OWNER] == "done", "owner", "selection is incomplete")
    require(statuses[OWNER] in ("active", "done"), "owner", "fixture owner is not activated")
    require(statuses[SOURCE_CORRECTION_OWNER] in ("active", "done"),
            "owner", "source correction is not activated")


def rejection(check: Callable[[], None], reason: str) -> None:
    try:
        check()
    except ContractError as error:
        require(error.code == reason, "falsifier_reason",
                f"expected {reason}, observed {error.code}")
    else:
        raise ContractError("falsifier_accepted", f"corruption did not reject for {reason}")


def observation_falsifiers() -> list[str]:
    models = {case[0]: expected_observation(case) for case in CASES}
    results = []
    for mutation, case_id, _ in MUTATIONS:
        actual = copy.deepcopy(models[case_id])
        reason = "observation_value"
        if mutation == "D_operand_order":
            actual["value"]["effects"].reverse()
        elif mutation == "D_omitted_effect":
            actual["value"]["effects"].pop()
        elif mutation == "D_item_order":
            actual["events"][1], actual["events"][4] = actual["events"][4], actual["events"][1]
            reason = "observation_events"
        elif mutation == "D_output_in_result":
            actual["value"]["output"] = "begin:go"
        elif mutation == "D_boolean_as_number":
            actual["value"]["payload"] = 0
        elif mutation == "D_work_after_exit":
            actual["events"].append(event("say", "late\n"))
            reason = "observation_events"
        elif mutation == "D_wrapped_caller_failure":
            actual["caller_error_identity"] = False
            reason = "observation_caller_error_identity"
        elif mutation == "D_effect_before_arity":
            actual["events"].append(event("say", "arity:items\n"))
            reason = "observation_events"
        elif mutation in ("P_frozen_prefix", "P_skipped_function"):
            for key in ("tree", "mapped"):
                actual["value"][key]["a"] = "old:AB" if mutation == "P_frozen_prefix" else "new:ab"
        elif mutation == "P_parameter_restore":
            actual["value"]["text"] = "cd"
        elif mutation == "P_mapped_alias":
            actual["detachment"]["mapped_unchanged"] = False
            reason = "observation_detachment"
        elif mutation == "P_original_alias":
            actual["detachment"]["original_unchanged"] = False
            reason = "observation_detachment"
        elif mutation == "P_reversed_visits":
            actual["value"]["seen"].reverse()
        elif mutation == "P_wrong_count":
            actual["value"]["visits"] = 1
        elif mutation == "P_missing_publication":
            del actual["value"]["tree"]["meta"]
        else:
            raise ContractError("mutation_register", f"unhandled mutation {mutation}")
        rejection(lambda: compare_observation(actual, models[case_id]), reason)
        results.append(mutation)
    return results


def contract_falsifiers(contract: dict[str, Any]) -> int:
    count = 0
    for key in contract:
        mutant = copy.deepcopy(contract)
        del mutant[key]
        rejection(lambda: validate_contract(mutant), "contract_schema")
        count += 1
    mutant = copy.deepcopy(contract)
    mutant["format"] = 1.0
    rejection(lambda: validate_contract(mutant), "contract_format")
    count += 1
    for key in ("fixture_owner", "selection_owner"):
        mutant = copy.deepcopy(contract)
        mutant[key] += ".missing"
        rejection(lambda: validate_contract(mutant), "contract_" + key)
        count += 1
    for key in POLICY:
        mutant = copy.deepcopy(contract)
        mutant["policy"][key] = "weakened"
        rejection(lambda: validate_contract(mutant), "contract_policy")
        count += 1
    for index, case in enumerate(CASES):
        for key in ("id", "source_id", "input", "sink_mode"):
            mutant = copy.deepcopy(contract)
            mutant["cases"][index][key] += "!"
            rejection(lambda: validate_contract(mutant), "case_register")
            count += 1
        for key, replacement in (("events", [event("say", "unexpected")]),
                                 ("host_output", "leaked output")):
            mutant = copy.deepcopy(contract)
            mutant["cases"][index]["expected"][key] = replacement
            rejection(lambda: validate_contract(mutant), "observation_" + key)
            count += 1
    for source in SOURCES.values():
        def corrupted_source(path: str, target: str = source["path"]) -> bytes:
            data = read_relative(path)
            return data + b" " if path == target else data
        rejection(lambda: validate_contract(contract, corrupted_source), "source_binding")
        count += 1
    original_path = SOURCE_CORRECTIONS["normalization"]["original"]["path"]
    rejection(lambda: validate_contract(contract, lambda path: read_relative(path) +
              (b" " if path == original_path else b"")), "source_history_binding")
    count += 1
    for field in ("owner", "original", "successor", "change"):
        mutant = copy.deepcopy(contract)
        mutant["source_corrections"]["normalization"][field] = "weakened"
        rejection(lambda: validate_contract(mutant), "contract_source_corrections")
        count += 1
    target = next(iter(contract["foundation_sources"]))
    rejection(lambda: validate_contract(contract, lambda path: read_relative(path) +
              (b" " if path == target else b"")), "foundation_binding")
    count += 1
    for call in (CI_CALL, PERL_REGRESSION_CALL):
        for replacement in ("", call + "\n" + call):
            rejection(lambda: validate_contract(contract, lambda path: read_relative(path).replace(
                call.encode(), replacement.encode(), 1) if path == "tools/run_ci_local.sh"
                else read_relative(path)), "ci_registration")
            count += 1
    for path in [CONTRACT, "tools/check_composed_objective_contract.py", *source_input_paths(),
                 *PERL_REGRESSION_INPUTS]:
        line = ("require_tracked_file " + path + "\n").encode()
        rejection(lambda: validate_contract(contract, lambda target: read_relative(target).replace(
            line, b"", 1) if target == "tools/run_ci_local.sh" else read_relative(target)),
            "ci_registration")
        count += 1
    statuses = task_statuses(ROOT / "docs/tasks")
    for owner in dict.fromkeys([OWNER, SELECTION_OWNER, SOURCE_CORRECTION_OWNER,
                               *EXECUTION_OWNERS.values(), *REPAIRS]):
        mutant = dict(statuses)
        del mutant[owner]
        rejection(lambda: validate_owners(mutant), "owner")
        count += 1
    return count


def validate_observation_file(document: Any, contract: dict[str, Any]) -> int:
    """A producer supplies native evidence beside these private portable predicates."""
    require(type(document) is dict and set(document) == {"contract_id", "producer", "observations"},
            "producer_schema", "producer report fields differ")
    require(document["contract_id"] == CONTRACT_ID, "producer_schema", "wrong contract identity")
    producer = document["producer"]
    require(type(producer) is dict and set(producer) == {"runtime", "route"}
            and producer["runtime"] in EXECUTION_OWNERS
            and type(producer["route"]) is str and bool(producer["route"]),
            "producer_schema", "runtime/route identity is required")
    rows = document["observations"]
    require(type(rows) is list and len(rows) == len(CASES),
            "producer_schema", "all sixteen selected cases are required")
    for row, case in zip(rows, contract["cases"]):
        require(type(row) is dict and set(row) == {
            "case_id", "source_sha256", "portable", "native_failure", "failure_phase"
        }, "producer_schema", "case report fields differ")
        require(row["case_id"] == case["id"]
                and row["source_sha256"] == SOURCES[case["source_id"]]["sha256"],
                "producer_identity", "case/source identity differs")
        compare_observation(row["portable"], case["expected"])
        if case["expected"]["outcome"] == "value":
            require(row["native_failure"] is None and row["failure_phase"] is None,
                    "native_failure", "successful case carries a failure")
        else:
            require(type(row["native_failure"]) in (str, dict) and bool(row["native_failure"])
                    and row["failure_phase"] in ("compile", "runtime"),
                    "native_failure", "retain native failure evidence and its phase")
            if case["expected"]["outcome"] != "helper_arity":
                require(row["failure_phase"] == "runtime",
                        "native_failure", "authored exit/caller failure must reach execution")
    return len(rows)


def producer_falsifiers(contract: dict[str, Any]) -> int:
    """Synthetic records exercise report validation, never native execution."""
    report = {
        "contract_id": CONTRACT_ID, "producer": {"runtime": "perl", "route": "neutral-control"},
        "observations": [{
            "case_id": case["id"], "source_sha256": SOURCES[case["source_id"]]["sha256"],
            "portable": copy.deepcopy(case["expected"]),
            "native_failure": None if case["expected"]["outcome"] == "value"
            else {"synthetic_control_only": True},
            "failure_phase": None if case["expected"]["outcome"] == "value" else "runtime",
        } for case in contract["cases"]],
    }
    validate_observation_file(report, contract)
    compile_arity = copy.deepcopy(report)
    arity_row = next(row for row in compile_arity["observations"] if row["case_id"] == "D_bad_arity")
    arity_row["failure_phase"] = "compile"
    validate_observation_file(compile_arity, contract)
    count = 0
    for key in report:
        mutant = copy.deepcopy(report)
        del mutant[key]
        rejection(lambda: validate_observation_file(mutant, contract), "producer_schema")
        count += 1
    for index, case in enumerate(contract["cases"]):
        mutant = copy.deepcopy(report)
        mutant["observations"][index]["source_sha256"] = "wrong"
        rejection(lambda: validate_observation_file(mutant, contract), "producer_identity")
        count += 1
        mutant = copy.deepcopy(report)
        mutant["observations"][index]["native_failure"] = (
            {"unexpected": True} if case["expected"]["outcome"] == "value" else None
        )
        rejection(lambda: validate_observation_file(mutant, contract), "native_failure")
        count += 1
        if case["expected"]["outcome"] in ("authored_exit", "caller_failure"):
            mutant = copy.deepcopy(report)
            mutant["observations"][index]["failure_phase"] = "compile"
            rejection(lambda: validate_observation_file(mutant, contract), "native_failure")
            count += 1
    mutant = copy.deepcopy(report)
    mutant["observations"].pop()
    rejection(lambda: validate_observation_file(mutant, contract), "producer_schema")
    return count + 1


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--observations", help="repository-relative private producer report")
    args = parser.parse_args()
    contract = load_json(read_relative(CONTRACT))
    validate_contract(contract)
    structural = contract_falsifiers(contract)
    observation = observation_falsifiers()
    producer = producer_falsifiers(contract)
    # A generic exception must never count as the expected semantic rejection.
    def unrelated_exception() -> None:
        raise ValueError("unrelated")

    def unrelated_contract_error() -> None:
        raise ContractError("source_binding", "unrelated")

    try:
        rejection(unrelated_exception, "observation_events")
    except ContractError:
        raise ContractError("falsifier_reason", "unrelated exception was classified as contract proof")
    except ValueError as error:
        require(str(error) == "unrelated", "falsifier_reason", "unexpected control exception")
    else:
        raise ContractError("falsifier_reason", "unrelated exception was swallowed")
    rejection(lambda: rejection(unrelated_contract_error, "observation_events"), "falsifier_reason")
    rejection(lambda: load_json(b'{"key":1,"key":2}'), "json")
    rejection(lambda: load_json(b'{"value":NaN}'), "json")
    extra = ""
    if args.observations:
        count = validate_observation_file(load_json(read_relative(args.observations)), contract)
        extra = f"; {count} supplied producer observations match (native proof remains producer-owned)"
    print(f"composed objective contract: {len(CASES)} cases / {len(SOURCES)} sources / "
          f"{len(DIMENSIONS)} dimensions; {structural} structural + "
          f"{len(observation)} observation / {producer} producer-report falsifiers; "
          f"two unrelated-error and two JSON controls PASS; "
          f"neutral governance only, no DSL execution{extra}")


if __name__ == "__main__":
    main()
