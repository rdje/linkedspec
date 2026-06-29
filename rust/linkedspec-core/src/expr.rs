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
//! stmt        → hash_index_assignment | array_append | scalar_assignment | expr ';'?
//! scalar_assignment → name '=' expr      (statement only)
//! array_append → name '+=' expr          (statement only)
//! hash_index_assignment → name '[' expr ']' '=' expr  (statement only)
//! expr        → primary ('.' method_call)*
//! primary     → call | indexed_var | literal | variable
//! call        → name '(' args? ')'
//! method_call → name '(' args? ')'
//! args        → arg (',' arg)*
//! arg         → expr | name '=' expr       (keyword argument)
//! literal     → string | number | boolean | regex | undef
//! string      → '"' [^"]* '"' | "'" [^']* "'"
//! number      → -?\d+(\.\d+)?
//! boolean     → 'true' | 'false'
//! undef       → 'undef'
//! variable    → '$'? name                  (bare word variable reference)
//! indexed_var → variable '[' expr ']'      (array/hash index access)
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

/// An expression — the core of the lifecycle code language.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(tag = "kind")]
pub enum Expr {
    /// A helper function call: `push_value(array(results), scalar(retv))`
    #[serde(rename = "call")]
    Call {
        name: String,
        args: Vec<Arg>,
    },
    /// A statement-only scalar assignment operator: `name = value`
    #[serde(rename = "assign_scalar")]
    AssignScalar {
        name: String,
        value: Box<Expr>,
    },
    /// A statement-only array append operator: `items += value`
    #[serde(rename = "assign_array_append")]
    AssignArrayAppend {
        name: String,
        value: Box<Expr>,
    },
    /// A statement-only hash-index assignment operator: `meta["key"] = value`
    #[serde(rename = "assign_hash_index")]
    AssignHashIndex {
        name: String,
        key: Box<Expr>,
        value: Box<Expr>,
    },
    /// A variable reference: `results`, `retv`, `$name`
    #[serde(rename = "variable")]
    Variable {
        name: String,
    },
    /// An indexed variable access: `results[0]`, `$hash{"key"}`
    #[serde(rename = "indexed_var")]
    IndexedVar {
        name: String,
        index: Box<Expr>,
    },
    /// A string literal: `"hello"`, `'world'`
    #[serde(rename = "string")]
    StringLiteral {
        value: String,
    },
    /// A numeric literal: `42`, `0`, `3.14`
    #[serde(rename = "number")]
    NumberLiteral {
        value: f64,
    },
    /// A boolean literal: `true`, `false`
    #[serde(rename = "boolean")]
    BooleanLiteral {
        value: bool,
    },
    /// A regex literal: `/pattern/`
    #[serde(rename = "regex")]
    RegexLiteral {
        pattern: String,
    },
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
    Keyword {
        name: String,
        value: Box<Expr>,
    },
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
                    if i > 0 { write!(f, ", ")?; }
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
                        if i > 0 { write!(f, ", ")?; }
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
            let expr = self.parse_statement_expr()?;
            statements.push(Stmt { expr });
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
        if name.is_empty()
            || !name
                .chars()
                .all(|c| c.is_ascii_alphanumeric() || c == '_')
        {
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
        if matches!(key, Expr::Variable { .. }) {
            return Err(
                "hash-index assignment operator bare key is reserved for Channel 2".into()
            );
        }
        if matches!(value, Expr::Variable { .. }) {
            return Err(
                "hash-index assignment operator bare RHS is reserved for Channel 2".into()
            );
        }
        Ok(Some(Expr::AssignHashIndex { name, key: Box::new(key), value: Box::new(value) }))
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
        if name.is_empty()
            || !name
                .chars()
                .all(|c| c.is_ascii_alphanumeric() || c == '_')
        {
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
        if matches!(value, Expr::Variable { .. }) {
            return Err(
                "array append operator bare RHS is reserved for Channel 2".into()
            );
        }
        Ok(Some(Expr::AssignArrayAppend { name, value: Box::new(value) }))
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
        if name.is_empty()
            || !name
                .chars()
                .all(|c| c.is_ascii_alphanumeric() || c == '_')
        {
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
        Ok(Some(Expr::AssignScalar { name, value: Box::new(value) }))
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
            '$' => {
                self.advance(1);
                self.parse_var_or_call()
            }
            '0'..='9' | '-' => {
                // Look ahead: if '-' followed by digit, it's a negative number
                if ch == '-' {
                    let after = self.src[self.pos+1..].chars().next();
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
                if after.is_empty() || !after.chars().next().unwrap().is_alphanumeric() && after.chars().next().unwrap() != '_' {
                    self.advance(5);
                    Ok(Expr::Undef)
                } else {
                    self.parse_var_or_call()
                }
            }
            't' if self.remaining().starts_with("true") => {
                let after = &self.remaining()[4..];
                if after.is_empty() || !after.chars().next().unwrap().is_alphanumeric() && after.chars().next().unwrap() != '_' {
                    self.advance(4);
                    Ok(Expr::BooleanLiteral { value: true })
                } else {
                    self.parse_var_or_call()
                }
            }
            'f' if self.remaining().starts_with("false") => {
                let after = &self.remaining()[5..];
                if after.is_empty() || !after.chars().next().unwrap().is_alphanumeric() && after.chars().next().unwrap() != '_' {
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
                    ch, self.pos, &self.src[self.pos..end]
                ))
            }
        }
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
            // Indexed variable: name[index]
            self.advance(1); // consume '['
            let index = self.parse_expr()?;
            self.skip_whitespace();
            if self.peek() != Some(']') {
                return Err(format!("expected ']' after index in '{}[..]'", name));
            }
            self.advance(1); // consume ']'
            let expr = Expr::IndexedVar { name, index: Box::new(index) };
            self.parse_fluent_chain(expr)
        } else {
            // Plain variable — check for fluent chain too
            let expr = Expr::Variable { name };
            self.parse_fluent_chain(expr)
        }
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
        Ok(Expr::FluentChain { receiver: Box::new(receiver), calls })
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
                args.push(Arg::Keyword { name: maybe_name, value: Box::new(value) });
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
        Err(format!("unterminated string starting at position {}", start))
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

    #[test]
    fn parse_no_paren_helper_keyword_is_not_single_call() {
        let code = r#"return cat("a", "b")"#;
        let block = CodeBlock::parse(code).unwrap();
        assert!(
            !matches!(&block.statements[0].expr, Expr::Call { name, .. } if name == "return"),
            "bare `return cat(...)` must not parse as return(cat(...))"
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
            CodeBlock::parse(r#"name[key] = "v""#).is_err(),
            "bare hash-index key is reserved for Channel 2"
        );
        assert!(
            CodeBlock::parse(r#"name["k"] = value"#).is_err(),
            "bare hash-index RHS is reserved for Channel 2"
        );
        assert!(
            CodeBlock::parse(r#"items ++"#).is_err(),
            "increment-like spelling is not parsed as array append"
        );
        assert!(
            CodeBlock::parse(r#"items += value"#).is_err(),
            "bare RHS is reserved for Channel 2"
        );
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
            Expr::Call { name: _, args } => {
                match args[0].value() {
                    Expr::NumberLiteral { value } => assert_eq!(*value, -1.0),
                    _ => panic!("expected NumberLiteral"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_float_number() {
        let code = "return(3.14)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => {
                match args[0].value() {
                    Expr::NumberLiteral { value } => assert!((*value - 3.14).abs() < 0.001),
                    _ => panic!("expected NumberLiteral"),
                }
            }
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
            Expr::Call { name: _, args } => {
                match args[0].value() {
                    Expr::StringLiteral { value } => assert_eq!(value, "hello world"),
                    _ => panic!("expected StringLiteral"),
                }
            }
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
            Expr::Call { name: _, args } => {
                match args[0].value() {
                    Expr::BooleanLiteral { value } => assert!(!*value),
                    _ => panic!("expected BooleanLiteral false"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_boolean_true_not_prefix_match() {
        // "trueword" should NOT be parsed as true
        let code = "return(trueword)";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => {
                match args[0].value() {
                    Expr::Variable { name } => assert_eq!(name, "trueword"),
                    _ => panic!("expected Variable for 'trueword'"),
                }
            }
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
            Expr::Call { name: _, args } => {
                match args[0].value() {
                    Expr::Variable { name } => assert_eq!(name, "CAPTURE"),
                    _ => panic!("expected Variable"),
                }
            }
            _ => panic!("expected Call"),
        }
    }

    #[test]
    fn parse_indexed_variable() {
        let code = "return(results[0])";
        let block = CodeBlock::parse(code).unwrap();
        match &block.statements[0].expr {
            Expr::Call { name: _, args } => {
                match args[0].value() {
                    Expr::IndexedVar { name, index } => {
                        assert_eq!(name, "results");
                        match index.as_ref() {
                            Expr::NumberLiteral { value } => assert_eq!(*value, 0.0),
                            _ => panic!("expected NumberLiteral index"),
                        }
                    }
                    _ => panic!("expected IndexedVar"),
                }
            }
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
        let code = "push_value(array(items), scalar(retv)).return(array_copy(array(items))).endif()";
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
        let displayed = block1.statements.iter()
            .map(|s| s.expr.to_string())
            .collect::<Vec<_>>()
            .join("; ");
        let block2 = CodeBlock::parse(&displayed)
            .unwrap_or_else(|e| panic!("second parse failed for '{displayed}': {e}"));
        assert_eq!(block1.statements.len(), block2.statements.len(),
            "statement count mismatch: '{code}' → '{displayed}'");
        for (i, (s1, s2)) in block1.statements.iter().zip(block2.statements.iter()).enumerate() {
            assert_eq!(s1.expr, s2.expr,
                "statement {i} mismatch: '{code}' → '{displayed}'\n  left: {:?}\n  right: {:?}",
                s1.expr, s2.expr);
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
        let code = "push_value(array(items), scalar(retv)).return(array_copy(array(items))).endif()";
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
        let result = CodeBlock::parse("declare(array, results) push_value(array(results), scalar(retv))");
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
