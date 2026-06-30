//! Expression AST for lifecycle code — parsed from code strings like
//! `push_value(array(results), scalar(retv))` and interpreted at runtime.
//!
//! This is the Rust-native replacement for Perl's eval-based code generation.
//! Lifecycle code is parsed into expression trees once at compile time,
//! then walked by the runtime interpreter during parser execution.
//!
//! ## Grammar
//!
//! ```text
//! stmts       → stmt*
//! stmt        → attached_if | attached_switch | attached_while | hash_index_assignment | array_append | scalar_assignment | expr ';'?
//! attached_if → (if | when) '(' expr ')' '{' stmts '}' (elseif '(' expr ')' '{' stmts '}')* ((else | otherwise) '{' stmts '}')?
//! attached_switch → switch '(' expr ')' '{' (case '(' expr ')' '{' stmts '}' | default '('? ')'? '{' stmts '}')+ '}'
//! attached_while → while '(' expr ')' '{' stmts '}'
//! scalar_assignment → name '=' expr      (statement only)
//! array_append → name '+=' expr          (statement only)
//! hash_index_assignment → name '[' expr ']' '=' expr  (statement only)
//! expr        → primary ('.' method_call)*
//! primary     → call | nested_access | indexed_var | literal | variable
//! call        → name '(' args? ')'
//! method_call → name '(' args? ')'
//! args        → arg (',' arg)*
//! arg         → expr | name '=' expr       (keyword argument)
//! literal     → string | number | boolean | regex | undef | array | hash
//! array       → '[' (expr (',' expr)*)? ']'
//! hash        → '{' (expr '=>' expr (',' expr '=>' expr)*)? '}'
//! block       → '{' stmt+ '}'              (non-empty, no top-level '=>')
//! string      → '"' [^"]* '"' | "'" [^']* "'"
//! number      → -?\d+(\.\d+)?
//! boolean     → 'true' | 'false'
//! undef       → 'undef'
//! variable    → '$'? name                  (bare word variable reference)
//! indexed_var → variable '[' expr ']'      (single-level array index access)
//! nested_access → variable ('[' expr ']')+ (mixed hash/array path access)
//! regex       → '/' [^/]* '/'
//! name        → [a-zA-Z_]\w*
//! ```

use serde::{Deserialize, Serialize};

/// A complete lifecycle code block, parsed into a sequence of statements.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct CodeBlock {
    pub statements: Vec<Stmt>,
}

/// A single statement within a lifecycle block.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Stmt {
    pub expr: Expr,
}

/// One segment in a direct nested-access path.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "kind")]
pub enum AccessSegment {
    /// Hash/object key segment from a quoted string: `foo["key"]`
    #[serde(rename = "key")]
    Key { value: String },
    /// Array index segment from a numeric or explicit helper expression: `foo[0]`, `foo[scalar(i)]`
    #[serde(rename = "index")]
    Index { expr: Box<Expr> },
}

/// One key/value pair in a direct hash shape literal.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct HashLiteralEntry {
    pub key: Expr,
    pub value: Expr,
}

/// An expression — the core of the lifecycle code language.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "kind")]
pub enum Expr {
    /// A helper function call: `push_value(array(results), scalar(retv))`
    #[serde(rename = "call")]
    Call { name: String, args: Vec<Arg> },
    /// A statement-only scalar assignment operator: `name = value`
    #[serde(rename = "assign_scalar")]
    AssignScalar { name: String, value: Box<Expr> },
    /// A statement-only array append operator: `items += value`
    #[serde(rename = "assign_array_append")]
    AssignArrayAppend { name: String, value: Box<Expr> },
    /// A statement-only hash-index assignment operator: `meta["key"] = value`
    #[serde(rename = "assign_hash_index")]
    AssignHashIndex {
        name: String,
        key: Box<Expr>,
        value: Box<Expr>,
    },
    /// A variable reference: `results`, `retv`, `$name`
    #[serde(rename = "variable")]
    Variable { name: String },
    /// An indexed variable access: `results[0]`, `$hash{"key"}`
    #[serde(rename = "indexed_var")]
    IndexedVar { name: String, index: Box<Expr> },
    /// A mixed nested access path: `foo["a"][0]["b"]`
    #[serde(rename = "nested_access")]
    NestedAccess {
        base: String,
        segments: Vec<AccessSegment>,
    },
    /// A direct array shape literal: `[]`, `[value, true]`
    #[serde(rename = "array_literal")]
    ArrayLiteral { items: Vec<Expr> },
    /// A direct hash shape literal: `{ key => value }`
    #[serde(rename = "hash_literal")]
    HashLiteral { entries: Vec<HashLiteralEntry> },
    /// A value-returning block expression: `{ set(x, "a"); x }`
    #[serde(rename = "block_value")]
    BlockValue { block: CodeBlock },
    /// A string literal: `"hello"`, `'world'`
    #[serde(rename = "string")]
    StringLiteral { value: String },
    /// A numeric literal: `42`, `0`, `3.14`
    #[serde(rename = "number")]
    NumberLiteral { value: f64 },
    /// A boolean literal: `true`, `false`
    #[serde(rename = "boolean")]
    BooleanLiteral { value: bool },
    /// A regex literal: `/pattern/`
    #[serde(rename = "regex")]
    RegexLiteral { pattern: String },
    /// Undefined/null: `undef`
    #[serde(rename = "undef")]
    Undef,
    /// A fluent method chain: `push_value(...).return(...).endif()`
    #[serde(rename = "fluent_chain")]
    FluentChain {
        receiver: Box<Expr>,
        calls: Vec<FluentCall>,
    },
}

/// A fluent chain method call: `.method(args)`.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct FluentCall {
    pub method: String,
    pub args: Vec<Arg>,
}

/// An argument to a function call.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Arg {
    /// A plain positional argument: `expr`
    Positional(Expr),
    /// A keyword argument: `name=expr`
    Keyword { name: String, value: Box<Expr> },
}

impl Arg {
    /// The value expression of this argument, regardless of kind.
    pub fn value(&self) -> &Expr {
        match self {
            Arg::Positional(e) => e,
            Arg::Keyword { value, .. } => value,
        }
    }
}

// ── Display for debugging ──

impl std::fmt::Display for Expr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Expr::Call { name, args } => {
                write!(f, "{name}(")?;
                for (i, arg) in args.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    match arg {
                        Arg::Positional(e) => write!(f, "{e}")?,
                        Arg::Keyword { name, value } => write!(f, "{name}={value}")?,
                    }
                }
                write!(f, ")")
            }
            Expr::AssignScalar { name, value } => write!(f, "{name} = {value}"),
            Expr::AssignArrayAppend { name, value } => write!(f, "{name} += {value}"),
            Expr::AssignHashIndex { name, key, value } => write!(f, "{name}[{key}] = {value}"),
            Expr::Variable { name } => write!(f, "{name}"),
            Expr::IndexedVar { name, index } => write!(f, "{name}[{index}]"),
            Expr::NestedAccess { base, segments } => {
                write!(f, "{base}")?;
                for segment in segments {
                    match segment {
                        AccessSegment::Key { value } => write!(f, "[\"{value}\"]")?,
                        AccessSegment::Index { expr } => write!(f, "[{expr}]")?,
                    }
                }
                Ok(())
            }
            Expr::ArrayLiteral { items } => {
                write!(f, "[")?;
                for (i, item) in items.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{item}")?;
                }
                write!(f, "]")
            }
            Expr::HashLiteral { entries } => {
                write!(f, "{{")?;
                for (i, entry) in entries.iter().enumerate() {
                    if i > 0 {
                        write!(f, ", ")?;
                    }
                    write!(f, "{} => {}", entry.key, entry.value)?;
                }
                write!(f, "}}")
            }
            Expr::BlockValue { block } => {
                write!(f, "{{")?;
                for (i, stmt) in block.statements.iter().enumerate() {
                    if i > 0 {
                        write!(f, "; ")?;
                    }
                    write!(f, "{}", stmt.expr)?;
                }
                write!(f, "}}")
            }
            Expr::StringLiteral { value } => write!(f, "\"{value}\""),
            Expr::NumberLiteral { value } => write!(f, "{value}"),
            Expr::BooleanLiteral { value } => write!(f, "{value}"),
            Expr::RegexLiteral { pattern } => write!(f, "/{pattern}/"),
            Expr::Undef => write!(f, "undef"),
            Expr::FluentChain { receiver, calls } => {
                write!(f, "{receiver}")?;
                for call in calls {
                    write!(f, ".{}(", call.method)?;
                    for (i, arg) in call.args.iter().enumerate() {
                        if i > 0 {
                            write!(f, ", ")?;
                        }
                        match arg {
                            Arg::Positional(e) => write!(f, "{e}")?,
                            Arg::Keyword { name, value } => write!(f, "{name}={value}")?,
                        }
                    }
                    write!(f, ")")?;
                }
                Ok(())
            }
        }
    }
}

impl CodeBlock {
    /// Parse a lifecycle code string into a CodeBlock of statements.
    pub fn parse(source: &str) -> Result<Self, String> {
        let mut parser = Parser::new(source);
        parser.parse_block()
    }
}

// ── Recursive-descent parser ──

struct Parser<'a> {
    src: &'a str,
    pos: usize,
}

impl<'a> Parser<'a> {
    fn new(src: &'a str) -> Self {
        Self { src, pos: 0 }
    }

