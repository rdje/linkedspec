"""Capture both actual census channels, independent lstat, and effective controls."""
import copy
import json
import stat
import common as c
import context
import census
import metadata_review as review
import oracle as independent


def controls():
    root = c.ROOT / '.linkedspec-data/scratch/hygiene22/fixture'
    root.mkdir(parents=True, exist_ok=False)
    for name, raw in [('kept.log', b'log'), ('kept.bin', b'bin'), ('.DS_Store', b'meta'), ('ordinary.txt', b'text')]:
        (root/name).write_bytes(raw)
    for directory in ('.git', '.agents', 'dependency', 'nested'):
        path = root/directory
        path.mkdir()
        (path/'excluded.log').write_bytes(b'excluded')
    (root/'nested/.git').mkdir()
    (root/'link').symlink_to(root/'nested', target_is_directory=True)
    scan = census.scan
    rows, nested, _, _ = scan(root, root, {'.git','.agents'}, {'dependency'})
    population = {(row['path'],row['bytes']) for row in rows} == {
        ('kept.log',3),('kept.bin',3),('.DS_Store',4)} and nested == ['nested']
    try:
        scan(root, root.parent, set(), set())
    except AssertionError:
        outside = True
    else:
        outside = False
    return dict(start_symlink=scan(root,root/'link',set(),set()) == ([],[],['link'],[]),
        ancestor_symlink=scan(root,root/'link/child',set(),set()) == ([],[],['link'],[]),
        nested_repository=scan(root,root/'nested',set(),set()) == ([],['nested'],[],[]),
        submodule=scan(root,root/'dependency',set(),{'dependency'}) == ([],[],[],[]),
        outside_root=outside,fixture_population=population)


def oracle(data):
    result = []
    for row in review.rows(data):
        path = c.ROOT / row['path']
        details = path.lstat()
        ancestors = [parent for parent in path.parents if parent.is_relative_to(c.ROOT)]
        result.append(dict(path=row['path'],bytes=details.st_size,suffix=row['suffix'],
            regular=stat.S_ISREG(details.st_mode),same_volume=details.st_dev == c.ROOT.stat().st_dev,
            symlink_ancestor=any(parent.is_symlink() for parent in [path,*ancestors]),
            foreign_repository_ancestor=any((parent/'.git').exists() for parent in ancestors if parent != c.ROOT)))
    return result


def coherent(value, change):
    result = copy.deepcopy(value)
    for run in result['runs']:
        data = json.loads(c.decode(run['stdout_base64']))
        change(data)
        run['stdout_base64'] = c.encode((json.dumps(data,sort_keys=True,separators=(',',':'))+'\n').encode())
    result['data'] = json.loads(c.decode(result['runs'][0]['stdout_base64']))
    return result


def main():
    supplied = context.snapshot()
    producers = {path:c.identity(path) for path in review.PRODUCERS}
    c.write_new('capture-inputs.json.gz',dict(context=supplied,producers=producers))
    traversal = controls()
    command = ['bash','tools/run_python_project_data.sh',c.PREFIX+'census.py']
    first, second = c.run(command), c.run(command)
    c.write_new('census-commands.json.gz',dict(runs=[first,second],producers=producers))
    assert all(run['returncode']==0 and not c.decode(run['stderr_base64']) for run in (first,second))
    data = json.loads(c.decode(first['stdout_base64']))
    conventions = {path:dict(exists=(c.ROOT/path).is_dir(),retained=True)
        for path in data['retained_conventions']}
    value = dict(data=data,runs=[first,second],producers=producers,context=supplied,
        oracle=oracle(data),population_oracle=independent.population(data, supplied['gitlinks']),
        convention_oracle=conventions,traversal_controls=traversal,
        inputs_unchanged=c.unchanged(supplied['inputs']))
    c.write_new('metadata.json.gz',value)
    result = review.validate(value)
    c.write_new('metadata-result.json',result)
    healthy = c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'metadata_review.py'])
    cases = {}
    cases['aggregate'] = coherent(value, lambda data:data.__setitem__('artifact_bytes',data['artifact_bytes']+1))
    def balanced(data):
        rows = [row for row in data['rows'] if row['suffix']=='.log' and row['bytes']>0]
        assert len(rows)>=2
        rows[0]['bytes'] += 1
        rows[1]['bytes'] -= 1
    cases['balanced'] = coherent(value,balanced)
    def omit(data):
        row = data['rows'].pop(0)
        data['artifact_files'] -= 1
        data['artifact_bytes'] -= row['bytes']
        data['by_suffix'][row['suffix']]['files'] -= 1
        data['by_suffix'][row['suffix']]['bytes'] -= row['bytes']
    cases['omission'] = coherent(value, omit)
    omitted = value['data']['rows'][0]['path']
    cases['omission']['oracle'] = [row for row in cases['omission']['oracle'] if row['path'] != omitted]
    cases['channel'] = copy.deepcopy(value)
    cases['channel']['runs'][0]['returncode'] = 1
    cases['producer'] = copy.deepcopy(value)
    cases['producer']['producers'][c.PREFIX+'census.py']['sha256'] = '0'*64
    observations = {}
    reasons = dict(aggregate=b'parent byte total',balanced=b'independent per-file lstat',
        channel=b'producer exit/channels',producer=b'producer identity',
        omission=b'independent parent population')
    for name, mutant in cases.items():
        stem = 'fault-'+name+'.json.gz'
        c.write_new(stem,mutant)
        run = c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'metadata_review.py',stem])
        observations[name] = run
        assert run['returncode'] != 0, name
        assert b'AssertionError: '+reasons[name] in c.decode(run['stderr_base64']),name
    restored = c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'metadata_review.py'])
    c.write_new('metadata-controls.json.gz',dict(healthy=healthy,faults=observations,restored=restored,
        scope='Actual reader rejects aggregate inflation, coherent balanced per-file corruption, a failed producer channel and altered producer identity. Original metadata/source packets stay unchanged.'))
    assert healthy['returncode']==restored['returncode']==0
    assert not c.decode(healthy['stderr_base64']) and not c.decode(restored['stderr_base64'])
    print('Dated artifact review PASS:',result['parent_files'],'parent candidates; zero removals; fresh/lstat/traversal proof and five actual reader denials')


if __name__ == '__main__':
    main()
