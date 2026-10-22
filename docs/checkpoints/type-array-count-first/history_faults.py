"""Falsify the real inverse call and its byte-identity check, restoring both exact inputs."""
import json
import common as c
import context
from history_probe import AUDITOR,TABLE


def observe(stem):
    supplied = context.snapshot()
    c.write_new(stem+'-inputs.json.gz',supplied)
    run = c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'history_probe.py'])
    stable = c.unchanged(supplied['inputs'])
    c.write_new(stem+'-run.json.gz',dict(run=run,inputs_unchanged=stable))
    assert stable and not c.decode(run['stderr_base64'])
    value = json.loads(c.decode(run['stdout_base64']))
    assert all(identity == supplied['inputs'][path] for path,identity in value['identities'].items())
    assert run['returncode'] == (0 if value['completed'] else 1)
    return value


def restore(path,packet):
    c.source(path).write_bytes(c.decode(packet['base64']))
    c.source(path).chmod(packet['mode'])


def main():
    saved = {path:c.read(path) for path in (AUDITOR,TABLE)}
    runtime = {path:c.read(path) for path in c.SOURCES}
    c.write_new('history-faults-before.json.gz',dict(sources=saved,runtime=runtime,context=context.snapshot()))
    healthy = observe('history-unit-healthy')
    assert healthy['completed']
    text = c.decode(saved[AUDITOR]['base64']).decode()
    marker = '    current_hash = digest(contents)\n    contents = restore_count_first_regressions(source, contents)\n'
    assert text.count(marker) == 1
    try:
        c.source(AUDITOR).write_text(text.replace(marker,'    current_hash = digest(contents)\n',1))
        inverse_fault = observe('history-unit-inverse-fault')
    finally:
        restore(AUDITOR,saved[AUDITOR])
    inverse_restored = observe('history-unit-inverse-restored')
    assert not inverse_fault['completed'] and inverse_restored == healthy
    marker = 'require(digest(raw) == COUNT_FIRST_TABLE_SHA256,'
    assert text.count(marker) == 1
    try:
        c.source(TABLE).write_bytes(c.decode(saved[TABLE]['base64'])+b' ')
        table_red = observe('history-unit-table-red')
        assert not table_red['completed'] and 'count/first inverse table identity mismatch:' in table_red['error']
        try:
            c.source(AUDITOR).write_text(text.replace(marker,'require(True,',1))
            hash_fault = observe('history-unit-hash-fault')
        finally:
            restore(AUDITOR,saved[AUDITOR])
        hash_restored = observe('history-unit-hash-restored')
        assert hash_fault['completed'] and not hash_restored['completed']
        assert hash_restored['error'] == table_red['error']
    finally:
        restore(AUDITOR,saved[AUDITOR])
        restore(TABLE,saved[TABLE])
    restored = observe('history-unit-final')
    assert restored == healthy
    assert all(c.read(path) == packet for path,packet in {**saved,**runtime}.items())
    c.write_new('history-faults-result.json',dict(inverse_bypass_rejected=True,
        table_byte_change_rejected=True,actual_hash_bypass_admitted=True,
        restored_hash_rejected=True,sources_restored=True,
        scope='Actual inverse-call removal rejects current source; exact restoration passes. A semantically inert table byte rejects; actual hash-check bypass admits it; restored check rejects it again, then restored table returns the exact healthy observation. All runtime source bytes/modes stay unchanged.'))
    print('Historical inverse/source and table/hash faults reject/admit/restore exactly')


if __name__ == '__main__':
    main()