    fn remaining(&self) -> &'a str {
        &self.src[self.pos..]
    }

    fn peek(&self) -> Option<char> {
        self.remaining().chars().next()
    }

    fn skip_whitespace(&mut self) {
        while self.pos < self.src.len() {
            let ch = self.src.as_bytes()[self.pos];
            if ch == b' ' || ch == b'\t' || ch == b'\n' || ch == b'\r' {
                self.pos += 1;
            } else {
                break;
            }
        }
    }

    fn skip_inline_whitespace(&mut self) {
        while self.pos < self.src.len() {
            let ch = self.src.as_bytes()[self.pos];
            if ch == b' ' || ch == b'\t' {
                self.pos += 1;
            } else {
                break;
            }
        }
    }

    fn skip_statement_separator_whitespace(&mut self) -> bool {
        let mut has_line_break = false;
        while self.pos < self.src.len() {
            let ch = self.src.as_bytes()[self.pos];
            if ch == b' ' || ch == b'\t' {
                self.pos += 1;
            } else if ch == b'\n' || ch == b'\r' {
                has_line_break = true;
                self.pos += 1;
            } else {
                break;
            }
        }
        has_line_break
    }

    fn advance(&mut self, n: usize) {
        self.pos = (self.pos + n).min(self.src.len());
    }

    fn parse_block(&mut self) -> Result<CodeBlock, String> {
        let mut statements = Vec::new();
        self.skip_whitespace();
        while self.pos < self.src.len() {
            // Skip semicolons between statements
            if self.peek() == Some(';') {
                self.advance(1);
                self.skip_whitespace();
                continue;
            }
            // Skip bare 'my' keyword (compatibility: `my $var = ...`)
            self.skip_whitespace();
            if self.remaining().starts_with("my ") {
                self.advance(3);
                self.skip_whitespace();
            }
            if let Some(mut attached_if_statements) = self.try_parse_attached_if_chain()? {
                statements.append(&mut attached_if_statements);
            } else if let Some(mut attached_switch_statements) =
                self.try_parse_attached_switch_block()?
            {
                statements.append(&mut attached_switch_statements);
            } else if let Some(attached_while_statement) = self.try_parse_attached_while_block()? {
                statements.push(attached_while_statement);
            } else {
                let expr = self.parse_statement_expr()?;
                statements.push(Stmt { expr });
            }
            let has_line_break = self.skip_statement_separator_whitespace();
            if self.peek() == Some(';') {
                self.advance(1);
                self.skip_whitespace();
                continue;
            }
            if self.pos < self.src.len() && !has_line_break {
                return Err(format!(
                    "expected ';' or newline between statements at byte {}",
                    self.pos
                ));
            }
        }
        Ok(CodeBlock { statements })
    }

    fn parse_statement_expr(&mut self) -> Result<Expr, String> {
        let start = self.pos;
        if let Some(expr) = self.try_parse_hash_index_assignment_statement()? {
            return Ok(expr);
        }
        self.pos = start;
        if let Some(expr) = self.try_parse_array_append_statement()? {
            return Ok(expr);
        }
        self.pos = start;
        if let Some(expr) = self.try_parse_scalar_assignment_statement()? {
            return Ok(expr);
        }
        self.pos = start;
        self.parse_expr()
    }

    fn try_parse_attached_if_chain(&mut self) -> Result<Option<Vec<Stmt>>, String> {
        let start = self.pos;
        let (if_expr, if_body) = match self.try_parse_attached_conditional_branch("if", "if")? {
            Some(branch) => branch,
            None => match self.try_parse_attached_conditional_branch("when", "if")? {
                Some(branch) => branch,
                None => {
                    self.pos = start;
                    return Ok(None);
                }
            },
        };

        let mut statements = Vec::new();
        statements.push(Stmt { expr: if_expr });
        statements.extend(if_body.statements);

        loop {
            let before_separator = self.pos;
            self.skip_whitespace();

            if let Some((elseif_expr, elseif_body)) =
                self.try_parse_attached_conditional_branch("elseif", "elseif")?
            {
                statements.push(Stmt { expr: elseif_expr });
                statements.extend(elseif_body.statements);
                continue;
            }

            if let Some(else_body) = self.try_parse_attached_else_branch()? {
                statements.push(Self::zero_arg_call_stmt("else"));
                statements.extend(else_body.statements);
                break;
            }

            self.pos = before_separator;
            break;
        }

        statements.push(Self::zero_arg_call_stmt("endif"));
        Ok(Some(statements))
    }

    fn try_parse_attached_switch_block(&mut self) -> Result<Option<Vec<Stmt>>, String> {
        let start = self.pos;
        if !self.starts_with_keyword("switch") {
            return Ok(None);
        }

        let expr = self.parse_var_or_call()?;
        let Expr::Call { name, args } = &expr else {
            self.pos = start;
            return Ok(None);
        };
        if name != "switch" || args.len() != 1 {
            self.pos = start;
            return Ok(None);
        }

        self.skip_whitespace();
        if self.peek() != Some('{') {
            self.pos = start;
            return Ok(None);
        }

        let mut statements = Vec::new();
        statements.push(Stmt { expr });
        statements.extend(self.parse_attached_switch_outer_block()?);
        statements.push(Self::zero_arg_call_stmt("endswitch"));
        Ok(Some(statements))
    }

    fn try_parse_attached_while_block(&mut self) -> Result<Option<Stmt>, String> {
        let start = self.pos;
        if !self.starts_with_keyword("while") {
            return Ok(None);
        }

        let expr = self.parse_var_or_call()?;
        let Expr::Call { name, mut args } = expr else {
            self.pos = start;
            return Ok(None);
        };
        if name != "while" || args.len() != 1 {
            self.pos = start;
            return Ok(None);
        }

        self.skip_whitespace();
        if self.peek() != Some('{') {
            self.pos = start;
            return Ok(None);
        }

        let body = self.parse_attached_branch_block("while")?;
        args.push(Arg::Positional(Expr::BlockValue { block: body }));
        Ok(Some(Stmt {
            expr: Expr::Call { name, args },
        }))
    }

    fn parse_attached_switch_outer_block(&mut self) -> Result<Vec<Stmt>, String> {
        let start = self.pos;
        let (payload_start, payload_end, after_close) = self.scan_brace_payload_bounds()?;
        let payload = &self.src[payload_start..payload_end];
        let mut branch_parser = Parser::new(payload);
        let statements = branch_parser.parse_attached_switch_body().map_err(|e| {
            format!("invalid attached switch block starting at position {start}: {e}")
        })?;
        self.pos = after_close;
        Ok(statements)
    }

    fn parse_attached_switch_body(&mut self) -> Result<Vec<Stmt>, String> {
        let mut statements = Vec::new();
        self.skip_whitespace();

        while self.pos < self.src.len() {
            if let Some((case_expr, case_body)) = self.try_parse_attached_case_branch()? {
                statements.push(Stmt { expr: case_expr });
                statements.extend(case_body.statements);
            } else if let Some(default_body) = self.try_parse_attached_default_branch()? {
                statements.push(Self::zero_arg_call_stmt("default"));
                statements.extend(default_body.statements);
            } else {
                return Err(format!(
                    "expected attached case(...) {{...}} or default {{...}} at byte {}",
                    self.pos
                ));
            }
            self.skip_whitespace();
        }

        if statements.is_empty() {
            return Err("attached switch block requires at least one case/default branch".into());
        }
        Ok(statements)
    }

    fn try_parse_attached_case_branch(&mut self) -> Result<Option<(Expr, CodeBlock)>, String> {
        let start = self.pos;
        if !self.starts_with_keyword("case") {
            return Ok(None);
        }

        let expr = self.parse_var_or_call()?;
        let Expr::Call { name, args } = &expr else {
            self.pos = start;
            return Ok(None);
        };
        if name != "case" || args.len() != 1 {
            self.pos = start;
            return Ok(None);
        }

        self.skip_whitespace();
        if self.peek() != Some('{') {
            self.pos = start;
            return Ok(None);
        }

        let body = self.parse_attached_branch_block("switch case")?;
        Ok(Some((expr, body)))
    }

    fn try_parse_attached_default_branch(&mut self) -> Result<Option<CodeBlock>, String> {
        let start = self.pos;
        if !self.starts_with_keyword("default") {
            return Ok(None);
        }

        self.advance("default".len());
        self.skip_whitespace();
        if self.peek() == Some('(') {
            self.pos = start;
            let expr = self.parse_var_or_call()?;
            let Expr::Call { name, args } = &expr else {
                self.pos = start;
                return Ok(None);
            };
            if name != "default" || !args.is_empty() {
                self.pos = start;
                return Ok(None);
            }
            self.skip_whitespace();
        }

        if self.peek() != Some('{') {
            self.pos = start;
            return Ok(None);
        }

        self.parse_attached_branch_block("switch default").map(Some)
    }

    fn try_parse_attached_conditional_branch(
        &mut self,
        keyword: &str,
        canonical_name: &str,
    ) -> Result<Option<(Expr, CodeBlock)>, String> {
        let start = self.pos;
        if !self.starts_with_keyword(keyword) {
            return Ok(None);
        }

        let mut expr = self.parse_var_or_call()?;
        let Expr::Call { name, args } = &mut expr else {
            self.pos = start;
            return Ok(None);
        };
        if name != keyword || args.len() != 1 {
            self.pos = start;
            return Ok(None);
        }
        if name != canonical_name {
            *name = canonical_name.to_string();
        }

        self.skip_whitespace();
        if self.peek() != Some('{') {
            self.pos = start;
            return Ok(None);
        }

        let body = self.parse_attached_branch_block("if/elseif")?;
        Ok(Some((expr, body)))
    }

    fn try_parse_attached_else_branch(&mut self) -> Result<Option<CodeBlock>, String> {
        let start = self.pos;
        let keyword = if self.starts_with_keyword("else") {
            "else"
        } else if self.starts_with_keyword("otherwise") {
            "otherwise"
        } else {
            return Ok(None);
        };

        self.advance(keyword.len());
        self.skip_whitespace();
        if self.peek() != Some('{') {
            self.pos = start;
            return Ok(None);
        }

        self.parse_attached_branch_block(keyword).map(Some)
    }

    fn parse_attached_branch_block(&mut self, label: &str) -> Result<CodeBlock, String> {
        let start = self.pos;
        let (payload_start, payload_end, after_close) = self.scan_brace_payload_bounds()?;
        let payload = &self.src[payload_start..payload_end];
        let block = CodeBlock::parse(payload).map_err(|e| {
            format!("invalid attached {label} branch block starting at position {start}: {e}")
        })?;
        self.pos = after_close;
        Ok(block)
    }

    fn starts_with_keyword(&self, keyword: &str) -> bool {
        let remaining = self.remaining();
        if !remaining.starts_with(keyword) {
            return false;
        }
        let after = &remaining[keyword.len()..];
        after
            .chars()
            .next()
            .is_none_or(|ch| !ch.is_alphanumeric() && ch != '_')
    }

    fn zero_arg_call_stmt(name: &str) -> Stmt {
        Stmt {
            expr: Expr::Call {
                name: name.to_string(),
                args: Vec::new(),
            },
        }
    }

    fn try_parse_hash_index_assignment_statement(&mut self) -> Result<Option<Expr>, String> {
        self.skip_whitespace();
        let start = self.pos;
        let Some(ch) = self.peek() else {
            return Ok(None);
        };
        if !ch.is_ascii_alphabetic() && ch != '_' {
            return Ok(None);
        }

        let name = self.parse_name();
        if name.is_empty() || !name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_') {
            self.pos = start;
            return Ok(None);
        }
        self.skip_whitespace();
        if self.peek() != Some('[') {
            self.pos = start;
            return Ok(None);
        }

        self.advance(1);
        self.skip_whitespace();
        if self.pos >= self.src.len() {
            self.pos = start;
            return Ok(None);
        }
        let key = self.parse_expr()?;
        self.skip_whitespace();
        if self.peek() != Some(']') {
            self.pos = start;
            return Ok(None);
        }
        self.advance(1);
        self.skip_whitespace();
        if self.peek() != Some('=') {
            self.pos = start;
            return Ok(None);
        }
        let after_eq = self.src[self.pos + 1..].chars().next();
        if matches!(after_eq, Some('=') | Some('>')) {
            self.pos = start;
            return Ok(None);
        }

        self.advance(1);
        self.skip_whitespace();
        if self.pos >= self.src.len() {
            self.pos = start;
            return Ok(None);
        }
        let value = self.parse_expr()?;
        Ok(Some(Expr::AssignHashIndex {
            name,
            key: Box::new(key),
            value: Box::new(value),
        }))
    }

    fn try_parse_array_append_statement(&mut self) -> Result<Option<Expr>, String> {
        self.skip_whitespace();
        let start = self.pos;
        let Some(ch) = self.peek() else {
            return Ok(None);
        };
        if !ch.is_ascii_alphabetic() && ch != '_' {
            return Ok(None);
        }

        let name = self.parse_name();
        if name.is_empty() || !name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_') {
            self.pos = start;
            return Ok(None);
        }
        self.skip_whitespace();
        if !self.remaining().starts_with("+=") {
            self.pos = start;
            return Ok(None);
        }

        self.advance(2);
        self.skip_whitespace();
        if self.pos >= self.src.len() {
            self.pos = start;
            return Ok(None);
        }
        let value = self.parse_expr()?;
        Ok(Some(Expr::AssignArrayAppend {
            name,
            value: Box::new(value),
        }))
    }

    fn try_parse_scalar_assignment_statement(&mut self) -> Result<Option<Expr>, String> {
        self.skip_whitespace();
        let start = self.pos;
        let Some(ch) = self.peek() else {
            return Ok(None);
        };
        if !ch.is_ascii_alphabetic() && ch != '_' {
            return Ok(None);
        }

        let name = self.parse_name();
        if name.is_empty() || !name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_') {
            self.pos = start;
            return Ok(None);
        }
        self.skip_whitespace();
        if self.peek() != Some('=') {
            self.pos = start;
            return Ok(None);
        }
        let after_eq = self.src[self.pos + 1..].chars().next();
        if matches!(after_eq, Some('=') | Some('>')) {
            self.pos = start;
            return Ok(None);
        }

        self.advance(1);
        self.skip_whitespace();
        if self.pos >= self.src.len() {
            self.pos = start;
            return Ok(None);
        }
        let value = self.parse_expr()?;
        Ok(Some(Expr::AssignScalar {
            name,
            value: Box::new(value),
        }))
    }

    fn parse_expr(&mut self) -> Result<Expr, String> {
        self.skip_whitespace();
        if self.pos >= self.src.len() {
            return Err("unexpected end of expression".into());
        }

        let ch = self.peek().unwrap();

        match ch {
            '"' | '\'' => self.parse_string(),
            '/' => self.parse_regex(),
            '[' => self.parse_array_literal(),
            '{' => self.parse_brace_expr(),
            '$' => {
                self.advance(1);
                self.parse_var_or_call()
            }
            '0'..='9' | '-' => {
                // Look ahead: if '-' followed by digit, it's a negative number
                if ch == '-' {
                    let after = self.src[self.pos + 1..].chars().next();
                    if after.is_some_and(|c| c.is_ascii_digit()) {
                        return self.parse_number();
                    }
                }
                if ch == '-' {
                    // Bare '-' without digits — treat as variable
                    self.advance(1);
                    self.parse_var_or_call()
                } else {
                    self.parse_number()
                }
            }
            'u' if self.remaining().starts_with("undef") => {
                // Check that "undef" is a whole word, not a prefix of a longer name
                let after = &self.remaining()[5..];
                if after.is_empty()
                    || !after.chars().next().unwrap().is_alphanumeric()
                        && after.chars().next().unwrap() != '_'
                {
                    self.advance(5);
                    Ok(Expr::Undef)
                } else {
                    self.parse_var_or_call()
                }
            }
            't' if self.remaining().starts_with("true") => {
                let after = &self.remaining()[4..];
                if after.is_empty()
                    || !after.chars().next().unwrap().is_alphanumeric()
                        && after.chars().next().unwrap() != '_'
                {
                    self.advance(4);
                    Ok(Expr::BooleanLiteral { value: true })
                } else {
                    self.parse_var_or_call()
                }
            }
            'f' if self.remaining().starts_with("false") => {
                let after = &self.remaining()[5..];
                if after.is_empty()
                    || !after.chars().next().unwrap().is_alphanumeric()
                        && after.chars().next().unwrap() != '_'
                {
                    self.advance(5);
                    Ok(Expr::BooleanLiteral { value: false })
                } else {
                    self.parse_var_or_call()
                }
            }
            c if c.is_alphabetic() || c == '_' => self.parse_var_or_call(),
            _ => {
                let end = (self.pos + 40).min(self.src.len());
                Err(format!(
                    "unexpected character '{}' at position {} near: '{}'",
                    ch,
                    self.pos,
                    &self.src[self.pos..end]
                ))
            }
        }
    }

    fn parse_array_literal(&mut self) -> Result<Expr, String> {
        self.advance(1); // consume '['
        let mut items = Vec::new();
        loop {
            self.skip_whitespace();
            if self.peek() == Some(']') {
                self.advance(1);
                return Ok(Expr::ArrayLiteral { items });
            }
            if self.pos >= self.src.len() {
                return Err("unterminated array literal".to_string());
            }

            items.push(self.parse_expr()?);
            self.skip_whitespace();
            match self.peek() {
                Some(',') => {
                    self.advance(1);
                }
                Some(']') => {
                    self.advance(1);
                    return Ok(Expr::ArrayLiteral { items });
                }
                Some(ch) => {
                    return Err(format!(
                        "expected ',' or ']' in array literal at position {}, found '{}'",
                        self.pos, ch
                    ));
                }
                None => return Err("unterminated array literal".to_string()),
            }
        }
    }

    fn parse_hash_literal(&mut self) -> Result<Expr, String> {
        self.advance(1); // consume '{'
        let mut entries = Vec::new();
        loop {
            self.skip_whitespace();
            if self.peek() == Some('}') {
                self.advance(1);
                return Ok(Expr::HashLiteral { entries });
            }
            if self.pos >= self.src.len() {
                return Err("unterminated hash literal".to_string());
            }

            let key = self.parse_expr()?;
            self.skip_whitespace();
            if !self.remaining().starts_with("=>") {
                return Err(format!(
                    "expected '=>' in hash literal at position {}",
                    self.pos
                ));
            }
            self.advance(2);
            self.skip_whitespace();
            if self.pos >= self.src.len() || self.peek() == Some('}') {
                return Err(format!(
                    "expected value after '=>' in hash literal at position {}",
                    self.pos
                ));
            }

            let value = self.parse_expr()?;
            entries.push(HashLiteralEntry { key, value });

            self.skip_whitespace();
            match self.peek() {
                Some(',') => {
                    self.advance(1);
                }
                Some('}') => {
                    self.advance(1);
                    return Ok(Expr::HashLiteral { entries });
                }
                Some(ch) => {
                    return Err(format!(
                        "expected ',' or '}}' in hash literal at position {}, found '{}'",
                        self.pos, ch
                    ));
                }
                None => return Err("unterminated hash literal".to_string()),
            }
        }
    }

    fn parse_brace_expr(&mut self) -> Result<Expr, String> {
        let start = self.pos;
        let (payload_start, payload_end, after_close) = self.scan_brace_payload_bounds()?;
        let payload = &self.src[payload_start..payload_end];

        if payload.trim().is_empty() || Self::has_top_level_fat_arrow(payload) {
            self.pos = start;
            return self.parse_hash_literal();
        }

        let block = CodeBlock::parse(payload).map_err(|e| {
            format!(
                "invalid expression-valued block starting at position {}: {}",
                start, e
            )
        })?;
        if block.statements.is_empty() {
            self.pos = start;
            return self.parse_hash_literal();
        }

        self.pos = after_close;
        Ok(Expr::BlockValue { block })
    }

    fn scan_brace_payload_bounds(&self) -> Result<(usize, usize, usize), String> {
        if self.peek() != Some('{') {
            return Err(format!("expected '{{' at position {}", self.pos));
        }
        let close = Self::matching_closing_brace(self.src, self.pos)?;
        Ok((self.pos + 1, close, close + 1))
    }

    fn matching_closing_brace(src: &str, open: usize) -> Result<usize, String> {
        let bytes = src.as_bytes();
        let mut pos = open;
        let mut depth = 0usize;
        while pos < bytes.len() {
            match bytes[pos] {
                b'"' | b'\'' => {
                    pos = Self::skip_delimited_literal(src, pos, bytes[pos])
                        .map_err(|e| format!("{e} while scanning brace literal"))?;
                    continue;
                }
                b'/' => {
                    if let Some(next) = Self::skip_regex_literal(src, pos) {
                        pos = next;
                        continue;
                    }
                }
                b'{' => depth += 1,
                b'}' => {
                    depth = depth.saturating_sub(1);
                    if depth == 0 {
                        return Ok(pos);
                    }
                }
                _ => {}
            }
            pos += 1;
        }
        Err(format!(
            "unterminated brace literal starting at position {open}"
        ))
    }

    fn has_top_level_fat_arrow(src: &str) -> bool {
        let bytes = src.as_bytes();
        let mut pos = 0usize;
        let mut paren_depth = 0usize;
        let mut bracket_depth = 0usize;
        let mut brace_depth = 0usize;
        while pos < bytes.len() {
            match bytes[pos] {
                b'"' | b'\'' => match Self::skip_delimited_literal(src, pos, bytes[pos]) {
                    Ok(next) => {
                        pos = next;
                        continue;
                    }
                    Err(_) => return false,
                },
                b'/' => {
                    if let Some(next) = Self::skip_regex_literal(src, pos) {
                        pos = next;
                        continue;
                    }
                }
                b'(' => paren_depth += 1,
                b')' => paren_depth = paren_depth.saturating_sub(1),
                b'[' => bracket_depth += 1,
                b']' => bracket_depth = bracket_depth.saturating_sub(1),
                b'{' => brace_depth += 1,
                b'}' => brace_depth = brace_depth.saturating_sub(1),
                b'=' if pos + 1 < bytes.len()
                    && bytes[pos + 1] == b'>'
                    && paren_depth == 0
                    && bracket_depth == 0
                    && brace_depth == 0 =>
                {
                    return true;
                }
                _ => {}
            }
            pos += 1;
        }
        false
    }

    fn skip_delimited_literal(src: &str, start: usize, delimiter: u8) -> Result<usize, String> {
        let bytes = src.as_bytes();
        let mut pos = start + 1;
        while pos < bytes.len() {
            if bytes[pos] == b'\\' {
                pos += 2;
                continue;
            }
            if bytes[pos] == delimiter {
                return Ok(pos + 1);
            }
            pos += 1;
        }
        Err(format!(
            "unterminated delimited literal starting at position {start}"
        ))
    }

    fn skip_regex_literal(src: &str, start: usize) -> Option<usize> {
        let bytes = src.as_bytes();
        let mut pos = start + 1;
        while pos < bytes.len() {
            if bytes[pos] == b'\\' {
                pos += 2;
                continue;
            }
            if bytes[pos] == b'/' {
                pos += 1;
                while pos < bytes.len() && bytes[pos].is_ascii_alphabetic() {
                    pos += 1;
                }
                return Some(pos);
            }
            pos += 1;
        }
        None
    }

    fn parse_var_or_call(&mut self) -> Result<Expr, String> {
        let name = self.parse_name();
        self.skip_whitespace();

        if self.peek() == Some('(') {
            // Function call
            self.advance(1); // consume '('
            let args = if self.peek() == Some(')') {
                Vec::new()
            } else {
                self.parse_args()?
            };
            if self.peek() != Some(')') {
                return Err(format!("expected ')' after args in call to '{}'", name));
            }
            self.advance(1); // consume ')'

            let expr = Expr::Call { name, args };
            // Parse any fluent chain continuations: .method(args)
            self.parse_fluent_chain(expr)
        } else if self.peek() == Some('[') {
            let segments = self.parse_access_segments(&name)?;
            let has_hash_key = segments
                .iter()
                .any(|segment| matches!(segment, AccessSegment::Key { .. }));
            if segments.len() == 1 && !has_hash_key {
                let AccessSegment::Index { expr } = segments.into_iter().next().unwrap() else {
                    unreachable!("single non-key access segment must be an index");
                };
                let expr = Expr::IndexedVar { name, index: expr };
                return self.parse_fluent_chain(expr);
            }
            let expr = Expr::NestedAccess {
                base: name,
                segments,
            };
            self.parse_fluent_chain(expr)
        } else {
            // Plain variable — check for fluent chain too
            let expr = Expr::Variable { name };
            self.parse_fluent_chain(expr)
        }
    }

    fn parse_access_segments(&mut self, name: &str) -> Result<Vec<AccessSegment>, String> {
        let mut segments = Vec::new();
        while self.peek() == Some('[') {
            self.advance(1); // consume '['
            let expr = self.parse_expr()?;
            self.skip_whitespace();
            if self.peek() != Some(']') {
                return Err(format!("expected ']' after index in '{}[..]'", name));
            }
            self.advance(1); // consume ']'
            let segment = match expr {
                Expr::StringLiteral { value } => AccessSegment::Key { value },
                other => AccessSegment::Index {
                    expr: Box::new(other),
                },
            };
            segments.push(segment);
            self.skip_whitespace();
        }
        Ok(segments)
    }

    /// Parse optional fluent chain continuations: `.method(args).method2(args2)...`
    fn parse_fluent_chain(&mut self, receiver: Expr) -> Result<Expr, String> {
        self.skip_inline_whitespace();
        if self.peek() != Some('.') {
            return Ok(receiver);
        }
        let mut calls: Vec<FluentCall> = Vec::new();
        while self.peek() == Some('.') {
            self.advance(1); // consume '.'
            self.skip_inline_whitespace();
            let method = self.parse_name();
            self.skip_inline_whitespace();
            if self.peek() != Some('(') {
                return Err(format!(
                    "expected '(' after fluent method '{}' at position {}",
                    method, self.pos
                ));
            }
            self.advance(1); // consume '('
            let args = if self.peek() == Some(')') {
                Vec::new()
            } else {
                self.parse_args()?
            };
            if self.peek() != Some(')') {
                return Err(format!(
                    "expected ')' after fluent method '{}' args at position {}",
                    method, self.pos
                ));
            }
            self.advance(1); // consume ')'
            calls.push(FluentCall { method, args });
            self.skip_inline_whitespace();
        }
        Ok(Expr::FluentChain {
            receiver: Box::new(receiver),
            calls,
        })
    }

    fn parse_args(&mut self) -> Result<Vec<Arg>, String> {
        let mut args = Vec::new();
        loop {
            self.skip_whitespace();
            if self.pos >= self.src.len() || self.peek() == Some(')') {
                break;
            }

            // Check for keyword arg: name=expr
            let start = self.pos;
            let maybe_name = self.parse_name();
            self.skip_whitespace();

            if self.peek() == Some('=') {
                self.advance(1); // consume '='
                self.skip_whitespace();
                let value = self.parse_expr()?;
                args.push(Arg::Keyword {
                    name: maybe_name,
                    value: Box::new(value),
                });
            } else {
                // Not a keyword — backtrack and parse as positional expr
                self.pos = start;
                let value = self.parse_expr()?;
                args.push(Arg::Positional(value));
            }

            self.skip_whitespace();
            if self.peek() == Some(',') {
                self.advance(1); // consume ','
            } else {
                break;
            }
        }
        Ok(args)
    }

    fn parse_name(&mut self) -> String {
        self.skip_whitespace();
        let rem = self.remaining();
        let end = rem
            .char_indices()
            .find(|(_, c)| !c.is_alphanumeric() && *c != '_' && *c != ':')
            .map(|(i, _)| i)
            .unwrap_or(rem.len());
        let name = rem[..end].to_string();
        self.advance(end);
        name
    }

    fn parse_string(&mut self) -> Result<Expr, String> {
        let quote = self.peek().unwrap();
        self.advance(1);
        let start = self.pos;
        while self.pos < self.src.len() {
            let ch = self.src.as_bytes()[self.pos];
            if ch == b'\\' {
                self.pos += 2; // skip escaped char
                continue;
            }
            if ch as char == quote {
                let value = self.src[start..self.pos].to_string();
                self.advance(1); // consume closing quote
                return Ok(Expr::StringLiteral { value });
            }
            self.pos += 1;
        }
        Err(format!(
            "unterminated string starting at position {}",
            start
        ))
    }

    fn parse_regex(&mut self) -> Result<Expr, String> {
        self.advance(1); // consume opening '/'
        let start = self.pos;
        while self.pos < self.src.len() {
            let ch = self.src.as_bytes()[self.pos];
            if ch == b'\\' {
                self.pos += 2;
                continue;
            }
            if ch == b'/' {
                let pattern = self.src[start..self.pos].to_string();
                self.advance(1); // consume closing '/'
                // Skip optional regex flags (Perl compatibility: /o, /i, /g, /x, etc.)
                self.skip_whitespace();
                while self.pos < self.src.len() {
                    let c = self.src.as_bytes()[self.pos];
                    if c.is_ascii_alphabetic() {
                        self.advance(1);
                    } else {
                        break;
                    }
                }
                return Ok(Expr::RegexLiteral { pattern });
            }
            self.pos += 1;
        }
        Err("unterminated regex literal".into())
    }

    fn parse_number(&mut self) -> Result<Expr, String> {
        self.skip_whitespace();
        let rem = self.remaining();
        let end = rem
            .char_indices()
            .find(|(_, c)| !c.is_ascii_digit() && *c != '.' && *c != '-')
            .map(|(i, _)| i)
            .unwrap_or(rem.len());
        let num_str = &rem[..end];
        match num_str.parse::<f64>() {
            Ok(value) => {
                self.advance(end);
                Ok(Expr::NumberLiteral { value })
            }
            Err(_) => Err(format!("invalid number: {}", num_str)),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // ── Basic call parsing ──

    #[test]
    fn parse_simple_call() {
        let code = r#"declare(scalar, results)"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 1);
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "declare");
                assert_eq!(args.len(), 2);
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_empty_call() {
        let code = "next()";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "next");
                assert!(args.is_empty());
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_nested_calls() {
        let code = r#"push_value(array(results), scalar(retv))"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "push_value");
                assert_eq!(args.len(), 2);
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_call_with_whitespace_before_parentheses() {
        let code = r#"set (name, cat ("a", "b")); return (scalar (name))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 2);
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "set");
                assert_eq!(args.len(), 2);
                match args[1].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "cat");
                        assert_eq!(args.len(), 2);
                    }
                    _ => panic!("expected nested cat call"),
                }
            }
            _ => panic!("expected set call"),
        }
        match &block.statements[1].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "scalar");
                        assert_eq!(args.len(), 1);
                    }
                    _ => panic!("expected nested scalar call"),
                }
            }
            _ => panic!("expected return call"),
        }
    }

    fn statement_call_names(block: &CodeBlock) -> Vec<&str> {
        block
            .statements
            .iter()
            .map(|stmt| match &stmt.expr {
                Expr::Call { name, .. } => name.as_str(),
                other => panic!("expected call statement, got {other:?}"),
            })
            .collect()
    }

    #[test]
    fn parse_attached_if_blocks_as_statement_controls() {
        let code = r#"if(false) { return("bad") } elseif(true) { set(out, "yes"); return(out) } else { return("no") }"#;
        let block = CodeBlock::parse(code).unwrap();

        assert_eq!(
            statement_call_names(&block),
            vec![
                "if", "return", "elseif", "set", "return", "else", "return", "endif"
            ]
        );
        match &block.statements[0].expr {
            Expr::Call { args, .. } => {
                assert_eq!(args.len(), 1);
                assert!(matches!(
                    args[0].value(),
                    Expr::BooleanLiteral { value: false }
                ));
            }
            other => panic!("expected if call, got {other:?}"),
        }
        match &block.statements[2].expr {
            Expr::Call { args, .. } => {
                assert_eq!(args.len(), 1);
                assert!(matches!(
                    args[0].value(),
                    Expr::BooleanLiteral { value: true }
                ));
            }
            other => panic!("expected elseif call, got {other:?}"),
        }
        match &block.statements[7].expr {
            Expr::Call { args, .. } => assert!(args.is_empty()),
            other => panic!("expected endif call, got {other:?}"),
        }
    }

    #[test]
    fn parse_when_otherwise_aliases_as_canonical_attached_if_else() {
        let code = r#"when(true) { return("yes") } otherwise { return("no") }"#;
        let block = CodeBlock::parse(code).unwrap();

        assert_eq!(
            statement_call_names(&block),
            vec!["if", "return", "else", "return", "endif"]
        );
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "if");
                assert_eq!(args.len(), 1);
                assert!(matches!(
                    args[0].value(),
                    Expr::BooleanLiteral { value: true }
                ));
            }
            other => panic!("expected canonical if call, got {other:?}"),
        }
    }

    #[test]
    fn parse_attached_if_preserves_following_statement_separator_contract() {
        let block =
            CodeBlock::parse(r#"if(true) { set(out, "a") } else { set(out, "b") }; return(out)"#)
                .unwrap();
        assert_eq!(
            statement_call_names(&block),
            vec!["if", "set", "else", "set", "endif", "return"]
        );

        let err =
            CodeBlock::parse(r#"if(true) { set(out, "a") } else { set(out, "b") } return(out)"#)
                .unwrap_err();
        assert!(
            err.contains("expected ';' or newline"),
            "attached if followed by a same-line statement must still need a separator: {err}"
        );
    }

    #[test]
    fn parse_attached_switch_blocks_as_statement_controls() {
        let code = r#"switch(kind) { case("a") { set(out, "a") } case("b") { return("b") } default { return("default") } }"#;
        let block = CodeBlock::parse(code).unwrap();

        assert_eq!(
            statement_call_names(&block),
            vec![
                "switch",
                "case",
                "set",
                "case",
                "return",
                "default",
                "return",
                "endswitch"
            ]
        );
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "switch");
                assert_eq!(args.len(), 1);
                assert!(matches!(args[0].value(), Expr::Variable { name } if name == "kind"));
            }
            other => panic!("expected switch call, got {other:?}"),
        }
        match &block.statements[1].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "case");
                assert_eq!(args.len(), 1);
                assert!(matches!(
                    args[0].value(),
                    Expr::StringLiteral { value } if value == "a"
                ));
            }
            other => panic!("expected case call, got {other:?}"),
        }
        match &block.statements[5].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "default");
                assert!(args.is_empty());
            }
            other => panic!("expected default call, got {other:?}"),
        }
        match &block.statements[7].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "endswitch");
                assert!(args.is_empty());
            }
            other => panic!("expected endswitch call, got {other:?}"),
        }
    }

    #[test]
    fn parse_attached_switch_accepts_default_call_branch() {
        let code = r#"switch(kind) { case("a") { return("a") } default() { return("default") } }"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(
            statement_call_names(&block),
            vec!["switch", "case", "return", "default", "return", "endswitch"]
        );
    }

    #[test]
    fn parse_attached_switch_preserves_inline_switch_value_form() {
        let code = r#"return(switch(kind, case("a", "A"), default("D")))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(statement_call_names(&block), vec!["return"]);

        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "switch");
                        assert_eq!(args.len(), 3);
                    }
                    other => panic!("expected inline switch expression, got {other:?}"),
                }
            }
            other => panic!("expected return call, got {other:?}"),
        }
    }

    #[test]
    fn parse_attached_switch_preserves_following_statement_separator_contract() {
        let block =
            CodeBlock::parse(r#"switch(kind) { case("a") { set(out, "a") } default { set(out, "d") } }; return(out)"#)
                .unwrap();
        assert_eq!(
            statement_call_names(&block),
            vec![
                "switch",
                "case",
                "set",
                "default",
                "set",
                "endswitch",
                "return"
            ]
        );

        let err = CodeBlock::parse(
            r#"switch(kind) { case("a") { set(out, "a") } default { set(out, "d") } } return(out)"#,
        )
        .unwrap_err();
        assert!(
            err.contains("expected ';' or newline"),
            "attached switch followed by a same-line statement must still need a separator: {err}"
        );
    }

    #[test]
    fn parse_attached_while_block_as_lazy_statement_loop() {
        let code = r#"set(count, 0); while(num_lt(scalar(count), 3)) { set(count, num_add(scalar(count), 1)) }; return(count)"#;
        let block = CodeBlock::parse(code).unwrap();

        assert_eq!(statement_call_names(&block), vec!["set", "while", "return"]);
        match &block.statements[1].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "while");
                assert_eq!(args.len(), 2);
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "num_lt");
                        assert_eq!(args.len(), 2);
                    }
                    other => panic!("expected while condition call, got {other:?}"),
                }
                match args[1].value() {
                    Expr::BlockValue { block } => {
                        assert_eq!(statement_call_names(block), vec!["set"]);
                    }
                    other => panic!("expected attached while body block, got {other:?}"),
                }
            }
            other => panic!("expected while call, got {other:?}"),
        }
    }

    #[test]
    fn parse_attached_while_preserves_following_statement_separator_contract() {
        let block =
            CodeBlock::parse(r#"while(false) { set(out, "bad") }; return("done")"#).unwrap();
        assert_eq!(statement_call_names(&block), vec!["while", "return"]);

        let err =
            CodeBlock::parse(r#"while(false) { set(out, "bad") } return("done")"#).unwrap_err();
        assert!(
            err.contains("expected ';' or newline"),
            "attached while followed by a same-line statement must still need a separator: {err}"
        );
    }

    #[test]
    fn parse_no_paren_helper_keyword_is_not_single_call() {
        let code = r#"return cat("a", "b")"#;
        let err = CodeBlock::parse(code).unwrap_err();
        assert!(
            err.contains("expected ';' or newline"),
            "bare `return cat(...)` must be rejected, not parsed as return(cat(...)): {err}"
        );
    }

    #[test]
    fn parse_keyword_arg() {
        let code = r#"declare(scalar, name=entry_group(1))"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "declare");
                assert_eq!(args.len(), 2);
                match &args[1] {
                    Arg::Keyword { name, .. } => assert_eq!(name, "name"),
                    _ => panic!("expected keyword arg"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_scalar_assignment_statement() {
        let code = r#"name = cat("o", "k"); return(scalar(name))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 2);
        match &block.statements[0].expr {
            Expr::AssignScalar { name, value } => {
                assert_eq!(name, "name");
                match value.as_ref() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "cat");
                        assert_eq!(args.len(), 2);
                    }
                    _ => panic!("expected call RHS"),
                }
            }
            _ => panic!("expected scalar assignment"),
        }
    }

    #[test]
    fn parse_array_append_statement() {
        let code = r#"items += cat("a", "b"); return(array_copy(array(items)))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 2);
        match &block.statements[0].expr {
            Expr::AssignArrayAppend { name, value } => {
                assert_eq!(name, "items");
                match value.as_ref() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "cat");
                        assert_eq!(args.len(), 2);
                    }
                    _ => panic!("expected call RHS"),
                }
            }
            _ => panic!("expected array append"),
        }
    }

    #[test]
    fn parse_hash_index_assignment_statement() {
        let code = r#"meta[cat("s", "tage")] = scalar(value); return(hash_copy(hash(meta)))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 2);
        match &block.statements[0].expr {
            Expr::AssignHashIndex { name, key, value } => {
                assert_eq!(name, "meta");
                match key.as_ref() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "cat");
                        assert_eq!(args.len(), 2);
                    }
                    _ => panic!("expected call key"),
                }
                match value.as_ref() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "scalar");
                        assert_eq!(args.len(), 1);
                    }
                    _ => panic!("expected scalar RHS"),
                }
            }
            _ => panic!("expected hash-index assignment"),
        }
    }

    #[test]
    fn parse_keyword_arg_is_not_scalar_assignment() {
        let code = r#"declare(scalar, name=entry_group(1))"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { args, .. } => match &args[1] {
                Arg::Keyword { name, .. } => assert_eq!(name, "name"),
                _ => panic!("expected keyword arg"),
            },
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_scalar_assignment_is_statement_only_and_narrow() {
        assert!(
            CodeBlock::parse(r#"name == "ok""#).is_err(),
            "equality-like spelling is not parsed as assignment"
        );
        assert!(
            CodeBlock::parse(r#"items ++"#).is_err(),
            "increment-like spelling is not parsed as array append"
        );
    }

    #[test]
    fn parse_scalar_bare_reads_in_mutation_slots() {
        let code = r#"items += value; meta[key] = value"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 2);
        match &block.statements[0].expr {
            Expr::AssignArrayAppend { name, value } => {
                assert_eq!(name, "items");
                assert!(matches!(value.as_ref(), Expr::Variable { name } if name == "value"));
            }
            _ => panic!("expected array append"),
        }
        match &block.statements[1].expr {
            Expr::AssignHashIndex { name, key, value } => {
                assert_eq!(name, "meta");
                assert!(matches!(key.as_ref(), Expr::Variable { name } if name == "key"));
                assert!(matches!(value.as_ref(), Expr::Variable { name } if name == "value"));
            }
            _ => panic!("expected hash-index assignment"),
        }
    }

    #[test]
    fn parse_array_shape_literal_value_expr() {
        let code = r#"return([value, cat("a", "b"), true, []])"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::ArrayLiteral { items } => {
                        assert_eq!(items.len(), 4);
                        assert!(matches!(&items[0], Expr::Variable { name } if name == "value"));
                        assert!(matches!(&items[1], Expr::Call { name, .. } if name == "cat"));
                        assert!(matches!(&items[2], Expr::BooleanLiteral { value: true }));
                        assert!(
                            matches!(&items[3], Expr::ArrayLiteral { items } if items.is_empty())
                        );
                    }
                    other => panic!("expected ArrayLiteral, got {:?}", other),
                }
            }
            _ => panic!("expected return call"),
        }
    }

    #[test]
    fn parse_hash_shape_literal_value_expr() {
        let code = r#"return({ key => value, "fixed" => [value] })"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::HashLiteral { entries } => {
                        assert_eq!(entries.len(), 2);
                        assert!(
                            matches!(&entries[0].key, Expr::Variable { name } if name == "key")
                        );
                        assert!(
                            matches!(&entries[0].value, Expr::Variable { name } if name == "value")
                        );
                        assert!(
                            matches!(&entries[1].key, Expr::StringLiteral { value } if value == "fixed")
                        );
                        assert!(
                            matches!(&entries[1].value, Expr::ArrayLiteral { items } if items.len() == 1)
                        );
                    }
                    other => panic!("expected HashLiteral, got {:?}", other),
                }
            }
            _ => panic!("expected return call"),
        }
    }

    #[test]
    fn parse_shape_literals_in_mutation_slots() {
        let code = r#"items += [value]; meta[key] = { key => value }"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 2);
        match &block.statements[0].expr {
            Expr::AssignArrayAppend { name, value } => {
                assert_eq!(name, "items");
                assert!(matches!(value.as_ref(), Expr::ArrayLiteral { items } if items.len() == 1));
            }
            other => panic!("expected array append, got {:?}", other),
        }
        match &block.statements[1].expr {
            Expr::AssignHashIndex { name, key, value } => {
                assert_eq!(name, "meta");
                assert!(matches!(key.as_ref(), Expr::Variable { name } if name == "key"));
                assert!(
                    matches!(value.as_ref(), Expr::HashLiteral { entries } if entries.len() == 1)
                );
            }
            other => panic!("expected hash-index assignment, got {:?}", other),
        }
    }

    #[test]
    fn parse_shape_literal_rhs_keeps_scalar_assignment_ast_until_target_inference_leaf() {
        let code = r#"name = [value]; set(out, { key => value })"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 2);
        match &block.statements[0].expr {
            Expr::AssignScalar { name, value } => {
                assert_eq!(name, "name");
                assert!(matches!(value.as_ref(), Expr::ArrayLiteral { items } if items.len() == 1));
            }
            other => panic!("expected scalar assignment, got {:?}", other),
        }
        match &block.statements[1].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "set");
                assert_eq!(args.len(), 2);
                assert!(matches!(args[0].value(), Expr::Variable { name } if name == "out"));
                assert!(
                    matches!(args[1].value(), Expr::HashLiteral { entries } if entries.len() == 1)
                );
            }
            other => panic!("expected set call, got {:?}", other),
        }
    }

    #[test]
    fn parse_expression_valued_block_return_payload() {
        let code = r#"return({ set(x, "a"); x })"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::BlockValue { block } => {
                        assert_eq!(block.statements.len(), 2);
                        assert!(
                            matches!(&block.statements[0].expr, Expr::Call { name, .. } if name == "set")
                        );
                        assert!(
                            matches!(&block.statements[1].expr, Expr::Variable { name } if name == "x")
                        );
                    }
                    other => panic!("expected BlockValue, got {:?}", other),
                }
            }
            other => panic!("expected return call, got {:?}", other),
        }
    }

    #[test]
    fn parse_expression_valued_block_preserves_nested_final_hash_literal() {
        let code = r#"return(array({ set(key, "stage"); set(value, "ok"); { key => value } }))"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "array");
                        match args[0].value() {
                            Expr::BlockValue { block } => {
                                assert_eq!(block.statements.len(), 3);
                                assert!(
                                    matches!(&block.statements[2].expr, Expr::HashLiteral { entries } if entries.len() == 1)
                                );
                            }
                            other => panic!("expected nested BlockValue, got {:?}", other),
                        }
                    }
                    other => panic!("expected array call, got {:?}", other),
                }
            }
            other => panic!("expected return call, got {:?}", other),
        }
    }

    #[test]
    fn parse_deeply_nested_5_levels() {
        // 5+ levels: return → array → array_copy → array → scalar
        let code = r#"return(array("?results:", array_copy(array(results))))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 1);
        // Verify the nesting depth is correct
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                assert_eq!(args.len(), 1);
                match args[0].value() {
                    Expr::Call { name, args: a2 } => {
                        assert_eq!(name, "array");
                        assert_eq!(a2.len(), 2);
                        match a2[1].value() {
                            Expr::Call { name, args: a3 } => {
                                assert_eq!(name, "array_copy");
                                assert_eq!(a3.len(), 1);
                                match a3[0].value() {
                                    Expr::Call { name, args: a4 } => {
                                        assert_eq!(name, "array");
                                        assert_eq!(a4.len(), 1);
                                        match a4[0].value() {
                                            Expr::Variable { name } => {
                                                assert_eq!(name, "results");
                                            }
                                            _ => panic!("expected Variable at depth 5"),
                                        }
                                    }
                                    _ => panic!("expected Call at depth 4"),
                                }
                            }
                            _ => panic!("expected Call at depth 3"),
                        }
                    }
                    _ => panic!("expected Call at depth 2"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_multiple_statements() {
        let code = r#"declare(array, results); push_value(array(results), scalar(retv)); return(array_copy(array(results)))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 3);
    }

    // ── Literal parsing ──

    #[test]
    fn parse_undef() {
        let code = "return(undef)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                assert_eq!(args.len(), 1);
                match args[0].value() {
                    Expr::Undef => {}
                    _ => panic!("expected Undef"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_undef_not_prefix_match() {
        // "undefine" should NOT be parsed as undef
        let code = "return(undefine)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => {
                assert_eq!(args.len(), 1);
                match args[0].value() {
                    Expr::Variable { name } => assert_eq!(name, "undefine"),
                    _ => panic!("expected Variable for 'undefine'"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_number_literal() {
        let code = "return(42)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::NumberLiteral { value } => assert_eq!(*value, 42.0),
                    _ => panic!("expected NumberLiteral"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_negative_number() {
        let code = "return(-1)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => match args[0].value() {
                Expr::NumberLiteral { value } => assert_eq!(*value, -1.0),
                _ => panic!("expected NumberLiteral"),
            },
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_float_number() {
        let code = "return(3.14)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => match args[0].value() {
                Expr::NumberLiteral { value } => assert!((*value - 3.14).abs() < 0.001),
                _ => panic!("expected NumberLiteral"),
            },
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_string_literal_double_quotes() {
        let code = r#"return("?results:")"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::StringLiteral { value } => assert_eq!(value, "?results:"),
                    _ => panic!("expected StringLiteral"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_string_literal_single_quotes() {
        let code = "return('hello world')";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => match args[0].value() {
                Expr::StringLiteral { value } => assert_eq!(value, "hello world"),
                _ => panic!("expected StringLiteral"),
            },
            _ => panic!("expected Call"),
        }
    }

    // ── Boolean literals ──

    #[test]
    fn parse_boolean_true() {
        let code = "assign(scalar(flag), true)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "assign");
                match args[1].value() {
                    Expr::BooleanLiteral { value } => assert!(*value),
                    _ => panic!("expected BooleanLiteral true"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_boolean_false() {
        let code = "return(false)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => match args[0].value() {
                Expr::BooleanLiteral { value } => assert!(!*value),
                _ => panic!("expected BooleanLiteral false"),
            },
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_boolean_true_not_prefix_match() {
        // "trueword" should NOT be parsed as true
        let code = "return(trueword)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => match args[0].value() {
                Expr::Variable { name } => assert_eq!(name, "trueword"),
                _ => panic!("expected Variable for 'trueword'"),
            },
            _ => panic!("expected Call"),
        }
    }

    // ── Variable parsing ──

    #[test]
    fn parse_simple_variable() {
        let code = "results";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Variable { name } => assert_eq!(name, "results"),
            _ => panic!("expected Variable"),
        }
    }

    #[test]
    fn parse_dollar_variable() {
        let code = "return($CAPTURE)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => match args[0].value() {
                Expr::Variable { name } => assert_eq!(name, "CAPTURE"),
                _ => panic!("expected Variable"),
            },
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_indexed_variable() {
        let code = "return(results[0])";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => match args[0].value() {
                Expr::IndexedVar { name, index } => {
                    assert_eq!(name, "results");
                    match index.as_ref() {
                        Expr::NumberLiteral { value } => assert_eq!(*value, 0.0),
                        _ => panic!("expected NumberLiteral index"),
                    }
                }
                _ => panic!("expected IndexedVar"),
            },
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_direct_nested_access_explicit_segments() {
        let code = r#"return(foo["a"][9]["b"][scalar(z)])"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => match args[0].value() {
                Expr::NestedAccess { base, segments } => {
                    assert_eq!(base, "foo");
                    assert_eq!(segments.len(), 4);
                    assert!(
                        matches!(segments[0], AccessSegment::Key { ref value } if value == "a")
                    );
                    assert!(matches!(segments[1], AccessSegment::Index { .. }));
                    assert!(
                        matches!(segments[2], AccessSegment::Key { ref value } if value == "b")
                    );
                    assert!(matches!(segments[3], AccessSegment::Index { .. }));
                }
                other => panic!("expected NestedAccess, got {:?}", other),
            },
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_direct_nested_access_accepts_bare_segments() {
        let block = CodeBlock::parse(r#"return(foo["a"][z])"#).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => match args[0].value() {
                Expr::NestedAccess { base, segments } => {
                    assert_eq!(base, "foo");
                    assert_eq!(segments.len(), 2);
                    assert!(
                        matches!(segments[0], AccessSegment::Key { ref value } if value == "a")
                    );
                    match &segments[1] {
                        AccessSegment::Index { expr } => {
                            assert!(
                                matches!(expr.as_ref(), Expr::Variable { name } if name == "z")
                            );
                        }
                        _ => panic!("expected scalar-index segment"),
                    }
                }
                other => panic!("expected NestedAccess, got {:?}", other),
            },
            _ => panic!("expected Call"),
        }
    }

    // ── Fluent chain parsing ──

    #[test]
    fn parse_fluent_chain_single_dot() {
        let code = r#"assign(scalar(name), entry_text()).return(scalar(name))"#;
        let block = CodeBlock::parse(code).unwrap();
        // First statement should be: assign(...).return(...)
        let first = &block.statements[0].expr;
        match first {
            Expr::FluentChain { receiver, calls } => {
                // Receiver is assign(scalar(name), entry_text())
                match receiver.as_ref() {
                    Expr::Call { name, .. } => assert_eq!(name, "assign"),
                    _ => panic!("expected Call receiver"),
                }
                assert_eq!(calls.len(), 1);
                assert_eq!(calls[0].method, "return");
                assert_eq!(calls[0].args.len(), 1);
            }
            _ => panic!("expected FluentChain, got {:?}", first),
        }
    }

    #[test]
    fn parse_fluent_chain_multiple_dots() {
        let code =
            "push_value(array(items), scalar(retv)).return(array_copy(array(items))).endif()";
        let block = CodeBlock::parse(code).unwrap();
        let first = &block.statements[0].expr;
        match first {
            Expr::FluentChain { receiver, calls } => {
                match receiver.as_ref() {
                    Expr::Call { name, .. } => assert_eq!(name, "push_value"),
                    _ => panic!("expected Call receiver"),
                }
                assert_eq!(calls.len(), 2);
                assert_eq!(calls[0].method, "return");
                assert_eq!(calls[1].method, "endif");
                assert!(calls[1].args.is_empty());
            }
            _ => panic!("expected FluentChain, got {:?}", first),
        }
    }

    #[test]
    fn parse_fluent_chain_on_variable() {
        // Variable with fluent chain (used for I.declare(...) style)
        let code = "results.push_value(scalar(new))";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                match receiver.as_ref() {
                    Expr::Variable { name } => assert_eq!(name, "results"),
                    _ => panic!("expected Variable receiver"),
                }
                assert_eq!(calls.len(), 1);
                assert_eq!(calls[0].method, "push_value");
            }
            _ => panic!("expected FluentChain"),
        }
    }

    #[test]
    fn parse_array_end_mutation_fluent_receivers() {
        let block = CodeBlock::parse(
            "items.push_back(value); array(items).pop_front(); a(items).push_front(\"a\")",
        )
        .unwrap();
        assert_eq!(block.statements.len(), 3);

        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(matches!(receiver.as_ref(), Expr::Variable { name } if name == "items"));
                assert_eq!(calls.len(), 1);
                assert_eq!(calls[0].method, "push_back");
                assert_eq!(calls[0].args.len(), 1);
            }
            other => panic!("expected bare receiver FluentChain, got {:?}", other),
        }

        match &block.statements[1].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(matches!(receiver.as_ref(), Expr::Call { name, .. } if name == "array"));
                assert_eq!(calls.len(), 1);
                assert_eq!(calls[0].method, "pop_front");
                assert!(calls[0].args.is_empty());
            }
            other => panic!("expected array receiver FluentChain, got {:?}", other),
        }

        match &block.statements[2].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(matches!(receiver.as_ref(), Expr::Call { name, .. } if name == "a"));
                assert_eq!(calls.len(), 1);
                assert_eq!(calls[0].method, "push_front");
            }
            other => panic!("expected a receiver FluentChain, got {:?}", other),
        }
    }

    #[test]
    fn parse_array_receiver_value_chain() {
        let block = CodeBlock::parse("items.sorted().drop_front(2).first()").unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(matches!(receiver.as_ref(), Expr::Variable { name } if name == "items"));
                let methods: Vec<&str> = calls.iter().map(|call| call.method.as_str()).collect();
                assert_eq!(methods, vec!["sorted", "drop_front", "first"]);
                assert_eq!(calls[1].args.len(), 1);
            }
            other => panic!("expected array receiver value FluentChain, got {:?}", other),
        }
    }

    #[test]
    fn parse_hash_receiver_value_chain() {
        let block = CodeBlock::parse(r#"meta.set_key("stage", "v").sorted_keys().count()"#).unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(matches!(receiver.as_ref(), Expr::Variable { name } if name == "meta"));
                let methods: Vec<&str> = calls.iter().map(|call| call.method.as_str()).collect();
                assert_eq!(methods, vec!["set_key", "sorted_keys", "count"]);
                assert_eq!(calls[0].args.len(), 2);
            }
            other => panic!("expected hash receiver value FluentChain, got {:?}", other),
        }
    }

    #[test]
    fn parse_fluent_chain_on_indexed_var() {
        let code = "results[0].return()";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                match receiver.as_ref() {
                    Expr::IndexedVar { name, .. } => assert_eq!(name, "results"),
                    _ => panic!("expected IndexedVar receiver"),
                }
                assert_eq!(calls.len(), 1);
                assert_eq!(calls[0].method, "return");
            }
            _ => panic!("expected FluentChain"),
        }
    }

    // ── Round-trip tests (Display → Parse produces equivalent AST) ──

    /// Helper: parse code, display it, parse again, verify both ASTs are equal.
    fn assert_roundtrip(code: &str) {
        let block1 = CodeBlock::parse(code)
            .unwrap_or_else(|e| panic!("first parse failed for '{code}': {e}"));
        let displayed = block1
            .statements
            .iter()
            .map(|s| s.expr.to_string())
            .collect::<Vec<_>>()
            .join("; ");
        let block2 = CodeBlock::parse(&displayed)
            .unwrap_or_else(|e| panic!("second parse failed for '{displayed}': {e}"));
        assert_eq!(
            block1.statements.len(),
            block2.statements.len(),
            "statement count mismatch: '{code}' → '{displayed}'"
        );
        for (i, (s1, s2)) in block1
            .statements
            .iter()
            .zip(block2.statements.iter())
            .enumerate()
        {
            assert_eq!(
                s1.expr, s2.expr,
                "statement {i} mismatch: '{code}' → '{displayed}'\n  left: {:?}\n  right: {:?}",
                s1.expr, s2.expr
            );
        }
    }

    #[test]
    fn roundtrip_simple_call() {
        assert_roundtrip("declare(scalar, results)");
    }

    #[test]
    fn roundtrip_nested_calls() {
        assert_roundtrip("push_value(array(results), scalar(retv))");
    }

    #[test]
    fn roundtrip_keyword_arg() {
        assert_roundtrip("declare(scalar, name=entry_group(1))");
    }

    #[test]
    fn roundtrip_deeply_nested() {
        assert_roundtrip(r#"return(array("?results:", array_copy(array(results))))"#);
    }

    #[test]
    fn roundtrip_undef() {
        assert_roundtrip("return(undef)");
    }

    #[test]
    fn roundtrip_number() {
        assert_roundtrip("return(42)");
    }

    #[test]
    fn roundtrip_negative_number() {
        assert_roundtrip("return(-1)");
    }

    #[test]
    fn roundtrip_float() {
        assert_roundtrip("return(3.14)");
    }

    #[test]
    fn roundtrip_boolean_true() {
        assert_roundtrip("assign(scalar(flag), true)");
    }

    #[test]
    fn roundtrip_boolean_false() {
        assert_roundtrip("return(false)");
    }

    #[test]
    fn roundtrip_string_double_quotes() {
        assert_roundtrip(r#"return("?results:")"#);
    }

    #[test]
    fn roundtrip_string_single_quotes() {
        assert_roundtrip("return('hello world')");
    }

    #[test]
    fn roundtrip_empty_call() {
        assert_roundtrip("next()");
    }

    #[test]
    fn roundtrip_variable() {
        assert_roundtrip("results");
    }

    #[test]
    fn roundtrip_dollar_variable() {
        // $-prefixed variables display without the $, so roundtrip is lossy ($CAPTURE → CAPTURE)
        // This is acceptable — the $ is a compatibility sigil, not semantically significant.
        let code = "return($CAPTURE)";
        let block = CodeBlock::parse(code).unwrap();
        let displayed = block.statements[0].expr.to_string();
        // Re-parse works fine because CAPTURE is a valid variable name
        let block2 = CodeBlock::parse(&displayed).unwrap();
        assert_eq!(block2.statements.len(), 1);
    }

    #[test]
    fn roundtrip_indexed_variable() {
        assert_roundtrip("results[0]");
    }

    #[test]
    fn roundtrip_shape_literals() {
        assert_roundtrip(r#"return([value, cat("a", "b"), true, []])"#);
        assert_roundtrip(r#"return({ key => value, "fixed" => [value] })"#);
    }

    #[test]
    fn roundtrip_expression_valued_block() {
        assert_roundtrip(r#"return({set(x, "a"); x})"#);
        assert_roundtrip(r#"return(array({set(key, "stage"); set(value, "ok"); {key => value}}))"#);
    }

    #[test]
    fn roundtrip_fluent_chain() {
        let code = "assign(scalar(name), entry_text()).return(scalar(name))";
        let block1 = CodeBlock::parse(code).unwrap();
        let displayed = block1.statements[0].expr.to_string();
        let block2 = CodeBlock::parse(&displayed).unwrap();
        assert_eq!(block1.statements.len(), block2.statements.len());
        // Verify the structure is equivalent
        match &block2.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                match receiver.as_ref() {
                    Expr::Call { name, .. } => assert_eq!(name, "assign"),
                    _ => panic!("expected Call receiver"),
                }
                assert_eq!(calls.len(), 1);
                assert_eq!(calls[0].method, "return");
            }
            _ => panic!("expected FluentChain after roundtrip"),
        }
    }

    #[test]
    fn roundtrip_fluent_chain_multi() {
        let code =
            "push_value(array(items), scalar(retv)).return(array_copy(array(items))).endif()";
        let block1 = CodeBlock::parse(code).unwrap();
        let displayed = block1.statements[0].expr.to_string();
        let block2 = CodeBlock::parse(&displayed).unwrap();
        match &block2.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                match receiver.as_ref() {
                    Expr::Call { name, .. } => assert_eq!(name, "push_value"),
                    _ => panic!("expected Call receiver"),
                }
                assert_eq!(calls.len(), 2);
                assert_eq!(calls[0].method, "return");
                assert_eq!(calls[1].method, "endif");
            }
            _ => panic!("expected FluentChain after roundtrip"),
        }
    }

    // ── Error cases ──

    #[test]
    fn error_unterminated_string() {
        let result = CodeBlock::parse(r#"return("hello)"#);
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("unterminated string"));
    }

    #[test]
    fn error_unterminated_regex() {
        let result = CodeBlock::parse("return(/pattern)");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("unterminated regex"));
    }

    #[test]
    fn error_missing_close_paren() {
        let result = CodeBlock::parse("declare(scalar, results");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("expected ')'"));
    }

    #[test]
    fn error_unexpected_character() {
        let result = CodeBlock::parse("return(@invalid)");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("unexpected character"));
    }

    #[test]
    fn error_fluent_chain_missing_paren() {
        let result = CodeBlock::parse("results.return");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("expected '('"));
    }

    // ── Semicolon handling ──

    #[test]
    fn parse_newline_separated_statements_without_semicolons() {
        // Newlines are the implicit separator for method-only statements.
        let code = r#"declare(array, results)
push_value(array(results), scalar(retv))
return(array_copy(array(results)))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 3);
    }

    #[test]
    fn parse_statements_with_semicolons() {
        let code = r#"declare(array, results);
push_value(array(results), scalar(retv));
return(array_copy(array(results)));"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 3);
    }

    #[test]
    fn parse_same_line_statements_require_semicolons() {
        let result =
            CodeBlock::parse("declare(array, results) push_value(array(results), scalar(retv))");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("expected ';' or newline"));
    }

    // ── Regex literal ──

    #[test]
    fn parse_regex_literal() {
        let code = "return(/[A-Za-z_]+/)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::RegexLiteral { pattern } => assert_eq!(pattern, "[A-Za-z_]+"),
                    _ => panic!("expected RegexLiteral"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    // ── serde roundtrip ──

    #[test]
    fn serde_roundtrip_codeblock() {
        let code = r#"push_value(array(results), scalar(retv))"#;
        let block = CodeBlock::parse(code).unwrap();
        let json = serde_json::to_string(&block).unwrap();
        let _back: CodeBlock = serde_json::from_str(&json).unwrap();
    }

    #[test]
    fn serde_roundtrip_fluent_chain() {
        let code = "assign(scalar(name), entry_text()).return(scalar(name))";
        let block = CodeBlock::parse(code).unwrap();
        let json = serde_json::to_string(&block).unwrap();
        let back: CodeBlock = serde_json::from_str(&json).unwrap();
        assert_eq!(block.statements.len(), back.statements.len());
    }
}
