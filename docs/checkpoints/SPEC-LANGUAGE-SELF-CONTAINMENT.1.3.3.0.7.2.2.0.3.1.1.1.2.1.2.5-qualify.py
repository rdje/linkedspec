"""Separate three historical supplemental observations from checked bounded claims."""
import copy
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
HISTORICAL_OWNER = 'SESSION-STARTUP-READING.5'
audit = json.loads((ROOT / (PREFIX + 'audit.json')).read_text())
CHANGES = {
 '2.1.1': ('Ten guarded live consumer suites, three actual public Toolbox lowering routes and eight reason-sensitive evidence RED controls pass; only Parser changes production.', 'Three actual public Toolbox lowering routes and eight reason-sensitive evidence RED controls pass; only Parser changes production.'),
 '2.1.2.0': ('Eleven guarded live suites (including constructor77), three actual Toolbox routes and eight reason-sensitive evidence RED controls pass.', 'Three actual Toolbox routes and eight reason-sensitive evidence RED controls pass.'),
 '2.1.2.4': ('Four effective semantic source inverses, twelve guarded direct suites, three unchanged actual Toolbox lowering routes and eight reason-sensitive evidence controls pass.', 'Four effective semantic source inverses, three unchanged actual Toolbox lowering routes and eight reason-sensitive evidence controls pass.'),
}
rows = []
for row in audit['rows']:
    original = json.loads((ROOT / row['before']).read_text())
    record = copy.deepcopy(original)
    if not row['missing_selected_json']:
        assert not row['recorded_epoch_mismatches']
        assert (ROOT / row['claim_path']).read_bytes() == (ROOT / row['before']).read_bytes()
        rows.append({'path': row['claim_path'], 'disposition': 'unchanged; both artifacts already recorded, all2306 epoch hashes match'})
        continue
    suffix = next(k for k in CHANGES if row['owner'].endswith('.' + k))
    old, new = CHANGES[suffix]
    claim = record['claims'][0]
    for field in ('statement',):
        assert claim[field].count(old) == 1
        claim[field] = claim[field].replace(old, new)
    assert claim['rederive']['result'].count(old) == 1
    claim['rederive']['result'] = claim['rederive']['result'].replace(old, new)
    claim['scope'] += (' Checked durability and semantic acceptance here are limited to the bounded standalone fixture/source-inverse and explicitly retained Toolbox/diagnostic measurements. Historical supplemental selected-consumer result counts from the original record are separated into historical-supplemental-consumer-observation below because two actual checkpoint JSON inputs were omitted. Original hashes/channels remain preserved; current epoch hashes do not retroactively identify original per-read bytes. Current replacement owner ' + OWNER + '; remaining original historical legs: ' + HISTORICAL_OWNER + '.')
    record['claims'].append({
        'name': 'historical-supplemental-consumer-observation',
        'statement': 'At historical epoch ' + row['epoch'] + ', the retained command reports PASS for ' + str(len(row['tests'])) + ' selected suites. Its recorded manifest contains ' + str(row['recorded_inputs']) + ' inputs but omits both actual membership checkpoint JSON reads. This is an actual passing observation with incomplete historical artifact binding, separate from the bounded standalone fixture proof.',
        'scope': 'The original command/channels and exact before claim are retained under ' + row['before'] + '. No complete source-bound supplemental consumer acceptance is claimed at that historical boundary. Current immutable133-file/fourteen-suite recurrence under ' + OWNER + ' supersedes acceptance without relabeling the original run; the broader historical audit remains SESSION-STARTUP-READING.5.',
        'rederive': {'status': 'checked', 'command': 'At ' + row['epoch'] + ', the original captured command in ' + row['capture_path'],
                     'granularity': 'Actual selected-suite command/exit/full channels and recorded manifest membership, not unrecorded per-read JSON bytes.',
                     'result': 'Original command exit0 and Result: PASS retained; two required checkpoint JSON paths are absent from its original input manifest.'},
        'falsify': {'status': 'gap', 'reason': 'Original per-read JSON bytes were not separately guarded, so the hypothesis that a different unrecorded artifact influenced that original result cannot be retroactively falsified. Current actual missing-artifact/source controls and complete supplied recurrence supersede active acceptance.', 'repair_owner': HISTORICAL_OWNER},
        'durability': {'status': 'gap', 'reason': 'Two actual checkpoint JSON inputs are absent from the historical consumer manifest. Original recorded hashes and channels remain unchanged in the before claim/capture; adding current or epoch hashes cannot reconstruct those per-read bytes. The complete supplied recurrence repairs current acceptance.', 'repair_owner': HISTORICAL_OWNER},
    })
    assert claim['durability'] == original['claims'][0]['durability'], 'original bounded input bindings retained'
    path = ROOT / row['claim_path']
    assert json.loads(path.read_text()) in (original, record)
    path.write_text(json.dumps(record, indent=2) + '\n')
    rows.append({'path': row['claim_path'], 'disposition': 'bounded statement scoped; historical observation explicitly gapped',
                 'old_statement': old, 'new_statement': new,
                 'after_sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
report = {'rows': rows, 'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
          'scope': 'Three supplemental observations qualified; all original bounded input hashes and claims retained. Foundation is unchanged.'}
(ROOT / (PREFIX + 'qualification.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Three historical supplemental observations explicitly qualified; foundation unchanged; original bounded bindings retained.')
