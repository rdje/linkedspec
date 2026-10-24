---
id: perl-codeblock-boolean-literal-kind-drift
title: "Perl deferred literal kinds, precision and scalar validity"
answers:
  - "why does a Perl codeblock return 1 instead of true"
  - "do dynamic Perl codeblocks preserve boolean literal types"
  - "does a boolean argument remain typed through a Perl codeblock"
  - "where does Perl codeblock evaluation lose boolean literal identity"
  - "which task owns dynamic codeblock boolean result parity"
  - "why did deferred large fractional Perl literals lose numeric precision"
  - "why did Storable change whole float kinds in copied codeblocks"
  - "can a private Perl integer cache admit a fractional array selector"
  - "which scalar validity flags classify Perl nested write selectors"
date: 2026-10-24
status: repaired on Perl; finite literal-kind22 proof
tags: [perl, codeblock, literal, boolean, actionir, SESSION-STARTUP-READING]
evidence: "TYPE-REFERENCE-BOOK.1.2.22 executes startup35 acceptance; source epochs and original September6 diagnosis retained in docs/checkpoints/perl-literal-kinds/."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/perl-literal-kinds/publish.py; current: bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/callable_codeblock_literal_contract.t t/scalar_numeric_contract.t"
---

# Perl deferred literal fidelity

The September6 startup35 controls returned typed true/false directly and numeric1/0
through deferred literal bodies, including arrays; passed booleans stayed typed.
The AST retained kind=boolean. CodeblockRuntime returned native1/0 instead of
JSON::PP booleans. Original six controls, emitted-record diagnosis and old card
remain byte-exact in activation-inputs.json.gz and Git; they are dated history.

October24 repair22 reconstructs admitted ASCII decimal tokens using the parser's
0+source conversion and creates typed JSON booleans. A fresh substring avoids
retained conversion caches; absent/unsupported source records keep payload fallback.
The large fraction1000000000000000.5 previously lost its half in the serialized
numeric payload before reporting, while its source survived. Direct compiled
hexadecimal twins distinguish this from JSON display rounding.

Storable's installed public API changes whole-float kinds in both source and clone.
CodeblockRuntime now copies plain arrays/harrays by scalar assignment with memoized
aliases/cycles and callable origins; opaque references keep their existing fallback.
BindingRuntime classifies public SVf validity, not private SVp conversion caches.
An accepted-runtime native callback with computed-0.5 previously selected the tail;
its private integer cache was set but public integer validity was unset. Emitted and
compiled-argument controls rejected it. These are Perl5.34.1 measurements, not a
claim about every Perl release. Primary explanation: https://perldoc.perl.org/perlguts#What's-Really-Stored-in-an-SV?

Corrected37-program native/emitted proof observes kinds before final serialization,
including precision, fixed/rest/contextual calls, copied containers, typed writes,
source-less fallback and numeric/logical controls. Raw caches remain recorded.
Three first-after comparisons overconstrained private caches and earn no product
RED credit. The dated archive, physical faults/restorations and current permanent
consumer have separate roles. [[terse-primitive-literal-parity]] remains the typed
contract. No other-runtime parity or portable signed admission is inferred.
