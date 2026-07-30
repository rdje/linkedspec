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
CONTRACT_ID = "linkedspec-mcp-implementation-admission-v1"
TRANSPORT_ID = "linkedspec-mcp-transport-v1"
TASK_OWNER = "FUTURE-PARITY-BACKLOG.10.9.2.3"
TRANSPORT_SHA256 = "1f16d25ad1d3351da806428146ac43acff0b27ec4707ca4a26d047e01a444732"

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
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.4",
        "source_paths": [],
        "runtime_admissions": ["dart"],
    },
    {
        "backend": "julia",
        "server_name": "linkedspec-semantic-julia",
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.5",
        "source_paths": [],
        "runtime_admissions": ["julia"],
    },
    {
        "backend": "lua",
        "server_name": "linkedspec-semantic-lua",
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.6",
        "source_paths": [],
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
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.4",
        "consumer_path": None,
    },
    {
        "backend": "julia",
        "runtime": "julia",
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.5",
        "consumer_path": None,
    },
    {
        "backend": "lua",
        "runtime": "puc_lua",
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.6",
        "consumer_path": None,
    },
    {
        "backend": "lua",
        "runtime": "luajit",
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.6",
        "consumer_path": None,
    },
]

ORDERED_COMMANDS = [
    "bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py",
    "bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py",
    "bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py",
    "bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py",
    "bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py",
    "PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib mcp_",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_dispatch",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_stdio",
    "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_admission",
    "bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart test/mcp_server_dart_stdio_test.dart",
    "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py",
    "PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t",
]


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
        "require_tracked_file t/mcp_server_perl_admission.t",
        "require_tracked_file rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs",
        "require_tracked_file dart/lib/src/mcp/mcp_contract.dart",
        "require_tracked_file dart/lib/src/mcp/mcp_contract_runtime.dart",
        "require_tracked_file dart/lib/src/mcp/mcp_server.dart",
        "require_tracked_file dart/lib/src/mcp/mcp_wire.dart",
        "require_tracked_file dart/test/mcp_contract_dart_binding_test.dart",
        "require_tracked_file dart/test/mcp_server_dart_dispatch_test.dart",
        "require_tracked_file dart/test/mcp_server_dart_stdio_test.dart",
        "perl -c -Iperl t/mcp_server_perl_admission.t",
    ]
    for line in required:
        if source.count(line) != 1:
            fail(f"canonical tracked/syntax registration drifted: {line}")


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
            "rollout",
            "canonical_ci",
        },
        "ledger",
    )
    if ledger["format"] != 1 or ledger["contract_id"] != CONTRACT_ID or ledger["task_owner"] != TASK_OWNER:
        fail("ledger identity drifted")
    if ledger["decisions"] != ["0054", "0055", "0057", "0058", "0059"]:
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
    if sum(row["status"] == "complete" for row in ledger["implementations"]) != 2:
        fail("implementation completion count is not exactly two")
    if sum(row["status"] == "complete" for row in ledger["runtime_admissions"]) != 2:
        fail("runtime admission completion count is not exactly two")

    rollout = ledger["rollout"]
    exact_fields(
        rollout,
        {"semantic_capability", "status", "owner", "requires_runtime_admissions"},
        "rollout",
    )
    if rollout != {
        "semantic_capability": "thin_mcp_transport",
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.7",
        "requires_runtime_admissions": ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
    }:
        fail("thin MCP rollout was promoted or its six-runtime condition drifted")

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
    semantic_rows = [row for row in semantic.get("rollout", []) if row.get("capability") == "thin_mcp_transport"]
    if semantic_rows != [{
        "capability": "thin_mcp_transport",
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9",
    }]:
        fail("neutral semantic thin_mcp_transport rollout was promoted prematurely")
    semantic_checker = SEMANTIC_CHECKER_PATH.read_text(encoding="utf-8")
    if semantic_checker.count('(\"thin_mcp_transport\", \"pending\", \"FUTURE-PARITY-BACKLOG.10.9\")') != 1:
        fail("semantic checker no longer locks the pending MCP rollout")

    if inspect_files:
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
            else:
                fail(f"complete runtime has no consumer validator: {row['runtime']}")
        validate_ci_source(CI_PATH.read_text(encoding="utf-8"), canonical["ordered_commands"])
        validate_authority_sources()


