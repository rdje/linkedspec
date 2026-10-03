"""Capture selected unchanged suites as complete JSON-contained TAP streams."""
import json,os,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
rows=[]
for test in ('t/trace_actionir_pipeline.t','t/noncurrent_helper_metadata.t','t/actionir_ast_parser.t','t/trace_actionir_method_lowering.t'):
 cmd=['prove','-v','-Iperl',test]
 r=subprocess.run(cmd,cwd=ROOT,env=dict(os.environ,PERL5LIB=''),capture_output=True)
 rows.append({'command':cmd,'exit':r.returncode,'stdout':r.stdout.decode(),'stderr':r.stderr.decode()})
print(json.dumps({'rows':rows},indent=2))
raise SystemExit(any(r['exit'] for r in rows))
