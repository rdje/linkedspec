# Complete s-expression documents with token kinds

Select `specs/SExprDocumentV1.spec` when a file must be recognized completely and
the consumer needs to distinguish symbols, numbers and quoted strings. Its
default entry rule is `Document`. It returns every parenthesized top-level form
in order, including empty lists. Empty input and comment-only input are valid
documents with no forms.

The separate `Lispish.spec` grammar keeps its historical extraction behavior and
head/tail representation. Existing Lispish consumers do not opt into this format
automatically.

## Read a document

From the repository root, the reference command is:

```sh
perl bin/linkedspec --spec-file specs/SExprDocumentV1.spec --input '(v 1 "1")(done)'
```

The value is the following JSON object; formatting here is expanded for clarity:

```json
{
  "format": "linkedspec-sexpr-v1",
  "forms": [
    {"kind": "list", "items": [
      {"kind": "symbol", "lexeme": "v"},
      {"kind": "number", "lexeme": "1"},
      {"kind": "string", "lexeme": "\"1\""}
    ]},
    {"kind": "list", "items": [
      {"kind": "symbol", "lexeme": "done"}
    ]}
  ]
}
```

Use `--input-file` in place of `--input` to read a file through the same command.
Native hosts load and compile the specification through their normal public APIs
and inspect the returned direct value. The same grammar is exercised on Perl,
Rust, Dart, Julia, PUC Lua and LuaJIT. The dedicated
[Rust `sexpr_file` example](../public-api/integration-rust.md#read-document-files-in-your-application)
reads exact UTF-8 files through one compiled engine and supports a relocatable
binary/grammar bundle. The existing `lispish_file` adapter still consumes Lispish.

Backend-specific loading, entry selection and focused checks are documented in
the [Perl](../public-api/integration-perl.md#parse-complete-s-expression-documents),
[Rust](../public-api/integration-rust.md#parse-complete-s-expression-documents),
[Dart](../public-api/integration-dart.md#parse-complete-s-expression-documents),
[Julia](../public-api/integration-julia.md#parse-complete-s-expression-documents)
and [Lua/LuaJIT](../public-api/integration-lua.md#parse-complete-s-expression-documents)
integration guides. Adapting an example that explicitly selects `Top` also
requires selecting `Document`; changing the grammar path alone is insufficient.

## Interpret kinds and preserve spelling

Every document has exactly `format` and `forms`. A list node has `kind: "list"`
and an ordered `items` array. Every atom has `kind` and a string-valued `lexeme`.

| Input token | `kind` | `lexeme` contents |
| --- | --- | --- |
| `console.write` | `symbol` | `console.write` |
| `01` | `number` | `01` |
| `0x4_0000` | `number` | `0x4_0000` |
| `"01"` | `string` | Both quotes and `01` |
| `"a\nb"` | `string` | Both quotes, `a`, backslash, `n`, `b` |
| `1__0` | `symbol` | `1__0` |

Number classification uses the entire bare token. Decimal integers, fractions
with digits after the decimal point, exponents, optional signs, and hexadecimal
integers are recognized. Single underscores may separate digits. Examples of
number tokens are `+1`, `10_000`, `1.0`, `-.5`, `2e+10` and `0XFF`. Tokens such as
`1.`, `1__0`, `1.2.3` and `NaN` are symbols. The exact lexical rule is:

```text
[+-]?(?:0[xX][0-9a-fA-F](?:_?[0-9a-fA-F])*|(?:[0-9](?:_?[0-9])*(?:\.[0-9](?:_?[0-9])*)?|\.[0-9](?:_?[0-9])*)(?:[eE][+-]?[0-9](?:_?[0-9])*)?)
```

The grammar performs no numeric conversion, escape decoding or Unicode
normalization. A string may contain literal line breaks, tabs and structural
delimiters. Backslash and its following character remain an exact pair, including
an escaped quote or an unfamiliar escape such as `\q`. The enclosing quotes are
part of the lexeme. Consumer schemas decide numeric ranges, identifiers, units
and application-specific meanings.

For example, this is one string token, followed by a separate nested list:

```lisp
(message "first line
  ) still inside the string" (next 01))
```

The string's lexeme includes that LF, indentation and both quotes. Its `)` does
not close the surrounding list.

## Syntax and complete recognition

Only parenthesized lists are allowed at the top level. Lists can contain lists
or atoms. `(a)(b)` is two forms; `(a"b")` contains a symbol and a string in one
list. Single quotes and bare backslashes are ordinary token characters.

Trivia consists of ASCII space, tab, LF, CR, form feed and vertical tab, plus
semicolon comments ending at CRLF, CR, LF or EOF. Comments and inter-token trivia
are omitted from the result. A non-ASCII space is part of a bare token; it is not
implicit trivia. No BOM is stripped.

Bare tokens are maximal nonempty runs excluding those six whitespace characters
and `(`, `)`, `[`, `]`, `{`, `}`, `"`, `;`. Brackets and braces outside strings
are rejected. Missing closing parentheses or string quotes, dangling string
escapes, and unmatched closing parentheses reject the document.

All three inputs below fail, even though they contain a valid form:

```text
junk (a)
(a) junk (b)
(a) garbage (((
```

Failure uses the existing typed `exit_now(1)` boundary. The primary command exits
unsuccessfully and returns no accepted partial document. Native callers must
handle the failure result or exception rather than treating it as an empty
document. The compiled engine can be reused for a fresh, independent input after
a rejected document.

The grammar rejects otherwise unrecognized characters at both document and list
level. Its final cursor check is an additional safeguard. A cursor at EOF alone
would be insufficient: ordinary seek dispatch can skip text and still reach EOF.
The regression suite removes the rejecting edges and independently demonstrates
that `(a) junk (b)` would then be wrongly accepted.

## Write the tokens back

To serialize a parsed document, emit each atom's `lexeme` unchanged. For a list,
emit `(`, serialize its items separated by spaces, then emit `)`. Separate the
top-level forms with a newline. Re-parsing that text preserves kinds and lexemes.

This reconstructs token spelling and structure. Original whitespace, comments,
source offsets and layout are outside the v1 result. Use an application-specific
format-preservation layer if those are needed.

## Verification boundary

`tests/sexpr-document-v1/contract.json` contains 37 independently authored cases:
21 accepted documents and 16 rejections, including the four-form ARCHOGEN input
and all four SEMULITH kind examples. Run:

```sh
bash tools/check_sexpr_document_v1.sh
```

The driver checks all six native runtime routes, 21 token-spelling round trips per
route, and valid independent input after every rejection through the same
compiled engine. Perl also checks ActionIR readiness and the rejecting-edge
mutation. The canonical local gate runs this driver. The separate native Rust
file verifier consumes all 37 cases as real files and checks UTF-8, errors,
multiple inputs, packaged assets and relocation. Independent final integration
admission and downstream application acceptance remain separate steps.
