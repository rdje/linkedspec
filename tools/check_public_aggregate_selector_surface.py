#!/usr/bin/env python3
"""Enforce final public admission of selector-free typed bindings."""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXPECTED_PUBLIC_FILE_COUNT = 69
EXPECTED_CLASSIFIED_REFERENCE_COUNT = 35
MIGRATION_GUIDE = "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md"
MIGRATION_SECTION_START = (
    "The retired aggregate-selector spellings are not current authoring:"
)
MIGRATION_SECTION_END = "source is already selector-free."
# Construct retired spellings from fragments so the executable-source scanner does
# not mistake this checker's negative fixtures for runnable positive `.spec` source.
OLD_ARRAY_ITEMS = "array" + "(items)"
OLD_HASH_META = "hash" + "(meta)"
OLD_ARRAY_PARTS = "array" + "(parts)"
RETIRED_ARRAY_EXAMPLE = f"set({OLD_ARRAY_ITEMS}, [value]);"
RETIRED_HASH_EXAMPLE = f"set({OLD_HASH_META}, {{ field : value }});"
EXPECTED_RETIRED_EXAMPLES = f"""```text
{RETIRED_ARRAY_EXAMPLE}
{RETIRED_HASH_EXAMPLE}
```"""
EXPECTED_MIGRATION_CONTRASTS = (
    (OLD_ARRAY_ITEMS, "items"),
    (f"copy({OLD_ARRAY_ITEMS})", "copy(items)"),
    (f"set({OLD_ARRAY_ITEMS}, [])", "set(items, [])"),
    (f"push({OLD_ARRAY_ITEMS}, value)", "push(items, value)"),
    (
        f"split({OLD_ARRAY_PARTS}, source, delimiter)",
        "split(parts, source, delimiter)",
    ),
)
EXACT_SELECTOR = re.compile(
    r"(?<![A-Za-z0-9_])(?:array|hash)\([ \t]*[A-Za-z_][A-Za-z0-9_]*[ \t]*\)"
)
MIGRATION_CONTRAST = re.compile(
    r"`([^`\n]+)`[ \t]+becomes(?:[ \t]+|[ \t]*\n>[ \t]*)`([^`\n]+)`"
)
CODE_SELECTOR = re.compile(
    r"(?<![A-Za-z0-9_])(?:array|hash)[ \t]*\([ \t]*[A-Za-z_][A-Za-z0-9_]*[ \t]*\)"
)
NEGATIVE_CONTEXT = re.compile(
    r"\b(?:former|historical|invalid|migrat\w*|must\s+not|"
    r"no\s+exact|previously|reject\w*|remov\w*|retir\w*|supersed\w*)\b",
    re.IGNORECASE,
)


def fail(message: str) -> None:
    raise SystemExit(f"public-aggregate-selector-surface: {message}")


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        fail(f"required file is missing: {relative}")
    return path.read_text(encoding="utf-8")


class MigrationContrastError(ValueError):
    """Raised when the public old-to-new selector migration contract drifts."""


def migration_section_bounds(source: str) -> tuple[int, int]:
    if source.count(MIGRATION_SECTION_START) != 1:
        raise MigrationContrastError("migration section start is missing or duplicated")
    if source.count(MIGRATION_SECTION_END) != 1:
        raise MigrationContrastError("migration section end is missing or duplicated")
    start = source.find(MIGRATION_SECTION_START)
    end = source.find(MIGRATION_SECTION_END, start)
    return start, end + len(MIGRATION_SECTION_END)


def migration_section(source: str) -> str:
    start, end = migration_section_bounds(source)
    return source[start:end]


def validate_migration_contrasts(source: str) -> None:
    section = migration_section(source)
    if section.count(EXPECTED_RETIRED_EXAMPLES) != 1:
        raise MigrationContrastError(
            "retired array/hash selector example block is missing, duplicated, or altered"
        )

    contrasts = tuple(MIGRATION_CONTRAST.findall(section))
    if contrasts != EXPECTED_MIGRATION_CONTRASTS:
        raise MigrationContrastError(
            "ordered old-selector-to-bare-binding contrasts do not match the public contract: "
            f"observed {contrasts!r}"
        )
    for old, new in contrasts:
        if old == new:
            raise MigrationContrastError(f"migration contrast collapsed to identity: {old!r}")
        if not EXACT_SELECTOR.search(old):
            raise MigrationContrastError(
                f"migration old side has no removed aggregate selector: {old!r}"
            )
        if EXACT_SELECTOR.search(new):
            raise MigrationContrastError(
                f"migration replacement still contains an aggregate selector: {new!r}"
            )


def replace_once(source: str, old: str, new: str, mutation: str) -> str:
    if source.count(old) != 1:
        fail(f"invalid {mutation} self-test fixture: expected one {old!r}")
    return source.replace(old, new, 1)


