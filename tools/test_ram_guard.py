#!/usr/bin/env python3
"""Deterministic RAM-preflight controls; all fixtures stay on managed storage."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
CAPACITY = 25769803776
STATS = '''Mach Virtual Memory Statistics: (page size of 16384 bytes)
Pages free:                               262144.
Pages inactive:                           393216.
Pages speculative:                        131072.
'''
PRESSURE = 'The system has 25769803776 (1572864 pages with a page size of 16384).\nSystem-wide memory free percentage: 50%\n'


def check(command, environment, expected_code, expected_used=None, vm_calls=None, pressure_calls=None):
    trace = Path(environment['RAM_TEST_TRACE'])
    marker = Path(environment['RAM_TEST_MARKER'])
    trace.write_text('')
    marker.unlink(missing_ok=True)
    result = subprocess.run(command, cwd=ROOT, env=environment, capture_output=True, text=True)
    calls = trace.read_text().splitlines()
    observation = dict(command=command, code=result.returncode, stdout=result.stdout, stderr=result.stderr,
                       calls=calls, child_ran=marker.exists())
    print(json.dumps(observation, sort_keys=True))
    assert result.returncode == expected_code, 'admission/child exit'
    if expected_used is not None:
        assert f'RAM {expected_used}% used' in result.stdout + result.stderr, 'capacity/snapshot arithmetic'
    if vm_calls is not None:
        assert calls.count('vm_stat') == vm_calls, 'one vm_stat snapshot'
    if pressure_calls is not None:
        assert calls.count('memory_pressure') == pressure_calls, 'capacity fallback selection'
    assert marker.exists() == (expected_code not in (2, 77)), 'child admission'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--legacy-red', type=Path)
    args = parser.parse_args()
    run = Path(os.environ.get('LINKEDSPEC_RUN_DIR', ''))
    if (os.environ.get('LINKEDSPEC_RUN_ACTIVE') != '1' or not run.is_absolute()
            or not run.is_dir() or run.is_symlink() or not run.resolve().is_relative_to(ROOT)
            or run.stat().st_dev != ROOT.stat().st_dev):
        parser.error('run through tools/run_python_project_data.sh in managed repository storage')
    with tempfile.TemporaryDirectory(prefix='ram-guard-', dir=run) as directory:
        work = Path(directory)
        assert work.stat().st_dev == ROOT.stat().st_dev
        commands = work / 'commands'
        commands.mkdir()
        bodies = {
            'uname': 'printf "%s\\n" "${RAM_TEST_PLATFORM:-Darwin}"\n',
            'pagesize': 'printf "16384\\n"\n',
            'sysctl': 'printf "sysctl\\n" >> "$RAM_TEST_TRACE"\nif [[ "$RAM_TEST_SYSCTL" == deny ]]; then printf "Operation not permitted\\n" >&2; exit 1; fi\nprintf "%s\\n" "$RAM_TEST_SYSCTL"\n',
            'memory_pressure': 'printf "memory_pressure\\n" >> "$RAM_TEST_TRACE"\n/bin/cat "$RAM_TEST_PRESSURE"\nexit "${RAM_TEST_PRESSURE_EXIT:-0}"\n',
            'vm_stat': 'printf "vm_stat\\n" >> "$RAM_TEST_TRACE"\n/bin/cat "$RAM_TEST_VM"\nexit "${RAM_TEST_VM_EXIT:-0}"\n',
            'cat': 'if [[ "$1" == /proc/meminfo ]]; then /bin/cat "$RAM_TEST_LINUX"; else /bin/cat "$@"; fi\n',
        }
        for name, body in bodies.items():
            path = commands / name
            path.write_text('#!/bin/bash\nset -eu\n' + body)
            path.chmod(0o755)
        stats = work / 'vm-stat.txt'
        pressure = work / 'pressure.txt'
        linux = work / 'meminfo.txt'
        stats.write_text(STATS)
        pressure.write_text(PRESSURE)
        linux.write_text('MemTotal: 25165824 kB\nMemAvailable: 12582912 kB\n')
        environment = dict(os.environ, PATH=str(commands) + os.pathsep + os.environ['PATH'],
                           RAM_TEST_PLATFORM='Darwin', RAM_TEST_SYSCTL='deny',
                           RAM_TEST_TRACE=str(work / 'calls.txt'), RAM_TEST_MARKER=str(work / 'child'),
                           RAM_TEST_PRESSURE=str(pressure), RAM_TEST_VM=str(stats), RAM_TEST_LINUX=str(linux),
                           RAM_TEST_PRESSURE_EXIT='0', RAM_TEST_VM_EXIT='0')
        wrapper = (args.legacy_red.resolve() if args.legacy_red else ROOT / 'tools/ram_guard.sh')
        child = ['/bin/bash', '-c', ': > "$RAM_TEST_MARKER"; exit "${RAM_TEST_CHILD_EXIT:-0}"']

        def run(expected_code=0, used=50, danger=88, vm=1, fallback=1, **overrides):
            selected = dict(environment, **overrides)
            check(['bash', str(wrapper), '--ceiling-mb', '512', '--danger-pct', str(danger), '--'] + child,
                  selected, expected_code, used, vm, fallback)

        if args.legacy_red:
            # At known24GiB with12GiB available, the old16GiB fallback reports25%,
            # admits the child below40%, and obtains three separate snapshots.
            run(expected_code=77, used=50, danger=40)
            raise AssertionError('old implementation unexpectedly satisfied the repaired contract')

        run()
        run(fallback=0, RAM_TEST_SYSCTL=str(CAPACITY))
        run(expected_code=77, danger=40)
        run(expected_code=19, RAM_TEST_CHILD_EXIT='19')
        for value in ('0', '', 'not-a-size'):
            run(RAM_TEST_SYSCTL=value)
        pressure.write_text('unrecognized capacity\n')
        run(expected_code=77, used=None, vm=0)
        pressure.write_text(PRESSURE)
        run(expected_code=77, used=None, vm=0, RAM_TEST_PRESSURE_EXIT='1')
        run(expected_code=77, used=None, RAM_TEST_VM_EXIT='1')
        for bad in (
            STATS.replace('16384 bytes', 'unknown bytes'),
            STATS.replace('Pages free:', 'Pages missing:'),
            STATS + 'Pages free: 1.\n',
            STATS.replace('262144.', '-1.'),
            STATS.replace('262144.', '999999999.'),
        ):
            stats.write_text(bad)
            run(expected_code=77, used=None)
        stats.write_text(STATS.replace('262144.', '0.').replace('393216.', '0.').replace('131072.', '0.'))
        run(expected_code=77, used=100)
        stats.write_text(STATS.replace('262144.', '1572864.').replace('393216.', '0.').replace('131072.', '0.'))
        run(used=0)
        stats.write_text('Mach Virtual Memory Statistics: (page size of 4096 bytes)\nPages free: 1.\nPages inactive: 0.\nPages speculative: 0.\n')
        run(used=67, fallback=0, RAM_TEST_SYSCTL='12288')
        stats.write_text(STATS)
        run(vm=0, fallback=0, RAM_TEST_PLATFORM='Linux')
        linux.write_text('MemTotal: 3 kB\nMemAvailable: 1 kB\n')
        run(used=67, vm=0, fallback=0, RAM_TEST_PLATFORM='Linux')
        for bad in ('MemTotal: 0 kB\nMemAvailable: 1 kB\n', 'MemTotal: 3 kB\n',
                    'MemTotal: 3 kB\nMemAvailable: 4 kB\n'):
            linux.write_text(bad)
            run(expected_code=77, used=None, vm=0, fallback=0, RAM_TEST_PLATFORM='Linux')
        run(expected_code=77, used=None, vm=0, fallback=0, RAM_TEST_PLATFORM='Unsupported')
        print('RAM preflight deterministic controls: PASS')


if __name__ == '__main__':
    main()
