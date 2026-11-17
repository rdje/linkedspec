"""Record the received approximate-budget clarification without reopening permission."""
import json
from pathlib import Path
import re
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.37'
PUBLICATION = 'TYPE-REFERENCE-BOOK.1.2.23.4.30.2'
SOURCE = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.2.1'
PART = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
question = BASE / 'PUBLICATION_QUESTION.md'
with tarfile.open(BASE / 'director-before.tar.gz', 'x:gz') as archive:
    for path in (BASE / 'record_director.py', question, Path('MEMORY.md'), PART):
        archive.add(path, arcname=str(path), recursive=False)
reply = 'I meant around 1.5GB, that a little below or above is fine, so finish whatever you are doing then push, see what I mean?'
directive = 'Director2026-11-17 clarifies that1.5GB is approximate and a little below or above is fine. Finish current retention/reader slice37, then run full exact-candidate canonical CI and normal workflow and push the checkpoint. Source discovery/registration/native admission remain open; resume PNT after publication.'
text = question.read_text().replace('# Publication priority — director decision pending', '# Publication priority — director clarification')
text = text.replace('Raised through the live user-input request on2026-11-17; no answer or approval received.', 'Raised through the live user-input request on2026-11-17. The initial unanswered state is preserved in director-before.tar.gz; the director has now replied.')
text += '\n## Received clarification — 2026-11-17\n\n> ' + reply + '\n\n' + directive + '\n\nThe decision is received; no further permission is needed for this checkpoint. Full CI still precedes the push. Original discovery/registration and native prerequisites remain separate open admission work.\n'
question.write_text(text)
text = PART.read_text()


def alter(owner, change):
    global text
    start = text.index('- ID: `' + owner + '`\n'); end = text.find('\n- ID:', start + 1)
    assert end >= 0
    text = text[:start] + change(text[start:end]) + text[end:]


alter(OWNER, lambda node: node.replace('record the pending publication-priority handoff', 'record the director checkpoint handoff')
    .replace('Record the unresolved director1.5GB-versus-registration precedence question before further growth; no publication waiver or runtime admission.', 'Record the director approximate-budget/finish-slice/full-CI/checkpoint-push clarification; no registration/native admission.')
    .replace('Publication-priority question is durable; historical plan-reader qualification must pass before landing.', 'Director clarification is durable; old plan-reader RED/new historical GREEN/current RED pass before landing. Checkpoint canonical CI/push is next.'))
alter(PUBLICATION, lambda node: node.replace('Status: `blocked`', 'Status: `pending`', 1).replace(
    '  Priority blocker: Early-push margin and unfinished discovery/registration prerequisites now require a director choice; see docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md. Full CI stays mandatory. A checkpoint exception cannot close the original admission prerequisites.\n',
    '  Director clarification: ' + directive + ' Exact reply and initial question: docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md. This checkpoint may publish before original discovery/registration closeout; those owners are not completed by the push.\n'))
alter(SOURCE, lambda node: node.replace(
    '  Blocker: Director priority is required before more source-evidence growth near the early-push trigger; see docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md. Unblock by authorizing the checkpoint exception or prerequisite-first growth. No implementation started.\n',
    '  Blocker: Director prioritizes the clean checkpoint after slice37/full CI. Resume this source leaf after publication, first checking task-text capacity. No implementation started.\n'))
