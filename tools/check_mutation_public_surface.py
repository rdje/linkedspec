#!/usr/bin/env python3
"""Bind current mutation teaching to the frozen semantic authorities."""

from __future__ import annotations

import copy
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_PUBLIC_FILE_COUNT = 70
PRIMARY_GUIDE = "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md"

AUTHORITY_PATHS = {
    "write": "capability_conformance/write_vivification_contract.json",
    "map": "capability_conformance/map_leaves_mutation_contract.json",
    "composition": "capability_conformance/write_map_leaves_composition_contract.json",
}

EXPECTED_AUTHORITY = {
    "write": {
        "contract_id": "linkedspec-write-vivification-v1",
        "policies": {
            "creation": (
                "root_creation",
                "an absent binding is created as the container selected by the first evaluated segment; "
                "a present null or other scalar is not absence",
            ),
            "dense_arrays": (
                "dense_arrays",
                "an array write replaces an existing index or appends at exactly length; an index greater "
                "than length is a typed gap failure and no filler values are invented",
            ),
            "conflicts": (
                "existing_values",
                "existing values are never coerced or overwritten to manufacture a required container kind",
            ),
            "evaluation_order": (
                "evaluation_order",
                "segment expressions evaluate left to right exactly once, then the RHS evaluates exactly once, "
                "then segment-kind and structural validation begin",
            ),
        },
    },
    "map": {
        "contract_id": "linkedspec-map-leaves-mutation-v1",
        "policies": {
            "original_shape": (
                "snapshot",
                "receiver lookup validates an existing harray or array and deep-copies it before callbacks; "
                "traversal and rebuilding use only that isolated original-shape snapshot",
            ),
            "callback_fields": (
                "callback_frame",
                "each leaf callback receives detached scoped value, path, depth, and root-kind selector key or "
                "index; path is a fresh complete receiver-root-relative copy for every callback",
            ),
            "identity_guard": (
                "reentrancy",
                "while callbacks execute, every direct or helper-mediated write through the same resolved "
                "receiver binding identity is rejected before that attempted write; a shadow binding with the "
                "same spelling and unrelated binding identities remain independent",
            ),
            "rollback": (
                "failure_effects",
                "receiver validation, callback, or re-entrant failure leaves the receiver unchanged while "
                "already-completed ordinary effects on unrelated bindings retain normal semantics",
            ),
            "detached_result": (
                "result",
                "successful leaf publication returns a detached updated-root value; statement-position use may "
                "discard that value without suppressing the approved leaf updates",
            ),
        },
    },
    "composition": {
        "contract_id": "linkedspec-write-map-leaves-composition-v1",
        "policies": {
            "composition": (
                "callback_value",
                "vivifying the detached callback value changes only that callback-local value; the returned "
                "updated root becomes the replacement and is not revisited during the same traversal",
            ),
            "post_commit_continuation": (
                "post_commit",
                "ordinary caller-scoped continuation begins after map_leaves! publishes its leaf updates and "
                "after the guard is released; a nested write reached there follows the write contract, while "
                "its failure preserves the earlier leaf publication",
            ),
        },
    },
}

GOVERNED_ANCHORS = {
    "ROADMAP.md": [
        "Public-current examples and recurring no-drift are complete under `.19.9`",
    ],
    "ROADMAP_V2.md": [
        "`.19.9` publishes governed current examples, adds recurring public no-drift, and closes parent `.19`",
    ],
    "ARCHITECTURE_STATE.md": [
        "`.19.9` binds current public teaching back to those unchanged authorities through one recurring checker",
    ],
    "TOOLBOX.md": [
        "`tools/check_mutation_public_surface.py` — current mutation teaching/no-drift",
    ],
    "capability_conformance/README.md": [
        "## Public mutation surface",
        "It deliberately excludes task, decision, Knowledge, and history records from its stale-current scan",
    ],
    "dart/README.md": [
        "typed nested value-path assignment with dense unambiguous missing-container creation",
    ],
    "docs/linkedspec-book/src/appendix/backend-handoff.md": [
        "Nested-write and `map_leaves!` parity is publicly closed",
    ],
    "docs/linkedspec-book/src/appendix/formal-grammar.md": [
        "`.19.9` closes public no-drift for this exact grammar",
    ],
    "docs/linkedspec-book/src/appendix/helper-contract-catalog.md": [
        "`.19.9` closes current public no-drift",
        "On all five backends, `binding.map_leaves!() { block }` is the distinct atomic receiver-rebinding traversal",
    ],
    "docs/linkedspec-book/src/appendix/runtime-semantics.md": [
        "`.19.9` closes the current public semantics without changing this behavior",
    ],
    "docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md": [
        "`.19.9` closes current public no-drift for the exact v1 surface",
    ],
    PRIMARY_GUIDE: [
        "### Nested-write creation, dense arrays, conflicts, and evaluation order",
        "`.19.9` closes the governed public surface without widening the syntax",
    ],
    "docs/linkedspec-book/src/overview/design-rationale.md": [
        "`.19.9` closes their governed public surface and parent activity",
    ],
    "docs/linkedspec-book/src/overview/project-status.md": [
        "`.19.9` publishes the exact current examples, adds recurring public no-drift, and closes parent `.19`",
    ],
}

