"""Readonly recovery and actual owner-control review for numeric5 canonical admission."""
import gzip
import json
import subprocess
import admission_data as a
c = a.c


def candidate(saved, packed):
    assert c.sha(packed) == saved['candidate']['packed_sha256']
    assert len(packed) == saved['candidate']['packed_bytes']
    raw = gzip.decompress(packed)
    assert c.sha(raw) == saved['candidate']['raw_sha256']
    assert len(raw) == saved['candidate']['raw_bytes']
    return raw


def verify():
    saved = a.load('canonical1.json.gz')
    assert saved['base'] == c.BASE
    assert saved['producer'] == c.read(a.PREFIX + 'preserve.py')
    assert saved['primitives'] == c.read(c.PREFIX + 'common.py')
    original = saved['original']
    assert all(c.read(c.PREFIX + name) == packet for name, packet in original.items())
    manifest = json.loads(c.decode(original['publication-inputs.json']['base64']))
    publication = json.loads(c.decode(original['publication.json']['base64']))
    assert manifest['inputs'] == saved['inputs'] and len(saved['inputs']) == 10142
    assert publication['record_base64'] == saved['claim']['base64']
    assert c.sha(c.decode(saved['claim']['base64'])) == saved['claim']['sha256']
    assert c.decode(saved['baseline']['status']['base64']).strip() == b'0'
    assert b'10142 closed inputs;318 GREEN;169 accepted RED;13 faults' in c.decode(saved['baseline']['log']['base64'])
    assert c.decode(saved['canonical']['status']['base64']).strip() == b'1'
    assert b'found 2 [SESSION-STARTUP-READING.87.3, TYPE-REFERENCE-BOOK.1.2.5]' in c.decode(saved['canonical']['log']['base64'])
    for path, identity in saved['inputs'].items():
        if c.identity(path) != identity:
            packet = saved['before'][path]
            assert {key: packet[key] for key in ('sha256', 'mode')} == identity
            assert c.sha(c.decode(packet['base64'])) == identity['sha256']
    chunks = []
    for path, item in saved['candidate']['parts'].items():
        assert c.identity(path) == {key: item[key] for key in ('sha256', 'mode')}
        raw = (c.ROOT / path).read_bytes()
        assert len(raw) == item['size'] and len(raw) <= 16 * 1024 * 1024
        chunks.append(raw)
    packed = b''.join(chunks)
    candidate(saved, packed)
    denials = {}
    variants = dict(corruption=packed[:-1] + bytes([packed[-1] ^ 1]),
                    truncation=packed[:-1], order=b''.join(reversed(chunks)))
    for name, changed in variants.items():
        try:
            candidate(saved, changed)
        except (AssertionError, OSError, EOFError):
            denials[name] = True
        else:
            raise AssertionError('candidate alteration accepted: ' + name)
    use = saved['candidate']['reverse_check']
    assert use['command'] == ['git', 'apply', '--check', '--reverse', '--binary', '-']
    assert use['returncode'] == 0 and not c.decode(use['stderr_base64'])
    red = saved['owner_red']
    assert red['returncode'] != 0 and b'found 2 [' in c.decode(red['stderr_base64'])
    inputs, result = a.load('owner-inputs.json.gz'), a.load('owner-run.json.gz')
    assert inputs['base'] == c.BASE and result['inputs_unchanged']
    assert c.read('tools/check_task_verification_fields.pl') == inputs['checker']
    assert inputs['checker']['sha256'] == manifest['inputs']['tools/check_task_verification_fields.pl']['sha256']
    assert set(inputs['selection']) == {'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/SESSION-STARTUP-READING.50-99.md'}
    for path, packet in inputs['before'].items():
        raw = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert raw == c.decode(packet['base64']) and c.sha(raw) == packet['sha256']
        mode = subprocess.check_output(['git', 'ls-tree', c.BASE, '--', path], cwd=c.ROOT).split()[0].decode()
        assert mode == packet['git_mode']
    assert all(c.read(path) == packet for path, packet in inputs['after'].items())
    assert result['run']['returncode'] == 0 and not c.decode(result['run']['stderr_base64'])
    assert c.decode(result['run']['stdout_base64']).strip() == c.OWNER.encode()
    assert result['controls']['returncode'] == 0 and not c.decode(result['controls']['stderr_base64'])
    assert b'PASS 14 identity/relocation controls' in c.decode(result['controls']['stdout_base64'])
    repair = a.load('repair.json.gz')
    assert repair['producer'] == c.read(a.PREFIX + 'repair.py')
    for path, packet in repair['before'].items():
        assert packet == saved['before'][path]
        assert c.sha(c.decode(packet['base64'])) == packet['sha256']
        if path.startswith('docs/tasks/'):
            assert (c.ROOT / path).read_bytes() == c.decode(repair['after'][path])
    preparation = a.load('repair-preparation1.json.gz')
    assert preparation['run']['returncode'] != 0
    assert b"module 'preserve' has no attribute 'PREFIX'" in c.decode(preparation['run']['stderr_base64'])
    return dict(first_inputs=len(saved['inputs']), first_claim_bytes=len(c.decode(saved['claim']['base64'])),
        actual_readonly_status=0, canonical1_status=1, owner_red=red['returncode'], owner_green=0,
        existing_owner_controls=14, candidate_parts=len(chunks), candidate_packed_bytes=len(packed),
        candidate_raw_bytes=saved['candidate']['raw_bytes'], recovery_denials=sorted(denials),
        limits='Original whole draft/actual readonly0 and exact rejected staged candidate survive without a '
               'fictional Git revision. The original two-owner RED and corrected one-owner GREEN are actual '
               'staged executions with full declaration inputs. Candidate alteration controls are separate '
               'artifact denials, not engine faults. No checker/runtime/book changes or original observation refresh.')
