# Helper spellings and syntax roles

Owner: `TYPE-REFERENCE-BOOK.1.2.1.2.1`. This is the spelling/role spine; signatures, result kinds, effects and backend limits remain next child `.1.2.1.2.2`. Receiver transitions belong to `.1.2.1.3`, comprehensive useful families to `.1.2.23`. No complete API or semantic parity claim is made.

## Authorities and interpretation

- `dart/lib/src/action/action_contracts.dart`: supportedActionIrCallNames, separate alias sets/maps and _familyForCanonical. Resolver categories are not runtime input types or receiver-method guarantees.
- `tools/check_language_capability_coverage.pl`: shared spelling/reverse-contract checks and explicit non-generic classification. Report mode alone does not reject missing entries.
- `perl/LinkedSpec/ActionIR/Contracts.pm` and `perl/LinkedSpec/RuleIR/EmitContext.pm`: Perl contract names use diag_name; executable callbacks cannot be directly JSON-serialized as a method catalog. Pure helpers need not have separate contract rows.
- `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`, the formal grammar and `capability_conformance/` own signatures/semantics. The ledger is `docs/checkpoints/type-reference-inventory/README.md`; frozen captures are historical, not resume producers.

An entry means its source registry recognizes the spelling, not that every context executes it or every helper has a receiver counterpart. split is classified as array because of its result; copy and traversals span containers. Binding targets, callbacks, marker chains, parser state and child dispatch keep their own shapes.

## Primary spellings by resolver category

| Resolver category | Source spellings |
| --- | --- |
| control / invocation | `and`, `call`, `case`, `default`, `else`, `elseif`, `endcase`, `endif`, `endswitch`, `exit_now`, `if`, `next`, `not`, `or`, `return`, `return_undef`, `switch`, `while`, `with` |
| array | `array`, `concat_arrays`, `contains`, `count`, `drop_back`, `drop_front`, `filter_match`, `filter_nonempty`, `first`, `flat_array`, `index_of`, `is_empty`, `is_nonempty`, `join_values`, `last`, `lowercase_each`, `pop_back`, `pop_front`, `push`, `push_back`, `push_front`, `reversed`, `slice`, `sorted`, `split`, `split_each`, `split_tagged_records`, `take`, `take_last`, `trim_each`, `uniq`, `uppercase_each` |
| capture / marks | `capture_between`, `capture_from`, `capture_len_between`, `capture_len_from`, `capture_rest`, `capture_rest_from`, `capture_rest_len`, `capture_rest_len_from`, `capture_slice`, `capture_slice_col`, `capture_slice_len`, `capture_slice_line`, `capture_slice_pos`, `capture_slice_until_cursor`, `capture_slice_until_cursor_len`, `capture_until_boundary`, `capture_take`, `capture_take_between`, `capture_take_between_len`, `capture_take_len`, `capture_take_len_from`, `capture_take_rest`, `capture_take_rest_from`, `capture_take_rest_len`, `capture_take_rest_len_from`, `capture_take_until_cursor`, `capture_take_until_cursor_from`, `capture_take_until_cursor_len`, `capture_take_until_cursor_len_from`, `capture_until_cursor_from`, `capture_until_cursor_len_from`, `clear_mark`, `mark_capture_slice`, `mark_col`, `mark_copy`, `mark_entry_end`, `mark_entry_start`, `mark_exists`, `mark_here`, `mark_input_end`, `mark_input_start`, `mark_line`, `mark_match_end`, `mark_match_start`, `mark_pos`, `start_capture_slice`, `start_capture_slice_from` |
| string | `cat`, `coalesce`, `coalesce_nonempty`, `contains_substr`, `ends_with`, `length`, `lowercase`, `matches`, `replace_substr`, `rm_prefix`, `rm_suffix`, `starts_with`, `str_eq`, `str_ge`, `str_gt`, `str_le`, `str_lt`, `str_ne`, `substr`, `trim`, `uppercase` |
| container | `copy`, `flat`, `map_leaves`, `reduce_leaves`, `walk_leaves` |
| harray | `count_keys`, `drop_keys`, `flat_hash`, `has_key`, `hash`, `merge_hash`, `pick_keys`, `rename_key`, `set_key`, `sorted_keys`, `sorted_values` |
| input / cursor | `cursor_col`, `cursor_line`, `cursor_pos`, `cursor_rest`, `cursor_rest_len`, `input_end_col`, `input_end_line`, `input_end_pos`, `input_len`, `input_slice`, `input_text` |
| entry / match | `entry_col`, `entry_end_col`, `entry_end_line`, `entry_end_pos`, `entry_group`, `entry_groups`, `entry_has`, `entry_len`, `entry_line`, `entry_map`, `entry_named`, `entry_start_col`, `entry_start_line`, `entry_start_pos`, `entry_text`, `match_col`, `match_end_col`, `match_end_line`, `match_end_pos`, `match_group`, `match_groups`, `match_has`, `match_len`, `match_line`, `match_map`, `match_named`, `match_start_col`, `match_start_line`, `match_start_pos`, `match_text` |
| inter-match gap | `entry_slot`, `gap_kind`, `gap_span`, `gap_text` |
| helper | `is_defined`, `is_undefined` |
| numeric | `num_abs`, `num_add`, `num_avg`, `num_ceil`, `num_clamp`, `num_div`, `num_eq`, `num_floor`, `num_ge`, `num_gt`, `num_le`, `num_lt`, `num_max`, `num_median`, `num_min`, `num_mod`, `num_mul`, `num_ne`, `num_range`, `num_round`, `num_sub`, `num_sum` |
| output | `print`, `print_each`, `say` |
| runtime cursor effects | `restore_cursor`, `rewind_entry_start`, `rewind_match_start`, `save_cursor` |
| assignment | `set` |

