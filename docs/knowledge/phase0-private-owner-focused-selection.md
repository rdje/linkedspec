---
id: phase0-private-owner-focused-selection
title: Isolated Phase0 groups must explicitly load the private owners they call
answers:
  - why does an isolated Phase0 group exit before its first assertion
  - why is EmitContext lower_method_value_expr undefined in a selected group
  - may a no-tests setup failure count as a product regression RED
date: 2026-10-30
status: exact scalar boundary group repaired under TYPE45.8; no whole-suite independence claim
tags: [perl, phase0, selection, lazy-loading, tests]
evidence: "perl-phase0-scalar-boundary-intake.json.gz retains cold exit255/no-tests channels, explicit owner load, actual4 source assertion RED and final6 GREEN."
reverify: "Recover current-only selector and phase0-scalar-boundary-names.json from the retained TYPE45.8 packet; run project_data_run.sh env PERL5LIB= perl -Iperl with those names and a separate seen-output path."
---

The scalar boundary-transform group directly calls private EmitContext lowering
entrypoints. In the full historical selection, earlier groups load that package;
alone, its first call was undefined and the process exited255 before any of its
six assertions. The group now requires its direct private owner locally before
probing it. Production lazy loading remains unchanged.

The cold setup failure is retained without product or four-assertion RED credit.
After explicit loading, the four actual obsolete source-text assertions fail and
two semantic controls pass; repaired value/source/literal-boundary checks pass6.
Do not globally preload owners in the generic selector, because groups testing
cold startup or lazy loading must keep their intended initial conditions. Resolve
only a selected group's real dependencies, preserving its original fixture and
contract. No broad independence audit or universal test-setup repair is implied.

TYPE45.18 additionally guards the project-local activation producer against
existing diagnostic prefixes before writes. A reused pick-keys prefix overwrote
three local old preparation inputs; committed evidence remained intact and all
three were restored from its verified archive. New oracle inputs use a distinct
prefix. Three isolated project-local fixtures retain actual historical overwrite
RED and current no-write rejection, with only Git status/HEAD simulated. See
perl-phase0-pick-keys-oracle-intake.json.gz; initial missing-name selector2 is not
a semantic product failure.
