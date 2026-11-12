"""Keep the original failure and complete its bounded documentation qualification."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT).as_posix()
OUT = BASE / 'landing-supplement'
OUT.mkdir()
names = ['docs/knowledge/github-size-safe-publication.md', 'MEMORY.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
    'docs/linkedspec-book/src/appendix/backend-handoff.md', REL + '/REVIEW.md',
    REL + '/landing-pressure/result.json', REL + '/complete_landing_qualification.py',
    REL + '/publication-git-card-inputs/result.json', REL + '/launches/review-git-card-query/stdout.log.gz',
    REL + '/launches/review-git-card-query/stderr.log.gz', REL + '/launches/review-git-card-query/exit.txt']


def freeze(tag):
    rows = {}
    with tarfile.open(OUT / (tag + '.tar.gz'), 'x:gz') as packed:
        for name in names:
            path = ROOT / name; body = path.read_bytes()
            rows[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            packed.add(path, arcname=name, recursive=False)
    with tarfile.open(OUT / (tag + '.tar.gz')) as packed:
        assert set(packed.getnames()) == rows.keys()
        for member in packed:
            body = packed.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    (OUT / (tag + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


freeze('before')
query = json.loads((BASE / 'publication-git-card-inputs/result.json').read_bytes())
assert query['claim_records'] == 206 and not query['checked_intersections'] and not query['live_intersections']
assert (BASE / 'launches/review-git-card-query/exit.txt').read_text() == '0\n'
assert gzip.decompress((BASE / 'launches/review-git-card-query/stderr.log.gz').read_bytes()) == b''
correction = json.loads((BASE / 'landing-pressure/result.json').read_bytes())
assert (correction['original_recent_rows'], correction['corrected_recent_rows']) == (17, 16)
card = ROOT / names[0]; source = card.read_text()
source = source.replace('title: Publish oversized history through measured incremental packs on a temporary upload branch', 'title: Monitor outgoing packs and publish around the director 1.5 GB budget', 1)
source = source.replace('date: 2026-11-04', 'date: 2026-11-12', 1)
source = source.replace('status: backlog published at d3a26a94f5c2; bounded logical input custody reviewed', 'status: early-push policy adopted; November4 backlog historical; new operational custody gaps owned by23.4.30', 1)
anchor = '  - "are successive Git range object lists disjoint"\n'
assert source.count(anchor) == 1
source = source.replace(anchor, anchor + '''  - "when must LinkedSpec push before batch cadence completes"
  - "what is the conservative GitHub outgoing push budget"
  - "why can packed object count exceed the outgoing revision list"
  - "how does sparse Git pack walking add already remote objects"
''', 1)
anchor = '\nGitHub documents a maximum 2 GiB single push'
assert source.count(anchor) == 1
current = f'''
Current director override, November12: monitor the estimated serialized outgoing
pack after every leaf and before large growth. Publish around1,500,000,000 bytes
(decimal1.5GB), even before a PNT/batch cadence boundary. Prepare with enough margin
for canonical proof/receipts; every push still requires clean exact-HEAD canonical
CI, normal hooks and observed remote acceptance. Commit count and repository disk
usage do not substitute for outgoing pack size. Formal monitor/discovery/publication
owner TYPE-REFERENCE-BOOK.1.2.23.4.30 follows clean Dart80.3. The old one-off uploader
below remains retired; this directive does not authorize replaying it or rewriting
history. Future estimates must bind actual refs and disclose remote freshness.

The first operational HEAD1753884257bed7ce0b842bc406c665671403a828 versus cached
origin4683555ec51f04b8977812ce4e984c5cc6e6f42c estimate is1,233,210,937 bytes/101
commits. It excludes the uncommitted Dart slice and is not actual negotiated wire
size. Source/commands/metadata live at {REL}/push-monitor-current/.
The actual pack header45148 and outgoing revision-list45143 are different
populations: all five additional blobs already occur at the base. A first
added-delta-base hypothesis fails because none has delta children. Disabling only
sparse walking removes exactly these five and yields the full45143 logical set.
Git documents that sparse walking can include extra objects:
https://git-scm.com/docs/git-pack-objects#Documentation/git-pack-objects.txt---sparse.
Keep the larger conservative estimate. Raw packs/indexes stay ignored on this
volume. The scoped operational claim at docs/claims/TYPE-REFERENCE-BOOK.1.2.23.3.80.3.json
has checked re-derivation and explicitly missing independent historical size
falsification/complete physical artifact/toolchain durability, owned by23.4.30.
Logical metadata equality does not close these gaps or promise a future upload.

The November4 workflow below is dated historical evidence.
'''
source = source.replace(anchor, '\n' + current + anchor, 1)
card.write_text(source)
task = ROOT / names[2]; source = task.read_text(); start = source.index('- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.80.3`'); end = source.index('\n- ID:', start + 1)
part = source[start:end].replace('Status: `in_progress` / bounded focused proof complete; landing correction', 'Status: `completed` / bounded focused proof; qualified landing correction', 1)
part += '\n  Landing qualification: Original first normal commit1/eight PASS/two dependent failures remains in landing-pressure/ with exact combined log/mode/full17-row view/rotated accepted row. Separate qualify_live_status.py rotates only that oldest row under ADR0066; actual focused document-history0 restores16 without runtime/fixture replay. Original publisher/reader/seal/publication outputs remain immutable. Separate Git-card query/recovery0 proves206 accepted records/zero checked or live bindings before canonical policy-card edits; old claim/hash/revision values stay exact. New director threshold and demonstrated sparse object scope are now in the existing canonical fact home, with both operational claim gaps explicit. Final normal retry still required.\n'
task.write_text(source[:start] + part + source[end:])
memory = ROOT / 'MEMORY.md'; source = memory.read_text().replace('`TYPE-REFERENCE-BOOK.1.2.23.3.80.3` (in_progress)', '`TYPE-REFERENCE-BOOK.1.2.23.3.80.3` (completed)', 1)
start = source.index('- next_action:'); end = source.index('\n- blockers:', start)
source = source[:start] + '- next_action: After the clean Dart commit, remeasure committed outgoing pack and activate23.4.30 publication-budget preparation/discovery before further feature growth; exact clean-HEAD canonical CI before any early push. Independent Julia80.4 follows the publication boundary.\n- in_flight_uncommitted: none; focused Dart proof and qualified live-status correction committed; no required background job.\n' + source[end:]
source = source.replace('- qualifications: ', '- qualifications: First normal commit1 from17 recent live-status rows is preserved; separate bounded-view qualification restores16 with focused history0, without SDK replay. ', 1)
memory.write_text(source)
review = ROOT / names[6]
review.write_text(review.read_text() + '\nLanding qualification: The first normal commit1 has eight doctrine passes and\ntwo failures from a single17-row live-status overflow. landing-pressure/ retains\nits exact original combined log/mode, complete view, accepted oldest row and\n16-row correction. Original publisher/readers/seal/publication outputs remain\nunchanged. Focused document-history0 passes; no SDK test is replayed. The separate\nlanding-supplement/ retains this actual documentation update and original inputs.\nThe canonical Git publication card now carries the director1.5GB override and\nsparse-scope conclusion after a206-record/zero-binding query; no prior claim\nhash or revision changes. Final normal retry governs landing.\n')
for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    path = ROOT / name; source = path.read_text(); first = source.index('\n## '); next_record = source.index('\n## ', first + 1)
    source = source[:next_record] + '\nFirst normal landing1/eight PASS/two dependent doc failures is preserved; a\nseparate ADR0066 correction rotates only the oldest of17 recent rows to restore16.\nFocused document-history0 passes; runtime proof is not replayed. Canonical Git\npublication knowledge now carries the new1.5GB threshold/sparse-scope qualification.\n' + source[next_record:]; path.write_text(source)
handoff = ROOT / names[5]; source = handoff.read_text(); anchor = 'Publication-budget preparation23.4.30 precedes independent Julia/Lua.'
assert source.count(anchor) == 1
handoff.write_text(source.replace(anchor, anchor + ' Director publication steering monitors outgoing packed bytes after each leaf and pushes around1,500,000,000 bytes even mid-batch/PNT, with clean exact-HEAD canonical CI before every push.', 1))
freeze('after')
print('Qualified original doc-only landing failure; current16 and durable1.5GB policy, original proofs unchanged')
