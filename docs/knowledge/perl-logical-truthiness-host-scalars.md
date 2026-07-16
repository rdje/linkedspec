---
id: perl-logical-truthiness-host-scalars
title: "Perl logical truthiness distinguishes shared numeric zero from nonempty string zero."
answers:
  - "why did Perl count value select the true if branch for an empty callback aggregate"
  - "why can Perl false comparisons look like strings to B scalar flags"
  - "how does RuntimeLogical distinguish numeric zero from string zero"
  - "does a Perl string zero remain true after numeric inspection"
  - "where is Perl typed logical truthiness implemented"
date: 2026-07-16
status: current
tags: [perl, logical-helper, truthiness, runtime, ActionIR]
evidence: "FUTURE-PARITY-BACKLOG.5.2.2 introduced perl/LinkedSpec/RuntimeLogical.pm and t/logical_helper_perl_contract.t. A full Phase 0 run exposed count(value) over an empty callback aggregate selecting the true branch. Toolbox lowering showed the condition reached RuntimeLogical::truthy as scalar(@value). Perl's shared false/zero scalar advertises public string, integer, and floating-point slots simultaneously; ordinary nonempty string zero values can acquire one numeric slot after inspection. RuntimeLogical therefore recognizes the simultaneous public integer-plus-floating signature before applying string precedence, while ordinary strings retain nonempty-string truth. The focused contract locks empty aggregate count, false comparison, and numerically inspected string-zero behavior; the canonical hash-tree fixture again preserves A/B leaves."
reverify: "prove -Iperl t/logical_helper_perl_contract.t && perl -Iperl -MB -MLinkedSpec::RuntimeLogical -e 'my @empty; my $string = q{0}; my $ignored = 0 + $string; die unless !LinkedSpec::RuntimeLogical::truthy(scalar(@empty)); die unless !LinkedSpec::RuntimeLogical::truthy(1 == 2); die unless LinkedSpec::RuntimeLogical::truthy($string); print qq{perl-logical-host-scalars: OK\\n}'"
---

# Perl Logical Truthiness and Host Scalars

Perl does not preserve LinkedSpec's semantic scalar kind in one simple host flag. In particular, the shared scalar
returned by a false comparison and by an empty array in scalar context exposes valid string, integer, and
floating-point slots at once. Applying ordinary string precedence to that host value turns numeric zero into the
nonempty string `"0"` and incorrectly makes it true.

`LinkedSpec::RuntimeLogical::truthy` owns the Perl reference policy. It first handles semantic references and real
booleans, then recognizes the shared numeric scalar's simultaneous public integer and floating-point signature.
Only after that exception does a string slot take precedence, which preserves the contract that `"0"`,
`"false"`, whitespace, and other nonempty strings are true even when Perl has numerically inspected the scalar.

This is a host-representation boundary, not permission to use Perl's native boolean context. Logical helpers and
lazy control conditions both call the same runtime seam.
