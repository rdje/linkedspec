"""Independently accept complete source, recovery, channel and filesystem evidence."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
BASE = '224d5443af794d4e5ade6e80bd8f09145ee7b5b3'
SOURCE = 'b2156813fffed53622e640583a46a4ca94186a08'
SURFACES = [('change_history', 'CHANGES.md', 'changes', rb'^## '),
            ('engineering_notes', 'DEVELOPMENT_NOTES.md', 'development-notes',
             rb'^(?:- 20\d{2}-\d{2}-\d{2}\b|## )')]
LABELS = ['exact source/suffix/manifest', 'ordinary EOF whitespace', 'archive-only query',
          'resulting pressure', 'below-pressure no-op', 'orphan recovery',
          'orphan corrupt rejection', 'orphan symbolic rejection', 'pending recovery',
          'pending missing rejection', 'pending corrupt rejection', 'pending symbolic rejection',
          'pending metadata rejection', 'rewrite rejection', 'reorder rejection',
          'preamble rejection', 'uncommitted-byte-pressure rejection', 'uncommitted-line-pressure rejection']
STATES = ['fresh'] * 5 + ['orphan', 'orphan-corrupt', 'orphan-symbolic', 'pending',
          'pending-missing', 'pending-corrupt', 'pending-symbolic', 'pending-metadata',
          'rewrite', 'reorder', 'preamble', 'uncommitted-byte-pressure', 'uncommitted-line-pressure']
FAILURES = {1, 8, 9, 10, 11, 12}
PATH_LABELS = ['relative destination', 'traversal rejection', 'absolute rejection',
               'symbolic parent rejection', 'Git metadata rejection']


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(value):
    assert value['encoding'] == 'gzip-base64', 'lossless channel encoding'
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'channel bytes and digest'
    return raw


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':')).encode() + b'\n'


def source(path, revision=SOURCE):
    return subprocess.check_output(['git', 'show', revision + ':' + path], cwd=ROOT)


def identity(path, raw):
    return {'path': path, 'kind': 'regular', 'bytes': len(raw), 'sha256': sha(raw)}


def check(data, outer, epoch, verify_git=True):
    original = epoch == 'before'
    assert data['complete'] is True and data['original'] is original, 'complete actual epoch'
    assert data['revision'] == SOURCE and data['producer_revision'] == BASE, 'exact fixture/producer boundaries'
    assert data['instrument_sha256'] == sha((ROOT / 'tools/test_document_history_rollover.py').read_bytes()), 'actual regression producer'
    assert len(data['source_inputs']) == 91, 'complete immutable fixture population'
    files = {}
    for entry in data['source_inputs']:
        assert entry['path'] not in files, 'unique immutable fixture inputs'
        files[entry['path']] = decode(entry)
        if verify_git:
            assert files[entry['path']] == source(entry['path']), 'exact immutable Git fixture bytes'
    assert list(files) == sorted(files), 'ordered immutable fixture inputs'
    tool = decode(data['producer'])
    assert tool == (source('tools/roll_document_history.pl', BASE) if original else
                    (ROOT / 'tools/roll_document_history.pl').read_bytes()), 'exact actual rollover producer'
    shim = decode(data['git_shim'])
    assert b"args[0] not in ('show', 'rev-parse')" in shim and b"revision + arg[4:]" in shim, 'read-only exact-source Git shim'
    assert len(data['commands']) == 36 and len(data['results']) == 41 and len(data['observations']) == 2, 'complete command/result population'
    names = [surface + ': ' + label for surface, *_ in SURFACES for label in LABELS]
    names += ['report path: ' + label for label in PATH_LABELS]
    assert [r['name'] for r in data['results']] == names, 'ordered actual result identities'
    assert [r['ok'] for r in data['results']] == [not original or i % 18 not in FAILURES for i in range(36)] + [True] * 5, 'original RED/final GREEN groups'
    probes = data['report_path_probes']
    assert [p['name'] for p in probes] == PATH_LABELS and [p['rejected'] for p in probes] == [False, True, True, True, True], 'actual report destination guards'
    assert [p['input'] for p in probes[:3]] == ['docs/checkpoints/rollover-path-probe.json', '../rollover-path-probe.json', '/dev/null'] and probes[4]['input'] == '.git/rollover-path-probe.json', 'exact report-path inputs'
    run_tree = data['commands'][0]['cwd'].rsplit('/', 1)[0]
    assert probes[3]['input'] == run_tree + '/report-escape/report.json', 'exact symbolic report escape'
    assert data['prior_report_guard'] == {'lexical_accepts': True, 'resolved_inside': False}, 'actual prior lexical report-guard witness'
    assert outer['complete'] is True and outer['epoch'] == epoch and outer['base'] == BASE, 'complete guarded outer capture'
    assert outer['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture producer'
    assert outer['inputs_before'] == outer['inputs_after'], 'outer producer guards'
    for path, digest in outer['inputs_before'].items():
        assert digest == sha((ROOT / path).read_bytes()), 'current outer producer inputs'
    expected_command = ['bash', 'tools/run_python_project_data.sh', 'tools/test_document_history_rollover.py']
    if original:
        expected_command.append('--original')
    expected_command += ['--report', Path(PREFIX + epoch + '.json').relative_to(ROOT).as_posix()]
    assert outer['command'] == expected_command, 'actual complete capture command'
    assert outer['result_sha256'] == sha((json.dumps(data, indent=2) + '\n').encode()), 'actual captured result identity'
    assert outer['exit'] == (1 if original else 0) and decode(outer['stderr']) == b'', 'actual unfiltered outer exit/diagnostics'
    tap = []
    for i, row in enumerate(data['results'], 1):
        tap.append(('ok' if row['ok'] else 'not ok') + f' {i} - ' + row['name'])
        if not row['ok']:
            tap.append('# ' + row['reason'])
    tap.append('1..41')
    assert decode(outer['stdout']) == ('\n'.join(tap) + '\n').encode(), 'complete ordered outer TAP'

    for si, (surface, current, family, boundary) in enumerate(SURFACES):
        observation = data['observations'][si]
        assert observation['surface'] == surface and observation['source_path'] == current, 'exact surface identity'
        manifest_path = f'docs/history/{family}/manifest.jsonl'
        head, old_manifest = files[current], files[manifest_path]
        old_lines = old_manifest.splitlines(keepends=True)
        old_rows = [json.loads(line) for line in old_lines]
        archive_paths = [r['target_path'] for r in old_rows[1:]]
        assert all(p in files for p in archive_paths), 'all immutable archive inputs'
        starts = [m.start() for m in re.finditer(boundary, head, re.M)]
        preamble = head[:starts[0]]
        records = [head[start: starts[i + 1] if i + 1 < len(starts) else len(head)]
                   for i, start in enumerate(starts)]
        title = b'## 2026-10-06 rollover fixture\n' if si == 0 else b'- 2026-10-06 rollover fixture\n'
        fresh = title + b'x' * 25_000 + b'\n\n'
        candidate = preamble + fresh + b''.join(records)
        assert decode(observation['candidate']) == candidate, 'independent original pressure fixture'
        final_root, manifest, part = (decode(observation[k]) for k in ('root', 'manifest', 'archive'))
        lines = manifest.splitlines(keepends=True)
        row = json.loads(lines[1])
        assert lines[2:] == old_lines[1:] and json.loads(lines[0]) == dict(old_rows[0], segment_count=len(old_rows)), 'exact prior manifest rows/count'
        assert row['source_commit'] == SOURCE and row['source_blob'] == subprocess.check_output(
            ['git', 'rev-parse', SOURCE + ':' + current], cwd=ROOT).decode().strip(), 'exact bound source identity'
        assert head.endswith(part) and re.match(boundary, part), 'exact complete clean-source suffix'
        assert part == b''.join(head.splitlines(keepends=True)[row['source_start_line'] - 1:row['source_end_line']]), 'exact source line interval'
        assert row['source_end_line'] == len(head.splitlines()) and row['byte_count'] == len(part) and row['line_count'] == len(part.splitlines()) and row['sha256'] == sha(part), 'exact suffix endpoint/count/digest'
        segment_id = f"{int(old_rows[1]['segment_id']) - 1:04d}"
        expected_row = dict(old_rows[1], byte_count=len(part), line_count=len(part.splitlines()),
                            segment_id=segment_id, sha256=sha(part), source_commit=SOURCE,
                            source_blob=row['source_blob'], source_start_line=row['source_start_line'],
                            source_end_line=len(head.splitlines()),
                            target_path=f'docs/history/{family}/segment-{segment_id}-{sha(part)[:12]}.md',
                            retrieval_command=f'perl tools/read_document_history.pl --surface {surface} --segment {segment_id}')
        assert row == expected_row and row['immutable'] is True, 'exact complete segment schema/string identity'
        prefix = head[:-len(part)]
        complete = preamble + fresh + prefix[len(preamble):]
        removed = decode(observation['removed_separator'])
        assert final_root + removed == complete and removed == (b'' if original else b'\n'), 'exact retained terminal separator'
        assert preamble + final_root[len(preamble) + len(fresh):] + removed + part == head, 'lossless full clean-root reconstruction'
        assert len(final_root.splitlines()) <= 256 and len(final_root) <= 32_768, 'unchanged retained-root bounds'
        queried = part + b''.join(files[p] for p in archive_paths)
        target = row['target_path']

        base_files = {p: identity(p, files[p]) for p in archive_paths}
        base_files.update({'tools/roll_document_history.pl': identity('tools/roll_document_history.pl', tool),
                           'tools/read_document_history.pl': identity('tools/read_document_history.pl', files['tools/read_document_history.pl'])})

        def guards(root, manifest_bytes, extra=None):
            entries = dict(base_files)
            entries[current] = identity(current, root)
            entries[manifest_path] = identity(manifest_path, manifest_bytes)
            entries.update(extra or {})
            return [entries[p] for p in sorted(entries)]

        for ci, state in enumerate(STATES):
            command = data['commands'][si * 18 + ci]
            cwd = command['cwd']
            assert re.fullmatch(r'\.linkedspec-data/scratch/history-rollover-eof/(?:original|repaired)-[a-z0-9_]+/' + surface + '-' + state, cwd), 'repo-local exact fixture view'
            argv = command['command']
            expected = ['perl', 'tools/roll_document_history.pl', '--surface', surface, '--apply']
            if ci == 1:
                assert Path(argv[0]).name == 'git', 'actual Git whitespace executable'
                expected = [argv[0], 'diff', '--no-index', '--check', '/dev/null', current]
            elif ci == 2:
                expected = ['perl', 'tools/read_document_history.pl', '--surface', surface, '--all']
            elif ci == 3:
                expected[-1] = '--check'
            assert argv == expected, 'actual public command identity'
            stdout, stderr = decode(command['stdout']), decode(command['stderr'])
            root, before_manifest, extra = candidate, old_manifest, {}
            if ci in (1, 2, 3, 4):
                root, before_manifest, extra = final_root, manifest, {target: identity(target, part)}
            elif state.startswith('orphan') or state.startswith('pending'):
                before_manifest = manifest if state.startswith('pending') else old_manifest
                if not state.endswith('missing'):
                    extra[target] = identity(target, part + b'changed\n' if state.endswith('corrupt') else part)
                if state.endswith('symbolic'):
                    extra[target] = {'path': target, 'kind': 'symbolic', 'target': cwd + '/fixture-target.md'}
                    extra['fixture-target.md'] = identity('fixture-target.md', part)
                if state == 'pending-metadata':
                    before_manifest = lines[0] + canonical(dict(row, source_blob='0' * 40)) + b''.join(lines[2:])
            elif state == 'rewrite':
                root = preamble + fresh + b''.join(records).replace(b'## ', b'## changed ', 1)
            elif state == 'reorder':
                root = preamble + fresh + records[1] + records[0] + b''.join(records[2:])
            elif state == 'preamble':
                root = preamble + b'changed preamble\n' + fresh + b''.join(records)
            elif state == 'uncommitted-byte-pressure':
                root = preamble + title + b'x' * 33_000 + b'\n\n' + b''.join(records)
            elif state == 'uncommitted-line-pressure':
                root = preamble + title + b'x\n' * 500 + b'\n' + b''.join(records)
            before_guard = guards(root, before_manifest, extra)
            assert command['inputs_before'] == before_guard, 'complete exact command inputs'
            after_guard = before_guard
            if ci in (0, 5, 8):
                after_guard = guards(final_root, manifest, {target: identity(target, part)})
            if original and 8 <= ci <= 12:
                dup = dict(row, segment_id=f"{int(row['segment_id']) - 1:04d}")
                dup['target_path'] = f"docs/history/{family}/segment-{dup['segment_id']}-{row['sha256'][:12]}.md"
                dup['retrieval_command'] = f"perl tools/read_document_history.pl --surface {surface} --segment {dup['segment_id']}"
                duplicate_manifest = canonical(dict(old_rows[0], segment_count=len(old_rows) + 1)) + canonical(dup) + b''.join(before_manifest.splitlines(keepends=True)[1:])
                after_guard = guards(final_root, duplicate_manifest, dict(extra, **{dup['target_path']: identity(dup['target_path'], part)}))
            assert command['inputs_after'] == after_guard, 'exact publication/no-write guard'
            expected_exit = 0
            if ci == 1:
                expected_exit = 3 if original else 1
                assert stderr == b'' and stdout == (f'{current}:{len(final_root.splitlines())}: new blank line at EOF.\n'.encode() if original else b''), 'actual distinguishing whitespace diagnostic'
            elif ci == 2:
                assert stdout == queried and stderr == b'', 'exact archive-only reader bytes'
            elif ci >= 6 and ci not in (8,) and not (original and 9 <= ci <= 12):
                expected_exit = 2 if ci == 9 else 255
                reason = b'target' if ci in (6, 7, 9, 10, 11) else b'pending' if ci == 12 else b'record order/content changed' if ci in (13, 14) else b'preamble' if ci == 15 else b'without archiving uncommitted records'
                assert stdout == b'' and reason in stderr, 'exact invalid-input diagnostic'
            else:
                assert stderr == b'' and stdout.startswith(b'document-history rollover'), 'actual successful public channels'
                if ci == 8 and not original:
                    assert b'recovered pending generation' in stdout, 'actual pending recovery channel'
            assert command['exit'] == expected_exit, 'exact actual public exit'
    return len(files)


def main():
    before = json.loads(Path(PREFIX + 'before.json').read_bytes())
    after = json.loads(Path(PREFIX + 'after.json').read_bytes())
    bouter = json.loads(Path(PREFIX + 'before-command.json').read_bytes())
    aouter = json.loads(Path(PREFIX + 'after-command.json').read_bytes())
    count = check(before, bouter, 'before')
    assert check(after, aouter, 'after') == count
    assert before['source_inputs'] == after['source_inputs'], 'unchanged complete fixture source bytes'
    current = (ROOT / 'tools/roll_document_history.pl').read_bytes()
    inverse = current.replace(b"# A separator belongs between records, not at the hot root's EOF. Keep archive\n# bytes exact; the bound clean source commit/blob retains the omitted LF bytes\n# when reconstructing the original prefix and its complete source suffix.\n$retained =~ s/\\n{2,}\\z/\\n/;\n", b'', 1)
    inverse = inverse.replace(b"    # The numeric eligibility check gives this local scalar a numeric flag.\n    # Restore its string identity before canonical JSON comparison with the row.\n    $pending_id = sprintf('%04d', $pending_id);\n", b'', 1)
    inverse = inverse.replace(b'    die "$surface pending rollover metadata conflicts with clean HEAD\\n"\n        if ($pending->{source_commit} // \'\') eq $source_commit;\n', b'', 1)
    assert inverse == source('tools/roll_document_history.pl', BASE), 'exact three bounded producer edits'
    gate = (ROOT / 'scripts/check_document_history.sh').read_bytes()
    assert gate == source('scripts/check_document_history.sh', BASE) + b'bash tools/run_python_project_data.sh tools/test_document_history_rollover.py\n', 'actual retained-producer gate integration'
    diagnosis = json.loads(Path(PREFIX + 'diagnosis.json').read_bytes())
    assert diagnosis['complete'] and diagnosis['instrument_sha256'] == sha(Path(PREFIX + 'diagnosis.py').read_bytes()) and diagnosis['probe_sha256'] == sha(Path(PREFIX + 'diagnose.pl').read_bytes()), 'causal producer identity'
    for command, mode, expected in zip(diagnosis['commands'], ['original', 'fixed'], [1, 0]):
        assert command['exit'] == expected and decode(command['stderr']) == b'', 'actual causal RED/GREEN exit'
        value = json.loads(decode(command['stdout']))
        assert value['mode'] == mode and value['comparison'] is (mode == 'fixed') and value['before'] == value['actual'] == '{"segment_id":"4966"}' and value['coerced'] == '{"segment_id":4966}', 'actual distinguishing JSON type oracle'
    controls = []

    def corrupt(name, mutate, reason):
        bad, outer = copy.deepcopy(after), copy.deepcopy(aouter)
        mutate(bad, outer)
        assert (bad, outer) != (after, aouter), 'effective evidence mutation'
        outer['result_sha256'] = sha((json.dumps(bad, indent=2) + '\n').encode())
        try:
            check(bad, outer, 'after', verify_git=False)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'reason': reason, 'observed': 'RED'})
        else:
            raise AssertionError('accepted corruption: ' + name)

    for i in range(36):
        corrupt(f'false exit {i}', lambda d, o, i=i: d['commands'][i].update(exit=7), 'exact actual public exit')
    for i in range(91):
        corrupt(f'missing immutable input {i}', lambda d, o, i=i: d['source_inputs'].pop(i), 'complete immutable fixture population')
    for si in range(2):
        corrupt(f'lost separator {si}', lambda d, o, si=si: d['observations'][si].update(removed_separator=envelope(b'')), 'exact retained terminal separator')
        corrupt(f'false source suffix {si}', lambda d, o, si=si: d['observations'][si].update(archive=envelope(decode(d['observations'][si]['archive'])[:-1])), 'exact complete clean-source suffix')
        corrupt(f'forged prior row {si}', lambda d, o, si=si: d['observations'][si].update(manifest=envelope(decode(d['observations'][si]['manifest']).replace(b'"immutable":true', b'"immutable":false', 2))), 'exact prior manifest rows/count')
    corrupt('missing command', lambda d, o: d['commands'].pop(), 'complete command/result population')
    corrupt('forged instrument', lambda d, o: d.update(instrument_sha256='0' * 64), 'actual regression producer')
    corrupt('invented final failure', lambda d, o: d['results'][1].update(ok=False), 'original RED/final GREEN groups')
    corrupt('lost outer diagnostic', lambda d, o: o.update(stderr=envelope(b'warning\n')), 'actual unfiltered outer exit/diagnostics')
    corrupt('missing TAP tail', lambda d, o: o.update(stdout=envelope(decode(o['stdout'])[:-6])), 'complete ordered outer TAP')
    corrupt('lost filesystem guard', lambda d, o: d['commands'][0]['inputs_before'].pop(), 'complete exact command inputs')
    corrupt('false rejection writes', lambda d, o: d['commands'][12]['inputs_after'].pop(), 'exact publication/no-write guard')
    corrupt('false pending stdout', lambda d, o: d['commands'][8].update(stdout=envelope(b'document-history rollover: archived again\n')), 'actual pending recovery channel')
    corrupt('forged rollover producer', lambda d, o: d.update(producer=envelope(decode(d['producer']) + b'# forged\n')), 'exact actual rollover producer')
    corrupt('changed public command', lambda d, o: d['commands'][0]['command'].__setitem__(-1, '--foreign'), 'actual public command identity')
    segment_id = json.loads(decode(after['observations'][0]['manifest']).splitlines()[1])['segment_id']
    corrupt('numeric segment ID', lambda d, o: d['observations'][0].update(manifest=envelope(
        decode(d['observations'][0]['manifest']).replace(
            f'"segment_id":"{segment_id}"'.encode(), f'"segment_id":{segment_id}'.encode(), 1))),
        'exact complete segment schema/string identity')
    bad, outer = copy.deepcopy(before), copy.deepcopy(bouter)
    bad['results'][1]['ok'] = True
    outer['result_sha256'] = sha((json.dumps(bad, indent=2) + '\n').encode())
    try:
        check(bad, outer, 'before', verify_git=False)
    except AssertionError as error:
        assert str(error) == 'original RED/final GREEN groups'
        controls.append({'name': 'false original GREEN', 'reason': str(error), 'observed': 'RED'})
    else:
        raise AssertionError('accepted false original GREEN')
    for i in range(5):
        corrupt(f'false report-path result {i}', lambda d, o, i=i: d['report_path_probes'][i].update(
            rejected=not d['report_path_probes'][i]['rejected']), 'actual report destination guards')
    corrupt('missing report-path probe', lambda d, o: d['report_path_probes'].pop(), 'actual report destination guards')
    for field in ('lexical_accepts', 'resolved_inside'):
        corrupt('false prior report witness ' + field, lambda d, o, field=field: d['prior_report_guard'].update(
            {field: not d['prior_report_guard'][field]}), 'actual prior lexical report-guard witness')
    summary = {'complete': True, 'revision': BASE, 'fixture_revision': SOURCE,
               'immutable_inputs': count, 'commands_per_epoch': 36, 'groups': 41,
               'original_red_groups': 12, 'repaired_green_groups': 41, 'surfaces': 2,
               'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps({k: v for k, v in summary.items() if k not in ('controls',)}))
    print(str(len(controls)) + ' effective evidence controls RED')


if __name__ == '__main__':
    main()
