"""Retain and repair the interrupted plan producer, without replaying its one-shot writes."""
import ast
import json
import re
import shutil
import sys
import warnings
import common as c
import context


def main():
    supplied = context.snapshot()
    c.write_new('preparation-resume-inputs.json.gz', supplied)
    old = c.read(c.PREFIX+'prepare.py')
    command = [sys.executable, '-c',
        "import sys; sys.path.insert(0,'docs/checkpoints/type-array-count-first'); import prepare; prepare.fixed_plan()"]
    failure = c.run(command)
    c.write_new('preparation-failure.json.gz', dict(producer=old, run=failure))
    assert failure['returncode'] != 0
    assert b"multiple values for keyword argument 'id'" in c.decode(failure['stderr_base64'])
    text = c.decode(old['base64']).decode()
    marker = "dict(**case,id='supplement/'+case['id'],expected=expected)"
    assert text.count(marker) == 1
    text = text.replace(marker,
        "dict(**{key:value for key,value in case.items() if key != 'id'},id='supplement/'+case['id'],expected=expected)", 1)
    c.source(c.PREFIX+'prepare.py').write_text(text)
    import prepare
    plan = prepare.fixed_plan()
    # The first execution already applied this sole warning fix before its later failure.
    warning_before = c.load('findings-inputs.json.gz')['overrides'][c.PREFIX+'record_findings.py']
    original = c.decode(warning_before['base64']).decode()
    corrected = c.source(c.PREFIX+'record_findings.py').read_text()
    assert corrected == original.replace(',line,1)', ',line,count=1)', 1)
    row = next(line for line in c.source('docs/tasks/TYPE-REFERENCE-BOOK.md').read_text().splitlines()
        if line.startswith('| 8 |'))
    results = []
    for name, source in [('original', original), ('keyword', corrected)]:
        nodes = [node for node in ast.walk(ast.parse(source)) if isinstance(node, ast.Assign)
            and isinstance(node.value, ast.Call) and isinstance(node.value.func, ast.Attribute)
            and isinstance(node.value.func.value, ast.Name) and node.value.func.value.id == 're'
            and node.value.func.attr == 'sub' and isinstance(node.targets[0], ast.Subscript)]
        assert len(nodes) == 1
        namespace = dict(re=re, lines=[row], index=0, order=8, line=row)
        with warnings.catch_warnings(record=True) as observed:
            warnings.simplefilter('always')
            exec(compile(ast.Module(body=nodes, type_ignores=[]), c.PREFIX+'record_findings.py', 'exec'), namespace)
        results.append(dict(name=name, value=namespace['lines'][0], warnings=[dict(
            category=type(item.message).__name__, message=str(item.message)) for item in observed]))
    assert results[0]['value'] == results[1]['value'] == row
    assert len(results[0]['warnings']) == 1 and not results[1]['warnings']
    assert results[0]['warnings'][0]['category'] == 'DeprecationWarning'
    c.write_new('cases.json', plan)
    shutil.copy2(c.source('docs/checkpoints/type-sort-copy-kinds/oracle.py'), c.ROOT/c.PREFIX/'oracle.py')
    c.write_new('preparation.json.gz', dict(producer=c.read(c.PREFIX+'resume_prepare.py'),
        repaired_producer=c.read(c.PREFIX+'prepare.py'), original_failure='preparation-failure.json.gz',
        warning_correction=dict(before=warning_before, after=c.read(c.PREFIX+'record_findings.py'),
            results=results, python=sys.version),
        plan=c.read(c.PREFIX+'cases.json'), oracle=c.read(c.PREFIX+'oracle.py'), cases=len(plan['cases']),
        before_runtime={path:c.read(path) for path in c.SOURCES},
        scope='Interrupted preparer failure retained before repair; no product runtime changes. Literal fixed expectations and independent length/index controls precede implementation. The original warning statement is re-executed; the repaired statement preserves its exact row without a warning.'))
    print('Fixed plan:', len(plan['cases']), 'cases; actual producer failure and warning controls retained')


if __name__ == '__main__':
    main()
