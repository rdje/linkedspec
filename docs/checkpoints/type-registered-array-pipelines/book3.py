"""Execute unchanged rendered bodies and exact inline example on final guarded source."""
import common as c
import book
import oracle

def main():
    supplied=c.load('book-inputs.json.gz')['inputs']
    assert all(c.read(p)==packet for p,packet in supplied.items())
    plan=book.examples()
    inline=c.load('inline-before-compatibility.json.gz')['plan']
    assert 'length([2,10,1]).abs()' in c.source(book.document.CHAPTER).read_text()
    context=c.epoch()
    run=c.observe(plan)
    inline_run=c.observe(inline)
    failures=oracle.failures(run,plan)
    inline_failures=oracle.failures(inline_run,inline)
    c.write_new('book3-run.json.gz',dict(context=context,run=run,plan=plan,failures=failures,
        inline_plan=inline,inline=inline_run,inline_failures=inline_failures,
        producer=c.read(c.PREFIX+'book3.py'),book_inputs_unchanged=all(c.read(p)==packet for p,packet in supplied.items())))
    assert not failures and not inline_failures,(failures,inline_failures)
    print('Final code executes both rendered examples and two exact inline routes')

if __name__=='__main__':main()
