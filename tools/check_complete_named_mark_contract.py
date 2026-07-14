#!/usr/bin/env python3
"""Validate the exact neutral complete named-mark helper contract."""

from __future__ import annotations

import copy
import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "complete_named_mark_contract.json"
HELPERS = [
    ("mark_entry_start", "write", "entry_start"),
    ("mark_entry_end", "write", "entry_end"),
    ("mark_match_start", "write", "match_start"),
    ("mark_match_end", "write", "match_end"),
    ("mark_line", "read", "stored_mark_line"),
    ("mark_col", "read", "stored_mark_column"),
    ("clear_mark", "delete", "stored_mark"),
]


class ContractError(ValueError):
    """Stable contract validation failure."""


def fail(detail: str) -> None:
    raise ContractError(detail)


def line_col(text: str, position: int) -> tuple[int, int]:
    if position < 0 or position > len(text):
        fail(f"invalid character position {position}")
    prefix = text[:position]
    line = prefix.count("\n") + 1
    column = len(prefix.rsplit("\n", 1)[-1]) + 1
    return line, column


def location(text: str, position: int) -> list[int]:
    line, column = line_col(text, position)
    return [position, line, column]


def render_fixture() -> str:
    return """Top::
 I { mark_input_end(shared) }
 /é\\nA/ -> Top {
  return(hash(
   "child", call(Child),
   "parent_shared", mark_pos(shared),
   "parent_line", mark_line(shared),
   "parent_col", mark_col(shared)
  ))
 }

Child::
 /β/ -> Child {
  mark_entry_start(entry_start)
  mark_entry_end(entry_end)
  mark_match_start(match_start)
  mark_match_end(match_end)
  mark_match_end(shared)
  mark_match_end(clearable)
  before_clear = mark_exists(clearable)
  clear_mark(clearable)
  return(hash(
   "entry_start", array(mark_pos(entry_start), mark_line(entry_start), mark_col(entry_start)),
   "entry_end", array(mark_pos(entry_end), mark_line(entry_end), mark_col(entry_end)),
   "match_start", array(mark_pos(match_start), mark_line(match_start), mark_col(match_start)),
   "match_end", array(mark_pos(match_end), mark_line(match_end), mark_col(match_end)),
   "symbolic", mark_exists(entry_start),
   "before_clear", before_clear,
   "after_clear", mark_exists(clearable),
   "cleared_pos", mark_pos(clearable),
   "missing_pos", mark_pos(missing),
   "missing_line", mark_line(missing),
   "missing_col", mark_col(missing)
  ))
 }
"""


def evaluate_fixture(fixture: dict[str, Any]) -> dict[str, Any]:
    text = fixture["input"]
    parent_match = fixture["parent_match"]
    child_match = fixture["child_match"]
    if not text.startswith(parent_match):
        fail("parent match is not the input prefix")
    entry_start = 0
    entry_end = len(parent_match)
    if not text.startswith(child_match, entry_end):
        fail("child match does not begin at the parent right edge")
    match_start = entry_end
    match_end = match_start + len(child_match)

    parent_marks = {"shared": len(text)}
    child_marks = {
        "entry_start": entry_start,
        "entry_end": entry_end,
        "match_start": match_start,
        "match_end": match_end,
        "shared": match_end,
        "clearable": match_end,
    }
    before_clear = int("clearable" in child_marks)
    child_marks.pop("clearable", None)

    return {
        "child": {
            "entry_start": location(text, child_marks["entry_start"]),
            "entry_end": location(text, child_marks["entry_end"]),
            "match_start": location(text, child_marks["match_start"]),
            "match_end": location(text, child_marks["match_end"]),
            "symbolic": int("entry_start" in child_marks),
            "before_clear": before_clear,
            "after_clear": int("clearable" in child_marks),
            "cleared_pos": child_marks.get("clearable"),
            "missing_pos": child_marks.get("missing"),
            "missing_line": None,
            "missing_col": None,
        },
        "parent_shared": parent_marks["shared"],
        "parent_line": line_col(text, parent_marks["shared"])[0],
        "parent_col": line_col(text, parent_marks["shared"])[1],
    }


def validate_contract(contract: dict[str, Any]) -> None:
    if set(contract) != {
        "format",
        "contract_id",
        "policy",
        "helper_schema",
        "helpers",
        "fixture",
    }:
        fail("top-level fields drifted")
    if contract["format"] != 1 or contract["contract_id"] != "linkedspec-complete-named-mark-v1":
        fail("format or contract id drifted")
    if set(contract["policy"]) != {"scope", "storage", "names", "missing", "clear", "entry", "local"}:
        fail("policy fields drifted")
    if "isolated by rule label" not in contract["policy"]["scope"]:
        fail("rule-local scope policy drifted")
    if contract["helper_schema"] != {
        "fields": ["name", "kind", "args", "position"],
        "symbolic_mark_arg": "mark_name",
        "public_location_base": 1,
    }:
        fail("helper schema drifted")

    helpers = contract["helpers"]
    if not isinstance(helpers, list) or len(helpers) != len(HELPERS):
        fail("helper count drifted")
    observed: list[tuple[str, str, str]] = []
    for helper in helpers:
        if not isinstance(helper, dict) or list(helper) != ["name", "kind", "args", "position"]:
            fail("helper fields or order drifted")
        if helper["args"] != ["mark_name"]:
            fail(f"symbolic argument drifted for {helper['name']}")
        observed.append((helper["name"], helper["kind"], helper["position"]))
    if observed != HELPERS:
        fail("helper membership, order, or semantics drifted")

    fixture = contract["fixture"]
    if not isinstance(fixture, dict) or set(fixture) != {
        "input",
        "parent_match",
        "child_match",
        "spec_source",
        "expected",
    }:
        fail("fixture fields drifted")
    if fixture["spec_source"] != render_fixture():
        fail("fixture source drifted")
    if evaluate_fixture(fixture) != fixture["expected"]:
        fail("fixture expected value drifted")


def assert_mutation_rejected(contract: dict[str, Any], mutate: Any, label: str) -> None:
    changed = copy.deepcopy(contract)
    mutate(changed)
    try:
        validate_contract(changed)
    except ContractError:
        return
    fail(f"checker accepted drift mutation: {label}")


def main() -> None:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    validate_contract(contract)
    assert_mutation_rejected(contract, lambda value: value["helpers"].pop(), "missing helper")
    assert_mutation_rejected(
        contract,
        lambda value: value["policy"].__setitem__("scope", "execution-global marks"),
        "global scope",
    )
    assert_mutation_rejected(
        contract,
        lambda value: value["fixture"]["expected"].__setitem__("parent_shared", 4),
        "child overwrites parent mark",
    )
    print(
        "complete named-mark contract: "
        f"{len(contract['helpers'])} helpers, exact Unicode/rule-local fixture, 3 drift mutations"
    )


if __name__ == "__main__":
    main()
