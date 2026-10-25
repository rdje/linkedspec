"""Consolidate current indexed-read facts and retain their exact historical home."""
import json
import common as c

READ='docs/knowledge/rust-single-index-read-bypasses-typed-binding.md'
WRITE='docs/knowledge/write-vivification-rust-runtime.md'


def main():
    prior={path:c.read(path) for path in [READ,WRITE]}
    old=c.decode(prior[READ]['base64']).decode()
    header=old.split('---',2)[1]
    header=header.replace('Rust single-index reads use current typed array bindings after startup .88','Rust indexed reads preserve typed bindings and support signed array positions')
    header=header.replace('date: "2026-10-23"','date: "2026-10-25"')
    header=header.replace('status: "typed-binding repair preserved; legacy negative coercion awaits signed child17.3"','status: "signed implementation; portable admission remains child17.7"')
    start=header.index('evidence: ');end=header.index('\nreverify:',start)
    header=header[:start]+'evidence: "Startup88 and intake17.0 remain dated evidence. TYPE-REFERENCE-BOOK.1.2.17.3 retains complete old/new Rust sources, actual native/emitted executables, raw diagnostic channels, independent target readers and explicit existing read-order/coercion controls under docs/checkpoints/signed-array-rust/."'+header[end:]
    start=header.index('reverify: ')
    header=header[:start]+'reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test signed_array_selector_contract; dated evidence: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-rust/publish.py"\n'
    read='---'+header+'---\n\n'+'''# Rust indexed reads

`IndexedVar` resolves the current typed array binding after evaluating its selector.
The older startup88 repair replaced a private-array-map read that missed scalar-held
arrays: `items=["a"]; items[0]` returned null and a computed harray key became empty.
Assignment, set, append, split and rebinding now observe the typed value; stale private
storage cannot override it. Missing/non-array reads are pure Undef. Saved snapshots
are detached. The public positive example is `examples/indexed-value-reads.spec`.

Signed child17.3 routes both single and nested/value-result array reads through
`array_selector_value`: a supported finite whole negative number selects `length+index`
only within the existing array, otherwise Undef. `[-1]` selects the last entry.
Single-index receiver lookup still follows selector effects; nested/value access retains
its earlier receiver snapshot. Fractions, evaluated strings, null and other unrelated
coercions retain their existing Rust behavior. Explicit quoted key access stays a key.
Rust's `f64` model does not distinguish `-1` from `-1.0` as selector kinds.

The original intake calibration `[-2,10,10,10,10]` described the old negative-to-usize
cast, including underflow selecting element0. Its 32 sources, actual CLI binary and
trace remain immutable. The permanent coercion test now expects tail selection for
negative integers while preserving its fractional/string/undefined controls. Rebuild
saved/emitted parsers after runtime updates. Portable signed admission remains17.7;
Perl grouped postfix remains startup87.4, with no AST format change here.

Exact former card and all startup88/intake reading details:
`git show 691d2d87690ce3f9052c1d032a3e862ee5d76211:docs/knowledge/rust-single-index-read-bypasses-typed-binding.md`.
That card points to the complete startup88 record at92c98fb3de0f8392abde59043bd6f67ba0199452,
including its seventeen source pairs, five unchanged controls and runtime/emitted/book
proof. Those historical counts are not new reruns.

Related: [[uniform-binding-neutral-contract]], [[terse-rust-duck-typed-assignment-parity]],
[[write-vivification-rust-runtime]], [[rust-hash-separator-and-cat-arity-defects]].
'''
    write=c.decode(prior[WRITE]['base64']).decode()
    write=write.replace('date: 2026-09-08','date: 2026-10-25',1)
    write=write.replace('status: implemented under FUTURE-PARITY-BACKLOG.19.3.1; portable capability admitted under .19.7',
        'status: v1 admitted under FUTURE-PARITY-BACKLOG.19.7; signed extension implemented under TYPE-REFERENCE-BOOK.1.2.17.3, portable extension pending17.7',1)
    write=write.replace('  - "are Rust nested write results detached"','  - "are Rust nested write results detached"\n  - "how does Rust preserve signed diagnostic integers beyond i64"\n  - "why do Rust callable nested-write errors have a codeblock prefix"\n  - "are Rust action error spans relative to outer brace padding"',1)
    anchor='# Rust write-vivification runtime\n'
    current='''# Current signed Rust extension

Child17.3 preserves the v1 node/carriers and adds conditionally valid negative integer
segments. `NegativeIndex(i128)` retains the authored value; the isolated walk checks
array kind and resolves each position against its encountered post-expression length.
Missing negative roots/children retain invalid-segment/negative_integer; present null
and wrong kinds remain conflicts. Underflow carries exact index, length, resolved_index
and authored prefix. Negative selectors never append, create arrays or invent fillers.
All segments then RHS evaluate once before classification/walk; global invalid kinds
precede structural failures, and existing guard identity, effects, atomicity and copies
remain. The `usize` magnitude check is repeated after exact conversion because the float
representation of usize::MAX can round upward. Broader positive-index/Number saturation
remains P1 startup55.1, next after this leaf; this path does not close that defect.

Nested-write diagnostics serialize a private typed payload directly to the original
String channel. Its signed fields/path use serde i128 without a generic Value round-trip
or Cargo feature change. Generic JSON Value observation can coarsen wide integers;
the regression consumes original strings with typed fields, and Python independently
decodes exact integer tokens. Existing alphabetical v1 field order/messages remain.
Callable invocation still prefixes a nested failure with `codeblock 'name': `; the
observer requires the explicitly expected name before examining the inner JSON, keeping
the complete original error. No runtime envelope policy changes here.

Public rule parsing trims outer action whitespace into the CodeBlock source before
compilation. Nested-write spans are Unicode-scalar positions in that action source,
not full-spec bytes or brace padding. The Unicode probe distinguishes scalar26 from
byte28 and rejected padded scalar27, and varies leading/trailing spaces and newlines.
Standalone ActionIR retains its own containing source coordinates.

Current consumers: `rust/linkedspec-runtime/tests/signed_array_selector_contract.rs`
and `tests/signed-array-rust/cases.json`; retained dated proof and qualifications:
`docs/checkpoints/signed-array-rust/`. Reverify through the Cargo consumer and readonly
`publish.py`; exact staged canonical CI is the admission boundary. Other backends and
portable signed admission stay separately owned. Installed SDK/OS and public prepared
RGX outputs are prerequisites; no dependency-internal or whole-SDK replay is claimed.

# Historical v1 runtime and reading checkpoints
'''
    assert write.count(anchor)==1;write=write.replace(anchor,current,1)
    marker='## September 7 diagnostic-definition reading'
    assert write.count(marker)==1
    write=write.split(marker,1)[0]+'''## Dated reading checkpoints

The exact previous card, including every original reading window and repeated neutral
result, remains `git show 691d2d87690ce3f9052c1d032a3e862ee5d76211:docs/knowledge/write-vivification-rust-runtime.md`.
These checkpoints establish source/assertion definitions, with no fresh native milestone
rerun. Their neutral proof retains5 AST/7 syntax,11 success/16 structural failures,
3 evaluation failures/3 read exclusions,8 compositions and105 mutations.

- Startup3.3.15 reads the three v1 formatter variants: exact binding/path/segment/span,
  kind/reason or index/length, deterministic String JSON; no traversal proof yet.
- Startup3.3.16 reads engine2631–2669 and supporting emitter355–420/997–1030:
  validated entry/emission/decode reject malformed nodes; raw low-level generated
  contexts rely on caller validation rather than independently repeating it.
- Startup3.3.17 reads ordered segments then RHS, classification, post-expression
  presence/kind snapshot and store-preserving single commit. Its positive numeric
  `<= usize::MAX as f64` cast has the separately owned55.1 rounded-boundary risk.
- Startup3.3.18 completes engine4888–4986 recursion: replace/insert harray keys,
  create absent children from the next selector, reject positive gaps, append at
  exact length, preserve null/wrong-kind conflicts and publish only after success.
  The old pure numeric read cast is superseded by signed17.3 above.
- Startup3.3.23 reads tests through EOF: exact segment0/segment1/RHS audit,
  structural fields and RHS-rebind preservation, independently mutated aggregate
  boundaries, three expression-stop positions and three noncreating read controls.
- Startup3.3.66 reconciles all592 lines of the original write consumer. Five parent
  tests cover frozen AST/syntax, native successes/failures, fresh function presence
  and one composed carrier. That carrier reconstructs SpecFile/CompiledSpec,
  validates native/generated-plan state and rejects corrupt segment kind. Its
  separately compiled emitted child checks one computed path yielding
  `{"sections":[{"title":"Intro"}]}`, using relative `../../../linkedspec-runtime`
  and an owned Drop workspace. It does not run every frozen case on every carrier.
'''
    updated={READ:read.encode(),WRITE:write.encode()}
    delta=sum(len(updated[path])-len(c.decode(prior[path]['base64'])) for path in prior)
    if __import__('sys').argv[1:]==['--plan']:
        print('Planned Knowledge collection byte delta:',delta)
        return
    c.write_new('knowledge-inputs.json.gz',dict(producer=c.read(c.PREFIX+'document_knowledge.py'),
        before=prior,after={path:dict(base64=c.encode(raw),sha256=c.sha(raw),mode=prior[path]['mode']) for path,raw in updated.items()},
        scope='Current signed read/write facts; exact former read card remains in accepted Git. All original questions and dated evidence references survive. No collection cap increase or extra card.'))
    for path,raw in updated.items():c.source(path).write_bytes(raw)
    print('Current Rust facts consolidated; collection byte delta:',delta)


if __name__=='__main__':main()