SEMANTIC_EXAMPLE_ANCHORS = {
    "creation": 'document["sections"][0]["title"] = "Intro";',
    "dense_arrays": '`document[2] = "gap"` fails with `nested_write_array_gap`',
    "conflicts": 'document["item"]["name"] = "new";',
    "evaluation_order": "the two segment expressions run exactly once in left-to-right order, then the RHS runs exactly once",
    "original_shape": "Traversal follows the receiver's original root kind and shape",
    "callback_fields": "Each callback receives detached `value` and `path`, plus `depth` and `index`",
    "identity_guard": "The guard follows resolved binding identity",
    "rollback": "The same rollback applies when a callback itself fails",
    "detached_result": "The bang call returns a detached copy of the committed root",
    "composition": 'value[0]["name"] = "A";',
    "post_commit_continuation": 'tree["extra"][2] = "X";',
}

STALE_CURRENT_CLAIMS = (
    "Nested writes are non-vivifying on every backend.",
    "`map_leaves!` is unsupported on every backend.",
    "nested value-path assignment without autovivifying missing intermediates",
    "portable admission remains pending",
    "public-current closeout remains `.19.9`",
    "public-current no-drift remains `.19.9`",
    "public-current no-drift remains owned by `.19.9`",
    "public-current no-drift plus parent closeout remain `.19.9`",
    "final public-current no-drift remains `.19.9`",
    "`.19.9` owns final public-current examples and no-drift",
)


class PublicSurfaceError(ValueError):
    """Raised when current mutation teaching drifts from its authority."""


def fail(message: str) -> None:
    raise SystemExit(f"mutation-public-surface: ERROR: {message}")


