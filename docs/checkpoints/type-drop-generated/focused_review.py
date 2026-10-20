"""Accept the existing intentional receiver-copy TAP diagnostic, preserving it whole."""
import json
import re
import subprocess
import common as c


def verify():
    captured=c.load('focused-run.json.gz')
    assert captured['inputs_unchanged']
    tests,scanner=captured['tests'],captured['scanner']
    assert tests['returncode']==scanner['returncode']==0
    output=c.decode(tests['stdout_base64'])
    match=re.search(rb'Files=(\d+), Tests=(\d+),',output)
    assert match and (int(match[1]),int(match[2]))==(9,1322) and b'Result: PASS' in output
    stderr=c.decode(tests['stderr_base64'])
    prefix=b'# RECEIVER_COPY_OBSERVATIONS '
    assert stderr.startswith(prefix) and len(stderr.splitlines())==1 and stderr.endswith(b'\n')
    observed=json.loads(stderr[len(prefix):])
    assert observed['live_error'] is None and observed['live']==observed['standalone']
    assert observed['live_identity']==observed['standalone_identity']
    assert set(observed['live_identity'].values())=={1}
    sender='t/actionir_receiver_scalar_copy.t'
    assert (c.ROOT/sender).read_bytes()==subprocess.check_output(['git','show',c.BASE+':'+sender],cwd=c.ROOT)
    assert b"diag('RECEIVER_COPY_OBSERVATIONS '" in (c.ROOT/sender).read_bytes()
    assert not c.decode(scanner['stderr_base64'])
    assert b'0 positive; 69 classified' in c.decode(scanner['stdout_base64'])
    return dict(suites=9,assertions=1322,intentional_diagnostic_records=1,stderr_bytes=len(stderr),
        scope='All nine suites actually passed. The first focused actor rejected an existing explicit TAP '
              'diagnostic as if it were an unexpected compiler warning. Preserve its complete original '
              '18KB JSON payload; parse exactly its one marker line and reject all other stderr. The '
              'unchanged accepted test owns that protocol. Public value/FATAL routes still require silence.')


if __name__=='__main__':
    result=verify()
    c.write_new('focused-review.json.gz',dict(result=result,producer=c.read(c.PREFIX+'focused_review.py'),
        original_producer=c.read(c.PREFIX+'focused.py'),input_capture=c.read(c.PREFIX+'focused-inputs.json.gz'),
        run=c.read(c.PREFIX+'focused-run.json.gz')))
    print(json.dumps(result,sort_keys=True))
