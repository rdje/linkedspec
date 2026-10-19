"""Lossless current knowledge routing under the unchanged collection limit."""
import ast
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-knowledge-route/'
SELF = PREFIX + 'route.py'
MANIFEST = PREFIX + 'manifest.json'
PIPELINE = 'docs/checkpoints/pipeline-scope/'
ARTIFACTS = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-artifacts/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.6.json'
PUB = PIPELINE + 'publish.py'
FINALIZER = PIPELINE + 'finalize-continuity.py'
MAP = 'KNOWLEDGE_MAP.md'
OLD_CARD = 'docs/knowledge/pipeline-checkpoint-artifact-transport.md'
CARD = 'docs/knowledge/project-root-evidence-filesystem-modes.md'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
decode = base64.b64decode


def artifact():
    sys.path.insert(0, str(ROOT / ARTIFACTS))
    import artifact as module
    return module


def load():
    value = json.loads((ROOT / MANIFEST).read_bytes())
    assert value['result'] == 'PASS' and decode(value['producer_base64']) == Path(__file__).read_bytes()
    claim = decode(value['claim_base64'])
    assert len(claim) == 117298 and sha(claim) == value['claim_sha256']
    bindings = json.loads(claim)['claims'][0]['durability']['inputs']
    assert len(bindings) == len(value['inputs']) == 696
    assert {item['path']: item['sha256'] for item in bindings} == {
        path: item['sha256'] for path, item in value['inputs'].items()}
    assert decode(json.loads(decode(value['preflight_base64']))['draft_base64']) == claim
    for path, item in value['before_overrides'].items():
        assert sha(decode(item['base64'])) == value['inputs'][path]['sha256']
    return value


def recover_before(manifest):
    values = {}
    for path, item in manifest['inputs'].items():
        if path in manifest['before_overrides']: value = decode(manifest['before_overrides'][path]['base64'])
        else: value = (ROOT / path).read_bytes()
        assert sha(value) == item['sha256'], ('complete696 before bytes', path)
        if path != OLD_CARD: assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
        values[path] = value
    return values


def replay_before(manifest):
    values = recover_before(manifest)
    a = artifact()
    original = json.loads(gzip.decompress(a.part_bytes(a.load_manifest())))
    with a.common().original_fixture(original) as (fixture, environment):
        for path, value in values.items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(value); target.chmod(manifest['inputs'][path]['mode'])
        (fixture / CLAIM).write_bytes(decode(manifest['claim_base64']))
        (fixture / CLAIM).chmod(manifest['claim_mode'])
        command = ['python3', PUB]
        run = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
        unchanged = all((fixture / path).read_bytes() == value and
                        (fixture / path).stat().st_mode & 0o7777 == manifest['inputs'][path]['mode']
                        for path, value in values.items())
        whole = (fixture / CLAIM).read_bytes() == decode(manifest['claim_base64']) and (
            (fixture / CLAIM).stat().st_mode & 0o7777 == manifest['claim_mode'])
        no_compatibility_copy = not (fixture / a.RAW).exists()
    return dict(command=command, returncode=run.returncode, stdout_base64=encode(run.stdout),
                stderr_base64=encode(run.stderr), all696_bytes_modes_unchanged=unchanged,
                whole_claim_mode_unchanged=whole, compatibility_copy_removed=no_compatibility_copy)


def current_inputs():
    return {path.relative_to(ROOT).as_posix() for path in (ROOT / PREFIX).iterdir() if path.is_file()} | {CARD}


