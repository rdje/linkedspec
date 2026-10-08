"""Capture actual built-in traces using a separate fixed input tree."""
from pathlib import Path
import copy
import importlib.util
import json
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('trace-capture.py')
spec = importlib.util.spec_from_file_location('replacement_capture', Path(PREFIX + 'capture.py'))
capture = importlib.util.module_from_spec(spec); spec.loader.exec_module(capture)
streams = capture.streams


def main():
    original = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    manifest = copy.deepcopy(original); entries = manifest['entries']
    scratch = ROOT / '.linkedspec-data/scratch/replacement-diagnosis'
    tree = Path(tempfile.mkdtemp(prefix='traces-', dir=scratch)); assert tree.stat().st_dev == ROOT.stat().st_dev
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for entry in entries:
            if entry.get('overlay'):
                raw = (ROOT / entry['path']).read_bytes()
            else:
                process.stdin.write((entry['oid'] + '\n').encode()); process.stdin.flush()
                assert process.stdout.readline().split() == [entry['oid'].encode(), b'blob', str(entry['bytes']).encode()]
                raw = process.stdout.read(entry['bytes']); assert process.stdout.read(1) == b'\n'
            assert len(raw) == entry['bytes'] and streams.sha(raw) == entry['sha256']
            target = tree / entry['path']; target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw); target.chmod(int(entry['mode'][-3:], 8))
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    probe = Path(PREFIX + 'trace.pl'); relative = probe.relative_to(ROOT).as_posix(); raw = probe.read_bytes()
    target = tree / relative; target.write_bytes(raw); target.chmod(0o644)
    assert relative not in {entry['path'] for entry in entries}
    entries.append({'path': relative, 'mode': '100644', 'bytes': len(raw), 'sha256': streams.sha(raw), 'overlay': True})
    manifest['overlays'].append(relative)
    Path(PREFIX + 'trace-inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    report = {'complete': False, 'revision': original['revision'], 'runs': [],
              'input_tree': tree.relative_to(ROOT).as_posix(),
              'producer_sha256': streams.sha(Path(__file__).read_bytes()),
              'capture_source_sha256': streams.sha(Path(PREFIX + 'capture.py').read_bytes())}
    for name in ('quoted_before', 'interleaved_equal', 'generated_data'):
        before = streams.verify_tree(tree, entries)
        command = ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', relative, name]
        result = subprocess.run(command, cwd=tree, env=capture.environment(0), capture_output=True)
        report['runs'].append({'id': name, 'seed': 0, 'command': command, 'exit': result.returncode,
            'stdout': streams.envelope(result.stdout), 'stderr': streams.envelope(result.stderr),
            'inputs_before': before, 'inputs_after': streams.verify_tree(tree, entries)})
        Path(PREFIX + 'traces.json').write_text(json.dumps(report, indent=2) + '\n')
        assert result.returncode == 0
        print('Actual built-in trace:', name, flush=True)
    report['complete'] = True
    Path(PREFIX + 'traces.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
