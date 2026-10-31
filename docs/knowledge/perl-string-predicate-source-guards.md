---
id: perl-string-predicate-source-guards
title: Perl String-predicate roles preserve actual-kind and with rejection guards
answers:
  - "how does Perl guard free starts_with and matches continuations"
  - "why do rejected String predicates skip later with bodies"
  - "where are Perl String-predicate source and prefix guard tests"
  - "does the String-predicate guard repair change regex flags or producer kinds"
date: 2026-10-31
status: bounded Perl70.1 targeted-checked; full admission separate
tags: [perl, string, predicates, regex, guards, with]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.70.1; string-predicate-guard-perl-intake.json.gz retains actual producers, declared inputs, before/after public substitutions and native/fresh results."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/string_predicate_result_guard_composition.t t/string_predicate_result_guard_source_fences.t t/string_predicate_result_receiver_contract.t; historical activation/mutation/closeout writers are one-shot."
---

Perl70.1 adds a dedicated canonical String-predicate source/prefix role for starts_with/ends_with/contains_substr/matches. Unchanged shared22 groups14PASS8RED become22PASS native/fresh: seven wrong groups and one unsupported-with readiness gap repaired, thirteen healthy values and the needed source error exact. All21 value programs ready/raw0/fallback0/unresolved0/warning-free. Existing emitted/scoped-with/intermediate actual-kind guards reject incompatible operands and later bodies while preserving source-operand SOC snapshots, numeric flags, null/empty/text/regex domains, copy/default/strict arithmetic/generic predicates and valid false/null/empty with/returned Array/function caller state. Regex kind is admitted only in the existing matches operand, with producer/flags untouched. Canonical free-two/ordinary one-operand spelling/arity and recognized operands required; unknown/traversal/deferred/trailing overloads stay excluded. Nearest predicate/free String/receiver bridge/presence 59 assertions, excluded18 public AST/lowering fences and owner/normal syntax pass. 461 other declared activation inputs exact; seven actual primary/nearest fixtures derived from consumers and all phase identities retained, not complete transitive closure. Actual instruments/templates/inputs/raw channels/four before-after public substitutions retained in string-predicate-guard-perl-intake.json.gz. Regenerate emitted Perl. Rust70.2 independently next; general rejection isolation, full regex/domain/context/portable admission23.4 and canonical registration remain separate.

The pure `_ordinary_free_string_predicate_result_source` and ordinary one-operand prefix role in `perl/LinkedSpec/ActionIR/MethodLowering.pm` join existing emitted, scoped-with and intermediate kind guards. Transform roles retain their existing meaning. Regex literals are recognized only in the matches operand; no regex evaluator or serialized representation changes. Earlier selection evidence stays historical under [[string-predicate-result-source-guards]].
