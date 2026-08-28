#!/usr/bin/env python3
"""Validate the backend-neutral typed source-location algebra contract."""

from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from typing import Any, Callable


ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "capability_conformance" / "typed_source_location_contract.json"
CHECKER_PATH = ROOT / "tools" / "check_typed_source_location_contract.py"
LUA_CONTRACTS_PATH = ROOT / "lua" / "src" / "linkedspec" / "action_contracts.lua"
PERL_CONTRACTS_PATH = ROOT / "perl" / "LinkedSpec" / "ActionIR" / "Contracts.pm"
PERL_LEGACY_SCANNER_PATH = (
    ROOT / "perl" / "LinkedSpec" / "ActionIR" / "Scanner" / "LegacyRules.pm"
)
CI_PATH = ROOT / "tools" / "run_ci_local.sh"
PERL_VALUE_CONSUMER_PATH = ROOT / "t" / "typed_source_location_values.t"
PERL_PROJECTION_CONSUMER_PATH = ROOT / "t" / "typed_source_location_perl_contract.t"
RUST_CONSUMER_PATH = (
    ROOT / "rust" / "linkedspec-runtime" / "tests" / "typed_source_location_contract.rs"
)
RUST_OBSERVATION_CONSUMER_PATH = (
    ROOT / "rust" / "linkedspec-runtime" / "tests" / "recursive_observation_contract.rs"
)
DART_CONSUMER_PATH = (
    ROOT / "dart" / "test" / "typed_source_location_contract_test.dart"
)
DART_OBSERVATION_CONSUMER_PATH = (
    ROOT / "dart" / "test" / "recursive_observation_contract_test.dart"
)
DART_DORMANT_CONSUMER_PATH = (
    ROOT / "dart" / "test_dormant" / "typed_source_location_contract_test.dart"
)
JULIA_CONSUMER_PATH = ROOT / "julia" / "test" / "typed_source_location_contract_test.jl"
JULIA_OBSERVATION_CONSUMER_PATH = (
    ROOT / "julia" / "test" / "recursive_observation_contract_test.jl"
)
JULIA_RUNTESTS_PATH = ROOT / "julia" / "test" / "runtests.jl"
LUA_CONSUMER_PATH = ROOT / "lua" / "test" / "typed_source_location_contract_test.lua"
LUA_OBSERVATION_CONSUMER_PATH = (
    ROOT / "lua" / "test" / "recursive_observation_contract_test.lua"
)
LUA_ORDINARY_DRIVER_PATH = ROOT / "tools" / "run_lua_local.sh"
RECURRING_DRIVER_PATH = ROOT / "tools" / "check_typed_source_location_six_runtime.sh"
RECURSIVE_OBSERVATION_RECURRING_DRIVER_PATH = (
    ROOT / "tools" / "check_recursive_observation_six_runtime.sh"
)
PROGRESSIVE_SPAN_DISPATCH_RECURRING_DRIVER_PATH = (
    ROOT / "tools" / "check_progressive_span_dispatch_six_runtime.sh"
)
STAGED_AST_ENRICHMENT_RECURRING_DRIVER_PATH = (
    ROOT / "tools" / "check_staged_ast_enrichment_six_runtime.sh"
)
TYPED_AUTHORING_MODEL_RECURRING_DRIVER_PATH = (
    ROOT / "tools" / "check_typed_authoring_model_six_runtime.sh"
)
STAGED_AST_ENRICHMENT_CONTRACT_PATH = (
    ROOT / "capability_conformance" / "staged_ast_enrichment_contract.json"
)
LOSSLESS_GAP_CONTRACT_PATH = (
    ROOT / "capability_conformance" / "inter_match_gap_capture_contract.json"
)
LOSSLESS_GAP_CHECKER_PATH = ROOT / "tools" / "check_inter_match_gap_capture_contract.py"
LOSSLESS_GAP_DRIVER_PATH = ROOT / "tools" / "check_inter_match_gap_capture_six_runtime.sh"
TYPED_GAP_COMPOSITION_DRIVER_PATH = (
    ROOT / "tools" / "check_typed_gap_composition_six_runtime.sh"
)
RECOGNITION_TRANSACTION_CONTRACT_PATH = (
    ROOT / "capability_conformance" / "recognition_transaction_contract.json"
)
RECOGNITION_TRANSACTION_CHECKER_PATH = (
    ROOT / "tools" / "check_recognition_transaction_contract.py"
)
RECOGNITION_TRANSACTION_DRIVER_PATH = (
    ROOT / "tools" / "check_recognition_transaction_six_runtime.sh"
)
PROJECT_DATA_WORKFLOW_ROUTING_PATH = ROOT / "tools" / "test_project_data_workflow_routing.sh"

EXPECTED_COUNTS = {
    "sources": 3,
    "position_conversions": 7,
    "direct_spans": 6,
    "derived_text_cases": 3,
    "invocation_transitions": 8,
    "transaction_transitions": 8,
    "recursive_observation_transitions": 33,
    "recursive_observations": 6,
    "structural_authoring_cases": 4,
    "helper_projections": 92,
    "compatibility_aliases": 7,
    "internal_contract_ids": 2,
    "diagnostics": 33,
    "rollout_legs": 14,
    "recurring_source_groups": 5,
    "recurring_runtime_routes": 6,
    "recursive_observation_recurring_source_groups": 5,
    "recursive_observation_recurring_runtime_routes": 6,
    "progressive_span_dispatch_recurring_source_groups": 5,
    "progressive_span_dispatch_recurring_runtime_routes": 6,
    "staged_ast_enrichment_recurring_source_groups": 5,
    "staged_ast_enrichment_recurring_runtime_routes": 6,
    "recursive_observation_public_documents": 6,
    "recursive_observation_public_forbidden_claims": 6,
    "recursive_observation_public_surface_guard_paths": 10,
    "program_wide_recurring_drivers": 6,
    "program_wide_public_documents": 8,
    "program_wide_public_forbidden_claims": 8,
    "program_wide_authoring_safety_claims": 6,
    "program_wide_public_surface_guard_paths": 10,
    "mutations": 231,
}

POLICY = {
    "source_identity": "caller-authorized decoded input identity; never a path, backend object, or implicit read authority",
    "position": "immutable source identity plus a zero-based Unicode-scalar offset in the closed input interval",
    "span": "immutable same-source half-open interval with start not greater than end; empty spans are valid",
    "coordinates": "Unicode-scalar offset is authoritative; one-based line and column plus UTF-8 byte offset are derived evidence",
    "direct_text": "materialize text on demand from one direct span; a span never embeds copied text or host state",
    "derived_text": "concatenate an ordered provenance sequence explicitly; never pretend derived text is one contiguous interval",
    "invocation_state": "cursor, anonymous boundary, and marks are mutable only inside one invocation; public projections are immutable",
    "transactions": "one bounded recognition-only attempt snapshots cursor, boundary, and marks; commit or rollback invalidates its token",
    "transaction_effects": "rollback never restores user variables, AST mutation, diagnostics, output, external calls, registry effects, or host state",
    "recursion": "entry, selected-match, and accepted-exit observations are read-only; invocation ids are positive, unique, and monotonic; nullable parents are distinct earlier same-authority ids with bounded acyclic links",
    "progress": "repetition, recursion, and staged queues must advance the cursor or prove a well-founded decreasing measure",
    "dispatch_authority": "a span conveys data and provenance only; source, registry, capability, and policy authority remain independently required",
    "source_spelling": "observe_recognition(observation, call(Child)) and private value = dispatch_span(\"expr-v1\", \"Expr\", span) are current in Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; Position and Span remain private architectural values projected as detached records",
    "implementation_boundary": "recognition transaction safety, recursive-observation spelling, dedicated private nodes, detached carriers, parser behavior, exact typed-source, transaction, recursive-observation, lossless-gap, progressive-span, and staged-AST six-runtime recurring composition, and combined program-wide public no-drift are current; this is not a second transaction, gap, progressive, or staged syntax, lifecycle, implementation, compatibility, or migration owner, and no public helper, descriptor/schema version, or semantic/MCP projection is admitted",
}

CANONICAL_EXECUTION = {
    "contract_path": "capability_conformance/typed_source_location_contract.json",
    "checker_path": "tools/check_typed_source_location_contract.py",
    "project_data_runner": "tools/run_python_project_data.sh",
    "canonical_driver": "tools/run_ci_local.sh",
    "invocation": "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py",
    "tracked_required": True,
}

RECURRING_GATE = {
    "driver": "tools/check_typed_source_location_six_runtime.sh",
    "source_schema": {
        "fields": ["backend", "paths"],
        "policy": "five backend source groups are immutable; Perl owns its separate value and projection tests and Lua owns one source shared by both ABIs",
    },
    "consumer_sources": [
        {
            "backend": "perl",
            "paths": [
                "t/typed_source_location_values.t",
                "t/typed_source_location_perl_contract.t",
                "t/recursive_observation_perl_contract.t",
            ],
        },
        {
            "backend": "rust",
            "paths": [
                "rust/linkedspec-runtime/tests/typed_source_location_contract.rs",
                "rust/linkedspec-runtime/tests/recursive_observation_contract.rs",
            ],
        },
        {
            "backend": "dart",
            "paths": [
                "dart/test/typed_source_location_contract_test.dart",
                "dart/test/recursive_observation_contract_test.dart",
            ],
        },
        {
            "backend": "julia",
            "paths": [
                "julia/test/typed_source_location_contract_test.jl",
                "julia/test/recursive_observation_contract_test.jl",
            ],
        },
        {
            "backend": "lua",
            "paths": [
                "lua/test/typed_source_location_contract_test.lua",
                "lua/test/recursive_observation_contract_test.lua",
            ],
        },
    ],
    "route_schema": {
        "fields": ["runtime", "source_backend", "command"],
        "policy": "neutral runs first; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT then run exactly once in order",
    },
    "runtime_routes": [
        {
            "runtime": "perl",
            "source_backend": "perl",
            "command": "PERL5LIB= prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t t/recursive_observation_perl_contract.t",
        },
        {
            "runtime": "rust",
            "source_backend": "rust",
            "command": '"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract --test recursive_observation_contract',
        },
        {
            "runtime": "dart",
            "source_backend": "dart",
            "command": "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/typed_source_location_contract_test.dart test/recursive_observation_contract_test.dart",
        },
        {
            "runtime": "julia",
            "source_backend": "julia",
            "command": "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/typed_source_location_contract_test.jl\"); include(\"julia/test/recursive_observation_contract_test.jl\")'",
        },
        {
            "runtime": "puc_lua",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua && bash tools/run_lua_project_data.sh puc lua/test/recursive_observation_contract_test.lua",
        },
        {
            "runtime": "luajit",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/recursive_observation_contract_test.lua",
        },
    ],
    "support_checks": [
        "perl tools/check_generated_source_contract.pl",
        "perl tools/check_capability_conformance.pl",
        "perl tools/check_language_capability_coverage.pl",
    ],
    "local_ci": {
        "driver": "tools/run_ci_local.sh",
        "switch": "LINKEDSPEC_RUN_TYPED_SOURCE_MATRIX",
    },
}

RECURSIVE_OBSERVATION_RECURRING_GATE = {
    "driver": "tools/check_recursive_observation_six_runtime.sh",
    "source_schema": {
        "fields": ["backend", "paths"],
        "policy": "five admitted recursive-observation source groups are immutable; one shared Lua source executes independently on both ABIs",
    },
    "consumer_sources": [
        {"backend": "perl", "paths": ["t/recursive_observation_perl_contract.t"]},
        {
            "backend": "rust",
            "paths": [
                "rust/linkedspec-runtime/tests/recursive_observation_contract.rs"
            ],
        },
        {
            "backend": "dart",
            "paths": ["dart/test/recursive_observation_contract_test.dart"],
        },
        {
            "backend": "julia",
            "paths": ["julia/test/recursive_observation_contract_test.jl"],
        },
        {
            "backend": "lua",
            "paths": ["lua/test/recursive_observation_contract_test.lua"],
        },
    ],
    "route_schema": {
        "fields": ["runtime", "source_backend", "command"],
        "policy": "neutral runs first; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT then run exactly once in order",
    },
    "runtime_routes": [
        {
            "runtime": "perl",
            "source_backend": "perl",
            "command": "PERL5LIB= prove -Iperl t/recursive_observation_perl_contract.t",
        },
        {
            "runtime": "rust",
            "source_backend": "rust",
            "command": '"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recursive_observation_contract',
        },
        {
            "runtime": "dart",
            "source_backend": "dart",
            "command": "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/recursive_observation_contract_test.dart",
        },
        {
            "runtime": "julia",
            "source_backend": "julia",
            "command": "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/recursive_observation_contract_test.jl\")'",
        },
        {
            "runtime": "puc_lua",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh puc lua/test/recursive_observation_contract_test.lua",
        },
        {
            "runtime": "luajit",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh luajit lua/test/recursive_observation_contract_test.lua",
        },
    ],
    "support_checks": [
        "perl tools/check_generated_source_contract.pl",
        "perl tools/check_capability_conformance.pl",
        "perl tools/check_language_capability_coverage.pl",
    ],
    "storage": {
        "initializer": "tools/project_data_env.sh",
        "managed_entrypoint": "tools/check_recursive_observation_six_runtime.sh",
        "policy": "all temporary, cache, build, native, and test data stays under repository-derived storage",
    },
    "local_ci": {
        "driver": "tools/run_ci_local.sh",
        "switch": "LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX",
    },
}

PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE = {
    "driver": "tools/check_progressive_span_dispatch_six_runtime.sh",
    "neutral_check": "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py",
    "source_schema": {
        "fields": ["backend", "paths"],
        "policy": "five admitted progressive span-dispatch source groups are immutable; one shared Lua source executes independently on both ABIs",
    },
    "consumer_sources": [
        {"backend": "perl", "paths": ["t/progressive_span_dispatch_perl_contract.t"]},
        {
            "backend": "rust",
            "paths": [
                "rust/linkedspec-runtime/tests/progressive_span_dispatch_contract.rs"
            ],
        },
        {
            "backend": "dart",
            "paths": ["dart/test/progressive_span_dispatch_contract_test.dart"],
        },
        {
            "backend": "julia",
            "paths": ["julia/test/progressive_span_dispatch_contract_test.jl"],
        },
        {
            "backend": "lua",
            "paths": ["lua/test/progressive_span_dispatch_contract_test.lua"],
        },
    ],
    "route_schema": {
        "fields": ["runtime", "source_backend", "command"],
        "policy": "neutral runs first; Perl, cfg-enabled Rust, Dart, Julia, PUC Lua, and LuaJIT then run exactly once in order",
    },
    "runtime_routes": [
        {
            "runtime": "perl",
            "source_backend": "perl",
            "command": "PERL5LIB= prove -Iperl t/progressive_span_dispatch_perl_contract.t",
        },
        {
            "runtime": "rust",
            "source_backend": "rust",
            "command": "RUSTFLAGS='--cfg linkedspec_progressive_span_dispatch_red' \"$CARGO_CMD\" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test progressive_span_dispatch_contract",
        },
        {
            "runtime": "dart",
            "source_backend": "dart",
            "command": "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/progressive_span_dispatch_contract_test.dart",
        },
        {
            "runtime": "julia",
            "source_backend": "julia",
            "command": "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/progressive_span_dispatch_contract_test.jl\")'",
        },
        {
            "runtime": "puc_lua",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh puc lua/test/progressive_span_dispatch_contract_test.lua",
        },
        {
            "runtime": "luajit",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh luajit lua/test/progressive_span_dispatch_contract_test.lua",
        },
    ],
    "support_checks": [
        "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py",
        "perl tools/check_generated_source_contract.pl",
        "perl tools/check_capability_conformance.pl",
        "perl tools/check_language_capability_coverage.pl",
    ],
    "storage": {
        "initializer": "tools/project_data_env.sh",
        "managed_entrypoint": "tools/check_progressive_span_dispatch_six_runtime.sh",
        "policy": "all temporary, cache, build, native, and test data stays under repository-derived storage",
    },
    "local_ci": {
        "driver": "tools/run_ci_local.sh",
        "switch": "LINKEDSPEC_RUN_PROGRESSIVE_SPAN_MATRIX",
    },
    "rollout_assertions": {
        "row_count": 14,
        "progressive_span_dispatch": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.6",
        },
        "staged_span_dispatch": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.7",
        },
        "recurring_public_no_drift": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.8",
        },
    },
}

STAGED_AST_ENRICHMENT_RECURRING_GATE = {
    "driver": "tools/check_staged_ast_enrichment_six_runtime.sh",
    "neutral_check": "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py",
    "source_schema": {
        "fields": ["backend", "paths"],
        "policy": "five admitted staged-AST enrichment source groups are immutable; one shared Lua source executes independently on both ABIs",
    },
    "consumer_sources": [
        {"backend": "perl", "paths": ["t/staged_ast_enrichment_perl_contract.t"]},
        {
            "backend": "rust",
            "paths": ["rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs"],
        },
        {
            "backend": "dart",
            "paths": ["dart/test/staged_ast_enrichment_contract_test.dart"],
        },
        {
            "backend": "julia",
            "paths": ["julia/test/staged_ast_enrichment_contract_test.jl"],
        },
        {
            "backend": "lua",
            "paths": ["lua/test/staged_ast_enrichment_contract_test.lua"],
        },
    ],
    "route_schema": {
        "fields": ["runtime", "source_backend", "command"],
        "policy": "neutral runs first; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT then run exactly once in order",
    },
    "runtime_routes": [
        {
            "runtime": "perl",
            "source_backend": "perl",
            "command": "PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t",
        },
        {
            "runtime": "rust",
            "source_backend": "rust",
            "command": '"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract',
        },
        {
            "runtime": "dart",
            "source_backend": "dart",
            "command": "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart",
        },
        {
            "runtime": "julia",
            "source_backend": "julia",
            "command": "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl",
        },
        {
            "runtime": "puc_lua",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua",
        },
        {
            "runtime": "luajit",
            "source_backend": "lua",
            "command": "bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua",
        },
    ],
    "support_checks": [
        "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py",
        "perl tools/check_generated_source_contract.pl",
        "perl tools/check_capability_conformance.pl",
        "perl tools/check_language_capability_coverage.pl",
    ],
    "storage": {
        "initializer": "tools/project_data_env.sh",
        "managed_entrypoint": "tools/check_staged_ast_enrichment_six_runtime.sh",
        "policy": "all temporary, cache, build, native, and test data stays under repository-derived storage",
    },
    "local_ci": {
        "driver": "tools/run_ci_local.sh",
        "switch": "LINKEDSPEC_RUN_STAGED_AST_ENRICHMENT_MATRIX",
    },
    "rollout_assertions": {
        "row_count": 14,
        "staged_span_dispatch": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.7",
        },
        "recurring_public_no_drift": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.8",
        },
    },
    "capability_projection": {
        "manifest": "capability_conformance/manifest.json",
        "capability_id": "language.staged_ast_enrichment",
        "backend_status": "pass",
        "public_authoring_contract": "capability_conformance/staged_ast_enrichment_contract.json",
        "public_authoring_status": "current",
    },
}

RECURSIVE_OBSERVATION_PUBLIC_NO_DRIFT = {
    "owner": "FUTURE-PARITY-BACKLOG.14.4.8",
    "status": "complete",
    "policy": "current public documentation must describe the private recursive-observation spelling and exact six-runtime proof without admitting a public helper, authored Position/Span value, facade export, descriptor/generated or result schema, semantic/MCP field, CLI option, README behavior, runtime change, or storage-root change",
    "rollout_assertions": {
        "row_count": 14,
        "recursive_observation": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.4",
        },
        "recurring_public_no_drift": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.8",
        },
    },
    "documents": [
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "required_markers": [
                "Recursive-observation public projection/no-drift is current: the private authored spelling and exact six-runtime proof are documented without adding a public API."
            ],
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "required_markers": [
                "Recursive-observation public projection is current without a public facade, value, schema, semantic/MCP, CLI, or README admission."
            ],
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "required_markers": [
                "Recursive-observation public no-drift remains current under `.14.4.8`; final combined `.14.8` is now complete."
            ],
        },
        {
            "path": "docs/linkedspec-book/src/development/local-ci-and-regression.md",
            "required_markers": [
                "The recursive-observation public projection/no-drift check is current and does not promote the combined program-wide rollout row."
            ],
        },
        {
            "path": "capability_conformance/README.md",
            "required_markers": [
                "Recursive-observation public projection/no-drift is current without a new public API; its own rollout row remains complete."
            ],
        },
        {
            "path": "TOOLBOX.md",
            "required_markers": [
                "Recursive-observation public projection/no-drift is current without moving any public or runtime surface."
            ],
        },
    ],
    "forbidden_claims": [
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "public closeout remains",
        },
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "text": "final public no-drift remains pending",
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "text": "public `.8` follows",
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "text": "Public closeout remains `.14.4.8` and the combined final `.14.8` row.",
        },
        {
            "path": "docs/linkedspec-book/src/development/local-ci-and-regression.md",
            "text": "Public no-drift remains pending.",
        },
        {
            "path": "TOOLBOX.md",
            "text": "Public no-drift remains pending;",
        },
    ],
    "surface_guard": {
        "paths": [
            "perl/LinkedSpec.pm",
            "rust/linkedspec-runtime/src/lib.rs",
            "dart/lib/linkedspec_dart.dart",
            "julia/src/LinkedSpecJulia.jl",
            "lua/src/linkedspec/init.lua",
            "capability_conformance/outward_descriptor_contract.json",
            "capability_conformance/semantic_introspection_model.json",
            "capability_conformance/mcp_semantic_transport/schema.json",
            "cli_conformance/manifest.json",
            "README.md",
        ],
        "forbidden_tokens": [
            "observe_recognition",
            "ObserveRecognition",
            "ActionObserveRecognitionExpr",
            "RecursiveObservation",
            "OBSERVE_RECOGNITION",
        ],
    },
}

RECURSIVE_OBSERVATION_PUBLIC_MUTATION_COUNT = 18

