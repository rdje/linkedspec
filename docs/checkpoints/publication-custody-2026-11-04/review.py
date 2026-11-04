"""Review retained publication/source custody; no recorded push command is run."""
import argparse
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

import model as m
import source_capture

OUTPUT = m.HERE / 'publication.json.gz'


def ids(raw):
    values = [line.split(b' ', 1)[0].decode('ascii') for line in raw.splitlines()]
    m.require(all(re.fullmatch('[0-9a-f]{40}', value) for value in values), 'object identifier')
    m.require(len(set(values)) == len(values), 'duplicate stream object')
    return set(values)


def dataset(record, name):
    item = record['datasets'][name]
    image = record['streams'][item['stream_sha256']]
    m.require(image['sha256'] == item['stream_sha256'], 'stream identity')
    return ids(m.decode(image))


def stdout_chunks(value):
    if isinstance(value, dict):
        if isinstance(value.get('output'), str):
            yield value['output']
        for key, child in value.items():
            if key != 'output':
                yield from stdout_chunks(child)
    elif isinstance(value, list):
        for child in value:
            yield from stdout_chunks(child)


def original_outputs(source_report, label=None):
    wanted = None
    if label:
        number = source_report['primary_records'][label]
        wanted = json.loads(m.decode(source_report['records'][str(number)]['image']))['payload']['call_id']
    for row in source_report['records'].values():
        record = json.loads(m.decode(row['image']))['payload']
        if record['type'] != 'custom_tool_call_output' or wanted and record['call_id'] != wanted:
            continue
        for item in record['output']:
            try:
                value = json.loads(item.get('text', ''))
            except ValueError:
                continue
            yield from stdout_chunks(value)


def raw_observation(source_report, label):
    found = []
    for chunk in original_outputs(source_report, label):
        found += re.findall(r'^outgoing_object_count=(\d+) uncompressed_object_bytes=(\d+)$', chunk, re.M)
    m.require(len(found) == 1, 'original raw observation population')
    return tuple(map(int, found[0]))


def object_table(record, compare_git=True):
    complete = dataset(record, 'published_closure')
    rows = record['objects']
    names = [row['oid'] for row in rows]
    m.require(names == sorted(complete), 'object population')
    for row in rows:
        m.require(row['kind'] in ('blob', 'tree', 'commit', 'tag')
                  and type(row['bytes']) is int and row['bytes'] >= 0
                  and re.fullmatch('[0-9a-f]{64}', row['sha256']), 'object row shape')
    if compare_git:
        command = ['git', 'cat-file', '--batch-check=%(objectname) %(objecttype) %(objectsize)']
        raw = subprocess.check_output(command, cwd=m.ROOT, input=('\n'.join(names) + '\n').encode())
        headers = [line.decode().split() for line in raw.splitlines()]
        expected = [[row['oid'], row['kind'], str(row['bytes'])] for row in rows]
        m.require(headers == expected, 'Git object metadata')
    return {row['oid']: row for row in rows}


def coverage(record, prefix, target, plan):
    """Require coverage of newly reachable objects; permit repeated/common inputs."""
    base = dataset(record, 'remote_base_closure')
    union, occurrences = set(), 0
    for number in range(1, len(plan['batches']) + 1):
        part = dataset(record, f'{prefix}_batch_{number:02}')
        occurrences += len(part)
        union |= part
    m.require(target - base <= union <= target, 'batch reachable-object coverage')
    return {'input_rows': occurrences, 'unique_objects': len(union),
            'repeated_occurrences': occurrences - len(union)}


