"""Read-only occurrence-order repair review; raw before/after evidence stays untouched."""
from pathlib import Path
import collections,copy,hashlib,json,re,subprocess
ROOT=Path(__file__).resolve().parents[2]
OWNER='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1'
PREFIX='docs/checkpoints/'+OWNER+'-'
BASE='5bbceb962cc5aa5fb071b86efa479178e0e25d32'
def require(ok,message):
 if not ok:raise ValueError(message)
def read(p):return (ROOT/p).read_bytes()
def digest(raw):return hashlib.sha256(raw).hexdigest()
def encode(obj):return json.dumps(obj,sort_keys=True,separators=(',',':'))
def bag(events):return collections.Counter(encode(e) for e in events)
def raw_row(row):
 require(row['exit']==0 and row['stderr']=='','producer exit/stderr')
 require(json.loads(row['stdout'])==row['observation'],'raw stdout correspondence')
def inspect(report,cases):
 require(len(report['rows'])==27 and len(cases)==9,'source population')
 require(report['seeds']==['0','1','2'] and report['perturbation']=='2','seed policy')
 grouped={};values={'raw_ambiguous':'other','raw_single':'inner'}
 readiness={'quoted':(0,0,3),'raw_ambiguous':(0,1,2),'raw_single':(0,1,0)}
 for row in report['rows']:
  raw_row(row);require(len(row['observation']['cases'])==1,'one source per process')
  o=row['observation']['cases'][0];case=next(c for c in cases if c['id']==o['id'])
  key=(o['id'],o['seed']);require(key not in grouped and o['seed'] in ('0','1','2') and o['perturb']=='2','unique case/seed')
  require(row['command']==['perl','-Iperl',PREFIX+'probe.pl',case['id']],'public command')
  require(o['source']==case['source'] and o['source_sha256']==digest(case['source'].encode()),'source identity')
  action=re.search(r'\bI\s*(\{.*\})\s*$',case['source'],re.S).group(1)
  require(o['action_probe_source']==action and o['ast']['source']==action,'typed source')
  for name in ('substitution','emitted'):require(o[name+'_sha256']==digest(o[name].encode()),name+' hash')
  require(o['fresh']['emitted_sha256']==o['emitted_sha256'],'fresh actual source')
  for carrier in ('native','fresh'):
   actual=o[carrier];require(actual['exception'] is None and actual['value']==case.get('expected',values.get(case['id'])),'carrier value/error')
   require(actual['stdout']=='','carrier output')
   if carrier=='fresh' and case['id']=='nested_raw_known':require('isn\'t numeric' in actual['stderr'] and 'Unquoted string "i"' in actual['stderr'],'known host warnings retained')
   else:require(actual['stderr']=='','unexpected carrier stderr')
  require(o['native']['context_error'] is None,'context failure')
  m=o['metadata'];events=m['canonical_action_ir_events']
  require((m['language_agnostic_action_ir_ready'],m['canonical_action_ir_fallback_count'],m['unresolved_helper_count'])==readiness.get(case['id'],(1,0,0)),'readiness owner boundary')
  require(m['canonical_action_ir_count']==len(events) and m['canonical_action_ir_hits']==dict(collections.Counter(e['kind'] for e in events)),'event counts')
  require(all(set(e)=={'args','contract_id','kind','raw','source'} for e in events),'event schema')
  grouped[key]=o
 require(set(grouped)=={(c['id'],seed) for c in cases for seed in ('0','1','2')},'complete source/seed coverage')
 return grouped

def check(red,green,cases,orders):
 require(red['mode']=='red' and green['mode']=='green','before/after modes')
 before=inspect(red,cases);after=inspect(green,cases)
 require(set(orders)=={c['id'] for c in cases},'independent order population')
 for key,o in after.items():
  old=before[key];events=o['metadata']['canonical_action_ir_events']
  require([e['raw'] for e in events]==orders[o['id']],'pending occurrence order '+o['id'])
  require(bag(events)==bag(old['metadata']['canonical_action_ir_events']),'canonical record population changed')
  for field in ('source','ast','substitution','dump','emitted','native'):
   require(o[field]==old[field],'measured '+field+' changed')
  a=copy.deepcopy(o['metadata']);b=copy.deepcopy(old['metadata']);a.pop('canonical_action_ir_events');b.pop('canonical_action_ir_events')
  require(a==b,'non-order metadata changed')
  a=copy.deepcopy(o['fresh']);b=copy.deepcopy(old['fresh'])
  if o['id']=='nested_raw_known':
   # Preserve both raw warning streams; eval identifiers are process diagnostics, not source identity.
   a.pop('stderr');b.pop('stderr')
  require(a==b,'fresh observations changed')
 for id in orders:
  rows=[o['metadata']['canonical_action_ir_events'] for (name,seed),o in after.items() if name==id]
  require(all(row==rows[0] for row in rows),'current full sequence differs across seeds')
 for seed in ('0','1','2'):
  require([e['raw'] for e in before[('repeated',seed)]['metadata']['canonical_action_ir_events']]!=orders['repeated'],'baseline A/B/A must be RED')
 return before,after

