//! AST types for parsed `.spec` files.
//!
//! These represent the structure of a LinkedSpec grammar file:
//! a sequence of rule paragraphs, each with a header and body elements.

use serde::{Deserialize, Serialize};

/// A complete `.spec` file AST.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpecFile {
    #[serde(default)]
    pub functions: Vec<FunctionDefinition>,
    pub rules: Vec<Rule>,
}

/// A top-level user-defined function definition.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FunctionDefinition {
    pub name: String,
    pub params: Vec<String>,
    pub arity: usize,
    pub body_source: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub body_payload: Option<serde_json::Value>,
    pub source: String,
    pub source_span: SourceSpan,
    pub body_span: SourceSpan,
}

/// 1-based source line span metadata.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct SourceSpan {
    pub line_start: usize,
    pub line_end: usize,
}

/// A single rule paragraph — one `RuleName:: /regex/ ...` block.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Rule {
    pub header: RuleHeader,
    pub body: Vec<BodyElement>,
}

/// Rule header: label, colon type, mode, and rest-of-line after the mode.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RuleHeader {
    /// The rule's name (e.g. "Top", "Child").
    pub label: String,
    /// True if this is a top-level rule (`::`), false for body rules (`:`).
    pub is_top: bool,
    /// The rule's mode suffix (AND, OR, *, +, ?, etc.).
    pub mode: RuleMode,
    /// Everything after the mode suffix on the header line.
    pub rest: String,
    /// The 1-based line number where this rule header appears.
    pub line: usize,
}

/// Rule mode suffix — determines repetition, ordering, and matching behavior.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum RuleMode {
    /// No mode suffix — repeated choice (equivalent to `OR+`).
    Default,
    /// `:AND` — ordered sequence.
    And,
    /// `:AND+` — unbounded ordered repetition.
    AndPlus,
    /// `:AND{N}`, `:AND{N,M}`, `:AND{N,}`, `:AND{,M}` — bounded ordered repetition.
    AndBounded { min: usize, max: Option<usize> },
    /// `:OR` — repeated choice.
    Or,
    /// `:OR+` — unbounded repeated choice.
    OrPlus,
    /// `:OR{N}`, `:OR{N,M}`, `:OR{N,}`, `:OR{,M}` — bounded repetition.
    OrBounded { min: usize, max: Option<usize> },
    /// `:&` — single-match choice.
    Single,
    /// `:|` — pipe (equivalent to `AND`).
    Pipe,
    /// `:+` — one-or-more repeated choice.
    Plus,
    /// `:*` — zero-or-more repeated choice.
    Star,
    /// `:?` — zero-or-one choice.
    Optional,
}

impl RuleMode {
    /// True if this mode is an AND-type (ordered sequence) variant.
    pub fn is_and(&self) -> bool {
        matches!(
            self,
            RuleMode::And
                | RuleMode::AndPlus
                | RuleMode::AndBounded { .. }
                | RuleMode::Pipe
                | RuleMode::Single
        )
    }

    /// True if this mode involves repetition (looping).
    pub fn is_repetition(&self) -> bool {
        matches!(
            self,
            RuleMode::Default
                | RuleMode::Star
                | RuleMode::Plus
                | RuleMode::OrPlus
                | RuleMode::AndPlus
                | RuleMode::Optional
                | RuleMode::OrBounded { .. }
                | RuleMode::AndBounded { .. }
        )
    }

    /// The minimum number of repetitions, if this is a repetition mode.
    pub fn rep_min(&self) -> Option<usize> {
        match self {
            RuleMode::Default | RuleMode::Star | RuleMode::Optional => Some(0),
            RuleMode::Plus | RuleMode::OrPlus | RuleMode::AndPlus => Some(1),
            RuleMode::OrBounded { min, .. } | RuleMode::AndBounded { min, .. } => Some(*min),
            _ => None,
        }
    }

