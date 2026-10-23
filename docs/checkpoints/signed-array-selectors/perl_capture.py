"""Capture actual descriptor/Get/dump/fresh Perl channels before runtime edits."""
import common as c
import context


def main():
    epoch = context.snapshot()
    c.write_new('perl-inputs.json.gz',dict(context=epoch,
        producer=c.read(c.PREFIX+'perl_capture.py'),probe=c.read(c.PREFIX+'perl_probe.pl'),
        plan=c.read(c.PREFIX+'cases.json')))
    result = c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'perl_probe.pl'],
        input=c.source(c.PREFIX+'cases.json').read_bytes())
    stable = c.unchanged(epoch['inputs'])
    c.write_new('perl-baseline.json.gz',dict(run=result,inputs_unchanged=stable,
        scope='Exact current descriptor/Get-dump/native/fresh observations. Requested values are independent comparison targets, not accepted old-engine expectations. No runtime source changes.'))
    assert stable and result['returncode'] == 0
    assert not c.decode(result['stderr_base64'])
    print('Perl signed-index baseline retained; source unchanged; inspect observations before conclusions')


if __name__ == '__main__':
    main()
