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
date: 2026-07-02
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
