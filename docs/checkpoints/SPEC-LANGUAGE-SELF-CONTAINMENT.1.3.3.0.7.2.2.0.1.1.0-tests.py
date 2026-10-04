"""Preserve complete actual provenance RED/GREEN command and TAP streams."""
from pathlib import Path
import hashlib
import importlib.util
import json
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-'
spec = importlib.util.spec_from_file_location('capture', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
mode = sys.argv[1]
assert mode in ('before','after')
test = 't/actionir_basic_regex_source_provenance.t'
command = ['prove','-v','-Iperl',test]
env = dict(os.environ,PERL5LIB='',PERL_HASH_SEED='0',PERL_PERTURB_KEYS='2')
if mode == 'before':
    env['LINKEDSPEC_BASIC_REGEX_BASELINE'] = '1'
else:
    env.pop('LINKEDSPEC_BASIC_REGEX_BASELINE',None)
result = subprocess.run(command,cwd=ROOT,env=env,capture_output=True)
record = {'mode':mode,'command':command,'baseline':env.get('LINKEDSPEC_BASIC_REGEX_BASELINE'),
          'test_path':test,'test_sha256':hashlib.sha256((ROOT/test).read_bytes()).hexdigest(),
          'exit':result.returncode,'stdout':capture.envelope(result.stdout),'stderr':capture.envelope(result.stderr)}
(ROOT/(PREFIX+'tests-'+mode+'.json')).write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({'mode':mode,'exit':result.returncode,'stdout_bytes':len(result.stdout),'stderr_bytes':len(result.stderr)}))
raise SystemExit(result.returncode)
