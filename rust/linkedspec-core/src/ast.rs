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
pub struct BodyElement {
    /// Classification of this element.
    pub kind: BodyElementKind,
    /// The original line text (used for validation, brace counting).
    pub line: String,
}

/// The type of a body element.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum BodyElementKind {
    /// A regex literal: /pattern/
    Regex,
    /// An action edge: -> Target or -> Target[N]
    ActionEdge { target: String, index: usize },
    /// A blind-call edge: => Target
    BlindEdge { target: String },
    /// A code block.
    CodeBlock { lifecycle: Option<String>, code: String },
    /// A split marker: @capture_slice, @mark(name)
    SplitMarker,
    /// A lifecycle marker: I, LS, LE, E, EX, IT, LX
    LifecycleMarker { marker: String },
    /// A fluent chain: .method(args)
    FluentChain,
    /// A conditional marker: -? word
    Conditional,
    /// Raw body line (fallback for unrecognized content).
    Raw,
}

impl BodyElement {
    /// Create a new body element with the given kind and original line text.
    pub fn new(kind: BodyElementKind, line: &str) -> Self {
        Self { kind, line: line.to_string() }
    }
}
