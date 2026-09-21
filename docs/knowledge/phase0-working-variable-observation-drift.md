---
id: phase0-working-variable-observation-drift
title: Phase0 working-variable checks retain obsolete wrapper and declaration-deferral claims
answers:
  - does fluent push items still defer its Perl lexical declaration
  - which Phase0 working-variable test misses a removed scalar declaration
  - why do working-variable dedup tests still describe wrapped targets
  - which task owns Phase0 working-variable observation drift
  - which migrated Phase0 equivalence tests compare identical current inputs
  - which bounded repair leaves own declaration contrast and description drift
date: 2026-09-21
status: confirmed test observation and description drift; .2.14 repair retains required reading prerequisites
tags: [perl, phase0, working-variables, tests, uniform-binding, observation-gap]
evidence: "CONFORMANCE-SOURCE-READING.1.78 at 2defd6def6f2fab08ac62e5b2f119186dc26cb9a. The exact fluent fixture captures 12,795 bytes with one my $items and no my @items. Its six authored assertions pass pristine and after deleting that scalar declaration from the observed source. A positive scalar-declaration control distinguishes the two. Adjacent dedup fixtures now use bare targets/reads despite wrapped-target descriptions."
reverify: "Run WORKING_VARIABLE_OBSERVATION below through the repository-local wrapper. It probes current public generated source and test sensitivity without changing production or executing target parser branches."
---

## Mechanism and repair ownership

`spec_format_terse_1_2_1_bare_arg_position_auto_exists` generates this fixture:

```text
top:: -> w.push(items)
 LX { return(count) }

w : /(\w+)/  I.return(match_group(0))
```

Public `Get` with `generate_only`, `dump_parser_source` and `parser_source_ref`
captures one `my $items;` and zero `my @items` declarations. Its 12,795-byte size
is a dated observation, not an output-size contract. The test's sixth assertion
only denies `my @items` and says the child-append target is deferred and not
auto-declared. That description no longer matches the current scalar-held binding.

Deleting only `my $items;` from the observed fluent source leaves all six
authored assertions passing. A scratch seventh assertion positively observes
the scalar declaration: pristine passes and the deletion fails that assertion.
Compiler calls and other generated fixtures remain unchanged. No production
leak or parser-runtime failure is established by this observation mutation.

The adjacent `spec_format_terse_1_2_1_dedup_with_wrapped_and_setup_single_my`
test still describes wrapped targets and reads, although its current source uses
bare `set(count, ...)`, `return(count)` and `copy(items)`. Its first two scalar
fixture expressions are identical. Their declaration-count assertions remain
meaningful, but they no longer distinguish a bare case from a wrapped case.
Historical channel comments and sigil claims throughout this family need an
explicit current-contract audit, including the unread continuation in group 79.

Group 79 has now read that continuation and the adjacent migrated helper tests.
Its extension to `.2.14` owns these additional bounded observation mismatches:

- `spec_format_terse_1_2_3_3_3_direct_access_bare_path_atoms_auto_exist`
  compares `return(foo["a"][z])` with itself while describing an explicit-index
  contrast. Its separate exact lowering and runtime result remain useful.
- `spec_format_terse_1_4_1_set_is_full_assign_alias` compares the node set for
  `set(x, 1)` with itself. The old alias claim is unsupported by that comparison;
  the exact assignment lowering and lexical placement/count checks remain useful.
- `spec_format_terse_1_4_1_terse_spec_runs_identically_to_canonical` builds two
  byte-identical current-spelling fixtures. It checks repeat compilation and
  concrete `["a!","b!","c!"]` results, but does not distinguish helper renames.
- `spec_format_terse_1_5_3_call_spacing_and_parentheses_locks` has one identical
  `return(name)` pair labeled a whitespace contrast. Five other pairs actually
  differ in spacing. Their normalized-node comparisons retain that distinction.
- The scalar-assignment test labels a `set(name, entry_group(1))` fixture as a
  `name=entry_group(1)` keyword argument. The append test's deferred-read comment
  also predates its current bare-binding contract.

Repeated exact expectations elsewhere are not automatically defects. In
particular, the explicit mixed-path test repeats its expected dereference chain;
the repair should describe or consolidate that redundancy without claiming a
missing runtime result. Genuine scalar-assignment/set and append/push contrasts,
typed nested-write versus harray-only set_key distinctions, mutation results and
repeated-invocation controls must survive. No production failure follows from
these source-qualified observation limits, and no sensitivity mutation of these
additional comparisons is claimed.

Group 80 extends the description audit to the shape-binding `.11_2` and array-end
`.1_6` tests: their current bare targets/receivers are still called explicit
aggregate selectors in comments or labels. The aggregate assignment `.3_3_2`
introduction also calls retired selector targets temporary aliases; its body
continues in group 81. The array receiver-chain test's missing receiver is a
different case: public capture confirms zero scalar declarations and an
undeclared host-array read. Do not invent a missing positive declaration there.
Its demonstrated host-state sensitivity is owned by startup `.17.1` and recorded
in [[perl-wrong-kind-collection-host-slot-drift]].

