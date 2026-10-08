"""Capture exact original/current owners with explicit private handoff overlays."""
from pathlib import Path
import importlib.util
import json
import os
import subprocess
import tempfile
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('capture.py')
REVISION = '32169d1282effa083a431b17b11c436fdd862771'
PUBLIC = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0-'
OWNERS = ['perl/LinkedSpec/ActionIR/'+p+'.pm' for p in ['SourceOrigins','Scanner','Diagnostics','CanonicalEvents','CanonicalEvents/Core','RewritePipeline']]
STREAM = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
TESTS = ['t/' + name + '.t' for name in (
    'actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_nested_block_source_spans', 'actionir_compiler_source_membership',
    'actionir_executable_source_membership', 'trace_emit_context_bridge')]
spec = importlib.util.spec_from_file_location('replacement_streams', ROOT / STREAM)
streams = importlib.util.module_from_spec(spec); spec.loader.exec_module(streams)


def environment(seed):
    reset = {'TMPDIR', 'TMP', 'TEMP', 'CARGO_HOME', 'CARGO_TARGET_DIR', 'PUB_CACHE',
             'JULIA_DEPOT_PATH', 'PYTHONPYCACHEPREFIX', 'MDBOOK_BUILD__BUILD_DIR'}
    env = {k: v for k, v in os.environ.items() if k not in reset and not k.startswith('LINKEDSPEC_')}
    env.update(PERL5LIB='', PERL5OPT='', PERL_PERTURB_KEYS='2', PERL_HASH_SEED=str(seed))
    return env


def main():
    epoch = sys.argv[1]
    assert epoch in ('before','after')
    output = PREFIX+epoch+'-'
    entries, excluded = [], []
    listing = subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT)
    for row in filter(None, listing.split(b'\0')):
        metadata, path = row.split(b'\t', 1); mode, kind, oid, size = metadata.split()
        if kind != b'blob' or mode not in (b'100644', b'100755'):
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
        else:
            entries.append({'path': path.decode(), 'mode': mode.decode(),
                            'oid': oid.decode(), 'bytes': int(size)})
    committed_count = len(entries)
    scratch = ROOT / '.linkedspec-data/scratch/private-source-handoff'; scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix='fixed-', dir=scratch)); assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            process.stdin.write((entry['oid'] + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
            raw = process.stdout.read(entry['bytes']); assert len(raw) == entry['bytes'] and process.stdout.read(1) == b'\n'
            target = tree / entry['path']; target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw); target.chmod(int(entry['mode'][-3:], 8)); entry['sha256'] = streams.sha(raw)
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    overlays = []
    overlay_paths = [str(Path(PREFIX+'origin-fixture.t').relative_to(ROOT))]
    if epoch == 'after': overlay_paths += OWNERS
    for relative in overlay_paths:
        raw = (ROOT / relative).read_bytes()
        original = next((e for e in entries if e['path']==relative), None)
        mode = original['mode'] if original else '100644'
        target = tree / relative; target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw); target.chmod(int(mode[-3:],8)); overlays.append(relative)
        entries = [e for e in entries if e['path'] != relative]
        entries.append({'path':relative,'mode':mode,'bytes':len(raw),'sha256':streams.sha(raw),'overlay':True})
    manifest = {'revision': REVISION, 'entries': entries, 'overlays': overlays,
                'regular_git_inputs': committed_count, 'epoch': epoch, 'excluded_metadata': excluded,
                'scope': 'Complete regular committed Git supplied superset plus one authored private-channel '
                         'fixture; after uses exactly six declared production overlays. Gitlinks/nonregular payloads excluded '
                         'without inspection. Not a minimal observed IO set.'}
    Path(output + 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'revision': REVISION, 'complete': False, 'runs': [], 'input_tree': tree.relative_to(ROOT).as_posix(),
              'instrument_sha256': streams.sha(Path(__file__).read_bytes()),
              'stream_instrument_sha256': streams.sha((ROOT / STREAM).read_bytes()),
              'host_scope': 'Necessary read-only OS/Perl/Python standard libraries; project data local/same-volume.'}
    cases = json.loads((ROOT / (PUBLIC + 'cases.json')).read_bytes())
    probe = PUBLIC+'probe.pl'
    fixture = Path(PREFIX + 'origin-fixture.t').relative_to(ROOT).as_posix()
    commands = [('public:' + case['id'], seed, ['perl', '-Iperl', probe, case['id']])
                for seed in (0, 1, 42) for case in cases]
    commands += [('private-origin-tap', 0, ['prove', '-v', '-Iperl', fixture]),
                 ('consumers', 0, ['prove', '-v', '-Iperl'] + TESTS)]
    for kind, seed, tail in commands:
        before = streams.verify_tree(tree, entries); command = ['bash', 'tools/project_data_run.sh'] + tail
        result = subprocess.run(command, cwd=tree, env=environment(seed), capture_output=True)
        report['runs'].append({'kind': kind, 'seed': seed, 'command': command, 'exit': result.returncode,
            'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
            'inputs_before': before, 'inputs_after': streams.verify_tree(tree, entries)})
        Path(output + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')
        print(kind, seed, result.returncode, flush=True)
    assert report['instrument_sha256'] == streams.sha(Path(__file__).read_bytes())
    report['complete'] = True
    Path(output + 'observations.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
