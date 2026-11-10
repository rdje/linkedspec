"""Author independent Perl source questions before SDK use; preserve templates."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
OLD = Path('docs/checkpoints/array-pipeline-result-selection-2026-11-10')
COMMON = Path('tests/fixtures/array_pipeline_result_guard_cases.json')
profiles = []


def add(identifier, body, error=None, **extra):
    row = dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
               input='x', rule='Value', profile_only=True, **extra)
    if error:
        row['expected_error'] = error
    profiles.append(row)


def expression(helper, source, receiver=False, extra=False, delimiter=None):
    args = {'split_each': ['":"'], 'filter_match': ['/./']}.get(helper, [])[:]
    if delimiter is not None:
        assert helper == 'split_each'
        args[0] = delimiter
    if extra:
        args.append('{order=cat(order,"A");0}')
    if receiver:
        return source + '.' + helper + '(' + ','.join(args) + ')'
    return helper + '(' + ','.join([source] + args) + ')'


helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')
consumer = '.set_key({order=cat(order,"K");"k"},1)'
for helper in helpers:
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":1}')):
        for receiver in (False, True):
            add('initial_' + kind + '_' + helper + ('_receiver' if receiver else '_free'),
                'return(' + expression(helper, source, receiver) + ')')
        add('initial_' + kind + '_' + helper + '_with',
            'order="";out=' + expression(helper, source, True) +
            '.with(){order=cat(order,"W");return(value.count())};return([out,order])')
    for receiver in (False, True):
        suffix = '_receiver' if receiver else '_free'
        add('extra_' + helper + suffix,
            'order="";out=' + expression(helper, '{order=cat(order,"S");["head:tail"]}', receiver, True) +
            consumer + '.with(){order=cat(order,"W");return("ran")};return([out,order])')
    add('needed_' + helper + '_source', 'return(' +
        expression(helper, '{items="bad";items+=1;["head:tail"]}') + consumer + '.coalesce("masked"))',
        error='binding_kind_mismatch')
for identifier, source in (('prior_count', '[1].count()'), ('prior_key_count', '{"k":1}.count_keys()'),
                           ('prior_length', '"abc".length()'), ('prior_view', 'sorted_keys({"k":1})'),
                           ('prior_copy', 'copy(3)'), ('prior_array', 'array("tail")')):
    add(identifier, 'order="";out=' + source + '.trim_each()' + consumer +
        '.with(){order=cat(order,"W");return("ran")};return([out,order])')
for receiver in (False, True):
    suffix = '_receiver' if receiver else '_free'
    add('needed_split_delimiter' + suffix, 'return(' + expression('split_each', '["head:tail"]', receiver,
        delimiter='{items="bad";items+=1;":"}') + consumer + '.coalesce("masked"))', error='binding_kind_mismatch')
    value = '["head"].filter_match(/(/)' if receiver else 'filter_match(["head"],/(/)'
    for composed in (False, True):
        add('invalid_pattern' + suffix + ('_composed' if composed else '_terminal'),
            'order="";return(' + value + (consumer + '.coalesce("masked")' if composed else '') + ')')
add('nested_scalar_kinds', 'items=[false,0,undef,"0",""];out=uniq(items);return([out,items])')
add('numeric_array_source', 'items=[3];return([trim_each(items),filter_nonempty(items),uniq(items),items])')
assert len(profiles) == 98

hosts = []
for row in profiles:
    if row['id'].startswith('initial_number_') and not row['id'].endswith('_with'):
        for seed in ('main', 'outer'):
            hosts.append(dict(row, id=row['id'] + '_host_' + seed, seed=seed, host_literal=True))
for helper in helpers:
    for receiver in (False, True):
        body = 'return(' + expression(helper, '{3}', receiver) + ')'
        hosts.append(dict(id='computed_number_' + helper + ('_receiver' if receiver else '_free') + '_host_main',
            body=body, source='Value:: I {' + body + '}\n', input='x', rule='Value', seed='main',
            host_computed=True, expected=[]))
assert len(hosts) == 42

templates = BASE / 'template-inputs'; templates.mkdir()
identity = {}
for name in ('observer.pl', 'capture.py'):
    path = ROOT / OLD / name
    body = path.read_bytes()
    target = templates / (name + '.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    identity[str(OLD / name)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), retained=str(target.relative_to(ROOT)))
(BASE / 'template-identities.json').write_text(json.dumps(identity, indent=2) + '\n')
common = json.loads((ROOT / COMMON).read_bytes())
assert len(common) == 36
cases = common + profiles + hosts
assert len(cases) == len({row['id'] for row in cases}) == 176
(BASE / 'profiles-source.json').write_text(json.dumps(profiles, indent=2) + '\n')
(BASE / 'host-cases.json').write_text(json.dumps(hosts, indent=2) + '\n')
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')

observer = gzip.decompress((templates / 'observer.pl.gz').read_bytes()).decode()
observer = observer.replace(str(OLD), str(REL))
start, end = observer.index('sub error_value {'), observer.index('sub persist {')
observer = observer[:start] + '''sub plain_error_value {
 my ($value)=@_;
 return $value unless ref($value);
 return $value if JSON::PP::is_bool($value);
 my $kind=reftype($value)//'';
 return [map {plain_error_value($_)} @$value] if $kind eq 'ARRAY';
 if ($kind eq 'HASH') {
  my %copy=map {$_=>plain_error_value($value->{$_})} keys %$value;
  $copy{class}=ref($value) if ref($value) ne 'HASH';
  return \\%copy;
 }
 return "$value";
}
sub error_value {
 my ($error)=@_;
 return undef unless defined($error) && (ref($error) || length($error));
 return plain_error_value($error);
}
''' + observer[end:]
package = " my $package='LinkedSpec::ArrayPipelineSelectionProbe::'.$id;"
assert observer.count(package) == 1
observer = observer.replace(package + '\n', '')
observer = observer.replace(' if ($row{native_callable}) {', package + '''
 no strict 'refs';
 my $seed=$case->{seed}//'empty';
 local @{'main::3'} = $seed eq 'main' ? ('MAIN','TAIL','END') : ();
 local @{$package.'::3'} = $seed eq 'outer' ? ('OUTER','TAIL','END') : ();
 $row{host_before}={main=>[@{'main::3'}],outer=>[@{$package.'::3'}]};
 $row{build_context_error}=error_value($ctx{last_error}) if exists $ctx{last_error};
 if ($row{native_callable}) {''')
observer = observer.replace(' $row{warnings}=\\@warnings;', " $row{host_after}={main=>[@{'main::3'}],outer=>[@{$package.'::3'}]};\n $row{warnings}=\\@warnings;")
(BASE / 'observer.pl').write_text(observer)
capture = gzip.decompress((templates / 'capture.py.gz').read_bytes()).decode()
capture = capture.replace("OUT=BASE/'intake'", "OUT=BASE/'preflight'")
capture = capture.replace("['git','ls-files','perl']", "['git','ls-files','perl','tests/fixtures']")
capture = capture.replace("records={}\n", "paths += list(BASE.glob('*.py')) + list((BASE/'template-inputs').glob('*')) + [BASE/'template-identities.json',BASE/'profiles-source.json',BASE/'host-cases.json']\npaths += [Path(p) for p in ('docs/checkpoints/type-operation-inventory/array-pipeline-result-guard-composition.md','docs/knowledge/perl-array-transform-source-preflight.md','docs/knowledge/action-regex-operands-and-runtime-kinds.md','tests/fixtures/array_pipeline_result_guard_cases.json')]\nrecords={}\n")
(BASE / 'capture.py').write_text(capture)
print('Authored unchanged36 plus98 independent source questions and42 localized host distinctions; no SDK verdict')
