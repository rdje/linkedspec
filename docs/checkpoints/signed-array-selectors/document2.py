"""One-shot current-status documentation with retained before images and no cap growth."""
import json
import re
import common as c
import context

FLOW = 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
INTEGRATION = 'docs/linkedspec-book/src/public-api/integration-perl.md'
CARDS = ['docs/knowledge/'+name+'.md' for name in (
    'terse-direct-access-bare-path-atoms','rust-single-index-read-bypasses-typed-binding',
    'perl-primary-cli-operational-failures','write-vivification-perl-reference')]
EXAMPLES = {
    'examples/negative-array-current-perl.spec':'read-last',
    'examples/negative-array-current-callable-perl.spec':'callable-read',
}
MARKER = 'Current negative-index read status'
CLI_MARKER = 'The current Perl primary CLI has a reporting gap'


def field(text,name,value):
    result,count = re.subn(r'^'+re.escape(name)+r': .*$',name+': '+json.dumps(value,ensure_ascii=False),text,count=1,flags=re.M)
    assert count == 1, name
    return result


def questions(text,items):
    anchor = '\ndate:'
    assert text.count(anchor) == 1
    return text.replace(anchor,''.join('\n  - '+json.dumps(item,ensure_ascii=False) for item in items)+anchor,1)


def main():
    paths = [FLOW,INTEGRATION]+CARDS
    planned = set(paths)|set(EXAMPLES)|{'KNOWLEDGE_MAP.md'}
    live = {}
    intersections = {}
    for file in sorted((c.ROOT/'docs/claims').glob('*.json')):
        record = json.loads(file.read_bytes())
        rows = []
        for index,claim in enumerate(record.get('claims',[])):
            durability = claim.get('durability',{})
            if durability.get('status') == 'checked' and durability.get('mode','live') == 'live':
                matched = sorted({item['path'] for item in durability['inputs']} & planned)
                rows.append(dict(index=index,name=claim['name'],intersection=matched))
        if rows:
            path = file.relative_to(c.ROOT).as_posix()
            live[path] = dict(packet=c.read(path),claims=rows)
            if any(row['intersection'] for row in rows):
                intersections[path] = rows
    assert not intersections,intersections
    baseline = c.run(['bash','tools/run_python_project_data.sh','docs/checkpoints/REPO-HYGIENE.21/publish.py'])
    assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64'])
    before = {path:c.read(path) for path in paths}
    draft = {path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    reverify = 'Dated source-bound intake: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-selectors/review.py. No current signed-policy admission.'
    for path in CARDS:
        draft[path] = field(draft[path],'date','2026-10-23')
        draft[path] = field(draft[path],'reverify',reverify)
    bare,rust,cli,perl = CARDS
    draft[bare] = questions(draft[bare],['why does an ordinary Perl dynamic string hash read yield null'])
    draft[bare] = field(draft[bare],'evidence',
        'Historical bare-index/auto-declaration proof and later guarded reads remain unchanged; full original header/recipes: git show '+c.BASE+':'+bare+'. Signed intake17.0 retains the quoted-key/bare-index control and exact emitted ARRAY guard; the first provisional comparison target was wrong.')
    draft[bare] += '\n## October23 control qualification\n\nFor `tree={"-1":"key"}; chosen_index="-1"; return(tree[chosen_index])`, current ordinary Perl selects the authored scalar-array-index branch and returns null for the harray receiver. The quoted literal twin returns `key`. Intake17.0 preserves the first wrong comparison target and every actual row; it changes no read policy.\n'
    draft[rust] = questions(draft[rust],['why does Rust items[-1] return its first entry','which existing Rust negative index coercion test must the signed transition replace'])
    draft[rust] = field(draft[rust],'status','typed-binding repair preserved; legacy negative coercion awaits signed child17.3')
    draft[rust] = field(draft[rust],'evidence',
        'Original startup88 sources, seventeen before/after pairs, binary identities and complete dated proof remain retained; full original card: git show '+c.BASE+':'+rust+'. Intake17.0 retains32 native sources, the actual Rust CLI binary and a direct negative-value/index calibration. No new portable selector admission.')
    draft[rust],count = re.subn(r'```bash\nbash tools/project_data_run.sh env PERL5LIB=.*?\n```',
        'The full original public replay command is retained in `git show '+c.BASE+':'+rust+'`; its original sources and observations remain in the named checkpoints.',draft[rust],count=1,flags=re.S)
    assert count == 1
    draft[rust] += '\n## October23 signed-index intake\n\nThe retained native calibration returns `[-2,10,10,10,10]`: the variable remains negative, but each negative array selector selects element0. `engine.rs` converts the evaluated number to `usize` in `IndexedVar` and `eval_access_value`; `indexed_var_preserves_existing_read_index_coercion` explicitly expects the first entry for -1. Child17.3 must supersede that negative expectation under the director rule, preserving unrelated legacy-coercion scope and all historical evidence.\n'
    draft[cli] = questions(draft[cli],['why does Perl CLI print null for a typed invalid write','which task repairs Perl CLI context-only runtime failures'])
    draft[cli] = field(draft[cli],'status','stable phase protocol; context-only handler failure reporting is owned P1 child17.8')
    draft[cli] = field(draft[cli],'evidence',
        'Original operational rollout remains historical below. Intake17.0 retains twelve library write failures reported by Perl CLI as exit0/null; other five native routes exit1. A two-case established-protocol oracle is RED on Perl and GREEN on the other five. Child17.8 owns repair before signed contract17.1.')
    head,body = draft[cli].split('\n---\n',1)
    current = '\n# Context-only handler failures (October23)\n\n`items=[10,20,30]; items[1.5]=99; return(items)` reports a typed error through public Get/runtime_ctx_ref and independently emitted execution. The primary command emits `null` plus LF, empty stderr and exit0. Its runtime context is already wired, but the invocation boundary checks only `$@`. This conceals failure from scripts. P1 TYPE-REFERENCE-BOOK.1.2.17.8 repairs both failure channels while preserving successful null/false/no-match results. Current evidence is a dated baseline, not a repaired-command claim.\n\n# Original operational rollout (July10)\n'
    draft[cli] = head+'\n---\n'+current+body
    draft[perl] = questions(draft[perl],['do ordinary and deferred Perl negative array reads currently agree'])
    draft[perl] += '\n## Signed-selector intake (October23)\n\nOrdinary Perl reads already select existing tail entries, including dynamic integer selectors, and preserve empty/underflow state. Callable array reads require digit-only indexes and return null for negatives; BindingRuntime rejects negative write selectors. Intake17.0 retains descriptor/Get-dump/fresh observations, the original sources and finite oracle REDs. Canonical child17.2 owns the requested extension; no signed write or portable admission is inferred.\n'
    head,_ = draft[rust].split('\n---\n',1)
    draft[rust] = head+'\n---\n'+'\n# Rust indexed reads: typed bindings and pending signed selectors\n\nBefore startup .88, `IndexedVar` read the private array map while ordinary\nassignment stored the typed value in the scalar map. Consequently `items=["a"];\nreturn(items[0])` returned null, and an indexed value used as a computed hash key\nbecame an empty string. Bare binding and `first()` controls agreed with Perl.\n\nThe .88 repair reads `ctx.get_bare_value(name)` and selects a cloned element from\nthat current typed array. It observes assignment, set, append, split and later\nrebinding; stale private storage cannot override the value. Missing/non-array\nreads return Undef and create no state. The index expression still runs before\nthe binding is resolved. Saved binding snapshots remain detached.\n\nThe original17-source before/after proof, five unchanged controls, complete\nruntime/emitted/book checks, command recipes, binary identities and historical\ncounts remain unchanged in the startup88 checkpoints. The complete original\ncard is `git show 92c98fb3de0f8392abde59043bd6f67ba0199452:docs/knowledge/rust-single-index-read-bypasses-typed-binding.md`.\nThe positive public example remains `examples/indexed-value-reads.spec`.\nRust grouped receiver access was a separate control; Perl grouped postfix\nremains separately owned by startup .87.4. No AST or serialized format changed.\n\n## October23 signed-index intake\n\nThe retained public calibration returns `[-2,10,10,10,10]`: the variable remains\nnegative, but negative selectors, including underflow, select element0.\n`IndexedVar` and `eval_access_value` convert evaluated numbers to `usize`.\nThe existing `indexed_var_preserves_existing_read_index_coercion` test explicitly\nexpects the first entry for -1. Its fractional, numeric-string, nonnumeric and\nundefined controls are existing Rust behavior, not a portable read policy.\n\nTYPE-REFERENCE-BOOK.1.2.17.3 owns replacing that negative behavior under the\ndirector\'s in-range tail rule, preserving unrelated coercion scope and the\noriginal evidence. Intake17.0 retains the source, actual CLI binary, full trace\nand native outcomes; it admits no signed support. Regenerate/rebuild emitted\nparsers after a runtime repair.\n\nRelated: [[uniform-binding-neutral-contract]],\n[[terse-rust-duck-typed-assignment-parity]],\n[[rust-hash-separator-and-cat-arity-defects]].\n'
    delta = sum(len(draft[path].encode())-len(c.decode(before[path]['base64'])) for path in CARDS)
    assert delta <= 0, ('Knowledge must not grow',delta)
    # Existing record bodies/questions stay discoverable; exact before images precede all writes.
    addition = '''
#### Current negative-index read status

Tail-relative indexing is being extended across the runtimes. For an existing array of size `L`, the requested rule is `[-n] = [L-n]` when `L-n >= 0`; negative selectors never create missing elements. The extension is not yet admitted portably.

For `[10,20,30]`, the current `[-1]` library-read results are:

| Runtime/context | Current result |
| --- | --- |
| Ordinary Perl action | `30` |
| Perl callable body | `null` |
| Rust ordinary/callable read | `10`, from its legacy index coercion |
| Dart, Julia, PUC Lua and LuaJIT | `null` |

These are implementation observations while the extension is pending. Negative writes remain rejected by the libraries. See [Perl error reporting](../public-api/integration-perl.md#handle-runtime-outcomes-explicitly) for the primary-command limitation.

The ordinary Perl example returns `[30,[10,20,30]]` with input `x`:

```text
{{#include ../../../../examples/negative-array-current-perl.spec}}
```

The callable example currently returns `[null,[10,20,30]]`:

```text
{{#include ../../../../examples/negative-array-current-callable-perl.spec}}
```

#### Existing parameter and effect behavior
'''
    marker = '\nNonparameter assignments update the caller\'s current slot.'
    assert draft[FLOW].count(marker) == 1
    draft[FLOW] = draft[FLOW].replace(marker,addition+marker,1)
    marker = '\nThe standalone JSON adapter also selects'
    caveat = '\nThe current Perl primary CLI has a reporting gap: it checks thrown exceptions but ignores a handler failure recorded only in `last_error`. Such a failure can print `null` and exit `0`, including an invalid fractional array write. The application adapter in this chapter checks both channels and reports these failures. CLI repair is pending; the successful-null rule above applies only when neither failure channel is set.\n'
    assert draft[INTEGRATION].count(marker) == 1
    draft[INTEGRATION] = draft[INTEGRATION].replace(marker,caveat+marker,1)
    cases = {row['id']:row for row in c.load('cases.json')['cases']}
    examples = {path:cases[case_id]['source'].encode() for path,case_id in EXAMPLES.items()}
    assert all(not (c.ROOT/path).exists() for path in examples)
    c.write_new('documentation-inputs.json.gz',dict(context=context.snapshot(),
        producer=c.read(c.PREFIX+'document2.py'),before=before,
        proposed={path:dict(base64=c.encode(text.encode()),sha256=c.sha(text.encode())) for path,text in draft.items()},
        live_claims=live,direct_intersections=intersections,prior_readonly=baseline,
        scope='The explicit read/write/CLI Knowledge and existing book scope is checked across every live claim before any bound write. The unrelated private-capacity card stays unchanged. Original whole card bodies/headers also recover from real accepted92c98fb3d; no budget increase.'))
    for path,text in draft.items():
        c.source(path).write_text(text)
    for path,raw in examples.items():
        with (c.ROOT/path).open('xb') as stream:
            stream.write(raw)
    c.write_new('documentation.json.gz',dict(before=before,
        after={path:c.read(path) for path in paths+list(EXAMPLES)},knowledge_byte_delta=delta,
        examples=EXAMPLES,scope='Authored current status follows retained observations; all original Knowledge questions survive, dated original recipes remain in accepted Git, and no runtime or authority is changed.'))
    print('Current implementation/CLI status documented; Knowledge byte delta',delta)


if __name__ == '__main__':
    main()
