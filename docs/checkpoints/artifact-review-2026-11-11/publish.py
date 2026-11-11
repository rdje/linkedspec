"""Author this finite maintenance declaration directly from retained actual results."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
BASE = HERE.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.26'
assert (HERE / 'readonly-exit.txt').read_text() == '0\n'
assert gzip.decompress((HERE / 'readonly-stderr.log.gz').read_bytes()) == b''
result = json.loads(gzip.decompress((HERE / 'readonly-stdout.log.gz').read_bytes()))
retirement = json.loads((HERE / 'retirement.json').read_bytes())
assert result['result'] == retirement['result'] == 'PASS'
assert result['archived_files'] == retirement['removed_plain_files'] == 4
assert result['archived_content_bytes'] == retirement['archived_content_bytes']
names = {path.relative_to(ROOT).as_posix() for path in HERE.rglob('*') if path.is_file()}
for capture in HERE.glob('*-inputs.json.gz'):
    names.update(json.loads(gzip.decompress(capture.read_bytes())))
report = json.loads(gzip.decompress((HERE / 'observation.json.gz').read_bytes()))
names.update(report['producers'])
inputs = []
for name in sorted(names):
    path = ROOT / name
    assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    inputs.append(dict(path=name, sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
        role='producer' if name.endswith(('.py', '.sh')) and name != 'tools/run_lua_project_data.sh' else 'input'))
source = dict(name='dated-metadata-and-exact-combined-log-recovery',
    statement=f"The dated primary and independent census agree on {result['scoped_rows']} named-scope metadata rows. Four completed owned combined logs retain all {result['archived_content_bytes']} content bytes and original modes in compressed evidence. Independent use passes before exact plain-file retirement and again afterward; fourteen distinguishing metadata/log/channel corruptions reject.",
    scope='Eight explicit root/Rust/log scopes, with configured rust/target covered. Only the four manifest-named combined command logs are retired; every other candidate, cache, native product, tracked proof and other repository remains protected. Retained combined logs do not recreate the original stdout/stderr separation. Source template, census/index records, project instruments, command channels, archives, original modes, Git completion identities and residue receipt are explicit inputs. No whole-project population, global liveness, allocated/free-space reclamation, concurrent-adversarial guarantee or infrastructure/runtime change.',
    rederive=dict(status='checked',
        command='bash tools/project_data_run.sh env PYTHONPATH= python3 -P ' + str(BASE / 'review.py'),
        granularity='Each retained census path/suffix/byte row, each of four log bodies/modes/actual Git completion markers, exact retirement/residue and actual capture/replay/predelete/retirement channels.',
        result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked',
        hypothesis='An omitted/changed metadata row, missing or altered archive, fabricated successful log, wrong mode/commit or substituted command/channel could be accepted as support for safe exact retirement.',
        oracle='Separately implemented scandir/lstat population versus the accepted os.walk scanner; independent reader of retained gzip bytes and original Git records, without census-helper or retirement imports; actual healthy predelete and postdelete invocations.',
        red_control=json.dumps(result['rejected_controls'], sort_keys=True)),
    durability=dict(status='checked', mode='live', inputs=inputs))
native = copy.deepcopy(source)
native.update(name='dated-host-maintenance-with-native-custody-gap',
    statement='The dated host census and exact four-log archival retirement completed with retained actual command channels and independent checks.',
    scope='Original dated host filesystem observation and owned plain-duplicate retirement only. Later readonly recovery establishes retained evidence consistency; it does not recreate the original host epoch or measure reclaimed physical storage.')
native['durability'] = dict(status='gap',
    reason='All named project sources, template/index/census inputs, archive bodies/modes and actual channels are retained. The original interpreter/native libraries/toolchain/kernel/filesystem and complete transitive first-use epoch are not acquired.',
    repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2')
destination = ROOT / 'docs/claims' / (OWNER + '.json')
assert not destination.exists(), 'one-shot declaration'
destination.write_text(json.dumps(dict(version=1, owner=OWNER, claims=[source, native]), indent=2) + '\n')
(ROOT / 'docs/ARTIFACT_CLEANUP.md').write_text(
    '# Latest artifact cleanup\n\n- Date: ' + retirement['at_utc'] + '\n- Summary: ' + OWNER +
    f" reviewed {result['scoped_rows']} matching metadata rows in eight named scopes; archived four completed owned combined logs ({result['archived_content_bytes']} content bytes/modes), verified independent use before deletion, removed exactly their plain duplicates and confirmed residue absent. Separate readonly0/empty stderr and fourteen corruption controls pass. All other artifacts/caches/proof/repositories remain retained; no physical reclamation claim. Evidence: {BASE}/; complete native/OS custody remains23.4.2.\n")
(HERE / 'REVIEW.md').write_text(f'''# November11 safe artifact cleanup

Owner: {OWNER}. Clean activation: e5f2cb78ab99192974178ea04177b6cabf283e1e.
Census: {report['at_utc']}; exact duplicate retirement: {retirement['at_utc']}.

The accepted non-following scanner and independent scandir/lstat agree on
{result['scoped_rows']} path/suffix/byte rows in eight named root/Rust/log scopes.
The configured Cargo target is covered. Every census candidate is retained;
metadata alone grants no disposal authority. Dart/Julia conventions remain
retained, and managed runs/caches/submodules/other repositories are not traversed.
The unchanged November10 census source is an explicit composition input, copied
and verified before transformation. No previous claim JSON supplied this record.

Only four exact owned combined command logs are selected, each from a completed
normal commit in this session: qualified Dart callable, Rust task headroom,
Julia callable and installed Lua callable. Original bodies, byte sizes, modes,
metadata and Git completion/parent identities survive in archive-manifest.json
and combined-logs/. All {result['archived_content_bytes']} content bytes are exact.
These are combined logs; original stdout/stderr separation is unavailable.
No tracked proof reference was found in the retained, bounded Git query. No
generic log deletion, lifecycle recovery/purge or global process-liveness claim.

Copies are compressed and byte-verified before an actual independent predelete
reader returns0/empty stderr. That reader checks complete all10/post-pointer/
commit markers and fourteen effective metadata/log/channel corruptions. The
writer rechecks each exact file's identity/hash immediately before unlinking it.
The residue receipt contains exactly four absent plain paths. Separate default
readonly acquisition returns0/empty stderr afterward and consumes the archives
without requiring those retired plain files. Every unselected file/cache/native
product and historical proof stays retained. No allocated/free-space measurement.

Actual argv/cwd/exit/full child channels and project source images are retained.
This bounds source/evidence consistency, not the original interpreter/OS/native/
transitive first-use epoch; that missing leg stays with23.4.2/SESSION5.
prepare, capture, retire, acquisition and publication modes are completed one-shot
writers. Do not replay them. Default recovery is readonly:

```sh
bash tools/project_data_run.sh env PYTHONPATH= python3 -P {BASE}/review.py
```

All bounded ordinary79/callable79.6 outcomes remain focused-checked, with full
admission separate. Next23.1.41 reconciles the authoritative operation inventory,
including its stale current pointers and missing parent child link, before
choosing a bounded next owner. Finite samples imply no overall completeness.
''')
print(json.dumps(dict(result='published', owner=OWNER, inputs=len(inputs), scoped_rows=result['scoped_rows'],
    archived_files=result['archived_files'], content_bytes=result['archived_content_bytes']), sort_keys=True))
