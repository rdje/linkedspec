"""Execute the exact recurring queue child snippet; preserve complete raw TAP."""
from pathlib import Path
import hashlib,json,os,re,subprocess
root=Path(__file__).resolve().parents[2]
path='t/phase0_regression.t';source=(root/path).read_text()
match=re.search(r"subtest 'actionir_residual_occurrence_order_regression'.*?<<'PERL';\n(.*?)\nPERL\n",source,re.S)
assert match
command=['perl','-Iperl','-e',match.group(1)]
run=subprocess.run(command,cwd=root,env=dict(os.environ,PERL5LIB='',LINKEDSPEC_EVENT_ORDER_BASELINE=''),capture_output=True)
result={'source':path,'source_sha256':hashlib.sha256((root/path).read_bytes()).hexdigest(),'command':command,'exit':run.returncode,'stdout':run.stdout.decode(),'stderr':run.stderr.decode()}
print(json.dumps(result,indent=2))
raise SystemExit(run.returncode or not re.search(r'^1\.\.[1-9][0-9]*$',result['stdout'],re.M))
