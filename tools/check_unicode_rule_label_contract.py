#!/usr/bin/env python3
"""Validate the pinned Unicode rule-label contract and generated artifacts."""

from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "unicode_rule_label_contract.json"
RUST_PATH = ROOT / "rust" / "linkedspec-core" / "src" / "unicode_rule_label.rs"
DART_PATH = ROOT / "dart" / "lib" / "src" / "parser" / "unicode_rule_label.dart"
DART_PARSER_PATH = ROOT / "dart" / "lib" / "src" / "parser" / "spec_parser.dart"
DART_VALIDATION_PATH = ROOT / "dart" / "lib" / "src" / "validation" / "spec_validator.dart"
SELF_HOSTED_REGEX_PATH = ROOT / "unicode_case" / "unicode_rule_label_regex_class.txt"
SELF_HOSTED_GRAMMAR_PATH = ROOT / "specs" / "spec.spec"
SELF_HOSTED_CLI_MANIFEST_PATH = (
    ROOT / "unicode_case" / "self_hosted_cli" / "manifest.json"
)
GENERATOR = ROOT / "unicode_case" / "generate_unicode_rule_label_contract.py"
FORMAL_GRAMMAR = ROOT / "docs" / "linkedspec-book" / "src" / "appendix" / "formal-grammar.md"
PARSER_PATH = ROOT / "rust" / "linkedspec-core" / "src" / "parser.rs"
VALIDATION_PATH = ROOT / "rust" / "linkedspec-core" / "src" / "validation.rs"
CORE_TEST_PATH = ROOT / "rust" / "linkedspec-core" / "tests" / "unicode_rule_label_contract.rs"
RUNTIME_TEST_PATH = (
    ROOT / "rust" / "linkedspec-runtime" / "tests" / "unicode_rule_label_routes.rs"
)
RUST_ENGINE_PATH = ROOT / "rust" / "linkedspec-runtime" / "src" / "engine.rs"
DART_SELF_HOSTED_TEST_PATH = (
    ROOT / "dart" / "test" / "self_hosted_unicode_rule_label_test.dart"
)
DART_CLASSIFIER_TEST_PATH = (
    ROOT / "dart" / "test" / "unicode_rule_label_classifier_test.dart"
)
DART_NATIVE_ROUTES_TEST_PATH = (
    ROOT / "dart" / "test" / "unicode_rule_label_routes_test.dart"
)
DART_IDENTITY_ROUTES_TEST_PATH = (
    ROOT / "dart" / "test" / "unicode_rule_label_identity_routes_test.dart"
)
DART_NEGATIVE_ISOLATION_TEST_PATH = (
    ROOT / "dart" / "test" / "unicode_rule_label_negative_isolation_test.dart"
)
MATRIX_DRIVER_PATH = ROOT / "tools" / "run_primary_cli_matrix.sh"
CI_PATH = ROOT / "tools" / "run_ci_local.sh"
SELF_HOSTED_CORPUS_CASES = (
    "spec_spec_minimal_rule",
    "spec_spec_action_edge",
    "spec_spec_user_function_definition",
    "spec_spec_comment_skip",
)
CORPUS_ROOT = ROOT / "rust" / "linkedspec-runtime" / "tests" / "corpus"


def fail(message: str) -> None:
    raise SystemExit(f"unicode-rule-label-contract: ERROR: {message}")


def contains(ranges: list[tuple[int, int]], codepoint: int) -> bool:
    low, high = 0, len(ranges)
    while low < high:
        middle = (low + high) // 2
        start, end = ranges[middle]
        if codepoint < start:
            high = middle
        elif codepoint > end:
            low = middle + 1
        else:
            return True
    return False


def valid_label(ranges: list[tuple[int, int]], label: str) -> bool:
    return bool(label) and all(contains(ranges, ord(character)) for character in label)


def render_self_hosted_regex_class(ranges: list[tuple[int, int]]) -> str:
    pieces: list[str] = []
    for start, end in ranges:
        pieces.append(chr(start))
        if start != end:
            pieces.extend(("-", chr(end)))
    return "[" + "".join(pieces) + "]+"


