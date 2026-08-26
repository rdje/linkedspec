//! LinkedSpec runtime — handler execution engine, helpers, and lifecycle interpreter.
//!
//! This crate provides:
//! - An interpreted runtime engine that executes compiled rule specifications
//! - A regex dispatch engine with seek/consume modes
//! - Helper function dispatch for lifecycle code execution
//! - Variable store (working variables and assignment with scoping)
//!
//! The Perl reference implementation lives at `perl/LinkedSpec.pm`.
//! The Rust implementation is idiomatic Rust — no code generation, no eval.

#[doc(hidden)]
pub mod bounded_child_parse_authority;
pub mod diagnostic;
pub mod diagnostic_output;
pub mod engine;
pub mod helpers;
mod mcp_contract;
mod mcp_contract_runtime;
pub mod mcp_server;
mod mcp_wire;
pub mod primary_cli;
#[doc(hidden)]
pub mod recognition_transaction;
pub mod runtime;
pub mod semantic_index;
pub mod semantic_observation;
pub mod source_emitter;
pub mod source_location;
pub mod spec_loader;
pub mod spec_parser;
// FUTURE-PARITY-BACKLOG.14.7.4.4 removes this ordinary-build allowance when it
// attaches the first production carrier; the cfg-enabled dormant consumer uses
// every exported test seam in the meantime.
#[cfg_attr(not(linkedspec_staged_ast_enrichment_red), allow(dead_code))]
mod staged_ast_enrichment;
mod staged_parse_job;
pub mod staged_parser_registry;
pub mod unicode_case_mapping;

#[allow(unexpected_cfgs)]
mod staged_parse_job_test_exports {
    #[cfg(linkedspec_staged_ast_enrichment_red)]
    pub use crate::staged_ast_enrichment::{
        CompiledStagedAuthority, FrozenStagedRegistry, StagedAstEnrichmentError, StagedCacheStats,
        StagedEnrichmentOutcome, StagedRecursiveAuthority, StagedRecursiveOutcome,
        StagedRecursiveResources, StagedRuntimeContext, enrich_current_depth, enrich_recursively,
        evaluate_staged_chain_case, staged_cache_identity, staged_current_depth_order,
        staged_job_identity,
    };
    #[cfg(linkedspec_staged_ast_enrichment_red)]
    pub use crate::staged_parse_job::validate_and_materialize_provenance;
}

#[doc(hidden)]
#[allow(unused_imports)]
pub use staged_parse_job_test_exports::*;

pub use diagnostic::{RuntimeDiagnostic, RuntimeExecutionError};
pub use diagnostic_output::{
    RuntimeDiagnosticOutputEvent, RuntimeDiagnosticOutputExecutionError,
    RuntimeDiagnosticOutputSink, RuntimeDiagnosticOutputSinkFailure, RuntimeExitNow,
};
pub use linkedspec_core::trace;
pub use mcp_server::{
    McpBudgetLimits, McpDeploymentPolicy, McpRegistrationOptions, McpServer, McpServerError,
};
pub use semantic_observation::{
    RUNTIME_SEMANTIC_OBSERVATION_CONTRACT, RuntimeSemanticObservationEvent,
    RuntimeSemanticObservationEventKind, RuntimeSemanticObservationSink,
};

/// Crate version, matching the workspace version.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
