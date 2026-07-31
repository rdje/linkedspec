#!/usr/bin/env python3
"""Validate native MCP implementation/runtime admission status and topology."""

from __future__ import annotations

import copy
import hashlib
import json
import re
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
LEDGER_PATH = ROOT / "capability_conformance" / "mcp_implementation_admission.json"
TRANSPORT_PATH = ROOT / "capability_conformance" / "mcp_semantic_transport_contract.json"
SEMANTIC_PATH = ROOT / "capability_conformance" / "semantic_introspection_contract.json"
SEMANTIC_CHECKER_PATH = ROOT / "tools" / "check_semantic_introspection_contract.py"
CI_PATH = ROOT / "tools" / "run_ci_local.sh"
RECURRING_PATH = ROOT / "tools" / "check_mcp_six_runtime.sh"
CONTRACT_ID = "linkedspec-mcp-implementation-admission-v1"
TRANSPORT_ID = "linkedspec-mcp-transport-v1"
TASK_OWNER = "FUTURE-PARITY-BACKLOG.10.9.2.3"
TRANSPORT_SHA256 = "e068519994a7d4fb8e4c8ece0e277a470f48204d4c670f915ba49052a52630b3"

ROLES = [
    "contract_inventory",
    "canonical_static_dispatch",
    "native_capabilities_identity",
    "native_query_identity",
    "raw_input_outcomes",
    "lifecycle_outcomes",
    "handle_state_indistinguishability",
    "policy_overlay",
    "cancellation_emission",
    "shutdown_and_io",
    "hostile_output_and_log_privacy",
    "authority_surface_fences",
]

IMPLEMENTATIONS = [
    {
        "backend": "perl",
        "server_name": "linkedspec-semantic-perl",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.2",
        "source_paths": [
            "perl/LinkedSpec/MCPContract.pm",
            "perl/LinkedSpec/MCPContractRuntime.pm",
            "perl/LinkedSpec/MCPServer.pm",
            "perl/LinkedSpec/MCPWire.pm",
        ],
        "runtime_admissions": ["perl"],
    },
    {
        "backend": "rust",
        "server_name": "linkedspec-semantic-rust",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.3",
        "source_paths": [
            "rust/linkedspec-runtime/src/mcp_contract.rs",
            "rust/linkedspec-runtime/src/mcp_contract_runtime.rs",
            "rust/linkedspec-runtime/src/mcp_server.rs",
            "rust/linkedspec-runtime/src/mcp_wire.rs",
        ],
        "runtime_admissions": ["rust"],
    },
    {
        "backend": "dart",
        "server_name": "linkedspec-semantic-dart",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.4",
        "source_paths": [
            "dart/lib/src/mcp/mcp_contract.dart",
            "dart/lib/src/mcp/mcp_contract_runtime.dart",
            "dart/lib/src/mcp/mcp_server.dart",
            "dart/lib/src/mcp/mcp_wire.dart",
        ],
        "runtime_admissions": ["dart"],
    },
    {
        "backend": "julia",
        "server_name": "linkedspec-semantic-julia",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.5",
        "source_paths": [
            "julia/src/mcp/McpContract.jl",
            "julia/src/mcp/McpContractRuntime.jl",
            "julia/src/mcp/McpServer.jl",
            "julia/src/mcp/McpWire.jl",
        ],
        "runtime_admissions": ["julia"],
    },
    {
        "backend": "lua",
        "server_name": "linkedspec-semantic-lua",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.6",
        "source_paths": [
            "lua/src/linkedspec/mcp_contract.lua",
            "lua/src/linkedspec/mcp_contract_runtime.lua",
            "lua/src/linkedspec/mcp_server.lua",
            "lua/src/linkedspec/mcp_wire.lua",
        ],
        "runtime_admissions": ["puc_lua", "luajit"],
    },
]

RUNTIME_ADMISSIONS = [
    {
        "backend": "perl",
        "runtime": "perl",
        "status": "complete",
        "owner": TASK_OWNER,
        "consumer_path": "t/mcp_server_perl_admission.t",
    },
    {
        "backend": "rust",
        "runtime": "rust",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.3.3",
        "consumer_path": "rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs",
    },
    {
        "backend": "dart",
        "runtime": "dart",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.4.3",
        "consumer_path": "dart/test/mcp_server_dart_admission_test.dart",
    },
    {
        "backend": "julia",
        "runtime": "julia",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.5.3",
        "consumer_path": "julia/test/mcp_server_julia_admission_test.jl",
    },
    {
        "backend": "lua",
        "runtime": "puc_lua",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.6.3",
        "consumer_path": "lua/test/mcp_server_lua_admission_test.lua",
    },
    {
        "backend": "lua",
        "runtime": "luajit",
        "status": "complete",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.6.3",
        "consumer_path": "lua/test/mcp_server_lua_admission_test.lua",
    },
]

JULIA_OWNERS = {
    "generator": "tools/generate_julia_mcp_contract.py",
    "source_paths": [
        "julia/src/mcp/McpContract.jl",
        "julia/src/mcp/McpContractRuntime.jl",
        "julia/src/mcp/McpServer.jl",
        "julia/src/mcp/McpWire.jl",
    ],
    "test_paths": [
        "julia/test/mcp_contract_julia_binding_test.jl",
        "julia/test/mcp_server_julia_dispatch_test.jl",
        "julia/test/mcp_server_julia_stdio_test.jl",
        "julia/test/mcp_server_julia_admission_test.jl",
    ],
}

LUA_OWNERS = {
    "generator": "tools/generate_lua_mcp_contract.py",
    "source_paths": [
        "lua/src/linkedspec/mcp_contract.lua",
        "lua/src/linkedspec/mcp_contract_runtime.lua",
        "lua/src/linkedspec/mcp_server.lua",
        "lua/src/linkedspec/mcp_wire.lua",
        "lua/native/mcp_system.c",
    ],
    "test_paths": [
        "lua/test/mcp_contract_lua_binding_test.lua",
        "lua/test/mcp_server_lua_dispatch_test.lua",
        "lua/test/mcp_server_lua_stdio_test.lua",
        "lua/test/mcp_server_lua_admission_test.lua",
    ],
}

LUA_GENERATOR_COMMAND = (
    "bash tools/run_python_project_data.sh tools/generate_lua_mcp_contract.py"
)

ORDERED_COMMANDS = [
    "bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py",
    "bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py",
    "bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py",
    "bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py",
    "bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py",
    "bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py",
    LUA_GENERATOR_COMMAND,
    "PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib mcp_",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_dispatch",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_stdio",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_admission",
    "bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart test/mcp_server_dart_stdio_test.dart",
    "bash ../tools/run_dart_project_data.sh test test/mcp_server_dart_admission_test.dart",
    "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include(\"julia/test/mcp_contract_julia_binding_test.jl\"); include(\"julia/test/mcp_server_julia_dispatch_test.jl\"); include(\"julia/test/mcp_server_julia_stdio_test.jl\")'",
    "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include(\"julia/test/mcp_server_julia_admission_test.jl\")'",
    "bash tools/run_lua_project_data.sh puc lua/test/mcp_server_lua_admission_test.lua",
    "bash tools/run_lua_project_data.sh luajit lua/test/mcp_server_lua_admission_test.lua",
    "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py",
    "PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t",
]

ROLLOUT_OWNER = "FUTURE-PARITY-BACKLOG.10.9.7.1"
RECURRING_GATE = {
    "driver": "tools/check_mcp_six_runtime.sh",
    "preflight_commands": [
        "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py",
        "bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py",
        "bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py",
        "bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py",
        "bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py",
        "bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py",
        "bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py",
        LUA_GENERATOR_COMMAND,
    ],
    "consumer_schema": {
        "fields": ["backend", "runtime", "consumer_path", "command"],
        "role_policy": "each admitted all-twenty direct/MCP identity consumer runs once; the shared Lua source runs once per ABI",
    },
    "consumers": [
        {
            "backend": "perl",
            "runtime": "perl",
            "consumer_path": RUNTIME_ADMISSIONS[0]["consumer_path"],
            "command": "PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t",
        },
        {
            "backend": "rust",
            "runtime": "rust",
            "consumer_path": RUNTIME_ADMISSIONS[1]["consumer_path"],
            "command": "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_admission",
        },
        {
            "backend": "dart",
            "runtime": "dart",
            "consumer_path": RUNTIME_ADMISSIONS[2]["consumer_path"],
            "command": "cd dart && bash ../tools/run_dart_project_data.sh test test/mcp_server_dart_admission_test.dart",
        },
        {
            "backend": "julia",
            "runtime": "julia",
            "consumer_path": RUNTIME_ADMISSIONS[3]["consumer_path"],
            "command": "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include(\"julia/test/mcp_server_julia_admission_test.jl\")'",
        },
        {
            "backend": "lua",
            "runtime": "puc_lua",
            "consumer_path": RUNTIME_ADMISSIONS[4]["consumer_path"],
            "command": "bash tools/run_lua_project_data.sh puc lua/test/mcp_server_lua_admission_test.lua",
        },
        {
            "backend": "lua",
            "runtime": "luajit",
            "consumer_path": RUNTIME_ADMISSIONS[5]["consumer_path"],
            "command": "bash tools/run_lua_project_data.sh luajit lua/test/mcp_server_lua_admission_test.lua",
        },
    ],
    "postflight_commands": [
        "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py",
    ],
    "primary_cli": {
        "matrix_driver": "tools/run_primary_cli_matrix.sh",
        "case_ids": [
            "success_named_source_literal_input",
            "failure_compile_precedes_input_load",
            "trace_failure_invoke_route_low",
        ],
        "backend_count": 5,
        "environments": ["default", "posix"],
        "policy": "thin MCP transport adds no primary CLI surface; success, compile failure, and traced invocation failure stay exact",
    },
    "local_ci": {
        "driver": "tools/run_ci_local.sh",
        "switch": "LINKEDSPEC_RUN_MCP_MATRIX",
    },
}


