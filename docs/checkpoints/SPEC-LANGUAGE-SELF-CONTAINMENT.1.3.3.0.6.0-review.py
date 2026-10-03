"""Read-only diagnosis review. Never replace raw observations or historical writers."""
from pathlib import Path
import collections,copy,hashlib,json,re,subprocess
ROOT=Path(__file__).resolve().parents[2]
OWNER='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0'
PREFIX='docs/checkpoints/'+OWNER+'-'
BASE='bb615f387850fa74f7cbfa3c78b8cf4682373c16'
TESTS=('t/trace_actionir_pipeline.t','t/noncurrent_helper_metadata.t','t/actionir_ast_parser.t','t/trace_actionir_method_lowering.t')
def require(ok,message):
 if not ok: raise ValueError(message)
def read(path): return (ROOT/path).read_bytes()
def digest(value): return hashlib.sha256(value).hexdigest()
def encode(value): return json.dumps(value,sort_keys=True,separators=(',',':'))
def bag(events): return collections.Counter(encode(e) for e in events)
def raw_row(row):
 require(row['exit']==0 and row['stderr']=='','producer exit/stderr')
 require(json.loads(row['stdout'])==row['observation'],'raw stdout correspondence')
def check_observations(report,cases):
 require(report['seeds']==['0','1','2'] and report['perturbation']=='2','seed policy')
 require(len(report['rows'])==27 and len(cases)==9,'source/seed population')
 grouped={case['id']:[] for case in cases}
 expected_meta={'quoted':(0,0,3),'raw_ambiguous':(0,1,2),'raw_single':(0,1,0)}
 host_values={'raw_ambiguous':'other','raw_single':'inner'}
 for row in report['rows']:
  raw_row(row);require(len(row['observation']['cases'])==1,'one source per process')
  o=row['observation']['cases'][0];case=next(c for c in cases if c['id']==o['id'])
  require(row['command']==['perl','-Iperl',PREFIX+'probe.pl',case['id']],'public producer command')
  require(o['source']==case['source'] and o['source_sha256']==digest(case['source'].encode()),'authored source')
  require(o['seed'] in ('0','1','2') and o['perturb']=='2','process seed')
  action=re.search(r'\bI\s*(\{.*\})\s*$',case['source'],re.S).group(1)
  require(o['action_probe_source']==action and o['ast']['source']==action,'typed AST source')
  for field in ('substitution','emitted'):
   require(o[field+'_sha256']==digest(o[field].encode()),field+' bytes/hash')
  require(o['fresh']['emitted_sha256']==o['emitted_sha256'],'fresh actual emitted input')
  for carrier in ('native','fresh'):
   n=o[carrier]
   require(n['exception'] is None and n['value']==case.get('expected',host_values.get(case['id'])),'observed '+carrier+' value/error')
   require(n['stdout']=='','unexpected output')
   if carrier=='fresh' and case['id']=='nested_raw_known':
    require('Argument "i" isn' in n['stderr'] and 'isn\'t numeric' in n['stderr'],'retained host warnings')
   else: require(n['stderr']=='','unexpected stderr')
  require(o['native']['context_error'] is None,'native context failure')
  m=o['metadata'];events=m['canonical_action_ir_events']
  require(m['canonical_action_ir_count']==len(events),'event count')
  require(m['canonical_action_ir_hits']==dict(collections.Counter(e['kind'] for e in events)),'event kind counts')
  require((m['language_agnostic_action_ir_ready'],m['canonical_action_ir_fallback_count'],m['unresolved_helper_count'])==expected_meta.get(case['id'],(1,0,0)),'readiness/raw/unresolved boundary')
  require(all(set(e)=={'args','contract_id','kind','raw','source'} for e in events),'public event schema')
  grouped[case['id']].append(o)
 for id,rows in grouped.items():
  require(sorted(o['seed'] for o in rows)==['0','1','2'],'distinct controlled seeds')
  first=rows[0]
  for o in rows[1:]:
   for field in ('ast','substitution','dump','emitted'):
    require(o[field]==first[field],'current '+field+' drift')
   m=copy.deepcopy(o['metadata']);a=copy.deepcopy(first['metadata'])
   require(bag(m.pop('canonical_action_ir_events'))==bag(a.pop('canonical_action_ir_events')),'raw event multiset drift')
   require(m==a,'metadata excluding sequence drift')
 for id in ('nested_original','body_original','repeated','raw_ambiguous'):
  require(len({encode(o['metadata']['canonical_action_ir_events']) for o in grouped[id]})>1,'observed residual permutation '+id)
 repeated=grouped['repeated'][0]['metadata']
 require([e['raw'] for e in repeated['helper_action_ir_events'][:3]]==['return("a")','return("b")','return("a")'],'interleaved scanner occurrence oracle')
 require(sum(e['raw']=='return("a")' for e in repeated['canonical_action_ir_events'])==2,'duplicate occurrence preserved')
 quoted=grouped['quoted'][0]
 require(quoted['ast']['block']['statements'][0]['expr']['args'][0]['kind']=='string','quoted data typed literal')
 require(any(e['kind']=='IF' and e['raw']=='if(true)' for e in quoted['metadata']['canonical_action_ir_events']),'quoted false control retained')
 return grouped

def check_original(rows,cases):
 require(len(rows)==6,'original population')
 for id in ('nested','body'):
  source=next(c['source'] for c in cases if c['id']==id+'_original')
  selected=[r for r in rows if r['observation']['id']==id]
  require(sorted(r['observation']['seed'] for r in selected)==['0','1','2'],'original seeds')
  for r in selected:
   raw_row(r);o=r['observation'];require(o['source']==source,'exact original source')
   require(o['substitution_sha256']==digest(o['substitution'].encode()),'original substitution hash')
   require(r['command']==['perl','-Iperl','docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1-order.pl',id],'original public command')
  require(len({encode(r['observation']['metadata']['canonical_action_ir_events']) for r in selected})>1,'original permutation')
  require(len({r['observation']['substitution'] for r in selected})==1,'original stable substitution')

