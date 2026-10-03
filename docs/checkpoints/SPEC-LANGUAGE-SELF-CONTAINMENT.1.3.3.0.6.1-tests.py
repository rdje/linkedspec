"""Capture complete selected TAP streams to stdout, including actual baseline RED."""
import argparse,json,os,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('mode',choices=('red','green'));args=p.parse_args()
tests=['t/canonical_event_occurrence_order.t']
if args.mode=='green': tests+=['t/trace_actionir_pipeline.t','t/noncurrent_helper_metadata.t','t/actionir_ast_parser.t','t/trace_actionir_method_lowering.t','t/generated_source_contract.t','t/codeblock_while_perl.t','t/recursive_observation_perl_contract.t','t/recognition_transaction_perl_contract.t','t/progressive_span_dispatch_perl_contract.t','t/staged_ast_enrichment_perl_contract.t']
rows=[]
for test in tests:
 cmd=['prove','-v','-Iperl',test]
 r=subprocess.run(cmd,cwd=ROOT,env=dict(os.environ,PERL5LIB='',LINKEDSPEC_EVENT_ORDER_BASELINE='1' if args.mode=='red' else ''),capture_output=True)
 rows.append({'command':cmd,'exit':r.returncode,'stdout':r.stdout.decode(),'stderr':r.stderr.decode()})
print(json.dumps({'mode':args.mode,'rows':rows},indent=2))
if args.mode=='green':raise SystemExit(any(r['exit'] for r in rows))
else:raise SystemExit(not all(r['exit'] for r in rows))
