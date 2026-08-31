#!/usr/bin/env python3
"""Reject public mutation-result prose superseded by uniform binding v1."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

PUBLIC_FILES = [
    ROOT / "README.md",
    ROOT / "capability_conformance/README.md",
    ROOT / "dart/README.md",
    ROOT / "julia/README.md",
    ROOT / "lua/README.md",
    ROOT / "rust/README.md",
    *sorted((ROOT / "docs/linkedspec-book/src").rglob("*.md")),
]

HISTORICAL_CARDS = [
    "dart-runtime-array-helpers.md",
    "julia-runtime-array-helpers.md",
    "terse-array-end-mutation-methods.md",
    "terse-array-receiver-value-chains.md",
    "terse-composability-audit-boundaries.md",
    "terse-fluent-lifecycle-composability-split.md",
    "terse-mutation-assignment-expression-values.md",
    "terse-mutation-surface-ground-truth.md",
    "terse-return-type-method-chaining-split.md",
]

REQUIRED_ANCHORS = {
    "capability_conformance/uniform_binding_contract.json": [
        '"mutation_result": "mutable operations evaluate to the updated typed target value',
    ],
    "dart/README.md": ["updated-value array end mutations"],
    "julia/README.md": ["updated-value named/scalar-held end mutations"],
    "docs/linkedspec-book/src/appendix/helper-contract-catalog.md": [
        "`items.push_back(value).count()` yields the new count",
        "Array end mutations yield updated arrays too",
        "named array end mutations. They mutate a bare array binding",
        "the implicit form has no portable expression result yet",
        "yields an independent updated root snapshot in value positions",
        "Receiver-dot `name.set_key(key, value)` remains pure",
    ],
    "docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md": [
        "return independent updated arrays",
        "Their append behavior is portable, but their expression results are not yet",
        "typed path selection and yields the updated root snapshot",
        "Receiver-dot `meta.set_key(key, value)` is a pure derived value unless assigned back",
    ],
    "docs/knowledge/perl-uniform-binding-runtime.md": [
        "array end/transform methods all update that binding and yield its post-operation typed value",
    ],
    "docs/knowledge/rust-uniform-binding-runtime.md": [
        "`items.push_back(value).count()` mutates `items` and yields its updated count",
    ],
    "docs/knowledge/dart-uniform-binding-runtime.md": [
        "array-end updates can continue into methods such as `.count()`",
    ],
    "docs/knowledge/julia-uniform-binding-runtime.md": [
        "an array-end update can continue into methods such as `.count()`",
    ],
    "docs/knowledge/lua-uniform-binding-runtime.md": [
        "statement set-key mutation, array-end methods, and standalone collection transforms",
    ],
    "docs/knowledge/lua-runtime-named-harray-mutation.md": [
        "Direct `target[key] = value` harray assignment uses that same binding seam",
        "Statement context is the semantic boundary",
    ],
    "docs/knowledge/uniform-binding-array-end-result-supersession.md": [
        "The current contract is not statement-only",
        "Pop still discards the removed element",
    ],
}

FORBIDDEN = [
    re.compile(
        r"\bstatement-only\s+(?:named/scalar-held\s+)?(?:array\s+)?end mutations?\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\b(?:array\s+)?end mutations?\s+(?:remain|are|is)\s+statement-only\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\barray\s+end-mutation\s+methods?\s*;\s*statement-level\s+only\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\b(?:push_back|push_front|pop_back|pop_front)\b.{0,120}\b(?:remain|are|is)\s+statement-only\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\b(?:value-slot|value-position)\b.{0,160}\b(?:array[- ]end|end mutation|push_back|push_front|pop_back|pop_front)\b.{0,100}\b(?:no-op|null|undef|nothing|do not mutate)\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\bhash-index assignment\b.{0,140}\b(?:returns?|evaluates? to)\s+(?:void|undef|null|nothing)\b",
        re.IGNORECASE,
    ),
    re.compile(
        r"\breceiver(?:-dot)?\b.{0,80}\b[A-Za-z_]\w*\.set_key\b.{0,100}\bmutates?\s+(?:the\s+)?(?:source|named|working)\b",
        re.IGNORECASE,
    ),
]


def normalized(path: Path) -> str:
    return re.sub(r"\s+", " ", path.read_text(encoding="utf-8"))


def main() -> int:
    failures: list[str] = []

    for path in PUBLIC_FILES:
        text = normalized(path)
        for pattern in FORBIDDEN:
            match = pattern.search(text)
            if match:
                excerpt = match.group(0)[:180]
                failures.append(f"{path.relative_to(ROOT)}: superseded public claim: {excerpt}")

    for relative, anchors in REQUIRED_ANCHORS.items():
        path = ROOT / relative
        if not path.is_file():
            failures.append(f"{relative}: required file is missing")
            continue
        text = normalized(path)
        for anchor in anchors:
            if re.sub(r"\s+", " ", anchor) not in text:
                failures.append(f"{relative}: missing current anchor {anchor!r}")

    for name in HISTORICAL_CARDS:
        path = ROOT / "docs/knowledge" / name
        text = normalized(path).lower()
        if "supersed" not in text or "uniform" not in text or "binding" not in text:
            failures.append(f"docs/knowledge/{name}: missing explicit uniform-binding supersession")

    if failures:
        for failure in failures:
            print(f"uniform-binding-mutation-result-surface: ERROR: {failure}")
        return 1

    print(
        "uniform-binding-mutation-result-surface: OK "
        f"({len(PUBLIC_FILES)} public files; {len(REQUIRED_ANCHORS)} current anchors; "
        f"{len(HISTORICAL_CARDS)} historical cards classified)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
