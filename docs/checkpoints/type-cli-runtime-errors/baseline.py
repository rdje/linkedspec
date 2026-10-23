"""Retain actual unchanged CLI/library observations and permanent regression RED."""
import os
from pathlib import Path
import tempfile
import common as c
import context


def cli(case,traced=False):
    with tempfile.TemporaryDirectory(prefix='cli-runtime-',dir=os.environ['TMPDIR']) as directory:
        assert Path(directory).stat().st_dev == c.ROOT.stat().st_dev
        trace = Path(directory)/'trace.log'
        command = ['perl','-Iperl','bin/linkedspec','--inline-spec',case['source'],'--input',case['input']]
        if traced:
            command += ['--trace','low','--trace-file',str(trace),'--trace-mode','route','--trace-reset']
        return dict(run=c.run(command),trace=c.encode(trace.read_bytes()) if trace.exists() else None)


def main():
    epoch = context.snapshot()
    c.write_new('baseline-inputs.json.gz',dict(context=epoch,producer=c.read(c.PREFIX+'baseline.py'),
        probe=c.read(c.PREFIX+'perl_probe.pl'),plan=c.read(c.PREFIX+'cases.json')))
    result = dict(library=c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'perl_probe.pl'],
        input=c.source(c.PREFIX+'cases.json').read_bytes()),cli={})
    for case in c.load('cases.json')['cases']:
        result['cli'][case['id']] = dict(quiet=cli(case),routed=cli(case,True))
    result['permanent'] = c.run(['bash','tools/project_data_run.sh','prove','-Iperl','t/trace_cli.t'])
    result['inputs_unchanged'] = c.unchanged(epoch['inputs'])
    c.write_new('baseline.json.gz',result)
    assert result['inputs_unchanged'] and result['library']['returncode']==0
    assert result['permanent']['returncode']==1, 'permanent regression must distinguish the old CLI'
    print('Unchanged public library/18 CLI channels and actual permanent regression RED retained')


if __name__ == '__main__':
    main()
