"""Effective complete-plan source faults in an isolated supplied fixture."""
import gzip
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
import common as c

assert sys.argv[1:] in ([], ['--capture'])
GEN = 'knowledge-map/scripts/gen_knowledge_map.sh'
INPUTS = c.HOME + 'fault-inputs.json.gz'
REACHED = c.HOME + 'faults-reached.json.gz'
REPORT = c.HOME + 'faults.json'


def mutations(candidate):
    rules = [
        ('block-list-ignored', 'else add_metadata(curkey,v)', 'else if (0) add_metadata(curkey,v)',
         'block-evidence projects evidence metadata'),
        ('inline-list-ignored', '} else if (key=="evidence" || key=="reverify") metadata_list(inner,key)',
         '} else if (key=="evidence" || key=="reverify") { }', 'inline-evidence projects evidence metadata'),
        ('last-inline-item-dropped', 'add_metadata(key,strip(substr(value,start)))',
         'if (0) add_metadata(key,strip(substr(value,start)))', 'inline-evidence preserves evidence item 2'),
        ('list-order-reversed', 'metadata[key]=metadata[key] (metadata_count[key] ? " · " : "") code_span(value)',
         'metadata[key]=code_span(value) (metadata_count[key] ? " · " : "") metadata[key]',
         'multiple-reverify preserves reverify item 2'),
        ('zero-string-dropped', 'if ((key!="evidence" && key!="reverify") || value=="") return',
         'if ((key!="evidence" && key!="reverify") || value=="" || value=="0") return',
         'repeated-zero-items projects evidence metadata'),
        ('unsafe-code-delimiter', 'while (index(value,fence)) fence=fence "`"',
         'while (0 && index(value,fence)) fence=fence "`"', 'backticks in a list item remain data'),
        ('quoted-comma-split', 'if (quoted) {', 'if (0 && quoted) {',
         'quoted-inline-comma preserves evidence item 1'),
        ('scalar-presentation-drift', '(vals[key]!="" ? "`" vals[key] "`" : "")',
         '(vals[key]!="" ? "``" vals[key] "``" : "")',
         'scalar gives each question its scalar command'),
        ('wrong-list-pointer-count', '? "[" metadata_count["reverify"] " "',
         '? "[" (metadata_count["reverify"]+1) " "',
         'multiple-reverify gives each question its scalar command'),
        ('unrelated-list-authority', 'else add_metadata(curkey,v)',
         'else add_metadata(curkey=="tags" ? "evidence" : curkey,v)',
         'unrelated list metadata is not evidence or reverify output'),
    ]
    text = candidate.decode()
    result = []
    for name, old, new, reason in rules:
        assert text.count(old) == 1, (name, 'exact one-site source mutation')
        value = text.replace(old, new, 1).encode()
        assert value != candidate
        result.append(dict(name=name, old=old, new=new, reason=reason,
                           source_base64=c.encode(value), sha256=c.sha(value)))
    return result


def failures(observation):
    stdout = c.decode(observation['stdout_base64'])
    assert stdout.endswith(b'1..176\n'), 'every fault retains the same complete plan'
    return [(int(number), name.decode()) for number, name in re.findall(rb'^not ok (\d+)(?: - (.*))?$', stdout, re.M)]


