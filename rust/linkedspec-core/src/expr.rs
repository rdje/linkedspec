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
//! stmts    → stmt*
//! stmt     → expr ';'?
//! expr     → call | indexed_var | literal | variable
//! call     → name '(' args? ')'
//! args     → arg (',' arg)*
//! arg      → expr | name '=' expr       (keyword argument)
//! literal  → string | number | regex
//! string   → '"' [^"]* '"' | "'" [^']* "'"
//! number   → \d+(\.\d+)?
//! variable → '$'? name                  (bare word variable reference)
//! indexed_var → variable '[' expr ']'   (array/hash index access)
//! regex    → '/' [^/]* '/'
//! name     → [a-zA-Z_]\w*
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
            Expr::Variable { name } => write!(f, "{name}"),
            Expr::IndexedVar { name, index } => write!(f, "{name}[{index}]"),
            Expr::StringLiteral { value } => write!(f, "\"{value}\""),
            Expr::NumberLiteral { value } => write!(f, "{value}"),
            Expr::BooleanLiteral { value } => write!(f, "{value}"),
            Expr::RegexLiteral { pattern } => write!(f, "/{pattern}/"),
            Expr::Undef => write!(f, "undef"),
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
            let expr = self.parse_expr()?;
            statements.push(Stmt { expr });
            self.skip_whitespace();
            // Consume optional semicolon
            if self.peek() == Some(';') {
                self.advance(1);
            }
            self.skip_whitespace();
        }
        Ok(CodeBlock { statements })
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
                self.advance(5);
                Ok(Expr::Undef)
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

            // Check for fluent chain: .method(args)
            self.skip_whitespace();
            if self.peek() == Some('.') {
                self.advance(1); // consume '.'
                let _method = self.parse_var_or_call()?;
                // Wrap as nested: method(name, call_result)
                return Ok(Expr::Call {
                    name: "chain".into(),
                    args: vec![
                        Arg::Positional(Expr::Variable { name }),
                        Arg::Positional(Expr::Call { name: String::new(), args: vec![] }),
                    ],
                });
            }

            Ok(Expr::Call { name, args })
        } else if self.peek() == Some('[') {
            // Indexed variable: name[index]
            self.advance(1); // consume '['
            let index = self.parse_expr()?;
            self.skip_whitespace();
            if self.peek() != Some(']') {
                return Err(format!("expected ']' after index in '{}[..]'", name));
            }
            self.advance(1); // consume ']'
            Ok(Expr::IndexedVar { name, index: Box::new(index) })
        } else {
            // Plain variable
            Ok(Expr::Variable { name })
        }
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
    fn parse_deeply_nested() {
        let code = r#"return(array("?results:", array_copy(array(results))))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 1);
    }

    #[test]
    fn parse_multiple_statements() {
        let code = r#"declare(array, results); push_value(array(results), scalar(retv)); return(array_copy(array(results)))"#;
        let block = CodeBlock::parse(code).unwrap();
        assert_eq!(block.statements.len(), 3);
    }

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
    fn parse_string_literal() {
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
    fn roundtrip_display() {
        let code = r#"push_value(array(results), scalar(retv))"#;
        let block = CodeBlock::parse(code).unwrap();
        let displayed = block.statements[0].expr.to_string();
        let block2 = CodeBlock::parse(&displayed).unwrap();
        assert_eq!(block.statements.len(), block2.statements.len());
    }
}
