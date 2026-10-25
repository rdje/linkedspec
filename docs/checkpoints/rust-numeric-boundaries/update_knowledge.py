"""Bound the current numeric fact and repair the existing book retrieval pointer."""
import re
import common as c

NUMERIC='docs/knowledge/rust-large-number-conversion-defect.md'
BOOK='docs/knowledge/terse-type-method-surface-inventory.md'
BODY='''# Rust numeric value transport

`SESSION-STARTUP-READING.55.1` repairs value conversion; `.55.2` still owns portable
scalar-text spelling and `.55.3` broad closeout. `RuntimeValue::Number` remains
binary64, with no arbitrary-precision integer promise.

`core/numeric.rs` supplies checked integer projection: finite whole values in
[-2^63,2^63) become signed integer JSON, then values in [0,2^64) use unsigned
integer JSON. Other finite values remain floating JSON; nonfinite values become
null. Negative zero remains floating negative zero. Exact integer tokens matter:
converting the wrong i64-max token back to f64 can mask its identity at 2^63.

`to_str`, numeric `len` and `Display` share checked integer text inside those
domains and the existing f64 formatter outside them. Aggregate JSON/Display
recurse. Engine finalization, text helpers, hash keys, recognition payloads,
serialized AST/compiled carriers and public emitted Rust are in the owned audit.
`to_scalar_text`/`cat` and the frozen scalar-text authority remain unchanged.

The workspace enables serde_json `float_roundtrip` without a version/pin change.
Actual raw numeric serde previously moved both representable neighbors immediately
inside the i64 limits to the limits; the same-source feature control and physical
feature inverse distinguish that second defect from saturation.

Positive nested writes and the definition-AST/v1-job integer readers use finite,
whole, nonnegative values strictly below 2^usize::BITS. The integer u64 branch
still uses checked usize conversion. The inclusive rounded `usize::MAX as f64`
guard formerly admitted 2^64 and changed its diagnostic index. Existing read,
bounded-count and child-push overload coercions remain; signed selectors retain
their separate normalization contract.

`runtime_value_from_json` recursively maps child payloads and typed source records
to the existing f64 model. No fallback-to-zero failure was observed. Nonrepresentable
integer inputs may round under that model. Actual progressive nested payloads
cover33 finite inputs through native/generated paths. Private definition-field
tests cover seven fields/both number branches; they do not claim a reachable
source with 2^usize::BITS characters. Public v1 dispatch has23 boundary controls.

Current retained evidence covers36 core inputs;53 source cases through native,
SpecFile JSON, compiled JSON and generated plans;49+4 independently compiled
emitted entries;52 CLI cases/104 quiet-trace processes plus4 function CLI controls;
and the real user-function definition AST/staged-body path. Five physical source
faults fail and restore fresh GREEN. Exact source/support admission keeps original
historical source/log/runtime identities and the prior signed-selector image.

Re-derive the actual item observations with `review_numeric.py`,
`review_processes.py` and `review_faults.py` under
`docs/checkpoints/rust-numeric-boundaries/`. `AUDIT.md` records the consumer
boundary. The readonly `publish.py` additionally binds all retained inputs,
executable bytes, book, dependent suites and historical recovery. All one-shot
capture writers stay retired; no historical runtime is refreshed.

## Dated pre-repair evidence and separate spelling

The September7 public Rust CLI returned i64-max/min for +/-1e20; Perl Get preserved
the values, and42 passed both. The complete original card, including every dated
command, source-only qualification and artifact pointer, remains recoverable in
`audit-before.json.gz` (context/sources at this path) under the same checkpoint
prefix, and in activation f0d974aa1b337bbf2ee16e51c0297182e1e94f82.
The fresh retained pre-repair CLI reproduces those results. Historical usize
diagnostics and source-only bridge/private AST inventories earn no new public
failure credit beyond their actual supplied controls.

Rust `cat(100000000000000000000, "")` still produces full decimal text while Perl
produces scientific text. The frozen neutral samples -0.0,1.0,1.25 do not decide
that magnitude. `.55.2` must reconcile the reference policy before changing that
authority. Initial overstrict wide-integer text targets, invalid key/dispatch
probes and incomplete first-capture custody stay explicitly qualified; none is
silently converted into product or portable admission.
'''


def main():
    assert len(c.load('closeout3-result.json.gz')['completed'])==4
    before={path:c.read(path) for path in (NUMERIC,BOOK)}
    old=c.decode(before[NUMERIC]['base64']).decode()
    header=old.split('\n---\n',1)[0]
    header=re.sub(r'^title:.*$', 'title: Rust binary64 value transport and checked integer boundaries',header,flags=re.M)
    header=re.sub(r'^date:.*$', 'date: 2026-10-25',header,flags=re.M)
    header=re.sub(r'^evidence:.*$', 'evidence: "SESSION-STARTUP-READING.55.1; docs/checkpoints/rust-numeric-boundaries/"',header,flags=re.M)
    header=re.sub(r'^reverify:.*$', 'reverify: "bash tools/run_python_project_data.sh docs/checkpoints/rust-numeric-boundaries/publish.py"',header,flags=re.M)
    header=header.replace('date: 2026-10-25',
        '  - "why does numeric serde change values adjacent to the i64 limits"\n'
        '  - "how does Rust preserve unsigned integer JSON tokens from binary64"\n'
        'date: 2026-10-25',1)
    (c.ROOT/NUMERIC).write_text(header+'\n---\n\n'+BODY)
    text=c.decode(before[BOOK]['base64']).decode()
    old='Accepted7: only the search-index reference differs; decoded15 body-whitespace\nchanges; strict rejection remains.'
    new=('Accepted7 retains its15 body-whitespace differences. Current numeric55.1\n'
        'reverification retains90 outputs/four body-whitespace differences and verifies\n'
        'both HTML and searcher fallback references against the complete decoded index.\n'
        'Decoder: `docs/checkpoints/type-deferred-indexed-writes/search_data.py`.\n'
        'Readonly proof: `docs/checkpoints/rust-numeric-boundaries/review_book.py`;\n'
        'only document-body whitespace is normalized; all other fields/URLs and\n'
        'literal code/script/style remain checked. Semantic/URL controls reject.')
    assert text.count(old)==1
    text=text.replace(old,new,1)
    text=re.sub(r'^date:.*$', 'date: 2026-10-25',text,count=1,flags=re.M)
    text=text.replace('reverify: "bash tools/project_data_run.sh prove -Iperl t/scalar_numeric_contract.t"',
        'reverify:\n  - "bash tools/project_data_run.sh prove -Iperl t/scalar_numeric_contract.t"\n'
        '  - "bash tools/run_python_project_data.sh docs/checkpoints/rust-numeric-boundaries/review_book.py"',1)
    (c.ROOT/BOOK).write_text(text)
    after={path:c.read(path) for path in before}
    c.save('knowledge-documentation.json.gz',dict(before=before,after=after,
        producer=c.read(c.PREFIX+'update_knowledge.py'),
        scope='Preserve the complete old numeric card, replace its live body with '
            'current bounded facts and exact proof pointers; repair the already '
            'existing book lookup/reverify route. No new fact-card slot or budget.'))
    print('Bounded numeric fact and exact book retrieval route updated; complete prior bytes retained.')


if __name__=='__main__':main()
