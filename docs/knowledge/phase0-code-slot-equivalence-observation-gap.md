---
id: phase0-code-slot-equivalence-observation-gap
title: Phase0 code-slot equality can pass without observing generated code
answers:
  - do Phase0 lifecycle code-slot comparisons observe generated code
  - can changed branch payloads pass Phase0 lowering equivalence assertions
  - why are ICODE and ACODE absent from the public Perl descriptor
  - who owns vacuous Phase0 code-slot equivalence assertions
  - why does the Toolbox source capture example raise Not a SCALAR reference
date: 2026-09-21
status: confirmed test observation gap and capture recipe error; repairs pending under required reading prerequisites
tags: [perl, phase0, tests, descriptors, generated-source, toolbox]
evidence: "CONFORMANCE-SOURCE-READING.1.56 at e258190c84fa85aa819c4e4eb13e353ec63d585f. The exact six-tag inline-switch test passes 48 inner assertions both pristine and after changing only the structured branch payload. Twelve observed descriptors lack all uppercase code slots. Captured generated handlers contain the distinct original and changed return values. Explicit scalar source capture succeeds; dereferencing the ARRAY chunk store as a scalar fails."
reverify: "Run CODE_SLOT_OBSERVATION below from the repository root through tools/project_data_run.sh. This diagnoses test sensitivity and capture shape; it does not execute target branches or close repair prerequisites."
---

## Cause and scope

The exact test `method_like_remaining_lifecycle_inline_composite_switch_lower_equivalently`
in `t/phase0_regression.t` compares `$descriptor->{spec}{Top}{$code_key}` for
I, LS, LE, E, EX and IT. Its public `Get(..., return_descriptor => 1)` output
has `dependency_refs`, `handler`, `meta` and `re` at `spec.Top`. The uppercase
ICODE/LSCODE/LECODE/ECODE/EXCODE/ITCODE/LXCODE/ACODE fields do not exist there.
The purported code comparison therefore passes on two undefined values.

Changing only the structured fixture's returned `semantic_annotation` string to
`changed_annotation` preserves all six nested plans of eight passing assertions.
Explicitly captured I/LS/LE generated source contains the changed return expression.
Metadata equality and zero-fallback checks remain meaningful observations, but
they cannot distinguish this payload mutation. No target parser is executed by
this reproduction, and it establishes no production branch-selection defect.

`Compiler.pm` returns the final descriptor at its `return_descriptor` boundary;
`CompilerState::compiled_descriptor_state_to_legacy_descriptor` projects compiled
rules into its `spec` map. The test reads nonexistent fields in that public result.
Adding uppercase fields to production just to satisfy these tests is not the repair.

`CONFORMANCE-SOURCE-READING.2.10` owns the full comparison inventory and bounded
repairs: observe actual nonempty lowering or independently execute discriminating
branches, retain metadata coverage, and reject the changed-payload control.
Earlier reading notes in groups 53–55 that called these slot comparisons exact
generated-code proof are superseded by this finding. Historical test success and
physical reading remain valid; generated-code equivalence does not follow from them.
Current consumer and book checkpoints carry this correction. Similar unprobed
comparisons remain inventory work, not independently reproduced findings.

The same six-tag fixture selects `and_single_acode`; E/EX/IT payloads are absent
from its captured handler. This is explained by
`HandlerVariantEmitter::_build_and_single_acode_variant`, whose fields carry
preamble, LX, LS, LE and action code, but not E/EX/IT. The public lifecycle guide
already makes these advanced hooks handler-shape dependent. The recipe checks
the actual I/LS/LE emitted payloads and records the remaining omission explicitly;
it does not invent a six-hook execution pass. `.2.10` must use appropriate handler
shapes for meaningful positives. Existing `SESSION-STARTUP-READING.27.1` owns
normative mode/finalization reconciliation; see [[perl-lifecycle-final-value-e-drift]].

## Source capture pitfall

`TOOLBOX.md` section 2.2 and the maintained reverify recipe in
[[top-rule-is-ordinary-rule-entered-first]] use a scalar dereference of
`runtime_ctx->{parser_source_chunks_ref}`. The store is an ARRAY, as confirmed by
public `Get` output and `RuntimeContext::ensure_runtime_ctx_parser_source_chunks_ref`.
`flush_runtime_ctx_parser_source` joins its chunks and writes to the explicit
`parser_source_ref` SCALAR. A valid control captures 12,203 bytes through that
scalar while the documented scalar dereference raises `Not a SCALAR reference`.
The byte count is a dated control measurement, not a stable output-length contract.
`CONFORMANCE-SOURCE-READING.2.11` owns the exact maintained-recipe inventory and
correction. This recipe uses the working explicit scalar destination.

