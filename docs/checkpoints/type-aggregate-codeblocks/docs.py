"""Synchronize worked public semantics, precise kind limitation and bounded task/fact homes."""
import re
import common as c

CHAPTER='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
REFERENCE='docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
CATALOG='docs/linkedspec-book/src/appendix/helper-contract-catalog.md'
TYPE='docs/knowledge/terse-type-method-surface-inventory.md'
KIND='docs/knowledge/perl-numeric-reducer-string-result-kinds.md'
ARRAY='docs/knowledge/terse-array-numeric-reducer-receiver-methods.md'
TASK='docs/tasks/TYPE-REFERENCE-BOOK.md'
STARTUP='docs/tasks/SESSION-STARTUP-READING.50-99.md'
INDEX='docs/tasks/SESSION-STARTUP-READING.index.jsonl'
STARTUP_ROOT='docs/tasks/SESSION-STARTUP-READING.md'


def main():
    paths=[CHAPTER,REFERENCE,CATALOG,TYPE,KIND,ARRAY,TASK,STARTUP,INDEX,STARTUP_ROOT]
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    cases=[dict(id='book/aggregate-summary',expected=[[12,4,3,7,1,8],0,None,None],body='''items = [3,1,8];
summary = {|values|
  return([sum(values),values.avg(),median(values),values.range(),min(values),values.max()])
};
return([summary(items),sum([]),avg([]),sum([1,"bad"])]);
'''),dict(id='book/aggregate-terminal',expected=[None,''],body='''trace = "";
read = {|| trace = cat(trace,"r"); return([3,1,8]) };
cb = {|| return(read().sum().abs()) };
out = cb();
return([out,trace]);
'''),dict(id='book/numeric-index',expected=['zero','changed'],body='''items = ["zero","one"];
index = add(min(["2","1"]),0);
items[index] = "changed";
return(items);
''')]
    chapter=after[CHAPTER]
    old='''Deferred numeric aggregate reducers, including array-form min/max and array
reducer methods, still raise the typed `unknown_helper` diagnostic in Perl.
'''
    assert chapter.count(old)==1
    chapter=chapter.replace(old,'''The six numeric aggregate reducers execute inside Perl codeblocks. General array
pipelines remain separate: `items.sorted().take(2).sum()` inside a deferred body
currently raises `unknown_helper` at `sorted`. Prepare the array outside the body
and pass it in until that owned pipeline repair is complete.
''',1)
    old='''Numeric array reducers remain outside this deferred scalar family. An executed unsupported
call keeps its typed `unknown_helper` cause.
'''
    assert chapter.count(old)==1
    chapter=chapter.replace(old,'''Array reducers use the separate [aggregate rules](#aggregate-numeric-helpers-in-codeblocks).
Other executed unsupported calls keep their typed `unknown_helper` cause.
''',1)
    anchor='### Callable values in with\n'
    addition='''### Aggregate numeric helpers in codeblocks

Perl callbacks execute `num_sum`, `num_avg`, `num_median`, `num_range`, and
single-array `num_min`/`num_max`. Their word aliases and terminal array methods
`sum()`, `avg()`, `median()`, `range()`, `min()` and `max()` also work. Array
parameters, direct reads and registered-function results are accepted sources.
The source is evaluated once; the reducer does not reorder its array.

These use the existing Perl aggregate checks, separately from the strict scalar
numeric contract. Every item must match the legacy decimal spelling; a null or
nonnumeric item invalidates the whole reduction. Empty `sum([])` is `0`; the
other five empty reductions are `undef`. The older checks do not establish the
scalar contract's finite-number and typed-boolean rules for aggregates.

This returns `[[12,4,3,7,1,8],0,null,null]`:

```text
'''+cases[0]['body']+'''```

Free reducers take one array. Min/max with two or more operands use the scalar
operation; a receiver min/max with an explicit operand follows those scalar
operand rules. Scalar operands run before kind rejection. The array receiver
forms take no arguments and end the chain. Invalid reducer arity or a continuation
after an array reducer returns `undef` before receiver/operand effects. Save the
result before starting a separate expression. This invalid continuation returns
`[null,""]` without running `read`:

```text
'''+cases[1]['body']+'''```

One existing Perl result-kind defect remains: min/max and odd median can select
an original numeric string. Current JSON output can show `1` while its internal
kind is still string. Using that result directly as an array-write index fails
with `nested_write_kind_conflict`. Scalar arithmetic converts it to a numeric
value; this example returns `["zero","changed"]`:

```text
'''+cases[2]['body']+'''```

That conversion is a workaround, not the pending result-kind repair. Boolean
body literals and deferred general array pipelines retain the limits above.

'''
    assert chapter.count(anchor)==1 and '### Aggregate numeric helpers in codeblocks' not in chapter
    after[CHAPTER]=chapter.replace(anchor,addition+anchor,1)
    reference=after[REFERENCE].replace('boolean-literal and deferred aggregate limits','boolean-literal and deferred pipeline limits')
    anchor='Arithmetic symbols are accepted as the equivalent call names for the binary or\n'
    addition='''Perl callable bodies also execute the six array reducers and their terminal
receiver forms. These retain the separate aggregate checks: every item must be
decimal-looking; empty sum is `0` and the other empty reducers are `undef`.
See [aggregate callback examples](values-containers-and-flow-helpers.md#aggregate-numeric-helpers-in-codeblocks)
for parameters, effects, min/max overloads and the selected-string index limit.

'''
    assert reference.count(anchor)==1
    after[REFERENCE]=reference.replace(anchor,addition+anchor,1)
    catalog=after[CATALOG]
    catalog=catalog.replace('→ `["1"]` on current Perl (numeric-string result; see below).',
        '→ `[1]` on the current Perl/JSON route (internal selected-kind limitation below).',1)
    catalog=catalog.replace('→ `["8"]` on current Perl (numeric-string result; see below).',
        '→ `[8]` on the current Perl/JSON route (internal selected-kind limitation below).',1)
    catalog=catalog.replace('→ `["3"]` on current Perl (sorted `1,2,3,4,5`; middle element).',
        '→ `[3]` on the current Perl/JSON route (sorted `1,2,3,4,5`; internal selected-kind limitation below).',1)
    old='''Current Perl type limitation: array-form `num_min`/`num_max` and odd-length
`num_median` preserve the selected element's string kind when the array contains
numeric text, including capture groups. Even-length median, sum, average and range
perform arithmetic and return numbers. `SESSION-STARTUP-READING.95` owns correction
of these numeric result kinds; the scalar two-argument min/max forms return numbers.
'''
    new='''Current Perl type limitation: array-form `num_min`/`num_max` and odd-length
`num_median` can retain a selected numeric string's internal kind. Current
Perl5.34.1/JSON::PP4.06 renders the examples above as numbers, including when
replaying the recorded sources with the older owned Perl library. The September
quoted-JSON observations remain historical; their original process/instrument
is not reconstructed. JSON alone is insufficient: these selected results still
fail as array-write indexes with `nested_write_kind_conflict`, while scalar
min/add controls work. `SESSION-STARTUP-READING.95` owns the internal-kind repair.
See the [worked numeric-index conversion](../dsl/values-containers-and-flow-helpers.md#aggregate-numeric-helpers-in-codeblocks)
for an arithmetic workaround. No result-kind fix is claimed by callback availability.
'''
    assert catalog.count(old)==1
    after[CATALOG]=catalog.replace(old,new,1)
    fact=after[TYPE]
    front=fact.split('---\n',2)[1]
    front=front.replace('date: 2026-10-20','date: 2026-10-21').replace(
        'status: bounded Perl value/numeric/drop repairs; full inventory pending',
        'status: bounded Perl value/numeric/drop/aggregate repairs; inventory pending')
    front=re.sub(r'^evidence:.*$', 'evidence: "TYPE-REFERENCE-BOOK.1.2.3-.7 retain accepted/candidate epochs and actual producer faults. Aggregate7 owns deferred dispatch/shapes;95 owns selected-string kinds and9 the deferred sorted pipeline."',front,flags=re.M)
    front=re.sub(r'^reverify:.*$', 'reverify: "bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py"',front,flags=re.M)
    front=front.replace('date:','  - "can Perl sum run inside a deferred codeblock"\n  - "why does invalid aggregate receiver arity reach a host function"\ndate:',1)
    after[TYPE]='---\n'+front+'''---

# Value model and bounded Perl helper execution

Bindings hold scalar, array, harray or codeblock. String/number/boolean/null
remain distinct. Numeric comparisons yield1/0; logical helpers yield booleans.
Generic with passes false; deferred bodies read caller slots. Callable-yielded
arrays use ordinary methods, not a codeblock table.

Covered constructors, dynamic keys, callable arguments and variadic scalar
numeric producers materialize each operand before later siblings run. Explicit
flat splices remain lists. Container updates follow copy-on-write; this is no
arbitrary host-object deep-copy admission. Prior rejected alias/kind oracles
remain in type-evaluated-values/. Scoped callable with is repaired by4 and
[[perl-generic-final-codeblock-normalization]] owns its frame mechanism.

CodeblockRuntime uses Numeric's separate scalar and aggregate dispatch. Scalar
names/aliases preserve the neutral contract and reject invalid shapes before
effects. Comparisons and array reducers terminate their chains. Invalid emitted
numeric shapes are complete undef expressions, not host-function fallthrough.
Aggregate word/canonical calls consume one array; min/max with explicit extra
operands use scalar evaluation before kind rejection. Array receiver reducers
take no arguments. Perl checks every term's legacy decimal spelling; empty sum
is0, other empty reducers undef. Rust's generic-filter path is separate.

Selected original min/max/odd-median strings retain an internal kind defect95:
current JSON can show a number while an array-write index still requires harray.
[[perl-numeric-reducer-string-result-kinds]] owns the exact public/flag evidence.
Boolean body literal35, Unicode coercion20 and constructor94 remain separate.
Deferred sorted/take pipelines raise unknown_helper:sorted and are owned next9.
No full helper/backend admission follows from aggregate availability.

Perl drop_keys materializes key operands and explicit splices/shapes, then deletes
a private key list from a copied harray. Normal/FATAL syntax loading is quiet;
later callbacks cannot change earlier keys. Source-kind errors/null-key warnings
remain; no portable reference-key coercion is admitted. Whole accepted numeric
and drop epochs survive in their checkpoints before aggregate7 bound writes.

The dated c053c9dcf inventory already listed substr and typed receivers.
Enumeration1 follows7/9 before mapping/layout; prior cards/proofs survive in Git.
'''
    fact=after[KIND]
    front=fact.split('---\n',2)[1]
    front=front.replace('date: 2026-09-26','date: 2026-10-21')
    front=re.sub(r'^title:.*$','title: Perl selected numeric-string results can hide string kind behind numeric JSON',front,flags=re.M)
    front=re.sub(r'^status:.*$','status: current internal-kind defect95; historical JSON observations qualified',front,flags=re.M)
    front=re.sub(r'^evidence:.*$','evidence: "Aggregate7 retains five public native/fresh index controls and scalar flags: selected min/max/odd median reject; scalar min/add succeed. JSON::PP4.06 emits1 for all five, while selected results retain POK/string kind."',front,flags=re.M)
    front=re.sub(r'^reverify:.*$','reverify: "bash tools/run_python_project_data.sh '+c.PREFIX+'verify_kinds.py"',front,flags=re.M)
    front=front.replace('date:','  - "can JSON show a number while Perl still treats a reducer result as a string"\ndate:',1)
    after[KIND]='---\n'+front+'''---

Array min/max and odd median return a selected original term rather than applying
the scalar numeric adapter's0+ conversion. Numeric comparisons can add numeric
flags while retaining POK. BindingRuntime::_runtime_kind gives that string flag
priority, so `index=min(["2","1"]); items[index]="changed"` requires a harray
and rejects an array with nested_write_kind_conflict. Max/odd-median twins fail;
scalar min/add controls update the array successfully. Scalar arithmetic such
as add(min(["2","1"]),0) supplies a numeric index as a workaround.

JSON alone does not prove language kind. Current Perl5.34.1/JSON::PP4.06 renders
all five results as1 despite the three selected string flags. The original95
eight-source record reported three quoted JSON results. Exact sources now render
numbers through current native/fresh execution, three controlled emitter epochs
and the192-input accepted91 owned Perl library with current system/dependency
prerequisites. The original instrument/process environment is unretained; those
quoted observations remain dated, not refreshed or assigned a guessed cause.

docs/checkpoints/type-aggregate-codeblocks/ retains raw channels, full source
epochs/restorations, direct JSON independent of projection, B flags and actual
public index failures.95 remains after93/92/94 before51: audit aggregate authority,
repair internal numeric kinds and add kind-sensitive recurrence. No95 fix or
all-input/backend result-kind admission follows from aggregate7's availability.
'''
    after[ARRAY]=after[ARRAY].replace('September reading `SESSION-STARTUP-READING.3.3.21`','September Rust reading `SESSION-STARTUP-READING.3.3.21`',1)
    after[ARRAY]+='\nThose filtering paths describe Rust. Perl retains an all-terms decimal-spelling check; see [[terse-type-method-surface-inventory]].\n'
    old_total=sum(path.stat().st_size for path in (c.ROOT/'docs/knowledge').glob('*.md'))
    new_total=old_total+sum(len(after[path].encode())-len(c.decode(before[path]['base64'])) for path in (TYPE,KIND,ARRAY))
    assert new_total<=8388608,(old_total,new_total)
    # Preserve all formal declarations and acceptance rows while moving completed3 chronology to custody.
    tree=after[TASK];start=tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.3`\n');end=tree.index('- ID: `TYPE-REFERENCE-BOOK.1.2.4`\n',start)
    old=tree[start:end]
    prefixes=('  Status:','  Goal:','  Dependencies:','  Verification tier:','  Focused checks:',
        '  Canonical trigger:','  Claim verification:','  Acceptance Checklist','  - [x]')
    keep=[line for line in old.splitlines() if line.startswith('- ID:') or line.startswith(prefixes)]
    keep.insert(4,'  Evidence/custody: docs/checkpoints/type-evaluated-values/README.md and accepted2fca7d848; complete prior root bytes also survive in aggregate7 docs-update.json.gz. Subsequent historical/required-consumer controls remain in their recorded source epochs.')
    new='\n'.join(keep)+'\n\n'
    formal=lambda text:[line for line in text.splitlines() if re.match(r'  (Verification tier|Focused checks|Canonical trigger):',line)]
    assert formal(old)==formal(new)
    tree=tree[:start]+new+tree[end:]
    assert len(tree.encode())<=65536
    after[TASK]=tree
    text=after[STARTUP];start=text.index('- ID: `SESSION-STARTUP-READING.95`\n');end=text.index('- ID: `SESSION-STARTUP-READING.96`\n',start)
    node=text[start:end]
    node=node.replace('  Planned focused proof: Strict serialized JSON kinds,',
        '  Planned focused proof: Internal scalar flags and public array-write index consumers plus strict serialized JSON kinds,',1)
    node+='''  Aggregate7 intake (2026-10-21): Current JSON::PP4.06 can emit1 while selected min/max/odd median retain POK/string kind. Three real native/fresh array-write indexes reject with nested_write_kind_conflict; scalar min/add controls succeed. Exact old8 now render numbers even with the accepted91 owned library under current system/dependency prerequisites; original producer/environment is unretained. Keep old observations historical. type-aggregate-codeblocks/verify_kinds.py owns independent current diagnosis;95 must repair internal kinds and add consumer recurrence. Priority/dependencies remain unchanged; no95 completion in7.

'''
    after[STARTUP]=text[:start]+node+text[end:]
    c.write_new('book-cases.json',dict(cases=cases))
    c.write_new('docs-update.json.gz',dict(before=before,after={path:c.encode(raw.encode()) for path,raw in after.items()},
        producer=c.read(c.PREFIX+'docs.py'),knowledge_before_bytes=old_total,knowledge_after_bytes=new_total,
        scope='Worked aggregate behavior and explicit pipeline9/kind95 limits. Preserve whole completed3 '
              'chronology before bounded-root compaction; all three formal declarations unchanged. '
              'Historical JSON95 is qualified rather than refreshed. No containment budget is raised.'))
    for path,raw in after.items():(c.ROOT/path).write_text(raw)
    index=c.run(['perl','tools/update_task_tree_index.pl','--tree','SESSION-STARTUP-READING'])
    c.write_new('docs-index.json.gz',dict(run=index,after={path:c.read(path) for path in (STARTUP,INDEX,STARTUP_ROOT)}))
    assert index['returncode']==0,c.decode(index['stderr_base64']).decode()
    print('Book3/facts/owned95 updated; Knowledge bytes',new_total,'; task bytes',len(tree.encode()))


if __name__=='__main__':main()
