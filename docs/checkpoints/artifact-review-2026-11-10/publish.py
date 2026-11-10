"""Publish the dated retained-metadata record without borrowing a claim template."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.19'
report = json.loads(gzip.decompress((HERE / 'observation.json.gz').read_bytes()))
result = json.loads((HERE / 'channel-review-result.json').read_bytes())
assert report['owner'] == OWNER and result['result'] == 'PASS'
assert result['removed'] == 0 and result['scoped_rows'] == 1181
assert result['preservation']['checked_claims'] == 8
names = set(report['producers'])
local = ('observation.json.gz', 'capture-result.json', 'result.json',
         'channel-review-result.json', 'channel_review.py', 'prepare_review.py',
         'preserve_prior_claim.py', 'preservation-result.json',
         'preservation-review-result.json', 'prior-18.1-claim.json.gz',
         'preserved-18.1-claim.json.gz', 'publish.py')
names.update((HERE / name).relative_to(ROOT).as_posix() for name in local)
for mode in ('capture', 'review'):
    names.update((HERE / (mode + suffix)).relative_to(ROOT).as_posix()
                 for suffix in ('-command.json', '-exit.txt', '-stdout.log.gz', '-stderr.log.gz'))
# These are the actual source templates used by prepare_review.py, not a hidden
# previous-claim dependency. No prior claim supplied this declaration's fields.
names.update('docs/checkpoints/artifact-review-2026-11-07/' + name for name in ('review.py', 'run.py'))
inputs = []
for name in sorted(names):
    path = ROOT / name
    assert not path.is_symlink() and path.is_file()
    role = 'producer' if name.endswith(('.py', '.sh')) and name != 'tools/run_lua_project_data.sh' else 'input'
    inputs.append(dict(path=name, sha256=hashlib.sha256(path.read_bytes()).hexdigest(), role=role))
source = dict(name='dated-artifact-metadata-source-and-channel-consistency',
    statement='The retained primary and independent metadata populations agree on1181 named-scope rows. Five altered-evidence and four command-channel controls reject. Eight previously checked checkpoint claims retain every original statement/result/input binding at their actual accepted physical Git capture.',
    scope='Dated ' + result['date'] + ' artifact records in eight explicit scopes: root-level strays, six root/crate Rust release/incremental/deps paths and retained log directory. Only log/bin/DS_Store suffixes; configured rust/target is covered. Project observation producer bodies are captured before census helper import and checked unchanged afterward. The separate readonly replay verifies retained populations and actual argv/cwd/exit/full channels; no fresh filesystem state is inferred. The preservation reader checks214 original input rows at accepted41ba410b, changing only selected mode/revision/capture scope. Existing native gaps stay unchanged. Source composition uses two explicit accepted script templates; this declaration is authored directly, without a previous-claim template. No content ownership, liveness, disposability, reclamation, concurrent-adversarial, runtime/storage-default/hook/CI change or complete native/OS input closure.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/artifact-review-2026-11-10/channel_review.py',
        granularity='Each retained per-file path/suffix/byte row in all eight named scopes; every actual command target/exit/full stdout/stderr; every214 accepted input row and eight scoped claim qualifications.',
        result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='A missing/altered metadata row, substituted source/channel or fabricated historical capture can appear to support the dated review.',
        oracle='Independent scandir/lstat versus the accepted non-following os.walk scanner; retained complete source bodies and raw command channels; original accepted Git record and exact regular input blobs.',
        red_control='Missing-row, wrong-size, duplicate-row, outside-path and producer-byte mutations reject. Wrong-command, wrong-exit, missing-stdout and unexpected-stderr mutations reject. Healthy capture and separate readonly review return0 with empty stderr. Exact accepted Git comparison preserves all11 original claim objects except the permitted eight capture qualifications, with all three original native gaps unchanged.'),
    durability=dict(status='checked', mode='live', inputs=inputs))
native = copy.deepcopy(source)
native.update(name='dated-artifact-host-observation-with-native-custody-gap',
    statement='The dated host census and independent walk observe1181 matching rows in eight named scopes; no artifacts are removed.',
    scope='Actual bounded capture and separate readonly replay. Filesystem metadata is time-dependent; retained arrays are the dated observation, not a later live census or disposal authority. Caches, proof, active outputs, Dart/Julia convention directories and other Git repositories remain protected.')
native['rederive']['granularity'] = 'Retained dated primary/independent host metadata and actual capture/replay channels; no recreation of the original OS/filesystem epoch.'
native['durability'] = dict(status='gap', reason='Project census producers and complete retained metadata/channels are available. The original shared interpreter, OS/kernel/filesystem, native libraries and transitive first-use epoch are not fully acquired; source retention does not close that native leg.', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2')
record = dict(version=1, owner=OWNER, claims=[source, native])
destination = ROOT / 'docs/claims' / (OWNER + '.json')
assert not destination.exists()
destination.write_text(json.dumps(record, indent=2) + '\n')
assert destination.stat().st_size <= 131072
(ROOT / 'docs/ARTIFACT_CLEANUP.md').write_text('''# Latest artifact cleanup

- Date: ''' + result['date'] + '''
- Summary: ''' + OWNER + ''' reviewed1181 matching per-file metadata rows in eight named root/Rust/log scopes; configured Cargo target covered, five metadata/four channel controls and separate readonly replay pass. Nothing was removed; caches, proof and other repositories remain protected. Actual snapshot/channels: docs/checkpoints/artifact-review-2026-11-10/; readonly channel_review.py verifies them. Complete native/OS custody remains separately owned by23.4.2.
''')
(HERE / 'README.md').write_text('''# November10 bounded artifact review

Owner: ''' + OWNER + '''. Clean activation:41ba410bbb03fe8e7e4dc1412331d069e258d70b.
Dated observation: ''' + result['date'] + '''.

The accepted scanner and independent scandir/lstat agree on1181 path/suffix/byte
rows in eight named root/Rust/log scopes. Every candidate is retained. Metadata
grants no content ownership, liveness or disposal authority. Caches, proof,
managed runs and other repositories stay protected; no submodule implementation
is traversed. This is not a whole-project census or a complete native/OS epoch.

Project observation producers are captured before helper import and checked
unchanged afterward. Five metadata and four channel corruptions reject. Actual
argv/cwd/exit and full raw gzip channels are retained; separate readonly replay
matches the capture. Source composition templates are explicit inputs; publish.py
authors the claim directly without the earlier hidden prior-claim template issue.

Before shared book edits, preserve_prior_claim.py --preserve checked214 input
rows for all eight checked18.1 claims at their actual accepted Git capture.
Only mode/revision/capture qualification changes; original logical epochs,
observations, hashes and three native gaps remain. Both old and qualified records
are recoverable here. The --preserve, --capture, acquisition and publisher modes
are completed one-shot writers, not replay commands.

Readonly: bash tools/run_python_project_data.sh
docs/checkpoints/artifact-review-2026-11-10/channel_review.py (one command line).
It composes the unchanged metadata and accepted-capture checks. The native
observation's complete input-custody leg remains owned by23.4.2.
''')
print(json.dumps(dict(result='published', owner=OWNER, claims=2, removed=0, rows=1181), sort_keys=True))
