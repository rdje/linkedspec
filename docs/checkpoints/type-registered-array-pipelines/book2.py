"""Re-execute the exact unchanged book bodies on the minimized final runtime."""
import common as c
import book
import oracle

def main():
    supplied=c.load('book-inputs.json.gz')['inputs']
    assert all(c.read(p)==packet for p,packet in supplied.items())
    plan=book.examples()
    context=c.epoch()
    run=c.observe(plan)
    failures=oracle.failures(run,plan)
    c.write_new('book2-run.json.gz',dict(context=context,run=run,plan=plan,failures=failures,
        producer=c.read(c.PREFIX+'book2.py'),book_inputs_unchanged=all(c.read(p)==packet for p,packet in supplied.items())))
    assert not failures,failures
    print('Final runtime executes both unchanged rendered book examples')

if __name__=='__main__':main()
