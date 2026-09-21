---
id: phase0-array-assignment-description-drift
title: Four Phase0 list-context labels misdescribe scalar-held array assignments
answers:
  - why do four Phase0 assignment tests claim list-context flattening
  - who owns sorted_keys sorted_values sorted and reversed assignment descriptions
  - do sorted helper assignment probes return scalar-held arrays
  - how can I reproduce Phase0 array assignment description drift
date: 2026-09-21
status: confirmed description drift; CONFORMANCE-SOURCE-READING.2.12 owns correction after required reading
tags: [perl, phase0, tests, assignment, descriptions]
evidence: "Reading .1.71 at a9b874f7b704ca9fa7446944d7767077eb256afb. Four exact authored subtests pass sixteen assertions. Four public call_spec_handler_subst outputs assign ARRAY references to scalar bindings and execute with expected contents. Production/test source is unchanged."
reverify: "Run ARRAY_ASSIGNMENT and EXACT_ASSIGNMENT_TESTS below through tools/project_data_run.sh from the repository root; require all four assignment results and all sixteen authored assertions."
---

## Observed mismatch and repair

The fourth assertion in each of these `t/phase0_regression.t` subtests says
“list-context flattening,” while its actual pattern matches a scalar assignment:

| Subtest helper suffix | Description line at activation | Observed binding |
| --- | --- | --- |
| `sorted_keys_value_helpers` | 37778 | `$keys_out` |
| `sorted_values_value_helpers` | 37890 | `$values_out` |
| `sorted_array_value_helpers` | 38110 | `$ordered` |
| `reversed_array_value_helpers` | 38218 | `$reversed_parts` |

Each full name begins `emit_context_lowers_`. The exact phrase occurs four times
in the current Phase0 source. Public lowering and execution of those exact
assignment inputs confirm the outer assignment receives an array reference.
For a hash with kind=NODE and source=rule, adding stage=normalized produces keys
`[kind, source, stage]` and values `[NODE, rule, normalized]`; the latter follow
**key order**, not value sorting. With parts `[beta, alpha, gamma]` plus delta,
sorting yields `[alpha, beta, delta, gamma]` and reversing yields
`[delta, gamma, alpha, beta]`.

The root mismatch is between assertion prose and the observation it labels.
The assertions pass because they correctly match `$target = ...`, and do not
test the prose's claim. Nested array literals still construct elements in list
context, including concat_arrays source flattening. That internal construction
does not turn the outer scalar binding into a list assignment. This diagnosis
does not classify every mention of list construction as wrong.

`CONFORMANCE-SOURCE-READING.2.12` owns precise description corrections, retained
assertion strength, four-case focused verification and Knowledge/book sync after
required source/book/policy reading. No production lowering change or retired
namespace selector is needed. This observation establishes no runtime failure.
The sixteen original assertions pass freshly; the extra four result probes are
diagnostic controls, not newly committed tests or full-parser execution.

## Reproduce the public observation

```sh
bash tools/project_data_run.sh perl -Iperl <<'ARRAY_ASSIGNMENT'
use strict;
use warnings;
use LinkedSpec;
use JSON::PP;
my @rows;
for my $case (
 ['keys_out', 'sorted_keys', 'merge_hash(meta, hash("stage", "normalized"))', ['kind','source','stage']],
 ['values_out', 'sorted_values', 'merge_hash(meta, hash("stage", "normalized"))', ['NODE','rule','normalized']],
 ['ordered', 'sorted', 'concat_arrays(parts, ["delta"])', ['alpha','beta','delta','gamma']],
 ['reversed_parts', 'reversed', 'concat_arrays(parts, ["delta"])', ['delta','gamma','alpha','beta']],
) {
 my ($target,$helper,$operand,$expected)=@$case;
 my $input='set('.$target.', '.$helper.'('.$operand.'))';
 my $lowered=LinkedSpec::call_spec_handler_subst('Top',$input);
 die 'missing scalar assignment' unless index($lowered, '$'.$target.' = ') == 0;
 my $runner=eval 'sub { my %meta=(kind=>"NODE",source=>"rule"); my @parts=("beta","alpha","gamma"); my $'.$target.'; '.$lowered.'; return $'.$target.'; }';
 die $@ unless $runner;
 my $result=$runner->();
 die 'not an arrayref' unless ref($result) eq 'ARRAY';
 die 'wrong values' unless JSON::PP->new->canonical->encode($result) eq JSON::PP->new->canonical->encode($expected);
 push @rows,{helper=>$helper,input=>$input,lowered=>$lowered,result_ref=>ref($result),result=>$result};
}
print JSON::PP->new->canonical->pretty->encode({status=>'PASS',signature=>'SCALAR_ARRAY_ASSIGNMENT',observations=>\@rows});
ARRAY_ASSIGNMENT
```

Expected signature: `SCALAR_ARRAY_ASSIGNMENT`, status PASS, four observations
whose `result_ref` is ARRAY and whose results match the examples above.

## Execute the exact authored subtests

The extraction below checks unique exact names and four-assertion plans, writes
only a repository-local scratch test, and executes the original bodies unchanged.

```sh
bash tools/project_data_run.sh python3 - <<'EXACT_ASSIGNMENT_TESTS'
from pathlib import Path
import re, subprocess
source = Path('t/phase0_regression.t').read_text()
chunks = []
for helper in ['sorted_keys', 'sorted_values', 'sorted_array', 'reversed_array']:
    name = 'emit_context_lowers_' + helper + '_value_helpers'
    matches = re.findall(r"^subtest '" + name + r"' => sub \{\n.*?(?=^subtest |\Z)",
                         source, re.M | re.S)
    assert len(matches) == 1, name
    chunk = matches[0]
    assert chunk.endswith('};\n') and chunk.count('plan tests => 4;') == 1, name
    chunks.append(chunk)
work = Path('.linkedspec-data/scratch/array-assignment-description-reverify')
work.mkdir(parents=True, exist_ok=True)
target = work / 'focused.t'
target.write_text('use strict; use warnings; use Test::More; use LinkedSpec; '
                  'require LinkedSpec::RuleIR::EmitContext;\n' +
                  ''.join(chunks) + 'done_testing();\n')
subprocess.run(['prove', '-v', '-Iperl', str(target)], check=True)
EXACT_ASSIGNMENT_TESTS
```

After correction, all four exact subtests and result probes should still pass,
and the misleading assignment descriptions should be absent. Reproduction of
this historical mismatch is not a requirement to retain the bad descriptions.
