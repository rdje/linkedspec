"""Qualify the selector vocabulary; the initial reader and failed channels stay exact."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import shlex
import sys
import tarfile

BASE = Path(__file__).resolve().parent


def load():
    with tarfile.open(BASE / 'qualification-sources.tar.gz') as archive:
        identities = json.loads((BASE / 'qualification-identities.json').read_bytes())
        assert set(archive.getnames()) == identities.keys()
        for member in archive:
            assert member.isfile() and not Path(member.name).is_absolute()
            body = archive.extractfile(member).read()
            assert hashlib.sha256(body).hexdigest() == identities[member.name]['sha256']
            assert member.mode == identities[member.name]['mode']
            assert Path(member.name).read_bytes() == body
    spec = importlib.util.spec_from_file_location('initial_roles', BASE / 'review.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    original = module.selection

    def selection(source):
        # A log string saying "prove" is not a prove command. Preserve all
        # exact array lines and only actual top-level command forms.
        kept, active = [], False
        for line in source.splitlines():
            if line == 'private_factory_suites=(':
                active = True
            if active or re.match(r'^(?:[A-Z_][A-Z0-9_]*=[^ \t]*[ \t]+)*prove[ \t]', line):
                kept.append(line)
            if active and line == ')':
                active = False
        return original('\n'.join(kept))

    module.selection = selection
    return module


if __name__ == '__main__':
    load().main()
