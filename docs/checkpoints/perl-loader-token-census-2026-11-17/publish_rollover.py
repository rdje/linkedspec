"""Attach the actual required data rollover to this uncommitted leaf record."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PLAN = json.loads((BASE / 'plan.json').read_bytes())
OWNER = PLAN['owner']
FOLDER = BASE / 'history-rollover'
assert not (FOLDER / 'publication.json').exists(), 'one-shot rollover publication'
result = json.loads(gzip.decompress((FOLDER / 'review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and len(result['controls']) == 6
assert result['before_bytes'] == 59278 and result['after_bytes'] == 32254 and result['archived_bytes'] == 27023
assert result['combined_bytes'] == 4978078 and result['old_files_unchanged'] == 95
assert result['omitted_hot_separator_hex'] == '0a'
path = Path('docs/claims/' + OWNER + '.json')
record = json.loads(path.read_bytes())
assert not any(claim['name'] == 'required-changes-data-rollover' for claim in record['claims'])
record['claims'].append(dict(name='required-changes-data-rollover',
    statement='Existing public rollover archives27023 bytes and normalizes one hot LF separator, reducing CHANGES59278 to32254 bytes. Exact4978078-byte combined reconstruction and95 unchanged old-store identities pass six corruption controls.',
    scope='Only this required change_history data rollover at activation83f3ccc5. Archive --all excludes the hot root; reconstruction explicitly reinstates the one source LF under the existing EOF contract. Existing tools/schema/caps and original measured runtime claims remain unchanged.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'review_hot_history.py'),
        granularity='Exact before/after hot roots, original archive-only streams, new immutable source suffix, permitted separator and all95 before/after existing store byte/mode identities.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='The required threshold or rollover could permit changed source/archive/separator bytes or altered old-store membership/modes/content.',
        oracle='Actual unchanged public pressure checker and separate byte reconstruction using retained before/after source and archive streams; exact old-store identity comparison.',
        red_control='Before-apply public check rejects59278-byte hot source; after check passes32254. Changed hot/archive bytes, extra separator LF, missing old entry and changed old mode/digest each reject; healthy complete reconstruction agrees.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Actual public reader/writer/module/project-launcher and checkpoint producer bodies, before/after source/manifest/new files, complete archive streams, old-store identities and actual command channels survive. A preliminary unused reader remains in the before-image; actual first-used reader has a separate before-use self-image. Complete Perl/Git/native/OS/outer-first-use/per-read/physical custody remains4.2/SESSION5. No original claim/hash/result is rewritten.')))
path.write_text(json.dumps(record, indent=2) + '\n')
path = Path('DEVELOPMENT_NOTES.md')
text = path.read_text()
start = text.index('\n## 2026-11-17 — keep lexical source sites separate from runtime calls\n')
end = text.index('\n## ', start + 2)
note = ('\nThe mandatory changes pressure check also requires its existing90-percent rollover. The same public data writer archives27023 bytes, retains32254 hot bytes and all95 older store identities; exact4978078-byte reconstruction restores only the recorded source LF separator. Six independent byte/store controls pass. No history tool, schema or cap changes. Full native custody remains4.2.\n')
path.write_text(text[:end] + note + text[end:])
path = BASE / 'REVIEW.md'
text = path.read_text()
text += '''
## Required history rollover during landing

The mandatory pressure check stopped at385 lines/59278 bytes before the book
build. Existing policy requires action at90 percent, below the hard65536-byte
ceiling. The source lexer and its observations remain unchanged. A separate
same-leaf producer retains before/after public tools, hot source, manifest,
catalog/new segment files and actual commands before applying the existing data
rollover. The fresh before-check is observed RED and final check passes.

The public archive-only streams exclude the hot root. The new archived suffix is
27023 bytes; the hot root becomes32254 bytes. Exact complete reconstruction is
4978078 bytes, SHA256 eb0a725998e22e671af32dbd74ed0ebfd920938a2297685737328d3155ff85d4,
after reinstating only the one source LF permitted by the existing EOF contract.
All95 older store files retain their bytes/modes. Only the new segment/catalog
pages and mutable manifest/hot root change. Six source/archive/separator/store
corruptions reject; no cap/schema/tool or old measurement changes.

The writer's before-image includes an unused preliminary reader. Before its first
execution, the extra-LF control label and self-image guard were finalized and the
actual first-used body captured separately. Both source versions survive; no used
producer was reset. Full native/outer-first-use/per-read/physical custody remains4.2.
Readonly recovery: `bash tools/run_python_project_data.sh docs/checkpoints/perl-loader-token-census-2026-11-17/review_hot_history.py`.
'''
path.write_text(text)
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end] + '  Required history rollover: Existing data tool0 archives27023 bytes; hot59278 to32254, old95 identities unchanged. Full4978078-byte reconstruction with existing source LF0a and six corruption controls0. Archive-only reader contract/old tool/schema/caps/old claims preserved. Book and normal checks resume.\n'
path.write_text(text[:start] + node + text[end:])
(FOLDER / 'publication.json').write_text(json.dumps(dict(result='PASS', claim_record='docs/claims/' + OWNER + '.json',
    statement='New uncommitted leaf receives the actual rollover proof; all original claim entries remain value-identical and no CHANGES record is rewritten after rollover.'), indent=2) + '\n')
print('Published existing data rollover: hot59278→32254; archived27023; reconstructed4978078/old95/six controls; no cap/tool change.')
