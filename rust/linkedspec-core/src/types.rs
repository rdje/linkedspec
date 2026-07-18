//! Core shared types — parse mode enum, value types, and compiled spec structures.
//!
//! These types are the contract between the compiler (in linkedspec-core) and the
//! runtime engine (in linkedspec-runtime). They are idiomatic Rust — no Perl mimicry.

use serde::{Deserialize, Serialize};

/// Parse mode for a rule handler.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ParseMode {
    /// Ungrounded matching — match anywhere from current position.
    Seek,
    /// \G-anchored matching — must match contiguously from current position.
    Consume,
}

impl ParseMode {
    pub fn is_consume(self) -> bool {
        matches!(self, Self::Consume)
    }
    pub fn is_seek(self) -> bool {
        matches!(self, Self::Seek)
    }
}

// ── Runtime value types (shared between core and runtime) ──

/// A runtime value — the data that flows through lifecycle code execution.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(untagged)]
pub enum RuntimeValue {
    /// Undefined / missing / null.
    Undef,
    /// A scalar string value.
    Scalar(String),
    /// A numeric value (stored as f64, displayed as integer when whole).
    Number(f64),
    /// An array of values.
    Array(Vec<RuntimeValue>),
    /// A hash / object of key-value pairs.
    Hash(Vec<(String, RuntimeValue)>),
    /// A boolean value.
    Bool(bool),
}

impl RuntimeValue {
    /// Convert to a serde_json::Value for output.
    pub fn to_json(&self) -> serde_json::Value {
        match self {
            Self::Undef => serde_json::Value::Null,
            Self::Scalar(s) => serde_json::Value::String(s.clone()),
            Self::Number(n) => {
                if n.fract() == 0.0 && n.is_finite() {
                    serde_json::Value::Number(serde_json::Number::from(*n as i64))
                } else {
                    serde_json::Number::from_f64(*n)
                        .map(serde_json::Value::Number)
                        .unwrap_or(serde_json::Value::Null)
                }
            }
            Self::Bool(b) => serde_json::Value::Bool(*b),
            Self::Array(arr) => serde_json::Value::Array(arr.iter().map(|v| v.to_json()).collect()),
            Self::Hash(entries) => {
                let mut map = serde_json::Map::new();
                for (k, v) in entries {
                    map.insert(k.clone(), v.to_json());
                }
                serde_json::Value::Object(map)
            }
        }
    }

    /// True if this value is undefined.
    pub fn is_undef(&self) -> bool {
        matches!(self, Self::Undef)
    }

    /// True if this value is defined (not undef).
    pub fn is_defined(&self) -> bool {
        !self.is_undef()
    }

    /// True if this value is a non-empty string, non-empty array, or non-empty hash.
    /// Undef is treated as empty.
    pub fn is_nonempty(&self) -> bool {
        match self {
            Self::Undef => false,
            Self::Scalar(s) => !s.is_empty(),
            Self::Number(_) => true,
            Self::Bool(_) => true,
            Self::Array(a) => !a.is_empty(),
            Self::Hash(h) => !h.is_empty(),
        }
    }

    /// Coerce to a string representation (for display/comparison).
    pub fn as_str(&self) -> Option<&str> {
        match self {
            Self::Scalar(s) => Some(s.as_str()),
            _ => None,
        }
    }

    /// Coerce to a string, returning empty string for undef/non-string.
    pub fn to_str(&self) -> String {
        match self {
            Self::Scalar(s) => s.clone(),
            Self::Number(n) => {
                if n.fract() == 0.0 {
                    format!("{}", *n as i64)
                } else {
                    format!("{n}")
                }
            }
            Self::Bool(b) => (if *b { "1" } else { "0" }).to_string(),
            Self::Undef => String::new(),
            Self::Array(_) | Self::Hash(_) => String::new(),
        }
    }

    /// Convert a scalar value to the portable LinkedSpec text spelling.
    ///
    /// Arrays, hashes, and undef are values but are not scalar text. Callers
    /// such as `cat` must propagate that distinction instead of silently
    /// replacing them with empty fragments.
    pub fn to_scalar_text(&self) -> Option<String> {
        match self {
            Self::Scalar(value) => Some(value.clone()),
            Self::Number(value) if value.is_finite() => Some(if *value == 0.0 {
                "0".to_string()
            } else {
                format!("{value}")
            }),
            Self::Bool(value) => Some(if *value { "1" } else { "0" }.to_string()),
            Self::Undef | Self::Array(_) | Self::Hash(_) | Self::Number(_) => None,
        }
    }

