"""Seal owned acquisition workspaces after proving complete archive recovery."""
import hashlib
import json
import os
from pathlib import Path
import posixpath
import shutil
import stat
import tarfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
RECORD = HERE / 'workspace-custody.json'
assert not RECORD.exists(), 'one-shot packaging only'

def digest(data):
    return hashlib.sha256(data).hexdigest()

# Compare actual surviving inputs with their first-run captured bytes, before
# packaging any workspace. Dart's original tar has its captured package cwd.
first = []
for prefix in (HERE, HERE / 'logical'):
    for name in ('rust-native', 'rust-fresh', 'dart-native', 'dart-fresh'):
        archive_path = prefix / (name + '-before-first-run.tar.gz')
        with tarfile.open(archive_path) as archive:
            for member in archive.getmembers():
                if not member.isfile():
                    continue
                relative = member.name
                if prefix == HERE and name == 'dart-fresh':
                    relative = posixpath.normpath((prefix / 'dart-fresh').relative_to(ROOT).as_posix() + '/' + member.name)
                assert not relative.startswith('/') and '..' not in Path(relative).parts
                current = ROOT / relative
                actual = archive.extractfile(member).read()
                assert current.is_file() and current.read_bytes() == actual, relative
                first.append({'archive': archive_path.relative_to(ROOT).as_posix(),
                              'member': member.name, 'path': relative,
                              'sha256': digest(actual)})

workspaces = []
for prefix in (HERE, HERE / 'logical'):
    for name in ('rust-native', 'rust-fresh', 'dart-fresh'):
        directory = prefix / name
        assert directory.is_dir() and not directory.is_symlink()
        paths = [directory]
        for parent, dirs, files in os.walk(directory, followlinks=False):
            assert '.git' not in dirs and '.git' not in files, 'nested repository'
            for entry in dirs + files:
                path = Path(parent) / entry
                info = path.lstat()
                assert not stat.S_ISLNK(info.st_mode), 'retain unexpected symlink: ' + str(path)
                assert info.st_dev == ROOT.stat().st_dev
                assert stat.S_ISDIR(info.st_mode) or stat.S_ISREG(info.st_mode)
                paths.append(path)
        images = {}
        for path in paths:
            if path.is_file():
                images[path.relative_to(ROOT).as_posix()] = digest(path.read_bytes())
        archive_path = prefix / (name + '-workspace.tar.gz')
        assert not archive_path.exists()
        with tarfile.open(archive_path, 'w:gz', dereference=False) as archive:
            for path in sorted(paths):
                archive.add(path, arcname=path.relative_to(ROOT).as_posix(), recursive=False)
        with tarfile.open(archive_path) as archive:
            restored = {member.name: digest(archive.extractfile(member).read())
                        for member in archive.getmembers() if member.isfile()}
        assert restored == images, 'workspace recovery mismatch'
        # Only exact workspaces created by this acquisition are removed; all
        # recoverable input bytes and modes survive in the verified archive.
        shutil.rmtree(directory)
        assert not directory.exists()
        workspaces.append({'path': directory.relative_to(ROOT).as_posix(),
                           'archive': archive_path.relative_to(ROOT).as_posix(),
                           'files': images, 'residue': False})
RECORD.write_text(json.dumps({'first_run_input_equality': first,
                             'sealed_workspaces': workspaces}, sort_keys=True, indent=2) + '\n')
print('Verified first-run input equality and complete recovery for owned acquisition workspaces.')
