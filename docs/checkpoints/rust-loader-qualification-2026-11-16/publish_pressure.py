"""Record the bounded-summary repair and immediate headroom owner."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
record = json.loads((BASE / 'pressure/record.json').read_bytes())
assert (BASE / 'pressure/routing-exit.txt').read_text() == '0\n'
assert (BASE / 'pressure/review-exit.txt').read_text() == '0\n'
result = json.loads(gzip.decompress((BASE / 'pressure/review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['headroom_bytes'] == 227
path = Path('docs/claims/' + record['owner'] + '.json')
claims = json.loads(path.read_bytes())
assert not any(claim['name'] == 'bounded-new-task-summary' for claim in claims['claims'])
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'pressure_repair.py') + ' --review'
claims['claims'].append(dict(name='bounded-new-task-summary',
    statement='The rejected12584665-byte task-evidence population becomes12582685 under unchanged12582912 limit, leaving227 bytes; headroom renewal35 precedes continuation.',
    scope='Current registered task Markdown/index population and this new uncommitted leaf summary only. Full before/after images retain the rejected text; unselected task bodies/frontier and Goal/Acceptance/tier/claim/Evidence fields remain exact. Focus/trigger summaries retain full detail in the evidence capsule. No cap, tool, runtime, historical SDK or physical space-reclamation claim.',
    rederive=dict(status='checked', command=command,
        granularity='Each registered member identity/size/mode, all four before/after task navigation images, every unselected node body and named retained fields; actual unchanged routing check exit0.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Task bytes could exceed the unchanged ceiling, or the compact summary could discard unselected bodies/contracts without detection.',
        oracle='Actual normal-hook routing rejection and separately derived registered-member census; full before/after node/field comparison and retained original images.',
        red_control='Original staged image reports12584665/12582912 and rejects. Same unchanged routing check passes the bounded image; preservation review requires every unselected body and named field byte-equal.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Rejected hook log, original and bounded task images/modes, full registered-member identities, repair/recorder bodies and actual command channels are retained. Complete routing producer/all changing reference inputs, outer-launcher first-use and native/toolchain/OS custody remain4.2/SESSION5; no complete native/physical closure.')))
path.write_text(json.dumps(claims, indent=2) + '\n')
paragraph = ('\n## Task-summary pressure repair\n\nThe first normal hook rejects task evidence at12,584,665 bytes against the unchanged12,582,912-byte ceiling. Its complete partial log and exact staged task images remain under `pressure/`. Only this new leaf summary is shortened; all original wording stays recoverable, all unselected bodies/frontier remain byte-equal, and Goal/Acceptance/tier/claim/Evidence fields stay exact. The complete retained result and conditions remain above and in claim/command artifacts.\n\nThe registered census and unchanged routing check now pass at12,582,685 bytes, leaving227 bytes. New pending `TYPE-REFERENCE-BOOK.1.2.23.4.35` owns immediate existing-epoch headroom renewal before further loader work. No cap/tool/schema is changed. The interrupted hook is not a completed normal receipt; the corrected candidate must rerun normal hooks.\n\nReadonly archived preservation: `bash tools/run_python_project_data.sh docs/checkpoints/rust-loader-qualification-2026-11-16/pressure_repair.py --review`; add `--current` only for the exact bounded candidate, not after later task work.\n')
path = BASE / 'REVIEW.md'
assert '## Task-summary pressure repair' not in path.read_text()
path.write_text(path.read_text() + paragraph)
note = ' The first normal hook rejects task bytes1753 over the unchanged ceiling. Exact candidate/diagnostic retention and a bounded new summary restore227-byte headroom; all unselected bodies and contracts persist. Immediate existing-epoch renewal35 precedes continuation.'
for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    path = Path(name)
    text = path.read_text()
    start = text.index('\n## ')
    end = text.index('\n## ', start + 1)
    path.write_text(text[:end].rstrip('\n') + note + '\n' + text[end:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
path.write_text(path.read_text().replace('PNT: ordinary Rust loaders complete; generated Rust/Perl-transitive/generated Dart qualification remains.',
    'PNT: ordinary Rust loaders complete; immediate task headroom35 precedes generated Rust/Perl-transitive/generated Dart qualification.'))
path = Path('MEMORY.md')
path.write_text(path.read_text().replace('- evidence: ', '- evidence: pressure/ archived task-summary proof (227-byte headroom; renewal35 next), plus ', 1))
path = Path('docs/knowledge/rust-direct-loader-roles.md')
text = path.read_text()
text = text.replace('reverify: "bash tools/run_python_project_data.sh docs/checkpoints/rust-loader-qualification-2026-11-16/review_qualified2.py"',
    'reverify:\n  - "bash tools/run_python_project_data.sh docs/checkpoints/rust-loader-qualification-2026-11-16/review_qualified2.py"\n  - "bash tools/run_python_project_data.sh docs/checkpoints/rust-loader-qualification-2026-11-16/pressure_repair.py --review"')
text += '\nThe same leaf preserves its rejected and bounded task-summary images. Unselected\ntask bodies and named contract fields remain exact; full wording and result\ndetail live in its evidence capsule. Headroom renewal35 is the next owned task\nunder the existing limits. The227-byte remainder is a dated preparation state.\n'
path.write_text(text)
print('Recorded bounded summary, unchanged-limit routing PASS and immediate headroom35.')
