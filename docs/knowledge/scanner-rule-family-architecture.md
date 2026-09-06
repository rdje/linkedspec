---
id: scanner-rule-family-architecture
title: ScannerCore dispatches seven ordered owners with five dynamically scoped dependencies
answers:
  - "how are scanner rules organized in linkedspec"
  - "what is the difference between PrimitiveBasicRules and LegacyRules"
  - "where do new scanner rules go"
  - "what is the scanner rule family split"
  - "how many scanner dispatchers are registered"
  - "does an empty scanner result fall through to later families"
date: 2026-09-06
status: current
tags: [architecture, scanner, actionir, lowering]
evidence: "SESSION-STARTUP-READING.3.2.30 re-reads Scanner and FlowRules plus the ScannerCore registry/dependency/dispatch implementation. The callable registry census returns seven ordered packages; the Scanner directory contains five modules. The managed pipeline trace suite passes five tests. This supersedes the June 12 four-family/six-file inventory; retained internal scanner IDs do not restore retired authoring spellings."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl -MLinkedSpec::ActionIR::ScannerCore -E 'say for LinkedSpec::ActionIR::ScannerCore::_scanner_rule_family_packages()'"
  - "rg --files perl/LinkedSpec/ActionIR/Scanner"
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/trace_actionir_pipeline.t"
---

The ordered registry in `ScannerCore::_scanner_rule_family_packages` contains:

1. `LinkedSpec::ActionIR::StagedParseJob`
2. `LinkedSpec::ActionIR::ProgressiveSpanDispatch`
3. `LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules`
4. `LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules`
5. `LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules`
6. `LinkedSpec::ActionIR::Scanner::FlowRules`
7. `LinkedSpec::ActionIR::Scanner::LegacyRules`

The first two owners live outside the Scanner directory. Its five modules comprise
recognition transactions and the four earlier primitive, pipeline, flow, and legacy families.
FlowRules includes control markers, printing, exit, next, and return_undef scanning;
LegacyRules retains compatibility patterns alongside current return/call surfaces.
Family names and internal contract IDs are not the public helper-admission authority.

ScannerCore binds five shared callbacks: statement splitting, trimming, call parsing,
optional-scope normalization, and array-pipeline planning. Call parsing and optional-scope
normalization explicitly resolve to MethodExpr. Temporary typeglob bindings scope those
callbacks through each family invocation, and package loading stays lazy.

Dispatch stops at the first **defined** result, including an empty array. `undef` means
that a family does not own the contract; an empty array means an owned contract found
no matches. Exhausting every dispatcher returns an empty array. Scanner wraps this
orchestration with OwnerDispatch error preservation and event-producing trace reports.

New rules need an explicit contract owner and must preserve this ordered ownership
boundary. Related: [[actionir-lowering-stack]], [[trace-actionir-pipeline-decisions]],
and [[perl-progressive-span-dispatch-carriers]].
