"""Reconfirm count/first through public tools on the actual clean accepted kind13."""
import gzip
import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-sort-copy-kinds'))
import common as c

BASE = 'a8bd8620a4e545b3e472561bfea90c656ab69923'


def save(name,value):
    raw = (json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with (ROOT/'.linkedspec-data/verification'/name).open('xb') as output:
        output.write(gzip.compress(raw,mtime=0))


def main():
    producer = c.read(Path(__file__).resolve().relative_to(ROOT).as_posix())
    status = c.run(['git','status','--porcelain'])
    assert status['returncode'] == 0 and not c.decode(status['stdout_base64'])
    assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip() == BASE
    prior_path = '.linkedspec-data/verification/type-count-first-prior.json.gz'
    prior = json.loads(gzip.decompress(c.source(prior_path).read_bytes()))
    assert prior['base'] == BASE and prior['baseline']['returncode'] == 0
    inputs = {path:c.identity(path) for path in prior['images']}
    assert all(inputs[path] == {key:item[key] for key in ('sha256','mode')}
        for path,item in prior['images'].items())
    intake = 'docs/checkpoints/type-array-pipelines/followup-confirmation.json.gz'
    plan = json.loads(gzip.decompress(c.source(intake).read_bytes()))['plan']
    run = c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    stable = c.unchanged(inputs)
    save('type-count-first-baseline-observed.json.gz',dict(base=BASE,producer=producer,
        prior=dict(path=prior_path,**c.identity(prior_path)),inputs=inputs,plan=plan,
        run=run,inputs_unchanged=stable,status=status))
    module_path = ROOT/'docs/checkpoints/type-array-pipelines/oracle.py'
    spec = importlib.util.spec_from_file_location('count_first_intake_oracle',module_path)
    oracle = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(oracle)
    failures = oracle.failures(run,plan)
    observed = json.loads(c.decode(run['stdout_base64']))
    loaded = {}
    for path in ['perl/LinkedSpec.pm']+c.SOURCES+['perl/LinkedSpec/CodeblockRuntime.pm']:
        key = path.removeprefix('perl/')
        assert Path(observed['inc'][key]).resolve() == ROOT/path
        loaded[path] = c.identity(path)
        assert loaded[path] == inputs[path]
    save('type-count-first-baseline.json.gz',dict(base=BASE,producer=producer,
        observation='type-count-first-baseline-observed.json.gz',failures=failures,
        loaded_sources=loaded,inputs_unchanged=stable,
        scope='Fresh descriptor/Get-dump/native/independently emitted observations on real clean accepted kind13. Exact prior four-case intake plan, old oracle and current public observer are committed inputs. Both ordinary results and both structured native/generated unknown-helper causes are independently checked. Every regular committed source and full mode stays unchanged; Gitlinks remain black boxes.'))
    assert stable and not failures,failures
    assert c.run(['git','status','--porcelain']) == status
    assert c.read(Path(__file__).resolve().relative_to(ROOT).as_posix()) == producer
    print('Accepted13 count/first baseline: two ordinary results, two typed deferred failures;',len(inputs),'full-mode inputs unchanged')


if __name__ == '__main__':
    main()
