"""Recover rejected candidate inputs from reachable Git blobs and tracked overlays."""
from pathlib import Path
import importlib.util, json, subprocess, tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('recover.py')
REL = str(Path(PREFIX).relative_to(ROOT))
spec = importlib.util.spec_from_file_location('recovery_capture', PREFIX + 'corrected-capture.py')
capture = importlib.util.module_from_spec(spec); spec.loader.exec_module(capture)

def recover(manifest):
    assert manifest['revision'] == capture.REVISION
    scratch = ROOT / '.linkedspec-data/scratch/mapped-replacement'
    scratch.mkdir(parents=True, exist_ok=True)
    tree = Path(tempfile.mkdtemp(prefix='recovered-', dir=scratch))
    assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in manifest['entries']:
            path = entry['path']
            if entry.get('overlay'):
                source = REL + 'pipeline-candidate.pm' if path == 'perl/LinkedSpec/ActionIR/RewritePipeline.pm' else path
                raw = (ROOT / source).read_bytes()
            else:
                process.stdin.write((entry['oid'] + '\n').encode()); process.stdin.flush()
                assert process.stdout.readline().split() == [entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
                raw = process.stdout.read(entry['bytes'])
                assert process.stdout.read(1) == b'\n'
            assert len(raw) == entry['bytes'] and capture.streams.sha(raw) == entry['sha256'], 'actual recovered bytes ' + path
            target = tree / path; target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw); target.chmod(int(entry['mode'][-3:], 8))
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    capture.streams.verify_tree(tree, manifest['entries'])
    return tree

if __name__ == '__main__':
    manifest = json.loads(Path(PREFIX + 'corrected-after-inputs.json').read_bytes())
    tree = recover(manifest)
    result = dict(complete=True, producer_sha256=capture.streams.sha(Path(__file__).read_bytes()),
        manifest_sha256=capture.streams.sha(Path(PREFIX + 'corrected-after-inputs.json').read_bytes()),
        supplied_inputs=len(manifest['entries']), recovered_tree=tree.relative_to(ROOT).as_posix(),
        scope='Actual complete candidate regular-input graph recovers only from reachable immutable Git objects and exact tracked authored/candidate overlays. No prior ignored capture tree, dependency implementation or refreshed historical input is used. Final whole-tree bytes/modes verify.')
    Path(PREFIX + 'recovery.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))