def check_trace(report,grouped):
 require(len(report['rows'])==15,'trace population')
 expected={'body_original':('source_span_missing',3),'repeated':('source_span_missing',5),'raw_ambiguous':('skip_ambiguous_unmatched_event',2),'raw_single':('unmatched_helper_event_rewritten',1),'quoted':('unmatched_helper_event_rewritten',1)}
 seen=[]
 for row in report['rows']:
  raw_row(row);o=row['observation'];seen.append((o['id'],o['seed']))
  require(row['command']==['perl','-Iperl',PREFIX+'trace.pl',o['id']],'trace facade command')
  control=next(v for v in grouped[o['id']] if v['seed']==o['seed'])
  require(o['source']==control['source'] and o['substitution']==control['substitution'],'actual traced substitution')
  require(o['substitution_sha256']==digest(o['substitution'].encode()),'trace source bytes')
  decision,count=expected[o['id']]
  require(o['trace'].count('DECISION actionir:rewrite_pipeline:lower_action_code_from_canonical_ir:Top:'+decision+' => TAKEN')==count,'actual consumer decision '+o['id'])
 require(sorted(seen)==sorted((id,seed) for id in expected for seed in ('0','1','2')),'trace case/seed coverage')

def check_tests(report):
 require(len(report['rows'])==len(TESTS),'complete selected suites')
 counts=[]
 for row,test in zip(report['rows'],TESTS):
  require(row['command']==['prove','-v','-Iperl',test] and row['exit']==0,'suite command/exit')
  match=re.search(r'Files=1, Tests=(\d+),',row['stdout'])
  require(match and 'Result: PASS' in row['stdout'],'complete TAP/count')
  counts.append({'path':test,'tests':int(match.group(1))})
 return counts

def change(row,callback):
 callback(row['observation']);row['stdout']=json.dumps(row['observation'])
def rejected(label,callback):
 try: callback()
 except (ValueError,KeyError,StopIteration,IndexError): return label
 raise ValueError('control unexpectedly accepted: '+label)

def main():
 cases=json.loads(read(PREFIX+'cases.json'));observations=json.loads(read(PREFIX+'observations.json'))
 original=json.loads(read(PREFIX+'original-order.json'));trace=json.loads(read(PREFIX+'trace.json'));tests=json.loads(read(PREFIX+'tests.json'))
 grouped=check_observations(observations,cases);check_original(original,cases);check_trace(trace,grouped);counts=check_tests(tests)
 controls=[]
 mutations=[('authored source',lambda o:o.update(source='Top:: I { return("different") }')),
 ('native value',lambda o:o['native'].update(value='wrong')),
 ('fresh actual emitted input',lambda o:o['fresh'].update(emitted_sha256='0'*64)),
 ('typed source',lambda o:o['ast'].update(source='{}')),
 ('raw readiness',lambda o:o['metadata'].update(language_agnostic_action_ir_ready=0)),
 ('missing occurrence',lambda o:o['metadata']['canonical_action_ir_events'].pop()),
 ('helper provenance',lambda o:o['metadata']['helper_action_ir_events'].reverse())]
 for label,mutation in mutations:
  broken=copy.deepcopy(observations);change(broken['rows'][0],lambda o:mutation(o['cases'][0]))
  controls.append(rejected(label,lambda:check_observations(broken,cases)))
 broken=copy.deepcopy(observations)
 for row in broken['rows'][1:3]:
  change(row,lambda o:o['cases'][0]['metadata'].update(canonical_action_ir_events=copy.deepcopy(observations['rows'][0]['observation']['cases'][0]['metadata']['canonical_action_ir_events'])))
 controls.append(rejected('permutation erased',lambda:check_observations(broken,cases)))
 broken=copy.deepcopy(trace);change(broken['rows'][0],lambda o:o.update(trace=o['trace'].replace('source_span_missing','missing_fake')))
 controls.append(rejected('consumer trace removed',lambda:check_trace(broken,grouped)))
 broken=copy.deepcopy(tests);broken['rows'][0]['exit']=1
 controls.append(rejected('nonzero suite exit',lambda:check_tests(broken)))
 paths=set(subprocess.check_output(['git','ls-files','perl','specs'],cwd=ROOT,text=True).splitlines())
 paths.update(TESTS)
 paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob(OWNER+'-*') if p.name not in (OWNER+'-verification.json',OWNER+'-book-check.json',OWNER+'-book-check.py'))
 paths.update(['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm','docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1-order.pl','tools/project_data_run.sh','tools/project_data_env.sh','tools/run_python_project_data.sh'])
 inputs={p:digest(read(p)) for p in sorted(paths)}
 for p in paths:
  if p.startswith(('perl/','specs/','t/')):
   require(read(p)==subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT),'diagnosis changed executable '+p)
 print(json.dumps({'owner':OWNER,'result':'PASS','activation':BASE,'sources':len(cases),'native_fresh_observations':len(observations['rows']),'initial_public_observations':len(original),'public_trace_observations':len(trace['rows']),'permuting_cases':['nested_original','body_original','repeated','raw_ambiguous'],'tests':counts,'test_total':sum(r['tests'] for r in counts),'controls':controls,'tracked_inputs':inputs,'limits':'Raw arrays/streams retained; event bags compare population only. Three controlled seeds are exact named observations, not a probability estimate or arbitrary overlap equivalence. No compiler repair, portable raw helper admission, semantic runtime mutant or full CI rerun.'},indent=2))
if __name__=='__main__': main()
