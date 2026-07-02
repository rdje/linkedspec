---
id: spec-defined-user-function-definition-parser
title: User-function definition shells are parsed by specs/user_function_definition.spec, and body_brace does not own the outer close
answers:
  - "how are user function definitions parsed now"
  - "does Perl raw-scan user function definitions"
  - "what owns user_function_definition AST shape"
  - "why does user_function_definition.spec use body_brace"
  - "can body_brace consume the outer function close"
  - "how are unbalanced user function bodies diagnosed"
  - "where is the user function definition spec file"
date: 2026-07-02
status: current
tags: [implementation, staged-parsing, user-functions, ast, diagnostics, language-neutral]
evidence: "STAGED-LINKED-PARSING.5.3.1 added specs/user_function_definition.spec as the executable grammar owner for top-level fn name(params) { body } definition shells. LinkedSpec::UserFunctionRegistry now loads that spec parser, validates the returned function_definition AST, post-annotates body_payload.parent_ast_path, stitches in the existing ActionIR body AST, and no longer raw-scans definition syntax. Generated-handler debug showed the function_definition dependency map dispatches nested { to body_brace but dispatches the outer } to function_definition[1]; body_brace itself can start only on {. Focused phase0 tests cover whitespace params, nested braces, adjacent nested body_brace matches, strings, regex literals, malformed definitions, and unbalanced nested bodies returning function_definition_error nodes."
reverify: "rg -n 'user_function_definitions::|function_definition:|body_brace:|function_definition\\[1\\]|invalid or unbalanced user function definition|user_function_definition_spec_ast_shape' specs/user_function_definition.spec t/phase0_regression.t perl/LinkedSpec/UserFunctionRegistry.pm docs/tasks/STAGED-LINKED-PARSING.md"
---

The user-function definition grammar is now a `.spec` file:
`specs/user_function_definition.spec`. It parses the outer `fn name(params) { body }`
shell and returns source-ordered `function_definition` AST nodes with parsed params,
arity, exact source/body text, spans, source-slice provenance, and a neutral
`body_payload`.

The Perl reference registry consumes that returned AST. It no longer owns a separate raw
scanner for the definition shell; it only validates the AST, annotates the source-order
payload path, parses the already-extracted body text through the existing ActionIR body
parser, and strips definitions before bootstrap parsing.

`body_brace` is for nested brace islands inside the function body. Generated-handler debug
showed `body_brace` can start only on `{`; at the outer `}` close edge,
`function_definition[1]` is the matching edge. Adjacent nested bodies such as
`fn adjacent_braces() { {}{} }` therefore leave the outer close for the function rule.
Unbalanced nested bodies return a `function_definition_error` AST instead of pushing a
null node.