def normalized(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def public_markdown_paths() -> list[Path]:
    fixed = [
        ROOT / "README.md",
        ROOT / "ROADMAP.md",
        ROOT / "ROADMAP_V2.md",
        ROOT / "ARCHITECTURE_STATE.md",
        ROOT / "TOOLBOX.md",
        ROOT / "capability_conformance/README.md",
    ]
    component_readmes = list(ROOT.glob("*/README.md"))
    book_files = list((ROOT / "docs/linkedspec-book/src").rglob("*.md"))
    return sorted(
        set(fixed + component_readmes + book_files),
        key=lambda path: path.relative_to(ROOT).as_posix(),
    )


def read_public_sources(paths: list[Path]) -> dict[str, str]:
    sources: dict[str, str] = {}
    for path in paths:
        if not path.is_file():
            raise PublicSurfaceError(f"required public file is missing: {path.relative_to(ROOT)}")
        sources[path.relative_to(ROOT).as_posix()] = path.read_text(encoding="utf-8")
    return sources


def read_authorities() -> dict[str, Any]:
    authorities: dict[str, Any] = {}
    for name, relative in AUTHORITY_PATHS.items():
        path = ROOT / relative
        if not path.is_file():
            raise PublicSurfaceError(f"frozen authority is missing: {relative}")
        try:
            authorities[name] = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise PublicSurfaceError(f"cannot read frozen authority {relative}: {error}") from error
    return authorities


def validate_authorities(authorities: dict[str, Any]) -> None:
    if set(authorities) != set(EXPECTED_AUTHORITY):
        raise PublicSurfaceError("frozen authority set drifted")
    for name, expected in EXPECTED_AUTHORITY.items():
        authority = authorities[name]
        if authority.get("contract_id") != expected["contract_id"]:
            raise PublicSurfaceError(f"{name} authority id drifted")
        policy = authority.get("policy")
        if not isinstance(policy, dict):
            raise PublicSurfaceError(f"{name} authority policy must be an object")
        for concept, (field, exact_text) in expected["policies"].items():
            if policy.get(field) != exact_text:
                raise PublicSurfaceError(f"{name} authority {concept} policy drifted")


def require_exact_anchor(relative: str, source: str, anchor: str) -> None:
    count = normalized(source).count(normalized(anchor))
    if count != 1:
        raise PublicSurfaceError(
            f"{relative}: current anchor must occur exactly once ({count} found): {anchor!r}"
        )


def remove_anchor_once(source: str, anchor: str, where: str) -> str:
    pattern = re.compile(r"\s+".join(re.escape(part) for part in anchor.split()))
    candidate, replacements = pattern.subn("", source, count=1)
    if replacements != 1:
        raise PublicSurfaceError(f"invalid anchor mutation fixture in {where}: {anchor!r}")
    return candidate


def validate_public_sources(paths: list[Path], sources: dict[str, str]) -> None:
    if len(paths) != EXPECTED_PUBLIC_FILE_COUNT:
        raise PublicSurfaceError(
            f"public Markdown inventory drifted: expected {EXPECTED_PUBLIC_FILE_COUNT}, got {len(paths)}"
        )
    expected_paths = {path.relative_to(ROOT).as_posix() for path in paths}
    if set(sources) != expected_paths:
        raise PublicSurfaceError("loaded public source set does not match the public inventory")

    for relative, anchors in GOVERNED_ANCHORS.items():
        if relative not in sources:
            raise PublicSurfaceError(f"governed public document is absent from inventory: {relative}")
        for anchor in anchors:
            require_exact_anchor(relative, sources[relative], anchor)

    guide = sources[PRIMARY_GUIDE]
    for concept, anchor in SEMANTIC_EXAMPLE_ANCHORS.items():
        require_exact_anchor(f"{PRIMARY_GUIDE} ({concept})", guide, anchor)

    normalized_sources = {relative: normalized(source).casefold() for relative, source in sources.items()}
    for claim in STALE_CURRENT_CLAIMS:
        needle = normalized(claim).casefold()
        for relative, source in normalized_sources.items():
            if needle in source:
                raise PublicSurfaceError(f"{relative}: stale current claim remains: {claim!r}")


def expect_failure(name: str, action: Any) -> None:
    try:
        action()
    except PublicSurfaceError:
        return
    raise PublicSurfaceError(f"self-test mutation unexpectedly passed: {name}")


def mutation_checks(
    paths: list[Path], sources: dict[str, str], authorities: dict[str, Any]
) -> int:
    count = 0

    for authority_name, expected in EXPECTED_AUTHORITY.items():
        for concept, (field, _exact_text) in expected["policies"].items():
            candidate = copy.deepcopy(authorities)
            candidate[authority_name]["policy"][field] += " drift"
            expect_failure(
                f"authority:{authority_name}:{concept}",
                lambda candidate=candidate: validate_authorities(candidate),
            )
            count += 1

    for relative, anchors in GOVERNED_ANCHORS.items():
        for anchor in anchors:
            candidate = dict(sources)
            candidate[relative] = remove_anchor_once(candidate[relative], anchor, relative)
            expect_failure(
                f"current-anchor:{relative}:{anchor}",
                lambda candidate=candidate: validate_public_sources(paths, candidate),
            )
            count += 1

    for concept, anchor in SEMANTIC_EXAMPLE_ANCHORS.items():
        candidate = dict(sources)
        candidate[PRIMARY_GUIDE] = remove_anchor_once(
            candidate[PRIMARY_GUIDE], anchor, f"semantic example {concept}"
        )
        expect_failure(
            f"semantic-example:{concept}",
            lambda candidate=candidate: validate_public_sources(paths, candidate),
        )
        count += 1

    for index, claim in enumerate(STALE_CURRENT_CLAIMS):
        candidate = dict(sources)
        candidate["README.md"] += f"\n{claim}\n"
        expect_failure(
            f"stale-current:{index}",
            lambda candidate=candidate: validate_public_sources(paths, candidate),
        )
        count += 1

    expect_failure(
        "public-inventory-omission",
        lambda: validate_public_sources(paths[:-1], sources),
    )
    return count + 1


def main() -> int:
    try:
        paths = public_markdown_paths()
        sources = read_public_sources(paths)
        authorities = read_authorities()
        validate_authorities(authorities)
        validate_public_sources(paths, sources)
        mutation_count = mutation_checks(paths, sources, authorities)
    except PublicSurfaceError as error:
        fail(str(error))

    print(
        "mutation-public-surface: OK "
        f"({len(paths)} public files; {len(GOVERNED_ANCHORS)} governed documents; "
        f"{len(SEMANTIC_EXAMPLE_ANCHORS)} semantic example classes; "
        f"{len(STALE_CURRENT_CLAIMS)} stale claims rejected; {mutation_count} mutations)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