TRANSACTION_SAFETY_COMPOSITION = {
    "owner": "FUTURE-PARITY-BACKLOG.14.6.0.1",
    "status": "complete",
    "policy": "project the separately owned current recognition-transaction authority into the typed cursor algebra without duplicating syntax, runtime behavior, recurrence, or public admission",
    "upstream_recognition_authority": {
        "contract_id": "linkedspec-recognition-transaction-v1",
        "contract_path": "capability_conformance/recognition_transaction_contract.json",
        "checker_path": "tools/check_recognition_transaction_contract.py",
        "driver_path": "tools/check_recognition_transaction_six_runtime.sh",
        "status": "neutral_runtime_recurring_and_public_no_drift_complete",
        "rollout": {"complete": 9, "pending": 0, "semantic_mutations": 58},
        "topology": {"source_groups": 5, "runtime_routes": 6},
        "effects": {
            "allowed": 9,
            "rejected": 11,
            "uncommitted_dispatch_effect": "parser_registry_or_staged_dispatch",
        },
        "progress": {
            "cases": 8,
            "policy": "every accepted repetition iteration and accepted direct or mutual recursive cycle edge requires end_offset greater than start_offset",
        },
        "public_no_drift": {"documents": 3, "forbidden_claims": 26, "mutations": 45},
        "capability_guide_no_drift": {"documents": 1, "forbidden_claims": 14, "mutations": 18},
    },
    "typed_projection": {
        "leg": "transaction_safety",
        "representation": "one opaque linear recognition token snapshots and may restore only the owning invocation cursor, anonymous boundary, and named marks",
        "effect_boundary": "uncommitted recognition rejects registry or staged dispatch and every other non-recognition effect before commit",
        "progress_boundary": "rolled-back work does not establish progress; accepted repetition and recursive-cycle edges require cursor advance",
        "runtimes": ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
        "behavior_owner": "FUTURE-PARITY-BACKLOG.14.3 owns syntax, runtime behavior, recurrence, and public no-drift",
    },
    "current_projection_no_drift": {
        "documents": [
            {
                "path": "docs/knowledge/cursor-transaction-authored-contract.md",
                "required_markers": [
                    "Recognition transactions are current on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; the exact recurring and public no-drift rollout is 9/9 complete."
                ],
            },
            {
                "path": "docs/knowledge/cursor-transaction-safety-audit-plan.md",
                "required_markers": [
                    "The implementation program is complete across neutral authority, Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, recurrence, and public no-drift."
                ],
            },
            {
                "path": "docs/knowledge/typed-source-location-cursor-algebra-direction.md",
                "required_markers": [
                    "Typed transaction, progressive span-dispatch, staged-AST composition, and combined public no-drift are current at six runtimes and the typed rollout is 14 complete / 0 pending."
                ],
            },
            {
                "path": "docs/linkedspec-book/src/overview/project-status.md",
                "required_markers": [
                    "All 14 typed source-location rollout legs are complete; combined program-wide public no-drift is current."
                ],
            },
            {
                "path": "capability_conformance/README.md",
                "required_markers": [
                    "Combined typed authoring-model governance is complete at 14/14 under the composed six-runtime proof."
                ],
            },
        ],
        "forbidden_claims": [
            {"path": "docs/knowledge/cursor-transaction-authored-contract.md", "text": "status: accepted authored/static contract; current on Perl and Rust; other runtime support pending"},
            {"path": "docs/knowledge/cursor-transaction-authored-contract.md", "text": "current on Perl and Rust and future on the other runtimes"},
            {"path": "docs/knowledge/cursor-transaction-authored-contract.md", "text": "These spellings and rules are current executable syntax on the independently admitted Perl and Rust backends."},
            {"path": "docs/knowledge/cursor-transaction-safety-audit-plan.md", "text": "status: behavior-free audit frozen; exact future authored/static contract ratified; executable implementation pending"},
            {"path": "docs/knowledge/typed-source-location-cursor-algebra-direction.md", "text": "lossless-gap handoff frozen"},
            {"path": "docs/linkedspec-book/src/overview/project-status.md", "text": "Ten of 14 rollout legs are complete and 4 remain pending."},
            {"path": "docs/linkedspec-book/src/overview/project-status.md", "text": "their rollout is 10 complete / 4 pending"},
            {"path": "capability_conformance/README.md", "text": "Current governance is 126 mutations and rollout is 10 complete / 4 pending across 14 legs:"},
            {"path": "docs/knowledge/typed-source-location-cursor-algebra-direction.md", "text": "Typed transaction composition is current at six runtimes and the typed rollout is 11 complete / 3 pending."},
            {"path": "docs/linkedspec-book/src/overview/project-status.md", "text": "Typed transaction composition is now current at 11 complete / 3 pending; progressive dispatch, staged dispatch, and combined program-wide no-drift remain pending."},
            {"path": "capability_conformance/README.md", "text": "Typed transaction composition is current and promotes only `transaction_safety`; the typed rollout is 11 complete / 3 pending."},
            {"path": "capability_conformance/README.md", "text": "Its rollout is 2/9 complete (neutral and Perl), with Rust, Dart, Julia, PUC Lua, LuaJIT,"},
            {"path": "capability_conformance/README.md", "text": "The typed `progressive_span_dispatch` row remains pending until exact six-runtime recurrence owner"},
        ],
    },
    "rollout_assertions": {
        "row_count": 14,
        "transaction_safety": {"status": "complete", "owner": "FUTURE-PARITY-BACKLOG.14.3"},
        "progressive_span_dispatch": {"status": "complete", "owner": "FUTURE-PARITY-BACKLOG.14.6"},
        "staged_span_dispatch": {"status": "complete", "owner": "FUTURE-PARITY-BACKLOG.14.7"},
        "recurring_public_no_drift": {"status": "complete", "owner": "FUTURE-PARITY-BACKLOG.14.8"},
    },
}

TRANSACTION_SAFETY_COMPOSITION_PUBLIC_MUTATION_COUNT = 15

LOSSLESS_GAP_COMPOSITION = {
    "owner": "FUTURE-PARITY-BACKLOG.14.5.1",
    "status": "complete",
    "policy": "compose the separately owned current gap-span carrier with the typed same-source half-open algebra; do not duplicate gap syntax, lifecycle, implementation, compatibility, migration, or public-admission ownership",
    "upstream_gap_authority": {
        "contract_id": "linkedspec-inter-match-gap-capture-v1",
        "contract_path": "capability_conformance/inter_match_gap_capture_contract.json",
        "checker_path": "tools/check_inter_match_gap_capture_contract.py",
        "driver_path": "tools/check_inter_match_gap_capture_six_runtime.sh",
        "rollout": {"complete": 9, "pending": 0, "semantic_mutations": 63},
        "public": {
            "documents": 6,
            "forbidden_current_claims": 12,
            "surface_guard_paths": 10,
            "mutations": 29,
        },
    },
    "typed_projection": {
        "call": "gap_span",
        "representation": "detached typed same-source half-open Unicode-scalar span with source identity and gap provenance",
        "segment_kinds": ["prefix", "interstitial", "tail"],
        "slot_identity": "entry_slot preserves named or positional target-slot provenance independently of the gap span",
        "text_materialization": "gap_text materializes on demand; gap_span never embeds copied text",
        "behavior_owner": "INTER-MATCH-GAP-CAPTURE.1-.7 owns syntax, lifecycle, implementation, compatibility, migration, and public admission",
    },
    "recurring_gate": {
        "driver": "tools/check_typed_gap_composition_six_runtime.sh",
        "ordered_checks": [
            "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py",
            "bash tools/check_inter_match_gap_capture_six_runtime.sh",
            "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py",
            "perl tools/check_generated_source_contract.pl",
            "perl tools/check_capability_conformance.pl",
            "perl tools/check_language_capability_coverage.pl",
        ],
        "storage": {
            "initializer": "tools/project_data_env.sh",
            "managed_entrypoint": "tools/check_typed_gap_composition_six_runtime.sh",
            "policy": "all temporary, cache, build, native, and test data stays under repository-derived storage",
        },
        "local_ci": {
            "driver": "tools/run_ci_local.sh",
            "switch": "LINKEDSPEC_RUN_TYPED_GAP_COMPOSITION_MATRIX",
        },
    },
    "rollout_assertions": {
        "row_count": 14,
        "lossless_gap_composition": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.5",
        },
        "recurring_public_no_drift": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.8",
        },
    },
}

PROGRAM_WIDE_PUBLIC_NO_DRIFT = {
    "owner": "FUTURE-PARITY-BACKLOG.14.8",
    "status": "complete",
    "policy": "compose the six existing recurring authorities and lock the complete authoring-model projection without adding a rollout row, behavior oracle, parser/compiler/runtime/value/helper/carrier/outward/capability/CLI/storage change, or public authored Position/Span type",
    "recurring_composition": {
        "driver": "tools/check_typed_authoring_model_six_runtime.sh",
        "ordered_drivers": [
            "tools/check_typed_source_location_six_runtime.sh",
            "tools/check_recognition_transaction_six_runtime.sh",
            "tools/check_recursive_observation_six_runtime.sh",
            "tools/check_typed_gap_composition_six_runtime.sh",
            "tools/check_progressive_span_dispatch_six_runtime.sh",
            "tools/check_staged_ast_enrichment_six_runtime.sh",
        ],
        "execution_policy": "run the six existing fail-fast authorities in order; each remains the sole oracle for its owned behavior and runtime topology",
        "storage": {
            "initializer": "tools/project_data_env.sh",
            "managed_entrypoint": "tools/check_typed_authoring_model_six_runtime.sh",
            "policy": "all temporary, cache, build, native, and test data stays under repository-derived storage",
        },
        "local_ci": {
            "driver": "tools/run_ci_local.sh",
            "switch": "LINKEDSPEC_RUN_TYPED_AUTHORING_MODEL_MATRIX",
        },
    },
    "rollout_assertions": {
        "row_count": 14,
        "complete": 14,
        "pending": 0,
        "recurring_public_no_drift": {
            "status": "complete",
            "owner": "FUTURE-PARITY-BACKLOG.14.8",
        },
    },
    "documents": [
        {
            "path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md",
            "required_markers": [
                "Combined typed authoring-model public no-drift is current: all 14 rollout legs are complete under the composed six-runtime recurring proof."
            ],
        },
        {
            "path": "docs/linkedspec-book/src/appendix/backend-handoff.md",
            "required_markers": [
                "Combined typed authoring-model public no-drift is current with 14/14 rollout legs complete and no new runtime or public API."
            ],
        },
        {
            "path": "docs/linkedspec-book/src/overview/project-status.md",
            "required_markers": [
                "All 14 typed source-location rollout legs are complete; combined program-wide public no-drift is current."
            ],
        },
        {
            "path": "docs/linkedspec-book/src/development/local-ci-and-regression.md",
            "required_markers": [
                "`bash tools/check_typed_authoring_model_six_runtime.sh` is the composed authoring-model proof; canonical CI opts into it with `LINKEDSPEC_RUN_TYPED_AUTHORING_MODEL_MATRIX=1`."
            ],
        },
        {
            "path": "capability_conformance/README.md",
            "required_markers": [
                "Combined typed authoring-model governance is complete at 14/14 under the composed six-runtime proof."
            ],
        },
        {
            "path": "TOOLBOX.md",
            "required_markers": [
                "Combined typed authoring-model public no-drift is current at 14 complete / 0 pending."
            ],
        },
        {
            "path": "docs/knowledge/typed-source-location-runtime-rollout-plan.md",
            "required_markers": [
                "Combined program-wide public no-drift is current at 14 complete / 0 pending under `FUTURE-PARITY-BACKLOG.14.8`."
            ],
        },
        {
            "path": "docs/knowledge/typed-authoring-model-public-no-drift.md",
            "required_markers": [
                "The final combined authoring-model row is current: 14 complete / 0 pending under one composed six-runtime proof."
            ],
        },
    ],
    "forbidden_claims": [
        {"path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md", "text": "Only combined program-wide no-drift remains pending."},
        {"path": "docs/linkedspec-book/src/appendix/backend-handoff.md", "text": "recurring/public no-drift row stays pending for final program-wide owner"},
        {"path": "docs/linkedspec-book/src/overview/project-status.md", "text": "combined program-wide no-drift remains pending."},
        {"path": "docs/linkedspec-book/src/development/local-ci-and-regression.md", "text": "the combined typed row remains pending."},
        {"path": "capability_conformance/README.md", "text": "The combined `recurring_public_no_drift` row remains pending"},
        {"path": "TOOLBOX.md", "text": "The combined program-wide `.14.8` row remains pending"},
        {"path": "docs/knowledge/typed-source-location-runtime-rollout-plan.md", "text": "status: six internal value/projection and recursive-observation runtimes admitted; recurrence and recursive-observation public projection current; combined program-wide closeout pending"},
        {"path": "docs/knowledge/typed-authoring-model-public-no-drift.md", "text": "combined program-wide public no-drift remains pending"},
    ],
    "authoring_safety": {
        "forbidden_claims": [
            {"path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md", "text": "capture_take_slice("},
            {"path": "docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md", "text": "capture_take_slice_len("},
            {"path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md", "text": "save_cursor() and restore_cursor() provide transactional rollback"},
            {"path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md", "text": "restore_cursor() can roll back AST, output, diagnostics, or registry effects"},
            {"path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md", "text": "a parent may reset the cursor before calling a child"},
            {"path": "docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md", "text": "mark or variable changes satisfy recursive progress without cursor advance"},
        ],
    },
    "surface_guard": {
        "paths": [
            "perl/LinkedSpec.pm",
            "rust/linkedspec-runtime/src/lib.rs",
            "dart/lib/linkedspec_dart.dart",
            "julia/src/LinkedSpecJulia.jl",
            "lua/src/linkedspec/init.lua",
            "capability_conformance/outward_descriptor_contract.json",
            "capability_conformance/semantic_introspection_model.json",
            "capability_conformance/mcp_semantic_transport/schema.json",
            "cli_conformance/manifest.json",
            "README.md",
        ],
        "forbidden_tokens": [
            "capture_take_slice",
            "capture_take_slice_len",
            "ObserveRecognition",
            "ActionObserveRecognitionExpr",
            "PROGRESSIVE_DISPATCH_SPAN",
            "STAGED_PARSE_JOB",
        ],
    },
}

PROGRAM_WIDE_PUBLIC_MUTATION_COUNT = 26

HELPER_GROUPS = {
    "capture_mark": "CAPTURE_MARK_HELPERS",
    "entry_match": "ENTRY_MATCH_HELPERS",
    "input_cursor": "INPUT_HELPERS",
    "cursor_control": "RUNTIME_HELPERS",
}

PROJECTION_VOCABULARY = [
    "capture_boundary_write_position",
    "capture_group_exists",
    "capture_group_list",
    "capture_group_map",
    "capture_group_text",
    "cursor_checkpoint_compatibility",
    "cursor_position",
    "cursor_state_write_compatibility",
    "mark_delete",
    "mark_exists",
    "mark_read_column",
    "mark_read_line",
    "mark_read_offset",
    "mark_write_position",
    "position_column",
    "position_line",
    "position_offset",
    "source_length",
    "source_slice_text",
    "source_text",
    "span_length",
    "span_start_column",
    "span_start_line",
    "span_start_offset",
    "span_text",
]

ALIASES = [
    ("capture_from_rule_start", "capture_slice"),
    ("capture_len_from_rule_start", "capture_slice_len"),
    ("capture_rest_length", "capture_rest_len"),
    ("capture_slice_here", "start_capture_slice"),
    ("capture_slice_length", "capture_slice_len"),
    ("entry_named_map", "entry_map"),
    ("match_named_map", "match_map"),
]


def extract_perl_contract_record(source: str, helper: str) -> str:
    record = re.search(
        rf"\n  \{{\n\s*id\s*=>\s*'{re.escape(helper)}',(?P<body>.*?)\n  \}},",
        source,
        re.DOTALL,
    )
    if record is None:
        fail(f"Perl contract authority is missing helper record {helper!r}")
    return record.group(0)


def extract_perl_record_field(record: str, helper: str, field: str) -> str:
    value = re.search(rf"\b{re.escape(field)}\s*=>\s*'([^']+)'", record)
    if value is None:
        fail(f"Perl helper record {helper!r} is missing field {field!r}")
    return value.group(1)


def extract_perl_runtime_calls(record: str) -> list[str]:
    return re.findall(r"LinkedSpec::SourceLocation::Runtime::([a-z_]+)\s*\(", record)

INTERNAL_CONTRACT_IDS = [
    ("capture_take_slice", "capture_take"),
    ("capture_take_slice_len", "capture_take_len"),
]

RECURSIVE_OBSERVATIONS = [
    ("ordinary_leaf", "Leaf", 2, 1, "unicode", 2, "unicode_emoji_tail", 4, "accepted", None),
    ("zero_regex_coordinator", "Coordinator", 3, None, "unicode", 0, None, 4, "accepted", None),
    ("failed_selection", "Missing", 5, 4, "unicode", 0, None, None, "failed", None),
    ("abnormal_exit", "AbortChild", 7, 6, "unicode", 2, "unicode_emoji_tail", None, "aborted", None),
    (
        "direct_nonprogress",
        "DirectRecur",
        9,
        8,
        "unicode",
        1,
        None,
        None,
        "rejected",
        "source_location_nonprogress_direct_recursion",
    ),
    (
        "mutual_nonprogress",
        "MutualA",
        11,
        10,
        "unicode",
        1,
        None,
        None,
        "rejected",
        "source_location_nonprogress_mutual_recursion",
    ),
]

STRUCTURAL_CASES = [
    (
        "zero_regex_coordinator",
        0,
        "coordinator",
        True,
        "linked_rule_graph",
        "coordinate child rules without embedding a boundary regex",
    ),
    (
        "one_regex_leaf",
        1,
        "leaf",
        True,
        "linked_rule_graph",
        "recognize one small boundary or token",
    ),
    (
        "two_regex_recursive_node",
        2,
        "start_end_node",
        True,
        "linked_rule_graph",
        "recognize start and end boundaries while recursion stays in graph edges",
    ),
    (
        "regex_bearing_entry",
        1,
        "selected_entry",
        True,
        "linked_rule_graph",
        "a selected top rule may itself own an ordinary regex",
    ),
]

INVOCATION_ARG_FIELDS = {
    "enter": [
        "invocation_id",
        "rule_label",
        "source_id",
        "parent_invocation_id",
        "cursor",
    ],
    "set_cursor": ["invocation_id", "offset"],
    "set_boundary": ["invocation_id", "offset"],
    "set_mark": ["invocation_id", "name", "offset", "generation"],
    "accept": ["invocation_id"],
}

TRANSACTION_ARG_FIELDS = {
    "checkpoint": ["token"],
    "try_cursor": ["token", "offset"],
    "try_boundary": ["token", "offset"],
    "try_mark": ["token", "name", "offset"],
    "try_state": ["token", "cursor", "anonymous_boundary", "marks"],
    "commit": ["token"],
    "rollback": ["token"],
}

RECURSIVE_OBSERVATION_SURFACE = {
    "request": "value = observe_recognition(observation, call(Child))",
    "target": "the first operand is one bare rule-local harray binding replaced atomically at the terminal observation boundary",
    "operand": "the second operand is exactly one unevaluated statically named call(Rule)",
    "return": "the expression returns the ordinary child payload unchanged; observation data is never mixed with payload truthiness",
    "terminal": "accepted and failed calls bind before returning; aborted and rejected calls finalize the detached record before propagating the unchanged typed failure",
    "availability": "private syntax, exact recurring proof, and public documentation/no-drift projection are current in Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; this is not a public API admission, and no facade, descriptor/schema, semantic/MCP, or CLI surface is current",
}

RECURSIVE_OBSERVATION_CARRIER = {
    "kind": "detached_harray",
    "fields": [
        "source_id",
        "rule_label",
        "invocation_id",
        "parent_invocation_id",
        "entry_position",
        "selected_match",
        "accepted_exit",
        "outcome",
        "diagnostic",
    ],
    "field_access": 'observation["field"]',
    "position_record": ["source_id", "offset"],
    "span_record": ["source_id", "start", "end", "provenance"],
    "nullable_fields": [
        "parent_invocation_id",
        "selected_match",
        "accepted_exit",
        "diagnostic",
    ],
    "outcomes": ["accepted", "failed", "aborted", "rejected"],
    "detachment": "each projection is a fresh recursively detached harray with no source text, path, parser, frame, match, authority, or host object",
    "retention": "the runtime retains at most one pending record until the explicit boundary and no parse-wide observation history",
}

RECURSIVE_FAMILY_POLICIES = {
    "or_default": "seek",
    "and": "consume",
}

RECURSIVE_OBSERVATION_ARG_FIELDS = {
    "enter": [
        "rule_label",
        "source_id",
        "origin",
        "entry_match_span_id",
        "family",
        "observation_id",
        "caller_cursor",
    ],
    "select_match": ["invocation_id", "span_id"],
    "accept": ["invocation_id", "exit_offset"],
    "fail": ["invocation_id"],
    "abort": ["invocation_id", "diagnostic"],
    "reject": [
        "rule_label",
        "source_id",
        "origin",
        "entry_match_span_id",
        "family",
        "observation_id",
        "caller_cursor",
        "recursion_kind",
        "diagnostic",
    ],
    "detach": ["observation_id"],
    "assert_unavailable": ["diagnostic"],
}

RECURSIVE_OBSERVATION_TRANSITION_IDS = [
    "enter_ordinary_parent",
    "select_ordinary_parent_entry",
    "enter_ordinary_child",
    "select_ordinary_child_initial",
    "select_ordinary_child_terminal",
    "accept_ordinary_child",
    "detach_ordinary_leaf",
    "accept_ordinary_parent",
    "enter_zero_coordinator",
    "accept_zero_coordinator",
    "detach_zero_coordinator",
    "enter_failed_parent",
    "enter_failed_child",
    "fail_failed_child",
    "detach_failed_selection",
    "fail_failed_parent",
    "enter_aborted_parent",
    "select_aborted_parent_entry",
    "enter_aborted_child",
    "select_aborted_child_initial",
    "select_aborted_child_terminal",
    "abort_aborted_child",
    "detach_abnormal_exit",
    "abort_aborted_parent",
    "enter_direct_parent",
    "reject_direct_child",
    "detach_direct_nonprogress",
    "fail_direct_parent",
    "enter_mutual_parent",
    "reject_mutual_child",
    "detach_mutual_nonprogress",
    "fail_mutual_parent",
    "assert_detached_history_empty",
]

