"""Retain pre-acceptance instrument failures without product mismatch credit."""
import common as c

cli=c.load('cli1-result.json.gz')
assert cli['programs']==107 and len(cli['runs'])==214 and len(cli['failures'])==76
assert cli['inputs_and_executable_unchanged']
assert all(row['run']['returncode']==1 and
    c.decode(row['run']['stderr_base64'])==b'linkedspec: parser invocation failed\n'
    for row in cli['failures'])
private=c.load('private1-build.json.gz')
assert private['returncode']!=0 and b"Required named parameter 'currentEdge'" in c.decode(private['stderr_base64'])
c.save('instrument-qualification.json.gz',dict(producer=c.read(c.PREFIX+'qualify_instruments.py'),
    cli_protocol=c.read('dart/lib/src/cli/primary_cli.dart'),
    cli_capture=c.read(c.PREFIX+'cli1-result.json.gz'),
    private_build=c.read(c.PREFIX+'private1-build.json.gz'),
    qualification='CLI1 expected detailed messages that the public primary CLI deliberately hides. '
        'All76 rejected observations instead have the correct stable generic invocation failure. '
        'CLI2 compares exact phase output/exit and routed trace separately; no typed CLI diagnostic claim. '
        'Private1 fails AOT compilation because two observer calls omit required currentEdge:null; '
        'it executes no runtime cases and earns no mismatch credit. Private2 supplies the parameter. '
        'Complete old instrument/copy inputs remain in their original epochs; production code is unchanged.'))
print('CLI1/private1 instrument qualifications retained.')
