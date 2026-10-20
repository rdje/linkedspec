"""Guard the final live publisher against the preserved complete second draft."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
path = c.PREFIX + 'publish.py'
before = c.read(path)
assert before == preserved['before'][path]
assert c.read(c.CLAIM) == preserved['original_claim']
source = c.decode(before['base64']).decode()
assert source.count('import review\n') == 1
source = source.replace('import review\n', 'import review_phase0 as review\n', 1)
source = source.replace('publication-final.json', 'publication-phase0.json')
source = source.replace('publication-final-inputs.json', 'publication-phase0-inputs.json')
old = "'../TYPE-REFERENCE-BOOK.1.2.3-publication-guard.json.gz'"
new = "'../TYPE-REFERENCE-BOOK.1.2.3-phase0-preservation.json.gz'"
assert source.count(old) == 1
source = source.replace(old, new, 1)
anchor = "paths.update(review.load('docs-proposals.json.gz')['proposals'])"
assert source.count(anchor) == 1
source = source.replace(anchor, anchor + '''
paths.update(review.phase0_records.current_proposals(
    review.load('final-inputs.json.gz')['inputs'], review.load('docs-proposals.json.gz')))
paths.update(path.relative_to(c.ROOT).as_posix() for path in
    (c.ROOT / 'docs/checkpoints').glob('TYPE-REFERENCE-BOOK.1.2.3-*') if path.is_file())
''', 1)
anchor = "assert result['result'] == 'PASS'"
assert source.count(anchor) == 1
source = source.replace(anchor, anchor + "\ngraph = result['graph']", 1)


def field(name, next_name, expression):
    global source
    start = source.index('    ' + name + '=')
    end = source.index('    ' + next_name + '=', start)
    source = source[:start] + '    ' + name + '=' + expression + ',\n' + source[end:]


statement = (
    'Perl emitted array/harray members, constructor operands, dynamic keys and callable arguments '
    'retain each evaluated value before later sibling effects. Accepted runtime rejects19 of23 '
    'finite cases with four healthy controls; candidate Get/fresh generated match all23 values/kinds. '
    'Seven selected suites pass from declared277 test/data/bin inputs. Six actual source faults '
    'reject19/14/2/1/1/1 cases and restore. Additional focused52 uses a frozen1651-input snapshot, '
    '982 explicit skipped roots,130 value/diagnostic goldens and unchanged native/descriptor checks. '
    'An actual value-observer fault rejects129 goldens with one valid null control and exact restoration; '
    'a missing selector rejects all-skip false acceptance. Two historical compiler advisories are '
    'explicit data. Current Knowledge {graph[markdown]}/{graph[facts]}/{graph[question_keys]} preserves '
    '{graph[list_items]} entries/{graph[list_fields]} fields at {result[knowledge_bytes]} bytes. '
    'Complete89-input book/heading denial and whole prior388/full68814 reader in2706 supplied files '
    'pass with exact prior channels and supplied bytes/modes unchanged. Generated single-key drop '
    'warns and fatal caller loading rejects; that separate defect remains owned by .1.2.6.'
)
field('statement', 'scope', 'f' + repr(statement))
field('scope', 'rederive', repr(
    'Finite Perl evaluated-list repair at real c053 source boundary plus declared current proposals. '
    'Explicit splices keep list behavior; no deep-copy/alias, exhaustive methods, cross-backend or '
    'private/parent admission. Original wrong push oracle, first candidate, no-write source/doc '
    'writers, incomplete syntax2/TAP2 context, dated graph count failure and uncommitted568/91709 '
    'and573/92573 drafts remain recoverable with actual source/modes; no fabricated historical '
    'revision. Original bare Phase01035 transcript is supplemental, lacking an initial environment '
    'snapshot/separate channels/full per-read input closure; it has140 spelling failures and a '
    'wrapper-bypass volume failure with explicit cleanup. Fresh source-closed focused52 has982 '
    'explicit skips and is not ordinary all1035 admission. Three first focused fixture compile '
    'failures stay retained; declared caller presence maps repair fixtures without changing goldens. '
    'Historical-oracle preparation/load and zero-stderr postcondition failures remain exact; two '
    'actual advisories are attributed rather than suppressed. Scoped-with4, deferred numeric5, '
    'generated drop6, boolean literal startup35 and caller shadowing startup32 remain owned. '
    'Canonical exact-staged receipt, ordinary all1035 and normal hooks are separately required before landing.'))
field('rederive', 'falsify', repr(dict(status='checked',
    command='bash tools/run_python_project_data.sh ' + c.PREFIX + 'publish.py',
    granularity='Each23 native/generated value and primitive kind; seven selected suites;130 finite '
        'historical/manual compatibility values; focused52 names/numbers and explicit skip population; '
        'every supplied snapshot byte/mode; current complete graph/book; whole prior publication.',
    result='Accepted19 RED/four controls and candidate23 GREEN; selected seven suites0; focused52 '
        'PASS with982 explicit skips; actual value-helper129 RED/one null control/restoration and '
        'missing-selector RED; current graph/book/whole original reader PASS. Public generated '
        'drop advisory and FATAL loading RED remain unresolved under .1.2.6.')))
field('falsify', 'durability', repr(dict(status='checked',
    hypothesis='Perl lvalues could change earlier observations; scalar snapshots could erase splices; '
        'a value observer could return null, a selector could skip every test, a compiler advisory '
        'could be silently dropped, or environment/missing inputs could masquerade as behavior.',
    oracle='Independent fixed23 values/kinds, saved-binding and host controls, real accepted source, '
        '106 accepted historical test expectations plus24 independent manual fixtures, exact original '
        'root names/numbers, intact ordinary-file assertions, generated anchors and actual prior channels.',
    red_control='Syntax-valid accepted runtime19 RED. Six actual emitter faults reject19/14/2/1/1/1 '
        'cases and restore. Actual value-observer execution bypass rejects129 assertions while one '
        'genuine null remains; healthy source restores focused52. An absent selector executes zero '
        'selected groups and exits nonzero despite all excluded groups being SKIP. Changed heading '
        'builds0 but loses its required anchor. Three fixture compile errors cannot match value goldens. '
        'Actual generated single-key drop loading emits one warning and caller FATAL syntax rejects; '
        'no global warning policy is weakened.')))
raw = source.encode()
after = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before['mode'])
c.write_new(P + 'publication-proposal.json.gz', dict(before={path: before}, after={path: after},
    producer=c.read(P + 'publication.py'), helper=c.read(c.PREFIX + 'common.py'),
    original_claim=preserved['original_claim'],
    scope='Full second draft and actual unchanged readonly baseline precede the final publisher. '
          'Every earlier actor/capsule remains intact; the stable entrypoint now uses the separate '
          'layered reader and new manifest/receipt. Its manifest is directly bound. No remeasurement '
          'or historical-Git identity is assigned to either uncommitted draft.'), packed=True)
assert c.read(path) == before
(ROOT / path).write_bytes(raw)
assert c.read(path) == after
print('Stable publisher now owns the layered Phase0/diagnostic epoch; both earlier drafts remain intact')