VALUE_CONTEXT = ["rule_role", "invocation_role", "source_id"]
PROGRESS_CONTEXT = [
    "rule_role",
    "invocation_role",
    "source_id",
    "start_offset",
    "end_offset",
    "originating_edge_or_job",
]
DIAGNOSTICS = [
    ("source_mismatch", "validate_value", "runtime", VALUE_CONTEXT + ["other_source_id"]),
    (
        "position_out_of_range",
        "validate_value",
        "runtime",
        VALUE_CONTEXT + ["position_offset", "source_length"],
    ),
    ("reversed_span", "validate_value", "runtime", VALUE_CONTEXT + ["start_offset", "end_offset"]),
    (
        "invalid_derived_provenance",
        "validate_value",
        "runtime",
        ["rule_role", "invocation_role", "provenance_index", "source_id"],
    ),
    ("unknown_mark", "read_mark", "runtime", VALUE_CONTEXT + ["mark_name"]),
    ("stale_mark", "read_mark", "runtime", VALUE_CONTEXT + ["mark_name", "mark_generation"]),
    (
        "cross_invocation_mark",
        "read_mark",
        "runtime",
        VALUE_CONTEXT + ["mark_name", "owner_invocation_id"],
    ),
    (
        "invalidated_mark",
        "read_mark",
        "runtime",
        VALUE_CONTEXT + ["mark_name", "mark_generation"],
    ),
    (
        "unknown_transaction_token",
        "transaction",
        "runtime",
        VALUE_CONTEXT + ["transaction_token"],
    ),
    (
        "stale_transaction_token",
        "transaction",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "transaction_generation"],
    ),
    (
        "cross_invocation_transaction_token",
        "transaction",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "owner_invocation_id"],
    ),
    (
        "invalidated_transaction_token",
        "transaction",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "transaction_generation"],
    ),
    (
        "transaction_nesting",
        "transaction",
        "static_or_runtime",
        VALUE_CONTEXT + ["transaction_token"],
    ),
    (
        "transaction_escape",
        "transaction",
        "static_or_runtime",
        VALUE_CONTEXT + ["transaction_token", "originating_edge_or_job"],
    ),
    ("transaction_double_commit", "commit", "runtime", VALUE_CONTEXT + ["transaction_token"]),
    ("transaction_double_rollback", "rollback", "runtime", VALUE_CONTEXT + ["transaction_token"]),
    (
        "effect_before_commit",
        "try",
        "static_or_runtime",
        VALUE_CONTEXT + ["transaction_token", "effect_family"],
    ),
    (
        "cross_rule_restore",
        "rollback",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "owner_rule_role"],
    ),
    (
        "cross_source_restore",
        "rollback",
        "runtime",
        VALUE_CONTEXT + ["transaction_token", "owner_source_id"],
    ),
    ("cursor_regression", "advance", "static_or_runtime", PROGRESS_CONTEXT),
    ("nullable_repetition", "progress", "static_or_runtime", PROGRESS_CONTEXT),
    ("nonprogress_direct_recursion", "progress", "static_or_runtime", PROGRESS_CONTEXT),
    ("nonprogress_mutual_recursion", "progress", "static_or_runtime", PROGRESS_CONTEXT),
    ("staged_dispatch_cycle", "progress", "static_or_runtime", PROGRESS_CONTEXT),
    (
        "recursive_boundary_unavailable",
        "observe_recursion",
        "runtime",
        VALUE_CONTEXT + ["boundary_role", "originating_edge_or_job"],
    ),
    (
        "recursive_observation_target",
        "observe_recursion",
        "static",
        ["rule_role", "source_id", "binding_name", "originating_edge_or_job"],
    ),
    (
        "recursive_observation_operand",
        "observe_recursion",
        "static",
        ["rule_role", "source_id", "operand_kind", "originating_edge_or_job"],
    ),
    (
        "ambiguous_regex_slot",
        "resolve_slot",
        "static",
        ["rule_role", "source_id", "slot_reference", "originating_edge_or_job"],
    ),
    (
        "stale_regex_slot",
        "resolve_slot",
        "static",
        ["rule_role", "source_id", "slot_reference", "originating_edge_or_job"],
    ),
    (
        "span_dispatch_source_denied",
        "dispatch",
        "runtime",
        VALUE_CONTEXT + ["span_start", "span_end", "originating_edge_or_job"],
    ),
    (
        "span_dispatch_registry_denied",
        "dispatch",
        "runtime",
        VALUE_CONTEXT + ["parser_identity", "originating_edge_or_job"],
    ),
    (
        "span_dispatch_capability_denied",
        "dispatch",
        "runtime",
        VALUE_CONTEXT + ["parser_identity", "capability", "originating_edge_or_job"],
    ),
    (
        "span_dispatch_policy_denied",
        "dispatch",
        "runtime",
        VALUE_CONTEXT + ["parser_identity", "policy", "originating_edge_or_job"],
    ),
]

ROLLOUT = [
    ("neutral_contract", "complete", "FUTURE-PARITY-BACKLOG.14.1.1", []),
    ("public_structure", "complete", "FUTURE-PARITY-BACKLOG.14.1.2", []),
    ("neutral_public_recomposition", "complete", "FUTURE-PARITY-BACKLOG.14.1.3", []),
    ("perl_runtime", "complete", "FUTURE-PARITY-BACKLOG.14.2.1.3", ["perl"]),
    ("rust_runtime", "complete", "FUTURE-PARITY-BACKLOG.14.2.2.3", ["rust"]),
    ("dart_runtime", "complete", "FUTURE-PARITY-BACKLOG.14.2.3.3", ["dart"]),
    ("julia_runtime", "complete", "FUTURE-PARITY-BACKLOG.14.2.4.3", ["julia"]),
    ("lua_dual_abi", "complete", "FUTURE-PARITY-BACKLOG.14.2.5.3", ["puc_lua", "luajit"]),
    (
        "transaction_safety",
        "complete",
        "FUTURE-PARITY-BACKLOG.14.3",
        ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
    ),
    (
        "recursive_observation",
        "complete",
        "FUTURE-PARITY-BACKLOG.14.4",
        ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
    ),
    (
        "lossless_gap_composition",
        "complete",
        "FUTURE-PARITY-BACKLOG.14.5",
        ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
    ),
    (
        "progressive_span_dispatch",
        "complete",
        "FUTURE-PARITY-BACKLOG.14.6",
        ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
    ),
    (
        "staged_span_dispatch",
        "complete",
        "FUTURE-PARITY-BACKLOG.14.7",
        ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
    ),
    (
        "recurring_public_no_drift",
        "complete",
        "FUTURE-PARITY-BACKLOG.14.8",
        ["perl", "rust", "dart", "julia", "puc_lua", "luajit"],
    ),
]


class ContractError(ValueError):
    """Stable neutral-contract validation failure."""


def fail(detail: str) -> None:
    raise ContractError(detail)


def require_fields(value: Any, fields: list[str] | set[str], context: str) -> dict[str, Any]:
    if not isinstance(value, dict) or list(value) != list(fields):
        fail(f"{context} fields or order drifted")
    return value


def require_list(value: Any, context: str, length: int | None = None) -> list[Any]:
    if not isinstance(value, list):
        fail(f"{context} must be a list")
    if length is not None and len(value) != length:
        fail(f"{context} count drifted")
    return value


def transaction_safety_composition_texts(
    composition: dict[str, Any],
) -> dict[str, str]:
    document_texts: dict[str, str] = {}
    for row in composition["current_projection_no_drift"]["documents"]:
        path = row["path"]
        source = ROOT / path
        if not source.is_file():
            fail(f"transaction-safety composition document is missing: {path}")
        document_texts[path] = source.read_text(encoding="utf-8")
    return document_texts


def validate_transaction_safety_composition(
    composition: dict[str, Any],
    rollout: list[dict[str, Any]],
    document_texts: dict[str, str] | None = None,
) -> None:
    if composition != TRANSACTION_SAFETY_COMPOSITION:
        fail("transaction-safety composition contract drifted")

    projection = composition["current_projection_no_drift"]
    documents = projection["documents"]
    document_paths = [row["path"] for row in documents]
    if len(document_paths) != len(set(document_paths)):
        fail("transaction-safety composition document inventory drifted")
    forbidden_claims = projection["forbidden_claims"]
    forbidden_pairs = [(row["path"], row["text"]) for row in forbidden_claims]
    if len(forbidden_pairs) != len(set(forbidden_pairs)):
        fail("transaction-safety composition forbidden-claim inventory drifted")
    if any(path not in document_paths for path, _text in forbidden_pairs):
        fail("transaction-safety composition forbidden claim has an unmanaged path")

    assertions = composition["rollout_assertions"]
    if assertions["row_count"] != len(rollout):
        fail("transaction-safety composition changed rollout cardinality")
    rollout_by_leg = {row["leg"]: row for row in rollout}
    for leg in (
        "transaction_safety",
        "progressive_span_dispatch",
        "staged_span_dispatch",
        "recurring_public_no_drift",
    ):
        actual = rollout_by_leg.get(leg)
        expected = assertions[leg]
        if actual is None or {
            "status": actual["status"],
            "owner": actual["owner"],
        } != expected:
            fail(f"transaction-safety composition rollout assertion drifted: {leg}")

    if document_texts is None:
        return
    if set(document_texts) != set(document_paths):
        fail("transaction-safety composition document text inventory drifted")
    for row in documents:
        path = row["path"]
        markers = row["required_markers"]
        if not markers or len(markers) != len(set(markers)):
            fail(f"transaction-safety composition marker inventory drifted: {path}")
        for marker in markers:
            if document_texts[path].count(marker) != 1:
                fail(
                    "transaction-safety composition marker missing or duplicated: "
                    f"{path}: {marker}"
                )
    for row in forbidden_claims:
        path = row["path"]
        claim = row["text"]
        if claim in document_texts[path]:
            fail(f"stale transaction-safety composition claim remains: {path}: {claim}")


def recursive_observation_public_texts(
    public_contract: dict[str, Any],
) -> tuple[dict[str, str], dict[str, str]]:
    document_texts: dict[str, str] = {}
    for row in public_contract["documents"]:
        path = row["path"]
        source = ROOT / path
        if not source.is_file():
            fail(f"recursive-observation public document is missing: {path}")
        document_texts[path] = source.read_text(encoding="utf-8")

    surface_texts: dict[str, str] = {}
    for path in public_contract["surface_guard"]["paths"]:
        source = ROOT / path
        if not source.is_file():
            fail(f"recursive-observation public surface guard is missing: {path}")
        surface_texts[path] = source.read_text(encoding="utf-8")
    return document_texts, surface_texts


def validate_recursive_observation_public_no_drift(
    public_contract: dict[str, Any],
    rollout: list[dict[str, Any]],
    document_texts: dict[str, str] | None = None,
    surface_texts: dict[str, str] | None = None,
) -> None:
    if public_contract != RECURSIVE_OBSERVATION_PUBLIC_NO_DRIFT:
        fail("recursive-observation public no-drift contract drifted")

    documents = public_contract["documents"]
    document_paths = [row["path"] for row in documents]
    if (
        len(document_paths) != len(set(document_paths))
        or len(document_paths)
        != EXPECTED_COUNTS["recursive_observation_public_documents"]
    ):
        fail("recursive-observation public document inventory drifted")
    forbidden_claims = public_contract["forbidden_claims"]
    forbidden_pairs = [(row["path"], row["text"]) for row in forbidden_claims]
    if (
        len(forbidden_pairs)
        != len(set(forbidden_pairs))
        or len(forbidden_pairs)
        != EXPECTED_COUNTS["recursive_observation_public_forbidden_claims"]
    ):
        fail("recursive-observation public forbidden-claim inventory drifted")
    if any(path not in document_paths for path, _text in forbidden_pairs):
        fail("recursive-observation forbidden claim has an unmanaged document path")

    surface_guard = public_contract["surface_guard"]
    guard_paths = surface_guard["paths"]
    guard_tokens = surface_guard["forbidden_tokens"]
    if (
        len(guard_paths)
        != len(set(guard_paths))
        or len(guard_paths)
        != EXPECTED_COUNTS["recursive_observation_public_surface_guard_paths"]
    ):
        fail("recursive-observation public surface-guard inventory drifted")
    if not guard_tokens or len(guard_tokens) != len(set(guard_tokens)):
        fail("recursive-observation public surface-guard token inventory drifted")

    assertions = public_contract["rollout_assertions"]
    if assertions["row_count"] != len(rollout):
        fail("recursive-observation public proof changed rollout cardinality")
    rollout_by_leg = {row["leg"]: row for row in rollout}
    for leg in ("recursive_observation", "recurring_public_no_drift"):
        expected = assertions[leg]
        actual = rollout_by_leg.get(leg)
        if actual is None or {
            "status": actual["status"],
            "owner": actual["owner"],
        } != expected:
            fail(f"recursive-observation public rollout assertion drifted: {leg}")

    if document_texts is None and surface_texts is None:
        return
    if document_texts is None or surface_texts is None:
        fail("recursive-observation public text inventories must be provided together")
    if set(document_texts) != set(document_paths):
        fail("recursive-observation public document text inventory drifted")
    if set(surface_texts) != set(guard_paths):
        fail("recursive-observation public surface text inventory drifted")

    for row in documents:
        path = row["path"]
        markers = row["required_markers"]
        if not markers or len(markers) != len(set(markers)):
            fail(f"recursive-observation public marker inventory drifted: {path}")
        for marker in markers:
            if document_texts[path].count(marker) != 1:
                fail(
                    "recursive-observation public marker missing or duplicated: "
                    f"{path}: {marker}"
                )
    for row in forbidden_claims:
        path = row["path"]
        claim = row["text"]
        if claim in document_texts[path]:
            fail(f"stale recursive-observation public claim remains: {path}: {claim}")
    for path in guard_paths:
        for token in guard_tokens:
            if token in surface_texts[path]:
                fail(
                    "recursive-observation public surface widened: "
                    f"{path}: {token}"
                )


def program_wide_public_texts(
    public_contract: dict[str, Any],
) -> tuple[dict[str, str], dict[str, str], dict[str, str]]:
    document_texts: dict[str, str] = {}
    for row in public_contract["documents"]:
        path = row["path"]
        source = ROOT / path
        if not source.is_file():
            fail(f"program-wide public document is missing: {path}")
        document_texts[path] = source.read_text(encoding="utf-8")

    safety_texts: dict[str, str] = {}
    for row in public_contract["authoring_safety"]["forbidden_claims"]:
        path = row["path"]
        source = ROOT / path
        if not source.is_file():
            fail(f"program-wide authoring-safety document is missing: {path}")
        safety_texts[path] = source.read_text(encoding="utf-8")

    surface_texts: dict[str, str] = {}
    for path in public_contract["surface_guard"]["paths"]:
        source = ROOT / path
        if not source.is_file():
            fail(f"program-wide public surface guard is missing: {path}")
        surface_texts[path] = source.read_text(encoding="utf-8")
    return document_texts, safety_texts, surface_texts


def validate_program_wide_public_no_drift(
    public_contract: dict[str, Any],
    rollout: list[dict[str, Any]],
    document_texts: dict[str, str] | None = None,
    safety_texts: dict[str, str] | None = None,
    surface_texts: dict[str, str] | None = None,
) -> None:
    if public_contract != PROGRAM_WIDE_PUBLIC_NO_DRIFT:
        fail("program-wide public no-drift contract drifted")

    composition = public_contract["recurring_composition"]
    ordered_drivers = composition["ordered_drivers"]
    if (
        len(ordered_drivers) != len(set(ordered_drivers))
        or len(ordered_drivers) != EXPECTED_COUNTS["program_wide_recurring_drivers"]
    ):
        fail("program-wide recurring driver inventory drifted")

    documents = public_contract["documents"]
    document_paths = [row["path"] for row in documents]
    if (
        len(document_paths) != len(set(document_paths))
        or len(document_paths) != EXPECTED_COUNTS["program_wide_public_documents"]
    ):
        fail("program-wide public document inventory drifted")
    forbidden_claims = public_contract["forbidden_claims"]
    forbidden_pairs = [(row["path"], row["text"]) for row in forbidden_claims]
    if (
        len(forbidden_pairs) != len(set(forbidden_pairs))
        or len(forbidden_pairs)
        != EXPECTED_COUNTS["program_wide_public_forbidden_claims"]
    ):
        fail("program-wide public forbidden-claim inventory drifted")
    if any(path not in document_paths for path, _text in forbidden_pairs):
        fail("program-wide forbidden claim has an unmanaged document path")

    safety_claims = public_contract["authoring_safety"]["forbidden_claims"]
    safety_pairs = [(row["path"], row["text"]) for row in safety_claims]
    if (
        len(safety_pairs) != len(set(safety_pairs))
        or len(safety_pairs)
        != EXPECTED_COUNTS["program_wide_authoring_safety_claims"]
    ):
        fail("program-wide authoring-safety inventory drifted")

    surface_guard = public_contract["surface_guard"]
    guard_paths = surface_guard["paths"]
    guard_tokens = surface_guard["forbidden_tokens"]
    if (
        len(guard_paths) != len(set(guard_paths))
        or len(guard_paths)
        != EXPECTED_COUNTS["program_wide_public_surface_guard_paths"]
    ):
        fail("program-wide public surface-guard inventory drifted")
    if not guard_tokens or len(guard_tokens) != len(set(guard_tokens)):
        fail("program-wide public surface-guard token inventory drifted")

    assertions = public_contract["rollout_assertions"]
    complete = sum(row["status"] == "complete" for row in rollout)
    pending = sum(row["status"] == "pending" for row in rollout)
    if {
        "row_count": len(rollout),
        "complete": complete,
        "pending": pending,
    } != {
        "row_count": assertions["row_count"],
        "complete": assertions["complete"],
        "pending": assertions["pending"],
    }:
        fail("program-wide public rollout counts drifted")
    final_row = next(
        (row for row in rollout if row["leg"] == "recurring_public_no_drift"),
        None,
    )
    if final_row is None or {
        "status": final_row["status"],
        "owner": final_row["owner"],
    } != assertions["recurring_public_no_drift"]:
        fail("program-wide public final rollout assertion drifted")

    supplied = (document_texts, safety_texts, surface_texts)
    if all(texts is None for texts in supplied):
        return
    if any(texts is None for texts in supplied):
        fail("program-wide public text inventories must be provided together")
    assert document_texts is not None
    assert safety_texts is not None
    assert surface_texts is not None
    if set(document_texts) != set(document_paths):
        fail("program-wide public document text inventory drifted")
    if set(safety_texts) != {path for path, _text in safety_pairs}:
        fail("program-wide authoring-safety text inventory drifted")
    if set(surface_texts) != set(guard_paths):
        fail("program-wide public surface text inventory drifted")

    for row in documents:
        path = row["path"]
        markers = row["required_markers"]
        if not markers or len(markers) != len(set(markers)):
            fail(f"program-wide public marker inventory drifted: {path}")
        for marker in markers:
            if document_texts[path].count(marker) != 1:
                fail(
                    "program-wide public marker missing or duplicated: "
                    f"{path}: {marker}"
                )
    for path, claim in forbidden_pairs:
        if claim in document_texts[path]:
            fail(f"stale program-wide public claim remains: {path}: {claim}")
    for path, claim in safety_pairs:
        if claim in safety_texts[path]:
            fail(f"unsafe public authoring claim remains: {path}: {claim}")
    for path in guard_paths:
        for token in guard_tokens:
            if token in surface_texts[path]:
                fail(f"program-wide public surface widened: {path}: {token}")


def position_coordinates(text: str, offset: int) -> tuple[int, int, int]:
    if not isinstance(offset, int) or isinstance(offset, bool) or offset < 0 or offset > len(text):
        fail(f"position offset is outside decoded source: {offset!r}")
    prefix = text[:offset]
    return prefix.count("\n") + 1, len(prefix.rsplit("\n", 1)[-1]) + 1, len(prefix.encode("utf-8"))


def extract_lua_helper_names(source: str, constant_name: str) -> list[str]:
    match = re.search(
        rf"local {re.escape(constant_name)} = make_set\(\{{(.*?)\n\}}\)",
        source,
        re.DOTALL,
    )
    if match is None:
        fail(f"current Lua helper authority is missing {constant_name}")
    return re.findall(r'"([a-z0-9_]+)"', match.group(1))


def expected_projection(name: str, family: str) -> str:
    if family == "capture_mark":
        exact = {
            "capture_slice_col": "span_start_column",
            "capture_slice_line": "span_start_line",
            "capture_slice_pos": "span_start_offset",
            "mark_capture_slice": "capture_boundary_write_position",
            "start_capture_slice": "capture_boundary_write_position",
            "start_capture_slice_from": "capture_boundary_write_position",
            "mark_copy": "mark_write_position",
            "mark_here": "mark_write_position",
            "mark_input_end": "mark_write_position",
            "mark_input_start": "mark_write_position",
            "mark_entry_end": "mark_write_position",
            "mark_entry_start": "mark_write_position",
            "mark_match_end": "mark_write_position",
            "mark_match_start": "mark_write_position",
            "mark_exists": "mark_exists",
            "mark_pos": "mark_read_offset",
            "mark_line": "mark_read_line",
            "mark_col": "mark_read_column",
            "clear_mark": "mark_delete",
        }
        if name in exact:
            return exact[name]
        if name.startswith("capture_"):
            return "span_length" if "_len" in name else "span_text"
    elif family == "entry_match":
        suffix = name.split("_", 1)[1]
        exact_suffix = {
            "group": "capture_group_text",
            "groups": "capture_group_list",
            "has": "capture_group_exists",
            "map": "capture_group_map",
            "named": "capture_group_text",
            "len": "span_length",
            "text": "span_text",
            "col": "span_start_column",
            "line": "span_start_line",
            "start_col": "span_start_column",
            "start_line": "span_start_line",
            "start_pos": "span_start_offset",
            "end_col": "position_column",
            "end_line": "position_line",
            "end_pos": "position_offset",
        }
        if suffix in exact_suffix:
            return exact_suffix[suffix]
    elif family == "input_cursor":
        exact = {
            "cursor_col": "position_column",
            "cursor_line": "position_line",
            "cursor_pos": "cursor_position",
            "cursor_rest": "span_text",
            "cursor_rest_len": "span_length",
            "input_end_col": "position_column",
            "input_end_line": "position_line",
            "input_end_pos": "position_offset",
            "input_len": "source_length",
            "input_slice": "source_slice_text",
            "input_text": "source_text",
        }
        if name in exact:
            return exact[name]
    elif family == "cursor_control":
        exact = {
            "restore_cursor": "cursor_state_write_compatibility",
            "rewind_entry_start": "cursor_state_write_compatibility",
            "rewind_match_start": "cursor_state_write_compatibility",
            "save_cursor": "cursor_checkpoint_compatibility",
        }
        if name in exact:
            return exact[name]
    fail(f"no typed-algebra projection is defined for current helper {name!r}")


def invocation_snapshot(state: dict[str, Any]) -> dict[str, Any]:
    stack = state["stack"]
    if not stack:
        return {
            "active_invocation_id": None,
            "cursor": None,
            "anonymous_boundary": None,
            "mark_names": [],
            "stack_depth": 0,
            "completed_count": state["completed_count"],
        }
    active = stack[-1]
    return {
        "active_invocation_id": active["invocation_id"],
        "cursor": active["cursor"],
        "anonymous_boundary": active["anonymous_boundary"],
        "mark_names": sorted(active["marks"]),
        "stack_depth": len(stack),
        "completed_count": state["completed_count"],
    }


def apply_invocation_transition(state: dict[str, Any], transition: dict[str, Any]) -> None:
    operation = transition["operation"]
    args = transition["args"]
    stack = state["stack"]
    if operation == "enter":
        parent = stack[-1]["invocation_id"] if stack else None
        if args["parent_invocation_id"] != parent:
            fail("invocation parent identity drifted")
        stack.append(
            {
                "invocation_id": args["invocation_id"],
                "rule_label": args["rule_label"],
                "source_id": args["source_id"],
                "parent_invocation_id": args["parent_invocation_id"],
                "cursor": args["cursor"],
                "anonymous_boundary": args["cursor"],
                "marks": {},
            }
        )
        return
    if not stack or stack[-1]["invocation_id"] != args["invocation_id"]:
        fail("invocation transition does not target the active frame")
    active = stack[-1]
    if operation == "set_cursor":
        active["cursor"] = args["offset"]
    elif operation == "set_boundary":
        active["anonymous_boundary"] = args["offset"]
    elif operation == "set_mark":
        active["marks"][args["name"]] = {
            "offset": args["offset"],
            "generation": args["generation"],
        }
    elif operation == "accept":
        accepted = stack.pop()
        state["completed_count"] += 1
        if stack:
            if stack[-1]["source_id"] != accepted["source_id"]:
                fail("accepted child source identity drifted")
            stack[-1]["cursor"] = accepted["cursor"]
    else:
        fail(f"unknown invocation transition operation: {operation!r}")


