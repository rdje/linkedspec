"""Replay captured selector populations and verify the authored repair controls."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import subprocess
import tempfile
import types

from book_review import Visible, normal
from compact_selector_population import decode, reconstruct

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BASE = '0db5e9e87b7c1cfaf09936b9629974787038f5e3'


def safe_name(name):
    path = PurePosixPath(name)
    assert not path.is_absolute() and str(path) == name
    assert all(part not in ('.', '..', '.git') for part in path.parts)
    return name


class EpochReader:
    """Resolve immutable inputs through one tree and a bounded Git blob stream."""

    def __init__(self):
        self.tree = {}
        for row in subprocess.check_output(['git', 'ls-tree', '-rz', BASE], cwd=ROOT).split(b'\0'):
            if row:
                header, name = row.split(b'\t', 1)
                self.tree[name.decode()] = header.decode().split()
        self.process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                                        stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    def close(self):
        self.process.stdin.close()
        assert self.process.wait() == 0, 'selector Git reader failed'

    def read(self, name, row):
        safe_name(name)
        if row['disposition'] == 'unreadable':
            assert self.tree[name][:2] == ['160000', 'commit'], 'unclassified unreadable input'
            return None
        choices = [key for key in ('revision', 'payload', 'artifact_path') if key in row]
        assert len(choices) == 1, 'selector input representation'
        if choices[0] == 'revision':
            assert row['revision'] == BASE
            mode, kind, oid = self.tree[name]
            assert mode in ('100644', '100755') and kind == 'blob'
            self.process.stdin.write((oid+'\n').encode())
            self.process.stdin.flush()
            header = self.process.stdout.readline().split()
            assert len(header) == 3 and header[:2] == [oid.encode(), b'blob']
            raw = self.process.stdout.read(int(header[2]))
            assert len(raw) == int(header[2]) and self.process.stdout.read(1) == b'\n'
        elif choices[0] == 'payload':
            raw = decode(row['payload'])
        else:
            assert row['artifact_path'] == name and row['disposition'] == 'binary'
            assert name.startswith('docs/checkpoints/document-pressure-restoration/') or name == 'tests/language-readiness/current-source-images.json.gz'
            raw = (ROOT/name).read_bytes()
        assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'selector input drift: '+name
        try:
            raw.decode('utf-8')
            disposition = 'utf8'
        except UnicodeDecodeError:
            disposition = 'binary'
        assert disposition == row['disposition'], 'selector input disposition drift'
        return raw


def module(raw, path, name):
    result = types.ModuleType(name)
    result.__file__ = str(path)
    exec(compile(raw, str(path), 'exec'), result.__dict__)
    return result


def install(fixture, name, row, reader):
    target = fixture/safe_name(name)
    target.parent.mkdir(parents=True, exist_ok=True)
    raw = reader.read(name, row)
    if raw is None:
        target.mkdir(exist_ok=True)
        return
    if target.exists() or target.is_symlink():
        target.unlink()
    source = ROOT/name
    # Both scanners only read inputs. Reusing an identical binary inode avoids
    # copying large primary artifacts; replacement always unlinks the fixture first.
    if row['disposition'] == 'binary' and source.is_file() and not source.is_symlink() and source.read_bytes() == raw:
        os.link(source, target)
    else:
        target.write_bytes(raw)


def population_membership(paths, inputs, suffixes):
    assert len(paths) == len(set(paths)), 'duplicate selector candidate'
    assert {name for name in paths if Path(name).suffix not in suffixes} == set(inputs), 'selector input omission'


def review():
    before = reconstruct(json.loads(gzip.decompress((HERE/'selector-source-population.json.gz').read_bytes())),
                         lambda name: (ROOT/safe_name(name)).read_bytes())
    after = json.loads(gzip.decompress((HERE/'selector-intake-after.json.gz').read_bytes()))
    intake = json.loads(gzip.decompress((HERE/'selector-intake-before.json.gz').read_bytes()))
    assert before['returncode'] == 1 and after['owner'] == 'TYPE-REFERENCE-BOOK.1.2.20.1.13.1'
    assert decode(before['scanner']) == decode(intake['scanner'])
    assert len(intake['positives']) == 20 and len(intake['literal_occurrences']) == 8
    assert len(intake['reviewed_negative_inputs']) == 8
    assert sum(len(row['lines']) for row in intake['reviewed_negative_inputs'].values()) == 12
    effective = dict(before['inputs'])
    for name in after['removed_inputs']:
        assert name in effective
        effective.pop(name)
    effective.update(after['changed_inputs'])
    reader = EpochReader()
    try:
        with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR'], prefix='selector-replay-') as directory:
            fixture = Path(directory)
            for name, row in before['inputs'].items():
                install(fixture, name, row, reader)
            path = fixture/'tools/check_executable_aggregate_selector_sources.py'
            old = module(decode(before['scanner']), path, 'selector_before_replay')
            population_membership(before['candidate_paths'], before['inputs'], old.EXCLUDED_SUFFIXES)
            lost = dict(before['inputs']); lost.pop(next(iter(lost)))
            try:
                population_membership(before['candidate_paths'], lost, old.EXCLUDED_SUFFIXES)
            except AssertionError:
                pass
            else:
                raise AssertionError('lost selector source was admitted')
            named = next(name for name, row in before['inputs'].items() if 'revision' in row)
            stale = dict(before['inputs'][named], sha256='0'*64)
            try:
                reader.read(named, stale)
            except AssertionError:
                pass
            else:
                raise AssertionError('stale selector source identity was admitted')
            positives, _ = old.scan_files(before['candidate_paths'])
            assert positives == intake['positives'], 'original selector rejection differs'
            old_public_path = fixture/'tools/check_public_aggregate_selector_surface.py'
            old_public = module(old_public_path.read_bytes(), old_public_path, 'public_selector_before_replay')
            before_page = fixture/'README.md'
            before_page.write_text(after['public_literal_before']['source'])
            try:
                old_public.check_exact_references([before_page])
            except SystemExit as error:
                assert str(error) == after['public_literal_before']['error']
            else:
                raise AssertionError('original public literal false positive did not reproduce')
            for name in after['removed_inputs']:
                (fixture/name).unlink()
            for name, row in after['changed_inputs'].items():
                install(fixture, name, row, reader)
            current = module(decode(after['scanner']), path, 'selector_after_replay')
            assert current.EXCLUDED_SUFFIXES == old.EXCLUDED_SUFFIXES
            population_membership(after['candidate_paths'], effective, current.EXCLUDED_SUFFIXES)
            assert not current.scan_files(after['candidate_paths'])[0]
            assert current.self_test_classification() == (8, 84)
            ordinary = fixture/'ordinary.dart'
            ordinary.write_text('array'+'(items);\n')
            assert current.scan_files(['ordinary.dart'])[0], 'ordinary positive selector admitted'
            ordinary.write_text('array'+'(false); hash'+'(items);\n')
            assert current.scan_files(['ordinary.dart'])[0], 'mixed positive selector admitted'
            public = module(decode(after['public_checker']), fixture/'tools/check_public_aggregate_selector_surface.py', 'public_selector_replay')
            page = fixture/'literal-page.md'
            for row in after['public_literal_controls']:
                page.write_text(row['source'])
                try:
                    count = public.check_exact_references([page])
                    code = 0
                except SystemExit:
                    code, count = 1, None
                assert code == row['returncode'] and (code or count == 0)
    finally:
        reader.close()
    for name, run in after['commands'].items():
        assert run['returncode'] == 0, 'selector command failed: '+name
        decode(run['stdout']); decode(run['stderr'])
    rows = [json.loads(line) for line in decode(after['literal_probe']['stdout']).splitlines()]
    expected = {'true':'boolean','false':'boolean','undef':'undef',
                'null':'variable','nothing':'variable','True':'variable','FALSE':'variable','items':'variable'}
    assert {row['token']:row['node']['args'][0]['kind'] for row in rows[:-1]} == expected
    native = rows[-1]
    assert native['built'] == 1 and not native['thrown'] and native['error'] is None
    assert native['value'][0][0] is True and native['value'][1][0] is False and native['value'][2] == [None]
    assert not decode(after['literal_probe']['stderr'])
    book = after['book']
    before_book, after_book = decode(book['before']), decode(book['after'])
    assert after_book.startswith(before_book) and len(after_book) > len(before_book)
    visible = Visible(); visible.feed(decode(book['rendered']).decode())
    assert 'array(false)' in normal(''.join(visible.parts))
    binding = json.loads(gzip.decompress((HERE/'binding-surface-epoch.json.gz').read_bytes()))
    assert {name:row['returncode'] for name,row in binding['cases'].items()} == dict(
        before=1, after=0, lost_annotation=1, stale_public_claim=1, lost_current_anchor=1)
    for row in binding['sources'].values(): decode(row)
    for row in binding['cases'].values(): decode(row['stdout']); decode(row['stderr'])
    for name in ('before', 'lost_annotation'):
        output = decode(binding['cases'][name]['stdout'])
        assert b'dart-runtime-array-helpers.md: missing explicit uniform-binding supersession' in output
    assert b'superseded public claim' in decode(binding['cases']['stale_public_claim']['stdout'])
    assert b'missing current anchor' in decode(binding['cases']['lost_current_anchor']['stdout'])
    assert binding['teaching']['returncode'] == 0
    return 'exact source populations replay RED20/GREEN0; literal/native/public, owned diagnostic, positive, loss and concurrency controls PASS'


if __name__ == '__main__':
    print(review())
