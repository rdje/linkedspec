"""Publish the bounded staged source-origin repair and retained actual proof."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parents[2]
OWNER='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.1'
PREFIX='docs/checkpoints/'+OWNER+'-'
ORIGINAL='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0-'
REVISION='8a64493d96795ef7398926b508e07595d01ef26c'
PREVIOUS='docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0.json'
def digest(path): return hashlib.sha256((ROOT/path).read_bytes()).hexdigest()
def load(name): return json.loads((ROOT/(PREFIX+name+'.json')).read_bytes())
runtime,book,freeze,repair,before=[load(n) for n in ('verification','book-verification','freeze','book-control-repair','before-review')]
assert runtime['complete'] and book['complete'] and before['complete']
assert runtime['revision']==freeze['revision']==REVISION
assert runtime['regular_inputs']==before['regular_inputs']==4614
assert tuple(runtime[k] for k in ('runtime_overlays','fixture_replacements','owner_deltas','commands','contracts','cases','seeds','events','statement_frames','source_origins','compiler_cases','fixture_suites','fixture_groups'))==(0,1,1,10,7,22,3,42,63,8,4,10,1589)
assert runtime['original_red_groups']==[129,131,132,133,138] and before['original_red_groups']==runtime['original_red_groups']
assert len(runtime['controls'])==130 and all(c['observed']=='RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'],book['rendered_examples'],book['rendered_sections'],len(book['controls']),freeze['bound_inputs'])==(58,24,4,42,101)
assert all(c['rejected'] and c['reason'] for c in book['controls'])
for result,producer in ((runtime,'review.py'),(book,'book.py'),(freeze,'freeze.py'),(repair,'book-control-repair.py'),(before,'before-review.py')):
    assert result['instrument_sha256']==digest(PREFIX+producer), 'actual publication producer'
assert before['review_producer_sha256']==digest(PREFIX+'review.py')
assert repair['exit']==1 and (repair['literal_needles'],repair['escaped_needles'])==(1,0)
assert repair['before_sha256']==digest(PREFIX+'book-rejected-producer.py') and repair['after_sha256']==digest(PREFIX+'book.py')
old=(ROOT/(PREFIX+'book-rejected-producer.py')).read_bytes()
assert old.replace(b"b'&quot;unknown&quot;'",b"b'\"unknown\"'")==(ROOT/(PREFIX+'book.py')).read_bytes(), 'one actual rendered-needle repair'
expected=load('before-diagnosis-claim')
for claim in expected['claims']: claim['durability'].update(mode='historical',revision=REVISION)
assert json.loads((ROOT/PREVIOUS).read_bytes())==expected, 'mode/revision-only original claim freeze'
paths=[p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob(OWNER+'-*') if p.is_file()]
paths += [PREVIOUS, 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py']
paths += [ORIGINAL+n for n in ('cases.json','probe.pl','oracle.py','review.py','observations.json')]
paths += ['docs/knowledge/perl-staged-annotation-statement-origins.md','docs/knowledge/perl-dedicated-producer-source-diagnosis.md',
          'perl/LinkedSpec.pm','perl/LinkedSpec/ActionIR/Scanner.pm','perl/LinkedSpec/ActionIR/ScannerCore.pm',
          'perl/LinkedSpec/ActionIR/Contracts.pm','perl/LinkedSpec/ActionIR/MethodExpr.pm','perl/LinkedSpec/ActionIR/StatementSplit/Core.pm',
          'perl/LinkedSpec/ActionIR/StagedParseJob.pm','perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm','perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm',
          'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh']
paths += ['t/'+name+'.t' for name in ('staged_ast_enrichment_perl_contract','progressive_span_dispatch_perl_contract','recognition_transaction_perl_contract','recursive_observation_perl_contract','actionir_helper_source_provenance','actionir_statement_source_frames','actionir_ast_parser','canonical_event_occurrence_order','actionir_nested_block_source_spans','phase0_regression')]
paths += [e['path'] for e in load('book-inputs')['entries']]
inputs=[{'path':p,'sha256':digest(p),'role':'producer' if p.endswith(('.py','.pl','.pm','.t','.sh')) else 'input'} for p in sorted(set(paths))]
statement=('Immutable8a64493d9 supplies4614 regular original Git inputs, one declared recurring fixture replacement in both epochs and one staged producer delta after, with no extra runtime overlays. The original138-group fixture observes five expected RED groups before and all138 GREEN after. All seven original dedicated contracts/22 cases preserve42 events and63 physical frames per seed, adding only eight staged origins. Complete original public/private event, callback and four Toolbox compiler-construction channels remain exact under three seeds. Ten selected suites pass1589 groups including Phase01035;130 effective reason-specific evidence controls observe RED. Book58 inputs/24 examples/four chapters/42 RED and101 original hash-verified mode/revision-only diagnosis claim freeze pass. The initial ineffective book encoded-quote control is retained as actual RED and repaired against the one literal rendered needle.')
scope=('One private StagedParseJob annotation producer. Original literal event/argument and independently assembled Unicode-scalar intervals remain unchanged. The private sidecar retains original occurrences without altering public event fields, typed text plans, normalized options, invalid-event validation, exclusive ownership or lowering. Constructor event/argument identity and copied-array, foreign-source, changed-raw, fatal-callback and nested real recorder behavior are observed by the recurring fixture. The original probe measures actual dispatcher return identities, builds four Get parsers and captures full substitution, ActionIR descriptor metadata and parser-source output; it does not execute those four parsers. Selected consumers separately execute their covered routes once. Three sampled hash seeds and these controlled callbacks do not establish arbitrary host syntax or stochastic guarantees. Conservative complete supplied Git input population is not minimal observed IO; every original byte/object/mode/member is recoverable at '+REVISION+' through tracked manifests, while exact fixture/owner replacements bind their current tracked paths. Original full channels and previous claims remain retained. Book examples are rendered teaching, not extra runtime executions. Progressive/recognition origins and canonical family acceptance .1.5.2-.4, all-producer composition, executable quoted/comment membership, exact replacement, recognition token/effect/restoration/boolean-kind, progressive resource ceilings, marker lifetime, mark-copy observation and wrapper lifecycle repairs retain their recorded owners. Recovery/purge remain prohibited. No public/helper/serialized carrier/backend/admission/CI/storage/dependency change or historical runtime audit refresh. Read-only necessary OS/toolchain prerequisites remain external; all project data is repository-local; excluded Gitlink/nonregular metadata requires no implementation payload reads, RGX/PGEN remain black boxes and other Git repositories read-only.')
record={'version':1,'owner':OWNER,'claims':[{'name':'staged-annotation-original-statement-origins','statement':statement,'scope':scope,
'rederive':{'status':'checked','command':'; '.join('bash tools/run_python_project_data.sh '+PREFIX+n for n in ('capture.py before','capture.py after','before-review.py','review.py','freeze.py','book.py --review')),'granularity':'4614 original Git files; two controlled epochs/10 commands; seven contracts/22 cases/42 events/63 frames/eight staged origins per sampled seed;138-group RED/GREEN fixture/1589 consumer groups;58 book inputs/24 examples/four chapters;101 original hashes.','result':statement},
'falsify':{'status':'checked','hypothesis':'Missing or fabricated staged origins, swapped equal statement intervals, cloned equal references or truncated original callback/compiler/input/TAP channels could falsely appear to repair the dedicated producer.','oracle':'Unchanged independently authored original event/argument literals and assembled source intervals; full original diagnosis channels; actual dispatcher-returned references and constructor-reference fixture assertions; exact callback sequence/results, dedicated compiler nodes/constructors, complete immutable Git identities and ordered positive TAP/nested-failure rejection.','red_control':'Actual five original recurring fixture RED groups become GREEN after the one producer hook;130 effective reason-specific evidence mutations reject omitted events/origins, changed repeated intervals/source/arguments, fabricated origins in other producers, cloned references, lost callbacks/compiler nodes/constructors, missing/forged commands/exits/guards/instruments/channels/Git input declarations and shortened or hidden-failure TAP.42 rendered-book controls reject original/new teaching loss and failed or forged evidence; the initially ineffective encoded-quote mutation is preserved and corrected against actual HTML.'},
'durability':{'status':'checked','mode':'live','inputs':inputs}}]}
target=ROOT/('docs/claims/'+OWNER+'.json');target.write_text(json.dumps(record,indent=2)+'\n')
assert target.stat().st_size<=131072, 'bounded claim record'
print('Published staged source-origin repair with '+str(len(inputs))+' retained bindings')
