//! AST types for parsed .spec files.
//! Placeholder — will be populated in .2 (parser implementation).

use serde::{Deserialize, Serialize};

/// A complete .spec file AST.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpecFile {
    pub rules: Vec<Rule>,
}

/// A single rule paragraph.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Rule {
    pub header: RuleHeader,
    pub body: Vec<BodyElement>,
}

/// Rule header: label, colon type, mode, and rest-of-line.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RuleHeader {
    pub label: String,
    pub is_top: bool,
    pub mode: RuleMode,
    pub rest: String,
}

/// Rule mode suffix.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum RuleMode {
    /// No mode suffix — repeated choice (equivalent to OR+).
    Default,
    /// AND ordered sequence.
    And,
    /// AND+ unbounded repetition.
    AndPlus,
    /// AND{N}, AND{N,M}, AND{N,}, AND{,M}
    AndBounded { min: usize, max: Option<usize> },
    /// OR repeated choice.
    Or,
    /// OR+ unbounded.
    OrPlus,
    /// OR{N}, OR{N,M}, OR{N,}, OR{,M}
    OrBounded { min: usize, max: Option<usize> },
    /// :& single-match choice.
    Single,
    /// :| pipe (equivalent to AND).
    Pipe,
    /// :+ one-or-more.
    Plus,
    /// :* zero-or-more.
    Star,
    /// :? zero-or-one.
    Optional,
}

/// A body element within a rule paragraph.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum BodyElement {
    /// A regex literal: /pattern/
    Regex { value: String },
    /// An action edge: -> Target or -> Target[N]
    ActionEdge {
        target: String,
        index: usize,
    },
    /// A blind-call edge: => Target
    BlindEdge { target: String },
    /// A code block with optional lifecycle marker prefix.
    CodeBlock {
        lifecycle: Option<String>,
        code: String,
    },
    /// A split marker: @capture_slice, @mark(name)
    SplitMarker { marker: String },
    /// A lifecycle marker: I, LS, LE, E, EX, IT, LX
    LifecycleMarker { marker: String },
    /// A fluent chain: .method(args)
    FluentChain { code: String },
    /// A conditional marker: -? word
    Conditional { text: String },
    /// Raw body line (fallback for unrecognized content).
    Raw(String),
}
