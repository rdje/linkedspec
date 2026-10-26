# Ordinary scalar arithmetic result continuations

Owner: TYPE-REFERENCE-BOOK.1.2.23.2.16; implementation23.3.16.1-.5.
Existing short methods: abs/floor/ceil/round/add/sub/mul/div/mod/clamp/min/max.
The prior Number-only chain boundary is intentional. The comprehensive fluent
directive extends their existing numeric/null results into compatible scalar,
text, generic and explicit container-producing operations. No new helper name,
Number subtype, strict equality or canonical num_* method spelling is added.

## Existing producer and overload authority

scalar-numeric-v1 keeps finite numeric/untrimmed decimal String inputs, numeric
outputs and invalid-to-null, rejecting Bool/null/containers/malformed values.
Unary methods take zero RHS; sub/div/mod one; clamp two; add/mul/scalar min/max
one or more. Preserve valid-shape source-before-operands order, first evaluated
values, finite/rounding/modulo rules, zero-divisor/null and free helper signatures.
Unambiguous malformed receiver shapes reject before source/operand effects, as
the public Perl reference already does. Free invalid-shape evaluation stays its
existing helper policy. Do not impose a global min/max shape normalization:
zero-extra Array min/max selects the reducer; one-or-more operands selects the
scalar helper. Preserve existing overloaded invalid-source/arity behavior and
separate Array reducer kinds/defects owned by SESSION-STARTUP-READING95.

## Result flow

Use the actual numeric/null result for compatible consumers. Examples:
2.add(3).cat("!")->5!,0.add(0).coalesce_nonempty("late").cat("!")->0!,
2.div(0).coalesce_nonempty(7).add(1)->8,
2.add(1).cat(",x").split(",").last().uppercase()->X.
Numeric/String prefixes and literal/named/selected/count/length/Hash/function/
reducer/default sources use the same result rule. String-prefix numeric methods
still apply their existing strict numeric conversion; trim is explicit when
needed, e.g." 2 ".trim().add(3).cat("!")->5!.
Container-only consumers reject until an explicit bridge/default returns a
container. Existing defaults remain lazy and retain actual Array/Hash values;
2.div(0).coalesce_nonempty(["a","b"]).last().uppercase()->B.
Evaluate source once, operands once in helper order, compute result before
consumer operands; later rebindings must not replace captured inputs/results.
Preserve current producer kinds and selected snapshots. Deferred/callable
vocabulary and complete domain/context/portable admission stay23.4.

## Public Perl baseline

Retained probe_scalar_arithmetic_results.pl uses Get/substitution/dumps/native
and independently fresh emitted routes. Twelve free producers yield
[3,3,4,3,5,3,6,3.5,1,10,3,5]; nested text consumers preserve corresponding
3!/3!/4!/3!/5!/3!/6!/3.5!/1!/10!/3!/5!. Canonical call/first/count/Array-reducer
source controls already yield four5! values. Invalid free controls remain null;
nested default/zero preserve8/0!. Array/scalar min/max controls give[3,4,ASO,5,4].
Unambiguous bad abs/add/clamp shapes are null/no-effects.

Plain twelve Number-method->cat, numeric->text->split and effect/default chains
retain raw DSL and fail handler compilation. String-prefix arithmetic remains
raw trim and fails host evaluation. Substitution shows residue; MethodLowering
_number_receiver_value_chain_return_family classifies arithmetic as Number,
whose loop only accepts Number links, while String loop only hands comparisons
to scalar dispatch. Nested source/operand/consumer already returns5!/SOC/null;
no producer/source capture defect is inferred. Reuse existing scalar result and
explicit container handoffs, assessing each backend independently before repair.

Two older numeric overview paragraphs still called comparisons terminal after
15.1-.5. This assessment corrects the doc defect to actual numeric result flow;
no implementation change is required for that correction. Arithmetic targets
above remain planned until each bounded implementation is targeted-checked.