def transaction_snapshot(state: dict[str, Any], token: str) -> dict[str, Any]:
    token_data = state["tokens"].get(token)
    return {
        "cursor": state["cursor"],
        "anonymous_boundary": state["anonymous_boundary"],
        "marks": [[name, offset] for name, offset in sorted(state["marks"].items())],
        "token": token,
        "token_state": token_data["state"] if token_data else None,
    }


def require_active_token(state: dict[str, Any], token: str) -> dict[str, Any]:
    token_data = state["tokens"].get(token)
    if token_data is None or token_data["state"] != "active":
        fail(f"transaction operation requires active token {token!r}")
    return token_data


def apply_transaction_transition(state: dict[str, Any], transition: dict[str, Any]) -> None:
    operation = transition["operation"]
    args = transition["args"]
    token = args["token"]
    if operation == "checkpoint":
        if any(value["state"] == "active" for value in state["tokens"].values()):
            fail("nested transaction appeared in positive fixture")
        if token in state["tokens"]:
            fail("transaction token was reused")
        state["tokens"][token] = {
            "state": "active",
            "snapshot": {
                "cursor": state["cursor"],
                "anonymous_boundary": state["anonymous_boundary"],
                "marks": copy.deepcopy(state["marks"]),
            },
        }
        return
    token_data = require_active_token(state, token)
    if operation == "try_cursor":
        state["cursor"] = args["offset"]
    elif operation == "try_boundary":
        state["anonymous_boundary"] = args["offset"]
    elif operation == "try_mark":
        state["marks"][args["name"]] = args["offset"]
    elif operation == "try_state":
        state["cursor"] = args["cursor"]
        state["anonymous_boundary"] = args["anonymous_boundary"]
        state["marks"] = dict(args["marks"])
    elif operation == "commit":
        token_data["state"] = "invalidated"
    elif operation == "rollback":
        snapshot = token_data["snapshot"]
        state["cursor"] = snapshot["cursor"]
        state["anonymous_boundary"] = snapshot["anonymous_boundary"]
        state["marks"] = copy.deepcopy(snapshot["marks"])
        token_data["state"] = "invalidated"
    else:
        fail(f"unknown transaction transition operation: {operation!r}")


def validate_recursive_observation_lineage(observations: list[dict[str, Any]]) -> None:
    observations_by_invocation: dict[int, dict[str, Any]] = {}
    for observation in observations:
        invocation_id = observation["invocation_id"]
        parent_invocation_id = observation["parent_invocation_id"]
        if (
            not isinstance(invocation_id, int)
            or isinstance(invocation_id, bool)
            or invocation_id <= 0
        ):
            fail("recursive invocation identity must be a positive integer")
        if invocation_id in observations_by_invocation:
            fail("recursive invocation identity was reused")
        if parent_invocation_id is not None and (
            not isinstance(parent_invocation_id, int)
            or isinstance(parent_invocation_id, bool)
            or parent_invocation_id <= 0
        ):
            fail("recursive parent invocation identity must be a positive integer or null")
        if parent_invocation_id == invocation_id:
            fail("recursive observation cannot self-parent")
        observations_by_invocation[invocation_id] = observation

    for invocation_id in observations_by_invocation:
        visited: set[int] = set()
        current_id: int | None = invocation_id
        while current_id is not None and current_id in observations_by_invocation:
            if current_id in visited:
                fail("recursive invocation lineage is cyclic")
            visited.add(current_id)
            current_id = observations_by_invocation[current_id]["parent_invocation_id"]

    for observation in observations:
        invocation_id = observation["invocation_id"]
        parent_invocation_id = observation["parent_invocation_id"]
        if parent_invocation_id is not None and parent_invocation_id >= invocation_id:
            fail("recursive parent invocation must precede child")


def recursive_observation_projection(
    observation: dict[str, Any], span_by_id: dict[str, dict[str, Any]]
) -> dict[str, Any]:
    selected_match = None
    selected_match_span_id = observation["selected_match_span_id"]
    if selected_match_span_id is not None:
        span = span_by_id[selected_match_span_id]
        selected_match = {
            "source_id": span["source_id"],
            "start": span["start"],
            "end": span["end"],
            "provenance": "match",
        }
    accepted_exit = None
    if observation["accepted_exit_offset"] is not None:
        accepted_exit = {
            "source_id": observation["source_id"],
            "offset": observation["accepted_exit_offset"],
        }
    return {
        "source_id": observation["source_id"],
        "rule_label": observation["rule_label"],
        "invocation_id": observation["invocation_id"],
        "parent_invocation_id": observation["parent_invocation_id"],
        "entry_position": {
            "source_id": observation["source_id"],
            "offset": observation["entry_offset"],
        },
        "selected_match": selected_match,
        "accepted_exit": accepted_exit,
        "outcome": observation["outcome"],
        "diagnostic": observation["diagnostic"],
    }


def recursive_observation_snapshot(state: dict[str, Any]) -> dict[str, Any]:
    return {
        "next_invocation_id": state["next_invocation_id"],
        "stack_depth": len(state["stack"]),
        "pending_observation": (
            state["pending_observation"]["id"]
            if state["pending_observation"] is not None
            else None
        ),
        "detached_count": state["detached_count"],
        "retained_history_count": 0,
    }


def complete_recursive_observation(
    state: dict[str, Any], frame: dict[str, Any], outcome: str, exit_offset: int | None,
    diagnostic: str | None,
) -> None:
    observation_id = frame["observation_id"]
    if observation_id is None:
        return
    if state["pending_observation"] is not None:
        fail("recursive observation boundary retained more than one pending record")
    state["pending_observation"] = {
        "id": observation_id,
        "rule_label": frame["rule_label"],
        "invocation_id": frame["invocation_id"],
        "parent_invocation_id": frame["parent_invocation_id"],
        "source_id": frame["source_id"],
        "entry_offset": frame["entry_offset"],
        "selected_match_span_id": frame["selected_match_span_id"],
        "accepted_exit_offset": exit_offset,
        "outcome": outcome,
        "diagnostic": diagnostic,
    }


def apply_recursive_observation_transition(
    state: dict[str, Any],
    transition: dict[str, Any],
    source_by_id: dict[str, dict[str, Any]],
    span_by_id: dict[str, dict[str, Any]],
    observation_by_id: dict[str, dict[str, Any]],
    detached: list[dict[str, Any]],
) -> None:
    operation = transition["operation"]
    args = transition["args"]
    stack = state["stack"]

    if operation == "enter":
        source = source_by_id.get(args["source_id"])
        if source is None:
            fail("recursive entry references unknown source")
        position_coordinates(source["decoded_text"], args["caller_cursor"])
        family = args["family"]
        if family not in RECURSIVE_FAMILY_POLICIES:
            fail("recursive entry has unknown child family")
        parent = stack[-1] if stack else None
        if parent is not None:
            if parent["source_id"] != args["source_id"]:
                fail("recursive child crossed source authority")
            if parent["cursor"] != args["caller_cursor"]:
                fail("recursive child entry did not use the caller cursor")
        origin = args["origin"]
        entry_match_span_id = args["entry_match_span_id"]
        if origin == "direct":
            if entry_match_span_id is not None:
                fail("direct recursive call invented an entry match")
        elif origin == "action_edge":
            if (
                parent is None
                or entry_match_span_id is None
                or parent["selected_match_span_id"] != entry_match_span_id
            ):
                fail("action-edge recursive entry did not carry the parent selected match")
        else:
            fail("recursive entry origin is unknown")
        observation_id = args["observation_id"]
        if observation_id is not None and observation_id not in observation_by_id:
            fail("recursive entry references unknown observation boundary")
        invocation_id = state["next_invocation_id"]
        state["next_invocation_id"] += 1
        stack.append(
            {
                "invocation_id": invocation_id,
                "parent_invocation_id": parent["invocation_id"] if parent else None,
                "rule_label": args["rule_label"],
                "source_id": args["source_id"],
                "entry_offset": args["caller_cursor"],
                "entry_match_span_id": entry_match_span_id,
                "selected_match_span_id": None,
                "cursor": args["caller_cursor"],
                "family": family,
                "cursor_policy": RECURSIVE_FAMILY_POLICIES[family],
                "observation_id": observation_id,
            }
        )
        return

    if operation == "select_match":
        if not stack or stack[-1]["invocation_id"] != args["invocation_id"]:
            fail("recursive selected match does not target the active invocation")
        frame = stack[-1]
        span = span_by_id.get(args["span_id"])
        if span is None or span["source_id"] != frame["source_id"]:
            fail("recursive selected match crossed source authority")
        if frame["cursor_policy"] == "consume" and span["start"] != frame["entry_offset"]:
            fail("consume-family recursive match did not begin at child entry")
        if frame["cursor_policy"] == "seek" and span["start"] < frame["entry_offset"]:
            fail("seek-family recursive match began before child entry")
        frame["selected_match_span_id"] = args["span_id"]
        frame["cursor"] = span["end"]
        return

    if operation in {"accept", "fail", "abort"}:
        if not stack or stack[-1]["invocation_id"] != args["invocation_id"]:
            fail("recursive terminal does not target the active invocation")
        frame = stack.pop()
        if operation == "accept":
            exit_offset = args["exit_offset"]
            source = source_by_id[frame["source_id"]]
            position_coordinates(source["decoded_text"], exit_offset)
            if exit_offset < frame["entry_offset"]:
                fail("accepted recursive exit precedes entry")
            selected_match_span_id = frame["selected_match_span_id"]
            if (
                selected_match_span_id is not None
                and exit_offset < span_by_id[selected_match_span_id]["end"]
            ):
                fail("accepted recursive exit precedes terminal selected match")
            complete_recursive_observation(state, frame, "accepted", exit_offset, None)
            if stack:
                stack[-1]["cursor"] = exit_offset
        elif operation == "fail":
            complete_recursive_observation(state, frame, "failed", None, None)
        else:
            diagnostic = args["diagnostic"]
            if diagnostic is not None and (
                not isinstance(diagnostic, str) or not diagnostic.startswith("source_location_")
            ):
                fail("recursive abort diagnostic is not typed")
            complete_recursive_observation(state, frame, "aborted", None, diagnostic)
        return

    if operation == "reject":
        if not stack:
            fail("recursive rejection has no active parent")
        parent = stack[-1]
        source = source_by_id.get(args["source_id"])
        if source is None or parent["source_id"] != args["source_id"]:
            fail("recursive rejection crossed source authority")
        position_coordinates(source["decoded_text"], args["caller_cursor"])
        if parent["cursor"] != args["caller_cursor"]:
            fail("recursive rejected child did not use the caller cursor")
        if args["origin"] != "direct" or args["entry_match_span_id"] is not None:
            fail("pre-entry recursive rejection invented an action-edge match")
        if args["family"] not in RECURSIVE_FAMILY_POLICIES:
            fail("recursive rejection has unknown child family")
        recursion_kind = args["recursion_kind"]
        expected_diagnostic = {
            "direct": "source_location_nonprogress_direct_recursion",
            "mutual": "source_location_nonprogress_mutual_recursion",
        }.get(recursion_kind)
        if expected_diagnostic is None or args["diagnostic"] != expected_diagnostic:
            fail("recursive rejection kind and diagnostic disagree")
        if recursion_kind == "direct" and args["rule_label"] != parent["rule_label"]:
            fail("direct recursive rejection changed rule identity")
        if recursion_kind == "mutual" and args["rule_label"] == parent["rule_label"]:
            fail("mutual recursive rejection reused parent rule identity")
        observation_id = args["observation_id"]
        if observation_id not in observation_by_id:
            fail("recursive rejection references unknown observation boundary")
        invocation_id = state["next_invocation_id"]
        state["next_invocation_id"] += 1
        rejected = {
            "invocation_id": invocation_id,
            "parent_invocation_id": parent["invocation_id"],
            "rule_label": args["rule_label"],
            "source_id": args["source_id"],
            "entry_offset": args["caller_cursor"],
            "entry_match_span_id": None,
            "selected_match_span_id": None,
            "cursor": args["caller_cursor"],
            "family": args["family"],
            "cursor_policy": RECURSIVE_FAMILY_POLICIES[args["family"]],
            "observation_id": observation_id,
        }
        complete_recursive_observation(
            state, rejected, "rejected", None, args["diagnostic"]
        )
        return

    if operation == "detach":
        pending = state["pending_observation"]
        if pending is None or pending["id"] != args["observation_id"]:
            fail("recursive observation boundary is unavailable")
        expected = observation_by_id[args["observation_id"]]
        if pending != expected:
            fail("recursive observation state machine emitted the wrong terminal record")
        detached.append(copy.deepcopy(pending))
        state["pending_observation"] = None
        state["detached_count"] += 1
        return

    if operation == "assert_unavailable":
        if args["diagnostic"] != "source_location_recursive_boundary_unavailable":
            fail("recursive unavailable-boundary diagnostic drifted")
        if state["pending_observation"] is not None:
            fail("recursive observation history remained available after detach")
        return

    fail(f"unknown recursive observation transition operation: {operation!r}")


