"""Actual identity and enumerator/scope-validator faults; restore each actor exactly."""
import copy
import json
import common as c
import context
import publish


def main():
    path = c.PREFIX+'publish.py'
    original = c.read(path)
    text = c.decode(original['base64'])
    actual = {name:c.identity(name) for name in publish.input_paths()}
    target = c.PREFIX+'cases.json'
    cases = {name:copy.deepcopy(actual) for name in ('missing','bytes','mode')}
    cases['missing'].pop(target)
    assert actual[target]['sha256'] != '0'*64
    cases['bytes'][target]['sha256'] = '0'*64
    cases['mode'][target]['mode'] ^= 0o100
    c.write_new('artifact-controls-inputs.json.gz',dict(actual=actual,cases=cases,
        producer=original,controller=c.read(c.PREFIX+'artifact_controls.py'),context=context.snapshot()))
    def execute(source,argument):
        c.source(path).write_bytes(source)
        c.source(path).chmod(original['mode'])
        return dict(producer=c.read(path),run=c.run([
            'bash','tools/run_python_project_data.sh',path,argument]))
    result = {}
    try:
        marker = b'def validate_inputs(declared, actual):\n'
        assert text.count(marker) == 1
        result['identity'] = dict(
            healthy=execute(text,'--identity-controls'),
            bypass=execute(text.replace(marker,marker+b'    return\n',1),'--identity-controls'),
            restored=execute(text,'--identity-controls'))
        population = b'return sorted((owned | set(WRAPPERS)) - {MANIFEST,PUBLICATION,CLAIM})'
        scope = b'def validate_scope(actual):\n'
        assert text.count(population) == text.count(scope) == 1
        result['scope'] = {}
        for name in ('cases.json','rust-cli-001.part'):
            omitted = c.PREFIX+name
            faulty = text.replace(population,b'return sorted((owned | set(WRAPPERS)) - {MANIFEST,PUBLICATION,CLAIM,'+repr(omitted).encode()+b'})',1)
            result['scope'][name] = dict(omitted_path=omitted,
                healthy=execute(text,'--scope-check'),
                omitted=execute(faulty,'--scope-check'),
                bypass=execute(faulty.replace(scope,scope+b'    return\n',1),'--scope-check'),
                validator_restored=execute(faulty,'--scope-check'),
                restored=execute(text,'--scope-check'))
    finally:
        c.source(path).write_bytes(text)
        c.source(path).chmod(original['mode'])
    result['producer_restored'] = c.read(path) == original
    c.write_new('artifact-controls.json.gz',result)
    import control_review
    print(json.dumps(control_review.check(),sort_keys=True))


if __name__ == '__main__':
    main()
