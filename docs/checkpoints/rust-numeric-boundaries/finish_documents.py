"""Owned final continuity update and measured-claim publication; one shot each."""
import json
import re
import subprocess
import sys
from pathlib import Path
import common as c

SUBJECT=c.OWNER+' - preserve Rust numeric values at conversion boundaries'
NEXT='TYPE-REFERENCE-BOOK.1.2.17.4'
PART='docs/tasks/SESSION-STARTUP-READING.50-99.md'
PATHS=['MEMORY.md','CHANGES.md','DEVELOPMENT_NOTES.md','LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md',PART,
    'docs/tasks/SESSION-STARTUP-READING.md','docs/tasks/TYPE-REFERENCE-BOOK.md']


def replace(text,old,new):
    assert text.count(old)==1,old[:120]
    return text.replace(old,new,1)


def documents():
    assert len(c.load('closeout3-result.json.gz')['completed'])==4
    assert c.load('auditor-control-result.json.gz')['exact_restoration']
    for name in ['source-fault','auditor','input']:
        assert not (c.ROOT/f'.linkedspec-data/verification/numeric55-{name}-lease.json').exists()
    before={path:c.read(path) for path in PATHS}
    # No old live claim may be refreshed to accommodate mutable documentation.
    selected=set(PATHS+['KNOWLEDGE_MAP.md',
        'docs/knowledge/terse-type-method-surface-inventory.md'])
    claims={}
    for path in subprocess.check_output(['git','ls-files','docs/claims'],cwd=c.ROOT,text=True).splitlines():
        packet=c.read(path);claims[path]=packet
        for claim in json.loads(c.decode(packet['base64']))['claims']:
            durable=claim['durability']
            if durable.get('mode')=='live':
                assert not selected & {item['path'] for item in durable.get('inputs',[])},path
    c.save('live-documents-before.json.gz',dict(files=before,claims=claims,
        producer=c.read(c.PREFIX+'finish_documents.py'),live_claim_intersections=[],
        scope='Complete old mutable continuity and actual current claim namespace. '
            'Knowledge before/after bytes are separately retained; no historical claim is refreshed.'))
    texts={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    texts['MEMORY.md']=f'''# MEMORY

- activation_commit: `{c.BASE}` — clean numeric55.1 activation base; derive current HEAD from Git.
- latest_completed_leaf: `{c.OWNER}`; subject: {SUBJECT}; derive accepted identity from Git.
- active_work_unit: `{NEXT}`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: from clean committed Git activate Dart signed selectors17.4. Read its leaf, canonical signed targets and Dart integration/affected book paths; reproduce existing-position reads/writes and implement one owned safe slice. Then Julia/Lua/admission17.5–7 and the type-reference frontier. Never pivot dirty.
- in_flight_uncommitted: none in the intended clean post-landing handoff. No pending verification job or fault lease; no push. Exact staged canonical receipt and normal hooks govern this commit.
- proof: docs/checkpoints/rust-numeric-boundaries/publish.py is the readonly final entrypoint. Core36, runtime212+metadata23, bridge66, emitted49+4, CLI52/104+function4, five physical faults/restoration, suites260/libraries189+202/types8, readiness6/emitted4/4/3, book95/90 and exact historical recovery134/84613241/22 pass. Input4 actual bypass/restoration and final custody are required by the final publisher. Capture/seal writers are retired after acceptance; signed-array-rust198 and signed-array-rust-admission58 remain sealed and unchanged.
- steering: Numeric55.2 owns portable text spelling;55.3 broad closeout. Fluent23 and OPENAI-TOOL-API remain deferred. Canonical CI starts on the approved host per docs/knowledge/project-data-process-locality-proof.md, with its sandbox intact. Other repositories/submodules are read-only black boxes; project data stays on-volume. Commit each leaf; no push until PNT exhausted.
'''
    change='''## 2026-10-25 — SESSION-STARTUP-READING.55.1 — Rust numeric value transport

Rust preserves finite binary64 values across JSON, numeric text/length/Display and serialized/generated parsers. Checked signed/unsigned integer projection replaces saturation; wider finite values remain floating JSON, negative zero retains its JSON sign, and nonfinite JSON remains null. The serde_json float_roundtrip feature preserves the two representable neighbors inside the i64 limits without a dependency-version change. Positive nested-write indexes and both integer metadata readers check the exclusive host bound. Legacy read/count coercions, signed selectors, the scalar-text authority and the binary64 model remain.

Independent retained checks pass36 core cases,212 runtime observations/23 metadata controls,66 real bridge observations,49+4 actual emitted entries,52 CLI cases/104 quiet-trace channels and4 function CLI controls. Five physical source faults fail and restore exact source/fresh GREEN. Eight direct suites pass260 tests; libraries189/202 and core types8 pass. Fresh unchanged readiness passes parent6/emitted4/4/3. Complete book95/90, two executed examples, five source and two semantic controls pass; containment changes four search bodies in whitespace only and decreases source lines by one.

Exact historical admission preserves134 streams/84613241 bytes/22 controls and the signed predecessor. The observed pair-only admission gap is repaired with five support images: six primary/five support/nine direct denials and actual rollback/two bypasses reject; exact restoration returns the identical report. Readonly publication requires whole retained source/executable/input custody and four physical input denials/bypasses/restoration. All provisional instruments remain qualified in the checkpoint README; no old proof is refreshed. Exact staged canonical CI and normal hooks govern landing. Dart signed17.4 is next; numeric spelling55.2, broad closeout55.3 and fluent23 remain open.

'''
    notes='''## 2026-10-25 — SESSION-STARTUP-READING.55.1 — exact integer domains and source admission

Use exclusive powers of two at f64/host-integer boundaries: an integer MAX cast to f64 can round upward and admit a saturating conversion. The numeric helper separates exact signed64, unsigned64 and finite-floating JSON. Exact JSON tokens and bit-level round trips are independent targets; converting an incorrect i64-max token back to f64 would hide its identity at2^63. Shared numeric text/Display/length fixes outward consumers without choosing the portable cat spelling policy. The real recursive child bridge and actual function-definition/staged-body producers are covered separately from private huge metadata tests.

Enabling serde_json float_roundtrip fixes a distinct raw-serde parser loss, proven by same-source feature control and a physical inverse. Numeric reads/bounded counts/child-push overloads retain their contracts. No arbitrary precision,32-bit execution, alternate backend admission or reachable huge grammar source is claimed.

Primary Cargo/Engine image checks initially admitted an actual mutated helper. Retained same-fault evidence distinguishes the repaired five-support guard, which uses the supplied guarded reader and retains the signed predecessor. Original134 historical streams and results remain immutable; fresh readiness is separate. Actual old-auditor rollback and primary/support guard bypasses fail, and exact restoration reproduces the same recovery report.

The first wide-text oracle, incomplete helper custody, invalid dispatch/key probes, correction parse failure, book capacity assumptions, generated-search references, invalid compatibility target and missing readiness-wrapper path remain explicit provisional instruments. Corrected epochs retain whole source, actual executable bytes/modes and channels. Readonly publish.py binds the final namespace; capture/seal writers stay retired. Existing book retrieval now points directly to its canonical decoder and current90-output proof; no collection budget grows.

'''
    for path,record in [('CHANGES.md',change),('DEVELOPMENT_NOTES.md',notes)]:
        text=texts[path];position=text.index('\n## ')
        texts[path]=text[:position+1]+record+text[position+1:]
    live=texts['LIVE_ACHIEVEMENT_STATUS.md'];history=live[live.index('## History'):]
    recent=live.split('## Recent Completions\n',1)[1].split('## History',1)[0]
    rows=[line for line in recent.splitlines() if line.startswith('- ')]
    rows.insert(0,'- `SESSION-STARTUP-READING.55.1` — finite Rust transport/core36/runtime212/bridge66/emitted53/CLI104; five source faults restored, suites260/readiness6+4/4/3, book95/90, exact historical admission and physical input4; Dart17.4 next.')
    texts['LIVE_ACHIEVEMENT_STATUS.md']='''# LIVE ACHIEVEMENT STATUS

## Current Activity

Rust numeric55.1 is verified; exact canonical receipt and normal hooks govern landing. Next clean activity is Dart signed-selector17.4, then Julia/Lua/admission17.5–7. Fluent23 and OPENAI-TOOL-API implementation remain deferred.

## Latest Completed Slice

SESSION-STARTUP-READING.55.1 preserves finite binary64 transport and checked host-integer boundaries. Core36/runtime212+metadata23/bridge66/emitted49+4/CLI52 cases104 channels+function4 pass. Five physical source faults restore exact bytes and fresh GREEN; suites260/libraries189+202/types8 and fresh readiness6/emitted4/4/3 pass. Book95/90 and actual source/semantic controls preserve examples and aliases. Historical134/84613241/22, six primary/five support/nine direct denials and three actual auditor faults/restoration pass. Final readonly publication binds whole proof inputs and requires physical input4/bypass/restoration. No portable spelling or other-backend closeout is claimed.

## Next Action

From clean committed Git activate TYPE-REFERENCE-BOOK.1.2.17.4. Recover its Dart leaf and signed authority, verify current observations and implement one bounded native/generated slice. Continue the existing frontier; never rerun sealed capture writers or pivot dirty.

## Recent Completions

'''+ '\n'.join(rows[:16])+'\n\n'+history
    for path in ['ROADMAP.md','ROADMAP_V2.md']:
        text=texts[path]
        text=re.sub(r'^October25 current PNT boundary:.*$',
            'October25 current PNT boundary: Rust signed17.3 and numeric55.1 are verified. Numeric transport retains binary64 values, checked integer boundaries, five physical source faults/restoration, direct suites260, fresh readiness6/emitted4/4/3, current book and exact historical source/support admission. Exact staged canonical CI/normal hooks govern landing. Dart17.4 is next, then Julia/Lua/admission17.5–7. Portable numeric spelling55.2 and broad closeout55.3 remain open.',text,count=1,flags=re.M)
        text=replace(text,'Numeric55.1, Dart/Julia/Lua and admission17.4–7,','Dart/Julia/Lua and admission17.4–7,')
        text=replace(text,'literal-kind22 and Rust17.3 implementation are complete.','literal-kind22, Rust17.3 and numeric55.1 are complete.')
        text=replace(text,'Rust17.3 then numeric55.1 preserve the PNT engineering order.','Dart17.4 follows verified Rust17.3/numeric55.1 in the PNT engineering order.')
        texts[path]=text
    text=texts[PART];start=text.index('- ID: `'+c.OWNER+'`\n');end=text.index('- ID: `SESSION-STARTUP-READING.55.2`',start)
    node=text[start:end].replace('  Status: `in_progress`','  Status: `done`',1).replace('- [ ]','- [x]')
    a=node.index('  Continuity repair:');b=node.index('  Acceptance: Lock direct',a)
    node=node[:a]+'''  Verification: Core36, native/spec/compiled/plan212 and public metadata23 pass; actual progressive bridge66, emitted49+function4, primary CLI52/104 plus4 function controls and private AST77 checks pass. Exact JSON integer tokens and independent IEEE bits distinguish value preservation. Runtime/core libraries189/202 and core types8 pass; eight direct suites260 and fresh unchanged readiness parent6/emitted4/4/3 pass with actual source/workspace/executable custody.
  Physical controls: Five production faults distinguish saturation, exclusive host bound, raw-serde parsing, signed zero and the private AST guard. Each actually fails, restores exact bytes/mode and passes fresh GREEN. The pair-only admission gap is reproduced during the helper fault and repaired with five support bindings; six primary/five support/nine direct denials and actual auditor rollback/two bypasses reject. Exact restoration reproduces original134 streams/84613241 bytes/22 controls without refreshing historical runtime.
  Documentation/custody: Book95 inputs/90 outputs, two executed examples, five source/two semantic denials pass. Neutral containment changes four search bodies only in whitespace and source lines decrease by one. Existing numeric/book Knowledge routes are bounded and directly reverify the proof. Final publish.py requires exact whole source/executable/input custody and four physical missing/bytes/mode/required-omission denials, actual validator bypasses and exact restoration. Claim and normal doctrine/canonical receipt gates govern landing.
  Qualifications: Complete pre-final task/live bytes are retained in live-documents-before.json.gz. Checkpoint README/AUDIT and original epochs preserve the overstrict wide-text oracle, initial helper-custody omission, invalid dispatch/key probes, correction parse failure, book capacity/search-reference rejections, invalid compatibility target and wrong readiness-wrapper path without false product RED. No arbitrary precision,32-bit execution, other-backend admission or portable55.2 spelling decision. Sealed signed predecessors and all other repositories remain unchanged.
  Next boundary: Commit this leaf cleanly before Dart signed17.4. Numeric55.2/55.3 and comprehensive fluent23 retain their independent owners. Exact staged approved-host canonical CI and normal hooks are mandatory before acceptance; keep the process sandbox intact and do not push during PNT.
'''+node[b:]
    node=node.replace('  Verification: `pending` repair —','  Historical verification (pre-repair):',1)
    node=replace(node,'  Commit: `pending`','  Commit: `'+SUBJECT+'`')
    texts[PART]=text[:start]+node+text[end:]
    text=texts['docs/tasks/SESSION-STARTUP-READING.md'];a=text.index('Existing P1 `.55.1`');b=text.index('\nIndexed-read .88',a)
    text=text[:a]+'''Numeric `.55.1` is verified from activation f0d974aa1; its exact canonical receipt
and normal hooks govern landing. Return to `TYPE-REFERENCE-BOOK.1.2.17.4` only
after the clean numeric commit. Portable text policy remains `.55.2`; `.55.3`
owns the broader numeric closeout. Other startup repairs retain their schedule.

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `TYPE-REFERENCE-BOOK.1.2.17.4` | `pending` | Resume Dart signed selectors after the clean Rust numeric repair; owner is the type-reference tree. |
'''+text[b:]
    text=replace(text,'P1 .55.1 is active;','Numeric .55.1 is verified;')
    texts['docs/tasks/SESSION-STARTUP-READING.md']=text
    text=texts['docs/tasks/TYPE-REFERENCE-BOOK.md']
    text=replace(text,'- Status: `active` / P1 numeric55.1 then Dart17.4','- Status: `active` / Dart signed17.4 next')
    text=replace(text,'This is future acceptance work under .1.2.23, with no pivot from the active Rust signed-selector leaf.','This is future acceptance work under .1.2.23; the current signed-selector backend sequence remains selected.')
    a=text.index('## Current Frontier');b=text.index('\n## Decisions',a);frontier=text[a:b]
    frontier=re.sub(r'^\| 1 \| `SESSION-STARTUP-READING.55.1`.*\n','',frontier,flags=re.M)
    frontier=re.sub(r'^\| (\d+) \|',lambda m:'| '+str(int(m[1])-1)+' |',frontier,flags=re.M)
    texts['docs/tasks/TYPE-REFERENCE-BOOK.md']=text[:a]+frontier+text[b:]
    text=texts['docs/TASK_TREE.md']
    text=re.sub(r'^Latest PNT slice:.*$',
        'Latest PNT slice: SESSION-STARTUP-READING.55.1 — finite Rust transport and checked integer boundaries pass independent source/executable, fault/restoration, compatibility/book and exact historical source/support checks. Canonical receipt/normal hooks govern landing. Dart signed17.4 is next; fluent23 and OPENAI-TOOL-API implementation remain deferred.',text,count=1,flags=re.M)
    text=text.replace('fallback verification .92, numeric constructor .94, result kinds .95 and cat-arity .51 remain queued;',
        'fallback verification .92 and numeric55.1 are verified; constructor .94, result kinds .95 and cat-arity .51 remain queued;',1)
    text=re.sub(r'^\| `TYPE-REFERENCE-BOOK`.*$',
        '| `TYPE-REFERENCE-BOOK` | `active` / Dart .1.2.17.4 next | `.spec documentation / complete type and fluent reference` | Rust signed17.3/numeric55.1 verified; Dart/Julia/Lua/admission17.4–7 follow the clean numeric commit. Complete inventory then comprehensive fluent/inter-type23 precede coverage/layout and family closeout. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |',text,count=1,flags=re.M)
    text=re.sub(r'^\| `SESSION-STARTUP-READING`.*$',
        '| `SESSION-STARTUP-READING` | `active` / targeted startup | `Session continuity / repair selection` | ADR0123 governs targeted recovery; separate full-reading remains open. Numeric55.1 is verified, with spelling55.2/broad55.3 separately owned; Dart signed17.4 resumes after clean landing. Canonical repair evidence and remaining .7/.87/.94/.95/.51/.96 obligations stay in this partitioned tree. | [docs/tasks/SESSION-STARTUP-READING.md](docs/tasks/SESSION-STARTUP-READING.md) |',text,count=1,flags=re.M)
    texts['docs/TASK_TREE.md']=text
    for path,text in texts.items():(c.ROOT/path).write_text(text)
    c.save('live-documents-after.json.gz',dict(files={path:c.read(path) for path in PATHS},
        producer=c.read(c.PREFIX+'finish_documents.py'),
        scope='Intended clean post-landing continuity; exact staged canonical receipt and normal hooks remain mandatory before commit. Task index/Knowledge Map are regenerated separately.'))
    print('Current task/live/roadmap handoff updated; whole prior documents and claim census retained.')


def claim():
    import publish
    result=publish.check()
    inputs=[]
    for file in sorted((c.ROOT/c.PREFIX).iterdir()):
        if file.is_file():
            inputs.append(dict(path=file.relative_to(c.ROOT).as_posix(),
                sha256=c.identity(file.relative_to(c.ROOT).as_posix())['sha256'],
                role='producer' if file.suffix=='.py' else 'input'))
    record=dict(version=1,owner=c.OWNER,claims=[dict(
        name='rust-numeric-value-transport',
        statement='Rust preserves finite binary64 values through the selected outward/serialized/generated numeric boundaries and checks positive nested-write and integer-metadata host bounds.',
        scope='Dated64-bit Rust producer/source/executable epochs at activation '+c.BASE+'. Exact integer tokens, IEEE bits and named diagnostic fields are independent targets. Number(f64), legacy reads/counts/child-push overloads, signed normalization, frozen scalar-text authority and nonfinite policy remain. Private huge AST controls do not establish reachable source. No arbitrary precision,32-bit execution, portable decimal/exponent policy, unrelated arithmetic or other-backend admission. SDK/OS/prepared published RGX products and accepted Git objects are read-only prerequisites; no whole-environment replay. Provisional fixture/custody/invalid-probe/book/target/wrapper instruments remain retained and explicitly qualified; corrected epochs are separate. Historical134 streams and predecessor source identities are unchanged. Exact staged canonical receipt and normal commit hooks govern landing.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Actual numeric input/IEEE bits/JSON token, authored program and execution route, typed metadata/error field, source fault/restoration, executable/input epoch, original historical stream, complete supplied book output and physical publication input.',
            result=json.dumps(result,sort_keys=True)),
        falsify=dict(status='checked',
            hypothesis='Saturated values, rounded host bounds, raw-serde bit loss, lost signed zero, unchecked private metadata, incomplete source admission or missing/altered proof inputs pass.',
            oracle='Independent authored IEEE bits/exact integer tokens and original targets, observed public pre-repair output, actual physical production inverses and unchanged consumers, original historical archive/source identities, complete decoded book and physical publication faults.',
            red_control='Five actual source faults fail: json-clamp core34 grouped fields/bridge34/emitted25/functions2; host-bound runtime4/metadata4; float-roundtrip core2/emitted2/functions1; signed-zero core1; private AST reader actual test RED. Every source restores exact bytes/mode and fresh GREEN. The observed pair-only admission gap is rejected after five-support repair; six primary/five support/nine direct denials and actual old-auditor/primary-bypass/support-bypass fail; exact restored historical report matches. Five book source/two semantic controls reject. Four actual missing/bytes/mode/required-omission inputs reject, admit under physically discarded publisher and reject again after exact source/input restoration.'),
        durability=dict(status='checked',mode='live',inputs=inputs))])
    path=c.ROOT/'docs/claims'/f'{c.OWNER}.json'
    with path.open('x') as output:json.dump(record,output,sort_keys=True,separators=(',',':'));output.write('\n')
    assert path.stat().st_size<=131072
    print(json.dumps(dict(inputs=len(inputs),claim_bytes=path.stat().st_size,result=result),sort_keys=True))


if __name__=='__main__':
    assert sys.argv[1:] in (['documents'],['claim'])
    documents() if sys.argv[1]=='documents' else claim()
