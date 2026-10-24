"""One-shot continuity/Knowledge preparation and separate claim creation."""
import json
import subprocess
import sys
import common as c
import context

BOOLEAN = 'docs/knowledge/perl-codeblock-boolean-literal-kind-drift.md'
PRIMITIVE = 'docs/knowledge/terse-primitive-literal-parity.md'
WRITE = 'docs/knowledge/write-vivification-perl-reference.md'
INVENTORY = 'docs/knowledge/terse-type-method-surface-inventory.md'
TREE = 'docs/tasks/TYPE-REFERENCE-BOOK.md'


def replace(path, old, new):
    file=c.source(path)
    text=file.read_text()
    assert text.count(old) == 1, (path,old[:80])
    file.write_text(text.replace(old,new,1))


def prepare():
    assert c.load('fault-controller-runs.json.gz')['sources_restored']
    records={}
    for path in subprocess.check_output(['git','ls-files','docs/claims'],cwd=c.ROOT).decode().splitlines():
        value=json.loads(c.source(path).read_bytes())
        claims=[claim for claim in value['claims'] if claim['durability'].get('status')=='checked' and claim['durability'].get('mode')=='live']
        if claims:
            names={item['path'] for claim in claims for item in claim['durability']['inputs']}
            assert INVENTORY not in names,path
            records[path]=dict(packet=c.read(path),inputs=sorted(names))
    epoch=context.snapshot()
    c.write_new('knowledge-before.json.gz',dict(context=epoch,producer=c.read(c.PREFIX+'finish.py'),
        added_path=INVENTORY,live_records=records,before={path:c.read(path) for path in (BOOLEAN,PRIMITIVE,WRITE,INVENTORY)},
        qualification='Additional type-method card receives a pre-write live-claim census; existing card identities and every retrieval question survive in this packet and Git. The boolean original is also retained in activation.'))
    c.source(BOOLEAN).write_text('''---
id: perl-codeblock-boolean-literal-kind-drift
title: "Perl deferred literal kinds, precision and scalar validity"
answers:
  - "why does a Perl codeblock return 1 instead of true"
  - "do dynamic Perl codeblocks preserve boolean literal types"
  - "does a boolean argument remain typed through a Perl codeblock"
  - "where does Perl codeblock evaluation lose boolean literal identity"
  - "which task owns dynamic codeblock boolean result parity"
  - "why did deferred large fractional Perl literals lose numeric precision"
  - "why did Storable change whole float kinds in copied codeblocks"
  - "can a private Perl integer cache admit a fractional array selector"
  - "which scalar validity flags classify Perl nested write selectors"
date: 2026-10-24
status: repaired on Perl; finite literal-kind22 proof
tags: [perl, codeblock, literal, boolean, actionir, SESSION-STARTUP-READING]
evidence: "TYPE-REFERENCE-BOOK.1.2.22 executes startup35 acceptance; source epochs and original September6 diagnosis retained in docs/checkpoints/perl-literal-kinds/."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/perl-literal-kinds/publish.py; current: bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/callable_codeblock_literal_contract.t t/scalar_numeric_contract.t"
---

# Perl deferred literal fidelity

The September6 startup35 controls returned typed true/false directly and numeric1/0
through deferred literal bodies, including arrays; passed booleans stayed typed.
The AST retained kind=boolean. CodeblockRuntime returned native1/0 instead of
JSON::PP booleans. Original six controls, emitted-record diagnosis and old card
remain byte-exact in activation-inputs.json.gz and Git; they are dated history.

October24 repair22 reconstructs admitted ASCII decimal tokens using the parser's
0+source conversion and creates typed JSON booleans. A fresh substring avoids
retained conversion caches; absent/unsupported source records keep payload fallback.
The large fraction1000000000000000.5 previously lost its half in the serialized
numeric payload before reporting, while its source survived. Direct compiled
hexadecimal twins distinguish this from JSON display rounding.

Storable's installed public API changes whole-float kinds in both source and clone.
CodeblockRuntime now copies plain arrays/harrays by scalar assignment with memoized
aliases/cycles and callable origins; opaque references keep their existing fallback.
BindingRuntime classifies public SVf validity, not private SVp conversion caches.
An accepted-runtime native callback with computed-0.5 previously selected the tail;
its private integer cache was set but public integer validity was unset. Emitted and
compiled-argument controls rejected it. These are Perl5.34.1 measurements, not a
claim about every Perl release. Primary explanation: https://perldoc.perl.org/perlguts#What's-Really-Stored-in-an-SV?

Corrected37-program native/emitted proof observes kinds before final serialization,
including precision, fixed/rest/contextual calls, copied containers, typed writes,
source-less fallback and numeric/logical controls. Raw caches remain recorded.
Three first-after comparisons overconstrained private caches and earn no product
RED credit. The dated archive, physical faults/restorations and current permanent
consumer have separate roles. [[terse-primitive-literal-parity]] remains the typed
contract. No other-runtime parity or portable signed admission is inferred.
''')
    replace(PRIMITIVE,'title: "Typed primitive literal contract; Perl dynamic codeblock boolean coverage remains incomplete"','title: "Typed primitive literal contract; Perl deferred literal fidelity repaired"')
    replace(PRIMITIVE,'date: 2026-09-06','date: 2026-10-24')
    old='''## September 6 dynamic-codeblock qualification

The ordinary action controls still return typed JSON true/false. The dynamic CodeblockRuntime evaluator
instead returns numeric 1/0 for its boolean literal AST nodes, including nested array elements; a passed-in
boolean remains typed. [[perl-codeblock-boolean-literal-kind-drift]] preserves six public controls and the
emitted-record root cause. `SESSION-STARTUP-READING.35` owns repair without changing this typed-literal contract.
Rust and other runtime behavior were not remeasured by this reading checkpoint.'''
    new='''## Perl deferred literal repair (October24)

TYPE-REFERENCE-BOOK.1.2.22 closes startup35 on Perl: returned, assigned, nested,
fixed/rest and contextual literals preserve typed booleans. Admitted decimal source
reconstruction also preserves whole-float kind and numeric precision; typed copies
retain source kinds. [[perl-codeblock-boolean-literal-kind-drift]] owns the causal
facts and dated native/emitted evidence, including the original September6 defect.
Other-runtime parity is not remeasured or inferred by this repair.'''
    replace(PRIMITIVE,old,new)
    replace(PRIMITIVE,'the string contract and existing boolean repair remain unchanged.','the string contract remains unchanged; the later Perl boolean repair is described above.')
    replace(WRITE,'literal-kind intake: bash tools/run_python_project_data.sh docs/checkpoints/perl-literal-number-intake/read.py.','literal-kind repair: bash tools/run_python_project_data.sh docs/checkpoints/perl-literal-kinds/publish.py.')
    text=c.source(WRITE).read_text();i=text.index('Owned22: accepted/current native and emitted byte-shadow probes show\n')
    c.source(WRITE).write_text(text[:i]+'''Repair22 preserves whole-float/boolean literal kinds and large-fraction values
through deferred evaluation and typed copies. BindingRuntime uses public scalar
validity rather than lossy private integer caches, excluding computed fractional
selectors. [[perl-codeblock-boolean-literal-kind-drift]] owns source-bound causal
facts and actual before/after/fault controls. Existing signed/v1 authorities and
original17.2 observations stay unchanged; no other-backend admission is added.
''')
    replace(INVENTORY,'date: 2026-10-22','date: 2026-10-24')
    replace(INVENTORY,'  - "why did registered sorted pipelines lose function parameters"','  - "why did registered sorted pipelines lose function parameters"\n  - "why does a reused book renderer import the wrong document module"\n  - "when are private Storable integer caches unsafe for scalar kind checks"')
    replace(INVENTORY,'[[perl-numeric-reducer-string-result-kinds]]. Boolean35, Unicode20/constructor94\nremain separate.','[[perl-numeric-reducer-string-result-kinds]]. Boolean35 is repaired through22;\nUnicode20/constructor94 remain separate.')
    replace(INVENTORY,'kinds through clones/indexes; measure flags before Storable caches private float iOK.','kinds through clones/indexes. Literal22 distinguishes public validity from private\nStorable caches: [[perl-codeblock-boolean-literal-kind-drift]].')
    c.source(INVENTORY).write_text(c.source(INVENTORY).read_text()+'''\nBook proof reuse: a historical renderer prepended its own directory and caused\ndocument to resolve to its older module. Literal22 retains the pre-epoch setup\nfailure without product RED credit; preload local context and restore sys.path\nin finally when importing only pure render helpers.\n''')
    discussion='  DBIQNP clarification: The proposed plugin exposes structured LinkedSpec tools; ChatGPT/Codex interprets the conversation, calls those operations, and explains results. LinkedSpec need not parse chat. Director acknowledged this tool-API distinction and explicitly requested a deferred LinkedSpec integration task-tree (the FSMGen name was corrected). Create that planning-only tree at the next clean commit boundary; do not implement or reprioritize the integration. Official concept reference fetched: https://developers.openai.com/plugins/concepts/mcp-server. This remains discussion only.\n'
    text=c.source(TREE).read_text();start=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.22`');end=text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.17.3`',start)
    block=text[start:end].replace('Status: `in_progress`','Status: `done` / verified finite Perl repair',1)
    block=block.replace('Goal: Preserve authored whole-float and boolean literal kinds through deferred evaluation and assignment before continuing signed backend work.','Goal: Preserve deferred primitive kinds, numeric payloads and copied scalar validity before continuing signed backend work.')
    block=block.replace('Claim verification: none: Activation metadata only; source-bound before/after/falsification admission will be declared here before landing.','Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.22.json`')
    block=block.replace('  Reproduce:', '  Historical reproduction before22:').replace('  Root-cause verification:', '  Pre-repair root-cause verification:').replace('No producer repair/admission yet.', 'No producer repair/admission was claimed at that intake.').replace('  Schedule: P1', '  Original schedule: P1')
    block+='''  Completion: Corrected accepted47/74 RED becomes74/74 native/emitted GREEN, with28 complete callable roots. Eight required physical runtime inverses are RED and all nine restored consumers GREEN; the optional fresh-token diagnostic is reported as actually observed. Eleven compatibility suites reach784 roots: ten pass unchanged; the sole startup35 numeric expectation is corrected and the full affected10-root/1008-program suite passes. All431 source/id rows and immutable old generator stay exact. Book95 inputs/six native-emitted examples/three rendered denials, executed wrong selector and18 blank-only separators with all90 outputs byte/mode-identical pass. Actual input3/scope2 inverse/bypass/restoration and whole source epochs support the dated finite proof. The three original overstrict cache comparisons and pre-epoch import setup failure earn no product RED credit. Startup35 closes through this owner only; all signed/intake history and other runtime sources remain exact. Current tests/Knowledge/book/roadmaps align. Required exact canonical CI and normal hooks govern landing; no other-runtime/portable admission.
  - [x] **ADDRESSED (verified)** — typed booleans/whole floats, large fractional payloads, source/copy kinds, cached fractional selectors; actual old-source RED and restored controls.
  - [x] **NO REGRESSION** — complete callable and direct consumers; only the deliberately old boolean expectation changes. Exact staged canonical receipt is required before commit.
  - [x] **LOCKSTEP** — current teaching/examples, original anchor, Knowledge routes, existing issue35 and both roadmaps agree; historical proofs remain immutable.
'''+discussion+'\n'
    c.source(TREE).write_text(text[:start]+block+text[end:])
    replace(TREE,'| `TYPE-REFERENCE-BOOK.1.2.22` | `in_progress`','| `TYPE-REFERENCE-BOOK.1.2.22` | `done`')
    issue='docs/tasks/SESSION-STARTUP-READING.04-49.md';text=c.source(issue).read_text();start=text.index('- ID: `SESSION-STARTUP-READING.35`');end=text.index('- ID: ',start+5);block=text[start:end].replace('Status: `pending`','Status: `done` / repaired through TYPE-REFERENCE-BOOK.1.2.22',1)
    block=block.replace('  Verification: `pending` — `.3.2.34` public controls return true/false directly but 1/0 through cb() literals;\n    a true argument stays typed while a dynamic literal array returns [1,0], all without context errors.\n  Commit: `pending`','  Verification: Original September6 diagnosis is retained byte-exact in22 activation. Corrected native/emitted literals preserve returned/assigned/nested/fixed/rest/contextual booleans; integer/string/null, numeric/logical and direct-dependent controls pass. Complete current book renders and examples execute. Exact claim, original REDs, qualifications and canonical acceptance belong solely to TYPE-REFERENCE-BOOK.1.2.22; no other-runtime parity is claimed.\n  Commit: TYPE-REFERENCE-BOOK.1.2.22 - preserve Perl deferred literal kinds and precision; derive accepted identity from Git.')
    c.source(issue).write_text(text[:start]+block+text[end:])
    subprocess.run(['perl','tools/update_task_tree_index.pl','--tree','SESSION-STARTUP-READING'],cwd=c.ROOT,check=True)
    summary='Perl deferred literals preserve boolean/whole-float kinds and large-fraction payloads; typed copies retain source kinds, and private integer caches cannot admit fractional selectors. Corrected47/74 RED becomes74/74 GREEN, callable28; eight required runtime inverses/nine restored GREEN; compatibility11/784 with the single startup35 expectation corrected and affected10/1008 GREEN; book95/six examples/three denials; actual input3/scope2 controls. Finite Perl scope only.'
    for path in ('CHANGES.md','DEVELOPMENT_NOTES.md'):
        text=c.source(path).read_text();i=text.index('\n## ')
        note='\n## 2026-10-24 — TYPE-REFERENCE-BOOK.1.2.22 — Perl deferred literal fidelity\n\n'+summary+'\n\nDecimal reconstruction uses admitted source spelling, preserving legacy fallback for absent/unsupported records. Memoized plain-container copying avoids Storable source/copy kind changes; opaque fallback remains. BindingRuntime uses public SVf validity. The original private-cache oracle and import setup failure remain explicitly qualified, with no product RED credit. Existing startup35 closes through this owner; old signed and numeric producers/proofs remain unchanged. Current Knowledge and book explain actual behavior. Exact canonical CI/normal hooks govern the landing.\n'
        c.source(path).write_text(text[:i]+note+text[i:])
    text=c.source('LIVE_ACHIEVEMENT_STATUS.md').read_text();history=text[text.index('## History'):];recent=text.split('## Recent Completions\n\n',1)[1].split('\n## History',1)[0].strip().splitlines();recent=([f'- `TYPE-REFERENCE-BOOK.1.2.22` — {summary}']+recent)[:16]
    c.source('LIVE_ACHIEVEMENT_STATUS.md').write_text('# LIVE ACHIEVEMENT STATUS\n\n## Current Activity\n\nLiteral-kind22 closes the Perl primitive producer defects and existing startup35; Rust17.3 is next after clean Git and due hygiene. Other backends and portable admission remain owned.\n\n## Latest Completed Slice\n\nTYPE-REFERENCE-BOOK.1.2.22: '+summary+' Original failed candidates/instrument qualifications remain retained. Exact canonical CI, normal hooks and post-pointer checks govern landing.\n\n## Next Action\n\nFrom clean Git perform artifact hygiene if24h is due, then activate Rust signed-selector17.3. Continue17.4–7, last14/with16, grouped assignment19, raw-regex21/policy20 and complete inventory/reference work.\n\n## Recent Completions\n\n'+'\n'.join(recent)+'\n\n'+history)
    current='October24 current PNT activity: [TYPE-REFERENCE-BOOK](docs/tasks/TYPE-REFERENCE-BOOK.md) completes Perl literal-kind22 after signed17.2. '+summary+' Exact canonical CI and normal hooks govern landing; due hygiene then Rust17.3 and17.4–7 follow clean Git. Director rule: [-n] selects [size-n] only when size-n>=0; negative positions never create entries.'
    for path in ('ROADMAP.md','ROADMAP_V2.md'):
        text=c.source(path).read_text();lines=text.splitlines();index=next(i for i,line in enumerate(lines) if line.startswith('October24 current PNT activity:'));lines[index]=current
        index=next(i for i,line in enumerate(lines) if line.startswith('October24 type-reference work:'));lines[index]='October24 type-reference work: Deferred-write12, signed intake17.0, CLI17.8, neutral target17.1, Perl17.2 and literal-kind22 are complete. Rust/Dart/Julia/Lua and admission17.3–7, deferred last14/with16, grouped assignment19, raw-regex21 and policy20 precede complete operation/spelling inventory1.2.1, mapping1.2.2 and layout1.3. Full per-type references and structured-format campaign admission remain unclaimed.';c.source(path).write_text('\n'.join(lines)+'\n')
    text=c.source('docs/TASK_TREE.md').read_text();lines=text.splitlines();i=next(i for i,line in enumerate(lines) if line.startswith('Latest PNT slice:'));lines[i]='Latest PNT slice: TYPE-REFERENCE-BOOK.1.2.22 — '+summary+' Exact canonical CI and normal hooks govern landing; due hygiene then Rust17.3 follows clean Git.';i=next(i for i,line in enumerate(lines) if line.startswith('| `TYPE-REFERENCE-BOOK` |'));lines[i]='| `TYPE-REFERENCE-BOOK` | `active` / next .1.2.17.3 | `.spec documentation / per-type reference` | Perl signed17.2 and literal-kind22 complete; due hygiene then Rust/Dart/Julia/Lua17.3–6 and independent admission17.7 precede remaining gaps and complete references. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |';c.source('docs/TASK_TREE.md').write_text('\n'.join(lines)+'\n')
    c.source('MEMORY.md').write_text('''# MEMORY

- activation_commit: `3c8f69c88992d7d3aacccf701eecf602f6544e07` — clean literal-kind22 base; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.22` — preserve Perl deferred literal kinds and precision; exact canonical receipt and normal hooks govern landing.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.17.3`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean Git create/commit the explicitly requested deferred LinkedSpec tool-API planning tree, without activating implementation. Then check24h hygiene (last2026-10-23T16:47:31Z), complete due cleanup under its own leaf and activate Rust signed-selector17.3.22/35 are complete.
- in_flight_uncommitted: none; no required background work remains after the commit workflow.
- proof: docs/checkpoints/perl-literal-kinds/publish.py reviews37 programs/74 native-emitted observations, corrected47 RED/74 GREEN, complete callable28, eight required runtime faults/nine restored consumers, compatibility11/784 and corrected numeric10/1008, book95/six examples/three denials and actual input3/scope2 controls. Original failed candidates and cache/import qualifications remain retained. Frozen signed/intake/old numeric proof stays unchanged. This is finite Perl5.34.1 evidence; no other-runtime/portable admission.
- steering: [-n]=[size-n] when size-n>=0; negatives never create. Continue17.3–7,14/16/19/raw-regex21/policy20 and complete inventory/references. DBIQNP plugin proposal/structured tool-API clarification is retained in22 task-tree; no implementation priority change.
- limits: Other repositories/submodules read-only black boxes; all project data on-volume. No push until PNT exhausted. Every new slice owns fresh proof and a separate commit; never rerun sealed one-shot writers.
''')
    print('Knowledge/issue35/current roadmap/continuity prepared; publication and exact canonical acceptance still required.',flush=True)