def check_migration_contrast_mutations(source: str) -> int:
    validate_migration_contrasts(source)
    mutations = (
        (
            "collapse retired array example",
            f"{RETIRED_ARRAY_EXAMPLE}\n{RETIRED_HASH_EXAMPLE}",
            f"set(items, [value]);\n{RETIRED_HASH_EXAMPLE}",
        ),
        (
            "collapse retired hash example",
            f"{RETIRED_ARRAY_EXAMPLE}\n{RETIRED_HASH_EXAMPLE}",
            f"{RETIRED_ARRAY_EXAMPLE}\nset(meta, {{ field : value }});",
        ),
        (
            "collapse bare-read contrast",
            f"`{OLD_ARRAY_ITEMS}` becomes `items`",
            "`items` becomes `items`",
        ),
        (
            "collapse copy contrast",
            f"`copy({OLD_ARRAY_ITEMS})` becomes `copy(items)`",
            "`copy(items)` becomes `copy(items)`",
        ),
        (
            "collapse set contrast",
            f"`set({OLD_ARRAY_ITEMS}, [])` becomes\n> `set(items, [])`",
            "`set(items, [])` becomes\n> `set(items, [])`",
        ),
        (
            "collapse push contrast",
            f"`push({OLD_ARRAY_ITEMS}, value)` becomes `push(items, value)`",
            "`push(items, value)` becomes `push(items, value)`",
        ),
        (
            "collapse split contrast",
            f"`split({OLD_ARRAY_PARTS}, source, delimiter)` becomes `split(parts, source, delimiter)`",
            "`split(parts, source, delimiter)` becomes `split(parts, source, delimiter)`",
        ),
        (
            "retain selector in replacement",
            f"`{OLD_ARRAY_ITEMS}` becomes `items`",
            f"`{OLD_ARRAY_ITEMS}` becomes `{OLD_ARRAY_ITEMS}`",
        ),
        (
            "alter replacement binding",
            f"`copy({OLD_ARRAY_ITEMS})` becomes `copy(items)`",
            f"`copy({OLD_ARRAY_ITEMS})` becomes `copy(meta)`",
        ),
        (
            "reorder contrasts",
            (
                f"`{OLD_ARRAY_ITEMS}` becomes `items`, "
                f"`copy({OLD_ARRAY_ITEMS})` becomes `copy(items)`"
            ),
            (
                f"`copy({OLD_ARRAY_ITEMS})` becomes `copy(items)`, "
                f"`{OLD_ARRAY_ITEMS}` becomes `items`"
            ),
        ),
        (
            "omit split contrast",
            f", and\n> `split({OLD_ARRAY_PARTS}, source, delimiter)` becomes `split(parts, source, delimiter)`",
            "",
        ),
    )
    for name, old, new in mutations:
        mutated = replace_once(source, old, new, name)
        try:
            validate_migration_contrasts(mutated)
        except MigrationContrastError:
            continue
        fail(f"migration contrast mutation unexpectedly passed: {name}")
    return len(mutations)


def public_markdown_paths() -> list[Path]:
    fixed = [
        ROOT / "README.md",
        ROOT / "ROADMAP.md",
        ROOT / "ROADMAP_V2.md",
        ROOT / "ARCHITECTURE_STATE.md",
        ROOT / "capability_conformance/README.md",
    ]
    component_readmes = sorted(ROOT.glob("*/README.md"))
    book = sorted((ROOT / "docs/linkedspec-book/src").rglob("*.md"))
    paths = sorted(
        set(fixed + component_readmes + book),
        key=lambda path: path.relative_to(ROOT).as_posix(),
    )
    missing = [path for path in paths if not path.is_file()]
    if missing:
        fail(f"public markdown path is missing: {missing[0].relative_to(ROOT)}")
    return paths


def sentence_at(source: str, start: int, end: int) -> str:
    boundaries = ("\n\n", ". ", "? ", "! ")
    left = max(source.rfind(mark, 0, start) for mark in boundaries)
    right_candidates = [
        position
        for mark in boundaries
        if (position := source.find(mark, end)) >= 0
    ]
    right = min(right_candidates) if right_candidates else len(source)
    return source[left + 1 : right + 1]


def check_exact_references(paths: list[Path]) -> int:
    reference_count = 0
    for path in paths:
        source = path.read_text(encoding="utf-8")
        relative = path.relative_to(ROOT)
        explicit_migration_bounds = (
            migration_section_bounds(source)
            if relative.as_posix() == MIGRATION_GUIDE
            else None
        )
        locations = {(match.start(), match.end()) for match in EXACT_SELECTOR.finditer(source)}
        for code in re.finditer(r"`([^`\n]+)`", source):
            locations.update(
                (code.start(1) + match.start(), code.start(1) + match.end())
                for match in CODE_SELECTOR.finditer(code.group(1))
            )
        for code in re.finditer(r"```[^\n]*\n(.*?)```", source, flags=re.DOTALL):
            locations.update(
                (code.start(1) + match.start(), code.start(1) + match.end())
                for match in CODE_SELECTOR.finditer(code.group(1))
            )
        for start, end in sorted(locations):
            reference_count += 1
            sentence = sentence_at(source, start, end)
            explicit_migration_context = bool(
                explicit_migration_bounds
                and explicit_migration_bounds[0] <= start < explicit_migration_bounds[1]
            )
            if not NEGATIVE_CONTEXT.search(sentence) and not explicit_migration_context:
                line = source.count("\n", 0, start) + 1
                fail(
                    f"{relative}:{line} presents {source[start:end]!r} without explicit "
                    "removed/rejected/migrated historical context"
                )
    return reference_count


