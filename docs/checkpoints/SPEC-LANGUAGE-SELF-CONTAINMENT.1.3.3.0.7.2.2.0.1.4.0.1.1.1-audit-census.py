"""Retain the exact failed candidate and census audited source evolution."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('audit-census.py')
BASE = '224d5443af794d4e5ade6e80bd8f09145ee7b5b3'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
HISTORICAL = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-verification.json'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip() == BASE
    scratch = ROOT / '.linkedspec-data/scratch/history-rollover-eof'
    assert (scratch / 'canonical.exit').read_text().strip() == '1'
    raw_log = (scratch / 'canonical.log').read_bytes()
    reason = b'ValueError: current executable evidence drift: perl/LinkedSpec/ActionIR/Contracts.pm\n'
    assert raw_log.endswith(reason)
    diff = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index', '--no-ext-diff', '--no-renames', 'HEAD', '--'], cwd=ROOT)
    failure = {'command': ['bash', 'tools/run_ci_local.sh'], 'base': BASE, 'exit': 1,
               'channel_scope': 'complete combined stdout/stderr, not separately reconstructed',
               'log': envelope(raw_log), 'staged_candidate': envelope(diff),
               'result': reason.decode().strip(), 'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'second-canonical.json').write_text(json.dumps(failure, indent=2) + '\n')
    original = subprocess.check_output(['git', 'show', BASE + ':' + AUDITOR], cwd=ROOT)
    assert original == (ROOT / AUDITOR).read_bytes(), 'unchanged failing auditor'
    Path(PREFIX + 'audit-before.py').write_bytes(original)
    historical = json.loads((ROOT / HISTORICAL).read_bytes())['audit_report']
    rows = []
    for path, identity in sorted(historical['latest_source_inputs'].items()):
        raw = (ROOT / path).read_bytes()
        row = {'path': path, 'historical': identity['sha256'], 'milestone': identity['milestone'],
               'current': sha(raw), 'bytes': len(raw)}
        if row['current'] != row['historical']:
            row['changed'] = True
            row['kind'] = 'documentation' if path.startswith('docs/') and path.endswith('.md') else 'executable'
            row['payload'] = envelope(raw)
        rows.append(row)
    result = {'base': BASE, 'source_report': HISTORICAL,
              'source_report_sha256': sha((ROOT / HISTORICAL).read_bytes()),
              'sources': rows, 'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'audit-census.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'sources': len(rows), 'changed': [{k: row[k] for k in ('path', 'kind', 'historical', 'current')}
                     for row in rows if row.get('changed')]}))


if __name__ == '__main__':
    main()
