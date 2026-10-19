"""Original draft custody and the one declared lossless observation transport."""
import base64
import contextlib
import gzip
import hashlib
import io
import json
import os
import subprocess
import tarfile
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/pipeline-scope/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.6.json'
NATIVE = OLD + 'native-prove-context-before.json'
WORKFLOW = 'docs/linkedspec-book/src/development/documentation-workflow.md'
CARD = 'docs/knowledge/project-root-evidence-filesystem-modes.md'
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
decode = base64.b64decode


def load():
    packed = (ROOT / (PREFIX + 'preserved.json.gz')).read_bytes()
    report = json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())
    assert sha(packed) == report['capsule_sha256'], 'original whole draft capsule'
    original = json.loads(gzip.decompress(packed))
    claim_raw = decode(original['claim_base64'])
    assert sha(claim_raw) == original['claim_sha256'] == report['claim_sha256']
    assert len(claim_raw) == 123401 and original['base'] == BASE
    claim = json.loads(claim_raw)
    bindings = claim['claims'][0]['durability']['inputs']
    assert len(bindings) == len(original['inputs']) == 625
    assert {item['path']: item['sha256'] for item in bindings} == {
        path: item['sha256'] for path, item in original['inputs'].items()}
    for path, item in original['inputs'].items():
        assert sha(decode(item['base64'])) == item['sha256'], ('original bytes', path)
    assert decode(json.loads(decode(original['publication_preflight_base64']))['draft_base64']) == claim_raw
    baseline = original['baseline']
    assert baseline == report['baseline'] and baseline['returncode'] == 0
    assert not decode(baseline['stderr_base64'])
    assert decode(baseline['stdout_base64']) == b'Pipeline invocation publication PASS: 625 live inputs; 123401 bytes\n'
    assert decode(original['producer_base64']) == (ROOT / (PREFIX + 'preserve.py')).read_bytes()
    assert sha(decode(original['producer_base64'])) == report['producer_sha256']
    standard = json.loads(gzip.decompress((ROOT / (
        'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6-standard-verification.json.gz')).read_bytes()))
    claim_source = next(item for item in standard['sources'] if item['path'] == CLAIM)
    assert decode(claim_source['base64']) == claim_raw, 'independent pre-transport claim custody'
    return original


def native_view(original):
    raw = decode(original['inputs'][NATIVE]['base64'])
    view = raw.replace(b'/', b'\\/')
    assert json.loads(view) == json.loads(raw)
    assert view.replace(b'\\/', b'/') == raw
    return view


def verify_native(original):
    actual = (ROOT / NATIVE).read_bytes()
    raw = decode(original['inputs'][NATIVE]['base64'])
    assert json.loads(actual) == json.loads(raw), 'decoded native observation is identical'
    assert actual == native_view(original), 'exact standard JSON solidus transport'
    assert (ROOT / NATIVE).stat().st_mode & 0o7777 == original['inputs'][NATIVE]['mode']


@contextlib.contextmanager
def original_fixture(original):
    # The unchanged reader compares the entire Perl tree and its fixed Git claim
    # namespace. Restore both from the real activation, then all625 actual overlays.
    with tempfile.TemporaryDirectory(prefix='pipeline-original-', dir=os.environ['TMPDIR']) as directory:
        fixture = Path(directory)
        assert fixture.stat().st_dev == ROOT.stat().st_dev
        archive = subprocess.check_output(['git', 'archive', BASE, '--', 'perl', 'docs/claims'], cwd=ROOT)
        with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
            for member in stream:
                assert not member.name.startswith('/') and '..' not in Path(member.name).parts
                if member.isdir(): continue
                assert member.isfile(), member.name
                target = fixture / member.name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(stream.extractfile(member).read())
                target.chmod(member.mode)
        for path, item in original['inputs'].items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(decode(item['base64']))
            target.chmod(item['mode'])
        for path, item in load_namespace(original)['inputs'].items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(decode(item['base64']))
            target.chmod(item['mode'])
        (fixture / CLAIM).write_bytes(decode(original['claim_base64']))
        environment = os.environ.copy()
        environment.update(GIT_DIR=subprocess.check_output(
            ['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT, text=True).strip(),
            GIT_WORK_TREE=str(fixture), GIT_OPTIONAL_LOCKS='0')
        yield fixture, environment


def load_namespace(original):
    packed = (ROOT / (PREFIX + 'namespace.json.gz')).read_bytes()
    namespace = json.loads(gzip.decompress(packed))
    assert namespace['result'] == 'PASS' and namespace['base'] == BASE
    assert namespace['original_claim_sha256'] == original['claim_sha256']
    assert decode(namespace['producer_base64']) == (ROOT / (PREFIX + 'supplement.py')).read_bytes()
    names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE,
                                     '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
    assert namespace['fixed_names'] == names and set(namespace['inputs']) == set(names), 'fixed supplied claim namespace'
    for path, item in namespace['inputs'].items():
        value = decode(item['base64'])
        assert sha(value) == item['sha256']
        old = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
        if path == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json':
            expected = json.loads(old)
            expected['claims'][0]['durability'].update(mode='historical', revision=BASE)
            assert json.loads(value) == expected, 'actual selected claim freeze'
        else:
            assert value == old, ('unchanged fixed namespace member', path)
    assert namespace['returncode'] == 0 and not decode(namespace['stderr_base64'])
    assert decode(namespace['stdout_base64']) == b'Pipeline invocation publication PASS: 625 live inputs; 123401 bytes\n'
    assert namespace['added_names'] == sorted(set(names) - set(original['inputs']))
    return namespace
