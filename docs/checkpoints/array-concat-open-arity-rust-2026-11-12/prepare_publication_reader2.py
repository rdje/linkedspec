"""Route publication to qualified2 recovery and preserve all actual failed attempts."""
import gzip
from pathlib import Path

BASE = Path(__file__).resolve().parent


def candidate(name):
    source = (BASE / name).read_text()
    image = BASE / (name + '.unexecuted.gz')
    assert not image.exists()
    image.write_bytes(gzip.compress(source.encode(), mtime=0))
    return source


source = candidate('publish_qualified.py')
source = source.replace('review-qualified', 'review-qualified2')
source = source.replace('review_qualified.py', 'review_qualified2.py')
source = source.replace('first independent readonly', 'qualified2 readonly').replace('first readonly', 'qualified2 readonly')
source = source.replace('first full independent qualified readonly reader exits0', 'qualified2 independent readonly reader exits0')
anchor = 'The qualified2 independent readonly reader exits0'
assert source.count(anchor) == 1
source = source.replace(anchor, '''The original qualified reader exits1 before acceptance because a legacy reversed-
Array/source-pair case and the new concat nested-kinds cases share a question label.
Separate qualified2 scopes new intent to questions108, anchors all case metadata
to the original intake and rejects the actual origin-collision control. Original
reader/source/seal/failure remain exact; no SDK observation or expectation changes.
The first publication-preparer1 catches a literal escaping error at its compile
guard before any live document write; a separate preparer2 passes with the original
failure/proposals retained. The qualified2 independent readonly reader exits0''', 1)
anchor = 'Related: [[rust-callable-array-transform-result-guards]],'
assert source.count(anchor) == 1
source = source.replace(anchor, '''Original qualified reader1 exposes a legacy/new question-label collision;
qualified2 limits the new nested intent to questions108 and anchors case metadata
to intake. Its collision control is RED. Original sources/seal/failure remain,
with no SDK/fixture change. The publication-preparer1 compile-guard escaping
failure is retained; its separate corrected preparer writes no SDK data.

Related: [[rust-callable-array-transform-result-guards]],''', 1)
source = source.replace('first independent readonly0', 'qualified2 readonly0')
compile(source, 'publish_qualified2.py', 'exec')
(BASE / 'publish_qualified2.py').write_text(source)

source = candidate('run_publication_qualified.py')
source = source.replace('publish_qualified.py', 'publish_qualified2.py')
source = source.replace('run_publication_qualified.py', 'run_publication_qualified2.py')
source = source.replace('review_publication_qualified.py', 'review_publication_qualified2.py')
source = source.replace('review_qualified.py', 'review_qualified2.py')
source = source.replace('review-qualified', 'review-qualified2')
anchor = "    for name in ('stdout.log.gz', 'stderr.log.gz', 'exit.txt')]\n"
assert source.count(anchor) == 1
source = source.replace(anchor, anchor + '''reports += [str(REL / 'launches' / tag / name) for tag in (
    'direct', 'remaining', 'prepare-publication-qualified', 'prepare-publication-qualified2', 'review-qualified')
    for name in ('stdout.log.gz', 'stderr.log.gz', 'exit.txt')]
''', 1)
compile(source, 'run_publication_qualified2.py', 'exec')
(BASE / 'run_publication_qualified2.py').write_text(source)

source = candidate('review_publication_qualified.py')
source = source.replace('publish_qualified.py', 'publish_qualified2.py')
source = source.replace('run_publication_qualified.py', 'run_publication_qualified2.py')
source = source.replace('review_publication_qualified.py', 'review_publication_qualified2.py')
source = source.replace('review-qualified', 'review-qualified2')
source = source.replace('first readonly', 'qualified2 readonly')
# The additional source reports are inputs to this independent document oracle.
anchor = "    report = json.loads(gzip.decompress(inputs[prefix + 'review-qualified2/stdout.log.gz']))\n"
assert source.count(anchor) == 1
check = '''    for tag, status in (('direct', 1), ('remaining', 1), ('prepare-publication-qualified', 1),
        ('prepare-publication-qualified2', 0), ('review-qualified', 1)):
        assert inputs[prefix + tag + '/exit.txt'] == (str(status) + chr(10)).encode(), 'original publication failure status'
    assert b'SyntaxError: unterminated string literal' in gzip.decompress(inputs[prefix + 'prepare-publication-qualified/stderr.log.gz']), 'original preparer failure mechanism'
    assert b'AssertionError: supported terminal' in gzip.decompress(inputs[prefix + 'review-qualified/stderr.log.gz']), 'original reader failure mechanism'
'''
source = source.replace(anchor, check + anchor, 1)
compile(source, 'review_publication_qualified2.py', 'exec')
(BASE / 'review_publication_qualified2.py').write_text(source)
print('Prepared qualified2 publication/default readers and complete original failure-report custody; no live documents written')
