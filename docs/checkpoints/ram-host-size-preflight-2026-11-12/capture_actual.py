"""Retain each actual OS response before forwarding it to the RAM producer."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'native-usage'

if len(sys.argv) > 1:
    assert sys.argv[1] == 'record'
    name, *command = sys.argv[2:]
    assert name in ('uname', 'sysctl', 'memory_pressure', 'vm_stat')
    prefix = OUT / name
    assert not prefix.with_suffix('.exit.txt').exists()
    result = subprocess.run(command, capture_output=True)
    prefix.with_suffix('.command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
    for channel in ('stdout', 'stderr'):
        prefix.with_suffix('.' + channel + '.gz').write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    prefix.with_suffix('.exit.txt').write_text(str(result.returncode) + '\n')
    sys.stdout.buffer.write(result.stdout)
    sys.stderr.buffer.write(result.stderr)
    sys.exit(result.returncode)

OUT.mkdir()
commands = OUT / 'commands'
commands.mkdir()
for name in ('uname', 'sysctl', 'memory_pressure', 'vm_stat'):
    native = shutil.which(name)
    assert native and Path(native).is_file()
    path = commands / name
    assert "'" not in native
    path.write_text('#!/bin/bash\nexec "$RAM_CAPTURE_PYTHON" -P "$RAM_CAPTURE_SCRIPT" record ' + name + " '" + native + "' \"$@\"\n")
    path.chmod(0o755)
paths = [Path(__file__).relative_to(ROOT), Path('tools/host_ram_usage.sh'),
         Path('tools/project_data_run.sh'), Path('tools/project_data_env.sh')] + list(commands.iterdir())
identities = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in paths:
        raw = path.read_bytes()
        identities[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
env = dict(os.environ, PATH=str(ROOT / commands) + os.pathsep + os.environ['PATH'],
           RAM_CAPTURE_PYTHON=sys.executable, RAM_CAPTURE_SCRIPT=str(Path(__file__).resolve()))
result = subprocess.run(['bash', 'tools/host_ram_usage.sh'], cwd=ROOT, env=env, capture_output=True)
for channel in ('stdout', 'stderr'):
    (OUT / ('helper-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'helper-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and not result.stderr
read = lambda name: gzip.decompress((OUT / (name + '.stdout.gz')).read_bytes())
assert read('uname').strip() == b'Darwin'
sysctl_code = int((OUT / 'sysctl.exit.txt').read_text())
if sysctl_code == 0 and re.fullmatch(rb'[1-9][0-9]*\n?', read('sysctl')):
    total = int(read('sysctl'))
else:
    match = re.search(rb'^The system has ([0-9]+) ', read('memory_pressure'), re.M)
    assert match and int((OUT / 'memory_pressure.exit.txt').read_text()) == 0
    total = int(match[1])
snapshot = read('vm_stat')
page = re.search(rb'^Mach Virtual Memory Statistics: \(page size of ([0-9]+) bytes\)$', snapshot, re.M)
assert page
counts = []
for key in (b'free', b'inactive', b'speculative'):
    matches = re.findall(rb'^Pages ' + key + rb':\s+([0-9]+)\.$', snapshot, re.M)
    assert len(matches) == 1
    counts.append(int(matches[0]))
available = sum(counts) * int(page[1])
assert 0 <= available <= total
expected = 100 - available * 100 // total
assert int(result.stdout) == expected
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        raw = archive.extractfile(member).read()
        assert hashlib.sha256(raw).hexdigest() == identities[member.name]['sha256']
        assert member.mode & 0o777 == identities[member.name]['mode']
(OUT / 'result.json').write_text(json.dumps(dict(result='PASS', capacity_bytes=total,
    page_size=int(page[1]), available_page_counts=counts, observed_used_percent=expected,
    sysctl_exit=sysctl_code, vm_stat_calls=1,
    scope='One actual availability snapshot; capacity fallback is independently parsed. Not memory_pressure free percentage or live trend/peak safety. Native executable/toolchain/OS closure remains4.2/SESSION5.'), indent=2) + '\n')
print('Actual OS capacity/single-snapshot arithmetic: PASS')
