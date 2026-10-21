"""Install permanent fixtures and the complete-book proof actor after source faults restore."""
import common as c

def main():
    test='t/scalar_numeric_contract.t'
    before=c.read(test);text=c.decode(before['base64']).decode()
    old='qw(cases effects stability receiver-invalid terminals)'
    assert text.count(old)==1
    after=text.replace(old,'qw(cases effects stability receiver-invalid terminals pipelines)',1).encode()
    fixture='tests/numeric-codeblocks/pipelines.json'
    with (c.ROOT/fixture).open('xb') as output:output.write((c.ROOT/(c.PREFIX+'cases3.json')).read_bytes())
    (c.ROOT/test).write_bytes(after)
    book=(c.ROOT/'docs/checkpoints/type-aggregate-codeblocks/doc_proof.py').read_text()
    book=book.replace("HEADING=b'### Aggregate numeric helpers in codeblocks'","HEADING=b'### Sorting and taking inside Perl codeblocks'").replace('id="aggregate-numeric-helpers-in-codeblocks"','id="sorting-and-taking-inside-perl-codeblocks"').replace('aggregate heading','pipeline heading').replace('aggregate-book-','pipeline-book-')
    book=book.replace("snapshot=context.snapshot(extras)","snapshot=context.snapshot(extras+['tests/numeric-codeblocks/pipelines.json'])")
    book=book.replace("section=text.split(HEADING.decode()+'\\n',1)[1].split('\\n### ',1)[0]", "section=re.split(r'\\n#{1,3} ',text.split(HEADING.decode()+'\\n',1)[1],maxsplit=1)[0]")
    with (c.ROOT/(c.PREFIX+'doc_proof.py')).open('x') as output:output.write(book)
    focused=(c.ROOT/'docs/checkpoints/type-aggregate-codeblocks/focused.py').read_text()
    focused=focused.replace('snapshot=context.snapshot(extras)',"snapshot=context.snapshot(extras+['tests/numeric-codeblocks/pipelines.json'])")
    with (c.ROOT/(c.PREFIX+'focused.py')).open('x') as output:output.write(focused)
    c.write_new('permanent-migration.json.gz',dict(producer=c.read(c.PREFIX+'prepare_validation.py'),before=before,after=c.read(test),fixture=c.read(fixture),cases=len(c.load('cases3.json')['cases'])))
    print('Permanent85 fixture installed; original runner and doc/focused producers retained')

if __name__=='__main__':main()
