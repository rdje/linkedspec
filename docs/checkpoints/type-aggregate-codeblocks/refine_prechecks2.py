"""Retain the second pressure rejection and leave useful room in the current card."""
import common as c


def main():
    path=c.PREFIX+'final_prechecks.py'
    before=c.read(path)
    run=c.run(['bash','tools/run_python_project_data.sh',path])
    assert run['returncode']!=0 and b'AssertionError: 8388619' in c.decode(run['stderr_base64'])
    raw=c.decode(before['base64']).decode()
    anchor="    total=sum(path.stat().st_size for path in (c.ROOT/'docs/knowledge').glob('*.md'))"
    addition='''    verbose="""CodeblockRuntime uses Numeric's separate scalar and aggregate dispatch. Scalar
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
'''
    assert raw.count(anchor)==1
    after=raw.replace(anchor,addition+anchor,1)
    c.write_new('final-prechecks-pressure2.json.gz',dict(before=before,run=run,after_base64=c.encode(after.encode()),
        scope='Second rejected size proposal precedes writes; compact current numeric/drop prose while '
              'preserving exact semantics, prior bytes, limits and the original budget.'))
    (c.ROOT/path).write_text(after)


if __name__=='__main__':main()
