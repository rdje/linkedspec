"""Describe the already measured legacy Boolean aggregate boundary precisely."""
import json
import common as c


def main():
    chapter='docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md'
    fact='docs/knowledge/perl-numeric-reducer-string-result-kinds.md'
    task='docs/tasks/SESSION-STARTUP-READING.50-99.md'
    index='docs/tasks/SESSION-STARTUP-READING.index.jsonl'
    before={path:c.read(path) for path in (chapter,fact,task,index)}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    rows={row['id']:row for row in json.loads(c.decode(c.load('candidate2-run.json.gz')['run']['stdout_base64']))['rows']}
    observed={name:rows[name] for name in ('ordinary/min/typed-boolean','deferred/min/typed-boolean')}
    assert all(row[route]['value'] is True for row in observed.values() for route in ('native','generated'))
    old="The older checks do not establish the\nscalar contract's finite-number and typed-boolean rules for aggregates."
    new="These older checks differ from the scalar finite-number and Boolean rules.\nPerl can accept typed Boolean items as `0`/`1`; for example, the minimum of\n`[and(1,1),3]` remains Boolean true. That input/result-kind boundary is part of\nthe pending aggregate authority and result-kind audit, not a new scalar rule."
    assert after[chapter].count(old)==1
    after[chapter]=after[chapter].replace(old,new,1)
    old="Array min/max and odd median return a selected original term rather than applying\nthe scalar numeric adapter's0+ conversion. Numeric comparisons can add numeric\nflags while retaining POK."
    new="Array min/max and odd median select terms without scalar0+ conversion;\ncomparisons can retain POK alongside numeric flags."
    assert after[fact].count(old)==1
    after[fact]=after[fact].replace(old,new,1)
    after[fact]=after[fact].replace('No95 fix or\nall-input/backend result-kind admission follows from aggregate7\'s availability.',
        'No95 fix or all-input/backend admission follows from7.',1)
    after[fact]+='\nThe retained minimum of [true,3] also remains Boolean;95 must audit input admission separately from numeric result kind.\n'
    total=sum(path.stat().st_size for path in (c.ROOT/'docs/knowledge').glob('*.md'))
    total+=len(after[fact].encode())-len(c.decode(before[fact]['base64']))
    assert total<=8388608,total
    needle='  Aggregate7 intake (2026-10-21):'
    line=next(line for line in after[task].splitlines() if line.startswith(needle))
    after[task]=after[task].replace(line,line+' The measured [true,3] minimum also remains Boolean; include intended Boolean admission versus numeric result kind in the authority audit.',1)
    c.write_new('boolean-clarity.json.gz',dict(before=before,after={path:c.encode(raw.encode()) for path,raw in after.items()},
        observed=observed,producer=c.read(c.PREFIX+'boolean_clarity.py'),knowledge_after_bytes=total))
    for path,raw in after.items():(c.ROOT/path).write_text(raw)
    run=c.run(['perl','tools/update_task_tree_index.pl','--tree','SESSION-STARTUP-READING'])
    c.write_new('boolean-index.json.gz',dict(run=run,after=c.read(index)))
    assert run['returncode']==0
    print('Measured Boolean boundary qualified; Knowledge bytes',total)


if __name__=='__main__':main()
