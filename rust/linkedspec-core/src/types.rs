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
            Self::Array(arr) => {
                serde_json::Value::Array(arr.iter().map(|v| v.to_json()).collect())
            }
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
                if n.fract() == 0.0 { format!("{}", *n as i64) }
                else { format!("{n}") }
            }
            Self::Bool(b) => (if *b { "1" } else { "0" }).to_string(),
            Self::Undef => String::new(),
            Self::Array(_) | Self::Hash(_) => String::new(),
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

    /// Interpret this value as a boolean. Undef/empty/"0"/"false" → false.
    pub fn as_bool(&self) -> bool {
        match self {
            Self::Undef => false,
            Self::Bool(b) => *b,
            Self::Number(n) => *n != 0.0,
            Self::Scalar(s) => !s.is_empty() && s != "0" && s != "false",
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
                if n.fract() == 0.0 { format!("{}", *n as i64).len() }
                else { format!("{n}").len() }
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
                if n.fract() == 0.0 { write!(f, "{}", *n as i64) }
                else { write!(f, "{n}") }
            }
            Self::Bool(b) => write!(f, "{b}"),
            Self::Array(a) => {
                write!(f, "[")?;
                for (i, v) in a.iter().enumerate() {
                    if i > 0 { write!(f, ", ")?; }
                    write!(f, "{v}")?;
                }
                write!(f, "]")
            }
            Self::Hash(h) => {
                write!(f, "{{")?;
                for (i, (k, v)) in h.iter().enumerate() {
                    if i > 0 { write!(f, ", ")?; }
                    write!(f, "{k}: {v}")?;
                }
                write!(f, "}}")
            }
        }
    }
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
    /// Parse mode (seek or consume).
    pub parse_mode: ParseMode,
    /// Regex patterns for this rule (compiled from `/pattern/` body elements).
    pub regex_patterns: Vec<String>,
    /// Action edge dispatch: maps regex index → (child_label, code expression tree).
    pub acode_dispatch: Vec<(usize, String, Option<crate::expr::CodeBlock>)>,
    /// Blind-call dispatch: ordered list of (child_label, code expression tree).
    pub bcode_dispatch: Vec<(String, Option<crate::expr::CodeBlock>)>,
    /// Lifecycle blocks with parsed expression trees.
    pub preamble: Option<crate::expr::CodeBlock>,    // I-block
    pub lxcode: Option<crate::expr::CodeBlock>,      // LX-block (no-match exit)
    pub lscode: Option<crate::expr::CodeBlock>,      // LS-block (loop start)
    pub lecode: Option<crate::expr::CodeBlock>,      // LE-block (loop end)
    pub ecode: Option<crate::expr::CodeBlock>,       // E-block (exit)
    pub excode: Option<crate::expr::CodeBlock>,      // EX-block (exhaustion)
    pub itcode: Option<crate::expr::CodeBlock>,      // IT-block (per-iteration)
    /// Repetition bounds.
    pub rep_min: Option<usize>,
    pub rep_max: Option<usize>,
}

/// A fully compiled specification — maps rule labels to compiled rules.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompiledSpec {
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
}
