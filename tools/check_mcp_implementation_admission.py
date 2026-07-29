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
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.3",
        "source_paths": [],
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
        "status": "pending",
        "owner": "FUTURE-PARITY-BACKLOG.10.9.3",
        "consumer_path": None,
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
    "PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t",
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
        "require_tracked_file t/mcp_server_perl_admission.t",
        "perl -c -Iperl t/mcp_server_perl_admission.t",
    ]
    for line in required:
        if source.count(line) != 1:
            fail(f"canonical tracked/syntax registration drifted: {line}")


def validate_consumer_source(source: str) -> None:
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
    if ledger["decisions"] != ["0054", "0055", "0057"]:
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
    if sum(row["status"] == "complete" for row in ledger["implementations"]) != 1:
        fail("implementation completion count is not exactly one")
    if sum(row["status"] == "complete" for row in ledger["runtime_admissions"]) != 1:
        fail("runtime admission completion count is not exactly one")

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
        consumer_path = ROOT / RUNTIME_ADMISSIONS[0]["consumer_path"]
        if not consumer_path.is_file():
            fail("Perl MCP admission consumer is absent")
        validate_consumer_source(consumer_path.read_text(encoding="utf-8"))
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
    ("premature Rust implementation", lambda value: value["implementations"][1].__setitem__("status", "complete")),
    ("implementation source", lambda value: value["implementations"][0]["source_paths"].pop()),
    ("runtime omission", lambda value: value["runtime_admissions"].pop()),
    ("runtime reorder", lambda value: value["runtime_admissions"].reverse()),
    ("Perl admission regression", lambda value: value["runtime_admissions"][0].__setitem__("status", "pending")),
    ("premature Rust admission", lambda value: value["runtime_admissions"][1].__setitem__("status", "complete")),
    ("Lua ABI ownership", lambda value: value["runtime_admissions"][5].__setitem__("runtime", "lua54")),
    ("Perl consumer path", lambda value: value["runtime_admissions"][0].__setitem__("consumer_path", "wrong")),
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
        ("CI admission checker omission", ci_source.replace(ORDERED_COMMANDS[4] + "\n", "")),
        ("CI Perl admission omission", ci_source.replace(ORDERED_COMMANDS[5] + "\n", "")),
        (
            "CI admission before checker",
            ci_source.replace(ORDERED_COMMANDS[4], "__CHECK__")
            .replace(ORDERED_COMMANDS[5], ORDERED_COMMANDS[4])
            .replace("__CHECK__", ORDERED_COMMANDS[5]),
        ),
        (
            "CI checker before focused server proof",
            ci_source.replace(ORDERED_COMMANDS[3], "__FOCUSED__")
            .replace(ORDERED_COMMANDS[4], ORDERED_COMMANDS[3])
            .replace("__FOCUSED__", ORDERED_COMMANDS[4]),
        ),
        (
            "CI ledger registration omission",
            ci_source.replace(
                "require_tracked_file capability_conformance/mcp_implementation_admission.json\n",
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
        f"1/5 implementations, 1/6 runtimes, rollout pending, {rejected} rejected mutations"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
