"""Publish immutable dedicated-family proof; canonical CI is a separate receipt gate."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.4'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '7dc393211a12d54d5986c8f6a5462c25615ccbc4'
ORIGINAL = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0-'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3-'
PREVIOUS_CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3.json'

def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

def load(name):
    return json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())

runtime, book, freeze, manifest = [load(n) for n in ('verification','book-verification','freeze','inputs')]
assert runtime['complete'] and book['complete']
assert runtime['revision'] == manifest['revision'] == freeze['revision'] == REVISION
assert runtime['regular_inputs'] == len(manifest['entries']) == 4692 and manifest['overlays'] == []
assert tuple(runtime[k] for k in ('runtime_overlays','commands','contracts','cases','seeds','events',
                                 'statement_frames','source_origins','compiler_cases','fixture_suites',
                                 'fixture_groups')) == (0,4,7,22,3,42,63,42,4,12,636)
assert len(runtime['controls']) == 184 and all(c['observed']=='RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'],book['rendered_examples'],book['rendered_sections'],
        len(book['controls']),freeze['bound_inputs']) == (58,29,4,54,120)
assert all(c['rejected'] and c['reason'] for c in book['controls'])
for report, producer in ((runtime,'review.py'),(book,'book.py'),(freeze,'freeze.py')):
    assert report['instrument_sha256'] == digest(PREFIX+producer), 'actual publication producer'
expected = load('before-recognition-claim')
for claim in expected['claims']:
    claim['durability'].update(mode='historical',revision=REVISION)
assert json.loads((ROOT/PREVIOUS_CLAIM).read_bytes()) == expected, 'mode/revision-only historical freeze'
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob(OWNER+'-*') if p.is_file()]
paths += [ORIGINAL+n for n in ('cases.json','probe.pl','oracle.py','review.py','inventory.json')]
paths += [PREVIOUS+n for n in ('review.py','after-observations.json')]
paths += [PREVIOUS_CLAIM,'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py']
paths += ['docs/knowledge/'+n+'.md' for n in ('perl-dedicated-family-source-acceptance',
          'perl-recognition-annotation-statement-origins','perl-dedicated-producer-source-diagnosis',
          'perl-staged-annotation-statement-origins','perl-progressive-annotation-statement-origins',
          'project-root-evidence-filesystem-modes')]
paths += ['perl/LinkedSpec.pm','perl/LinkedSpec/ActionIR/Scanner.pm','perl/LinkedSpec/ActionIR/ScannerCore.pm',
          'perl/LinkedSpec/ActionIR/Contracts.pm','perl/LinkedSpec/ActionIR/MethodExpr.pm',
          'perl/LinkedSpec/ActionIR/StatementSplit/Core.pm','perl/LinkedSpec/ActionIR/StagedParseJob.pm',
          'perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm',
          'perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm',
          'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh']
paths += [e['path'] for e in load('book-inputs')['entries']]
paths += ['t/'+n+'.t' for n in ('staged_ast_enrichment_perl_contract','progressive_span_dispatch_perl_contract',
          'progressive_span_dispatch_perl_authority','recognition_transaction_perl_authority',
          'recognition_transaction_perl_contract','generated_source_contract','recursive_observation_perl_contract',
          'actionir_helper_source_provenance','actionir_statement_source_frames','actionir_ast_parser',
          'canonical_event_occurrence_order','actionir_nested_block_source_spans')]
inputs = [{'path':p,'sha256':digest(p),'role':'producer' if p.endswith(('.py','.pl','.pm','.t','.sh')) else 'input'}
          for p in sorted(set(paths))]
statement = ('Fresh immutable7dc393211 supplies4692 regular committed inputs/no overlays and four guarded '
             'commands. All seven original dedicated contracts retain22 cases/42 events/63 physical frames/'
             '42 origins per seed, actual dispatcher references and complete preceding compiler/callback/'
             'origin channels under seeds0/1/42. Twelve unchanged direct consumers pass636 ordered groups;'
             '184 effective reason-specific evidence controls observe RED. Book58 inputs/29 examples/four '
             'chapters/54 RED and120 original-hash mode/revision-only recognition freeze pass.')
scope = ('Complete original dedicated syntactic population in immutable '+REVISION+' with no runtime or '
         'fixture overlays, owner deltas or production/spec/test/contract/admission changes. Every supplied '
         'runtime byte/object/mode/member recovers from the declared Git revision and tracked manifest; '
         'the conservative supplied superset is not minimal observed IO. Original independently authored '
         'event/argument/scalar data and all previous full channels remain unchanged. The probe measures '
         'references at dispatcher return and builds four Get parsers with complete descriptor/substitution/'
         'source channels without executing those four parsers. Constructor identities and custom copied/'
         'foreign/transformed/fatal/nested cases remain recurring fixture observations. Selected consumers '
         'execute only their covered routes; three seeds do not establish arbitrary callbacks/hosts. '
         'Rendered teaching is not extra runtime execution. Required Phase0 runs in the exact staged '
         'canonical gate, independently required before this milestone/parent commit; this record does '
         'not publish a canonical CI measurement. All-producer composition, executable quoted/comment '
         'membership and precise replacement remain separate. Existing token order, effects/restoration/'
         'boolean-kind, resource ceilings, marker lifetime, mark-copy observation and wrapper-lifecycle '
         'repairs retain their owners; recovery/purge remain prohibited. No global audit refresh, new '
         'helper/public event, backend, CI/storage/dependency or other-repository change. OS/toolchain '
         'prerequisites are necessary read-only external inputs; all project data remains repository-local. '
         'Gitlink/nonregular payloads are excluded; RGX/PGEN remain black boxes.')
record = {'version':1,'owner':OWNER,'claims':[{
    'name':'complete-dedicated-family-immutable-recurrence','statement':statement,'scope':scope,
    'rederive':{'status':'checked','command':'; '.join('bash tools/run_python_project_data.sh '+PREFIX+n
                for n in ('capture.py','review.py','freeze.py','book.py --review')),
                'granularity':'4692 immutable inputs/0 overlays/4 commands;7 contracts/22 cases/3 seeds/'
                              '42 events/63 frames/42 origins/4 compiler-construction cases;12 suites/'
                              '636 groups;58 book inputs/29 examples/4 chapters;120 prior hashes.',
                'result':statement},
    'falsify':{'status':'checked','hypothesis':'Omitted or fabricated origins/events, paired equal raw by '
               'search, cloned references, altered compiler/callback channels or truncated input/TAP '
               'evidence could falsely accept the complete dedicated family.',
               'oracle':'Unchanged independent original event/argument/scalar fixtures and exact seven '
               'contract partition; actual dispatcher reference observations and constructor fixture '
               'assertions; full previous committed channels; immutable Git identities and complete '
               'ordered positive TAP with nested-failure rejection.',
               'red_control':'184 effective reason-specific RED controls lose each positive event/origin, '
               'swap repeated intervals/change origin arguments/source, falsify all seven contract '
               'references/arrays/callbacks, lose all four compiler node/constructor channels or change '
               'their full metadata/text, omit/forge commands/exits/guards/instruments/channels/Git '
               'members/black-box exclusions, invent runtime overlays and shorten/hide TAP failures. '
               '54 rendered-evidence controls reject lost examples/teaching/scope and forged/failed '
               'renders/guards/channels.'},
    'durability':{'status':'checked','mode':'live','inputs':inputs},
}]}
p=ROOT/('docs/claims/'+OWNER+'.json');p.write_text(json.dumps(record,indent=2)+'\n')
assert p.stat().st_size <= 131072
print('Published complete dedicated-family acceptance with '+str(len(inputs))+' retained bindings')
