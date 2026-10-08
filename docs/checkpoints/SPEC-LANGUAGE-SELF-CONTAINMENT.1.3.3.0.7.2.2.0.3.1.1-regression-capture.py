"""Distinguish rejected candidate residual failure using guarded full supplied copies."""
from pathlib import Path
import copy, importlib.util, json, subprocess, tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('regression-capture.py')
REL = str(Path(PREFIX).relative_to(ROOT))
spec = importlib.util.spec_from_file_location('candidate_capture', PREFIX + 'corrected-capture.py')
capture = importlib.util.module_from_spec(spec); spec.loader.exec_module(capture)
manifest = json.loads(Path(PREFIX + 'corrected-before-inputs.json').read_bytes())
report = json.loads(Path(PREFIX + 'corrected-before-observations.json').read_bytes())
original = ROOT / report['input_tree']
capture.streams.verify_tree(original, manifest['entries'])
result = dict(complete=False, revision=capture.REVISION,
              producer_sha256=capture.streams.sha(Path(__file__).read_bytes()),
              original_manifest_sha256=capture.streams.sha(Path(PREFIX + 'corrected-before-inputs.json').read_bytes()),
              runs=[], scope='Complete immutable regular Base6fe superset and three unchanged authored inputs plus exactly two regression probe/case overlays. Candidate epoch replaces only RewritePipeline with retained rejected source. Original and candidate run through the same Toolbox facade/AST/descriptor/dump/native/independent fresh probe. No production mutation; no broader Phase0 input identity claim.')
for epoch in ('original', 'candidate'):
    entries = copy.deepcopy(manifest['entries'])
    tree = Path(tempfile.mkdtemp(prefix='residual-', dir=ROOT / '.linkedspec-data/scratch/mapped-replacement'))
    assert tree.stat().st_dev == ROOT.stat().st_dev
    for entry in entries:
        target = tree / entry['path']; target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes((original / entry['path']).read_bytes()); target.chmod(int(entry['mode'][-3:], 8))
    overlays = [REL + 'regression-cases.json', REL + 'regression-probe.pl']
    if epoch == 'candidate': overlays += ['perl/LinkedSpec/ActionIR/RewritePipeline.pm']
    for path in overlays:
        source = REL + 'pipeline-candidate.pm' if path == 'perl/LinkedSpec/ActionIR/RewritePipeline.pm' else path
        raw = (ROOT / source).read_bytes(); target = tree / path
        target.parent.mkdir(parents=True, exist_ok=True); target.write_bytes(raw); target.chmod(0o644)
        entries = [e for e in entries if e['path'] != path]
        entries.append(dict(path=path, mode='100644', bytes=len(raw), sha256=capture.streams.sha(raw), overlay=True, recover_from=source))
    before = capture.streams.verify_tree(tree, entries)
    command = ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', REL + 'regression-probe.pl', 'nonempty_guard']
    process = subprocess.run(command, cwd=tree, env=capture.environment(0), capture_output=True)
    assert process.returncode == 0
    result['runs'].append(dict(epoch=epoch, input_tree=tree.relative_to(ROOT).as_posix(),
        supplied_entries=entries, overlays=overlays, inputs_before=before,
        inputs_after=capture.streams.verify_tree(tree, entries), command=command, exit=process.returncode,
        stdout=capture.streams.envelope(process.stdout), stderr=capture.streams.envelope(process.stderr)))
    Path(PREFIX + 'regression.json').write_text(json.dumps(result, indent=2) + '\n')
    print(epoch, 'complete guarded channels', flush=True)
result['complete'] = True
Path(PREFIX + 'regression.json').write_text(json.dumps(result, indent=2) + '\n')