The first investigation wrapper globally replaced `Get`, intercepted bootstrap
calls and caused unrelated setup failures. Those results are discarded as probe
errors. The reproduction below changes only the two calls inside the selected
test, leaving recursive/bootstrap calls untouched.

## Exact reproduction

```bash
bash tools/project_data_run.sh env PERL5LIB= python3 - <<'CODE_SLOT_OBSERVATION'
from pathlib import Path
import json, re, subprocess

work = Path('.linkedspec-data/scratch/code-slot-observation')
work.mkdir(parents=True, exist_ok=True)
source = Path('t/phase0_regression.t').read_text()
name = 'method_like_remaining_lifecycle_inline_composite_switch_lower_equivalently'
start = source.index("subtest '" + name + "'")
end = source.index('\nsubtest ', start + 1)
block = source[start:end]
assert block.count('LinkedSpec::Get(') == 2
block = block.replace('LinkedSpec::Get(', 'probe_get(')
prefix = r'''use strict;
use warnings;
use Test::More;
use JSON::PP;
use LinkedSpec;
my $seen = 0;
sub probe_get {
    my ($captured, %ctx);
    my $d = LinkedSpec::Get(@_, dump_parser_source => 1,
        parser_source_ref => \$captured, runtime_ctx_ref => \%ctx);
    die 'descriptor missing' unless ref($d) eq 'HASH'
        && ref($d->{spec}) eq 'HASH' && ref($d->{spec}{Top}) eq 'HASH';
    my $rule = $d->{spec}{Top};
    my $bad_ok = eval { my $bad = ${$ctx{parser_source_chunks_ref}}; 1 };
    my $bad_error = $@;
    print STDERR JSON::PP->new->canonical->encode({
        probe => ++$seen, keys => [sort keys %$rule],
        slots => {map { $_ => exists($rule->{$_}) ? 1 : 0 }
            qw(ICODE LSCODE LECODE ECODE EXCODE ITCODE LXCODE ACODE)},
        source_bytes => length($captured), chunk_type => ref($ctx{parser_source_chunks_ref}),
        bad_scalar_deref_ok => $bad_ok ? 1 : 0, bad_error => $bad_error,
        original_return => index($captured, q{return ["semantic_annotation", {"items" => $events}]}) >= 0 ? 1 : 0,
        changed_return => index($captured, q{return ["changed_annotation", {"items" => $events}]}) >= 0 ? 1 : 0,
    }), "\n";
    return $d;
}
'''
for mode in ('pristine', 'changed_payload'):
    candidate = block
    if mode == 'changed_payload':
        a = candidate.index('my $block_spec =')
        b = candidate.index('\nSPEC', a)
        fixture = candidate[a:b]
        assert fixture.count('semantic_annotation') == 1
        candidate = candidate[:a] + fixture.replace(
            'semantic_annotation', 'changed_annotation') + candidate[b:]
    test = work / (mode + '.t')
    test.write_text(prefix + candidate + '\ndone_testing;\n')
    run = subprocess.run(['perl', '-Iperl', str(test)], capture_output=True, text=True)
    (work / (mode + '.tap')).write_text(run.stdout)
    (work / (mode + '.jsonl')).write_text(run.stderr)
    assert run.returncode == 0, (mode, run.stderr)
    assert len(re.findall(r'^        ok \d+(?: |$)', run.stdout, re.M)) == 48
    assert len(re.findall(r'^        1\.\.8$', run.stdout, re.M)) == 6
    rows = [json.loads(line) for line in run.stderr.splitlines()]
    assert len(rows) == 12
    for i, row in enumerate(rows):
        assert row['keys'] == ['dependency_refs', 'handler', 'meta', 're']
        assert not any(row['slots'].values())
        assert row['source_bytes'] > 0 and row['chunk_type'] == 'ARRAY'
        assert not row['bad_scalar_deref_ok'] and 'Not a SCALAR reference' in row['bad_error']
        emitted = i < 6  # I/LS/LE; this handler shape omits E/EX/IT bodies.
        changed = mode == 'changed_payload' and i % 2 == 1
        assert row['original_return'] == int(emitted and not changed)
        assert row['changed_return'] == int(emitted and changed)
    print(mode + ': 48 assertions PASS; 12 absent slots; I/LS/LE payloads and E/EX/IT omission verified')
print('Confirmed observation gap; neither test pass establishes target runtime equivalence.')
CODE_SLOT_OBSERVATION
```

Related facts: [[conformance-perl-consumer-reading]],
[[conformance-source-reading-coverage]], [[terse-attached-switch-split-ground-truth]].
