---
id: phase0-num-min-lowering-fixture
title: A positive Phase0 num_min fixture compares identical invalid lowering text
answers:
  - does the Phase0 num_min floor_value fixture produce compilable Perl
  - why does the positive num_min lowering assertion pass with an extra parenthesis
  - which task fixes the malformed positive numeric lowering fixture
date: 2026-09-21
status: confirmed test defect; repair owned by CONFORMANCE-SOURCE-READING.2.8 after required reading
tags: [perl, phase0, conformance, numeric, test-gap]
evidence: "CONFORMANCE-SOURCE-READING.1.52 at b71ea10ae reads Phase015950–15954. Exact call_spec_handler_subst output equals the test expectation but fails compilation near }); removing one trailing authored parenthesis yields compilable lowering returning2 for raw_name=abcd and limit=2. Both observations are fresh focused probes; no production source/test edit is made."
reverify: "Run the repository-managed two-case extraction below. The original must match its expected text and fail compilation; the corrected input must compile and return2. After tracked fixture repair, preserve this as dated RED evidence."
---

The `floor_value` assignment inside the 79-assertion method-contract subtest has
one extra closing parenthesis in both the authored call and expected generated
Perl. String equality therefore passes while the positive example cannot execute.
The Toolbox lowering probe returns the exact expected string; independent Perl
compilation fails at the trailing `})`. Removing only the extra authored `)`
produces valid output and the expected minimum, `2`, for the supplied values.

This is a positive-fixture defect. It does not establish a production failure for
valid numeric expressions or decide malformed-input diagnostics. Those boundaries
remain with [[perl-actionir-ast-covered-call-diagnostics]] and
[[perl-actionir-fallback-boundary-audit]]. `CONFORMANCE-SOURCE-READING.2.8` owns
correcting the fixture and adding actual compilation/execution proof after the
remaining source/book/policy prerequisites. A scratch correction does not close it.

```bash
bash tools/project_data_run.sh env PERL5LIB= perl -Iperl - <<'NUM_MIN_FIXTURE'
use strict;
use warnings;
use LinkedSpec;
use LinkedSpec::Numeric;
use JSON::PP;

open my $fh, '<', 't/phase0_regression.t' or die $!;
local $/;
my $source = <$fh>;
my ($authored, $expected) = $source =~ /LinkedSpec::call_spec_handler_subst\('Top', q\{(set\(Top, floor_value, num_min\([^\n]+)\}\),\n\s*q\{([^\n]+)\},/;
die 'fixture not found' unless defined $authored && defined $expected;
my $corrected = $authored;
$corrected =~ s/\)\z// or die 'missing trailing parenthesis';
for my $case (['original', $authored], ['balanced', $corrected]) {
    my ($tag, $action) = @$case;
    my $lowered = LinkedSpec::call_spec_handler_subst('Top', $action);
    die 'original assertion drift' if $tag eq 'original' && $lowered ne $expected;
    my ($floor_value, $raw_name, $limit) = (undef, 'abcd', 2);
    my $compiled = eval 'sub { '.$lowered.'; return $floor_value; }';
    my $error = $@;
    my $value = $compiled ? $compiled->() : undef;
    print JSON::PP->new->canonical->encode({case=>$tag, authored=>$action, lowered=>$lowered, compiled=>$compiled?1:0, value=>$value, error=>$error}), "\n";
    die 'original must fail syntax' if $tag eq 'original' && ($compiled || $error !~ /syntax error/);
    die 'balanced control must yield 2' if $tag eq 'balanced' && (!$compiled || $error || $value != 2);
}
NUM_MIN_FIXTURE
```
