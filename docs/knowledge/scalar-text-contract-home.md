---
id: scalar-text-contract-home
title: The neutral scalar-text contract owns cat conversion and non-text rejection
answers:
  - where is the canonical cat scalar conversion contract
  - does cat skip null Array or Hash fragments
  - how does cat render false integral numbers and negative zero
  - does the scalar-text fixture admit explicit final-codeblock call syntax
date: 2026-10-30
status: existing neutral contract; focused Perl TYPE45.9 check, no new peer admission
tags: [cat, scalar-text, contract, kinds, perl]
evidence: "capability_conformance/scalar_text_contract.json and README scalar-text section; t/scalar_text_contract.t and perl-phase0-cat-intake.json.gz retain the current focused proof."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/scalar_text_contract.t"
---

The existing `linkedspec-scalar-text-v1` contract preserves String fragments,
renders Boolean true/false as1/0, and uses stable finite decimal text with
negative zero0 and no unnecessary integral `.0`. Null, Array, Hash and Codeblock
are non-text: they make `cat` return null rather than disappear as empty text.
The executable fixture covers its named portable source values; Codeblock is a
semantic kind rule, not admission of explicit final-Codeblock call syntax.
Retired `concat` stays rejected.

TYPE45.9 reconciles one old exact emitted-text expectation with its original
cat expression result, preserved source bindings and fallback composition.
The other three source/flow/semantic assertions stay byte-exact. All4 and the neutral Perl
consumer7 pass; production and the neutral contract are unchanged. The direct
String native/fresh regression from45.8 is earlier unchanged-source evidence,
not a fresh run or a new all-backend completeness claim here.
