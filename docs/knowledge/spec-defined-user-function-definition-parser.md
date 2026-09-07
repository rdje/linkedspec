---
id: spec-defined-user-function-definition-parser
title: User-function definition shells are parsed by specs/user_function_definition.spec, and body_brace does not own the outer close
answers:
  - "how are user function definitions parsed now"
  - "does Perl raw-scan user function definitions"
  - "does Rust raw-scan user function definitions"
  - "what owns user_function_definition AST shape"
  - "why does user_function_definition.spec use body_brace"
  - "can body_brace consume the outer function close"
  - "how are unbalanced user function bodies diagnosed"
  - "where is the user function definition spec file"
  - "how does Rust validate staged function payload and parse job metadata"
  - "how does Rust strip function definitions without moving scalar offsets"
date: 2026-09-07
status: current
tags: [implementation, staged-parsing, user-functions, ast, diagnostics, language-neutral]
evidence: "STAGED-LINKED-PARSING.5.3.1 added specs/user_function_definition.spec as the executable grammar owner for top-level fn name(params) { body } definition shells and made LinkedSpec::UserFunctionRegistry consume its returned AST instead of raw-scanning. STAGED-LINKED-PARSING.5.3.2 made Rust consume the same spec-returned function_definition / function_definition_error AST through linkedspec-runtime::spec_parser; rust/linkedspec-core/src/parser.rs no longer extracts top-level fn definitions. Generated-handler debug showed the function_definition dependency map dispatches nested { to body_brace but dispatches the outer } to function_definition[1]; Rust runtime tests lock the same self-recursive finalizer behavior. Focused Perl/Rust tests cover whitespace params, nested braces, adjacent nested body_brace matches, strings, regex literals, malformed definitions, and unbalanced nested bodies returning function_definition_error nodes."
reverify: "rg -n 'user_function_definitions::|function_definition:|body_brace:|function_definition\\[1\\]|invalid or unbalanced user function definition' specs/user_function_definition.spec && rg -n 'parse_spec_with_user_functions|parse_user_function_definition_asts|spec_defined_user_function_parser_' rust/linkedspec-runtime && rg -n 'UserFunctionRegistry|user_function_definition_spec_ast_shape' perl t/phase0_regression.t"
---

The user-function definition grammar is now a `.spec` file:
`specs/user_function_definition.spec`. It parses the outer `fn name(params) { body }`
shell and returns source-ordered `function_definition` AST nodes with parsed params,
arity, exact source/body text, spans, source-slice provenance, and a neutral
`body_payload`.

The Perl reference registry and Rust runtime adapter consume that returned AST. They no
longer own separate raw scanners for the definition shell. The bridge validates the AST,
preserves the neutral body payload, parses or compiles the already-extracted body text
through the existing action-body machinery, and strips definitions before ordinary rule
parsing.

`body_brace` is for nested brace islands inside the function body. Generated-handler debug
showed `body_brace` can start only on `{`; at the outer `}` close edge,
`function_definition[1]` is the matching edge. Adjacent nested bodies such as
`fn adjacent_braces() { {}{} }` therefore leave the outer close for the function rule.
Unbalanced nested bodies return a `function_definition_error` AST instead of pushing a
null node.

## September 7 Rust projection reading

`SESSION-STARTUP-READING.3.3.35` reads spec_parser.rs 1–836. Ordinary and traced entrypoints parse, validate,
compile and execute the same embedded definition grammar, validate returned node shapes, project definitions,
then parse the stripped rule source. The typed adapter distinguishes fixed-arity v1, callable-signature v2 and
the v1 final-codeblock form, rejecting incompatible signature/parameter fields. Definition and body spans must
match exact decoded-scalar text, with the body contained in its definition.

Body payload and parse job must agree with the projected function's name, signature/parameter kinds, text and
span. Jobs are restricted to actionir-body.spec/action_block, replace_field/body_ast, fail and function_body
diagnostic ownership. Parent paths are checked for the functions/*/body_source shape, then rewritten with the
actual node index; job IDs incorporate that index and the exact body span. The registry executes the validated
job before FunctionDefinition receives body_ast. It does not substitute a Rust definition-shell scanner.

Definition stripping sorts and rejects overlapping/out-of-range scalar spans, substitutes one space per
non-newline scalar and preserves CR/LF. Scalar offsets and line layout are retained; multibyte UTF-8 byte
length need not be retained. The semantic source mapper separately checks scalar-to-byte provenance as described
in [[rust-semantic-call-staged-projection]]. SourceLocation materialization uses a different private authority.

Remaining scalar/signature/error helper suffix 837–1022 is the next reading window. Fresh staged neutral proof
passes 9 rollout legs/123 base mutations and 6 public documents/129 public mutations; this is not a new native
function parser, trace or serialized carrier test run.

## September 7 Rust helper completion

`SESSION-STARTUP-READING.3.3.36` reads 837–1022 and completes spec_parser.rs. Callable signatures require exactly
six named fields, version1, valid ASCII positional/rest names, min_arity equal to positional count and null
max_arity. Scalar extraction checks string/array/object types; unsigned integer conversion is checked, while
the floating fallback's unchecked upper boundary is added to .55.1's source inventory in
[[rust-large-number-conversion-defect]]. Definition-error presentation distinguishes malformed/final/missing
codeblock parameter forms and unknown types, retaining a positive source line or falling back to node index.
These helper checks do not replace compiler-level validation or the executable shell grammar. Fresh staged and
typed-source neutral proof pass; no new native definition/signature or trace suite is claimed.