def prepare():
    assert not (ROOT / MANIFEST).exists()
    claim_raw = (ROOT / CLAIM).read_bytes()
    bindings = json.loads(claim_raw)['claims'][0]['durability']['inputs']
    assert len(bindings) == 696 and len(claim_raw) == 117298
    preflight = (ROOT / (PIPELINE + 'publication-preflight.json')).read_bytes()
    assert decode(json.loads(preflight)['draft_base64']) == claim_raw
    inputs = {}
    for item in bindings:
        source = ROOT / item['path']
        assert source.is_file() and not source.is_symlink()
        assert sha(source.read_bytes()) == item['sha256']
        inputs[item['path']] = dict(sha256=item['sha256'], mode=source.stat().st_mode & 0o7777)
    overrides = {path: dict(base64=encode((ROOT / path).read_bytes()), mode=inputs[path]['mode'])
                 for path in (PUB, FINALIZER, MAP, CARD, OLD_CARD)}
    command = ['python3', PUB]
    baseline = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert baseline.returncode == 0 and not baseline.stderr
    assert baseline.stdout == b'Current pipeline publication PASS: 696 live inputs; 117298 bytes; original625+161 supplied\n'
    for path, item in inputs.items():
        assert sha((ROOT / path).read_bytes()) == item['sha256']
        assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    old = decode(overrides[OLD_CARD]['base64'])
    old_header, old_body = old.split(b'\n---\n', 1)
    question_lines = [line for line in old_header.splitlines() if line.startswith(b'  - "')]
    assert len(question_lines) == 3
    evidence = next(line for line in old_header.splitlines() if line.startswith(b'evidence: "'))
    evidence = evidence[len(b'evidence: "'):-1]
    header, body = decode(overrides[CARD]['base64']).split(b'\n---\n', 1)
    assert all(line not in header for line in question_lines)
    date_line = next(line for line in header.splitlines() if line.startswith(b'date:'))
    header = header.replace(date_line, b'\n'.join(question_lines) + b'\n' + date_line, 1)
    title = next(line for line in header.splitlines() if line.startswith(b'title:'))
    header = header.replace(title, b'title: Evidence preserves filesystem permissions, namespaces and artifact bytes', 1)
    body += '\n## Exact checkpoint artifact transport — October 19\n\n'.encode('utf-8') + evidence + b'\n' + old_body
    card = header + b'\n---\n' + body
    assert old_body in card and evidence in card and all(line in card for line in question_lines)
    total = sum(path.stat().st_size for path in (ROOT / 'docs/knowledge').rglob('*.md'))
    assert total == 8386562
    total += len(card) - len(decode(overrides[CARD]['base64'])) - len(old)
    assert total <= 8388608
    publisher = decode(overrides[PUB]['base64'])
    with_line = b'with _artifacts.materialized_original():\n'
    assert publisher.count(with_line) == 1
    setup = ("_route_spec = importlib.util.spec_from_file_location('_knowledge_route', ROOT / " + repr(SELF) + ")\n"
             "_route = importlib.util.module_from_spec(_route_spec)\n_route_spec.loader.exec_module(_route)\n")
    publisher = publisher.replace(with_line, setup.encode() + with_line)
    old_reader = repr(ARTIFACTS + 'review.py').encode()
    assert publisher.count(old_reader) == 1
    publisher = publisher.replace(old_reader, repr(PREFIX + 'review.py').encode())
    marker = b'    paths.update(_artifacts.current_inputs())\n'
    assert publisher.count(marker) == 1
    publisher = publisher.replace(marker, marker +
        b'    paths.discard(_artifacts.CARD)\n    paths.update(_route.current_inputs())\n')
    for before, after in [('1488', '1487'), ('1350', '1349'), ('8386562', str(total))]:
        publisher = publisher.replace(before.encode(), after.encode())
    publisher = publisher.replace(b'one new artifact card', b'artifact facts in the existing canonical card')
    finalizer = decode(overrides[FINALIZER]['base64'])
    for before, after in [('1488', '1487'), ('1350', '1349'), ('8386562', str(total))]:
        finalizer = finalizer.replace(before.encode(), after.encode())
    finalizer = finalizer.replace(b'tree += (\'\\n## Transport and input-closure acceptance',
                                  b'tree += (\'\\n## Knowledge routing acceptance')
    ast.parse(publisher, filename=PUB); ast.parse(finalizer, filename=FINALIZER)
    failure_path = '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-commit-attempt2.log'
    failure = (ROOT / failure_path).read_bytes()
    assert b'knowledge_cards exceeds control: files 1351/1350' in failure
    manifest = dict(version=1, result='PASS', producer_base64=encode(Path(__file__).read_bytes()),
        claim_base64=encode(claim_raw), claim_sha256=sha(claim_raw), claim_mode=(ROOT / CLAIM).stat().st_mode & 0o7777,
        preflight_base64=encode(preflight), inputs=inputs, before_overrides=overrides, knowledge_bytes=total,
        proposal={PUB: dict(base64=encode(publisher), mode=inputs[PUB]['mode']),
                  FINALIZER: dict(base64=encode(finalizer), mode=inputs[FINALIZER]['mode']),
                  CARD: dict(base64=encode(card), mode=inputs[CARD]['mode'])},
        baseline=dict(command=command, returncode=baseline.returncode, stdout_base64=encode(baseline.stdout), stderr_base64=encode(baseline.stderr)),
        original_gate_failure_base64=encode(failure), deleted_card=OLD_CARD,
        scope='Whole696/117298 draft and actual readonly baseline precede bound routing changes. '
              'Every before byte is recoverable through current unchanged files or exact before '
              'images, including the deleted new card. All three questions, complete artifact '
              'evidence and body move to the richer existing canonical card. No limit, registry, '
              'native observation, runtime source or book source changes.')
    (ROOT / MANIFEST).write_text(json.dumps(manifest, indent=1) + '\n')
    continuity = ROOT / (PIPELINE + 'continuity.json')
    assert continuity.is_file()
    with (ROOT / (PREFIX + 'previous-continuity.json.gz')).open('xb') as output:
        output.write(gzip.compress(continuity.read_bytes(), mtime=0))
    continuity.unlink()
    for path, item in manifest['proposal'].items(): (ROOT / path).write_bytes(decode(item['base64']))
    assert (ROOT / OLD_CARD).read_bytes() == old
    (ROOT / OLD_CARD).unlink()
    original = json.loads(gzip.decompress(artifact().part_bytes(artifact().load_manifest())))
    (ROOT / CLAIM).write_bytes(decode(original['claim_base64']))
    print('Knowledge canonical-home routing prepared; no budget change; bytes', total)


if __name__ == '__main__':
    assert sys.argv[1:] == ['--prepare']
    prepare()
