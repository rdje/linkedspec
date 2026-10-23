"""Record actual healthy/semantic-change RED/restored containment-reader channels."""
import json
import common as c


def main():
    actor=c.read(c.PREFIX+'containment_review.py')
    command=['bash','tools/run_python_project_data.sh',c.PREFIX+'containment_review.py']
    healthy=c.run(command)
    fault=c.run(command+['--fault'])
    restored=c.run(command)
    c.write_new('containment-reader-runs.json.gz',dict(producer=c.read(c.PREFIX+'check_containment.py'),
        reader=actor,healthy=healthy,fault=fault,restored=restored,
        scope='Independent unchanged-input/output recovery and real Python AST oracle. A valid-Python epoch-name mutation is an observed reason-sensitive RED, without altering any source or old observation.'))
    assert healthy['returncode']==restored['returncode']==0
    assert not c.decode(healthy['stderr_base64']) and not c.decode(restored['stderr_base64'])
    assert json.loads(c.decode(healthy['stdout_base64']))==json.loads(c.decode(restored['stdout_base64']))
    assert fault['returncode']==1 and not c.decode(fault['stdout_base64'])
    assert c.decode(fault['stderr_base64']).decode().endswith('AssertionError: helper AST\n')
    assert c.read(c.PREFIX+'containment_review.py')==actor
    print('Containment PASS: whole unpublished outputs/60 inputs, EOF-only AST equality; actual semantic AST RED/restored GREEN')


if __name__=='__main__':
    main()
