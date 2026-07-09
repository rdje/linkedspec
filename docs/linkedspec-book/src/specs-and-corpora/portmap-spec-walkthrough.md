# `portmap.spec` Walkthrough

`specs/portmap.spec` parses VHDL/Verilog port-map expressions — the signal connection lists that wire component instances to ports. It handles bare signal names, bit/slice forms (`sig[3]`, `sig[3:0]`), constants (`0x1F`, `0b101`, `4'1011`), and concatenations (`{sig1 sig2}`).

It demonstrates:

- bounded-delimiter rules (`/{/` and `/}/` for concatenation),
- complex regex with multiple capture groups and alternatives,
- multi-branch `if/elseif/else` classification logic,
- fluent continuation (`.push` on action edges),
- flat-array construction for AST output.

Read this after the [`Lispish.spec` Walkthrough](lispish-spec-walkthrough.md).

## How to run it

`portmap.spec` is the backend-neutral contract; any LinkedSpec backend can run it. The
reference (Perl) backend loads it by spec name:

```perl
use LinkedSpec;

my $parser = LinkedSpec::get_parser('portmap');
my $input = '{sig_a sig_b[7:0] 0x1f}';
my $ast = $parser->(\$input);
```

## Output shape

The AST is shown below in the Perl reference backend's value rendering (arrays);
another backend produces the equivalent structure in its own value types.

For a bare signal `clk`:

```json
["?bare:", ["clk"]]
```

For a single bit `bar[3]`:

```json
["?bit:", ["bar", "3"]]
```

For a slice `addr[7:0]`:

```json
["?slice:", ["addr", "7", "0"]]
```

For a constant `0x1f`:

```json
["?constant:", ["0x1f"]]
```

For a concatenation `{sig_a sig_b[7:0] 0x1f}`:

```json
[
  "?concatenation:",
  [
    ["?bare:", ["sig_a"]],
    ["?slice:", ["sig_b", "7", "0"]],
    ["?constant:", ["0x1f"]]
  ]
]
```

The first element of each array is a tag string (`?bare:`, `?slice:`, `?bit:`,
`?constant:`, `?concatenation:`, `?multi:`) that identifies the node kind. Scalar
classifications place the participating regex captures in the second element; a
concatenation places its child nodes in the second element.

## Rule inventory

| Rule | Mode | Role |
| --- | --- | --- |
| `portmap::` | Top (entry) | Entry point. Dispatches to `bare_bit_slice` and `concatenation`. |
| `concatenation` | `/{/` / `/}/` bounded regex | Parenthesized concatenation. Recursive self-call + `bare_bit_slice`. |
| `bare_bit_slice` | Ungrounded regex with 5 capture groups | Single port expression: signal name, optional bit slice, or constant. |

The `portmap` entry rule uses `.push` fluent continuation on its action edges. In `LX`, it checks: if exactly one item accumulated, return it directly; otherwise return the array tagged `?multi:`.

The `concatenation` rule does the same with `?concatenation:` tagging on its closing-bracket action edge (`[1]`).

## Key design points

**Single regex, multiple classifications.** The `bare_bit_slice` rule uses one complex regex that captures all possible forms:

```text
/([[:alpha:]]\w*)(?:\[(?:(\d+)(?::(\d+))?|(\?[[:alpha:]]\w+))\])?|(?i)(0x[0-9a-f]+|0b[01]+|\d+\'\d+)/
```

The `if/elseif/else` chain in its `I` block then classifies the match: if the entry text contains `:`, it's a slice; if entry group 1 is non-empty/zero, it's a bit; if entry group 0 starts with a digit, it's a constant; otherwise it's a bare signal.

**Tags as AST discriminators.** The `?prefix:` tag convention makes AST nodes self-describing without requiring the caller to know the regex structure. Each tag tells downstream code what shape to expect in the remaining array elements.

**Flat arrays for compact output.** Rather than building hash-per-node (as `Lispish.spec` does), `portmap.spec` uses `flat_array(...)` to produce compact tagged arrays. This is a stylistic choice appropriate for hardware signal lists where the schema is fixed and verbosity would add noise.

## Descriptor readiness

The `portmap.spec` compiles with `language_agnostic_ready_ratio == 1.0000` — zero raw-Perl dependency. All helpers (`set`, `return`, `copy`, `flat_array`, `entry_groups`, `if/elseif/else/endif`, `matches`, `or`, `str_eq`, `is_nonempty`, `num_eq`, `count`) are canonical ActionIR.

## Why this spec is interesting

Portmap shows LinkedSpec handling a real hardware-description task: parsing VHDL/Verilog port connections. The spec is only 33 lines but handles nested concatenations, multiple signal forms, and produces structured output. It's a good example of how a single well-crafted regex with classification logic can replace what would otherwise require multiple grammar rules in a traditional parser-generator.
