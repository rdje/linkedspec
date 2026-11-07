"""Update public behavior and durable facts only after the focused proof passes."""
import gzip
from pathlib import Path

BASE = Path(__file__).resolve().parent
assert (BASE / 'readonly-review/exit.txt').read_text() == '0\n'
assert gzip.decompress((BASE / 'readonly-review/stderr.log.gz').read_bytes()) == b''
p = Path('docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md')
s = p.read_text()
old_anchor = 'array-transform-continuations-guarded-perl-results'
new_anchor = 'array-transform-continuations-guarded-perl-and-rust-results'
s = s.replace('### Array transform continuations: guarded Perl results',
              '### Array transform continuations: guarded Perl and Rust results', 1)
s = s.replace('`concat_arrays` return Arrays. Their ordinary Perl results now retain actual-kind',
              '`concat_arrays` return Arrays. Their ordinary Perl and Rust results now retain actual-kind', 1)
s = s.replace('The bounded Perl forms retain their existing arities:',
              'The bounded Perl and Rust forms retain their existing arities:', 1)
old = '''Perl composition78.1.1 is focused-checked on native and full emitted-fresh routes;
regenerate previously emitted Perl to receive these guards. Independent Rust78.2
assessment and full source/context/admission remain open.'''
new = '''Rust retains its own initial Number/null/Hash source behavior. The following
compatibility examples describe Rust, and do not extend portable input authority:

```text
take(3,1)                         # []
sorted({"k":1})                    # []
concat_arrays(undef,["tail"])       # [null,"tail"]
concat_arrays(3,["tail"])           # [3,"tail"]
```

The first producer keeps that policy; its resulting Array then owns subsequent
kind checks. Earlier produced or copied values keep their existing guards.
Omitted take/drop counts retain the default of one, and `slice` with an omitted
count keeps the remaining tail. Malformed or variadic calls retain their existing
backend behavior and gain no new guarded-result authority.

Perl composition78.1.1 is focused-checked on native and full emitted-fresh routes;
regenerate previously emitted Perl to receive these guards. Rust78.2 is
focused-checked on native, restored compiled state, generated plans and compiled
emitted-fresh routes; rebuild Rust applications/runtime. Independent Dart78.3,
Julia and Lua assessments and full source/context/admission remain open.'''
assert s.count(old) == 1
p.write_text(s.replace(old, new))
p = Path('docs/linkedspec-book/src/appendix/helper-contract-catalog.md')
s = p.read_text().replace('and rejection guards on bounded Perl routes.',
                         'and rejection guards on bounded Perl and Rust routes.', 1)
s = s.replace("guarded concat forms are free-two/receiver-one. Source-isolation78.0's Number-AST\nfences remain. Other backends, variadic concat continuations and full admission\nare independently owned. Regenerate affected emitted Perl. See the",
              "guarded concat forms are free-two/receiver-one. Source-isolation78.0's Perl Number-AST\nfences remain; Rust retains its own Number/null/Hash source policy, including scalar\nconcat elements. Dart/Julia/Lua, variadic concat continuations and full admission\nare independently owned. Regenerate affected emitted Perl; rebuild Rust applications/runtime. See the")
assert old_anchor in s
p.write_text(s.replace(old_anchor, new_anchor))

card = Path('docs/knowledge/rust-array-transform-result-guards.md')
assert not card.exists()
card.write_text('''---
id: rust-array-transform-result-guards
title: Rust ordinary Array results own guards after their original producer policy
answers:
  - "why does Rust take set_key still evaluate Hash operands"
  - "which Rust guard paths own ordinary Array transform results"
  - "does Rust concat_arrays discard an initial null or Number source"
  - "do Rust optional Array transforms retain result guards"
  - "does git ls-files capture newly authored Rust include fixtures"
  - "why did the first Rust Array repair writer fail before changing source"
date: 2026-11-07
status: bounded Rust78.2 focused-checked; full admission separate
tags: [rust, arrays, helpers, guards, source, arity, custody]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.78.2; array-transform-result-guard-rust-2026-11-07/REVIEW.md retains shared37/own148/optional10,21 original failures/174 healthy to195PASS, direct290 and exact private old21RED/current195PASS;152 profiles/195 artifact pairs and first readonly/eight controls pass."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/array-transform-result-guard-rust-2026-11-07/review.py"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -j 1 -p linkedspec-runtime --test array_transform_result_guard_composition --test hash_value_result_guard_composition --test value_copy -- --test-threads=1"
---

Independent public native/restored/generated-plan/emitted-fresh acquisition finds
eleven failures in unchanged37 and ten optional-result failures. Eight shared
literal receiver targets already work on Rust; Perl's nineteen-failure verdict
does not apply. Free take.set_key returns its Array with KV; later copy/with
executes KVW. Actual compiled actions retain canonical producers and operands.

engine.rs direct FluentChain and trailing-with source-role lists omit the eight
ordinary Array transforms. Canonical source/prefix roles now enter both existing
persistent guards before Hash-helper first-source permission. Only a first
producer without earlier ownership retains its source fallback; the actual
result owns later consumers. Hash consumers reject before operands, retaining
rejection through copy/logical/with. Producer bodies and serialized format stay.

Own Number/null/Hash controls for take/drop/slice/sorted/reversed yield empty
Arrays; initial with executes W/count0. concat keeps those named source kinds as
scalar elements, including [null,"z"] and [3,"z"]. Optional four counts default1;
slice omitted count keeps its tail. Missing/excess-arity effects, required errors,
earlier guards, nested kinds, source snapshots and compatible bridges stay exact.
Variadic concat, deferred/callback/traversal/function-receiver roles gain no new
authority. Rebuild Rust runtime/applications; peer and full23.4 admission separate.

git ls-files omits new untracked fixtures. First ordinary before therefore omits
the actual new optional include_str path, despite retained intake source bytes
and actual195 frames/21 failures. No complete original-normal first-use custody
credit. Separate capture_qualified.py explicitly includes its path/mode before
qualified-before and later builds. Original inputs/producers/channels stay exact.

First repair.py uses an unanchored eight-space substring that matches both guard
blocks, and asserts before writes. A non-fail-fast shell then acquires old source
again under after. Those actual old observations are retained without GREEN
credit. Separate line-anchored writer passes a read/construct-only rehearsal,
then produces repaired-after. Native/cache/transitive/toolchain custody4.2/SESSION5
remains separate; successful technical acquisition alone is not semantic GREEN.

Related: [[array-transform-result-guard-selection]], [[rust-hash-value-result-guards]],
[[rust-runtime-embedded-help-input]].
''')
p = Path('docs/knowledge/array-transform-result-guard-selection.md')
s = p.read_text().replace('bounded Perl78.1.1 focused-checked; independent peer assessments remain',
                         'bounded Perl78.1.1/Rust78.2 focused-checked; independent peer assessments remain', 1)
s = s.replace('independent Rust78.2 is next.',
              'Rust78.2 now has its own bounded outcome in `docs/knowledge/rust-array-transform-result-guards.md`; independent Dart78.3 is next.', 1)
p.write_text(s)
print('public examples, backend bounds and durable Rust guard/input facts updated')