## Current aliases

Numeric symbolic spellings are prefix/helper-call forms, not blanket host infix arithmetic. Numeric comparisons follow the numeric contract; str_eq/str_ne/etc. are separate string comparisons.

| Canonical helper | Numeric aliases |
| --- | --- |
| `num_add` | `+`, `add` |
| `num_sub` | `-`, `sub` |
| `num_mul` | `*`, `mul` |
| `num_div` | `/`, `div` |
| `num_mod` | `%`, `mod` |
| `num_eq` | `==`, `eq` |
| `num_ne` | `!=`, `ne` |
| `num_gt` | `>`, `gt` |
| `num_ge` | `>=`, `ge` |
| `num_lt` | `<`, `lt` |
| `num_le` | `<=`, `le` |
| `num_abs` | `abs` |
| `num_avg` | `avg` |
| `num_ceil` | `ceil` |
| `num_clamp` | `clamp` |
| `num_floor` | `floor` |
| `num_max` | `max` |
| `num_median` | `median` |
| `num_min` | `min` |
| `num_range` | `range` |
| `num_round` | `round` |
| `num_sum` | `sum` |

| Current nonnumeric alias | Canonical spelling and role limit |
| --- | --- |
| `=` | `set`; binding-target call shape; bare assignment is separate syntax |
| `elif` | `elseif`; elseif marker chain |
| `i` | `if`; if marker chain |
| `otherwise` | `else`; else attached chain |
| `when` | `if`; if attached chain |

Do not interchange marker/attached aliases merely because canonical names agree; FUTURE-PARITY-BACKLOG.5 owns existing backend acceptance differences. Bare assignment, += and indexed writes remain syntax operations.

## Source-boundary compatibility aliases

These belong to a separate compatibility set, not new primary portable helpers or fluent methods.

| Compatibility spelling | Canonical target |
| --- | --- |
| `capture_from_rule_start` | `capture_slice` |
| `capture_from_rule_start` | `capture_slice` |
| `capture_len_from_rule_start` | `capture_slice_len` |
| `capture_rest_length` | `capture_rest_len` |
| `capture_slice_here` | `start_capture_slice` |
| `capture_slice_length` | `capture_slice_len` |
| `entry_named_map` | `entry_map` |
| `match_named_map` | `match_map` |

## Dedicated, internal and legacy forms

The reverse Perl-contract check excludes these diagnostics from ordinary generic helpers. Diagnostic names are not public authoring syntax. Recognition/dispatch and parse-job annotation retain their dedicated contracts; legacy capture/selector forms are not revived.

| Diagnostic | Source-owned classification |
| --- | --- |
| `array_append_operator` | internal lowering operation |
| `array_end_mutation_method` | internal lowering operation |
| `capture` | legacy capture surface |
| `capture_macro` | legacy capture surface |
| `dispatch_span` | cross-backend dedicated private intrinsic, not an ordinary generic helper call |
| `entry_named_map` | documented compatibility alias |
| `hash_index_assignment_operator` | internal lowering operation |
| `match_named_map` | documented compatibility alias |
| `observe_recognition` | grammar-owned dedicated intrinsic |
| `parse_job` | public dedicated assignment annotation, not an ordinary generic helper call |
| `recognition_checkpoint` | grammar-owned dedicated intrinsic |
| `recognition_commit` | grammar-owned dedicated intrinsic |
| `recognition_rollback` | grammar-owned dedicated intrinsic |
| `recognize_once` | grammar-owned dedicated intrinsic |
| `scalar_assignment_operator` | internal lowering operation |
| `value_drop` | internal lowering operation |

## Remaining semantic work

- Map each primary spelling/overload to actual signature/arity, input/result kind, mutation/copy, callback scope, error/empty behavior and backend limits; never infer these from resolver families.
- Reconcile book/reference compatibility names such as array_copy, hash_copy and regex_subst with actual owners before treating them as shared generic helpers. User-function/codeblock invocation is a separate callable role.
- Keep known fixes/limits explicit: ordinary Perl pipelines preserve inputs/kinds and dynamic split_each scalar delimiters work in values/statements. Deferred helper vocabulary, escape fidelity and remaining parity decisions keep existing owners.
- Select bounded missing implementations from this spine. Runtime matrices, portable admission and final comprehensive per-type claims follow feature coverage.
