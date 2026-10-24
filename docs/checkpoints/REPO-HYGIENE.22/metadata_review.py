"""Check retained actual channels against an independent per-file OS oracle."""
import json
import common as c

PRODUCERS = [c.PREFIX + name for name in ('common.py', 'census.py', 'metadata_review.py', 'capture.py', 'context.py', 'oracle.py')]
PRODUCERS += ['docs/checkpoints/REPO-HYGIENE.19/census.py',
    'docs/checkpoints/REPO-HYGIENE.18-census.py', 'tools/run_python_project_data.sh',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_lua_project_data.sh']


def rows(data):
    return data['rows'] + [row for group in data['rust_log_bin'].values() for row in group['rows']]


def validate(value):
    assert value['inputs_unchanged']
    assert all(c.identity(path) == item for path, item in value['producers'].items()), 'producer identity'
    observations = []
    for run in value['runs']:
        assert run['returncode'] == 0 and not c.decode(run['stderr_base64']), 'producer exit/channels'
        observations.append(json.loads(c.decode(run['stdout_base64'])))
    assert len(observations) == 2
    first, second = observations
    assert {key:item for key,item in first.items() if key != 'at_utc'} == {
        key:item for key,item in second.items() if key != 'at_utc'}, 'fresh census comparison'
    assert first == value['data'] and first['owner'] == c.OWNER
    assert first['activation_commit'] == c.BASE and first['removed_files'] == first['removed_bytes'] == 0
    assert first['artifact_files'] == len(first['rows']), 'parent file count'
    assert first['artifact_bytes'] == sum(row['bytes'] for row in first['rows']), 'parent byte total'
    for suffix, totals in first['by_suffix'].items():
        selected = [row for row in first['rows'] if row['suffix'] == suffix]
        assert totals == dict(files=len(selected), bytes=sum(row['bytes'] for row in selected)), 'suffix totals'
    for group in first['rust_log_bin'].values():
        assert group['files'] == len(group['rows']) and group['bytes'] == sum(row['bytes'] for row in group['rows']), 'Rust totals'
    selected = rows(first)
    assert len({row['path'] for row in selected}) == len(selected)
    assert [dict(path=row['path'], bytes=row['bytes'], suffix=row['suffix']) for row in selected] == [
        dict(path=row['path'], bytes=row['bytes'], suffix=row['suffix']) for row in value['oracle']], 'independent per-file lstat'
    assert all(row['regular'] and row['same_volume'] and not row['symlink_ancestor']
        and not row['foreign_repository_ancestor'] for row in value['oracle'])
    assert first['rows'] == value['population_oracle']['parent'], 'independent parent population'
    for path, group in first['rust_log_bin'].items():
        assert group['rows'] == value['population_oracle']['rust'][path], 'independent Rust population'
    assert value['convention_oracle'] == first['retained_conventions']
    assert set(first['rust_log_bin']) == {'rust/target/release','rust/target/debug/incremental',
        'rust/target/debug/deps','target/release','target/debug/incremental','target/debug/deps'}
    assert value['traversal_controls'] == dict(start_symlink=True, ancestor_symlink=True,
        nested_repository=True, submodule=True, outside_root=True, fixture_population=True)
    return dict(parent_files=first['artifact_files'], parent_bytes=first['artifact_bytes'],
        rust={path:dict(files=group['files'],bytes=group['bytes'],exists=group['exists'])
            for path,group in first['rust_log_bin'].items()}, at_utc=first['at_utc'], removed_files=0,
        scope=first['scope'])


if __name__ == '__main__':
    import sys
    assert len(sys.argv) in (1, 2)
    name = sys.argv[1] if len(sys.argv) == 2 else 'metadata.json.gz'
    print(json.dumps(validate(c.load(name)), sort_keys=True))