def check_tests(red,green):
 require(red['mode']=='red' and len(red['rows'])==1 and red['rows'][0]['exit']!=0,'observed queue RED')
 r=red['rows'][0]
 require('Failed 1/15 subtests' in r['stdout'] and 'not ok 1 - interleaved residual' in r['stdout'],'isolated original order failure')
 require(green['mode']=='green' and len(green['rows'])==11,'selected green suites')
 counts=[]
 for row in green['rows']:
  require(row['exit']==0 and row['command'][:3]==['prove','-v','-Iperl'],'test command/exit')
  match=re.search(r'Files=1, Tests=(\d+),',row['stdout'])
  require(match and 'Result: PASS' in row['stdout'],'complete TAP')
  counts.append({'path':row['command'][3],'tests':int(match.group(1))})
 require(counts[0]=={'path':'t/canonical_event_occurrence_order.t','tests':15},'permanent regression')
 return counts

def check_traces(report,after):
 require(len(report['rows'])==15,'current trace population')
 expected={'body_original':('source_span_missing',3),'repeated':('source_span_missing',5),'raw_ambiguous':('skip_ambiguous_unmatched_event',2),'raw_single':('unmatched_helper_event_rewritten',1),'quoted':('unmatched_helper_event_rewritten',1)}
 seen=set()
 for row in report['rows']:
  raw_row(row);o=row['observation'];key=(o['id'],o['seed']);require(key not in seen,'trace unique case/seed');seen.add(key)
  require(o['source']==after[key]['source'] and o['substitution']==after[key]['substitution'],'traced current source/lowering')
  decision,count=expected[o['id']]
  require(o['trace'].count('DECISION actionir:rewrite_pipeline:lower_action_code_from_canonical_ir:Top:'+decision+' => TAKEN')==count,'current consumer decision')
 require(seen=={(id,seed) for id in expected for seed in ('0','1','2')},'trace coverage')

def check_phase0(record):
 expected="my $result = do './t/canonical_event_occurrence_order.t';\ndie $@ if $@;\ndie \"queue regression did not load: $!\" unless defined $result;"
 require(record['command']==['perl','-Iperl','-e',expected],'exact recurring child')
 require(record['source']=='t/phase0_regression.t' and record['source_sha256']==digest(read(record['source'])),'recurring source identity')
 require(record['exit']==0 and record['stderr']=='' and re.search(r'^1\.\.15$',record['stdout'],re.M),'actual complete recurring TAP')

def changed(row,callback):
 callback(row['observation']);row['stdout']=json.dumps(row['observation'])
def rejects(label,callback):
 try:callback()
 except (ValueError,KeyError,StopIteration,IndexError):return label
 raise ValueError('control unexpectedly accepted: '+label)
