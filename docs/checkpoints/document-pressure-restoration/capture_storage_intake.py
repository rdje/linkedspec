"""Freeze storage census sources and actual failed consumers before repair."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BASE = '0db5e9e87b7c1cfaf09936b9629974787038f5e3'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def populations(sources):
    return {
        'perl_temporary_owners': sorted(name for name, raw in sources.items()
            if re.match(r'^(?:t/.*\.t|t/.*\.pm|tools/[^/]+\.pl|perl/.*\.pm)$', name)
            and re.search(rb'File::Temp|tempdir\(|tempfile\(', raw)),
        'python_temporary_owners': sorted(name for name, raw in sources.items()
            if re.match(r'^tools/[^/]+\.py$', name)
            and re.search(rb'^\s*(?:import\s+tempfile\b|from\s+tempfile\s+import\b)', raw, re.M)),
        'python_entrypoints': sorted(name for name, raw in sources.items()
            if re.match(r'^tools/[^/]+\.py$', name) and raw.startswith(b'#!/usr/bin/env python3\n')),
        'shell_temporary_owners': sorted(name for name, raw in sources.items()
            if re.match(r'^(?:tools|knowledge-map/scripts)/[^/]+\.sh$', name)
            and re.search(rb'\$\(mktemp\b', raw)),
    }


def capture():
    destination = HERE / 'storage-intake.json.gz'
    assert not destination.exists(), 'never overwrite an intake epoch'
    names = subprocess.check_output(['git', 'ls-files', '-z', '--', 't', 'perl', 'tools',
                                     'knowledge-map/scripts'], cwd=ROOT).split(b'\0')[:-1]
    names = [name.decode() for name in names if re.match(
        rb'^(?:t/.*\.(?:t|pm)|perl/.*\.pm|tools/[^/]+\.(?:pl|py|sh)|knowledge-map/scripts/[^/]+\.sh)$', name)]
    current = {name: (ROOT / name).read_bytes() for name in names}
    previous = {}
    for name in names:
        result = subprocess.run(['git', 'show', BASE + ':' + name], cwd=ROOT, capture_output=True)
        if result.returncode == 0:
            previous[name] = result.stdout
    extra = [str(Path(__file__).relative_to(ROOT)), 'tests/language-readiness/verify_objectives.py',
             'docs/knowledge/project-data-ssd-storage-locality.md',
             'docs/knowledge/tool-project-data-ssd-storage.md',
             'docs/linkedspec-book/src/development/local-ci-and-regression.md']
    record = dict(owner='TYPE-REFERENCE-BOOK.1.2.20.1.19', base=BASE,
                  current={name: packet(raw) for name, raw in current.items()},
                  previous={name: packet(raw) for name, raw in previous.items()},
                  authorities={name: packet((ROOT / name).read_bytes()) for name in extra},
                  populations=dict(current=populations(current), previous=populations(previous)),
                  failures={name: packet((ROOT / '.linkedspec-data/normal-hook-restoration' / name).read_bytes())
                            for name in ['canonical-ci.log', 'storage-tool-before.log']},
                  limits='Tracked matching source scopes at intake, including all nonmatching candidates; import-based Python scope includes mkdtemp, unlike the failed two-API regex. No transitive allocation or global leak claim.')
    destination.write_bytes(gzip.compress(json.dumps(record, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
    for kind, owners in record['populations']['current'].items():
        old = record['populations']['previous'][kind]
        print(kind, len(old), '->', len(owners), 'added', sorted(set(owners) - set(old)))


if __name__ == '__main__':
    capture()
