"""Readonly source-domain RED/GREEN, retained inputs and exact public/module seeds."""
import copy
import gzip
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import tarfile

ROOT = Path.cwd()
BASE = Path(__file__).parent.relative_to(ROOT)
ACTIVATION = '10eff853701490e4c3129b5a6860d49722deb3a3'
OWNER = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
NORMAL = 't/key_count_source_domain.t'
FIXTURE = 'tests/fixtures/key_count_source_domain_cases.json'
RED = {'free_number', 'receiver_number', 'free_false', 'receiver_false', 'free_array',
       'receiver_array', 'free_true', 'free_nonempty_array', 'receiver_true',
       'receiver_nonempty_array', 'free_nonhash_order', 'receiver_nonhash_order',
       'initial_compatible'}


def digest(body): return hashlib.sha256(body).hexdigest()
def same(a, b): return json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True)


def raw(path):
    capsule = Path(str(ROOT / path) + '.gz')
    return gzip.decompress(capsule.read_bytes())


def recover(phase):
    records = json.loads((BASE / phase / 'input-identities.json').read_text())
    bodies = {}
    with tarfile.open(BASE / phase / 'inputs-before-first-run.tar.gz') as archive:
        for member in archive.getmembers():
            path = PurePosixPath(member.name)
            assert member.isfile() and not path.is_absolute() and '..' not in path.parts
            assert member.name not in bodies
            body = archive.extractfile(member).read(); item = records[member.name]
            assert digest(body) == item['sha256'] and len(body) == item['bytes']
            assert member.mode & 0o777 == item['mode']
            bodies[member.name] = body
    assert bodies.keys() == records.keys()
    assert (BASE / phase / 'activation.txt').read_text().strip() == ACTIVATION
    return bodies


def observations(phase):
    rows = {}
    for line in raw(BASE / phase / 'normal-stderr.log').decode().splitlines():
        prefix = '# KEY_COUNT_DOMAIN_ACTUAL '
        line = line.lstrip()
        if line.startswith(prefix):
            name, body = line[len(prefix):].split(' ', 1)
            assert name not in rows
            rows[name] = json.loads(body)
    return rows


def target(case, row):
    if not row['native_callable'] or not row['loaded'] or row['warnings']:
        return False
    if any(row[k] for k in ('build_error', 'native_error', 'emission_error', 'load_error', 'fresh_error', 'descriptor_error')):
        return False
    meta = row['metadata']
    if not meta['language_agnostic_action_ir_ready'] or any(meta[k] for k in ('raw_perl_dependency_count', 'canonical_action_ir_fallback_count', 'unresolved_helper_count')):
        return False
    for route in ('native', 'fresh'):
        if not same(row[route], case['expected']) or row[route + '_cursor'] != 0:
            return False
    if case.get('seed_namespace'):
        seeds = row['seeds']
        if seeds['lowering_error'] or seeds['carrier_error']:
            return False
        if [(r['route'], r['seed']) for r in seeds['rows']] != [(route, seed) for route in ('public', 'fresh') for seed in ('empty', 'outer', 'main')]:
            return False
        for item in seeds['rows']:
            expected_host = dict(outer={'outer': 'OUTER'} if item['seed'] == 'outer' else {}, main={'main': 'MAIN'} if item['seed'] == 'main' else {})
            if not same(item['value'], 0) or item['error'] or item['warnings'] or item['host_before'] != expected_host or item['host_after'] != expected_host:
                return False
    return True


def validate(rows, cases, failing):
    assert list(rows) == [r['id'] for r in cases], 'complete ordered observations'
    assert {r['id'] for r in cases if not target(r, rows[r['id']])} == failing, 'exact authored domain/seed target'


def source_delta(before, after):
    assert before == subprocess.check_output(['git', 'show', ACTIVATION + ':' + OWNER]), 'actual historical source boundary'
    source = before.decode()
    for old, new in [
        ("defined($hash_symbol) &&\n   length($hash_symbol) &&\n   $target_expr =~ $hash_symbol_expr_re &&\n   (($target_kind // '') ne 'scalar')", "defined($hash_symbol) &&\n   $hash_symbol =~ /\\A[A-Za-z_][A-Za-z0-9_]*\\z/o &&\n   $target_expr =~ $hash_symbol_expr_re &&\n   (($target_kind // '') ne 'scalar')"),
        ("defined($__ls_count_keys) ? scalar(keys %{$__ls_count_keys})", "ref($__ls_count_keys) eq \\'HASH\\' ? scalar(keys %{$__ls_count_keys})"),
    ]:
        assert source.count(old) == 1
        source = source.replace(old, new)
    assert after == source.encode(), 'only two CountKeys producer clauses change'


def check_modules(bodies, frames):
    assert bodies.keys() == frames.keys(), 'all actual module/carrier inputs present'
    assert all(bodies[k] == frames[k] for k in bodies), 'persisted bytes precede execution/loading'


