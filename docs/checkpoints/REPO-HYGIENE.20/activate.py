"""Declare due maintenance20 before adopting its preserved accepted10 inputs."""
import gzip
import json
from pathlib import Path
import subprocess
import sys
ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-array-count-first'))
import common as old
BASE='79c68715c04f06379bb18673b09d44dd90611439'
PREFIX='docs/checkpoints/REPO-HYGIENE.20/'
OWNER='REPO-HYGIENE.20'


def load(name):
    return json.loads(gzip.decompress((ROOT/'.linkedspec-data/verification'/name).read_bytes()))


def main():
    prior=load('hygiene20-prior10.json.gz')
    assert prior['base']==BASE and prior['baseline']['returncode']==0
    assert not old.decode(prior['baseline']['stderr_base64'])
    status=old.run(['git','status','--porcelain'])
    assert not old.decode(status['stdout_base64']) and status['returncode']==0
    assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip()==BASE
    assert all(old.identity(path)=={key:item[key] for key in ('sha256','mode')}
        for path,item in prior['images'].items())
    paths=list(prior['planned_before'])+['docs/knowledge/repo-generated-artifact-cleanup-boundary.md']
    before={path:old.read(path) for path in paths}
    for path,packet in prior['planned_before'].items():
        assert packet==before[path]
    direct={}
    for path,entry in prior['live_claims'].items():
        record=json.loads(old.decode(entry['packet']['base64']))
        matched=[]
        for claim in record['claims']:
            durability=claim.get('durability',{})
            if durability.get('status')=='checked' and durability.get('mode','live')=='live':
                intersection=sorted({item['path'] for item in durability['inputs']} & set(paths))
                if intersection:matched.append(dict(name=claim['name'],paths=intersection))
        if matched:direct[path]=matched
    assert not direct,direct
    actor=old.read(Path(__file__).resolve().relative_to(ROOT).as_posix())
    tree=old.decode(before['docs/tasks/REPO-HYGIENE.md']['base64']).decode()
    tree=tree.replace('- Status: `completed` / retained review .19 verified','- Status: `active` / due retained review .20',1)
    tree=tree.replace('- Last updated: `2026-10-19` (`REPO-HYGIENE.19`: due retained review and public warning evidence)',
                      '- Last updated: `2026-10-22` (`REPO-HYGIENE.20`: due artifact review after callable selection)',1)
    tree=tree.replace('  Status: `done`\n  Goal: `Repository hygiene', '  Status: `active`\n  Goal: `Repository hygiene',1)
    tree=tree.replace('`REPO-HYGIENE.18`, `REPO-HYGIENE.19`','`REPO-HYGIENE.18`, `REPO-HYGIENE.19`, `REPO-HYGIENE.20`',1)
    marker='## Current Frontier\n'
    assert tree.count(marker)==1
    leaf='''- ID: `REPO-HYGIENE.20`
  Status: `active` / accepted10 custody preserved
  Priority: P2 — overdue daily artifact review, before registered pipeline11.
  Goal: Inspect dated parent/Rust artifact metadata and retained toolchain conventions; preserve evidence/caches unless an exact disposable target is proved safe; refresh the latest-only record.
  Activation: Clean79c68715 after count/first10 canonical CI, private91/32246, Phase01035, all10 normal hooks, receipt promotion, explicit post-pointer/memory, brief0 and clean Git. Actual clean readonly publication4 and11129 physical inputs/11132 independently Git-verified full-mode images plus older logical aliases precede this first tracked write. Complete checked-live census finds no direct planned-surface intersections; accepted10 additionally binds its whole physical manifest and is preserved/retired only at79c68715.
  Owned paths: docs/checkpoints/REPO-HYGIENE.20/; this task tree, latest-only docs/ARTIFACT_CLEANUP.md, normal live continuity/roadmap/index/history, artifact and helper reverify headers/derived map and maintenance book guidance; mode/revision-only retirement of claim10 and its checkpoint boundary note. No runtime, permanent test, dependency, cache policy, storage/gate mechanism or budget change.
  Verification tier: `focused`
  Focused checks: Whole accepted10 custody and actual readonly baseline before tracked writes; non-following parent and explicit Rust log/bin census, fresh comparison and independent per-file lstat; retained Dart/Julia/Lua conventions; actual metadata/channel falsifiers and restoration; current source/claim binding, complete affected book render with effective marker control, core scalar numeric consumer, Knowledge, both bounded histories, memory/whitespace and all normal doctrines.
  Canonical trigger: none — ordinary dated maintenance; the accepted10 canonical receipt is retained, with no new public/runtime/infrastructure admission.
  Claim verification: `docs/claims/REPO-HYGIENE.20.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Latest record2026-10-20T19:45:58.736082+00:00 is over24h old; committed count/first10 is clean and admitted.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Scheduled maintenance is due; established non-following census excludes all other repositories, managed runs, retained caches and old fixtures. Metadata alone never authorizes deletion.
  - [ ] **FIX** — Complete the owned review and latest-only date/disposition without deleting proof or reusable data.
  - [ ] **ADDRESSED (verified)** — Retained full actual channels, independent metadata oracle and effective denials.
  - [ ] **NO REGRESSION** — Focused core/book/provenance/doctrines pass; accepted10 stays independently recoverable at its real revision.
  - [ ] **LOCKSTEP** — Current book/Knowledge/task/roadmap/handoff describe this maintenance scope and resume11.
  Limits: Dated metadata, not content ownership/disposability or concurrent-adversarial/liveness/recovery/purge evidence. Zero removals is valid. Other repositories/submodules remain strictly read-only; reusable cache/package/compiler outputs remain retained by default. No push until PNT is exhausted.
  Commit subject: `REPO-HYGIENE.20 - review retained project artifacts`.

'''
    tree=tree.replace(marker,leaf+marker,1)
    tree=tree.replace('| 1 | `REPO-HYGIENE.19` |', '| 0 | `REPO-HYGIENE.20` | `active` | Due retained review at clean79c68715; resume pipeline11 after normal landing. |\n| 1 | `REPO-HYGIENE.19` |',1)
    # This owning leaf is the first tracked write. Everything else follows it.
    old.source('docs/tasks/REPO-HYGIENE.md').write_text(tree)
    target=ROOT/PREFIX
    target.mkdir()
    for name,source in [('preserve.py','hygiene20-preserve.py'),('activate.py','hygiene20-activate.py'),
                        ('prior-baseline.json.gz','hygiene20-baseline.json.gz'),('prior10.json.gz','hygiene20-prior10.json.gz')]:
        packet=old.read('.linkedspec-data/verification/'+source)
        with (target/name).open('xb') as stream:stream.write(old.decode(packet['base64']))
        (target/name).chmod(packet['mode'])
    common=old.source(old.PREFIX+'common.py').read_text().replace(old.BASE,BASE).replace(old.PREFIX,PREFIX).replace(old.OWNER,OWNER)
    with (target/'common.py').open('x') as stream:stream.write(common)
    with (target/'context.py').open('x') as stream:stream.write(old.source(old.PREFIX+'context.py').read_text())
    claim_path='docs/claims/TYPE-REFERENCE-BOOK.1.2.10.json'
    record=json.loads(old.decode(prior['claim']['base64']))
    assert before[claim_path]==prior['claim']
    for claim in record['claims']:
        assert claim['durability']['mode']=='live'
        claim['durability'].update(mode='historical',revision=BASE)
    old.source(claim_path).write_text(json.dumps(record,separators=(',',':'))+'\n')
    readme=old.source(old.PREFIX+'README.md')
    readme.write_text(readme.read_text()+'\nHistorical boundary: accepted79c68715c04f06379bb18673b09d44dd90611439. Publication4 and claim10 require their complete accepted inputs; maintenance20 preserves the whole publication and actual clean readonly0 before shared writes. Current work follows MEMORY.md.\n')
    memory=f'''# MEMORY

- activation_commit: `{BASE}` — clean maintenance20 base; Git owns current identity.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.10` —79c68715 after canonical CI, private91/32246, Phase01035, all10 normal hooks and promoted receipt.
- active_work_unit: `REPO-HYGIENE.20`; task_owner: docs/tasks/REPO-HYGIENE.md.
- next_action: Complete due parent/Rust retained artifact census with full channels, independent lstat/falsifiers, latest-only record/book/current proof, then normal focused commit before11.
- in_flight_uncommitted: Maintenance20 activation/custody only; runtime and evidence/caches are unchanged. No deletion is authorized by metadata alone.
- custody: docs/checkpoints/REPO-HYGIENE.20/prior10.json.gz retains11129 physical inputs/11132 Git-verified full-mode images, older logical aliases, whole publication4 and actual clean readonly0 at79c68715.
- proof: Count/first10 remains historical at79c68715:232 cases/107 accepted RED/eight source faults/private236/book89/5/history680. Maintenance changes no runtime behavior or admission.
- owners: After20,11 registered sorted/ordinary length ->12 deferred indexed writes ->14 deferred last ->inventory/mapping/layout/legacy/private QA. Other numeric/Boolean/Unicode owners remain separate.
- limits: Other repositories/RGX/PGEN stay read-only black boxes. Data stays on repository filesystem. Preserve reusable caches and proof; no liveness/recovery/purge or adversarial guarantee. No push until PNT is exhausted.
- cleanup: Latest2026-10-20T19:45:58.736082+00:00; current due review20 is not yet complete.
'''
    old.source('MEMORY.md').write_text(memory)
    value=dict(owner=OWNER,base=BASE,producer=actor,before=before,
        after={path:old.read(path) for path in ['docs/tasks/REPO-HYGIENE.md','MEMORY.md',claim_path,old.PREFIX+'README.md']},
        additional_direct_intersections=direct,
        scope='New maintenance leaf is declared before any other tracked write. Whole real accepted10 and actual clean readonly0 precede activation. Claim10 changes only durability mode/revision; runtime/proof/cache bytes stay unchanged.')
    with (target/'activation.json.gz').open('xb') as stream:
        stream.write(gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
    print('Maintenance20 active; whole accepted10 preserved; no runtime, cache or proof deletion')


if __name__=='__main__':main()
