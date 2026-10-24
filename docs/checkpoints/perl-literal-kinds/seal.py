"""One-shot source-bound seal, after all actual observations and reader controls."""
import json
import common as c
import read

EXTERNAL = [
    'docs/checkpoints/signed-array-perl-ci/contain_book.py',
    'docs/checkpoints/signed-array-perl/perl_probe.pl',
    'tools/project_data_env.sh','tools/project_data_run.sh',
    'tools/run_python_project_data.sh','tools/run_mdbook_local.sh',
]


def main():
    names=sorted({path for path in c.paths() if path.startswith(c.PREFIX)} | set(EXTERNAL))
    assert c.PREFIX+'publication-inputs.json.gz' not in names
    inputs={path:c.identity(path) for path in names}
    result=read.check()
    assert c.unchanged(inputs)
    c.write_new('publication-inputs.json.gz',dict(inputs=inputs,required=names,result=result,
        scope='Immutable dated literal-kind evidence/actual producers; all mutable source epochs are retained inside these artifacts. Runtime/book/Knowledge continuity remains independently editable and current tests/CI exercise it.'))
    print(json.dumps(result,sort_keys=True),flush=True)


if __name__ == '__main__':
    main()