class CheckError(RuntimeError):
    """One status-ledger invariant failed."""


def fail(message: str) -> None:
    raise CheckError(message)


def strict_object(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            fail(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=strict_object)
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        fail(f"cannot read strict JSON {path.relative_to(ROOT)}: {error}")
    if not isinstance(value, dict):
        fail(f"expected a JSON object: {path.relative_to(ROOT)}")
    return value


def exact_fields(value: Any, fields: set[str], label: str) -> None:
    if not isinstance(value, dict) or set(value) != fields:
        fail(f"{label} fields drifted")


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate_ci_source(source: str, ordered_commands: list[str]) -> None:
    positions: list[int] = []
    for command in ordered_commands:
        if source.count(command) != 1:
            fail(f"canonical command must occur exactly once: {command}")
        positions.append(source.index(command))
    if positions != sorted(positions):
        fail("canonical MCP commands are out of order")
    required = [
        "require_tracked_file capability_conformance/mcp_implementation_admission.json",
        "require_tracked_file tools/check_mcp_implementation_admission.py",
        "require_tracked_file tools/generate_dart_mcp_contract.py",
        "require_tracked_file tools/generate_julia_mcp_contract.py",
        "require_tracked_file tools/generate_lua_mcp_contract.py",
        "require_tracked_file t/mcp_server_perl_admission.t",
        "require_tracked_file rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs",
        "require_tracked_file dart/lib/src/mcp/mcp_contract.dart",
        "require_tracked_file dart/lib/src/mcp/mcp_contract_runtime.dart",
        "require_tracked_file dart/lib/src/mcp/mcp_server.dart",
        "require_tracked_file dart/lib/src/mcp/mcp_wire.dart",
        "require_tracked_file dart/test/mcp_contract_dart_binding_test.dart",
        "require_tracked_file dart/test/mcp_server_dart_dispatch_test.dart",
        "require_tracked_file dart/test/mcp_server_dart_stdio_test.dart",
        "require_tracked_file dart/test/mcp_server_dart_admission_test.dart",
        "require_tracked_file julia/src/mcp/McpContract.jl",
        "require_tracked_file julia/src/mcp/McpContractRuntime.jl",
        "require_tracked_file julia/src/mcp/McpServer.jl",
        "require_tracked_file julia/src/mcp/McpWire.jl",
        "require_tracked_file julia/test/mcp_contract_julia_binding_test.jl",
        "require_tracked_file julia/test/mcp_server_julia_dispatch_test.jl",
        "require_tracked_file julia/test/mcp_server_julia_stdio_test.jl",
        "require_tracked_file julia/test/mcp_server_julia_admission_test.jl",
        "require_tracked_file lua/native/mcp_system.c",
        "require_tracked_file lua/src/linkedspec/mcp_contract.lua",
        "require_tracked_file lua/src/linkedspec/mcp_contract_runtime.lua",
        "require_tracked_file lua/src/linkedspec/mcp_server.lua",
        "require_tracked_file lua/src/linkedspec/mcp_wire.lua",
        "require_tracked_file lua/test/mcp_contract_lua_binding_test.lua",
        "require_tracked_file lua/test/mcp_server_lua_dispatch_test.lua",
        "require_tracked_file lua/test/mcp_server_lua_stdio_test.lua",
        "require_tracked_file lua/test/mcp_server_lua_admission_test.lua",
        "perl -c -Iperl t/mcp_server_perl_admission.t",
    ]
    for line in required:
        if source.count(line) != 1:
            fail(f"canonical tracked/syntax registration drifted: {line}")


def validate_recurring_gate_source(gate: dict[str, Any], source: str, ci_source: str) -> None:
    if gate != RECURRING_GATE:
        fail("recurring MCP six-runtime topology drifted")
    if (
        'source "$REPO_ROOT/tools/project_data_env.sh"' not in source
        or 'linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_mcp_six_runtime.sh" "$@"'
        not in source
    ):
        fail("recurring MCP driver is not repository-routed")
    for marker in [
        'TASK_ARTIFACT_ROOT=$(mktemp -d "${TMPDIR:',
        'export CARGO_TARGET_DIR="$RUST_TARGET_ROOT"',
        'export JULIA_DEPOT_PATH="$JULIA_WRITE_DEPOT:$JULIA_READ_DEPOTS"',
        "trap cleanup EXIT",
    ]:
        if source.count(marker) != 1:
            fail(f"recurring MCP scratch isolation drifted: {marker}")

    markers = gate["preflight_commands"] + [
        "PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t",
        "--test mcp_server_rust_admission",
        "bash ../tools/run_dart_project_data.sh test test/mcp_server_dart_admission_test.dart",
        RECURRING_GATE["consumers"][3]["command"],
        "puc lua/test/mcp_server_lua_admission_test.lua",
        "luajit lua/test/mcp_server_lua_admission_test.lua",
    ] + gate["postflight_commands"] + ["bash tools/run_primary_cli_matrix.sh"]
    positions: list[int] = []
    for marker in markers:
        if source.count(marker) != 1:
            fail(f"recurring MCP command count drifted: {marker}")
        positions.append(source.index(marker))
    if positions != sorted(positions):
        fail("recurring MCP commands are out of order")
    for case_id in gate["primary_cli"]["case_ids"]:
        if source.count(f"--case {case_id}") != 1:
            fail(f"recurring MCP primary case drifted: {case_id}")

    expected_path_counts = {
        RUNTIME_ADMISSIONS[0]["consumer_path"]: 1,
        RUNTIME_ADMISSIONS[3]["consumer_path"]: 1,
        RUNTIME_ADMISSIONS[4]["consumer_path"]: 2,
    }
    for path, count in expected_path_counts.items():
        if source.count(path) != count:
            fail(f"recurring MCP consumer path count drifted: {path}")

    driver = gate["driver"]
    if ci_source.count(f"require_tracked_file {driver}") != 2:
        fail("canonical CI does not require the recurring MCP driver at inventory and execution")
    syntax_block = ci_source[
        ci_source.index('log "running syntax checks"') : ci_source.index("perl -c perl/LinkedSpec.pm")
    ]
    if syntax_block.count(driver) != 1:
        fail("canonical CI does not syntax-check the recurring MCP driver")
    switch = gate["local_ci"]["switch"]
    if ci_source.count(f'if [[ "${{{switch}:-0}}" == "1" ]]; then') != 1:
        fail("canonical CI recurring MCP switch drifted")
    if ci_source.count(f'bash "$REPO_ROOT/{driver}"') != 1:
        fail("canonical CI recurring MCP execution drifted")


def validate_cross_ledger(
    ledger: dict[str, Any], semantic: dict[str, Any], semantic_checker: str
) -> None:
    semantic_rows = [
        row
        for row in semantic.get("rollout", [])
        if row.get("capability") == "thin_mcp_transport"
    ]
    expected_rollout = {
        "capability": "thin_mcp_transport",
        "status": "complete",
        "owner": ROLLOUT_OWNER,
    }
    if semantic_rows != [expected_rollout]:
        fail("neutral semantic thin_mcp_transport rollout diverged from MCP promotion")
    rollout = ledger["rollout"]
    if (rollout["status"], rollout["owner"]) != (
        expected_rollout["status"],
        expected_rollout["owner"],
    ):
        fail("MCP and semantic rollout status/owner are not atomic")
    expected_identity = {
        "status": "complete",
        "owner": ROLLOUT_OWNER,
        "driver": RECURRING_GATE["driver"],
    }
    if semantic.get("canonical_ci", {}).get("mcp_direct_identity") != expected_identity:
        fail("neutral semantic MCP recurring identity drifted")
    lock = f'("thin_mcp_transport", "complete", "{ROLLOUT_OWNER}")'
    if semantic_checker.count(lock) != 1:
        fail("semantic checker no longer locks the coordinated MCP rollout")


def require_consumer_role_markers(
    source: str, start: str, end: str, markers: list[str], runtime: str
) -> None:
    if source.count(start) != 1 or source.count(end) != 1:
        fail(f"{runtime} native-query role boundary drifted")
    body = source[source.index(start) : source.index(end)]
    for marker in markers:
        if body.count(marker) != 1:
            fail(f"{runtime} all-twenty identity marker drifted: {marker}")


def validate_perl_consumer_source(source: str) -> None:
    declaration = re.search(r"my @ROLE_ORDER = qw\(\n(.*?)\n\);", source, re.DOTALL)
    if declaration is None:
        fail("Perl admission role declaration is missing")
    declared = declaration.group(1).split()
    if declared != ROLES:
        fail("Perl admission role declaration/order drifted")
    calls = re.findall(r"admission_role\(\s*'([a-z_]+)'", source)
    if calls != ROLES:
        fail("Perl admission roles are not invoked exactly once in order")
    if source.count("done_testing;") != 1:
        fail("Perl admission does not have one explicit test completion")
    require_consumer_role_markers(
        source,
        "admission_role(\n 'native_query_identity',",
        "admission_role(\n 'raw_input_outcomes',",
        [
            "is(scalar(@query_cases), 19",
            "is_deeply($response->{result}{structuredContent}, $native",
            "is($response->{result}{content}[0]{text}, canonical($native)",
            "is_deeply($PLAIN_JSON->decode($response->{result}{content}[0]{text}), $native",
            "is(response_digest($native), $query_case->{expected}{response_sha256}",
        ],
        "Perl",
    )


def validate_rust_consumer_source(source: str) -> None:
    declaration = re.search(
        r"const ROLE_ORDER: \[&str; 12\] = \[\n(.*?)\n\];", source, re.DOTALL
    )
    if declaration is None:
        fail("Rust admission role declaration is missing")
    declared = re.findall(r'"([a-z_]+)"', declaration.group(1))
    if declared != ROLES:
        fail("Rust admission role declaration/order drifted")
    calls = re.findall(
        r'admission_role\(\s*&mut roles_seen,\s*"([a-z_]+)"', source, re.DOTALL
    )
    if calls != ROLES:
        fail("Rust admission roles are not invoked exactly once in order")
    test_name = "fn exact_rust_mcp_admission_executes_every_role_once()"
    if source.count(test_name) != 1:
        fail("Rust admission does not have one exact consumer test")
    test_declaration = re.search(
        rf"((?:#\[[^\]\n]+\]\s*)+){re.escape(test_name)}", source
    )
    if (
        test_declaration is None
        or "#[test]" not in test_declaration.group(1)
        or "#[ignore" in test_declaration.group(1)
        or source.count("assert_eq!(roles_seen, ROLE_ORDER);") != 1
    ):
        fail("Rust admission completion/order assertion drifted")
    require_consumer_role_markers(
        source,
        'admission_role(&mut roles_seen, "native_query_identity", || {',
        'admission_role(&mut roles_seen, "raw_input_outcomes", || {',
        [
            'assert_eq!(cases.len(), 19, "all governed MCP query responses")',
            'actual["result"]["structuredContent"], native',
            'assert_eq!(text, canonical(&native), "{id} canonical text identity")',
            'serde_json::from_str::<Value>(text).expect("MCP query text decodes")',
            'case["expected"]["response_sha256"]',
        ],
        "Rust",
    )


def validate_dart_consumer_source(source: str) -> None:
    declaration = re.search(
        r"const _roleOrder = <String>\[\n(.*?)\n\];", source, re.DOTALL
    )
    if declaration is None:
        fail("Dart admission role declaration is missing")
    declared = re.findall(r"'([a-z_]+)'", declaration.group(1))
    if declared != ROLES:
        fail("Dart admission role declaration/order drifted")
    calls = re.findall(
        r"await _admissionRole\(\s*rolesSeen,\s*'([a-z_]+)'", source, re.DOTALL
    )
    if calls != ROLES:
        fail("Dart admission roles are not invoked exactly once in order")
    test_name = "test('exact Dart MCP admission executes every role once', () async {"
    if source.count(test_name) != 1:
        fail("Dart admission does not have one exact consumer test")
    if source.count("expect(rolesSeen, _roleOrder);") != 1 or re.search(
        r"\n\s*},\s*skip\s*:", source
    ):
        fail("Dart admission completion/order assertion drifted")
    require_consumer_role_markers(
        source,
        "await _admissionRole(rolesSeen, 'native_query_identity', () async {",
        "await _admissionRole(rolesSeen, 'raw_input_outcomes', () async {",
        [
            "expect(queryCases, hasLength(19));",
            "expect(result['structuredContent'], native, reason: '$id structured');",
            "expect(text, _canonicalJson(native), reason: '$id canonical text');",
            "expect(jsonDecode(text), native, reason: '$id decoded text');",
            "_object(queryCase['expected'])['response_sha256']",
        ],
        "Dart",
    )


def validate_julia_consumer_source(source: str) -> None:
    declaration = re.search(
        r"const _MCP_ADMISSION_ROLE_ORDER = \[\n(.*?)\n\]", source, re.DOTALL
    )
    if declaration is None:
        fail("Julia admission role declaration is missing")
    declared = re.findall(r'"([a-z_]+)"', declaration.group(1))
    if declared != ROLES:
        fail("Julia admission role declaration/order drifted")
    calls = re.findall(
        r'_mcp_admission_role!\(\s*roles_seen,\s*"([a-z_]+)"', source, re.DOTALL
    )
    if calls != ROLES:
        fail("Julia admission roles are not invoked exactly once in order")
    test_name = '@testset "exact Julia MCP admission executes every role once" begin'
    if source.count(test_name) != 1:
        fail("Julia admission does not have one exact consumer test")
    if (
        source.count("@test roles_seen == _MCP_ADMISSION_ROLE_ORDER") != 1
        or "@test_broken" in source
        or "@test_skip" in source
    ):
        fail("Julia admission completion/order assertion drifted")
    require_consumer_role_markers(
        source,
        '_mcp_admission_role!(roles_seen, "native_query_identity") do',
        '_mcp_admission_role!(roles_seen, "raw_input_outcomes") do',
        [
            "@test length(query_cases) == 19",
            '@test actual["result"]["structuredContent"] == native',
            "@test text == LinkedSpecJulia._mcp_canonical_json(native)",
            "@test JSON3.read(text, Dict{String,Any}) == native",
            'query_case["expected"]["response_sha256"]',
        ],
        "Julia",
    )


def validate_lua_consumer_source(source: str) -> None:
    declaration = re.search(
        r"local ROLE_ORDER = json\.array\(\{\n(.*?)\n\}\)", source, re.DOTALL
    )
    if declaration is None:
        fail("Lua admission role declaration is missing")
    declared = re.findall(r'"([a-z_]+)"', declaration.group(1))
    if declared != ROLES:
        fail("Lua admission role declaration/order drifted")
    calls = re.findall(
        r'admission_role\(roles_seen,\s*"([a-z_]+)"', source, re.DOTALL
    )
    if calls != ROLES:
        fail("Lua admission roles are not invoked exactly once in order")
    completion = (
        'check_same_json(roles_seen, ROLE_ORDER, '
        '"all exact admission roles execute once in order")'
    )
    if (
        source.count(completion) != 1
        or source.count('io.write("[lua-mcp-admission] PASS: "') != 1
        or "if false" in source
        or "os.exit(0)" in source
    ):
        fail("Lua admission completion/order assertion drifted")
    require_consumer_role_markers(
        source,
        'admission_role(roles_seen, "native_query_identity", function()',
        'admission_role(roles_seen, "raw_input_outcomes", function()',
        [
            'check_equal(#query_cases, 19, "all governed MCP query responses")',
            "check_same_json(actual.result.structuredContent, native,",
            "check_equal(actual.result.content[1].text, runtime.canonical_json(native),",
            "check_same_json(json.decode(actual.result.content[1].text), native,",
            "check_equal(semantic_response_digest(native), governed.expected.response_sha256,",
        ],
        "Lua",
    )


def validate_authority_sources() -> None:
    sources = {
        path: (ROOT / path).read_text(encoding="utf-8")
        for path in [
            "perl/LinkedSpec/MCPContractRuntime.pm",
            "perl/LinkedSpec/MCPServer.pm",
            "perl/LinkedSpec/MCPWire.pm",
        ]
    }
    forbidden = [
        "LinkedSpec::Get(",
        "LinkedSpec::get_parser",
        "return_descriptor(",
        "call_spec_handler",
        "dump_parser_source",
        "LINKEDSPEC_TRACE_LEVEL",
        "readpipe(",
        "system(",
        "exec(",
    ]
    combined = "\n".join(sources.values())
    for token in forbidden:
        if token in combined:
            fail(f"MCP production authority fence contains forbidden token: {token}")
    server_source = sources["perl/LinkedSpec/MCPServer.pm"]
    if server_source.count("sysopen my $fh, '/dev/urandom', O_RDONLY") != 1:
        fail("the sole documented OS entropy read drifted")
    if "sysopen" in sources["perl/LinkedSpec/MCPContractRuntime.pm"] or "sysopen" in sources["perl/LinkedSpec/MCPWire.pm"]:
        fail("a non-registry MCP owner acquired filesystem-open authority")

    rust_sources = {
        path: (ROOT / path).read_text(encoding="utf-8")
        for path in IMPLEMENTATIONS[1]["source_paths"]
    }
    rust_combined = "\n".join(rust_sources.values())
    for token in [
        "std::fs::",
        "File::open(",
        "OpenOptions::",
        "std::process::Command",
        "Command::new(",
        "TcpListener",
        "TcpStream",
        "UdpSocket",
        "tokio::",
        "LINKEDSPEC_TRACE_LEVEL",
        "dump_parser_source",
        "return_descriptor",
        "call_spec_handler",
    ]:
        if token in rust_combined:
            fail(f"Rust MCP production authority fence contains forbidden token: {token}")

    dart_sources = {
        path: (ROOT / path).read_text(encoding="utf-8")
        for path in [
            "dart/lib/src/mcp/mcp_server.dart",
            "dart/lib/src/mcp/mcp_contract_runtime.dart",
            "dart/lib/src/mcp/mcp_wire.dart",
        ]
    }
    dart_server = dart_sources["dart/lib/src/mcp/mcp_server.dart"]
    dart_io_import = "import 'dart:io' show IOSink;"
    if dart_server.count(dart_io_import) != 1:
        fail("Dart MCP must import exactly the borrowed IOSink authority")
    for path, source in dart_sources.items():
        if path != "dart/lib/src/mcp/mcp_server.dart" and "import 'dart:io'" in source:
            fail(f"non-server Dart MCP owner acquired dart:io authority: {path}")
    dart_combined = "\n".join(dart_sources.values())
    for token in [
        "import 'dart:ffi'",
        "import 'dart:isolate'",
        "File(",
        "Directory(",
        "Process.",
        "Socket",
        "HttpClient",
        "parseSpec(",
        "compileSpec(",
        "loadSpec(",
        "LinkedSpecRuntimeEngine",
        "LINKEDSPEC_TRACE_LEVEL",
        "emitDartSource",
    ]:
        if token in dart_combined:
            fail(f"Dart MCP production authority fence contains forbidden token: {token}")
    primary = (ROOT / "bin" / "linkedspec").read_text(encoding="utf-8")
    if "McpServer" in primary or "serve_stdio" in primary:
        fail("the primary parser CLI acquired MCP bootstrap authority")
    dart_primary = (ROOT / "dart" / "bin" / "linkedspec_dart.dart").read_text(
        encoding="utf-8"
    )
    if "McpServer" in dart_primary or "serveStdio" in dart_primary:
        fail("the primary Dart parser CLI acquired MCP bootstrap authority")

    julia_sources = {
        path: (ROOT / path).read_text(encoding="utf-8")
        for path in JULIA_OWNERS["source_paths"][1:]
    }
    julia_combined = "\n".join(julia_sources.values())
    for token in [
        "open(",
        "rm(",
        "mkpath(",
        "ENV[",
        "run(",
        "Cmd(",
        "Sockets",
        "Downloads",
        "HTTP",
        "@async",
        "Threads.",
        "Channel",
        "parse_spec(",
        "compile_spec(",
        "load_spec(",
        "LinkedSpecRuntimeEngine",
        "LINKEDSPEC_TRACE_LEVEL",
        "emit_julia_source",
    ]:
        if token in julia_combined:
            fail(f"Julia MCP production authority fence contains forbidden token: {token}")
    julia_primary = (ROOT / "julia" / "bin" / "linkedspec_julia.jl").read_text(
        encoding="utf-8"
    )
    if (
        "McpServer" in julia_primary
        or "dispatch_mcp" in julia_primary
        or "serve_mcp_stdio!" in julia_primary
    ):
        fail("the primary Julia parser CLI acquired MCP bootstrap authority")


def validate_julia_owners(tests_source: str | None = None) -> None:
    owned_paths = [
        JULIA_OWNERS["generator"],
        *JULIA_OWNERS["source_paths"],
        *JULIA_OWNERS["test_paths"],
    ]
    for path in owned_paths:
        if not (ROOT / path).is_file():
            fail(f"Julia MCP owner is absent: {path}")

    module_source = (ROOT / "julia" / "src" / "LinkedSpecJulia.jl").read_text(
        encoding="utf-8"
    )
    for include in [
        'include("mcp/McpContract.jl")',
        'include("mcp/McpContractRuntime.jl")',
        'include("mcp/McpServer.jl")',
        'include("mcp/McpWire.jl")',
    ]:
        if module_source.count(include) != 1:
            fail(f"Julia MCP module owner registration drifted: {include}")
    if tests_source is None:
        tests_source = (ROOT / "julia" / "test" / "runtests.jl").read_text(
            encoding="utf-8"
        )
    for include in [
        'include("mcp_contract_julia_binding_test.jl")',
        'include("mcp_server_julia_dispatch_test.jl")',
        'include("mcp_server_julia_stdio_test.jl")',
        'include("mcp_server_julia_admission_test.jl")',
    ]:
        if tests_source.count(include) != 1:
            fail(f"Julia MCP package-test registration drifted: {include}")


def validate_lua_owners(
    init_source: str | None = None,
    semantic_source: str | None = None,
    builder_source: str | None = None,
    gate_source: str | None = None,
    process_source: str | None = None,
) -> None:
    owned_paths = [
        LUA_OWNERS["generator"],
        *LUA_OWNERS["source_paths"],
        *LUA_OWNERS["test_paths"],
    ]
    for path in owned_paths:
        if not (ROOT / path).is_file():
            fail(f"Lua MCP owner is absent: {path}")

    if init_source is None:
        init_source = (ROOT / "lua" / "src" / "linkedspec" / "init.lua").read_text(
            encoding="utf-8"
        )
    init_tokens = [
        'local mcp_server',
        'mcp_server = require("linkedspec.mcp_server")',
        'M.mcp_server = function(...) return load_mcp_server().server(...) end',
        'M.mcp_budget_limits = function(...) return load_mcp_server().budget_limits(...) end',
        'M.mcp_deployment_policy = function(...) return load_mcp_server().deployment_policy(...) end',
        'M.mcp_registration_options = function(...) return load_mcp_server().registration_options(...) end',
        'M.is_mcp_server_error = function(...) return load_mcp_server().is_error(...) end',
        'M.mcp_server_error_to_json = function(...) return load_mcp_server().error_to_json(...) end',
    ]
    for token in init_tokens:
        if init_source.count(token) != 1:
            fail(f"Lua MCP lazy root registration drifted: {token}")

    if semantic_source is None:
        semantic_source = (
            ROOT / "lua" / "src" / "linkedspec" / "semantic_index.lua"
        ).read_text(encoding="utf-8")
    if semantic_source.count("function M._is_index(value)") != 1:
        fail("Lua MCP native semantic-index identity seam drifted")

    if builder_source is None:
        builder_source = (ROOT / "tools" / "build_lua_native.sh").read_text(
            encoding="utf-8"
        )
    for token in [
        '"$REPO_ROOT/lua/native/mcp_system.c"',
        '"$output/linkedspec_mcp_system.so"',
    ]:
        if builder_source.count(token) != 1:
            fail(f"Lua MCP native-system build registration drifted: {token}")

    if gate_source is None:
        gate_source = (ROOT / "tools" / "run_lua_local.sh").read_text(
            encoding="utf-8"
        )
    if gate_source.count(LUA_GENERATOR_COMMAND) != 1:
        fail("Lua local gate binding-generator registration drifted")
    for path in LUA_OWNERS["test_paths"]:
        if gate_source.count(path) != 2:
            fail(f"Lua MCP proof is not registered once per ABI: {path}")

    if process_source is None:
        process_source = (
            ROOT / "tools" / "test_project_data_process_locality.sh"
        ).read_text(encoding="utf-8")
    if process_source.count("lua/native/mcp_system.c") != 1:
        fail("Lua MCP native-system relocated-checkout overlay drifted")


def validate_lua_authority_sources(
    runtime_source: str | None = None,
    server_source: str | None = None,
    wire_source: str | None = None,
    native_source: str | None = None,
) -> None:
    if runtime_source is None:
        runtime_source = (
            ROOT / "lua" / "src" / "linkedspec" / "mcp_contract_runtime.lua"
        ).read_text(encoding="utf-8")
    if server_source is None:
        server_source = (
            ROOT / "lua" / "src" / "linkedspec" / "mcp_server.lua"
        ).read_text(encoding="utf-8")
    if wire_source is None:
        wire_source = (
            ROOT / "lua" / "src" / "linkedspec" / "mcp_wire.lua"
        ).read_text(encoding="utf-8")
    lua_combined = runtime_source + "\n" + server_source + "\n" + wire_source
    for token in [
        "io.open(",
        "io.input(",
        "io.output(",
        "io.popen(",
        "io.lines(",
        "io.write(",
        "os.",
        "dofile(",
        "loadfile(",
        "package.",
        "debug.",
        "socket",
        "http",
        "ffi",
        "jit.",
        "LINKEDSPEC_TRACE_LEVEL",
        "parse_spec(",
        "compile_spec(",
        "load_spec(",
        "emit_lua_source",
    ]:
        if token in lua_combined:
            fail(f"Lua MCP production authority fence contains forbidden token: {token}")

    if native_source is None:
        native_source = (ROOT / "lua" / "native" / "mcp_system.c").read_text(
            encoding="utf-8"
        )
    for name in ["fopen", "open", "system", "exec", "fork", "socket", "getenv"]:
        if re.search(rf"(?<![A-Za-z0-9_]){name}\s*\(", native_source):
            fail(f"Lua MCP native-system authority fence contains forbidden call: {name}")
    for token in [
        "arc4random_buf(bytes, sizeof(bytes));",
        "getrandom(bytes + offset, sizeof(bytes) - offset, 0U);",
        "clock_gettime(CLOCK_MONOTONIC, &value)",
        '#error "LinkedSpec MCP requires arc4random_buf or getrandom"',
    ]:
        if native_source.count(token) != 1:
            fail(f"Lua MCP native-system portability source drifted: {token}")

    primary = (ROOT / "lua" / "bin" / "linkedspec-lua").read_text(encoding="utf-8")
    if "mcp_server" in primary or "serve_stdio" in primary:
        fail("the primary Lua parser CLI acquired MCP bootstrap authority")


def validate_ledger(ledger: dict[str, Any], inspect_files: bool = True) -> None:
    exact_fields(
        ledger,
        {
            "format",
            "contract_id",
            "task_owner",
            "decisions",
            "transport_contract",
            "admission_contract",
            "implementations",
            "runtime_admissions",
            "recurring_gate",
            "rollout",
            "canonical_ci",
        },
        "ledger",
    )
    if ledger["format"] != 1 or ledger["contract_id"] != CONTRACT_ID or ledger["task_owner"] != TASK_OWNER:
        fail("ledger identity drifted")
    if ledger["decisions"] != ["0054", "0055", "0057", "0058", "0059", "0060", "0061", "0062"]:
        fail("ledger decision provenance drifted")

    transport_ref = ledger["transport_contract"]
    exact_fields(transport_ref, {"contract_id", "path", "sha256"}, "transport reference")
    if transport_ref != {
        "contract_id": TRANSPORT_ID,
        "path": "capability_conformance/mcp_semantic_transport_contract.json",
        "sha256": TRANSPORT_SHA256,
    }:
        fail("normative transport reference drifted")
    if sha256(TRANSPORT_PATH) != TRANSPORT_SHA256:
        fail("normative transport contract changed during implementation admission")

    admission = ledger["admission_contract"]
    exact_fields(admission, {"roles", "role_policy", "contract_inventory"}, "admission contract")
    if admission["roles"] != ROLES:
        fail("admission role inventory/order drifted")
    if admission["role_policy"] != "one ordered consumer per runtime executes every exact role once":
        fail("admission role policy drifted")
    if admission["contract_inventory"] != {
        "canonical_frames": 35,
        "raw_inputs": 10,
        "lifecycle_cases": 10,
        "handle_cases": 4,
        "policy_cases": 4,
    }:
        fail("admission contract inventory drifted")

    if ledger["implementations"] != IMPLEMENTATIONS:
        fail("five-implementation status/identity topology drifted")
    if ledger["runtime_admissions"] != RUNTIME_ADMISSIONS:
        fail("six-runtime admission status/topology drifted")
    if sum(row["status"] == "complete" for row in ledger["implementations"]) != 5:
        fail("implementation completion count is not exactly five")
    if sum(row["status"] == "complete" for row in ledger["runtime_admissions"]) != 6:
        fail("runtime admission completion count is not exactly six")

    if ledger["recurring_gate"] != RECURRING_GATE:
        fail("recurring MCP six-runtime topology drifted")

    rollout = ledger["rollout"]
    exact_fields(
        rollout,
        {"semantic_capability", "status", "owner", "requires_runtime_admissions"},
        "rollout",
    )
    if rollout != {
        "semantic_capability": "thin_mcp_transport",
        "status": "complete",
        "owner": ROLLOUT_OWNER,
        "requires_runtime_admissions": ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
    }:
        fail("thin MCP rollout completion or its six-runtime condition drifted")

    canonical = ledger["canonical_ci"]
    exact_fields(canonical, {"driver", "ordered_commands"}, "canonical CI")
    if canonical["driver"] != "tools/run_ci_local.sh" or canonical["ordered_commands"] != ORDERED_COMMANDS:
        fail("canonical MCP admission topology drifted")

    transport = load_json(TRANSPORT_PATH)
    identities = [
        {"backend": row["id"], "server_name": row["name"], "runtime_admissions": row["runtime_admissions"]}
        for row in transport.get("server_identities", [])
    ]
    ledger_identities = [
        {
            "backend": row["backend"],
            "server_name": row["server_name"],
            "runtime_admissions": row["runtime_admissions"],
        }
        for row in ledger["implementations"]
    ]
    if ledger_identities != identities:
        fail("ledger identities do not derive from the normative transport contract")

    semantic = load_json(SEMANTIC_PATH)
    semantic_checker = SEMANTIC_CHECKER_PATH.read_text(encoding="utf-8")
    validate_cross_ledger(ledger, semantic, semantic_checker)

    if inspect_files:
        validate_julia_owners()
        validate_lua_owners()
        for row in ledger["implementations"]:
            for path in row["source_paths"]:
                if not (ROOT / path).is_file():
                    fail(f"implemented MCP source is absent: {path}")
        for row in RUNTIME_ADMISSIONS:
            if row["status"] != "complete":
                continue
            consumer_path = ROOT / row["consumer_path"]
            if not consumer_path.is_file():
                fail(f"{row['runtime']} MCP admission consumer is absent")
            source = consumer_path.read_text(encoding="utf-8")
            if row["runtime"] == "perl":
                validate_perl_consumer_source(source)
            elif row["runtime"] == "rust":
                validate_rust_consumer_source(source)
            elif row["runtime"] == "dart":
                validate_dart_consumer_source(source)
            elif row["runtime"] == "julia":
                validate_julia_consumer_source(source)
            elif row["runtime"] in {"puc_lua", "luajit"}:
                validate_lua_consumer_source(source)
            else:
                fail(f"complete runtime has no consumer validator: {row['runtime']}")
        validate_ci_source(CI_PATH.read_text(encoding="utf-8"), canonical["ordered_commands"])
        if not RECURRING_PATH.is_file():
            fail("recurring MCP six-runtime driver is missing")
        if RECURRING_PATH.stat().st_mode & 0o111 == 0:
            fail("recurring MCP six-runtime driver is not executable")
        validate_recurring_gate_source(
            ledger["recurring_gate"],
            RECURRING_PATH.read_text(encoding="utf-8"),
            CI_PATH.read_text(encoding="utf-8"),
        )
        validate_authority_sources()
        validate_lua_authority_sources()


def coordinated_promotion(ledger: dict[str, Any]) -> None:
    for row in ledger["implementations"]:
        row["status"] = "complete"
    for row in ledger["runtime_admissions"]:
        row["status"] = "complete"
    ledger["rollout"]["status"] = "complete"
    ledger["rollout"]["owner"] = "FUTURE-PARITY-BACKLOG.10.9.7"


LEDGER_MUTATIONS: list[tuple[str, Callable[[dict[str, Any]], None]]] = [
    ("contract identity", lambda value: value.__setitem__("contract_id", "wrong")),
    ("task owner", lambda value: value.__setitem__("task_owner", "wrong")),
    ("decision provenance", lambda value: value["decisions"].pop()),
    ("transport digest", lambda value: value["transport_contract"].__setitem__("sha256", "0" * 64)),
    ("role omission", lambda value: value["admission_contract"]["roles"].pop()),
    ("inventory drift", lambda value: value["admission_contract"]["contract_inventory"].__setitem__("raw_inputs", 9)),
    ("implementation omission", lambda value: value["implementations"].pop()),
    ("implementation reorder", lambda value: value["implementations"].reverse()),
    ("server identity", lambda value: value["implementations"][0].__setitem__("server_name", "wrong")),
    ("Perl implementation regression", lambda value: value["implementations"][0].__setitem__("status", "pending")),
    ("Rust implementation regression", lambda value: value["implementations"][1].__setitem__("status", "pending")),
    ("Dart implementation regression", lambda value: value["implementations"][2].__setitem__("status", "pending")),
    ("Julia implementation regression", lambda value: value["implementations"][3].__setitem__("status", "pending")),
    ("Lua implementation regression", lambda value: value["implementations"][4].__setitem__("status", "pending")),
    ("implementation source", lambda value: value["implementations"][0]["source_paths"].pop()),
    ("Rust implementation source", lambda value: value["implementations"][1]["source_paths"].pop()),
    ("Dart implementation source", lambda value: value["implementations"][2]["source_paths"].pop()),
    ("Julia implementation source", lambda value: value["implementations"][3]["source_paths"].pop()),
    ("Lua implementation source", lambda value: value["implementations"][4]["source_paths"].pop()),
    ("runtime omission", lambda value: value["runtime_admissions"].pop()),
    ("runtime reorder", lambda value: value["runtime_admissions"].reverse()),
    ("Perl admission regression", lambda value: value["runtime_admissions"][0].__setitem__("status", "pending")),
    ("Rust admission regression", lambda value: value["runtime_admissions"][1].__setitem__("status", "pending")),
    ("Dart admission regression", lambda value: value["runtime_admissions"][2].__setitem__("status", "pending")),
    ("Julia admission regression", lambda value: value["runtime_admissions"][3].__setitem__("status", "pending")),
    ("PUC Lua admission regression", lambda value: value["runtime_admissions"][4].__setitem__("status", "pending")),
    ("LuaJIT admission regression", lambda value: value["runtime_admissions"][5].__setitem__("status", "pending")),
    ("Lua ABI ownership", lambda value: value["runtime_admissions"][5].__setitem__("runtime", "lua54")),
    ("Perl consumer path", lambda value: value["runtime_admissions"][0].__setitem__("consumer_path", "wrong")),
    ("Rust consumer path", lambda value: value["runtime_admissions"][1].__setitem__("consumer_path", "wrong")),
    ("Dart consumer path", lambda value: value["runtime_admissions"][2].__setitem__("consumer_path", "wrong")),
    ("Julia consumer path", lambda value: value["runtime_admissions"][3].__setitem__("consumer_path", "wrong")),
    ("PUC Lua consumer path", lambda value: value["runtime_admissions"][4].__setitem__("consumer_path", "wrong")),
    ("LuaJIT consumer path", lambda value: value["runtime_admissions"][5].__setitem__("consumer_path", "wrong")),
    ("rollout regression", lambda value: value["rollout"].__setitem__("status", "pending")),
    ("rollout owner", lambda value: value["rollout"].__setitem__("owner", "FUTURE-PARITY-BACKLOG.10.9.7")),
    ("rollout requirement", lambda value: value["rollout"]["requires_runtime_admissions"].pop()),
    ("coordinated owner mismatch", coordinated_promotion),
    ("recurring gate omission", lambda value: value.pop("recurring_gate")),
    ("recurring runtime omission", lambda value: value["recurring_gate"]["consumers"].pop()),
    ("recurring runtime reorder", lambda value: value["recurring_gate"]["consumers"].reverse()),
    ("recurring preflight omission", lambda value: value["recurring_gate"]["preflight_commands"].pop()),
    ("recurring ledger check omission", lambda value: value["recurring_gate"]["postflight_commands"].pop()),
    ("recurring primary case omission", lambda value: value["recurring_gate"]["primary_cli"]["case_ids"].pop()),
    ("recurring switch drift", lambda value: value["recurring_gate"]["local_ci"].__setitem__("switch", "WRONG")),
    ("canonical omission", lambda value: value["canonical_ci"]["ordered_commands"].pop()),
    ("canonical reorder", lambda value: value["canonical_ci"]["ordered_commands"].reverse()),
]


def run_mutations(ledger: dict[str, Any]) -> int:
    rejected = 0
    for name, mutate in LEDGER_MUTATIONS:
        candidate = copy.deepcopy(ledger)
        mutate(candidate)
        try:
            validate_ledger(candidate, inspect_files=False)
        except CheckError:
            rejected += 1
            continue
        fail(f"mutation was accepted: {name}")

    semantic = load_json(SEMANTIC_PATH)
    semantic_checker = SEMANTIC_CHECKER_PATH.read_text(encoding="utf-8")
    semantic_mutations: list[tuple[str, Callable[[dict[str, Any]], None]]] = [
        (
            "semantic rollout regression",
            lambda value: next(
                row for row in value["rollout"] if row["capability"] == "thin_mcp_transport"
            ).__setitem__("status", "pending"),
        ),
        (
            "semantic rollout owner mismatch",
            lambda value: next(
                row for row in value["rollout"] if row["capability"] == "thin_mcp_transport"
            ).__setitem__("owner", "FUTURE-PARITY-BACKLOG.10.9"),
        ),
        (
            "semantic rollout omission",
            lambda value: value["rollout"].__setitem__(
                slice(None),
                [row for row in value["rollout"] if row["capability"] != "thin_mcp_transport"],
            ),
        ),
        (
            "semantic recurring identity omission",
            lambda value: value["canonical_ci"].pop("mcp_direct_identity"),
        ),
        (
            "semantic recurring identity owner mismatch",
            lambda value: value["canonical_ci"]["mcp_direct_identity"].__setitem__(
                "owner", "FUTURE-PARITY-BACKLOG.10.9"
            ),
        ),
    ]
    for name, mutate in semantic_mutations:
        candidate = copy.deepcopy(semantic)
        mutate(candidate)
        try:
            validate_cross_ledger(ledger, candidate, semantic_checker)
        except CheckError:
            rejected += 1
            continue
        fail(f"mutation was accepted: {name}")

    ci_source = CI_PATH.read_text(encoding="utf-8")
    ci_mutations = [
        ("CI Dart generator omission", ci_source.replace(ORDERED_COMMANDS[4] + "\n", "")),
        ("CI Julia generator omission", ci_source.replace(ORDERED_COMMANDS[5] + "\n", "")),
        ("CI Lua generator omission", ci_source.replace(ORDERED_COMMANDS[6] + "\n", "")),
        ("CI Rust admission omission", ci_source.replace(ORDERED_COMMANDS[11] + "\n", "")),
        ("CI Dart decoded proof omission", ci_source.replace(ORDERED_COMMANDS[12] + "\n", "")),
        (
            "CI Dart strict stdio proof omission",
            ci_source.replace(
                ORDERED_COMMANDS[12],
                "bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart",
                1,
            ),
        ),
        ("CI Dart admission omission", ci_source.replace(ORDERED_COMMANDS[13] + "\n", "")),
        ("CI Julia focused proof omission", ci_source.replace(ORDERED_COMMANDS[14] + "\n", "")),
        (
            "CI Julia strict stdio proof omission",
            ci_source.replace(
                ORDERED_COMMANDS[14],
                "bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include(\"julia/test/mcp_contract_julia_binding_test.jl\"); include(\"julia/test/mcp_server_julia_dispatch_test.jl\")'",
                1,
            ),
        ),
        ("CI Julia admission omission", ci_source.replace(ORDERED_COMMANDS[15] + "\n", "")),
        ("CI PUC Lua admission omission", ci_source.replace(ORDERED_COMMANDS[16] + "\n", "")),
        ("CI LuaJIT admission omission", ci_source.replace(ORDERED_COMMANDS[17] + "\n", "")),
        ("CI admission checker omission", ci_source.replace(ORDERED_COMMANDS[18] + "\n", "")),
        ("CI Perl admission omission", ci_source.replace(ORDERED_COMMANDS[19] + "\n", "")),
        (
            "CI checker before Rust admission",
            ci_source.replace(ORDERED_COMMANDS[11], "__RUST_ADMISSION__")
            .replace(ORDERED_COMMANDS[18], ORDERED_COMMANDS[11])
            .replace("__RUST_ADMISSION__", ORDERED_COMMANDS[18]),
        ),
        (
            "CI Rust admission before strict stdio proof",
            ci_source.replace(ORDERED_COMMANDS[10], "__RUST_STDIO__")
            .replace(ORDERED_COMMANDS[11], ORDERED_COMMANDS[10])
            .replace("__RUST_STDIO__", ORDERED_COMMANDS[11]),
        ),
        (
            "CI Dart admission before focused proof",
            ci_source.replace(ORDERED_COMMANDS[12], "__DART_FOCUSED__")
            .replace(ORDERED_COMMANDS[13], ORDERED_COMMANDS[12])
            .replace("__DART_FOCUSED__", ORDERED_COMMANDS[13]),
        ),
        (
            "CI checker before Dart admission",
            ci_source.replace(ORDERED_COMMANDS[13], "__DART_ADMISSION__")
            .replace(ORDERED_COMMANDS[18], ORDERED_COMMANDS[13])
            .replace("__DART_ADMISSION__", ORDERED_COMMANDS[18]),
        ),
        (
            "CI checker before Julia focused proof",
            ci_source.replace(ORDERED_COMMANDS[14], "__JULIA_FOCUSED__")
            .replace(ORDERED_COMMANDS[18], ORDERED_COMMANDS[14])
            .replace("__JULIA_FOCUSED__", ORDERED_COMMANDS[18]),
        ),
        (
            "CI Julia admission before focused proof",
            ci_source.replace(ORDERED_COMMANDS[14], "__JULIA_FOCUSED__")
            .replace(ORDERED_COMMANDS[15], ORDERED_COMMANDS[14])
            .replace("__JULIA_FOCUSED__", ORDERED_COMMANDS[15]),
        ),
        (
            "CI checker before Julia admission",
            ci_source.replace(ORDERED_COMMANDS[15], "__JULIA_ADMISSION__")
            .replace(ORDERED_COMMANDS[18], ORDERED_COMMANDS[15])
            .replace("__JULIA_ADMISSION__", ORDERED_COMMANDS[18]),
        ),
        (
            "CI checker before PUC Lua admission",
            ci_source.replace(ORDERED_COMMANDS[16], "__PUC_LUA_ADMISSION__")
            .replace(ORDERED_COMMANDS[18], ORDERED_COMMANDS[16])
            .replace("__PUC_LUA_ADMISSION__", ORDERED_COMMANDS[18]),
        ),
        (
            "CI LuaJIT admission before PUC Lua admission",
            ci_source.replace(ORDERED_COMMANDS[16], "__PUC_LUA_ADMISSION__")
            .replace(ORDERED_COMMANDS[17], ORDERED_COMMANDS[16])
            .replace("__PUC_LUA_ADMISSION__", ORDERED_COMMANDS[17]),
        ),
        (
            "CI ledger registration omission",
            ci_source.replace(
                "require_tracked_file capability_conformance/mcp_implementation_admission.json\n",
                "",
            ),
        ),
        (
            "CI Rust admission registration omission",
            ci_source.replace(
                "require_tracked_file rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs\n",
                "",
            ),
        ),
        (
            "CI Dart generator registration omission",
            ci_source.replace(
                "require_tracked_file tools/generate_dart_mcp_contract.py\n",
                "",
            ),
        ),
        (
            "CI Dart decoded proof registration omission",
            ci_source.replace(
                "require_tracked_file dart/test/mcp_server_dart_dispatch_test.dart\n",
                "",
            ),
        ),
        (
            "CI Dart wire registration omission",
            ci_source.replace(
                "require_tracked_file dart/lib/src/mcp/mcp_wire.dart\n",
                "",
            ),
        ),
        (
            "CI Dart stdio proof registration omission",
            ci_source.replace(
                "require_tracked_file dart/test/mcp_server_dart_stdio_test.dart\n",
                "",
            ),
        ),
        (
            "CI Dart admission registration omission",
            ci_source.replace(
                "require_tracked_file dart/test/mcp_server_dart_admission_test.dart\n",
                "",
            ),
        ),
        (
            "CI Julia generator registration omission",
            ci_source.replace(
                "require_tracked_file tools/generate_julia_mcp_contract.py\n",
                "",
            ),
        ),
        (
            "CI Julia server registration omission",
            ci_source.replace(
                "require_tracked_file julia/src/mcp/McpServer.jl\n",
                "",
            ),
        ),
        (
            "CI Julia wire registration omission",
            ci_source.replace(
                "require_tracked_file julia/src/mcp/McpWire.jl\n",
                "",
            ),
        ),
        (
            "CI Julia binding proof registration omission",
            ci_source.replace(
                "require_tracked_file julia/test/mcp_contract_julia_binding_test.jl\n",
                "",
            ),
        ),
        (
            "CI Julia decoded proof registration omission",
            ci_source.replace(
                "require_tracked_file julia/test/mcp_server_julia_dispatch_test.jl\n",
                "",
            ),
        ),
        (
            "CI Julia stdio proof registration omission",
            ci_source.replace(
                "require_tracked_file julia/test/mcp_server_julia_stdio_test.jl\n",
                "",
            ),
        ),
        (
            "CI Julia admission registration omission",
            ci_source.replace(
                "require_tracked_file julia/test/mcp_server_julia_admission_test.jl\n",
                "",
            ),
        ),
        (
            "CI Lua generator registration omission",
            ci_source.replace(
                "require_tracked_file tools/generate_lua_mcp_contract.py\n", "", 1
            ),
        ),
        (
            "CI Lua native system registration omission",
            ci_source.replace("require_tracked_file lua/native/mcp_system.c\n", "", 1),
        ),
        (
            "CI Lua contract runtime registration omission",
            ci_source.replace(
                "require_tracked_file lua/src/linkedspec/mcp_contract_runtime.lua\n",
                "",
                1,
            ),
        ),
        (
            "CI Lua server registration omission",
            ci_source.replace(
                "require_tracked_file lua/src/linkedspec/mcp_server.lua\n", "", 1
            ),
        ),
        (
            "CI Lua binding proof registration omission",
            ci_source.replace(
                "require_tracked_file lua/test/mcp_contract_lua_binding_test.lua\n",
                "",
                1,
            ),
        ),
        (
            "CI Lua decoded proof registration omission",
            ci_source.replace(
                "require_tracked_file lua/test/mcp_server_lua_dispatch_test.lua\n",
                "",
                1,
            ),
        ),
        (
            "CI Lua wire registration omission",
            ci_source.replace(
                "require_tracked_file lua/src/linkedspec/mcp_wire.lua\n", "", 1
            ),
        ),
        (
            "CI Lua stdio proof registration omission",
            ci_source.replace(
                "require_tracked_file lua/test/mcp_server_lua_stdio_test.lua\n",
                "",
                1,
            ),
        ),
        (
            "CI Lua admission registration omission",
            ci_source.replace(
                "require_tracked_file lua/test/mcp_server_lua_admission_test.lua\n",
                "",
                1,
            ),
        ),
    ]
    for name, mutant in ci_mutations:
        try:
            validate_ci_source(mutant, ORDERED_COMMANDS)
        except CheckError:
            rejected += 1
            continue
        fail(f"mutation was accepted: {name}")

    recurring_source = RECURRING_PATH.read_text(encoding="utf-8")
    recurring_mutations = [
        (
            "recurring route omission",
            recurring_source.replace('source "$REPO_ROOT/tools/project_data_env.sh"\n', "", 1),
            ci_source,
        ),
        (
            "recurring scratch isolation omission",
            recurring_source.replace('export CARGO_TARGET_DIR="$RUST_TARGET_ROOT"\n', "", 1),
            ci_source,
        ),
        (
            "recurring neutral preflight omission",
            recurring_source.replace(RECURRING_GATE["preflight_commands"][0] + "\n", "", 1),
            ci_source,
        ),
        (
            "recurring Rust consumer omission",
            recurring_source.replace(" --test mcp_server_rust_admission\n", "", 1),
            ci_source,
        ),
        (
            "recurring LuaJIT consumer omission",
            recurring_source.replace(
                " luajit lua/test/mcp_server_lua_admission_test.lua\n", "", 1
            ),
            ci_source,
        ),
        (
            "recurring ledger omission",
            recurring_source.replace(RECURRING_GATE["postflight_commands"][0] + "\n", "", 1),
            ci_source,
        ),
        (
            "recurring primary case omission",
            recurring_source.replace(
                " --case trace_failure_invoke_route_low\n", "", 1
            ),
            ci_source,
        ),
        (
            "recurring CI inventory omission",
            recurring_source,
            ci_source.replace(
                f"require_tracked_file {RECURRING_GATE['driver']}\n", "", 1
            ),
        ),
        (
            "recurring CI switch drift",
            recurring_source,
            ci_source.replace("LINKEDSPEC_RUN_MCP_MATRIX", "LINKEDSPEC_RUN_WRONG_MCP_MATRIX"),
        ),
    ]
    for name, source_mutant, ci_mutant in recurring_mutations:
        try:
            validate_recurring_gate_source(RECURRING_GATE, source_mutant, ci_mutant)
        except CheckError:
            rejected += 1
            continue
        fail(f"mutation was accepted: {name}")

    julia_tests_source = (ROOT / "julia" / "test" / "runtests.jl").read_text(
        encoding="utf-8"
    )
    try:
        validate_julia_owners(
            julia_tests_source.replace(
                'include("mcp_server_julia_admission_test.jl")\n', "", 1
            )
        )
    except CheckError:
        rejected += 1
    else:
        fail("mutation was accepted: Julia package admission registration omission")

    lua_init_source = (ROOT / "lua" / "src" / "linkedspec" / "init.lua").read_text(
        encoding="utf-8"
    )
    lua_semantic_source = (
        ROOT / "lua" / "src" / "linkedspec" / "semantic_index.lua"
    ).read_text(encoding="utf-8")
    lua_builder_source = (ROOT / "tools" / "build_lua_native.sh").read_text(
        encoding="utf-8"
    )
    lua_gate_source = (ROOT / "tools" / "run_lua_local.sh").read_text(
        encoding="utf-8"
    )
    lua_process_source = (
        ROOT / "tools" / "test_project_data_process_locality.sh"
    ).read_text(encoding="utf-8")
    lua_owner_mutations = [
        (
            "Lua lazy root registration omission",
            {"init_source": lua_init_source.replace('local mcp_server\n', "", 1)},
        ),
        (
            "Lua semantic-index identity omission",
            {
                "semantic_source": lua_semantic_source.replace(
                    "function M._is_index(value)", "function M.wrong_index(value)", 1
                )
            },
        ),
        (
            "Lua native-system build omission",
            {
                "builder_source": lua_builder_source.replace(
                    '"$REPO_ROOT/lua/native/mcp_system.c"',
                    '"$REPO_ROOT/lua/native/wrong.c"',
                    1,
                )
            },
        ),
        (
            "Lua binding proof ABI omission",
            {
                "gate_source": lua_gate_source.replace(
                    "lua/test/mcp_contract_lua_binding_test.lua", "", 1
                )
            },
        ),
        (
            "Lua decoded proof ABI omission",
            {
                "gate_source": lua_gate_source.replace(
                    "lua/test/mcp_server_lua_dispatch_test.lua", "", 1
                )
            },
        ),
        (
            "Lua strict-stdio proof ABI omission",
            {
                "gate_source": lua_gate_source.replace(
                    "lua/test/mcp_server_lua_stdio_test.lua", "", 1
                )
            },
        ),
        (
            "Lua admission proof ABI omission",
            {
                "gate_source": lua_gate_source.replace(
                    "lua/test/mcp_server_lua_admission_test.lua", "", 1
                )
            },
        ),
        (
            "Lua native-system relocated-checkout overlay omission",
            {
                "process_source": lua_process_source.replace(
                    "lua/native/mcp_system.c ", "", 1
                )
            },
        ),
    ]
    for name, sources in lua_owner_mutations:
        try:
            validate_lua_owners(**sources)
        except CheckError:
            rejected += 1
            continue
        fail(f"mutation was accepted: {name}")

    lua_runtime_source = (
        ROOT / "lua" / "src" / "linkedspec" / "mcp_contract_runtime.lua"
    ).read_text(encoding="utf-8")
    lua_server_source = (
        ROOT / "lua" / "src" / "linkedspec" / "mcp_server.lua"
    ).read_text(encoding="utf-8")
    lua_wire_source = (
        ROOT / "lua" / "src" / "linkedspec" / "mcp_wire.lua"
    ).read_text(encoding="utf-8")
    lua_native_source = (ROOT / "lua" / "native" / "mcp_system.c").read_text(
        encoding="utf-8"
    )
    lua_authority_mutations = [
        (
            "Lua decoded server filesystem authority",
            {
                "server_source": lua_server_source
                + "\nlocal forbidden = os.execute\n"
            },
        ),
        (
            "Lua strict wire filesystem authority",
            {"wire_source": lua_wire_source + "\nlocal forbidden = io.open()\n"},
        ),
        (
            "Lua native-system file authority",
            {"native_source": lua_native_source + "\n/* fopen( */\n"},
        ),
    ]
    for name, sources in lua_authority_mutations:
        arguments = {
            "runtime_source": lua_runtime_source,
            "server_source": lua_server_source,
            "wire_source": lua_wire_source,
            "native_source": lua_native_source,
        }
        arguments.update(sources)
        try:
            validate_lua_authority_sources(**arguments)
        except CheckError:
            rejected += 1
            continue
        fail(f"mutation was accepted: {name}")

    perl_source = (ROOT / RUNTIME_ADMISSIONS[0]["consumer_path"]).read_text(encoding="utf-8")
    rust_source = (ROOT / RUNTIME_ADMISSIONS[1]["consumer_path"]).read_text(encoding="utf-8")
    dart_source = (ROOT / RUNTIME_ADMISSIONS[2]["consumer_path"]).read_text(encoding="utf-8")
    julia_source = (ROOT / RUNTIME_ADMISSIONS[3]["consumer_path"]).read_text(encoding="utf-8")
    lua_source = (ROOT / RUNTIME_ADMISSIONS[4]["consumer_path"]).read_text(encoding="utf-8")
    consumer_mutations = [
        ("Perl role omission", perl_source.replace(" contract_inventory\n", "", 1), validate_perl_consumer_source),
        (
            "Perl all-twenty coverage omission",
            perl_source.replace("  is(scalar(@query_cases), 19,", "  is(scalar(@query_cases), 18,", 1),
            validate_perl_consumer_source,
        ),
        (
            "Rust role omission",
            rust_source.replace('    "contract_inventory",\n', "", 1),
            validate_rust_consumer_source,
        ),
        (
            "Rust all-twenty coverage omission",
            rust_source.replace("assert_eq!(cases.len(), 19,", "assert_eq!(cases.len(), 18,", 1),
            validate_rust_consumer_source,
        ),
        (
            "Rust role invocation omission",
            rust_source.replace(
                'admission_role(&mut roles_seen, "contract_inventory", || {',
                'admission_role(&mut roles_seen, "wrong_role", || {',
                1,
            ),
            validate_rust_consumer_source,
        ),
        (
            "Rust completion omission",
            rust_source.replace("    assert_eq!(roles_seen, ROLE_ORDER);\n", "", 1),
            validate_rust_consumer_source,
        ),
        (
            "Rust consumer ignored",
            rust_source.replace(
                "#[test]\nfn exact_rust_mcp_admission_executes_every_role_once()",
                "#[test]\n#[ignore]\nfn exact_rust_mcp_admission_executes_every_role_once()",
                1,
            ),
            validate_rust_consumer_source,
        ),
        (
            "Dart role omission",
            dart_source.replace("  'contract_inventory',\n", "", 1),
            validate_dart_consumer_source,
        ),
        (
            "Dart all-twenty coverage omission",
            dart_source.replace("expect(queryCases, hasLength(19));", "expect(queryCases, hasLength(18));", 1),
            validate_dart_consumer_source,
        ),
        (
            "Dart role invocation omission",
            dart_source.replace(
                "await _admissionRole(rolesSeen, 'contract_inventory', () async {",
                "await _admissionRole(rolesSeen, 'wrong_role', () async {",
                1,
            ),
            validate_dart_consumer_source,
        ),
        (
            "Dart completion omission",
            dart_source.replace("    expect(rolesSeen, _roleOrder);\n", "", 1),
            validate_dart_consumer_source,
        ),
        (
            "Dart consumer skipped",
            dart_source.replace(
                "    expect(rolesSeen, _roleOrder);\n  });",
                "    expect(rolesSeen, _roleOrder);\n  }, skip: true);",
                1,
            ),
            validate_dart_consumer_source,
        ),
        (
            "Julia role omission",
            julia_source.replace('    "contract_inventory",\n', "", 1),
            validate_julia_consumer_source,
        ),
        (
            "Julia all-twenty coverage omission",
            julia_source.replace("@test length(query_cases) == 19", "@test length(query_cases) == 18", 1),
            validate_julia_consumer_source,
        ),
        (
            "Julia role invocation omission",
            julia_source.replace(
                '_mcp_admission_role!(roles_seen, "contract_inventory") do',
                '_mcp_admission_role!(roles_seen, "wrong_role") do',
                1,
            ),
            validate_julia_consumer_source,
        ),
        (
            "Julia completion omission",
            julia_source.replace(
                "    @test roles_seen == _MCP_ADMISSION_ROLE_ORDER\n", "", 1
            ),
            validate_julia_consumer_source,
        ),
        (
            "Julia consumer skipped",
            julia_source.replace(
                '@testset "exact Julia MCP admission executes every role once" begin',
                '@testset "exact Julia MCP admission executes every role once" begin\n    @test_skip true',
                1,
            ),
            validate_julia_consumer_source,
        ),
        (
            "Lua role omission",
            lua_source.replace('  "contract_inventory",\n', "", 1),
            validate_lua_consumer_source,
        ),
        (
            "Lua all-twenty coverage omission",
            lua_source.replace(
                'check_equal(#query_cases, 19, "all governed MCP query responses")',
                'check_equal(#query_cases, 18, "all governed MCP query responses")',
                1,
            ),
            validate_lua_consumer_source,
        ),
        (
            "Lua role invocation omission",
            lua_source.replace(
                'admission_role(roles_seen, "contract_inventory", function()',
                'admission_role(roles_seen, "wrong_role", function()',
                1,
            ),
            validate_lua_consumer_source,
        ),
        (
            "Lua completion omission",
            lua_source.replace(
                'check_same_json(roles_seen, ROLE_ORDER, "all exact admission roles execute once in order")\n',
                "",
                1,
            ),
            validate_lua_consumer_source,
        ),
        (
            "Lua consumer skipped",
            lua_source.replace(
                "local roles_seen = json.array()",
                "if false then\nlocal roles_seen = json.array()",
                1,
            ),
            validate_lua_consumer_source,
        ),
    ]
    for name, mutant, validator in consumer_mutations:
        try:
            validator(mutant)
        except CheckError:
            rejected += 1
            continue
        fail(f"mutation was accepted: {name}")
    return rejected


def main() -> int:
    try:
        ledger = load_json(LEDGER_PATH)
        validate_ledger(ledger)
        rejected = run_mutations(ledger)
    except CheckError as error:
        print(f"MCP implementation/admission ERROR: {error}")
        return 1
    print(
        "MCP implementation/admission: "
        f"5/5 implementations, 6/6 runtimes, rollout complete, {rejected} rejected mutations"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