def main():
 cases=json.loads(read(PREFIX+'cases.json'));orders=json.loads(read(PREFIX+'order-oracles.json'))
 red=json.loads(read(PREFIX+'red.json'));green=json.loads(read(PREFIX+'green.json'))
 redtests=json.loads(read(PREFIX+'red-tests.json'));tests=json.loads(read(PREFIX+'green-tests.json'));traces=json.loads(read(PREFIX+'trace.json'))
 before,after=check(red,green,cases,orders);counts=check_tests(redtests,tests);check_traces(traces,after)
 phase=json.loads(read(PREFIX+'phase0-check.json'));check_phase0(phase)
 governance=json.loads(read(PREFIX+'governance-check.json'))
 require(governance['result']=='PASS' and governance['exit']==0 and governance['prior_phase0_bytes_recovered'],'historical governance replay')
 require(governance['red']=='unreviewed signature-regression drift: t/phase0_regression.t','actual historical audit RED')
 require(governance['controls']['governance_mutations_by_source']['t/phase0_regression.t']==6,'actual Phase0 evolution controls')
 require(governance['failure_envelope_controls']==['base64','sha256','bytes'],'actual historical log envelope controls')
 require(json.loads(governance['stdout'])['audit_controls']==governance['controls'],'raw historical replay controls')
 for path,expected in governance['tracked_inputs'].items():require(digest(read(path))==expected,'historical governance input '+path)
 controls=[]
 mutations=[('wrong value',lambda o:o['native'].update(value='wrong')),
 ('missing occurrence',lambda o:o['metadata']['canonical_action_ir_events'].pop()),
 ('private field leaked',lambda o:o['metadata']['canonical_action_ir_events'][0].update(_exclusive_statement=1)),
 ('readiness changed',lambda o:o['metadata'].update(language_agnostic_action_ir_ready=0)),
 ('source changed',lambda o:o.update(source='Top:: I { return("other") }')),
 ('emitted input changed',lambda o:o['fresh'].update(emitted_sha256='0'*64)),
 ('ordered sequence reversed',lambda o:o['metadata']['canonical_action_ir_events'].reverse())]
 for label,mutation in mutations:
  broken=copy.deepcopy(green);changed(broken['rows'][0],lambda o:mutation(o['cases'][0]))
  controls.append(rejects(label,lambda:check(red,broken,cases,orders)))
 broken=copy.deepcopy(tests);broken['rows'][0]['exit']=1
 controls.append(rejects('failed TAP hidden',lambda:check_tests(redtests,broken)))
 broken=copy.deepcopy(traces);changed(broken['rows'][0],lambda o:o.update(trace=o['trace'].replace('source_span_missing','fake')))
 controls.append(rejects('consumer decision removed',lambda:check_traces(broken,after)))
 broken=copy.deepcopy(phase);broken['command'][3]='print 1'
 controls.append(rejects('recurring child replaced',lambda:check_phase0(broken)))
 require(read(PREFIX+'before.pm')==subprocess.check_output(['git','show',BASE+':perl/LinkedSpec/ActionIR/CanonicalEvents.pm'],cwd=ROOT),'exact before owner')
 require(read(PREFIX+'cases.json')==read('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0-cases.json'),'unchanged diagnosis sources')
 paths=set(subprocess.check_output(['git','ls-files','perl','specs'],cwd=ROOT,text=True).splitlines())
 paths.update(t['path'] for t in counts);paths.add('t/phase0_regression.t')
 paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob(OWNER+'-*') if p.name not in (OWNER+'-verification.json',OWNER+'-book-check.py',OWNER+'-book-check.json'))
 paths.update(['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm','tools/run_python_project_data.sh','tools/project_data_run.sh','tools/project_data_env.sh'])
 paths.update(governance['tracked_inputs'])
 for p in paths:
  if p.startswith(('perl/','specs/')) and p!='perl/LinkedSpec/ActionIR/CanonicalEvents.pm':
   require(read(p)==subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT),'unowned executable drift '+p)
 inputs={p:digest(read(p)) for p in sorted(paths)}
 permuting=[c['id'] for c in cases if len({encode(before[(c['id'],s)]['metadata']['canonical_action_ir_events']) for s in ('0','1','2')})>1]
 print(json.dumps({'owner':OWNER,'result':'PASS','activation':BASE,'sources':len(cases),'before_after_native_fresh':len(after),'observed_baseline_permuting_cases':permuting,'current_exact_seed_sequences':len(cases),'tests':counts,'test_total':sum(t['tests'] for t in counts),'controls':controls,'trace_observations':len(traces['rows']),'historical_phase0_controls':governance['controls']['governance_mutations_by_source']['t/phase0_regression.t'],'tracked_inputs':inputs,'limits':'Exact measured source/seed populations and unchanged consumers. Scan occurrence provenance, not global source order. Raw arrays/streams preserved; only known fresh raw warning eval-location identity is excluded from before/after equality, with warning classes checked on both sides. Exact historical Phase0 evolution preserves prior bytes; no fresh objective execution. No nested raw/quoted readiness repair, arbitrary overlap proof, backend admission or semantic runtime mutants.'},indent=2))
if __name__=='__main__':main()