def coordinated_promotion(ledger: dict[str, Any]) -> None:
    for row in ledger["implementations"]:
        row["status"] = "complete"
    for row in ledger["runtime_admissions"]:
        row["status"] = "complete"
    ledger["rollout"]["status"] = "complete"


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
    ("premature Dart implementation", lambda value: value["implementations"][2].__setitem__("status", "complete")),
    ("implementation source", lambda value: value["implementations"][0]["source_paths"].pop()),
    ("Rust implementation source", lambda value: value["implementations"][1]["source_paths"].pop()),
    ("runtime omission", lambda value: value["runtime_admissions"].pop()),
    ("runtime reorder", lambda value: value["runtime_admissions"].reverse()),
    ("Perl admission regression", lambda value: value["runtime_admissions"][0].__setitem__("status", "pending")),
    ("Rust admission regression", lambda value: value["runtime_admissions"][1].__setitem__("status", "pending")),
    ("premature Dart admission", lambda value: value["runtime_admissions"][2].__setitem__("status", "complete")),
    ("Lua ABI ownership", lambda value: value["runtime_admissions"][5].__setitem__("runtime", "lua54")),
    ("Perl consumer path", lambda value: value["runtime_admissions"][0].__setitem__("consumer_path", "wrong")),
    ("Rust consumer path", lambda value: value["runtime_admissions"][1].__setitem__("consumer_path", "wrong")),
    ("premature rollout", lambda value: value["rollout"].__setitem__("status", "complete")),
    ("rollout requirement", lambda value: value["rollout"]["requires_runtime_admissions"].pop()),
    ("coordinated premature promotion", coordinated_promotion),
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

    ci_source = CI_PATH.read_text(encoding="utf-8")
    ci_mutations = [
        ("CI Dart generator omission", ci_source.replace(ORDERED_COMMANDS[4] + "\n", "")),
        ("CI Rust admission omission", ci_source.replace(ORDERED_COMMANDS[9] + "\n", "")),
        ("CI Dart decoded proof omission", ci_source.replace(ORDERED_COMMANDS[10] + "\n", "")),
        (
            "CI Dart strict stdio proof omission",
            ci_source.replace(
                ORDERED_COMMANDS[10],
                "bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart",
                1,
            ),
        ),
        ("CI admission checker omission", ci_source.replace(ORDERED_COMMANDS[11] + "\n", "")),
        ("CI Perl admission omission", ci_source.replace(ORDERED_COMMANDS[12] + "\n", "")),
        (
            "CI checker before Rust admission",
            ci_source.replace(ORDERED_COMMANDS[9], "__RUST_ADMISSION__")
            .replace(ORDERED_COMMANDS[11], ORDERED_COMMANDS[9])
            .replace("__RUST_ADMISSION__", ORDERED_COMMANDS[11]),
        ),
        (
            "CI Rust admission before strict stdio proof",
            ci_source.replace(ORDERED_COMMANDS[8], "__RUST_STDIO__")
            .replace(ORDERED_COMMANDS[9], ORDERED_COMMANDS[8])
            .replace("__RUST_STDIO__", ORDERED_COMMANDS[9]),
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
    ]
    for name, mutant in ci_mutations:
        try:
            validate_ci_source(mutant, ORDERED_COMMANDS)
        except CheckError:
            rejected += 1
            continue
        fail(f"mutation was accepted: {name}")

    perl_source = (ROOT / RUNTIME_ADMISSIONS[0]["consumer_path"]).read_text(encoding="utf-8")
    rust_source = (ROOT / RUNTIME_ADMISSIONS[1]["consumer_path"]).read_text(encoding="utf-8")
    consumer_mutations = [
        ("Perl role omission", perl_source.replace(" contract_inventory\n", "", 1), validate_perl_consumer_source),
        (
            "Rust role omission",
            rust_source.replace('    "contract_inventory",\n', "", 1),
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
        f"2/5 implementations, 2/6 runtimes, rollout pending, {rejected} rejected mutations"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
