"""Keep unexecuted publication proposals and disclose the exact direct qualification."""
import gzip
from pathlib import Path

BASE = Path(__file__).resolve().parent


def proposal(name):
    source = (BASE / name).read_text()
    image = BASE / (name + '.unexecuted.gz')
    if image.exists():
        assert gzip.decompress(image.read_bytes()) == source.encode()
    else:
        image.write_bytes(gzip.compress(source.encode(), mtime=0))
    return source


source = proposal('publish.py')
source = source.replace("('review', 'current', 'format', 'review-publication')", "('review-qualified', 'current-qualified', 'format', 'review-publication')")
source = source.replace('launches/review/', 'launches/review-qualified/').replace('launches/current/', 'launches/current-qualified/')
source = source.replace("REL}/review.py", "REL}/review_qualified.py").replace('review.py is the historical', 'review_qualified.py is the historical')
source = source.replace('direct1205', 'combined direct1205')
anchor = 'Direct504+195+312+194=1205 pass; rustfmt passes.'
assert source.count(anchor) == 1
source = source.replace(anchor, '''The first direct controller exits1: new504 pass and ordinary193 pass, while two
additional old ordinary profile projections fail with actual101. Exact source-only
four-program terminal/composed probes on the same private original/current SDK pass
all four routes: terminal [["b","a","z",1],"SX"] stays exact, while the later Hash
consumer now rejects before K/W. Only those two ordinary profile projections change;
they are outside main504 and grant no portable scalar-input authority. Their two
filtered normals pass, and the previously unexecuted callable312/pipeline194 pass.
Combined unique focused coverage is504+193+2+312+194=1205; the successful504/193
groups are not replayed and the original actual1/101 channels remain. Completion
retains1008 already-written original normal snapshots after the controller failure,
without claiming an earlier archive event. SDK remains only two changed lines.
Rustfmt passes.''', 1)
anchor = 'Neither those controls nor malformed calls grant portable input/signature authority.'
source = source.replace(anchor, anchor + '\nThe two additional ordinary-profile transfers are disclosed separately below.', 1)
anchor = 'complete operation/context/population or raw typed diagnostic authority.'
# The current text wraps this sentence; scope is also explicit in the qualification paragraph.
source = source.replace('The first full independent readonly reader exits0', 'The first full independent qualified readonly reader exits0')
anchor = 'Same-path old18RED-current504/combined direct1205 and first readonly{controls}/current{current}'
assert source.count(anchor) == 1
source = source.replace(anchor, '''The first direct controller1 retains new504PASS plus ordinary193PASS/two older
expectation failures. Exact four-route same-path old/current probes preserve their
terminal Array/SX and qualify only two outside504 ordinary projections. Filtered
two plus previously unexecuted callable312/pipeline194 pass; combined unique
coverage is504+193+2+312+194=1205 without replaying completed groups. Original
failure channels and1008 completed normal snapshots remain recoverable.

Same-path old18RED-current504/combined direct1205 and first readonly{controls}/current{current}''', 1)
anchor = 'Its16 supported repairs retain source-once S/T/U, valid rest-argument X effects,'
assert source.count(anchor) == 1
paragraph = 'Two additional older ordinary expectations at that same scalar-operand boundary\nare independently qualified by exact old/current terminal/composed probes; their\nterminal values/effects stay exact and their later Hash consumer now skips K/W.\nThe original failed direct run remains recorded. These controls sit outside504.\n'
source = source.replace(anchor, paragraph.replace(chr(10), chr(92) + 'n') + anchor, 1)
source = source.replace('Independent Dart80.3 is next. Evidence: {REL}/REVIEW.md.',
    'The first direct1/ordinary193+2 failure is retained; two extra ordinary expectations outside504 are qualified through exact terminal/composed old/current probes, and only missing508 checks then pass. Independent Dart80.3 is next. Evidence: {REL}/REVIEW.md.')
compile(source, 'publish_qualified.py', 'exec')
(BASE / 'publish_qualified.py').write_text(source)

source = proposal('run_publication.py')
source = source.replace("'publish.py'", "'publish_qualified.py'").replace("'run_publication.py'", "'run_publication_qualified.py'").replace("'review_publication.py'", "'review_publication_qualified.py'")
source = source.replace("('review', 'current', 'format', 'review-publication')", "('review-qualified', 'current-qualified', 'format', 'review-publication')")
source = source.replace("REL / 'review.py'", "REL / 'review_qualified.py'")
source = source.replace('review_publication.py recovers', 'review_publication_qualified.py recovers')
source = source.replace('Same-path old18-current504 and direct1205 pass;', 'Same-path old18-current504 and combined1205 unique focused checks pass;')
compile(source, 'run_publication_qualified.py', 'exec')
(BASE / 'run_publication_qualified.py').write_text(source)

source = proposal('review_publication.py')
source = source.replace("('review', 'current', 'format', 'review-publication')", "('review-qualified', 'current-qualified', 'format', 'review-publication')")
source = source.replace("'review/stdout.log.gz'", "'review-qualified/stdout.log.gz'").replace("'current/stdout.log.gz'", "'current-qualified/stdout.log.gz'")
source = source.replace("'publish.py', 'run_publication.py', 'review_publication.py'", "'publish_qualified.py', 'run_publication_qualified.py', 'review_publication_qualified.py'")
source = source.replace("REL / 'review_publication.py'", "REL / 'review_publication_qualified.py'")
source = source.replace("REL / 'launches/review/exit.txt'", "REL / 'launches/review-qualified/exit.txt'")
anchor = "    controls = len(report['corruption_controls']); current = identity['declared_inputs']\n"
assert source.count(anchor) == 1
source = source.replace(anchor, "    assert report['original_direct_exit'] == 1 and report['original_ordinary_passed'] == 193 and report['qualified_missing_checks'] == 508, 'publication qualification'\n" + anchor, 1)
compile(source, 'review_publication_qualified.py', 'exec')
(BASE / 'review_publication_qualified.py').write_text(source)
print('Prepared qualified publication: original direct1/ordinary193+2, exact old/current probes and missing508 are explicit; original proposals remain unexecuted')
