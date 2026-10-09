"""Activate the recovered foundation; restore only its two verified owners."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1'
BASE = 'a367b66f06b1deacefc172484834b7cd9b1093d1'
PREFIX = 'docs/checkpoints/' + OWNER
ORIGINS = 'perl/LinkedSpec/ActionIR/SourceOrigins.pm'
EMISSIONS = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


assert git('rev-parse', 'HEAD').decode().strip() == BASE
if sys.argv[1:] == ['--activate']:
    changed = {ORIGINS, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
               'LIVE_ACHIEVEMENT_STATUS.md', 'docs/TASK_TREE.md', 'ROADMAP.md',
               'ROADMAP_V2.md', 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'}
    frozen = []
    for path in git('ls-files', 'docs/claims').decode().splitlines():
        raw = git('show', BASE + ':' + path)
        record = json.loads(raw)
        original = copy.deepcopy(record)
        for claim in record['claims']:
            leg = claim['durability']
            if leg.get('mode') != 'live' or not any(x['path'] in changed for x in leg['inputs']):
                continue
            for entry in leg['inputs']:
                assert sha(git('show', BASE + ':' + entry['path'])) == entry['sha256'], entry['path']
            leg.update(mode='historical', revision=BASE)
        if record != original:
            assert (ROOT / path).read_bytes() == raw
            (ROOT / path).write_text(json.dumps(record, indent=2) + '\n')
            frozen.append({'path': path, 'original_sha256': sha(raw),
                           'preserved_sha256': sha((ROOT / path).read_bytes())})
    (ROOT / (PREFIX + '-freeze.json')).write_text(json.dumps({
        'revision': BASE, 'records': frozen,
        'scope': 'Every original input verified; durability mode/revision only.'}, indent=2) + '\n')
    tree = ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
    text = tree.read_text()
    start = text.index('- ID: `' + OWNER + '`')
    end = text.index('\n- ID:', start + 1)
    node = text[start:end].replace('Status: `pending`', 'Status: `active`', 1)
    node = node.replace('Planned tier:', 'Verification tier:')
    node = node.replace('Planned focused proof:', 'Focused checks:')
    node = node.replace('Planned canonical boundary:', 'Canonical trigger:')
    node = node.replace('Planned claim record: none: No implementation measurement exists; declare the actual foundation proof record on activation.',
                        'Claim verification: `docs/claims/' + OWNER + '.json`')
    node += ('\n  Activation: Clean a367b66; only SourceEmissions.pm and the private SourceOrigins invocation accessor are production owners. '
             'No pipeline, public callback, family-order, dependency, gate or generated-format change. '
             'Independent labelled-character construction/consumption and identity controls precede integration; '
             'seven unchanged provenance/occurrence consumers and normal focused checks govern landing. '
             'Full guarded Phase0 remains .2.5. Supplied policy hashes match the canonical startup record.\n')
    text = text[:start] + node + text[end:]
    text = text.replace('| `' + OWNER + '` | `pending` |', '| `' + OWNER + '` | `active` |')
    tree.write_text(text)
    (ROOT / 'MEMORY.md').write_text(
        '# MEMORY\n\n- activation_commit: `' + BASE + '` — clean foundation activation.\n'
        '- latest_completed_leaf: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0` (done).\n'
        '- active_work_unit: `' + OWNER + '` (active).\n'
        '- next_action: Complete independent foundation RED/GREEN and source inverses, then commit before input integration.\n'
        '- in_flight_uncommitted: foundation activation/proof; see owning task.\n'
        '- blockers: none; no foundation or replacement acceptance yet. Artifact review is due at the next clean boundary.\n'
        '- task_owner: `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`.\n')
    print('Activated foundation; preserved', len(frozen), 'intersecting claim records.')
elif sys.argv[1:] == ['--restore']:
    snapshot = json.loads((ROOT / (PREFIX.replace('.0.1', '.0.0') + '-crash.json')).read_text())
    entry = next(x for x in snapshot['entries'] if x['path'] == EMISSIONS)
    raw = base64.b64decode(entry['content_base64'], validate=True)
    assert len(raw) == entry['bytes'] and sha(raw) == entry['sha256']
    assert not (ROOT / EMISSIONS).exists()
    origin_entry = next(x for x in snapshot['entries'] if x['path'] == ORIGINS)
    original = (ROOT / ORIGINS).read_bytes()
    assert sha(original) == origin_entry['base_sha256']
    needle = b'our $_invocation;\n'
    accessor = (b'\n# Identity only: private producers bind to this actual dynamic invocation, not\n'
                b'# to another invocation with equal source text. No event or callback field changes.\n'
                b'sub _invocation_token {\n return ref($_invocation) eq \'HASH\' ? $_invocation : undef\n}\n')
    restored = original.replace(needle, needle + accessor, 1)
    assert sha(restored) == origin_entry['sha256']
    (ROOT / EMISSIONS).write_bytes(raw)
    (ROOT / ORIGINS).write_bytes(restored)
    print('Restored exact emission draft and exact accessor only.')
else:
    raise SystemExit('usage: prepare.py --activate|--restore')
