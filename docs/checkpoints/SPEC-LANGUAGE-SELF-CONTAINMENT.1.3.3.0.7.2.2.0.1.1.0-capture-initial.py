"""Capture six exact sources over seeds0/1/2; preserve every process stream."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-'
spec = importlib.util.spec_from_file_location('streams', ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-capture.py')
streams = importlib.util.module_from_spec(spec)
spec.loader.exec_module(streams)
mode = sys.argv[1]
assert mode in ('before','after')
cases = json.loads((ROOT/(PREFIX+'cases.json')).read_bytes())
rows = []
for case in cases:
    for seed in (0,1,2):
        command = ['perl','-Iperl',PREFIX+'probe.pl',case['id']]
        env = dict(os.environ,PERL5LIB='',PERL_HASH_SEED=str(seed),PERL_PERTURB_KEYS='2')
        if mode == 'before':
            env['LINKEDSPEC_BASIC_REGEX_BASELINE'] = '1'
        else:
            env.pop('LINKEDSPEC_BASIC_REGEX_BASELINE',None)
        result = subprocess.run(command,cwd=ROOT,env=env,capture_output=True,timeout=120)
        rows.append({'id':case['id'],'seed':seed,'command':command,'exit':result.returncode,
                     'stdout':streams.envelope(result.stdout),'stderr':streams.envelope(result.stderr)})
        print(f'{mode}: {case["id"]} seed{seed} exit{result.returncode}',flush=True)
(ROOT/(PREFIX+mode+'.json')).write_text(json.dumps({'mode':mode,'cases':rows},indent=2)+'\n')
assert all(row['exit'] == 0 and not streams.unpack(row['stderr']) for row in rows)
print(f'PASS {len(rows)} complete {mode} probe processes')