def validate_contract(contract: dict[str, Any], *, check_registration: bool = True) -> None:
    if "program_wide_public_no_drift" not in contract:
        fail("program-wide public no-drift contract is missing")
    if "transaction_safety_composition" not in contract:
        fail("transaction-safety composition contract is missing")
    if "lossless_gap_composition" not in contract:
        fail("lossless-gap composition contract is missing")
    if "recursive_observation_recurring_gate" not in contract:
        fail("recursive-observation recurring gate is missing")
    if "progressive_span_dispatch_recurring_gate" not in contract:
        fail("progressive span-dispatch recurring gate is missing")
    if "staged_ast_enrichment_recurring_gate" not in contract:
        fail("staged-AST enrichment recurring gate is missing")
    if "recursive_observation_public_no_drift" not in contract:
        fail("recursive-observation public no-drift contract is missing")
    top_fields = [
        "format",
        "contract_id",
        "task_owner",
        "status",
        "expected_counts",
        "policy",
        "canonical_execution",
        "sources",
        "position_conversions",
        "direct_spans",
        "derived_text_cases",
        "invocation_state_machine",
        "transaction_state_machine",
        "recursive_observation_state_machine",
        "recursive_observations",
        "structural_authoring_cases",
        "helper_projection_schema",
        "helper_projections",
        "compatibility_aliases",
        "internal_contract_ids",
        "diagnostic_schema",
        "diagnostics",
        "recurring_gate",
        "recursive_observation_recurring_gate",
        "progressive_span_dispatch_recurring_gate",
        "staged_ast_enrichment_recurring_gate",
        "recursive_observation_public_no_drift",
        "transaction_safety_composition",
        "lossless_gap_composition",
        "program_wide_public_no_drift",
        "rollout",
    ]
    require_fields(contract, top_fields, "contract")
    if contract["format"] != 1:
        fail("format drifted")
    if contract["contract_id"] != "linkedspec-typed-source-location-v1":
        fail("contract id drifted")
    if contract["task_owner"] != "FUTURE-PARITY-BACKLOG.14.1.1":
        fail("task owner drifted")
    if contract["status"] != "complete_authoring_model_with_combined_recurring_and_public_no_drift":
        fail("typed source-location status drifted")
    if contract["expected_counts"] != EXPECTED_COUNTS:
        fail("expected counts drifted")
    if contract["policy"] != POLICY:
        fail("typed source-location policy drifted")
    if contract["canonical_execution"] != CANONICAL_EXECUTION:
        fail("canonical execution contract drifted")

    sources = require_list(contract["sources"], "sources", EXPECTED_COUNTS["sources"])
    source_by_id: dict[str, dict[str, Any]] = {}
    for source in sources:
        require_fields(
            source,
            ["id", "decoded_text", "unicode_scalar_length", "utf8_byte_length"],
            "source",
        )
        source_id = source["id"]
        if not isinstance(source_id, str) or not source_id or source_id in source_by_id:
            fail("source identity is missing or duplicated")
        text = source["decoded_text"]
        if not isinstance(text, str):
            fail(f"decoded source {source_id!r} is not text")
        if source["unicode_scalar_length"] != len(text):
            fail(f"Unicode-scalar length drifted for source {source_id!r}")
        if source["utf8_byte_length"] != len(text.encode("utf-8")):
            fail(f"UTF-8 byte length drifted for source {source_id!r}")
        source_by_id[source_id] = source
    if list(source_by_id) != ["unicode", "ascii", "parts"]:
        fail("source identity order drifted")

    positions = require_list(
        contract["position_conversions"],
        "position conversions",
        EXPECTED_COUNTS["position_conversions"],
    )
    expected_position_ids = [
        "unicode_start",
        "unicode_after_e_acute",
        "unicode_line_two",
        "unicode_after_emoji",
        "unicode_end",
        "ascii_middle",
        "parts_line_two",
    ]
    for expected_id, position in zip(expected_position_ids, positions, strict=True):
        require_fields(
            position,
            ["id", "source_id", "offset", "line", "column", "utf8_byte_offset"],
            "position conversion",
        )
        if position["id"] != expected_id:
            fail("position conversion order drifted")
        source = source_by_id.get(position["source_id"])
        if source is None:
            fail(f"position references unknown source: {position['source_id']!r}")
        coordinates = position_coordinates(source["decoded_text"], position["offset"])
        if coordinates != (position["line"], position["column"], position["utf8_byte_offset"]):
            fail(f"derived coordinates drifted for position {position['id']!r}")

    spans = require_list(contract["direct_spans"], "direct spans", EXPECTED_COUNTS["direct_spans"])
    expected_span_ids = [
        "unicode_empty",
        "unicode_prefix",
        "unicode_newline",
        "unicode_emoji_tail",
        "ascii_tail",
        "parts_beta_newline",
    ]
    expected_provenance = ["input", "entry", "match", "capture", "mark", "gap"]
    span_by_id: dict[str, dict[str, Any]] = {}
    for expected_id, provenance, span in zip(expected_span_ids, expected_provenance, spans, strict=True):
        require_fields(
            span,
            ["id", "source_id", "start", "end", "provenance", "expected_text"],
            "direct span",
        )
        if span["id"] != expected_id or span["provenance"] != provenance:
            fail("direct span identity, order, or provenance drifted")
        source = source_by_id.get(span["source_id"])
        if source is None:
            fail("direct span references unknown source")
        start, end = span["start"], span["end"]
        position_coordinates(source["decoded_text"], start)
        position_coordinates(source["decoded_text"], end)
        if start > end:
            fail(f"direct span is reversed: {span['id']!r}")
        if source["decoded_text"][start:end] != span["expected_text"]:
            fail(f"direct span materialization drifted: {span['id']!r}")
        span_by_id[span["id"]] = span

    derived_cases = require_list(
        contract["derived_text_cases"],
        "derived text cases",
        EXPECTED_COUNTS["derived_text_cases"],
    )
    expected_derived_ids = ["same_source_noncontiguous", "multi_source", "empty_then_gap"]
    for expected_id, case in zip(expected_derived_ids, derived_cases, strict=True):
        require_fields(
            case,
            ["id", "policy", "span_ids", "contiguous_source_interval", "expected_text"],
            "derived text case",
        )
        if case["id"] != expected_id or case["policy"] != "concatenate_in_order":
            fail("derived text identity, order, or policy drifted")
        if case["contiguous_source_interval"] is not None:
            fail("derived text pretends to have one contiguous source interval")
        segment_ids = require_list(case["span_ids"], "derived provenance sequence")
        if not segment_ids or any(span_id not in span_by_id for span_id in segment_ids):
            fail("derived provenance is empty or references an unknown span")
        materialized = "".join(span_by_id[span_id]["expected_text"] for span_id in segment_ids)
        if materialized != case["expected_text"]:
            fail(f"derived text materialization drifted: {case['id']!r}")

    invocation = require_fields(
        contract["invocation_state_machine"],
        ["initial", "transitions"],
        "invocation state machine",
    )
    if invocation["initial"] != {"stack": [], "completed_count": 0}:
        fail("invocation initial state drifted")
    invocation_state = copy.deepcopy(invocation["initial"])
    invocation_transitions = require_list(
        invocation["transitions"],
        "invocation transitions",
        EXPECTED_COUNTS["invocation_transitions"],
    )
    expected_invocation_ids = [
        "enter_root",
        "seek_root",
        "set_root_boundary",
        "write_root_mark",
        "enter_child",
        "advance_child",
        "accept_child",
        "accept_root",
    ]
    for expected_id, transition in zip(expected_invocation_ids, invocation_transitions, strict=True):
        require_fields(transition, ["id", "operation", "args", "expected"], "invocation transition")
        if transition["id"] != expected_id:
            fail("invocation transition identity or order drifted")
        operation = transition["operation"]
        if operation not in INVOCATION_ARG_FIELDS:
            fail(f"unknown invocation transition operation: {operation!r}")
        args = require_fields(
            transition["args"],
            INVOCATION_ARG_FIELDS[operation],
            f"invocation transition {expected_id!r} args",
        )
        require_fields(
            transition["expected"],
            [
                "active_invocation_id",
                "cursor",
                "anonymous_boundary",
                "mark_names",
                "stack_depth",
                "completed_count",
            ],
            f"invocation transition {expected_id!r} expected state",
        )
        if operation == "enter":
            source = source_by_id.get(args["source_id"])
            if source is None:
                fail("invocation transition references unknown source")
            position_coordinates(source["decoded_text"], args["cursor"])
        elif operation in {"set_cursor", "set_boundary", "set_mark"}:
            if not invocation_state["stack"]:
                fail("invocation position transition has no active frame")
            active_source_id = invocation_state["stack"][-1]["source_id"]
            position_coordinates(source_by_id[active_source_id]["decoded_text"], args["offset"])
        if operation == "set_mark":
            if not isinstance(args["name"], str) or not args["name"]:
                fail("invocation mark name must be non-empty text")
            if (
                not isinstance(args["generation"], int)
                or isinstance(args["generation"], bool)
                or args["generation"] < 1
            ):
                fail("invocation mark generation must be a positive integer")
        apply_invocation_transition(invocation_state, transition)
        if invocation_snapshot(invocation_state) != transition["expected"]:
            fail(f"invocation transition result drifted: {transition['id']!r}")

    transaction = require_fields(
        contract["transaction_state_machine"],
        ["initial", "transitions"],
        "transaction state machine",
    )
    transaction_initial = require_fields(
        transaction["initial"],
        ["invocation_id", "rule_label", "source_id", "cursor", "anonymous_boundary", "marks"],
        "transaction initial state",
    )
    transaction_source = source_by_id.get(transaction_initial["source_id"])
    if transaction_source is None:
        fail("transaction initial state references unknown source")
    transaction_text = transaction_source["decoded_text"]
    position_coordinates(transaction_text, transaction_initial["cursor"])
    position_coordinates(transaction_text, transaction_initial["anonymous_boundary"])
    initial_marks = require_list(transaction_initial["marks"], "transaction initial marks")
    seen_initial_marks: set[str] = set()
    for mark in initial_marks:
        if (
            not isinstance(mark, list)
            or len(mark) != 2
            or not isinstance(mark[0], str)
            or not mark[0]
            or mark[0] in seen_initial_marks
        ):
            fail("transaction initial mark row is invalid or duplicated")
        seen_initial_marks.add(mark[0])
        position_coordinates(transaction_text, mark[1])
    transaction_state = {
        **copy.deepcopy(transaction_initial),
        "marks": dict(transaction_initial["marks"]),
        "tokens": {},
    }
    transaction_transitions = require_list(
        transaction["transitions"],
        "transaction transitions",
        EXPECTED_COUNTS["transaction_transitions"],
    )
    expected_transaction_ids = [
        "checkpoint_commit_path",
        "try_advance_commit_path",
        "try_boundary_commit_path",
        "try_mark_commit_path",
        "commit_path",
        "checkpoint_rollback_path",
        "try_mutate_rollback_path",
        "rollback_path",
    ]
    for expected_id, transition in zip(expected_transaction_ids, transaction_transitions, strict=True):
        require_fields(transition, ["id", "operation", "args", "expected"], "transaction transition")
        if transition["id"] != expected_id:
            fail("transaction transition identity or order drifted")
        operation = transition["operation"]
        if operation not in TRANSACTION_ARG_FIELDS:
            fail(f"unknown transaction transition operation: {operation!r}")
        args = require_fields(
            transition["args"],
            TRANSACTION_ARG_FIELDS[operation],
            f"transaction transition {expected_id!r} args",
        )
        require_fields(
            transition["expected"],
            ["cursor", "anonymous_boundary", "marks", "token", "token_state"],
            f"transaction transition {expected_id!r} expected state",
        )
        if not isinstance(args["token"], str) or not args["token"]:
            fail("transaction token must be non-empty text")
        if operation in {"try_cursor", "try_boundary", "try_mark"}:
            position_coordinates(transaction_text, args["offset"])
        if operation == "try_mark" and (not isinstance(args["name"], str) or not args["name"]):
            fail("transaction mark name must be non-empty text")
        if operation == "try_state":
            position_coordinates(transaction_text, args["cursor"])
            position_coordinates(transaction_text, args["anonymous_boundary"])
            marks = require_list(args["marks"], "transaction replacement marks")
            seen_marks: set[str] = set()
            for mark in marks:
                if (
                    not isinstance(mark, list)
                    or len(mark) != 2
                    or not isinstance(mark[0], str)
                    or not mark[0]
                    or mark[0] in seen_marks
                ):
                    fail("transaction replacement mark row is invalid or duplicated")
                seen_marks.add(mark[0])
                position_coordinates(transaction_text, mark[1])
        apply_transaction_transition(transaction_state, transition)
        token = transition["args"]["token"]
        if transaction_snapshot(transaction_state, token) != transition["expected"]:
            fail(f"transaction transition result drifted: {transition['id']!r}")

    observations = require_list(
        contract["recursive_observations"],
        "recursive observations",
        EXPECTED_COUNTS["recursive_observations"],
    )
    observed_recursive: list[tuple[Any, ...]] = []
    for observation in observations:
        require_fields(
            observation,
            [
                "id",
                "rule_label",
                "invocation_id",
                "parent_invocation_id",
                "source_id",
                "entry_offset",
                "selected_match_span_id",
                "accepted_exit_offset",
                "outcome",
                "diagnostic",
            ],
            "recursive observation",
        )
        source = source_by_id.get(observation["source_id"])
        if source is None:
            fail("recursive observation references unknown source")
        position_coordinates(source["decoded_text"], observation["entry_offset"])
        if observation["accepted_exit_offset"] is not None:
            position_coordinates(source["decoded_text"], observation["accepted_exit_offset"])
        if observation["selected_match_span_id"] is not None:
            span = span_by_id.get(observation["selected_match_span_id"])
            if span is None or span["source_id"] != observation["source_id"]:
                fail("recursive selected-match span identity drifted")
        observed_recursive.append(tuple(observation.values()))
    validate_recursive_observation_lineage(observations)
    if observed_recursive != RECURSIVE_OBSERVATIONS:
        fail("recursive observation semantics or order drifted")

    recursive_machine = require_fields(
        contract["recursive_observation_state_machine"],
        [
            "authored_surface",
            "carrier_projection",
            "family_cursor_policies",
            "match_spans",
            "initial",
            "transitions",
            "expected_final",
        ],
        "recursive observation state machine",
    )
    if recursive_machine["authored_surface"] != RECURSIVE_OBSERVATION_SURFACE:
        fail("recursive observation authored surface drifted")
    if recursive_machine["carrier_projection"] != RECURSIVE_OBSERVATION_CARRIER:
        fail("recursive observation carrier projection drifted")
    if recursive_machine["family_cursor_policies"] != RECURSIVE_FAMILY_POLICIES:
        fail("recursive observation child-family cursor policy drifted")

    recursive_spans = require_list(
        recursive_machine["match_spans"], "recursive observation match spans", 2
    )
    expected_recursive_spans = [
        ("unicode_zero_at_two", "unicode", 2, 2, ""),
        ("unicode_emoji", "unicode", 2, 3, "🙂"),
    ]
    recursive_span_by_id = dict(span_by_id)
    for expected, span in zip(expected_recursive_spans, recursive_spans, strict=True):
        require_fields(
            span,
            ["id", "source_id", "start", "end", "expected_text"],
            "recursive observation match span",
        )
        if tuple(span.values()) != expected or span["id"] in recursive_span_by_id:
            fail("recursive observation match span identity or order drifted")
        source = source_by_id.get(span["source_id"])
        if source is None:
            fail("recursive observation match span references unknown source")
        position_coordinates(source["decoded_text"], span["start"])
        position_coordinates(source["decoded_text"], span["end"])
        if (
            span["start"] > span["end"]
            or source["decoded_text"][span["start"] : span["end"]]
            != span["expected_text"]
        ):
            fail("recursive observation match span materialization drifted")
        recursive_span_by_id[span["id"]] = span

    recursive_initial = {
        "next_invocation_id": 1,
        "stack": [],
        "pending_observation": None,
        "detached_count": 0,
    }
    if recursive_machine["initial"] != recursive_initial:
        fail("recursive observation initial state drifted")
    observation_by_id = {observation["id"]: observation for observation in observations}
    recursive_state = copy.deepcopy(recursive_initial)
    detached_observations: list[dict[str, Any]] = []
    recursive_transitions = require_list(
        recursive_machine["transitions"],
        "recursive observation transitions",
        EXPECTED_COUNTS["recursive_observation_transitions"],
    )
    for expected_id, transition in zip(
        RECURSIVE_OBSERVATION_TRANSITION_IDS, recursive_transitions, strict=True
    ):
        require_fields(
            transition, ["id", "operation", "args"], "recursive observation transition"
        )
        if transition["id"] != expected_id:
            fail("recursive observation transition identity or order drifted")
        operation = transition["operation"]
        if operation not in RECURSIVE_OBSERVATION_ARG_FIELDS:
            fail(f"unknown recursive observation operation: {operation!r}")
        require_fields(
            transition["args"],
            RECURSIVE_OBSERVATION_ARG_FIELDS[operation],
            f"recursive observation transition {expected_id!r} args",
        )
        apply_recursive_observation_transition(
            recursive_state,
            transition,
            source_by_id,
            recursive_span_by_id,
            observation_by_id,
            detached_observations,
        )
    if [row["id"] for row in detached_observations] != [row["id"] for row in observations]:
        fail("recursive observation detach order drifted")
    if recursive_observation_snapshot(recursive_state) != recursive_machine["expected_final"]:
        fail("recursive observation final state or retention boundary drifted")

    for observation in detached_observations:
        projection = recursive_observation_projection(observation, recursive_span_by_id)
        require_fields(
            projection,
            RECURSIVE_OBSERVATION_CARRIER["fields"],
            "detached recursive observation projection",
        )
        require_fields(
            projection["entry_position"],
            RECURSIVE_OBSERVATION_CARRIER["position_record"],
            "recursive observation entry position",
        )
        if projection["selected_match"] is not None:
            require_fields(
                projection["selected_match"],
                RECURSIVE_OBSERVATION_CARRIER["span_record"],
                "recursive observation selected match",
            )
        if projection["accepted_exit"] is not None:
            require_fields(
                projection["accepted_exit"],
                RECURSIVE_OBSERVATION_CARRIER["position_record"],
                "recursive observation accepted exit",
            )
        if (observation["outcome"] == "accepted") != (
            projection["accepted_exit"] is not None
        ):
            fail("recursive observation accepted-exit presence drifted")
        independent_projection = recursive_observation_projection(
            observation, recursive_span_by_id
        )
        projection["entry_position"]["offset"] = -1
        if independent_projection["entry_position"]["offset"] != observation["entry_offset"]:
            fail("recursive observation projection is not detached")

    structural = require_list(
        contract["structural_authoring_cases"],
        "structural authoring cases",
        EXPECTED_COUNTS["structural_authoring_cases"],
    )
    for case in structural:
        require_fields(
            case,
            ["id", "regex_count", "role", "entry_rule_valid", "recursion_owner", "guidance"],
            "structural authoring case",
        )
    if [tuple(case.values()) for case in structural] != STRUCTURAL_CASES:
        fail("zero/one/two-regex structural authoring contract drifted")

    helper_schema = require_fields(
        contract["helper_projection_schema"],
        ["row", "families", "projection_vocabulary"],
        "helper projection schema",
    )
    if helper_schema != {
        "row": ["name", "projection"],
        "families": list(HELPER_GROUPS),
        "projection_vocabulary": PROJECTION_VOCABULARY,
    }:
        fail("helper projection schema drifted")
    projections = require_fields(contract["helper_projections"], list(HELPER_GROUPS), "helper projections")
    lua_source = LUA_CONTRACTS_PATH.read_text(encoding="utf-8")
    all_names: list[str] = []
    for family, lua_constant in HELPER_GROUPS.items():
        rows = require_list(projections[family], f"{family} helper projections")
        source_names = extract_lua_helper_names(lua_source, lua_constant)
        row_names: list[str] = []
        for row in rows:
            if not isinstance(row, list) or len(row) != 2 or not all(isinstance(item, str) for item in row):
                fail(f"{family} helper projection row drifted")
            name, projection = row
            row_names.append(name)
            if projection not in PROJECTION_VOCABULARY:
                fail(f"unknown projection vocabulary item: {projection!r}")
            if projection != expected_projection(name, family):
                fail(f"typed projection drifted for helper {name!r}")
        if row_names != source_names:
            fail(f"{family} helper membership or order drifted from current authority")
        all_names.extend(row_names)
    if len(all_names) != EXPECTED_COUNTS["helper_projections"] or len(set(all_names)) != len(all_names):
        fail("helper projection count or uniqueness drifted")

    aliases = require_list(
        contract["compatibility_aliases"],
        "compatibility aliases",
        EXPECTED_COUNTS["compatibility_aliases"],
    )
    if [tuple(alias) for alias in aliases] != ALIASES:
        fail("compatibility alias membership, order, or target drifted")
    perl_source = PERL_CONTRACTS_PATH.read_text(encoding="utf-8")
    legacy_scanner_source = PERL_LEGACY_SCANNER_PATH.read_text(encoding="utf-8")
    scanner_owned_aliases = {"entry_named_map", "match_named_map"}
    for alias, canonical in ALIASES:
        alias_record = extract_perl_contract_record(perl_source, alias)
        if alias in scanner_owned_aliases:
            scanner_pattern = f"\\b{alias}\\s*\\(\\s*\\)"
            if scanner_pattern not in legacy_scanner_source:
                fail(f"Perl legacy scanner authority is missing alias {alias!r}")
        else:
            canonical_record = extract_perl_contract_record(perl_source, canonical)
            if re.search(r"\bcompatibility_surface\s*=>\s*1", alias_record) is None:
                fail(f"Perl compatibility flag is missing for alias {alias!r}")
            if extract_perl_record_field(alias_record, alias, "diag_name") != canonical:
                fail(f"Perl alias diagnostic identity drifted for {alias!r}")
            if extract_perl_record_field(alias_record, alias, "ir_node") != extract_perl_record_field(
                canonical_record,
                canonical,
                "ir_node",
            ):
                fail(f"Perl alias IR identity drifted for {alias!r}")
            if extract_perl_runtime_calls(alias_record) != extract_perl_runtime_calls(canonical_record):
                fail(f"Perl alias runtime lowering drifted for {alias!r}")

    internal_ids = require_list(
        contract["internal_contract_ids"],
        "internal contract ids",
        EXPECTED_COUNTS["internal_contract_ids"],
    )
    if [tuple(item) for item in internal_ids] != INTERNAL_CONTRACT_IDS:
        fail("internal contract id membership, order, or canonical spelling drifted")
    for internal_id, canonical in INTERNAL_CONTRACT_IDS:
        contract_record = re.search(
            rf"id\s*=>\s*'{re.escape(internal_id)}'.{{0,300}}?diag_name\s*=>\s*'{re.escape(canonical)}'",
            perl_source,
            re.DOTALL,
        )
        scanner_record = re.search(
            rf"sub _scan_contract_{re.escape(internal_id)}\b(.*?)(?=\nsub |\Z)",
            legacy_scanner_source,
            re.DOTALL,
        )
        canonical_pattern = f"\\b{canonical}\\s*\\(\\s*\\)"
        if (
            contract_record is None
            or scanner_record is None
            or canonical_pattern not in scanner_record.group(1)
        ):
            fail(f"internal contract/scanner authority drifted for {internal_id!r}")

    diagnostic_schema = require_fields(
        contract["diagnostic_schema"],
        ["fields", "detection_values", "privacy"],
        "diagnostic schema",
    )
    if diagnostic_schema != {
        "fields": ["id", "code", "phase", "detection", "required_context"],
        "detection_values": ["static", "runtime", "static_or_runtime"],
        "privacy": "carry identities and relevant coordinates without leaking source text above the active source-detail ceiling",
    }:
        fail("diagnostic schema drifted")
    diagnostics = require_list(
        contract["diagnostics"],
        "diagnostics",
        EXPECTED_COUNTS["diagnostics"],
    )
    observed_diagnostics: list[tuple[Any, ...]] = []
    for diagnostic in diagnostics:
        require_fields(diagnostic, diagnostic_schema["fields"], "diagnostic")
        if diagnostic["code"] != f"source_location_{diagnostic['id']}":
            fail(f"diagnostic code does not derive from id: {diagnostic['id']!r}")
        if diagnostic["detection"] not in diagnostic_schema["detection_values"]:
            fail(f"diagnostic detection class drifted: {diagnostic['id']!r}")
        observed_diagnostics.append(
            (
                diagnostic["id"],
                diagnostic["phase"],
                diagnostic["detection"],
                diagnostic["required_context"],
            )
        )
    if observed_diagnostics != DIAGNOSTICS:
        fail("diagnostic membership, order, phase, detection, or context drifted")

    recurring = require_fields(
        contract["recurring_gate"],
        [
            "driver",
            "source_schema",
            "consumer_sources",
            "route_schema",
            "runtime_routes",
            "support_checks",
            "local_ci",
        ],
        "recurring gate",
    )
    if recurring != RECURRING_GATE:
        fail("recurring gate source, route, command, support, or canonical topology drifted")

    recursive_observation_recurring = require_fields(
        contract["recursive_observation_recurring_gate"],
        [
            "driver",
            "source_schema",
            "consumer_sources",
            "route_schema",
            "runtime_routes",
            "support_checks",
            "storage",
            "local_ci",
        ],
        "recursive-observation recurring gate",
    )
    if recursive_observation_recurring != RECURSIVE_OBSERVATION_RECURRING_GATE:
        fail(
            "recursive-observation recurring source, route, command, support, storage, or canonical topology drifted"
        )

    progressive_span_dispatch_recurring = require_fields(
        contract["progressive_span_dispatch_recurring_gate"],
        [
            "driver",
            "neutral_check",
            "source_schema",
            "consumer_sources",
            "route_schema",
            "runtime_routes",
            "support_checks",
            "storage",
            "local_ci",
            "rollout_assertions",
        ],
        "progressive span-dispatch recurring gate",
    )
    if (
        progressive_span_dispatch_recurring
        != PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE
    ):
        fail(
            "progressive span-dispatch recurring neutral, source, route, command, support, storage, rollout, or canonical topology drifted"
        )

    staged_ast_enrichment_recurring = require_fields(
        contract["staged_ast_enrichment_recurring_gate"],
        [
            "driver",
            "neutral_check",
            "source_schema",
            "consumer_sources",
            "route_schema",
            "runtime_routes",
            "support_checks",
            "storage",
            "local_ci",
            "rollout_assertions",
            "capability_projection",
        ],
        "staged-AST enrichment recurring gate",
    )
    if staged_ast_enrichment_recurring != STAGED_AST_ENRICHMENT_RECURRING_GATE:
        fail(
            "staged-AST enrichment recurring neutral, source, route, command, support, storage, rollout, capability, or canonical topology drifted"
        )

    rollout = require_list(contract["rollout"], "rollout", EXPECTED_COUNTS["rollout_legs"])
    observed_rollout: list[tuple[Any, ...]] = []
    for leg in rollout:
        require_fields(leg, ["leg", "status", "owner", "runtimes"], "rollout leg")
        if leg["status"] not in {"complete", "pending"}:
            fail("rollout status drifted")
        observed_rollout.append((leg["leg"], leg["status"], leg["owner"], leg["runtimes"]))
    if observed_rollout != ROLLOUT:
        fail("rollout membership, order, status, owner, or runtime coverage drifted")
    recursive_observation_public = contract[
        "recursive_observation_public_no_drift"
    ]
    validate_recursive_observation_public_no_drift(
        recursive_observation_public,
        rollout,
    )
    transaction_safety_composition = contract["transaction_safety_composition"]
    validate_transaction_safety_composition(
        transaction_safety_composition,
        rollout,
    )
    lossless_gap_composition = contract["lossless_gap_composition"]
    if lossless_gap_composition != LOSSLESS_GAP_COMPOSITION:
        fail("lossless-gap composition contract drifted")
    gap_assertions = lossless_gap_composition["rollout_assertions"]
    if gap_assertions["row_count"] != len(rollout):
        fail("lossless-gap composition changed rollout cardinality")
    rollout_by_leg = {row["leg"]: row for row in rollout}
    for leg in ("lossless_gap_composition", "recurring_public_no_drift"):
        actual = rollout_by_leg.get(leg)
        expected = gap_assertions[leg]
        if actual is None or {
            "status": actual["status"],
            "owner": actual["owner"],
        } != expected:
            fail(f"lossless-gap composition rollout assertion drifted: {leg}")

    progressive_assertions = progressive_span_dispatch_recurring[
        "rollout_assertions"
    ]
    if progressive_assertions["row_count"] != len(rollout):
        fail("progressive span-dispatch recurrence changed rollout cardinality")
    for leg in (
        "progressive_span_dispatch",
        "staged_span_dispatch",
        "recurring_public_no_drift",
    ):
        actual = rollout_by_leg.get(leg)
        expected = progressive_assertions[leg]
        if actual is None or {
            "status": actual["status"],
            "owner": actual["owner"],
        } != expected:
            fail(f"progressive span-dispatch rollout assertion drifted: {leg}")

    staged_assertions = staged_ast_enrichment_recurring["rollout_assertions"]
    if staged_assertions["row_count"] != len(rollout):
        fail("staged-AST enrichment recurrence changed rollout cardinality")
    for leg in ("staged_span_dispatch", "recurring_public_no_drift"):
        actual = rollout_by_leg.get(leg)
        expected = staged_assertions[leg]
        if actual is None or {
            "status": actual["status"],
            "owner": actual["owner"],
        } != expected:
            fail(f"staged-AST enrichment rollout assertion drifted: {leg}")

    program_wide_public = contract["program_wide_public_no_drift"]
    validate_program_wide_public_no_drift(program_wide_public, rollout)

    actual_counts = {
        "sources": len(sources),
        "position_conversions": len(positions),
        "direct_spans": len(spans),
        "derived_text_cases": len(derived_cases),
        "invocation_transitions": len(invocation_transitions),
        "transaction_transitions": len(transaction_transitions),
        "recursive_observation_transitions": len(recursive_transitions),
        "recursive_observations": len(observations),
        "structural_authoring_cases": len(structural),
        "helper_projections": len(all_names),
        "compatibility_aliases": len(aliases),
        "internal_contract_ids": len(internal_ids),
        "diagnostics": len(diagnostics),
        "rollout_legs": len(rollout),
        "recurring_source_groups": len(recurring["consumer_sources"]),
        "recurring_runtime_routes": len(recurring["runtime_routes"]),
        "recursive_observation_recurring_source_groups": len(
            recursive_observation_recurring["consumer_sources"]
        ),
        "recursive_observation_recurring_runtime_routes": len(
            recursive_observation_recurring["runtime_routes"]
        ),
        "progressive_span_dispatch_recurring_source_groups": len(
            progressive_span_dispatch_recurring["consumer_sources"]
        ),
        "progressive_span_dispatch_recurring_runtime_routes": len(
            progressive_span_dispatch_recurring["runtime_routes"]
        ),
        "staged_ast_enrichment_recurring_source_groups": len(
            staged_ast_enrichment_recurring["consumer_sources"]
        ),
        "staged_ast_enrichment_recurring_runtime_routes": len(
            staged_ast_enrichment_recurring["runtime_routes"]
        ),
        "recursive_observation_public_documents": len(
            recursive_observation_public["documents"]
        ),
        "recursive_observation_public_forbidden_claims": len(
            recursive_observation_public["forbidden_claims"]
        ),
        "recursive_observation_public_surface_guard_paths": len(
            recursive_observation_public["surface_guard"]["paths"]
        ),
        "program_wide_recurring_drivers": len(
            program_wide_public["recurring_composition"]["ordered_drivers"]
        ),
        "program_wide_public_documents": len(program_wide_public["documents"]),
        "program_wide_public_forbidden_claims": len(
            program_wide_public["forbidden_claims"]
        ),
        "program_wide_authoring_safety_claims": len(
            program_wide_public["authoring_safety"]["forbidden_claims"]
        ),
        "program_wide_public_surface_guard_paths": len(
            program_wide_public["surface_guard"]["paths"]
        ),
        "mutations": EXPECTED_COUNTS["mutations"],
    }
    if actual_counts != EXPECTED_COUNTS:
        fail("derived contract counts drifted")

    if check_registration:
        for path in (
            CONTRACT_PATH,
            CHECKER_PATH,
            ROOT / CANONICAL_EXECUTION["project_data_runner"],
            CI_PATH,
            PERL_VALUE_CONSUMER_PATH,
            PERL_PROJECTION_CONSUMER_PATH,
            RUST_CONSUMER_PATH,
            RUST_OBSERVATION_CONSUMER_PATH,
            DART_CONSUMER_PATH,
            DART_OBSERVATION_CONSUMER_PATH,
            JULIA_CONSUMER_PATH,
            JULIA_OBSERVATION_CONSUMER_PATH,
            JULIA_RUNTESTS_PATH,
            LUA_CONSUMER_PATH,
            LUA_OBSERVATION_CONSUMER_PATH,
            LUA_ORDINARY_DRIVER_PATH,
            RECURRING_DRIVER_PATH,
            RECURSIVE_OBSERVATION_RECURRING_DRIVER_PATH,
            PROGRESSIVE_SPAN_DISPATCH_RECURRING_DRIVER_PATH,
            STAGED_AST_ENRICHMENT_RECURRING_DRIVER_PATH,
            TYPED_AUTHORING_MODEL_RECURRING_DRIVER_PATH,
            LOSSLESS_GAP_CONTRACT_PATH,
            LOSSLESS_GAP_CHECKER_PATH,
            LOSSLESS_GAP_DRIVER_PATH,
            TYPED_GAP_COMPOSITION_DRIVER_PATH,
            RECOGNITION_TRANSACTION_CONTRACT_PATH,
            RECOGNITION_TRANSACTION_CHECKER_PATH,
            RECOGNITION_TRANSACTION_DRIVER_PATH,
            PROJECT_DATA_WORKFLOW_ROUTING_PATH,
        ):
            if not path.is_file():
                fail(f"canonical contract/checker/runner input is missing: {path.relative_to(ROOT)}")
        public_document_texts, public_surface_texts = recursive_observation_public_texts(
            recursive_observation_public
        )
        validate_recursive_observation_public_no_drift(
            recursive_observation_public,
            rollout,
            public_document_texts,
            public_surface_texts,
        )
        transaction_document_texts = transaction_safety_composition_texts(
            transaction_safety_composition
        )
        validate_transaction_safety_composition(
            transaction_safety_composition,
            rollout,
            transaction_document_texts,
        )
        (
            program_document_texts,
            program_safety_texts,
            program_surface_texts,
        ) = program_wide_public_texts(program_wide_public)
        validate_program_wide_public_no_drift(
            program_wide_public,
            rollout,
            program_document_texts,
            program_safety_texts,
            program_surface_texts,
        )
        recognition_contract = json.loads(
            RECOGNITION_TRANSACTION_CONTRACT_PATH.read_text(encoding="utf-8")
        )
        recognition_authority = transaction_safety_composition[
            "upstream_recognition_authority"
        ]
        recognition_counts = recognition_contract.get("expected_counts", {})
        recognition_rollout = recognition_contract.get("rollout", [])
        if recognition_contract.get("contract_id") != recognition_authority["contract_id"]:
            fail("transaction-safety upstream recognition contract identity drifted")
        if recognition_contract.get("status") != recognition_authority["status"]:
            fail("transaction-safety upstream recognition status drifted")
        if {
            "complete": sum(row.get("status") == "complete" for row in recognition_rollout),
            "pending": sum(row.get("status") == "pending" for row in recognition_rollout),
            "semantic_mutations": recognition_counts.get("mutations"),
        } != recognition_authority["rollout"]:
            fail("transaction-safety upstream rollout or mutation authority drifted")
        recurring_gate = recognition_contract.get("recurring_gate", {})
        if {
            "source_groups": len(recurring_gate.get("consumer_sources", [])),
            "runtime_routes": len(recurring_gate.get("runtime_routes", [])),
        } != recognition_authority["topology"]:
            fail("transaction-safety upstream recurring topology drifted")
        effect_model = recognition_contract.get("effect_model", {})
        if {
            "allowed": len(effect_model.get("allowed", [])),
            "rejected": len(effect_model.get("rejected", [])),
            "uncommitted_dispatch_effect": "parser_registry_or_staged_dispatch",
        } != recognition_authority["effects"]:
            fail("transaction-safety upstream effect authority drifted")
        if "parser_registry_or_staged_dispatch" not in effect_model.get("rejected", []):
            fail("transaction-safety upstream uncommitted-dispatch rejection drifted")
        progress_cases = recognition_contract.get("fixtures", {}).get("progress", [])
        if len(progress_cases) != recognition_authority["progress"]["cases"]:
            fail("transaction-safety upstream progress fixture authority drifted")
        if recognition_contract.get("policy", {}).get("progress") != recognition_authority["progress"]["policy"]:
            fail("transaction-safety upstream progress policy drifted")
        gap_contract = json.loads(LOSSLESS_GAP_CONTRACT_PATH.read_text(encoding="utf-8"))
        upstream = lossless_gap_composition["upstream_gap_authority"]
        if gap_contract.get("contract_id") != upstream["contract_id"]:
            fail("lossless-gap upstream contract identity drifted")
        gap_counts = gap_contract.get("expected_counts", {})
        gap_rollout = gap_contract.get("rollout", [])
        if {
            "complete": sum(row.get("status") == "complete" for row in gap_rollout),
            "pending": sum(row.get("status") == "pending" for row in gap_rollout),
            "semantic_mutations": gap_counts.get("semantic_mutations"),
        } != upstream["rollout"]:
            fail("lossless-gap upstream rollout or mutation authority drifted")
        gap_public = gap_contract.get("public_contract", {})
        expected_gap_public = upstream["public"]
        if {
            "documents": len(gap_public.get("documents", [])),
            "forbidden_current_claims": len(
                gap_public.get("forbidden_current_claims", [])
            ),
            "surface_guard_paths": len(
                gap_public.get("surface_guard", {}).get("paths", [])
            ),
            "mutations": expected_gap_public["mutations"],
        } != expected_gap_public:
            fail("lossless-gap upstream public authority drifted")
        ci_text = CI_PATH.read_text(encoding="utf-8")
        required_markers = [
            f"require_tracked_file {CANONICAL_EXECUTION['contract_path']}",
            f"require_tracked_file {CANONICAL_EXECUTION['checker_path']}",
            CANONICAL_EXECUTION["invocation"],
            "require_tracked_file t/typed_source_location_values.t",
            "require_tracked_file t/typed_source_location_perl_contract.t",
            "require_tracked_file t/recursive_observation_perl_contract.t",
            "perl -c -Iperl t/typed_source_location_values.t",
            "perl -c -Iperl t/typed_source_location_perl_contract.t",
            "perl -c -Iperl t/recursive_observation_perl_contract.t",
            "PERL5LIB= prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t t/recursive_observation_perl_contract.t",
            "require_tracked_file rust/linkedspec-runtime/tests/typed_source_location_contract.rs",
            "require_tracked_file rust/linkedspec-runtime/tests/recursive_observation_contract.rs",
            "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract --test recursive_observation_contract",
            "require_tracked_file dart/test/typed_source_location_contract_test.dart",
            "require_tracked_file dart/test/recursive_observation_contract_test.dart",
            "bash ../tools/run_dart_project_data.sh test --reporter failures-only test/typed_source_location_contract_test.dart test/recursive_observation_contract_test.dart",
            "require_tracked_file julia/test/typed_source_location_contract_test.jl",
            "require_tracked_file julia/test/recursive_observation_contract_test.jl",
            "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include(\"julia/test/typed_source_location_contract_test.jl\"); include(\"julia/test/recursive_observation_contract_test.jl\")'",
            "require_tracked_file lua/test/typed_source_location_contract_test.lua",
            "require_tracked_file lua/test/recursive_observation_contract_test.lua",
            "bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua",
            "bash tools/run_lua_project_data.sh puc lua/test/recursive_observation_contract_test.lua",
            "bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua",
            "bash tools/run_lua_project_data.sh luajit lua/test/recursive_observation_contract_test.lua",
        ]
        for marker in required_markers:
            if ci_text.count(marker) != 1:
                fail(f"canonical registration marker must appear exactly once: {marker}")
        if CI_PATH.name != Path(CANONICAL_EXECUTION["canonical_driver"]).name:
            fail("canonical driver identity drifted")
        recurring_driver_text = RECURRING_DRIVER_PATH.read_text(encoding="utf-8")
        recurring_markers = [
            CANONICAL_EXECUTION["invocation"],
            *[route["command"] for route in RECURRING_GATE["runtime_routes"]],
            *RECURRING_GATE["support_checks"],
        ]
        recurring_positions: list[int] = []
        for marker in recurring_markers:
            if recurring_driver_text.count(marker) != 1:
                fail(f"recurring driver marker must appear exactly once: {marker}")
            recurring_positions.append(recurring_driver_text.index(marker))
        if recurring_positions != sorted(recurring_positions):
            fail("recurring driver neutral/runtime/support order drifted")
        for source in RECURRING_GATE["consumer_sources"]:
            for relative_path in source["paths"]:
                if not (ROOT / relative_path).is_file():
                    fail(f"recurring consumer source is missing: {relative_path}")
        recurring_ci = RECURRING_GATE["local_ci"]
        if recurring_ci["driver"] != CI_PATH.relative_to(ROOT).as_posix():
            fail("recurring canonical driver identity drifted")
        recurring_ci_markers = (
            f"require_tracked_file {RECURRING_GATE['driver']}",
            f'if [[ "${{{recurring_ci["switch"]}:-0}}" == "1" ]]; then',
            f'bash "$REPO_ROOT/{RECURRING_GATE["driver"]}"',
        )
        expected_ci_counts = (2, 1, 1)
        for marker, expected_count in zip(recurring_ci_markers, expected_ci_counts, strict=True):
            if ci_text.count(marker) != expected_count:
                fail(
                    "recurring canonical registration marker count drifted: "
                    f"{marker} expected {expected_count}"
                )
        observation_recurring_driver_text = (
            RECURSIVE_OBSERVATION_RECURRING_DRIVER_PATH.read_text(encoding="utf-8")
        )
        observation_storage = RECURSIVE_OBSERVATION_RECURRING_GATE["storage"]
        if observation_storage != {
            "initializer": "tools/project_data_env.sh",
            "managed_entrypoint": "tools/check_recursive_observation_six_runtime.sh",
            "policy": "all temporary, cache, build, native, and test data stays under repository-derived storage",
        }:
            fail("recursive-observation recurring storage topology drifted")
        for marker in (
            'source "$REPO_ROOT/tools/project_data_env.sh"',
            'linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_recursive_observation_six_runtime.sh" "$@"',
        ):
            if observation_recurring_driver_text.count(marker) != 1:
                fail(
                    "recursive-observation recurring driver is not repository-routed: "
                    f"{marker}"
                )
        observation_markers = [
            CANONICAL_EXECUTION["invocation"],
            *[
                route["command"]
                for route in RECURSIVE_OBSERVATION_RECURRING_GATE["runtime_routes"]
            ],
            *RECURSIVE_OBSERVATION_RECURRING_GATE["support_checks"],
        ]
        observation_positions: list[int] = []
        for marker in observation_markers:
            if observation_recurring_driver_text.count(marker) != 1:
                fail(
                    "recursive-observation recurring driver marker must appear exactly once: "
                    f"{marker}"
                )
            observation_positions.append(observation_recurring_driver_text.index(marker))
        if observation_positions != sorted(observation_positions):
            fail("recursive-observation recurring neutral/runtime/support order drifted")
        observation_sources = RECURSIVE_OBSERVATION_RECURRING_GATE["consumer_sources"]
        observation_source_paths = [
            relative_path
            for source in observation_sources
            for relative_path in source["paths"]
        ]
        if len(observation_source_paths) != len(set(observation_source_paths)):
            fail("recursive-observation recurring consumer source duplication drifted")
        for relative_path in observation_source_paths:
            if not (ROOT / relative_path).is_file():
                fail(
                    "recursive-observation recurring consumer source is missing: "
                    f"{relative_path}"
                )
        observation_route_backends = {
            row["source_backend"]
            for row in RECURSIVE_OBSERVATION_RECURRING_GATE["runtime_routes"]
        }
        observation_source_backends = {row["backend"] for row in observation_sources}
        if observation_route_backends != observation_source_backends:
            fail("recursive-observation recurring route/source binding drifted")
        observation_ci = RECURSIVE_OBSERVATION_RECURRING_GATE["local_ci"]
        if observation_ci["driver"] != CI_PATH.relative_to(ROOT).as_posix():
            fail("recursive-observation recurring canonical driver identity drifted")
        observation_ci_markers = (
            f"require_tracked_file {RECURSIVE_OBSERVATION_RECURRING_GATE['driver']}",
            f'if [[ "${{{observation_ci["switch"]}:-0}}" == "1" ]]; then',
            f'bash "$REPO_ROOT/{RECURSIVE_OBSERVATION_RECURRING_GATE["driver"]}"',
        )
        for marker, expected_count in zip(
            observation_ci_markers, (2, 1, 1), strict=True
        ):
            if ci_text.count(marker) != expected_count:
                fail(
                    "recursive-observation recurring canonical registration marker count drifted: "
                    f"{marker} expected {expected_count}"
                )
        workflow_routing_text = PROJECT_DATA_WORKFLOW_ROUTING_PATH.read_text(
            encoding="utf-8"
        )
        if workflow_routing_text.count(
            "tools/check_recursive_observation_six_runtime.sh"
        ) != 1:
            fail("recursive-observation recurring project-data routing registration drifted")
        progressive_driver_text = (
            PROGRESSIVE_SPAN_DISPATCH_RECURRING_DRIVER_PATH.read_text(
                encoding="utf-8"
            )
        )
        if not PROGRESSIVE_SPAN_DISPATCH_RECURRING_DRIVER_PATH.stat().st_mode & 0o111:
            fail("progressive span-dispatch recurring driver is not executable")
        progressive_storage = PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE["storage"]
        if progressive_storage != {
            "initializer": "tools/project_data_env.sh",
            "managed_entrypoint": "tools/check_progressive_span_dispatch_six_runtime.sh",
            "policy": "all temporary, cache, build, native, and test data stays under repository-derived storage",
        }:
            fail("progressive span-dispatch recurring storage topology drifted")
        for marker in (
            'source "$REPO_ROOT/tools/project_data_env.sh"',
            'linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_progressive_span_dispatch_six_runtime.sh" "$@"',
        ):
            if progressive_driver_text.count(marker) != 1:
                fail(
                    "progressive span-dispatch recurring driver is not repository-routed: "
                    f"{marker}"
                )
        progressive_markers = [
            PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE["neutral_check"],
            *[
                route["command"]
                for route in PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE[
                    "runtime_routes"
                ]
            ],
            *PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE["support_checks"],
        ]
        progressive_positions: list[int] = []
        for marker in progressive_markers:
            if progressive_driver_text.count(marker) != 1:
                fail(
                    "progressive span-dispatch recurring driver marker must appear exactly once: "
                    f"{marker}"
                )
            progressive_positions.append(progressive_driver_text.index(marker))
        if progressive_positions != sorted(progressive_positions):
            fail(
                "progressive span-dispatch recurring neutral/runtime/support order drifted"
            )
        progressive_sources = PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE[
            "consumer_sources"
        ]
        progressive_source_paths = [
            relative_path
            for source in progressive_sources
            for relative_path in source["paths"]
        ]
        if len(progressive_source_paths) != len(set(progressive_source_paths)):
            fail("progressive span-dispatch recurring consumer source duplication drifted")
        for relative_path in progressive_source_paths:
            if not (ROOT / relative_path).is_file():
                fail(
                    "progressive span-dispatch recurring consumer source is missing: "
                    f"{relative_path}"
                )
        progressive_route_backends = {
            row["source_backend"]
            for row in PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE["runtime_routes"]
        }
        progressive_source_backends = {
            row["backend"] for row in progressive_sources
        }
        if progressive_route_backends != progressive_source_backends:
            fail("progressive span-dispatch recurring route/source binding drifted")
        progressive_ci = PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE["local_ci"]
        if progressive_ci["driver"] != CI_PATH.relative_to(ROOT).as_posix():
            fail("progressive span-dispatch recurring canonical driver identity drifted")
        progressive_ci_markers = (
            f"require_tracked_file {PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE['driver']}",
            f'if [[ "${{{progressive_ci["switch"]}:-0}}" == "1" ]]; then',
            f'bash "$REPO_ROOT/{PROGRESSIVE_SPAN_DISPATCH_RECURRING_GATE["driver"]}"',
        )
        for marker, expected_count in zip(
            progressive_ci_markers, (2, 1, 1), strict=True
        ):
            if ci_text.count(marker) != expected_count:
                fail(
                    "progressive span-dispatch recurring canonical registration marker count drifted: "
                    f"{marker} expected {expected_count}"
                )
        if workflow_routing_text.count(
            "tools/check_progressive_span_dispatch_six_runtime.sh"
        ) != 2:
            fail(
                "progressive span-dispatch recurring project-data routing registration drifted"
            )
        staged_driver_text = STAGED_AST_ENRICHMENT_RECURRING_DRIVER_PATH.read_text(
            encoding="utf-8"
        )
        if not STAGED_AST_ENRICHMENT_RECURRING_DRIVER_PATH.stat().st_mode & 0o111:
            fail("staged-AST enrichment recurring driver is not executable")
        staged_storage = STAGED_AST_ENRICHMENT_RECURRING_GATE["storage"]
        for marker in (
            f'source "$REPO_ROOT/{staged_storage["initializer"]}"',
            f'linkedspec_project_data_enter_run "$REPO_ROOT/{staged_storage["managed_entrypoint"]}" "$@"',
        ):
            if staged_driver_text.count(marker) != 1:
                fail(
                    "staged-AST enrichment recurring driver is not repository-routed: "
                    f"{marker}"
                )
        staged_markers = [
            STAGED_AST_ENRICHMENT_RECURRING_GATE["neutral_check"],
            *[
                route["command"]
                for route in STAGED_AST_ENRICHMENT_RECURRING_GATE["runtime_routes"]
            ],
            *STAGED_AST_ENRICHMENT_RECURRING_GATE["support_checks"],
        ]
        staged_positions: list[int] = []
        for marker in staged_markers:
            if staged_driver_text.count(marker) != 1:
                fail(
                    "staged-AST enrichment recurring driver marker must appear exactly once: "
                    f"{marker}"
                )
            staged_positions.append(staged_driver_text.index(marker))
        if staged_positions != sorted(staged_positions):
            fail("staged-AST enrichment recurring neutral/runtime/support order drifted")
        staged_sources = STAGED_AST_ENRICHMENT_RECURRING_GATE["consumer_sources"]
        staged_source_paths = [
            relative_path
            for source in staged_sources
            for relative_path in source["paths"]
        ]
        if len(staged_source_paths) != len(set(staged_source_paths)):
            fail("staged-AST enrichment recurring consumer source duplication drifted")
        for relative_path in staged_source_paths:
            if not (ROOT / relative_path).is_file():
                fail(
                    "staged-AST enrichment recurring consumer source is missing: "
                    f"{relative_path}"
                )
        if {
            row["source_backend"]
            for row in STAGED_AST_ENRICHMENT_RECURRING_GATE["runtime_routes"]
        } != {row["backend"] for row in staged_sources}:
            fail("staged-AST enrichment recurring route/source binding drifted")
        staged_ci = STAGED_AST_ENRICHMENT_RECURRING_GATE["local_ci"]
        if staged_ci["driver"] != CI_PATH.relative_to(ROOT).as_posix():
            fail("staged-AST enrichment recurring canonical driver identity drifted")
        staged_ci_markers = (
            f"require_tracked_file {STAGED_AST_ENRICHMENT_RECURRING_GATE['driver']}",
            f'if [[ "${{{staged_ci["switch"]}:-0}}" == "1" ]]; then',
            f'bash "$REPO_ROOT/{STAGED_AST_ENRICHMENT_RECURRING_GATE["driver"]}"',
        )
        for marker, expected_count in zip(staged_ci_markers, (2, 1, 1), strict=True):
            if ci_text.count(marker) != expected_count:
                fail(
                    "staged-AST enrichment recurring canonical registration marker count drifted: "
                    f"{marker} expected {expected_count}"
                )
        if workflow_routing_text.count(
            STAGED_AST_ENRICHMENT_RECURRING_GATE["driver"]
        ) != 2:
            fail("staged-AST enrichment recurring project-data routing registration drifted")
        program_composition = program_wide_public["recurring_composition"]
        program_driver_text = TYPED_AUTHORING_MODEL_RECURRING_DRIVER_PATH.read_text(
            encoding="utf-8"
        )
        if not TYPED_AUTHORING_MODEL_RECURRING_DRIVER_PATH.stat().st_mode & 0o111:
            fail("typed authoring-model recurring driver is not executable")
        program_storage = program_composition["storage"]
        for marker in (
            f'source "$REPO_ROOT/{program_storage["initializer"]}"',
            f'linkedspec_project_data_enter_run "$REPO_ROOT/{program_storage["managed_entrypoint"]}" "$@"',
        ):
            if program_driver_text.count(marker) != 1:
                fail(
                    "typed authoring-model recurring driver is not repository-routed: "
                    f"{marker}"
                )
        program_positions: list[int] = []
        for driver in program_composition["ordered_drivers"]:
            marker = f'bash "$REPO_ROOT/{driver}"'
            if program_driver_text.count(marker) != 1:
                fail(
                    "typed authoring-model recurring driver marker must appear exactly once: "
                    f"{marker}"
                )
            program_positions.append(program_driver_text.index(marker))
        if program_positions != sorted(program_positions):
            fail("typed authoring-model recurring driver order drifted")
        program_ci = program_composition["local_ci"]
        if program_ci["driver"] != CI_PATH.relative_to(ROOT).as_posix():
            fail("typed authoring-model canonical driver identity drifted")
        program_ci_markers = (
            f"require_tracked_file {program_composition['driver']}",
            f'if [[ "${{{program_ci["switch"]}:-0}}" == "1" ]]; then',
            f'bash "$REPO_ROOT/{program_composition["driver"]}"',
        )
        for marker, expected_count in zip(
            program_ci_markers, (2, 1, 1), strict=True
        ):
            if ci_text.count(marker) != expected_count:
                fail(
                    "typed authoring-model canonical registration marker count drifted: "
                    f"{marker} expected {expected_count}"
                )
        if workflow_routing_text.count(program_composition["driver"]) != 2:
            fail("typed authoring-model project-data routing registration drifted")
        capability_projection = STAGED_AST_ENRICHMENT_RECURRING_GATE[
            "capability_projection"
        ]
        capability_manifest = json.loads(
            (ROOT / capability_projection["manifest"]).read_text(encoding="utf-8")
        )
        capability_rows = [
            row
            for row in capability_manifest["capabilities"]
            if row["id"] == capability_projection["capability_id"]
        ]
        if len(capability_rows) != 1 or any(
            backend["status"] != capability_projection["backend_status"]
            for backend in capability_rows[0]["backends"].values()
        ):
            fail("staged-AST enrichment capability projection drifted")
        if any(
            row["id"] == "future.general_parse_job_authoring"
            for row in capability_manifest["excluded_or_future"]
        ):
            fail("satisfied staged-AST public-authoring exclusion remains present")
        if (
            capability_projection["public_authoring_contract"]
            != STAGED_AST_ENRICHMENT_CONTRACT_PATH.relative_to(ROOT).as_posix()
            or capability_projection["public_authoring_status"] != "current"
        ):
            fail("staged-AST public-authoring projection drifted")
        staged_contract = json.loads(
            STAGED_AST_ENRICHMENT_CONTRACT_PATH.read_text(encoding="utf-8")
        )
        if (
            staged_contract.get("status")
            != "all_backends_complete_recurring_and_public_current"
            or staged_contract.get("rollout", [{}])[-1].get("status") != "complete"
        ):
            fail("staged-AST public-authoring contract is not current")
        composition_gate = lossless_gap_composition["recurring_gate"]
        composition_driver_text = TYPED_GAP_COMPOSITION_DRIVER_PATH.read_text(
            encoding="utf-8"
        )
        if not TYPED_GAP_COMPOSITION_DRIVER_PATH.stat().st_mode & 0o111:
            fail("typed gap-composition driver is not executable")
        composition_positions: list[int] = []
        for marker in composition_gate["ordered_checks"]:
            if composition_driver_text.count(marker) != 1:
                fail(
                    "typed gap-composition driver marker must appear exactly once: "
                    f"{marker}"
                )
            composition_positions.append(composition_driver_text.index(marker))
        if composition_positions != sorted(composition_positions):
            fail("typed gap-composition driver check order drifted")
        composition_storage = composition_gate["storage"]
        for marker in (
            f'source "$REPO_ROOT/{composition_storage["initializer"]}"',
            f'linkedspec_project_data_enter_run "$REPO_ROOT/{composition_storage["managed_entrypoint"]}" "$@"',
        ):
            if composition_driver_text.count(marker) != 1:
                fail(f"typed gap-composition driver is not repository-routed: {marker}")
        composition_ci = composition_gate["local_ci"]
        composition_ci_markers = (
            f"require_tracked_file {composition_gate['driver']}",
            f'if [[ "${{{composition_ci["switch"]}:-0}}" == "1" ]]; then',
            f'bash "$REPO_ROOT/{composition_gate["driver"]}"',
        )
        for marker, expected_count in zip(
            composition_ci_markers, (2, 1, 1), strict=True
        ):
            if ci_text.count(marker) != expected_count:
                fail(
                    "typed gap-composition canonical registration marker count drifted: "
                    f"{marker} expected {expected_count}"
                )
        if workflow_routing_text.count(composition_gate["driver"]) != 2:
            fail("typed gap-composition project-data routing registration drifted")
        rust_consumer_text = RUST_CONSUMER_PATH.read_text(encoding="utf-8")
        for dormant_marker in (
            "linkedspec_typed_source_red",
            "linkedspec_typed_source_projection_red",
        ):
            if dormant_marker in rust_consumer_text:
                fail(f"Rust consumer remains dormant behind {dormant_marker}")
        if DART_DORMANT_CONSUMER_PATH.exists():
            fail("Dart consumer remains outside ordinary test discovery")
        dart_consumer_text = DART_CONSUMER_PATH.read_text(encoding="utf-8")
        for stale_marker in (
            "test_dormant/typed_source_location_contract_test.dart",
            "pre-admission directory",
        ):
            if stale_marker in dart_consumer_text:
                fail(f"Dart consumer retains stale dormancy marker: {stale_marker}")
        julia_runtests_text = JULIA_RUNTESTS_PATH.read_text(encoding="utf-8")
        julia_include = 'include("typed_source_location_contract_test.jl")'
        if julia_runtests_text.count(julia_include) != 1:
            fail("Julia typed-source consumer must appear exactly once in ordinary discovery")
        julia_observation_include = 'include("recursive_observation_contract_test.jl")'
        if julia_runtests_text.count(julia_observation_include) != 1:
            fail("Julia recursive-observation consumer must appear exactly once in ordinary discovery")
        julia_consumer_text = JULIA_CONSUMER_PATH.read_text(encoding="utf-8")
        for stale_marker in (
            "JULIA_TYPED_SOURCE_RED_MODE",
            "dormant Julia typed source-location RED",
            "pre-admission consumer",
        ):
            if stale_marker in julia_consumer_text:
                fail(f"Julia consumer retains stale dormancy marker: {stale_marker}")
        julia_observation_text = JULIA_OBSERVATION_CONSUMER_PATH.read_text(
            encoding="utf-8"
        )
        for marker in (
            "observe_recognition(observation, call(Child))",
            '"observe_recognition"',
            "execute_generated_parser_v2",
            "emit_julia_source_v2",
        ):
            if marker not in julia_observation_text:
                fail(f"Julia recursive-observation consumer marker is missing: {marker}")
        lua_ordinary_text = LUA_ORDINARY_DRIVER_PATH.read_text(encoding="utf-8")
        lua_ordinary_markers = (
            'LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" '
            "lua/test/typed_source_location_contract_test.lua",
            'LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" '
            "lua/test/recursive_observation_contract_test.lua",
            'LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \\\n'
            '  "$LUAJIT_CMD" lua/test/typed_source_location_contract_test.lua',
            'LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \\\n'
            '  "$LUAJIT_CMD" lua/test/recursive_observation_contract_test.lua',
        )
        for marker in lua_ordinary_markers:
            if lua_ordinary_text.count(marker) != 1:
                fail(f"Lua ordinary typed-source registration must appear exactly once: {marker}")
        lua_consumer_text = LUA_CONSUMER_PATH.read_text(encoding="utf-8")
        for stale_marker in (
            "LINKEDSPEC_LUA_TYPED_SOURCE_RED_MODE",
            "dormant shared Lua typed source-location RED",
            "pre-admission consumer",
            'mode == "projection"',
        ):
            if stale_marker in lua_consumer_text:
                fail(f"Lua consumer retains stale dormancy marker: {stale_marker}")
        lua_observation_text = LUA_OBSERVATION_CONSUMER_PATH.read_text(
            encoding="utf-8"
        )
        for marker in (
            "observe_recognition(observation, call(Child))",
            'objects_with_kind(top, "observe_recognition")',
            "execute_generated_parser_v2",
            "emit_lua_source_v2",
        ):
            if marker not in lua_observation_text:
                fail(f"Lua recursive-observation consumer marker is missing: {marker}")


