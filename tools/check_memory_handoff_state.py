#!/usr/bin/env python3
"""Reject resume pointers whose handoff semantics contradict task-tree state."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MEMORY = ROOT / "MEMORY.md"
TASKS_DIR = ROOT / "docs/tasks"

FIELD_RE = re.compile(r"^- ([a-z][a-z0-9_]*):\s*(.*)$")
TASK_ID_RE = re.compile(r"`([A-Z][A-Z0-9-]*(?:\.\d+)+)(?=`|\s)")
TASK_DEFINITION_RE = re.compile(r"^\s*- ID: `([^`]+)`\s*$")
TASK_STATUS_RE = re.compile(r"^\s+Status: `([^`]+)`")
DONE_STATUS_RE = re.compile(
    r"(?:^|[; /-])(?:done|closed|complete|completed)(?:$|[; /-])|signoff-complete"
)
NONE_RE = re.compile(r"^none(?:\b|[.;: —-])", re.IGNORECASE)
STALE_ACTIVE_RE = re.compile(
    r"\b(?:staged|uncommitted|in[- ]flight|in progress|"
    r"awaiting (?:commit|push)|commit/push boundary)\b",
    re.IGNORECASE,
)
FUTURE_LANDING_RE = re.compile(
    r"\b(?:re)?stag(?:e|ing)\b|\bcommit(?:ting)?\b|"
    r"\bpush(?:ing)?\b|\bland(?:ing)?\b",
    re.IGNORECASE,
)
REQUIRED_FIELDS = (
    "latest_completed_leaf",
    "active_work_unit",
    "next_action",
    "in_flight_uncommitted",
)


class HandoffError(ValueError):
    """Resume-pointer handoff invariant failure."""


def require(condition: bool, detail: str) -> None:
    if not condition:
        raise HandoffError(detail)


def parse_memory_fields(source: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    current: str | None = None

    for line in source.splitlines():
        match = FIELD_RE.match(line)
        if match:
            current, value = match.groups()
            require(current not in fields, f"MEMORY.md duplicates field {current!r}")
            fields[current] = value.strip()
            continue
        if current is not None and line.startswith("  ") and line.strip():
            fields[current] = f"{fields[current]} {line.strip()}".strip()
            continue
        current = None

    for field in REQUIRED_FIELDS:
        require(field in fields and fields[field], f"MEMORY.md is missing nonempty field {field!r}")
    return fields


def task_statuses(tasks_dir: Path) -> dict[str, str | None]:
    statuses: dict[str, str | None] = {}

    for path in sorted(tasks_dir.glob("*.md")):
        lines = path.read_text(encoding="utf-8").splitlines()
        for index, line in enumerate(lines):
            match = TASK_DEFINITION_RE.match(line)
            if not match:
                continue
            task_id = match.group(1)
            status = ""
            for candidate in lines[index + 1 : index + 6]:
                status_match = TASK_STATUS_RE.match(candidate)
                if status_match:
                    status = status_match.group(1)
                    break
                if TASK_DEFINITION_RE.match(candidate):
                    break
            require(status, f"task {task_id!r} has no nearby Status field in {path.relative_to(ROOT)}")
            if task_id not in statuses:
                statuses[task_id] = status
            elif statuses[task_id] != status:
                statuses[task_id] = None

    require(statuses, "no task-tree definitions were discovered")
    return statuses


def extract_task_id(value: str, field: str) -> str:
    match = TASK_ID_RE.search(value)
    require(match is not None, f"{field} must name one backticked task-tree leaf ID")
    return match.group(1)


def task_is_done(status: str) -> bool:
    return DONE_STATUS_RE.search(status.lower()) is not None


def short_task_id(task_id: str) -> str:
    dot = task_id.find(".")
    return task_id[dot:] if dot >= 0 else task_id


def references_task(value: str, task_id: str) -> bool:
    return task_id in value or short_task_id(task_id) in value


def resolved_status(statuses: dict[str, str | None], task_id: str, field: str) -> str:
    require(task_id in statuses, f"{field} names unknown task {task_id!r}")
    status = statuses[task_id]
    require(status is not None, f"{field} names task {task_id!r} with ambiguous current statuses")
    return status


def validate_handoff(fields: dict[str, str], statuses: dict[str, str | None]) -> None:
    latest_id = extract_task_id(fields["latest_completed_leaf"], "latest_completed_leaf")
    latest_status = resolved_status(statuses, latest_id, "latest_completed_leaf")
    require(
        task_is_done(latest_status),
        f"latest_completed_leaf {latest_id!r} has non-complete task status {latest_status!r}",
    )

    active_value = fields["active_work_unit"]
    in_flight = fields["in_flight_uncommitted"]
    if NONE_RE.match(active_value):
        require(
            NONE_RE.match(in_flight) is not None,
            "active_work_unit is none but in_flight_uncommitted is not none",
        )
        return

    active_id = extract_task_id(active_value, "active_work_unit")
    active_status = resolved_status(statuses, active_id, "active_work_unit")
    if not task_is_done(active_status):
        return

    require(
        STALE_ACTIVE_RE.search(active_value) is None,
        f"completed active_work_unit {active_id!r} still describes pre-landing state",
    )
    require(
        NONE_RE.match(in_flight) is not None,
        f"completed active_work_unit {active_id!r} requires in_flight_uncommitted: none",
    )
    next_action = fields["next_action"]
    require(
        not (references_task(next_action, active_id) and FUTURE_LANDING_RE.search(next_action)),
        f"next_action still schedules stage/commit/push work for completed leaf {active_id!r}",
    )


def fixture_fields(
    *,
    latest: str = "`TREE.22` - complete stable markers",
    active: str,
    next_action: str,
    in_flight: str,
) -> dict[str, str]:
    return {
        "latest_completed_leaf": latest,
        "active_work_unit": active,
        "next_action": next_action,
        "in_flight_uncommitted": in_flight,
    }


def expect_rejection(
    name: str,
    fields: dict[str, str],
    statuses: dict[str, str | None],
) -> None:
    try:
        validate_handoff(fields, statuses)
    except HandoffError:
        return
    raise HandoffError(f"mutation {name!r} was not rejected")


def run_mutation_proof() -> tuple[int, int]:
    statuses = {
        "TREE.22": "completed",
        "TREE.22.1": "in_progress",
        "TREE.23.1": "pending",
    }
    valid = (
        fixture_fields(
            active="`TREE.22.1` in progress",
            next_action="Implement the owned continuity repair.",
            in_flight="task-tree activation is staged; implementation follows",
        ),
        fixture_fields(
            active="`TREE.22` completed; awaiting next selection",
            next_action="After `TREE.22` landed cleanly, select and activate `TREE.23.1`.",
            in_flight="none; the completed leaf is clean",
        ),
        fixture_fields(
            active="none after the atomic closeout",
            next_action="Select and activate `TREE.23.1`.",
            in_flight="none; no background job remains",
        ),
    )
    for fields in valid:
        validate_handoff(fields, statuses)

    rejected = (
        (
            "completed_active_still_staged",
            fixture_fields(
                active="`TREE.22` exact staged canonical boundary",
                next_action="Select `TREE.23.1` after closeout.",
                in_flight="none",
            ),
        ),
        (
            "completed_next_action_still_lands",
            fixture_fields(
                active="`TREE.22` completed; awaiting next selection",
                next_action="Stage, commit, and push `.22`.",
                in_flight="none",
            ),
        ),
        (
            "completed_leaf_still_in_flight",
            fixture_fields(
                active="`TREE.22` completed; awaiting next selection",
                next_action="Select `TREE.23.1`.",
                in_flight="the `.22` candidate remains uncommitted",
            ),
        ),
        (
            "latest_completed_is_not_done",
            fixture_fields(
                latest="`TREE.22.1` - continuity repair",
                active="`TREE.22.1` in progress",
                next_action="Implement the repair.",
                in_flight="none",
            ),
        ),
        (
            "idle_pointer_claims_in_flight_work",
            fixture_fields(
                active="none after the atomic closeout",
                next_action="Select `TREE.23.1`.",
                in_flight="an unstaged candidate remains",
            ),
        ),
    )
    for name, fields in rejected:
        expect_rejection(name, fields, statuses)
    ambiguous_statuses = dict(statuses)
    ambiguous_statuses["TREE.22.1"] = None
    expect_rejection(
        "active_task_status_is_ambiguous",
        fixture_fields(
            active="`TREE.22.1` in progress",
            next_action="Implement the repair.",
            in_flight="none",
        ),
        ambiguous_statuses,
    )
    return len(valid), len(rejected) + 1


def main() -> int:
    fields = parse_memory_fields(MEMORY.read_text(encoding="utf-8"))
    statuses = task_statuses(TASKS_DIR)
    validate_handoff(fields, statuses)
    valid_count, mutation_count = run_mutation_proof()
    print(
        "memory-handoff-state: OK "
        f"({len(REQUIRED_FIELDS)} fields; {valid_count} valid cases; "
        f"{mutation_count} rejected mutations)"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except HandoffError as error:
        raise SystemExit(f"memory-handoff-state: {error}") from error
