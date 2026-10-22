"""Capture once; verify complete current inputs and fresh public selection behavior."""
import json
import sys
import common as c

MANIFEST_NAME = 'publication4-inputs.json.gz'
PUBLICATION_NAME = 'publication4.json'
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
    supplied = c.load('artifact4-inputs.json.gz')
    result = {}
    for name,declared in supplied['cases'].items():
        try:
            validate_inputs(declared,supplied['actual'])
        except AssertionError as error:
            result[name] = dict(rejected=True,reason=str(error))
        else:
            result[name] = dict(rejected=False,reason='')
    return result


def record(result):
    producers = [path for path in input_paths() if path.startswith(c.PREFIX) and path.endswith(('.py','.pl'))]
    producers += c.SOURCES+['t/scalar_numeric_contract.t','t/actionir_ast_parser.t','tools/run_python_project_data.sh','tools/project_data_run.sh',
        'tools/roll_document_history.pl','scripts/check_readme_routing_pressure.pl','scripts/check_repo_root_path_portability.sh']
    producers += ['t/phase0_regression.t', 'tests/language-readiness/verify_objectives.py', 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py', 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-focused.pl']
    producers += ['t/actionir_method_kind_capture.t','t/actionir_method_kind_probe.pl',
        't/actionir_method_kind_authority_probe.pl','t/lib/LinkedSpecTest/MethodLocations.pm','t/lib/LinkedSpecTest/EmittedValues.pm']
    bindings = [dict(path=path,sha256=c.identity(path)['sha256'],role='producer') for path in sorted(set(producers))]
    bindings.append(dict(path='tests/language-readiness/count-first-regression-evolution.json',sha256=c.identity('tests/language-readiness/count-first-regression-evolution.json')['sha256'],role='input'))
    bindings.append(dict(path=MANIFEST,sha256=c.identity(MANIFEST)['sha256'],role='input'))
    runtime = dict(name='perl-codeblock-count-first',
        statement='Perl deferred count/first match the observed ordinary arity, terminal/effect and stored-value contract; free non-array harray calls return neutral values without host dereference errors.',
        scope='Bounded Perl ordinary/deferred free/receiver, sorted/take selections, scalar/container/callable kinds, side effects, lexical helper precedence and existing copy boundaries. Last14, registered sorted/ordinary length11, deferred indexed writes12, reducers95, complete inventory and other backends are separate.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Each fixed case through descriptor/Get-dump/native/fresh emitted source; permanent native/generated tests, independent length/index proxies and actual book bodies. '+result['direct_scope'],
            result=f"{result['cases']} cases;{result['accepted_red']} actual accepted RED/{result['accepted_controls']} controls;{len(result['faults'])} restored source faults;{result['direct_suites']}/{result['direct_tap']} TAP;history{result['historical_controls']};book{result['book_inputs']}/{result['book_examples']}. Exact staged canonical receipt and normal hooks govern landing."),
        falsify=dict(status='checked',hypothesis='Adding a helper name alone can hide wrong arity, eager side effects, receiver continuations, wrong selected elements or ordinary harray host failures.',
            oracle='Literal typed expected values, independently accepted ordinary terminal behavior and length/index routes, source/result mutation and callable invocation controls.',
            red_control='Actual accepted runtime fails the fixed population. Free/receiver dispatch, free/receiver arity, terminal effects, selected index and both generated ARRAY guards each reject and restore. Displaced actual book heading rejects. Three missing/byte/mode declarations reject; an actual return-only publication validator admits them and exact restoration rejects them again. Original producer duplicate-key/warning, shared fault marker and unused-interpreter loader assumptions are retained and corrected, without treating them as product defects.'),
        durability=dict(status='checked',mode='live',inputs=bindings))
    runtime['rederive']['result'] += (f" Phase0:{result['phase0']['selected']} focused roots/"
        f"{result['phase0']['goldens']} exact guard goldens; retained historical audit "
        f"{result['phase0']['previous']} prior+{result['phase0']['added']} new="
        f"{result['phase0']['current']} denials. Focused roots retain explicit skips; canonical full Phase0 remains required.")
    runtime['falsify']['red_control'] += (' Actual old Phase0 expectations reject all selected roots; ten exact guard literals pass after repair. '
        'The independent hash-gated inverse restores real accepted bytes before unchanged older layers. '
        'Actual inverse-call removal rejects; an inert table byte rejects, a real hash-check bypass admits it, '
        'and exact source/table restoration restores rejection and healthy observations. '
        'Whole unpublished draft1 and its actual readonly baseline survive before these bound edits. '
        'Draft2 and the actual production portability failure remain whole; two published loader summaries use relative paths while exact raw observations survive. The current observer re-executes the same three real roots and emits those relative paths. The restored production path checker passes.')
    runtime['rederive']['result'] += f" Private count fixture:{result['private']['assertions']} assertions; three exact current guard expectations preserve original native captures."
    runtime['falsify']['red_control'] += (' Whole draft3 and actual readonly0/full canonical2 failure survive. Three stale private count expectations are repaired without editing native captures. Actual expectation omission rejects; matched old guard and source expectation reject solely through independent array/nonarray execution; exact restoration passes.')
    continuity = dict(name='finite-selection-history-continuity',
        statement='Both required count/first history rollovers preserve exact clean-source suffixes and every older immutable member; ADR0137 admits only their measured members/manifests and its sole decision/index overhead.',
        scope='The two actual rollovers at a8bd8620a, old limits and exact reviewed resulting objects. Root, per-file, aggregate, checker and unrelated limits stay exact; no future archive reserve.',
        rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'publish.py',
            granularity='Each original immutable file, manifest row, clean Git source range/blob/digest and combined current-plus-new-archive reconstruction.',
            result=json.dumps(result['history'],sort_keys=True)+'; actual old-cap production refusal retained; exact staged routing/canonical admission remains mandatory.'),
        falsify=dict(status='checked',hypothesis='Rollover could lose or rewrite accepted records, or silently grant unrelated capacity.',
            oracle='Real accepted Git images and literal unchanged prior manifest rows; exact source range/digest/reconstruction; production old-cap rejection and exact finite registry/ADR objects.',
            red_control='Actual90% pressure checks reject both expanded roots and the old routing checker rejects the resulting history capacity. Independent byte/mode custody and actual publication-validator faults reject missing/changed inputs. Required staged production/doctrine/canonical proof gates the corrected candidate.'),
        durability=dict(status='checked',mode='live',inputs=bindings))
    return dict(version=1,owner=c.OWNER,claims=[runtime,continuity])


