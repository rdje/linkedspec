"""Distinguish the actual task-file authority from a historical capture guard."""
import ast
import json
import traceback
import common as c
import context


def main():
    path = 'docs/tasks/TYPE-REFERENCE-BOOK.md'
    source = c.read(path)
    raw = c.decode(source['base64'])
    registry_path = 'doctrine/readme_stability/routes.jsonl'
    registry = [json.loads(line) for line in c.source(registry_path).read_text().splitlines() if line]
    surface = next(row for row in registry if row.get('type') == 'surface' and row['id'] == 'task_evidence')
    assert path not in surface['member_limits']
    limit = surface['limits']['max_bytes_per_file']
    assert limit == 1048576
    actor_path = c.PREFIX+'activate.py'
    actor = c.read(actor_path)
    syntax = ast.parse(c.decode(actor['base64']).decode())
    guards = [node for node in ast.walk(syntax) if isinstance(node,ast.Assert)
        and ast.unparse(node.test) == 'len(tree.encode()) <= 65536']
    assert len(guards) == 1
    guard = guards[0]
    authored_limit = guard.test.comparators[0].value
    assert authored_limit < len(raw) <= limit
    supplied = context.snapshot()
    c.write_new('task-limit-inputs.json.gz',supplied)
    try:
        exec(compile(ast.Module(body=[guard],type_ignores=[]),actor_path,'exec'),
            {'tree':raw.decode()})
    except AssertionError as error:
        red = dict(rejected=True,error_class=type(error).__name__,message=str(error),
            traceback_base64=c.encode(traceback.format_exc().encode()))
    else:
        red = dict(rejected=False)
    # These are the actual collection and metadata owners, on the physical
    # worktree already exceeding the author's guard; no checker is altered.
    collection = c.run(['perl','scripts/check_task_tree_partitions.pl'])
    metadata = c.run(['bash','scripts/check_task_tree_metadata.sh'])
    stable = c.unchanged(supplied['inputs'])
    c.write_new('task-limit-review.json.gz',dict(path=path,source=source,
        registry=c.read(registry_path),checker=c.read('scripts/check_task_tree_partitions.pl'),
        actor=actor,source_bytes=len(raw),authored_guard=authored_limit,governed_limit=limit,
        old_guard=red,collection=collection,metadata=metadata,inputs_unchanged=stable,
        scope='The actual old actor assertion rejects this physical tree; both actual policy owners accept it. The one-MiB registry and collection predicate agree and TYPE has no member override. The earlier capacity warning confused author transaction headroom with policy. No project ceiling or helper behavior changes.'))
    assert stable and red['rejected']
    assert collection['returncode'] == metadata['returncode'] == 0
    print('Task-limit correction verified:',len(raw),'source bytes;',limit,
        'governed ceiling; actual capture guard RED / production collection and metadata GREEN')


if __name__ == '__main__':
    main()