    /// Interpret this value as a numeric (f64). Returns None if not numeric.
    pub fn as_number(&self) -> Option<f64> {
        match self {
            Self::Number(n) => Some(*n),
            Self::Scalar(s) => s.parse::<f64>().ok(),
            Self::Bool(b) => Some(if *b { 1.0 } else { 0.0 }),
            _ => None,
        }
    }

    /// Interpret this value using LinkedSpec's typed truthiness contract.
    ///
    /// Undef, false, numeric zero, empty strings, and empty aggregates are
    /// false. Every non-empty string is true, including `"0"` and `"false"`.
    pub fn as_bool(&self) -> bool {
        match self {
            Self::Undef => false,
            Self::Bool(b) => *b,
            Self::Number(n) => *n != 0.0,
            Self::Scalar(s) => !s.is_empty(),
            Self::Array(a) => !a.is_empty(),
            Self::Hash(h) => !h.is_empty(),
        }
    }

    /// Get the length: string length, array length, hash key count, 0 for undef.
    pub fn len(&self) -> usize {
        match self {
            Self::Undef => 0,
            Self::Scalar(s) => s.len(),
            Self::Number(n) => {
                if n.fract() == 0.0 {
                    format!("{}", *n as i64).len()
                } else {
                    format!("{n}").len()
                }
            }
            Self::Bool(_) => 1,
            Self::Array(a) => a.len(),
            Self::Hash(h) => h.len(),
        }
    }
}

impl Default for RuntimeValue {
    fn default() -> Self {
        Self::Undef
    }
}

impl std::fmt::Display for RuntimeValue {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Undef => write!(f, "undef"),
            Self::Scalar(s) => write!(f, "{s}"),
            Self::Number(n) => {
                if n.fract() == 0.0 {
                    write!(f, "{}", *n as i64)
                } else {
                    write!(f, "{n}")
                }
            }
            Self::Bool(b) => write!(f, "{b}"),
            Self::Array(a) => {
                write!(f, "[")?;
                for (i, v) in a.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{v}")?;
                }
                write!(f, "]")
            }
            Self::Hash(h) => {
                write!(f, "{{")?;
                for (i, (k, v)) in h.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{k}: {v}")?;
                }
                write!(f, "}}")
            }
        }
    }
}

/// An action edge entry in the compiled dispatch table.
///
/// Action edges fire when a regex alternative matches. Each entry records:
/// - which regex of *this* rule's alternation triggers the edge (`regex_idx`)
/// - which child rule to invoke (`child_label`)
/// - which regex slot of the *child* rule to enter (`child_regex_idx`, from `-> child[N]`)
/// - whether this edge was anchored to a parent `/regex/` or is edge-only
/// - optional lifecycle code to execute after the child returns
/// - optional fluent continuation methods attached to the edge
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AcodeEntry {
    /// Index of the regex pattern in this rule's alternation that triggers this edge.
    /// For parent-anchored edges: points to the parent regex position.
    /// For edge-only entries: set during post-processing to the position of the
    /// resolved child regex in the expanded alternation.
    pub regex_idx: usize,
    /// Label of the child rule to invoke.
    pub child_label: String,
    /// Which regex slot of the child rule to enter (from `-> child[N]`; 0 = default first).
    pub child_regex_idx: usize,
    /// Optional code block to execute after child dispatch.
    pub code: Option<crate::expr::CodeBlock>,
    /// Optional fluent chain on the edge (`-> rule .push`, `-> rule[1] .return(...)`).
    /// Each entry is (method_name, args_string).
    #[serde(default)]
    pub fluent_chain: Vec<(String, String)>,
    /// True if this edge immediately follows a `/regex/` element in the rule body
    /// (i.e. it is "anchored" to a parent regex). False for edge-only entries that
    /// need child-regex resolution during post-processing.
    #[serde(default = "default_has_parent_regex")]
    pub has_parent_regex: bool,
}

fn default_has_parent_regex() -> bool {
    true
}

/// A blind-call edge entry in the compiled dispatch table.
///
/// Blind-call edges (`=> rule`) are dispatched sequentially in AND-type rules.
/// They can carry an optional code block and/or a fluent chain of method calls.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BcodeEntry {
    /// Label of the child rule to invoke.
    pub child_label: String,
    /// Optional code block attached to the edge.
    pub code: Option<crate::expr::CodeBlock>,
    /// Optional fluent chain on the edge (`=> rule .method(args).method2(args2)`).
    /// Each entry is (method_name, args_string).
    pub fluent_chain: Vec<(String, String)>,
}

