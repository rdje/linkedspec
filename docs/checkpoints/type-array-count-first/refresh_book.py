"""Align the two first-selection result labels with the verified stored-value contract."""
import common as c
import context


def main():
    path = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
    before = c.read(path)
    c.write_new('book-result-label-inputs.json.gz',context.snapshot())
    text = c.decode(before['base64']).decode()
    for helper in ('items.drop_front(index).first','meta.pick_keys(key).sorted_values().first'):
        old = '| `'+helper+'` | scalar value or `undef` |'
        assert text.count(old) == 1
        text = text.replace(old,'| `'+helper+'` | stored value or `undef` |',1)
    c.source(path).write_text(text)
    c.source(path).chmod(before['mode'])
    proof = c.source(c.PREFIX+'doc_proof.py').read_text()
    assert proof.count("else 'doc'") == 1
    proof = proof.replace("else 'doc'","else 'doc2'",1)
    with (c.ROOT/c.PREFIX/'doc_proof2.py').open('x') as output:
        output.write(proof)
    c.write_new('book-result-labels.json.gz',dict(before=before,after=c.read(path),
        producer=c.read(c.PREFIX+'refresh_book.py'),proof=c.read(c.PREFIX+'doc_proof2.py'),
        scope='First returns its stored value, including containers and callable records. Two existing first rows now use that precise result label. Actual fixed-plan and worked selection proofs constrain the behavior. Final complete book proof uses distinct doc2 outputs; original89/5 proof stays exact.'))
    print('Two first result labels aligned; distinct final book producer prepared')


if __name__ == '__main__':
    main()