def forensic_inputs():
    """Check retained failed instrument and independent overlap observation."""
    failure = json.loads(gzip.decompress((m.HERE / 'capture-failure-01.json.gz').read_bytes()))
    m.require(failure['failed_exit'] == 1 and failure['reason'] == 'overlapping batch object population',
              'failed capture identity')
    for group in ('inputs', 'published_inputs'):
        for image in failure[group].values():
            m.decode(image)
    log = m.decode(failure['inputs']['.linkedspec-data/logs/publication-custody-capture.log'])
    m.require(b'ValueError: overlapping batch object population' in log, 'actual failed control log')
    diagnosis = json.loads(gzip.decompress((m.HERE / 'object-overlap-diagnosis.json.gz').read_bytes()))
    m.require(m.decode(diagnosis['producer']) == (m.HERE / 'diagnose_overlap.py').read_bytes(),
              'diagnosis producer identity')
    m.decode(diagnosis['model_source'])
    m.decode(diagnosis['plan'])
    values = {name: ids(m.decode(row['image'])) for name, row in diagnosis['streams'].items()
              if row['command'][1] == 'rev-list'}
    union = set().union(*(values[f'batch_{number:02}'] for number in range(1, 24)))
    m.require(union == values['original_range'] == values['initial_closure'] - values['base_closure'],
              'independent observed range coverage')
    repeated = sum(len(values[f'batch_{number:02}']) for number in range(1, 24)) - len(union)
    m.require(repeated == diagnosis['summary']['repeated_occurrences'] == 1,
              'independent observed overlap')
    for sample in diagnosis['samples']:
        oid = sample['oid']
        later = sample['later_batch']
        tip = m.decode(diagnosis['streams'][f'negative_tip_{later:02}']['image'])
        tip_ids = {entry.split(b'\t', 1)[0].split()[2].decode()
                   for entry in tip.split(b'\0') if entry}
        m.require(oid in values[f'batch_{sample["earlier_batch"]:02}']
                  and oid in values[f'batch_{later:02}']
                  and oid in values[f'negative_base_{later:02}'] and oid not in tip_ids,
                  'observed historical-blob distinction')
    return repeated


