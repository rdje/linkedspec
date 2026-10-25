"""Pass-through capture of the unchanged isolated historical recovery driver."""
from contextlib import redirect_stderr, redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import traceback
import admission_common as a

PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
AUDIT = 'tests/language-readiness/verify_objectives.py'
RECOVERY = 'tests/language-readiness/recover_objective_audit_inputs.py'
PRODUCER = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-archive.py'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, a.ROOT/path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def main():
    sources = {path: a.read(path) for path in [PROOF, AUDIT, RECOVERY, PRODUCER,
               a.PREFIX+'capture_historical.py', a.PREFIX+'admission_common.py']}
    a.save('historical-producer-inputs.json.gz', dict(sources=sources,
        scope='Actual unchanged recovery driver and current auditor execute in process. Pass-through readers retain exact bytes returned; original-log/tracked-write denial remains the original instrument. No historical runtime or capture writer is rerun.'))
    proof = module('signed_rust_historical_driver', PROOF)
    original_load = proof.load
    reads, isolated = {}, {}
    loaded = {}

    def observed(path, raw):
        name = Path(path).as_posix()
        if name.startswith('.linkedspec-data/'):
            # The archive already retains complete log streams. Keep isolated
            # read identities and suffixes instead of copying those streams.
            isolated[name] = dict(sha256=a.sha(raw), bytes=len(raw))
        else:
            packet = a.read(name)
            assert a.decode(packet['base64']) == raw, 'input changed during pass-through read'
            if name in reads:
                assert reads[name] == packet
            reads[name] = packet
        return raw

    def load(name, path):
        loaded[path] = a.read(path)
        result = original_load(name, path)
        if path == AUDIT:
            assert result.RUST_SIGNED_AFTER == a.identity(result.RUST_SIGNED_SOURCE)['sha256']
            delegate = result.read_relative

            def reader(name):
                return observed(name, delegate(name))

            result.read_relative = reader
        elif path == RECOVERY:
            delegate = result.read_input

            def reader(name):
                return observed(name, delegate(name))

            result.read_input = reader
        return result

    proof.load = load
    output, error = io.StringIO(), io.StringIO()
    status = 0
    with redirect_stdout(output), redirect_stderr(error):
        try:
            proof.main()
        except Exception:
            traceback.print_exc()
            status = 1
    stable = all(a.read(path) == packet for path, packet in sources.items())
    a.save('historical-read-inputs.json.gz', dict(files=reads, isolated_reads=isolated,
        loaded_sources=loaded,
        scope='Actual data returned by unaltered readers. Isolated log bytes remain recoverable from the observed immutable archive; their actual read hashes/sizes and scratch-relative paths are retained. All other actual file bytes/modes are complete. Accepted historical Git objects and installed Python/OS are read-only prerequisites.'))
    a.save('historical-run.json.gz', dict(returncode=status, stdout_base64=a.encode(output.getvalue().encode()),
        stderr_base64=a.encode(error.getvalue().encode()), producer_inputs_unchanged=stable,
        invocation='unchanged old proof.main() with pass-through read capture; actual original guards remain'))
    assert status == 0, error.getvalue()[-3000:]
    assert stable
    result = json.loads(output.getvalue())
    assert result['restored_inputs'] == 134 and result['restored_bytes'] == 84613241
    assert result['healthy_audit_guard'] == {'original_log_attempts': 0, 'tracked_write_attempts': 0}
    assert len(result['controls']) == 22
    assert result['audit_controls']['runtime_source_mutations_rejected'] == 3
    a.save('historical-result.json.gz', result)
    print('Historical recovery PASS: unchanged134/84613241/22; original guard0; exact runtime source admission/3 denials.')


if __name__ == '__main__':
    main()
