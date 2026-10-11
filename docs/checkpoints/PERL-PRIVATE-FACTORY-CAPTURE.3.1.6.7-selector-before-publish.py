"""Guarded portable-diagnostic publication; readonly default, --capture once."""
import copy
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DIR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7/'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7.json'
spec = importlib.util.spec_from_file_location('capacity', ROOT / (PREFIX + 'capacity.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
assert sys.argv[1:] in ([], ['--capture'])
original = m.read(DIR + 'original-claim.json')
for path in (DIR + 'review.py', DIR + 'evidence.py'):
    result = m.command(['python3', path])
    assert result['exit_code'] == 0 and not result['stderr']['bytes'], result
proof = m.command(['python3', PREFIX + 'review.py'])
assert proof['exit_code'] == 0 and not proof['stderr']['bytes'], proof
assert proof == m.load('final.json'), 'complete current proof matches original retained result without refresh'
target = ROOT / CLAIM
report = ROOT / (DIR + 'current-proof.json')
if sys.argv[1:]:
    assert target.read_bytes() == original and not report.exists(), 'one-shot guarded publication'
    report.write_text(json.dumps(proof, indent=2) + '\n')
else:
    assert json.loads(report.read_bytes()) == proof
data = json.loads(original)
primary = data['claims'][0]
old = copy.deepcopy(primary)
paths = {entry['path'] for entry in old['durability']['inputs']}
assert len(paths) == 369
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / DIR).iterdir() if p.is_file())
inputs = [{'path': p, 'sha256': m.sha(m.read(p)),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl') else 'input'} for p in sorted(paths)]
primary['name'] = 'finite-change-history-with-portable-evidence'
primary['statement'] += (' Original369-input/94175-byte publication and every original input/claim field remain '
    'recoverable exactly:366 current inputs plus three exact decoded relocations. The diagnostic changes only '
    'representation, its reader changes only decoding, and the Knowledge pointer names this guarded publisher. '
    'Complete current proof reruns successfully; two additional actual encoding/preservation REDs restore exactly.')
primary['scope'] += (' The first canonical attempt observed REPO-ROOT-PATHS rejection of a literal checkout prefix '
    'in the transcribed raw diagnostic. Its verified wrapper received TERM after the candidate was invalid and '
    'exited143; claim verification was still running, so no complete doctrine/runtime/canonical result is inferred. '
    'Full available log is encoded and retained. Original369 publication is byte-bound preserved, without a fresh '
    'execution of that original uncommitted publisher. Every original SHA/field remains exact in original-claim.json; '
    'three original payloads are recoverable from original-inputs.json, and366 other bytes remain unchanged. '
    'Current complete review executes separately and compares with the original retained result, never overwriting '
    'it. No archive/root/manifest/registry/decision/runtime or original measured outcome changes. Fresh staged '
    'canonical CI/receipt and normal hooks govern landing; failed managed runs are never recovered or purged.')
primary['rederive']['command'] = ('bash tools/run_python_project_data.sh ' + DIR + 'publish.py; separately '
    + DIR + 'review.py, retention.py and evidence.py through that wrapper; the original core ' + PREFIX
    + 'review.py remains current. Defaults readonly; --capture writers and all original applied/freezer/repair '
    'writers are one-shot. Old publish-claim.py requires its retained original369-input logical boundary.')
primary['rederive']['granularity'] += (' Full original94175-byte record and all369 logical input hashes, three '
    'exact bounded current changes, complete available failed canonical log, actual current complete proof result '
    'and two new reason-sensitive damaged/restored populations including an original payload beyond updated metadata.')
primary['rederive']['result'] = primary['statement']
primary['falsify']['hypothesis'] += ' An encoded raw diagnostic or updated immediate retention SHA might conceal changed original evidence.'
primary['falsify']['oracle'] += ' Frozen original full publication identity and all369 decoded/current original bindings; exact representation/reader/pointer reconstruction.'
primary['falsify']['red_control'] += (' Two further actual controls reject altered encoded diagnostic with coherent '
    'updated channel metadata and changed retained original card bytes beyond updated payload/retention SHA; exact '
    'restoration passes. No fresh original-publication execution is claimed.')
primary['durability']['inputs'] = inputs
raw = (json.dumps(data, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded claim', len(raw))
if sys.argv[1:]:
    target.write_bytes(raw)
else:
    assert target.read_bytes() == raw, 'guarded publication/inputs drift'
print('Guarded finite change-history publication PASS:', len(inputs), 'live inputs;', len(raw),
      'bytes; original369 exact/two portable-evidence REDs restored')