def validate(record, compare_git=True):
    m.require(record['owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.7'
              and record['published_root'] == m.PUBLISHED and record['initial_root'] == m.INITIAL
              and record['remote_base'] == m.BASE, 'capture identity')
    sources = json.loads(gzip.decompress(m.decode(record['source_record_file'])))
    source_capture.review(sources)
    for name, image in sources['archived_sources'].items():
        m.require((m.HERE / name).read_bytes() == m.decode(image), 'archived original source identity')
    for name, image in record['producers'].items():
        m.require((m.ROOT / name).read_bytes() == m.decode(image), 'current producer identity')
    for name, image in record['published_sources'].items():
        m.require(m.git('cat-file', 'blob', m.PUBLISHED + ':' + name) == m.decode(image),
                  'published producer/input identity')
    publication = record['publication']
    m.require(publication['initial_plan'] == record['published_sources'][m.PREFIX + 'push-plan.json']
              and publication['original_plan_output'] == publication['initial_plan'],
              'original plan byte preservation')
    normalized = m.publication(publication)
    m.require(normalized == record['normalized_final_plan'], 'normalized final metadata')
    initial = json.loads(m.decode(publication['initial_plan']))
    final = json.loads(m.decode(publication['final_plan']))
    expected = {'remote_base_closure': m.BASE, 'initial_closure': m.INITIAL,
                'original_outgoing': m.BASE + '..' + m.INITIAL,
                'published_outgoing': m.BASE + '..' + m.PUBLISHED, 'published_closure': m.PUBLISHED}
    for prefix, plan in (('initial', initial), ('runtime', final)):
        for number, row in enumerate(plan['batches'], 1):
            expected[f'{prefix}_batch_{number:02}'] = row['base'] + '..' + row['target']
    m.require(set(record['datasets']) == set(expected), 'input dataset population')
    for name, revision in expected.items():
        m.require(record['datasets'][name]['command'] == ['git', 'rev-list', '--objects', revision],
                  'input dataset command')
        dataset(record, name)
    used = {row['stream_sha256'] for row in record['datasets'].values()}
    m.require(used == set(record['streams']), 'input stream population')
    complete = dataset(record, 'published_closure')
    base = dataset(record, 'remote_base_closure')
    original = dataset(record, 'original_outgoing')
    initial_closure = dataset(record, 'initial_closure')
    outgoing = dataset(record, 'published_outgoing')
    m.require(not base & outgoing and base | outgoing == complete and original <= outgoing,
              'logical Git input closure')
    m.require(base <= initial_closure <= complete and initial_closure - base <= original <= initial_closure,
              'initial reachable-object closure')
    input_coverage = {'initial': coverage(record, 'initial', initial_closure, initial),
                      'runtime': coverage(record, 'runtime', complete, final)}
    forensic_inputs()
    rows = object_table(record, compare_git)
    raw_count, raw_bytes = raw_observation(sources, 'raw_count')
    bad_count, bad_bytes = raw_observation(sources, 'bad_raw_count')
    m.require((len(original), sum(rows[oid]['bytes'] for oid in original)) == (raw_count, raw_bytes),
              'original raw counter versus actual objects')
    m.require(bad_count == raw_count and bad_bytes != raw_bytes, 'historical wrong-counter distinction')
    intake = json.loads(m.decode(record['published_sources'][m.PREFIX + 'publication-intake.json']))
    non_thin = intake['non_thin_pack_bytes_observed']
    m.require(any(re.fullmatch(r'\s*' + str(non_thin) + r'\s*', chunk)
                  for chunk in original_outputs(sources)), 'original non-thin output')
    thin = json.loads(m.decode(record['published_sources'][m.PREFIX + 'thin-pack-estimate.json']))
    thin_outputs = []
    for chunk in original_outputs(sources):
        try:
            candidate = json.loads(chunk)
        except ValueError:
            continue
        if isinstance(candidate, dict) and 'thin_pack_bytes' in candidate:
            thin_outputs.append(candidate)
    m.require(thin in thin_outputs, 'original thin output')
    return {'original_objects': raw_count, 'original_raw_bytes': raw_bytes,
            'historical_wrong_raw_bytes': bad_bytes, 'logical_published_objects': len(rows),
            'logical_published_bytes': sum(row['bytes'] for row in rows.values()),
            'initial_non_thin_bytes_reported': non_thin, 'initial_thin_bytes_reported': thin['thin_pack_bytes'],
            'verified_data_batches': len(final['batches']), 'published_head': m.PUBLISHED,
            'runtime_commits': normalized['runtime_commits'],
            'last_original_group_commits': normalized['ranges'][-1]['original_group_commits'],
            'last_runtime_range_commits': normalized['ranges'][-1]['runtime_range_commits'],
            'batch_input_coverage': input_coverage}


def controls(record):
    rejected = []

    def reject(name, action, reason):
        try:
            action()
        except ValueError as error:
            m.require(str(error) == reason, 'unrelated control refusal: ' + name + ': ' + str(error))
            rejected.append(name)
        else:
            raise ValueError('control accepted: ' + name)

    initial = json.loads(m.decode(record['publication']['initial_plan']))
    for name, change, reason in (
        ('wrong-budget', lambda p: p.update(limit_bytes=m.BUDGET * 2), 'budget identity'),
        ('equal-budget', lambda p: p['batches'][0].update(pack_bytes=m.BUDGET), 'strict pack budget'),
        ('bool-size', lambda p: p['batches'][0].update(pack_bytes=True), 'strict pack budget'),
        ('broken-chain', lambda p: p['batches'][1].update(base=m.BASE), 'broken batch chain'),
        ('wrong-group-count', lambda p: p['batches'][0].update(commits=1), 'initial group count'),
        ('missing-tail', lambda p: p['batches'].pop(), 'incomplete initial endpoint'),
    ):
        altered = copy.deepcopy(initial)
        change(altered)
        reject(name, lambda: m.initial_plan(altered), reason)
    for name, change, reason in (
        ('missing-event', lambda e: e.pop(1), 'event population'),
        ('wrong-tip', lambda e: e[1].update(remote_tip=m.BASE), 'observed remote identity'),
        ('force-main', lambda e: e[-2]['command'].insert(4, '--force'), 'actual push command identity'),
        ('over-budget-event', lambda e: e[1].update(measured_non_thin_pack_bytes=m.BUDGET), 'strict pack budget'),
    ):
        publication = copy.deepcopy(record['publication'])
        events = [json.loads(line) for line in m.decode(publication['events']).splitlines()]
        change(events)
        publication['events'] = m.packet(('\n'.join(json.dumps(row) for row in events) + '\n').encode())
        reject(name, lambda: m.publication(publication), reason)
    publication = copy.deepcopy(record['publication'])
    publication['fresh_remote']['stdout'] = m.packet((m.PUBLISHED + '\trefs/heads/main\n'
                                                       + m.PUBLISHED + '\t' + m.TEMPORARY + '\n').encode())
    reject('temporary-ref-remains', lambda: m.publication(publication), 'fresh final remote identity')
    publication = copy.deepcopy(record['publication'])
    publication['canonical_receipt'] = m.packet(m.decode(publication['canonical_receipt']).replace(
        m.PUBLISHED.encode(), m.INITIAL.encode()))
    reject('wrong-receipt-head', lambda: m.publication(publication), 'historical canonical receipt identity')
    altered = copy.deepcopy(record)
    altered['objects'].pop()
    reject('missing-object', lambda: object_table(altered), 'object population')
    altered = copy.deepcopy(record)
    base_oid = min(dataset(record, 'remote_base_closure'))
    next(row for row in altered['objects'] if row['oid'] == base_oid)['bytes'] += 1
    reject('wrong-object-size', lambda: object_table(altered), 'Git object metadata')
    normalized = record['normalized_final_plan']
    raw = json.loads(m.decode(record['publication']['final_plan']))
    legacy = {'head': raw['head'], 'commits': sum(row['commits'] for row in raw['batches']),
              'last_commits': raw['batches'][-1]['commits']}
    actual = {'head': m.PUBLISHED,
              'commits': int(m.git('rev-list', '--first-parent', '--count', m.BASE + '..' + m.PUBLISHED)),
              'last_commits': int(m.git('rev-list', '--first-parent', '--count',
                                       raw['batches'][-1]['base'] + '..' + m.PUBLISHED))}
    derived = {'head': normalized['published_head'], 'commits': normalized['runtime_commits'],
               'last_commits': normalized['ranges'][-1]['runtime_range_commits']}
    m.require(derived == actual, 'normalized metadata versus independent Git count')
    reject('raw-final-as-runtime', lambda: m.require(legacy == actual, 'raw final metadata is not runtime'),
           'raw final metadata is not runtime')
    observed = coverage(record, 'initial', dataset(record, 'initial_closure'), initial)
    reject('disjoint-batch-model',
           lambda: m.require(observed['repeated_occurrences'] == 0, 'actual batch inputs overlap'),
           'actual batch inputs overlap')
    return {'rejected': rejected, 'original_equality_red': m.original_equality_red(),
            'legacy_final_metadata_model': legacy, 'Git_derived_runtime_metadata': actual}


def verify_bodies(record):
    """Optional fresh full retrieval, distinct from default dated/metadata review."""
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=m.ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    success = False
    try:
        for row in record['objects']:
            process.stdin.write((row['oid'] + '\n').encode())
            process.stdin.flush()
            header = process.stdout.readline().decode().split()
            m.require(header == [row['oid'], row['kind'], str(row['bytes'])], 'current object header')
            digest = hashlib.sha256()
            address = hashlib.sha1((row['kind'] + ' ' + str(row['bytes']) + '\0').encode())
            remaining = row['bytes']
            while remaining:
                block = process.stdout.read(min(remaining, 1024 * 1024))
                m.require(bool(block), 'current object truncation')
                digest.update(block)
                address.update(block)
                remaining -= len(block)
            m.require(process.stdout.read(1) == b'\n' and digest.hexdigest() == row['sha256']
                      and address.hexdigest() == row['oid'], 'current object body identity')
        success = True
    finally:
        process.stdin.close()
        if not success:
            process.terminate()
        code = process.wait()
        if success:
            m.require(code == 0, 'current object retrieval exit')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify-objects', action='store_true')
    args = parser.parse_args()
    record = json.loads(gzip.decompress(OUTPUT.read_bytes()))
    result = validate(record)
    m.require(controls(record) == record['controls'], 'retained control outcome')
    if args.verify_objects:
        verify_bodies(record)
    result['fresh_full_body_verification'] = args.verify_objects
    result['rejected_controls'] = len(record['controls']['rejected'])
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()
