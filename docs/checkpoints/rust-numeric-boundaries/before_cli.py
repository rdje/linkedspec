"""Fresh public baseline before any numeric runtime mutation."""
import json
import os
from pathlib import Path
import subprocess
import common as c

PERL = r'''use JSON::PP;my $s=$ARGV[0];my %ctx;my $p=eval{LinkedSpec::Get(\$s,runtime_ctx_ref=>\%ctx)};my $ce="$@";my $in="xhello";my $v;my $ie="";if(ref($p)eq"CODE"){$v=eval{$p->(\$in)};$ie="$@"}print JSON::PP->new->canonical->allow_nonref->encode({compiled=>ref($p)eq"CODE"?1:0,value=>$v,compile_exception=>$ce,invoke_exception=>$ie,last_error=>$ctx{last_error}}),"\n";'''


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=c.ROOT, text=True).strip() == c.BASE
    assert not subprocess.check_output(['git', 'diff', '--name-only', '--', 'rust'], cwd=c.ROOT)
    supplied = c.context()
    cases = []
    for name, expr in [('small', '42'), ('large-positive', '100000000000000000000'),
                       ('large-negative', '-100000000000000000000'),
                       ('text-control', 'cat(100000000000000000000,"")')]:
        cases.append(dict(name=name, expression=expr,
            source='Top::\n I { return('+expr+') }\n /x/ -> Done\nDone:\n /[a-z]+/\n'))
    c.save('before-cli-inputs.json.gz', dict(context=supplied, cases=cases, perl_program=PERL,
        scope='Four current public source controls before runtime changes. JSON numeric preservation is the selected defect; the distinct text-spelling row remains .55.2-owned and supplies no normative portable spelling decision.'))
    build = c.run(['bash', 'tools/run_cargo_local.sh', 'build', '--manifest-path', 'rust/Cargo.toml',
        '--locked', '--offline', '-p', 'linkedspec-runtime', '--bin', 'linkedspec-rust',
        '--message-format=json'])
    c.save('before-cli-build.json.gz', build)
    assert build['returncode'] == 0
    executables = []
    for line in c.decode(build['stdout_base64']).splitlines():
        row = json.loads(line)
        if row.get('reason') == 'compiler-artifact' and row.get('executable') \
                and row['target']['name'] == 'linkedspec-rust':
            executables.append(Path(row['executable']))
    assert len(executables) == 1
    executable = executables[0]
    relative = executable.relative_to(c.ROOT).as_posix()
    artifact = c.archive(executable, 'before-cli')
    c.save('before-cli-binary.json', dict(path=relative, artifact=artifact))
    runs = []
    env = os.environ.copy()
    env['PERL5LIB'] = ''
    for case in cases:
        quiet = c.run([str(executable), '--inline-spec', case['source'], '--input', 'xhello', '--trace', 'none'])
        trace = c.run([str(executable), '--inline-spec', case['source'], '--input', 'xhello', '--trace', 'low'])
        perl = c.run(['perl', '-Iperl', '-MLinkedSpec', '-e', PERL, case['source']], env=env)
        result = dict(name=case['name'], rust_quiet=quiet, rust_trace=trace, perl_get=perl)
        c.save('before-cli-'+case['name']+'.json.gz', result)
        runs.append(result)
        assert all(item['returncode'] == 0 for item in [quiet, trace, perl])
    stable = c.identity(relative) == {key: artifact[key] for key in ('sha256', 'mode')}
    inputs_stable = c.unchanged(supplied['inputs'])
    c.save('before-cli-runs.json.gz', dict(runs=runs, executable_unchanged=stable,
        inputs_unchanged=inputs_stable))
    assert stable and inputs_stable
    observed = {}
    for row in runs:
        rust = json.loads(c.decode(row['rust_quiet']['stdout_base64']))
        perl = json.loads(c.decode(row['perl_get']['stdout_base64']))
        assert perl['compiled'] and not perl['compile_exception'] and not perl['invoke_exception']
        assert perl['last_error'] is None
        observed[row['name']] = dict(rust=rust, perl=perl['value'])
    assert observed['small'] == dict(rust=42, perl=42)
    assert observed['large-positive'] == dict(rust=2**63-1, perl=10**20)
    assert observed['large-negative'] == dict(rust=-(2**63), perl=-(10**20))
    c.save('before-cli-result.json.gz', dict(observed=observed,
        scope='Observed current value loss only; trace/Perl complete channels and exact producer/input/binary epoch retained. Text control is .55.2-owned.'))
    print('Current public baseline reconfirms positive/negative finite JSON saturation; small control and complete source/binary custody retained.')


if __name__ == '__main__':
    main()
