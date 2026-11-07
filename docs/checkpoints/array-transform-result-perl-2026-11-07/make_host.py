"""Distinguish literal Number sources from unrelated localized host Arrays."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
original = json.loads((BASE / 'supplement_cases.json').read_text())
cases = []
for case in original:
    if case['id'].startswith('literal_number_'):
        for seed in ('empty', 'main', 'outer'):
            cases.append(dict(case, id=case['id'] + '_' + seed, seed=seed))
(BASE / 'host_cases.json').write_text(json.dumps(cases, indent=2) + '\n')
observer = (BASE / 'observer.pl').read_text().replace('/cases.json', '/host_cases.json')
package = " my $package='LinkedSpec::ArrayTransformSelectionProbe::'.$id;"
observer = observer.replace(package + '\n', '')
observer = observer.replace(' if ($row{native_callable}) {', package + '''
 no strict 'refs';
 local @{'main::3'} = $case->{seed} eq 'main' ? ('MAIN','TAIL','END') : ();
 local @{$package.'::3'} = $case->{seed} eq 'outer' ? ('OUTER','TAIL','END') : ();
 $row{host_before} = {main=>[@{'main::3'}],outer=>[@{$package.'::3'}]};
 if ($row{native_callable}) {''')
observer = observer.replace(' $row{warnings}=\\@warnings;', " $row{host_after} = {main=>[@{'main::3'}],outer=>[@{$package.'::3'}]};\n $row{warnings}=\\@warnings;")
(BASE / 'observer_host.pl').write_text(observer)
capture = (BASE / 'capture_qualified.py').read_text().replace("('preflight', 'after', 'inverse', 'restored')", "('host_before', 'host_after', 'host_inverse', 'host_restored')")
capture = capture.replace("BASE / 'observer.pl'", "BASE / 'observer_host.pl'").replace("BASE / 'cases.json'", "BASE / 'host_cases.json'")
(BASE / 'capture_host.py').write_text(capture)
print('Authored localized empty/main/outer host controls:', len(cases))