def expect_mutation_failure(
    contract: dict[str, Any], name: str, mutate: Callable[[dict[str, Any]], None]
) -> None:
    candidate = copy.deepcopy(contract)
    mutate(candidate)
    try:
        validate_contract(candidate, check_registration=False)
    except ContractError:
        return
    fail(f"mutation {name!r} was not rejected")


def mutation_checks(contract: dict[str, Any]) -> int:
    def transaction_out_of_range(candidate: dict[str, Any]) -> None:
        transition = candidate["transaction_state_machine"]["transitions"][6]
        transition["args"].update(
            {"cursor": 5, "anonymous_boundary": 5, "marks": [["m", 5]]}
        )
        transition["expected"].update(
            {"cursor": 5, "anonymous_boundary": 5, "marks": [["m", 5]]}
        )

    def swap_recurring_routes(candidate: dict[str, Any]) -> None:
        routes = candidate["recurring_gate"]["runtime_routes"]
        routes[0], routes[1] = routes[1], routes[0]

    def swap_recursive_observation_recurring_routes(candidate: dict[str, Any]) -> None:
        routes = candidate["recursive_observation_recurring_gate"]["runtime_routes"]
        routes[0], routes[1] = routes[1], routes[0]

    def swap_progressive_span_dispatch_recurring_routes(
        candidate: dict[str, Any],
    ) -> None:
        routes = candidate["progressive_span_dispatch_recurring_gate"][
            "runtime_routes"
        ]
        routes[0], routes[1] = routes[1], routes[0]

    def swap_staged_ast_enrichment_recurring_routes(
        candidate: dict[str, Any],
    ) -> None:
        routes = candidate["staged_ast_enrichment_recurring_gate"][
            "runtime_routes"
        ]
        routes[0], routes[1] = routes[1], routes[0]

    def recursive_self_parent(candidate: dict[str, Any]) -> None:
        observation = candidate["recursive_observations"][4]
        observation["parent_invocation_id"] = observation["invocation_id"]

    def recursive_reused_identity(candidate: dict[str, Any]) -> None:
        observations = candidate["recursive_observations"]
        observations[5]["invocation_id"] = observations[4]["invocation_id"]

    def recursive_parent_order(candidate: dict[str, Any]) -> None:
        candidate["recursive_observations"][0]["parent_invocation_id"] = 3

    def recursive_cycle(candidate: dict[str, Any]) -> None:
        observations = candidate["recursive_observations"]
        observations[0]["parent_invocation_id"] = observations[2]["invocation_id"]
        observations[2]["parent_invocation_id"] = observations[0]["invocation_id"]

    def direct_entry_match(candidate: dict[str, Any]) -> None:
        candidate["recursive_observation_state_machine"]["transitions"][12]["args"][
            "entry_match_span_id"
        ] = "unicode_newline"

    def action_entry_match_missing(candidate: dict[str, Any]) -> None:
        candidate["recursive_observation_state_machine"]["transitions"][2]["args"][
            "entry_match_span_id"
        ] = None

    def child_entry_cursor_override(candidate: dict[str, Any]) -> None:
        candidate["recursive_observation_state_machine"]["transitions"][2]["args"][
            "caller_cursor"
        ] = 3

    def child_family_policy_override(candidate: dict[str, Any]) -> None:
        candidate["recursive_observation_state_machine"]["family_cursor_policies"][
            "or_default"
        ] = "consume"

    def terminal_match_not_replaced(candidate: dict[str, Any]) -> None:
        candidate["recursive_observation_state_machine"]["transitions"][4]["args"][
            "span_id"
        ] = "unicode_emoji"

    def accepted_exit_before_match(candidate: dict[str, Any]) -> None:
        candidate["recursive_observation_state_machine"]["transitions"][5]["args"][
            "exit_offset"
        ] = 3

    def failed_outcome_gains_exit(candidate: dict[str, Any]) -> None:
        transition = candidate["recursive_observation_state_machine"]["transitions"][13]
        transition["operation"] = "accept"
        transition["args"] = {"invocation_id": 5, "exit_offset": 0}

    def rejected_child_cursor_override(candidate: dict[str, Any]) -> None:
        candidate["recursive_observation_state_machine"]["transitions"][25]["args"][
            "caller_cursor"
        ] = 2

    def rejected_identity_not_fresh(candidate: dict[str, Any]) -> None:
        candidate["recursive_observation_state_machine"]["initial"][
            "next_invocation_id"
        ] = 2

    def retained_observation_history(candidate: dict[str, Any]) -> None:
        candidate["recursive_observation_state_machine"]["expected_final"][
            "retained_history_count"
        ] = 1

    mutations: list[tuple[str, Callable[[dict[str, Any]], None]]] = [
        ("format", lambda c: c.__setitem__("format", 2)),
        ("contract id", lambda c: c.__setitem__("contract_id", "drift")),
        ("task owner", lambda c: c.__setitem__("task_owner", "FUTURE-PARITY-BACKLOG.14.2")),
        ("neutral status", lambda c: c.__setitem__("status", "implemented")),
        ("coordinate policy", lambda c: c["policy"].__setitem__("coordinates", "bytes are authoritative")),
        ("source spelling", lambda c: c["policy"].__setitem__("source_spelling", "span()")),
        ("source removed", lambda c: c["sources"].pop()),
        ("source scalar length", lambda c: c["sources"][0].__setitem__("unicode_scalar_length", 8)),
        ("position removed", lambda c: c["position_conversions"].pop()),
        ("position byte coordinate", lambda c: c["position_conversions"][1].__setitem__("utf8_byte_offset", 1)),
        ("span reversed", lambda c: c["direct_spans"][1].__setitem__("start", 2)),
        ("span text", lambda c: c["direct_spans"][3].__setitem__("expected_text", "x")),
        ("derived segment order", lambda c: c["derived_text_cases"][0]["span_ids"].reverse()),
        ("derived contiguous lie", lambda c: c["derived_text_cases"][1].__setitem__("contiguous_source_interval", [0, 3])),
        ("invocation transition removed", lambda c: c["invocation_state_machine"]["transitions"].pop()),
        ("invocation operation", lambda c: c["invocation_state_machine"]["transitions"][1].__setitem__("operation", "accept")),
        ("invocation mark generation", lambda c: c["invocation_state_machine"]["transitions"][3]["args"].__setitem__("generation", 0)),
        ("transaction transition removed", lambda c: c["transaction_state_machine"]["transitions"].pop()),
        ("transaction operation", lambda c: c["transaction_state_machine"]["transitions"][4].__setitem__("operation", "rollback")),
        ("transaction offset bounds", transaction_out_of_range),
        (
            "recursive authored target",
            lambda c: c["recursive_observation_state_machine"]["authored_surface"].__setitem__(
                "target", "any expression"
            ),
        ),
        (
            "recursive carrier field removed",
            lambda c: c["recursive_observation_state_machine"]["carrier_projection"][
                "fields"
            ].pop(),
        ),
        (
            "recursive executable transition removed",
            lambda c: c["recursive_observation_state_machine"]["transitions"].pop(),
        ),
        ("recursive observation removed", lambda c: c["recursive_observations"].pop()),
        ("recursive diagnostic", lambda c: c["recursive_observations"][4].__setitem__("diagnostic", None)),
        (
            "Rust recursive observation admission omitted",
            lambda c: c["rollout"][9].__setitem__("runtimes", ["perl"]),
        ),
        (
            "Dart recursive observation admission omitted",
            lambda c: c["rollout"][9].__setitem__("runtimes", ["perl", "rust"]),
        ),
        (
            "Julia recursive observation admission omitted",
            lambda c: c["rollout"][9].__setitem__(
                "runtimes", ["perl", "rust", "dart"]
            ),
        ),
        (
            "Lua recursive observation admission omitted",
            lambda c: c["rollout"][9].__setitem__(
                "runtimes", ["perl", "rust", "dart", "julia"]
            ),
        ),
        ("structural case removed", lambda c: c["structural_authoring_cases"].pop()),
        ("structural regex count", lambda c: c["structural_authoring_cases"][2].__setitem__("regex_count", 3)),
        ("helper projection removed", lambda c: c["helper_projections"]["capture_mark"].pop()),
        ("helper projection semantic", lambda c: c["helper_projections"]["entry_match"][0].__setitem__(1, "span_text")),
        ("alias removed", lambda c: c["compatibility_aliases"].pop()),
        ("alias anonymous/named target", lambda c: c["compatibility_aliases"][0].__setitem__(1, "capture_from")),
        ("internal contract id", lambda c: c["internal_contract_ids"][0].__setitem__(1, "capture_take_len")),
        ("diagnostic removed", lambda c: c["diagnostics"].pop()),
        ("diagnostic code", lambda c: c["diagnostics"][0].__setitem__("code", "wrong")),
        ("diagnostic context", lambda c: c["diagnostics"][19]["required_context"].pop()),
        (
            "recurring source group omitted",
            lambda c: c["recurring_gate"]["consumer_sources"].pop(),
        ),
        (
            "recurring source path omitted",
            lambda c: c["recurring_gate"]["consumer_sources"][0]["paths"].pop(),
        ),
        (
            "recurring runtime route omitted",
            lambda c: c["recurring_gate"]["runtime_routes"].pop(),
        ),
        ("recurring runtime route order", swap_recurring_routes),
        (
            "recurring runtime route duplicated",
            lambda c: c["recurring_gate"]["runtime_routes"].append(
                copy.deepcopy(c["recurring_gate"]["runtime_routes"][0])
            ),
        ),
        (
            "recurring runtime command",
            lambda c: c["recurring_gate"]["runtime_routes"][1].__setitem__(
                "command", "cargo test --wrong"
            ),
        ),
        (
            "recurring runtime source binding",
            lambda c: c["recurring_gate"]["runtime_routes"][5].__setitem__(
                "source_backend", "rust"
            ),
        ),
        (
            "recurring support check omitted",
            lambda c: c["recurring_gate"]["support_checks"].pop(),
        ),
        (
            "recurring driver",
            lambda c: c["recurring_gate"].__setitem__("driver", "tools/missing.sh"),
        ),
        (
            "recurring canonical switch",
            lambda c: c["recurring_gate"]["local_ci"].__setitem__(
                "switch", "LINKEDSPEC_RUN_WRONG_MATRIX"
            ),
        ),
        (
            "combined public no-drift regressed to pending",
            lambda c: c["rollout"][13].__setitem__("status", "pending"),
        ),
        (
            "recursive-observation recurring source group omitted",
            lambda c: c["recursive_observation_recurring_gate"][
                "consumer_sources"
            ].pop(),
        ),
        (
            "recursive-observation recurring source path omitted",
            lambda c: c["recursive_observation_recurring_gate"]["consumer_sources"][
                0
            ]["paths"].pop(),
        ),
        (
            "recursive-observation recurring runtime route omitted",
            lambda c: c["recursive_observation_recurring_gate"][
                "runtime_routes"
            ].pop(),
        ),
        (
            "recursive-observation recurring runtime route order",
            swap_recursive_observation_recurring_routes,
        ),
        (
            "recursive-observation recurring runtime route duplicated",
            lambda c: c["recursive_observation_recurring_gate"][
                "runtime_routes"
            ].append(
                copy.deepcopy(
                    c["recursive_observation_recurring_gate"]["runtime_routes"][0]
                )
            ),
        ),
        (
            "recursive-observation recurring runtime command",
            lambda c: c["recursive_observation_recurring_gate"]["runtime_routes"][
                1
            ].__setitem__("command", "cargo test --wrong"),
        ),
        (
            "recursive-observation recurring runtime source binding",
            lambda c: c["recursive_observation_recurring_gate"]["runtime_routes"][
                5
            ].__setitem__("source_backend", "rust"),
        ),
        (
            "recursive-observation recurring support check omitted",
            lambda c: c["recursive_observation_recurring_gate"][
                "support_checks"
            ].pop(),
        ),
        (
            "recursive-observation recurring storage initializer",
            lambda c: c["recursive_observation_recurring_gate"]["storage"].__setitem__(
                "initializer", "/tmp/project_data_env.sh"
            ),
        ),
        (
            "recursive-observation recurring driver",
            lambda c: c["recursive_observation_recurring_gate"].__setitem__(
                "driver", "tools/missing.sh"
            ),
        ),
        (
            "recursive-observation recurring canonical switch",
            lambda c: c["recursive_observation_recurring_gate"]["local_ci"].__setitem__(
                "switch", "LINKEDSPEC_RUN_WRONG_MATRIX"
            ),
        ),
        (
            "progressive span-dispatch recurring source group omitted",
            lambda c: c["progressive_span_dispatch_recurring_gate"][
                "consumer_sources"
            ].pop(),
        ),
        (
            "progressive span-dispatch recurring source path omitted",
            lambda c: c["progressive_span_dispatch_recurring_gate"][
                "consumer_sources"
            ][0]["paths"].pop(),
        ),
        (
            "progressive span-dispatch recurring runtime route omitted",
            lambda c: c["progressive_span_dispatch_recurring_gate"][
                "runtime_routes"
            ].pop(),
        ),
        (
            "progressive span-dispatch recurring runtime route order",
            swap_progressive_span_dispatch_recurring_routes,
        ),
        (
            "progressive span-dispatch recurring runtime route duplicated",
            lambda c: c["progressive_span_dispatch_recurring_gate"][
                "runtime_routes"
            ].append(
                copy.deepcopy(
                    c["progressive_span_dispatch_recurring_gate"]["runtime_routes"][
                        0
                    ]
                )
            ),
        ),
        (
            "progressive span-dispatch recurring runtime command",
            lambda c: c["progressive_span_dispatch_recurring_gate"][
                "runtime_routes"
            ][1].__setitem__("command", "cargo test --wrong"),
        ),
        (
            "progressive span-dispatch recurring runtime source binding",
            lambda c: c["progressive_span_dispatch_recurring_gate"][
                "runtime_routes"
            ][5].__setitem__("source_backend", "rust"),
        ),
        (
            "progressive span-dispatch recurring neutral check",
            lambda c: c["progressive_span_dispatch_recurring_gate"].__setitem__(
                "neutral_check", "bash tools/run_python_project_data.sh tools/wrong.py"
            ),
        ),
        (
            "progressive span-dispatch recurring support check omitted",
            lambda c: c["progressive_span_dispatch_recurring_gate"][
                "support_checks"
            ].pop(),
        ),
        (
            "progressive span-dispatch recurring storage initializer",
            lambda c: c["progressive_span_dispatch_recurring_gate"][
                "storage"
            ].__setitem__("initializer", "/tmp/project_data_env.sh"),
        ),
        (
            "progressive span-dispatch recurring driver",
            lambda c: c["progressive_span_dispatch_recurring_gate"].__setitem__(
                "driver", "tools/missing.sh"
            ),
        ),
        (
            "progressive span-dispatch recurring canonical switch",
            lambda c: c["progressive_span_dispatch_recurring_gate"][
                "local_ci"
            ].__setitem__("switch", "LINKEDSPEC_RUN_WRONG_MATRIX"),
        ),
        (
            "staged-AST enrichment recurring source group omitted",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "consumer_sources"
            ].pop(),
        ),
        (
            "staged-AST enrichment recurring source path omitted",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "consumer_sources"
            ][0]["paths"].pop(),
        ),
        (
            "staged-AST enrichment recurring runtime route omitted",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "runtime_routes"
            ].pop(),
        ),
        (
            "staged-AST enrichment recurring runtime route order",
            swap_staged_ast_enrichment_recurring_routes,
        ),
        (
            "staged-AST enrichment recurring runtime route duplicated",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "runtime_routes"
            ].append(
                copy.deepcopy(
                    c["staged_ast_enrichment_recurring_gate"]["runtime_routes"][0]
                )
            ),
        ),
        (
            "staged-AST enrichment recurring runtime command",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "runtime_routes"
            ][1].__setitem__("command", "cargo test --wrong"),
        ),
        (
            "staged-AST enrichment recurring runtime source binding",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "runtime_routes"
            ][5].__setitem__("source_backend", "rust"),
        ),
        (
            "staged-AST enrichment recurring neutral check",
            lambda c: c["staged_ast_enrichment_recurring_gate"].__setitem__(
                "neutral_check", "bash tools/run_python_project_data.sh tools/wrong.py"
            ),
        ),
        (
            "staged-AST enrichment recurring support check omitted",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "support_checks"
            ].pop(),
        ),
        (
            "staged-AST enrichment recurring storage initializer",
            lambda c: c["staged_ast_enrichment_recurring_gate"]["storage"].__setitem__(
                "initializer", "/tmp/project_data_env.sh"
            ),
        ),
        (
            "staged-AST enrichment recurring storage entrypoint",
            lambda c: c["staged_ast_enrichment_recurring_gate"]["storage"].__setitem__(
                "managed_entrypoint", "tools/wrong.sh"
            ),
        ),
        (
            "staged-AST enrichment recurring driver",
            lambda c: c["staged_ast_enrichment_recurring_gate"].__setitem__(
                "driver", "tools/missing.sh"
            ),
        ),
        (
            "staged-AST enrichment recurring canonical switch",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "local_ci"
            ].__setitem__("switch", "LINKEDSPEC_RUN_WRONG_MATRIX"),
        ),
        (
            "staged-AST enrichment recurring rollout assertion",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "rollout_assertions"
            ]["staged_span_dispatch"].__setitem__("status", "pending"),
        ),
        (
            "staged-AST enrichment recurring capability id",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "capability_projection"
            ].__setitem__("capability_id", "language.wrong"),
        ),
        (
            "staged-AST enrichment recurring capability status",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "capability_projection"
            ].__setitem__("backend_status", "partial"),
        ),
        (
            "staged-AST enrichment public-authoring contract",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "capability_projection"
            ].__setitem__("public_authoring_contract", "capability_conformance/wrong.json"),
        ),
        (
            "staged-AST enrichment public-authoring status",
            lambda c: c["staged_ast_enrichment_recurring_gate"][
                "capability_projection"
            ].__setitem__("public_authoring_status", "pending"),
        ),
        (
            "staged span-dispatch rollout regressed",
            lambda c: c["rollout"][12].update({"status": "pending", "runtimes": []}),
        ),
        (
            "program-wide public owner",
            lambda c: c["program_wide_public_no_drift"].__setitem__(
                "owner", "FUTURE-PARITY-BACKLOG.14.7"
            ),
        ),
        (
            "program-wide public status",
            lambda c: c["program_wide_public_no_drift"].__setitem__(
                "status", "pending"
            ),
        ),
        (
            "program-wide public policy",
            lambda c: c["program_wide_public_no_drift"].__setitem__(
                "policy", "replacement behavior oracle"
            ),
        ),
        (
            "program-wide recurring driver",
            lambda c: c["program_wide_public_no_drift"][
                "recurring_composition"
            ].__setitem__("driver", "tools/wrong.sh"),
        ),
        (
            "program-wide recurring driver omitted",
            lambda c: c["program_wide_public_no_drift"]["recurring_composition"][
                "ordered_drivers"
            ].pop(),
        ),
        (
            "program-wide recurring driver order",
            lambda c: c["program_wide_public_no_drift"]["recurring_composition"][
                "ordered_drivers"
            ].reverse(),
        ),
        (
            "program-wide storage initializer",
            lambda c: c["program_wide_public_no_drift"]["recurring_composition"][
                "storage"
            ].__setitem__("initializer", "/tmp/project_data_env.sh"),
        ),
        (
            "program-wide canonical switch",
            lambda c: c["program_wide_public_no_drift"]["recurring_composition"][
                "local_ci"
            ].__setitem__("switch", "LINKEDSPEC_RUN_WRONG_MATRIX"),
        ),
        (
            "program-wide rollout count",
            lambda c: c["program_wide_public_no_drift"]["rollout_assertions"].__setitem__(
                "complete", 13
            ),
        ),
        (
            "program-wide final rollout assertion",
            lambda c: c["program_wide_public_no_drift"]["rollout_assertions"][
                "recurring_public_no_drift"
            ].__setitem__("status", "pending"),
        ),
        (
            "program-wide public document omitted",
            lambda c: c["program_wide_public_no_drift"]["documents"].pop(),
        ),
        (
            "program-wide public forbidden claim omitted",
            lambda c: c["program_wide_public_no_drift"]["forbidden_claims"].pop(),
        ),
        (
            "program-wide authoring-safety claim omitted",
            lambda c: c["program_wide_public_no_drift"]["authoring_safety"][
                "forbidden_claims"
            ].pop(),
        ),
        (
            "program-wide public surface path omitted",
            lambda c: c["program_wide_public_no_drift"]["surface_guard"][
                "paths"
            ].pop(),
        ),
        (
            "program-wide public surface token omitted",
            lambda c: c["program_wide_public_no_drift"]["surface_guard"][
                "forbidden_tokens"
            ].pop(),
        ),
        (
            "program-wide recurring execution policy",
            lambda c: c["program_wide_public_no_drift"]["recurring_composition"].__setitem__(
                "execution_policy", "replace all six authorities"
            ),
        ),
        (
            "recursive-observation public owner",
            lambda c: c["recursive_observation_public_no_drift"].__setitem__(
                "owner", "FUTURE-PARITY-BACKLOG.14.8"
            ),
        ),
        (
            "recursive-observation public status",
            lambda c: c["recursive_observation_public_no_drift"].__setitem__(
                "status", "pending"
            ),
        ),
        (
            "recursive-observation public policy",
            lambda c: c["recursive_observation_public_no_drift"].__setitem__(
                "policy", "public API admitted"
            ),
        ),
        (
            "recursive-observation public document omitted",
            lambda c: c["recursive_observation_public_no_drift"]["documents"].pop(),
        ),
        (
            "recursive-observation public marker omitted",
            lambda c: c["recursive_observation_public_no_drift"]["documents"][0][
                "required_markers"
            ].pop(),
        ),
        (
            "recursive-observation public forbidden claim omitted",
            lambda c: c["recursive_observation_public_no_drift"][
                "forbidden_claims"
            ].pop(),
        ),
        (
            "recursive-observation public surface path omitted",
            lambda c: c["recursive_observation_public_no_drift"]["surface_guard"][
                "paths"
            ].pop(),
        ),
        (
            "recursive-observation public surface token omitted",
            lambda c: c["recursive_observation_public_no_drift"]["surface_guard"][
                "forbidden_tokens"
            ].pop(),
        ),
        (
            "recursive-observation public combined row regressed",
            lambda c: c["recursive_observation_public_no_drift"][
                "rollout_assertions"
            ]["recurring_public_no_drift"].__setitem__("status", "pending"),
        ),
        (
            "transaction-safety composition owner",
            lambda c: c["transaction_safety_composition"].__setitem__(
                "owner", "FUTURE-PARITY-BACKLOG.14.6"
            ),
        ),
        (
            "transaction-safety composition status",
            lambda c: c["transaction_safety_composition"].__setitem__(
                "status", "pending"
            ),
        ),
        (
            "transaction-safety upstream contract identity",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ].__setitem__("contract_id", "wrong"),
        ),
        (
            "transaction-safety upstream contract path",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ].__setitem__("contract_path", "capability_conformance/wrong.json"),
        ),
        (
            "transaction-safety upstream checker path",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ].__setitem__("checker_path", "tools/wrong.py"),
        ),
        (
            "transaction-safety upstream driver path",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ].__setitem__("driver_path", "tools/wrong.sh"),
        ),
        (
            "transaction-safety upstream status",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ].__setitem__("status", "pending"),
        ),
        (
            "transaction-safety upstream mutation count",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ]["rollout"].__setitem__("semantic_mutations", 57),
        ),
        (
            "transaction-safety upstream allowed-effect count",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ]["effects"].__setitem__("allowed", 8),
        ),
        (
            "transaction-safety upstream rejected-effect count",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ]["effects"].__setitem__("rejected", 10),
        ),
        (
            "transaction-safety upstream progress count",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ]["progress"].__setitem__("cases", 7),
        ),
        (
            "transaction-safety upstream public count",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ]["public_no_drift"].__setitem__("documents", 2),
        ),
        (
            "transaction-safety upstream guide count",
            lambda c: c["transaction_safety_composition"][
                "upstream_recognition_authority"
            ]["capability_guide_no_drift"].__setitem__("forbidden_claims", 13),
        ),
        (
            "transaction-safety typed representation",
            lambda c: c["transaction_safety_composition"][
                "typed_projection"
            ].__setitem__("representation", "cursor only"),
        ),
        (
            "transaction-safety progressive row regressed",
            lambda c: c["transaction_safety_composition"][
                "rollout_assertions"
            ]["progressive_span_dispatch"].__setitem__("status", "pending"),
        ),
        (
            "lossless-gap composition owner",
            lambda c: c["lossless_gap_composition"].__setitem__(
                "owner", "FUTURE-PARITY-BACKLOG.14.8"
            ),
        ),
        (
            "lossless-gap upstream contract path",
            lambda c: c["lossless_gap_composition"][
                "upstream_gap_authority"
            ].__setitem__("contract_path", "capability_conformance/wrong.json"),
        ),
        (
            "lossless-gap upstream checker path",
            lambda c: c["lossless_gap_composition"][
                "upstream_gap_authority"
            ].__setitem__("checker_path", "tools/wrong.py"),
        ),
        (
            "lossless-gap upstream driver path",
            lambda c: c["lossless_gap_composition"][
                "upstream_gap_authority"
            ].__setitem__("driver_path", "tools/wrong.sh"),
        ),
        (
            "lossless-gap upstream rollout mutations",
            lambda c: c["lossless_gap_composition"]["upstream_gap_authority"][
                "rollout"
            ].__setitem__("semantic_mutations", 62),
        ),
        (
            "lossless-gap upstream public mutations",
            lambda c: c["lossless_gap_composition"]["upstream_gap_authority"][
                "public"
            ].__setitem__("mutations", 28),
        ),
        (
            "lossless-gap typed representation",
            lambda c: c["lossless_gap_composition"]["typed_projection"].__setitem__(
                "representation", "copied text"
            ),
        ),
        (
            "lossless-gap recurring check omitted",
            lambda c: c["lossless_gap_composition"]["recurring_gate"][
                "ordered_checks"
            ].pop(),
        ),
        (
            "lossless-gap storage initializer",
            lambda c: c["lossless_gap_composition"]["recurring_gate"][
                "storage"
            ].__setitem__("initializer", "/tmp/project_data_env.sh"),
        ),
        (
            "lossless-gap managed entrypoint",
            lambda c: c["lossless_gap_composition"]["recurring_gate"][
                "storage"
            ].__setitem__("managed_entrypoint", "tools/wrong.sh"),
        ),
        (
            "lossless-gap canonical switch",
            lambda c: c["lossless_gap_composition"]["recurring_gate"][
                "local_ci"
            ].__setitem__("switch", "LINKEDSPEC_RUN_WRONG_MATRIX"),
        ),
        (
            "lossless-gap composition regressed to pending",
            lambda c: c["rollout"][10].__setitem__("status", "pending"),
        ),
        (
            "recursive observation Perl admission omitted",
            lambda c: c["rollout"][9]["runtimes"].pop(),
        ),
        ("rollout removed", lambda c: c["rollout"].pop()),
        ("canonical checker", lambda c: c["canonical_execution"].__setitem__("checker_path", "tools/wrong.py")),
        ("mutation count", lambda c: c["expected_counts"].__setitem__("mutations", 56)),
    ]
    recursive_lineage_regressions = [
        (
            "recursive self-parent",
            recursive_self_parent,
            "recursive observation cannot self-parent",
        ),
        (
            "recursive invocation identity reused",
            recursive_reused_identity,
            "recursive invocation identity was reused",
        ),
        (
            "recursive parent order",
            recursive_parent_order,
            "recursive parent invocation must precede child",
        ),
        (
            "recursive lineage cycle",
            recursive_cycle,
            "recursive invocation lineage is cyclic",
        ),
    ]
    recursive_state_regressions = [
        (
            "direct call invented entry match",
            direct_entry_match,
            "direct recursive call invented an entry match",
        ),
        (
            "action edge dropped carried match",
            action_entry_match_missing,
            "action-edge recursive entry did not carry the parent selected match",
        ),
        (
            "parent overrode child entry cursor",
            child_entry_cursor_override,
            "recursive child entry did not use the caller cursor",
        ),
        (
            "parent overrode child family policy",
            child_family_policy_override,
            "recursive observation child-family cursor policy drifted",
        ),
        (
            "terminal selected match was not replaced",
            terminal_match_not_replaced,
            "recursive observation state machine emitted the wrong terminal record",
        ),
        (
            "accepted exit preceded selected match",
            accepted_exit_before_match,
            "accepted recursive exit precedes terminal selected match",
        ),
        (
            "failed outcome gained accepted exit",
            failed_outcome_gains_exit,
            "recursive observation state machine emitted the wrong terminal record",
        ),
        (
            "rejected child changed caller cursor",
            rejected_child_cursor_override,
            "recursive rejected child did not use the caller cursor",
        ),
        (
            "rejected child identity was not fresh",
            rejected_identity_not_fresh,
            "recursive observation initial state drifted",
        ),
        (
            "detached observation history retained",
            retained_observation_history,
            "recursive observation final state or retention boundary drifted",
        ),
    ]
    rollout_regressions = [
        (
            "public structure regressed to pending",
            lambda c: c["rollout"][1].__setitem__("status", "pending"),
        ),
        (
            "neutral public recomposition regressed to pending",
            lambda c: c["rollout"][2].__setitem__("status", "pending"),
        ),
        (
            "Perl runtime admission regressed to pending",
            lambda c: c["rollout"][3].__setitem__("status", "pending"),
        ),
        (
            "Rust runtime admission regressed to pending",
            lambda c: c["rollout"][4].__setitem__("status", "pending"),
        ),
        (
            "Dart runtime admission regressed to pending",
            lambda c: c["rollout"][5].__setitem__("status", "pending"),
        ),
        (
            "Julia runtime admission regressed to pending",
            lambda c: c["rollout"][6].__setitem__("status", "pending"),
        ),
        (
            "Lua dual-ABI runtime admission regressed to pending",
            lambda c: c["rollout"][7].__setitem__("status", "pending"),
        ),
        (
            "transaction-safety composition regressed to pending",
            lambda c: c["rollout"][8].__setitem__("status", "pending"),
        ),
        (
            "recursive-observation recurrence regressed to pending",
            lambda c: c["rollout"][9].__setitem__("status", "pending"),
        ),
        (
            "progressive span-dispatch recurrence regressed to pending",
            lambda c: c["rollout"][11].__setitem__("status", "pending"),
        ),
    ]
    if (
        len(mutations)
        + len(recursive_lineage_regressions)
        + len(recursive_state_regressions)
        + len(rollout_regressions)
        != EXPECTED_COUNTS["mutations"]
        - RECURSIVE_OBSERVATION_PUBLIC_MUTATION_COUNT
        - TRANSACTION_SAFETY_COMPOSITION_PUBLIC_MUTATION_COUNT
        - PROGRAM_WIDE_PUBLIC_MUTATION_COUNT
    ):
        fail("checker mutation inventory count drifted")
    for name, mutate in mutations:
        expect_mutation_failure(contract, name, mutate)
    for name, mutate, expected_error in recursive_lineage_regressions:
        candidate = copy.deepcopy(contract)
        mutate(candidate)
        try:
            validate_contract(candidate, check_registration=False)
        except ContractError as error:
            if expected_error not in str(error):
                fail(f"mutation {name!r} failed for the wrong reason: {error}")
        else:
            fail(f"mutation {name!r} was not rejected")
    for name, mutate, expected_error in recursive_state_regressions:
        candidate = copy.deepcopy(contract)
        mutate(candidate)
        try:
            validate_contract(candidate, check_registration=False)
        except ContractError as error:
            if expected_error not in str(error):
                fail(f"mutation {name!r} failed for the wrong reason: {error}")
        else:
            fail(f"mutation {name!r} was not rejected")
    for name, mutate in rollout_regressions:
        candidate = copy.deepcopy(contract)
        mutate(candidate)
        try:
            validate_contract(candidate, check_registration=False)
        except ContractError as error:
            if "rollout membership, order, status, owner, or runtime coverage drifted" not in str(error):
                fail(f"mutation {name!r} failed for the wrong reason: {error}")
        else:
            fail(f"mutation {name!r} was not rejected")
    return (
        len(mutations)
        + len(recursive_lineage_regressions)
        + len(recursive_state_regressions)
        + len(rollout_regressions)
    )


