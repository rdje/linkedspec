"""Render the complete numeric source/support admission boundary."""
import importlib.util
import common as c
import book_sources as plan
import book_render

spec=importlib.util.spec_from_file_location('numeric_support_book',c.ROOT/plan.HELPER)
book=importlib.util.module_from_spec(spec);spec.loader.exec_module(book)
before=book.inputs()
old=('Rust numeric admission permits only the exact reviewed Cargo feature and engine source images, '
    'retaining the signed-selector source pair as a checked predecessor.')
new=('Rust numeric admission binds the exact reviewed Cargo/engine images and all five changed numeric support files, '
    'retaining the signed-selector source pair as a checked predecessor.')
raw=c.decode(before[plan.DEV]['base64']);assert raw.count(old.encode())==1
(c.ROOT/plan.DEV).write_bytes(raw.replace(old.encode(),new.encode(),1))
supplied=book.inputs();healthy=book_render.render(supplied);plan.validate(book,healthy)
page='development/local-ci-and-regression.html'
assert new in c.decode(healthy['outputs'][page]['base64']).decode()
changed=plan.changed(supplied,plan.DEV,new.encode(),b'Rust numeric admission ignores its numeric support files.')
fault=book_render.render(changed);assert fault['returncode']==0
assert new not in c.decode(fault['outputs'][page]['base64']).decode()
c.save('book8-support.json.gz',dict(before=before,after=supplied,healthy=healthy,
    fault_input=changed[plan.DEV],fault=fault,statement=new,examples=plan.EXAMPLES,
    producers={name:c.read(name) for name in [c.PREFIX+'book_support.py',
        c.PREFIX+'book_render.py',c.PREFIX+'book_sources.py',c.PREFIX+'common.py',plan.HELPER]},
    scope='Whole supplied book renders the exact two-primary/five-support boundary. '
        'Actual changed admission statement rejects. Numeric code examples stay exact '
        'and retain their independently observed CLI result; no new runtime admission.'))
assert all(c.read(path)==packet for path,packet in supplied.items())
print('Complete two-primary/five-support admission rendered; changed-statement control rejects.')