def main() -> None:
    for path in (
        CONTRACT_PATH,
        RUST_PATH,
        DART_PATH,
        DART_PARSER_PATH,
        DART_VALIDATION_PATH,
        SELF_HOSTED_REGEX_PATH,
        SELF_HOSTED_GRAMMAR_PATH,
        SELF_HOSTED_CLI_MANIFEST_PATH,
        GENERATOR,
        CORE_TEST_PATH,
        RUNTIME_TEST_PATH,
        RUST_ENGINE_PATH,
        DART_SELF_HOSTED_TEST_PATH,
        DART_CLASSIFIER_TEST_PATH,
        DART_NATIVE_ROUTES_TEST_PATH,
        DART_IDENTITY_ROUTES_TEST_PATH,
        DART_NEGATIVE_ISOLATION_TEST_PATH,
        MATRIX_DRIVER_PATH,
        *(CORPUS_ROOT / case / "input.spec" for case in SELF_HOSTED_CORPUS_CASES),
    ):
        if not path.is_file():
            fail(f"missing {path.relative_to(ROOT)}")
    with tempfile.TemporaryDirectory(prefix="linkedspec-unicode-label-") as temp:
        generated_contract = Path(temp) / "contract.json"
        generated_rust = Path(temp) / "unicode_rule_label.rs"
        generated_dart = Path(temp) / "unicode_rule_label.dart"
        generated_self_hosted_regex = Path(temp) / "unicode_rule_label_regex_class.txt"
        subprocess.run(
            [
                sys.executable,
                str(GENERATOR),
                "--contract-output",
                str(generated_contract),
                "--rust-output",
                str(generated_rust),
                "--self-hosted-regex-output",
                str(generated_self_hosted_regex),
                "--dart-output",
                str(generated_dart),
            ],
            cwd=ROOT,
            check=True,
        )
        if generated_contract.read_bytes() != CONTRACT_PATH.read_bytes():
            fail("contract differs from deterministic regeneration")
        if generated_rust.read_bytes() != RUST_PATH.read_bytes():
            fail("Rust classifier differs from deterministic regeneration")
        if generated_dart.read_bytes() != DART_PATH.read_bytes():
            fail("Dart classifier differs from deterministic regeneration")
        if generated_self_hosted_regex.read_bytes() != SELF_HOSTED_REGEX_PATH.read_bytes():
            fail("self-hosted regex class differs from deterministic regeneration")

    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    expected_top = {
        "schema_version",
        "contract_id",
        "task_owner",
        "decision",
        "unicode_version",
        "policy",
        "sources",
        "data_sha256",
        "counts",
        "xid_continue_ranges",
        "positive_fixtures",
        "negative_fixtures",
        "distinct_fixtures",
    }
    if set(contract) != expected_top:
        fail("top-level fields drifted")
    if contract["contract_id"] != "linkedspec-unicode-rule-label-v1":
        fail("contract identity drifted")
    if contract["unicode_version"] != "17.0.0":
        fail("Unicode version drifted")
    if contract["policy"] != {
        "property": "XID_Continue",
        "positions": "one_or_more_same_class_including_first",
        "identity": "exact_unicode_scalar_sequence",
        "case_sensitive": True,
        "normalization": "none",
        "case_mapping": "none",
        "encoding_boundary": "strict_utf8",
    }:
        fail("label policy drifted")

    ranges: list[tuple[int, int]] = []
    prior_end = -2
    for index, row in enumerate(contract["xid_continue_ranges"]):
        if not isinstance(row, list) or len(row) != 2:
            fail(f"range {index} shape drifted")
        start, end = (int(value, 16) for value in row)
        if start > end or start <= prior_end + 1 or end > 0x10FFFF:
            fail(f"range {index} is not sorted, disjoint, and maximally merged")
        ranges.append((start, end))
        prior_end = end
    counts = contract["counts"]
    if counts["xid_continue_ranges"] != len(ranges):
        fail("range count drifted")

    dart_text = DART_PATH.read_text(encoding="utf-8")
    dart_ranges = [
        (int(start, 16), int(end, 16))
        for start, end in re.findall(
            r"_RuleLabelRange\(0x([0-9A-F]{4,6}), 0x([0-9A-F]{4,6})\)",
            dart_text,
        )
    ]
    if dart_ranges != ranges:
        fail("Dart range table does not independently encode the contract ranges")
    for marker in (
        f"const int unicodeRuleLabelRangeCount = {len(ranges)};",
        "while (low < high)",
        "for (final codePoint in label.runes)",
        "endCodeUnit += codePoint > 0xFFFF ? 2 : 1;",
        "RuleLabelPrefix? takeRuleLabelPrefix(String input)",
    ):
        if marker not in dart_text:
            fail(f"Dart classifier/scanner topology marker missing: {marker}")
    for unsafe in ("\\", "/", "[", "]", "^", "-", "\n", "\r", "\0"):
        if contains(ranges, ord(unsafe)):
            fail(f"self-hosted literal regex class requires escaping for {unsafe!r}")

    expected_class = render_self_hosted_regex_class(ranges)
    expected_artifact = (
        "# Generated pinned Unicode rule-label regex class. Do not edit by hand.\n"
        f"# contract: {contract['contract_id']}\n"
        f"# unicode: {contract['unicode_version']}\n"
        f"# data-sha256: {contract['data_sha256']}\n"
        f"{expected_class}\n"
    )
    actual_artifact = SELF_HOSTED_REGEX_PATH.read_text(encoding="utf-8", errors="strict")
    if actual_artifact != expected_artifact:
        fail("self-hosted regex artifact does not independently encode the contract ranges")
    self_hosted_grammar = SELF_HOSTED_GRAMMAR_PATH.read_text(
        encoding="utf-8", errors="strict"
    )
    canonical_grammar_bytes = SELF_HOSTED_GRAMMAR_PATH.read_bytes()
    canonical_grammar_sha256 = hashlib.sha256(canonical_grammar_bytes).hexdigest()
    for case in SELF_HOSTED_CORPUS_CASES:
        corpus_path = CORPUS_ROOT / case / "input.spec"
        corpus_bytes = corpus_path.read_bytes()
        if corpus_bytes != canonical_grammar_bytes:
            corpus_sha256 = hashlib.sha256(corpus_bytes).hexdigest()
            fail(
                f"{corpus_path.relative_to(ROOT)} is stale: sha256 "
                f"{corpus_sha256}, expected canonical {canonical_grammar_sha256}"
            )
    expected_label_sites = {
        "rule_header": 1,
        "action_block": 2,
        "action_fluent": 1,
        "action_bare": 1,
        "blind_block": 1,
        "blind_fluent": 1,
        "blind_bare": 1,
        "bare_edge_block": 2,
        "bare_edge_fluent": 1,
        "bare_edge_plain": 1,
    }
    grammar_lines = {
        line.split(":", 1)[0]: line
        for line in self_hosted_grammar.splitlines()
        if ": /" in line
    }
    for production, expected_count in expected_label_sites.items():
        line = grammar_lines.get(production)
        if line is None:
            fail(f"self-hosted label production is missing: {production}")
        if line.count(expected_class) != expected_count:
            fail(
                f"self-hosted label production {production} does not consume "
                f"the generated class exactly {expected_count} time(s)"
            )
    if self_hosted_grammar.count(expected_class) != sum(expected_label_sites.values()):
        fail("self-hosted grammar has an unexpected generated label-class site")
    required_boundaries = {
        "rule_header": ("rule_header: /(?m:^[ \\t]*", "(?!:))/"),
        "action_bare": ("action_bare: /(?m:^[ \\t]*->", "[ \\t]*(?=\\r?$))/"),
        "blind_bare": ("blind_bare: /(?m:^[ \\t]*=>", "[ \\t]*(?=\\r?$))/"),
    }
    for production, (prefix, suffix) in required_boundaries.items():
        line = grammar_lines[production]
        if not line.startswith(prefix) or not line.endswith(suffix):
            fail(f"self-hosted label production {production} lost its physical-line boundary")
    compiled_class = re.compile(rf"^(?:{expected_class})$")
    for row in contract["positive_fixtures"]:
        if not valid_label(ranges, row["label"]):
            fail(f"positive fixture rejected: {row['id']}")
        if compiled_class.fullmatch(row["label"]) is None:
            fail(f"self-hosted regex rejects positive fixture: {row['id']}")
    for row in contract["negative_fixtures"]:
        if valid_label(ranges, row["label"]):
            fail(f"negative fixture accepted: {row['id']}")
        if compiled_class.fullmatch(row["label"]) is not None:
            fail(f"self-hosted regex accepts negative fixture: {row['id']}")
    for row in contract["distinct_fixtures"]:
        if not valid_label(ranges, row["left"]) or not valid_label(ranges, row["right"]):
            fail(f"distinct fixture is not valid: {row['id']}")
        if row["left"] == row["right"]:
            fail(f"distinct fixture collapsed: {row['id']}")
        if compiled_class.fullmatch(row["left"]) is None or compiled_class.fullmatch(row["right"]) is None:
            fail(f"self-hosted regex rejects distinct fixture: {row['id']}")

    cli_manifest = json.loads(SELF_HOSTED_CLI_MANIFEST_PATH.read_text(encoding="utf-8"))
    if set(cli_manifest) != {"schema_version", "suite", "cases"}:
        fail("self-hosted CLI manifest fields drifted")
    if cli_manifest["schema_version"] != 1:
        fail("self-hosted CLI manifest schema drifted")
    if cli_manifest["suite"] != "linkedspec-self-hosted-unicode-rule-labels":
        fail("self-hosted CLI manifest suite identity drifted")
    cases = cli_manifest["cases"]
    if not isinstance(cases, list) or len(cases) != 1:
        fail("self-hosted CLI manifest must compose exactly one bounded compile case")
    case = cases[0]
    if case.get("id") != "current_grammar_unicode_contract":
        fail("self-hosted CLI case identity drifted")
    expected_args = [
        "--spec-file",
        "{{REPO_ROOT}}/specs/spec.spec",
        "--top-rule",
        "spec_file",
        "--input",
    ]
    args = case.get("args")
    if not isinstance(args, list) or args[:5] != expected_args or len(args) != 6:
        fail("self-hosted CLI case does not execute canonical specs/spec.spec via spec_file")
    fixture_input = args[5]
    if not isinstance(fixture_input, str):
        fail("self-hosted CLI case input must be text")
    for row in contract["positive_fixtures"]:
        if f" -> {row['label']}\n" not in fixture_input:
            fail(f"self-hosted CLI case omits positive fixture: {row['id']}")
    for row in contract["distinct_fixtures"]:
        for side in ("left", "right"):
            if f" -> {row[side]}\n" not in fixture_input:
                fail(f"self-hosted CLI case omits {side} distinct fixture: {row['id']}")
    negative_by_id = {row["id"]: row["label"] for row in contract["negative_fixtures"]}
    for fixture_id in ("empty", "hyphen", "space", "emoji", "colon", "dollar"):
        label = negative_by_id[fixture_id]
        for arrow in ("->", "=>"):
            if f" {arrow} {label}\n" not in fixture_input:
                fail(f"self-hosted CLI case omits {arrow} negative fixture: {fixture_id}")
    for fixture_id in ("hyphen", "space", "emoji", "colon", "dollar", "slash"):
        if f"{negative_by_id[fixture_id]}::\n" not in fixture_input:
            fail(f"self-hosted CLI case omits header negative fixture: {fixture_id}")
    newline_label = negative_by_id["newline"]
    if f" -> {newline_label}\n" not in fixture_input or f" => {newline_label}\n" not in fixture_input:
        fail("self-hosted CLI case omits physical newline splitting fixture")

    expected = case.get("expect")
    if not isinstance(expected, dict) or expected.get("exit") != 0:
        fail("self-hosted CLI case must expect successful exact projection")
    if expected.get("stderr") != {"text": ""} or expected.get("files") != []:
        fail("self-hosted CLI case stderr/file contract drifted")
    stdout = expected.get("stdout")
    if not isinstance(stdout, dict) or set(stdout) != {"text"}:
        fail("self-hosted CLI case stdout contract drifted")
    stdout_text = stdout["text"]
    if not isinstance(stdout_text, str) or not stdout_text.endswith("\n"):
        fail("self-hosted CLI case stdout must be one newline-terminated JSON value")
    try:
        projected = json.loads(stdout_text)
    except json.JSONDecodeError as error:
        fail(f"self-hosted CLI expected stdout is not JSON: {error}")
    if not isinstance(projected, list) or len(projected) != 1 or not isinstance(projected[0], list):
        fail("self-hosted CLI expected projection paragraph shape drifted")
    nodes = projected[0]
    expected_targets = [row["label"] for row in contract["positive_fixtures"]]
    expected_targets.append(
        next(row["right"] for row in contract["distinct_fixtures"] if row["id"] == "case_sensitive")
    )
    expected_targets.extend(["Top", "Rule", "Top", "Rule"])
    actual_targets = [node["target"] for node in nodes if isinstance(node, dict) and "target" in node]
    if actual_targets != expected_targets:
        fail("self-hosted CLI expected projection lost exact label identity or boundary order")

    matrix_driver = MATRIX_DRIVER_PATH.read_text(encoding="utf-8")
    for marker in (
        "--manifest)",
        'MANIFEST_ARGS=(--manifest "$2")',
        '"${MANIFEST_ARGS[@]}" "${CASE_ARGS[@]}"',
    ):
        if marker not in matrix_driver:
            fail(f"five-backend matrix manifest routing marker missing: {marker}")

    formal = FORMAL_GRAMMAR.read_text(encoding="utf-8")
    required_formal = [
        "Unicode 17.0.0 `XID_Continue`",
        "case-sensitive and normalization-sensitive",
        "No normalization or case folding is performed",
        "The self-hosted structural tokens also own exact physical-line boundaries",
        "Perl, Rust, Dart, Julia, and Lua now execute one byte-exact",
    ]
    if any(marker not in formal for marker in required_formal):
        fail("formal grammar is not synchronized")
    parser_text = PARSER_PATH.read_text(encoding="utf-8")
    validation_text = VALIDATION_PATH.read_text(encoding="utf-8")
    if "take_rule_label_prefix" not in parser_text or "is_rule_label" not in validation_text:
        fail("Rust parser/validator does not consume the generated label classifier")
    for stale in (
        'r"^(\\w+)[ \\t]*(::|:)"',
        'r"^->[ \\t]*(\\w+)',
        'r"^=>[ \\t]*(\\w+)"',
    ):
        if stale in parser_text:
            fail(f"stale Rust label regex remains: {stale}")
    core_test = CORE_TEST_PATH.read_text(encoding="utf-8")
    for marker in (
        "parser_uses_one_unicode_label_class_for_headers_and_all_edge_forms",
        "validator_rejects_invalid_labels_in_programmatic_asts",
        "exact_scalar_identity_survives_validation_and_compilation",
    ):
        if marker not in core_test:
            fail(f"core route proof missing: {marker}")
    runtime_test = RUNTIME_TEST_PATH.read_text(encoding="utf-8")
    for marker in (
        "native_selector_descriptor_and_trace_keep_exact_scalar_identity",
        "generated_plan_and_emitted_source_keep_unicode_labels_exact",
        "strict_file_loader_accepts_unicode_and_rejects_invalid_utf8_before_parsing",
    ):
        if marker not in runtime_test:
            fail(f"runtime route proof missing: {marker}")
    rust_engine = RUST_ENGINE_PATH.read_text(encoding="utf-8")
    for marker in (
        "helpers_5_2_absent_entry_group_is_undef",
        '.map(RuntimeValue::Scalar)\n                        .unwrap_or(RuntimeValue::Undef)',
    ):
        if marker not in rust_engine:
            fail(f"Rust absent entry-group parity marker missing: {marker}")
    dart_test = DART_SELF_HOSTED_TEST_PATH.read_text(encoding="utf-8")
    for marker in (
        "canonical grammar consumes the exact generated label atom",
        "runtime regex enables Unicode mode for supplementary label ranges",
        "current canonical grammar executes every Unicode label edge form",
    ):
        if marker not in dart_test:
            fail(f"Dart self-hosted route proof missing: {marker}")
    dart_classifier_test = DART_CLASSIFIER_TEST_PATH.read_text(encoding="utf-8")
    for marker in (
        "generated metadata and all range boundaries match the contract",
        "complete-label validation matches every neutral fixture",
        "longest-prefix scanning preserves scalar and UTF-16 boundaries",
    ):
        if marker not in dart_classifier_test:
            fail(f"Dart classifier proof missing: {marker}")
    dart_parser = DART_PARSER_PATH.read_text(encoding="utf-8")
    for marker in (
        "import 'unicode_rule_label.dart';",
        "_parseRuleHeaderFields",
        "_parseActionEdgePrefix",
        "_parseBlindEdgePrefix",
        "_parseBareEdgePrefix",
        "takeRuleLabelPrefix",
        "_startsWithEdgeToken",
    ):
        if marker not in dart_parser:
            fail(f"Dart native label scanner marker missing: {marker}")
    for stale in (
        "final _headerPattern = RegExp(r'^(\\w+)",
        "final _bodyHeaderPattern = RegExp(r'^\\w+",
        "r'^->[ \\t]*(\\w+",
        "r'^=>[ \\t]*(\\w+",
        "r'^(\\w+(?:[ \\t]*\\|",
    ):
        if stale in dart_parser:
            fail(f"stale Dart host-regex label scanner remains: {stale}")
    dart_validation = DART_VALIDATION_PATH.read_text(encoding="utf-8")
    for marker in (
        "import '../parser/unicode_rule_label.dart';",
        "_checkRuleLabels(spec)",
        "isRuleLabel(rule.header.label)",
        "isRuleLabel(target)",
        "invalid_rule_label",
        "validate_rule_labels",
    ):
        if marker not in dart_validation:
            fail(f"Dart rule-label validation marker missing: {marker}")
    dart_native_routes_test = DART_NATIVE_ROUTES_TEST_PATH.read_text(encoding="utf-8")
    for marker in (
        "scanner parses every declaration and edge form with exact identity",
        "invalid suffixes never become partial action blind or bare edges",
        "validator rejects every programmatic declaration and target role",
        "validator rejects invalid labels reconstructed from AST JSON",
    ):
        if marker not in dart_native_routes_test:
            fail(f"Dart native route proof missing: {marker}")
    dart_identity_routes_test = DART_IDENTITY_ROUTES_TEST_PATH.read_text(
        encoding="utf-8"
    )
    for marker in (
        "every positive and distinct label survives compiled artifacts",
        "emitted source reconstructs and executes every exact label",
        "strict loading and primary commands preserve every exact label",
        "selectors diagnostics and traces retain exact Unicode identity",
        "_contract['positive_fixtures']",
        "_contract['distinct_fixtures']",
        "emitDartSourceV2",
        "loadAndCompileSpec",
        "runLinkedSpecDartPrimaryCli",
        "executeGeneratedParserWithTraceV2",
    ):
        if marker not in dart_identity_routes_test:
            fail(f"Dart exact-identity route proof missing: {marker}")
    dart_negative_isolation_test = DART_NEGATIVE_ISOLATION_TEST_PATH.read_text(
        encoding="utf-8"
    )
    for marker in (
        "every negative label fails every external AST trust route",
        "source surfaces reject whole invalid tokens without truncation",
        "no-prefix surfaces never recover a suffix and newline splits tokens",
        "primary commands reject every negative declaration deterministically",
        "unrelated identifier grammars retain their existing boundaries",
        "_contract['negative_fixtures']",
        "ActionEdgeBodyElementKind",
        "BlindEdgeBodyElementKind",
        "BareEdgeBodyElementKind",
        "parseActionExpression",
        "lifecycleMarkers",
        "mark_here(shared_9)",
    ):
        if marker not in dart_negative_isolation_test:
            fail(f"Dart negative/isolation proof missing: {marker}")
    ci_text = CI_PATH.read_text(encoding="utf-8")
    for marker in (
        "require_tracked_file capability_conformance/unicode_rule_label_contract.json",
        "require_tracked_file tools/check_unicode_rule_label_contract.py",
        "require_tracked_file unicode_case/generate_unicode_rule_label_contract.py",
        "require_tracked_file unicode_case/unicode_rule_label_regex_class.txt",
        "require_tracked_file rust/linkedspec-core/src/unicode_rule_label.rs",
        "require_tracked_file rust/linkedspec-core/tests/unicode_rule_label_contract.rs",
        "require_tracked_file rust/linkedspec-runtime/tests/unicode_rule_label_routes.rs",
        "require_tracked_file dart/test/self_hosted_unicode_rule_label_test.dart",
        "require_tracked_file dart/lib/src/parser/unicode_rule_label.dart",
        "require_tracked_file dart/test/unicode_rule_label_classifier_test.dart",
        "require_tracked_file dart/test/unicode_rule_label_routes_test.dart",
        "require_tracked_file dart/test/unicode_rule_label_identity_routes_test.dart",
        "require_tracked_file dart/test/unicode_rule_label_negative_isolation_test.dart",
        "require_tracked_file unicode_case/self_hosted_cli/manifest.json",
        "python3 tools/check_unicode_rule_label_contract.py",
        "bash \"$REPO_ROOT/tools/run_primary_cli_matrix.sh\" --manifest unicode_case/self_hosted_cli/manifest.json",
    ):
        if marker not in ci_text:
            fail(f"canonical CI marker missing: {marker}")

    print(
        "unicode-rule-label-contract: OK "
        f"(Unicode {contract['unicode_version']}; {len(ranges)} XID_Continue ranges; "
        f"{len(contract['positive_fixtures'])} positive; "
        f"{len(contract['negative_fixtures'])} negative; "
        f"{len(contract['distinct_fixtures'])} distinct pairs)"
    )


if __name__ == "__main__":
    main()
