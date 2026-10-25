# Numeric conversion repair boundary — SESSION-STARTUP-READING.55.1

This is the pre-repair design and consumer audit, not a new cross-backend or
arbitrary-precision admission. The actual census supplies the tracked first-party
Rust population, whole input bytes and four search outputs. Text matches guide
manual review; they are not a type-resolved call graph or execution coverage.

| Producer / boundary | Actual consumers and decision |
| --- | --- |
| `core/types.rs` numeric `to_json` | Direct and accumulator finalization in `engine.rs`; recursive arrays/hashes; recognition payloads; span arguments sent to child authorities. Four finite-whole casts currently saturate across JSON, `to_str`, numeric `len`, and `Display`. Use checked signed/unsigned integer projection and floating fallback. |
| Numeric `to_str` | Engine text comparison/switch, split/join/regex, scalar transforms, filtering/uniqueness/sorting, diagnostics, lifecycle scalar text, hash literals and keys/rename/pick/drop. A shared checked integer formatter fixes these consumers without separate copies. `length(number)` uses this text's character count; native numeric `len` uses its byte count, identical for numeric ASCII. Aggregate Display recurses. |
| `to_scalar_text` / `cat` | Separate finite f64 formatter and strict scalar rejection, not the saturating path. Leave frozen scalar-text authority and this function unchanged; `.55.2` owns shortest/portable decimal versus scientific spelling. |
| Raw serde / source emission | `RuntimeValue`, Expr/SpecFile/CompiledSpec text serialization, generated-plan JSON decoder and `source_emitter.rs` embedded compiled JSON. Numeric serde is a different producer from `to_json`. The captured native baseline actually loses the two representable neighbors immediately inside the i64 limits. Compare the same test under `serde_json/float_roundtrip` before enabling that feature in the workspace. |
| `runtime.rs::runtime_value_from_json` | Recurses JSON numbers/arrays/objects; bounded child return payloads, typed source/span records, regex occurrence observations and recognition-commit payloads; `staged_parse_job.rs` creates v2 records through it. Existing binary64 storage intentionally rounds nonrepresentable integer inputs. No actual fallback-to-zero failure is established. Exercise the real progressive child callback with finite numeric nested payloads and existing source-record contracts. |
| `spec_parser.rs::usize_field` | Embedded grammar's function-definition versions, arity/signature and source span/line fields. u64 path is checked; floating fallback is not range checked. Apply a shared checked finite-whole-to-usize utility. The real grammar produces source-sized metadata; huge authored AST fields remain a private-boundary control, not a claimed reachable source-language failure. |
| `staged_parser_registry.rs::usize_field` | Public legacy v1 job start/end/line fields. Same checked u64 versus unchecked floating fallback. Measure the real public job dispatcher; keep v2's separate checked integer protocol intact. |
| Positive nested-write classifier | `<= usize::MAX as f64` admits the rounded first out-of-range power of two on 64-bit. Check the exclusive exact power-of-two bound before any cast; retain dense append/gap and signed tail-relative behavior, error identity and evaluation order. |
| Remaining numeric casts | Legacy read/capture selectors and bounded take/drop/slice/substr/gap widths clamp or bound against real containers/source. Keep their coercion/overload contracts; no blanket cast replacement. Legacy `literal_usize_arg` also selects a two-argument child-push overload; changing it would alter effects, not merely conversion. Staged direct-text numeric group uses checked `usize::try_from(value as u128)` and already rejects this host-range overflow. |
| Non-numeric same-name matches | Descriptor and diagnostic `to_json`, filesystem `Path::to_str`, usize-to-u64 source offsets/counts, fixed small test fixture conversions and ordinary container `len` are not the f64 saturation producer. |

The coherent representation remains `RuntimeValue::Number(f64)`: signed64 exact
integer JSON where representable, then unsigned64 exact integer JSON where
representable, then finite floating JSON. Bounds are exclusive powers of two,
never inclusive rounded integer maxima. Floating negative zero retains its sign
in JSON; existing scalar text zero and nonfinite JSON-null policy remain. Numeric
text/Display/length retain exact integer spelling inside those integer domains and
use the existing f64 formatter outside them. The provisional all-whole-values
mathematical integer expansion was overstrict; its full inputs/outcome are retained
in `fixture-qualification.json.gz`, and earn no portable spelling admission.

The SDK exposes separate `float_roundtrip` and `arbitrary_precision` features
([published feature table](https://docs.rs/crate/serde_json/1.0.150/features)); only
the former is proposed, subject to the actual captured distinguishing control.
No dependency version/pin or transitive implementation change is proposed.

Before source edits, the fresh historical audit identifies `rust/Cargo.toml` and
`engine.rs` as exact-bound historical inputs. Their numeric evolution requires a
new owner-bound admission; the signed-selector predecessor hashes/results remain
unchanged. Ordinary historical claims are not refreshed to current source hashes.
