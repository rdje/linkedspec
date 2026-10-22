"""Retain exact required rollovers and admit only their measured member overhead."""
import copy
import json
import re
import subprocess
import common as c
import context

REGISTRY = 'doctrine/readme_stability/routes.jsonl'
ADR = 'docs/decisions/0137-finite-selection-history-members.md'
INDEX = 'docs/decisions/INDEX.md'


def canonical(value):
    return json.dumps(value,sort_keys=True,separators=(',',':'))


def contract(surface):
    keys = ('authority','control','lifecycle','member_limits','members','owner','route_targets','state','verifier')
    return dict(**{key:surface[key] for key in keys},transition_owners=surface['transition'].get('owners'))


def main():
    c.write_new('history-inputs.json.gz',context.snapshot())
    tree_path = 'docs/tasks/TYPE-REFERENCE-BOOK.md'
    tree = c.source(tree_path).read_text()
    marker = '  Diagnostic correction owned here:'
    assert tree.count(marker) == 1
    tree = tree.replace(marker,'  Commit prerequisite owned here: Required complete change/note records trigger real history rollovers. Preserve every immutable member and exact clean-source suffix; ADR0137 admits only the two measured members/manifest overhead and its own decision/index lines. No runtime scope expansion or future archive reserve. Verification and claim include this prerequisite.\n'+marker,1)
    c.source(tree_path).write_text(tree)
    records = {
        'change_history':('CHANGES.md','changes',
            '## 2026-10-21 - TYPE-REFERENCE-BOOK.1.2.10: callable count/first\n\n'
            'Execute deferred count/first with compatible arity, terminal/effect and stored-value semantics; guard ordinary free harray inputs. Fixed232 passes after107 accepted RED/125 controls. Permanent native/fresh cases, source faults and worked book examples are retained at docs/checkpoints/type-array-count-first/. Exact canonical receipt and normal hooks govern landing. Required lossless history rollovers use finite ADR0137;11/12/14 remain separate.\n\n'),
        'engineering_notes':('DEVELOPMENT_NOTES.md','development-notes',
            '## 2026-10-21 - count/first10\n\n'
            'Preflight receiver terminal shape before effects; free calls require one argument. Preserve the stored first value. See docs/checkpoints/type-array-count-first/ for public contract, producer corrections and finite history proof.\n\n'),
    }
    old_registry = c.read(REGISTRY)
    lines = c.source(REGISTRY).read_text().splitlines()
    rows = [json.loads(line) for line in lines]
    old = {row['id']:copy.deepcopy(row) for row in rows if row.get('type') == 'surface'}
    new = copy.deepcopy(old)
    results = {}
    for surface,(root,family,record) in records.items():
        before = c.read(root)
        manifest_path = 'docs/history/'+family+'/manifest.jsonl'
        manifest_before = c.read(manifest_path)
        old_members = {path.relative_to(c.ROOT).as_posix():c.identity(path.relative_to(c.ROOT).as_posix())
            for path in (c.ROOT/'docs/history'/family).glob('*') if path.is_file()}
        value = c.decode(before['base64']).decode()
        start = re.search(r'^## ',value,re.M).start()
        c.source(root).write_text(value[:start]+record+value[start:])
        pressure = c.run(['perl','tools/roll_document_history.pl','--surface',surface,'--check'])
        c.write_new(surface+'-pressure.json.gz',dict(before=before,manifest_before=manifest_before,
            record=record,run=pressure,old_members=old_members))
        assert pressure['returncode'] != 0 and b'rollover required' in c.decode(pressure['stderr_base64'])
        applied = c.run(['perl','tools/roll_document_history.pl','--surface',surface,'--apply'])
        assert applied['returncode'] == 0
        checked = c.run(['perl','tools/roll_document_history.pl','--surface',surface,'--check'])
        assert checked['returncode'] == 0
        prior_rows = c.decode(manifest_before['base64']).splitlines(keepends=True)
        current_rows = c.source(manifest_path).read_bytes().splitlines(keepends=True)
        assert current_rows[2:] == prior_rows[1:]
        entry = json.loads(current_rows[1])
        archived = c.source(entry['target_path']).read_bytes()
        source = subprocess.check_output(['git','show',c.BASE+':'+root],cwd=c.ROOT)
        assert c.decode(before['base64']) == source
        assert entry['source_commit'] == c.BASE and source.endswith(archived)
        assert archived == b''.join(source.splitlines(keepends=True)[entry['source_start_line']-1:entry['source_end_line']])
        assert len(archived) == entry['byte_count'] and c.sha(archived) == entry['sha256']
        actual_root = c.source(root).read_bytes()
        assert actual_root.replace(record.encode(),b'',1)+archived == source
        for path,item in old_members.items():
            if path != manifest_path:
                assert c.identity(path) == item
        members = [c.ROOT/root]+list((c.ROOT/'docs/history'/family).glob('*'))
        limit = new[surface]
        limit['limits']['max_files'] = len(members)
        limit['member_limits'][manifest_path] = dict(max_bytes=sum(map(len,current_rows)),max_lines=len(current_rows))
        assert limit['limits']['max_files'] == old[surface]['limits']['max_files']+1
        assert sum(p.read_bytes().count(b'\n') for p in members) <= limit['limits']['max_total_lines']
        assert sum(p.stat().st_size for p in members) <= limit['limits']['max_total_bytes']
        results[surface] = dict(applied=applied,checked=checked,entry=entry,
            current=c.read(root),manifest=c.read(manifest_path),segment=c.read(entry['target_path']),
            old_members=old_members,combined_original_sha256=c.sha(source),
            files=len(members),lines=sum(p.read_bytes().count(b'\n') for p in members))
    old_cap = c.run(['perl','scripts/check_readme_routing_pressure.pl','--report'])
    c.write_new('history-old-cap.json.gz',dict(run=old_cap,registry=old_registry,rollovers=results))
    assert old_cap['returncode'] != 0
    assert b'change_history' in c.decode(old_cap['stdout_base64'])+c.decode(old_cap['stderr_base64'])
    assert b'engineering_notes' in c.decode(old_cap['stdout_base64'])+c.decode(old_cap['stderr_base64'])
    def body():
        out = '# ADR 0137: Finite selection history members\n\n- Date: 2026-10-21\n- Status: accepted engineering maintenance under `TYPE-REFERENCE-BOOK.1.2.10`; exact canonical admission required\n- Tags: history, capacity, continuity, verification\n'
        for surface in ('change_history','engineering_notes','decisions'):
            out += '\n## Exact '+surface+' authorization\n\n- Routed surface: `'+surface+'`\n'
            out += '- Previous routed limits: `'+canonical(old[surface]['limits'])+'`\n'
            out += '- New routed limits: `'+canonical(new[surface]['limits'])+'`\n'
            if surface != 'decisions':
                out += '- Previous routed contract: `'+canonical(contract(old[surface]))+'`\n'
                out += '- New routed contract: `'+canonical(contract(new[surface]))+'`\n'
        out += '\n## Decision and verification\n\nRequired complete count/first records cross both90% hot-shard boundaries. The normal roller preserves exact clean a8bd8620a suffixes, Git provenance and all older immutable bytes; unchanged routing limits reject the two new archive members and exact manifest overhead. Engineering-maintenance precedent permits only those measured members and this sole decision/index overhead. Root, per-file, aggregate, tool and unrelated limits stay exact. No future member or unlimited PNT reserve is granted.\n\nThe owning checkpoint retains full original sources, actual pressure/refusal/apply/check channels and independent suffix/current/manifest reconstruction. Source-closed readonly review checks every prior immutable identity and these exact transitions; actual staged routing/doctrine/canonical proof and normal hooks govern admission. No dependency implementation changes. Owner: docs/tasks/TYPE-REFERENCE-BOOK.md; review: docs/checkpoints/type-array-count-first/publish.py through tools/run_python_project_data.sh.\n'
        return out
    new['decisions']['limits']['max_files'] += 1
    # Physical lines, rather than a reserve; the numeric width cannot affect line count.
    new['decisions']['limits']['max_total_lines'] += body().count('\n')+1
    adr = body()
    assert adr.count('\n')+1 == new['decisions']['limits']['max_total_lines']-old['decisions']['limits']['max_total_lines']
    with (c.ROOT/ADR).open('x') as output:
        output.write(adr)
    before_index = c.read(INDEX)
    value = c.decode(before_index['base64']).decode()
    row = '| [0137](0137-finite-selection-history-members.md) | Two measured history members for count/first continuity | 2026-10-21 | accepted engineering maintenance; canonical admission required | history, capacity, verification |\n'
    marker = '\n## How to add a record\n'
    assert value.count(marker) == 1
    c.source(INDEX).write_text(value.replace(marker,row+marker,1))
    for index,row in enumerate(rows):
        if row.get('id') in ('change_history','engineering_notes','decisions'):
            lines[index] = canonical(new[row['id']])
    c.source(REGISTRY).write_text('\n'.join(lines)+'\n')
    c.write_new('history-result.json.gz',dict(before_registry=old_registry,after_registry=c.read(REGISTRY),
        before_index=before_index,after_index=c.read(INDEX),adr=c.read(ADR),
        old=old,new=new,rollovers=results,scope='Two actual required rollovers and sole decision/index overhead only. All aggregate/root/per-file and unrelated limits stay exact. Production old-cap refusal retained; staged corrected admission remains mandatory.'))
    print('Both exact rollovers retained; finite ADR0137 awaits staged admission')


if __name__ == '__main__':
    main()
