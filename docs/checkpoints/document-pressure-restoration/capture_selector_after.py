"""Retain the post-repair source delta, actual commands and public observations."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

from compact_selector_population import packet

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
SCRATCH = ROOT/'.linkedspec-data/normal-hook-restoration'


def capture():
    destination = HERE/'selector-intake-after.json.gz'
    if destination.exists():
        raise ValueError('retain prior selector after epochs')
    envelope = json.loads(gzip.decompress((HERE/'selector-source-population.json.gz').read_bytes()))
    before = envelope['record']
    source = ROOT/'tools/check_executable_aggregate_selector_sources.py'
    spec = importlib.util.spec_from_file_location('selector_after_inputs', source)
    scanner = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(scanner)
    paths = scanner.candidate_files()
    current, changed = {}, {}
    for name in paths:
        if Path(name).suffix in scanner.EXCLUDED_SUFFIXES:
            continue
        try:
            raw = (ROOT/name).read_bytes()
        except OSError:
            row = dict(disposition='unreadable')
        else:
            try:
                raw.decode('utf-8')
                disposition = 'utf8'
            except UnicodeDecodeError:
                disposition = 'binary'
            row = dict(disposition=disposition, sha256=hashlib.sha256(raw).hexdigest())
            old = before['inputs'].get(name)
            if old and old.get('sha256') == row['sha256'] and old['disposition'] == disposition:
                row = old
            elif disposition == 'binary' and (name.startswith('docs/checkpoints/document-pressure-restoration/')
                    or name == 'tests/language-readiness/current-source-images.json.gz'):
                row['artifact_path'] = name
            else:
                row['payload'] = packet(raw)
        current[name] = row
        if row != before['inputs'].get(name):
            changed[name] = row
    commands = {}
    for name, path in (
            ('scanner', 'tools/check_executable_aggregate_selector_sources.py'),
            ('public', 'tools/check_public_aggregate_selector_surface.py'),
            ('binding', 'tools/check_uniform_binding_mutation_result_surface.py'),
            ('teaching', 'tools/check_mutation_public_surface.py')):
        command = ['bash', 'tools/run_python_project_data.sh', path]
        result = subprocess.run(command, cwd=ROOT, capture_output=True)
        commands[name] = dict(command=command, returncode=result.returncode,
                              stdout=packet(result.stdout), stderr=packet(result.stderr))
        if result.returncode:
            raise ValueError('selector final focused command failed: '+name+'\n'+result.stderr.decode())
    if scanner.candidate_files() != paths:
        raise ValueError('source membership changed during selector capture')
    for name, row in current.items():
        if 'sha256' in row and hashlib.sha256((ROOT/name).read_bytes()).hexdigest() != row['sha256']:
            raise ValueError('source bytes changed during selector capture: '+name)
    value = dict(schema_version=1, owner='TYPE-REFERENCE-BOOK.1.2.20.1.13.1',
                 scanner=packet(source.read_bytes()),
                 public_checker=packet((ROOT/'tools/check_public_aggregate_selector_surface.py').read_bytes()),
                 producer=packet(Path(__file__).read_bytes()), candidate_paths=paths,
                 changed_inputs=changed,
                 removed_inputs=sorted(set(before['inputs'])-set(current)), commands=commands,
                 public_literal_before=json.loads((SCRATCH/'public-selector-literal-before.json').read_bytes()),
                 public_literal_controls=json.loads((SCRATCH/'public-selector-literal-after.json').read_bytes()),
                 literal_probe=dict(producer=packet((HERE/'selector_literal_probe.pl').read_bytes()),
                                    stdout=packet((SCRATCH/'selector-literal-native.jsonl').read_bytes()),
                                    stderr=packet((SCRATCH/'selector-literal-native.stderr').read_bytes())),
                 concurrency_log=packet((SCRATCH/'selector-concurrency-after.log').read_bytes()),
                 book=dict(before=packet((SCRATCH/'selector-book-before.md').read_bytes()),
                           after=packet((ROOT/'docs/linkedspec-book/src/development/local-ci-and-regression.md').read_bytes()),
                           rendered=packet((ROOT/'docs/linkedspec-book/book/development/local-ci-and-regression.html').read_bytes())),
                 limits='Exact lexical repair component epoch before final continuity edits. The original population and every changed source are retained; final receipt separately binds the staged candidate. No runtime implementation or portable feature admission.')
    destination.write_bytes(gzip.compress(json.dumps(value, sort_keys=True).encode(), mtime=0))
    print('selector after epoch retained:',len(changed),'changed inputs;',len(paths),'candidate paths; four actual focused commands PASS')


if __name__ == '__main__':
    capture()
