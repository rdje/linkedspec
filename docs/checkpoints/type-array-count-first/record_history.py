"""Retain the complete recurring historical audit after the ten-line inverse admission."""
import json
import common as c
import context
from admit_phase0 import TABLE,DRIVER


def main():
    supplied = context.snapshot()
    c.write_new('history-final-inputs.json.gz',supplied)
    run = c.run(['bash','tools/run_python_project_data.sh',DRIVER])
    stable = c.unchanged(supplied['inputs'])
    c.write_new('history-final-run.json.gz',dict(run=run,inputs_unchanged=stable))
    assert stable and run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    value = json.loads(c.decode(run['stdout_base64']))
    old = json.loads(c.decode(c.load('focused-run.json.gz')['history']['stdout_base64']))
    prior = old['audit_controls']['governance_mutations_rejected']
    hunks = len(json.loads(c.source(TABLE).read_bytes())['hunks'])
    assert value['audit_controls']['governance_mutations_rejected'] == prior+3*hunks
    assert value['healthy_audit_guard'] == dict(original_log_attempts=0,tracked_write_attempts=0)
    assert value['tracked_inputs'][TABLE] == c.identity(TABLE)['sha256']
    c.write_new('history-final-result.json',dict(previous=prior,added=3*hunks,
        current=value['audit_controls']['governance_mutations_rejected'],hunks=hunks,
        scope='All original650 controls keep their original source stages; each of ten exact new guard lines adds absence/duplication/change. Historical recovery and actual read/write-denied boundaries stay intact. No historical runtime replay is claimed.'))
    print('Historical audit GREEN:',prior,'preserved +',3*hunks,'new =',prior+3*hunks,'actual denials')


if __name__ == '__main__':
    main()
