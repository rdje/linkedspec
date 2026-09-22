---
id: lispish-multiline-quoted-payload
title: Lispish quote readers must match line feeds before parent dispatch sees string contents
answers:
  - why do multiline Lispish strings corrupt sibling forms
  - which fix owns SEMULITH LS-001
  - does Lispish preserve actual LF and CRLF in quoted strings
  - how are multiline Lispish quotes regression tested
  - can a quote reader initial action capture input when selected as the root
date: 2026-09-22
status: SEMULITH/LS-001 repaired; all six runtime routes verified under startup .83.2.1
tags: [lispish, quotes, regression, SEMULITH]
evidence: "Startup .85 reproduces all eight supplied cases on Rust: four controls match and four LF cases silently corrupt the tree. .83.2.1 captures the generated Perl parser before and after the two quote-rule changes; its 26-file Rust integration verifier passes all 18 groups, and final shared fixtures pass 36 command legs across six runtimes/two environments after failing against exact pre-fix grammar."
reverify: "Run bash tools/run_primary_cli_matrix.sh --manifest tests/lispish/quoted-newlines.json and bash tools/run_python_project_data.sh examples/integration/rust/verify_lispish.py --binary rust/target/debug/lispish_file. Phase0 lispish_ast_smoke consumes the same shared expectations."
---

The shipped grammar's `dquotes` and `squotes` rules originally used a lazy dot
capture without DOTALL. `LinkedSpec::get_parser` with `return_descriptor` and
`dump_parser_source` attributes those patterns to `specs/Lispish.spec` lines 69
and 71, including their dependency slots in `parenthesis` and `curlyb`.
When the complete quoted token does not match, seek dispatch can find whitespace,
ordinary atoms or delimiters inside it instead. Thus a line feed can split a
string or change following sibling structure without a runtime error.

Inline `(?s)` in both quote patterns makes the capture include newlines. Capture
index 0, literal backslashes, negative lookbehind, historical head/tail output,
first-form extraction and atom-kind erasure remain unchanged. Both quote rules
matter because braces must ignore closing braces inside either quote style;
ordinary parenthesized single quotes still behave as atom characters.

The shared CLI fixture includes literal LF/CR/CRLF, indentation, blank lines,
Unicode, escaped quotes, literal backslash-n, empty strings, comments, adjacent
fragments, sibling forms and delimiters inside quoted brace contents. The Rust
file verifier independently retains all eight supplied source inputs and expected
adapted values, alongside its existing file, error and relocation checks.

In the Perl reference, a direct `--top-rule dquotes`/`squotes` probe does not
match a token: their
initial actions read **entry** captures supplied by a caller's matched edge.
The captured generated handler copies `info.match_list` and immediately returns
`entry_group(0)`; it does not first match its own entry regex. Root and matched
child controls must distinguish this pre-existing entry-context contract from LF
recognition. The public regression uses normal Lispish parent/brace dispatch.

Logs and descriptor/source captures are under
`.linkedspec-data/scratch/lispish-lf/`; the original native replay and source
snapshot identity are recorded in [[archogen-rust-lispish-integration]].

The fixed grammar SHA-256 is `1aca70b0a5dca6f2d788f07275e4746426964062ccbe6dffcc129594807583ab`.
The shared three-case manifest is SHA-256 `11a27b5d8d7d5b92602c54c8831793b29f0bc8692fb747e82979ec18a5d40ee1`.
