---
id: perl-method-regex-undef-required-capture
title: Regex and undefined-return required callback copies and literal boundaries
answers:
  - "which required callbacks does regex substitution acquire"
  - "does regex substitution strip both arguments before its undefined guard"
  - "does regex substitution trim writable defined flags or readonly default flags"
  - "does return undef normalize actual parser argument arrays"
  - "does undefined return pass readonly zero arity literals"
  - "where is regex and undefined-return required capture verified"
date: 2026-10-10
status: bounded composed proof verified; ordinary landing and broader admissions separate
tags: [perl, actionir, callbacks, capture, aliases, regex, return]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2 verifies619 main/23 cold,24 exact native-current callback rows,32 branches/four public Toolbox rows, six semantic faults, supplied60 suites/182 files, evidence5/original303 restoration and full book89/three controls. Immutable179-file native capsule precedes182-file paired assertions:24 original isolation REDs/595 controls/all619 current GREEN. Original final-owner fault-generator failure and exact delimiter repair are retained; no broader admission."
reverify: "These regex/undefined-return commands require accepted2b4e484a9bf27471d23d86f72aa25c7616b2bd3b Git inputs after later source/book changes, including original live claim. Historical command: bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly. Capture/freezer/faults/fault-boundary/evidence/--capture are one-shot. Earlier push commands require accepted ae65603bc5bee1f3abeab4d7a028546ddbc8da93 inputs."
---

Regex substitution eagerly requires scalar extraction, delimiter stripping and
trim. Target/pattern/replacement/flags are local scalar copies. Both stripping
calls occur before the pair's defined guard, using distinct local slots.
Defined flags give trim a writable local argument; missing flags give it a
readonly empty literal. The trim result overwrites any mutation of the local
flags argument; undefined trim becomes empty flags. Empty and0 symbol/pattern/
replacement values retain their defined-only guards.

Undefined-return eagerly requires parser/normalizer before AST fast path. Its
normalizer receives actual parser arguments (or a new empty array when missing)
and readonly0/0 literals. Array mutation survives undefined/fatal outcomes; a
distinct normalized array retains separate identity. The private normalizer
control does not admit extra public arguments.

The immutable probe established24 native callback outcomes over regex defined/
default flags and undefined-return plain paths before assertion construction.
Its179 inputs exclude the later tests and native reader itself. The182-input
paired test/consumer capsule adds main/cold tests and the complete native JSON
reader. No original observation or assertion instrument was replaced. The original fault
generator required a following function delimiter and failed at the final
undefined-return owner before capturing mutants. Its actual failure and unchanged
182-input census are retained. Separate faults.py changes only missing-delimiter
handling to use end of file; independent review reconstructs that exact delta
and gates all six effective faults.

Four public Toolbox rows retain bare-g regex_subst/substr source and plain/scoped
return_undef source. Existing quoted flags, callback routing and active-receiver
protection remain under SESSION-STARTUP-READING.59. The AST helper is an explicit
secondary control; complete helper/AST/language, optional/direct, output/mapped/
full-private and independent canonical admissions remain separate.
