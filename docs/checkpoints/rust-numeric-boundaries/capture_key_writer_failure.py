"""Retain the failed provisional writer before its syntax correction."""
import common as c

name=c.PREFIX+'correct_key_probe.py'
before=c.read(name)
fixture=c.read('tests/numeric-conversion/programs.json')
run=c.run(['bash','tools/run_python_project_data.sh',name])
c.save('key-writer-parse-failure.json.gz',dict(producer=before,
    runner=c.read(c.PREFIX+'capture_key_writer_failure.py'),run=run,
    fixture_unchanged=c.read('tests/numeric-conversion/programs.json')==fixture,
    scope='Initial correction writer fails during Python parsing, before any fixture/output write; no product test or claim credit.'))
assert run['returncode']!=0 and b'IndentationError' in c.decode(run['stderr_base64'])
assert c.read('tests/numeric-conversion/programs.json')==fixture