def main():
    if sys.argv[1:] == ['--controls']:
        print(json.dumps(controls(),sort_keys=True))
        return
    assert sys.argv[1:] in ([],['--capture'])
    import review
    capture = sys.argv[1:] == ['--capture']
    actual = {path:c.identity(path) for path in input_paths()}
    if capture:
        assert c.source(CLAIM).read_bytes() == c.decode(c.load('draft3.json.gz')['packets']['claim']['base64'])
        c.write_new(MANIFEST_NAME,dict(base=c.BASE,inputs=actual,
            scope='All regular tracked/nonignored new main-repository sources and full modes, excluding only own manifest/publication/claim. Supplied epochs retain whole changed plain sources; accepted Git and immutable hash-gated inputs recover the rest. Three old logical aliases derive from tracked chunks. Gitlinks and other repositories remain black boxes; installed tools and published dependency outputs are read-only prerequisites. Project data stays on the repository volume.'))
    validate_inputs(c.load(MANIFEST_NAME)['inputs'],actual)
    result = review.check()
    validate_inputs(actual,{path:c.identity(path) for path in input_paths()})
    raw = (json.dumps(record(result),separators=(',',':'))+'\n').encode()
    publication = dict(result=result,record_base64=c.encode(raw))
    if capture:
        c.write_new(PUBLICATION_NAME,publication)
        c.source(CLAIM).write_bytes(raw)
    else:
        assert c.source(CLAIM).read_bytes() == raw and c.load(PUBLICATION_NAME) == publication
    print(f"Count/first publication PASS:{len(actual)} inputs;{result['cases']} cases/"
        f"{result['accepted_red']} accepted RED/{len(result['faults'])} restored faults;"
        f"book{result['book_inputs']}/{result['book_examples']}; source readonly")


if __name__ == '__main__':
    main()
