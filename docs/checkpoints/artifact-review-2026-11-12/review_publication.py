"""Recover actual historical maintenance publication without executing writers."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'publication'


def recover(tag):
    rows = json.loads((OUT / (tag + '.json')).read_bytes())
    bodies = {}
    with tarfile.open(OUT / (tag + '.tar.gz')) as archive:
        assert len(archive.getnames()) == len(rows) and set(archive.getnames()) == rows.keys()
        for member in archive:
            path = Path(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts and member.name not in bodies
            body = archive.extractfile(member).read()
            row = rows[member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], 'publication bytes'
            assert member.mode & 0o777 == row['mode'], 'publication full modes'
            bodies[member.name] = body
    return bodies


def validate(inputs, outputs):
    prefix = str(BASE / 'launches') + '/'
    for tag in ('readonly', 'task-links', 'review-publication-query'):
        assert inputs[prefix + tag + '/exit.txt'] == b'0\n', 'publication report status'
        assert gzip.decompress(inputs[prefix + tag + '/stderr.log.gz']) == b'', 'publication report stderr'
    proof, links, query = [json.loads(gzip.decompress(inputs[prefix + tag + '/stdout.log.gz']))
        for tag in ('readonly', 'task-links', 'review-publication-query')]
    assert proof['result'] == links['task_links'] == 'PASS', 'publication proof verdict'
    assert (proof['scoped_rows'], proof['archived_files'], proof['archived_content_bytes'], len(proof['rejected_controls'])) == (1316, 3, 133480, 16), 'publication proof counts'
    assert links['public_queries'] == 3 and query['live_intersections'] == 0 and len(query['rejected_live_binding_controls']) == 6, 'publication binding/query proof'
    retirement = json.loads(inputs[str(BASE / 'retirement.json')])
    cleanup = outputs['docs/ARTIFACT_CLEANUP.md'].decode()
    assert cleanup.count('- Date:') == 1 and '- Date: ' + retirement['at_utc'] in cleanup, 'latest-only cleanup date'
    assert '1316' in cleanup and '133480' in cleanup and 'three' in cleanup, 'cleanup derived counts'
    assert '16' in cleanup and 'no physical reclamation claim' in cleanup, 'cleanup proof boundary'
    card = outputs['docs/knowledge/daily-artifact-log-archival-2026-11-12.md'].decode()
    assert 'readonly16/three public task queries' in card and str(BASE / 'review.py') in card, 'publication fact pointer'
    memory = outputs['MEMORY.md'].decode()
    assert 'active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.4.31` (completed)' in memory, 'completed publication owner'
    assert 'in_flight_uncommitted: none;' in memory and 'Lua80.5' in memory and '1,500,000,000' in memory, 'publication handoff'
    assert retirement['at_utc'] in memory, 'cleanup resume date'
    for name in ('publish.py', 'run_publication.py', 'review_publication.py', 'run_stage.py'):
        assert inputs[str(BASE / name)] == (BASE / name).read_bytes(), 'actual publication producer'
    for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
        assert b'Daily31 retains1316' in outputs[name] and b'Lua80.5' in outputs[name], 'roadmap frontier'
    workflow = outputs['docs/linkedspec-book/src/development/documentation-workflow.md']
    assert b'The November12 review retains all1316' in workflow and str(BASE / 'review.py').encode() in workflow, 'book maintenance proof'
    handoff = outputs['docs/linkedspec-book/src/appendix/backend-handoff.md']
    assert len(handoff.splitlines()) == 4999 and b'Remeasure after daily31' in handoff, 'bounded book frontier'
    before = inputs['LIVE_ACHIEVEMENT_STATUS.md'].decode()
    after = outputs['LIVE_ACHIEVEMENT_STATUS.md'].decode()
    def rows(source):
        return source.split('## Recent Completions\n\n', 1)[1].split('\n## History', 1)[0].strip().splitlines()
    assert len(rows(before)) == len(rows(after)) == 16 and rows(after)[1:] == rows(before)[:15], 'bounded live rows'
    assert outputs[str(OUT / 'rotated-live-row.txt')].decode() == rows(before)[-1] + '\n', 'exact rotated row'
    assert before.split('## History', 1)[1] == after.split('## History', 1)[1], 'exact history pointer'
    claims = json.loads(inputs['docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.31.json'])['claims']
    assert len(claims) == 2 and claims[0]['durability']['status'] == 'gap', 'native custody disclosure'
    assert claims[1]['falsify']['status'] == claims[1]['durability']['status'] == 'gap', 'auxiliary telemetry disclosure'
    origin = json.loads(outputs[str(OUT / 'driver-origin.json')])
    assert origin['source_path'] == 'docs/checkpoints/array-concat-open-arity-julia-2026-11-12/run_stage.py'
    assert hashlib.sha256(inputs[origin['source_path']]).hexdigest() == origin['source_sha256'], 'accepted launcher origin'
    assert hashlib.sha256(inputs[str(BASE / 'run_stage.py')]).hexdigest() == origin['actual_launcher_sha256'], 'actual retained launcher'


inputs, outputs = recover('inputs-before-use'), recover('outputs-after-use')
assert (OUT / 'exit.txt').read_text() == '0\n' and gzip.decompress((OUT / 'stderr.log.gz').read_bytes()) == b''
command = json.loads((OUT / 'command.json').read_bytes())
assert command['cwd'] == '.' and command['argv'][-1] == str(BASE / 'publish.py')
validate(inputs, outputs)
controls = []
for label, mutation, reason in (
    ('failed consumed report', lambda left, right: left.__setitem__(str(BASE / 'launches/readonly/exit.txt'), b'1\n'), 'publication report status'),
    ('unfinished owner', lambda left, right: right.__setitem__('MEMORY.md', right['MEMORY.md'].replace(b'(completed)', b'(active)')), 'completed publication owner'),
    ('lost dated record', lambda left, right: right.__setitem__('docs/ARTIFACT_CLEANUP.md', b'lost'), 'latest-only cleanup date'),
):
    left, right = copy.deepcopy(inputs), copy.deepcopy(outputs)
    mutation(left, right)
    try:
        validate(left, right)
    except AssertionError as failure:
        assert reason in str(failure)
    else:
        raise AssertionError('ineffective publication control:' + label)
    controls.append(label)
print(json.dumps(dict(publication_recovery='PASS', inputs=len(inputs), outputs=len(outputs), corruptions=controls,
    scope='Historical actual producer/report/document bytes and full archived modes; no current doc freshness, SDK/producer replay or complete native closure.')))
