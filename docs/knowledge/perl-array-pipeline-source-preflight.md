---
id: perl-array-pipeline-source-preflight
title: Perl numeric pipeline sources read ambient Array slots before result repair
answers:
  - "why does Perl trim_each 3 read an unrelated host Array"
  - "which task owns split_each trim_each filter_nonempty lowercase_each uppercase_each uniq filter_match Number source isolation"
  - "does a computed Number pipeline source read the same host slot as literal 3"
  - "does a receiver split_each delimiter error work before an incompatible consumer"
  - "which pipeline pattern controls reach regex compilation rather than DSL validation"
  - "did the original Perl pipeline selection retain every public error Hash field"
date: 2026-11-10
status: preflight79.1.0 acquired; P1 source79.0 before result79.1.1; no production repair yet
tags: [perl, array, pipeline, source, isolation, arity, errors, guards]
evidence: "docs/checkpoints/array-pipeline-result-perl-2026-11-10/REVIEW.md retains184 programs/148 acquired profiles/180 actual artifact pairs,original17 composition failures19 preserved,14 main-only numeric host reads and one additional receiver-error target. First readonly0/empty stderr/ten corruptions passes; no production or peer verdict."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/array-pipeline-result-perl-2026-11-10/review_preflight.py"
---

Actual public Get/descriptor/substitution/parser-source/native/full emitted-fresh
probes show literal Number3 becoming [@3] at MethodLowering.pm's shared
lower_array_value_source_expr shortcut. Fourteen free/receiver cases across the
seven pipelines read MAIN/TAIL/END only from localized main::3; lowercasing
transforms those unrelated strings. Empty-host/outer-package and computed {3}
under the same main seed stay empty. Every host snapshot remains unchanged.
P1 source79.0 owns this isolation repair before canonical result guards; do not
bless ambient reads, change global extractors or normalize initial producer policy.

Before production, unchanged36 retains17 composition failures/19 controls. Own98
questions acquire63 initial forms,14 excluded arities,six earlier owners,nine
binding-error requests,four source-syntax exclusions and two scalar-kind controls;
42 additional host distinctions and eight later source questions stay separate.
The63 initial empty-host forms yield [] or count0/W, without proving isolation.
Free extras retain ran/KW/unresolved helper; receiver extras retain null/no effects/
unresolved with. Prior owners keep their skips. Bool/null/text and numeric Array
entries retain actual kinds. These are finite observations, not portable domains.

Terminal receiver split_each forwards binding_kind_mismatch and supports computed/
variable delimiters/count. Adding the incompatible consumer retains DSL and
fails compilation instead. That extra needed-error target belongs to result79.1.1.
Four /(/ inputs stop at DSL validation, not a producer error. Four balanced
invalid-range inputs reach actual regex compilation and fail before consumers;
unloaded modules have load_error and no fresh invocation fields.

Own sources/three grammars/instruments/templates/fixture inputs precede SDK use;
actual modules and Get-built source precede execution. Full records/channels and
180 real artifact pairs survive for184 programs; four syntax rejections have none.
First readonly0/ten controls verifies actual identities, full frames/field absence,
host distinctions and explicit acquired defect/exclusion roles. New observed error
Hashes retain all fields; selection39's older whitelist remains a projection with
unknown omitted first-use fields. No original packet or source is rewritten.
Full native/cache/transitive/toolchain custody4.2/SESSION5, source/context/isolation/
registration/declared5.4/full23.4 remain separate. No current-runtime verdict follows
from historical recovery. Related: [[array-pipeline-result-guard-selection]],
[[perl-array-transform-source-preflight]], [[action-regex-operands-and-runtime-kinds]].
