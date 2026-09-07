---
id: rust-recognition-token-variable-use-gap
title: Rust accepts forbidden recognition token variable uses as undefined values
answers:
  - "does Rust reject returning a recognition token in authored source"
  - "why does Rust return null when copying a recognition token"
  - "does the Rust private token escape test prove DSL rejection"
  - "which task repairs Rust recognition token variable use"
date: 2026-09-07
status: dated public source/query/CLI counterexamples; repair pending under SESSION-STARTUP-READING.68
tags: [rust, perl, recognition, tokens, compiler, semantic-introspection, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.32 uses verified Rust native libraries and CLI, paired Perl Get controls and exact source mechanisms; .68 owns authored rejection and carrier recurrence."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
  - "bash tools/project_data_run.sh .linkedspec-data/scratch/startup91-semantic-failure/probe .linkedspec-data/scratch/startup91-semantic-failure/escape-semicolon-control"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/scratch/startup91-semantic-failure/perl-get.pl .linkedspec-data/scratch/startup91-semantic-failure/escape-semicolon-control"
---

# Authored token uses bypass the private rejection helper

The recognition contract forbids returning or copying a token and names `recognition_token_escape`.
The exact source below receives a compiled Rust semantic snapshot with no compilation diagnostic; the existing
public Rust CLI exits 0, prints `null` and has empty stderr. Perl Get rejects with that diagnostic. Replacing
`return(tx)` with `return("ok")` is a positive control: both public execution routes return `"ok"` normally.

```text
Top::
 I {
 tx = recognition_checkpoint()
 matched = recognize_once(tx, call(Child))
 recognition_rollback(tx)
 return(tx)
 }
 /never/
Child::
 /c/
```

A second forbidden control inserts `copied = tx;` before rollback and returns `copied`. Rust again constructs
a compiled semantic index and its CLI returns null without stderr; Perl rejects with recognition_token_escape.
This copies while the token is active, so the finding is not confined to a read after rollback. No token object
is observed escaping: the missing rejection exposes an ordinary undefined placeholder instead.

The two Rust assignment handlers in `rust/linkedspec-runtime/src/engine.rs` 4619–4622 and 5697–5700
register the actual token through RuntimeContext, then store RuntimeValue::Undef under its ordinary scalar name.
The variable evaluator at 5727 reads that ordinary value without checking token use. The source-wide runtime/core
search finds reject_escape only at its authority definition. The native negative-token test at
`rust/linkedspec-runtime/tests/recognition_transaction_contract.rs` 374–428 invokes that private helper
directly for return/copy/etc.; it does not run these authored uses through the DSL. Its success does not prove
integration rejection. Other forbidden forms and reconstructed/generated/emitted/MCP routes remain .68 acceptance.

The initial newline-only copy separately encounters a statement separator parse error, then the already-owned
.45 warning/drop behavior; it is excluded from the two clean token-use counterexamples. See
[[rust-bare-variable-newline-consumption]]. Its semicolon twin isolates token handling without that parser error.

All inputs, native raw compiler diagnostics/query responses, four paired Get/CLI controls, source proof,
library identities and process output/status are under `.linkedspec-data/scratch/startup91-semantic-failure/`.
The manifest covers 71 files/35,587,020 bytes; manifest itself is 11,923 bytes, SHA-256
`771a5f9bc682e9875a4bdb128ae1c39e292579d77f6c2204df5cedba544f4467`.
Independent assertions are 455 bytes, SHA-256
`975c9bb37c2bf1b42814974c73a4d0452ab298c8b923cf48838f5d1e36a67b5b`.
The diagnostic probe compiles in 42.778 seconds and its first four queries run in 5.313 seconds, with exit0
and empty stderr. Rust CLI identity is SHA-256
`ad45555750489b78f7835457a09ecfa174d56b7ebf6242a4db5850570797c81a`.
Retained binaries are dated evidence: rebuild against verified current code before claiming repair proof.

Fresh recognition neutral proof passes 138 nodes/250 calls/58 mutations, token8/17 and rollout9/9;
semantic proof passes6/20/128 at9/0 and6/0. Neither unchanged fixture set closes these authored counterexamples.
