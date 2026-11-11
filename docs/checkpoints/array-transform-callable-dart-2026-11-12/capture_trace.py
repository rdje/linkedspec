"""One-shot original Dart four-route epoch with actual inputs before SDK use."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import traceback

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'trace'
OUT.mkdir()
PROBE = Path('dart/tool/trace_callable_array_transform_results.dart')
CONFIG = Path('dart/.dart_tool/package_config.json')
ACTIVATION = '5ac1fac5eb7126cd8f952858f8df194914884830'
custody = []
ENVIRONMENT = dict(TERM='dumb', NO_COLOR='1')


def freeze(tag, paths):
    files = {}
    for path in sorted(set(paths)):
        assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
        assert path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        files[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
    target = OUT / (tag + '-inputs.tar.gz')
    with tarfile.open(target, 'x:gz') as archive:
        for path in files:
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(target) as archive:
        assert len(archive.getnames()) == len(files) and set(archive.getnames()) == set(files)
        for member in archive:
            body = archive.extractfile(member).read()
            row = files[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    custody.append(dict(tag=tag, archive=str(target), files=files))
    (OUT / 'custody.json').write_text(json.dumps(custody, indent=2, sort_keys=True) + '\n')


def run(tag, arguments, cwd=Path('dart')):
    command = ['bash', os.path.relpath(ROOT / 'tools/run_dart_project_data.sh', ROOT / cwd), *arguments]
    (OUT / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd=str(cwd), environment=ENVIRONMENT), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT / cwd, env=dict(os.environ, **ENVIRONMENT), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, tag + ': actual failure retained'


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    ids = {'initial_number_composed', 'take_receiver_hash_guard', 'drop_logical_later_with', 'own_needed_source_take_receiver', 'own_scalar_bool_receiver_with', 'take_later_with', 'reverse_copy_later_with', 'source_effect_before_rejection', 'positive_slice_receiver_composed'}
    cases = [row for row in json.loads((BASE / 'cases.json').read_bytes()) if row['id'] in ids]
    assert len(cases) == len(ids) == 9
    (OUT / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
    paths = [Path(p) for p in subprocess.check_output(['git','ls-files','dart'],text=True).splitlines()]
    paths += [PROBE, Path('dart/tool/callable_array_transform_observation.dart'), BASE / 'capture_trace.py', BASE / 'cases.json', OUT / 'cases.json']
    paths += [Path('specs') / name for name in ('spec.spec','user_function_definition.spec','pplugin.spec')]
    paths += [Path('tools') / name for name in ('project_data_env.sh','project_data_run.sh','run_dart_project_data.sh')]
    if CONFIG.exists(): paths.append(CONFIG)
    freeze('root',paths)
    run('version',['--version'])
    run('resolution',['pub','get','--offline','--enforce-lockfile'])
    freeze('resolved',[Path('dart/pubspec.yaml'),Path('dart/pubspec.lock'),*Path('dart/.dart_tool').glob('*.json')])
    run('analysis',['analyze','--fatal-infos','--fatal-warnings',str(PROBE.relative_to('dart')),'tool/callable_array_transform_observation.dart'])
    run('trace',['run',str(PROBE.relative_to('dart')),str(OUT)])
    freeze('actual-traces',list(OUT.glob('*.trace.log'))+list((OUT/'inputs').glob('*.json')))
    for packet in custody:
        for name,row in packet['files'].items():
            if packet['tag']=='root' and name==str(CONFIG): continue
            assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==row['sha256'],name
    print('Nine public Dart parse/compile/runtime traced probes retained with full channels and immutable inputs')


try:
    main()
except BaseException:
    (OUT/'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(),mtime=0))
    raise