def recursive_observation_public_mutation_checks(contract: dict[str, Any]) -> int:
    public_contract = contract["recursive_observation_public_no_drift"]
    document_texts, surface_texts = recursive_observation_public_texts(public_contract)
    first_document = public_contract["documents"][0]
    first_path = first_document["path"]
    first_marker = first_document["required_markers"][0]
    mutations: list[tuple[str, str, str, str]] = [
        ("required marker deleted", "replace", first_path, first_marker),
        ("required marker duplicated", "append_document", first_path, first_marker),
    ]
    mutations.extend(
        (f"stale claim {index}", "append_document", row["path"], row["text"])
        for index, row in enumerate(public_contract["forbidden_claims"], 1)
    )
    guard_token = public_contract["surface_guard"]["forbidden_tokens"][0]
    mutations.extend(
        (f"surface widening {index}", "append_surface", path, guard_token)
        for index, path in enumerate(public_contract["surface_guard"]["paths"], 1)
    )
    if len(mutations) != RECURSIVE_OBSERVATION_PUBLIC_MUTATION_COUNT:
        fail("recursive-observation public mutation inventory count drifted")

    for name, operation, path, value in mutations:
        candidate_documents = dict(document_texts)
        candidate_surfaces = dict(surface_texts)
        if operation == "replace":
            candidate_documents[path] = candidate_documents[path].replace(value, "", 1)
        elif operation == "append_document":
            candidate_documents[path] += "\n" + value
        elif operation == "append_surface":
            candidate_surfaces[path] += "\n" + value
        else:
            fail(f"unknown recursive-observation public mutation operation: {operation}")
        try:
            validate_recursive_observation_public_no_drift(
                public_contract,
                contract["rollout"],
                candidate_documents,
                candidate_surfaces,
            )
        except ContractError:
            continue
        fail(f"recursive-observation public mutation {name!r} was not rejected")
    return len(mutations)


