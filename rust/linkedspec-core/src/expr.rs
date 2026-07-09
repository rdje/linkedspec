//! Expression AST for lifecycle code — parsed from code strings like
//! `push(array(results), retv)` and interpreted at runtime.
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
//! scalar_assignment → name '=' expr      (scalar expression; statement-compatible)
//! array_append → name '+=' expr          (array mutation expression; statement-compatible)
//! hash_index_assignment → name '[' expr ']' '=' expr  (hash mutation expression; statement-compatible)
//! expr        → primary ('.' method_call)*
//! primary     → call | nested_access | indexed_var | literal | block | grouped | variable
//! call        → name '(' args? ')' trailing_block? | symbol '(' args? ')'
//! trailing_block → '{' stmts '}'          (helper-form `with(...)`, receiver `.with()`, and tree traversal receiver methods)
//! method_call → name '(' args? ')' trailing_block?
//! args        → arg (',' arg)*
//! arg         → expr | name '=' expr       (keyword argument only for keyword-aware callees)
//! literal     → string | number | boolean | regex | undef | array | hash
//! grouped     → '(' expr ')'
//! array       → '[' (expr (',' expr)*)? ']'
//! hash        → '{' (expr ':' expr (',' expr ':' expr)*)? '}'
//! block       → '{' stmt+ '}'              (non-empty, no top-level hash-pair separator)
//! string      → '"' [^"]* '"' | "'" [^']* "'"
//! number      → -?\d+(\.\d+)?
//! boolean     → 'true' | 'false'
//! undef       → 'undef'
//! variable    → '$'? name                  (bare word variable reference)
//! indexed_var → variable '[' expr ']'      (single-level array index access)
//! nested_access → variable ('[' expr ']')+ (mixed hash/array path access)
//! regex       → '/' [^/]* '/'
//! name        → [a-zA-Z_]\w*
//! symbol      → '+' | '-' | '*' | '/' | '%' | '=' | '==' | '!=' | '>' | '>=' | '<' | '<='
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
    /// Array index segment from a numeric or explicit expression: `foo[0]`, `foo[i]`
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
    /// A helper function call: `push(array(results), retv)`
    #[serde(rename = "call")]
    Call { name: String, args: Vec<Arg> },
    /// A scalar assignment operator: `name = value`
    #[serde(rename = "assign_scalar")]
    AssignScalar { name: String, value: Box<Expr> },
    /// An array append operator: `items += value`
    #[serde(rename = "assign_array_append")]
    AssignArrayAppend { name: String, value: Box<Expr> },
    /// A hash-index assignment operator: `meta["key"] = value`
    #[serde(rename = "assign_hash_index")]
    AssignHashIndex {
        name: String,
        key: Box<Expr>,
        value: Box<Expr>,
    },
    /// A nested value-path assignment operator: `payload["items"][0]["name"] = value`
    #[serde(rename = "assign_nested_access")]
    AssignNestedAccess {
        base: String,
        segments: Vec<AccessSegment>,
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
    /// A direct hash shape literal: `{ key : value }`
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
    /// A fluent method chain: `push(...).return(...).endif()`
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

fn fluent_call_prints_trailing_block(call: &FluentCall) -> bool {
    matches!(
        call.method.as_str(),
        "with" | "walk_leaves" | "map_leaves" | "reduce_leaves"
    )
}

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
            Expr::AssignNestedAccess {
                base,
                segments,
                value,
            } => {
                write!(f, "{base}")?;
                for segment in segments {
                    match segment {
                        AccessSegment::Key { value } => write!(f, "[\"{value}\"]")?,
                        AccessSegment::Index { expr } => write!(f, "[{expr}]")?,
                    }
                }
                write!(f, " = {value}")
            }
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
                    write!(f, "{} : {}", entry.key, entry.value)?;
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
                    if fluent_call_prints_trailing_block(call)
                        && matches!(
                            call.args.last(),
                            Some(Arg::Positional(Expr::BlockValue { .. }))
                        )
                    {
                        write!(f, ".{}(", call.method)?;
                        for (i, arg) in call.args[..call.args.len() - 1].iter().enumerate() {
                            if i > 0 {
                                write!(f, ", ")?;
                            }
                            match arg {
                                Arg::Positional(e) => write!(f, "{e}")?,
                                Arg::Keyword { name, value } => write!(f, "{name}={value}")?,
                            }
                        }
                        write!(f, ") {}", call.args.last().unwrap().value())?;
                        continue;
                    }
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

        let segments = self.parse_access_segments(&name)?;
        if segments.is_empty() {
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
        if segments.len() == 1 {
            let key = match segments.into_iter().next().unwrap() {
                AccessSegment::Key { value } => Expr::StringLiteral { value },
                AccessSegment::Index { expr } => *expr,
            };
            return Ok(Some(Expr::AssignHashIndex {
                name,
                key: Box::new(key),
                value: Box::new(value),
            }));
        }
        Ok(Some(Expr::AssignNestedAccess {
            base: name,
            segments,
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

        let assignment_start = self.pos;
        if matches!(self.peek(), Some(ch) if ch.is_ascii_alphabetic() || ch == '_') {
            if let Some(expr) = self.try_parse_hash_index_assignment_statement()? {
                return self.parse_fluent_chain(expr);
            }
            self.pos = assignment_start;
            if let Some(expr) = self.try_parse_array_append_statement()? {
                return self.parse_fluent_chain(expr);
            }
            self.pos = assignment_start;
            if let Some(expr) = self.try_parse_scalar_assignment_statement()? {
                return self.parse_fluent_chain(expr);
            }
            self.pos = assignment_start;
        }

        let ch = self.peek().unwrap();

        match ch {
            '"' | '\'' => {
                let expr = self.parse_string()?;
                self.parse_fluent_chain(expr)
            }
            '+' | '*' | '%' | '=' | '!' | '>' | '<' => {
                if self.is_symbol_call_at_current() {
                    self.parse_symbol_call()
                } else {
                    Err(self.unexpected_character_error(ch))
                }
            }
            '/' => {
                if self.is_symbol_call_at_current() {
                    self.parse_symbol_call()
                } else {
                    self.parse_regex()
                }
            }
            '[' => {
                let expr = self.parse_array_literal()?;
                self.parse_fluent_chain(expr)
            }
            ':' => self.parse_retired_colon_scalar_slot(),
            '{' => {
                let expr = self.parse_brace_expr()?;
                self.parse_fluent_chain(expr)
            }
            '(' => self.parse_parenthesized_expr(),
            '$' => {
                self.advance(1);
                self.parse_var_or_call()
            }
            '0'..='9' | '-' => {
                // Look ahead: if '-' followed by digit, it's a negative number
                if ch == '-' {
                    let after = self.src[self.pos + 1..].chars().next();
                    if after.is_some_and(|c| c.is_ascii_digit()) {
                        let expr = self.parse_number()?;
                        return self.parse_fluent_chain(expr);
                    }
                    if self.is_symbol_call_at_current() {
                        return self.parse_symbol_call();
                    }
                }
                if ch == '-' {
                    // Bare '-' without digits — treat as variable
                    self.advance(1);
                    self.parse_var_or_call()
                } else {
                    let expr = self.parse_number()?;
                    self.parse_fluent_chain(expr)
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
            _ => Err(self.unexpected_character_error(ch)),
        }
    }

    fn unexpected_character_error(&self, ch: char) -> String {
        let end = (self.pos + 40).min(self.src.len());
        format!(
            "unexpected character '{}' at position {} near: '{}'",
            ch,
            self.pos,
            &self.src[self.pos..end]
        )
    }

    fn is_symbol_call_at_current(&self) -> bool {
        self.symbol_call_token_at_current().is_some()
    }

    fn symbol_call_token_at_current(&self) -> Option<&'static str> {
        let token = [
            "==", "!=", ">=", "<=", "=", "+", "-", "*", "/", "%", ">", "<",
        ]
        .into_iter()
        .find(|candidate| self.remaining().starts_with(candidate))?;

        let mut cursor = self.pos + token.len();
        while cursor < self.src.len() && self.src.as_bytes()[cursor].is_ascii_whitespace() {
            cursor += 1;
        }
        if self.src.as_bytes().get(cursor) != Some(&b'(') {
            return None;
        }
        self.symbol_call_paren_has_expression_boundary(cursor)
            .then_some(token)
    }

    fn symbol_call_paren_has_expression_boundary(&self, open_idx: usize) -> bool {
        let bytes = self.src.as_bytes();
        let mut depth = 0usize;
        let mut in_single_quote = false;
        let mut in_double_quote = false;
        let mut escape_next = false;

        let mut pos = open_idx;
        while pos < bytes.len() {
            let byte = bytes[pos];

            if in_single_quote {
                if escape_next {
                    escape_next = false;
                } else if byte == b'\\' {
                    escape_next = true;
                } else if byte == b'\'' {
                    in_single_quote = false;
                }
                pos += 1;
                continue;
            }
            if in_double_quote {
                if escape_next {
                    escape_next = false;
                } else if byte == b'\\' {
                    escape_next = true;
                } else if byte == b'"' {
                    in_double_quote = false;
                }
                pos += 1;
                continue;
            }

            match byte {
                b'\'' => in_single_quote = true,
                b'"' => in_double_quote = true,
                b'\\' => {
                    pos += 2;
                    continue;
                }
                b'(' => depth += 1,
                b')' => {
                    depth = depth.saturating_sub(1);
                    if depth == 0 {
                        let mut after = pos + 1;
                        while after < bytes.len() && bytes[after].is_ascii_whitespace() {
                            after += 1;
                        }
                        return after >= bytes.len()
                            || matches!(bytes[after], b',' | b';' | b'.' | b')' | b']');
                    }
                }
                _ => {}
            }
            pos += 1;
        }

        false
    }

    fn parse_symbol_call(&mut self) -> Result<Expr, String> {
        let name = self
            .symbol_call_token_at_current()
            .ok_or_else(|| format!("expected symbol call at position {}", self.pos))?
            .to_string();
        self.advance(name.len());
        self.skip_whitespace();
        if self.peek() != Some('(') {
            return Err(format!(
                "expected '(' after symbol '{}' at position {}",
                name, self.pos
            ));
        }
        self.advance(1);
        let args = if self.peek() == Some(')') {
            Vec::new()
        } else {
            self.parse_args_for_callee(&name)?
        };
        if self.peek() != Some(')') {
            return Err(format!("expected ')' after args in symbol call '{}'", name));
        }
        self.advance(1);

        self.parse_fluent_chain(Expr::Call { name, args })
    }

    fn parse_parenthesized_expr(&mut self) -> Result<Expr, String> {
        self.advance(1); // consume '('
        self.skip_whitespace();
        let expr = self.parse_expr()?;
        self.skip_whitespace();
        if self.peek() != Some(')') {
            return Err("expected ')' after parenthesized expression".into());
        }
        self.advance(1);
        self.parse_fluent_chain(expr)
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
            if self.remaining().starts_with("=>") {
                return Err(format!(
                    "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon: retired '=>' hash-literal separator at position {}; use ':' as in '{{ key : value }}'",
                    self.pos
                ));
            }
            let Some(separator_len) = Self::hash_pair_separator_at(self.remaining()) else {
                return Err(format!(
                    "expected ':' in hash literal at position {}",
                    self.pos
                ));
            };
            self.advance(separator_len);
            self.skip_whitespace();
            if self.pos >= self.src.len() || self.peek() == Some('}') {
                return Err(format!(
                    "expected value after hash pair separator in hash literal at position {}",
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

        if payload.trim().is_empty() || Self::has_top_level_hash_pair_separator(payload) {
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

    fn hash_pair_separator_at(src: &str) -> Option<usize> {
        if src.starts_with(':') && !src.starts_with("::") {
            return Some(1);
        }
        None
    }

    fn has_top_level_hash_pair_separator(src: &str) -> bool {
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
                b':' if !(pos + 1 < bytes.len() && bytes[pos + 1] == b':')
                    && !(pos > 0 && bytes[pos - 1] == b':')
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
                self.parse_args_for_callee(&name)?
            };
            if self.peek() != Some(')') {
                return Err(format!("expected ')' after args in call to '{}'", name));
            }
            self.advance(1); // consume ')'

            let expr = self.parse_optional_trailing_block_arg(name, args)?;
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

    fn parse_retired_colon_scalar_slot(&mut self) -> Result<Expr, String> {
        let colon_pos = self.pos;
        self.advance(1);
        let start = self.pos;
        if let Some(first) = self.peek()
            && (first.is_ascii_alphabetic() || first == '_')
        {
            while let Some(ch) = self.peek() {
                if ch.is_ascii_alphanumeric() || ch == '_' {
                    self.advance(ch.len_utf8());
                } else {
                    break;
                }
            }
            let name = &self.src[start..self.pos];
            return Err(format!(
                "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read: retired ':{name}' scalar-slot syntax at position {colon_pos}; use bare '{name}'"
            ));
        }
        Err(format!(
            "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read: retired colon-prefixed scalar-slot syntax at position {colon_pos}; use bare variable reads"
        ))
    }

    fn parse_optional_trailing_block_arg(
        &mut self,
        name: String,
        mut args: Vec<Arg>,
    ) -> Result<Expr, String> {
        if name != "with" {
            return Ok(Expr::Call { name, args });
        }

        let before_whitespace = self.pos;
        self.skip_whitespace();
        if self.peek() != Some('{') {
            self.pos = before_whitespace;
            return Ok(Expr::Call { name, args });
        }

        let block = self.parse_attached_branch_block("with")?;
        args.push(Arg::Positional(Expr::BlockValue { block }));
        Ok(Expr::Call { name, args })
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
                self.parse_args_for_callee(&method)?
            };
            if self.peek() != Some(')') {
                return Err(format!(
                    "expected ')' after fluent method '{}' args at position {}",
                    method, self.pos
                ));
            }
            self.advance(1); // consume ')'
            let args = self.parse_optional_fluent_trailing_block_arg(&method, args)?;
            calls.push(FluentCall { method, args });
            self.skip_inline_whitespace();
        }
        Ok(Expr::FluentChain {
            receiver: Box::new(receiver),
            calls,
        })
    }

    fn parse_optional_fluent_trailing_block_arg(
        &mut self,
        method: &str,
        mut args: Vec<Arg>,
    ) -> Result<Vec<Arg>, String> {
        if !Self::method_allows_fluent_trailing_block(method) {
            return Ok(args);
        }

        let before_whitespace = self.pos;
        self.skip_whitespace();
        if self.peek() != Some('{') {
            self.pos = before_whitespace;
            return Ok(args);
        }
        match method {
            "with" | "walk_leaves" | "map_leaves" => {
                if !args.is_empty() {
                    return Err(format!(
                        "receiver .{method}() trailing block expects no parenthesized arguments at position {}",
                        before_whitespace
                    ));
                }
            }
            "reduce_leaves" => {
                if args.len() != 1 {
                    return Err(format!(
                        "LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:reduce_leaves: receiver .reduce_leaves(initial) trailing block expects exactly one parenthesized accumulator argument at position {}",
                        before_whitespace
                    ));
                }
            }
            _ => unreachable!("method_allows_fluent_trailing_block checked"),
        }

        let block = self.parse_attached_branch_block(method)?;
        args.push(Arg::Positional(Expr::BlockValue { block }));
        Ok(args)
    }

    fn method_allows_fluent_trailing_block(method: &str) -> bool {
        matches!(
            method,
            "with" | "walk_leaves" | "map_leaves" | "reduce_leaves"
        )
    }

    fn parse_args_for_callee(&mut self, _callee: &str) -> Result<Vec<Arg>, String> {
        let mut args = Vec::new();
        loop {
            self.skip_whitespace();
            if self.pos >= self.src.len() || self.peek() == Some(')') {
                break;
            }

            let value = self.parse_expr()?;
            args.push(Arg::Positional(value));

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
        let mut end = 0;
        let mut chars = rem.char_indices().peekable();
        if matches!(chars.peek(), Some((_, '-'))) {
            if let Some((idx, ch)) = chars.next() {
                end = idx + ch.len_utf8();
            }
        }
        let mut saw_digit = false;
        while let Some((idx, ch)) = chars.peek().copied() {
            if ch.is_ascii_digit() {
                saw_digit = true;
                chars.next();
                end = idx + ch.len_utf8();
            } else {
                break;
            }
        }
        if matches!(chars.peek(), Some((_, '.'))) {
            let mut lookahead = chars.clone();
            lookahead.next();
            if matches!(lookahead.peek(), Some((_, ch)) if ch.is_ascii_digit()) {
                if let Some((idx, ch)) = chars.next() {
                    end = idx + ch.len_utf8();
                }
                while let Some((idx, ch)) = chars.peek().copied() {
                    if ch.is_ascii_digit() {
                        saw_digit = true;
                        chars.next();
                        end = idx + ch.len_utf8();
                    } else {
                        break;
                    }
                }
            }
        }
        if !saw_digit {
            return Err("invalid number".into());
        }
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
        let code = r#"set(array(results), [])"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 1);
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "set");
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
        let code = r#"push(array(results), retv)"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "push");
                assert_eq!(args.len(), 2);
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_call_with_whitespace_before_parentheses() {
        let code = r#"set (name, cat ("a", "b")); return (name)"#;
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
                    Expr::Variable { name } => assert_eq!(name, "name"),
                    _ => panic!("expected bare variable read"),
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
        let code = r#"set(count, 0); while(num_lt(count, 3)) { set(count, num_add(count, 1)) }; return(count)"#;
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
    fn parse_with_helper_trailing_block_as_final_block_argument() {
        let block = CodeBlock::parse(r#"return(with("x") { return(cat(value, "!")) })"#).unwrap();

        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                assert_eq!(args.len(), 1);
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "with");
                        assert_eq!(args.len(), 2);
                        assert!(
                            matches!(args[0].value(), Expr::StringLiteral { value } if value == "x")
                        );
                        match args[1].value() {
                            Expr::BlockValue { block } => {
                                assert_eq!(statement_call_names(block), vec!["return"]);
                            }
                            other => panic!("expected trailing with block, got {other:?}"),
                        }
                    }
                    other => panic!("expected with call payload, got {other:?}"),
                }
            }
            other => panic!("expected return call, got {other:?}"),
        }
    }

    #[test]
    fn parse_with_helper_trailing_block_preserves_hash_literal_boundary() {
        let block =
            CodeBlock::parse(r#"return(with("ok") { return({ "stage" : value }) })"#).unwrap();

        let Expr::Call { args, .. } = &block.statements[0].expr else {
            panic!("expected return call");
        };
        let Expr::Call {
            name: with_name,
            args: with_args,
        } = args[0].value()
        else {
            panic!("expected with call");
        };
        assert_eq!(with_name, "with");
        let Expr::BlockValue { block } = with_args[1].value() else {
            panic!("expected trailing block argument");
        };
        let Expr::Call { name, args } = &block.statements[0].expr else {
            panic!("expected return call inside with block");
        };
        assert_eq!(name, "return");
        assert!(matches!(args[0].value(), Expr::HashLiteral { entries } if entries.len() == 1));
    }

    #[test]
    fn parse_receiver_with_trailing_block_as_fluent_call() {
        let block =
            CodeBlock::parse(r#"return("x".with() { return(cat(value, "!")) }.trim())"#).unwrap();

        let Expr::Call { name, args } = &block.statements[0].expr else {
            panic!("expected return call");
        };
        assert_eq!(name, "return");
        let Expr::FluentChain { receiver, calls } = args[0].value() else {
            panic!("expected receiver with fluent chain");
        };
        assert!(matches!(receiver.as_ref(), Expr::StringLiteral { value } if value == "x"));
        assert_eq!(calls.len(), 2);
        assert_eq!(calls[0].method, "with");
        assert_eq!(calls[0].args.len(), 1);
        assert!(matches!(calls[0].args[0].value(), Expr::BlockValue { .. }));
        assert_eq!(calls[1].method, "trim");
        assert!(calls[1].args.is_empty());
    }

    #[test]
    fn parse_receiver_with_trailing_block_rejects_explicit_value_arg() {
        let err = CodeBlock::parse(r#"return("x".with("bad") { return(value) })"#).unwrap_err();
        assert!(
            err.contains("receiver .with() trailing block expects no parenthesized arguments"),
            "receiver .with(value) must stay outside the .14.4 surface: {err}"
        );
    }

    #[test]
    fn parse_tree_traversal_receiver_trailing_blocks_as_fluent_calls() {
        let block = CodeBlock::parse(
            r#"return(meta.map_leaves() { return(cat(key, "=", value)) }.count_keys())"#,
        )
        .unwrap();
        let Expr::Call { name, args } = &block.statements[0].expr else {
            panic!("expected return call");
        };
        assert_eq!(name, "return");
        let Expr::FluentChain { receiver, calls } = args[0].value() else {
            panic!("expected hash-tree fluent chain");
        };
        assert!(matches!(receiver.as_ref(), Expr::Variable { name } if name == "meta"));
        assert_eq!(calls.len(), 2);
        assert_eq!(calls[0].method, "map_leaves");
        assert_eq!(calls[0].args.len(), 1);
        assert!(matches!(calls[0].args[0].value(), Expr::BlockValue { .. }));
        assert_eq!(calls[1].method, "count_keys");

        let array_block = CodeBlock::parse(
            r#"return(items.map_leaves() { return(cat(index, "=", value)) }.count())"#,
        )
        .unwrap();
        let Expr::Call { args, .. } = &array_block.statements[0].expr else {
            panic!("expected return call");
        };
        let Expr::FluentChain { receiver, calls } = args[0].value() else {
            panic!("expected array-tree fluent chain");
        };
        assert!(matches!(receiver.as_ref(), Expr::Variable { name } if name == "items"));
        assert_eq!(calls.len(), 2);
        assert_eq!(calls[0].method, "map_leaves");
        assert_eq!(calls[0].args.len(), 1);
        assert!(matches!(calls[0].args[0].value(), Expr::BlockValue { .. }));
        assert_eq!(calls[1].method, "count");

        let reducer =
            CodeBlock::parse(r#"return(meta.reduce_leaves("") { return(cat(acc, key)) })"#)
                .unwrap();
        let Expr::Call { args, .. } = &reducer.statements[0].expr else {
            panic!("expected return call");
        };
        let Expr::FluentChain { calls, .. } = args[0].value() else {
            panic!("expected reduce_leaves fluent chain");
        };
        assert_eq!(calls.len(), 1);
        assert_eq!(calls[0].method, "reduce_leaves");
        assert_eq!(calls[0].args.len(), 2);
        assert!(
            matches!(calls[0].args[0].value(), Expr::StringLiteral { value } if value.is_empty())
        );
        assert!(matches!(calls[0].args[1].value(), Expr::BlockValue { .. }));
    }

    #[test]
    fn parse_tree_traversal_receiver_trailing_blocks_reject_wrong_arity() {
        let err =
            CodeBlock::parse(r#"return(meta.map_leaves("bad") { return(value) })"#).unwrap_err();
        assert!(
            err.contains(
                "receiver .map_leaves() trailing block expects no parenthesized arguments"
            ),
            "map_leaves must take only its trailing block: {err}"
        );

        let err = CodeBlock::parse(r#"return(meta.reduce_leaves() { return(acc) })"#).unwrap_err();
        assert!(
            err.contains("LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:reduce_leaves")
                && err.contains(".reduce_leaves(initial)"),
            "reduce_leaves trailing block requires an initial accumulator: {err}"
        );
    }

    #[test]
    fn parse_non_with_helper_does_not_accept_trailing_block_argument() {
        let err = CodeBlock::parse(r#"return(cat("x") { return("bad") })"#).unwrap_err();
        assert!(
            err.contains("expected ')' after args in call to 'return'"),
            "only the owned helper-form with(...) trailing block should parse in .14.3: {err}"
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
    fn parse_scalar_assignment_statement() {
        let code = r#"name = cat("o", "k"); return(name)"#;
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
        let code = r#"items += cat("a", "b"); return(copy(array(items)))"#;
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
        let code = r#"meta[cat("s", "tage")] = value; return(copy(hash(meta)))"#;
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
                    Expr::Variable { name } => assert_eq!(name, "value"),
                    _ => panic!("expected bare variable RHS"),
                }
            }
            _ => panic!("expected hash-index assignment"),
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
    fn parse_retired_colon_scalar_slot_reports_bare_read_migration() {
        let err = CodeBlock::parse(r#"set(:payload, [value]); return(:payload)"#)
            .expect_err("retired colon scalar slot must not parse");
        assert!(err.contains("colon_scalar_slot_use_bare_read"));
        assert!(err.contains("retired ':payload' scalar-slot syntax"));
        assert!(err.contains("use bare 'payload'"));
    }

    #[test]
    fn parse_hash_shape_literal_value_expr() {
        let code = r#"return({ key : value, "fixed" : [value] })"#;
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
    fn parse_colon_hash_shape_literal_value_expr() {
        let code = r#"return({ key : value, "fixed" : [value], "outer" : { "nested" : value } })"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::HashLiteral { entries } => {
                        assert_eq!(entries.len(), 3);
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
                        assert!(
                            matches!(&entries[2].key, Expr::StringLiteral { value } if value == "outer")
                        );
                        match &entries[2].value {
                            Expr::HashLiteral { entries } => {
                                assert_eq!(entries.len(), 1);
                                assert!(
                                    matches!(&entries[0].key, Expr::StringLiteral { value } if value == "nested")
                                );
                                assert!(
                                    matches!(&entries[0].value, Expr::Variable { name } if name == "value")
                                );
                            }
                            other => panic!("expected nested HashLiteral, got {:?}", other),
                        }
                    }
                    other => panic!("expected HashLiteral, got {:?}", other),
                }
            }
            _ => panic!("expected return call"),
        }
    }

    #[test]
    fn parse_retired_hash_literal_fat_arrow_reports_colon_migration() {
        let code = r#"return({ old => value, current : value })"#;
        let err = CodeBlock::parse(code).expect_err("old hash-literal fat arrow must not parse");
        assert!(err.contains("LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon"));
        assert!(err.contains("retired '=>' hash-literal separator"));
        assert!(err.contains("use ':'"));
    }

    #[test]
    fn parse_shape_literals_in_mutation_slots() {
        let code = r#"items += [value]; meta[key] = { key : value }"#;
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
    fn parse_colon_shape_literals_in_assignment_and_mutation_slots() {
        let code = r#"name = { key : value }; meta[key] = { "inner" : value }; set(out, { key : value }); return(=(other, { key : value }))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 4);
        match &block.statements[0].expr {
            Expr::AssignScalar { name, value } => {
                assert_eq!(name, "name");
                assert!(
                    matches!(value.as_ref(), Expr::HashLiteral { entries } if entries.len() == 1)
                );
            }
            other => panic!("expected scalar assignment, got {:?}", other),
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
        match &block.statements[2].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "set");
                assert!(
                    matches!(args[1].value(), Expr::HashLiteral { entries } if entries.len() == 1)
                );
            }
            other => panic!("expected set call, got {:?}", other),
        }
        match &block.statements[3].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                assert!(
                    matches!(args[0].value(), Expr::Call { name, args } if name == "=" && matches!(args[1].value(), Expr::HashLiteral { entries } if entries.len() == 1))
                );
            }
            other => panic!("expected return call, got {:?}", other),
        }
    }

    #[test]
    fn parse_shape_literal_rhs_keeps_scalar_assignment_ast_until_target_inference_leaf() {
        let code = r#"name = [value]; set(out, { key : value })"#;
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
    fn top_level_hash_pair_separator_scanner_skips_nested_and_namespace_colons() {
        assert!(Parser::has_top_level_hash_pair_separator("key : value"));
        assert!(Parser::has_top_level_hash_pair_separator("old => value"));
        assert!(!Parser::has_top_level_hash_pair_separator("JSON::PP"));
        assert!(!Parser::has_top_level_hash_pair_separator(
            r#""literal:colon""#
        ));
        assert!(!Parser::has_top_level_hash_pair_separator(
            "call(key : value)"
        ));
        assert!(!Parser::has_top_level_hash_pair_separator(
            r#"{ "nested" : value }"#
        ));
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
        let code = r#"return(array({ set(key, "stage"); set(value, "ok"); { key : value } }))"#;
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
        // 5+ levels: return → array → copy → array → scalar
        let code = r#"return(array("?results:", copy(array(results))))"#;
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
                                assert_eq!(name, "copy");
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
        let code =
            r#"set(array(results), []); push(array(results), retv); return(copy(array(results)))"#;
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
        let code = "flag = true";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::AssignScalar { name, value } => {
                assert_eq!(name, "flag");
                match value.as_ref() {
                    Expr::BooleanLiteral { value } => assert!(*value),
                    _ => panic!("expected BooleanLiteral true"),
                }
            }
            _ => panic!("expected scalar assignment"),
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
        let code = r#"return(foo["a"][9]["b"][z])"#;
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

    #[test]
    fn parse_general_brace_expression_as_block_value() {
        let block = CodeBlock::parse(r#"return({content})"#).unwrap();
        match &block.statements[0].expr {
            Expr::Call { args, .. } => match args[0].value() {
                Expr::BlockValue { block } => {
                    assert_eq!(block.statements.len(), 1);
                    assert!(
                        matches!(&block.statements[0].expr, Expr::Variable { name } if name == "content")
                    );
                }
                other => panic!("expected BlockValue, got {:?}", other),
            },
            _ => panic!("expected return call"),
        }
    }

    // ── Fluent chain parsing ──

    #[test]
    fn parse_fluent_chain_single_dot() {
        let code = r#"set(name, entry_text()).return(name)"#;
        let block = CodeBlock::parse(code).unwrap();
        // First statement should be: set(...).return(...)
        let first = &block.statements[0].expr;
        match first {
            Expr::FluentChain { receiver, calls } => {
                // Receiver is set(name, entry_text())
                match receiver.as_ref() {
                    Expr::Call { name, .. } => assert_eq!(name, "set"),
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
        let code = "push(array(items), retv).return(copy(array(items))).endif()";
        let block = CodeBlock::parse(code).unwrap();
        let first = &block.statements[0].expr;
        match first {
            Expr::FluentChain { receiver, calls } => {
                match receiver.as_ref() {
                    Expr::Call { name, .. } => assert_eq!(name, "push"),
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
        // Variable with fluent chain.
        let code = "results.push(new)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                match receiver.as_ref() {
                    Expr::Variable { name } => assert_eq!(name, "results"),
                    _ => panic!("expected Variable receiver"),
                }
                assert_eq!(calls.len(), 1);
                assert_eq!(calls[0].method, "push");
            }
            _ => panic!("expected FluentChain"),
        }
    }

    #[test]
    fn parse_array_end_mutation_fluent_receivers() {
        let block = CodeBlock::parse(
            "items.push_back(value); array(items).pop_front(); array(items).push_front(\"a\")",
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
                assert!(matches!(receiver.as_ref(), Expr::Call { name, .. } if name == "array"));
                assert_eq!(calls.len(), 1);
                assert_eq!(calls[0].method, "push_front");
            }
            other => panic!("expected array receiver FluentChain, got {:?}", other),
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
    fn parse_block_valued_receiver_chain() {
        let block = CodeBlock::parse(r#"{ ["b", "a"] }.sorted().join_values(",")"#).unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(matches!(receiver.as_ref(), Expr::BlockValue { .. }));
                let methods: Vec<&str> = calls.iter().map(|call| call.method.as_str()).collect();
                assert_eq!(methods, vec!["sorted", "join_values"]);
                assert_eq!(calls[1].args.len(), 1);
            }
            other => panic!(
                "expected block-valued receiver FluentChain, got {:?}",
                other
            ),
        }
    }

    #[test]
    fn parse_hash_receiver_value_chain() {
        let block =
            CodeBlock::parse(r#"meta.set_key("stage", "v").sorted_keys().count()"#).unwrap();
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
    fn parse_string_receiver_value_chain() {
        let block =
            CodeBlock::parse(r#"raw.trim().lowercase().split("-").filter_nonempty().count()"#)
                .unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(matches!(receiver.as_ref(), Expr::Variable { name } if name == "raw"));
                let methods: Vec<&str> = calls.iter().map(|call| call.method.as_str()).collect();
                assert_eq!(
                    methods,
                    vec!["trim", "lowercase", "split", "filter_nonempty", "count"]
                );
                assert_eq!(calls[2].args.len(), 1);
            }
            other => panic!(
                "expected string receiver value FluentChain, got {:?}",
                other
            ),
        }
    }

    #[test]
    fn parse_string_literal_receiver_value_chain() {
        let block = CodeBlock::parse(r#"" raw ".trim().uppercase()"#).unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(
                    matches!(receiver.as_ref(), Expr::StringLiteral { value } if value == " raw ")
                );
                let methods: Vec<&str> = calls.iter().map(|call| call.method.as_str()).collect();
                assert_eq!(methods, vec!["trim", "uppercase"]);
            }
            other => panic!(
                "expected string literal receiver value FluentChain, got {:?}",
                other
            ),
        }
    }

    #[test]
    fn parse_number_receiver_value_chain() {
        let block = CodeBlock::parse(r#"5.add(2, 3).mul(4).gt(39)"#).unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(
                    matches!(receiver.as_ref(), Expr::NumberLiteral { value } if (*value - 5.0).abs() < 0.001)
                );
                let methods: Vec<&str> = calls.iter().map(|call| call.method.as_str()).collect();
                assert_eq!(methods, vec!["add", "mul", "gt"]);
                assert_eq!(calls[0].args.len(), 2);
            }
            other => panic!(
                "expected number receiver value FluentChain, got {:?}",
                other
            ),
        }
    }

    #[test]
    fn parse_decimal_number_receiver_value_chain() {
        let block = CodeBlock::parse(r#"3.5.floor().add(1)"#).unwrap();
        match &block.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                assert!(
                    matches!(receiver.as_ref(), Expr::NumberLiteral { value } if (*value - 3.5).abs() < 0.001)
                );
                let methods: Vec<&str> = calls.iter().map(|call| call.method.as_str()).collect();
                assert_eq!(methods, vec!["floor", "add"]);
            }
            other => panic!(
                "expected decimal number receiver value FluentChain, got {:?}",
                other
            ),
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
        assert_roundtrip("set(array(results), [])");
    }

    #[test]
    fn roundtrip_nested_calls() {
        assert_roundtrip("push(array(results), retv)");
    }

    #[test]
    fn roundtrip_current_assignment_call() {
        assert_roundtrip("set(name, entry_group(1))");
    }

    #[test]
    fn roundtrip_deeply_nested() {
        assert_roundtrip(r#"return(array("?results:", copy(array(results))))"#);
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
        assert_roundtrip("flag = true");
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
        assert_roundtrip(r#"return({ key : value, "fixed" : [value] })"#);
    }

    #[test]
    fn roundtrip_expression_valued_block() {
        assert_roundtrip(r#"return({set(x, "a"); x})"#);
        assert_roundtrip(r#"return(array({set(key, "stage"); set(value, "ok"); {key : value}}))"#);
    }

    #[test]
    fn roundtrip_fluent_chain() {
        let code = "set(name, entry_text()).return(name)";
        let block1 = CodeBlock::parse(code).unwrap();
        let displayed = block1.statements[0].expr.to_string();
        let block2 = CodeBlock::parse(&displayed).unwrap();
        assert_eq!(block1.statements.len(), block2.statements.len());
        // Verify the structure is equivalent
        match &block2.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                match receiver.as_ref() {
                    Expr::Call { name, .. } => assert_eq!(name, "set"),
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
        let code = "push(array(items), retv).return(copy(array(items))).endif()";
        let block1 = CodeBlock::parse(code).unwrap();
        let displayed = block1.statements[0].expr.to_string();
        let block2 = CodeBlock::parse(&displayed).unwrap();
        match &block2.statements[0].expr {
            Expr::FluentChain { receiver, calls } => {
                match receiver.as_ref() {
                    Expr::Call { name, .. } => assert_eq!(name, "push"),
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
        let result = CodeBlock::parse(r#"cat("a", "b""#);
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
        let code = r#"set(array(results), [])
push(array(results), retv)
return(copy(array(results)))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 3);
    }

    #[test]
    fn parse_statements_with_semicolons() {
        let code = r#"set(array(results), []);
push(array(results), retv);
return(copy(array(results)));"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 3);
    }

    #[test]
    fn parse_same_line_statements_require_semicolons() {
        let result = CodeBlock::parse("set(array(results), []) push(array(results), retv)");
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

    #[test]
    fn parse_arithmetic_symbol_callees() {
        let code = r#"return(array(+(2,3,4), -(10,3), *(2,3,4), /(9,2), %(17,5), +(2, *(3,4))))"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "array");
                        let names: Vec<&str> = args
                            .iter()
                            .map(|arg| match arg.value() {
                                Expr::Call { name, .. } => name.as_str(),
                                other => panic!("expected symbol call, got {other:?}"),
                            })
                            .collect();
                        assert_eq!(names, vec!["+", "-", "*", "/", "%", "+"]);
                        match args[5].value() {
                            Expr::Call { args, .. } => {
                                assert!(
                                    matches!(args[1].value(), Expr::Call { name, .. } if name == "*")
                                );
                            }
                            other => panic!("expected nested addition call, got {other:?}"),
                        }
                    }
                    other => panic!("expected array call, got {other:?}"),
                }
            }
            other => panic!("expected return call, got {other:?}"),
        }
    }

    #[test]
    fn parse_comparison_symbol_callees() {
        let code = r#"return(array(==(2,2), !=(2,3), >(10,2), >=(2,2), <(2,10), <=(2,2)))"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "array");
                        let names: Vec<&str> = args
                            .iter()
                            .map(|arg| match arg.value() {
                                Expr::Call { name, .. } => name.as_str(),
                                other => panic!("expected comparison symbol call, got {other:?}"),
                            })
                            .collect();
                        assert_eq!(names, vec!["==", "!=", ">", ">=", "<", "<="]);
                    }
                    other => panic!("expected array call, got {other:?}"),
                }
            }
            other => panic!("expected return call, got {other:?}"),
        }
    }

    #[test]
    fn parse_single_equals_symbol_callee_as_assignment_operator_call() {
        let block = CodeBlock::parse("return(=(target, value))").unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "=");
                        assert_eq!(args.len(), 2);
                    }
                    other => panic!("expected assignment operator call, got {other:?}"),
                }
            }
            other => panic!("expected return call, got {other:?}"),
        }
    }

    #[test]
    fn parse_scalar_assignment_value_expression_in_args() {
        let code = r#"return(array(name = "ok", set(out, other = name), =(again, out), =(items, [name]), items += value, meta[key] = value))"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "array");
                        match args[0].value() {
                            Expr::AssignScalar { name, .. } => assert_eq!(name, "name"),
                            other => panic!("expected scalar assignment arg, got {other:?}"),
                        }
                        match args[1].value() {
                            Expr::Call { name, args } => {
                                assert_eq!(name, "set");
                                match args[1].value() {
                                    Expr::AssignScalar { name, .. } => assert_eq!(name, "other"),
                                    other => {
                                        panic!("expected nested scalar assignment, got {other:?}")
                                    }
                                }
                            }
                            other => panic!("expected set call, got {other:?}"),
                        }
                        match args[2].value() {
                            Expr::Call { name, .. } => assert_eq!(name, "="),
                            other => panic!("expected assignment operator call, got {other:?}"),
                        }
                        match args[3].value() {
                            Expr::Call { name, args } => {
                                assert_eq!(name, "=");
                                assert!(
                                    matches!(args[1].value(), Expr::ArrayLiteral { items } if items.len() == 1)
                                );
                            }
                            other => {
                                panic!("expected aggregate assignment operator call, got {other:?}")
                            }
                        }
                        match args[4].value() {
                            Expr::AssignArrayAppend { name, value } => {
                                assert_eq!(name, "items");
                                assert!(
                                    matches!(value.as_ref(), Expr::Variable { name } if name == "value")
                                );
                            }
                            other => panic!("expected array append assignment, got {other:?}"),
                        }
                        match args[5].value() {
                            Expr::AssignHashIndex { name, key, value } => {
                                assert_eq!(name, "meta");
                                assert!(
                                    matches!(key.as_ref(), Expr::Variable { name } if name == "key")
                                );
                                assert!(
                                    matches!(value.as_ref(), Expr::Variable { name } if name == "value")
                                );
                            }
                            other => panic!("expected hash-index assignment, got {other:?}"),
                        }
                    }
                    other => panic!("expected array call, got {other:?}"),
                }
            }
            other => panic!("expected return call, got {other:?}"),
        }
    }

    #[test]
    fn parse_parenthesized_mutation_assignment_receiver_chains() {
        let code = r#"return(array((items += value).count(), (meta[key] = value).count_keys()))"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::Call { name, args } => {
                        assert_eq!(name, "array");
                        match args[0].value() {
                            Expr::FluentChain { receiver, calls } => {
                                assert!(matches!(
                                    receiver.as_ref(),
                                    Expr::AssignArrayAppend { name, .. } if name == "items"
                                ));
                                assert_eq!(calls[0].method, "count");
                            }
                            other => panic!("expected array append receiver chain, got {other:?}"),
                        }
                        match args[1].value() {
                            Expr::FluentChain { receiver, calls } => {
                                assert!(matches!(
                                    receiver.as_ref(),
                                    Expr::AssignHashIndex { name, .. } if name == "meta"
                                ));
                                assert_eq!(calls[0].method, "count_keys");
                            }
                            other => panic!("expected hash-index receiver chain, got {other:?}"),
                        }
                    }
                    other => panic!("expected array call, got {other:?}"),
                }
            }
            other => panic!("expected return call, got {other:?}"),
        }
    }

    #[test]
    fn parse_parenthesized_regex_literal_stays_regex() {
        let code = r#"return(/(\d+)/)"#;
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name, args } => {
                assert_eq!(name, "return");
                match args[0].value() {
                    Expr::RegexLiteral { pattern } => assert_eq!(pattern, r"(\d+)"),
                    other => panic!("expected RegexLiteral, got {other:?}"),
                }
            }
            other => panic!("expected return call, got {other:?}"),
        }
    }

    // ── serde roundtrip ──

    #[test]
    fn serde_roundtrip_codeblock() {
        let code = r#"push(array(results), retv)"#;
        let block = CodeBlock::parse(code).unwrap();
        let json = serde_json::to_string(&block).unwrap();
        let _back: CodeBlock = serde_json::from_str(&json).unwrap();
    }

    #[test]
    fn serde_roundtrip_fluent_chain() {
        let code = "set(name, entry_text()).return(name)";
        let block = CodeBlock::parse(code).unwrap();
        let json = serde_json::to_string(&block).unwrap();
        let back: CodeBlock = serde_json::from_str(&json).unwrap();
        assert_eq!(block.statements.len(), back.statements.len());
    }
}
