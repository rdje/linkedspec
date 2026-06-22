---
id: lispish-corpus-catastrophic-backtracking
title: corpus_regression's Lispish parse of the conf/tablescript corpus catastrophically backtracks (uninterruptible) — the real phase0 "corpus tail" blocker, long-masked
answers:
  - "why does corpus_regression hang"
  - "why does t/phase0_regression.t hang at corpus_regression"
  - "is the corpus_regression subtest-941 tail a natural stop or a real failure"
  - "does the Lispish parser catastrophically backtrack on the conf corpus"
  - "what is the corpus_regression natural-stop tail really"
  - "can the Lispish spec parse the conf/tablescript corpus"
  - "why is phase0 not green after the back-half triage"
  - "what blocks green phase0 after PHASE0-BACKHALF-TRIAGE cluster .2"
date: 2026-06-22
status: accepted
tags: [phase0, regex-hang, lispish, corpus, legacy, regression-gate]
evidence: "PHASE0-BACKHALF-TRIAGE.5 (2026-06-22): a full `perl -Iperl t/phase0_regression.t` burned 374 CPU-min stuck inside corpus_regression on the first conf file; a fork+SIGKILL census (alarm() cannot interrupt a C-level regex) hard-killed ~21/22 conf files at 6s each (≈100%); ebnf dataset (ebnf spec, 7 files) parses in 0.1-0.6s; ambitiming.conf is only 392 bytes."
reverify: "perl -Iperl -MPOSIX -MTime::HiRes=time,sleep -e 'use LinkedSpec; my $p=LinkedSpec::get_parser(q{Lispish}); open(my $h,q{<},q{conf/ambitiming.conf}); local $/; my $d=<$h>; close $h; my $pid=fork; if(!$pid){ eval { $p->(\\$d) }; POSIX::_exit(0) } my $t=time; while(time-$t<6){ last if waitpid($pid,POSIX::WNOHANG)==$pid; sleep(0.05) } if(kill(0,$pid)){ kill(q{KILL},$pid); waitpid($pid,0); print qq{HANG: catastrophic backtracking present\\n} } else { print qq{parsed ok (FIXED)\\n} }'  # prints HANG while unresolved"
---

# corpus_regression's Lispish corpus parse catastrophically backtracks

`t/phase0_regression.t` cannot reach a green end-to-end run because the
`corpus_regression` subtest (top-level subtest ~941) **catastrophically backtracks**
when it parses the `conf/` and `tablescript/` corpus through the **Lispish** spec.

## What "the corpus tail" actually was

Earlier sessions repeatedly hit a "corpus tail" / exit-255 / SIGALRM stop and read it
as a *natural-stop boundary* or external-CPU-load artifact. It was neither. The
`corpus_regression` subtest runs four datasets in order; dataset #1
(`plugin_plg_via_pplugin_spec`) `opendir`-**died** first (the `plugin/` dir was removed
by `NONCORE-QUARANTINE.3`), short-circuiting the subtest with exit-255 **before**
datasets #2-4 ever ran. Removing that stale plugin dataset
([[and-return-edge-codegen-defect]]'s sibling work, `PHASE0-BACKHALF-TRIAGE.5.1`) lifted
the mask and exposed the catastrophe underneath. This corpus parse had been dark for a
very long time — first behind the old subtest-110 RTLUtils hang
([[rtlutils-regex-hang]]), then behind the plugin `opendir` death.

## The catastrophe (measured 2026-06-22)

- A full `perl -Iperl t/phase0_regression.t` ran for **374 CPU-minutes** (≈6.25h, ~100%
  CPU, state R) **stuck inside `corpus_regression`** on the very first conf file, never
  printing `ok 941`. Not slow-but-progressing — effectively a hang.
- A **fork + SIGKILL** census (note: `alarm()` **cannot** interrupt a single C-level
  regex match, so a plain `alarm` guard does *not* kill it) hard-killed **~21 of 22
  conf files sampled at 6s each (≈100%)**. The conf corpus is uniformly affected.
- `tablescript/*.ts` uses the **same** Lispish parser → same pathology expected.
- `ambitiming.conf` is **392 bytes / 13 lines** — so this is a **ReDoS-style
  catastrophic regex in the Lispish spec/generated parser**, not a large-input problem.
- The **`ebnf` dataset is healthy**: all 7 `ebnf/*.ebnf` files parse via the `ebnf`
  spec in 0.1-0.6s. The pathology is specific to **Lispish**.

## Environment hazard found alongside

The shell has a stale `PERL5LIB=/Users/richarddje/Documents/github/pgen/fx/perl:`
pointing at a *different, older checkout*. Bare `use LinkedSpec` (no `-Iperl`) loads
the wrong module. The tests are safe because they run `perl -Iperl …` (this repo's
`perl/` is prepended ahead of `PERL5LIB`), but any ad-hoc probe MUST pass `-Iperl` and
should print `$INC{'LinkedSpec.pm'}` to confirm it loaded `perl/LinkedSpec.pm`.

## Status / direction (open — needs a user decision)

Not yet resolved. `PHASE0-BACKHALF-TRIAGE.5.2` owns it; the options are a judgment call:
- **Quarantine the Lispish corpus datasets** (conf + tablescript) from the core gate,
  keeping `ebnf` — mirrors the plugin-dataset removal and the
  [[feedback_keep-only-portable-cross-variant]] direction (conf/tablescript/Lispish are
  legacy non-core). Greens phase0 fast; parks the Lispish regex as retirement debt.
- **Fix the Lispish catastrophic regex** (engine/spec perf) — restores coverage but is
  legacy-spec work and would need engine/spec authorization.
- **Add a hard per-file timeout guard** (subprocess + SIGKILL) so the suite fails-fast
  instead of hanging — completes the run but the conf/ts files then report as failures.

Distinct from [[rtlutils-regex-hang]] (retired VHDL subsystem) and
[[andplusplus-lx-parser-hang]] (spec.spec self-parse).
