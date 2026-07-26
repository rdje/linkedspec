---
id: repository-root-path-portability
title: Repository-owned paths must survive checkout relocation
answers:
  - can the LinkedSpec repository root be moved or renamed
  - may LinkedSpec store an absolute checkout path
  - how must tools find the LinkedSpec repository root
  - may a runtime use CARGO_MANIFEST_DIR to find shipped specs
  - are caller supplied absolute spec paths still allowed
  - are usr opt and tmp paths repository path violations
  - do ignored build caches have to be free of absolute paths
  - which LinkedSpec primary command failed the relocation audit
  - what did REPO ROOT PATH PORTABILITY 0 discover
date: 2026-07-25
status: current
tags: [architecture, paths, repository-root, relocation, portability, doctrine, cli, rust, REPO-ROOT-PATH-PORTABILITY]
evidence: "REPO-ROOT-PATH-PORTABILITY.0 audited tracked text, modes, 27 shell/hook files, five primary commands, and outside-cwd process behavior. It found zero current/former checkout literals and zero tracked symlinks; Perl/Dart/Julia/Lua named-Lispish probes pass from /private/tmp, while a copied Rust binary under a synthetic moved tree exits 1 because rust/linkedspec-runtime/src/primary_cli.rs uses compile-time CARGO_MANIFEST_DIR. ADR 0052 freezes the boundary."
reverify: "git grep -n -I -F \"$(git rev-parse --show-toplevel)\" -- . ':(exclude)rgx' || true; git ls-files -s | awk '$1 == \"120000\" {print $4}'; rg -n 'CARGO_MANIFEST_DIR|current_exe|_findRepositoryRoot|_primary_cli_repo_root|FindBin|debug.getinfo' bin/linkedspec rust/linkedspec-runtime/src/primary_cli.rs dart/lib/src/cli/primary_cli.dart julia/src/cli/LinkedSpecJuliaCli.jl lua/bin/linkedspec-lua"
---

ADR `0052` makes checkout relocation a correctness property. Checked-in references to repository-owned files are
root-relative. Code that needs an absolute path computes it ephemerally from the current script, module,
executable, or an explicit caller root; a build directory or a former checkout is never runtime identity.

The audit began at clean commit `99a3df5b`. No tracked parent-repository text names the current SSD checkout or
the former `Documents/github` checkout shape, and the tree contains no tracked symlink. Twenty-five of 27 tracked
shell/hook files derive their root from their own location or git; the other two access no repository content.
Perl uses `FindBin`, Dart ascends from cwd and `Platform.script`, Julia joins from `@__DIR__`, and Lua derives from
`debug.getinfo`. Named-Lispish commands launched outside the checkout returned exact
`["hello",["world"]]` on all four.

Rust is the confirmed exception. `rust/linkedspec-runtime/src/primary_cli.rs` constructs the repository root from
`env!("CARGO_MANIFEST_DIR")`. Copying the built executable beneath a synthetic moved tree, adding a unique adjacent
named spec, and launching from outside both trees reproduced exit 1 with `parser compilation failed`: the binary
looked back into its compile-time checkout. `REPO-ROOT-PATH-PORTABILITY.1.1` owns runtime-anchor repair, and `.2.2`
owns the recurring copied-binary oracle.

The same audit found 12 Julia fact-card commands plus four legacy source/config files containing 42 developer-home
or private-session lines; four legacy config/plugin files contain six `/vobs/` mount values, and one contains a
`/dsync/` workspace. The derived `KNOWLEDGE_MAP.md` is not a separate source. `.1.2` repairs the exact legacy
owners; `.1.3` normalizes the fact cards and regenerates the map.

This doctrine does not ban filesystem absolutes as a data type. Explicit caller paths, neutral path-contract
fixtures such as `C:/Demo`, redaction-test needles, URLs, `/tmp` scratch, and external `/usr` or `/opt` tools remain
valid. Ignored caches are regenerated after a move, and debug symbols may retain source locations. The invariant
is that none of those values becomes an implicit or durable repository root.

Related facts: [[native-spec-resolution-contract]], [[native-spec-resolution-policy-drift]],
[[neutral-cli-fixture-runner]], [[rust-local-verification-gate]], [[lua-toolchain-package-policy]].