def transaction_safety_composition_public_mutation_checks(
    contract: dict[str, Any],
) -> int:
    composition = contract["transaction_safety_composition"]
    projection = composition["current_projection_no_drift"]
    document_texts = transaction_safety_composition_texts(composition)
    first_document = projection["documents"][0]
    first_path = first_document["path"]
    first_marker = first_document["required_markers"][0]
    mutations: list[tuple[str, str, str, str]] = [
        ("required marker deleted", "replace", first_path, first_marker),
        ("required marker duplicated", "append", first_path, first_marker),
    ]
    mutations.extend(
        (f"stale claim {index}", "append", row["path"], row["text"])
        for index, row in enumerate(projection["forbidden_claims"], 1)
    )
    if len(mutations) != TRANSACTION_SAFETY_COMPOSITION_PUBLIC_MUTATION_COUNT:
        fail("transaction-safety composition public mutation inventory count drifted")

    for name, operation, path, value in mutations:
        candidate_texts = dict(document_texts)
        if operation == "replace":
            candidate_texts[path] = candidate_texts[path].replace(value, "", 1)
        elif operation == "append":
            candidate_texts[path] += "\n" + value
        else:
            fail(f"unknown transaction-safety composition mutation operation: {operation}")
        try:
            validate_transaction_safety_composition(
                composition,
                contract["rollout"],
                candidate_texts,
            )
        except ContractError:
            continue
        fail(f"transaction-safety composition public mutation {name!r} was not rejected")
    return len(mutations)


def program_wide_public_mutation_checks(contract: dict[str, Any]) -> int:
    public_contract = contract["program_wide_public_no_drift"]
    document_texts, safety_texts, surface_texts = program_wide_public_texts(
        public_contract
    )
    first_document = public_contract["documents"][0]
    first_path = first_document["path"]
    first_marker = first_document["required_markers"][0]
    mutations: list[tuple[str, str, str, str, str]] = [
        (
            "required marker deleted",
            "replace_document",
            first_path,
            first_marker,
            "program-wide public marker",
        ),
        (
            "required marker duplicated",
            "append_document",
            first_path,
            first_marker,
            "program-wide public marker",
        ),
    ]
    mutations.extend(
        (
            f"stale claim {index}",
            "append_document",
            row["path"],
            row["text"],
            "stale program-wide public claim",
        )
        for index, row in enumerate(public_contract["forbidden_claims"], 1)
    )
    mutations.extend(
        (
            f"unsafe authoring claim {index}",
            "append_safety",
            row["path"],
            row["text"],
            "unsafe public authoring claim",
        )
        for index, row in enumerate(
            public_contract["authoring_safety"]["forbidden_claims"], 1
        )
    )
    guard_token = public_contract["surface_guard"]["forbidden_tokens"][0]
    mutations.extend(
        (
            f"surface widening {index}",
            "append_surface",
            path,
            guard_token,
            "program-wide public surface widened",
        )
        for index, path in enumerate(public_contract["surface_guard"]["paths"], 1)
    )
    if len(mutations) != PROGRAM_WIDE_PUBLIC_MUTATION_COUNT:
        fail("program-wide public mutation inventory count drifted")

    for name, operation, path, value, expected_error in mutations:
        candidate_documents = dict(document_texts)
        candidate_safety = dict(safety_texts)
        candidate_surfaces = dict(surface_texts)
        if operation == "replace_document":
            candidate_documents[path] = candidate_documents[path].replace(
                value, "", 1
            )
        elif operation == "append_document":
            candidate_documents[path] += "\n" + value
        elif operation == "append_safety":
            candidate_safety[path] += "\n" + value
        elif operation == "append_surface":
            candidate_surfaces[path] += "\n" + value
        else:
            fail(f"unknown program-wide public mutation operation: {operation}")
        try:
            validate_program_wide_public_no_drift(
                public_contract,
                contract["rollout"],
                candidate_documents,
                candidate_safety,
                candidate_surfaces,
            )
        except ContractError as error:
            if expected_error not in str(error):
                fail(f"program-wide public mutation {name!r} failed for the wrong reason: {error}")
        else:
            fail(f"program-wide public mutation {name!r} was not rejected")
    return len(mutations)


def main() -> int:
    contract = json.loads(CONTRACT_PATH.read_text(encoding="utf-8"))
    validate_contract(contract)
    mutation_count = mutation_checks(contract)
    mutation_count += recursive_observation_public_mutation_checks(contract)
    mutation_count += transaction_safety_composition_public_mutation_checks(contract)
    mutation_count += program_wide_public_mutation_checks(contract)
    complete = sum(leg["status"] == "complete" for leg in contract["rollout"])
    pending = len(contract["rollout"]) - complete
    print(
        "typed-source-location-contract: OK "
        f"({len(contract['sources'])} sources; {len(contract['position_conversions'])} positions; "
        f"{len(contract['direct_spans'])} direct spans; {len(contract['derived_text_cases'])} derived texts; "
        f"{len(contract['invocation_state_machine']['transitions'])}+"
        f"{len(contract['transaction_state_machine']['transitions'])}+"
        f"{len(contract['recursive_observation_state_machine']['transitions'])} state transitions; "
        f"{len(contract['recursive_observations'])} recursive observations; "
        f"{len(contract['structural_authoring_cases'])} structural cases; "
        f"{EXPECTED_COUNTS['helper_projections']} helper projections + "
        f"{len(contract['compatibility_aliases'])} aliases + "
        f"{len(contract['internal_contract_ids'])} internal ids; "
        f"{len(contract['diagnostics'])} diagnostics; "
        f"recursive-observation public "
        f"{EXPECTED_COUNTS['recursive_observation_public_documents']} documents/"
        f"{EXPECTED_COUNTS['recursive_observation_public_forbidden_claims']} forbidden/"
        f"{EXPECTED_COUNTS['recursive_observation_public_surface_guard_paths']} surface guards; "
        f"program-wide public {EXPECTED_COUNTS['program_wide_public_documents']} documents/"
        f"{EXPECTED_COUNTS['program_wide_public_forbidden_claims']} forbidden/"
        f"{EXPECTED_COUNTS['program_wide_authoring_safety_claims']} safety/"
        f"{EXPECTED_COUNTS['program_wide_public_surface_guard_paths']} surface guards; "
        f"{complete} complete / {pending} pending rollout; {mutation_count} drift mutations)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