if sys.argv[1:]:
    packed = (c.ROOT / (c.HOME + 'compact-inputs.json.gz')).read_bytes()
    epoch = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'compact.json.gz')).read_bytes()))
    assert c.sha(packed) == epoch['capsule_sha256']
    capsule = json.loads(gzip.decompress(packed))
    paths = [GEN, 'knowledge-map/scripts/check_knowledge_map.sh', 't/knowledge_map_header_lists.t',
             'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-headers-census.json',
             '.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
             'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
    supplied = {path: capsule['inputs'][path] for path in paths}
    for path, item in supplied.items():
        assert c.read(path) == item, ('current candidate before isolated faults', path)
    candidate = c.decode(supplied[GEN]['base64'])
    variants = mutations(candidate)
    original = dict(result='prepared', supplied=supplied, mutations=variants,
                    compact_capsule_sha256=c.sha(packed), producer_base64=c.encode(Path(__file__).read_bytes()),
                    scope='Complete actual source inputs and every exact one-site mutant precede '
                          'all fault commands. Only an isolated supplied generator is mutated; '
                          'the live repository generator and all other inputs remain unchanged.')
    c.write_new(INPUTS, original, packed=True)
    rows = []
    with tempfile.TemporaryDirectory(prefix='knowledge-fields-faults-', dir=os.environ['TMPDIR']) as directory:
        fixture = Path(directory)
        assert fixture.stat().st_dev == c.ROOT.stat().st_dev
        for path, item in supplied.items():
            target = fixture / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(c.decode(item['base64']))
            target.chmod(item['mode'])
        temporary = fixture / '.linkedspec-data/tmp'
        temporary.mkdir(parents=True)
        environment = dict(os.environ, GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
                           GIT_WORK_TREE=str(fixture), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary))

        def observe(command):
            run = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
            return dict(command=command, returncode=run.returncode,
                        stdout_base64=c.encode(run.stdout), stderr_base64=c.encode(run.stderr))

        def guarded(generator):
            return all((fixture / path).read_bytes() == (generator if path == GEN else c.decode(item['base64'])) and
                       (fixture / path).stat().st_mode & 0o7777 == item['mode'] for path, item in supplied.items())

        command = ['perl', 't/knowledge_map_header_lists.t']
        baseline = observe(command)
        c.write_new(c.HOME + 'fault-baseline.json', baseline)
        assert baseline['returncode'] == 0 and not failures(baseline) and guarded(candidate), baseline
        for variant in variants:
            value = c.decode(variant['source_base64'])
            target = fixture / GEN
            try:
                target.write_bytes(value)
                syntax = observe(['bash', '-n', GEN])
                negative = observe(command)
                mutant_unchanged = guarded(value)
            finally:
                target.write_bytes(candidate)
                target.chmod(supplied[GEN]['mode'])
            restored = observe(command)
            healthy_unchanged = guarded(candidate)
            failed = failures(negative)
            row = dict(name=variant['name'], syntax=syntax, negative=negative, restored=restored,
                       failures=[dict(number=number, name=name) for number, name in failed],
                       mutant_inputs_unchanged=mutant_unchanged, restored_inputs_unchanged=healthy_unchanged)
            rows.append(row)
            (c.ROOT / REACHED).write_bytes(gzip.compress(json.dumps(rows, sort_keys=True).encode(), mtime=0))
            assert syntax['returncode'] == 0 and negative['returncode'] != 0 and failed
            assert c.decode(negative['stdout_base64']).splitlines()[:120] == c.decode(baseline['stdout_base64']).splitlines()[:120]
            assert all(number > 120 and name for number, name in failed)
            assert any(variant['reason'] in name for _, name in failed), (variant['name'], failed)
            assert mutant_unchanged and healthy_unchanged and restored == baseline
            print('Source fault RED/restored:', variant['name'], len(failed), flush=True)
    assert all(c.read(path) == item for path, item in supplied.items()), 'live candidate never changes'
    report = dict(result='PASS', producer_sha256=c.sha(Path(__file__).read_bytes()), baseline=baseline,
                  inputs_sha256=c.sha((c.ROOT / INPUTS).read_bytes()), reached_sha256=c.sha((c.ROOT / REACHED).read_bytes()),
                  faults=[dict(name=row['name'], failures=len(row['failures'])) for row in rows],
                  scope='Ten exact syntax-valid source mutations each run the same complete176 plan. '
                        'All120 native header assertions remain byte-exact controls; distinguishing '
                        'named projection failures occur. After each fault, all actual fixture input '
                        'bytes/modes restore and the complete healthy channels exactly match baseline. '
                        'All complete mutant sources, syntax/TAP channels, original inputs and partial '
                        'rows are retained. Live repository sources are never mutated.')
    c.write_new(REPORT, report)

original = json.loads(gzip.decompress((c.ROOT / INPUTS).read_bytes()))
report = json.loads((c.ROOT / REPORT).read_bytes())
rows = json.loads(gzip.decompress((c.ROOT / REACHED).read_bytes()))
assert c.decode(original['producer_base64']) == Path(__file__).read_bytes()
assert report['producer_sha256'] == c.sha(Path(__file__).read_bytes())
assert report['inputs_sha256'] == c.sha((c.ROOT / INPUTS).read_bytes())
assert report['reached_sha256'] == c.sha((c.ROOT / REACHED).read_bytes())
variants = mutations(c.decode(original['supplied'][GEN]['base64']))
assert variants == original['mutations'] and len(rows) == len(variants) == 10
assert report['baseline']['returncode'] == 0 and not failures(report['baseline'])
for row, variant in zip(rows, variants):
    assert row['name'] == variant['name']
    assert row['syntax']['returncode'] == 0 and row['negative']['returncode'] != 0
    failed = failures(row['negative'])
    assert failed == [(item['number'], item['name']) for item in row['failures']]
    assert all(number > 120 and name for number, name in failed)
    assert any(variant['reason'] in name for _, name in failed)
    assert c.decode(row['negative']['stdout_base64']).splitlines()[:120] == c.decode(report['baseline']['stdout_base64']).splitlines()[:120]
    assert row['restored'] == report['baseline'] and row['mutant_inputs_unchanged'] and row['restored_inputs_unchanged']
assert report['faults'] == [dict(name=row['name'], failures=len(row['failures'])) for row in rows]
print('Source sensitivity PASS:10 exact effective faults;complete176;all exact restorations')