Group 81 completes `.3_3_2`: two repeated current `set` cases still claim
temporary explicit aggregate targets, and its runtime label mentions a scalar
wrapper that the fixture no longer uses. The quoted-constructor `.2_3_5_6`
and `.11_2` value-memory tests also retain wrapper/view wording. The `.2_1_2`
block introduction calls retired fat-arrow braces current hash literals, even
though its assertions correctly use colon pairs. Their concrete results survive.

The repair now has three bounded children: `.2.14.1` for actual declaration
sensitivity, `.2.14.2` for meaningful migrated comparisons, and `.2.14.3` for
remaining descriptions and associated maintained guidance. Each retains required
reading and its own verification/commit boundary; this decomposition closes none.

`CONFORMANCE-SOURCE-READING.2.14` owns that bounded repair after required
source/book/policy reading. It must observe actual nonempty scalar-held binding
declarations, reject declaration removal/duplication, preserve distinct setup,
per-invocation and recursion controls, correct descriptions and maintained
guidance, and avoid restoring retired wrapper syntax merely to fit old tests.
The historical channel chronology in [[terse-bare-working-vars-engine-gaps]]
does not override the current [[perl-uniform-binding-runtime]] contract.

## Reproduction

For the group-79 extension, inspect the named subtests in the unchanged Phase0
source and use this public lowering probe. It confirms current outputs; the
identical fixture inputs themselves establish the missing contrast. The retained
canonical run at `ec10be6b06934ba87c8c41b1f1f8d079714564a7` passes all nineteen
completed group-79 subtests (ordinals 983–1001, 246 direct assertions).

```bash
bash tools/project_data_run.sh perl -Iperl - <<'CURRENT_BINDING_LOWERING'
use strict; use warnings; use Test::More; use LinkedSpec;
is(LinkedSpec::call_spec_handler_subst('Top', 'return(foo["a"][z])'),
   'return $foo->{"a"}->[$z]', 'current mixed-path lowering');
is(LinkedSpec::call_spec_handler_subst('Top', 'set(x, 1)'),
   '$x = 1', 'current scalar assignment lowering');
is(LinkedSpec::call_spec_handler_subst('Top', 'return(name)'),
   'return $name', 'current bare scalar read');
done_testing();
CURRENT_BINDING_LOWERING
```

```bash
bash tools/project_data_run.sh python3 - <<'WORKING_VARIABLE_OBSERVATION'
from pathlib import Path
import os, re, subprocess

work = Path('.linkedspec-data/scratch/working-variable-observation-reverify')
work.mkdir(parents=True, exist_ok=True)
source = Path('t/phase0_regression.t').read_text()
name = 'spec_format_terse_1_2_1_bare_arg_position_auto_exists'
matches = re.findall(r"^subtest '" + name + r"' => sub \{\n.*?(?=^subtest |\Z)",
                     source, re.M | re.S)
assert len(matches) == 1
block = matches[0]
line = next(x for x in block.splitlines()
            if x.strip().startswith('my $fluent_src = $gen->('))
assert block.count(line) == 1 and block.count('plan tests => 6;') == 1
observe = r'''    diag('real fluent scalar declarations=' . scalar(() = $fluent_src =~ /my \$items\b/g));
    $fluent_src =~ s/^my \$items;\n//m if $ENV{PROBE_DROP_DECL};
'''
block = block.replace(line, line + '\n' + observe)
guarded = block.replace('plan tests => 6;', 'plan tests => 7;')
end = guarded.rindex('};')
positive = r'''    like($fluent_src, qr/my \$items\b/, 'positive control observes current fluent typed binding declaration');
'''
guarded = guarded[:end] + positive + guarded[end:]
for filename, text in [('original.t', block), ('guarded.t', guarded)]:
    (work / filename).write_text('use strict; use warnings; use Test::More; use LinkedSpec;\n'
                                + text + '\ndone_testing();\n')
for label, filename, drop, expected in [
    ('original-pristine', 'original.t', False, 0),
    ('original-dropped', 'original.t', True, 0),
    ('guarded-pristine', 'guarded.t', False, 0),
    ('guarded-dropped', 'guarded.t', True, 1),
]:
    env = dict(os.environ, PERL5LIB='')
    env.pop('PROBE_DROP_DECL', None)
    if drop:
        env['PROBE_DROP_DECL'] = '1'
    result = subprocess.run(['prove', '-v', '-Iperl', str(work / filename)],
                            env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (work / (label + '.log')).write_text(result.stdout)
    assert result.returncode == expected, (label, result.returncode, result.stdout)
    assert 'real fluent scalar declarations=1' in result.stdout, label
    failures = re.findall(r'^    not ok (\d+) - (.+)$', result.stdout, re.M)
    assert failures == ([('7', 'positive control observes current fluent typed binding declaration')]
                        if expected else []), (label, failures)
    plan = 7 if filename == 'guarded.t' else 6
    assert f'    1..{plan}' in result.stdout, label
    assert '    ok 6 - fluent .push(items) child-append target is deferred' in result.stdout, label
    print(label, 'PASS: expected observation sensitivity', flush=True)
WORKING_VARIABLE_OBSERVATION
```

After repair, the historical six-assertion reproduction may require its activation
commit. The defective description and assertion are not preservation requirements.

Related: [[phase0-cursor-source-observation-gap]],
[[phase0-array-assignment-description-drift]], [[conformance-perl-consumer-reading]].