/// A rule dependency reference in source order.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct DependencyRef {
    /// Referenced rule label.
    pub label: String,
    /// Zero-based regex slot in the referenced rule.
    #[serde(rename = "idx")]
    pub index: usize,
}

/// A compiled rule specification — the output of the compiler, input to the runtime.
///
/// This is the Rust-native equivalent of what the Perl variant achieves through
/// HandlerIR + eval-based code generation. It contains parsed expression trees
/// for all lifecycle blocks, compiled regex patterns, and dispatch tables.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompiledRule {
    /// Rule label.
    pub label: String,
    /// Whether this is a top rule.
    pub is_top: bool,
    /// Original parsed rule mode, preserved for generated-source family planning.
    #[serde(default)]
    pub mode: crate::ast::RuleMode,
    /// Regex patterns for this rule (compiled from `/pattern/` body elements).
    pub regex_patterns: Vec<String>,
    /// Ordered child-regex dependencies from action and blind-call edges.
    #[serde(default)]
    pub dependency_refs: Vec<DependencyRef>,
    /// Action edge dispatch: fires when the matching regex alternative matches.
    pub acode_dispatch: Vec<AcodeEntry>,
    /// Blind-call dispatch: ordered list of entries for `=> child` edges.
    pub bcode_dispatch: Vec<BcodeEntry>,
    /// Lifecycle blocks with parsed expression trees.
    pub preamble: Option<crate::expr::CodeBlock>, // I-block
    pub lxcode: Option<crate::expr::CodeBlock>, // LX-block (no-match exit)
    pub lscode: Option<crate::expr::CodeBlock>, // LS-block (loop start)
    pub lecode: Option<crate::expr::CodeBlock>, // LE-block (loop end)
    pub ecode: Option<crate::expr::CodeBlock>,  // E-block (exit)
    pub excode: Option<crate::expr::CodeBlock>, // EX-block (exhaustion)
    pub itcode: Option<crate::expr::CodeBlock>, // IT-block (per-iteration)
    /// Repetition bounds.
    pub rep_min: Option<usize>,
    pub rep_max: Option<usize>,
}

impl CompiledRule {
    /// Return the live cursor policy derived from this rule's authored family.
    ///
    /// Cursor policy is intentionally not stored as an independently mutable
    /// compiled field. AND-family rules consume; every OR/default family seeks.
    pub fn cursor_policy(&self) -> ParseMode {
        if self.mode.is_and() {
            ParseMode::Consume
        } else {
            ParseMode::Seek
        }
    }

    /// Reproduce the pre-rule-local policy only for staged v1 artifact views.
    ///
    /// Descriptor v1 and generated-source v1 migrate in
    /// `FUTURE-PARITY-BACKLOG.9.1.4.4-.5`. Normal live, loaded, and serialized
    /// execution must use [`Self::cursor_policy`] instead.
    pub fn legacy_artifact_parse_mode(&self) -> ParseMode {
        if self.mode.uses_legacy_and_interpretation() || !self.bcode_dispatch.is_empty() {
            ParseMode::Consume
        } else {
            ParseMode::Seek
        }
    }
}

/// A compiled top-level user-defined function definition.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompiledUserFunction {
    pub name: String,
    pub params: Vec<String>,
    pub arity: usize,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub signature: Option<crate::ast::CallableSignature>,
    pub body: crate::expr::CodeBlock,
    pub body_source: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub body_payload: Option<serde_json::Value>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub body_parse_job: Option<serde_json::Value>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub body_ast: Option<serde_json::Value>,
    pub source: String,
    pub source_span: crate::ast::SourceSpan,
    pub body_span: crate::ast::SourceSpan,
}

/// A fully compiled specification — maps rule labels to compiled rules.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompiledSpec {
    #[serde(default)]
    pub functions: Vec<CompiledUserFunction>,
    pub rules: Vec<CompiledRule>,
}

impl CompiledSpec {
    /// Find a compiled rule by label.
    pub fn find(&self, label: &str) -> Option<&CompiledRule> {
        self.rules.iter().find(|r| r.label == label)
    }

    /// Find the top rule.
    pub fn top_rule(&self) -> Option<&CompiledRule> {
        self.rules.iter().find(|r| r.is_top)
    }

    /// Find a compiled user function by name.
    pub fn find_function(&self, name: &str) -> Option<&CompiledUserFunction> {
        self.functions.iter().find(|f| f.name == name)
    }
}
