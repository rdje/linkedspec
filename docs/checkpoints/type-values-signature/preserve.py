"""Preserve the complete649 draft and exact failed candidate without nested asset copies."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-signature/'
V = '.linkedspec-data/verification/type-values-'
assert sys.argv[1:] in ([], ['--baseline'])
record = json.loads((ROOT / c.CLAIM).read_bytes())
bindings = record['claims'][0]['durability']['inputs']
assert len(bindings) == 649
modes = json.loads((ROOT / (c.PREFIX + 'publication-portable.json')).read_bytes())['input_modes']
identities = {}
for row in bindings:
    item = c.read(row['path'])
    assert item['sha256'] == row['sha256'] and item['mode'] == modes[row['path']], row['path']
    identities[row['path']] = {key: item[key] for key in ('sha256', 'mode')}
if sys.argv[1:]:
    assert (ROOT / (V + 'signature-readonly.status')).read_text().strip() == '0'
    c.write_new(P + 'baseline.json', dict(returncode=0,
        command=['bash', 'tools/run_python_project_data.sh', c.PREFIX + 'publish.py'],
        combined_output=c.read(V + 'signature-readonly.log'),
        status=c.read(V + 'signature-readonly.status'),
        claim=c.read(c.CLAIM), inputs=identities, producer=c.read(P + 'preserve.py')))
    print('Actual default649 readonly baseline0 retained before bound writes')
else:
    assert (ROOT / (V + 'canonical2.status')).read_text().strip() == '1'
    base = c.run(['git', 'rev-parse', 'HEAD'])
    assert base['returncode'] == 0 and c.decode(base['stdout_base64']).decode().strip() == c.BASE
    rows = c.run(['git', 'diff', '--cached', '--name-status', '-z'])
    assert rows['returncode'] == 0
    fields = c.decode(rows['stdout_base64']).decode().split('\0')[:-1]
    assert len(fields) == 376 and all(kind in ('A', 'M') for kind in fields[::2])
    candidate = {}
    for kind, path in zip(fields[::2], fields[1::2]):
        blob = c.run(['git', 'show', ':' + path])
        assert blob['returncode'] == 0
        raw = c.decode(blob['stdout_base64'])
        item = c.read(path)
        # Mutable continuity and the claim itself are retained inline. Other
        # bytes already have immutable tracked locations in the complete draft.
        if path in identities:
            assert c.sha(raw) == item['sha256'] == identities[path]['sha256'], path
            saved = dict(sha256=item['sha256'], mode=item['mode'], retained_path=path)
        else:
            saved = dict(sha256=c.sha(raw), mode=item['mode'], base64=c.encode(raw))
        candidate[path] = dict(status=kind, **saved)
    before_paths = (
        'tests/language-readiness/verify_objectives.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py',
        'docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md',
        'KNOWLEDGE_MAP.md', c.PREFIX + 'publish.py', c.PREFIX + 'README.md')
    before = {path: c.read(path) for path in before_paths}
    c.write_new(P + 'preservation.json.gz', dict(original_claim=c.read(c.CLAIM),
        inputs=identities, before=before, producer=c.read(P + 'preserve.py'),
        failed_candidate=dict(base_commit=c.BASE, changes=candidate),
        canonical=dict(command=['bash', 'tools/run_ci_local.sh'], returncode=1,
                       combined_output=c.read(V + 'canonical2.log'), status=c.read(V + 'canonical2.status')),
        scope='Complete649-input uncommitted draft and exact188-file staged source delta. '
              'Unchanged bound artifact bytes retain their original tracked locations with '
              'hash/mode identities; mutable continuity and claim bytes are inline. Planned '
              'changed inputs have full before bytes. All later mutations must retain their '
              'before bytes; no synthetic historical commit or refreshed historical hash. '
              'The actual default readonly baseline is separately retained before bound writes.'), packed=True)
    print('Whole649 draft and exact188-file failed source candidate retained')
