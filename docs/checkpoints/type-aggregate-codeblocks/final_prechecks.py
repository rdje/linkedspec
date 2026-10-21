"""Bind final reader epochs and correct the encountered scalar catalogue wording."""
import json
import re
import common as c


def main():
    catalog='docs/linkedspec-book/src/appendix/helper-contract-catalog.md'
    task='docs/tasks/TYPE-REFERENCE-BOOK.md'
    kind='docs/knowledge/perl-numeric-reducer-string-result-kinds.md'
    typed='docs/knowledge/terse-type-method-surface-inventory.md'
    paths=[c.PREFIX+'review.py',c.PREFIX+'custody.py',catalog,task,kind,typed,c.PREFIX+'README.md','MEMORY.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    path=c.PREFIX+'review.py';text=after[path]
    text=text.replace('import verify_kinds\n','import verify_kinds\nimport verify_library\nimport guard_proof\n',1)
    old="    assert all(c.read(path)==packet for path,packet in saved['sources'].items())"
    new="    change=c.load('guard-change.json.gz')\n    assert saved['sources'][c.SOURCE]==change['before'][c.SOURCE]\n    assert c.read(c.SOURCE)['base64']==change['after'][c.SOURCE]\n    assert all(c.read(path)==packet for path,packet in saved['sources'].items() if path!=c.SOURCE)"
    assert text.count(old)==1;text=text.replace(old,new,1)
    start=text.index("    library=c.load('kind-library-inputs.json.gz');")
    end=text.index('\n\n\ndef check(',start)
    text=text[:start]+'''    library=verify_library.check()
    return dict(exact_catalog_sources=8,controlled_emitter_epochs=3,
        owned_library_inputs=library['installed_inputs'],loaded_owned_modules=library['loaded_owned_modules'],
        limit=library['scope'])'''+text[end:]
    text=text.replace("assert c.load('candidate2-review.json.gz')['result']==current", "assert c.load('candidate3-review.json.gz')['result']==current")
    old="    assert all(c.read(path)==packet for path,packet in before['current'].items())"
    new="    change=c.load('guard-change.json.gz')\n    assert before['current'][c.SOURCE]==change['before'][c.SOURCE]\n    assert c.read(c.SOURCE)['base64']==change['after'][c.SOURCE]\n    assert all(c.read(path)==packet for path,packet in before['current'].items() if path!=c.SOURCE)"
    assert text.count(old)==1;text=text.replace(old,new,1)
    text=text.replace("focused=c.load('focused1-run.json.gz')","focused=c.load('focused2-run.json.gz')",1)
    text=text.replace("    assert not c.decode(focused['tests']['stderr_base64'])",'''    stderr=c.decode(focused['tests']['stderr_base64'])
    marker=b'# RECEIVER_COPY_OBSERVATIONS '
    assert stderr.startswith(marker) and stderr.endswith(b'\\n') and len(stderr.splitlines())==1
    diagnostic=json.loads(stderr[len(marker):])
    assert diagnostic['live_error'] is None and diagnostic['live']==diagnostic['standalone']
    assert diagnostic['live_identity']==diagnostic['standalone_identity']
    assert set(diagnostic['live_identity'].values())=={1}''',1)
    text=text.replace('    kinds=verify_kinds.check(fresh)', '''    guard=c.load('guard-proof-run.json.gz')
    assert guard['inputs_unchanged'] and guard['source_restored']
    assert guard_proof.typed(guard['healthy']) and guard_proof.typed(guard['restored'])
    assert not guard_proof.typed(guard['red'])
    kind_guard=c.load('guard-change.json.gz')
    assert c.decode(kind_guard['after'][c.SOURCE])==c.decode(kind_guard['before'][c.SOURCE]['base64']).replace(
        b" for (my $index = 0; $index < @$calls; ++$index) {\\n",
        b" for (my $index = 0; $index < @$calls; ++$index) {\\n  next unless ref($calls->[$index]) eq 'HASH';\\n",1)
    kinds=verify_kinds.check(fresh)''',1)
    text=text.replace('producer_faults=tasks,direct_suites=',"producer_faults=tasks+['malformed-call-guard'],direct_suites=",1)
    text=text.replace('permanent_added=201,permanent_advanced=3,','permanent_added=201,permanent_advanced=3,malformed_assertions=15,',1)
    needle="              'Known pipeline9 and internal kind95 failures stay owned; no95 fix, complete inventory, '"
    replacement="              'Six aggregate faults retain the exact pre-guard epoch; the only final delta skips non-hash '\n              'serialized members and has a distinct actual guard-removal fault plus15 permanent assertions. '\n              'Current214/final14 suites and canonical admission use that final producer. '\n"+needle
    assert text.count(needle)==1;text=text.replace(needle,replacement,1)
    compile(text,path,'exec');after[path]=text
    path=c.PREFIX+'custody.py';text=after[path]
    old="        'accepted-inputs.json.gz','focused1-inputs.json.gz','doc-inputs.json.gz']"
    new="        'accepted-inputs.json.gz','focused1-inputs.json.gz','doc-inputs.json.gz',\n        'candidate3-inputs.json.gz','malformed-before-inputs.json.gz','malformed-accepted-inputs.json.gz',\n        'library-actual-inputs.json.gz','guard-proof-inputs.json.gz','focused2-inputs.json.gz']"
    assert text.count(old)==1;after[path]=text.replace(old,new,1)
    # This is an encountered documentation defect, settled by the existing neutral authority.
    contract=json.loads((c.ROOT/'capability_conformance/scalar_numeric_contract.json').read_bytes())
    negative=next(row for row in contract['cases'] if row['id']=='round_negative_half')
    assert negative['args']==[-2.5] and negative['expected']==-3
    old='- **Behavior**: Rounds to nearest integer (half-up).'
    new='- **Behavior**: Rounds to nearest integer, with halves away from zero. For example, `num_round(-2.5)` returns `-3`.'
    assert after[catalog].count(old)==1;after[catalog]=after[catalog].replace(old,new,1)
    after[task]=after[task].replace('  Guard intake:', '  Catalogue defect owned/fixed here: num_round half-up wording contradicted scalar ADR0029/round_negative_half; clarify halves away from zero without changing behavior.\n  Guard intake:',1)
    # Keep the new durable loading fact with its actual kind experiment, under the existing budget.
    old='''Covered constructors, dynamic keys, callable arguments and variadic scalar
numeric producers materialize each operand before later siblings run. Explicit
flat splices remain lists. Container updates follow copy-on-write; this is no
arbitrary host-object deep-copy admission. Prior rejected alias/kind oracles
remain in type-evaluated-values/. Scoped callable with is repaired by4 and
[[perl-generic-final-codeblock-normalization]] owns its frame mechanism.'''
    new='''Covered constructors, dynamic keys, callable arguments and variadic scalar
numerics materialize operands before later siblings. Flat splices remain lists;
updates follow copy-on-write, not arbitrary deep copy. Rejected oracles stay in
type-evaluated-values/. Scoped callable with4 uses the frame mechanism in
[[perl-generic-final-codeblock-normalization]].'''
    assert after[typed].count(old)==1;after[typed]=after[typed].replace(old,new,1)
    old='''JSON alone does not prove language kind. Current Perl5.34.1/JSON::PP4.06 renders
all five results as1 despite the three selected string flags. The original95
eight-source record reported three quoted JSON results. Exact sources now render
numbers through current native/fresh execution, three controlled emitter epochs
and the192-input accepted91 owned Perl library with current system/dependency
prerequisites. The original instrument/process environment is unretained; those
quoted observations remain dated, not refreshed or assigned a guessed cause.'''
    new='''Perl5.34.1/JSON::PP4.06 emits1 for all five despite three string flags. Original95
reported three quoted results. Exact8 now render numbers through native/fresh,
three emitter epochs and real accepted91 library bytes (192 inputs,65 loaded
owners verified), with current tools/dependencies. Original instrument/environment
is unretained: keep quoted observations dated, without guessing a source cause.'''
    assert after[kind].count(old)==1;after[kind]=after[kind].replace(old,new,1)
    after[kind]+='\nA shadow path alone does not prove the selected owner loaded. Initial shadows misloaded current modules and were rejected; loaded-byte verification plus exact restoration admits the actual replay.\n'
    after[kind]=after[kind].replace('date: 2026-10-21','  - "how must a historical Perl source shadow verify the loaded owner"\ndate: 2026-10-21',1)
    after[kind]=after[kind].replace('reverify: "bash tools/run_python_project_data.sh '+c.PREFIX+'verify_kinds.py"',
        'reverify:\n  - "bash tools/run_python_project_data.sh '+c.PREFIX+'verify_kinds.py"\n  - "bash tools/run_python_project_data.sh '+c.PREFIX+'verify_library.py"',1)
    old_summary="""docs/checkpoints/type-aggregate-codeblocks/ retains raw channels, full source
epochs/restorations, direct JSON independent of projection, B flags and actual
public index failures.95 remains after93/92/94 before51: audit aggregate authority,
repair internal numeric kinds and add kind-sensitive recurrence. No95 fix or all-input/backend admission follows from7."""
    compact="""Evidence: docs/checkpoints/type-aggregate-codeblocks/ (raw channels, source bytes,
loaded owners, flags and public failures).95 stays after93/92/94 before51: audit
aggregate inputs and repair kinds with consumer recurrence. No95 fix/backend
admission from7."""
    assert after[kind].count(old_summary)==1
    after[kind]=after[kind].replace(old_summary,compact,1)
    verbose="""CodeblockRuntime uses Numeric's separate scalar and aggregate dispatch. Scalar
names/aliases preserve the neutral contract and reject invalid shapes before
effects. Comparisons and array reducers terminate their chains. Invalid emitted
numeric shapes are complete undef expressions, not host-function fallthrough.
Aggregate word/canonical calls consume one array; min/max with explicit extra
operands use scalar evaluation before kind rejection. Array receiver reducers
take no arguments. Perl checks every term's legacy decimal spelling; empty sum
is0, other empty reducers undef. Rust's generic-filter path is separate."""
    concise="""CodeblockRuntime uses separate scalar/aggregate Numeric dispatch. Scalars keep
the neutral contract; shapes validate before effects. Comparisons/array reducers
terminate chains. Complete emitted undef avoids host fallthrough. Aggregates
take one array; explicit min/max operands use scalar evaluation before kind
rejection. Receiver reducers take no arguments. Every Perl term passes legacy
decimal checks: empty sum0, othersundef. Rust filtering differs."""
    assert after[typed].count(verbose)==1
    after[typed]=after[typed].replace(verbose,concise,1)
    verbose="""Perl drop_keys materializes key operands and explicit splices/shapes, then deletes
a private key list from a copied harray. Normal/FATAL syntax loading is quiet;
later callbacks cannot change earlier keys. Source-kind errors/null-key warnings
remain; no portable reference-key coercion is admitted. Whole accepted numeric
and drop epochs survive in their checkpoints before aggregate7 bound writes."""
    concise="""Perl drop_keys materializes keys/splices/shapes, deleting a private list from a
copied harray. Normal/FATAL loading is quiet; later callbacks cannot change earlier
keys. Source/null-key diagnostics remain, with no portable reference-key coercion.
Whole numeric/drop epochs survive before aggregate7 writes."""
    assert after[typed].count(verbose)==1
    after[typed]=after[typed].replace(verbose,concise,1)
    total=sum(path.stat().st_size for path in (c.ROOT/'docs/knowledge').glob('*.md'))
    total+=sum(len(after[path].encode())-len(c.decode(before[path]['base64'])) for path in (kind,typed))
    assert total<=8388608,total
    after[c.PREFIX+'README.md']+='''
Final guard follow-up: public invoke exposed a raw-host diagnostic for malformed
serialized fluent members. One runtime guard restores the accepted typed error;
15 permanent assertions cover null/string/list members, callers and records.
The six aggregate faults remain exact pre-guard epochs; a separate removal fault
and corrected214/current dependents verify the final producer. The existing
receiver-copy test emits one intentional complete18010-byte JSON TAP diagnostic;
parse its protocol and reject other stderr. Its first quietness rejection stays.

Source identity: the first shadow experiments loaded current code. They are
rejected preparations. Actual accepted Runtime installation verifies the typed
baseline; actual192-input library installation verifies65 loaded LinkedSpec
owners against old bytes and restores every current file/mode. Both retain raw
channels. No old process environment is reconstructed or JSON observation refreshed.
'''
    after['MEMORY.md']=after['MEMORY.md'].replace('Run candidate3 after the malformed-record guard, then focused2 and book proof. Recheck the old library with verified loaded bytes: the first shadow loaded current code. Keep both rejected preparations; no history inverse is needed (650 audit passed).',
        'Run focused.py focused2 on final sources, then doc_proof.py and composed readonly review/publication. Seven actual faults are restored; actual192/65 old-library identity is verified. No inverse needed: ordinary Phase0 source stays unchanged and650 controls pass.')
    after['MEMORY.md']=after['MEMORY.md'].replace('Knowledge source8388596/8388608','Knowledge source'+str(total)+'/8388608')
    after['MEMORY.md']=after['MEMORY.md'].replace('Original176, rejected214/18 discrepancies, corrected source epochs and six actual faults/fresh restorations survive',
        'Original176, rejected214/18 discrepancies, final214, six aggregate faults and one final guard fault survive')
    c.write_new('final-prechecks.json.gz',dict(before=before,after={path:c.encode(raw.encode()) for path,raw in after.items()},
        producer=c.read(c.PREFIX+'final_prechecks.py'),knowledge_after_bytes=total,
        scope='Qualify pre-guard observations without refresh; bind final source epochs and actual loaded '
              'old owners. Correct encountered rounding wording from existing neutral case. Compact '
              'current fact prose before adding the durable source-identity lesson; no budget increase.'))
    for path,raw in after.items():(c.ROOT/path).write_text(raw)
    print('Final proof readers/book/facts prepared; Knowledge bytes',total)


if __name__=='__main__':main()
