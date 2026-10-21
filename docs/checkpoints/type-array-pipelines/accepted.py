"""Observe the fixed final plan with the real accepted runtime, then restore it."""
import json
import subprocess
import common as c
import context
import oracle

def main():
    plan=c.load('cases3.json');current=c.read(c.SOURCE)
    raw=subprocess.check_output(['git','show',c.BASE+':'+c.SOURCE],cwd=c.ROOT)
    original=c.load('baseline-run.json.gz')['source'][c.SOURCE]
    assert raw==c.decode(original['base64'])
    extras=[p.relative_to(c.ROOT).as_posix() for p in (c.ROOT/c.PREFIX).rglob('*') if p.is_file() and '__pycache__' not in p.parts]
    saved=context.snapshot(extras)
    saved.update(plan=plan,current=current,accepted=original,producer=c.read(c.PREFIX+'accepted.py'),new_inputs={p:c.read(p) for p in extras if not p.endswith(('.gz','.part'))})
    c.write_new('accepted-inputs.json.gz',saved)
    try:
        (c.ROOT/c.SOURCE).write_bytes(raw)
        (c.ROOT/c.SOURCE).chmod(original['mode'])
        run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
        failures=oracle.failures(run,plan)
        loaded=json.loads(c.decode(run['stdout_base64']))['inc']['LinkedSpec/CodeblockRuntime.pm']
        assert (c.ROOT/c.SOURCE).resolve().samefile(loaded) and c.read(c.SOURCE)==original
        c.write_new('accepted-observed.json.gz',dict(run=run,failures=failures,loaded_source=c.read(c.SOURCE),loaded_path=Path(loaded).resolve().relative_to(c.ROOT).as_posix()))
    finally:
        (c.ROOT/c.SOURCE).write_bytes(c.decode(current['base64']))
        (c.ROOT/c.SOURCE).chmod(current['mode'])
    stable=c.unchanged(saved['inputs'])
    c.write_new('accepted-restoration.json',dict(source_restored=c.read(c.SOURCE)==current,inputs_restored=stable))
    assert stable and failures
    print('Actual accepted runtime:',len(failures),'RED;',len(plan['cases'])-len(failures),'controls; loaded bytes verified and restored')

from pathlib import Path
if __name__=='__main__':main()
