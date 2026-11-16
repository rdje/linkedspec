"""Record the own-commentary repair without refreshing the original role claim."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.0'
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1'
path = Path('docs/claims/' + OWNER + '.json')
record = json.loads(path.read_bytes())
assert len(record['claims']) == 1, 'one-shot pressure publication'
result = json.loads((BASE / 'pressure-review-stdout.json').read_bytes())
assert result['result'] == 'PASS' and len(result['controls']) == 4
assert (BASE / 'pressure-review-stderr.txt').read_bytes() == b''
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_pressure.py')]
(BASE / 'pressure-review-command.json').write_text(json.dumps(dict(argv=command, cwd='.',
    recording='after actual command; no retroactive before-use/native custody credit'), indent=2) + '\n')
record['claims'].append(dict(name='own-task-commentary-routing',
    statement='The condensed task part adds589 bytes to its activation while preserving the complete original parent contract and all other original bytes. Four coherent body/contract/node/mode controls reject; the original pressure refusal and rejected own text remain retained.',
    scope='Only this slice\'s unlanded task commentary and new child records. No older task contract, limit, checker or previous claim/result/hash changes; no complete normal-hook PASS or canonical credit.',
    rederive=dict(status='checked', command=' '.join(command),
        granularity='Complete activation Git source, rejected/current task bodies and original mode; parent state/child suffixes versus otherwise exact bytes; actual normal pressure refusal.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Coherently rehashed older-prefix, parent-contract or new-node mutations, or changed mode, could pass as preservation.',
        oracle='Immutable actual3f619e9c2 activation Git source and complete separately retained rejected/current task bodies; the actual hook refusal distinguishes the pressure boundary.',
        red_control='Four named controls reject in actual pressure-review-stdout.json. Healthy reconstruction passes; the first normal hook pressure refusal is retained without complete-pass credit.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Full rejected/activation/current task bodies, original mode/digests, partial failed normal log, actual compact/review producers and review channels are tracked. Native Git/Python/OS, complete origin/outer-launcher first-use and physical closure remain4.2/SESSION5. The pressure command record is explicitly after-use, not retroactive custody.')))
path.write_text(json.dumps(record, indent=2) + '\n')
for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    path = Path(name)
    text = path.read_text()
    start = text.index('\n## ')
    end = text.index('\n## ', start + 1)
    text = text[:end] + ('\nLanding: the first normal hook exposed task-evidence pressure. Only new own commentary routes to the checkpoint; original parent/other bytes remain exact with four readonly controls. Full rejected text/log/mode survive; partial hooks and interrupted standalone prechecks have no PASS credit. Renew task headroom after clean landing; normal hooks are the single mandatory global boundary.\n') + text[end:]
    path.write_text(text)
next_action = 'Remeasure outgoing size, renew task-evidence headroom, then finish remaining qualification under ' + NEXT + ' before freezing registration4.1.2 input.'
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text, count = re.subn(r'(## Next Action\n\n).*?(?=\n## )', lambda match: match[1] + next_action + '\n', path.read_text(), count=1, flags=re.S)
assert count == 1
path.write_text(text)
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text = path.read_text()
old = 'Complete native roles/direct loaders/discovery after bounded Perl roles; freeze registration4.1.2 input. All separate before-push owners remain.'
assert text.count(old) == 1
path.write_text(text.replace(old, 'Renew task headroom, then finish native roles/loaders and registration4.1.2 inventory; separate push owners remain.', 1))
path = Path('docs/knowledge/perl-consumer-roles-and-selection.md')
text = path.read_text()
text += ('\nThe first normal hook also found task-evidence pressure. Full rejected own text, mode and partial hook survive; only this new slice\'s commentary routes to its checkpoint. Immutable-Git recovery protects the original parent and all other older bytes with four effective controls. Renew task headroom before further activation. The normal hook is the mandatory global integrity boundary; interrupted redundant standalone prechecks supply no PASS credit.\n')
path.write_text(text)
print('Original role claim retained; own-commentary pressure repair and next action published.')
