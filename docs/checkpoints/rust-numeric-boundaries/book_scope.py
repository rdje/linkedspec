"""Clarify strict writes versus preserved read/count coercions."""
import importlib.util
import common as c
import book_sources as plan
import book_render

spec=importlib.util.spec_from_file_location('numeric_scope_book',c.ROOT/plan.HELPER)
book=importlib.util.module_from_spec(spec);spec.loader.exec_module(book)
before=book.inputs()
raw=c.decode(before[plan.FLOW]['base64'])
old=(b'The hash constructor converts its key to text; numeric bracket selectors address arrays. '
    b'Existing index positions and source metadata must fit the host index type; an out-of-range integer rejects rather than becoming the largest index.')
new=(b'The hash constructor converts its key to text; a numeric bracket in a nested write selects an array. '
    b'Positive nested-write selectors and integer source metadata are checked against the host index bound. '
    b'Out-of-range writes fail before structural changes. Ordinary array reads and bounded counts keep their existing coercions.')
assert raw.count(old)==1
(c.ROOT/plan.FLOW).write_bytes(raw.replace(old,new,1))
supplied=book.inputs();healthy=book_render.render(supplied);plan.validate(book,healthy)
assert new.decode() in c.decode(healthy['page_base64']).decode()
fault_inputs=plan.changed(supplied,plan.FLOW,new,old)
fault=book_render.render(fault_inputs);assert fault['returncode']==0
assert new.decode() not in c.decode(fault['page_base64']).decode()
c.save('book7-scope.json.gz',dict(before=before,after=supplied,healthy=healthy,
    fault_input=fault_inputs[plan.FLOW],fault=fault,examples=plan.EXAMPLES,
    producer=c.read(c.PREFIX+'book_scope.py'),
    scope='Correct an overbroad index sentence: only positive nested writes and metadata '
        'receive the new strict boundary. Existing read/count coercions remain. Both '
        'executed example source blocks are unchanged from the actual52-case CLI proof.'))
assert all(c.read(path)==packet for path,packet in supplied.items())
print('Precise write/metadata scope rendered; broad-policy source control rejected; examples unchanged.')
