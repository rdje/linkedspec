"""Publish once; verify full byte/mode inputs and fresh behavior on subsequent reads."""
import json
import sys
import common as c

MANIFEST_NAME = 'publication-inputs.json.gz'
PUBLICATION_NAME = 'publication.json'
MANIFEST = c.PREFIX+MANIFEST_NAME
PUBLICATION = c.PREFIX+PUBLICATION_NAME
CLAIM = 'docs/claims/'+c.OWNER+'.json'


def input_paths():
    return c.paths([MANIFEST,PUBLICATION,CLAIM])


def validate_inputs(declared,actual):
    assert set(declared) == set(actual),'publication input population mismatch'
    for path,item in actual.items():
        assert declared[path]['sha256'] == item['sha256'],'publication input byte mismatch: '+path
        assert declared[path]['mode'] == item['mode'],'publication input mode mismatch: '+path


def controls():
    saved = c.load('artifact-inputs.json.gz')
    result = {}
    for name,declared in saved['cases'].items():
        try:
            validate_inputs(declared,saved['actual'])
        except AssertionError as error:
            result[name] = dict(rejected=True,reason=str(error))
        else:
            result[name] = dict(rejected=False,reason='')
    return result


def record(result):
    producers = [path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl'))]
    producers += c.SOURCES+['perl/LinkedSpec/CodeblockRuntime.pm','t/scalar_numeric_contract.t',
        't/uniform_binding_contract.t','tools/run_python_project_data.sh','tools/project_data_run.sh']
    bindings = [dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(set(producers))]
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    return dict(version=1,owner=c.OWNER,claims=[dict(name='perl-sorted-scalar-kind-preservation',
        statement='Perl lexical sorting preserves numeric and string element kinds through callable arguments, returned containers and typed indexes.',
        scope='Bounded Perl ordinary/deferred free/receiver and implicit-accumulator behavior. Comparator copies replace aliased string comparisons; cloning and typed-index policy are unchanged. Numeric order is lexical and numeric-looking strings retain their kind. No cross-backend, complete operation inventory, general pipeline or reducer95 admission. Deferred count/first10, registered sorted/ordinary length11 and indexed writes12 remain owned.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Each fixed case through descriptor/Get-dump/fresh emitted source, independent B flags and clone/index controls, permanent mandatory suites and actual book bodies.',
            result=f"{result['cases']} values;{result['accepted_red']} actual accepted RED/{result['accepted_controls']} controls;{len(result['faults'])} restored source faults;{result['direct_suites']}/{result['direct_tap']} TAP;{result['scalar_cases']}/{result['scalar_assertions']} direct kind cases/assertions;{result['flag_routes']} flag routes;book{result['book_inputs']}/{result['book_examples']};history{result['historical_controls']}. Whole accepted9 custody at real activation is retained. Exact staged canonical receipt governs landing."),
        falsify=dict(status='checked',hypothesis='Sorting can appear correct while comparison contaminates element kinds, clones become strings or a numeric index becomes an harray key.',
            oracle='Independent typed JSON projection, literal expected lexical permutations, pre-clone B flags, clone values, actual accepted runtime and explicit typed array/harray write consumers.',
            red_control='Actual accepted runtime fails the fixed population; three independently restored old comparator paths, numeric order, numeric coercion and source mutation each reject and restore. Actual displaced book heading rejects. Three missing/byte/mode publication declarations reject; the actual return-only validator admits them, then exact restoration rejects them again. All original observer/test failures remain: UTF8 transport, decimal flags measured after Storable cache effects, broad nested TAP plan counting, and one input epoch invalidated by proof-source preparation. They are not successful measurements or runtime defects.'),
        durability=dict(status='checked',mode='live',inputs=bindings))])


def main():
    if sys.argv[1:] == ['--controls']:
        print(json.dumps(controls(),sort_keys=True))
        return
    assert sys.argv[1:] in ([],['--capture'])
    import review
    capture = sys.argv[1:] == ['--capture']
    actual = {path:c.identity(path) for path in input_paths()}
    if capture:
        assert not (c.ROOT/CLAIM).exists()
        c.write_new(MANIFEST_NAME,dict(base=c.BASE,inputs=actual,
            scope='All regular tracked/nonignored new main-repository inputs and full modes, excluding only own manifest/publication/claim. Whole changed plain inputs and exact accepted Git recover every measured epoch; immutable binary evidence is hash-gated without recursive embedding. Three ignored prior aliases derive from retained chunks. Gitlinks remain black boxes. Installed tools/core and published dependency outputs are read-only prerequisites. Project data stays on the repository volume.'))
    validate_inputs(c.load(MANIFEST_NAME)['inputs'],actual)
    result = review.check()
    validate_inputs(actual,{path:c.identity(path) for path in input_paths()})
    raw = (json.dumps(record(result),separators=(',',':'))+'\n').encode()
    publication = dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new(PUBLICATION_NAME,publication)
        with (c.ROOT/CLAIM).open('xb') as output:
            output.write(raw)
    else:
        assert c.source(CLAIM).read_bytes() == raw and c.load(PUBLICATION_NAME) == publication
    print(f"Sort-kind publication PASS: {len(actual)} inputs;{result['cases']} values/"
        f"{result['accepted_red']} accepted RED/{len(result['faults'])} restored faults;"
        f"book{result['book_inputs']}/{result['book_examples']};source readonly")


if __name__ == '__main__':
    main()