def claim():
    path=c.ROOT/'docs/claims/TYPE-REFERENCE-BOOK.1.2.22.json'
    manifest=c.load('publication-inputs.json.gz')
    inputs=dict(manifest['inputs'])
    inputs[c.PREFIX+'publication-inputs.json.gz']=c.identity(c.PREFIX+'publication-inputs.json.gz')
    record=dict(version=1,owner=c.OWNER,claims=[dict(name='dated-perl-deferred-literal-fidelity',
        statement='At the recorded Perl5.34.1 source epochs based on3c8f69c88992d7d3aacccf701eecf602f6544e07, corrected37 public programs pass74 native/emitted observations with typed primitive kinds and preserved fractional payloads; the same consumer observes47 original failures.',
        scope='Dated finite Perl source/route, scalar-kind/precision/copy/cache/write/fallback and direct-consumer/book proof. Current permanent tests and canonical CI separately exercise current production. No exhaustive programs, other-runtime parity or portable admission.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh docs/checkpoints/perl-literal-kinds/publish.py',granularity='Each exact public source/route and scalar kind/value; complete consumer plans, conservative whole source epochs, physical faulty/restored runtime variants and complete rendered-book inputs.',result=json.dumps(manifest['result'],sort_keys=True)),
        falsify=dict(status='checked',hypothesis='Serialized numeric payloads, untyped booleans, Storable source/copy changes, private lossy caches or altered/omitted evidence could conceal incomplete literal fidelity.',oracle='Typed primitive/signed contracts; direct compiled/argument twins; observed raw/public flags and pre-report hexadecimal values; copied topology/effects/guards/fallback controls; physical runtime and inventory-validator inverses/restorations.',red_control='Corrected original47/74 RED versus74/74 GREEN; eight required runtime inverses, nine full restored consumers; optional fresh-token diagnostic reported as observed. Three original private-cache overconstraints and pre-epoch import failure earn no product RED. Three rendered denials/executed wrong selector and actual input3/scope2 physical inverse/bypass/restoration distinguish proof inputs and scope.'),
        durability=dict(status='checked',mode='live',inputs=[dict(path=name,sha256=item['sha256'],role='producer' if name.endswith(('.py','.pl','.sh')) else 'input') for name,item in sorted(inputs.items())]))])
    with path.open('x') as out:
        json.dump(record,out,separators=(',',':'));out.write('\n')
    print('Claim created from the actual sealed readonly result; no future CI outcome is included.',flush=True)


if __name__ == '__main__':
    assert len(sys.argv)==2
    {'prepare':prepare,'claim':claim}[sys.argv[1]]()