    /// The maximum number of repetitions, if this is a bounded repetition mode.
    pub fn rep_max(&self) -> Option<usize> {
        match self {
            RuleMode::Optional => Some(1),
            RuleMode::OrBounded { max, .. } | RuleMode::AndBounded { max, .. } => *max,
            _ => None,
        }
    }
}

/// A body element within a rule paragraph — one logical line or block.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BodyElement {
    /// Classification of this element.
    pub kind: BodyElementKind,
    /// The original source text (used for error messages, validation).
    pub source: String,
    /// The 1-based line number in the original file.
    pub line: usize,
}

/// The type of a body element.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "kind")]
pub enum BodyElementKind {
    /// A regex literal: `/pattern/`
    #[serde(rename = "regex")]
    Regex { pattern: String },
    /// An action edge: `-> Target` or `-> Target[N]` or `-> Target1 | Target2 { ... }`
    #[serde(rename = "action_edge")]
    ActionEdge {
        targets: Vec<EdgeTarget>,
        /// The attached code block, if present.
        code: Option<String>,
        /// Fluent chain methods on this edge, if any.
        fluent_chain: Vec<FluentCall>,
    },
    /// A blind-call edge: `=> Target` or `=> Target { ... }` or `=> Target .method() { ... }`
    #[serde(rename = "blind_edge")]
    BlindEdge {
        target: String,
        /// The attached code block, if present.
        code: Option<String>,
        /// Fluent chain methods on this edge, if any.
        fluent_chain: Vec<FluentCall>,
    },
    /// A lifecycle code block: `I { declare(array, results) }`
    #[serde(rename = "code_block")]
    CodeBlock {
        /// The lifecycle marker: I, LS, LE, E, EX, IT, LX
        lifecycle: String,
        /// The code inside the braces.
        code: String,
    },
    /// A plain code block (no lifecycle marker): `{ ... }`
    #[serde(rename = "plain_block")]
    PlainBlock { code: String },
    /// A split marker: `@capture_slice`, `@mark(name)`, `@capture_from_here`, `@move_pos`
    #[serde(rename = "split_marker")]
    SplitMarker { marker: String },
    /// A lifecycle marker without an attached block: bare `I`, `LS`, `LE`, etc.
    #[serde(rename = "lifecycle_marker")]
    LifecycleMarker { marker: String },
    /// A fluent chain continuation: `.method(args).method2()`
    #[serde(rename = "fluent_chain")]
    FluentChain { calls: Vec<FluentCall> },
    /// A conditional marker: `-? word`
    #[serde(rename = "conditional")]
    Conditional { word: String },
    /// A raw body line (fallback for unrecognized content — should not appear in valid specs).
    #[serde(rename = "raw")]
    Raw { text: String },
}

/// A single edge target: `RuleName` or `RuleName[N]`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EdgeTarget {
    pub label: String,
    pub index: usize,
}

/// A single fluent chain method call: `.method(args)`.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FluentCall {
    pub method: String,
    pub args: String,
}

impl BodyElement {
    pub fn new(kind: BodyElementKind, source: &str, line: usize) -> Self {
        Self {
            kind,
            source: source.to_string(),
            line,
        }
    }
}

impl SpecFile {
    /// Returns the top rule (the one with `::`), if any.
    pub fn top_rule(&self) -> Option<&Rule> {
        self.rules.iter().find(|r| r.header.is_top)
    }

    /// Returns all rule labels.
    pub fn labels(&self) -> Vec<&str> {
        self.rules.iter().map(|r| r.header.label.as_str()).collect()
    }

    /// Returns all top-level user-function names in source order.
    pub fn function_names(&self) -> Vec<&str> {
        self.functions.iter().map(|f| f.name.as_str()).collect()
    }

    /// Look up a rule by label.
    pub fn find_rule(&self, label: &str) -> Option<&Rule> {
        self.rules.iter().find(|r| r.header.label == label)
    }

    /// True if the mode implies consume-mode parsing.
    pub fn is_consume_mode(mode: &RuleMode) -> bool {
        mode.is_and()
    }
}
