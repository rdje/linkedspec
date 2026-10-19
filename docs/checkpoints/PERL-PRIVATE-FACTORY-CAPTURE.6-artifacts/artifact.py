"""Exact bounded artifact parts and readonly recovery of the complete669 draft."""
import ast
import base64
import contextlib
import gzip
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/pipeline-scope/'
HOME = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-artifacts/'
SELF = HOME + 'artifact.py'
MANIFEST = HOME + 'manifest.json'
RAW = PREFIX + 'preserved.json.gz'
PUB = PREFIX + 'publish.py'
FINALIZER = PREFIX + 'finalize-continuity.py'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.6.json'
WORKFLOW = 'docs/linkedspec-book/src/development/documentation-workflow.md'
MAP = 'KNOWLEDGE_MAP.md'
CARD = 'docs/knowledge/pipeline-checkpoint-artifact-transport.md'
PART_BYTES = 32 * 1024 * 1024
GITHUB_BYTES = 100 * 1024 * 1024
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
decode = base64.b64decode


def common():
    sys.path.insert(0, str(ROOT / PREFIX))
    import common_final
    return common_final


def load_manifest():
    value = json.loads((ROOT / MANIFEST).read_bytes())
    assert value['result'] == 'PASS' and decode(value['producer_base64']) == Path(__file__).read_bytes()
    claim_raw = decode(value['claim_base64'])
    assert len(claim_raw) == 112095 and sha(claim_raw) == value['claim_sha256']
    bindings = json.loads(claim_raw)['claims'][0]['durability']['inputs']
    assert len(bindings) == len(value['inputs']) == 669
    assert {item['path']: item['sha256'] for item in bindings} == {
        path: item['sha256'] for path, item in value['inputs'].items()}
    assert decode(json.loads(decode(value['preflight_base64']))['draft_base64']) == claim_raw
    previous = json.loads(gzip.decompress((ROOT / (
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-continuity-repair.json.gz')).read_bytes()))
    old_bindings = json.loads(decode(previous['claim_base64']))['claims'][0]['durability']['inputs']
    expected = next(item['sha256'] for item in old_bindings if item['path'] == RAW)
    assert value['raw_sha256'] == value['inputs'][RAW]['sha256'] == expected, 'original packed artifact identity'
    for path, item in value['before_overrides'].items():
        assert sha(decode(item['base64'])) == value['inputs'][path]['sha256']
    return value


def part_bytes(manifest):
    expected = (manifest['raw_bytes'] + PART_BYTES - 1) // PART_BYTES
    assert len(manifest['parts']) == expected == 4, 'complete part population'
    chunks = []
    for index, item in enumerate(manifest['parts']):
        assert item['path'] == HOME + ('part-%03d.bin' % index), 'ordered part population'
        source = ROOT / item['path']
        assert source.is_file() and not source.is_symlink()
        value = source.read_bytes()
        assert len(value) == item['bytes'] <= PART_BYTES and sha(value) == item['sha256'], 'part byte identity'
        assert source.stat().st_mode & 0o7777 == item['mode']
        chunks.append(value)
    value = b''.join(chunks)
    assert len(value) == manifest['raw_bytes'] == 127191037
    assert sha(value) == manifest['raw_sha256'], 'aggregate original byte identity'
    return value


@contextlib.contextmanager
def materialized_original():
    manifest = load_manifest()
    value = part_bytes(manifest)
    target = ROOT / RAW
    if target.exists():
        assert target.is_file() and not target.is_symlink()
        assert target.read_bytes() == value and target.stat().st_mode & 0o7777 == manifest['raw_mode']
    else:
        assert not target.is_symlink()
        with target.open('xb') as output: output.write(value)
        target.chmod(manifest['raw_mode'])
    assert target.stat().st_dev == ROOT.stat().st_dev
    try:
        yield manifest
    finally:
        # This exact named compatibility copy is recoverable from every tracked
        # part. Unknown or changed content is never removed.
        assert target.is_file() and not target.is_symlink()
        assert sha(target.read_bytes()) == manifest['raw_sha256']
        assert target.stat().st_mode & 0o7777 == manifest['raw_mode']
        target.unlink()


def recover_before(manifest, raw):
    values = {}
    for path, item in manifest['inputs'].items():
        if path == RAW: value = raw
        elif path in manifest['before_overrides']: value = decode(manifest['before_overrides'][path]['base64'])
        else: value = (ROOT / path).read_bytes()
        assert sha(value) == item['sha256'], ('complete669 before bytes', path)
        if path != RAW:
            assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
        values[path] = value
    return values


def replay_before(manifest, raw):
    values = recover_before(manifest, raw)
    original = json.loads(gzip.decompress(raw))
    with common().original_fixture(original) as (fixture, environment):
        for path, value in values.items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(value)
            target.chmod(manifest['inputs'][path]['mode'])
        (fixture / CLAIM).write_bytes(decode(manifest['claim_base64']))
        (fixture / CLAIM).chmod(manifest['claim_mode'])
        command = ['python3', PUB]
        run = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
        unchanged = all((fixture / path).read_bytes() == value and
                        (fixture / path).stat().st_mode & 0o7777 == manifest['inputs'][path]['mode']
                        for path, value in values.items())
        whole = (fixture / CLAIM).read_bytes() == decode(manifest['claim_base64']) and (
            (fixture / CLAIM).stat().st_mode & 0o7777 == manifest['claim_mode'])
    return dict(command=command, returncode=run.returncode, stdout_base64=encode(run.stdout),
                stderr_base64=encode(run.stderr), all669_bytes_modes_unchanged=unchanged,
                whole_claim_mode_unchanged=whole)


def current_inputs():
    return {path.relative_to(ROOT).as_posix() for path in (ROOT / HOME).iterdir() if path.is_file()} | {CARD}


def prepare():
    assert not (ROOT / MANIFEST).exists() and not (ROOT / CARD).exists()
    claim_raw = (ROOT / CLAIM).read_bytes()
    bindings = json.loads(claim_raw)['claims'][0]['durability']['inputs']
    assert len(bindings) == 669 and len(claim_raw) == 112095
    preflight = (ROOT / (PREFIX + 'publication-preflight.json')).read_bytes()
    assert decode(json.loads(preflight)['draft_base64']) == claim_raw
    inputs = {}
    for item in bindings:
        source = ROOT / item['path']
        assert source.is_file() and not source.is_symlink()
        assert sha(source.read_bytes()) == item['sha256']
        inputs[item['path']] = dict(sha256=item['sha256'], mode=source.stat().st_mode & 0o7777)
    overrides = {path: dict(base64=encode((ROOT / path).read_bytes()), mode=inputs[path]['mode'])
                 for path in (PUB, FINALIZER, WORKFLOW, MAP)}
    raw = (ROOT / RAW).read_bytes()
    assert len(raw) == 127191037 and sha(raw) == inputs[RAW]['sha256']
    tracked = subprocess.run(['git', 'ls-files', '--error-unmatch', '--', RAW], cwd=ROOT, capture_output=True)
    assert tracked.returncode != 0, 'uncommitted oversized artifact must never enter Git history'
    size_command = ['python3', SELF, '--size-original']
    size_red = subprocess.run(size_command, cwd=ROOT, capture_output=True)
    assert size_red.returncode == 1 and b'oversized original artifact' in size_red.stderr
    baseline = subprocess.run(['python3', PUB], cwd=ROOT, capture_output=True)
    assert baseline.returncode == 0 and not baseline.stderr
    assert baseline.stdout == b'Current pipeline publication PASS: 669 live inputs; 112095 bytes; original625+161 supplied\n'
    for path, item in inputs.items():
        assert sha((ROOT / path).read_bytes()) == item['sha256']
        assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    parts = []
    for offset in range(0, len(raw), PART_BYTES):
        path = HOME + ('part-%03d.bin' % len(parts))
        value = raw[offset:offset + PART_BYTES]
        with (ROOT / path).open('xb') as output: output.write(value)
        parts.append(dict(path=path, bytes=len(value), sha256=sha(value), mode=(ROOT / path).stat().st_mode & 0o7777))
    card = b'''---
id: pipeline-checkpoint-artifact-transport
title: Pipeline evidence uses exact bounded parts and supplied original contexts
answers:
  - "why are captured pipeline draft bytes stored in several parts"
  - "how does pipeline proof recover its original whole input context"
  - "may readonly verification assemble a temporary compatibility artifact"
date: 2026-10-19
status: current source-bound artifact transport
tags: [claims, artifacts, custody, git, PERL-PRIVATE-FACTORY-CAPTURE]
evidence: "The packed original has127191037 bytes. Four parts of at most33554432 bytes retain its exact aggregate identity and mode; actual unchanged669-reader use guards every supplied byte/mode and whole claim. No oversized blob is committed or remote push attempted."
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/pipeline-scope/publish.py."
---

GitHub's documented ordinary Git file limit is100MiB;32MiB is this project's
chosen part bound. The manifest retains every original packed byte, the whole
uncommitted669 claim/preflight and source overrides needed to recover its input
graph. It gives that draft no invented Git revision. Verification assembles the
exact compatibility copy only for its readers, then removes that known copy;
tracked parts retain all durable data. Native observations are never refreshed.

Source: https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github
Canonical inputs, controls and original use: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-artifacts/manifest.json.
'''
    total = sum(path.stat().st_size for path in (ROOT / 'docs/knowledge').rglob('*.md'))
    assert total == 8384959
    total += len(card)
    assert total <= 8388608, ('unchanged Knowledge cap', total)
    workflow = decode(overrides[WORKFLOW]['base64'])
    marker = b'### Historical claim populations\n'
    assert workflow.count(marker) == 1
    section = b'''### Checkpoint artifact parts

The original packed preservation has127,191,037 bytes. GitHub's
[ordinary Git file limit](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github)
is100MiB, so this checkpoint stores four exact parts, each at most32MiB. A manifest
retains aggregate identity, permissions, the complete original669-input claim and
the before source images needed to recover its supplied context.

The unchanged original reader executes against bytes recovered from those parts;
every supplied input and the whole claim retain their bytes and permissions.
Current verification assembles a compatibility copy during the command and
removes that known copy afterward. The tracked parts retain every durable byte.
No native observation, gate or repository history is rewritten, and no oversized
push is attempted. Corrupted, missing or reordered parts must be rejected.

'''
    workflow = workflow.replace(marker, section + marker)
    publisher = decode(overrides[PUB]['base64'])
    split = b"assert sys.argv[1:] in ([], ['--preflight'], ['--capture'])\n"
    assert publisher.count(split) == 1
    header, body = publisher.split(split)
    start = body.index(b'repair = subprocess.run(')
    end = body.index(b'original = load()\n', start)
    body = body[:start] + ("transport = subprocess.run(['python3', " + repr(SELF) + "], cwd=ROOT, capture_output=True)\n"
        "assert transport.returncode == 0 and not transport.stderr, ('artifact/current supplied proof', transport.stdout, transport.stderr)\n").encode() + body[end:]
    old = b"path.name not in ('publication-preflight.json', 'continuity.json')"
    assert body.count(old) == 1
    body = body.replace(old, b"path.name not in ('publication-preflight.json', 'continuity.json', 'preserved.json.gz')")
    needle = b"source_suffixes = {'.py', '.pm', '.pl', '.t', '.sh'}\n"
    assert body.count(needle) == 1
    body = body.replace(needle, b'paths.update(_artifacts.current_inputs())\n' + needle)
    for old_value, new_value in [('1487', '1488'), ('1349', '1350'), ('10450', '10453'), ('8384959', str(total))]:
        body = body.replace(old_value.encode(), new_value.encode())
    body = body.replace(b'fifteen routes/one body from that draft/', b'fifteen prior routes/one retained prior body/one new artifact card/')
    before_scope = (b"        'The complete667 draft, actual readonly baseline and AST failure of its unexecuted '\n"
                    b"        'continuity writer remain losslessly recoverable through current unchanged inputs plus '\n"
                    b"        'both retained before source byte streams. A one-operator repair changes no measurement. '\n")
    assert body.count(before_scope) == 1
    body = body.replace(before_scope,
        b"        'The earlier667 preparation draft and its before sources remain recoverable inside '\n"
        b"        'the exact restored669 context. Four bounded parts retain all127191037 packed bytes; '\n"
        b"        'actual original669-reader use guards every input and whole claim. Current compatibility '\n"
        b"        'assembly is temporary and removed after verified use. Three effective part controls '\n"
        b"        'reject corruption, omission and order changes. No oversized blob or push is admitted. '\n")
    body = body.replace(b'Actual current forgeries', b'Retained earlier forgeries')
    setup = ("import importlib.util\n_artifact_spec = importlib.util.spec_from_file_location(\n"
        "    '_pipeline_artifacts', ROOT / " + repr(SELF) + ")\n"
        "_artifacts = importlib.util.module_from_spec(_artifact_spec)\n_artifact_spec.loader.exec_module(_artifacts)\n"
        "with _artifacts.materialized_original():\n")
    publisher = header + setup.encode() + b''.join(b'    ' + line if line.strip() else line for line in (split + body).splitlines(keepends=True))
    finalizer = decode(overrides[FINALIZER]['base64'])
    for old_value, new_value in [('1487', '1488'), ('1349', '1350'), ('10450', '10453'), ('8384959', str(total))]:
        assert old_value.encode() in finalizer
        finalizer = finalizer.replace(old_value.encode(), new_value.encode())
    finalizer = finalizer.replace(b'No gate, selector, dependency or budget changes.',
        b'Four bounded parts retain all127191037 packed bytes with unchanged669-reader use and exact recovery; '
        b'current part controls reject corruption/omission/order. No oversized blob, gate, selector, dependency or budget changes.')
    ast.parse(publisher, filename=PUB); ast.parse(finalizer, filename=FINALIZER)
    manifest = dict(version=1, result='pending', owner='PERL-PRIVATE-FACTORY-CAPTURE.6',
        producer_base64=encode(Path(__file__).read_bytes()), raw_path=RAW, raw_bytes=len(raw),
        raw_sha256=sha(raw), raw_mode=inputs[RAW]['mode'], part_bound=PART_BYTES, parts=parts,
        claim_base64=encode(claim_raw), claim_sha256=sha(claim_raw), claim_mode=(ROOT / CLAIM).stat().st_mode & 0o7777,
        preflight_base64=encode(preflight), inputs=inputs, before_overrides=overrides,
        proposal={PUB: dict(base64=encode(publisher), mode=inputs[PUB]['mode']),
                  FINALIZER: dict(base64=encode(finalizer), mode=inputs[FINALIZER]['mode']),
                  WORKFLOW: dict(base64=encode(workflow), mode=inputs[WORKFLOW]['mode']),
                  CARD: dict(base64=encode(card), mode=0o644)}, knowledge_bytes=total,
        source_policy='https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github',
        size_red=dict(command=size_command, returncode=size_red.returncode, stdout_base64=encode(size_red.stdout), stderr_base64=encode(size_red.stderr)),
        baseline=dict(command=['python3', PUB], returncode=baseline.returncode, stdout_base64=encode(baseline.stdout), stderr_base64=encode(baseline.stderr)),
        scope='Lossless bounded transport of the exact packed original, complete669 claim/preflight '
              'and every before input. Raw bytes recover through parts; four changed sources recover '
              'through whole before images; all other before bytes match gated current inputs. '
              'Actual readonly use from parts precedes known untracked monolith removal. No original '
              'native/capture writer, fictional revision, external storage or repository rewrite.')
    (ROOT / MANIFEST).write_text(json.dumps(manifest, indent=1) + '\n')
    assert part_bytes(manifest) == raw
    use = replay_before(manifest, raw)
    manifest['use_from_parts'] = use
    (ROOT / MANIFEST).write_text(json.dumps(manifest, indent=1) + '\n')
    assert use['returncode'] == 0 and not decode(use['stderr_base64'])
    assert use['all669_bytes_modes_unchanged'] and use['whole_claim_mode_unchanged']
    assert decode(use['stdout_base64']) == baseline.stdout
    manifest['result'] = 'PASS'
    (ROOT / MANIFEST).write_text(json.dumps(manifest, indent=1) + '\n')
    for path, item in manifest['proposal'].items():
        if path == CARD:
            with (ROOT / path).open('xb') as output: output.write(decode(item['base64']))
            (ROOT / path).chmod(item['mode'])
        else: (ROOT / path).write_bytes(decode(item['base64']))
    (ROOT / CLAIM).write_bytes(decode(json.loads(gzip.decompress(raw))['claim_base64']))
    assert (ROOT / RAW).read_bytes() == raw and (ROOT / RAW).stat().st_mode & 0o7777 == manifest['raw_mode']
    (ROOT / RAW).unlink()
    print('Bounded artifact preparation PASS:4 parts;127191037 exact bytes;669-reader use;no original data removed')


def main():
    if sys.argv[1:] == ['--prepare']:
        prepare(); return
    if sys.argv[1:] == ['--size-original']:
        size = (ROOT / RAW).stat().st_size
        print(json.dumps(dict(path=RAW, bytes=size, ordinary_github_limit=GITHUB_BYTES)))
        if size > GITHUB_BYTES:
            print('oversized original artifact', file=sys.stderr)
            raise SystemExit(1)
        return
    if sys.argv[1:] == ['--parts-only']:
        value = part_bytes(load_manifest())
        print('Artifact parts PASS:4;', len(value), 'exact original bytes'); return
    assert not sys.argv[1:]
    with materialized_original() as manifest:
        raw = part_bytes(manifest)
        assert replay_before(manifest, raw) == manifest['use_from_parts']
        for path, item in manifest['proposal'].items():
            if path == MAP: continue
            assert (ROOT / path).read_bytes() == decode(item['base64'])
            assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
        for name in ('review-docs.py', 'controls.py'):
            run = subprocess.run(['python3', HOME + name], cwd=ROOT, capture_output=True)
            assert run.returncode == 0 and not run.stderr, ('actual current artifact/doc review', name, run.stdout, run.stderr)
        assert manifest['size_red']['returncode'] == 1 and b'oversized original artifact' in decode(manifest['size_red']['stderr_base64'])
    print('Current bounded artifact proof PASS:4 exact parts;whole669 recovery;current documentation/controls')


if __name__ == '__main__': main()
