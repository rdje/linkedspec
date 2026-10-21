"""Retain rejected Knowledge pressure proposal and compact the existing type card."""
import common as c


def main():
    path=c.PREFIX+'docs.py'
    before=c.read(path)
    run=c.run(['bash','tools/run_python_project_data.sh',path])
    assert run['returncode']!=0 and b'(8388583, 8388889)' in c.decode(run['stderr_base64'])
    raw=c.decode(before['base64']).decode()
    old='''The July4 inventory at c053c9dcf and its proposal already listed substr and
scalar/array/hash/number receivers; those dated, partly retired spellings guide
navigation. Current complete enumeration1 follows7/9 before book mapping/layout.
Historical scalar/type proof at accepted203cde315 and later qualifiers survive
in Git/checkpoints; this card is the bounded current view.'''
    new='''The dated c053c9dcf inventory already listed substr and typed receivers.
Enumeration1 follows7/9 before mapping/layout; prior cards/proofs survive in Git.'''
    assert raw.count(old)==1
    after=raw.replace(old,new,1)
    old='''Bindings hold scalar, array, harray or codeblock; integer/real notation creates
no namespace. String, number, boolean and null remain distinct. Numeric
comparisons yield numeric1/0; logical helpers yield booleans. Generic with can
pass false through; deferred bodies read current caller slots. Callable-yielded
arrays use ordinary array methods, not a new codeblock method table.'''
    new='''Bindings hold scalar, array, harray or codeblock. String/number/boolean/null
remain distinct. Numeric comparisons yield1/0; logical helpers yield booleans.
Generic with passes false; deferred bodies read caller slots. Callable-yielded
arrays use ordinary methods, not a codeblock table.'''
    assert after.count(old)==1
    after=after.replace(old,new,1)
    c.write_new('docs-size-preparation.json.gz',dict(before=before,run=run,after_base64=c.encode(after.encode()),
        scope='Rejected before writes. Compact only existing current type narrative; original source '
              'and all fact bytes remain recoverable, no Knowledge or task budget raised.'))
    (c.ROOT/path).write_text(after)


if __name__=='__main__':main()
