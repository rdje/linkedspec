"""Pass-through custody for the unchanged isolated recovery driver."""
from contextlib import redirect_stderr, redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import traceback
import common as c

PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
AUDIT = 'tests/language-readiness/verify_objectives.py'
RECOVERY = 'tests/language-readiness/recover_objective_audit_inputs.py'
PRODUCER = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-archive.py'


def module(name,path):
    spec = importlib.util.spec_from_file_location(name,c.ROOT/path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def main():
    sources = {path:c.read(path) for path in [PROOF,AUDIT,RECOVERY,PRODUCER,
        c.PREFIX+'capture_history.py',c.PREFIX+'common.py']}
    c.save('history-producer-inputs.json.gz',dict(sources=sources,
        scope='Unchanged recovery driver/current numeric auditor execute in process. '
            'Pass-through readers retain actual returned bytes; original-log and '
            'tracked-write denials stay unchanged. No old capture writer/runtime is rerun.'))
    proof = module('numeric_history_driver',PROOF)
    original_load = proof.load
    reads, isolated, loaded = {}, {}, {}

    def observed(path,raw):
        name = Path(path).as_posix()
        if name.startswith('.linkedspec-data/'):
            isolated[name] = dict(sha256=c.sha(raw),bytes=len(raw))
        else:
            packet = c.read(name)
            assert c.decode(packet['base64'])==raw
            assert name not in reads or reads[name]==packet
            reads[name]=packet
        return raw

    def load(name,path):
        loaded[path]=c.read(path)
        result=original_load(name,path)
        if path==AUDIT:
            for source,(_,_,accepted) in result.RUST_NUMERIC_IMAGES.items():
                assert c.identity(source)['sha256']==accepted
            delegate=result.read_relative
            result.read_relative=lambda name:observed(name,delegate(name))
        elif path==RECOVERY:
            delegate=result.read_input
            result.read_input=lambda name:observed(name,delegate(name))
        return result

    proof.load=load
    output,error=io.StringIO(),io.StringIO()
    status=0
    with redirect_stdout(output),redirect_stderr(error):
        try:
            proof.main()
        except Exception:
            traceback.print_exc()
            status=1
    stable=all(c.read(path)==packet for path,packet in sources.items())
    c.save('history-read-inputs.json.gz',dict(files=reads,isolated_reads=isolated,
        loaded_sources=loaded,
        scope='Actual non-log reads retain full bytes/modes. Isolated log bytes '
            'remain in the actual immutable archive with observed read hashes/sizes. '
            'Original accepted Git objects and installed Python/OS are read-only prerequisites.'))
    c.save('history-run.json.gz',dict(returncode=status,
        stdout_base64=c.encode(output.getvalue().encode()),
        stderr_base64=c.encode(error.getvalue().encode()),producer_inputs_unchanged=stable))
    assert status==0,error.getvalue()[-4000:]
    assert stable
    result=json.loads(output.getvalue())
    assert result['restored_inputs']==134 and result['restored_bytes']==84613241
    assert result['healthy_audit_guard']==dict(original_log_attempts=0,tracked_write_attempts=0)
    assert len(result['controls'])==22
    assert result['audit_controls']['runtime_source_mutations_rejected']==6
    updates=result['audit_report']['runtime_source_updates']
    assert len(updates)==2 and all(row['owner']==c.OWNER for row in updates)
    c.save('history-result.json.gz',result)
    print('Unchanged historical recovery134/84613241/22 passes; two exact numeric images/six denials.')


if __name__ == '__main__':
    main()
