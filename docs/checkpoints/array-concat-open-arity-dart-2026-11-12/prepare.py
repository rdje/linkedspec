"""Prepare own Dart source questions and public four-route acquisition tools."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '1753884257bed7ce0b842bc406c665671403a828'
OLD = Path('docs/checkpoints/array-transform-callable-dart-2026-11-12')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
paths = [
    Path('docs/checkpoints/array-concat-open-arity-selection-2026-11-12/cases.json'),
    OLD / 'cases.json',
    Path('tests/fixtures/array_transform_callable_result_guard_dart_profiles.json'),
    Path('docs/checkpoints/array-concat-open-arity-perl-2026-11-12/cases.json'),
    Path('tests/fixtures/array_transform_result_guard_dart_profiles.json'),
    Path('dart/tool/probe_callable_array_transform_results.dart'),
    Path('dart/tool/callable_array_transform_observation.dart'),
    OLD / 'capture_intake.py',
]
images, sources = {}, {}
for index, path in enumerate(paths):
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    image = BASE / ('template-' + str(index) + '.gz')
    image.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(image.read_bytes()) == body
    images[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
        mode=path.stat().st_mode & 0o777, image=str(image))
    sources[str(path)] = body
(BASE / 'template-identities.json').write_text(json.dumps(images, indent=2, sort_keys=True) + '\n')
allowed = ('id', 'body', 'source', 'input', 'rule', 'source_kind', 'array_count', 'form',
    'tail', 'empty', 'question', 'signature', 'paired_with')


def source_only(row, origin):
    result = {key: row[key] for key in allowed if key in row}
    result.update(origin=origin, profile_only=True)
    if 'expected_error' in row:
        result['question'] = 'needed-producer-error'
    assert not {'expected', 'expected_error', 'expected_observation', 'role'} & result.keys()
    return result


shared = json.loads(sources[str(paths[0])])
legacy = json.loads(sources[str(paths[1])])
questions = json.loads(sources[str(paths[3])])[396:]
assert (len(shared), len(legacy), len(questions)) == (84, 312, 108)
cases = [source_only(row, 'shared84') for row in shared]
cases += [source_only(row, 'legacy312') for row in legacy]
own = [source_only(row, 'questions108') for row in questions]
cases += own
ordinary = json.loads(sources[str(paths[4])])
tail = '.set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")}'
for form in ('free', 'receiver'):
    key = 'extra_concat_arrays_' + form
    source = ordinary[key]['source']
    assert source.count(tail) == 1
    for ending in ('terminal', 'composed'):
        cases.append(dict(id='ordinary_legacy_' + key + '_' + ending,
            source=source.replace(tail, '', 1) if ending == 'terminal' else source,
            input=ordinary[key]['input'], rule='Value', origin='ordinary4', legacy_id=key,
            form=form, tail=ending, question='legacy-ordinary-operand', profile_only=True))
assert len(cases) == len({row['id'] for row in cases}) == 508
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
(BASE / 'own-questions.json').write_text(json.dumps(own, indent=2) + '\n')

probe = sources[str(paths[5])].decode()
probe = probe.replace('CALLABLE_TRANSFORM_DART', 'ARRAY_CONCAT_DART')
probe = probe.replace('array_transform_callable_dart_fresh', 'array_concat_open_arity_dart_fresh')
anchor = "      final emitted = emitDartSourceV2(\n"
assert probe.count(anchor) == 1
identity = '''      final identityPrefix = switch (row['origin']) {
        'legacy312' => 'array-transform-callable-result-guard',
        'ordinary4' => 'array-transform-result-guard',
        _ => 'array-concat-open-arity-result-guard',
      };
'''
probe = probe.replace(anchor, identity + anchor, 1)
probe = probe.replace("'array-transform-callable-result-guard/$id.spec'", "'$identityPrefix/$id.spec'")
probe = probe.replace("'array-transform-callable-result-guard-assessment.spec'", "'$identityPrefix-assessment.spec'")
target = Path('dart/tool/probe_open_arity_array_concat_results.dart')
assert not target.exists()
target.write_text(probe)
(BASE / 'probe-before-format.dart.gz').write_bytes(gzip.compress(target.read_bytes(), mtime=0))

capture = sources[str(paths[7])].decode()
capture = capture.replace('import os\n', 'import os\nimport re\n')
capture = capture.replace('5ac1fac5eb7126cd8f952858f8df194914884830', ACTIVATION)
capture = capture.replace('probe_callable_array_transform_results.dart', target.name)
capture = capture.replace('array_transform_callable_dart_fresh', 'array_concat_open_arity_dart_fresh')
capture = capture.replace('== 312', '== 508').replace('Original312', 'Independent508')
start = capture.index('    paths += [PROBE,')
end = capture.index("    paths += [Path('specs')", start)
capture = capture[:start] + "    paths += [PROBE, Path('dart/tool/callable_array_transform_observation.dart')]\n    paths += [p for p in BASE.iterdir() if p.is_file()]\n" + capture[end:]
anchor = "    (OUT / 'activation.txt').write_text(ACTIVATION + '\\n')\n"
assert capture.count(anchor) == 1
memory = '''    command = ['bash', 'tools/project_data_run.sh', 'memory_pressure']
    (OUT / 'memory-command.json').write_text(json.dumps(dict(argv=command, cwd='.', environment=ENVIRONMENT), indent=2) + '\\n')
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, **ENVIRONMENT), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / ('memory-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / 'memory-exit.txt').write_text(str(result.returncode) + '\\n')
    free = re.search(rb'System-wide memory free percentage: (\\d+)%', result.stdout)
    assert result.returncode == 0 and free and int(free[1]) >= 45, 'Need conservative shared24GiB headroom before serial Dart work'
'''
capture = capture.replace(anchor, anchor + memory, 1)
compile(capture, 'capture_intake.py', 'exec')
(BASE / 'capture_intake.py').write_text(capture)

command = ['bash', 'tools/run_dart_project_data.sh', 'format', str(target)]
(BASE / 'probe-format-command.json').write_text(json.dumps(dict(argv=command, cwd='.',
    input_bytes=len(probe.encode()), input_sha256=hashlib.sha256(probe.encode()).hexdigest()), indent=2) + '\n')
result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('probe-format-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'probe-format-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0, 'Actual formatter failure retained'
print('Prepared own508 source-only questions: shared84/Dart legacy312/new108/four exact ordinary controls. Dart outcomes unacquired; no interpreter change')
