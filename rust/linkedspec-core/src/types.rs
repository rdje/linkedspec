//! Core types for LinkedSpec — HandlerIR node definitions and associated enums.
//!
//! These types are the stable contract between the compiler and the runtime.
//! They are defined here (in linkedspec-core) and consumed by linkedspec-runtime.
//!
//! Reference: `docs/knowledge/handler-ir-design.md`

use serde::{Deserialize, Serialize};

/// Parse mode for a rule handler.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ParseMode {
    /// Ungrounded matching — match anywhere from current position.
    Seek,
    /// \G-anchored matching — must match contiguously.
    Consume,
}

impl ParseMode {
    /// Returns true if this is consume mode.
    pub fn is_consume(self) -> bool {
        matches!(self, Self::Consume)
    }

    /// Returns true if this is seek mode.
    pub fn is_seek(self) -> bool {
        matches!(self, Self::Seek)
    }
}

/// Handler variant kind — determines loop structure and dispatch strategy.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum HandlerKind {
    /// while(1) loop, LinkedRE::or match, acode dispatch.
    Default,
    /// foreach call loop, bcode dispatch.
    AndBcode,
    /// Single match, index==0 check, single acode.
    AndSingleAcode,
    /// while(idx < N) loop, index-checked acode dispatch.
    AndAcodeSeq,
    /// foreach call loop, first-match-wins bcode dispatch.
    OrBcode,
    /// Single match, no index check, single acode.
    OrAcode,
    /// REP wrapper with inner OR_BCODE.
    RepBcode,
    /// REP wrapper with inner AND_BCODE.
    RepAndBcode,
    /// REP wrapper with inner AND_ACODE.
    RepAndAcode,
    /// REP wrapper with LinkedRE::or + acode dispatch.
    RepAcode,
}

/// A complete HandlerIR node — the structured representation of a compiled rule handler.
///
/// This is the decoupling seam between compiler and backend emitter.
/// All 10 variant kinds use this same struct; the `kind` field distinguishes them.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HandlerIR {
    /// Variant kind.
    pub kind: HandlerKind,

    /// Rule label this handler is for.
    pub label: String,

    /// Parse mode (seek or consume).
    pub parse_mode: ParseMode,

    /// I-block code (initialization).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub preamble: Option<String>,

    /// Loop-exit code (no-match / failure path).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub lxcode: Option<String>,

    /// Loop-start code (after successful match).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub lscode: Option<String>,

    /// Loop-end code (before collection/return).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub lecode: Option<String>,

    /// End code (exhaustion / final return).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub ecode: Option<String>,

    /// Extended-exit code (REP loop exhaustion fallback).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub excode: Option<String>,

    /// Iteration code (REP per-iteration collection).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub itcode: Option<String>,

    /// Per-child action code strings (for acode variants).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub acodes_ref: Option<Vec<String>>,

    /// Per-child blind-call code strings, keyed by child label.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bcodes_ref: Option<Vec<(String, String)>>,

    /// Ordered list of child labels for blind-call dispatch.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bcalls_ref: Option<Vec<String>>,

    /// AND I-block code.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub and_icode: Option<String>,

    /// Minimum repetitions (REP variants only).
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rep_min: Option<usize>,

    /// Maximum repetitions (REP variants only). None or large value means unbounded.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub rep_max: Option<usize>,
}

impl HandlerIR {
    /// Returns true if this handler uses repetition.
    pub fn is_rep_variant(&self) -> bool {
        use HandlerKind::*;
        matches!(self.kind, RepBcode | RepAndBcode | RepAndAcode | RepAcode)
    }

    /// Returns true if this handler uses acode (action) dispatch.
    pub fn uses_acode(&self) -> bool {
        self.acodes_ref.as_ref().is_some_and(|a| !a.is_empty())
    }

    /// Returns true if this handler uses bcode (blind-call) dispatch.
    pub fn uses_bcode(&self) -> bool {
        self.bcodes_ref.as_ref().is_some_and(|b| !b.is_empty())
    }
}
