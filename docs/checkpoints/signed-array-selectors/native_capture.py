"""One-shot six-runtime public CLI survey, retaining actual SUT binary inputs."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import zlib
import common as c
import context

CHUNK_BYTES = 32 * 1024 * 1024 - 1024
JOURNAL = c.ROOT/'.linkedspec-data/verification/signed-index-native-events.jsonl'


def archive(path,stem):
    """Retain a byte-exact executable/native adapter in bounded gzip parts."""
    digest = hashlib.sha256()
    compressor = zlib.compressobj(level=6,wbits=31)
    pending = bytearray()
    parts = []
    size = 0
    def flush(final=False):
        while len(pending) >= CHUNK_BYTES or (final and pending):
            raw = bytes(pending[:CHUNK_BYTES])
            del pending[:len(raw)]
            name = stem+'-'+str(len(parts)+1).zfill(3)+'.part'
            target = c.ROOT/c.PREFIX/name
            with target.open('xb') as stream:
                stream.write(raw)
            parts.append(dict(path=c.PREFIX+name,**c.identity(c.PREFIX+name),bytes=len(raw)))
    with path.open('rb') as stream:
        for raw in iter(lambda:stream.read(1024*1024),b''):
            digest.update(raw)
            size += len(raw)
            pending.extend(compressor.compress(raw))
            flush()
    pending.extend(compressor.flush())
    flush(True)
    return dict(sha256=digest.hexdigest(),bytes=size,mode=path.stat().st_mode & 0o7777,
        parts=parts,encoding='gzip stream split into ordered bounded parts')


def event(value):
    # Save each completed command before continuing so interrupted surveys resume honestly.
    with JOURNAL.open('a') as stream:
        stream.write(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n')


def survey(name,command,env=None):
    rows = []
    for case in c.load('cases.json')['cases']:
        run = c.run(command+['--inline-spec',case['source'],'--input',case['input']],env=env)
        row = dict(id=case['id'],run=run)
        rows.append(row)
        event(dict(runtime=name,**row))
    c.write_new('native-'+name+'.json.gz',dict(runtime=name,rows=rows,
        scope='Actual public primary CLI observations; all exits and both channels are retained, including rejected current behavior. Requested values are comparison targets, not a success assertion.'))


def main():
    assert not JOURNAL.exists(), 'one-shot native journal already exists'
    JOURNAL.parent.mkdir(parents=True,exist_ok=True)
    epoch = context.snapshot()
    c.write_new('native-inputs.json.gz',dict(context=epoch,
        producer=c.read(c.PREFIX+'native_capture.py'),plan=c.read(c.PREFIX+'cases.json'),
        scope='Complete conservative regular main-repository source epoch before builds/probes. Owned CLI/native output inputs are additionally retained byte-exact in bounded parts. Installed SDKs, operating-system libraries and documented public dependency products are read-only prerequisites; no dependency implementation is inspected.'))
    versions = {name:c.run(command) for name,command in {
        'perl':['perl','-e','print $^V'], 'rustc':['rustc','--version'],
        'cargo':['cargo','--version'], 'dart':['dart','--version'],
        'julia':['bash','tools/run_julia_project_data.sh','--startup-file=no','--history-file=no','--version'],
        'puc':['lua','-v'],'luajit':['luajit','-v']}.items()}
    c.write_new('native-versions.json.gz',versions)
    assert all(run['returncode'] == 0 for run in versions.values())
    rust_build = c.run(['bash','tools/run_cargo_local.sh','build','--manifest-path','rust/Cargo.toml',
        '--locked','--offline','-p','linkedspec-runtime','--bin','linkedspec-rust'])
    c.write_new('native-rust-build.json.gz',rust_build)
    assert rust_build['returncode'] == 0
    target = Path(os.environ.get('CARGO_TARGET_DIR',str(c.ROOT/'rust/target')))
    if not target.is_absolute():
        target = c.ROOT/target
    binary = target/'debug/linkedspec-rust'
    relative_binary = binary.relative_to(c.ROOT).as_posix()
    assert binary.stat().st_dev == c.ROOT.stat().st_dev
    rust_artifact = archive(binary,'rust-cli')
    c.write_new('native-rust-artifact.json',rust_artifact)
    survey('perl',['perl','-Iperl','bin/linkedspec'])
    survey('rust',[relative_binary])
    assert c.identity(relative_binary) == {key:rust_artifact[key] for key in ('sha256','mode')}
    survey('dart',['bash','tools/run_dart_project_data.sh',
        '--packages=dart/.dart_tool/package_config.json','dart/bin/linkedspec_dart.dart'])
    # Read source directly instead of relying on a previous project compilation cache.
    survey('julia',['bash','tools/run_julia_project_data.sh','--project=julia',
        '--startup-file=no','--history-file=no','--compiled-modules=no','julia/bin/linkedspec_julia.jl'])
    for abi in ('puc','luajit'):
        with tempfile.TemporaryDirectory(prefix='signed-index-'+abi+'-',dir=os.environ['TMPDIR']) as folder:
            native = Path(folder)
            assert native.stat().st_dev == c.ROOT.stat().st_dev
            build = c.run(['bash','tools/build_lua_native.sh',abi,native.relative_to(c.ROOT).as_posix()])
            c.write_new('native-'+abi+'-build.json.gz',build)
            assert build['returncode'] == 0
            artifacts = {file.name:archive(file,abi+'-'+file.name.replace('.','-'))
                for file in sorted(native.glob('*.so'))}
            assert artifacts
            c.write_new('native-'+abi+'-artifacts.json',artifacts)
            env = dict(os.environ,LUA_CPATH=str(native/'?.so')+';;',
                LUA_PATH=str(c.ROOT/'lua/src/?.lua')+';'+str(c.ROOT/'lua/src/?/init.lua')+';;')
            survey(abi,['lua' if abi == 'puc' else 'luajit','lua/bin/linkedspec-lua'],env)
            for name,packet in artifacts.items():
                assert c.identity((native/name).relative_to(c.ROOT).as_posix()) == {
                    key:packet[key] for key in ('sha256','mode')}
    stable = c.unchanged(epoch['inputs'])
    c.write_new('native-completion.json.gz',dict(inputs_unchanged=stable,
        producer=c.read(c.PREFIX+'native_capture.py'),journal=c.read(JOURNAL.relative_to(c.ROOT).as_posix()),
        runtimes=['perl','rust','dart','julia','puc','luajit'],case_ids=[case['id'] for case in c.load('cases.json')['cases']],
        scope='Six runtime primary CLI routes, full actual channels and archived SUT executable/native-adapter inputs. No runtime source or frozen authority changed. Non-Perl independently emitted routes are not covered by this native survey and remain mandatory in the separately owned backend children.'))
    assert stable
    print('Native signed-index survey retained: six runtime routes x32 sources; inspect every observed channel before conclusions')


if __name__ == '__main__':
    main()