def main():
    epochs = {p: recover(p) for p in ('before', 'after', 'nearest')}
    cases = json.loads(epochs['before'][FIXTURE])
    assert len(cases) == 23 and len({c['id'] for c in cases}) == 23
    assert all(e[FIXTURE] == epochs['before'][FIXTURE] for e in epochs.values())
    assert epochs['before'][NORMAL] == epochs['after'][NORMAL], 'unchanged RED/GREEN normal'
    assert (ROOT / NORMAL).read_bytes() == epochs['nearest'][NORMAL]
    assert (ROOT / FIXTURE).read_bytes() == epochs['nearest'][FIXTURE]
    assert epochs['after'][OWNER] == epochs['nearest'][OWNER]
    source_delta(epochs['before'][OWNER], epochs['after'][OWNER])
    for phase in ('after', 'nearest'):
        assert epochs[phase].keys() == epochs['before'].keys()
        assert all(body == epochs['before'][name] for name, body in epochs[phase].items() if name not in (OWNER, NORMAL))
    # The final normal only drops an unused optional-test branch after GREEN.
    final = epochs['after'][NORMAL].decode().replace('    my $unsupported = [];\n', '').replace('    $unsupported //= [];\n', '')
    start = final.index('        if (@$unsupported) {')
    end = final.index('\n    };', start)
    final = final[:start] + "        is($meta->{unresolved_helper_count}, 0, 'ordinary sources resolve');\n        ok($meta->{language_agnostic_action_ir_ready}, 'readiness accompanies actual execution');" + final[end:]
    assert epochs['nearest'][NORMAL] == final.encode(), 'exact nonbehavioral normal simplification'
    observations_by_phase = {p: observations(p) for p in epochs}
    validate(observations_by_phase['before'], cases, RED)
    validate(observations_by_phase['after'], cases, set())
    validate(observations_by_phase['nearest'], cases, set())
    healthy = [c['id'] for c in cases if c['id'] not in RED]
    assert all(same(observations_by_phase['before'][k], observations_by_phase['after'][k]) for k in healthy)
    assert same(observations_by_phase['after'], observations_by_phase['nearest'])
    for phase in epochs:
        exit_code = int((BASE / phase / 'normal-exit.txt').read_text())
        assert exit_code == (1 if phase == 'before' else 0)
        output = raw(BASE / phase / 'normal-stdout.log').decode()
        assert ('Tests=37' if phase == 'nearest' else 'Tests=23') in output
        frames = {}
        for line in output.splitlines():
            line = line.strip()
            for tag, prefix, suffix, field in [('KEY_COUNT_DOMAIN_INPUT ', 'module-', '.pm.gz', 'emitted'), ('KEY_COUNT_DOMAIN_PUBLIC ', 'public-', '.pl.gz', 'carrier')]:
                if line.startswith(tag):
                    number, body = line[len(tag):].split(' ', 1)
                    name = prefix + number + suffix
                    assert name not in frames
                    payload = json.loads(body)
                    if field == 'emitted': assert payload['source'] == cases[int(number) - 1]['source']
                    frames[name] = payload[field].encode()
        records = json.loads((BASE / phase / 'module-identities.json').read_text())
        bodies = {}
        for name, item in records.items():
            path = ROOT / name; capsule = path.read_bytes(); body = gzip.decompress(capsule)
            assert digest(capsule) == item['sha256'] and path.stat().st_mode & 0o777 == item['mode']
            assert digest(body) == item['raw_sha256'] and len(body) == item['raw_bytes']
            bodies[path.name] = body
        assert len(bodies) == 25
        check_modules(bodies, frames)
    raw_records = json.loads((BASE / 'raw-identities.json').read_text())
    assert len(raw_records) == 8
    for name, item in raw_records.items():
        capsule = (ROOT / item['capsule']).read_bytes(); body = raw(Path(name))
        assert digest(capsule) == item['capsule_sha256'] and digest(body) == item['sha256'] and len(body) == item['bytes']
    assert (BASE / 'after/owner-syntax-exit.txt').read_text().strip() == '0'
    controls = []
    def rejects(name, operation):
        try: operation()
        except (AssertionError, KeyError, ValueError): controls.append(name)
        else: raise AssertionError('ineffective control ' + name)
    rows = copy.deepcopy(observations_by_phase['after']); rows.pop('free_array')
    rejects('missing-row', lambda: validate(rows, cases, set()))
    rows = copy.deepcopy(observations_by_phase['after']); rows['free_false']['native'] = False
    rejects('false-as-number', lambda: validate(rows, cases, set()))
    rows = copy.deepcopy(observations_by_phase['after']); rows['free_number']['seeds']['rows'][2]['value'] = 1
    rejects('numeric-host-read', lambda: validate(rows, cases, set()))
    rows = copy.deepcopy(observations_by_phase['after']); rows['receiver_number']['seeds']['rows'][2]['host_after']['main']['extra'] = 1
    rejects('host-data-change', lambda: validate(rows, cases, set()))
    changed = dict(bodies); changed['module-1.pm.gz'] += b'\n'
    rejects('changed-module', lambda: check_modules(changed, frames))
    rejects('forged-source-boundary', lambda: source_delta(epochs['before'][OWNER] + b'\n', epochs['after'][OWNER]))
    print(json.dumps(dict(before='10PASS/13RED', after='23PASS', nearest='37PASS', healthy_exact=len(healthy), localized_seed_rows=12, rejected_controls=controls, result='PASS'), sort_keys=True))


if __name__ == '__main__': main()
