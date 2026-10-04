"""Preserve the old disclosed observation and supersede its acceptance claim."""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('supersession.py')
BASE = 'e853cd5a7537c0ad8452ffac57af18ef48215df1'
PREP = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.0.json'
REGEX = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0.json'
accepted = json.loads(Path(PREFIX + 'verification.json').read_bytes())
assert accepted['suites'] == 13 and all(row['rejected'] for row in accepted['controls'])
report = {'activation': BASE, 'superseding_measurement': PREFIX.removesuffix('-').split('/')[-1], 'records': []}
for name, path in [('preparation', PREP), ('regex', REGEX)]:
    original = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    before = Path(PREFIX + 'before-' + name + '-claim.json').read_bytes()
    assert before == original, 'exact retained pre-supersession record'
    record = json.loads(original)
    assert json.loads((ROOT / path).read_bytes()) == record, 'unexpected record changes'
    if name == 'preparation':
        for claim in record['claims']:
            leg = claim['durability']
            assert leg['status'] == 'checked' and leg['mode'] == 'live'
            for entry in leg['inputs']:
                data = subprocess.check_output(['git', 'show', BASE + ':' + entry['path']], cwd=ROOT)
                assert hashlib.sha256(data).hexdigest() == entry['sha256'], entry['path']
            leg.update(mode='historical', revision=BASE)
        action = 'Freeze unchanged preparation inputs at their exact committed boundary.'
    else:
        assert len(record['claims']) == 2
        assert all(record['claims'][1][key]['status'] == 'gap' for key in ('falsify', 'durability'))
        assert record['claims'][0]['durability']['mode'] == 'historical'
        # The bounded private/compiler claim stays exact. The old broader claim
        # remains fully recoverable in the retained before record and Git history;
        # a new source-bound execution is the active acceptance authority.
        record['claims'] = record['claims'][:1]
        action = 'Preserve old broader disclosed observation; retire it from active acceptance in favor of the new complete fixed-input execution.'
    (ROOT / path).write_text(json.dumps(record, indent=2) + '\n')
    report['records'].append({'path': path, 'before_sha256': hashlib.sha256(before).hexdigest(),
                              'retained_before': Path(PREFIX + 'before-' + name + '-claim.json').relative_to(ROOT).as_posix(),
                              'action': action})
report['limit'] = 'No old live-document read bytes are invented or relabeled. All original streams, producers, claim statements and disclosed gaps survive in immutable Git and retained before records. This is selected proof supersession, not completion of startup .5 historical audit.'
Path(PREFIX + 'supersession.json').write_text(json.dumps(report, indent=2) + '\n')
print('PASS old observations preserved and active acceptance superseded by the verified fixed-input measurement')
