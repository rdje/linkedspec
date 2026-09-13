#!/usr/bin/env python3
"""Keep checker-owned closeout facts outside mutable task-frontier rows."""

from __future__ import annotations

import re
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TASK_TREE = ROOT / "docs/TASK_TREE.md"
SECTION_BEGIN = "<!-- BEGIN CANONICAL CLOSED-CAPABILITY MARKERS -->"
SECTION_END = "<!-- END CANONICAL CLOSED-CAPABILITY MARKERS -->"
ACTIVE_TREE_HEADING = "## Active Task Trees"
FUTURE_ROW = re.compile(r"^\| `FUTURE-PARITY-BACKLOG` \|[^\n]*$", re.MULTILINE)

MARKER_FAMILIES = (
    {
        "id": "logical_helper",
        "markers": ("Logical helper parent `.5.2` is closed at 8/0",),
        "consumers": (
            "tools/check_logical_helper_contract.py",
            "capability_conformance/logical_helper_contract.json",
        ),
    },
    {
        "id": "root_rule_selection",
        "markers": ("final five-backend recurring/public no-drift",),
        "consumers": (
            "tools/check_root_rule_selection_contract.py",
            "capability_conformance/root_rule_selection_contract.json",
        ),
    },
    {
        "id": "duplicate_regex_slot",
        "markers": ("duplicate-slot recurring/public no-drift is closed",),
        "consumers": (
            "tools/check_duplicate_regex_slot_identity_contract.py",
            "capability_conformance/duplicate_regex_slot_identity_contract.json",
        ),
    },
    {
        "id": "rule_local_cursor",
        "markers": (
            "rule-local cursor recurring/public no-drift at 75 files / 8 complete + 0 pending / 60 mutations",
            "Explicit repeated-OR action-result shape `.9.1.10` remains",
        ),
        "consumers": (
            "tools/check_rule_local_cursor_contract.py",
            "capability_conformance/rule_local_cursor_contract.json",
        ),
    },
    {
        "id": "repeated_action_result",
        "markers": ("repeated-action recurring/public no-drift is closed",),
        "consumers": (
            "tools/check_repeated_action_result_contract.py",
            "capability_conformance/repeated_action_result_contract.json",
        ),
    },
    {
        "id": "callable_codeblock",
        "markers": (
            "Callable-codeblock parent `.11.7` is closed at four admitted backends",
            "Five-backend callable recurring/public admission is complete",
        ),
        "consumers": (
            "tools/check_callable_codeblock_contract.py",
            "capability_conformance/callable_codeblock_contract.json",
        ),
    },
    {
        "id": "capability_exclusion",
        "markers": (
            "exclusion public closeout `.24.2`",
            "Capability exclusion freshness is public-closed under `FUTURE-PARITY-BACKLOG.24`",
        ),
        "consumers": ("tools/check_capability_conformance.pl",),
    },
    {
        "id": "semantic_introspection",
        "markers": (
            "FUTURE-PARITY-BACKLOG.10.10",
            "128 omission-sensitive mutations",
        ),
        "consumers": (
            "tools/check_semantic_introspection_contract.py",
            "capability_conformance/semantic_introspection_contract.json",
        ),
    },
)


class MarkerError(ValueError):
    """Stable closed-capability marker invariant failure."""


def require(condition: bool, detail: str) -> None:
    if not condition:
        raise MarkerError(detail)


def all_markers() -> tuple[str, ...]:
    return tuple(
        dict.fromkeys(
            marker
            for family in MARKER_FAMILIES
            for marker in family["markers"]
        )
    )


def section_bounds(source: str) -> tuple[int, int]:
    require(source.count(SECTION_BEGIN) == 1, "stable marker section must have one BEGIN sentinel")
    require(source.count(SECTION_END) == 1, "stable marker section must have one END sentinel")
    begin = source.index(SECTION_BEGIN)
    end = source.index(SECTION_END, begin) + len(SECTION_END)
    require(begin < end, "stable marker section sentinels are reversed")
    return begin, end


def validate_task_tree(source: str) -> None:
    begin, end = section_bounds(source)
    heading = source.find(ACTIVE_TREE_HEADING)
    require(heading >= 0 and heading < begin, "active task-tree table must precede the stable marker section")
    frontier_surface = source[heading:begin]
    stable_surface = source[begin:end]

    for family in MARKER_FAMILIES:
        for marker in family["markers"]:
            require(
                stable_surface.count(marker) == 1,
                f"{family['id']} marker must occur exactly once in the stable section: {marker}",
            )
            require(
                marker not in frontier_surface,
                f"{family['id']} marker leaked into the mutable active-tree surface: {marker}",
            )