def check_stale_status(paths: list[Path]) -> None:
    forbidden = (
        r"future-invalid",
        r"active\s+parity\s+sequence",
        r"remaining\s+backend\s+recognizers",
        r"remaining\s+backends?[^\n.]{0,120}(?:reject|retir|recogniz)",
        r"temporary\s+Perl\s+rejects",
        r"final\s+public\s+admission[^\n.]{0,100}(?:active|follows|next|remain)",
        r"\.12\.1\.9[^\n.]{0,80}(?:active|follows|next|remain)",
    )
    for path in paths:
        source = path.read_text(encoding="utf-8")
        relative = path.relative_to(ROOT)
        for pattern in forbidden:
            match = re.search(pattern, source, flags=re.IGNORECASE)
            if match:
                line = source.count("\n", 0, match.start()) + 1
                fail(f"{relative}:{line} retains stale retirement status: {match.group(0)!r}")


def require_public_anchors() -> None:
    required = {
        "ROADMAP.md": ("Uniform-binding selector retirement `.12.1` is complete",),
        "ARCHITECTURE_STATE.md": ("Aggregate-selector retirement is admitted",),
        "capability_conformance/README.md": (
            "The uniform-binding selector retirement is admitted",
        ),
        "rust/README.md": ("Bare typed bindings", "set(items, [])"),
        "dart/README.md": ("bare typed bindings", "set(items, [])"),
        "julia/README.md": ("bare typed bindings", "set(items, [])"),
        "lua/README.md": ("Bare typed bindings", "set(items, [])"),
        "docs/linkedspec-book/src/overview/project-status.md": (
            "Uniform-binding selector retirement is complete",
        ),
        "docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md": (
            "All five backends reject",
            "set(items, [])",
            "push(items, value)",
            "copy(items)",
        ),
    }
    for relative, markers in required.items():
        source = read(relative)
        missing = [marker for marker in markers if marker not in source]
        if missing:
            fail(f"{relative} is missing final-admission marker(s): {', '.join(missing)}")


def check_capability_admission() -> None:
    manifest = json.loads(read("capability_conformance/manifest.json"))
    excluded = manifest.get("excluded_or_future")
    if not isinstance(excluded, list):
        fail("capability excluded_or_future must be an array")
    ids = {entry.get("id") for entry in excluded if isinstance(entry, dict)}
    if "future.uniform_binding_selector_retirement" in ids:
        fail("capability manifest still classifies selector retirement as future")


def run_check(command: list[str], label: str) -> str:
    result = subprocess.run(
        command,
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.stderr.write(result.stderr)
        sys.stdout.write(result.stdout)
        fail(f"composed {label} check failed")
    return result.stdout.strip()


def main() -> int:
    migration_source = read(MIGRATION_GUIDE)
    try:
        validate_migration_contrasts(migration_source)
    except MigrationContrastError as error:
        fail(f"{MIGRATION_GUIDE}: {error}")
    mutation_count = check_migration_contrast_mutations(migration_source)

    paths = public_markdown_paths()
    if len(paths) != EXPECTED_PUBLIC_FILE_COUNT:
        fail(
            f"public markdown inventory has {len(paths)} files, "
            f"expected {EXPECTED_PUBLIC_FILE_COUNT}"
        )
    reference_count = check_exact_references(paths)
    if reference_count != EXPECTED_CLASSIFIED_REFERENCE_COUNT:
        fail(
            f"classified reference inventory has {reference_count} occurrences, "
            f"expected {EXPECTED_CLASSIFIED_REFERENCE_COUNT}"
        )
    check_stale_status(paths)
    require_public_anchors()
    check_capability_admission()
    concurrency = run_check(
        [
            sys.executable,
            "tools/check_executable_aggregate_selector_sources.py",
            "--concurrency-self-test",
        ],
        "aggregate-selector scanner concurrency",
    )
    aggregate = run_check(
        [sys.executable, "tools/check_aggregate_selector_retirement.py"],
        "aggregate-selector retirement",
    )
    capability = run_check(
        ["perl", "tools/check_capability_conformance.pl"],
        "capability conformance",
    )
    if concurrency:
        print(concurrency)
    if aggregate:
        print(aggregate)
    if capability:
        print(capability)
    print(
        "public-aggregate-selector-surface: OK "
        f"({len(paths)} public files; {reference_count} classified removed/history references; "
        f"0 current examples; {len(EXPECTED_MIGRATION_CONTRASTS)} migration contrasts; "
        f"{mutation_count} contrast mutations; capability admitted)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