alter('TYPE-REFERENCE-BOOK.1.2.23.4.30', lambda node: node + '  Director clarification2026-11-17: Approximate1.5GB permits a little below or above; finish current37, full canonical CI/normal workflow, then checkpoint push before further PNT source work. Original discovery/registration admission stays open. Exact authority is retained with37.\n')
PART.write_text(text)
summary = 'Dated1322 rows/eight scopes/six controls and stage-source RED pass; all artifacts retained, zero removals. Historical plan recovery is corrected with actual old RED/new historical GREEN/current RED. Director clarifies approximate1.5GB: finish current37, full CI, then checkpoint push; original discovery/registration/native admission stays open.'
action = 'Activate ' + PUBLICATION + ' for the director-authorized checkpoint: full exact-candidate canonical CI, normal commit and clean push; then resume source1 after checking task-text capacity.'
path = Path('MEMORY.md'); text = path.read_text()
text = re.sub(r'(?m)^- run_state:.*$', '- run_state: PNT; director prioritizes checkpoint publication next, then source work resumes.', text)
text = re.sub(r'(?m)^- next_action:.*$', '- next_action: ' + action, text)
text = re.sub(r'(?m)^- blockers:.*$', '- blockers: none requiring user input; director reply is received in docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md. Source1 awaits prioritized checkpoint, not permission.', text)
path.write_text(text)
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md'); text = path.read_text()
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(PUBLICATION) + r'`.*$', '| 1 | `' + PUBLICATION + '` | `pending` | Director: finish37, full canonical CI/normal workflow, then checkpoint push around the approximate1.5GB target. Source admission remains open. |', text)
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$', 'November17 current PNT frontier: Director clarifies approximate1.5GB; finish current retention/reader37, full canonical CI/normal workflow, then checkpoint push. Dated metadata1322/eight scopes/six controls/zero removals and historical reader repair are focused-checked. Discovery/registration/native admission remains open; resume PNT after publication.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Director-authorized checkpoint publication follows current37/full canonical CI and normal workflow around approximate1.5GB; then source PNT resumes. Original source/registration/native admission stays open.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — retention1322/eight scopes/six controls/source RED/zero removals; historical reader qualified and director checkpoint clarification recorded.', text, count=1)
text = re.sub(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$', lambda match: match[1] + 'PNT: finish37, full canonical CI/normal workflow and checkpoint push under director approximate-budget clarification; discovery/registration/native admission remains open.' + match[2], text)
path.write_text(text)
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: director-authorized checkpoint canonical CI/push follows completed retention and historical reader repair.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
text = text.replace('publication-priority question recorded.', 'director approximate-budget checkpoint clarification recorded.')
path.write_text(text)
for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md', 'docs/ARTIFACT_CLEANUP.md'):
    path = Path(name); text = path.read_text()
    text = text.replace('Publication-priority decision remains pending; source growth is held.', 'Director clarifies approximate1.5GB: finish current37, full CI and normal workflow, then checkpoint push; discovery/registration/native admission remains open.')
    text = text.replace('The source frontier and original publication leaf are explicitly blocked on the director priority choice, without waiving canonical CI or registration.', 'The director reply prioritizes checkpoint publication after current37/full CI, allowing a little below or above1.5GB. Source1 resumes after the checkpoint; original discovery/registration/native admission stays open.')
    path.write_text(text)
path = BASE / 'REVIEW.md'; text = path.read_text()
text = text.replace('The explicit director question in `PUBLICATION_QUESTION.md` is unanswered.\nThe source frontier and original publication leaf are blocked before more\ngrowth. No requirement, full-CI boundary or registration prerequisite is waived;\nno push is attempted. A checkpoint exception cannot close original admission\nowners.', 'The explicit director reply in `PUBLICATION_QUESTION.md` clarifies that1.5GB\nis approximate and a little below or above is fine: finish current37, then full\ncanonical CI/normal workflow and checkpoint push. No further permission is\npending. Source1 resumes after publication; original discovery/registration/\nnative admission owners remain open. No push is attempted by this maintenance\nslice, and a checkpoint cannot close those separate admission owners.')
path.write_text(text)
path = Path('docs/knowledge/artifact-review-november17-index-reuse.md'); text = path.read_text().replace('The pending publication-priority question is retained separately in', 'The director approximate-budget/checkpoint clarification is retained separately in'); path.write_text(text)
claim_path = Path('docs/claims/' + OWNER + '.json'); record = json.loads(claim_path.read_bytes())
record['claims'][0]['statement'] = summary
claim_path.write_text(json.dumps(record, indent=2) + '\n')
(BASE / 'director-reply.json').write_text(json.dumps(dict(date='2026-11-17', exact_reply=reply, adopted_action=directive,
    permission_pending=False, full_CI_before_push=True, discovery_registration_native_admission='remains open'), indent=2) + '\n')
print(directive)