def tracked_consumer_candidates() -> set[str]:
    result = subprocess.run(
        ["git", "ls-files", "-z", "tools", "scripts", "capability_conformance"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    candidates = {
        item.decode("utf-8")
        for item in result.stdout.split(b"\0")
        if item
    }
    candidates.discard("tools/check_task_tree_closed_capability_markers.py")
    return candidates


def validate_consumer_inventory() -> None:
    expected_consumers = {
        consumer
        for family in MARKER_FAMILIES
        for consumer in family["consumers"]
    }
    markers = all_markers()
    discovered_consumers: set[str] = set()

    for relative in tracked_consumer_candidates():
        path = ROOT / relative
        if not path.is_file():
            continue
        source = path.read_text(encoding="utf-8")
        if "docs/TASK_TREE.md" in source and any(marker in source for marker in markers):
            discovered_consumers.add(relative)

    require(
        discovered_consumers == expected_consumers,
        "closed-capability consumer inventory drifted: "
        f"missing={sorted(expected_consumers - discovered_consumers)} "
        f"unexpected={sorted(discovered_consumers - expected_consumers)}",
    )

    for family in MARKER_FAMILIES:
        for relative in family["consumers"]:
            source = (ROOT / relative).read_text(encoding="utf-8")
            require(
                "docs/TASK_TREE.md" in source,
                f"{family['id']} consumer no longer targets docs/TASK_TREE.md: {relative}",
            )
            for marker in family["markers"]:
                require(
                    marker in source,
                    f"{family['id']} consumer lost marker {marker!r}: {relative}",
                )


def replace_stable_marker(source: str, marker: str, replacement: str) -> str:
    begin, end = section_bounds(source)
    stable_surface = source[begin:end]
    require(stable_surface.count(marker) == 1, f"mutation target is not unique in stable section: {marker}")
    mutated = stable_surface.replace(marker, replacement, 1)
    return source[:begin] + mutated + source[end:]


def expect_rejection(name: str, source: str) -> None:
    try:
        validate_task_tree(source)
    except MarkerError:
        return
    raise MarkerError(f"mutation {name!r} was not rejected")


def run_mutation_proof(source: str) -> int:
    row = FUTURE_ROW.search(source)
    require(row is not None, "FUTURE-PARITY-BACKLOG active-tree row is missing")
    replacement_row = (
        "| `FUTURE-PARITY-BACKLOG` | `active` / synthetic frontier | mutation fixture | "
        "Current work may change without carrying unrelated closed-state prose. | "
        "[task](docs/tasks/FUTURE-PARITY-BACKLOG.md) |"
    )
    rewritten = source[: row.start()] + replacement_row + source[row.end() :]
    validate_task_tree(rewritten)

    repeated = "repeated-action recurring/public no-drift is closed"
    callable_marker = "Five-backend callable recurring/public admission is complete"
    expect_rejection(
        "delete_repeated_action_stable_marker",
        replace_stable_marker(source, repeated, "repeated-action marker removed"),
    )
    moved = replace_stable_marker(source, repeated, "repeated-action marker moved")
    moved_row = FUTURE_ROW.search(moved)
    require(moved_row is not None, "FUTURE-PARITY-BACKLOG row disappeared during move mutation")
    moved_text = (
        moved[: moved_row.end() - 2]
        + f" {repeated} |"
        + moved[moved_row.end() :]
    )
    expect_rejection("move_repeated_action_marker_into_active_row", moved_text)
    expect_rejection(
        "delete_callable_stable_marker",
        replace_stable_marker(source, callable_marker, "callable marker removed"),
    )
    return 4


def main() -> int:
    source = TASK_TREE.read_text(encoding="utf-8")
    validate_task_tree(source)
    validate_consumer_inventory()
    mutation_count = run_mutation_proof(source)
    print(
        "task-tree-closed-capability-markers: OK "
        f"({len(MARKER_FAMILIES)} families; {len(all_markers())} markers; "
        f"{sum(len(family['consumers']) for family in MARKER_FAMILIES)} consumers; "
        f"{mutation_count} mutation cases)"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except MarkerError as error:
        raise SystemExit(f"task-tree-closed-capability-markers: {error}") from error
