# ADR 0124: A separate versioned grammar preserves s-expression kinds and validates complete documents

- Date: 2026-09-22
- Status: accepted design under SESSION-STARTUP-READING.83.1; grammar implemented under .83.2.2; native file delivery and final admission pending
- Tags: grammar, s-expressions, compatibility, token-kind, document-validation

## Context

SEMULITH/LS-002 requests recoverable atom kinds for files that are written as well
as read, explicitly preserving historical Lispish behavior. ARCHOGEN/LS-003 needs
the distinction between identifiers, string literals and numeric tokens;
ARCHOGEN/LS-002 needs every top-level form and rejection of unrecognized input.
The source-qualified reports are registered in
`docs/knowledge/archogen-rust-lispish-integration.md`.

`Lispish.spec` remains an extraction grammar with its historical head/tail output,
first-form behavior, literal escape handling and fragment concatenation. Its
quoted-LF defect is fixed at 8259719f8. Changing that existing representation would
break consumers and contradict SEMULITH's request.

## Decision

Add **`specs/SExprDocumentV1.spec`** through the implementation leaves below.
Selecting that separate grammar opts into this document and token contract.
No new global execution mode, dependency API or token-span side channel is needed.
The design checkpoint did not ship the grammar. Implementation .83.2.2 now ships
it with 37 authored cases, round trips and post-rejection reuse on six native runtimes;
.83.2.3 native file delivery and .83.3 final admission remain separate.

### Result shape

A successful parse returns exactly:

```json
{"format":"linkedspec-sexpr-v1","forms":[]}
```

`forms` is an ordered array of list nodes, including every top-level form.
A list is `{"kind":"list","items":[...]}`. Its items are list or atom nodes.
The three atom kinds share an exact lexical field:

| Source token | Node |
| --- | --- |
| `name` | `{"kind":"symbol","lexeme":"name"}` |
| `10` | `{"kind":"number","lexeme":"10"}` |
| `"10"` | `{"kind":"string","lexeme":"\"10\""}` |

`lexeme` preserves the complete source token. For strings it includes both double
quotes, literal line breaks and escape spelling. Numeric lexemes retain signs,
leading zeros, underscores, radix markers and exponent spelling. Parsing performs
no numeric conversion, escape decoding or Unicode normalization.

A writer can reconstruct each atom from `lexeme` and each list from parentheses
and its items. Re-parsing that serialization must preserve kinds and lexemes.
Whitespace and comments between tokens are omitted from the result; formatting,
comments and source offsets are outside this v1 result contract. Consumer schemas
remain responsible for names, units, numeric ranges and domain validation.

### Document and lexical syntax

- A document contains zero or more **parenthesized** top-level forms separated by
  optional trivia. Empty and trivia-only input produce an empty `forms` array.
  `(a)(b)` contains two forms. A bare or quoted top-level atom is rejected.
- Lists may contain arbitrary nested lists and atoms, including empty lists.
  Every opened list must close; unmatched closes reject the whole document.
- Trivia is exactly ASCII space, horizontal tab, LF, CR, form feed and vertical
  tab, plus semicolon comments ending at CRLF, CR, LF or EOF. A BOM is not stripped.
  Enumerating trivia keeps its meaning explicit across regex providers. Unicode
  remains valid in token spelling; a non-ASCII space is not implicit trivia.
- A bare token is a nonempty maximal run excluding those six whitespace
  characters and `(`, `)`, `[`, `]`, `{`, `}`, `"`, `;`. Single quotes and bare
  backslashes have no quoting or escape function. Brackets and braces outside
  double-quoted strings are rejected.
- Double-quoted strings permit literal LF/CR/tab and structural delimiters inside
  the string. Backslash plus the following character is preserved as an escape
  pair; no escape is decoded. An escaped quote cannot close the string. Missing
  closing quotes and dangling escape pairs are rejected, rather than reclassified
  as bare atoms.
- Delimiters establish token boundaries. `(a"b")` contains a symbol and a string;
  it does not concatenate them. Historical Lispish adjacency remains unchanged.

A bare token is a number only when its **entire** spelling matches:

```text
[+-]?(?:0[xX][0-9a-fA-F](?:_?[0-9a-fA-F])*|(?:[0-9](?:_?[0-9])*(?:\.[0-9](?:_?[0-9])*)?|\.[0-9](?:_?[0-9])*)(?:[eE][+-]?[0-9](?:_?[0-9])*)?)
```

Thus `+1`, `01`, `10_000`, `1.0`, `-.5`, `2e+10` and `0x4_0000` retain number
kind and exact spelling. `1__0`, `1.2.3` and `NaN` are symbols. This is lexical
classification, not validation against an application-specific numeric type.

### Complete-input rejection

No successful result may omit unrecognized leading, interstitial or trailing
characters. Invalid input yields a grammar failure with status 1 through the
existing typed `exit_now(1)` control; it yields no accepted partial document.
Hosts retain the normal runtime/CLI failure boundary and must check that boundary.

The planned grammar gives every character a recognized token/trivia branch or an
explicit rejecting catch-all branch. The document's end-position assertion is an
additional check, not the sole validation mechanism. A Perl prototype mutation
that removes the two rejecting edges accepts `(a) junk (b)` with both forms and a
final cursor at EOF: checking only the final offset cannot prove full recognition.
The implementation must retain an equivalent no-skipped-character invariant.

## Acceptance authority and evidence

`tests/sexpr-document-v1/contract.json` contains 37 independently authored examples:
21 accepted documents and 16 rejections. It includes all four SEMULITH kind probes,
ARCHOGEN's complete four-form eADL file, multiline strings, spelling boundaries,
empty documents/lists, EOF comments, malformed delimiters and three junk positions.

The scratch feasibility grammar uses only existing public DSL facilities. It is
not the production grammar and does not establish cross-backend admission.
`docs/knowledge/sexpr-document-design.md` preserves repeatable prototype proof,
its exact scope and the catch-all mutation. Production acceptance must independently
consume the authored expectations rather than regenerate them from parser output.

The first Rust prototype exposed existing compiler defect `.45`: a malformed LX
block was warned about and dropped while compilation succeeded. Its infix comparison
was corrected to the documented `num_ne(...)` call. That authoring correction does
not repair compiler error propagation. Bounded `.45.1-.45.3` repair and verify the
compiler boundary before strict-document implementation is delivered.

## Implementation and consequences

1. `.45.1-.45.3`: reject malformed Rust rule blocks, verify supported carriers and
   complete canonical/public closeout. Other parser defects retain their own owners.
2. `.83.2.2`: implement the versioned grammar and persistent contract consumers;
   prove valid values, atomic rejections and independent-input reuse across all six
   admitted runtime routes. Preserve Lispish and its fixed quoted-LF regressions.
3. `.83.2.3`: provide a separate native Rust file consumer and integration examples
   for the tagged document. Preserve `lispish_file`'s historical adapter. Verify
   UTF-8, file/error handling, multiple input files, assets and relocation.
4. `.83.3`: independent acceptance, complete book/roadmap alignment and canonical
   admission of the delivered scope. Downstream verification is a separate claim.

This design resolves the requested representation and validation direction. It
closes neither the implementation tasks nor the consumer reports by itself.
