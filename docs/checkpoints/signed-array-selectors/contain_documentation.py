"""Preserve the rejected documentation preflight, then prepare a distinct contained writer."""
import common as c
import context

RUST_BODY = '''
# Rust indexed reads: typed bindings and pending signed selectors

Before startup .88, `IndexedVar` read the private array map while ordinary
assignment stored the typed value in the scalar map. Consequently `items=["a"];
return(items[0])` returned null, and an indexed value used as a computed hash key
became an empty string. Bare binding and `first()` controls agreed with Perl.

The .88 repair reads `ctx.get_bare_value(name)` and selects a cloned element from
that current typed array. It observes assignment, set, append, split and later
rebinding; stale private storage cannot override the value. Missing/non-array
reads return Undef and create no state. The index expression still runs before
the binding is resolved. Saved binding snapshots remain detached.

The original17-source before/after proof, five unchanged controls, complete
runtime/emitted/book checks, command recipes, binary identities and historical
counts remain unchanged in the startup88 checkpoints. The complete original
card is `git show 92c98fb3de0f8392abde59043bd6f67ba0199452:docs/knowledge/rust-single-index-read-bypasses-typed-binding.md`.
The positive public example remains `examples/indexed-value-reads.spec`.
Rust grouped receiver access was a separate control; Perl grouped postfix
remains separately owned by startup .87.4. No AST or serialized format changed.

## October23 signed-index intake

The retained public calibration returns `[-2,10,10,10,10]`: the variable remains
negative, but negative selectors, including underflow, select element0.
`IndexedVar` and `eval_access_value` convert evaluated numbers to `usize`.
The existing `indexed_var_preserves_existing_read_index_coercion` test explicitly
expects the first entry for -1. Its fractional, numeric-string, nonnumeric and
undefined controls are existing Rust behavior, not a portable read policy.

TYPE-REFERENCE-BOOK.1.2.17.3 owns replacing that negative behavior under the
director's in-range tail rule, preserving unrelated coercion scope and the
original evidence. Intake17.0 retains the source, actual CLI binary, full trace
and native outcomes; it admits no signed support. Regenerate/rebuild emitted
parsers after a runtime repair.

Related: [[uniform-binding-neutral-contract]],
[[terse-rust-duck-typed-assignment-parity]],
[[rust-hash-separator-and-cat-arity-defects]].
'''


def main():
    writer = c.PREFIX+'document.py'
    before = c.read(writer)
    paths = ['docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md',
        'docs/linkedspec-book/src/public-api/integration-perl.md']
    paths += ['docs/knowledge/'+name+'.md' for name in (
        'terse-direct-access-bare-path-atoms','rust-single-index-read-bypasses-typed-binding',
        'perl-primary-cli-operational-failures','write-vivification-perl-reference')]
    images = {path:c.read(path) for path in paths}
    c.write_new('documentation-preflight-inputs.json.gz',dict(context=context.snapshot(),
        producer=c.read(c.PREFIX+'contain_documentation.py'),writer=before,before=images,
        original_tool_observation='Unified-exec98065 exit1 reported Knowledge must not grow,947 before any document write; its combined traceback was observed, without separately retained original wrapper channels.'))
    run = c.run(['bash','tools/run_python_project_data.sh',writer])
    exact = c.read(writer) == before and all(c.read(path) == image for path,image in images.items())
    c.write_new('documentation-preflight-replay.json.gz',dict(run=run,inputs_unchanged=exact,
        scope='Distinct isolated replay of the unchanged original preflight; actual separate channels retained. This expected budget refusal earns no product or semantic-falsifier credit.'))
    assert exact and run['returncode'] == 1 and not c.decode(run['stdout_base64'])
    assert b"AssertionError: ('Knowledge must not grow', 947)" in c.decode(run['stderr_base64'])
    source = c.decode(before['base64']).decode()
    marker = '    delta = sum(len(draft[path].encode())'
    assert source.count(marker) == 1
    # Current conclusions stay in the bounded card; full dated history remains in real accepted Git.
    inserted = "    head,_ = draft[rust].split('\\n---\\n',1)\n    draft[rust] = head+'\\n---\\n'+"+repr(RUST_BODY)+'\n'
    source = source.replace(marker,inserted+marker,1)
    old = "c.PREFIX+'document.py'"
    assert source.count(old) == 1
    source = source.replace(old,"c.PREFIX+'document2.py'",1)
    compile(source,c.PREFIX+'document2.py','exec')
    with (c.ROOT/c.PREFIX/'document2.py').open('x') as stream:
        stream.write(source)
    c.write_new('documentation-containment.json.gz',dict(before=before,
        after=c.read(c.PREFIX+'document2.py'),original_card=images[paths[3]],
        condensed_body=RUST_BODY,scope='Original rejected actor stays exact. Distinct writer2 retains every original question and the typed-binding/coercion facts, with complete old text in accepted92c98fb3d and retained before packets. No cap, runtime or frozen authority changes.'))
    print('Rejected documentation proposal/source and actual replay retained; distinct contained writer2 prepared')


if __name__ == '__main__':
    main()
