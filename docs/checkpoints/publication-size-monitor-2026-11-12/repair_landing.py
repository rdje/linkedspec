"""Route the complete new instructions and use the existing open-owner vocabulary."""
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'landing-repair'
OUT.mkdir()
CI = Path('docs/linkedspec-book/src/development/local-ci-and-regression.md')
WORKFLOW = Path('docs/linkedspec-book/src/development/documentation-workflow.md')
TREE = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
REGISTRY = Path('doctrine/readme_stability/routes.jsonl')
query = json.loads((BASE / 'workflow-inputs/result.json').read_bytes())
assert query['claim_records'] == 207 and not query['live_intersections']
assert (BASE / 'launches/review-workflow-bindings/exit.txt').read_text() == '0\n'
paths = [CI, WORKFLOW, TREE, REGISTRY, Path('TOOLBOX.md'), Path('tools/check_claim_verification.py'),
    BASE / 'workflow-inputs/result.json', Path(__file__).resolve().relative_to(ROOT)]


def freeze(tag):
    rows = {}
    with tarfile.open(OUT / (tag + '.tar.gz'), 'x:gz') as packed:
        for path in paths:
            body = path.read_bytes()
            rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            packed.add(path, arcname=str(path), recursive=False)
    with tarfile.open(OUT / (tag + '.tar.gz')) as packed:
        assert set(packed.getnames()) == rows.keys()
        for member in packed:
            body = packed.extractfile(member).read(); row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
    (OUT / (tag + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


freeze('before')
ci, workflow = CI.read_text(), WORKFLOW.read_text()
start = ci.index('### Outgoing publication byte budget\n')
end = ci.index('### Task-evidence coverage\n', start)
section = ci[start:end]
assert len(section.splitlines()) == 26
routed = section.replace('### Outgoing publication byte budget', '## Outgoing publication byte budget', 1)
anchor = '## Publishing a measured result\n'
assert workflow.count(anchor) == 1 and 'Outgoing publication byte budget' not in workflow
WORKFLOW.write_text(workflow.replace(anchor, routed + anchor, 1))
assert routed in WORKFLOW.read_text(), 'destination established before source removal'
pointer = ' Publish earlier when the [outgoing byte budget](documentation-workflow.md#outgoing-publication-byte-budget) requires it.'
anchor = 'This means a normal batch pays for focused proof on each commit and full proof once before push. Local Git hooks remain bypassable, and hosted CI remains disabled, so this is strong normal-workflow enforcement rather than a claim of literal impossibility.'
assert ci.count(anchor) == 1
CI.write_text((ci[:start] + ci[end:]).replace(anchor, anchor + pointer, 1))
owner_note = 'A claim’s repair task uses status `pending`, `active`, or `blocked`. Use `active`\nwhile that repair work is in progress.\n\n'
anchor = 'The registered checker validates disclosure and declared regular tracked byte identities;\n'
assert WORKFLOW.read_text().count(anchor) == 1
WORKFLOW.write_text(WORKFLOW.read_text().replace(anchor, owner_note + anchor, 1))
source = TREE.read_text(); begin = source.index('- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.30`'); finish = source.index('\n- ID:', begin + 1)
parent = source[begin:finish]
assert parent.count('  Status: `in_progress`') == 1
TREE.write_text(source[:begin] + parent.replace('  Status: `in_progress`', '  Status: `active`', 1) + source[finish:])
assert REGISTRY.read_bytes() == subprocess.check_output(['git', 'show', 'HEAD:' + str(REGISTRY)])
assert Path('docs/linkedspec-book/src/SUMMARY.md').read_bytes() == subprocess.check_output(['git', 'show', 'HEAD:docs/linkedspec-book/src/SUMMARY.md'])
routes = [json.loads(line) for line in REGISTRY.read_bytes().splitlines()]
diagnostics = next(row for row in routes if row.get('id') == 'diagnostics')
observations = []
for name in diagnostics['members']:
    body = Path(name).read_bytes(); count = len(body.splitlines())
    assert count <= diagnostics['limits']['max_lines_per_file'] and len(body) <= diagnostics['limits']['max_bytes_per_file']
    observations.append(dict(path=name, lines=count, bytes=len(body)))
assert sum(row['lines'] for row in observations) <= diagnostics['limits']['max_total_lines']
assert sum(row['bytes'] for row in observations) <= diagnostics['limits']['max_total_bytes']
public = next(row for row in routes if row.get('id') == 'public_reference')
assert len(WORKFLOW.read_bytes().splitlines()) <= public['limits']['max_lines_per_file']
assert len(WORKFLOW.read_bytes()) <= public['limits']['max_bytes_per_file']
assert len(CI.read_bytes().splitlines()) == 2048
freeze('after')
(OUT / 'result.json').write_text(json.dumps(dict(routed_section_lines=26, ci_lines=2048,
    workflow_lines=len(WORKFLOW.read_bytes().splitlines()), diagnostics=observations,
    source_section_sha256=hashlib.sha256(section.encode()).hexdigest(), routed_section_sha256=hashlib.sha256(routed.encode()).hexdigest(),
    parent_owner_status='active', registry_changed=False, summary_changed=False,
    scope='Complete section routed with heading-only adjustment and a short CI pointer; existing page/limits/registry/SUMMARY retained. Claim owner uses existing accepted vocabulary; no checker, measurement, claim hash or SDK change.'), indent=2, sort_keys=True) + '\n')
print('Routed exact26 lines; CI2048, existing workflow within5000; parent repair owner active, contract unchanged')
